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
grep -q compinit ~/.zshrc || echo -e "\nautoload -Uz compinit\ncompinit" >> ~/.zshrc
symfony completion zsh > ~/.symfony_completion && echo "source ~/.symfony_completion" >> ~/.zshrc
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

Voilà, tout est correctement installé pour utiliser Symfony.

</div></details>

## Nouveau projet "SymfoMarmiton" et arborescence du framework

<details><summary class="button">🔍 Spoiler</summary><div class="spoiler">

On créé un nouveau projet

On se met dans le répertoire on l'on range nos projets (chez moi dans `~/Local/Git`)

```bash
cd ~/Local/Git
```

```bash
symfony new SymfoMarmiton --version=lts --webapp
```

Puis on se rend dedans

```bash
cd ~/Local/Git/SymfoMarmiton
```

On utilise `gh` pour créer le repo distant

```bash
gh repo create SymfoMarmiton --public --source=. --remote=origin
```

Et on fait le commit et le push initiaux.

```bash
[[ -f README.md ]] && echo "Premier commit effectué" >> README.md || touch README.md; git add -A && git commit -m "chore: init projet avec README" && git push -u origin master
```

et on l'ouvre dans l'IDE

```bash
codium .
```

Et on lance l'installation des Dépendances

```bash
composer install
```

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

## Réglage de Postgres

On va paramétrer le mot de passe de postgres, on s'y connecte

```bash
sudo -u postgres psql
```

On entre la commande pour changer de mot de passe, ici je mets `root` pour l'exemple, je vous conseille de choisir un mot de passe fort.

```bash
ALTER USER postgres WITH PASSWORD 'root';
\q
```

Et l'on va générer un `.env.dev.local`

```bash
cat > .env.dev.local << EOF
DATABASE_URL="postgresql://postgres:root@127.0.0.1:5432/marmiton?serverVersion=16&charset=utf8"
EOF
```

Il se base sur `DATABASE_URL` dans `.env`

```bash
DATABASE_URL="postgresql://app:!ChangeMe!@127.0.0.1:5432/app?serverVersion=16&charset=utf8"
```

Voici comment on l'a modifié dans `.env.dev.local`.

```bash
DATABASE_URL="postgresql://postgres:root@127.0.0.1:5432/marmiton?serverVersion=16&charset=utf8"
```

- `app:!ChangeMe!` est l'identifiant pour se connecter à la bdd, suivi de son mdp, donc par défaut `postgres:root` (mettre un mdp fort en prod, attention)
- le second `app` est le nom de BDD, ici on va mettre `marmiton`

</div></details>

## Aperçu des commandes

<details><summary class="button">🔍 Spoiler</summary><div class="spoiler">

Il est possible de voir toutes les commandes réalisables de symfony. Effectivement si on fait la commande dans le terminal

```bash
symfony console
```

La commande ira chercher dans le répertoire `bin` le fichier `console` pour nous afficher toutes les commandes réalisables et fonctionnelles.

