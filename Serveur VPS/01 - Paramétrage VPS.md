# 01 - Paramétrage VPS

Le VPS permet d'installer docker (son installation sera décrite dans une autre documentation) et d'y déployer des images et des piles de conteneurs.

Voici une [doc de OVH pour sécuriser le VPS](https://docs.ovhcloud.com/fr/guides/bare-metal-cloud/virtual-private-servers/secure-your-vps)

Et un [guide de démarrage VPS](https://docs.ovhcloud.com/fr/guides/bare-metal-cloud/virtual-private-servers/starting-with-a-vps)

Et plus sympa, un [guide de gestion d'utilisateurs](https://docs.ovhcloud.com/fr/guides/bare-metal-cloud/dedicated-servers/changing-root-password-linux-ds)

Pour ce qui est du choix de l'OS, j'utilise Debian. Le générateur du mot de passe est envoyé par mail (et ré-envoyé à chaque reset si on n'ajoute pas une clef SSS lors du reset).

La partie [Network Firewall d'OVH](https://docs.ovhcloud.com/fr/guides/bare-metal-cloud/dedicated-servers/firewall-network) n'est pas encore abordée, c'est une étape à faire après déploiement.

- A plusieurs moments le port utilisé pour SSH est `49152`, prenez garde à bien le changer par le votre, en passant `49152` n'est pas un bon port, il est uniquement là à titre d'exemple.
- A plusieurs moments l'ipv4 utilisé pour SSH est `192.0.2.1`, prenez garde à bien le changer par le votre, en passant `192.0.2.1` n'est pas une ip valide, elle est uniquement là à titre d'exemple.

## Première connexion

<details><summary class="button">🔍 Spoiler</summary><div class="spoiler">

Pour se connecter sur ma machine vierge, on récupère l'`IPv4` de la machine sur son tableau de bord OVH dans `Bare Metal Cloud/Serveurs Privés Virtuels` et on clique sur le nom du VPS, l'`IPv4` se trouve dans l'encadré `IP` sur la droite.

Le générateur du mot de passe est envoyé par mail, il faut utiliser le "secret" comme mdp de première connexion, ici on se connecte à l'user `debian` (par défaut chez OVH).

```bash
ssh debian@192.0.2.1
```

`Are you sure you want to continue connecting (yes/no/[fingerprint])?` confirmer avec `yes`

Entrer le "secret" généré via le mail pour se connecter. Suivre ce qui est demandé pour changer le mdp, mettre son mot de passe habituel (pas besoin d'entropie, on retirera la connexion par mdp). Quand le mdp est changé, on est déconnecté.

## Prérequis

On se connecte via

```bash
ssh debian@192.0.2.1
```

On donne le nouveau mdp que l'on vient de régler pour se connecter.

On va installer `nala` (surcouche visuelle d'apt), `kitty-terminfo` (support pour mon émulateur de terminal) et `fastfetch` (affiche les infos de la machine)

```bash
sudo apt install -y nala kitty-terminfo fastfetch
```

</div></details>

## Mise à jour du système

<details><summary class="button">🔍 Spoiler</summary><div class="spoiler">

```bash
sudo nala update && sudo nala upgrade -y
```

Un prompt `Configuring openssh-server`, choisir `keep the local version currently installed` (il faut garder le réglage, il permet de rester connecté).

On refait un update

```bash
sudo nala update
```

il dit `1 packages can be upgraded. Run 'nala list --upgradable' to see them.`, on va faire les upgrades.

```bash
nala list --upgradable
```

Il explique que `linux-image-amd64 6.12.86-1` (c'est le kernel) peut être mis à jour vers `linux-image-amd64 6.12.90-2`

On lance l'upgrade en précisant simplement le nom du paquets

```bash
sudo nala install -y linux-image-amd64
```

Vu que c'est le kernel (le noyau), il demande `Notice: The following packages require a reboot.`, ce que l'on fait.

```bash
sudo reboot
```

On est déconnecté, c'est normal, ne pas se reconnecter, on va d'abord gérer les clefs SSH sur notre machine hôte (locale).

</div></details>

## Gestion de clefs SSH

<details><summary class="button">🔍 Spoiler</summary><div class="spoiler">

### Créer une clef SSH de récupération

On crée une clef de récupération, c'est une clef que l'on conserve précieusement, ce sera notre accès pour ajouter des clefs locales sur d'autres machines.

Dans l'exemple, on crée le repertoire `~/Documents/Sécurité/Clefs/`

```bash
mkdir -p ~/Documents/Sécurité/Clefs/
```

On crée la clef

```bash
ssh-keygen -t ed25519 -f ~/Documents/Sécurité/Clefs/la-recovery-key -C "Clef de récupération VPS OVH RogerBytes"
```

Attention, mettez un mot de passe avec une très forte entropie (40 chars par exemple) et enregistre le précieusement. Étant une clef de récupération, il faut en protéger l'accès.

On déplace les deux clefs dans `~/Documents/Sécurité/Clefs` (ou ailleurs), il faudra absolument garder ces clefs.

On l'ajoute la clef publique de récupération au VPS avec

```bash
ssh-copy-id -i ~/Documents/Sécurité/Clefs/la-recovery-key.pub debian@192.0.2.1
```

Et on tape le mot de passe de l'user `debian`

Il faut absolument conserver la clef de récupération !

### Générer une clef locale

Si l'on a pas déjà une clef locale, on en crée une avec

```bash
ssh-keygen -t ed25519 -C "your_email@example.com your_machine"
```

On l'ajoute la clef publique locale (quelle soit neuve ou pas), on prend toute suite la bonne habitude de l'ajouter via la clef de récupération

```bash
ssh -i ~/Documents/Sécurité/Clefs/la-recovery-key debian@192.0.2.1 "cat >> ~/.ssh/authorized_keys" < ~/.ssh/id_ed25519.pub
```

Donnez le mot de passe de votre clef de récupération et ça y est, votre clef locale est ajoutée !

</div></details>

## Changer le port par défaut de SSH

<details><summary class="button">🔍 Spoiler</summary><div class="spoiler">

On se connecte maintenant au serveur

```bash
ssh debian@192.0.2.1
```

Les tentatives de hack visent le port SSH par défaut, c'est à dire le port 22. Donc on le remplace.

On génère d'abord un numéro de port aléatoirement (en piochant dans une plage sûre entre 49152 et 65535).

```bash
RANDOM_PORT=$((RANDOM % (65535 - 49152 + 1) + 49152))
echo "Port SSH 100% tranquille : $RANDOM_PORT"
```

Gardez ce port de côté et servez vous en pour le reste de la documentation, ici j'utilise le port `49152` dans cette documentation (vous devez le remplacer par le votre).

Puis on utilise

```bash
sudo nano /etc/ssh/sshd_config
```

On remplace

```bash
#Port 22
```

par

```bash
Port 49152
```

Sauvegardez, puis on va mettre le protocole à jour avec

```bash
sudo systemctl restart sshd
```

On vérifie le changement de port avec

```bash
sudo ss -tlnp | grep ssh
```

On ne se déconnecte pas de la session, on teste dans un autre shell de se connecter, en précisant le port.

```bash
ssh -p 49152 debian@192.0.2.1
```

Voilà, on va fini de régler le port !

Pour Ubuntu 24.04 et ultérieures (**pas Debian, attention**), il faut voir [cette doc](https://docs.ovhcloud.com/fr/guides/bare-metal-cloud/virtual-private-servers/secure-your-vps#modifier-le-port-d%C3%A9coute-ssh-par-d%C3%A9faut), il y a eu des changements dans le fonctionnement de SSH.

</div></details>

## Créer un utilisateur non privilégié

<details><summary class="button">🔍 Spoiler</summary><div class="spoiler">

On ne va plus utiliser l'utilisateur `debian` (qui les privilèges `root`) pour des raisons de sécurité, on va créer un utilisateur principal.

```bash
sudo adduser username
```

-> remplacer `username` par le nom d'user désiré, et entrez votre mdp, le entrées `full name`, `room number` etc peuvent rester vides (çà la fin on valide avec `Y`), dans la suite de la doc, l'username donné est `paul`.

et on lui donne l'accès sudo, étant le vrai compte du VPS

```bash
sudo usermod -aG sudo username
```

Maintenant l'on ne se connecte plus avec l'user `debian`, mais avec cet utilisateur fraîchement créé.

```bash
ssh -p VOTRE_RANDOM_PORT NOUVEL_USER@192.0.2.1
```

Gardez précieusement votre commande de connexion, c'est celle-ci que vous utiliserez.

Pour les comptes non admin, ne donnez pas d'accès sudo !

</div></details>

## Ajouter la clef de récupération au nouveau user

<details><summary class="button">🔍 Spoiler</summary><div class="spoiler">

Modifiez les variables au besoin, ce script permet d'ajouter la clef de récupération au nouvel utilisateur (il ne faudra jamais la retirer sous peine de perdre tout accès), la connexion par mot de passe étant à bannir.

```bash
username=paul
vps_user=debian
public_key_path=~/Documents/Sécurité/Clefs/la-recovery-key.pub
recovery_path=~/Documents/Sécurité/Clefs/la-recovery-key
port=49152
ip=192.0.2.1

public_key=$(cat $public_key_path)

ssh -i $recovery_path -p $port $vps_user@$ip "sudo mkdir -p /home/$username/.ssh && echo '$public_key' | sudo tee -a /home/$username/.ssh/authorized_keys && sudo chown -R $username:$username /home/$username/.ssh && sudo chmod 700 /home/$username/.ssh && sudo chmod 600 /home/$username/.ssh/authorized_keys"
```

`$public_key_path` et `$recovery_path` sont les chemins de la clef publique et de la clef de récupération, il faut faut aussi ajouter la clé de récupération à l'utilisateur principal que l'on vient de créer (l'user debian sera verrouillé par la suite).

## Script de sysadmin pour ajouter des clefs publiques

Voici l'outil final d'admin pour l'user, ici c'est pour un user `robert`, mais on peut s'en servir pour ajouter la clef locale au compte que l'on vient de créer (en remplaçant `robert` par `paul` et en changeant le chemin de la clef publique par `~/.ssh/id_ed25519.pub`).

```bash
username=robert
vps_user=paul
public_key_path=~/id_ed25519.pub
recovery_path=~/Documents/Sécurité/Clefs/la-recovery-key
port=49152
ip=192.0.2.1

public_key=$(cat $public_key_path)

ssh -t -i $recovery_path -p $port $vps_user@$ip "sudo mkdir -p /home/$username/.ssh && echo '$public_key' | sudo tee -a /home/$username/.ssh/authorized_keys && sudo chown -R $username:$username /home/$username/.ssh && sudo chmod 700 /home/$username/.ssh && sudo chmod 600 /home/$username/.ssh/authorized_keys"
```

Il faut se connecter sur l'user et faire

```bash
cat ~/.ssh/authorized_keys
```

Pour être sûr qu'il a bien la clef de récupération dans ses connexions SSH.

</div></details>

## Le Pare-feu

<details><summary class="button">🔍 Spoiler</summary><div class="spoiler">

Les ports étant ouverts par défaut sur toute machines linux, on va les régler dans le pare-feu `iptables`, pour se simplifier la vie on installe UFW (qui va créer les règles iptables pour nous)

- Pour information, la règle de sécurité est de laisser le flux sortant ouverts, et de verrouiller par défaut le flux entrant (en laissant ouverts seulement les port SSH, http et https).
- C'est `Caddy` qui gérera le flux entrant en réceptionnant les requêtes du web pour les rediriger vers les conteneurs Docker.

```bash
sudo nala install -y ufw
```

On vérifie son état

```bash
sudo ufw status
```

Il doit normalement retourner `Inactive` (c'est normal à ce stade)

Maintenant, on autorise par défaut tout ce qui souhaite sortir, et on bloque par défaut tout ce qui veut entrer

```bash
sudo ufw default deny incoming
sudo ufw default allow outgoing
```

ET ATTENTION A FAIRE CE QUI SUIT DANS LA FOULÉE (sinon on ne pourra plus se connecter en SSH)

Modifiez la commande suivante pour y mettre votre port **ATTENTION A BIEN FAIRE LA MODIFICATION DU PORT**

```bash
sudo ufw allow 49152/tcp
```

On ajoute aussi le localhost (totalement indispensable, tout le fonctionnement interne du système repose sur les communications internes du localhost)

```bash
sudo ufw allow in on lo
```

Maintenant que le port SSH est en liste blanche, l'on peut activer le UFW.

```bash
sudo ufw enable
```

Valider le message d'alerte (le `Command may disrupt existing ssh connections. Proceed with operation (y|n)?` est bénin), on a bien ajouté notre port SSH.

Puis on vérifie les règles de UFW

```bash
sudo ufw status verbose
```

Il retourne

```bash
Status: active
Logging: on (low)
Default: deny (incoming), allow (outgoing), disabled (routed)
New profiles: skip

To                         Action      From
--                         ------      ----
49152/tcp                  ALLOW IN    Anywhere
Anywhere on lo             ALLOW IN    Anywhere
49152/tcp (v6)             ALLOW IN    Anywhere (v6)
Anywhere (v6) on lo        ALLOW IN    Anywhere (v6)
```

### Ajouter les ports http et https pour le Caddy (le Reverse Proxy)

- Caddy va recevoir le trafic venant d'Internet sur les ports http (80) et https (443) de la machine, puis redirige vers les conteneurs Docker, y ajoute nom de domaine et certificat TLS.
- Vu que le reverse proxy n'utilise pas `ports:` dans son `compose.yml` (il utilise `network_mode: "host"`), Docker ne gère pas les ports avec `iptables` mais redirige sur les vrais ports de la machine.
- Cette configuration en mode `host` permettra également à Fail2Ban de lire les logs de Caddy pour bloquer directement les attaquants au niveau d'UFW.
- Même si Caddy (notre futur reverse proxy) sera installé via Docker, il se comporte comme un logiciel classique du serveur au niveau du pare-feu, il faut donc absolument activer ces ports.

```bash
sudo ufw allow http
sudo ufw allow https
sudo ufw reload
```

On limite ainsi grandement la surface d'attaque. Il n'y a seulement que 3 ports ouverts depuis l'extérieur (1 pour se connecter en SSH, et 2 pour https et http).

</div></details>

## Fail2Ban

<details><summary class="button">🔍 Spoiler</summary><div class="spoiler">

Fail2Ban est un outil très pratique qui va automatiquement bannir les IP échouant dans leurs tentatives d'authentification au serveur. Il protège le serveur des attaques de type Brute Force ou Denial of Service (DoS).

Pour les attaques Distributed Denial of Service (DDoS), OVH intègre déjà VAC, un outil de protection Anti-DDoS activé par défaut. Le VAC filtre le trafic en amont et bloque les requêtes malveillantes simultanées (en identifiant les schémas et comportements suspects du trafic) avant qu'elles n'atteignent le VPS.

- Il lit les logs en continu, il prends note de toutes les tentatives de connexion
- Compte les tentatives par IP et les flag
- Il envoie à UFW une requête pour chaque suspect, afin de bloquer son IP avec un timer

On l'installe avec

```bash
sudo nala install -y fail2ban
```

Comme recommandé, on crée un fichier de configuration local de vos services en copiant le fichier "jail".

```bash
sudo cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
```

On va régler notre SSH personnalisé dedans

```bash
sudo nano /etc/fail2ban/jail.local
```

Pour information, Les paramètres [DEFAULT] sont les réglages dont héritent tous les services.

Il faut aller configurer la section [sshd] (c'est le premier qui apparaît en vert)'.

- Pour rechercher `sshd` faire `CTRL + W`, et pour aller au prochain résultat faire `Alt + W`
- Voici la section par défaut

```conf
[sshd]

# To use more aggressive sshd modes set filter parameter "mode" in jail.local:
# normal (default), ddos, extra or aggressive (combines all).
# See "tests/files/logs/sshd" or "filter.d/sshd.conf" for usage example and details.
#mode   = normal
port    = ssh
logpath = %(sshd_log)s
backend = %(sshd_backend)s
```

Et voici à quoi ça doit ressembler à la fin, dans le port, on met le nouveau port SSH `49152`, changez le port pour le votre !

```bash
[sshd]

# To use more aggressive sshd modes set filter parameter "mode" in jail.local:
# normal (default), ddos, extra or aggressive (combines all).
# See "tests/files/logs/sshd" or "filter.d/sshd.conf" for usage example and details.
mode     = aggressive
enabled  = true
port     = 49152
filter   = sshd
logpath  = %(sshd_log)s
backend  = systemd
findtime = 5m
maxretry = 3
bantime  = 1h
```

- Le `enabled=true` permet d'écraser l'héritage de `[DEFAULT]`, permettant ainsi d'activer le service.
- Le mode passe en `aggressive`, en gros Fail2Ban va lui même appliquer des règles UFW sévères aux IP qui tentent de trop nombreuses connexions
- `systemd` est le gestionnaire central du système sur debian, c'est lui qui fournit les logs par exemple
- `maxretry` c'est le nombre de tentatives et `bantime` c'est le timeout
- `findtime` c'est pour la période (ici c'est 3 essaie dans une durée de 5mn)

On enregistre le fichier, puis on active et lance le service

```bash
sudo systemctl enable --now fail2ban
```

Puis on vérifie que le réglage est pris en compte

```bash
sudo fail2ban-client status sshd
```

Il retourne

```bash
$ sudo fail2ban-client status sshd
Status for the jail: sshd
|- Filter
|  |- Currently failed: 0
|  |- Total failed: 0
|  `- Journal matches: _SYSTEMD_UNIT=ssh.service + _COMM=sshd
`- Actions
   |- Currently banned: 0
   |- Total banned: 0
   `- Banned IP list:
```

La prison `Status for the jail: sshd` est bien existante, c'est parfait.

On test un ping

et aussi via un test de ping

```bash
sudo fail2ban-client ping
```

Le serveur doit répondre `pong`

- Fail2Ban a ici pour mission de protéger l'accès SSH de la machine, ensuite on le réglera également pour suivre les logs de Caddy (qui redirigera les connexions entrantes vers les conteneurs docker).
- L'usage du VPS est dédié à Docker, une image de `Caddy` sera configurée pour gérer les accès et le trafic Web.

</div></details>

## Retirer une clef SSH du serveur

<details><summary class="button">🔍 Spoiler</summary><div class="spoiler">

ATTENTION : veillez à ne JAMAIS retirer la CLEF de RECUPERATION, sous peine de perdre tout accès à la machine et de devoir reset le VPS.

On liste les clefs sur la machine

```bash
cat ~/.ssh/authorized_keys
```

Et on retire via l'id avec

```bash
grep -v 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx/xxxxx' ~/.ssh/authorized_keys > ~/.ssh/tmp && mv ~/.ssh/tmp ~/.ssh/authorized_keys
```

</div></details>

## Retirer la connexion par mot de passe

<details><summary class="button">🔍 Spoiler</summary><div class="spoiler">

On vérifie la présence de "passwordauthentication yes" dans "/etc/ssh/sshd_config.d"

```bash
sudo grep -R --line-number "PasswordAuthentication" /etc/ssh/sshd_config.d/
```

S'il retourne "passwordauthentication yes" il faut éditer le fichier retourné ("50-cloud-init.conf" dans mon cas) avec nano

```bash
sudo nano /etc/ssh/sshd_config.d/50-cloud-init.conf
```

Remplacer `PasswordAuthentication yes` par `PasswordAuthentication no`

On vérifie que tout est ok avec

```bash
sudo sshd -T | grep -E "passwordauthentication"
```

S'il retourne "passwordauthentication no", c'est parfait, l'accès par MDP est fermé !

On va relancer le service SSH du VPS avec

```bash
sudo systemctl restart ssh
```

A partir de maintenant, on ne peut plus se connecter qu'avec une clef SSH, ce qui est la meilleure pratique pour protéger les connexions SSH sur mon VPS.

</div></details>

## Verrouillage de l'user initial `debian`

<details><summary class="button">🔍 Spoiler</summary><div class="spoiler">

On empêche la connexion et on enlève les droits sudo à `debian`, pour des raisons de paramétrages internes, on ne supprime jamais l'utilisateur initial d'un serveur, on le verrouille, et par acquis de conscience, on révoque les clefs publiques qu'il a enregistré.

On cherche le fichier qui lui donne un accès `NO_PASSWORD`

```bash
sudo ls /etc/sudoers.d/
```

Il retourne

```bash
90-cloud-init-users  README
```

On peut faire un `sudo cat /etc/sudoers.d/90-cloud-init-users` si on veut (par acquis de conscience), il y aura `debian ALL=(ALL) NOPASSWD:ALL`.

On supprime donc le fichier

```bash
sudo rm /etc/sudoers.d/90-cloud-init-users
```

Maintenant on lui bloque la connexion et on lui retire sa connexion SSH

```bash
sudo usermod -L -s /usr/sbin/nologin debian
sudo truncate -s 0 /home/debian/.ssh/authorized_keys
```

Et on remplace son mdp

```bash
sudo passwd debian
```

On met une énorme entropie et on jette le mdp, on ne veut pas qu'on puisse s'y connecter.

Voilà, l'utilisateur `debian` est proprement verrouillé.

</div></details>

## Verrouillage de la connexion SSH de root

<details><summary class="button">🔍 Spoiler</summary><div class="spoiler">

```bash
sudo nano /etc/ssh/sshd_config
```

Avec `CTRL + W` on cherche `PermitRootLogin` on dé-commente/transforme en `PermitRootLogin no`

On vérifie que tout est bon avec

```bash
sudo sshd -T | grep -i "permitrootlogin"
```

S'il retourne `permitrootlogin no`, tout est bon.

On vérifie s'il se trouve ailleurs

```bash
sudo grep -R -i "PermitRootLogin" /etc/ssh/sshd_config.d/
```

S'il ne retourne rien, c'est impeccable, on applique les changements

```bash
sudo systemctl restart sshd
```

</div></details>

## Gestion des logs (Logrotate)

<details><summary class="button">🔍 Spoiler</summary><div class="spoiler">

Le pare-feu (UFW) et Fail2Ban génèrent en continu des lignes de texte (logs) pour surveiller le serveur. Sans nettoyage, ces fichiers finissent par saturer l'espace disque du VPS, ce qui peut faire planter la machine. On utilise `logrotate` pour archiver, compresser et supprimer automatiquement les vieux logs.

On l'installe

```bash
sudo nala install -y logrotate
```

On vérifie que le planificateur (timer) est bien actif et qu'il réveillera logrotate toutes les nuits pour faire le ménage :

```bash
sudo systemctl status logrotate.timer
```

Il doit retourner `active (waiting)`. Rien de plus à faire, le système gère l'espace disque tout seul à partir de maintenant !

</div></details>

## Monitoring basique BTOP

<details><summary class="button">🔍 Spoiler</summary><div class="spoiler">

On l'installe avec

```bash
sudo nala install -y btop
```

C'est un outil léger et moderne pour monitorer le serveur, il suffit de taper `btop` pour le lancer.

</div></details>

## Réglage du shell

<details><summary class="button">🔍 Spoiler</summary><div class="spoiler">

Afin que ce soit plus confortable, on va customiser le shell du VPS

```bash
sudo nala install -y zsh autojump zsh-syntax-highlighting zsh-autosuggestions
curl -sS https://starship.rs/install.sh | sudo sh -s -- -y
touch ~/.zshrc
echo 'eval "$(starship init zsh)"' >> ~/.zshrc
echo ". /usr/share/autojump/autojump.sh" >> ~/.zshrc
echo "source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" >> ~/.zshrc
echo "source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh" >> ~/.zshrc
mkdir -p ~/.config
starship preset pastel-powerline -o ~/.config/starship.toml
sudo usermod -s "$(command -v zsh)" "$USER"
```

On sort

```bash
exit
```

On se reconnecte, normalement tout devrait être configuré.

</div></details>

## Multiplexeur Zellij

<details><summary class="button">🔍 Spoiler</summary><div class="spoiler">

Zellij est un multiplexeur de terminal. Il permet de séparer son écran en plusieurs terminaux, mais surtout, il garde ses sessions actives en arrière-plan. Si la connexion internet coupe au milieu d'une grosse commande Docker, la session reste vivante sur le VPS. Il suffit de se reconnecter et relancer la session du multiplexeur.

En gros, au lieu d'ouvrir plusieurs terminaux locaux (comme le fait VS Code), Zellij gère ces terminaux directement sur le VPS. Les sessions y sont persistées et restent actives indéfiniment (tant que le VPS ne redémarre pas), même si on ferme son PC (en s'y connectant via `zellij attach`).

Installation, depuis [le site officiel](https://zellij.dev)

```bash
curl -L "https://github.com/zellij-org/zellij/releases/latest/download/zellij-x86_64-unknown-linux-musl.tar.gz" | tar -xzvf - && sudo mv zellij /usr/local/bin/
```

</div></details>

## Quelques commandes basiques

<details><summary class="button">🔍 Spoiler</summary><div class="spoiler">

Juste quelque commandes de bases, voir doc dédiée, ce n'est pas le sujet ici.

```bash
# Pour s'attacher à une session existante (ou la créer si elle n'existe pas)
zellij attach -c ma-session

# Raccourci pour sortir en tuant la session (elle ne reste pas en arrière-plan)
# Faire Ctrl + q

# Raccourci pour sortir SANS tuer la session (elle reste en arrière-plan)
# Faire Ctrl + o puis la touche d

# Pour lister les sessions actives
zellij list-sessions

# Pour détruire une session spécifique à distance
zellij kill-session ma-session

# Pour détruire TOUTES les sessions en arrière-plan
zellij kill-all-sessions
```

</div></details>

## Mises à jour de sécurité auto unattended-upgrades

<details><summary class="button">🔍 Spoiler</summary><div class="spoiler">

C'est déjà installé par défaut (paquets `unattended-upgrades` et `apt-listchanges`)

et on l'active

```bash
sudo dpkg-reconfigure -plow unattended-upgrades
```

Il retourne `Automatically download and install stable updates`, choisir `Yes`

### Configuration

```bash
sudo nano /etc/apt/apt.conf.d/50unattended-upgrades
```

On peut faire une recherche avec `Ctrl + W` pour dé-commenter/modifier ces lignes comme ce qui suit :

```text
Unattended-Upgrade::Remove-Unused-Dependencies "true";
Unattended-Upgrade::Automatic-Reboot "false";
```

On a activé et configuré les **mises à jour de sécurité automatiques** pour que le VPS se protège tout seul des failles (en installant les màj) en arrière-plan, tout en nettoyant ses fichiers inutiles et en lui interdisant de redémarrer sans ton autorisation.

On vérifie que tout est bon

```bash
sudo systemctl status unattended-upgrades
```

Si on voit `Active: active (running)`, alors tout est bon.

### Quand reboot ?

Pour vérifier si un reboot est requis, il faut taper la commande

```bash
ls -l /var/run/reboot-required
```

S'il retourne

```bash
ls: cannot access '/var/run/reboot-required': No such file or directory
```

C'est qu'aucun reboot n'est requis.

</div></details>

## Le reset de mon VPS

<details><summary class="button">🔍 Spoiler</summary><div class="spoiler">

ATTENTION, RESET LE VPS FAIT TOUT PERDRE CE QU'IL CONTIENT !

- On se [connecte à son compte OVH](https://auth.eu.ovhcloud.com/signin/)
- On va sur `Bare Metal Cloud/Serveurs Privés Virtuels`
- On clique sur le VPS en question
- Dans l'encart `Votre VPS` on clique sur le bouton rond `...` sur la ligne `OS / Distribution` et `Réinstaller mon système`
- Une fois l'OS choisi et le reset fini (5 secondes), OVH renvoie un mail avec le mot de passe

Attention à virer le host (sinon votre système va bugger lors de la connexion à la machine remise à zéro)

```bash
ssh-keygen -f $HOME/.ssh/known_hosts -R 192.0.2.1
```

</div></details>

## Auteur

[<img src="https://github.com/RogerBytes.png" width="40" height="40" style="border-radius:50%;" alt="RogerBytes' avatar">](https://github.com/RogerBytes)  
[**RogerBytes (Harry Richmond)**](https://github.com/RogerBytes)

<span hidden>
<details><summary></summary>
<style>.spoiler{border-left:4px solid #1abc9c;border-bottom-left-radius:3px;padding-left:10px;padding-top:15px;margin-top:-10px;margin-bottom:15px}.button{cursor:pointer;padding:5px 10px;background-color:#3498db;color:white;border-radius:3px;margin-bottom:5px;display:inline-block;transition:background-color 0.2s}.button:hover{background-color:#217dbb}details[open] .button{background-color:#1abc9c}</style>
</details></span>

<p align="right"><a href="#">🔝 Retour en haut</a></p>
