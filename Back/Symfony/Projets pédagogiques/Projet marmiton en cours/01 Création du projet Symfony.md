# 01 Création du projet Symfony

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

Quand on crée un projet, composer est implicitement appelé pour installer les dépendances, mais si à chaque git clone, il faut lui dire de le faire (ces fichiers de dépendances ne font pas partie du projet).

```bash
composer install
```

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



<span hidden>
<details><summary></summary>
<style>.spoiler{border-left:4px solid #1abc9c;border-bottom-left-radius:3px;padding-left:10px;padding-top:15px;margin-top:-10px;margin-bottom:15px}.button{cursor:pointer;padding:5px 10px;background-color:#3498db;color:white;border-radius:3px;margin-bottom:5px;display:inline-block;transition:background-color 0.2s}.button:hover{background-color:#217dbb}details[open] .button{background-color:#1abc9c}</style>
</details></span>

<p align="right"><a href="#">🔝 Retour en haut</a></p>
