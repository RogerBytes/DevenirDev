# Stack Docker Symfony/Nginx/Postgres/CloudBeaver/MailPit/Node/Tailwind

## 01 Initialisation de la pile de conteneurs

J'ai fait un script pour simplifier la création de la pile de conteneurs.

Assurez-vous que `Docker Desktop` est démarré sur votre ordinateur, puis lancez `bootstrap-dev.sh`

```bash
./bootstrap-dev.sh
```

**Ceci est à effectuer seulement une seule fois par machine**.

## 02 Utilisation

Assurez-vous que `Docker Desktop` est démarré sur votre ordinateur, puis lancez `start-dev.sh`

```bash
./start-dev.sh
```

Utilisez cette commande à chaque fois que vous travaillez sur le projet, elle ouvre automatiquement le shell du conteneur du service `php`.

**Attention :** pour éviter tout conflit de dépendances (critique sur un projet en équipe avec différentes machines), prenez garde à bien faire toutes vos commandes (`symfony console *cmd*`, `node install *pkg*` et `composer require *pkg*` etc) **depuis ce shell**.
Pour sortir du shell d'un conteneur, il suffit d'utiliser `exit`.

## Lancer Tailwind

Pour lancer tailwind, ouvrez un nouveau terminal, et faites

```bash
./watch-dev.sh
```

### Connexion CloudBeaver

Le lien est <http://localhost:7852>

Faut cliquer sur "Next" jusqu'à devoir mettre le mdp ! Puis Next

Puis en haut à droite aller dans les préférences, le mettre en Français,

Puis faire "New Connection" ou via le plus "+" en haut à gauche

On choisit "Postgres"

Dans Host, on met le nom du service, donc "database"

Dans user et dans password, on utilise ceux du .env.local

et cocher "Save credentials for all users with access"

### Se connecter au site

<http://localhost:8080>

### Pour arrêter le projet

Depuis le shell de votre appareil (pas depuis le shell d'un conteneur)

```bash
docker compose stop
```

## 03 Sécurité

Point important, ici nous sommes en environnement de développement, l'identifiant `root` et le mot de passe `root` ne posent donc pas de problème.

En revanche, en production **utilisez impérativement un mot de passe fort**
