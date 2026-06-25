# 04 - Stratégie de sauvegarde

C'est le point le plus important puisque tu vas faire du Docker.

La règle d'or avec Docker : On ne sauvegarde pas les conteneurs eux-mêmes (on s'en fout, on peut les recréer en une seconde avec un fichier docker-compose.yml). On sauvegarde les volumes (les dossiers où tes conteneurs écrivent tes bases de données, tes fichiers de config, etc.).

Conseil : Centralise tous tes projets Docker dans un dossier unique (par exemple /opt/docker/). Pour tes sauvegardes, tu auras juste à planifier un script (via un cron) qui fait un zip de ce dossier /opt/docker/ et qui l'envoie ailleurs (sur un autre stockage OVH, un NAS chez toi, ou un autre cloud).

Franchement, pour un débutant, tu as abattu un boulot monstre et très qualitatif. Continue comme ça ! Tu veux qu'on prépare ensemble le bloc de code pour unattended-upgrades ou pour l'installation propre de Docker ?
