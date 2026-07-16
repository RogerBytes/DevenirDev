# Kill Switch

Pour plus de sécurité, nous allons mettre en place un système de Kill Switch, permettant ainsi d'avoir une politique de la terre brûlée en cas de compromission.

Nous allons ici faire deux étapes, la première étant un kill switch faible, avec un volume chiffré LUKS découpé en volumes logiques (LVM) montés directement sur `/var/lib/docker`, `/opt/docker` et `/home/`, utilisant une clef de déchiffrement locale. Cette approche sans _bind mount_ garantit de manière passive que Docker ne pourra jamais démarrer si le déverrouillage échoue.

Et dans un deuxième temps, avoir un serveur dédié avec [Mandos](https://www.recompile.se/mandos), permettant de virer la clef de déchiffrement locale pour la gérer lui-même, ainsi c'est le serveur tiers qui est appelé pour décrypter le volume LUKS et qui permet de révoquer de manière autonome telle ou telle machine.

Il faut découpler les risques et favoriser un autre fournisseur pour le VPS de Mandos, je conseille `Cloud VPS 4` chez [Contabo](https://contabo.com/en/vps/) par exemple.

## TOPO TODO

### Étape 1 — Kill switch simple (maintenant)

- Volume physique chiffré avec LUKS.
- Configuration de LVM **par-dessus** le conteneur LUKS ouvert (les "tiroirs dans le coffre").
- Création de volumes logiques dédiés montés directement sur `/var/lib/docker`, `/opt/docker` et `/home/` (pas de _bind mounts_).
- Clé de déchiffrement stockée localement sur le serveur (slot 0).
- **Sécurité passive :** Si la clé locale n'est pas saisie au boot, les volumes logiques n'existent pas, empêchant physiquement Docker d'écrire des données en clair sur la racine.
- Kill switch faible mais fonctionnel : utile contre un vol de disque à froid (machine éteinte), pas contre une machine compromise pendant qu'elle tourne.

### Étape 2 — Migration vers Mandos (plus tard)

- Montage d'un serveur Mandos séparé.
- Ajout de la clé Mandos comme nouveau slot LUKS, en parallèle de la clé locale.
- Test d'un reboot pour valider que Mandos déverrouille correctement.
- Suppression du slot de clé locale (slot 0) une fois Mandos confirmé fonctionnel.
- **Garder le SLOT 1 avec une passphrase robuste de secours** (hors du VPS, stockée de manière sécurisée dans notre gestionnaire de mots de passe) pour pouvoir déverrouiller manuellement via la console KVM si le serveur Mandos est en panne.
- Kill switch fort : révocation à distance possible, même disque volé physiquement.

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

On lance le chiffrement

```bash
sudo cryptsetup luksFormat --key-file /boot/keyfile.bin /dev/loop0
```

On tape `YES` en majuscules pour confirmer la recréation du fichier (ce qui efface son contenu s'il y avait eu quelque chose dessus)

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

## Création des volumes logiques

Vu qu'on a 60 GO, on va laisser 50Go au lib docker, et 8Go au repertoire opt, tout le reste ira sur home

Au besoin relancer la déclaration si `Volume group "vg_prod" not found`

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
```

```bash
sudo mkfs.ext4 /dev/vg_prod/lv_docker_opt
```

```bash
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

Normalement on peut faire le reboot, si on ne peut plus se co en SSH, c'est que ça ne decrypte pas ou ne monte pas les volumesq

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

On commence par voir si avant le démarrage complet de mon vps, il peut ou pas accéder au réseau au boot.

```bash
ip route
```

Le fait que l'on lise `proto dhcp` à la première ligne `default` est la certitude que ça ne bloquera pas, ainsi on peut se lancer dans l'aventure !

### Ajout d'un fallback

Vu que l'on va se débarrasser de la clef locale, il faut une méthode alternative pour nous y connecter

On ajoute un slot, mais avec un mdp.

```bash
sudo cryptsetup luksAddKey /luks.img --key-file /boot/keyfile.bin
```

Voilà, on a un mdp pour décrypter, le garder précieusement, cet accès servira en cas de panne !

