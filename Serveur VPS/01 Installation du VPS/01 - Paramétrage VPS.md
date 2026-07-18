# 01 - Paramétrage VPS

Le VPS permet d'installer docker (son installation sera décrite dans une autre documentation) et d'y déployer des images et des piles de conteneurs.

Voici une [doc de OVH pour sécuriser le VPS](https://docs.ovhcloud.com/fr/guides/bare-metal-cloud/virtual-private-servers/secure-your-vps)

Et un [guide de démarrage VPS](https://docs.ovhcloud.com/fr/guides/bare-metal-cloud/virtual-private-servers/starting-with-a-vps)

Et plus sympa, un [guide de gestion d'utilisateurs](https://docs.ovhcloud.com/fr/guides/bare-metal-cloud/dedicated-servers/changing-root-password-linux-ds)

Pour ce qui est du choix de l'OS, j'utilise Debian. Le générateur du mot de passe est envoyé par mail (et ré-envoyé à chaque reset si on n'ajoute pas une clef SSH lors du reset).

La partie [Network Firewall d'OVH](https://docs.ovhcloud.com/fr/guides/bare-metal-cloud/dedicated-servers/firewall-network) n'est pas encore abordée, c'est une étape à faire après déploiement.

- A plusieurs moments le port utilisé pour SSH est `49152`, prenez garde à bien le changer par le votre, en passant `49152` n'est pas un bon port, il est uniquement là à titre d'exemple.
- A plusieurs moments l'ipv4 utilisé pour SSH est `192.0.2.1`, prenez garde à bien le changer par le votre, en passant `192.0.2.1` n'est pas une ip valide, elle est uniquement là à titre d'exemple.

Dans cette documentation, le principe du moindre privilège est rigoureusement appliqué.

## Si reset

```bash
ssh-keygen -f $HOME/.ssh/known_hosts -R 192.0.2.1
```

## Première connexion

<details><summary class="button">🔍 Spoiler</summary><div class="spoiler">

Avant tout, privilégiez l'ajout d'une clef SSH lors de du déploiement du système d'exploitation.

Pour se connecter sur ma machine vierge, on récupère l'`IPv4` de la machine sur son tableau de bord OVH dans `Bare Metal Cloud/Serveurs Privés Virtuels` et on clique sur le nom du VPS, l'`IPv4` se trouve dans l'encadré `IP` sur la droite.

Le générateur du mot de passe est envoyé par mail (privilégiez la clef SSH), il faut utiliser le "secret" comme mdp de première connexion, ici on se connecte à l'user `debian` (par défaut chez OVH).

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

Et on met la bonne timezone

```bash
sudo timedatectl set-timezone Europe/Paris
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

On lance l'upgrade en précisant simplement le nom du paquets, à faire dans tous les cas.

```bash
sudo nala install -y linux-image-amd64
```

Vu que c'est le kernel (le noyau), il demande `Notice: The following packages require a reboot.`, ce que l'on fait.

```bash
sudo reboot
```

On est déconnecté, c'est normal, ne pas se reconnecter, on va d'abord gérer les clefs SSH sur notre machine hôte (locale).

</div></details>

## RKHunter

<details><summary class="button">🔍 Spoiler</summary><div class="spoiler">

RKHunter (ou RootKit Hunter) va détecter des backdoors, des rootkits et autre menaces pour le système. Infos depuis [ce site](https://homepages.lcc-toulouse.fr/colombet/rkhunter-detection-de-rootkit-sur-linux-debian/)

Notre installation de debian étant vierge, c'est maintenant que l'on installe le détecteur de rootkit.

### Installation

On l'installe (on privilégie les paquets officiels de la Distribution, le paquet est préconfiguré pour le système)

```bash
sudo apt install -y rkhunter mailutils msmtp msmtp-mta
```

Si demandé, activer AppArmor

### Configurer mailutils pour permettre l'envoi de mail depuis la machine

```bash
sudo nano /etc/msmtprc
```

```conf
# Configuration globale
defaults
auth             on
tls              on
tls_starttls     on
tls_trust_file   /etc/ssl/certs/ca-certificates.crt
# logfile          /var/log/msmtp/msmtp.log

# Ton compte d'envoi
account          default
host             smtp.ton-fournisseur.com
port             587
from             ton-adresse-d-envoi@domaine.com
user             ton-adresse-d-envoi@domaine.com
password         ton_mot_de_passe_de-mail
```

Pour `host` on met l'adresse de son serveur mxroute.com, `from` et `user` on met son adresse dédié, et pour `password` on met le mdp du mail

On change les droits d'accès pour protéger le fichier

```bash
sudo chmod 600 /etc/msmtprc
```

On paramètre `Maiutils`

```bash
sudo nano /etc/mail.rc
```

On ajoute à la fin

```bash
set sendmail="/usr/bin/msmtp -t"
```

et on test mailtutils

```bash
echo "Mailing système prêt !" | sudo mail -s "Le mailing système est actif" mon-adresse@mondomaine.com
```

Si erreur, modifier `sudo nano /etc/mail.rc` pour retirer le `-t`, ça dépends de la version du paquet installé, puis retenter.

### Configuration initiale

On modifie `/etc/default/rkhunter` (indispensable pour les vérifications automatisées la nuit)

```bash
sudo rm -f /etc/default/rkhunter
sudo nano /etc/default/rkhunter
```

Collez

```conf
CRON_DAILY_RUN="yes"
CRON_DB_UPDATE="yes"
DB_UPDATE_EMAIL="false"
REPORT_EMAIL="root"
APT_AUTOGEN="yes"
NICE="0"
RUN_CHECK_ON_BATTERY="true"
```

On enregistre et on ferme nano.

Maintenant on édite `/etc/rkhunter.conf` (indispensable pour activer les mises à jour de RKHunter)

```bash
sudo nano /etc/rkhunter.conf
```

On va à la fin du fichier (`ALT + /`, en passant le `M` signifie `ALT` et `^` signifie `CTRL`) et on colle

```conf
# Activer les mises à jour
UPDATE_MIRRORS=1
MIRRORS_MODE=0
WEB_CMD=""
MAIL-ON-WARNING="moncompte@mondomaine.com"

# Autoriser les fichiers cachés créés par le système et systemd
# ALLOWHIDDENFILE=/etc/.resolv.conf.systemd-resolved.bak
# ALLOWHIDDENFILE=/etc/.updated
```

**ATTENTION :** on fait aussi la recherche `CTRL + W` pour trouver `MAIL-ON-WARNING=root` et dé-commente et on y met son mail (on vérifie `MAIL-ON-WARNING_LEVEL=2` est bien présent)

On enregistre et on ferme nano.

On applique les changements en lançant un indexation avec

```bash
sudo rkhunter --propupd
```

### Mise à jour de RKHunter

Maintenant que nos réglages initiaux sont faits, on lance la mise à jour

```bash
sudo rkhunter --update
```

### Premier scan

On lance le premier scan avec

```bash
sudo rkhunter --check --sk
```

### Vérifier les warnings de RKHunter

Les `Skipped` en jaune n'ont aucune importance, maintenant ou va étudier les logs pour voir quels sont les `Warnings`

```bash
sudo grep -i "warning" /var/log/rkhunter.log
```

```text
[11:00:35] Info: Emailing warnings to 'moncompte@mondomaine.com' using command '/usr/bin/mail -s "[rkhunter] Warnings found for ${HOST_NAME}"'
[11:00:36] Info: Using syslog for some logging - facility/priority level is 'authpriv.warning'.
[11:02:36]   Checking if SSH root access is allowed          [ Warning ]
[11:02:36] Warning: The SSH configuration option 'PermitRootLogin' has not been set.
[11:02:39]   Checking for hidden files and directories       [ Warning ]
[11:02:39] Warning: Hidden file found: /etc/.resolv.conf.systemd-resolved.bak: ASCII text
[11:02:39] Warning: Hidden file found: /etc/.updated: ASCII text
```

Les deux première sont des information confirmant que c'est bien réglé.

Le `Warning` pour `PermitRootLogin` est à ignorer, on fera ça dans [Verrouillage de la connexion SSH de root](#verrouillage-de-la-connexion-ssh-de-root)

Et la liste des fichiers cachés

- `/etc/.resolv.conf.systemd-resolved.bak`
- `/etc/.updated`

Maintenant on édite `/etc/rkhunter.conf`, on va autoriser ces deux fichiers cachés

```bash
sudo nano /etc/rkhunter.conf
```

On va à la fin du fichier (`ALT + /`, en passant le `M` signifie `ALT` et `^` signifie `CTRL`) et on colle

```conf
# Autoriser les fichiers cachés créés par le système et systemd
ALLOWHIDDENFILE=/etc/.resolv.conf.systemd-resolved.bak
ALLOWHIDDENFILE=/etc/.updated
```

On enregistre et on ferme nano.

On ré-indexe le système

```bash
sudo rkhunter --propupd
```

Pour tester le scan automatique, on peut faire `sudo /etc/cron.daily/rkhunter`, si la commande met du temps à se terminer, c'est que le check se fait bien en arrière plan.

RKHunter est désormais correctement configuré, il s’exécutera toutes les nuits pour lancer des vérifications système.

### Lancer une vérification RKHunter

```bash
sudo rkhunter --check -sk
```

### Lire le résultat de la dernière vérification

Pour lire le résultat

```bash
sudo tail -n 50 /var/log/rkhunter.log | grep -A 17 "System checks summary"
```

Il faut aussi vérifier les `Warnings` (je conseille grandement de les corriger s'il y en a)

```bash
sudo tail -n 100 /var/log/rkhunter.log | grep -i "warning"
```

Il reste encore deux warnings

- `Checking if SSH root access is allowed`
- `'PermitRootLogin' has not been set`

Nous allons faire ça par la suite, il s'agit de l'accès root (que l'on va déverrouiller).

Sinon :

- On vérifie chacun des fichier qui ont un flag `Warnings`
- Si les fichiers/modifications sont légitimes, on lance une indexation pour les valider.
- Si ce sont des fichiers cachés légitimes, on réutilise `ALLOWHIDDENFILE` dans le fichier de configuration

On simule un usage de routine automatique avec

```bash
sudo rkhunter --check --cronjob
```

Il envoie un mail alertant que la machine est potentiellement compromise.

</div></details>

## Gestion de clefs SSH

<details><summary class="button">🔍 Spoiler</summary><div class="spoiler">

### Créer une clef SSH de récupération

On crée une clef de récupération (sur notre machine locale), c'est une clef que l'on conserve précieusement, ce sera notre accès pour ajouter des clefs locales sur d'autres machines.

Dans l'exemple, on crée le repertoire `~/Documents/Sécurité/Clefs/`

```bash
mkdir -p ~/Documents/Sécurité/Clefs/
```

On crée la clef

```bash
ssh-keygen -t ed25519 -f ~/Documents/Sécurité/Clefs/ovh-nomvps-vps-recovery-key -C "Clef de récupération - OVH - Nom du VPS"
```

Attention, mettez un mot de passe avec une très forte entropie (100 bits d'entropie minimum) et enregistrer le fichier précieusement. Étant une clef de récupération, il faut en protéger l'accès.

Il faudra absolument garder ces clefs.

### Générer une clef locale

Si l'on a pas déjà une clef locale, on en crée une avec

```bash
ssh-keygen -t ed25519 -C "your_email@example.com your_machine"
```

Si ce n'est pas fait (au déploiement de debian) on l'ajoute la clef publique normale au VPS avec

```bash
ssh-copy-id -i ~/.ssh/id_ed25519.pub debian@192.0.2.1
```

Et on tape le mot de passe de l'user `debian`

Il faut absolument conserver la clef de récupération !

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

-> remplacer `username` par le nom d'user désiré, et entrez votre mdp, le entrées `full name`, `room number` etc peuvent rester vides (çà la fin on valide avec `Y` ou `Entrée`), dans la suite de la doc, l'username donné est `paul`.

et on lui donne l'accès sudo, étant le vrai compte du VPS

```bash
sudo usermod -aG sudo username
```

On peut maintenant se déconnecter

```bash
exit
```

</div></details>

## Ajouter la clef de récupération au nouveau user

<details><summary class="button">🔍 Spoiler</summary><div class="spoiler">

Modifiez les variables au besoin, ce script permet d'ajouter la clef de récupération au nouvel utilisateur (il ne faudra jamais la retirer sous peine de perdre tout accès), la connexion par mot de passe étant à bannir.

```bash
username=paul
vps_user=debian
public_key_path=~/Documents/Sécurité/Clefs/la-recovery-key.pub
recovery_path=~/.ssh/id_ed25519.pub
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

Maintenant l'on ne se connecte plus avec l'user `debian`, mais avec cet utilisateur fraîchement créé.

```bash
ssh -p VOTRE_RANDOM_PORT NOUVEL_USER@192.0.2.1
```

Gardez précieusement votre commande de connexion, c'est celle-ci que vous utiliserez.

Pour les comptes non admin, ne donnez pas d'accès sudo !

```bash
cat ~/.ssh/authorized_keys
```

Pour être sûr qu'il a bien la clef de récupération dans ses connexions SSH.

</div></details>

## Le Pare-feu

<details><summary class="button">🔍 Spoiler</summary><div class="spoiler">

Les ports étant ouverts par défaut sur toute machines linux, on va les régler dans le pare-feu `iptables`, pour se simplifier la vie on installe UFW (qui va créer les règles iptables pour nous)

- Pour information, la règle de sécurité est de laisser le flux sortant ouvert, et de verrouiller par défaut le flux entrant (en laissant ouvert seulement le port SSH).
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

On ajouter les ip de cloudflare en liste blanche pour les ports 80 et 443

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

```text
Status: active
Logging: on (low)
Default: deny (incoming), allow (outgoing), disabled (routed)
New profiles: skip

To                         Action      From
--                         ------      ----
61869/tcp                  ALLOW IN    Anywhere
Anywhere on lo             ALLOW IN    Anywhere
80,443/tcp                 ALLOW IN    173.245.48.0/20
80,443/tcp                 ALLOW IN    103.21.244.0/22
80,443/tcp                 ALLOW IN    103.22.200.0/22
80,443/tcp                 ALLOW IN    103.31.4.0/22
80,443/tcp                 ALLOW IN    141.101.64.0/18
80,443/tcp                 ALLOW IN    108.162.192.0/18
80,443/tcp                 ALLOW IN    190.93.240.0/20
80,443/tcp                 ALLOW IN    188.114.96.0/20
80,443/tcp                 ALLOW IN    197.234.240.0/22
80,443/tcp                 ALLOW IN    198.41.128.0/17
80,443/tcp                 ALLOW IN    162.158.0.0/15
80,443/tcp                 ALLOW IN    104.16.0.0/13
80,443/tcp                 ALLOW IN    104.24.0.0/14
80,443/tcp                 ALLOW IN    172.64.0.0/13
80,443/tcp                 ALLOW IN    131.0.72.0/22
61869/tcp (v6)             ALLOW IN    Anywhere (v6)
Anywhere (v6) on lo        ALLOW IN    Anywhere (v6)
80,443/tcp                 ALLOW IN    2400:cb00::/32
80,443/tcp                 ALLOW IN    2606:4700::/32
80,443/tcp                 ALLOW IN    2803:f800::/32
80,443/tcp                 ALLOW IN    2405:b500::/32
80,443/tcp                 ALLOW IN    2405:8100::/32
80,443/tcp                 ALLOW IN    2a06:98c0::/29
80,443/tcp                 ALLOW IN    2c0f:f248::/32
```

On relance UFW pour activer les réglages.

```bash
sudo ufw reload
```

On limite ainsi grandement la surface d'attaque. Il n'y a qu'un port totalement ouvert (le SSH) depuis l'extérieur, et les ports http et https fonctionnent sur le principe d'une liste blanche (empêchant même quelqu'un ayant l'ip de tenter de se connecter sans passer par CloudFlare).

</div></details>

## Retirer une clef SSH d'un user

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

A partir de maintenant, on ne peut plus se connecter qu'avec une clef SSH, ce qui est la meilleure pratique pour protéger les connexions SSH sur un VPS.

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

On valide les changements de mdp du côté de RKHunter avec

```bash
sudo rkhunter --propupd
```

Voilà, l'utilisateur `debian` est proprement verrouillé.

</div></details>

## Verrouillage de la connexion SSH de root

<details><summary class="button">🔍 Spoiler</summary><div class="spoiler">

```bash
sudo nano /etc/ssh/sshd_config
```

Avec `CTRL + W` on cherche `PermitRootLogin` on dé-commente/transforme en `PermitRootLogin no`, on enregistre et on ferme nano.

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

Le pare-feu (UFW) génère en continu des lignes de texte (logs) pour surveiller le serveur. Sans nettoyage, ces fichiers finissent par saturer l'espace disque du VPS, ce qui peut faire planter la machine. On utilise `logrotate` pour archiver, compresser et supprimer automatiquement les vieux logs.

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

On peut afficher l'état de la machine avec cette commande (pensez à modifier `49152`, `192.0.2.1` et `paul`)

```bash
ssh -t -p 49152 paul@192.0.2.1 "btop"
```

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

### Quelques commandes basiques

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
//Unattended-Upgrade::Remove-Unused-Dependencies "false";
//Unattended-Upgrade::Automatic-Reboot "false";
```

et Pour

`//Unattended-Upgrade::Mail "";` dé-commenter et mettre le mail sur lequel on veut l'alerte d'erreur de màj.

On a activé et configuré les **mises à jour de sécurité automatiques** pour que le VPS se protège tout seul des failles (en installant les màj) en arrière-plan, tout en nettoyant ses fichiers inutiles et en lui interdisant de redémarrer sans ton autorisation.

On vérifie que tout est bon

```bash
sudo systemctl status unattended-upgrades
sudo systemctl status apt-daily-upgrade.timer
```

Si on voit `Active: active (running)` et `active (waiting)`, alors tout est bon.

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

## Dernier scan RKHunter

<details><summary class="button">🔍 Spoiler</summary><div class="spoiler">

### Dernière vérification RKHunter

```bash
sudo rkhunter --check -sk
```

On valide nos changements (la création de l'user, les changements des users root et debian)

```bash
sudo rkhunter --propupd
```

Pour lire le résultat

```bash
sudo tail -n 50 /var/log/rkhunter.log | grep -A 17 "System checks summary"
```

Il faut aussi vérifier les `Warnings` (je conseille grandement de les corriger s'il y en a), maintenant il ne devrait plus y avoir la moindre alerte

```bash
sudo tail -n 100 /var/log/rkhunter.log | grep -i "warning"
```

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

## Changement du Mot D'Accueil

<details><summary class="button">🔍 Spoiler</summary><div class="spoiler">

```bash
sudo nano /etc/motd
```

Et récupérer l'ascii sur [cette page](https://patorjk.com/software/taag/#p=display&f=miniwi&t=Test&x=none&v=4&h=4&w=80&we=false).

</div></details>

## Auteur

[<img src="https://github.com/RogerBytes.png" width="40" height="40" style="border-radius:50%;" alt="RogerBytes' avatar">](https://github.com/RogerBytes)  
[**RogerBytes (Harry Richmond)**](https://github.com/RogerBytes)

<span hidden>
<details><summary></summary>
<style>.spoiler{border-left:4px solid #1abc9c;border-bottom-left-radius:3px;padding-left:10px;padding-top:15px;margin-top:-10px;margin-bottom:15px}.button{cursor:pointer;padding:5px 10px;background-color:#3498db;color:white;border-radius:3px;margin-bottom:5px;display:inline-block;transition:background-color 0.2s}.button:hover{background-color:#217dbb}details[open] .button{background-color:#1abc9c}</style>
</details></span>

<p align="right"><a href="#">🔝 Retour en haut</a></p>
