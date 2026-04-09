# Docker & CI/CD avec GitHub Actions

---

## Création d'un projet Symfony

```bash
symfony new TestCI-CD --version=lts --webapp
cd TestCI-CD
```

On va 

```bash
git init
```

On créé le repo distant avec gh

```bash
gh repo create TestCI-CD --public --source=. --remote=origin
```

et on fait le commit et le push d'origine

```bash
git add -A && git commit -m 'ok' && git push -u origin master
```

### Ajout du Mailer

```bash
composer require symfony/mailer
```

Configurer `.env` :

```
MAILER_DSN=smtp://localhost:1025
DATABASE_URL="mysql://test:root@127.0.0.1:3306/test?serverVersion=8.0.32&charset=utf8mb4"
```

Configurer `.env.test` :

```
MAILER_DSN=smtp://localhost:1025
```

On créé un contrôleur `Mail`

```bash
symfony console ma:con Mail
```

Dans `src/Controller/MailController.php`, on fait

```php
<?php

namespace App\Controller;

use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Mailer\MailerInterface;
use Symfony\Component\Mime\Email;
use Symfony\Component\Routing\Attribute\Route;



final class MailController extends AbstractController
{
    #[Route('/send-mail', name: 'send_mail')]
    public function sendMail(MailerInterface $mailer): Response
    {
        $email = (new Email())
            ->from('demo@example.com')
            ->to('test@exemple.com')
            ->subject('Bonjour depuis Symfony !')
            ->text('Ceci est un email de test.');

        $mailer->send($email);

        return new Response("✅ Email envoyé... !");
    }
}
```

On créé un fichier `MailTest.php` dans le répertoire `tests`

```bash
touch tests/MailTest.php
```

Et dans `tests/MailTest.php`

```php
<?php

namespace App\Tests;

use Symfony\Bundle\FrameworkBundle\Test\WebTestCase;
use Symfony\Bundle\FrameworkBundle\Test\MailerAssertionsTrait;

class MailTest extends WebTestCase
{
  use MailerAssertionsTrait;
  public function testMailEnvoi(): void
  {
    $client = static::createClient();
    $client->request('GET', '/send-mail');

    // $this->assertResponseIsSuccessful();
    $this->assertEmailCount(1);
  }
}
```

### Mailhog / Mailpit pour tester les mails

Dans `compose.yaml`, on ajoute le service `mailer`

```yaml
services:

  mailer:
    image: axllent/mailpit
    ports:
      - "1025:1025"
      - "8025:8025"
```

- `http://localhost:8025` → interface pour voir les mails.
- `localhost:1025` → port SMTP où Symfony envoie les emails.

## CI : Intégration Continue avec GitHub Actions

### Définition

L’**Intégration Continue (CI)** est une pratique de développement où **chaque modification du code est automatiquement testée et validée**.

L’objectif est de détecter rapidement les erreurs, avant qu’elles ne s’accumulent.

### Pourquoi la CI ?

- Chaque fois qu’un développeur pousse du code, GitHub va :
    - Installer les dépendances.
    - Préparer la base de données.
    - Lancer les tests.

Cela garantit que **chaque commit est testé automatiquement**.

### Attention si on a utilise --webapp

il faut modifier `config/packages/messenger.yaml` et commenter `Symfony\Component\Mailer\Messenger\SendEmailMessage: async`, sinon les tests ne passeronts pas

### Fichier `.github/workflows/ci-cd.yml`

On va créer notre répertoire `.github/workflows/`

```bash
mkdir -p .github/workflows/
```

Puis on créé le fichier `.github/workflows/ci-cd.yml`

Ce repertoire et ce fichier seront utilisés par GitHub

```bash
touch .github/workflows/ci-cd.yml
```

Et on lui colle (attention si la branche principale est main, il faut le mettre à la place de master) :

```yaml
name: Symfony CI/CD

on:
  push:
    branches: [ "master" ]

jobs:
  build-and-test:
    runs-on: ubuntu-latest

    services:
      mysql:
        image: mysql:8.0
        env:
          MYSQL_ROOT_PASSWORD: root
          MYSQL_DATABASE: test
          MYSQL_USER: test
          MYSQL_PASSWORD: test
        ports:
          - 3306:3306
        options: >-
          --health-cmd="mysqladmin ping -h localhost"
          --health-interval=10s
          --health-timeout=5s
          --health-retries=3

      mailhog:
        image: mailhog/mailhog
        ports:
          - 1025:1025
          - 8025:8025

    steps:
      - uses: actions/checkout@v4

      - name: Setup PHP
        uses: shivammathur/setup-php@v2
        with:
          php-version: '8.3'

      - name: Install dependencies
        run: composer install --no-interaction --prefer-dist

      - name: Run tests
        run: php bin/phpunit --testdox

```

---

## CD : Déploiement Continu avec Docker Hub

### Définition

Le **CD** est la suite logique du CI.

Une fois les tests validés, l’application est automatiquement **préparée pour la production**.

### Ajout du job CD dans GitHub Actions

Dans `.github/workflows/ci-cd.yml` on ajoute

