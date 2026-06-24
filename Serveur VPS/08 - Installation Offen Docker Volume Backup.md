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
      # Exécute la sauvegarde tous les jours à minuit (syntaxe Cron)
      BACKUP_CRON_EXPRESSION: "0 0 * * *"
      # Nom du fichier de sauvegarde
      BACKUP_FILENAME: "backup-vps-%Y-%m-%d_%H-%M-%S.tar.gz"
      # Garde seulement les 7 dernières sauvegardes
      BACKUP_RETENTION_DAYS: 7
    volumes:
      # Permet à Offen d'accéder aux volumes des autres conteneurs
      - /var/run/docker.sock:/var/run/docker.sock:ro
      # Le dossier local où seront stockées tes sauvegardes sur le VPS
      - /opt/docker/backups:/archive
```

Et enregistrer le fichier.

## Création du conteneur

Et on lance le `compose up`

```bash
sudo docker compose up -d
```

Voilà, le conteneur Uptime Kuma est démarré et tourne en arrière-plan.

## Redirection Caddy

Pour pouvoir consulter `Uptime Kuma`, on passe par un sous domaine

### Créer un sous domaine avec CloudFlare

On crée un enregistrement DNS pour faire pointer notre sous-domaine vers le VPS.

- On peut aller voir [le dashboard de CloudFlare](https://dash.cloudflare.com/) et dans le menu de gauche `Domaines/Vue d'ensemble` on clique sur le domaine concerné
- Dans le menu de gauche `DNS/Enregistrements` et cliquer sur `+ Ajouter un enregistrement`
  - Type = `A`
  - Nom = `uptime.mondomaine.com`
  - Adresse IPv4 = `192.0.2.1`
  - Cliquer sur `Enregistrer`

### Caddyfile

```bash
sudo nano /opt/docker/caddy/Caddyfile
```

A la fin du document (`ALT + /`), dans la partie `Redirection de domaines` coller (en mettant votre nom de domaine)

```text
uptime.mondomaine.com {
    import fail2ban_logs
    reverse_proxy 127.0.0.1:3001
}
```

on utilise le formateur intégré avec

```bash
sudo docker compose -f /opt/docker/caddy/compose.yml exec -w /etc/caddy caddy caddy fmt --overwrite
```

et on relance caddy

```bash
sudo docker compose -f /opt/docker/caddy/compose.yml exec -w /etc/caddy caddy caddy reload
```

## Configurer Uptime Kuma via le navigateur

### Choix de DB

On va sur <https://uptime.mondomaine.com>, on choisi `Embedded MariaDB`

### Création du compte admin

On s'inscrit normalement.

### Notifications

#### Installer NTFY sur le téléphone

Voici le [site de ntfy](https://ntfy.sh), il y a les liens de téléchargements.

- Ouvrir l'application mobile et cliquer sur le `+` (et on choisi un nom particulier et unique, pour qu'il n'y ait que moi qui y ait accès)
  - `mondomaine-kuma-alertes-1111`
  - on cliquer sur `Créer`

Maintenant on va sur Uptime Kuma

- Cliquer sur son profil (en haut à droite) et `Paramètres`
- Aller dans l'onglet `Notification` et `Créer une notification`
  - Type de notification `Apprise`
  - Nom d'affichage `mondomaine Kuma`
  - URL d'Apprise `ntfy://mondomaine-kuma-alertes-1111`
  - Titre `Alerte Uptime Kuma`
  - cocher `Activé par défaut` et `Appliquer sur toutes les sondes existantes`

### Ajout de sonde

- Cliquer sur le bouton `+ Ajouter une nouvelle sonde`
- Type de sonde `HTTP(s)`
- Nom d'affichage `mondomaine.com`
- Cliquer sur `Enregistrer`

Voilà, si un site est hors ligne, une notification est envoyée dans la minute

## Ajouter une IP en liste blanche

### Récupérer son ip

```bash
curl -4 ifconfig.me

curl -6 ifconfig.me
```

### Liste blanche Fail2Ban

```bash
sudo nano /etc/fail2ban/jail.local
```

Et on fait ainsi, en espaçant les ip avec un espace, on le met en dessous de `[DEFAULT]` (`CTRL + W` pour faire la recherche)

```text
[DEFAULT]
ignoreip = 127.0.0.1/8 ::1 2001:861:34c0:1330:e67f:72fd:9f4e:664b 128.78.58.115
```

On y met l'IPv4 locale et l'IPv6 locale en premier,

et on relance fail2ban

```bash
sudo systemctl restart fail2ban
```

### Liste blanche CloudFlare

Fail2Ban ne peut pas donner ses listes blanches à CloudFlare, on va voir comment faire ici.

On va sur [dashboard de CloudFlare](https://dash.cloudflare.com)

- puis `Domaine / Vue d'ensemble` cliquer sur le domaine
- puis `Sécurité / Règles de sécurité`
- en haut à droite, cliquer sur `Ajouter une règle de sécurité`
  - Nom de la règle `IP blanche 1`
  - Champs `Adresse Source de l'adresse IP`
  - Opérateur `est égal à`
  - Valeur `mettre l'IPv4 ici`
  - Effectuer l'action `Ignorer`
  - Cliquer sur `OU` et refaire la même pour l'adresse IPv6
  - Dans `Composants du pare-feu WAF à ignorer`
    - cocher `Toutes les autres règles personnalisées`, `Toutes les règles de contrôle du volume de requêtes` et `Toutes les règles gérées`
  - Et appliquer en cliquant sur le bouton `Déployer` en bas à droite

## Commande de téléchargement du backup

```bash
scp -P 22 user@IP_DE_TON_VPS:/opt/docker/backups/ton_fichier.tar.gz /chemin/dossier/local/
```

Voilà je verra ce merdier après, il faudra ensuite que je vois pour que ça récupère que celui du jour etc, et voir pour que la commande s'execute une fois par jour (après que le backup soit fait) et qu'il en garde seulement 7 (si gemini trouve que c'est une bonne idée)

et expliquer que si on a un vps de backup, qu'on ne fait plus le backup seulement sur le vps de backup dédié

en gros, quand j'aurais un peu plus d'argent, j'aurais ce délire

- 1 VPS d'entreprise dédié, avec mes services perso dessous
- n* VPS de production (selon le nombre que je peux mettre dessus pour faire des économies)
- 1 VPS de preprod
- 1 VPS de backup

