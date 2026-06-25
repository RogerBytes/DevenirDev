# 01 - Killswitch

```bash
# Arrêt immédiat de Docker pour libérer les fichiers
systemctl stop docker
# Destruction définitive et sécurisée de tout le dossier de configuration et des données
shred -uvz -n 3 /opt/docker/
# Extinction brute du serveur
poweroff -f
```
