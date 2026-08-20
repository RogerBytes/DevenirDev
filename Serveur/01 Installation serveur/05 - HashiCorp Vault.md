# 05 - HashiCorp Vault

Vault va centraliser tous les secrets de l'infrastructure (clefs API CrowdSec, token Cloudflare, clefs R2, etc.), pour ne plus jamais avoir de secret stocké en clair dans un fichier `.yaml`/`.conf` sur le disque.

Vault tourne en conteneur Docker, mais **n'écoute que sur l'IP privée WireGuard** (`10.10.0.1`, voir doc 04), jamais sur l'IP publique du VPS. Seuls les VPS déjà connectés au réseau WireGuard peuvent l'atteindre.

- A plusieurs moments l'ip `10.10.0.1` correspond au VPS entreprise sur le réseau WireGuard, prenez garde à bien reprendre la votre si elle diffère.

## Prérequis

WireGuard (doc 04) doit déjà être installé et actif, `sudo wg show` doit afficher l'interface `wg0` active, et `ip addr show wg0` doit confirmer l'adresse `10.10.0.1`.

## Convention de nommage des secrets

Tous les secrets suivent cette arborescence dans le moteur KV de Vault, pour ne jamais avoir à improviser un chemin :

```text
secret/crowdsec/firewall-bouncer-api-key
secret/crowdsec/caddy-lapi-key
secret/cloudflare/api-token
secret/cloudflare/r2-access-key-id
secret/cloudflare/r2-secret-access-key
secret/<nom-du-saas>/<nom-du-secret>
```

Chaque futur SaaS reçoit son propre préfixe (`secret/produit-a/...`), ce qui permettra de restreindre l'accès de chaque VPS produit à son seul préfixe via une policy dédiée.

## Installation

<details><summary class="button">🔍 Spoiler</summary><div class="spoiler">

### Création des répertoires

```bash
sudo mkdir -p /opt/docker/vault/config
cd /opt/docker/vault
```

### Fichier de configuration Vault

```bash
sudo nano /opt/docker/vault/config/vault.hcl
```

```hcl
storage "raft" {
  path    = "/vault/data"
  node_id = "vps-entreprise"
}

listener "tcp" {
  address     = "0.0.0.0:8200"
  tls_disable = "true"
}

api_addr     = "http://10.10.0.1:8200"
cluster_addr = "http://10.10.0.1:8201"

disable_mlock = false
ui = true
```

Le TLS est désactivé volontairement ici : le trafic transite déjà dans le tunnel chiffré WireGuard, la connexion n'est jamais en clair sur le réseau. Le listener écoute sur `0.0.0.0:8200` **à l'intérieur** du conteneur, mais Docker ne publiera ce port que sur l'IP WireGuard côté hôte (voir le `compose.yml` ci-dessous), donc rien n'est jamais accessible depuis l'IP publique.

On protège l'accès

```bash
sudo chmod 644 /opt/docker/vault/config/vault.hcl
```

### Le compose

```bash
sudo nano /opt/docker/vault/compose.yml
```

```yaml
services:
  vault:
    image: hashicorp/vault:latest
    container_name: vault
    restart: unless-stopped
    cap_add:
      - IPC_LOCK
    environment:
      - VAULT_ADDR=http://127.0.0.1:8200
    volumes:
      - ./config/vault.hcl:/vault/config/vault.hcl:ro
      - data:/vault/data
      - logs:/vault/logs
    ports:
      - "10.10.0.1:8200:8200"
    command: server
    ulimits:
      memlock:
        soft: -1
        hard: -1
    networks:
      - caddy_network

volumes:
  data:
  logs:

networks:
  caddy_network:
    external: true
```

**Correction importante :** le bloc `networks: caddy_network: external: true` en bas est indispensable. Sans lui, Docker Compose crée un **nouveau** réseau nommé `vault_caddy_network` (préfixé par le nom du dossier projet) au lieu de rejoindre le réseau `caddy_network` déjà existant utilisé par Caddy — le conteneur Vault se retrouverait isolé, connecté à un réseau vide.

