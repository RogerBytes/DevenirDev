# 07 - Installation Uptime Kuma

- Depuis [Page docker hub](https://hub.docker.com/hardened-images/catalog/dhi/uptime-kuma)

Ce document détaille l'installation et la configuration d'Uptime Kuma pour surveiller la disponibilité des sites et applications.

## Prérequis

### Filtre Appsec

```yml
  - filter: |
      req.Host == "uptime.rogerbytes.com" &&
      req.URL.Path startsWith "/socket.io/"
    apply:
      - SetRemediation("allow")
      - CancelAlert()
      - CancelEvent()
```

On va l'ajouter en liste blanche à custom-config.yaml, dans la partie `on_match`

```bash
sudo nano /opt/docker/crowdsec/config/appsec-configs/custom-config.yaml
```

On enregistre et on relance crowdsec

```bash
sudo docker exec crowdsec cscli hub update && sudo docker restart crowdsec
```

### Création du répertoire

On prépare un répertoire dans `opt/docker`

```bash
sudo mkdir -p /opt/docker/apps/uptime-kuma
cd /opt/docker/apps/uptime-kuma
```

### Création du `compose.yml`

On créé le `compose.yml`

```bash
sudo nano compose.yml
```

et on colle

```yaml
services:
  uptime-kuma:
    image: louislam/uptime-kuma:2
    container_name: uptime-kuma
    restart: unless-stopped
    volumes:
      - ./data:/app/data
      - /var/run/docker.sock:/var/run/docker.sock:ro
    networks:
      - caddy_network

networks:
  caddy_network:
    external: true
```

Et enregistrer le fichier.

Et on protège l'accès.

```bash
sudo chmod 600 /opt/docker/apps/uptime-kuma/compose.yml
```

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
    import crowdsec_bouncer
    reverse_proxy uptime-kuma:3001
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
