# 01 - Installation VaultWarden

Depuis [Page docker hub](https://hub.docker.com/r/vaultwarden/server)
Depuis [Page GitHub](https://github.com/dani-garcia/vaultwarden)

- A plusieurs moments l'ipv4 utilisé pour SSH est `192.0.2.1`, prenez garde à bien le changer par le votre, en passant `192.0.2.1` est une IP de test réservée aux exemples, elle ne fonctionnera pas pour votre serveur.

## Prérequis

### Création du répertoire

On prépare un répertoire dans `opt/docker`

```bash
sudo mkdir -p /opt/docker/apps/openproject
cd /opt/docker/apps/openproject
```

### Gestion  domaine / sous domaine CloudFlare

On va sur [dashboard de CloudFlare](dash.cloudflare.com)

- puis `Domaine / Vue d'ensemble` cliquer sur le domaine
- puis `DNS / Enregistrements`
- cliquer sur le bouton `+ Ajouter un enregistrement`
- Type `A`
- Nom `sous.domaine.com`
- Adresse IPv4 `192.0.2.1`
- cliquer sur `Enregistrer`

Remplacer `192.0.2.1` par l'ipv4 du VPS.

### Générer une clé secrète hexadécimale (Secret Key Base)

OpenProject nécessite une clé secrète à forte entropie pour chiffrer les sessions utilisateurs. Générez une chaîne unique de 64 caractères directement depuis votre terminal :

```bash
openssl rand -hex 32
```

Gardez précieusement la chaîne générée de côté, elle va servir dans le fichier de configuration juste après.

Rappel de sécurité **IMPORTANT** : Veillez à ce que vos mots de passe de base de données ou votre clé secrète ne contiennent aucun caractère $. Docker interprète ce symbole comme une variable et tronquera vos identifiants, provoquant des erreurs de connexion (Erreur 502)

### Caddyfile

```bash
sudo nano /opt/docker/caddy/Caddyfile
```

A la fin du document (`ALT + /`), dans la partie `Redirection de domaines` coller (en mettant votre nom de domaine)

```text
op.mondomaine.com {
        import crowdsec_bouncer
        reverse_proxy openproject:80
}
```

Au cas où, pour voir les port internes à docker, faire

```bash
sudo docker ps --format "table {{.Names}}\t{{.Ports}}"
```

on utilise le formateur intégré avec

```bash
sudo docker compose -f /opt/docker/caddy/compose.yml exec -w /etc/caddy caddy caddy fmt --overwrite
```

et on relance caddy

```bash
sudo docker compose -f /opt/docker/caddy/compose.yml exec -w /etc/caddy caddy caddy reload
```

### Création du `compose.yml`

On créé le `compose.yml`

```bash
sudo nano compose.yml
```

et on colle

```yaml
services:
  db:
    image: postgres:15-alpine
    container_name: openproject-db
    restart: unless-stopped
    environment:
      POSTGRES_DB: openproject
      POSTGRES_USER: openproject
      POSTGRES_PASSWORD: UnMotDePasseRobusteEtSansDollar
    volumes:
      - ./pgdata:/var/lib/postgresql/data
    networks:
      - openproject_internal

  openproject:
    image: openproject/openproject:17-rc
    container_name: openproject
    restart: unless-stopped
    environment:
      OPENPROJECT_DB_BACKEND: postgres
      OPENPROJECT_DB_HOST: db
      OPENPROJECT_DB_PORT: 5432
      OPENPROJECT_DB_NAME: openproject
      OPENPROJECT_DB_USER: openproject
      OPENPROJECT_DB_PASSWORD: UnMotDePasseRobusteEtSansDollar # Must match the DB password above
      SECRET_KEY_BASE: CollerIciLaCleHexadécimaleGénérée
      OPENPROJECT_HOST__NAME: op.mondomaine.com # <-- Votre sous-domaine complet
      OPENPROJECT_HTTPS: "true"
    volumes:
      - ./assets:/var/openproject/assets
    networks:
      - openproject_internal
      - caddy_network
    depends_on:
      - db

networks:
  openproject_internal: # Réseau privé isolé pour la base de données
  caddy_network:
    external: true
```

Et enregistrer le fichier.

## Création du conteneur

Et on lance le `compose up`

```bash
sudo docker compose up -d
```

## La patience

Il faut du temps pour que tout s'initialise

```bash
sudo docker logs -f openproject
```

Voilà, notre **VaultWarden** est correctement déployé et paramétré !