```bash
$ symfony console
Symfony 7.4.6 (env: dev, debug: true)

Usage:
  command [options] [arguments]

Options:
  -h, --help            Display help for the given command. When no command is given display help for the list command
      --silent          Do not output any message
  -q, --quiet           Only errors are displayed. All other output is suppressed
  -V, --version         Display this application version
      --ansi|--no-ansi  Force (or disable --no-ansi) ANSI output
  -n, --no-interaction  Do not ask any interactive question
  -e, --env=ENV         The Environment name. [default: "dev"]
      --no-debug        Switch off debug mode.
      --profile         Enables profiling (requires debug).
  -v|vv|vvv, --verbose  Increase the verbosity of messages: 1 for normal output, 2 for more verbose output and 3 for debug

Available commands:
  about                                      Display information about the current project
  completion                                 Dump the shell completion script
  help                                       Display help for a command
  list                                       List commands
 asset-map
  asset-map:compile                          Compile all mapped assets and writes them to the final public output directory
 assets
  assets:compress                            Pre-compresses files to serve through a web server
  assets:install                             Install bundle s web assets under a public directory
 cache
  cache:clear                                Clear the cache
  cache:pool:clear                           Clear cache pools
  cache:pool:delete                          Delete an item from a cache pool
  cache:pool:invalidate-tags                 Invalidate cache tags for all or a specific pool
  cache:pool:list                            List available cache pools
  cache:pool:prune                           Prune cache pools
  cache:warmup                               Warm up an empty cache
 config
  config:dump-reference                      Dump the default configuration for an extension
 dbal
  dbal:run-sql                               Executes arbitrary SQL directly from the command line.
 debug
  debug:asset-map                            Output all mapped assets
  debug:autowiring                           List classes/interfaces you can use for autowiring
  debug:config                               Dump the current configuration for an extension
  debug:container                            Display current services for an application
  debug:dotenv                               List all dotenv files with variables and values
  debug:event-dispatcher                     Display configured listeners for an application
  debug:firewall                             Display information about your security firewall(s)
  debug:form                                 Display form type information
  debug:messenger                            List messages you can dispatch using the message buses
  debug:router                               Display current routes for an application
  debug:security:role-hierarchy              Dump the role hierarchy as a Mermaid flowchart
  debug:serializer                           Display serialization information for classes
  debug:translation                          Display translation messages information
  debug:twig                                 Show a list of twig functions, filters, globals and tests
  debug:validator                            Display validation constraints for classes
 doctrine
  doctrine:cache:clear-collection-region     Clear a second-level cache collection region
  doctrine:cache:clear-entity-region         Clear a second-level cache entity region
  doctrine:cache:clear-metadata              Clear all metadata cache of the various cache drivers
  doctrine:cache:clear-query                 Clear all query cache of the various cache drivers
  doctrine:cache:clear-query-region          Clear a second-level cache query region
  doctrine:cache:clear-result                Clear all result cache of the various cache drivers
  doctrine:database:create                   Creates the configured database
  doctrine:database:drop                     Drops the configured database
  doctrine:mapping:describe                  Display information about mapped objects
  doctrine:mapping:info                      Show basic information about all mapped entities
  doctrine:migrations:current                Outputs the current version
  doctrine:migrations:diff                   Generate a migration by comparing your current database to your mapping information.
  doctrine:migrations:dump-schema            Dump the schema for your database to a migration.
  doctrine:migrations:execute                Execute one or more migration versions up or down manually.
  doctrine:migrations:generate               Generate a blank migration class.
  doctrine:migrations:latest                 Outputs the latest version
  doctrine:migrations:list                   Display a list of all available migrations and their status.
  doctrine:migrations:migrate                Execute a migration to a specified version or the latest available version.
  doctrine:migrations:rollup                 Rollup migrations by deleting all tracked versions and insert the one version that exists.
  doctrine:migrations:status                 View the status of a set of migrations.
  doctrine:migrations:sync-metadata-storage  Ensures that the metadata storage is at the latest version.
  doctrine:migrations:up-to-date             Tells you if your schema is up-to-date.
  doctrine:migrations:version                Manually add and delete migration versions from the version table.
  doctrine:query:dql                         Executes arbitrary DQL directly from the command line
  doctrine:query:sql                         Executes arbitrary SQL directly from the command line.
  doctrine:schema:create                     Processes the schema and either create it directly on EntityManager Storage Connection or generate the SQL output
  doctrine:schema:drop                       Drop the complete database schema of EntityManager Storage Connection or generate the corresponding SQL output
  doctrine:schema:update                     Executes (or dumps) the SQL needed to update the database schema to match the current mapping metadata
  doctrine:schema:validate                   Validate the mapping files
 error
  error:dump                                 Dump error pages to plain HTML files that can be directly served by a web server
 importmap
  importmap:audit                            Check for security vulnerability advisories for dependencies
  importmap:install                          Download all assets that should be downloaded
  importmap:outdated                         List outdated JavaScript packages and their latest versions
  importmap:remove                           Remove JavaScript packages
  importmap:require                          Require JavaScript packages
  importmap:update                           Update JavaScript packages to their latest versions
 lint
  lint:container                             Ensure that arguments injected into services match type declarations
  lint:translations                          Lint translations files syntax and outputs encountered errors
  lint:twig                                  Lint a Twig template and outputs encountered errors
  lint:xliff                                 Lint an XLIFF file and outputs encountered errors
  lint:yaml                                  Lint a YAML file and outputs encountered errors
 mailer
  mailer:test                                Test Mailer transports by sending an email
 make
  make:auth                                  Create a Guard authenticator of different flavors
  make:command                               Create a new console command class
  make:controller                            Create a new controller class
  make:crud                                  Create CRUD for Doctrine entity class
  make:docker:database                       Add a database container to your compose.yaml file
  make:entity                                Create or update a Doctrine entity class, and optionally an API Platform resource
  make:fixtures                              Create a new class to load Doctrine fixtures
  make:form                                  Create a new form class
  make:listener                              [make:subscriber] Creates a new event subscriber class or a new event listener class
  make:message                               Create a new message and handler
  make:messenger-middleware                  Create a new messenger middleware
  make:migration                             Create a new migration based on database changes
  make:registration-form                     Create a new registration form system
  make:reset-password                        Create controller, entity, and repositories for use with symfonycasts/reset-password-bundle
  make:schedule                              Create a scheduler component
  make:security:custom                       Create a custom security authenticator.
  make:security:form-login                   Generate the code needed for the form_login authenticator
  make:serializer:encoder                    Create a new serializer encoder class
  make:serializer:normalizer                 Create a new serializer normalizer class
  make:stimulus-controller                   Create a new Stimulus controller
  make:test                                  [make:unit-test|make:functional-test] Create a new test class
  make:twig-component                        Create a Twig (or Live) component
  make:twig-extension                        Create a new Twig extension with its runtime class
  make:user                                  Create a new security user class
  make:validator                             Create a new validator and constraint class
  make:voter                                 Create a new security voter class
  make:webhook                               Create a new Webhook
 messenger
  messenger:consume                          Consume messages
  messenger:failed:remove                    Remove given messages from the failure transport
  messenger:failed:retry                     Retry one or more messages from the failure transport
  messenger:failed:show                      Show one or more messages from the failure transport
  messenger:setup-transports                 Prepare the required infrastructure for the transport
  messenger:stats                            Show the message count for one or more transports
  messenger:stop-workers                     Stop workers after their current message
 router
  router:match                               Help debug routes by simulating a path info match
 secrets
  secrets:decrypt-to-local                   Decrypt all secrets and stores them in the local vault
  secrets:encrypt-from-local                 Encrypt all local secrets to the vault
  secrets:generate-keys                      Generate new encryption keys
  secrets:list                               List all secrets
  secrets:remove                             Remove a secret from the vault
  secrets:reveal                             Reveal the value of a secret
  secrets:set                                Set a secret in the vault
 security
  security:hash-password                     Hash a user password
 server
  server:dump                                Start a dump server that collects and displays dumps in a single place
  server:log                                 Start a log server that displays logs in real time
 translation
  translation:extract                        Extract missing translations keys from code to translation files
  translation:pull                           Pull translations from a given provider.
  translation:push                           Push translations to a given provider.
```

