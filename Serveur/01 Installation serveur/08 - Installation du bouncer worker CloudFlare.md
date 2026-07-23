# 08 - Installation du bouncer worker CloudFlare

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

### Stocker le token CloudFlare dans Vault

Plutôt que de le garder en clair dans un fichier, on l'enregistre directement dans Vault (voir doc 05) :

```bash
sudo docker exec -it vault vault kv put secret/cloudflare/api-token value="<TON_TOKEN_CLOUDFLARE>"
```

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

On protège l'accès

```bash
sudo chmod 600 /opt/docker/cf-bouncer/cfg.yaml
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

On attend un peu, et on le restart

```bash
sudo docker compose -f /opt/docker/cf-bouncer/compose.yml restart
```

### Vérifier depuis le serveur

La liste communautaire peut prendre [2 heures](https://discourse.crowdsec.net/t/default-pull-interval/606) avant d'être chargée

On vérifie si elle a été téléchargée

```bash
sudo docker exec crowdsec cscli decisions list --origin community-blocklist
```

Et pour vérifier ses logs

```bash
sudo docker compose -f /opt/docker/cf-bouncer/compose.yml logs --tail=50
```

Et on nettoie les anciens conteneurs

```bash
sudo docker container prune -f
```

Si on liste les conteneurs avec `sudo docker ps -a`, on doit avoir `caddy-caddy`, `crowdsecurity/cloudflare-worker-bouncer` et `crowdsecurity/crowdsec:latest` en up/actifs.

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

- Clique sur ton domaine `mondomaine.com`
- Dans le menu gauche → **"Routes Workers"**
- Tu devrais voir la route `*mondomaine.com/*` liée au worker CrowdSec
