# 08 - Installation Offen Docker Volume Backup

- Depuis [Page docker hub](https://hub.docker.com/r/offen/docker-volume-backup)
- Depuis [Page github](https://github.com/offen/docker-volume-backup)

Ce document détaille l'installation et la configuration d'Uptime Kuma pour surveiller la disponibilité des sites et applications.

## Prérequis

### CloudFlare R2

#### Ouvrir un compte R2

- On va sur [le dashboard de CloudFlare](https://dash.cloudflare.com/) et dans le menu de gauche `Stockage et base de données / Stockage d'objet R2 / Vue d'ensemble`
- Le plan gratuit consiste à un disque dur virtuel gratuit de 10 Go.
  - C'est 0.015$ cent par Go supplémentaire
  - On a 1 millions d'operation classe A (envoi) gratuites et 4.5$ par million en plus
  - On a 10 millions d'operation classe B (lecture) gratuites et 0.36$ par million en plus
- On valide l'inscription `Ajouter un abonnement R2 à mon compte`
- Continuer l'inscription (nécessite CB en cas de dépassement, c'est le service le plus attractif)
- Terminer l'inscription

#### Créer un compartiment R2

- On va sur [le dashboard de CloudFlare](https://dash.cloudflare.com/) et dans le menu de gauche `Stockage et base de données / Stockage d'objet R2 / Vue d'ensemble`
- cliquer sur `Créer un compartiment`
  - nom du compartiment `mon_entreprise-backups`
  - Emplacement `Automatique`
  - Classe de stockage par défaut `Standard`
  - Cliquer sur `Créer le conteneur`

#### Récupérer le jeton du compartiment

- On va sur [le dashboard de CloudFlare](https://dash.cloudflare.com/) et dans le menu de gauche `Stockage et base de données / Stockage d'objet R2 / Vue d'ensemble`
- En bas à droite, aller dans l'encadré `Détails du compte`, et à droite de `Jetons API` cliquer sur `Gérer`
- Cliquer sur le bouton `Créer un jeton d'API de type Account`
  - Nom du jeton `R2 Account Token` (par défaut)
  - Autorisations `Lecture/écriture administrateur`
  - TTL `Indéfiniment`
  - Filtrage d'adresse IP client : on laisse les champs vide, pas besoin
  - Cliquer sur `Créer un jeton d'API de type Account`

Dans la nouvelle page qui s'ouvre, il faut **faire très attention** à ce qui suit

- ne pas fermer la page, et enregistrer dans une note (ou coffre fort VaultWarden) les valeurs des labels suivants
  - Valeur du jeton
  - ID de clé d’accès
  - Clé d’accès secrète
  - Utilisez des points de terminaison spécifiques à la juridiction pour les clients S3 : [par défaut]

### Création du répertoire

On prépare un répertoire dans `opt/docker`

```bash
sudo mkdir -p /opt/docker/utils/docker-volume-backup
cd /opt/docker/utils/docker-volume-backup
```

### Création du `compose.yml`

On créé le `compose.yml`

```bash
sudo nano compose.yml
```

et on colle

```yaml
services:
  backup:
    image: offen/docker-volume-backup:v2
    container_name: docker-volume-backup
    restart: unless-stopped
    environment:
      # --- CONFIGURATION CLOUDFLARE R2 ---
      AWS_ENDPOINT: "points de terminaison"
      AWS_S3_BUCKET_NAME: "Nom du compartiment"
      AWS_ACCESS_KEY_ID: "ID de clé d’accès"
      AWS_SECRET_ACCESS_KEY: "Clé d’accès secrète"

      # Configuration de la planification (tous les soirs à minuit)
      BACKUP_CRON_EXPRESSION: "0 0 * * *"

    volumes:
      - /var/run/docker.sock:/var/run/docker.sock:ro
      # Tes volumes Caddy à sauvegarder :
      - caddy_config:/backup/caddy_config:ro
      - caddy_data:/backup/caddy_data:ro

volumes:
  caddy_config:
    external: true
  caddy_data:
    external: true
```

Le bloc `volumes` du bas est une espèce d'import (en gros c'est comme s'il faisait `sudo docker volume ls` pour lister les volumes), qui permet au node `backup` de comprendre ce qu'est `vaultwarden-data`

Et enregistrer le fichier.

## Création du conteneur

Et on lance le `compose up`

```bash
sudo docker compose up -d
```

## Forcer un backup pour tester

```bash
sudo docker exec docker-volume-backup backup
```

## Lister les backups distants

On liste les backup (ceux sur le stockage d'objet R2) avec

```bash
sudo docker run --rm \
  -e AWS_ENDPOINT="https://5733c92e6925460128afab9af86fe3e6.r2.cloudflarestorage.com" \
  -e BUCKET_NAME="rogerbytes-backups" \
  -e AWS_ACCESS_KEY_ID="dc66ede22c00199159161da0b20501d8" \
  -e AWS_SECRET_ACCESS_KEY="aea3e00629b1763cc0533508830572fd3d2733d640c1cabd19c16385d218b893" \
  --entrypoint sh minio/mc -c "
    mc alias set r2 \$AWS_ENDPOINT \$AWS_ACCESS_KEY_ID \$AWS_SECRET_ACCESS_KEY && \
    mc ls r2/\$BUCKET_NAME/
  "
```

## Télécharger un backup

On télécharge le fichier que l'ou souhaite avec :

```bash
sudo docker run --rm -v "$PWD":/data \
  -e AWS_ENDPOINT="https://5733c92e6925460128afab9af86fe3e6.r2.cloudflarestorage.com" \
  -e BUCKET_NAME="rogerbytes-backups" \
  -e FICHIER="backup-2026-06-24T19-00-00.tar.gz" \
  -e AWS_ACCESS_KEY_ID="dc66ede22c00199159161da0b20501d8" \
  -e AWS_SECRET_ACCESS_KEY="aea3e00629b1763cc0533508830572fd3d2733d640c1cabd19c16385d218b893" \
  --entrypoint sh minio/mc -c "
    mc alias set r2 \$AWS_ENDPOINT \$AWS_ACCESS_KEY_ID \$AWS_SECRET_ACCESS_KEY && \
    mc cp r2/\$BUCKET_NAME/\$FICHIER /data/
  "
```

## Restaurer un backup

### Arrêt des conteneurs

On commence par arrêter tout

```bash
sudo docker stop $(sudo docker ps -q)
```

### vérifier le contenu des volumes

```bash
sudo docker run --rm \
  -v caddy_config:/config \
  -v caddy_data:/data \
  alpine sh -c "echo '=== CONTENU CONFIG ===' && ls -la /config && echo '=== CONTENU DATA ===' && ls -la /data"
```

### On vide les volumes à Restaurer

```bash
sudo docker run --rm \
  -v caddy_config:/config \
  -v caddy_data:/data \
  alpine sh -c "rm -rf /config/* /data/*"
```

On peut vérifier avec

```bash
sudo docker run --rm -v caddy_config:/check alpine ls -la /check
```

S'il retourne

```text
total 8
drwxr-xr-x    2 root     root          4096 Jun 25 14:06 .
drwxr-xr-x    1 root     root          4096 Jun 25 14:07 ..
```

Comme ceci, sans lister de fichier ou de repertoire, c'est que le volume a bien été vidé.

### On restaure

#### Vérifier le contenu

```bash
FICHIER="backup-2026-06-25T15-07-03.tar.gz"
sudo tar -tf $FICHIER | head -n 15
```

#### Restaurer

```bash
FICHIER="backup-2026-06-25T15-07-03.tar.gz"

sudo docker run --rm \
  -v "$PWD":/backup_dir \
  -v caddy_config:/target/caddy_config \
  -v caddy_data:/target/caddy_data \
  alpine tar -xzf /backup_dir/$FICHIER -C /target/ --strip-components=1
```

#### Relancer tous les conteneurs

```bash
for compose_file in $(sudo find /opt/docker -type f \( -name "docker-compose.yml" -o -name "compose.yml" \)); do sudo docker compose -f "$compose_file" up -d --build --force-recreate; done
```
