# 01 - Installation OpenProject

Depuis [Page docker hub](https://hub.docker.com/r/openproject/openproject)
Depuis [la doc All-In-One de déploiement Docker](https://www.openproject.org/docs/installation-and-operations/installation/docker/)

Le mode [All-In-One](https://www.openproject.org/docs/installation-and-operations/installation/docker/) (ce qui est utilisé dans la présente documentation) convient parfaitement pour trente dev travaillant dessus simultanément. Au dessus de 30 personnes, on déploiera OpenProject via [une méthode avec un conteneur par service](https://www.openproject.org/docs/installation-and-operations/installation/docker-compose/)

## Architecture réseau

OpenProject est isolé sur son propre réseau bridge dédié, jamais sur `caddy_network` :

- `openproject-agent` → `vault_network` uniquement (pour joindre `vault:8200`). Il ne parle jamais à `openproject` en réseau, seulement via le fichier `openproject.env` partagé par volume.
- `openproject` → `openproject_network` uniquement (réseau dédié, invisible pour les autres apps et pour Caddy tant qu'il n'y est pas rattaché).
- `caddy` doit rejoindre `openproject_network` en plus de `caddy_network`, pour pouvoir faire son `reverse_proxy` vers `openproject`. Voir la section dédiée plus bas dans ce doc.

## Prérequis

### Filtrage WAF

Voici le bloc de filtre positif à ajouter (pour éviter des faux positifs), il faut changer le domaine dans `op.mondomaine.com`.
On lui dit d'ignorer `"native_rule:911100"`.

```yml
- filter: |
    req.Host == "op.mondomaine.com" &&
    any(evt.Appsec.MatchedRules, #.name == "native_rule:911100")
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
      req.Host == "op.mondomaine.com" &&
      any(evt.Appsec.MatchedRules, #.name == "native_rule:911100")
    apply:
      - SetRemediation("allow")
      - CancelAlert()
      - CancelEvent()
```

On enregistre et on relance crowdsec

```bash
sudo docker exec crowdsec cscli hub update && sudo docker restart crowdsec
```

### Création du répertoire

On prépare un répertoire dans `opt/docker`

```bash
sudo mkdir -p /opt/docker/apps/openproject/secrets-runtime
cd /opt/docker/apps/openproject
```

### Création du réseau dédié

```bash
sudo docker network create openproject_network
```

Ce réseau isole OpenProject : aucun autre conteneur (hors Caddy, rattaché juste après) ne pourra le joindre en réseau, même en cas de compromission d'une autre app.

### Gestion domaine / sous domaine CloudFlare

On va sur [dashboard de CloudFlare](https://dash.cloudflare.com)

- puis `Domaine / Vue d'ensemble` cliquer sur le domaine
- puis `DNS / Enregistrements`
- cliquer sur le bouton `+ Ajouter un enregistrement`
- Type `A`
- Nom `op.domaine.com`
- Adresse IPv4 `192.0.2.1`
- cliquer sur `Enregistrer`

Remplacer `192.0.2.1` par l'ipv4 du VPS.

### Créer nouveau compte mail MXROUTE

Se connecter au [site de mxroute.com](https://management.mxroute.com/dashboard)

- Dans le menu `dashboard` (par défaut), cliquer sur le bouton `Login to Panel`, et allez sur le menu `Email Accounts`.
- Cliquer sur `+ Create New Email Account`, entrer `noreply` comme username et lui générer un mdp (garder précieusement les identifiants) et cliquer sur `Create Account`.
- La mail généré est `noreply@votrenomdedomaine.com`, attention à ne pas avoir de `$` dans le mot de passe.

### Récupérer le serveur MX de MXROUTE

Se connecter au [site de mxroute.com](https://management.mxroute.com/dashboard)

- Dans le menu `dashboard` (par défaut), cliquer sur le bouton `Login to Panel`, et allez sur le menu `DNS`.
- Dans l'encadré `MX Records` prendre la `VALUE` de celui avec la `PRIORITY` 10 (l'autre est un serveur de secours si le premier est en rade).
- Vous aurez une adresse serveur du genre `machin.mxrouting.net`

Si le compte MXROUTE est bien réglé, et pareil du côté du registrar lors de l'ajout du NDD, il n'y a rien d'autre à faire pour le mailing.

### Vérifier que Vault est déverrouillé

Vault se re-scelle automatiquement à chaque redémarrage du conteneur. On vérifie son état avant de continuer :

```bash
sudo docker exec -it vault vault status
```

Si `Sealed` affiche `true`, il faut le déverrouiller avec les clefs générées lors du tout premier `vault operator init` (voir doc 05, normalement on les a conservées précieusement) :

```bash
sudo docker exec -it vault vault operator unseal
```

À relancer autant de fois que le seuil de clefs nécessaires (3 par défaut sur 5), avec une clef différente à chaque fois. On revérifie ensuite avec `sudo docker exec -it vault vault status` que `Sealed` affiche `false` avant de continuer.

Et on se connecte au Vault HashiCorp avec le token `Initial Root Token` (uniquement si pas déjà connecté depuis une session précédente) :

```bash
sudo docker exec -it vault vault login
```

### Génération des clefs secrètes

On génère la clef pour OpenProject

```bash
openssl rand -hex 64
```

Gardez précieusement la chaîne générée de côté.

On génère la clef pour Hocuspocus

```bash
openssl rand -hex 64
```

Gardez précieusement cette seconde chaîne de côté aussi.

### Stockage des secrets dans Vault

Plutôt que de les garder en clair dans le `compose.yml`, on les enregistre directement dans Vault (voir doc 05) :

```bash
sudo docker exec -it vault vault kv put secret/openproject/secret-key-base value="<CLEF_OPENPROJECT_GENEREE>"
sudo docker exec -it vault vault kv put secret/openproject/hocuspocus-secret value="<CLEF_HOCUSPOCUS_GENEREE>"
sudo docker exec -it vault vault kv put secret/openproject/smtp-password value="<MOT_DE_PASSE_DU_MAIL>"
```

### Policy Vault dédiée à ce service

```bash
sudo docker exec -it vault sh -c 'cat <<EOF | vault policy write openproject-policy -
path "secret/data/openproject/secret-key-base" {
  capabilities = ["read"]
}
path "secret/data/openproject/hocuspocus-secret" {
  capabilities = ["read"]
}
path "secret/data/openproject/smtp-password" {
  capabilities = ["read"]
}
EOF'
```

Un token classique lié à cette policy suffit ici (comme pour cf-bouncer et VaultWarden) :

```bash
sudo docker exec -it vault vault token create -policy=openproject-policy -ttl=768h -field=token
```

Garder ce token précieusement (dans VaultWarden), on l'utilise juste après.

### Répertoire et template de rendu

```bash
sudo mkdir -p /opt/docker/apps/openproject/agent-config
sudo nano /opt/docker/apps/openproject/agent-config/op.ctmpl
```

```text
OPENPROJECT_SECRET_KEY_BASE={{ with secret "secret/data/openproject/secret-key-base" }}{{ .Data.data.value | replaceAll "$" "$$" }}{{ end }}
OPENPROJECT_COLLABORATIVE__EDITING__HOCUSPOCUS__SECRET={{ with secret "secret/data/openproject/hocuspocus-secret" }}{{ .Data.data.value | replaceAll "$" "$$" }}{{ end }}
OPENPROJECT_SMTP__PASSWORD={{ with secret "secret/data/openproject/smtp-password" }}{{ .Data.data.value | replaceAll "$" "$$" }}{{ end }}
```

### Configuration de l'agent Vault dédié

```bash
sudo nano /opt/docker/apps/openproject/agent-config/agent.hcl
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
  source      = "/vault/config/op.ctmpl"
  destination = "/vault/output/openproject.env"
  perms       = "0600"
}
```

On dépose le token généré plus haut dans un fichier lu au démarrage :

```bash
echo "<TOKEN_GENERE_PLUS_HAUT>" | sudo tee /opt/docker/apps/openproject/agent-config/token > /dev/null
sudo chown 100:1000 /opt/docker/apps/openproject/agent-config/token
sudo chmod 600 /opt/docker/apps/openproject/agent-config/token
```

### Création du `compose.yml`

```bash
sudo nano compose.yml
```

Et on y colle

```yaml
services:
  openproject-agent:
    image: hashicorp/vault:latest
    container_name: openproject-agent
    restart: unless-stopped
    volumes:
      - ./agent-config:/vault/config:ro
      - ./agent-config/token:/vault/secrets/token:ro
      - ./secrets-runtime:/vault/output
    command: agent -config=/vault/config/agent.hcl
    networks:
      - vault_network

  openproject:
    image: openproject/openproject:17.6-rc
    container_name: openproject
    restart: unless-stopped
    depends_on:
      - openproject-agent
    extra_hosts:
      - "op.mondomaine.com:127.0.0.1" # A mettre à jour "mondomaine"
    env_file:
      - ./secrets-runtime/openproject.env
    environment:
      - OPENPROJECT_URL=https://op.mondomaine.com # A mettre à jour "mondomaine"
      - TZ=Europe/Paris
      - OPENPROJECT_HOST__NAME=op.mondomaine.com # A mettre à jour "mondomaine"
      - OPENPROJECT_HTTPS=true
      - OPENPROJECT_DEFAULT__LANGUAGE=fr
      # --- CONFIGURATION HOCUSPOCUS ---
      - OPENPROJECT_COLLABORATIVE__EDITING__HOCUSPOCUS__URL=wss://op.mondomaine.com/hocuspocus # A mettre à jour "mondomaine"
      # --- CONFIGURATION EMAIL SMTP (MXROUTE) ---
      - OPENPROJECT_SMTP__ADDRESS=NOM_SERVEUR.mxrouting.net # A mettre à jour serveur
      - OPENPROJECT_SMTP__PORT=587
      - OPENPROJECT_SMTP__DOMAIN=mondomaine.com # A mettre à jour "mondomaine"
      - OPENPROJECT_SMTP__AUTHENTICATION=login
      - OPENPROJECT_SMTP__USER__NAME=noreply@mondomaine.com # A mettre à jour "mondomaine"
      - OPENPROJECT_SMTP__ENABLE__STARTTLS__AUTO=true
    volumes:
      - openproject_pgdata:/var/openproject/pgdata
      - openproject_assets:/var/openproject/assets
    networks:
      - openproject_network

volumes:
  openproject_pgdata:
  openproject_assets:

networks:
  vault_network:
    external: true
  openproject_network:
    external: true
```

On modifie tous les domaines `mondomaine.com`, avant de sauver.

**Ce qui change par rapport à une installation classique :**

- `SECRET_KEY_BASE`, `HOCUSPOCUS_SECRET` et `SMTP_PASSWORD` ne sont plus en clair dans ce fichier : ils sont injectés au démarrage via `env_file`, généré par l'agent Vault à partir du template.
- `openproject-agent` est sur `vault_network` (pas `caddy_network`) : il n'a besoin que de joindre `vault:8200`, jamais de parler à `openproject` en réseau (ça passe par le volume `secrets-runtime`).
- `openproject` est sur `openproject_network` (pas `caddy_network`) : il est invisible pour toutes les autres apps et pour Caddy, tant que Caddy n'est pas explicitement rattaché à ce réseau.
- `OPENPROJECT_URL` est passé en `https://` (au lieu de `http://`), pour rester cohérent avec `OPENPROJECT_HTTPS=true` juste en dessous.

Et enregistrer le fichier.

On règle l'accès

```bash
sudo chmod 600 /opt/docker/apps/openproject/compose.yml
```

⚠️ **Important** : `secrets-runtime` doit exister et contenir `openproject.env` **avant** que le service `openproject` démarre, car `env_file` est lu par Docker Compose au moment de la création du conteneur. D'où le démarrage en deux temps ci-dessous.

### Démarrage en deux temps

D'abord l'agent seul, pour qu'il génère le fichier de secrets :

```bash
sudo chown -R 100:1000 /opt/docker/apps/openproject/secrets-runtime
sudo docker compose up -d openproject-agent
sleep 5
sudo cat /opt/docker/apps/openproject/secrets-runtime/openproject.env
```

Si le fichier contient bien les 3 variables (`OPENPROJECT_SECRET_KEY_BASE=`, `OPENPROJECT_COLLABORATIVE__EDITING__HOCUSPOCUS__SECRET=`, `OPENPROJECT_SMTP__PASSWORD=`) avec les vraies valeurs, l'agent fonctionne. On peut ensuite démarrer le reste :

```bash
sudo docker compose up -d
```

### Redirection avec Caddyfile

Contrairement aux autres apps (qui restent toutes sur `caddy_network`), `openproject` est sur son propre réseau `openproject_network`. Il faut donc d'abord rattacher Caddy à ce réseau avant de pouvoir faire le reverse proxy.

#### Rattacher Caddy à `openproject_network`

```bash
sudo nano /opt/docker/caddy/compose.yml
```

Dans le service `caddy`, ajouter `openproject_network` à la liste des réseaux :

```yaml
networks:
  - caddy_network
  - openproject_network
```

Et dans le bloc `networks:` en bas du fichier, ajouter :

```yaml
networks:
  caddy_network:
    external: true
  openproject_network:
    external: true
```

On applique le changement :

```bash
cd /opt/docker/caddy
sudo docker compose up -d --force-recreate
```

#### Ajouter la redirection dans le Caddyfile

```bash
sudo nano /opt/docker/caddy/Caddyfile
```

Descendre tout en bas du document (`ALT + /`) et, dans la section dédiée à la **Redirection de domaines**, coller ce bloc de configuration :

```text
op.mondomaine.com {
        import crowdsec_bouncer
        reverse_proxy openproject:80
}
```

Sauvegarder et fermer.

Aligner le formatage de Caddy

```bash
sudo docker compose -f /opt/docker/caddy/compose.yml exec -w /etc/caddy caddy caddy fmt --overwrite
```

Recharger la configuration de Caddy à chaud pour qu'il prenne en compte le nouveau domaine

```bash
sudo docker compose -f /opt/docker/caddy/compose.yml exec -w /etc/caddy caddy caddy reload
```

## Vérification

On vérifie le statut des conteneurs

```bash
sudo docker compose ps
```

On peut suivre l'avancement de l'initialisation (prend plusieurs minutes) avec

```bash
sudo docker compose logs -f openproject
```

Et on attend de voir

```text
=> Booting Puma
```

et ce qui suit.

On se connecte sur le navigateur à <https://op.mondomaine.com/>

Pour identifiants : admin
mot de passe : admin: admin

et on change le mdp par un mdp lourd.

Changer la timezone dans les options du compte, et mettre Paris (sinon l'heure est en retard sur GMT0).

Reste sur le premier onglet principal. Descends tout en bas de cette page.

Dire aux utilisateurs de vérifier le fuseau horaire pour éviter le quiproquo.

## Régler SMTP depuis le menu

Administration → Emails and notifications

Cliquer sur mon avatar -> Administration -> E-mails et notifications -> Notifications par e-mail