Faites le test et cela par moment peut vous aider à réaliser des choses dans des temps record, vous allez gagner en productivité.

</div></details>

## Lancement du serveur

<details><summary class="button">🔍 Spoiler</summary><div class="spoiler">

Dans le terminal nous allons lancer le serveur Symfony pour voir si le projet installé fonctionne dans le navigateur.

```bash
symfony serve
```

Rendons nous dans le navigateur sur le localhost :8000 car dans notre retour de console on nous donne le lien <http://127.0.0.1:8000>.

A noter que `127.0.0.1` est équivalent au localhost <http://localhost:8000> car nous travaillons en local.

La barre de debug en bas s’appelle le profiler, très utile pour déboguer.

Nous voyons en bas à gauche que nous avons une erreur 404. Au début d’un projet c’est normal car nous n’avons encore rien configuré au niveau des routes.

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

## Les erreurs de symfony serve

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

véifiez bien "thenouillet.symfony-vscode-1.0.2-universal" que la version ou le nom n'ait pas légèrement changé

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

---

Je vais peut-être modifier le tuto pour utiliser tailwind à la place de bootstrap 
<https://tailwindcss.com/docs/installation/framework-guides/symfony>

et
<>
<span hidden>
<details><summary></summary>
<style>.spoiler{border-left:4px solid #1abc9c;border-bottom-left-radius:3px;padding-left:10px;padding-top:15px;margin-top:-10px;margin-bottom:15px}.button{cursor:pointer;padding:5px 10px;background-color:#3498db;color:white;border-radius:3px;margin-bottom:5px;display:inline-block;transition:background-color 0.2s}.button:hover{background-color:#217dbb}details[open] .button{background-color:#1abc9c}</style>
</details></span>

<p align="right"><a href="#">🔝 Retour en haut</a></p>
