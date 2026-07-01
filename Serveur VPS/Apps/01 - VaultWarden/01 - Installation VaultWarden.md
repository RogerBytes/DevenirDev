# 01 - Installation VaultWarden

Depuis [Page docker hub](https://hub.docker.com/r/vaultwarden/server)
Depuis [Page GitHub](https://github.com/dani-garcia/vaultwarden)

- A plusieurs moments l'ipv4 utilisé pour SSH est `192.0.2.1`, prenez garde à bien le changer par le votre, en passant `192.0.2.1` est une IP de test réservée aux exemples, elle ne fonctionnera pas pour votre serveur.

## Prérequis

### Création du répertoire

On prépare un répertoire dans `opt/docker`

```bash
sudo mkdir -p /opt/docker/apps/vaultwarden
cd /opt/docker/apps/vaultwarden
```

### Gestion  domaine / sous domaine CloudFlare

On va sur [dashboard de CloudFlare](dash.cloudflare.com)

- puis `Domaine / Vue d'ensemble` cliquer sur le domaine
- puis `DNS / Enregistrements`
- cliquer sur le bouton `+ Ajouter un enregistrement`
- Type `A`
- Nom `sous.domaine.com`
- Adresse IPv4 `192.0.2.1`
- cliquer sur `Enregistrer`

Remplacer `192.0.2.1` par l'ipv4 du VPS.

### Créer nouveau compte mail MXROUTE

Se connecter au [site de mxroute.com](https://management.mxroute.com/dashboard)

- Dans le menu `dashboard` (par défaut), cliquer sur le bouton `Login to Panel`, et allez sur le menu `Email Accounts`.
- Cliquer sur `+ Create New Email Account`, entrer `vault` comme username et lui générer un mdp (garder précieusement les identifiants) et cliquer sur `Create Account`.
- La mail généré est `vault@votrenomdedomaine.com`

### Créer un token

Créer un token avec une bonne entropie est indispensable (utiliser le générateur de mdo de KeePassXC par exemple), il faut conserver ce token précieusement dans `KeePassXC`.

Au lieu de laisser le token en clair sur le .env, on peut utiliser un hash `Argon2id PHC` du mot de passe

```bash
sudo docker run --rm -it vaultwarden/server /vaultwarden hash
```

Garder la ligne retournée, on va s'en servir juste après.

### Récupérer le serveur MX de MXROUTE

Se connecter au [site de mxroute.com](https://management.mxroute.com/dashboard)

- Dans le menu `dashboard` (par défaut), cliquer sur le bouton `Login to Panel`, et allez sur le menu `DNS`.
- Dans l'encadré `MX Records` prendre la `VALUE` de celui avec la `PRIORITY` 10 (l'autre est un serveur de secours si le premier est en rade).
- Vous aurez une adresse serveur du genre `machin.mxrouting.net`

Si le compte MXROUTE est bien réglé, et pareil du côté du registrar lors de l'ajout du NDD, il n'y a rien d'autre à faire pour le mailing.

On en profite pour créer une boite mail `vault@votrenomdedomaine.com`, attention à ne pas avoir de `$` dans le mot de passe.

### Création du .env

On créé le fichier d'environment (il contiendra les variables d'auth)

```bash
sudo nano .env
```

Et on y ajoute ce qui suit

```ini
ADMIN_TOKEN="ici le hash qu'on a créé, on remplace toute la ligne"
MX_SERVER=machin.mxrouting.net
MX_EMAIL=vault@votrenomdedomaine.com
MX_PASSWORD="LeMotDePasseDeCetteBoiteMail"
DOMAIN=https://ton-domaine.com
```

Voici les explications du `.env`, à ne pas utiliser tel quel (c'est juste pour savoir quelles données modifier dans le template au-dessus)

```ini
ADMIN_TOKEN=MonSuperMotDePasseSecret123! # <--- À remplacer par votre token
MX_SERVER=machin.mxrouting.net # <--- À remplacer par le serveur mxroute
MX_EMAIL=vault@votrenomdedomaine.com # <--- À remplacer par l'email d'envoi
MX_PASSWORD='LeMotDePasseDeCetteBoiteMail' # <--- À remplacer par le mot de passe de la boite mail
DOMAIN=https://sous.domaine.com # <--- À remplacer `sous.domaine.com` par le domaine / sous-domaine
```

Avant d’enregistrer, on change correctement les valeurs des différentes variables.

### Caddyfile

```bash
sudo nano /opt/docker/caddy/Caddyfile
```

A la fin du document (`ALT + /`), dans la partie `Redirection de domaines` coller (en mettant votre nom de domaine)

```text
vw.mondomaine.com {
        import crowdsec_bouncer
        reverse_proxy vaultwarden:80
}
```

on utilise le formateur intégré avec

```bash
sudo docker compose -f /opt/docker/caddy/compose.yml exec -w /etc/caddy caddy caddy fmt --overwrite
```

et on relance caddy

```bash
sudo docker compose -f /opt/docker/caddy/compose.yml exec -w /etc/caddy caddy caddy reload
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
      - DOMAIN=${DOMAIN}
      - SIGNUPS_ALLOWED=false
      - INVITATIONS_ALLOWED=true
      - ADMIN_TOKEN=${ADMIN_TOKEN}
      - SMTP_HOST=${MX_SERVER}
      - SMTP_FROM=${MX_EMAIL}
      - SMTP_PORT=465
      - SMTP_SECURITY=force_tls
      - SMTP_USERNAME=${MX_EMAIL}
      - SMTP_PASSWORD=${MX_PASSWORD}
    volumes:
      - ./data:/data
    networks:
      - caddy_network

networks:
  caddy_network:
    external: true
```

```yaml
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
```

Et enregistrer le fichier.

## Création du conteneur

Et on lance le `compose up`

```bash
sudo docker compose up -d
```

Voilà, notre **VaultWarden** est correctement déployé et paramétré !
