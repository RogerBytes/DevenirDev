# 08 - Installation du bouncer worker CloudFlare

Il faut prendre `Cloudflare Workers plan` à 5$ par mois, [depuis le dashboard CloudFlare](https://dash.cloudflare.com/), il faut aller dans `Calcul / Offres Workers` et prendre l'offre payante à 5$ par mois..

## Prérequis

Le conteneur `vault` (doc 05) doit être connecté au réseau `caddy_network`, sinon ce service ne pourra pas le résoudre par son nom. Vérifier avec :

```bash
sudo docker network inspect caddy_network --format '{{range .Containers}}{{.Name}} {{end}}'
```

`vault` doit apparaître dans la liste. Si absent, voir doc 05 pour l'ajout du réseau dans son `compose.yml`.

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

### Récupération de la clé LAPI CrowdSec, et stockage dans Vault

```bash
sudo docker exec crowdsec cscli bouncers add cloudflare-bouncer
```

```bash
sudo docker exec -it vault vault kv put secret/crowdsec/caddy-lapi-key value="<CLE_LAPI_GENEREE>"
```

### Génération ponctuelle du template de base

Le token doit d'abord servir une fois pour générer la structure de `cfg.yaml` (le worker CrowdSec l'exige à la création). On le fait une seule fois, en récupérant le token depuis Vault sans jamais le taper à la main :

```bash
TOKEN=$(sudo docker exec vault vault kv get -field=value secret/cloudflare/api-token)
sudo docker run crowdsecurity/cloudflare-worker-bouncer \
  -g "$TOKEN" | sudo tee /opt/docker/cf-bouncer/config/cfg-base.yaml
unset TOKEN
```

Ce fichier `cfg-base.yaml` sert uniquement de référence pour connaître la structure attendue (namespace KV, ID du worker, etc.) — il ne sera pas celui utilisé en production, garde-le juste pour t'y référer si besoin, avec `chmod 600` :

```bash
sudo chmod 600 /opt/docker/cf-bouncer/config/cfg-base.yaml
```

### Policy Vault dédiée à ce service

```bash
sudo docker exec -it vault sh -c 'cat <<EOF | vault policy write cf-bouncer-policy -
path "secret/data/cloudflare/api-token" {
  capabilities = ["read"]
}
path "secret/data/crowdsec/caddy-lapi-key" {
  capabilities = ["read"]
}
EOF'
```

Un token classique lié à cette policy suffit ici — pas besoin d'AppRole puisque ce service tourne sur le hub, à côté de Vault :

```bash
sudo docker exec -it vault vault token create -policy=cf-bouncer-policy -ttl=768h -field=token
```

Garde ce token précieusement (dans VaultWarden), on l'utilise juste après.

### Répertoire et template de rendu

```bash
sudo mkdir -p /opt/docker/cf-bouncer/agent-config
sudo nano /opt/docker/cf-bouncer/agent-config/cfg.ctmpl
```

Penser à modifier `mondomaine.com` et `adressedemoncompteCF@mondomaine.comuy`

```text
cloudflare_config:
    worker:
        script_name: ""
        logpush: null
        tags: []
        compatibility_date: ""
        compatibility_flags: []
        log_only: false
    decisions_sync_worker:
        cron: '*/5 * * * *'
    accounts:
        - id: <TON_ACCOUNT_ID>
          ban_template: ""
          zones:
            - zone_id: <TON_ZONE_ID>
              actions:
                - captcha
              default_action: captcha
              routes_to_protect:
                - '*mondomaine.com/*'
              turnstile:
                enabled: true
                rotate_secret_key: true
                rotate_secret_key_every: 168h0m0s
                mode: managed
          token: {{ with secret "secret/data/cloudflare/api-token" }}{{ .Data.data.value }}{{ end }}
          account_name: adressedemoncompteCF@mondomaine.com

crowdsec_config:
    lapi_url: http://crowdsec:8080
    lapi_key: {{ with secret "secret/data/crowdsec/caddy-lapi-key" }}{{ .Data.data.value }}{{ end }}
    update_frequency: 10s
    include_scenarios_containing: []
    exclude_scenarios_containing: []
    only_include_decisions_from: []
    key_path: ""
    cert_path: ""
    ca_cert_path: ""

daemon: true
log_level: info
log_mode: stdout
log_dir: ""
prometheus:
    enabled: false
    listen_addr: 0.0.0.0
    listen_port: "2112"
```

