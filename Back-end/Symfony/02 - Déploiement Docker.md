# Déploiement Docker

Dans cette documentation, nous allons créer un projet Symfony et le déployer dans une pile de conteneurs Docker.
Ceci est basé [la doc de Symfony sur Docker](https://symfony.com/doc/current/setup/docker.html), [la doc d'install de Symfony](https://symfony.com/download) ainsi que [cette vidéo de Devscast](https://www.youtube.com/watch?v=dBjOBV64bIg).

## Initialisation d'un nouveau projet Symfony

### Création de projet via CLI

<details>
  <summary class="button">
    Spoiler
  </summary>
  <div class="spoiler">

On va verifier la dernière version LTS en date [sur le calendrier officiel](https://symfony.com/releases#symfony-releases-calendar) via cette commande :

```bash
curl -s https://symfony.com/releases \
  | grep 'Latest stable version' \
  | head -1 \
  | sed -E 's/.*Latest stable version: ([0-9]+\.[0-9]+\.[0-9]+)\. Latest LTS version: ([0-9]+\.[0-9]+\.[0-9]+).*/Stable: \1, LTS: \2/'
```

Il retourne `7.4.3` pour la LTS : l'on pourra donc passer l'argument `--version="7.4.*"` ou `--version=lts` juste après, attention, il faut que votre système utilise PHP v8.3 (par rapport à la pile de conteneur, dans la version donnée dans) pour créer le projet.

On définit un nom de projet

```bash
PROJECT_NAME="LearnSymfony"
```

On se met dans le répertoire où l'on souhaite créer le projet, puis

```bash
symfony new $PROJECT_NAME --webapp --version=lts
cd $PROJECT_NAME
```

Cela a créé le projet complet (et déplacé à l'intérieur), pour faire une version "skeleton", il vous suffit de retirer l'argument `--webapp` de la commande.

On vérifie qu'il fonctionne en local

```bash
symfony serve
```

Et on se connecte à `http://127.0.0.1:8000/`, si le site apparaît, tout est bon.

  </div>
</details>

### Sécurisation des fichiers et repo

<details>
  <summary class="button">
    Spoiler
  </summary>
  <div class="spoiler">

On sécurise les .env sensibles (.env.local et dérivés sont déjà dans le `.gitignore`)

```bash
echo ".env.dev" >> .gitignore
echo ".env.test" >> .gitignore
git rm --cached .env.dev .env.test
git add .
git commit -m "Initial commit"
```

Il nous reste à créer notre repo sur github.

```bash
gh repo create "$PROJECT_NAME" --public
```

et à y lier notre branche locale :

```bash
ACCOUNT="RogerBytes"
git remote add origin git@github.com:"$ACCOUNT/$PROJECT_NAME".git
```

Puis notre commit

```bash
touch README.md
git add --all && git commit -m "First commit"
```

Suivi du premier push

```bash
git push -u origin master
```

  </div>
</details>

## Docker

### Réglages du compose.yml

<details>
  <summary class="button">
    Spoiler
  </summary>
  <div class="spoiler">

On commence par archiver les fichiers docker générés automatiquement (pour pouvoir utiliser notre compose personnalisé).

```bash
mv compose.override.yaml compose.override.yaml.bak
mv compose.yaml compose.yaml.bak
```

Ici l'on créé le `env.local` et l'on lui met les variables tels qu'identifiants et mots de passe de DB.

```bash
USER_ID=$(id -u)
GROUP_ID=$(id -g)
cat <<EOF > .env.local
DB_USER="root"
DB_PASSWORD="root"
DB_HOST_PORT="database:5432"
DB_NAME="default_db"
SERVER_VERSION="16"
CHARSET="utf8"
USER_ID="${USER_ID}"
GROUP_ID="${GROUP_ID}"


DATABASE_URL="postgresql://\${DB_USER}:\${DB_PASSWORD}@\${DB_HOST_PORT}/\${DB_NAME}?serverVersion=\${SERVER_VERSION}&charset=\${CHARSET}"
EOF
```

On télécharge le compose personnalisé

```bash
mkdir temp_repo
git clone --filter=blob:none --no-checkout https://github.com/RogerBytes-Softworks/DevenirDev.git temp_repo
cd temp_repo
git sparse-checkout init --cone
git sparse-checkout set "Back-end/Bases Symfony/stack"
git checkout HEAD
cp -r "Back/Bases Symfony/stack/." ../
cd ..
rm -rf temp_repo
```

On ouvre `compose.yml` et on modifie les `container_name`, les noms de conteneurs doivent être unique, pareil pour le port forwarding, les port sortant (les premiers) doivent êtres uniques.

J'utilise cette convention de nommage

```yml
container_name: NOM_SERVICE_NOM_PROJET
```

qui donne (tout doit être en minuscule)

```yml
container_name: mailer_learn_symfony
```

  </div>
</details>

### Création de la pile et réglages

<details>
  <summary class="button">
    Spoiler
  </summary>
  <div class="spoiler">

#### Lancement du compose.yml

On lance le daemon de Docker (ou sinon via Docker Desktop)

```bash
sudo systemctl start docker
```

Puis on lance la création de la pile.

```bash
PROJECT_NAME="LearnSymfony"
docker compose -p "${(L)PROJECT_NAME}" --env-file .env.local up -d
```

Voici les différents ports du `compose.yml`

- nginx : 7851:80
- cloudbeaver : 7852:8978
- postgres : 7853:5432
- mailer : 1025 et 8025

</div>
</details>

### Setup CloudBeaver

<details>
  <summary class="button">
    Spoiler
  </summary>
  <div class="spoiler">

J'au rempli **Administrator Credentials**.
**Login** : `Admin-user`
**Password** `Admin-password-1234`
**Repeat Password** `Admin-password-1234`

Normalement CloudBeaver est prêt à être utilisé, il ne reste qu'à cliquer sur son icône en haut à droite pour accéder au **tableau de bord CloudBeaver**..

#### Connexion CloudBeaver à la DB

1. Dans le tableau de bord, cliquez sur le "+" et choisir **New Connection** et cherchez "PostgreSQL".
2. Créez une connexion PostgreSQL avec :

- **Host** : `database` (il s'agit du nom du service `database:` dans le `compose.yml`)
- **Port** : `5432` (le port "3851:5432")
- **Database** : `postgres` (il faut laisser la valeur par défaut c'est Symfony qui va créer la bdd, elle apparaîtra après sa création)
- **User name** : `root` (ce que j'ai stocké dans le .env dans notre cas)
- **User password** : `root` (ce que j'ai stocké dans le .env dans notre cas)

Cocher `Save credentials for all users with access` puis `Create`.
Après ça, vous pourrez explorer vos tables et données.

  </div>
</details>

### Connexion en CLI

<details>
  <summary class="button">
    Spoiler
  </summary>
  <div class="spoiler">

```bash
docker exec -it <nom_du_conteneur> /bin/bash
```

donc dans le cas présent, pour le conteneur Postgres de la pile

```bash
docker exec -it serverPostgres851 /bin/bash
```

Dans les conteneur, il y a :

- serverApache851
- serverPostgres851
- serverCloudBeaver851

#### Pour se co au sql dans le conteneur de postgres

```bash
psql -U root -d blog
```

  </div>
</details>

### Utilisation

<details>
  <summary class="button">
    Spoiler
  </summary>
  <div class="spoiler">

Les commandes docker

```bash
PROJECT_NAME="LearnSymfony"
sudo systemctl start docker
docker compose -p "${PROJECT_NAME}" start
docker compose -p "${PROJECT_NAME}" stop
```

## Initialisation des droits du conteneur

Symfony est installé dans php, dans le conteneur `container_name: php_symfony_noob`, on va donner les droits d'accès à la pile.
Il faudra lancer ces commande une fois par ordinateur.

```bash
docker exec -it php_symfony_noob bash
chown -R $UID:$GID /var/www
composer install
git config --global --add safe.directory /var/www
exit

## Accès depuis le navigateur

Pour afficher dans le navigateur :

- [Connexion au projet sur le port 7851 `http://localhost:7851/`](http://localhost:7851/)
- [Connexion à CloudBeaver sur le port 7852 `http://localhost:7852/`](http://localhost:7852/)

</div>
</details>

<style>
.spoiler {
  border-left: 4px solid #1abc9c;
  border-bottom-left-radius:3px;
  padding-left:10px;
  padding-top:15px;
  margin-top:-10px;
  margin-bottom:15px;
}
.button {
  cursor:pointer;
  padding:5px 10px;
  background-color:#3498db;
  color:white;
  border-radius:3px;
  margin-bottom:5px;
  display:inline-block;
  transition: background-color 0.2s;
}
.button:hover {
  background-color: #217dbb;
}
details[open] .button {
  background-color: #1abc9c;
}
</style>
```
