# 12 - CloudFlared

Pour masquer totalement l'infrastructure sans modifier notre configuration web existante, nous allons mettre en place un **Cloudflare Tunnel (`cloudflared`)** dédié exclusivement aux flux non-HTTP.

Cette solution crée une connexion sortante sécurisée de nos serveurs vers le réseau de Cloudflare pour les protocoles spécifiques comme SSH et Mandos. Cela nous permet de fermer complètement ces ports entrants au niveau du pare-feu local (UFW), tout en conservant intacte notre configuration HTTP/HTTPS actuelle (filtrée par les IP proxy de Cloudflare).

Le filtrage des accès et la restriction par IP blanche pour l'administration et les serveurs clients sont alors centralisés et gérés directement en amont sur le dashboard Cloudflare Zero Trust.

## Installation de CloudFlared sur VPS

On se base sur [la documentation pour debian](https://pkg.cloudflare.com/index.html#debian-any)

```bash
# Add cloudflare gpg key
sudo mkdir -p --mode=0755 /usr/share/keyrings
curl -fsSL https://pkg.cloudflare.com/cloudflare-main.gpg | sudo tee /usr/share/keyrings/cloudflare-main.gpg >/dev/null

# Add this repo to your apt repositories
# Stable
echo 'deb [signed-by=/usr/share/keyrings/cloudflare-main.gpg] https://pkg.cloudflare.com/cloudflared any main' | sudo tee /etc/apt/sources.list.d/cloudflared.list

# install cloudflared
sudo nala update && sudo nala upgrade -y

sudo nala install -y cloudflared
```

## Lier le serveur au compte CloudFlare

Se connecter à son dashboard

```bash
cloudflared tunnel login
```

Ouvrir le lien dans le navigateur, et choisir le domaine à associer.

Les credentials sont dans `~/.cloudflared/cert.pem`.

## Création du tunnel sur le serveur

```bash
cloudflared tunnel create tunnel-prod
```

Il retourne l'ID

On récupère l'id suivant le `Created tunnel tunnel-prod with id`

On crée le fichier `~/.cloudflared/config.yml`

```bash
nano ~/.cloudflared/config.yml
```

et on lui met

```bash
tunnel: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
credentials-file: /home/paul/.cloudflared/xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx.json

ingress:
  - hostname: ssh.mondomaine.com
    service: ssh://localhost:22
  - service: http_status:404
```

On remplace ne le nom de domaine et le port par ce qu'il faut (pareil pour l'user), et pareil pour l'id (avec les xxxx)

Puis on crée l'entrée DNS automatiquement

```bash
cloudflared tunnel route dns tunnel-prod ssh.mondomaine.com
```

Puis on crée un service system

```bash
sudo cloudflared --config ~/.cloudflared/config.yml service install
```

Et on le lance

```bash
sudo systemctl start cloudflared
```

Voilà, le serveur est prêt (enfin il reste à fermer le port ssh dans UFW, mais on va d'abord tester le tunnel)

## Installed CloudFlared sur un ordinateur

Ici pour Ubuntu/LinuxMint

On identifie sa version de Ubuntu avec

```bash
cat /etc/os-release | grep UBUNTU_CODENAME
```

On se base dans notre exemple sur [la documentation pour u-noble](https://pkg.cloudflare.com/index.html#ubuntu-noble)

```bash
# Add cloudflare gpg key
sudo mkdir -p --mode=0755 /usr/share/keyrings
curl -fsSL https://pkg.cloudflare.com/cloudflare-main.gpg | sudo tee /usr/share/keyrings/cloudflare-main.gpg >/dev/null

# Add this repo to your apt repositories
# Stable
echo 'deb [signed-by=/usr/share/keyrings/cloudflare-main.gpg] https://pkg.cloudflare.com/cloudflared noble main' | sudo tee /etc/apt/sources.list.d/cloudflared.list

# install cloudflared
sudo nala update && sudo nala upgrade -y

sudo nala install -y cloudflared
```

On règle notre ssh (il prendra tous les sous domaine avec le *.mondomaine.com, pas besoin d'y retoucher si on ajoute d'autre sous domaine sur d'autres serveurs)

```bash
nano ~/.ssh/config
```

```bash
Host *.mondomaine.com
    ProxyCommand cloudflared access ssh --hostname %h
```

et on peut maintenant se connecter via

```bash
ssh paul@ssh.mondomaine.com
```

## On ferme le port SSH sur le serveur

```bash
sudo ufw delete allow 61869/tcp
```

## On installe CloudFlared sur le serveur Mandos

On se base sur [la documentation pour debian](https://pkg.cloudflare.com/index.html#debian-any)

```bash
# Add cloudflare gpg key
sudo mkdir -p --mode=0755 /usr/share/keyrings
curl -fsSL https://pkg.cloudflare.com/cloudflare-main.gpg | sudo tee /usr/share/keyrings/cloudflare-main.gpg >/dev/null

# Add this repo to your apt repositories
# Stable
echo 'deb [signed-by=/usr/share/keyrings/cloudflare-main.gpg] https://pkg.cloudflare.com/cloudflared any main' | sudo tee /etc/apt/sources.list.d/cloudflared.list

# install cloudflared
sudo nala update && sudo nala upgrade -y

sudo nala install -y cloudflared
```

## Lier le serveur Mandos au compte CloudFlare

Se connecter à son dashboard

```bash
cloudflared tunnel login
```

Ouvrir le lien dans le navigateur, et choisir le domaine à associer.

Les credentials sont dans `~/.cloudflared/cert.pem`.

## Création du tunnel sur le serveur Mandos

```bash
cloudflared tunnel create tunnel-mandos
```

Il retourne l'ID

On récupère l'id suivant le `Created tunnel tunnel-prod with id` et `3bc05ca7-0962-492f-ab30-4589e375a16b`

On crée le fichier `~/.cloudflared/config.yml`

```bash
nano ~/.cloudflared/config.yml
```

et on lui met

```bash
tunnel: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
credentials-file: /home/paul/.cloudflared/xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx.json

ingress:
  - hostname: mandos.mondomaine.com
    service: ssh://localhost:22
  - service: http_status:404
```

On remplace ne le nom de domaine et le port par ce qu'il faut (pareil pour l'user), et pareil pour l'id (avec les xxxx)

Puis on crée l'entrée DNS automatiquement

```bash
cloudflared tunnel route dns tunnel-mandos mandos.mondomaine.com
```

Puis on crée un service system

```bash
sudo cloudflared --config ~/.cloudflared/config.yml service install
```

Et on le lance

```bash
sudo systemctl start cloudflared
```

Voilà, le serveur  Mandos est prêt

## On ferme le port SSH sur le serveur Mandos

```bash
sudo ufw delete allow 53168/tcp
```

## Réglage du Check dans le serveur Mandos

```bash
sudo nano /etc/mandos/clients.conf
```

Et, pour notre serveur `ssh.mondomaine.com`, à la fin on remplace le checker par

```bash
checker = cloudflared access ssh --hostname ssh.mondomaine.com --timeout 5s
```

On relance Mandos avec

```bash
sudo systemctl restart mandos
```

Et on regarde

```bash
sudo mandos-ctl
```

Il est disabled, ce qui est normal, mais maintenant on le réactive (on prends le nom du serveur pour la commande suivante)

```bash
sudo mandos-ctl --enable vps-xxxxxxxx.xxx.xxx.xxx
```
