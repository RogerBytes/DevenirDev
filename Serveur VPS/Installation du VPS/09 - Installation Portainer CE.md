# 09 - Installation Portainer CE

- Depuis [Page docker hub](https://hub.docker.com/r/portainer/portainer-ce)
- Depuis [Page github](https://github.com/portainer/portainer)

Ce document détaille l'installation et la configuration d'Uptime Kuma pour surveiller la disponibilité des sites et applications.

## Prérequis

### Création du répertoire

On prépare un répertoire dans `opt/docker`

```bash
sudo mkdir -p /opt/docker/utils/portainer
cd /opt/docker/utils/portainer
```

### Création du `compose.yml`

On créé le `compose.yml`

```bash
sudo nano compose.yml
```

et on colle

```yaml
services:
  portainer:
    image: portainer/portainer-ce:latest
    container_name: portainer
    restart: always
    ports:
      - "9000:9000"
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - data:/data
    command:
      - "--trusted-origins=docker.rogerbytes.com"

volumes:
  data:
```

Le bloc `volumes` du bas est une espèce d'import (en gros c'est comme s'il faisait `sudo docker volume ls` pour lister les volumes), qui permet au node `backup` de comprendre ce qu'est `vaultwarden-data`

Et enregistrer le fichier.

## Création du conteneur

Et on lance le `compose up`

```bash
sudo docker compose up -d
```

### Créer un sous domaine avec CloudFlare

On crée un enregistrement DNS pour faire pointer notre sous-domaine vers le VPS.

- On peut aller voir [le dashboard de CloudFlare](https://dash.cloudflare.com/) et dans le menu de gauche `Domaines/Vue d'ensemble` on clique sur le domaine concerné
- Dans le menu de gauche `DNS/Enregistrements` et cliquer sur `+ Ajouter un enregistrement`
  - Type = `A`
  - Nom = `docker.mondomaine.com`
  - Adresse IPv4 = `192.0.2.1`
  - Cliquer sur `Enregistrer`

### Caddyfile

```bash
sudo nano /opt/docker/caddy/Caddyfile
```

A la fin du document (`ALT + /`), dans la partie `Redirection de domaines` coller (en mettant votre nom de domaine)

```text
docker.rogerbytes.com {
        import fail2ban_logs
        reverse_proxy 127.0.0.1:9000
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

## Inscription sur site

et on accès à la saloperie avec

docker.rogerbytes.com

et on récupère le token de merde avec

```bash
sudo docker logs portainer 2>&1 | grep "setup_token=" | awk -F "setup_token=" '{print $2}' | cut -d' ' -f1
```

et on fait inscrit son compte de merde

## Réglage sur site

Choisir `Gest Started` et voilà

Ca y est toutes les étapes d'installation de l'infrastructure du serveur sont terminées, on peut installer des applications depuis `Serveur VPS/Apps`.
