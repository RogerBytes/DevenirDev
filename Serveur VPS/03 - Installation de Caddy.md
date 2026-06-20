# 03 - Installation de Caddy

- Depuis [Page docker hub](https://hub.docker.com/_/caddy)
- Depuis [Page GitHub](https://github.com/caddyserver/caddy)
- Depuis [Le compose](https://caddyserver.com/docs/running#docker-compose)
- Depuis [La commande Docker](https://caddyserver.com/docs/install#docker)

## Prérequis

### Réglage Fail2Ban Système

Maintenant on paramètre `Fail2Ban` système

```bash
sudo nano /etc/fail2ban/jail.local
```

On l'ajoute `caddy-auth` (tout à la fin) `CTRL + W` puis `CTRL + V` pour aller à la fin du fichier

```plaintext
[caddy-auth]
enabled  = true
port     = 80,443
filter   = caddy-auth
logpath  = /opt/docker/caddy/logs/caddy.log
backend  = auto
findtime = 10m
maxretry = 5
bantime  = 1h
```

On créé le fichier de filtre

```bash
sudo nano /etc/fail2ban/filter.d/caddy-auth.conf
```

Et on y met

```plaintext
[Definition]
failregex = ^.*"status":401.*"remote_ip":"<ADDR>".*$
            ^.*"status":403.*"remote_ip":"<ADDR>".*$
ignoreregex =
```

On génère le log

```bash
sudo mkdir -p /opt/docker/caddy/logs/
sudo touch /opt/docker/caddy/logs/caddy.log
```

On enregistre la configuration, et on relance `Fail2ban`

```bash
sudo fail2ban-client reload
```

Voilà, nos deux ports d'entrées sont protégés des attaques BruteForce et DoS.

### Préparation du répertoire et Caddyfile

On prépare un répertoire dans `opt/docker` et on s'y rend

```bash
sudo mkdir -p /opt/docker/caddy/logs
cd /opt/docker/caddy
```

On créé le `Caddyfile`

```bash
sudo touch Caddyfile
```

### Création du `compose.yml`

Maintenant on fait le `compose.yml`

```bash
sudo nano compose.yml
```

et on colle

```yaml
services:
  caddy:
    image: caddy:2.11.4-alpine
    restart: unless-stopped
    volumes:
      - ./Caddyfile:/etc/caddy/Caddyfile
      - ./logs:/var/log/caddy
      - caddy_data:/data
      - caddy_config:/config
    network_mode: "host"

volumes:
  caddy_data:
  caddy_config:
```

#### Explication des volumes dans le `compose.yml`

##### Pour `./logs:/var/log/caddy`

- **Avant les `:` (`./logs`) :** C'est le dossier **réel** sur ton VPS (visible sous nos yeux, si on supprime le conteneur ou la pile de conteneur, il reste).
- **Après les `:` (`/var/log/caddy`) :** C'est le dossier **virtuel** tout au fond du conteneur Docker (ici pour le conteneur Caddy).
- **Explication courte :** On branche le dossier de logs interne de Caddy sur un dossier réel du VPS pour que Fail2Ban puisse lire les lignes en direct depuis l'extérieur.

##### Pour `caddy_data:/data`

- **Avant les `:` (`caddy_data`) :** C'est un coffre-fort **virtuel** géré et caché par Docker (il est dans le système de fichier du VPS, si on supprime le conteneur ou la pile de conteneur, il reste).
- **Après les `:` (`/data`) :** C'est le dossier **virtuel** tout au fond du conteneur Docker (ici pour le conteneur Caddy).
- **Explication courte :** On connecte une boîte de stockage privée gérée par Docker pour garder tes certificats SSL à l'abri des regards et sécurisés, même si tu supprimes le conteneur.

## Création du conteneur

Et on lance le `compose up`

```bash
sudo docker compose up -d
```

On vérifie le statut du conteneur

```bash
sudo docker compose logs -f
```

`caddy-1  | Error: adapting config using caddyfile: EOF` est normal, notre `Caddyfile` est pour l'instant vide.

Voilà, tout est prêt, il faudra à chaque fois ajouter les réglages dans le `Caddyfile`.

Maintenant que `Caddy` est correctement installé, il est temps de déployer des conteneurs Docker sur le serveur, commencez par `Serveur VPS/Apps/01 - VaultWarden/Installation VaultWarden.md`
