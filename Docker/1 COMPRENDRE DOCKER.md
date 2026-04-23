# COMPRENDRE DOCKER

---

## Qu’est-ce que Docker ?

Docker est un outil qui vous permet de créer des **conteneurs**.

Un conteneur est un environnement isolé qui contient :

- votre application
- ses dépendances
- sa configuration

---

## Pourquoi utiliser Docker ?

Sans Docker :

- votre application peut fonctionner chez vous
- mais pas chez quelqu’un d’autre

Avec Docker :

- même environnement partout
- installation rapide
- moins d’erreurs liées à la configuration

---

## Les concepts essentiels

### Image

Une image est un **modèle prêt à l’emploi**

Exemples :

- `php:8.3-apache`
- `mysql:8.0`

---

### Conteneur

Un conteneur est une **instance en cours d’exécution d’une image**

 Image = plan

Conteneur = application qui tourne

---

### Dockerfile

Un Dockerfile est un fichier qui permet de :

**décrire comment construire une image**

---

### Docker Compose

Docker Compose permet de :

lancer plusieurs conteneurs ensemble

les connecter automatiquement

---

## Le cycle Docker

```
Dockerfile → Image → Conteneur
```

---

# PREMIER PROJET

---

## Créer votre projet

Dans votre terminal :

```bash
mkdir projet-docker
cd projet-docker
mkdir src
```

---

## Créer votre fichier PHP

📄 `src/index.php`

```php
<?php
echo "Hello Docker 🚀";
```

---

## Créer votre premier Dockerfile

📄 `Dockerfile`

```docker
FROM php:8.3-apache
```

---

## Explication

Vous indiquez ici :

> “Je veux une image contenant PHP et Apache déjà installés”
> 

---

## Lancer votre conteneur

```bash
docker build -t mon-php .
docker run -p 8080:80 mon-php
```

---

Ouvrez votre navigateur :

[http://localhost:8080](http://localhost:8080/)

---

## Problème

Votre fichier PHP ne s’affiche pas.

Pourquoi ?

Parce qu’il n’est pas encore dans le conteneur.

---

# PARTIE 3 — AJOUTER VOTRE CODE

---

## Modifier votre Dockerfile

```docker
FROM php:8.3-apache

COPY ./src /var/www/html
```

---

## Explication

- `/var/www/html` est le dossier utilisé par Apache
- vous devez y placer votre code PHP

---

## Rebuild

```bash
docker build -t mon-php .
docker run -p 8080:80 mon-php
```

---

 Votre application fonctionne maintenant 

---

# PARTIE 4 — INTRODUCTION À DOCKER COMPOSE

---

## Pourquoi Docker Compose ?

Docker Compose vous permet de :

- gérer plusieurs conteneurs
- éviter de taper des commandes longues
- définir votre architecture dans un fichier

---

## Créer `docker-compose.yml`

```yaml
version: '3.8'

services:
  php:
    build: .
    ports:
      - "8080:80"
```

---

## Lancer

```bash
docker compose up --build
```

---

 Votre application fonctionne comme avant

---

# PARTIE 5 — AJOUTER MYSQL

---

## Modifier `docker-compose.yml`

```yaml
db:
  image: mysql:8.0
  environment:
    MYSQL_ROOT_PASSWORD: root
    MYSQL_DATABASE: demo
    MYSQL_USER: demo
    MYSQL_PASSWORD: demo
```

---

## Explication

Docker va automatiquement :

- créer une base `demo`
- créer un utilisateur `demo`

---

## Communication entre services

Dans Docker Compose :

les services communiquent via leur nom

```
php → db
```

---

# CONNECTER PHP À MYSQL

---

## 📄 Modifier `index.php`

```php
<?php

$dsn = "mysql:host=db;dbname=demo";
$user = "demo";
$pass = "demo";

try {
    $pdo = new PDO($dsn, $user, $pass);
    echo "Connexion OK";
} catch (PDOException $e) {
    echo $e->getMessage();
}
```

---

## ❌ Erreur attendue

```
could not find driver
```

---

## 🧠 Explication

PHP ne possède pas encore le driver MySQL.

---

# INSTALLER PDO MYSQL

---

## 🔧 Modifier votre Dockerfile

```docker
FROM php:8.3-apache

RUN docker-php-ext-install pdo pdo_mysql

COPY ./src /var/www/html
```

---

## Rebuild

```bash
docker compose up --build
```

---

La connexion fonctionne maintenant 

---

# 🔵 PARTIE 8 — DOCKERFILE COMPLET

---

```docker
FROM php:8.3-apache

RUN apt-get update && apt-get install -y \
    libicu-dev libzip-dev unzip git \
    && docker-php-ext-install pdo pdo_mysql intl zip \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /var/www/html
```

---

## 🧠 Explication détaillée

| Élément | Rôle |
| --- | --- |
| apt-get | installe des dépendances système |
| libicu-dev | extension intl |
| libzip-dev | extension zip |
| pdo_mysql | connexion MySQL |
| rm -rf | optimisation |

---

# 🔵 PARTIE 9 — UTILISER LES VOLUMES

---

```yaml
volumes:
  - ./src:/var/www/html
```

---

## 🧠 Pourquoi ?

- vous modifiez votre code en local
- les changements sont visibles immédiatement

---

# AJOUTER PHPMYADMIN

---

```yaml
phpmyadmin:
  image: phpmyadmin:latest
  environment:
    PMA_HOST: db
    PMA_USER: demo
    PMA_PASSWORD: demo
  ports:
    - "8081:80"
```

---

👉 Accès :

- Application → [http://localhost:8080](http://localhost:8080/)
- phpMyAdmin → [http://localhost:8081](http://localhost:8081/)

---

# PERSISTANCE DES DONNÉES

---

```yaml
volumes:
  - db_data:/var/lib/mysql

volumes:
  db_data:
```

---

## 🧠 Pourquoi ?

Sans volume :

❌ vos données disparaissent

Avec volume :

✅ vos données sont conservées

---

# CODE FINAL

[https://github.com/kerfiguetteb/docker-php.git](https://github.com/kerfiguetteb/docker-php.git)