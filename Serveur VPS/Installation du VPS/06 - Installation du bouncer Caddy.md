# 06 - Installation du bouncer Caddy

- Depuis [Page docker hub](https://hub.docker.com/_/caddy)
- Depuis [Page GitHub](https://github.com/caddyserver/caddy)
- Depuis [Le compose](https://caddyserver.com/docs/running#docker-compose)
- Depuis [La commande Docker](https://caddyserver.com/docs/install#docker)

## Prérequis

### Fichier de configuration

```bash
sudo mkdir -p /opt/docker/crowdsec/config/appsec-configs
sudo nano /opt/docker/crowdsec/config/appsec-configs/custom-config.yaml
```

```bash
name: custom/custom-config
inband_rules:
  - crowdsecurity/base-config
  - crowdsecurity/vpatch-*
  - crowdsecurity/generic-*
  - crowdsecurity/crs
outofband_rules:
  - crowdsecurity/appsec-generic-test
default_remediation: ban
blocked_http_code: 403
```

### Configuration de appsec

```bash
sudo mkdir -p /opt/docker/crowdsec/config/acquis.d
sudo nano /opt/docker/crowdsec/config/acquis.d/appsec.yaml
```

On lui met

```bash
source: appsec
listen_addr: 0.0.0.0:7422
appsec_configs:
  - custom/custom-config
labels:
  type: appsec
```

#### Mettre à jour les collections crowdsec

```bash
sudo rm -f /opt/docker/crowdsec/compose.yml
sudo nano /opt/docker/crowdsec/compose.yml
```

```yml
services:
  crowdsec:
    image: crowdsecurity/crowdsec:latest
    container_name: crowdsec
    restart: unless-stopped
    environment:
      COLLECTIONS: "crowdsecurity/sshd crowdsecurity/linux crowdsecurity/caddy crowdsecurity/appsec-virtual-patching crowdsecurity/appsec-generic-rules crowdsecurity/appsec-crs"
    volumes:
      - /opt/docker/crowdsec/config/appsec-configs:/etc/crowdsec/appsec-configs/custom:ro
      - /opt/docker/crowdsec/config/acquis.yaml:/etc/crowdsec/acquis.yaml:ro
      - /opt/docker/crowdsec/config/acquis.d:/etc/crowdsec/acquis.d:ro
      - /opt/docker/crowdsec/data:/var/lib/crowdsec/data
      - /var/log/auth.log:/var/log/auth.log:ro
      - /opt/docker/caddy/logs:/opt/docker/caddy/logs:ro
    ports:
      - "127.0.0.1:8080:8080"
    networks:
      - caddy_network

networks:
  caddy_network:
    external: true
```

On applique les changements (on lui a aussi ajouté le réseau caddy_network)

```bash
cd /opt/docker/crowdsec
sudo docker compose up -d --force-recreate
```

### Création de l'image personnalisée de Caddy

```bash
cd /opt/docker/caddy
```

et on fait le fichier Dockerfile (depuis [cette page github](https://github.com/hslatman/caddy-crowdsec-bouncer/blob/main/README.md))

```bash
sudo nano Dockerfile
```

```dockerfile
ARG CADDY_VERSION=2

FROM caddy:${CADDY_VERSION}-builder-alpine AS builder

RUN xcaddy build \
    --with github.com/mholt/caddy-l4 \
    --with github.com/caddyserver/transform-encoder \
    --with github.com/hslatman/caddy-crowdsec-bouncer/http@main \
    --with github.com/hslatman/caddy-crowdsec-bouncer/appsec@main \
    --with github.com/hslatman/caddy-crowdsec-bouncer/layer4@main

FROM caddy:${CADDY_VERSION}

COPY --from=builder /usr/bin/caddy /usr/bin/caddy
```

### On met à jour le conteneur Caddy

```bash
sudo rm -f /opt/docker/caddy/compose.yml
sudo nano /opt/docker/caddy/compose.yml
```

```yml
services:
  caddy:
    build:
      context: .
      dockerfile: Dockerfile
    container_name: caddy
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

On lance la création de l'image et du conteneur

```bash
cd /opt/docker/caddy
sudo docker compose up -d --build
```

## Paramétrage du Caddyfile

### Générer la clef LAPI de CrowdSec

La commande

```bash
sudo docker compose -f /opt/docker/crowdsec/compose.yml exec crowdsec cscli bouncers add caddy-bouncer
```

Bien noter la clef, on va la mettre dans notre Caddyfile

### Configuration Caddyfile

```bash
sudo rm -f /opt/docker/caddy/Caddyfile
sudo nano /opt/docker/caddy/Caddyfile
```

```text
# --------------- Réglages globaux --------------- #
{
    servers {
        # Reconnaissance de la vraie IP derrière Cloudflare
        trusted_proxies static 173.245.48.0/20 103.21.244.0/22 103.22.200.0/22 103.31.4.0/22 141.101.64.0/18 108.162.192.0/18 190.93.240.0/20 188.114.96.0/20 197.234.240.0/22 198.41.128.0/17 162.158.0.0/15 104.16.0.0/12
    }

    crowdsec {
        api_url http://crowdsec:8080
        api_key <REMPLACER PAR CLEF API>
        ticker_interval 15s
        appsec_url http://crowdsec:7422
    }
}

# ------------------- CrowdSec ------------------- #


(crowdsec_bouncer) {
    log {
        output file /var/log/caddy/access.log
        format json
    }
    route {
        crowdsec
        appsec
    }
}

# ----------- Redirection de domaines ------------ #

```

Exemples pour les conteneurs/services

```text
mondomaine.com, www.mondomaine.com {
        import crowdsec_bouncer
        respond "Caddy fonctionne avec Cloudflare !"
}
```

et on utilise (pour notre fichier Caddyfile de toute à l'heure) le formateur intégré avec

```bash
sudo docker compose -f /opt/docker/caddy/compose.yml exec -w /etc/caddy caddy caddy fmt --overwrite
```

et on relance caddy

```bash
sudo docker compose -f /opt/docker/caddy/compose.yml exec -w /etc/caddy caddy caddy reload
cd /opt/docker/caddy
sudo docker compose restart caddy
```

## Tests

En premier on crée une redirection de test, ça nous servira pour les autres tests aussi

```bash
sudo nano /opt/docker/caddy/Caddyfile
```

Ajoutez cette redirection à la fin, dans la partie `Redirection de domaines`

```text
rogerbytes.com, www.rogerbytes.com {
    import crowdsec_bouncer
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

### On fait les essais

A voir, pas indispensable, si le reste de la doc marche, c'est pas important.

```bash
curl -I --resolve mondomaine.com:80:127.0.0.1 http://mondomaine.com/
```

```bash
# Détecté en erreur 403 (c'est normal)
curl -kI --resolve rogerbytes.com:443:127.0.0.1 "https://rogerbytes.com/.env"

curl -s -D - -k --resolve rogerbytes.com:443:127.0.0.1 "https://rogerbytes.com/?id=1%20UNION%20SELECT%20username,%20password%20FROM%20users"
```
