# 01 - Installation PenPot

Depuis [Page docker hub](https://hub.docker.com/u/penpotapp)
Depuis [la doc du site](https://help.penpot.app/technical-guide/getting-started/docker/)

Le mode [All-In-One](https://www.openproject.org/docs/installation-and-operations/installation/docker/)(ce qui est utilisé dans la présente documentation) convient parfaitement pour trente dev travaillant dessus simultanément. Au dessus de 30 personne, on déploiera OpenProject via [une méthode avec un conteneur par service](https://www.openproject.org/docs/installation-and-operations/installation/docker-compose/)

## Prérequis

### Création du répertoire

On prépare un répertoire dans `opt/docker`

```bash
sudo mkdir -p /opt/docker/apps/penpot
cd /opt/docker/apps/penpot
```

### Téléchargement du compose officiel

```bash
sudo wget -O compose.yml https://raw.githubusercontent.com/penpot/penpot/main/docker/images/docker-compose.yaml
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

### Paramétrage du bridge caddy_network dans le compose.yml

Par sécurité on n'expose aucun port du conteneur, on utilise `caddy_network`, comme à notre habitude.

```bash
sudo nano compose.yml
```

On va à

```yml
  penpot-frontend:
    image: "penpotapp/frontend:${PENPOT_VERSION:-2.16}"
    restart: always
    ports:
      - 9001:8080
```

on supprime `ports:` par

```yml
  penpot-frontend:
    image: "penpotapp/frontend:${PENPOT_VERSION:-2.16}"
    restart: always
    networks:
      - penpot
      - caddy_network
```

Quelques lignes en dessous, il y a

```yml
    networks:
      - penpot
```

on ajoute `- caddy_network`

```yml
    networks:
      - penpot
      - caddy_network
```

et chercher `PENPOT_SECRET_KEY:`, juste en dessous il y a `networks:`

```yml
networks:
  penpot:
```

Lui ajouter notre bridge

```yml
networks:
  penpot:
  caddy_network:
    external: true
```

### Mettre le URI du domaine dans le compose.yml

```bash
sudo nano compose.yml
```

On va à

```yml
x-uri: &penpot-public-uri
  PENPOT_PUBLIC_URI: http://localhost:9001
```

et on remplace

```yml
x-uri: &penpot-public-uri
  PENPOT_PUBLIC_URI: https://draw.mondomaine.com
```

### Redirection avec Caddyfile

```python
sudo nano /opt/docker/caddy/Caddyfile
```

Descendre tout en bas du document (`ALT + /`) et, dans la section dédiée à la **Redirection de domaines**, coller ce bloc de configuration :

```text
draw.mondomaine.com {
        import crowdsec_bouncer
        reverse_proxy penpot-frontend:80
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
sudo docker compose -p penpot -f compose.yml up -d


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

Pour identifiants: admin
mot de passe: admin: admin

et on change le mdp par un mdp lourd

ET dans

Va dans l'Administration globale (via l'icône d'engrenage en haut à droite ou le menu utilisateur).

Dans le menu latéral gauche, clique sur Emails et notifications (ou Emails and notifications).

Adresse expéditeur
mettre le bon expéditeur `noreply@mondomaine.com`

Changer la timezone dans les options du compte, et mettre paris (sinon l'heure est en retard sur GMT0)

Reste sur le premier onglet principal. Descends tout en bas de cette page.

Dire aux utilisateurs de vérifier le fuseau horaire pour éviter le quiproquo.

--

## La merde

on teste de trouver

```yml
PENPOT_FLAGS: disable-email-verification enable-smtp enable-prepl-server disable-secure-session-cookies enable-mcp
```

```bash
sudo nano compose.yml
```

VIRER
'disable-secure-session-cookies' and 'disable-email-verification'

```yml
PENPOT_FLAGS: disable-email-verification enable-smtp enable-prepl-server disable-secure-session-cookies enable-mcp
```

```yml
PENPOT_FLAGS: enable-smtp enable-prepl-server enable-mcp
```

!!!!!network sur le backend

- caddy_network

!!!! Lhistoire

```yml
environment:
      <<: *penpot-flags
      <<: *penpot-http-body-size
      <<: *penpot-public-uri
```

au lieu de

```yml
environment:
  << : [*penpot-flags, *penpot-http-body-size, *penpot-public-uri]
```

ET SURTOUT

```bash
harry  …/docker/apps/penpot  ♥ 19:50  sudo docker compose config
[sudo] password for harry: 
yaml: while parsing a block mapping at <unknown position>: line 42, column 3: did not find expected key

harry  …/docker/apps/penpot  ♥ 19:50  

```
