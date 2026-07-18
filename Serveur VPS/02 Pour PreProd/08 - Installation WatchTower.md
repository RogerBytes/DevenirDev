# 08 - Installation WatchTower

C'est à installer sur un VPS de **PreProd**, ne **pas l'installer en prod**, et en pre prod ne pas vérifier les compose avec SHA pinning, sinon il ne fera pas.

- Depuis [Page docker hub](https://hub.docker.com/r/containrrr/watchtower)

Ce document détaille l'installation et la configuration de Watchtower pour automatiser la mise à jour invisible et quotidienne de tous les conteneurs Docker.

## Prérequis

### Création du répertoire

On prépare un répertoire dans `opt/docker`

```bash
sudo mkdir -p /opt/docker/utils/watchtower
cd /opt/docker/utils/watchtower
```

### Création du `compose.yml`

On créé le `compose.yml`

```bash
sudo nano compose.yml
```

et on colle

```yaml
services:
  watchtower:
    image: containrrr/watchtower:latest
    container_name: watchtower
    restart: unless-stopped
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
    environment:
      - WATCHTOWER_CLEANUP=true
      - WATCHTOWER_POLL_INTERVAL=86400
      - DOCKER_API_VERSION=1.40
```

Et enregistrer le fichier.

## Création du conteneur

Et on lance le `compose up`

```bash
sudo docker compose up -d
```

Voilà, il va mettre les conteneurs Docker à jour automatiquement tous les 24 heures.

## Voir ses logs

```bash
sudo docker compose logs --tail=50
```

## A FINIR FONCTIONNEMENT LISTE BLANCHE

```yaml
environment:
  - WATCHTOWER_CLEANUP=true
  - WATCHTOWER_POLL_INTERVAL=86400
  - DOCKER_API_VERSION=1.40
  - WATCHTOWER_LABEL_ENABLE=true
```

sur **chaque conteneur autorisé à se mettre à jour**, ajouter ce label dans son `compose.yml` :

```yaml
labels:
  - "com.centurylinklabs.watchtower.enable=true"
```

S'il n'y a pas ce label, pas de màj auto.
