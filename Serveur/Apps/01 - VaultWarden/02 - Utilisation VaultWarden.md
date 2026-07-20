# 02 - Utilisation VaultWarden

## Envoyer une invitation de connexion

Notre service ayant les inscriptions fermées, on doit passer par <https://sousdomaine.domaine.com/admin>, et entrer le token pour être connecté.

Ensuite on peut envoyer des invitations.

## Clients pour VaultWarden

VaultWarden doit être absolument le gestionnaire quotidien des mots de passe.

Il faut utiliser [les clients Bitwarden](https://bitwarden.com/fr-fr/download/) :

- Extension navigateur : [Extension Chrome](https://chromewebstore.google.com/detail/bitwarden-free-password-m/nngceckbapebfimnlniiiahkandclblb) et [Extension Firefox](https://addons.mozilla.org/en-US/firefox/addon/bitwarden-password-manager/)
- Application Desktop : [Page Flathub](https://flathub.org/fr/apps/com.bitwarden.desktop)
- Application Android : [Page Google Play Store](https://play.google.com/store/apps/details?id=com.x8bit.bitwarden) ou activer le dépôt `Bitwarden F-Droid` sur `Droid-ify` pour pouvoir le télécharger

Il faut éviter au maximum d'utiliser le copié-collé des mots de passe, partant du principe qu'un keylogger peut se trouver sur la machine.
Il faut privilégier le raccourci clavier de remplissage automatique de l'extension (ex: Ctrl + Shift + L sur Bitwarden) qui injecte directement les identifiants dans les champs sans passer par le presse-papiers de la machine.

## Usage

L'usage de VaultWarden est assez simple

- Générer des mots de passe différents pour chaque site ou service
- Quand c'est possible sur un site ou service, utiliser la fonction TOTP comme méthode de vérification à double facteur, VaultWarden le prend parfaitement en charge

## Import depuis coffre KeePass

- Ouvrir `KeePassXC`, aller dans `Base de données/Exporter` et `Fichier .CSV...`
  - Mettre le nom du fichier genre `import-temp.csv` et valider, le fichier est créé.
- Ouvrir le client `BitWarden`, aller dans `Import`
  - Dans `Données / Format de fichier` choisir `KeePassX (csv)`
  - Cliquer sur `Choisir le fichier` et pointer le fichier `import-temp.csv`
  - Cliquer sur `Importer`
  - Laisser les options par défaut et cliquer sur `Terminer`

## Backup

Tous les trimestre il faut faire un backup de VaultWarden, il faut lui faire générer un fichier `.json`.

- Ouvrir `KeePassXC`, aller dans `Base de données/Importer...` et dans `Choix du fichier à importer` choisir `Bitwarden (.json)`
  - À côté de `Fichier à importer`, cliquer sur `Parcourir...` et pointez vers le fichier `*.json`
  - Mettre le mot de passe KeePassXC habituel (faites attention)
  - Laisser l'option `Nouvelle base de données`
  - Cliquer sur `Continuer`
  - Dans la nouvelle fenêtre nommez votre base de données et ajouter au nom la date
  - Cliquer sur `Continuer`
  - Laisser les options par défaut et cliquer sur `Terminer`
- Stocker le fichier `*.kdbx` sur la clef USB dédiée et sur votre Cloud personnel
- Supprimer le fichier `*.json` de BitWarden, et vider la corbeille immédiatement (**indispensable, le fichier est en clair**)

Nous avons ainsi 2 endroits différents pour notre backup.
