# 01 Installation et configuration de Symfony

## Dépendances

Il faut installer `PHP`, `Composer`, `certutil` puis `PostgreSQL`.

### Php

<details><summary class="button">🔍 Spoiler</summary><div class="spoiler">

On installe Php, basé sur la [doc d'install de PHP](https://www.php.net/downloads.php?usage=web&os=linux&osvariant=linux-ubuntu&version=8.5).

```bash
PHP_VERSION=8.3
sudo nala update
sudo nala install -y software-properties-common
sudo LC_ALL=C.UTF-8 add-apt-repository ppa:ondrej/php -y
sudo nala update
sudo nala install -y php${PHP_VERSION}
sudo nala install -y php${PHP_VERSION}-cli php${PHP_VERSION}-common php${PHP_VERSION}-xml php${PHP_VERSION}-mbstring php${PHP_VERSION}-intl php${PHP_VERSION}-sqlite3 php${PHP_VERSION}-mysql php${PHP_VERSION}-pgsql php${PHP_VERSION}-curl
```

Ici l'on a installé la version `8.3`, la version utilisée par la dernière LTS de Symfony (la v7.4), pour changer de version il suffit de modifier la variable `$PHP_VERSION`.

On choisit notre version de php (s'il y a plusieurs versions de php sur votre système)

```bash
sudo update-alternatives --config php
```

</div></details>

### Composer

<details><summary class="button">🔍 Spoiler</summary><div class="spoiler">

On installe la [dernière version de Composer](https://getcomposer.org/download/) (le script perso suivant automatise le processus d'installation et devrait rester fonctionnel).

```bash
php -r "copy('https://getcomposer.org/installer','composer-setup.php');" && \
php -r "copy('https://composer.github.io/installer.sig','sig');" && \
[ "$(php -r "echo hash_file('sha384','composer-setup.php');")" = "$(cat sig)" ] && \
php composer-setup.php --quiet && rm composer-setup.php sig || \
{ echo 'ERROR: Invalid installer checksum' >&2; rm composer-setup.php sig; exit 1; }
sudo mv composer.phar /usr/local/bin/composer
```

Pour désinstaller composer

```bash
sudo rm /usr/local/bin/composer
```

</div></details>

### certutil

<details><summary class="button">🔍 Spoiler</summary><div class="spoiler">

Le paquet `libnss3-tools` contient `certutil` qui est requis pour avoir le certificat TLS (facultatif)

```bash
sudo nala install -y libnss3-tools
```

</div></details>

### PostgreSQL

<details><summary class="button">🔍 Spoiler</summary><div class="spoiler">

En se basant [sur la doc de postgresql](https://www.postgresql.org/download/linux/ubuntu/)

On peut passe par le repo dédié de postgres

```bash
sudo apt install -y postgresql
```

On va également installer DBeaver pour visualiser nos BDD.

```bash
wget https://dbeaver.io/files/dbeaver-ce-latest-linux-x86_64.deb
sudo nala install -y dbeaver-ce-latest-linux-x86_64.deb
rm dbeaver-ce-latest-linux-x86_64.deb
```

</div></details>

## Installation

<details><summary class="button">🔍 Spoiler</summary><div class="spoiler">

Les informations viennent depuis la [page officielle de téléchargements](https://symfony.com/download).

```bash
curl -1sLf 'https://dl.cloudsmith.io/public/symfony/stable/setup.deb.sh' | sudo -E bash
sudo nala install -y symfony-cli
```

On va ajouter [l'autocompletion à notre zshrc](https://symfony.com/doc/current/setup/symfony_cli.html).

```bash
grep -q 'autoload -Uz compinit' ~/.zshrc || echo 'autoload -Uz compinit' >> ~/.zshrc
grep -q 'compinit' ~/.zshrc || echo 'compinit' >> ~/.zshrc
[ -f ~/.symfony_completion ] || symfony completion zsh > ~/.symfony_completion
grep -q 'source ~/.symfony_completion' ~/.zshrc || echo 'source ~/.symfony_completion' >> ~/.zshrc
source ~/.zshrc
```

J'ai ajouté `compinit`, qui est requis pour l'autocompletion des scripts avancé.

On ajoute le certificat TLS (afin de lancer le serveur avec https)

```bash
symfony server:ca:install
```

On vérifie que Symfony est correctement installé

```bash
symfony check:req
```

il est censé retourner

```bash
$ symfony check:req

Symfony Requirements Checker
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

> PHP is using the following php.ini file:
/etc/php/8.3/cli/php.ini

> Checking Symfony requirements:

.............................


[OK]
Your system is ready to run Symfony projects

```

</div></details>

## Mettre à jour

<details><summary class="button">🔍 Spoiler</summary><div class="spoiler">

Il suffit de refaire l'installation :

```bash
curl -1sLf 'https://dl.cloudsmith.io/public/symfony/stable/setup.deb.sh' | sudo -E bash
sudo nala install -y symfony-cli
```

</div></details>

## Extensions de VsCodium

<details><summary class="button">🔍 Spoiler</summary><div class="spoiler">

Pour optimiser notre utilisation de l'IDE avec Symfony

```bash
codium --install-extension cvergne.vscode-php-getters-setters-cv
codium --install-extension bmewburn.vscode-intelephense-client
codium --install-extension nadim-vscode.symfony-code-snippets
codium --install-extension TheNouillet.symfony-vscode
codium --install-extension mikestead.dotenv
codium --install-extension redhat.vscode-yaml
codium --install-extension mblode.twig-language
codium --install-extension tmrdh.symfony-helper
codium --install-extension DEVSENSE.phptools-vscode
codium --install-extension DEVSENSE.composer-php-vscode
codium --install-extension DEVSENSE.intelli-php-vscode
codium --install-extension DEVSENSE.profiler-php-vscode
codium --install-extension MehediDracula.php-namespace-resolver
codium --install-extension neilbrayfield.php-docblocker
codium --install-extension SonarSource.sonarlint-vscode
codium --install-extension zobo.php-intellisense
vsix-dl klesun.deep-assoc-completion-vscode
```

Et dans `~/.config/VSCodium/User/settings.json` (<kbd>Ctrl</kbd> + <kbd>,</kbd>) :

```json
  "symfonyHelper.phpParser.phpPath": "/usr/bin/php",
  "[php]": {
    "editor.defaultFormatter": "bmewburn.vscode-intelephense-client",
  },
  "[twig]": {
    "editor.defaultFormatter": "mblode.twig-language-2",
  },
  "emmet.includeLanguages": {
    "twig": "html",
  },
  "php.suggest.basic": false,
  "emmet.excludeLanguages": ["markdown", "php"],
  "php.executables": {
    "php": "/usr/bin/php",
  },
```

</div></details>

## Architecture d'une webapp Symfony

<details><summary class="button">🔍 Spoiler</summary><div class="spoiler">

Voici l'architecture (via `tree -L 1`)

```bash
$ tree -L 1
.
├── assets
├── bin
├── compose.override.yaml
├── composer.json
├── composer.lock
├── compose.yaml
├── config
├── importmap.php
├── migrations
├── phpunit.dist.xml
├── public
├── src
├── symfony.lock
├── templates
├── tests
├── translations
├── var
└── vendor

12 directories, 7 files
```

- Le répertoire `bin` : contient des fichiers de commandes ( maj bdd, vider le cache...)
- Le répertoire `config` : configuration des packages
- Le répertoire de `migrations` : Migrations pour envoyer en bdd grâce à l’ORM
- Le répertoire `public` : point d’entrée de l’application
- Le répertoire `src` : cœur du projet => controller, entité, repository etc...
- Le répertoire `template` : comprendra les vues Le répertoire test : c’est notre répertoire pour faire nos tests
- Le Fichier `translation` : pour la traduction si on a une application multilingue
- Le répertoire `var` : répertoire de cache et de log pour déboguer
- Le répertoire `vendor` : Code de tous les composants pour faire tourner Symfony
- Le `.env` : fichier d’environnement Le composer.json : c’est l’endroit où tous nos paquets sont installés

</div></details>

## Les erreurs de symfony serve

<details><summary class="button">🔍 Spoiler</summary><div class="spoiler">

Ces erreurs peuvent être retord à corriger, quand on bute sur une erreur inconnue dont on ne comprends pas l'origine il est bon de virer le repertoire `var`

```bash
rm -rf var/*
```

Et de le regénrer avec serve derrière

```bash
symfony serve
```

## La saleté d'erreur style class

A titre d'info !

Elle vient du fichier `assets/app.js`, avec le `import './styles/app.css';`. En commentant la ligne ça fait partir l'erreur

Ensuite, avec le réglage de bootstrap dans `templates/base.html.twig`, on peut également commenter `<link rel="stylesheet" href="style.css">`

et pour le ouin ouin `GET https://localhost:8000/.well-known/appspecific/com.chrome.devtools.json` c'est le dev tool, faut abandonner je ne trouve pas de solution.

normalement c'est :

Lien direct pour désactiver :
<chrome://flags/#devtools-project-settings>

Ensuite : désactiver **DevTools Project Settings** puis redémarrer Chrome, Symfony et l'IDE— ça stoppe les requêtes vers `/.well-known/appspecific/com.chrome.devtools.json`.

Cette feature qu'on vient de désactiver semble être utile quand on utilise vite.

### "show-private" option does not exist

Dans `~/.vscode-oss/extensions/thenouillet.symfony-vscode-1.0.2-universal/out/symfony/provider/`

vérifiez bien "thenouillet.symfony-vscode-1.0.2-universal" que la version ou le nom n'ait pas légèrement changé

Allez ouvrir `~/.vscode-oss/extensions/thenouillet.symfony-vscode-1.0.2-universal/out/symfony/provider/ConsoleContainerProvider.js`

Chercher `--show-private` (l 26 normalement) et remplacer par `--show-hidden`. Puis redémarrer VSC

Et dans le projet :

```bash
rm -rf var/*
```

Et de le régénérer avec serve derrière

```bash
symfony serve
```

</div></details>

---

Je vais peut-être modifier le tuto SymfoMarmiton pour utiliser tailwind à la place de bootstrap [via la doc tailwind](https://tailwindcss.com/docs/installation/framework-guides/symfony).

<details><summary></summary>
<style>.spoiler{border-left:4px solid #1abc9c;border-bottom-left-radius:3px;padding-left:10px;padding-top:15px;margin-top:-10px;margin-bottom:15px}.button{cursor:pointer;padding:5px 10px;background-color:#3498db;color:white;border-radius:3px;margin-bottom:5px;display:inline-block;transition:background-color 0.2s}.button:hover{background-color:#217dbb}details[open] .button{background-color:#1abc9c}</style>
</details></span>

<p align="right"><a href="#">🔝 Retour en haut</a></p>
