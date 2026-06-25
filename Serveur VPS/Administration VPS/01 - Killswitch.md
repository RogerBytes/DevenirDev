# 01 - Killswitch

Attention à bien mettre en place le système des backup des dump avant !

Le KillSwitch sert à détruire toutes les données du serveur, en cas de crise majeur les données de mes applications seront détruire sur le serveur grâce au killswitch.

- **Le Kill Switch :** C'est un bouton d'urgence (un script) qui permet de détruire instantanément et définitivement toutes les données du serveur pour éviter qu'elles ne soient volées si le serveur est piraté ou compromis.
- **La Forensique (Informatique légale) :** C'est l'ensemble des techniques scientifiques utilisées par des experts pour analyser un serveur, retrouver des indices et récupérer des fichiers, même s'ils ont été effacés normalement.

```bash
# Arrêt immédiat de Docker pour libérer les fichiers
systemctl stop docker
# Destruction définitive et sécurisée de tout le dossier de configuration et des données
shred -uvz -n 3 /opt/docker/
# Extinction brute du serveur
poweroff -f
```
