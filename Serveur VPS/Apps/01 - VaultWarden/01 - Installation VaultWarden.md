# 01 - Installation VaultWarden

Depuis [Page docker hub](https://hub.docker.com/r/vaultwarden/server)
Depuis [Page GitHub](https://github.com/dani-garcia/vaultwarden)

- A plusieurs moments l'ipv4 utilisé pour SSH est `192.0.2.1`, prenez garde à bien le changer par le votre, en passant `192.0.2.1` est une IP de test réservée aux exemples, elle ne fonctionnera pas pour votre serveur.

## Prérequis

### Création du répertoire

On prépare un répertoire dans `opt/docker`

```bash
sudo mkdir -p /opt/docker/vaultwarden
cd /opt/docker/vaultwarden
```

### Préparation de la boite mail chez MXROUTE.com

Une fois que l'on a paramétré correctement MXROUTE.com avec le nom de domaine (voir `Mailing/Utiliser mail MXROUTE.md`), il suffit de créer un compte mail.

#### Créer nouveau compte mail MXROUTE

Se connecter au [site de mxroute.com](https://management.mxroute.com/dashboard)

- Dans le menu `dashboard` (par défaut), cliquer sur le bouton `Login to Panel`, et allez sur le menu `Email Accounts`.
- Cliquer sur `+ Create New Email Account`, entrer `vault` comme username et lui générer un mdp (garder précieusement les identifiants) et cliquer sur `Create Account`.
- La mail généré est `vault@votrenomdedomaine.com`

#### Récupérer le serveur MX de MXROUTE

Se connecter au [site de mxroute.com](https://management.mxroute.com/dashboard)

- Dans le menu `dashboard` (par défaut), cliquer sur le bouton `Login to Panel`, et allez sur le menu `DNS`.
- Dans l'encadré `MX Records` prendre la `VALUE` de celui avec la `PRIORITY` 10 (l'autre est un serveur de secours si le premier est en rade).
- Vous aurez une adresse serveur du genre `machin.mxrouting.net`

Si le compte MXROUTE est bien réglé, et pareil du côté du registrar lors de l'ajout du NDD, il n'y a rien d'autre à faire pour le mailing.

### Création du .env

On créé le fichier d'environment (il contiendra les variables d'auth)

```bash
sudo nano .env
```

Et on y ajoute ce qui suit

```ini
ADMIN_TOKEN=MonSuperMotDePasseSecret123!
MX_SERVER=machin.mxrouting.net
MX_EMAIL=vault@votrenomdedomaine.com
MX_PASSWORD=LeMotDePasseDeCetteBoiteMail
```

Voici les explications du `.env`, à ne pas utiliser tel quel (c'est juste pour savoir quelles données modifier dans le template au-dessus)

```ini
ADMIN_TOKEN=MonSuperMotDePasseSecret123! # <--- À remplacer par votre token
MX_SERVER=machin.mxrouting.net # <--- À remplacer par le serveur mxroute
MX_EMAIL=vault@votrenomdedomaine.com # <--- À remplacer par l'email d'envoi
MX_PASSWORD=LeMotDePasseDeCetteBoiteMail # <--- À remplacer par le mot de passe de la boite mail
```

Avant d’enregistrer, on change correctement les valeurs des différentes variables

### Création du `compose.yml`

On créé le `compose.yml`

```bash
sudo nano compose.yml
```

et on colle

```yaml
services:
  vaultwarden:
    image: vaultwarden/server:latest
    container_name: vaultwarden
    restart: unless-stopped
    environment:
      - SIGNUPS_ALLOWED=false
      - INVITATIONS_ALLOWED=true
      - ADMIN_TOKEN=${ADMIN_TOKEN}
      - SMTP_HOST=${MX_SERVER}
      - SMTP_FROM=${MX_EMAIL}
      - SMTP_PORT=465
      - SMTP_SECURITY=force_tls
      - SMTP_USERNAME=${MX_EMAIL}
      - SMTP_PASSWORD=${MX_PASSWORD}
    volumes:
      - ./vw-data:/data
    ports:
      - 127.0.0.1:8000:80
```

Et enregistrer le fichier.

## Création du conteneur

Et on lance le `compose up`

```bash
sudo docker compose up -d
```

On vérifie le statut du conteneur

```bash
sudo docker compose ps
```

Et on vérifie s'il a bien crée le dossier de stockage

```bash
ls -l
```

il retourne

```bash
total 8
-rw-r--r-- 1 root root  196 Jun 20 19:05 compose.yml
drwxr-xr-x 3 root root 4096 Jun 20 19:06 vw-data
```

## Gestion du domaine / sous-domaine

Se connecter sur le [Hub d'OVH](https://manager.eu.ovhcloud.com/#/hub/), et aller sur `Web Cloud/Zones DNS`, cliquer sur le nom de domaine souhaité pour aller sur son menu.

Cliquer sur `Ajouter une entrée` et, dans `Champs de pointage` prendre `A`, remplir comme cela :

```text
Sous-domaine:
vw
TTL:
(Laisser par défaut)
Cible*:
192.0.2.1
```

Remplacer `192.0.2.1` par l'ipv4 du VPS.

## Configurer un reverse proxy avec Caddy

Il suffit de modifier le `Caddyfile` comme on l'a déjà fait.

```bash
sudo nano /opt/docker/caddy/Caddyfile
```

On y ajoute

```plaintext
vw.rogerbytes.com {
        log {
                output file /var/log/caddy/caddy.log
        }
        reverse_proxy 127.0.0.1:8000
}
```

On enregistre le fichier puis on actualise la configuration de Caddy

```bash
sudo docker compose -f /opt/docker/caddy/compose.yml restart caddy
```

Si ce n'était pas le premier reverse proxy, on aurait fait

```bash
sudo docker compose -f /opt/docker/caddy/compose.yml exec -w /etc/caddy caddy caddy reload
```

Si `Caddyfile input is not formatted; run 'caddy fmt --overwrite' to fix inconsistencies    {"adapter": "caddyfile", "file": "Caddyfile", "line": 2}`

Il suffit de lancer la commande pour reformater le fichier automatiquement

```bash
sudo docker compose -f /opt/docker/caddy/compose.yml exec -w /etc/caddy caddy caddy fmt --overwrite
```

### Hasher le Token pour VaultWarden

Au lieu de laisser le token en clair sur le .env, on peut utiliser un hash `Argon2id PHC` du mot de passe

```bash
sudo docker exec -it vaultwarden /vaultwarden hash
```

puis on édite le `.env`

```bash
sudo nano .env
```

Pour y mettre son hash à la place du mot de passe.

Puis on relance le service (on peut pas faire `reload` ou `restart`, il garderait en mémoire l'ancien `.env`)

```bash
sudo docker compose up -d
```
