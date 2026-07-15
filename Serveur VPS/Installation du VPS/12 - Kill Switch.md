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

Voici les crottes

- `/dev/mapper/crypt_prod` : Conteneur LUKS
- `vg_prod` : Volume Group LVM
- `/var/lib/docker`, `/var/lib/docker` et `/var/lib/docker` : Logical Volumes
- `/dev/mapper/crypt_prod` : Conteneur LUKS
- `/dev/mapper/crypt_prod` : Conteneur LUKS

Pour que tu puisses copier-coller les commandes les yeux fermés, j'ai juste besoin d'une info : **quel est le nom du disque dur ou de la partition** que tu veux dédier à ce stockage chiffré ? (par exemple `/dev/sdb`, `/dev/vdb`, ou une partition LVM existante).

Une fois que tu me donnes ça, je te déroule le script étape par étape avec :

1. La création du conteneur LUKS.
2. La création des volumes LVM à l'intérieur.
3. Le transfert de tes données existantes (`/var/lib/docker`, etc.) pour ne rien perdre.
4. La configuration du montage automatique.

