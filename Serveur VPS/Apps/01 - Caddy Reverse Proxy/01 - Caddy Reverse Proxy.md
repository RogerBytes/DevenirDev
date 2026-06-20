# 01 - Caddy Reverse Proxy

Depuis [Page docker hub](https://hub.docker.com/_/caddy)
Depuis [Page GitHub](https://github.com/caddyserver/caddy)
Depuis [Le compose](https://caddyserver.com/docs/running#docker-compose)
Depuis [La commande Docker](https://caddyserver.com/docs/install#docker)

## Prérequis

### Réglage pare-feu

On dit à `UFW` d'ouvrir les ports, car ils passent par `network_mode: "host"` et non par `ports:`.  
Donc Docker ne crée pas de boîte réseau isolée et n'ouvre pas automatiquement les ports via iptables.  
Caddy se comporte comme un logiciel classique du serveur, il faut donc ouvrir le pare-feu du VPS.

```bash
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw reload
```

Le port 80 est le port http, et le port 443 est le port https.

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

On enregistre la configuration, et on relance `Fail2ban`

```bash
sudo fail2ban-client reload
```

Voilà, nos deux ports d'entrées sont protégés des attaques BruteForce et DoS.

## Installation

On prépare un répertoire dans `opt/docker`

```bash
sudo mkdir -p /opt/docker/caddy/logs
cd /opt/docker/caddy
```

On créé le `Caddyfile`

```bash
sudo nano Caddyfile
```

On y colle (ici l'exemple pour `VaultWarden`)

```plaintext
vw.rogerbytes.com {
        log {
                output file /var/log/caddy/caddy.log
        }
        reverse_proxy 127.0.0.1:8000
}
```

Pour la ligne `reverse_proxy 127.0.0.1:8000`

Il faut lire cet extrait du `compose.yml` de `VaultWarden` pour comprendre

```yml
ports:
  - 127.0.0.1:8000:80
```

Voici la lecture

- `127.0.0.1:8000:80`
- `localhost:hôte:conteneur`

- `hôte` **(8000)** C'est la prise sur laquelle le service est disponible uniquement au sein du VPS (grâce au 127.0.0.1). C'est pour cela que Caddy doit pointer vers cette prise locale
- `conteneur` **(80)** C'est le port interne du conteneur Docker, en général on s'abstient de le modifier, car les services interagissent les uns les autres via ce port

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

Et on lance le `compose up`

```bash
sudo docker compose up -d
```

On vérifie le statut du conteneur

```bash
sudo docker compose logs -f
```

## Pour ajouter d'autres domaines/sous-domaines

Il suffit de modifier le `Caddyfile` comme on l'a déjà fait.

```bash
sudo nano Caddyfile
```

On y colle une nouvelle entrée (ici l'exemple pour `VaultWarden`)

```plaintext
vw.rogerbytes.com {
        log {
                output file /var/log/caddy/caddy.log
        }
        reverse_proxy 127.0.0.1:8000
}

autre.rogerbytes.com {
        log {
                output file /var/log/caddy/caddy.log
        }
        reverse_proxy 127.0.0.1:9000
}
```

Au besoin, on peut formater/amélioré l'indentation du `Caddyfile` avec

```bash
sudo docker compose exec -w /etc/caddy caddy caddy fmt --overwrite
```

**Très important** : Après chaque modification du `Caddyfile`, il faut recharger la configuration de Caddy pour qu'elle soit prise en compte, sans pour autant couper le service

```bash
sudo docker compose exec -w /etc/caddy caddy caddy reload
```

Et voilà, la nouvelle configuration est prise en compte.
