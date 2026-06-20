# Installation VaultWarden

Depuis [Page docker hub](https://hub.docker.com/r/vaultwarden/server)
Depuis [Page GitHub](https://github.com/dani-garcia/vaultwarden)

## Partie A

On prépare un répertoire dans `opt/docker`

```bash
sudo mkdir -p /opt/docker/vaultwarden
cd /opt/docker/vaultwarden
```

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
    volumes:
      - ./vw-data:/data
    ports:
      - 127.0.0.1:8000:80
```

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
-rw-r--r-- 1 root root  196 Jun 19 22:15 docker-compose.yml
drwxr-xr-x 3 root root 4096 Jun 19 22:16 vw-data
```

## Partie B

Se connecter sur le [Hub d'OVH](https://manager.eu.ovhcloud.com/#/hub/), et aller sur `Web Cloud/Zones DNS`, cliquer sur le nom de domaine souhaité pour aller sur son menu.

Cliquer sur `Ajouter une entrée` et, dans `Champs de pointage` prendre `A`, remplir comme cela :

```text
Sous-domaine:
vw
TTL:
(Laisser par défaut)
Cible*:
51.210.47.245
```

Cible l'ip de la machine.

## Le réglage de Caddy

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
sudo docker compose exec -w /etc/caddy caddy caddy reload
```

---

IL RESTE A FAIRE

environment:
      - SIGNUPS_ALLOWED=false

pour bloquer les inscriptions

PUIS

2. Configurer les e-mails (Optionnel)
Si tu veux que ton Vaultwarden puisse t'envoyer des invitations ou des alertes de sécurité par mail, il faudra lui ajouter les identifiants d'un serveur SMTP (comme une adresse Gmail, OVH ou autre dédiée aux envois automatique).

Pour l'instant, profite de ton installation : tu as mérité de tester ton coffre-fort de mots de passe ! Tout est prêt.