# 03 - Installation de Caddy

- Depuis [Page docker hub](https://hub.docker.com/_/caddy)
- Depuis [Page GitHub](https://github.com/caddyserver/caddy)
- Depuis [Le compose](https://caddyserver.com/docs/running#docker-compose)
- Depuis [La commande Docker](https://caddyserver.com/docs/install#docker)

## Prérequis

### Réglage Fail2Ban Système

Maintenant on paramètre `Fail2Ban` système

```bash
sudo nano /etc/fail2ban/jail.local
```

On l'ajoute `caddy-auth` (tout à la fin) `ALT + /`

```plaintext
[caddy-auth]
enabled  = true
port     = 80,443
filter   = caddy-auth
logpath  = /opt/docker/caddy/logs/access.log
backend  = auto
findtime = 10m
maxretry = 5
bantime  = 1h
action   = cloudflare
```

#### Donner la clef à fail2ban

On ajoute son token de cloudflare dans

```bash
sudo nano /etc/fail2ban/action.d/cloudflare.conf
```

En bas (`ALT + /`) on voit

```text
cftoken =

cfuser =

cftarget = ip

[Init?family=inet6]
cftarget = ip6
```

Les infos de  `cftoken` et `cfuser`

- `cftoken` - [cette page](https://dash.cloudflare.com/profile/api-tokens)(ignorer l'alerte `Clé CA Origine`, c'est caddy qui s'occupe de ça et non CloudFlare), faire `Afficher`.
- `cfuser` - C'est tout simplement l'adresse email avec laquelle on se connecte au compte Cloudflare.

On créé le fichier de filtre

```bash
sudo nano /etc/fail2ban/filter.d/caddy-auth.conf
```

Et on y met

```plaintext
[Definition]
failregex = ^\{.*"client_ip":"<ADDR>".*"status":(401|403).*\}
            ^\{.*"status":(401|403).*"client_ip":"<ADDR>".*\}

datepattern = ,Epoch
```

On génère le log

```bash
sudo mkdir -p /opt/docker/caddy/logs/
sudo touch /opt/docker/caddy/logs/access.log
```

On enregistre la configuration, et on relance `Fail2ban`

```bash
sudo fail2ban-client reload
```

Voilà, nos deux ports d'entrées sont protégés des attaques BruteForce et DoS, et Fail2Ban modifiera les réglages du pare-feu CloudFlare via l'API.

### Préparation du répertoire et Caddyfile

On prépare un répertoire dans `opt/docker` et on s'y rend

```bash
sudo mkdir -p /opt/docker/caddy/logs
cd /opt/docker/caddy
```

On créé le `Caddyfile`

```bash
sudo nano Caddyfile
```

On y colle

```text
# --------------- Réglages globaux --------------- #
{
        servers {
                # Permet à Caddy de reconnaître la vraie IP du visiteur derrière Cloudflare.
                trusted_proxies static 173.245.48.0/20 103.21.244.0/22 103.22.200.0/22 103.31.4.0/22 141.101.64.0/18 108.162.192.0/18 190.93.240.0/20 188.114.96.0/20 197.234.240.0/22 198.41.128.0/17 162.158.0.0/15 104.16.0.0/13 104.24.0.0/14 172.64.0.0/13 131.0.72.0/22 2400:cb00::/32 2606:4700::/32 2803:f800::/32 2405:b500::/32 2405:8100::/32 2a06:98c0::/29 2c0f:f248::/32
        }
}

(fail2ban_logs) {
        log {
                output file /var/log/caddy/access.log
                format json
        }
}

# ----------- Redirection de domaines ------------ #

```

Les ipv4 listées proviennent [de la page dédiée aux ip de CloudFlare](https://www.cloudflare.com/ips-v4)

On enregistre.

### Création du `compose.yml`

Maintenant on fait le `compose.yml`

```bash
sudo nano compose.yml
```

et on colle

```yaml
services:
  caddy:
    image: caddy:2.11.4-alpine
    restart: unless-stopped
    volumes:
      - ./Caddyfile:/etc/caddy/Caddyfile
      - ./logs:/var/log/caddy
      - data:/data
      - config:/config
    network_mode: "host"

volumes:
  data:
  config:
```

#### Explication du Mappage de volumes

Un conteneur se base sur une image Docker. En gros, c'est une mini-distribution Linux, stockée comme une sorte d'*.iso (une image immuable en lecture seule).

Docker, afin que ces "mini-distrib" puissent fonctionner correctement, gère (entre autres) le mappage de volumes, permettant aux mini-Linux de voir des fichiers et répertoires en dehors de leur image et d’interagir avec l'hôte.

##### Compréhension du Bind Mount

On observe ici

```yml
      - ./Caddyfile:/etc/caddy/Caddyfile
      - ./logs:/var/log/caddy
```

- `./Caddyfile:/etc/caddy/Caddyfile`
  - `./Caddyfile` est le chemin hôte (donc sur la machine qui fait tourner Docker)
  - `/etc/caddy/Caddyfile` est le chemin présent sur l'image.
  - Quand le linux du conteneur pensera interagir avec `/etc/caddy/Caddyfile` il sera en fait en train d’interagir avec `./Caddyfile`

C'est le même raisonnement pour `./logs:/var/log/caddy`, à part que `logs` est un répertoire (la syntaxe ne permet pas de faire la distinction dans le path)

##### Compréhension du Named Volume

```yml
      - data:/data
      - config:/config
```

et

```yml
volumes:
  data:
  config:
```

La partie du bas sert à déclarer des volumes nommés (créant des espaces de stockage). Cela permet d'avoir un point de montage nommé qui sera séparé du conteneur. Si on supprime le conteneur, ce qui a été écrit sur ce volume n'est pas supprimé, il reste.

Seulement, si on n'associe pas ce volume au service avec la ligne `- config:/config`, le volume du bas reste juste "existant" mais vide.

C'est pour ça qu'il est mis dans les volumes du service

- `data:/data`
  - `data` (de gauche) est le nom du volume déclaré en bas.
  - `data` (de droite) est le chemin présent sur l'image.
  - Quand le linux du conteneur pensera interagir avec `/data` il sera en fait en train d’interagir avec le volume `data`.

## Création du conteneur

Et on lance le `compose up`

```bash
sudo docker compose up -d
```

On wipe les logs (vu que c'est notre installation, on peut le faire)

```bash
sudo truncate -s 0 $(sudo docker inspect --format='{{.LogPath}}' $(sudo docker compose ps -q caddy))
```

et on utilise (pour notre fichier Caddyfile de toute à l'heure) le formateur intégré avec

```bash
sudo docker compose -f /opt/docker/caddy/compose.yml exec -w /etc/caddy caddy caddy fmt --overwrite
```

et on relance caddy

```bash
sudo docker compose -f /opt/docker/caddy/compose.yml exec -w /etc/caddy caddy caddy reload
```

On vérifie le statut du conteneur

```bash
sudo docker compose logs -f
```

Retourne

```text
caddy-1  | {"level":"info","ts":1782226246.2882688,"logger":"admin.api","msg":"received request","method":"POST","host":"localhost:2019","uri":"/load","remote_ip":"127.0.0.1","remote_port":"41222","headers":{"User-Agent":["Go-http-client/1.1"],"Content-Length":["2"],"Caddy-Config-Source-Adapter":["caddyfile"],"Caddy-Config-Source-File":["Caddyfile"],"Content-Type":["application/json"],"Origin":["http://localhost:2019"],"Accept-Encoding":["gzip"]}}
caddy-1  | {"level":"info","ts":1782226246.2888181,"msg":"config is unchanged"}
caddy-1  | {"level":"info","ts":1782226246.2890744,"logger":"admin.api","msg":"load complete"}
```

Voilà, tout est prêt, il faudra à chaque fois ajouter les nouveaux réglages (pour chaque domaine) dans le `Caddyfile`, à la fin du fichier dans la partie `Redirection de domaines`.

Maintenant que `Caddy` est correctement installé, on va terminer la section par un dernier réglage de pare-feu.

## UFW réglage final

On donne la liste blanche d'ip de CloudFlare

```bash
for ip in 173.245.48.0/20 103.21.244.0/22 103.22.200.0/22 103.31.4.0/22 141.101.64.0/18 108.162.192.0/18 190.93.240.0/20 188.114.96.0/20 197.234.240.0/22 198.41.128.0/17 162.158.0.0/15 104.16.0.0/13 104.24.0.0/14 172.64.0.0/13 131.0.72.0/22 2400:cb00::/32 2606:4700::/32 2803:f800::/32 2405:b500::/32 2405:8100::/32 2a06:98c0::/29 2c0f:f248::/32; do
  sudo ufw allow from $ip to any port 80,443 proto tcp
done
```

- Les ipv4 listées proviennent [de la page dédiée aux ipv4 de CloudFlare](https://www.cloudflare.com/ips-v4)
- Les ipv6 listées proviennent [de la page dédiée aux ipv6 de CloudFlare](https://www.cloudflare.com/ips-v6)

Pour tout récupérer d'un coup

```bash
echo $(curl -s https://www.cloudflare.com/ips-v4) $(curl -s https://www.cloudflare.com/ips-v6)
```

Puis on relance UFW

```bash
sudo ufw reload
```

## Réglage CloudFlare SSL/TLS

On va sur [dashboard de CloudFlare](dash.cloudflare.com)

- puis `Domaine / Vue d'ensemble` cliquer sur le domaine
- puis `SSL/TLS / Vue d'ensemble`
- cliquer sur le bouton `Configurer`
- choisir `Full (Strict)`
- cliquer sur `Enregistrer`

Ce réglage utilise deux certificats (un créé par Cloudflare pour le visiteur, et un créé par Caddy pour Cloudflare) afin de sécuriser entièrement la connexion de bout en bout et d'éliminer les erreurs.

## Test

Il y a énormément de tests à effectuer pour être sûr que l’infrastructure fonctionne comme désiré.

### Tester une requête http/https

En premier on crée un redirection de test, ça nous servira pour les autres tests aussi

```bash
sudo nano /opt/docker/caddy/Caddyfile
```

Ajoutez cette redirection à la fin, dans la partie `Redirection de domaines`

```text
mondomaine.com {
        import fail2ban_logs
        respond "Caddy fonctionne avec Cloudflare !"
}
```

on utilise le formateur intégré avec

```bash
sudo docker compose -f /opt/docker/caddy/compose.yml exec -w /etc/caddy caddy caddy fmt --overwrite
```

et on relance caddy

```bash
sudo docker compose -f /opt/docker/caddy/compose.yml exec -w /etc/caddy caddy caddy reload
```

Tester votre domaines avec `curl https://mondomaine.com` il doit renvoyer `Caddy fonctionne avec Cloudflare !`

### Connexion directe interdite

Vérifier que les requêtes directes ne passent pas (seule l'ip de CloudFlare est en liste blanche), mettre la vraie IP du VPS ci-dessous

```bash
curl -I http://192.0.2.1
curl -I https://192.0.2.1
```

### Bannir une ip

on teste fail2ban avec un ban manuel

```bash
sudo fail2ban-client set caddy-auth banip 1.2.3.4
```

L'IP doit apparaître ici

```bash
sudo fail2ban-client status caddy-auth
```

Attention, un ban manuel n'a pas de timer, l'ip restera en prison, et le pare-feu CloudFlare applique la règle immédiatement.

### Verifier le ban automatique des IP malveillante

On simuler une requête malveillante depuis le shell du VPS

```bash
echo '{"level":"info","ts":1782246668.0,"logger":"http.log.access.log0","msg":"handled request","request":{"remote_ip":"172.69.176.43","remote_port":"9513","client_ip":"99.99.99.99","proto":"HTTP/1.1","method":"GET","host":"rogerbytes.com","uri":"/wp-admin/","headers":{}},"status":403}' | sudo tee -a /opt/docker/caddy/logs/access.log
```

On la fait plein de fois et vite pour être sûr du ban, et on vérifie la cellule des prisoners de Jail2Ban.

```bash
sudo fail2ban-client status caddy-auth
```

Si on voit son ip `99.99.99.99` en bas comme ce qui suit, c'est bon !

```text
Status for the jail: caddy-auth
|- Filter
|  |- Currently failed: 2
|  |- Total failed:     40
|  `- File list:        /opt/docker/caddy/logs/access.log
`- Actions
   |- Currently banned: 1
   |- Total banned:     4
   `- Banned IP list:   99.99.99.99 1.2.3.4
```

### Vérifier que l'api CloudFlare fonctionne correctement

Maintenant que nous avons au moins deux IP bannie, on vérifie le bon fonctionnement de l'API CloudFlare utilisée par Fail2Ban

- On peut aller voir [le dashboard de CloudFlare](https://dash.cloudflare.com/) et dans le menu de gauche `Domaines/Vue d'ensemble` on clique sur le domaine concerné
- dans le menu de gauche `Sécurité/Règles de sécurité` et dans l'encart `Règles d’accès IP` on voit bien l'IP `99.99.99.99` et l'IP `1.2.3.4`

Pour infos, le warning à côté de `Règles de contrôle du volume de requêtes` c'est juste un popup pour inciter à prendre l'offre payante `Vous avez utilisé toutes les règles disponibles pour votre Offre gratuite. Effectuez une mise à niveau pour obtenir plus de règles afin de renforcer votre niveau de sécurité.`, il faut ignorer ce message, ça ne vaut rien.

### Lever un ban d'IP

On retire un ban

```bash
sudo fail2ban-client set caddy-auth unbanip 1.2.3.4
```

puis le second

```bash
sudo fail2ban-client set caddy-auth unbanip 99.99.99.99
```

Automatiquement les IP seront retirées de la prison du pare-feu CloudFlare.

### Connaître son IP

```bash
# IPV4
curl https://api.ipify.org

# IPV6
curl https://api6.ipify.org
```

### Retirer notre redirection de test

Nos tests étant finis, on retire notre redirection factice.

```bash
sudo nano /opt/docker/caddy/Caddyfile
```

A la fin du document, dans la partie `Redirection de domaines`, retirer cette redirection

```text
http://mondomaine.com, http://www.mondomaine.com {
        import fail2ban_logs
        respond "Caddy fonctionne avec Cloudflare !"
}
```

on utilise le formateur intégré avec

```bash
sudo docker compose -f /opt/docker/caddy/compose.yml exec -w /etc/caddy caddy caddy fmt --overwrite
```

et on relance caddy

```bash
sudo docker compose -f /opt/docker/caddy/compose.yml exec -w /etc/caddy caddy caddy reload
```

Tester une dernière fois votre domaine avec `curl https://mondomaine.com`. Le message de test ne doit plus apparaître.

Voilà, votre Caddy est officiellement prêt pour la production !
