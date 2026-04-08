# Stack Docker Symfony/Nginx/Postgres/CloudBeaver/MailPit/Node/Tailwind

## 01 Création du projet Symfony

Ici l'on va créer un nouveau projet pour tester le déploiement de la stack docker.

```bash
symfony new "StackDocker" -version=lts --webapp && \
cd StackDocker && \
codium .
```

Cette commande se charge également de l'ouvrir dans `codium` (version sans telemétrie de vscode) et de supprimer l'ancien `compose.yaml`.

Ensuite on y colle notre répertoire `docker` et le `compose.yml`

## 02 Réglage d'environnement

On paremètre le `.env` avec cette commande (on peut changer la valeur de `$ENV_FILE` au besoin)

```bash
ENV_FILE=".env"
CONTENT='POSTGRES_DB="MaBaseDeDonnees"
POSTGRES_USER="root"
POSTGRES_PASSWORD="root"
DATABASE_URL="postgresql://$POSTGRES_USER:$POSTGRES_PASSWORD@database:5432/$POSTGRES_DB?serverVersion=16&charset=utf8"'

if [ -f "$ENV_FILE" ]; then
    echo "$CONTENT" >> "$ENV_FILE"
else
    echo "$CONTENT" > "$ENV_FILE"
fi
```


## 03 Création de la pile

```
docker compose up -d --build
```

Il faut quelques secondes avant que le serveur nginx démarre la première fois (il installe les dépendances), patience, quand le fichier `postcss.config.mjs` apparait, nginx va démarrer.


## 04 Utilisation

Pour utiliser symfony, il suffit de communiquer avec depuis le terminal de son conteneur (ici construit avec le service `php`).

## Connexion au service  `php` conteneur via `docker compose`

Si on est dans à la racine du projet avec le compose

```bash
docker compose exec php zsh
```

On remarque ici que `php` est le nom du service auquel je veux me connecter et qu'on lui précise qu'on communique avec via son shell `zsh`.

Maintenant l'on peut lancer nos commande symfony etc !

## Lancer Tailwind

```bash
docker compose exec -T php zsh -c "npm run watch"
```

Ou simplement via `npm run watch` dans le terminal du conteneur.

---

## Connexion au conteneur via `docker`

C'est un peu moins pratique, mais j'imagine qu'à distance ça pourrait être utile

### 1. On identifie le nom du conteneur désiré

```bash
docker ps
```

ce qui retourne chez moi

```bash
$ docker ps
CONTAINER ID   IMAGE                  COMMAND                  CREATED          STATUS                    PORTS                                                                                          NAMES
4c87a0cdbcde   nginx:1.28.3-alpine    "/docker-entrypoint.…"   10 minutes ago   Up 10 minutes             0.0.0.0:8080->80/tcp, [::]:8080->80/tcp                                                        stackdocker-web-1
58790830b75f   stackdocker-php        "docker-php-entrypoi…"   10 minutes ago   Up 10 minutes             9000/tcp                                                                                       stackdocker-php-1
dcbc9757b5e4   dbeaver/cloudbeaver    "./launch-product.sh"    10 minutes ago   Up 10 minutes             0.0.0.0:7850->8978/tcp, [::]:7850->8978/tcp                                                    stackdocker-cloudbeaver-1
2e63c6693ee7   postgres:18.3-alpine   "docker-entrypoint.s…"   10 minutes ago   Up 10 minutes (healthy)   0.0.0.0:6000->5432/tcp, 0.0.0.0:37339->5432/tcp, [::]:6000->5432/tcp, [::]:37339->5432/tcp     stackdocker-database-1
259c8f3c4260   axllent/mailpit        "/mailpit"               10 minutes ago   Up 10 minutes (healthy)   0.0.0.0:37715->1025/tcp, [::]:37715->1025/tcp, 0.0.0.0:42745->8025/tcp, [::]:42745->8025/tcp   stackdocker-mailer-1
ea7d84aa1463   axllent/mailpit:edge   "/mailpit"               10 minutes ago   Up 10 minutes (healthy)   0.0.0.0:8025->8025/tcp, [::]:8025->8025/tcp                                                    stackdocker-mail-1
```

Donc ici, le nom du conteneur php dont j'ai besoin est `stackdocker-php-1`

### 2. On se connecte au conteneur

```bash
docker exec -it stackdocker-php-1 zsh
```

