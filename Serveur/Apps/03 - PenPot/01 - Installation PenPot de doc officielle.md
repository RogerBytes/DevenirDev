# 01 - Installation PenPot

Depuis [Page docker hub](https://hub.docker.com/u/penpotapp)
Depuis [la doc du site](https://help.penpot.app/technical-guide/getting-started/docker/)

## Prérequis

### Création du répertoire

On prépare un répertoire dans `opt/docker`

```bash
sudo mkdir -p /opt/docker/apps/penpot
cd /opt/docker/apps/penpot
```

### Récupérer le serveur MX de MXROUTE

On a déjà notre adresse mail `noreply@mondomaine.com`, pas besoin d'en refaire une autre.

Se connecter au [site de mxroute.com](https://management.mxroute.com/dashboard)

- Dans le menu `dashboard` (par défaut), cliquer sur le bouton `Login to Panel`, et allez sur le menu `DNS`.
- Dans l'encadré `MX Records` prendre la `VALUE` de celui avec la `PRIORITY` 10 (l'autre est un serveur de secours si le premier est en rade).
- Vous aurez une adresse serveur du genre `machin.mxrouting.net`

Si le compte MXROUTE est bien réglé, et pareil du côté du registrar lors de l'ajout du NDD, il n'y a rien d'autre à faire pour le mailing.

### CloudFlare R2

#### Créer un compartiment R2

- On va sur [le dashboard de CloudFlare](https://dash.cloudflare.com/) et dans le menu de gauche `Stockage et base de données / Stockage d'objet R2 / Vue d'ensemble`
- cliquer sur `Créer un compartiment`
  - nom du compartiment `penpot-assets`
  - Emplacement `Automatique`
  - Classe de stockage par défaut `Standard`
  - Cliquer sur `Créer un compartiment`

#### Récupérer le jeton du compartiment

On récupère les infos de notre token `R2 Account Token` (fait pour Offen Docker Volume Backup), pas besoin d'en refaire un.

On récupère la note (ou coffre fort VaultWarden) les valeurs des labels suivants

- Valeur du jeton
- ID de clé d’accès
- Clé d’accès secrète
- Utilisez des points de terminaison spécifiques à la juridiction pour les clients S3 : [par défaut]

### Générer une clef secrète pour PenPot

```bash
openssl rand -hex 64
```

Gardez précieusement la chaîne générée de côté, elle va servir dans le fichier de configuration juste après.

### Configuration du conteneur

Si on veut faire avec le template officiel (au lieu d'utiliser le compose tout prêt du guide), on peut utiliser

```bash
sudo wget -O compose.yml https://raw.githubusercontent.com/penpot/penpot/main/docker/images/docker-compose.yaml
```

Ici on va le créer nous-mêmes au lieu de partir du template.

```bash
sudo nano compose.yml
```

Et on met

```yml
x-flags: &penpot-flags
  PENPOT_FLAGS: enable-smtp enable-prepl-server enable-mcp

x-uri: &penpot-public-uri
  PENPOT_PUBLIC_URI: https://draw.mondomaine.com

x-body-size: &penpot-http-body-size
  PENPOT_HTTP_SERVER_MAX_BODY_SIZE: 367001600
  PENPOT_HTTP_SERVER_MAX_MULTIPART_BODY_SIZE: 367001600

x-secret-key: &penpot-secret-key
  PENPOT_SECRET_KEY: CLEF-SECRÈTE-PENPOT

networks:
  penpot:
  caddy_network:
    external: true

volumes:
  penpot_postgres_v15:
  penpot_assets:

services:

  penpot-frontend:
    image: "penpotapp/frontend:${PENPOT_VERSION:-2.16}"
    restart: always

    volumes:
      - penpot_assets:/opt/data/assets

    depends_on:
      - penpot-backend
      - penpot-exporter
      - penpot-mcp

    networks:
      - penpot
      - caddy_network

    environment:
      << : [*penpot-flags, *penpot-http-body-size, *penpot-public-uri]

  penpot-backend:
    image: "penpotapp/backend:${PENPOT_VERSION:-2.16}"
    restart: always

    volumes:
      - penpot_assets:/opt/data/assets

    depends_on:
      penpot-postgres:
        condition: service_healthy
      penpot-valkey:
        condition: service_healthy

    networks:
      - penpot

    environment:
      << : [*penpot-flags, *penpot-public-uri, *penpot-http-body-size, *penpot-secret-key]

      PENPOT_DATABASE_URI: postgresql://penpot-postgres/penpot
      PENPOT_DATABASE_USERNAME: penpot
      PENPOT_DATABASE_PASSWORD: penpot

      PENPOT_REDIS_URI: redis://penpot-valkey/0

      AWS_ACCESS_KEY_ID: ID-R2-CLEF-ACCÈS
      AWS_SECRET_ACCESS_KEY: ID-R2-CLEF-ACCÈS-SECRÈTE
      PENPOT_OBJECTS_STORAGE_BACKEND: s3
      PENPOT_OBJECTS_STORAGE_S3_ENDPOINT: https://ADRESSE-ENDPOINT.r2.cloudflarestorage.com
      PENPOT_OBJECTS_STORAGE_S3_BUCKET: penpot-assets
      PENPOT_OBJECTS_STORAGE_S3_REGION: auto

      PENPOT_TELEMETRY_ENABLED: "false"
      PENPOT_TELEMETRY_REFERER: compose

      PENPOT_SMTP_DEFAULT_FROM: noreply@mondomaine.com
      PENPOT_SMTP_DEFAULT_REPLY_TO: noreply@mondomaine.com
      PENPOT_SMTP_HOST: mymxserver.mxrouting.net
      PENPOT_SMTP_PORT: 465
      PENPOT_SMTP_USERNAME: noreply@mondomaine.com
      PENPOT_SMTP_PASSWORD: MDP-BOITE-MAIL
      PENPOT_SMTP_TLS: "true"
      PENPOT_SMTP_SSL: "true"

  penpot-mcp:
    image: "penpotapp/mcp:${PENPOT_VERSION:-2.16}"
    restart: always
    networks:
      - penpot

  penpot-exporter:
    image: "penpotapp/exporter:${PENPOT_VERSION:-2.16}"
    restart: always

    depends_on:
      penpot-valkey:
        condition: service_healthy

    networks:
      - penpot

    environment:
      << : [*penpot-secret-key, *penpot-public-uri]
      PENPOT_INTERNAL_URI: http://penpot-frontend:8080
      PENPOT_REDIS_URI: redis://penpot-valkey/0

  penpot-postgres:
    image: "postgres:15"
    restart: always
    stop_signal: SIGINT

    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U penpot"]
      interval: 2s
      timeout: 10s
      retries: 5
      start_period: 2s

    volumes:
      - penpot_postgres_v15:/var/lib/postgresql/data

    networks:
      - penpot

    environment:
      - POSTGRES_INITDB_ARGS=--data-checksums
      - POSTGRES_DB=penpot
      - POSTGRES_USER=penpot
      - POSTGRES_PASSWORD=penpot

  penpot-valkey:
    image: valkey/valkey:8.1
    restart: always

    healthcheck:
      test: ["CMD-SHELL", "valkey-cli ping | grep PONG"]
      interval: 1s
      timeout: 3s
      retries: 5
      start_period: 3s

    networks:
      - penpot

    environment:
      - VALKEY_EXTRA_FLAGS=--maxmemory 128mb --maxmemory-policy volatile-lfu
```

### Gestion domaine / sous domaine CloudFlare

On va sur [dashboard de CloudFlare](https://dash.cloudflare.com)

- puis `Domaine / Vue d'ensemble` cliquer sur le domaine
- puis `DNS / Enregistrements`
- cliquer sur le bouton `+ Ajouter un enregistrement`
- Type `A`
- Nom `draw.domaine.com`
- Adresse IPv4 `192.0.2.1`
- cliquer sur `Enregistrer`

Remplacer `192.0.2.1` par l'ipv4 du VPS.

### Redirection avec Caddyfile

```python
sudo nano /opt/docker/caddy/Caddyfile
```

Descendre tout en bas du document (`ALT + /`) et, dans la section dédiée à la **Redirection de domaines**, coller ce bloc de configuration :

```text
draw.mondomaine.com {
        import crowdsec_bouncer
        reverse_proxy penpot-frontend:8080
}
```

Sauvegarder et fermer.

Aligner le formatage de Caddy

```bash
sudo docker compose -f /opt/docker/caddy/compose.yml exec -w /etc/caddy caddy caddy fmt --overwrite
```

Recharger la configuration de Caddy à chaud pour qu'il prenne en compte le nouveau domaine

```bash
sudo docker compose -f /opt/docker/caddy/compose.yml exec -w /etc/caddy caddy caddy reload
```

## Installation du conteneur

```bash
cd /opt/docker/apps/penpot
sudo docker compose up -d
```

On peut suivre l'avancement de l'initialisation (prend plusieurs minutes) avec

```bash
sudo docker compose logs -f penpot-backend
```

Et on attends de voir

```text
penpot-backend-1  | [2026-07-02 15:04:47.613] I app.worker.runner - hint="started", id="webhooks/0", queue="webhooks"
```

On se connecte sur le navigateur à

```url
https://draw.mondomaine.com/
```

## Gestion utilisateurs

### Créer un utilisateur

```bash
sudo docker exec -ti penpot-penpot-backend-1 python3 manage.py create-profile
```

ou

```bash
sudo docker exec -ti penpot-penpot-backend-1 python3 manage.py create-profile --skip-tutorial --skip-walkthrough
```

### Lister les users

```bash
sudo docker compose exec penpot-postgres psql -U penpot -d penpot -c "SELECT id, email FROM profile;"
```

### Supprimer un user

Il y a juste l'adresse à modifier à la fin.

```bash
sudo docker compose exec penpot-postgres psql -U penpot -d penpot -c "SET rules.deletion_protection TO off; DELETE FROM profile WHERE email='yves.quatre@gmail.com';"
```

## Identifier des erreurs de CrowdSec

Ici par exemple avec penpot, si regarder les logs en direct, par exemple avec une erreur muette, dont on cherche à comprendre d'où elle provient.

```bash
sudo docker compose logs -f penpot-backend
```

Si rien ne s'affiche lorsque l'erreur se produit sur le site, c'est très probablement l'AppSec de CrowdSec le responsable et non le conteneur.

### Voir les blocages AppSec en temps réel

So on veut afficher les mesures AppSec prises en temps réel, à partir de l'instant T.

```bash
sudo docker compose -f /opt/docker/crowdsec/compose.yml logs -f --tail=0 crowdsec 2>&1 | grep -i appsec
```

On essaie de provoquer l'erreur, ça un heartbeat (pas sûr qu'il apparaisse mais bref)

```bash
crowdsec  | time="2026-07-13T11:22:40Z" level=info msg="127.0.0.1 - [Mon, 13 Jul 2026 11:22:40 UTC] \"HEAD /v1/decisions/stream HTTP/1.1 200 759.881µs \"appsec/v1.7.8-63227459-docker\" \"" module=lapi
```

### Lister les alertes

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
      req.Host == "draw.rogerbytes.com" &&
      any(evt.Appsec.MatchedRules, #.name == "native_rule:920420")
    apply:
      - SetRemediation("allow")
      - CancelAlert()
      - CancelEvent()
  - filter: |
      req.Host == "draw.rogerbytes.com" &&
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

## Problème erreur interne avec plein de 404 dans l'inspecteur navi

Apparemment CloudFlare aurait gardé en cache des trucs (d'où les erreurs dans la console du navigfateur) claude me dit de purger le cache de CloudFlare

Donc dans CloudFlare, je vais sur mon domaine, puis `Caching/Configuration` et cliquer sur `Vider tous les éléments`

## Problème d'erreur CSS

```bash
sudo docker compose exec penpot-frontend find / -iname "ui.css" 2>/dev/null
```

Semble inoffensif (l'interface fonctionne normalement malgré l'erreur console)
