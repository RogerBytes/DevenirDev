# 01 - Installation VaultWarden

Depuis [Page docker hub](https://hub.docker.com/r/openproject/openproject)
Depuis [la doc All-In-One de déploiement Docker](https://www.openproject.org/docs/installation-and-operations/installation/docker/)

Le mode [All-In-One](https://www.openproject.org/docs/installation-and-operations/installation/docker/)(ce qui est utilisé dans la présente documentation) convient parfaitement pour trente dev travaillant dessus simultanément. Au dessus de 30 personne, on déploiera OpenProject via [une méthode avec un conteneur par service](https://www.openproject.org/docs/installation-and-operations/installation/docker-compose/)

## Prérequis

### Création du répertoire

On prépare un répertoire dans `opt/docker`

```bash
sudo mkdir -p /opt/docker/apps/openproject
cd /opt/docker/apps/openproject
```

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

### Générer une clef secrète pour openproject

```bash
openssl rand -hex 64
```

Gardez précieusement la chaîne générée de côté, elle va servir dans le fichier de configuration juste après.

### Générer le compose.yml

```bash
sudo nano compose.yml
```

Et on y colle

```yml
services:
  openproject:
    image: openproject/openproject:17
    container_name: openproject
    restart: unless-stopped
    environment:
      - TZ=Europe/Paris
      - SECRET_KEY_BASE=METS_TA_CLE_DE_64_OCTETS_ICI
      - OPENPROJECT_HOST__NAME=op.mondomaine.com
      - OPENPROJECT_HTTPS=true
      - OPENPROJECT_DEFAULT__LANGUAGE=fr

      # --- CONFIGURATION EMAIL SMTP (MXROUTE) ---
      - OPENPROJECT_SMTP__ADDRESS=le-serveur.mxroute.com
      - OPENPROJECT_SMTP__PORT=587
      - OPENPROJECT_SMTP__DOMAIN=mondomaine.com
      - OPENPROJECT_SMTP__AUTHENTICATION=login
      - OPENPROJECT_SMTP__USER__NAME=ton-email@mondomaine.com
      - OPENPROJECT_SMTP__PASSWORD=ton-mot-de-passe-mxroute
      - OPENPROJECT_SMTP__ENABLE__STARTTLS__AUTO=true
    volumes:
      - openproject_pgdata:/var/openproject/pgdata
      - openproject_assets:/var/openproject/assets
    networks:
      - caddy_network

volumes:
  openproject_pgdata:
  openproject_assets:

networks:
  caddy_network:
    external: true
```

### Redirection avec Caddyfile

```python
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

## Installation du conteneur

```bash
cd /opt/docker/apps/openproject
sudo docker compose up -d
```

On peut suivre l'avancement de l'initialisation avec

```bash
sudo docker compose logs -f openproject
```

Et on attends de voir

```text
openproject  | [206] * Listening on http://0.0.0.0:8080
openproject  | [206] Use Ctrl-C to stop
openproject  | [206] - Worker 0 (PID: 533) booted in 0.02s, phase: 0
openproject  | [206] - Worker 1 (PID: 536) booted in 0.01s, phase: 0
openproject  | I, [2026-07-02T09:46:40.054709 #215]  INFO -- : [GoodJob] GoodJob started cron with 17 jobs.
openproject  | I, [2026-07-02T09:46:40.121529 #215]  INFO -- : [GoodJob] Notifier subscribed with LISTEN
openproject  | I, [2026-07-02T09:47:45.966281 #536]  INFO -- : [634e5e59-169b-42af-bb74-eecc2051f650] method=GET path=/robots.txt format=text controller=HomescreenController action=robots status=200 allocations=34182 duration=267.57 view=22.92 db=75.94 user=2
```

On se connecte sur le navigateur à <https://op.mondomaine.com/>

Pour identifiants: admin
mot de passe: admin: admin

et on change le mdp par un mdp lourd

ET dans

Va dans l'Administration globale (via l'icône d'engrenage en haut à droite ou le menu utilisateur).

Dans le menu latéral gauche, clique sur Emails et notifications (ou Emails and notifications).

Adresse expéditeur
mettre le bon expéditeur noreply@mondomaine.com

Reste sur le premier onglet principal. Descends tout en bas de cette page.

Dire aux utilisateurs de vérifier le fuseau horaire pour éviter le quiproquo
