# 02 - Backup des dump

A FAIRE

Repose-toi, tu as bien bossé ! C'est normal de saturer, l'architecture réseau et les backups, ça fait des gros morceaux à digérer.

Voici ton topo ultra-simple, à lire quand tu auras l'esprit reposé. Pour automatiser tes dumps de base de données avec Offen, tu auras juste **3 étapes logiques** à apprendre (et on le fera ensemble pas à pas le moment venu) :

## 1. Apprendre à ajouter le "Créateur" de dump dans Portainer

Tu vas apprendre à copier-coller un petit bloc de texte (le service de backup) dans ton fichier `compose.yml` existant.

* **Le but :** Lui donner le nom de ta base de données et lui dire de créer un petit fichier `.sql` toutes les heures dans un dossier du VPS (par exemple `/opt/docker/les-dumps-db/`).

## 2. Apprendre à dire à "Offen" de surveiller ce nouveau dossier

Tu vas apprendre à modifier la configuration de ton outil Offen actuel pour lui ajouter une nouvelle mission.

* **Le but :** Lui dire : *« En plus de sauvegarder tout mon dossier principal une fois par nuit, tu vas aussi aller dans le dossier `/opt/docker/les-dumps-db/` toutes les heures. »*

## 3. Apprendre à configurer la destination sur ton Cloudflare R2

Tu vas apprendre à dire à Offen où ranger ce petit fichier toutes les heures.

* **Le but :** Lui donner le chemin exact pour qu'il envoie le dump horaire dans le bon dossier de ton seau (bucket) R2, sans toucher à tes autres sauvegardes.

---

C'est tout. Rien de sorcier, ce ne sont que des lignes de configuration à ajuster dans Portainer.

Prends ta pause, ferme les écrans, et quand tu seras prêt à t'y mettre, tu n'auras qu'à me faire signe !