`cap_add: IPC_LOCK` est nécessaire pour empêcher le système d'exploitation d'écrire la mémoire de Vault dans le swap (les secrets déchiffrés en mémoire ne doivent jamais atterrir sur le disque, même temporairement).

`ports: "10.10.0.1:8200:8200"` restreint la publication du port à cette seule IP hôte — c'est ce qui garantit qu'aucune tentative de connexion depuis l'IP publique n'aboutira, sans même avoir besoin d'une règle UFW dédiée.

### Création du conteneur

```bash
sudo docker compose up -d
```

### Correction des permissions du volume de données

L'image officielle de Vault tourne avec un utilisateur non-root à l'intérieur du conteneur (UID 100, GID 1000), alors que Docker crée le volume `vault_data` appartenant à `root` par défaut. Il faut corriger ça une seule fois :

```bash
sudo docker run --rm -v vault_data:/vault/data alpine chown -R 100:1000 /vault/data
sudo docker compose up -d --force-recreate
```

On vérifie

```bash
sudo docker compose logs -f
```

Si on voit `==> Vault server started! Log data will stream in below:`. Si elle apparaît sans message d'erreur juste avant (type `Error parsing listener configuration` ou `bind: address already in use`), Vault a démarré correctement.

et

```bash
sudo docker exec -it vault vault status
```

Il doit afficher `Initialized: false` et `Sealed: true`, c'est normal, c'est l'étape suivante.

</div></details>

## Initialisation (à ne faire qu'une seule fois dans la vie de ce Vault)

<details><summary class="button">🔍 Spoiler</summary><div class="spoiler">

```bash
sudo docker exec -it vault vault operator init -key-shares=5 -key-threshold=3
```

Cette commande ne se lance **qu'une seule fois**. Elle retourne :

- **5 Unseal Keys** (parts de la clef de déverrouillage, il en faudra 3 sur 5 à chaque redémarrage de Vault)
- **1 Initial Root Token** (le jeton d'administration complet de Vault)

**Ces informations n'apparaissent qu'une seule fois et ne sont jamais ré-affichables.** Il faut les répartir immédiatement comme vos autres secrets critiques :

- Les 5 parts de clef doivent être séparées sur des supports différents (par exemple : 2 dans VaultWarden, 1 sur la clef USB dédiée, 1 sur papier dans le coffre physique, 1 sur le Cloud personnel) — jamais toutes au même endroit, sinon le principe du seuil (3 sur 5) ne protège plus rien.
- Le Root Token est à stocker dans VaultWarden comme un mot de passe classique, et ne doit servir qu'à la configuration initiale (créer les policies et AppRoles), jamais à l'usage quotidien.

</div></details>

## Déverrouillage (unseal)

<details><summary class="button">🔍 Spoiler</summary><div class="spoiler">

À chaque démarrage ou redémarrage du conteneur Vault, celui-ci démarre scellé (sealed) et ne répond à aucune requête tant qu'il n'est pas déverrouillé. Il faut fournir 3 des 5 parts de clef générées à l'initialisation :

```bash
sudo docker exec -it vault vault operator unseal
```

La commande demande une part de clef, on la colle, on valide. **On répète l'opération 3 fois (avec 3 parts différentes parmi les 5)**.

On vérifie l'état

```bash
sudo docker exec -it vault vault status
```

`Sealed: false` confirme que Vault est déverrouillé et opérationnel.

**Ce n'est pas automatisable par un script stocké sur le serveur** (ça reviendrait à stocker les clefs de unseal sur la machine qu'elles protègent, ce qui annule toute la protection). L'opération reste volontairement manuelle et humaine à chaque redémarrage du conteneur ou reboot du VPS.

</div></details>

## Premier login et configuration du moteur de secrets

<details><summary class="button">🔍 Spoiler</summary><div class="spoiler">

Depuis le VPS entreprise (qui a accès à `10.10.0.1` directement, sans passer par le tunnel puisqu'il en est l'extrémité) :

