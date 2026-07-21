# 01 - Installation OpenProject

Depuis [Page docker hub](https://hub.docker.com/r/openproject/openproject)
Depuis [la doc All-In-One de déploiement Docker](https://www.openproject.org/docs/installation-and-operations/installation/docker/)

Le mode [All-In-One](https://www.openproject.org/docs/installation-and-operations/installation/docker/)(ce qui est utilisé dans la présente documentation) convient parfaitement pour trente dev travaillant dessus simultanément. Au dessus de 30 personne, on déploiera OpenProject via [une méthode avec un conteneur par service](https://www.openproject.org/docs/installation-and-operations/installation/docker-compose/)

## Prérequis

### Filtrage WAF

Voici le bloc de filtre positif à ajouter (pour éviter des faux positifs), il faut changer le domaine dans `op.mondomaine.com`.
On lui dit d'ignorer `"native_rule:911100"`.

```yml
  - filter: |
      req.Host == "op.mondomaine.com" &&
      any(evt.Appsec.MatchedRules, #.name == "native_rule:911100")
    apply:
      - SetRemediation("allow")
      - CancelAlert()
      - CancelEvent()
```

On va l'ajouter en liste blanche à custom-config.yaml, dans la partie `on_match`

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
      req.Host == "op.mondomaine.com" &&
      any(evt.Appsec.MatchedRules, #.name == "native_rule:911100")
    apply:
      - SetRemediation("allow")
      - CancelAlert()
      - CancelEvent()
```

On enregistre et on relance crowdsec

```bash
sudo docker exec crowdsec cscli hub update && sudo docker restart crowdsec
```

### Création du répertoire

On prépare un répertoire dans `opt/docker`

```bash
sudo mkdir -p /opt/docker/apps/openproject
cd /opt/docker/apps/openproject
```

### Gestion domaine / sous domaine CloudFlare

On va sur [dashboard de CloudFlare](https://dash.cloudflare.com)

- puis `Domaine / Vue d'ensemble` cliquer sur le domaine
- puis `DNS / Enregistrements`
- cliquer sur le bouton `+ Ajouter un enregistrement`
- Type `A`
- Nom `op.domaine.com`
- Adresse IPv4 `192.0.2.1`
- cliquer sur `Enregistrer`

Remplacer `192.0.2.1` par l'ipv4 du VPS.

### Créer nouveau compte mail MXROUTE

Se connecter au [site de mxroute.com](https://management.mxroute.com/dashboard)

- Dans le menu `dashboard` (par défaut), cliquer sur le bouton `Login to Panel`, et allez sur le menu `Email Accounts`.
- Cliquer sur `+ Create New Email Account`, entrer `noreply` comme username et lui générer un mdp (garder précieusement les identifiants) et cliquer sur `Create Account`.
- La mail généré est `noreply@votrenomdedomaine.com`, attention à ne pas avoir de `$` dans le mot de passe.

### Récupérer le serveur MX de MXROUTE

Se connecter au [site de mxroute.com](https://management.mxroute.com/dashboard)

- Dans le menu `dashboard` (par défaut), cliquer sur le bouton `Login to Panel`, et allez sur le menu `DNS`.
- Dans l'encadré `MX Records` prendre la `VALUE` de celui avec la `PRIORITY` 10 (l'autre est un serveur de secours si le premier est en rade).
- Vous aurez une adresse serveur du genre `machin.mxrouting.net`

Si le compte MXROUTE est bien réglé, et pareil du côté du registrar lors de l'ajout du NDD, il n'y a rien d'autre à faire pour le mailing.

### Générer une clef secrète pour openproject

```bash
openssl rand -hex 64
```

Gardez précieusement la chaîne générée de côté, elle va servir dans le fichier de configuration juste après.

### Générer une clef secrète pour hocuspocus

```bash
openssl rand -hex 64
```

Gardez précieusement la chaîne générée de côté, elle va servir dans le fichier de configuration juste après.

### Générer le compose.yml

```bash
sudo nano compose.yml
```

Et on y colle

```yaml
services:
  openproject:
    image: openproject/openproject:17.6-rc
    container_name: openproject
    restart: unless-stopped
    extra_hosts:
      - "op.mondomaine.com:127.0.0.1"
    environment:
      - OPENPROJECT_URL=http://op.mondomaine.com
      - TZ=Europe/Paris
      - SECRET_KEY_BASE=CLEF_SECRETE_OPENPROJECT
      - OPENPROJECT_HOST__NAME=op.mondomaine.com
      - OPENPROJECT_HTTPS=true
      - OPENPROJECT_DEFAULT__LANGUAGE=fr
      # --- CONFIGURATION HOCUSPOCUS ---
      - OPENPROJECT_COLLABORATIVE__EDITING__HOCUSPOCUS__URL=wss://op.mondomaine.com/hocuspocus
      - OPENPROJECT_COLLABORATIVE__EDITING__HOCUSPOCUS__SECRET=CLEF_SECRETE_HOCUSPOCUS
      # --- CONFIGURATION EMAIL SMTP (MXROUTE) ---
      - OPENPROJECT_SMTP__ADDRESS=NOM_SERVEUR.mxrouting.net
      - OPENPROJECT_SMTP__PORT=587
      - OPENPROJECT_SMTP__DOMAIN=mondomaine.com
      - OPENPROJECT_SMTP__AUTHENTICATION=login
      - OPENPROJECT_SMTP__USER__NAME=noreply@mondomaine.com
      - OPENPROJECT_SMTP__PASSWORD=MOT_DE_PASSE_DU_MAIL
      - OPENPROJECT_SMTP__ENABLE__STARTTLS__AUTO=true
    volumes:
      - openproject_pgdata:/var/openproject/pgdata
      - openproject_assets:/var/openproject/assets
    networks:
      - caddy_network

volumes:
  openproject_pgdata:
  openproject_assets:

networks:
  caddy_network:
    external: true
```

On modifie tous les domaines `mondomaine.com` et on ajoute nos clefs, avant de sauver.

Et on protège l'accès

```bash
sudo chmod 600 /opt/docker/apps/openproject/compose.yml
```

### Redirection avec Caddyfile

```python
sudo nano /opt/docker/caddy/Caddyfile
```

Descendre tout en bas du document (`ALT + /`) et, dans la section dédiée à la **Redirection de domaines**, coller ce bloc de configuration :

```text
op.mondomaine.com {
        import crowdsec_bouncer
        reverse_proxy openproject:80
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
cd /opt/docker/apps/openproject
sudo docker compose up -d
```

On peut suivre l'avancement de l'initialisation (prend plusieurs minutes) avec

```bash
sudo docker compose logs -f openproject
```

Et on attends de voir

```text
=> Booting Puma
```

et ce qui suit

On se connecte sur le navigateur à <https://op.mondomaine.com/>

Pour identifiants: admin
mot de passe: admin: admin

et on change le mdp par un mdp lourd

Changer la timezone dans les options du compte, et mettre paris (sinon l'heure est en retard sur GMT0)

Reste sur le premier onglet principal. Descends tout en bas de cette page.

Dire aux utilisateurs de vérifier le fuseau horaire pour éviter le quiproquo.

## Régler SMTP depuis le menu

Administration → Emails and notifications

Cliquer sur mon avatar -> Administration -> E-mails et notifications -> Notifications par e-mail
