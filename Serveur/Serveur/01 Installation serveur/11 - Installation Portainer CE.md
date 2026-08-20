# 11 - Installation Portainer CE

- Depuis [Page docker hub](https://hub.docker.com/r/portainer/portainer-ce)
- Depuis [Page github](https://github.com/portainer/portainer)

Ce document détaille l'installation et la configuration de Portainer CE, permettant de voir le statut des conteneurs à distance.

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
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - data:/data
    command:
      - "--trusted-origins=dash.mondomaine.com"
    networks:
      - caddy_network

volumes:
  data:

networks:
  caddy_network:
    external: true
```

Penser à mettre le bon domaine.

Et enregistrer le fichier.

On règle l'accès

```bash
sudo chmod 600 /opt/docker/utils/portainer/compose.yml
```

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
  - Nom = `dash.mondomaine.com`
  - Adresse IPv4 = `192.0.2.1`
  - Cliquer sur `Enregistrer`

Mettez la bonne adresse IPv4 et le bon nom.

### Caddyfile

```bash
sudo nano /opt/docker/caddy/Caddyfile
```

A la fin du document (`ALT + /`), dans la partie `Redirection de domaines` coller (en mettant votre nom de domaine)

```text
dash.mondomaine.com {
        import crowdsec_bouncer
        reverse_proxy portainer:9000
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

et, si on a du faire une modification sur le compose entre deux

```bash
sudo docker compose -f /opt/docker/caddy/compose.yml restart
```

## Inscription sur site

On se connecte sur <dash.mondomaine.com>

S'il est trop tard pour s'inscrire, on fait

```bash
sudo docker compose restart portainer
```

On remplit le formulaire d'inscription, et pour le token, on utilise

```bash
sudo docker logs portainer 2>&1 | grep "setup_token=" | awk -F "setup_token=" '{print $2}' | cut -d' ' -f1
```

## Réglage sur site

Choisir `Get Started` et voilà

Ca y est toutes les étapes d'installation de l'infrastructure du serveur sont terminées, on peut installer des applications depuis `Serveur VPS/Apps`.

## Stack réglée

On vire les conteneurs et images inutiles

```bash
sudo docker image prune -a
sudo docker system prune -f
```

On vérifie que tout est actif

```bash
sudo docker ps -a
sudo docker ps --format "table {{.Names}}\t{{.Image}}"
```

On doit voir `up`

```bash
portainer/portainer-ce:latest
offen/docker-volume-backup:v2
clamav/clamav-debian:stable
crowdsecurity/cloudflare-worker-bouncer
caddy-caddy
crowdsecurity/crowdsec:latest
```

Vous aurez peut-être en plus watchtower si serveur de test ou de pre-prod.

## Sécurité et CrowdSec

- crowdsec -> moteur de CrowdSec
- cloudflare-worker-bouncer -> permet de lier CrowdSec au compte CloudFlare
- caddy -> version recompilée de Caddy qui contient un bouncer serveur spécifique

En plus, sur la machine, on a le bouncer pour le par-feu, nommé `crowdsec-firewall-bouncer`

On peur vérifier son état

```bash
sudo systemctl status crowdsec-firewall-bouncer
```
