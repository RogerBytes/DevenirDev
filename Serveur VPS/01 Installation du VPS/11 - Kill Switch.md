# 11 - Kill Switch

Pour plus de sécurité, nous allons mettre en place un système de Kill Switch, permettant ainsi d'avoir une politique de la terre brûlée en cas de compromission (qui se lancera automatiquement).

Nous allons ici faire deux étapes, la première étant un kill switch faible, avec un volume chiffré LUKS découpé en volumes logiques (LVM) montés directement sur `/var/lib/docker`, `/opt/docker` et `/home/`, utilisant une clef de déchiffrement locale. Cette approche sans _bind mount_ garantit de manière passive que Docker ne pourra jamais démarrer si le déverrouillage échoue.

Et dans un deuxième temps, avoir un serveur dédié avec [Mandos](https://www.recompile.se/mandos), permettant de virer la clef de déchiffrement locale pour la gérer lui-même, ainsi c'est le serveur tiers qui est appelé pour décrypter le volume LUKS et qui permet de révoquer de manière autonome telle ou telle machine.

Il faut découpler les risques et favoriser un autre fournisseur pour le VPS de Mandos, je conseille `Cloud VPS 4` chez [Contabo](https://contabo.com/en/vps/) par exemple.

## Kill switch simple

Informations principales

- `/var/lib/docker`, `/opt/docker` et `/home/` : Chemins des répertoires que l'on va encrypter
- `/dev/mapper/crypt_prod` : Conteneur LUKS
- `vg_prod` : Volume Group LVM
- `/var/lib/docker`, `lv_home` et `lv_docker_opt` : Logical Volumes
- `/dev/vg_prod/lv_docker_lib`, `/dev/vg_prod/lv_docker_opt` et `/dev/vg_prod/lv_home` : Chemins des Logical Volumes

Une fois que tu me donnes ça, je te déroule le script étape par étape avec :

1. La création du conteneur LUKS.
2. La création des volumes LVM à l'intérieur.
3. Le transfert de tes données existantes (`/var/lib/docker`, etc.) pour ne rien perdre.
4. La configuration du montage automatique.

On liste les partitions avec `lsblk`

Dans l'exemple il retourne

```bash
$ lsblk
NAME    MAJ:MIN RM  SIZE RO TYPE MOUNTPOINTS
sda       8:0    0   75G  0 disk
├─sda1    8:1    0 74.9G  0 part /
├─sda14   8:14   0    3M  0 part
└─sda15   8:15   0  124M  0 part /boot/efi
```

Donc on va créer un fichier conteneur de 60Go (laissant 14.9 Go pour debian)

### Création et association du fichier conteneur au Loop Device /dev/loop0

```bash
sudo fallocate -l 60G /luks.img
sudo chmod 600 /luks.img
sudo losetup /dev/loop0 /luks.img
```

On vérifie l'association avec

```bash
sudo /sbin/losetup -a
```

Il doit retourner `/dev/loop0: [2049]:8032 (/luks.img)`

Ainsi que sa taille

```bash
ls -lh /luks.img
```

Il doit retourner `-rw------- 1 root root 60G Jul 15 15:35 /luks.img`

### Création du fichier clef

```bash
sudo dd if=/dev/urandom of=/boot/keyfile.bin bs=1024 count=4 && sudo chmod 600 /boot/keyfile.bin
```

### Chiffrement du fichier via Loop Device

On installe `crypsetup`

```bash
sudo nala install -y cryptsetup cryptsetup-initramfs systemd-cryptsetup
```

Si demandé, on choisit `OK` pour le réglage `Guess optimal character set` par défaut, puis `Other/French/French - French (AZERTY)`.

On lance le chiffrement

```bash
sudo cryptsetup luksFormat --key-file /boot/keyfile.bin /dev/loop0
```

On tape `YES` en majuscules pour confirmer la recréation du fichier (qui aurait effacé son contenu s'il y avait eu quelque chose dessus)

On ouvre le volume chiffré avec la clef

```bash
sudo cryptsetup luksOpen --key-file /boot/keyfile.bin /dev/loop0 crypt_prod
```

Le warning `Warning: keyslot operation could fail as it requires more than available memory.` n'est pas bloquant.

On peut vérifier que tout va bien avec

```bash
ls /dev/mapper/crypt_prod
```

Il doit retourner `/dev/mapper/crypt_prod`

### Déclaration du volume pour LVM

On installe `lvm2`

```bash
sudo nala install -y lvm2
```

Et on fait la déclaration du volume

```bash
sudo pvcreate /dev/mapper/crypt_prod
```

### Créer le Volume Group

```bash
sudo vgcreate vg_prod /dev/mapper/crypt_prod
```

## Création des volumes logiques

Vu qu'on a 60 GO, on va laisser 50Go au lib docker, et 8Go au repertoire opt, tout le reste ira sur home

```bash
sudo lvcreate -L 50G -n lv_docker_lib vg_prod
```

```bash
sudo lvcreate -L 8G -n lv_docker_opt vg_prod
```

```bash
sudo lvcreate -l 100%FREE -n lv_home vg_prod
```

## Formatage en ext4

```bash
sudo mkfs.ext4 /dev/vg_prod/lv_docker_lib
sudo mkfs.ext4 /dev/vg_prod/lv_docker_opt
sudo mkfs.ext4 /dev/vg_prod/lv_home
```

On vérifie que les répertoires sources existent

```bash
ls -ld /home /opt/docker /var/lib/docker 2>/dev/null
```

Ca retourne

```bash
drwxr-xr-x  4 root root 4096 Jul 14 00:34 /home
drwxr-xr-x  7 root root 4096 Jul 14 02:47 /opt/docker
drwx--x--- 12 root root 4096 Jul 14 00:50 /var/lib/docker
```

### Copie

On crée les dossier temp de transfert

```bash
sudo mkdir -p /mnt/temp_home /mnt/temp_lib /mnt/temp_opt
```

On connecte les partitions sur les repertoires temporaires

```bash
sudo mount /dev/vg_prod/lv_home /mnt/temp_home
sudo mount /dev/vg_prod/lv_docker_lib /mnt/temp_lib
sudo mount /dev/vg_prod/lv_docker_opt /mnt/temp_opt
```

On arrête Docker

```bash
sudo systemctl stop docker docker.socket
```

On copie les données vers le stockage chiffré

```bash
sudo cp -a /home/. /mnt/temp_home/
sudo cp -a /var/lib/docker/. /mnt/temp_lib/
sudo cp -a /opt/docker/. /mnt/temp_opt/
```

Et on démonte les répertoire temporaires

```bash
sudo umount /mnt/temp_home
sudo umount /mnt/temp_lib
sudo umount /mnt/temp_opt
```

On vide les repertoires d'origine

```bash
sudo find /home -mindepth 1 -delete
sudo find /opt/docker -mindepth 1 -delete
sudo find /var/lib/docker -mindepth 1 -delete
```

On ignore les `permission denied` de starship

```bash
Unable to create log dir "/home/harry/.cache/starship": Os { code: 13, kind: PermissionDenied, message: "Permission denied" }!
Unable to create log dir "/home/harry/.cache/starship": Os { code: 13, kind: PermissionDenied, message: "Permission denied" }!
```

et on lance le montage

```bash
sudo mount /dev/vg_prod/lv_home /home
sudo mount /dev/vg_prod/lv_docker_lib /var/lib/docker
sudo mount /dev/vg_prod/lv_docker_opt /opt/docker
```

Et on démarre Docker

```bash
sudo systemctl start docker
```

Les partitions sont montées en mémoire vive et ça fonctionne (on voir le prompt starship de nouveau comme avant)

## Montage automatique

On commence par faire un backup du fstab

```bash
sudo cp /etc/fstab /etc/fstab.bak
```

Et on ajoute nos montage au fstab

```bash
sudo tee -a /etc/fstab <<EOF

# Partitions chiffrées LVM de production
/dev/mapper/vg_prod-lv_home        /home            ext4    defaults,noatime,nofail    0    2
/dev/mapper/vg_prod-lv_docker_lib  /var/lib/docker  ext4    defaults,noatime,nofail    0    2
/dev/mapper/vg_prod-lv_docker_opt  /opt/docker      ext4    defaults,noatime,nofail    0    2
EOF
```

### Créer un service systemd pour le loop Device

```bash
sudo nano /etc/systemd/system/setup-loop-prod.service
```

```bash
[Unit]
Description=Attach /luks.img to /dev/loop0 before cryptsetup
DefaultDependencies=no
Before=cryptsetup.target systemd-cryptsetup@crypt_prod.service
After=local-fs-pre.target

[Service]
Type=oneshot
ExecStart=/sbin/losetup /dev/loop0 /luks.img
RemainAfterExit=yes

[Install]
WantedBy=cryptsetup.target
```

Notre clef se trouve `/boot/keyfile.bin`

On édite `crypttab`

```bash
sudo nano /etc/crypttab
```

A la fin, on ajoute

```bash
crypt_prod    /dev/loop0    /boot/keyfile.bin    luks
```

On recharge initramfs

```bash
sudo systemctl daemon-reload
sudo update-initramfs -u -k all
sudo systemctl daemon-reload
```

Les erreurs lors de l'update initramfs sont sans importance.

Et activer le service

```bash
sudo systemctl enable setup-loop-prod.service
```

### On vérifie que les repertoire d'origine sont vides

On crée un point d'accès temp

```bash
sudo mkdir -p /mnt/verif_racine
sudo mount --bind / /mnt/verif_racine
```

On inspecte les anciens dossiers

```bash
sudo ls -la /mnt/verif_racine/home
sudo ls -la /mnt/verif_racine/var/lib/docker
sudo ls -la /mnt/verif_racine/opt/docker
```

Si c'est vide, il est censé retourner

```bash
$ sudo ls -la /mnt/verif_racine/opt/docker
total 8
drwxr-xr-x  2 root root 4096 Jul 15 20:54 .
drwxr-xr-x 18 root root 4096 Jul 15 15:35 ..
total 8
drwx--x---  2 root root 4096 Jul 15 20:54 .
drwxr-xr-x 29 root root 4096 Jul 14 00:49 ..
total 8
drwxr-xr-x 2 root root 4096 Jul 15 20:54 .
drwxr-xr-x 4 root root 4096 Jul 14 00:51 ..
```

Et on nettoie le point de Vérification

```bash
sudo umount /mnt/verif_racine
sudo rmdir /mnt/verif_racine
```

### Test final

Normalement on peut faire le reboot, si on ne peut plus se co en SSH, c'est que ça ne décrypte pas ou ne monte pas les volumes.

```bash
df -h | grep -E "docker|home"
```

il retourne

```bash
$ $df -h | grep -E "docker|home"
/dev/mapper/vg_prod-lv_home        2.0G  632K  1.8G   1% /home
/dev/mapper/vg_prod-lv_docker_lib   49G  242M   47G   1% /var/lib/docker
/dev/mapper/vg_prod-lv_docker_opt  7.8G   18M  7.4G   1% /opt/docker
```

Montrant qu'ils sont bien montés.

On relance la machine

```bash
sudo reboot now
```

## Cassé KVM et réparation

Je laisse ici pour info, normalement la doc est bonne, mais la partie est utile en cas de souci

Pour KVM, avant tout on vire les messages toutes les 5 secondes et on passe en azerty

```bash
logout

sudo dmesg -n 1
sudo apt install kbd
# et choisir France/France Azerty
```

Ensuite on débrouille, voici ce que j'utilisais avec l'ancienne erreur

```bash
sudo losetup /dev/loop0 /luks.img
sudo cryptsetup luksOpen --key-file /boot/keyfile.bin /dev/loop0 crypt_prod
sudo vgchange -ay vg_prod
sudo mount -a
```

Voilà, le KillSwitch faible est paramétré !

## KillSwitch Mandos

Maintenant qu'on a les bases, on va passer à la suite.

### Compatibilité avec Mandos

On commence par voir si notre serveur actuel est compatible (avant le démarrage complet de mon vps), il peut ou pas accéder au réseau au boot.

```bash
ip route
```

Le fait que l'on lise `proto dhcp` à la première ligne `default` est la certitude que ça ne bloquera pas, ainsi on peut se lancer dans l'aventure !

### Ajout d'un fallback

Vu que l'on va se débarrasser de la clef locale, il faut une méthode alternative pour nous y connecter (sur le serveur du client)

On ajoute un slot, mais avec un mdp.

```bash
sudo cryptsetup luksAddKey /luks.img --key-file /boot/keyfile.bin
```

Voilà, on a un mdp pour décrypter, le garder précieusement, cet accès servira pour Mandos comme en cas de panne !

### VPS serveur Mandos

On prend `Cloud VPS 4` chez [Contabo](https://contabo.com/en/vps/).

On commence par réinstaller en mettant sa clef SSH, et dans les options, bloquer la connexion root.

[Accès au Dashboard Contabo](https://new.contabo.com/servers/vps)

#### Rediriger sur CloudFlare

Et sur CloudFlare, on va sur notre domaine, et `DNS/Enregistrements` et on clique sur `+ Ajouter un enregistrement`

pour ipv4
Type A
nom : mandos
mettre l'adresse ipv4
décocher état du proxy

### Paramétrage serveur VPS Mandos

On suit le [Paramétrage VPS](Serveur VPS/Installation du VPS/02 - Paramétrage VPS.md) pour faire

- Première connexion
- Mise à jour du système
- RKHunter
- Gestion de clefs SSH
- Changer le port par défaut de SSH
- Créer un utilisateur non privilégié
- Ajouter la clef de récupération au nouveau user
- CloudFlared
- Le Pare-feu
- TOTP pour connexion SSH locale sur le VPS
- Retirer la connexion par mot de passe
- Verrouillage de l'user initial debian
- Verrouillage de la connexion SSH de root
- Gestion des logs (Logrotate)
- Monitoring basique BTOP
- Réglage du shell
- Mises à jour de sécurité auto unattended-upgrades
- Dernier scan RKHunter

Attention pour le pare-feu, on autorise pas les ip cloudflare (on ouvre seulement le port SSH), les port http et https doivent rester complètement fermés.

On ajoutera le port mandos plus tard, mais notre base serveur est propre.

#### Logs SSH avec rsyslog

```bash
sudo nala install -y rsyslog
```

On refait le fichier (docker l'a créé comme un répertoire, c'est normal)

```bash
sudo rm -rf /var/log/auth.log
sudo systemctl restart rsyslog
sleep 5
ls -la /var/log/auth.log
```

#### Installer CrowdSec

Depuis [la page dédiée de la doc](https://doc.crowdsec.net/u/getting_started/installation/linux/)

On installe le repo

```bash
curl -s https://install.crowdsec.net | sudo sh
```

On fait une màj

```bash
sudo nala update && sudo nala upgrade -y
```

Et on installe avec

```bash
sudo nala install -y crowdsec
```

On regarde les metrics

```bash
sudo cscli metrics
```

Si on voit `file:/var/log/auth.log` dans le tableau `Acquisition Metrics`, c'est parfait.

Puis on installe le bouncer firewall (c'est qui s'occupera des règles iptables)

```bash
sudo nala install -y crowdsec-firewall-bouncer-iptables
```

On lance

```bash
sudo cscli bouncers list
```

On doit voir `crowdsec-firewall-bouncer`

et on fait

```bash
sudo iptables -L -n -v | grep -i crowdsec
```

S'il est bien actif, ça retourne

```bash
$ sudo iptables -L -n -v | grep -i crowdsec
 1281  103K CROWDSEC_CHAIN  all  --  *      *       0.0.0.0/0            0.0.0.0/0
Chain CROWDSEC_CHAIN (1 references)
```

Cela prouve qu'il est bien actif dans iptables.

Pour déban une ip

```bash
sudo cscli decisions delete --ip <L_IP_A_DEBANNIR>
```

Pour ban une ip

```bash
sudo cscli decisions add --ip <L_IP_A_BANNIR> --duration 4h --reason "Test perso"
```

On peut tester avec une ip de test `192.0.2.1`

```bash
sudo cscli decisions add --ip 192.0.2.1 --duration 4h --reason "Test perso"
```

On regarde les décision pour voir l'ip est bannie

```bash
sudo cscli decisions list
```

On la déban avec

```bash
sudo cscli decisions delete --ip 192.0.2.1
```

### Installation de Mandos (sur le vps dédié)

```bash
sudo nala install -y mandos
```

et on vérifie son état

```bash
sudo systemctl status mandos
```

S'il y a `Active: active (running)`, c'est bon.

On modifie le port par défaut

```bash
sudo nano /etc/mandos/mandos.conf
```

On cherche `;port =`, on dé-commente et on met `13721`

Et on relance mandos

```bash
sudo systemctl restart mandos
```

On cherche quel port est utilisé par mandos

```bash
sudo ss -tlnp | grep -E "mandos|python"
```

Si on voit `*:13721`, c'est bon, le changement est effectif.

#### Récupérer adresse IPv4 sur le client

```bash
# IPV4
curl https://api.ipify.org
```

#### Autoriser une IP pour acceder au port de mantos dans UFW et pour ping

Ici, avec pour exemple l'IPv4 `192.0.2.1`, il faudra le faire pour chaque client que l'on ajoutera

```bash
sudo ufw allow from 192.0.2.1 to any port 13721 proto tcp comment 'Serveur Mandos depuis VPS Prod'
```

On active ufw avec

```bash
sudo ufw enable
```

On vérifie qu'il est bien activé avec

```bash
sudo ufw status verbose
```

On doit voir nos règles.

### Installation du client mandos sur le VPS client

On fait une màj

```bash
sudo nala update && sudo nala upgrade -y
```

Puis on installe le client

```bash
sudo nala install -y mandos-client
```

### Récupérer l'entrée de co sur le client

Sur le client on fait

```bash
sudo /usr/sbin/mandos-keygen --password --dir /etc/keys/mandos
```

On met le mdp de déchiffrement luks du client, et ça retourne

```conf
[xxx-xxxxxxxx.xxx.xxx.xxx]
host = xxx-xxxxxxxx.xxx.xxx.xxx
key_id = xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
fingerprint = xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

secret =
    xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
    xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
    xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
    xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
    xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
    xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
    xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
    xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
    xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
    xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
    xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
    xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
    xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
    xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
    xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
    xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
    xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
    xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
    xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
    xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
    xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
    xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
    xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
    xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
    xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

On garde ça au chaud.

### Ajouter un client au serveur Mandos

On ajoute cette entrée, sur le serveur mandos, tout à la fin de `/etc/mandos/clients.conf`

```bash
sudo nano /etc/mandos/clients.conf
```

Et dans le fichier, on dé-commente tous les réglages du haut

On ajoute dans notre partie client, on ajoute

- `checker = check-ping -4 -H %(host)s` en remplaçant 22 par le port SSH du VPS client

OU Normalement

```bash
checker = ssh -q -o BatchMode=yes -o ConnectTimeout=5 -o ProxyCommand="/usr/bin/cloudflared access ssh --hostname %h" %(host)s exit
```

Et on enregistre.

puis

```bash
sudo systemctl restart mandos
```

## Activer un client dans mandos

On liste les client avec

```bash
sudo mandos-ctl
```

```bash
sudo mandos-ctl --enable vps-xxxxxxxx.xxx.xxx.xxx
```

Et depuis le client

```bash
sudo /usr/lib/x86_64-linux-gnu/mandos/plugins.d/mandos-client \
  --pubkey=/etc/keys/mandos/pubkey.txt \
  --seckey=/etc/keys/mandos/seckey.txt \
  --tls-pubkey=/etc/keys/mandos/tls-pubkey.pem \
  --tls-privkey=/etc/keys/mandos/tls-privkey.pem \
  --connect=192.0.2.1:13721
```

S'il retourne la clef, normalement c'est bon

## Service systemd sur le client

On créé un service systemd

```bash
sudo nano /etc/systemd/system/mandos-unlock.service
```

```bash
[Unit]
Description=Unlock crypt_prod via Mandos
DefaultDependencies=no
Requires=setup-loop-prod.service network-online.target
After=setup-loop-prod.service network-online.target
Before=cryptsetup.target

[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=/bin/sh -c '/usr/lib/x86_64-linux-gnu/mandos/plugins.d/mandos-client --pubkey=/etc/keys/mandos/pubkey.txt --seckey=/etc/keys/mandos/seckey.txt --tls-pubkey=/etc/keys/mandos/tls-pubkey.pem --tls-privkey=/etc/keys/mandos/tls-privkey.pem --connect=192.0.2.1:13721 | /sbin/cryptsetup luksOpen /dev/loop0 crypt_prod --key-file=-'

[Install]
WantedBy=cryptsetup.target
```

On prend note qu'il faut modifier `--connect=192.0.2.1:13721` avec l'ip du serveur Mandos.

et on fait

```bash
sudo systemctl daemon-reload
```

## Changement dans crypttab

Sur le client

```bash
sudo nano /etc/crypttab
```

on met

```bash
crypt_prod    /dev/loop0    none    luks,noauto
```

### Prioriser notre service systemd pour Mantos devant Docker (sur le client)

On doit dire à docker de se lancer après notre service systemd sur le client

```bash
sudo mkdir -p /etc/systemd/system/docker.service.d/
sudo nano /etc/systemd/system/docker.service.d/override.conf
```

y coller à la fin

```bash
[Unit]
After=cryptsetup.target local-fs.target mandos-unlock.service
Requires=mandos-unlock.service
```

```bash
sudo systemctl daemon-reload
```

Et on vérifie que les lignes apparaissent avec

```bash
systemctl show docker.service -p After -p Requires
```

Voilà ça c'est bon.

Et on ajoute un accès

```bash
sudo visudo -f /etc/sudoers.d/mandos-ctl
```

On colle

```bash
%sudo ALL=(ALL) NOPASSWD: /usr/sbin/mandos-ctl
```

et on gère l'accès

```bash
sudo chmod 0440 /etc/sudoers.d/mandos-ctl
```

## Tester le checker sur le serveur Mandos

```bash
sudo mandos-ctl --check vps-59944032.vps.ovh.net

sudo mandos-ctl --start-checker vps-59944032.vps.ovh.net

et


/usr/bin/cloudflared access ssh --hostname vps-59944032.vps.ovh.net
```

## Activer le killswitch sur serveur mandos

```bash
sudo mandos-ctl --disable vps-xxxxxxxx.xxx.xxx.xxx
sudo mandos-ctl
```

Et lancer un reboot soit depuis SSH, soit depuis le dashboard du VPS.
Tout est verrouillé.

## Script activation de KillSwitch

Script pour déclencher le KillSwitch

```bash
MANDOS=(ssh -p xxxx1 harry@xxx.xx.xx.xx1)
PROD=(ssh -p xxxx2 harry@xxx.xx.xx.xx2)
CLIENT_NAME="xxx-xxxxxxxx.xxx.xxx.xxx"

echo -n "Mot de passe sudo (serveur Mandos) : "
read -s SUDO_PASS
echo

"${MANDOS[@]}" "sudo -S mandos-ctl --disable $CLIENT_NAME" <<< "$SUDO_PASS" && \
STATUS=$("${MANDOS[@]}" "sudo -S mandos-ctl" <<< "$SUDO_PASS" | grep "$CLIENT_NAME" | awk '{print $2}') && \
if [ "$STATUS" = "No" ]; then
  echo ""
  echo "Client bien désactivé, lancement du reboot..."
  "${PROD[@]}" -t "sudo reboot"
else
  echo "ERREUR: le client n'est pas désactivé (statut: $STATUS), reboot annulé"
fi
```

## Réactiver après KillSwitch

```bash
ssh -p 53168 harry@xxx.xx.xx.xx2 -t "sudo mandos-ctl --enable xxx-xxxxxxxx.xxx.xxx.xxx"
ssh -p 53168 harry@xxx.xx.xx.xx2 -t "sudo mandos-ctl"
```

Regarder qu'il apparaisse bien en `enabled` et rapidement demander le reboot sur le fournisseur du VPS verrouillé.

## Si je me retrouve coincé dehors

On va sur kvm

```bash
logout
# se co
# Une fois co, écrasage des touches de clavier, il faut du temps avant que kvm donne le retour, et il va sûrement redemander de login

# Ensuite on fait
sudo dmesg -n 1
```

Et ensuite, dans notre kvl logué

```bash
sudo cryptsetup luksOpen /dev/loop0 crypt_prod
# On tape passphrase à la main
sudo vgchange -ay vg_prod
sudo mount -a
```

Voilà, l'accès ssh est disponible (et les volumes sont décryptés surtout).

### Correction Claude pour le cloudflared avec Mandos

```bash
sudo nano /etc/mandos/clients.conf
```

On corrige le host

```bash
host = hub.rogerbytes.com
```

et on vire le checker en bas et on remplace le checker du haut par

```bash
checker = sh -c 'ssh -o BatchMode=yes -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o ConnectTimeout=5 -o ProxyCommand="/usr/bin/cloudflared access ssh --hostname %%(host)s" %(host)s exit 2>&1 | grep -q "Permission denied" && exit 0 || exit 1'
```

On relance le service

```bash
sudo systemctl restart mandos
```

Et on lance

```bash
sudo mandos-ctl
```

On s'en sert pour tester le checker par défaut

```bash
sudo mandos-ctl --start-checker vps-xxxxxxxxxxxx.vps.ovh.net

sudo mandos-ctl --start-checker vps-59944032.vps.ovh.net


sudo mandos-ctl --enable vps-59944032.vps.ovh.net


sudo mandos-ctl --start-checker vps-59944032.vps.ovh.net
```

Pour débuguer le merdier

```bash
sudo mandos-ctl --start-checker vps-59944032.vps.ovh.net
sleep 8
sudo journalctl -u mandos -n 30 --no-pager


et ensuite


ssh -v -o BatchMode=yes -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o ConnectTimeout=5 -o ProxyCommand="/usr/bin/cloudflared access ssh --hostname hub.rogerbytes.com" hub.rogerbytes.com exit
echo "Code retour : $?"


et le dernier test

ssh -v -o BatchMode=yes -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o ConnectTimeout=5 -o ProxyCommand="/usr/bin/cloudflared access ssh --hostname hub.rogerbytes.com" hub.rogerbytes.com exit
echo "Code retour : $?"






sudo mandos-ctl --start-checker vps-59944032.vps.ovh.net
sleep 8
sudo mandos-ctl

```


Pour tester le checker

```bash
HOSTNAME="hub.rogerbytes.com"
ssh -o BatchMode=yes -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o ConnectTimeout=5 -o ProxyCommand="/usr/bin/cloudflared access ssh --hostname $HOSTNAME" "$HOSTNAME" exit 2>&1 | grep -q "Permission denied" && echo "Code retour : 0 (succès)" || echo "Code retour : 1 (échec)"
```
