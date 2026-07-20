# 01 - Installation VaultWarden

Depuis [Page docker hub](https://hub.docker.com/r/vaultwarden/server)
Depuis [Page GitHub](https://github.com/dani-garcia/vaultwarden)

- A plusieurs moments l'ipv4 utilisé pour SSH est `192.0.2.1`, prenez garde à bien le changer par le votre, en passant `192.0.2.1` est une IP de test réservée aux exemples, elle ne fonctionnera pas pour votre serveur.

## Prérequis

### Filtrage WAF

Voici les 3 blocs de filtres positifs à ajouter (pour éviter des faux positifs), il faut changer le domaine dans `draw.mondomaine.com`.
On lui dit d'ignorer `"native_rule:911100"`, `"native_rule:932125"`, `"native_rule:932235"` et  `"native_rule:932230"`.

```yml
  - filter: |
      req.Host == "vw.mondomaine.com" &&
      any(evt.Appsec.MatchedRules, #.name == "native_rule:911100")
    apply:
      - SetRemediation("allow")
      - CancelAlert()
      - CancelEvent()
  - filter: |
      req.Host == "vw.mondomaine.com" &&
      any(evt.Appsec.MatchedRules, #.name == "native_rule:932125")
    apply:
      - SetRemediation("allow")
      - CancelAlert()
      - CancelEvent()
  - filter: |
      req.Host == "vw.mondomaine.com" &&
      any(evt.Appsec.MatchedRules, #.name == "native_rule:932235")
    apply:
      - SetRemediation("allow")
      - CancelAlert()
      - CancelEvent()
  - filter: |
      req.Host == "vw.mondomaine.com" &&
      any(evt.Appsec.MatchedRules, #.name == "native_rule:932230")
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
      req.Host == "vw.mondomaine.com" &&
      any(evt.Appsec.MatchedRules, #.name == "native_rule:911100")
    apply:
      - SetRemediation("allow")
      - CancelAlert()
      - CancelEvent()
  - filter: |
      req.Host == "vw.mondomaine.com" &&
      any(evt.Appsec.MatchedRules, #.name == "native_rule:932125")
    apply:
      - SetRemediation("allow")
      - CancelAlert()
      - CancelEvent()
  - filter: |
      req.Host == "vw.mondomaine.com" &&
      any(evt.Appsec.MatchedRules, #.name == "native_rule:932235")
    apply:
      - SetRemediation("allow")
      - CancelAlert()
      - CancelEvent()
  - filter: |
      req.Host == "vw.mondomaine.com" &&
      any(evt.Appsec.MatchedRules, #.name == "native_rule:932230")
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
sudo mkdir -p /opt/docker/apps/vaultwarden
cd /opt/docker/apps/vaultwarden
```

### Gestion domaine / sous domaine CloudFlare

On va sur [dashboard de CloudFlare](dash.cloudflare.com)

- puis `Domaine / Vue d'ensemble` cliquer sur le domaine
- puis `DNS / Enregistrements`
- cliquer sur le bouton `+ Ajouter un enregistrement`
- Type `A`
- Nom `vw.domaine.com`
- Adresse IPv4 `192.0.2.1`
- cliquer sur `Enregistrer`

Remplacer `192.0.2.1` par l'ipv4 du VPS.

### Générer une clef secrète pour VaultWarden

```bash
openssl rand -hex 32
```

Gardez précieusement la chaîne générée de côté, elle va servir dans le fichier de configuration juste après.

puis on génère le hash

```bash
sudo docker exec -it vaultwarden /vaultwarden hash
```

et récupérer la ligne

```yml
ADMIN_TOKEN='$argon2id$v=19$m=65540,t=3,p=4$ysIF9qGecYGRkS9Fr1UhzqhnCBi1Tl4axpbc4u5ytE8$S2n7CVZKYv8vRYuL8VYKukqb6J1/oXPDyAdpHFuyNfU'
```

### Mettre le token dans un .env

```bash
sudo nano .env
```

Et on copie toute la ligne hashée (y compris "ADMIN_TOKEN=(...)")

```bash
sudo chmod 600 /opt/docker/apps/vaultwarden/.env
```

### Création du `compose.yml`

On créé le `compose.yml`

```bash
sudo nano compose.yml
```

et on colle

```yaml
services:
  vaultwarden:
    image: vaultwarden/server:latest
    container_name: vaultwarden
    restart: unless-stopped
    environment:
      - DOMAIN=https://vw.mondomaine.com
      - SIGNUPS_ALLOWED=false
      - INVITATIONS_ALLOWED=true
      - ADMIN_TOKEN=${ADMIN_TOKEN}
      - SMTP_HOST=SMTP.MAIL.COM
      - SMTP_FROM=noreply@domaine.com
      - SMTP_PORT=465
      - SMTP_SECURITY=force_tls
      - SMTP_USERNAME=noreply@domaine.com
      - SMTP_PASSWORD=MdpCompteMail
    volumes:
      - ./vw-data:/data
    networks:
      - caddy_network

networks:
  caddy_network:
    external: true
```

Penser à modifier `DOMAIN`, `SMTP_HOST`, `SMTP_FROM`, `SMTP_USERNAME` et `SMTP_PASSWORD`.

Et enregistrer le fichier.

On règle l'accès

```bash
sudo chmod 600 /opt/docker/apps/vaultwarden/compose.yml
```

## Création du conteneur

Et on lance le `compose up`

```bash
sudo docker compose up -d
```

On vérifie le statut du conteneur (permet aussi de voir le port interne qu'utilisera le reverse proxy de Caddy)

```bash
sudo docker compose ps
```

Et on vérifie s'il a bien crée le dossier de stockage

```bash
ls -l
```

il retourne

```bash
total 8
-rw-r--r-- 1 root root  196 Jun 20 19:05 compose.yml
drwxr-xr-x 3 root root 4096 Jun 20 19:06 vw-data
```

## Configurer un reverse proxy avec Caddy

Il suffit de modifier le `Caddyfile` comme on l'a déjà fait.

```bash
sudo nano /opt/docker/caddy/Caddyfile
```

On y ajoute

```plaintext
vw.mondomaine.com {
        import crowdsec_bouncer
        reverse_proxy vaultwarden:80
}
```

On enregistre le fichier puis on vérifie la mise en forme

```bash
sudo docker compose -f /opt/docker/caddy/compose.yml exec -w /etc/caddy caddy caddy fmt --overwrite
```

on actualise la configuration de Caddy

```bash
sudo docker compose -f /opt/docker/caddy/compose.yml exec -w /etc/caddy caddy caddy reload
```

Voilà, l'installation est finie.

Garder le token secret, et passer à la partie 2.
