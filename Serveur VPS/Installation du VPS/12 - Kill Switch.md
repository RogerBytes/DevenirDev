# Kill Switch

Pour plus de sécurité, nous allons mettre en place un système de Kill Switch, permettant ainsi d'avoir une politique de la terre brûlée en cas de compromission.

Nous allons ici faire deux étapes, la première étant un kill switch faible, avec un volume chiffré LUKS découpé en volumes logiques (LVM) montés directement sur `/var/lib/docker`, `/opt/docker` et `/home/`, utilisant une clef de déchiffrement locale. Cette approche sans *bind mount* garantit de manière passive que Docker ne pourra jamais démarrer si le déverrouillage échoue.

Et dans un deuxième temps, avoir un serveur dédié avec [Mandos](https://www.recompile.se/mandos), permettant de virer la clef de déchiffrement locale pour la gérer lui-même, ainsi c'est le serveur tiers qui est appelé pour décrypter le volume LUKS et qui permet de révoquer de manière autonome telle ou telle machine.

Il faut découpler les risques et favoriser un autre fournisseur pour le VPS de Mandos, je conseille `Cloud VPS 4` chez [Contabo](https://contabo.com/en/vps/) par exemple.

## TOPO TODO

### Étape 1 — Kill switch simple (maintenant)

- Volume physique chiffré avec LUKS.
- Configuration de LVM **par-dessus** le conteneur LUKS ouvert (les "tiroirs dans le coffre").
- Création de volumes logiques dédiés montés directement sur `/var/lib/docker`, `/opt/docker` et `/home/` (pas de *bind mounts*).
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
sudo nala install -y cryptsetup
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
