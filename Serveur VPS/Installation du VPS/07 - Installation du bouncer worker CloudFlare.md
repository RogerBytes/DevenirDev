# 07 - Installation du bouncer worker CloudFlare

Il faut prendre `Cloudflare Workers plan` à 5$ par mois, [depuis le dashboard CloudFlare](https://dash.cloudflare.com/), il faut aller dans `Calcul / Offres Workers` et prendre l'offre payante à 5$ par mois..

## Prérequis

### Créer le token API CloudFlare

Aller sur [page](https://dash.cloudflare.com/profile/api-tokens), ne pas utiliser le jeton créé automatiquement, il ne sert pas à ça.

Cliquer sur `+ Créer un jeton` puis `Créer un jeton personnalisé / Commencer`, et mettre `CrowdSec CloudFlare Bouncer` comme Nom du jeton

- `Compte` / `Stockage KV de Workers` → **Modifier**
- `Compte` / `Scripts de Workers` → **Modifier**
- `Compte` / `Turnstile` → **Modifier**
- `Zone` / `Zone` → **Lu**
- `Zone` / `DNS` → **Lu**
- `Zone` / `Routes Workers` → **Modifier**

Pour le scope :

- Ressources du compte → "Inclure" -> le compte
- Ressources de la zone → Toutes les zones

Puis cliquer en bas sur `Continuer vers le résumé`, puis `Créer un jeton`.

Une fois créé, il faut bien conserver le token.

### Lancer la configuration du bouncer worker avec le token de CloudFlare

On créé le repertoire pour le conteneur

```bash
sudo mkdir -p /opt/docker/cf-bouncer
```

Puis on lance cette commande pour générer la configuration (bien penser à mettre son token worker de CloudFlare)

```bash
sudo docker run crowdsecurity/cloudflare-worker-bouncer \
  -g LE_TOKEN_CLOUDFLARE | sudo tee /opt/docker/cf-bouncer/cfg.yaml
```

### Fichier de configuration du bouncer worker

```bash
sudo docker exec crowdsec cscli bouncers add cloudflare-bouncer
```

On note précieusement la clef, on va s'en servir juste après.

On édite le fichier

```bash
sudo nano /opt/docker/cf-bouncer/cfg.yaml
```

Pour `lapi_url:` et `lapi_key`, on met

```bash
crowdsec_config:
    lapi_url: http://crowdsec:8080
    lapi_key: COLLER_LA_CLÉ_ICI
```

Et remplacer `daemon: false` par `daemon: true`.

### Création du compose.yml

```bash
sudo nano /opt/docker/cf-bouncer/compose.yml
```

```yml
services:
  cf-bouncer:
    image: crowdsecurity/cloudflare-worker-bouncer
    container_name: cf-bouncer
    restart: unless-stopped
    volumes:
      - ./cfg.yaml:/etc/crowdsec/bouncers/crowdsec-cloudflare-worker-bouncer.yaml
    networks:
      - caddy_network

networks:
  caddy_network:
    external: true
```

## Création du conteneur

On va dans le répertoire

```bash
cd /opt/docker/cf-bouncer
```

puis on lance

```bash
sudo docker compose up -d
```

### Vérifier dans le Dashboard de CloudFlare

Aller sur [le dashboard de CloudFlare](https://dash.cloudflare.com), puis aller dans

**Pour voir le Worker :**

- Clique sur **"Calcul / Workers et Pages"** dans le menu de gauche
- Tu devrais voir un worker nommé `crowdsec-cloudflare-worker-bouncer`

**Pour voir le KV store :**

- Clique sur **"Stockage et base de données / Workers KV"**
- Tu devrais voir un namespace nommé `CROWDSECCFBOUNCERNS`
- Clique dessus puis sur **"Paires KV "** pour voir les IPs bannies

**Pour voir les routes protégées :**

- Clique sur ton domaine `rogerbytes.com`
- Dans le menu gauche → **"Routes Workers"**
- Tu devrais voir la route `*rogerbytes.com/*` liée au worker CrowdSec