```yaml
  docker-build-push:
    runs-on: ubuntu-latest
    needs: build-and-test

    steps:
      - uses: actions/checkout@v4

      - name: Log in to Docker Hub
        uses: docker/login-action@v3
        with:
          username: ${{ secrets.DOCKERHUB_USERNAME }}
          password: ${{ secrets.DOCKERHUB_TOKEN }}

      - name: Build Docker image
        run: docker build -t ${{ secrets.DOCKERHUB_USERNAME }}/testdecicd:latest .

      - name: Push Docker image
        run: docker push ${{ secrets.DOCKERHUB_USERNAME }}/testdecicd:latest
```

Ce qui donne

```bash
name: Symfony CI/CD

on:
  push:
    branches: [ "master" ]

jobs:
  build-and-test:
    runs-on: ubuntu-latest

    services:
      mysql:
        image: mysql:8.0
        env:
          MYSQL_ROOT_PASSWORD: root
          MYSQL_DATABASE: test
          MYSQL_USER: test
          MYSQL_PASSWORD: test
        ports:
          - 3306:3306
        options: >-
          --health-cmd="mysqladmin ping -h localhost"
          --health-interval=10s
          --health-timeout=5s
          --health-retries=3

      mailhog:
        image: mailhog/mailhog
        ports:
          - 1025:1025
          - 8025:8025

    steps:
      - uses: actions/checkout@v4

      - name: Setup PHP
        uses: shivammathur/setup-php@v2
        with:
          php-version: '8.3'

      - name: Install dependencies
        run: composer install --no-interaction --prefer-dist

      - name: Run tests
        run: php bin/phpunit --testdox

  docker-build-push:
    runs-on: ubuntu-latest
    needs: build-and-test

    steps:
      - uses: actions/checkout@v4

      - name: Log in to Docker Hub
        uses: docker/login-action@v3
        with:
          username: ${{ secrets.DOCKERHUB_USERNAME }}
          password: ${{ secrets.DOCKERHUB_TOKEN }}

      - name: Build Docker image
        run: docker build -t ${{ secrets.DOCKERHUB_USERNAME }}/testdecicd:latest .

      - name: Push Docker image
        run: docker push ${{ secrets.DOCKERHUB_USERNAME }}/testdecicd:latest
```

### Création du dockerfile

le `context: .` indique le chemin où chercher le dockerfile pour build l'image, ici à la racine

On a créé un `Dockerfile`

```bash
touch Dockerfile
```

Et on le remplit ainsi :

```dockerfile
FROM php:8.3-apache
RUN apt-get update && apt-get install -y \
    libicu-dev libzip-dev unzip git \
  && docker-php-ext-install pdo pdo_mysql intl zip \
  && rm -rf /var/lib/apt/lists/*
RUN a2enmod rewrite
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer
WORKDIR /var/www/html
COPY . .
ENV APP_ENV=prod APP_DEBUG=0
RUN composer install --no-dev --optimize-autoloader

RUN chown -R www-data:www-data /var/www/html/var
EXPOSE 80
```

---

## **Configuration des variables d’accès Docker Hub & GitHub**

### Génération d’un Access Token Docker Hub

1. Ouvrir [**Account Settings**](https://app.docker.com/accounts/harryric/settings) (paramètres du compte Docker Hub).
2. Aller dans l’onglet **Personnal access tokens** → cliquer sur **Generate New Token**.
3. Dans `Access token description` on met ce qu'on veut, je vais mettre 'accès gh'.
4. Dans `Acess permission` on met `Read, Write, Delete` et on clique sur `Generate`
5. **Copier immédiatement le token généré** (il n’apparaîtra plus par la suite).

 Ce token permet à GitHub Actions de se connecter à Docker Hub **en toute sécurité**.

### Ajout des secrets dans GitHub

1. Ouvrir le dépôt GitHub concerné.
2. Aller dans **Settings** (paramètres du dépôt).
3. Dans le menu gauche → **Secrets and variables > Actions**.
4. Cliquer sur **New repository secret**.
5. Ajouter les deux secrets suivants :
    - `DOCKERHUB_USERNAME` → identifiant Docker Hub
    - `DOCKERHUB_TOKEN` → valeur du token généré précédemment

 Les secrets apparaissent maintenant dans la liste, accessibles uniquement par GitHub Actions.

---


Maintenant on test, en faisant un push, et on regarde dans action si tout fonctionne.

### Simulation de production

- Même sans serveur dédié, vous pouvez montrer que votre app Symfony est **portable**.
- L’image Docker publiée sur **Docker Hub** peut être téléchargée partout et exécutée instantanément.
- Docker Hub joue ici le rôle de “production”.

---

<aside>
💡

- **Docker** : uniformise et simplifie l’exécution des applis.
- **CI (GitHub Actions)** : automatise les tests et sécurise le code.
- **CD (Docker Hub)** : rend les déploiements fiables et reproductibles.
- Résultat : un simple `git push` = tests + image prête à déployer
</aside>

---

## Conclusion

Le CI/CD est un **pilier du DevOps** :

- CI/CD supprime les barrières entre **développeurs** et **ops**.
- Les développeurs n’ont plus besoin d’envoyer des fichiers par FTP.
- Les ops n’ont plus besoin de réinstaller manuellement les serveurs.
- Tout est **automatisé, versionné, reproductible**.
