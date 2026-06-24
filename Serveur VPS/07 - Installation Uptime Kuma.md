# 07 - Installation Uptime Kuma

- Depuis [Page docker hub](https://hub.docker.com/hardened-images/catalog/dhi/uptime-kuma)

Ce document détaille l'installation et la configuration de Watchtower pour automatiser la mise à jour invisible et quotidienne de tous les conteneurs Docker.

## Prérequis

### Création du répertoire

On prépare un répertoire dans `opt/docker`

```bash
sudo mkdir -p /opt/docker/utils/uptime-kuma
cd /opt/docker/utils/uptime-kuma
```

### Création du `compose.yml`

On créé le `compose.yml`

```bash
sudo nano compose.yml
```

et on colle

```yaml
services:
  uptime-kuma:
    image: louislam/uptime-kuma:2
    container_name: uptime-kuma
    restart: unless-stopped
    ports:
      - "3001:3001"
    volumes:
      - ./data:/app/data
      - /var/run/docker.sock:/var/run/docker.sock:ro
```

Et enregistrer le fichier.

## Création du conteneur

Et on lance le `compose up`

```bash
sudo docker compose up -d
```

Voilà, il va mettre les conteneurs Docker à jour automatiquement tous les 24 heures.

## Redirection Caddie

Pour pouvoir consulter `Uptime Kuma`, on passe par un sous domaine

### Créer un sous domaine avec CloudFlare

Maintenant que nous avons au moins deux IP bannie, on vérifie le bon fonctionnement de l'API CloudFlare utilisée par Fail2Ban

- On peut aller voir [le dashboard de CloudFlare](https://dash.cloudflare.com/) et dans le menu de gauche `Domaines/Vue d'ensemble` on clique sur le domaine concerné
- Dans le menu de gauche `DNS/Enregistrements` et cliquer sur `+ Ajouter un enregistrement`
  - Type = `A`
  - Nom = `uptime.mondomaine.com`
  - Adresse IPv4 = `192.0.2.1`
  - Cliquer sur `Enregistrer`

### Caddyfile

```bash
sudo nano /opt/docker/caddy/Caddyfile
```

A la fin du document (`ALT + /`), dans la partie `Redirection de domaines` coller (en mettant votre nom de domaine)

```text
http://uptime.mondomaine.com {
    import fail2ban_logs
    reverse_proxy 127.0.0.1:3001
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

## Configurer Uptime Kuma via le navigateur

### Choix de DB

On va sur <https://uptime.mondomaine.com>, on choisi `Embedded MariaDB`

### Création du compte admin

On s'inscrit normalement.

### Notifications

JE FINIS CA DEMAIN, LA J'EN AI PLEIN LE CUL

- Cliquer sur son profil (en haut à droite) et `Paramètres`
- Aller dans l'onglet `Notification` et `Créer une notification`

### Ajout de sonde

- Cliquer sur le bouton `+ Ajouter une nouvelle sonde`
- Type de sonde `HTTP(s)`
- Nom d'affichage `mondomaine.com`
- Cliquer sur `Enregistrer`