```bash
sudo docker exec -it vault vault login
```

On colle le Root Token généré à l'initialisation. et il retourne

```bash
$ sudo docker exec -it vault vault login
Success! You are now authenticated. The token information displayed below
is already stored in the token helper. You do NOT need to run "vault login"
again. Future Vault requests will automatically use this token.

Key                  Value
---                  -----
token                xxxxxxxxxxxxxxxxx
token_accessor       xxxxxxxxxx
token_duration       ∞
token_renewable      falsetoken_policies       ["root"]
identity_policies    []
policies             ["root"]
```

**Ceci ne se fait qu'une seule fois, pour toute la vie du serveur.** Pas besoin de refaire ce login après un reboot ni après un restart du conteneur — contrairement à l'unseal (voir plus haut), qui lui doit être refait à chaque redémarrage.

### Activation du moteur KV version 2

```bash
sudo docker exec -it vault vault secrets enable -path=secret -version=2 kv
```

Il dit `Success! Enabled the kv secrets engine at: secret/`.

### Test d'écriture et de lecture d'un secret

```bash
sudo docker exec -it vault vault kv put secret/cloudflare/api-token value="mon_token_de_test"
sudo docker exec -it vault vault kv get secret/cloudflare/api-token
```

Si la valeur s'affiche correctement, le moteur de secrets est opérationnel.

</div></details>

## Migration des secrets existants (ne pas faire sur un vps vierge)

<details><summary class="button">🔍 Spoiler</summary><div class="spoiler">

**Attention** ceci est à faire sur un vps déjà existant avec divers services, si le serveur est vierge, pas besoin.

On migre progressivement les secrets aujourd'hui en clair sur le VPS entreprise, selon la convention de nommage définie plus haut :

```bash
sudo docker exec -it vault vault kv put secret/cloudflare/api-token value="<TOKEN CLOUDFLARE>"
sudo docker exec -it vault vault kv put secret/cloudflare/r2-access-key-id value="<ID CLE R2>"
sudo docker exec -it vault vault kv put secret/cloudflare/r2-secret-access-key value="<CLE SECRETE R2>"
```

Une fois un secret migré et vérifié dans Vault, on supprime sa version en clair du fichier `.yaml`/`.conf` d'origine sur le disque, et on adapte le `compose.yml` du service concerné pour qu'il aille chercher la valeur dans Vault au démarrage (via un script de déploiement ou `vault agent`, à détailler dans une doc dédiée le moment venu).

</div></details>

## AppRole : accès dédié pour chaque futur VPS produit

<details><summary class="button">🔍 Spoiler</summary><div class="spoiler">

Chaque VPS produit doit avoir un accès limité à son seul préfixe de secrets, jamais un accès complet à Vault. On utilise l'authentification AppRole pour ça.

### Activation de la méthode AppRole (une seule fois)

```bash
sudo docker exec -it vault vault auth enable approle
```

### Création d'une policy dédiée à un SaaS (exemple : `produit-a`)

Remplacer `produit-a` (dans `vault policy write produit-a-policy` et `path "secret/data/produit-a/*"`) par le nom du Saas, afin de pouvoir bien gérer les accès.

```bash
sudo docker exec -it vault sh -c 'cat <<EOF | vault policy write produit-a-policy -
path "secret/data/produit-a/*" {
  capabilities = ["read", "list"]
}
EOF'
```

Cette policy ne donne accès qu'en lecture au préfixe `secret/produit-a/*`, jamais aux autres SaaS ni aux secrets d'infrastructure (`crowdsec/`, `cloudflare/`).

### Création du rôle AppRole lié à cette policy

Remplacer `produit-a` (dans `auth/approle/role/produit-a` et `token_policies="produit-a-policy"`) par le nom du Saas, afin de pouvoir bien gérer les accès.

```bash
sudo docker exec -it vault vault write auth/approle/role/produit-a \
    token_policies="produit-a-policy" \
    token_ttl=1h \
    token_max_ttl=4h
```

