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

On l'ajoute `caddy-auth` (tout à la fin) `ALT + /` puis `CTRL + V` pour aller à la fin du fichier

```plaintext
[caddy-auth]
enabled  = true
port     = 80,443
filter   = caddy-auth
logpath  = /opt/docker/caddy/logs/access.log
backend  = auto
findtime = 10m
maxretry = 5
bantime  = 1h
action   = cloudflare
```

#### Donner la clef à fail2ban

On ajoute son token de cloudflare dans

```bash
sudo nano /etc/fail2ban/action.d/cloudflare.conf
```

En bas (`ALT + /`) on voit

```text
cftoken =

cfuser =

cftarget = ip

[Init?family=inet6]
cftarget = ip6

```

Les infos de  `cftoken` et `cfuser`

- `cftoken` - [cette page](https://dash.cloudflare.com/profile/api-tokens)(ignorer l'alerte `Clé CA Origine`, c'est caddy qui s'occupe de ça et non CloudFlare), faire `Afficher`.
- `cfuser` - C'est tout simplement l'adresse email avec laquelle on se connectes au compte Cloudflare.

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

Voilà, nos deux ports d'entrées sont protégés des attaques BruteForce et DoS, et Fail2Ban modifiera les réglages du pare-feu CloudFlare via l'API.

### Préparation du répertoire et Caddyfile

On prépare un répertoire dans `opt/docker` et on s'y rend

```bash
sudo mkdir -p /opt/docker/caddy/logs
cd /opt/docker/caddy
```

On créé le `Caddyfile`

```bash
sudo nano Caddyfile
```

On y colle

```text
# ==========================================================
# 1. BLOC GLOBAL
# ==========================================================
{
        servers {
                # Dit à Caddy de faire confiance aux en-têtes de Cloudflare
                # (Nécessite que les IPs de Cloudflare soient déclarées ou gérées)
                trusted_proxies static 173.245.48.0/20 103.21.244.0/22 103.22.200.0/22 103.31.4.0/22 141.101.64.0/18 108.162.192.0/18 190.93.240.0/20 188.114.96.0/20 197.234.240.0/22 198.41.128.0/17 162.158.0.0/15 104.16.0.0/13 104.24.0.0/14 172.64.0.0/13 131.0.72.0/22
        }
}

# ==========================================================
# 2. LE MODÈLE DE LOGS POUR FAIL2BAN (Snippet)
# ==========================================================
(fail2ban_logs) {
        log {
                output file /var/log/caddy/caddy.log
                format json
        }
}

# ==========================================================
# 3. SITES
# ==========================================================
```

Les ipv4 listées proviennent [de la page dédiée aux ip de CloudFlare](https://www.cloudflare.com/ips-v4)

On enregistre et on utilise le formateur intégré avec

```bash
sudo docker compose -f /opt/docker/caddy/compose.yml exec -w /etc/caddy caddy caddy fmt --overwrite
```

et on relance caddy

```bash
sudo docker compose -f /opt/docker/caddy/compose.yml exec -w /etc/caddy caddy caddy reload
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

On wipe les logs (vu que c'est notre installation, on peut le faire)

```bash
sudo truncate -s 0 $(sudo docker inspect --format='{{.LogPath}}' $(sudo docker compose ps -q caddy))
```

On relance

et on relance caddy

```bash
sudo docker compose -f /opt/docker/caddy/compose.yml exec -w /etc/caddy caddy caddy reload
```

On vérifie le statut du conteneur

```bash
sudo docker compose logs -f
```

Retourne

```text
caddy-1  | {"level":"info","ts":1782226246.2882688,"logger":"admin.api","msg":"received request","method":"POST","host":"localhost:2019","uri":"/load","remote_ip":"127.0.0.1","remote_port":"41222","headers":{"User-Agent":["Go-http-client/1.1"],"Content-Length":["2"],"Caddy-Config-Source-Adapter":["caddyfile"],"Caddy-Config-Source-File":["Caddyfile"],"Content-Type":["application/json"],"Origin":["http://localhost:2019"],"Accept-Encoding":["gzip"]}}
caddy-1  | {"level":"info","ts":1782226246.2888181,"msg":"config is unchanged"}
caddy-1  | {"level":"info","ts":1782226246.2890744,"logger":"admin.api","msg":"load complete"}
```

Voilà, tout est prêt, il faudra à chaque fois ajouter les nouveaux réglages (pour chaque domaine) dans le `Caddyfile`, à la fin du fichier.

Maintenant que `Caddy` est correctement installé, on va terminer la section par un dernier réglage de pare-feu.

## UFW réglage final

On donne la liste blanche d'ip de CloudFlare

```bash
for ip in 173.245.48.0/20 103.21.244.0/22 103.22.200.0/22 103.31.4.0/22 141.101.64.0/18 108.162.192.0/18 190.93.240.0/20 188.114.96.0/20 197.234.240.0/22 198.41.128.0/17 162.158.0.0/15 104.16.0.0/13 104.24.0.0/14 172.64.0.0/13 131.0.72.0/22; do
  sudo ufw allow from $ip to any port 80,443 proto tcp
done
```

Les ipv4 listées proviennent [de la page dédiée aux ip de CloudFlare](https://www.cloudflare.com/ips-v4)

Pour tester