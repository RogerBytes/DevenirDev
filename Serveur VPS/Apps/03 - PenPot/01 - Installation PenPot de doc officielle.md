# 01 - Installation PenPot

Depuis [Page docker hub](https://hub.docker.com/u/penpotapp)
Depuis [la doc du site](https://help.penpot.app/technical-guide/getting-started/docker/)

## Prérequis

### Création du répertoire

On prépare un répertoire dans `opt/docker`

```bash
sudo mkdir -p /opt/docker/apps/penpot
cd /opt/docker/apps/penpot
```

### Téléchargement du compose officiel et création de stack

```bash
sudo wget -O compose.yml https://raw.githubusercontent.com/penpot/penpot/main/docker/images/docker-compose.yaml
```

Et on lance

```bash
sudo docker compose up -d
```

Rappel, pour afficher tous les services qui tournent

```bash
sudo docker compose ls --all
```

### Configuration

#### Alerte

Ici je recommence tout ex nihilo, en passant par [la doc de configuration dédiée](https://help.penpot.app/technical-guide/configuration/).

```bash
sudo nano compose.yml
```

### Générer une clef secrète pour PenPot

```bash
openssl rand -hex 64
```

Gardez précieusement la chaîne générée de côté, elle va servir dans le fichier de configuration juste après.

### Ajout de la clef secrète

```bash
sudo nano compose.yml
```

Chercher `PENPOT_SECRET_KEY: change-this-insecure-key` (avec `CTRL+W`) pour y mettre la clef secrète qu'on vient de générer. Enregistrer.

## Mon yml (en cours)

```yml
# Flags que je dois enquêter dans mon cas
# log-emails
# log-invitation-tokens
x-flags: &penpot-flags
  PENPOT_FLAGS: enable-smtp enable-prepl-server enable-mcp

x-uri: &penpot-public-uri
  PENPOT_PUBLIC_URI: https://draw.mondomaine.com

x-body-size: &penpot-http-body-size
  PENPOT_HTTP_SERVER_MAX_BODY_SIZE: 367001600
  PENPOT_HTTP_SERVER_MAX_MULTIPART_BODY_SIZE: 367001600

x-secret-key: &penpot-secret-key
  PENPOT_SECRET_KEY: 2b14af4615462388c1a72987614ce43a070a3180aff692b9f2345ff9bbecb9b739f57ce3a349b6d46901dacffda27f48255ee467957ab56e9b50b88297086db3

networks:
  penpot:

volumes:
  penpot_postgres_v15:
  penpot_assets:
  # penpot_traefik: -> voir par la suite si je dois lui mettre mon bridge caddy-network, mais d'abord en vanilla sans bridge

services:
  # Il y avait un template service pour traefik, à voir si c'est nécessaire de faire un service caddy (je pense que non)

  penpot-frontend:
    image: "penpotapp/frontend:${PENPOT_VERSION:-2.16}"
    restart: always
    ports:
      - 9001:8080

    volumes:
      - penpot_assets:/opt/data/assets

    depends_on:
      - penpot-backend
      - penpot-exporter
      - penpot-mcp

    networks:
      - penpot

    environment:
      << : [*penpot-flags, *penpot-http-body-size, *penpot-public-uri]

  penpot-backend:
    image: "penpotapp/backend:${PENPOT_VERSION:-2.16}"
    restart: always

    volumes:
      - penpot_assets:/opt/data/assets

    depends_on:
      penpot-postgres:
        condition: service_healthy
      penpot-valkey:
        condition: service_healthy

    networks:
      - penpot

    environment:
      << : [*penpot-flags, *penpot-public-uri, *penpot-http-body-size, *penpot-secret-key]

      PENPOT_DATABASE_URI: postgresql://penpot-postgres/penpot
      PENPOT_DATABASE_USERNAME: penpot
      PENPOT_DATABASE_PASSWORD: penpot

      PENPOT_REDIS_URI: redis://penpot-valkey/0

      AWS_ACCESS_KEY_ID: 14d8cd7a09f80c2a23d4656e22058b4c
      AWS_SECRET_ACCESS_KEY: 4bfb4d836e8196c5d39954b21b1e6fae8a852070861f7be40bfec00bf89fcb04
      PENPOT_OBJECTS_STORAGE_BACKEND: s3
      PENPOT_OBJECTS_STORAGE_S3_ENDPOINT: https://5733c92e6925460128afab9af86fe3e6.r2.cloudflarestorage.com
      PENPOT_OBJECTS_STORAGE_S3_BUCKET: penpot-assets

      PENPOT_TELEMETRY_ENABLED: "false"
      PENPOT_TELEMETRY_REFERER: compose

      PENPOT_SMTP_DEFAULT_FROM: noreply@rogerbytes.com
      PENPOT_SMTP_DEFAULT_REPLY_TO: noreply@rogerbytes.com
      PENPOT_SMTP_HOST: PENPOT_OBJECTS_STORAGE_FS_DIRECTORY
      PENPOT_SMTP_PORT: 465
      PENPOT_SMTP_USERNAME: noreply@rogerbytes.com
      PENPOT_SMTP_PASSWORD: fRp9WmLDFsSziW2@
      PENPOT_SMTP_TLS: "true"
      PENPOT_SMTP_SSL: "true"

  penpot-mcp:
    image: "penpotapp/mcp:${PENPOT_VERSION:-2.16}"
    restart: always
    networks:
      - penpot

  penpot-exporter:
    image: "penpotapp/exporter:${PENPOT_VERSION:-2.16}"
    restart: always

    depends_on:
      penpot-valkey:
        condition: service_healthy

    networks:
      - penpot

    environment:
      << : [*penpot-secret-key, *penpot-public-uri]
      PENPOT_INTERNAL_URI: http://penpot-frontend:8080
      PENPOT_REDIS_URI: redis://penpot-valkey/0

  penpot-postgres:
    image: "postgres:15"
    restart: always
    stop_signal: SIGINT

    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U penpot"]
      interval: 2s
      timeout: 10s
      retries: 5
      start_period: 2s

    volumes:
      - penpot_postgres_v15:/var/lib/postgresql/data

    networks:
      - penpot

    environment:
      - POSTGRES_INITDB_ARGS=--data-checksums
      - POSTGRES_DB=penpot
      - POSTGRES_USER=penpot
      - POSTGRES_PASSWORD=penpot

  penpot-valkey:
    image: valkey/valkey:8.1
    restart: always

    healthcheck:
      test: ["CMD-SHELL", "valkey-cli ping | grep PONG"]
      interval: 1s
      timeout: 3s
      retries: 5
      start_period: 3s

    networks:
      - penpot

    environment:
      - VALKEY_EXTRA_FLAGS=--maxmemory 128mb --maxmemory-policy volatile-lfu
```

### CloudFlare R2

#### Créer un compartiment R2

- On va sur [le dashboard de CloudFlare](https://dash.cloudflare.com/) et dans le menu de gauche `Stockage et base de données / Stockage d'objet R2 / Vue d'ensemble`
- cliquer sur `Créer un compartiment`
  - nom du compartiment `penpot-assets`
  - Emplacement `Automatique`
  - Classe de stockage par défaut `Standard`
  - Cliquer sur `Créer un compartiment`

#### Récupérer le jeton du compartiment

On récupère les infos de notre token `R2 Account Token` (fait pour Offen Docker Volume Backup), pas besoin d'en refaire un.

On récupère la note (ou coffre fort VaultWarden) les valeurs des labels suivants

- Valeur du jeton
- ID de clé d’accès
- Clé d’accès secrète
- Utilisez des points de terminaison spécifiques à la juridiction pour les clients S3 : [par défaut]

#### Paramétrage de R2 dans le compose.yml

```bash
sudo nano compose.yml
```

On commente :

```yml
      PENPOT_OBJECTS_STORAGE_BACKEND: fs
      PENPOT_OBJECTS_STORAGE_FS_DIRECTORY: /opt/data/assets
```

et juste en dessous, on dé-commente

```yml
      # AWS_ACCESS_KEY_ID: <KEY_ID>
      # AWS_SECRET_ACCESS_KEY: <ACCESS_KEY>
      # PENPOT_OBJECTS_STORAGE_BACKEND: s3
      # PENPOT_OBJECTS_STORAGE_S3_ENDPOINT: <ENDPOINT>
      # PENPOT_OBJECTS_STORAGE_S3_BUCKET: <BUKET_NAME>
```

et on remplit comme ça

```yml
      AWS_ACCESS_KEY_ID: "TON_ID_DE_CLE_D_ACCES"
      AWS_SECRET_ACCESS_KEY: "TA_CLE_D_ACCES_SECRETE"
      PENPOT_OBJECTS_STORAGE_BACKEND: s3
      PENPOT_OBJECTS_STORAGE_S3_ENDPOINT: "Le endpoint R2 (terminaison)"
      PENPOT_OBJECTS_STORAGE_S3_BUCKET: "penpot-assets"
```

### Désactiver la télémétrie

```bash
sudo nano compose.yml
```

Et modifier `PENPOT_TELEMETRY_ENABLED: "true"` en le mettant sur `false` au lieu de `true`

### Récupérer le serveur MX de MXROUTE

On a déjà notre adresse mail `noreply@mondomaine.com`, pas besoin d'en refaire une autre.

Se connecter au [site de mxroute.com](https://management.mxroute.com/dashboard)

- Dans le menu `dashboard` (par défaut), cliquer sur le bouton `Login to Panel`, et allez sur le menu `DNS`.
- Dans l'encadré `MX Records` prendre la `VALUE` de celui avec la `PRIORITY` 10 (l'autre est un serveur de secours si le premier est en rade).
- Vous aurez une adresse serveur du genre `machin.mxrouting.net`

Si le compte MXROUTE est bien réglé, et pareil du côté du registrar lors de l'ajout du NDD, il n'y a rien d'autre à faire pour le mailing.

### Paramétrer les envois de mail dans le compose.yml

```bash
sudo nano compose.yml
```

On va sur la partie

```yml
      PENPOT_SMTP_DEFAULT_FROM: no-reply@example.com
      PENPOT_SMTP_DEFAULT_REPLY_TO: no-reply@example.com
      PENPOT_SMTP_HOST: penpot-mailcatch
      PENPOT_SMTP_PORT: 1025
      PENPOT_SMTP_USERNAME:
      PENPOT_SMTP_PASSWORD:
      PENPOT_SMTP_TLS: "false"
      PENPOT_SMTP_SSL: "false"
```

On le remplit comme ça

```yml
      PENPOT_SMTP_DEFAULT_FROM: noreply@mondomaine.com
      PENPOT_SMTP_DEFAULT_REPLY_TO: noreply@mondomaine.com
      PENPOT_SMTP_HOST: TON_SERVEUR.mxroute.com
      PENPOT_SMTP_PORT: 587
      PENPOT_SMTP_USERNAME: noreply@mondomaine.com
      PENPOT_SMTP_PASSWORD: "MOT_DE_PASSE_DU_MAIL_MXROUTE"
      PENPOT_SMTP_TLS: "true"
      PENPOT_SMTP_SSL: "false"
```

Une fois fait on désactive le mail catcher (à la fin) en le commentant ou en le supprimant

```yml
  penpot-mailcatch:
    image: sj26/mailcatcher:latest
    restart: always
    expose:
      - '1025'
    ports:
      - "1080:1080"
    networks:
      - penpot
```

### Gestion domaine / sous domaine CloudFlare

On va sur [dashboard de CloudFlare](https://dash.cloudflare.com)

- puis `Domaine / Vue d'ensemble` cliquer sur le domaine
- puis `DNS / Enregistrements`
- cliquer sur le bouton `+ Ajouter un enregistrement`
- Type `A`
- Nom `draw.domaine.com`
- Adresse IPv4 `192.0.2.1`
- cliquer sur `Enregistrer`

Remplacer `192.0.2.1` par l'ipv4 du VPS.

### Redirection avec Caddyfile

```python
sudo nano /opt/docker/caddy/Caddyfile
```

Descendre tout en bas du document (`ALT + /`) et, dans la section dédiée à la **Redirection de domaines**, coller ce bloc de configuration :

```text
draw.mondomaine.com {
        import crowdsec_bouncer
        reverse_proxy 172.17.0.1:9001
}

draw.rogerbytes.com {
    reverse_proxy 172.17.0.1:9001
}

draw.rogerbytes.com {
        import crowdsec_bouncer

        reverse_proxy 172.17.0.1:9001 {
                header_up Host {upstream_hostport}
                header_up X-Real-IP {remote_host}
                header_up X-Forwarded-For {remote_host}
                header_up X-Forwarded-Proto {scheme}
        }
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

## Installation du conteneur

```bash
cd /opt/docker/apps/penpot
sudo docker compose -p penpot -f compose.yml up -d --force-recreate


cd /opt/docker/apps/penpot
sudo docker compose -p penpot -f compose.yml down
```

On peut suivre l'avancement de l'initialisation (prend plusieurs minutes) avec

```bash
sudo docker compose logs -f penpot-backend
```

Et on attends de voir

```text
penpot-backend-1  | [2026-07-02 15:04:47.613] I app.worker.runner - hint="started", id="webhooks/0", queue="webhooks"
```

---

et ce qui suit

On se connecte sur le navigateur à <https://draw.mondomaine.com/>

Si la page s'affiche, c'est un bon début !

## Créer un user

```bash
sudo docker exec -ti penpot-penpot-backend-1 python3 manage.py create-profile
```

## Origine du souci "Un problème est survenu" (spoiler c'est appsec de crowdsec)

C'est l'appsec de crowdsec qui bloque

```bash
sudo docker compose -f /opt/docker/crowdsec/compose.yml logs -f --tail=0 crowdsec 2>&1 | grep -i appsec
```

Tenter de se connecter, ça retourne

```bash
crowdsec  | time="2026-07-13T11:22:40Z" level=info msg="127.0.0.1 - [Mon, 13 Jul 2026 11:22:40 UTC] \"HEAD /v1/decisions/stream HTTP/1.1 200 759.881µs \"appsec/v1.7.8-63227459-docker\" \"" module=lapi
```

On liste les alertes récentes avec

```bash
sudo docker exec -it crowdsec cscli alerts list
```


```bash
sudo docker exec -it crowdsec cscli alerts list
╭─────┬──────────────────────────────────────────┬───────────────────────────────────────────┬─────────┬──────────────────────────┬───────────┬──────────────────────┬──────────╮
│  ID │                   value                  │                   reason                  │ country │            as            │ decisions │      created_at      │   kind   │
├─────┼──────────────────────────────────────────┼───────────────────────────────────────────┼─────────┼──────────────────────────┼───────────┼──────────────────────┼──────────┤
│ 840 │ Ip:172.71.126.253                        │ anomaly score block: anomaly: 5,          │ FR      │ 13335 CLOUDFLARENET      │           │ 2026-07-13T11:22:40Z │ waf      │
│ 839 │ Ip:172.71.126.253                        │ anomaly score block: anomaly: 5,          │ FR      │ 13335 CLOUDFLARENET      │           │ 2026-07-13T11:22:03Z │ waf      │
│ 838 │ Ip:172.71.126.253                        │ anomaly score block: anomaly: 5,          │ FR      │ 13335 CLOUDFLARENET      │           │ 2026-07-13T11:22:02Z │ waf      │
│ 837 │ Ip:172.71.126.253                        │ anomaly score block: anomaly: 5,          │ FR      │ 13335 CLOUDFLARENET      │           │ 2026-07-13T11:22:02Z │ waf      │
│ 836 │ Ip:172.71.126.253                        │ anomaly score block: anomaly: 5,          │ FR      │ 13335 CLOUDFLARENET      │           │ 2026-07-13T11:22:01Z │ waf      │
│ 835 │ Ip:172.71.126.253                        │ anomaly score block: anomaly: 5,          │ FR      │ 13335 CLOUDFLARENET      │           │ 2026-07-13T11:22:01Z │ waf      │
│ 834 │ Ip:172.71.126.253                        │ anomaly score block: anomaly: 5,          │ FR      │ 13335 CLOUDFLARENET      │           │ 2026-07-13T11:22:00Z │ waf      │
│ 833 │ Ip:172.71.126.253                        │ anomaly score block: anomaly: 5,          │ FR      │ 13335 CLOUDFLARENET      │           │ 2026-07-13T11:22:00Z │ waf      │
│ 832 │ Ip:172.71.126.253                        │ anomaly score block: anomaly: 5,          │ FR      │ 13335 CLOUDFLARENET      │           │ 2026-07-13T11:21:55Z │ waf      │
│ 831 │ Ip:172.71.126.253                        │ anomaly score block: anomaly: 5,          │ FR      │ 13335 CLOUDFLARENET      │           │ 2026-07-13T11:21:34Z │ waf      │
│ 830 │ Ip:2001:861:34c0:1330:62b3:46c:bfcf:38a6 │ anomaly score block: anomaly: 5,          │ FR      │ 5410 Bouygues Telecom SA │           │ 2026-07-13T11:19:54Z │ waf      │
│ 829 │ Ip:2001:861:34c0:1330:62b3:46c:bfcf:38a6 │ anomaly score block: anomaly: 5,          │ FR      │ 5410 Bouygues Telecom SA │           │ 2026-07-13T11:19:48Z │ waf      │
│ 828 │ Ip:172.71.123.27                         │ anomaly score block: anomaly: 5,          │ FR      │ 13335 CLOUDFLARENET      │           │ 2026-07-13T11:18:39Z │ waf      │
│ 827 │ Ip:172.71.232.133                        │ anomaly score block: anomaly: 5,          │ FR      │ 13335 CLOUDFLARENET      │           │ 2026-07-13T11:07:03Z │ waf      │
│ 826 │ Ip:172.71.232.133                        │ anomaly score block: anomaly: 5,          │ FR      │ 13335 CLOUDFLARENET      │           │ 2026-07-13T11:06:58Z │ waf      │
│ 825 │ Ip:172.71.232.133                        │ anomaly score block: anomaly: 5,          │ FR      │ 13335 CLOUDFLARENET      │           │ 2026-07-13T11:02:06Z │ waf      │
│ 824 │ Ip:172.71.232.133                        │ anomaly score block: anomaly: 5,          │ FR      │ 13335 CLOUDFLARENET      │           │ 2026-07-13T11:01:57Z │ waf      │
│ 823 │ Ip:172.71.118.148                        │ anomaly score block: anomaly: 5,          │ FR      │ 13335 CLOUDFLARENET      │           │ 2026-07-13T10:54:35Z │ waf      │
│ 822 │ Ip:2001:861:34c0:1330:62b3:46c:bfcf:38a6 │ anomaly score block: anomaly: 5,          │ FR      │ 5410 Bouygues Telecom SA │           │ 2026-07-13T10:54:28Z │ waf      │
│ 821 │ Ip:172.71.126.253                        │ anomaly score block: anomaly: 5,          │ FR      │ 13335 CLOUDFLARENET      │           │ 2026-07-13T10:53:18Z │ waf      │
│ 820 │ Ip:2001:861:34c0:1330:62b3:46c:bfcf:38a6 │ anomaly score block: anomaly: 5,          │ FR      │ 5410 Bouygues Telecom SA │           │ 2026-07-13T10:51:17Z │ waf      │
│ 819 │ Ip:172.71.123.28                         │ anomaly score block: anomaly: 5,          │ FR      │ 13335 CLOUDFLARENET      │           │ 2026-07-13T10:50:21Z │ waf      │
│ 818 │ Ip:2001:861:34c0:1330:62b3:46c:bfcf:38a6 │ anomaly score block: anomaly: 5,          │ FR      │ 5410 Bouygues Telecom SA │           │ 2026-07-13T10:48:27Z │ waf      │
│ 817 │ Ip:2001:861:34c0:1330:62b3:46c:bfcf:38a6 │ anomaly score block: anomaly: 5,          │ FR      │ 5410 Bouygues Telecom SA │           │ 2026-07-13T10:48:09Z │ waf      │
│ 816 │ Ip:172.71.123.28                         │ anomaly score block: anomaly: 5,          │ FR      │ 13335 CLOUDFLARENET      │           │ 2026-07-13T10:41:29Z │ waf      │
│ 815 │ Ip:172.71.123.28                         │ anomaly score block: anomaly: 5,          │ FR      │ 13335 CLOUDFLARENET      │           │ 2026-07-13T10:41:19Z │ waf      │
│ 814 │ Ip:2001:861:34c0:1330:62b3:46c:bfcf:38a6 │ anomaly score block: anomaly: 5,          │ FR      │ 5410 Bouygues Telecom SA │           │ 2026-07-13T10:37:19Z │ waf      │
│ 813 │ Ip:2001:861:34c0:1330:62b3:46c:bfcf:38a6 │ anomaly score block: anomaly: 5,          │ FR      │ 5410 Bouygues Telecom SA │           │ 2026-07-13T10:37:08Z │ waf      │
│ 812 │ Ip:2001:861:34c0:1330:62b3:46c:bfcf:38a6 │ anomaly score block: anomaly: 5,          │ FR      │ 5410 Bouygues Telecom SA │           │ 2026-07-13T10:35:10Z │ waf      │
│ 811 │ Ip:2001:861:34c0:1330:62b3:46c:bfcf:38a6 │ anomaly score block: anomaly: 5,          │ FR      │ 5410 Bouygues Telecom SA │           │ 2026-07-13T10:27:00Z │ waf      │
│ 810 │ Ip:172.69.222.25                         │ anomaly score block: anomaly: 5,          │ FR      │ 13335 CLOUDFLARENET      │           │ 2026-07-13T10:26:58Z │ waf      │
│ 809 │ Ip:172.69.222.25                         │ anomaly score block: anomaly: 5,          │ FR      │ 13335 CLOUDFLARENET      │           │ 2026-07-13T10:23:40Z │ waf      │
│ 808 │ Ip:172.69.222.25                         │ anomaly score block: anomaly: 5,          │ FR      │ 13335 CLOUDFLARENET      │           │ 2026-07-13T10:20:38Z │ waf      │
│ 807 │ Ip:172.69.222.25                         │ anomaly score block: anomaly: 5,          │ FR      │ 13335 CLOUDFLARENET      │           │ 2026-07-13T10:19:33Z │ waf      │
│ 806 │ Ip:172.71.183.167                        │ anomaly score block: anomaly: 5,          │ NL      │ 13335 CLOUDFLARENET      │           │ 2026-07-13T10:18:48Z │ waf      │
│ 804 │ Ip:172.69.17.200                         │ anomaly score block: anomaly: 5,          │ US      │ 13335 CLOUDFLARENET      │           │ 2026-07-13T09:36:05Z │ waf      │
│ 803 │ Ip:172.69.17.161                         │ anomaly score block: anomaly: 5,          │ US      │ 13335 CLOUDFLARENET      │           │ 2026-07-13T09:36:05Z │ waf      │
│ 802 │ Ip:172.70.111.159                        │ anomaly score block: anomaly: 5,          │ US      │ 13335 CLOUDFLARENET      │           │ 2026-07-13T08:31:18Z │ waf      │
│ 796 │ Ip:139.59.231.238                        │ crowdsecurity/http-probing                │ SG      │ 14061 DIGITALOCEAN-ASN   │ ban:1     │ 2026-07-12T23:12:29Z │ crowdsec │
│ 795 │ Ip:139.59.231.238                        │ crowdsecurity/http-technology-probing     │ SG      │ 14061 DIGITALOCEAN-ASN   │           │ 2026-07-12T23:12:49Z │ crowdsec │
│ 794 │ Ip:139.59.231.238                        │ crowdsecurity/jira_cve-2021-26086         │ SG      │ 14061 DIGITALOCEAN-ASN   │ ban:1     │ 2026-07-12T23:12:46Z │ crowdsec │
│ 793 │ Ip:139.59.231.238                        │ Enabling body inspection                  │ SG      │ 14061 DIGITALOCEAN-ASN   │           │ 2026-07-12T23:12:46Z │ waf      │
│ 792 │ Ip:139.59.231.238                        │ crowdsecurity/vpatch-git-config           │ SG      │ 14061 DIGITALOCEAN-ASN   │           │ 2026-07-12T23:12:41Z │ waf      │
│ 791 │ Ip:172.71.124.151                        │ crowdsecurity/vpatch-env-access           │ SG      │ 13335 CLOUDFLARENET      │           │ 2026-07-12T23:12:37Z │ waf      │
│ 790 │ Ip:172.70.142.133                        │ anomaly score block: lfi: 5, anomaly: 5,  │ SG      │ 13335 CLOUDFLARENET      │           │ 2026-07-12T23:12:36Z │ waf      │
│ 789 │ Ip:157.245.113.227                       │ crowdsecurity/http-technology-probing     │ US      │ 14061 DIGITALOCEAN-ASN   │           │ 2026-07-12T22:54:14Z │ crowdsec │
│ 788 │ Ip:157.245.113.227                       │ crowdsecurity/jira_cve-2021-26086         │ US      │ 14061 DIGITALOCEAN-ASN   │ ban:1     │ 2026-07-12T22:54:11Z │ crowdsec │
│ 787 │ Ip:157.245.113.227                       │ crowdsecurity/appsec-native               │ US      │ 14061 DIGITALOCEAN-ASN   │ ban:1     │ 2026-07-12T22:54:04Z │ crowdsec │
│ 786 │ Ip:157.245.113.227                       │ Enabling body inspection                  │ US      │ 14061 DIGITALOCEAN-ASN   │           │ 2026-07-12T22:54:11Z │ waf      │
│ 785 │ Ip:157.245.113.227                       │ crowdsecurity/http-probing                │ US      │ 14061 DIGITALOCEAN-ASN   │ ban:1     │ 2026-07-12T22:53:56Z │ crowdsec │
╰─────┴──────────────────────────────────────────┴───────────────────────────────────────────┴─────────┴──────────────────────────┴───────────┴──────────────────────┴──────────╯

harry  …/docker/apps/penpot  ♥ 11:24  
```

ici c'est la 840, donc on fait

```bash
sudo docker exec -it crowdsec cscli alerts inspect 840
```

```bash
harry  …/docker/apps/penpot  ♥ 11:26  sudo docker exec -it crowdsec cscli alerts inspect 840

################################################################################################

 - ID           : 840
 - Date         : 2026-07-13T11:22:40Z
 - Machine      : localhost
 - Simulation   : false
 - Remediation  : false
 - Kind         : waf
 - Reason       : anomaly score block: anomaly: 5, 
 - Events Count : 4
 - Scope:Value  : Ip:172.71.126.253
 - Country      : FR
 - AS           : CLOUDFLARENET
 - Begin        : 2026-07-13T11:22:40Z
 - End          : 2026-07-13T11:22:40Z
 - UUID         : 66291b13-54b4-4867-b27b-1b24ab354680


 - Context  :
╭───────────────┬──────────────────────────────────────────────────────────────╮
│      Key      │                             Value                            │
├───────────────┼──────────────────────────────────────────────────────────────┤
│ ja4h          │ po11cn28frfr_dd3a5d47b9f0_464bf67f72dd_bc6e648077a8          │
│ matched_zones │ REQUEST_HEADERS.Content-Type                                 │
│ matched_zones │ TX.content_type                                              │
│ method        │ POST                                                         │
│ msg           │ Request content type is not allowed by policy                │
│ name          │ native_rule:920420                                           │
│ target_uri    │ /api/main/methods/login-with-password                        │
│ user_agent    │ Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML,   │
│               │ like Gecko) Chrome/150.0.0.0 Safari/537.36                   │
╰───────────────┴──────────────────────────────────────────────────────────────╯

harry  …/docker/apps/penpot  ♥ 11:26  
```

On voit la règle `native_rule:920420`

On va l'ajouter en liste blanche à custom-config.yaml

```bash
sudo nano /opt/docker/crowdsec/config/appsec-configs/custom-config.yaml
```

Voici à quoi ressemble le fichier

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
```

Voici en quoi on le transforme

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
      req.Host == "draw.rogerbytes.com" &&
      any(evt.Appsec.MatchedRules, {#.name == "native_rule:920420"})
    apply:
      - SetRemediation("allow")
      - CancelAlert()
      - CancelEvent()
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
      req.Host == 'draw.rogerbytes.com' &&
      any(evt.Appsec.MatchedRules, {r.Name == 'native_rule:920420'})
    apply:
      - SetRemediation("allow")
```

On enregistre et on relance crowdsec

```bash
sudo docker exec crowdsec cscli hub update && sudo docker restart crowdsec
```

## Problème erreur interne

```bash
harry  …/docker/apps/penpot  ♥ 11:54  curl -I -H "Host: draw.rogerbytes.com" https://51.210.47.245/js/main-workspace.js -k
curl: (35) TLS connect error: error:0A000438:SSL routines::tlsv1 alert internal error

harry  …/docker/apps/penpot  ♥ 11:54  
```

Cloudflare / le domainbe -> Regle / vue d'ensemble