### Récupération du `role_id` (fixe, à donner au VPS produit)

Remplacer `produit-a` (dans `auth/approle/role/produit-a/role-id`) par le nom du Saas, afin de pouvoir bien gérer les accès.

```bash
sudo docker exec -it vault vault read auth/approle/role/produit-a/role-id
```

### Génération du `secret_id` (temporaire, ne pas le laisser stocké en clair longtemps)

**Note :** par défaut, cette commande ne limite ni le nombre d'usages ni la durée de vie du `secret_id` (il reste valable et réutilisable selon le TTL par défaut du système). Si tu veux un vrai usage unique, ajoute `secret_id_num_uses=1` à la création du rôle plus bas. Ici on le garde réutilisable volontairement, car le Vault Agent (voir plus bas) peut avoir besoin de s'authentifier à nouveau après un redémarrage du VPS produit.

Remplacer `produit-a` (dans `auth/approle/role/produit-a/role-id`) par le nom du Saas, afin de pouvoir bien gérer les accès.

```bash
sudo docker exec -it vault vault write -f auth/approle/role/produit-a/secret-id
```

Ces deux valeurs (`role_id` + `secret_id`) sont transmises une seule fois au VPS produit (via une connexion déjà sécurisée, par exemple le tunnel WireGuard), qui s'en sert pour obtenir un token temporaire :

```bash
vault write auth/approle/login role_id="<ROLE_ID>" secret_id="<SECRET_ID>"
```

