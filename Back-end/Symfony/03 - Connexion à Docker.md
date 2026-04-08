# Connexion à Docker

Ici on apprend à utiliser Symfony, et plus précisément une stack Docker.

## Se connecter au conteneur

<details><summary class="button">Spoiler</summary><div class="spoiler">

On lance les conteneurs

```bash
PROJECT_NAME="LearnSymfony"
docker compose -p "${(L)PROJECT_NAME}" --env-file .env.local up -d
```

`--env-file .env.local` permet de charger les variables d'environnement locales.

Et on vérifie que tout fonctionne

```bash
docker compose --env-file .env.local -p "${(L)PROJECT_NAME}" ps
```

Ici, l’application sera accessible sur le port exposé par le conteneur Nginx, et DBeaver sur son port respectif.

Pour arrêter la pile

```bash
docker compose down
```

### Connection au shell

Symfony est installé dans php, ici, c'est dans le conteneur `container_name: php_learn_symfony` donc

```bash
docker exec -it php_learn_symfony bash
```

On peut vérifier que tout est bien installé

```bash
composer --version
php -v
php bin/console --version
ls -la var/
```

Pour installer les dépendances

```bash
composer install
```

</div></details>

<style>.spoiler{border-left:4px solid #1abc9c;border-bottom-left-radius:3px;padding-left:10px;padding-top:15px;margin-top:-10px;margin-bottom:15px}.button{cursor:pointer;padding:5px 10px;background-color:#3498db;color:white;border-radius:3px;margin-bottom:5px;display:inline-block;transition:background-color 0.2s}.button:hover{background-color:#217dbb}details[open] .button{background-color:#1abc9c}</style>
