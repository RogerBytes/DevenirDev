# Logique de sécurisation et gestion mdp

Il est important d'avoir de bonnes pratiques dans la gestion des mots de passe.

- Pour tester l'entropie des mots de passe, il suffit d'installer et utiliser `KeepassXC`.
- Dans `KeePassXC`, utiliser l'option `Générateur de mots de passe`, on peut y tester nos mots de passe, l'entropie sera affichée.

Il y a 4 mots différents de passe à créer et à apprendre pour être bien protégé.

- Mot de passe : sudo user local (sur ordinateur) / sudo user distant (type vps/serveur) [+40 bits d'entropie]
- Mot de passe : KeePass [+100 bits d'entropie]
- Mot de passe : VaultWarden [+100 bits d'entropie]
- Mot de passe : Service Cloud [+100 bits d'entropie]

Ces mots de passe **ne doivent avoir aucune corrélation entre les uns les autres**.

## Sauvegarder les mots de passe en physique

Afin de ne pas se retrouver complètement verrouillé hors de ses bases de données, il faut écrire ses 4 mots de passe sur un papier physique et ranger le papier chez soi, dans un coffre ou une pièce sécurisée.

## Client KeePassXC

On va utiliser [KeePassXC](https://keepassxc.org/download/#linux) dans notre optique de backup.

Il faut l'installer depuis [sa page Flathub](https://flathub.org/fr/apps/org.keepassxc.KeePassXC)

## Compte VaultWarden

### Mot de passe enregistrés

Le compte VaultWarden **contient**

- Mot de passe : VaultWarden (uniquement pour qu'il soit présent dans les backup de KeyPassXC)
- Mot de passe : Service Cloud

### Mot de passe non enregistrés

Le compte VaultWarden **ne contient pas**

- Mot de passe : user local/user distant (type vps/serveur)
- Mot de passe : KeyPass

### Clients pour VaultWarden

VaultWarden doit être absolument le gestionnaire quotidien des mots de passe.

Il faut utiliser [les clients Bitwarden](https://bitwarden.com/fr-fr/download/) :

- Extension navigateur : [Extension Chrome](https://chromewebstore.google.com/detail/bitwarden-free-password-m/nngceckbapebfimnlniiiahkandclblb) et [Extension Firefox](https://addons.mozilla.org/en-US/firefox/addon/bitwarden-password-manager/)
- Application Desktop : [Page Flathub](https://flathub.org/fr/apps/com.bitwarden.desktop)
- Application Android : [Page Google Play Store](https://play.google.com/store/apps/details?id=com.x8bit.bitwarden) ou activer le dépôt `Bitwarden F-Droid` sur `Droid-ify` pour pouvoir le télécharger

Il faut éviter au maximum d'utiliser le copié-collé des mots de passe, partant du principe qu'un keylogger peut se trouver sur la machine.

### Usage

L'usage de VaultWarden est assez simple

- Générer des mots de passe différents pour chaque site ou service
- Quand c'est possible sur un site ou service, utiliser la fonction TOTP comme méthode de vérification à double facteur, VaultWarden le prend parfaitement en charge

### Backup

Tous les trimestre il faut faire un backup de VaultWarden, il faut lui faire générer un fichier `.json`.

- Ouvrir `KeyPassXC`, aller dans `Base de données/Importer...` et dans `Choix du fichier à importer` choisir `Bitwarden (.json)`
  - À côté de `Fichier à importer`, cliquer sur `Parcourir...` et pointez vers le fichier `*.json`
  - Mettre le mot de passe KeyPassXC habituel (faites attention)
  - Laisser l'option `Nouvelle base de données`
  - Cliquer sur `Continuer`
  - Dans la nouvelle fenêtre nommez votre base de données et ajouter au nom la date
  - Cliquer sur `Continuer`
  - Laisser les options par défaut et cliquer sur `Terminer`
- Stocker le fichier `*.kdbx` sur la clef USB dédiée et sur votre Cloud personnel
- Supprimer le fichier `*.json` de BitWarden (**indispensable, le fichier est en clair**)

Nous avons ainsi 2 endroits différents pour notre backup

## Antivirus et analyse de machine

### ClamUI

ClamUI est un client pour ClamAv, un antivirus qui va analyser les fichiers pour voir si certains sont connus comme étant des virus (par exemple c'est lui qui détectera un keylogger).

On l'installe sur son poste personnel (pas le VPS, on utilisera un conteneur clamav avec docker sur le VPS) depuis [sa page Flathub](https://flathub.org/en/apps/io.github.linx_systems.ClamUI)

Pour le scan :

- On clique sur `Base virale` et `Mettre à jour la base virale` et on revient sur l'onglet `Analyse`
- on utilise le profil d'analyse `Full Scan` et on choisir le répertoire racine `/` dans la cible à analyser (le scan est long). On ignore les alertes pour `/proc` ou `/sys`

### Consulter les résultats de RKHunter sur nos serveurs

RKHunter est un détecteur de rootkit, c'est utile sur serveur VPS.

Pour lire le résultat

```bash
sudo tail -n 50 /var/log/rkhunter.log | grep -A 17 "System checks summary"
```

Il faut aussi vérifier les `Warnings` (je conseille grandement de les corriger s'il y en a)

```bash
sudo tail -n 100 /var/log/rkhunter.log | grep -i "warning"
```

- On vérifie chacun des fichier qui ont un flag `Warnings`
- Si les fichiers/modifications sont légitimes, on lance une indexation pour les valider.
- Si ce sont des fichiers cachés légitimes, on réutilise `ALLOWHIDDENFILE` dans le fichier de configuration

## Bonnes pratiques

- Suivre cette documentation à la lettre
- Faire des backups trimestriels (en important le JSON dans KeyPassXC) depuis un client BitWarden et sauver le `*.kdbx` sur clef USB et Cloud
- Dans les mail, toujours vérifier l’expéditeur, et ne pas cliquer sur les liens, il vaut mieux se connecter soi-même au site pour éviter le pishing
- Verrouiller son ordinateur dès que l'on est plus devant l'écran
- N'utiliser que des mots de passe unique avec VaultWarden (il est fait pour), ainsi toute brèche est limitée
- Se connecter au VPS uniquement via clef SSH et **désactiver la connexion SSH par mot de passe au VPS**
- Se servir du client BitWarden pour l'auto remplissage des identifiants (évitant ainsi le problème d'un KeyLogger)
- Vérifier les logs de RKHunter de temps en temps

## Mauvaises (très mauvaises) pratiques

Voici les comportements à **bannir absolument**

- Avoir des mots de passes corrélés ou identiques
- Ne pas faire de backup de VaultWarden
- Laisser sa session déverrouillée
- Laisser sa connexion ouverte sur son VPS
- Partager des mots de passe
- Cliquer sur les liens des mails (toujours se connecter soi-même sur les sites que l'on utilise, hormis inscription et changement de mdp)
- Noter ses mots de passe sur son moniteur/poste de travail (sur un post-it par exemple)
- Ne pas vérifier les expéditeurs des mails
- Ne pas mettre de mot de passe sur une session
- Se connecter en SSH avec mot de passe (il faut désactiver l'option)
- Ne jamais vérifier les logs de RKHunter
