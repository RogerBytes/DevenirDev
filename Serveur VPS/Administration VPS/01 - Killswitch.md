# 01 - Killswitch

## Todo minimal LUKS kill switch `/opt/docker`

* Installer LUKS (`cryptsetup`)
* Créer un volume chiffré (fichier ou partition)
* Ouvrir + formater le volume
* Monter ce volume sur `/opt/docker`
* Déplacer les données Docker dedans
* Configurer le montage automatique au boot
* Kill switch = supprimer la clé LUKS
