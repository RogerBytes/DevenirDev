# 01 - Installation VaultWarden

Depuis [Page docker hub](https://hub.docker.com/r/vaultwarden/server)
Depuis [Page GitHub](https://github.com/dani-garcia/vaultwarden)

- A plusieurs moments l'ipv4 utilisé pour SSH est `192.0.2.1`, prenez garde à bien le changer par le votre, en passant `192.0.2.1` est une IP de test réservée aux exemples, elle ne fonctionnera pas pour votre serveur.

## Architecture réseau

VaultWarden est isolé sur son propre réseau bridge dédié, jamais sur `caddy_network` :

- `vaultwarden-agent` → `vault_network` uniquement (pour joindre `vault:8200`). Il ne parle jamais à `vaultwarden` en réseau, seulement via le fichier `vaultwarden.env` partagé par volume.
- `vaultwarden` → `vaultwarden_network` uniquement (réseau dédié, invisible pour les autres apps et pour Caddy tant qu'il n'y est pas rattaché).
- `caddy` doit rejoindre `vaultwarden_network` en plus de `caddy_network`, pour pouvoir faire son `reverse_proxy` vers `vaultwarden`. Voir la section dédiée plus bas dans ce doc.

## Prérequis

### Filtrage WAF

Voici les 3 blocs de filtres positifs à ajouter (pour éviter des faux positifs), il faut changer le domaine dans `vw.mondomaine.com`.
On lui dit d'ignorer `"native_rule:911100"`, `"native_rule:932125"`, `"native_rule:932235"` et `"native_rule:932230"`.

```yml
- filter: |
    req.Host == "vw.mondomaine.com" &&
    any(evt.Appsec.MatchedRules, #.name == "native_rule:911100")
  apply:
    - SetRemediation("allow")
    - CancelAlert()
    - CancelEvent()
- filter: |
    req.Host == "vw.mondomaine.com" &&
    any(evt.Appsec.MatchedRules, #.name == "native_rule:932125")
  apply:
    - SetRemediation("allow")
    - CancelAlert()
    - CancelEvent()
- filter: |
    req.Host == "vw.mondomaine.com" &&
    any(evt.Appsec.MatchedRules, #.name == "native_rule:932235")
  apply:
    - SetRemediation("allow")
    - CancelAlert()
    - CancelEvent()
- filter: |
    req.Host == "vw.mondomaine.com" &&
    any(evt.Appsec.MatchedRules, #.name == "native_rule:932230")
  apply:
    - SetRemediation("allow")
    - CancelAlert()
    - CancelEvent()
```

On va l'ajouter en liste blanche à custom-config.yaml, dans la partie `on_match`

```bash
sudo nano /opt/docker/crowdsec/config/appsec-configs/custom-config.yaml
```

```yml
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
on_match:
  - filter: |
      req.Host == "vw.mondomaine.com" &&
      any(evt.Appsec.MatchedRules, #.name == "native_rule:911100")
    apply:
      - SetRemediation("allow")
      - CancelAlert()
      - CancelEvent()
  - filter: |
      req.Host == "vw.mondomaine.com" &&
      any(evt.Appsec.MatchedRules, #.name == "native_rule:932125")
    apply:
      - SetRemediation("allow")
      - CancelAlert()
      - CancelEvent()
  - filter: |
      req.Host == "vw.mondomaine.com" &&
      any(evt.Appsec.MatchedRules, #.name == "native_rule:932235")
    apply:
      - SetRemediation("allow")
      - CancelAlert()
      - CancelEvent()
  - filter: |
      req.Host == "vw.mondomaine.com" &&
      any(evt.Appsec.MatchedRules, #.name == "native_rule:932230")
    apply:
      - SetRemediation("allow")
      - CancelAlert()
      - CancelEvent()
```

On enregistre et on relance crowdsec

```bash
sudo docker exec crowdsec cscli hub update && sudo docker restart crowdsec
```

On en profite aussi pour faire des màj

```bash
sudo docker exec crowdsec cscli hub upgrade && sudo docker restart crowdsec
```

### Création du répertoire

On prépare un répertoire dans `opt/docker`

```bash
sudo mkdir -p /opt/docker/apps/vaultwarden/secrets-runtime
cd /opt/docker/apps/vaultwarden
```

### Création du réseau dédié

```bash
sudo docker network create vaultwarden_network
```

Ce réseau isole VaultWarden : aucun autre conteneur (hors Caddy, rattaché juste après) ne pourra le joindre en réseau, même en cas de compromission d'une autre app.

### Gestion domaine / sous domaine CloudFlare

On va sur [dashboard de CloudFlare](https://dash.cloudflare.com)

- puis `Domaine / Vue d'ensemble` cliquer sur le domaine
- puis `DNS / Enregistrements`
- cliquer sur le bouton `+ Ajouter un enregistrement`
- Type `A`
- Nom `vw.domaine.com`
- Adresse IPv4 `192.0.2.1`
- cliquer sur `Enregistrer`

Remplacer `192.0.2.1` par l'ipv4 du VPS.

### Vérifier que Vault est déverrouillé

Vault se re-scelle automatiquement à chaque redémarrage du conteneur. On vérifie son état avant de continuer :

```bash
sudo docker exec -it vault vault status
```

Si `Sealed` affiche `true`, il faut le déverrouiller avec les clefs générées lors du tout premier `vault operator init` (voir doc 05, normalement on les a conservées précieusement) :

Pour avoir les clef d'unseal

```bash
sudo docker exec -it vault vault operator unseal
```

À relancer autant de fois que le seuil de clefs nécessaires (3 par défaut sur 5), avec une clef différente à chaque fois. On revérifie ensuite avec `sudo docker exec -it vault vault status` que `Sealed` affiche `false` avant de continuer.

Et on se connecte au vault hashi corp avec le token `Initial Root Token`.

```bash
sudo docker exec -it vault vault login
```

### Génération du token admin et du mot de passe SMTP

On génère d'abord la clef brute

```bash
openssl rand -hex 32
```

Gardez précieusement la chaîne générée de côté, elle va servir juste après (le hash a besoin du conteneur VaultWarden, on le fera après le premier démarrage).

### Stockage des secrets dans Vault

Plutôt que de les garder en clair dans un `.env`, on les enregistre directement dans Vault (voir doc 05), on met le mdp du mail `noreply@mondomaine.com` :

```bash
sudo docker exec -it vault vault kv put secret/vaultwarden/smtp-password value="MdpCompteMail"
```

_(Le `ADMIN_TOKEN` hashé définitif sera ajouté plus bas, une fois généré via le conteneur — mais Vault Agent a besoin que le chemin existe dès maintenant pour pouvoir rendre le template, voir juste en dessous.)_

On crée donc un placeholder temporaire, indispensable pour que l'agent puisse générer le fichier `vaultwarden.env` dès son premier démarrage (sans secret existant à ce chemin, le rendu du template échoue entièrement, y compris pour `SMTP_PASSWORD`) :

```bash
sudo docker exec -it vault vault kv put secret/vaultwarden/admin-token value="placeholder"
```

Ce placeholder sera écrasé par la vraie valeur hashée plus loin dans ce document.

### Policy Vault dédiée à ce service

```bash
sudo docker exec -it vault sh -c 'cat <<EOF | vault policy write vaultwarden-policy -
path "secret/data/vaultwarden/admin-token" {
  capabilities = ["read"]
}
path "secret/data/vaultwarden/smtp-password" {
  capabilities = ["read"]
}
EOF'
```

Un token classique lié à cette policy suffit ici (comme pour cf-bouncer) :

```bash
sudo docker exec -it vault vault token create -policy=vaultwarden-policy -ttl=768h -field=token
```

Garder ce token précieusement (dans un coffre existant en attendant que VaultWarden lui-même tourne), on l'utilise juste après.

### Répertoire et template de rendu

```bash
sudo mkdir -p /opt/docker/apps/vaultwarden/agent-config
sudo nano /opt/docker/apps/vaultwarden/agent-config/vw.ctmpl
```

```text
ADMIN_TOKEN={{ with secret "secret/data/vaultwarden/admin-token" }}{{ .Data.data.value | replaceAll "$" "$$" }}{{ end }}
SMTP_PASSWORD={{ with secret "secret/data/vaultwarden/smtp-password" }}{{ .Data.data.value }}{{ end }}
```

### Configuration de l'agent Vault dédié

```bash
sudo nano /opt/docker/apps/vaultwarden/agent-config/agent.hcl
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
  source      = "/vault/config/vw.ctmpl"
  destination = "/vault/output/vaultwarden.env"
  perms       = "0600"
}
```

On dépose le token généré plus haut dans un fichier lu au démarrage :

```bash
echo "<TOKEN_GENERE_PLUS_HAUT>" | sudo tee /opt/docker/apps/vaultwarden/agent-config/token > /dev/null
sudo chown 100:1000 /opt/docker/apps/vaultwarden/agent-config/token
sudo chmod 600 /opt/docker/apps/vaultwarden/agent-config/token
```

### Création du `compose.yml`

```bash
sudo nano compose.yml
```

et on colle

```yaml
services:
  vaultwarden-agent:
    image: hashicorp/vault:latest
    container_name: vaultwarden-agent
    restart: unless-stopped
    volumes:
      - ./agent-config:/vault/config:ro
      - ./agent-config/token:/vault/secrets/token:ro
      - ./secrets-runtime:/vault/output
    command: agent -config=/vault/config/agent.hcl
    networks:
      - vault_network

  vaultwarden:
    image: vaultwarden/server:latest
    container_name: vaultwarden
    restart: unless-stopped
    depends_on:
      - vaultwarden-agent
    env_file:
      - ./secrets-runtime/vaultwarden.env
    environment:
      - DOMAIN=https://vw.mondomaine.com
      - SIGNUPS_ALLOWED=false
      - INVITATIONS_ALLOWED=true
      - SMTP_HOST=SMTP.MAIL.COM
      - SMTP_FROM=noreply@domaine.com
      - SMTP_PORT=465
      - SMTP_SECURITY=force_tls
      - SMTP_USERNAME=noreply@domaine.com
    volumes:
      - ./vw-data:/data
    networks:
      - vaultwarden_network

networks:
  vault_network:
    external: true
  vaultwarden_network:
    external: true
```

Penser à modifier `DOMAIN`, `SMTP_HOST`, `SMTP_FROM`, `SMTP_USERNAME`.

**Ce qui change par rapport à une installation classique :**

- `vaultwarden-agent` est sur `vault_network` (pas `caddy_network`) : il n'a besoin que de joindre `vault:8200`, jamais de parler à `vaultwarden` en réseau (ça passe par le volume `secrets-runtime`).
- `vaultwarden` est sur `vaultwarden_network` (pas `caddy_network`) : il est invisible pour toutes les autres apps et pour Caddy, tant que Caddy n'est pas explicitement rattaché à ce réseau (voir plus bas).

Et enregistrer le fichier.

On règle l'accès

```bash
sudo chmod 600 /opt/docker/apps/vaultwarden/compose.yml
```

⚠️ **Important** : `secrets-runtime` doit exister et contenir `vaultwarden.env` **avant** que le service `vaultwarden` démarre, car `env_file` est lu par Docker Compose au moment de la création du conteneur (contrairement à un fichier lu par le process applicatif lui-même). D'où le démarrage en deux temps ci-dessous.

### Démarrage en deux temps

D'abord l'agent seul, pour qu'il génère le fichier de secrets :

```bash
sudo chown -R 100:1000 /opt/docker/apps/vaultwarden/secrets-runtime
sudo docker compose up -d vaultwarden-agent
sleep 5
sudo cat /opt/docker/apps/vaultwarden/secrets-runtime/vaultwarden.env
```

Si le fichier contient bien `ADMIN_TOKEN=placeholder` (vide pour l'instant, on s'en occupe juste après) et `SMTP_PASSWORD=MdpCompteMail`, l'agent fonctionne. On peut ensuite démarrer le reste :

```bash
sudo docker compose up -d
```

### Générer et enregistrer le token admin (hashé)

Une fois VaultWarden démarré une première fois, on génère le hash :

```bash
sudo docker exec -it vaultwarden /vaultwarden hash
```

Coller la clef en clair générée avec `openssl rand -hex 32` plus haut, et récupérer la ligne retournée, du type :

```yml
$argon2id$v=19$m=65540,t=3,p=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

On l'enregistre dans Vault (uniquement la valeur hashée, sans `ADMIN_TOKEN=`) :

```bash
sudo docker exec -it vault vault kv put secret/vaultwarden/admin-token value='$argon2id$v=19$m=65540,t=3,p=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
```

L'agent Vault (par défaut toutes les quelques minutes, ou en le relançant) va régénérer `vaultwarden.env` avec la valeur cette fois remplie. On force la prise en compte immédiate :

```bash
sudo docker compose restart vaultwarden-agent
sleep 5
sudo docker compose up -d --force-recreate vaultwarden
```

### Vérification

On vérifie le statut des conteneurs

```bash
sudo docker compose ps
```

Et on vérifie s'il a bien créé le dossier de stockage

```bash
ls -l
```

il retourne

```bash
total 12
-rw-r--r-- 1 root root  580 Jun 20 19:05 compose.yml
drwxr-xr-x 3 root root 4096 Jun 20 19:06 vw-data
drwxr-xr-x 3 root root 4096 Jun 20 19:06 secrets-runtime
drwxr-xr-x 3 root root 4096 Jun 20 19:06 agent-config
```

## Configurer un reverse proxy avec Caddy

Contrairement aux autres apps (qui restent toutes sur `caddy_network`), `vaultwarden` est sur son propre réseau `vaultwarden_network`. Il faut donc d'abord rattacher Caddy à ce réseau avant de pouvoir faire le reverse proxy.

### Rattacher Caddy à `vaultwarden_network`

```bash
sudo nano /opt/docker/caddy/compose.yml
```

Dans le service `caddy`, ajouter `vaultwarden_network` à la liste des réseaux :

```yaml
networks:
  - caddy_network
  - vaultwarden_network
```

Et dans le bloc `networks:` en bas du fichier, ajouter :

```yaml
networks:
  caddy_network:
    external: true
  vaultwarden_network:
    external: true
```

On applique le changement :

```bash
cd /opt/docker/caddy
sudo docker compose up -d --force-recreate
```

### Ajouter la redirection dans le Caddyfile

```bash
sudo nano /opt/docker/caddy/Caddyfile
```

On y ajoute

```plaintext
vw.mondomaine.com {
        import crowdsec_bouncer
        reverse_proxy vaultwarden:80
}
```

On enregistre le fichier puis on vérifie la mise en forme

```bash
sudo docker compose -f /opt/docker/caddy/compose.yml exec -w /etc/caddy caddy caddy fmt --overwrite
```

on actualise la configuration de Caddy

```bash
sudo docker compose -f /opt/docker/caddy/compose.yml exec -w /etc/caddy caddy caddy reload
```

Voilà, l'installation est finie.

Le token admin en clair (celui généré par `openssl rand -hex 32`, pas la version hashée) n'est jamais stocké nulle part côté serveur — à garder uniquement de ton côté (dans un gestionnaire de mots de passe) pour te connecter à `/admin`.

Passer à la partie 2.