Ce token temporaire (durée de vie 1h, renouvelable jusqu'à 4h) est ensuite utilisé par le VPS produit pour lire ses propres secrets, jamais ceux des autres SaaS. Pour que le renouvellement se fasse sans intervention manuelle, il faudra installer et configurer `vault agent` sur le VPS produit (étape à faire une fois, détaillée dans une doc dédiée le moment venu) — c'est lui qui redemandera un nouveau token tout seul avant expiration, sans avoir besoin de relancer la commande à la main.

</div></details>

## Sauvegarde du Vault

<details><summary class="button">🔍 Spoiler</summary><div class="spoiler">

Le stockage `raft` se sauvegarde en un seul snapshot, à ajouter à votre routine de backup (voir doc 10 - Offen Docker Volume Backup, à étendre pour inclure ce fichier) :

```bash
sudo docker exec -it vault vault operator raft snapshot save /vault/data/backup.snap
```

Ce fichier reste chiffré (il ne peut être restauré et lu qu'avec le même Vault déverrouillé par les mêmes parts de clef), il peut donc être envoyé vers R2 comme les autres sauvegardes sans risque de fuite en clair.

Pour restaurer sur une nouvelle machine (par exemple, un jour où vous décidez d'héberger Vault sur un serveur dédié) :

```bash
sudo docker exec -it vault vault operator raft snapshot restore /vault/data/backup.snap
```

</div></details>

## Vault Agent : renouvellement automatique du token (à faire sur chaque VPS produit)

<details><summary class="button">🔍 Spoiler</summary><div class="spoiler">

Cette partie se fait sur le **VPS produit** (le "bébé"), pas sur le hub. Elle permet au VPS produit d'obtenir et de renouveler son token tout seul, sans intervention manuelle, puis d'écrire les secrets récupérés dans un fichier `.env` que ses conteneurs peuvent consommer normalement.

### Prérequis de l'agent

Le VPS produit doit être connecté au réseau WireGuard (voir doc 04) et pouvoir joindre `10.10.0.1:8200`. On vérifie avec :

```bash
curl -s http://10.10.0.1:8200/v1/sys/health
```

Si ça retourne du JSON (même une erreur type `sealed`), la connexion réseau fonctionne.

### Stockage du `role_id` et du `secret_id`

On crée un répertoire dédié, avec des permissions strictes, pour stocker les deux identifiants reçus du hub :

```bash
sudo mkdir -p /opt/docker/vault-agent/secrets
sudo chmod 700 /opt/docker/vault-agent/secrets
```

```bash
echo "<ROLE_ID>" | sudo tee /opt/docker/vault-agent/secrets/role_id > /dev/null
echo "<SECRET_ID>" | sudo tee /opt/docker/vault-agent/secrets/secret_id > /dev/null
sudo chmod 600 /opt/docker/vault-agent/secrets/role_id /opt/docker/vault-agent/secrets/secret_id
```

Remplacer `<ROLE_ID>` et `<SECRET_ID>` par les valeurs générées sur le hub. Le `secret_id` étant à usage limité, une fois consommé une première fois par l'agent, il n'est plus nécessaire de le garder — mais on le laisse en place, l'agent peut avoir besoin de s'authentifier à nouveau après un redémarrage du VPS produit.

### Fichier de configuration de l'agent

```bash
sudo mkdir -p /opt/docker/vault-agent/config
sudo nano /opt/docker/vault-agent/config/agent.hcl
```

```hcl
vault {
  address = "http://10.10.0.1:8200"
}

auto_auth {
  method "approle" {
    config = {
      role_id_file_path   = "/vault/secrets/role_id"
      secret_id_file_path = "/vault/secrets/secret_id"
    }
  }

  sink "file" {
    config = {
      path = "/vault/secrets/token"
    }
  }
}

template {
  source      = "/vault/config/secrets.ctmpl"
  destination = "/vault/output/secrets.env"
}
```

### Le template de rendu des secrets

Ce fichier décrit quels secrets récupérer et sous quel nom de variable les écrire dans le `.env` final. Remplacer `<NOM_SAAS>` par le préfixe utilisé sur le hub (celui donné lors de la création de la policy) :

```bash
sudo nano /opt/docker/vault-agent/config/secrets.ctmpl
```

```text
{{- with secret "secret/data/<NOM_SAAS>/exemple-cle" -}}
EXEMPLE_CLE={{ .Data.data.value }}
{{- end }}
```

Un bloc `{{- with secret "..." -}}` par secret à récupérer, à dupliquer pour chaque variable dont tes conteneurs ont besoin.

### Le compose de l'agent

```bash
sudo nano /opt/docker/vault-agent/compose.yml
```

```yaml
services:
  vault-agent:
    image: hashicorp/vault:latest
    container_name: vault-agent
    restart: unless-stopped
    volumes:
      - ./config:/vault/config:ro
      - ./secrets:/vault/secrets
      - output:/vault/output
    command: agent -config=/vault/config/agent.hcl

volumes:
  output:
```

### Création du conteneur de l'agent

```bash
cd /opt/docker/vault-agent
sudo docker compose up -d
```

### Vérification

```bash
sudo docker compose logs -f
```

On doit voir l'agent s'authentifier avec succès, puis générer le fichier `secrets.env` régulièrement.

Le fichier généré (`/vault/output/secrets.env`, dans le volume `output`) peut ensuite être référencé comme n'importe quel `.env` via `env_file:` dans le `compose.yml` du service applicatif du VPS produit — l'agent le tiendra à jour tout seul en arrière-plan, sans que tu aies à relancer quoi que ce soit manuellement.

</div></details>

## Auteur

[<img src="https://github.com/RogerBytes.png" width="40" height="40" style="border-radius:50%;" alt="RogerBytes' avatar">](https://github.com/RogerBytes)
[**RogerBytes (Harry Richmond)**](https://github.com/RogerBytes)

<span hidden>
<details><summary></summary>
<style>.spoiler{border-left:4px solid #1abc9c;border-bottom-left-radius:3px;padding-left:10px;padding-top:15px;margin-top:-10px;margin-bottom:15px}.button{cursor:pointer;padding:5px 10px;background-color:#3498db;color:white;border-radius:3px;margin-bottom:5px;display:inline-block;transition:background-color 0.2s}.button:hover{background-color:#217dbb}details[open] .button{background-color:#1abc9c}</style>
</details></span>

<p align="right"><a href="#">🔝 Retour en haut</a></p>
