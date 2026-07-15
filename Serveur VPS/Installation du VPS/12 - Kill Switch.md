# Kill Switch

Pour plus de sécurité, nous allons mettre en place un système de Kill Switch, permettant ainsi d'avoir une politique de la terre brûlée en cas de compromission.

Nous allons ici faire deux étapes, la première étant un kill switch faible, avec un volume `/mnt/encrypted` encrypté LUKS avec bind mount des répertoires `/var/lib/docker`, `/opt/docker` et `/home/` dessus et une clef de déchiffrement locale.

Et dans un deuxième temps, avoir un serveur dédié avec [Mandos](https://www.recompile.se/mandos), permettant de virer la clef de déchiffrement locale pour la gérer lui-même, ainsi c'est le serveur tiers qui est appelé pour décrypter le volume `/mnt/encrypted` et qui permet de révoquer de manière autonome telle ou telle machine.

Il faut découpler les risques et favoriser un autre fournisseur pour le VPS de Mandos, je conseille `Cloud VPS 4` chez [Contabo](https://contabo.com/en/vps/) par exemple.

## TOPO TODO

Oui, exactement — c'est une approche saine et réversible, comme on vient de le voir. Résumé de ta trajectoire par étapes :

### Étape 1 — Kill switch simple (maintenant)

- Volume LVM séparé, chiffré LUKS
- Déplacement de `/var/lib/docker`, `/opt/docker`, `/home/` dessus
- Clé de déchiffrement stockée localement sur le serveur (slot 0)
- Kill switch faible mais fonctionnel : utile contre un vol de disque à froid (machine éteinte), pas contre une machine compromise pendant qu'elle tourne

### Étape 2 — Migration vers Mandos (plus tard)

- Montage d'un serveur Mandos séparé
- Ajout de la clé Mandos comme nouveau slot LUKS, en parallèle de la clé locale
- Test d'un reboot pour valider que Mandos déverrouille correctement
- Suppression du slot de clé locale une fois Mandos confirmé fonctionnel
- Kill switch fort : révocation à distance possible, même disque volé physiquement

Tu peux avancer sur l'étape 1 dès maintenant sans attendre d'avoir réglé Mandos, et ça n'ajoute pas de travail perdu pour l'étape 2.Bien noté ce plan en deux étapes pour la suite.
