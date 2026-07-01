# 05 - Installation de Caddy

- Depuis [Page docker hub](https://hub.docker.com/_/caddy)
- Depuis [Page GitHub](https://github.com/caddyserver/caddy)
- Depuis [Le compose](https://caddyserver.com/docs/running#docker-compose)
- Depuis [La commande Docker](https://caddyserver.com/docs/install#docker)

## Prérequis

### Fichier de logs de Caddy

```bash
sudo mkdir -p /opt/docker/caddy/logs/
sudo touch /opt/docker/caddy/logs/access.log
```

Ok mais il me reste à faire en sorte que crowdsec le surveille...

### Paramétrage du bouncer de pare-feu de Crowdsec

On va ajouter le fichier de log de caddy

```bash
sudo nano /opt/docker/crowdsec/config/acquis.yaml
```

Pour que ça ressemble à

```yml
filenames:
  - /var/log/auth.log
labels:
  type: syslog
---
filenames:
  - /opt/docker/caddy/logs/access.log
labels:
  type: caddy
```

### Ajout du fichier de log au conteneur crowdsec

```bash
sudo nano /opt/docker/crowdsec/compose.yml
```

Il faut lui ajouter `- /opt/docker/caddy/logs:/opt/docker/caddy/logs:ro` comme volume, et `` dans la collection

```yml
services:
  crowdsec:
    image: crowdsecurity/crowdsec:latest
    container_name: crowdsec
    restart: unless-stopped
    environment:
      COLLECTIONS: "crowdsecurity/sshd crowdsecurity/linux crowdsecurity/caddy"
    volumes:
      - /opt/docker/crowdsec/config/acquis.yaml:/etc/crowdsec/acquis.yaml:ro
      - /opt/docker/crowdsec/data:/var/lib/crowdsec/data
      - /var/log/auth.log:/var/log/auth.log:ro
      - /opt/docker/caddy/logs:/opt/docker/caddy/logs:ro
    ports:
      - "127.0.0.1:8080:8080"
```

Et on redémarre le conteneur Crowdsec

```bash
cd /opt/docker/crowdsec
sudo docker compose up -d --force-recreate
```

### Préparation du répertoire et Caddyfile

On prépare un répertoire dans `opt/docker` et on s'y rend

```bash
cd /opt/docker/caddy
```

On créé le `Caddyfile`

```bash
sudo nano Caddyfile
```

On y colle

```text
# --------------- Réglages globaux --------------- #
{
        servers {
                # Permet à Caddy de reconnaître la vraie IP du visiteur derrière Cloudflare.
                trusted_proxies static 173.245.48.0/20 103.21.244.0/22 103.22.200.0/22 103.31.4.0/22 141.101.64.0/18 108.162.192.0/18 190.93.240.0/20 188.114.96.0/20 197.234.240.0/22 198.41.128.0/17 162.158.0.0/15 104.16.0.0/13 104.24.0.0/14 172.64.0.0/13 131.0.72.0/22 2400:cb00::/32 2606:4700::/32 2803:f800::/32 2405:b500::/32 2405:8100::/32 2a06:98c0::/29 2c0f:f248::/32
        }
}

(crowdsec_logs) {
        log {
                output file /var/log/caddy/access.log
                format json
        }
}

# ----------- Redirection de domaines ------------ #

```

On enregistre.

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
    environment:
      - TZ=Europe/Paris
    volumes:
      - ./Caddyfile:/etc/caddy/Caddyfile
      - ./logs:/var/log/caddy
      - data:/data
      - config:/config
    ports:
      - "80:80"
      - "443:443"
    networks:
      - caddy_network

volumes:
  data:
  config:

networks:
  caddy_network:
    external: true
```

#### Explication du Mappage de volumes

Un conteneur se base sur une image Docker. En gros, c'est une mini-distribution Linux, stockée comme une sorte d'\*.iso (une image immuable en lecture seule).

Docker, afin que ces "mini-distrib" puissent fonctionner correctement, gère (entre autres) le mappage de volumes, permettant aux mini-Linux de voir des fichiers et répertoires en dehors de leur image et d’interagir avec l'hôte.

##### Compréhension du Bind Mount

On observe ici

```yml
- ./Caddyfile:/etc/caddy/Caddyfile
- ./logs:/var/log/caddy
```

- `./Caddyfile:/etc/caddy/Caddyfile`
  - `./Caddyfile` est le chemin hôte (donc sur la machine qui fait tourner Docker)
  - `/etc/caddy/Caddyfile` est le chemin présent sur l'image.
  - Quand le linux du conteneur pensera interagir avec `/etc/caddy/Caddyfile` il sera en fait en train d’interagir avec `./Caddyfile`

C'est le même raisonnement pour `./logs:/var/log/caddy`, à part que `logs` est un répertoire (la syntaxe ne permet pas de faire la distinction dans le path)

##### Compréhension du Named Volume

Ces deux Bind Mount

```yml
- data:/data
- config:/config
```

Sont liés à ces deux Named Volume

```yml
volumes:
  data:
  config:
```

La partie du bas sert à déclarer des volumes nommés (créant des espaces de stockage). Cela permet d'avoir un point de montage nommé qui sera séparé du conteneur. Si on supprime le conteneur, ce qui a été écrit sur ce volume n'est pas supprimé, il reste.

Seulement, si on n'associe pas ce volume au service avec la ligne `- config:/config`, le volume du bas reste juste "existant" mais vide.

C'est pour ça qu'il est mis dans les volumes du service

- `data:/data`
  - `data` (de gauche) est le nom du volume déclaré en bas.
  - `data` (de droite) est le chemin présent sur l'image.
  - Quand le linux du conteneur pensera interagir avec `/data` il sera en fait en train d’interagir avec le volume `data`.

## Création du réseau

C'est un réseau dédié et protégé que Caddy va utiliser.

```bash
sudo docker network create caddy_network
```

## Création du conteneur

Et on lance le `compose up`

```bash
sudo docker compose up -d
```

On wipe les logs (vu que c'est notre installation, on peut le faire)

```bash
sudo truncate -s 0 $(sudo docker inspect --format='{{.LogPath}}' $(sudo docker compose ps -q caddy))
```

et on utilise (pour notre fichier Caddyfile de toute à l'heure) le formateur intégré avec

```bash
sudo docker compose -f /opt/docker/caddy/compose.yml exec -w /etc/caddy caddy caddy fmt --overwrite
```

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
caddy-1  | {"level":"info","ts":1782817773.551094,"logger":"admin.api","msg":"received request","method":"POST","host":"localhost:2019","uri":"/load","remote_ip":"127.0.0.1","remote_port":"52192","headers":{"Caddy-Config-Source-File":["Caddyfile"],"Content-Type":["application/json"],"Origin":["http://localhost:2019"],"Accept-Encoding":["gzip"],"User-Agent":["Go-http-client/1.1"],"Content-Length":["2"],"Caddy-Config-Source-Adapter":["caddyfile"]}}
caddy-1  | {"level":"info","ts":1782817773.5522165,"msg":"config is unchanged"}
caddy-1  | {"level":"info","ts":1782817773.5522926,"logger":"admin.api","msg":"load complete"}
caddy-1  | {"level":"info","ts":1782821173.3904107,"logger":"admin.api","msg":"received request","method":"POST","host":"localhost:2019","uri":"/load","remote_ip":"127.0.0.1","remote_port":"32998","headers":{"User-Agent":["Go-http-client/1.1"],"Content-Length":["2"],"Caddy-Config-Source-Adapter":["caddyfile"],"Caddy-Config-Source-File":["Caddyfile"],"Content-Type":["application/json"],"Origin":["http://localhost:2019"],"Accept-Encoding":["gzip"]}}
caddy-1  | {"level":"info","ts":1782821173.390588,"msg":"config is unchanged"}
caddy-1  | {"level":"info","ts":1782821173.39069,"logger":"admin.api","msg":"load complete"}
```

Voilà, tout est prêt, il faudra à chaque fois ajouter les nouveaux réglages (pour chaque domaine) dans le `Caddyfile`, à la fin du fichier dans la partie `Redirection de domaines`.

Maintenant que `Caddy` est correctement installé, on va terminer la section par un dernier réglage de pare-feu.

## Réglage CloudFlare SSL/TLS

On va sur [dashboard de CloudFlare](dash.cloudflare.com)

- puis `Domaine / Vue d'ensemble` cliquer sur le domaine
- puis `SSL/TLS / Vue d'ensemble`
- cliquer sur le bouton `Configurer`
- choisir `Full (Strict)`
- cliquer sur `Enregistrer`

Ce réglage utilise deux certificats (un créé par Cloudflare pour le visiteur, et un créé par Caddy pour Cloudflare) afin de sécuriser entièrement la connexion de bout en bout et d'éliminer les erreurs.

## Test

Il y a énormément de tests à effectuer pour être sûr que l’infrastructure fonctionne comme désiré.

### Tester une requête http/https

En premier on crée un redirection de test, ça nous servira pour les autres tests aussi

```bash
sudo nano /opt/docker/caddy/Caddyfile
```

Ajoutez cette redirection à la fin, dans la partie `Redirection de domaines`

```text
mondomaine.com, www.mondomaine.com {
        import crowdsec_logs
        respond "Caddy fonctionne avec Cloudflare !"
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

Tester votre domaines avec `curl https://mondomaine.com` il doit renvoyer `Caddy fonctionne avec Cloudflare !`

### Simuler une attaque

Dans le shell du vps, on va simuler une attaque

```bash
sudo docker compose -f /opt/docker/crowdsec/compose.yml exec crowdsec cscli decisions add --ip 99.99.99.99 --reason "crowdsecurity/http-probing" --type ban
```

On vérifie si l'ip a été bannie avec

```bash
sudo docker compose -f /opt/docker/crowdsec/compose.yml exec crowdsec cscli decisions list
```

Vérifier si le bouncer a bien appliqué le blocage

```bash
sudo ipset list | grep 99.99.99.99
```

On peut lever la décision (donc le ban de l'ip)

```bash
sudo docker compose -f /opt/docker/crowdsec/compose.yml exec crowdsec cscli decisions delete --ip 99.99.99.99
```

### Connexion directe interdite

Vérifier que les requêtes directes ne passent pas (seule l'ip de CloudFlare est en liste blanche), mettre la vraie IP du VPS ci-dessous

```bash
curl -I http://192.0.2.1
curl -I https://192.0.2.1
```

### Connaître son IP

```bash
# IPV4
curl https://api.ipify.org

# IPV6
curl https://api6.ipify.org
```

### Retirer notre redirection de test

Nos tests étant finis, on retire notre redirection factice.

```bash
sudo nano /opt/docker/caddy/Caddyfile
```

A la fin du document, dans la partie `Redirection de domaines`, retirer cette redirection

```text
mondomaine.com, www.mondomaine.com {
        import crowdsec_logs
        respond "Caddy fonctionne avec Cloudflare !"
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

Tester une dernière fois votre domaine avec `curl https://mondomaine.com`. Le message de test ne doit plus apparaître.

Voilà, votre Caddy est officiellement prêt pour la production !
