# 12 - Kill Switch

Pour plus de sécurité, nous allons mettre en place un système de Kill Switch, permettant ainsi d'avoir une politique de la terre brûlée en cas de compromission (qui se lancera automatiquement).

Nous allons ici faire deux étapes, la première étant un kill switch faible, avec un volume chiffré LUKS découpé en volumes logiques (LVM) montés directement sur `/var/lib/docker`, `/opt/docker` et `/home/`, utilisant une clef de déchiffrement locale. Cette approche sans _bind mount_ garantit de manière passive que Docker ne pourra jamais démarrer si le déverrouillage échoue.

Et dans un deuxième temps, avoir un serveur dédié avec [Mandos](https://www.recompile.se/mandos), permettant de virer la clef de déchiffrement locale pour la gérer lui-même, ainsi c'est le serveur tiers qui est appelé pour décrypter le volume LUKS et qui permet de révoquer de manière autonome telle ou telle machine.

Il faut découpler les risques et favoriser un autre fournisseur pour le VPS de Mandos, je conseille `Cloud VPS 4` chez [Contabo](https://contabo.com/en/vps/) par exemple.

## Encryption LUKS

<details><summary class="button">🔍 Spoiler</summary><div class="spoiler">

Informations principales

- `/var/lib/docker`, `/var/lib/containerd`, `/opt/docker` et `/home/` : Chemins des répertoires que l'on va encrypter
- `/dev/mapper/crypt_prod` : Conteneur LUKS
- `vg_prod` : Volume Group LVM
- `/var/lib/docker`, `lv_home` et `lv_docker_opt` : Logical Volumes
- `/dev/vg_prod/lv_docker_lib`, `/dev/vg_prod/lv_containerd_lib`, `/dev/vg_prod/lv_docker_opt` et `/dev/vg_prod/lv_home` : Chemins des Logical Volumes

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

Donc on va créer un fichier conteneur de 60Go (laissant 14.9 Go pour debian, ce qui est amplement suffisant)

### Création et association du fichier conteneur au Loop Device /dev/loop0

<details><summary class="button">🔍 Spoiler</summary><div class="spoiler">

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

</div></details>

### Création du fichier clef

<details><summary class="button">🔍 Spoiler</summary><div class="spoiler">

```bash
sudo dd if=/dev/urandom of=/boot/keyfile.bin bs=1024 count=4 && sudo chmod 600 /boot/keyfile.bin
```

</div></details>

### Chiffrement du fichier via Loop Device

<details><summary class="button">🔍 Spoiler</summary><div class="spoiler">

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

</div></details>

### Déclaration du volume pour LVM

<details><summary class="button">🔍 Spoiler</summary><div class="spoiler">

On installe `lvm2`

```bash
sudo nala install -y lvm2
```

Et on fait la déclaration du volume

```bash
sudo pvcreate /dev/mapper/crypt_prod
```

</div></details>

### Créer le Volume Group

<details><summary class="button">🔍 Spoiler</summary><div class="spoiler">

```bash
sudo vgcreate vg_prod /dev/mapper/crypt_prod
```

</div></details>

### Création des volumes logiques

<details><summary class="button">🔍 Spoiler</summary><div class="spoiler">

Vu qu'on a 60 GO, on met 19Go à containerd, 15Go aux lib docker, 1Go au repertoire opt, et 1Go au repertoire home

```bash
sudo lvcreate -L 19G -n lv_containerd_lib vg_prod
sudo lvcreate -L 15G -n lv_docker_lib vg_prod
sudo lvcreate -L 1G -n lv_docker_opt vg_prod
sudo lvcreate -L 1G -n lv_home vg_prod
```

Il nous reste encore 24 Go de libre sur le volume `luks.img`

#### Agrandir un volume (à chaud, sans coupure)

Par exemple, on pourrait en ajouter sur `lv_docker_lib` avec (on peut le faire à chaud, ça ne pose aucun souci)

```bash
sudo lvextend -L +5G -r /dev/vg_prod/lv_docker_lib
```

#### Diminuer un volume (À froid, avec arrêt du service)

Pour réduire un volume (ex: -5 Go sur Docker `/var/lib/docker` qui contient les DB et les volumes nommés)

```bash
# 1. Arrêter Docker et son socket pour libérer le volume
sudo systemctl stop docker.socket docker

# 2. Démonter le volume
sudo umount /var/lib/docker

# 3. Vérifier l'intégrité du système de fichiers (obligatoire avant de réduire)
sudo e2fsck -f /dev/vg_prod/lv_docker_lib

# 4. Réduire le système de fichiers ET le volume LVM ensemble (-r)
sudo lvreduce -L -5G -r /dev/vg_prod/lv_docker_lib

# 5. Remonter le volume
sudo mount /dev/vg_prod/lv_docker_lib /var/lib/docker

# 6. Relancer Docker
sudo systemctl start docker
```

</div></details>

### Formatage en ext4

<details><summary class="button">🔍 Spoiler</summary><div class="spoiler">

```bash
sudo mkfs.ext4 /dev/vg_prod/lv_docker_lib
sudo mkfs.ext4 /dev/vg_prod/lv_docker_opt
sudo mkfs.ext4 /dev/vg_prod/lv_home
sudo mkfs.ext4 /dev/vg_prod/lv_containerd_lib
```

On vérifie que les répertoires sources existent

```bash
ls -ld /home /opt/docker /var/lib/containerd /var/lib/docker 2>/dev/null
```

Ca retourne

```bash
drwxr-xr-x  4 root root 4096 Jul 21 20:26 /home
drwxr-xr-x  6 root root 4096 Jul 21 21:09 /opt/docker
drwx------ 13 root root 4096 Jul 21 20:55 /var/lib/containerd
drwx--x--- 12 root root 4096 Jul 21 20:56 /var/lib/docker
```

</div></details>

### Copie

<details><summary class="button">🔍 Spoiler</summary><div class="spoiler">

On crée les dossier temp de transfert

```bash
sudo mkdir -p /mnt/temp_home /mnt/temp_lib /mnt/temp_opt /mnt/temp_containerd_lib
```

On connecte les partitions sur les repertoires temporaires

```bash
sudo mount /dev/vg_prod/lv_home /mnt/temp_home
sudo mount /dev/vg_prod/lv_docker_lib /mnt/temp_lib
sudo mount /dev/vg_prod/lv_docker_opt /mnt/temp_opt
sudo mount /dev/vg_prod/lv_containerd_lib /mnt/temp_containerd_lib
```

On arrête Docker

```bash
sudo systemctl stop docker docker.socket containerd
```

On copie les données vers le stockage chiffré (en passant par les montages temporaires)

```bash
sudo cp -a /home/. /mnt/temp_home/
sudo cp -a /var/lib/docker/. /mnt/temp_lib/
sudo cp -a /opt/docker/. /mnt/temp_opt/
sudo cp -a /var/lib/containerd/. /mnt/temp_containerd_lib/
```

Et on démonte les répertoire temporaires

```bash
sudo umount /mnt/temp_home
sudo umount /mnt/temp_lib
sudo umount /mnt/temp_opt
sudo umount /mnt/temp_containerd_lib
```

On vide les repertoires d'origine

```bash
sudo find /home -mindepth 1 -delete
sudo find /opt/docker -mindepth 1 -delete
sudo find /var/lib/docker -mindepth 1 -delete
sudo find /var/lib/containerd -mindepth 1 -delete
```

On ignore les `permission denied` de starship

```bash
Unable to create log dir "/home/paul/.cache/starship": Os { code: 13, kind: PermissionDenied, message: "Permission denied" }!
Unable to create log dir "/home/paul/.cache/starship": Os { code: 13, kind: PermissionDenied, message: "Permission denied" }!
```

et on lance le montage

```bash
sudo mount /dev/vg_prod/lv_home /home
sudo mount /dev/vg_prod/lv_docker_lib /var/lib/docker
sudo mount /dev/vg_prod/lv_docker_opt /opt/docker
sudo mount /dev/vg_prod/lv_containerd_lib /var/lib/containerd
```

Et on démarre Docker

```bash
sudo systemctl start containerd docker
```

Les partitions sont montées en mémoire vive et ça fonctionne (on voir le prompt starship de nouveau comme avant)

</div></details>

### Montage automatique

<details><summary class="button">🔍 Spoiler</summary><div class="spoiler">

On commence par faire un backup du fstab

```bash
sudo cp /etc/fstab /etc/fstab.bak
```

Et on ajoute nos montage au fstab

```bash
sudo tee -a /etc/fstab <<EOF

# Partitions chiffrées LVM de production
/dev/mapper/vg_prod-lv_home             /home                 ext4    defaults,noatime,nofail    0    2
/dev/mapper/vg_prod-lv_docker_lib       /var/lib/docker       ext4    defaults,noatime,nofail    0    2
/dev/mapper/vg_prod-lv_docker_opt       /opt/docker           ext4    defaults,noatime,nofail    0    2
/dev/mapper/vg_prod-lv_containerd_lib   /var/lib/containerd   ext4    defaults,noatime,nofail    0    2
EOF
```

</div></details>

### Créer un service systemd pour le loop Device

<details><summary class="button">🔍 Spoiler</summary><div class="spoiler">

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
cd ~
pwd
sudo update-initramfs -u -k all
sudo systemctl daemon-reload
```

Et activer le service

```bash
sudo systemctl enable setup-loop-prod.service
```

</div></details>

### On vérifie que les repertoire d'origine sont vides

<details><summary class="button">🔍 Spoiler</summary><div class="spoiler">

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
sudo ls -la /mnt/verif_racine/var/lib/containerd
```

Si c'est vide, il est censé retourner

```bash
$ (...)
total 8
drwxr-xr-x  2 root root 4096 Jul 21 21:23 .
drwxr-xr-x 18 root root 4096 Jul 21 21:17 ..
total 8
drwx--x---  2 root root 4096 Jul 21 21:23 .
drwxr-xr-x 29 root root 4096 Jul 21 20:54 ..
total 8
drwxr-xr-x 2 root root 4096 Jul 21 21:23 .
drwxr-xr-x 4 root root 4096 Jul 21 20:56 ..
total 8
drwx------  2 root root 4096 Jul 21 21:23 .
drwxr-xr-x 29 root root 4096 Jul 21 20:54 ..
```

Et on nettoie le point de Vérification

```bash
sudo umount /mnt/verif_racine
sudo rmdir /mnt/verif_racine
```

</div></details>

### Test final

<details><summary class="button">🔍 Spoiler</summary><div class="spoiler">

Normalement on peut faire le reboot, si on ne peut plus se co en SSH, c'est que ça ne décrypte pas ou ne monte pas les volumes.

```bash
df -h | grep -E "docker|home|containerd"
```

il retourne (E EDITER POUR AJOUTER LE RETOURE POUR CONTENERD)

```bash
$ $df -h | grep -E "docker|home|containerd"
/dev/mapper/vg_prod-lv_home            974M  384K  906M   1% /home
/dev/mapper/vg_prod-lv_docker_lib       15G  171M   14G   2% /var/lib/docker
/dev/mapper/vg_prod-lv_docker_opt      974M  1.8M  905M   1% /opt/docker
/dev/mapper/vg_prod-lv_containerd_lib   19G  1.5G   17G   9% /var/lib/containerd
```

Montrant qu'ils sont bien montés.

On relance la machine

```bash
sudo reboot now
```

</div></details>

### Voir espace utilisé sur le serveur

<details><summary class="button">🔍 Spoiler</summary><div class="spoiler">

#### Voir espace disque et points de montage

```bash
df -h -x tmpfs -x devtmpfs
```

Il retourne

```bash
$ df -h -x tmpfs -x devtmpfs
Filesystem                             Size  Used Avail Use% Mounted on
/dev/sda1                               74G   63G  8.5G  88% /
/dev/sda15                             124M  8.9M  115M   8% /boot/efi
/dev/mapper/vg_prod-lv_docker_opt      974M  2.0M  905M   1% /opt/docker
/dev/mapper/vg_prod-lv_containerd_lib   19G  1.5G   17G   9% /var/lib/containerd
/dev/mapper/vg_prod-lv_docker_lib       15G  172M   14G   2% /var/lib/docker
/dev/mapper/vg_prod-lv_home            974M  384K  906M   1% /home
```

C'est impeccable, un peu plus de 8 Go pour le système est un excellent compromis, sans non plus avoir une perte d'espace sur le support de stockage.

#### Voir espace disque des volumes chiffrés

```bash
df -h | grep -E "docker|home|containerd"
```

Il retourne

```bash
$ df -h | grep -E "docker|home|containerd"
/dev/mapper/vg_prod-lv_docker_opt      974M  2.0M  905M   1% /opt/docker
/dev/mapper/vg_prod-lv_containerd_lib   19G  1.5G   17G   9% /var/lib/containerd
/dev/mapper/vg_prod-lv_docker_lib       15G  172M   14G   2% /var/lib/docker
/dev/mapper/vg_prod-lv_home            974M  384K  906M   1% /home
```

#### Afficher la mémoire non allouée avec

```bash
sudo vgs vg_prod
```

Il retourne

```bash
$ sudo vgs vg_prod
  VG      #PV #LV #SN Attr   VSize  VFree
  vg_prod   1   4   0 wz--n- 59.98g 23.98g
```

Si jamais les volumes chiffrés se remplissent trop, on a 24 Go en reserve.

</div></details>

### Cassé KVM et réparation

<details><summary class="button">🔍 Spoiler</summary><div class="spoiler">

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

</div></details>

</div></details>

## KillSwitch Mandos

<details><summary class="button">🔍 Spoiler</summary><div class="spoiler">

Maintenant qu'on a les bases, on va passer à la suite et utiliser un autre serveur qui va pouvoir automatiquement encrypter le serveur client (le serveur de prod par exemple).

### Compatibilité avec Mandos (sur le client)

<details><summary class="button">🔍 Spoiler</summary><div class="spoiler">

On commence par voir si notre serveur actuel est compatible (avant le démarrage complet de mon vps), il peut ou pas accéder au réseau au boot.

```bash
ip route
```

Le fait que l'on lise `proto dhcp` à la première ligne `default` est la certitude que ça ne bloquera pas, ainsi on peut se lancer dans l'aventure !

</div></details>

### Ajout d'un fallback sur le client

<details><summary class="button">🔍 Spoiler</summary><div class="spoiler">

Vu que l'on va se débarrasser de la clef locale, il faut une méthode alternative pour nous y connecter (sur le serveur du client)

On ajoute un slot, mais avec un mdp.

```bash
sudo cryptsetup luksAddKey /luks.img --key-file /boot/keyfile.bin
```

Voilà, on a un mdp pour décrypter, le garder précieusement, cet accès servira pour Mandos comme en cas de panne !

</div></details>

### VPS serveur Mandos

<details><summary class="button">🔍 Spoiler</summary><div class="spoiler">

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

</div></details>

### Paramétrage serveur VPS Mandos

<details><summary class="button">🔍 Spoiler</summary><div class="spoiler">

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

</div></details>

### Installation de Mandos (sur le vps dédié)

<details><summary class="button">🔍 Spoiler</summary><div class="spoiler">

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

</div></details>

### Installation du client mandos sur le VPS client

<details><summary class="button">🔍 Spoiler</summary><div class="spoiler">

On fait une màj

```bash
sudo nala update && sudo nala upgrade -y
```

Puis on installe le client

```bash
sudo nala install -y mandos-client
```

</div></details>

### Récupérer l'entrée de co sur le client

<details><summary class="button">🔍 Spoiler</summary><div class="spoiler">

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
checker = ssh-keyscan -q -t ecdsa-sha2-nistp256 %%(host)s 2>/dev/null | grep --fixed-strings --line-regexp --quiet --regexp=%%(host)s" %(ssh_fingerprint)s"
ssh_fingerprint = xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

On garde ça au chaud.

</div></details>

### Ajouter un client au serveur Mandos

<details><summary class="button">🔍 Spoiler</summary><div class="spoiler">

On ajoute cette `entrée de co`, sur le serveur mandos, tout à la fin de `/etc/mandos/clients.conf`

```bash
sudo nano /etc/mandos/clients.conf
```

Et dans le fichier, on dé-commente tous les réglages du haut

On ajoute notre `entrée de co` dans notre partie client à la fin, mais on retire `checker = ssh-keyscan -q -t ecdsa-sha2-nistp256 %%(host)s 2>/dev/null | grep --fixed-strings --line-regexp --quiet --regexp=%%(host)s" %(ssh_fingerprint)s"`

On corrige le host de l'`entrée de co` (en utilisant le nom de domaine utilisé par le tunnel CloudFlared)

```bash
host = truc.mondomaine.com
```

et on vire le checker en bas et on remplace le checker du haut (le `DEFAULT`) par

```bash
checker = sh -c 'ssh -o BatchMode=yes -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o ConnectTimeout=5 -o ProxyCommand="/usr/bin/cloudflared access ssh --hostname %%(host)s" %(host)s exit 2>&1 | grep -q "Permission denied" && exit 0 || exit 1'
```

Et on enregistre.

puis

```bash
sudo systemctl restart mandos
```

</div></details>

### Service systemd sur le client

<details><summary class="button">🔍 Spoiler</summary><div class="spoiler">

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

</div></details>

### Changement dans crypttab (sur le client)

<details><summary class="button">🔍 Spoiler</summary><div class="spoiler">

Sur le client

```bash
sudo nano /etc/crypttab
```

on met

```bash
crypt_prod    /dev/loop0    none    luks,noauto
```

</div></details>

### Prioriser notre service systemd pour Mantos devant Docker (sur le client)

<details><summary class="button">🔍 Spoiler</summary><div class="spoiler">

On doit dire à docker de se lancer après notre service systemd sur le client

```bash
sudo mkdir -p /etc/systemd/system/docker.service.d/
sudo nano /etc/systemd/system/docker.service.d/override.conf
```

y coller

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

</div></details>

### Activer un client dans Mandos

<details><summary class="button">🔍 Spoiler</summary><div class="spoiler">

On liste les client avec

```bash
sudo mandos-ctl
```

```bash
sudo mandos-ctl --enable vps-xxxxxxxx.xxx.xxx.xxx
```

</div></details>

### Désactiver un client dans Mandos

<details><summary class="button">🔍 Spoiler</summary><div class="spoiler">

On liste les client avec

```bash
sudo mandos-ctl
```

```bash
sudo mandos-ctl --disable vps-xxxxxxxx.xxx.xxx.xxx
```

</div></details>

### Tester le client (sur le serveur du client)

<details><summary class="button">🔍 Spoiler</summary><div class="spoiler">

Pour être sûr que le client se connecte bien à au serveur Mandos, on fait

```bash
sudo /usr/lib/x86_64-linux-gnu/mandos/plugins.d/mandos-client \
  --pubkey=/etc/keys/mandos/pubkey.txt \
  --seckey=/etc/keys/mandos/seckey.txt \
  --tls-pubkey=/etc/keys/mandos/tls-pubkey.pem \
  --tls-privkey=/etc/keys/mandos/tls-privkey.pem \
  --connect=192.0.2.1:13721
```

Il faut bien remplacer `192.0.2.1` par l'ip du du serveur Mandos.

S'il retourne la clef, cela confirme qu'il est bien authentifié et activé par Mandos.

</div></details>

### Tester le checker (sur le serveur Mandos)

<details><summary class="button">🔍 Spoiler</summary><div class="spoiler">

On lance un check avec

```bash
sudo mandos-ctl --start-checker nom-du-client
```

On peut vérifier ensuite

```bash
sudo mandos-ctl
```

On verra `2026-07-20T13:34:05.285460` dans la colonne `Last Successful Check`.

</div></details>

### Suppression du keyfile et reboot

<details><summary class="button">🔍 Spoiler</summary><div class="spoiler">

```bash
sudo rm -rf /boot/keyfile.bin
```

Et on peut faire le grand saut et reboot

```bash
sudo reboot
```

On patiente un peu avant de se reconnecter en SSH (genre une minute), une fois reconnecté, on vérifie les logs du service de déverrouillage

```bash
sudo journalctl -u mandos-unlock.service --no-pager
```

On peut y voir toutes les interactions avec le serveur Mandos, mission accomplie !

</div></details>

</div></details>

## Script activation de KillSwitch

<details><summary class="button">🔍 Spoiler</summary><div class="spoiler">

Sur le serveur Mandos, on récupère le nom du client

```bash
sudo mandos-ctl
```

Et depuis son ordi, on utilise ceci (en modifiant les valeurs des 3 premières variables)

```bash
MANDOS_HOST="mandos.mondomaine.com"
PROD_HOST="hub.mondomaine.com"
CLIENT_NAME="nom du client"

CONTROL_PATH="$HOME/.ssh/cm-killswitch"
echo "Connexion au serveur Mandos (clé + TOTP, une seule fois)..."
ssh -MNf -o ControlPath="$CONTROL_PATH" "$MANDOS_HOST"
echo -n "Mot de passe sudo (serveur Mandos) : "
read -s SUDO_PASS
echo
ssh -o ControlPath="$CONTROL_PATH" "$MANDOS_HOST" "sudo -S mandos-ctl --disable $CLIENT_NAME" <<< "$SUDO_PASS" && \
STATUS=$(ssh -o ControlPath="$CONTROL_PATH" "$MANDOS_HOST" "sudo -S mandos-ctl" <<< "$SUDO_PASS" | grep "$CLIENT_NAME" | awk '{print $2}') && \
if [ "$STATUS" = "No" ]; then
  echo ""
  echo "Client bien désactivé, lancement du reboot..."
  ssh "$PROD_HOST" -t "sudo reboot"
else
  echo "ERREUR: le client n'est pas désactivé (statut: $STATUS), reboot annulé"
fi
ssh -O exit -o ControlPath="$CONTROL_PATH" "$MANDOS_HOST" 2>/dev/null
echo ""
echo "⚠️  $PROD_HOST est encryptée."
```

</div></details>

## Réactivation après encryption

<details><summary class="button">🔍 Spoiler</summary><div class="spoiler">

Sur le serveur Mandos, on récupère le nom du client

```bash
sudo mandos-ctl
```

Et depuis son ordi, on utilise ceci (en modifiant les valeurs des 3 premières variables)

```bash
MANDOS_HOST="mandos.mondomaine.com"
CLIENT_NAME="nom du client"

CONTROL_PATH="$HOME/.ssh/cm-killswitch"
echo "Connexion au serveur Mandos (clé + TOTP, une seule fois)..."
ssh -MNf -o ControlPath="$CONTROL_PATH" "$MANDOS_HOST"
ssh -o ControlPath="$CONTROL_PATH" "$MANDOS_HOST" -t "sudo mandos-ctl --enable $CLIENT_NAME"
ssh -O exit -o ControlPath="$CONTROL_PATH" "$MANDOS_HOST" 2>/dev/null
echo ""
echo "⚠️  4 minutes restantes pour se connecter au Dashboard du fournisseur du VPS pour reboot $CLIENT_NAME."
```

Regarder qu'il apparaisse bien en `enabled` et rapidement demander le reboot sur le fournisseur du VPS verrouillé.

</div></details>

## Si coincé dehors (utilisation KVM)

<details><summary class="button">🔍 Spoiler</summary><div class="spoiler">

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

</div></details>

## Auteur

[<img src="https://github.com/RogerBytes.png" width="40" height="40" style="border-radius:50%;" alt="RogerBytes' avatar">](https://github.com/RogerBytes)
[**RogerBytes (Harry Richmond)**](https://github.com/RogerBytes)

<span hidden>
<details><summary></summary>
<style>.spoiler{border-left:4px solid #1abc9c;border-bottom-left-radius:3px;padding-left:10px;padding-top:15px;margin-top:-10px;margin-bottom:15px}.button{cursor:pointer;padding:5px 10px;background-color:#3498db;color:white;border-radius:3px;margin-bottom:5px;display:inline-block;transition:background-color 0.2s}.button:hover{background-color:#217dbb}details[open] .button{background-color:#1abc9c}</style>
</details></span>

<p align="right"><a href="#">🔝 Retour en haut</a></p>