Remplace <TON_ACCOUNT_ID> et <TON_ZONE_ID> par les vraies valeurs que tu as vues dans ton cfg-base.yaml (celles en xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx), ce ne sont pas des secrets, juste des identifiants de compte/zone.

Pour afficher

```bash
sudo cat /opt/docker/cf-bouncer/config/cfg-base.yaml
```

*(Ajuster la structure exacte selon ce que retourne réellement `cfg-base.yaml` généré plus haut — les clés `account_token`/`kv_namespace_id`/etc. peuvent varier selon la version du bouncer.)*

### Configuration de l'agent Vault dédié

```bash
sudo nano /opt/docker/cf-bouncer/agent-config/agent.hcl
```

```hcl
vault {
  address = "http://vault:8200"
}

auto_auth {
  method "token_file" {
    config = {
      token_file_path = "/vault/secrets/token"
    }
  }
}

template {
  source      = "/vault/config/cfg.ctmpl"
  destination = "/vault/output/crowdsec-cloudflare-worker-bouncer.yaml"
  perms       = "0600"
}
```

On dépose le token généré plus haut dans un fichier lu au démarrage :

```bash
echo "<TOKEN_GENERE_PLUS_HAUT>" | sudo tee /opt/docker/cf-bouncer/agent-config/token > /dev/null
sudo chown 100:1000 /opt/docker/cf-bouncer/agent-config/token
sudo chmod 600 /opt/docker/cf-bouncer/agent-config/token
```

### Création du `compose.yml`

```bash
sudo nano /opt/docker/cf-bouncer/compose.yml
```

```yaml
services:
  cf-bouncer-agent:
    image: hashicorp/vault:latest
    container_name: cf-bouncer-agent
    restart: unless-stopped
    volumes:
      - ./agent-config:/vault/config:ro
      - ./agent-config/token:/vault/secrets/token:ro
      - cfg-output:/vault/output
    command: agent -config=/vault/config/agent.hcl
    networks:
      - caddy_network

  cf-bouncer:
    image: crowdsecurity/cloudflare-worker-bouncer
    container_name: cf-bouncer
    restart: unless-stopped
    depends_on:
      - cf-bouncer-agent
    volumes:
      - cfg-output:/etc/crowdsec/bouncers
    networks:
      - caddy_network

volumes:
  cfg-output:

networks:
  caddy_network:
    external: true
```

Le fichier `cfg.yaml` généré par l'agent est monté dans le conteneur `cf-bouncer` via un volume partagé (`cfg-output`) — le token/la clé LAPI ne transitent jamais par un `compose.yml` en clair, ni par une saisie manuelle une fois cette mise en place terminée.

### Préparation du volume de sortie

On crée le volume à l'avance et on corrige ses permissions, pour que l'utilisateur non-root de l'agent Vault puisse y écrire :

```bash
sudo docker volume create cf-bouncer_cfg-output
sudo docker run --rm -v cf-bouncer_cfg-output:/vault/output alpine chown -R 100:1000 /vault/output
```

## Création des conteneurs

```bash
cd /opt/docker/cf-bouncer
sudo docker compose up -d
```

On vérifie que l'agent a bien généré le fichier :

```bash
sudo docker compose logs cf-bouncer-agent --tail=30
```

## Vérification

La liste communautaire peut prendre [2 heures](https://discourse.crowdsec.net/t/default-pull-interval/606) avant d'être chargée

```bash
sudo docker exec crowdsec cscli decisions list --all -o json | grep -c '"id"'
```

S'il retourne un nombre supérieur à 10000, c'est que la liste communautaire est bien importée.

Et pour vérifier ses logs

```bash
sudo docker compose logs cf-bouncer --tail=50
```

### Vérifier dans le Dashboard de CloudFlare

Aller sur [le dashboard de CloudFlare](https://dash.cloudflare.com), puis aller dans

**Pour voir le Worker :** `Calcul / Workers et Pages` → `crowdsec-cloudflare-worker-bouncer`

**Pour voir le KV store (avec les bans ip) :** `Stockage et base de données / Workers KV` → `CROWDSECCFBOUNCERNS`
