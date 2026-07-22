# 06 - Troubleshooting WAF Appsec

Quand on a une erreur non identifiée, il faut vérifier que le WAF n'est pas responsable

## Vérifier les logs de Caddy

```bash
sudo docker logs --tail 20 caddy
```

Pour voir en direct les logs d'un service, ici pour `penpot-backend`

```bash
sudo docker compose logs -f penpot-backend
```

Si rien ne s'affiche lorsque l'erreur se produit sur le site, c'est très probablement l'AppSec de CrowdSec le responsable et non le conteneur.

## Voir les blocages AppSec en temps réel

So on veut afficher les mesures AppSec prises en temps réel, à partir de l'instant T.

```bash
sudo docker compose -f /opt/docker/crowdsec/compose.yml logs -f --tail=0 crowdsec 2>&1 | grep -i appsec
```

On essaie de provoquer l'erreur, ça un heartbeat (pas sûr qu'il apparaisse mais bref)

```bash
crowdsec  | time="2026-07-13T11:22:40Z" level=info msg="127.0.0.1 - [Mon, 13 Jul 2026 11:22:40 UTC] \"HEAD /v1/decisions/stream HTTP/1.1 200 759.881µs \"appsec/v1.7.8-63227459-docker\" \"" module=lapi
```

## Lister les alertes

On liste les alertes récentes avec

```bash
sudo docker exec -it crowdsec cscli alerts list
```

```bash
$ sudo docker exec -it crowdsec cscli alerts list
╭─────┬──────────────────────────────────────────┬───────────────────────────────────────────┬─────────┬──────────────────────────┬───────────┬──────────────────────┬──────────╮
│  ID │                   value                  │                   reason                  │ country │            as            │ decisions │      created_at      │   kind   │
├─────┼──────────────────────────────────────────┼───────────────────────────────────────────┼─────────┼──────────────────────────┼───────────┼──────────────────────┼──────────┤
│ 840 │ Ip:172.71.126.253                        │ anomaly score block: anomaly: 5,          │ FR      │ 13335 CLOUDFLARENET      │           │ 2026-07-13T11:22:40Z │ waf      │
│ 839 │ Ip:172.71.126.253                        │ anomaly score block: anomaly: 5,          │ FR      │ 13335 CLOUDFLARENET      │           │ 2026-07-13T11:22:03Z │ waf      │
╰─────┴──────────────────────────────────────────┴───────────────────────────────────────────┴─────────┴──────────────────────────┴───────────┴──────────────────────┴──────────╯
```

### Inspecter une alerte avec son ID

ici c'est la 840, donc on fait

```bash
sudo docker exec -it crowdsec cscli alerts inspect 840
```

```bash
$ sudo docker exec -it crowdsec cscli alerts inspect 840
(...)
 - Context  :
╭───────────────┬──────────────────────────────────────────────────────────────╮
│      Key      │                             Value                            │
├───────────────┼──────────────────────────────────────────────────────────────┤
│ (...)         │ (...)                                                        │
│ name          │ native_rule:920420                                           │
│ (...)         │ (...)                                                        │
╰───────────────┴──────────────────────────────────────────────────────────────╯
```

On voit dans `name` la règle `native_rule:920420`, il y a aussi une autre qui arrive après, la `943120` (je passe mais c'est le même procédé, mais avec les cookies de session)

Voici un bloc de filtre positif, il n'y a qu'à modifier `draw.mondomaine.com` et `"native_rule:943120"`

```yml
  - filter: |
      req.Host == "draw.mondomaine.com" &&
      any(evt.Appsec.MatchedRules, #.name == "native_rule:943120")
    apply:
      - SetRemediation("allow")
      - CancelAlert()
      - CancelEvent()
```

On va l'ajouter en liste blanche à custom-config.yaml

```bash
sudo nano /opt/docker/crowdsec/config/appsec-configs/custom-config.yaml
```

```yml
name: custom/custom-config
inband_rules:
  - crowdsecurity/base-config
  - crowdsecurity/vpatch-*
  - crowdsecurity/generic-*
  - crowdsecurity/crs
outofband_rules:
  - crowdsecurity/appsec-generic-test
default_remediation: ban
blocked_http_code: 403
on_match:
  - filter: |
      req.Host == "draw.mondomaine.com" &&
      any(evt.Appsec.MatchedRules, #.name == "native_rule:943120")
    apply:
      - SetRemediation("allow")
      - CancelAlert()
      - CancelEvent()
```

On enregistre et on relance crowdsec

```bash
sudo docker exec crowdsec cscli hub update && sudo docker restart crowdsec
```

On peut ajouter autant de blocs de filtre dans on_match que l'on veut.
