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

Pour le scan, on utilise le profil d'analyse `Full Scan` et on choisir le répertoire racine `/` dans la cible à analyser (le scan est long). On ignore les alertes pour `/proc` ou `/sys`

### RKHunter

RKHunter (ou RootKit Hunter) va détecter des backdoors, des rootkits et autre menaces pour le système.

On l'installe avec

```bash
sudo nala install -y rkhunter
```

Quand est demandé `General mail configuration type`, on choisit `Local uniquement`, sur le prompt suivant, il suffit de laisser le nom de la machine par défaut ou de le modifier au besoin.

On va créer un index des fichiers système

```bash
sudo rkhunter --propupd
```

Cette commande fera une espèce de hash du système, par la suite il servira de modèle de base pour détecter des modifications malveillantes typique d'un rootkit

#### Lancer la première vérification des fichiers système

```bash
sudo rkhunter --check
```

Quand c'est vert, c'est que c'est valide/safe.
Il faut appuyer sur `Entrée` pour passer à chaque session suivante.

- `/usr/bin/lwp-request [ Warning ]` est normal, c'est un faux-positif de Perl.
- `Checking for suspicious (large) shared memory segments [ Warning ]` est normal, c'est un faux-positif, la règle de mémoire partagée de RKHunter est rigide sur ce qui dépasse 1mo.
- `Checking for passwd file changes [ Warning ]` au premier scan, Rkhunter n'a pas d'historique pour comparer ces fichiers d'utilisateurs. Il signale simplement qu'il les découvre.
- `Checking for group file changes [ Warning ]` au premier scan, Rkhunter n'a pas d'historique pour comparer ces fichiers d'utilisateurs. Il signale simplement qu'il les découvre.
- `Checking /dev for suspicious file types [ Warning ]` faux-positif : les Linux modernes créent des fichiers temporaires légitimes dans /dev pour le matériel, ce qui active les vieilles alertes de Rkhunter.
- `Checking for hidden files and directories [ Warning ]` est normal. Linux utilise par défaut des tonnes de fichiers et dossiers cachés (commençant par un point) pour stocker les configurations de ses applications.

A la fin, il retourne les différents cumulés à `Possible rootkits: 6`, c'est donc normal.

On sauvegarde cet état avec

```bash
sudo rkhunter --propupd
```

Ces `Warnings` n'apparaîtront plus lors des prochains scans !

## Bonnes pratiques

- Suivre cette documentation à la lettre
- Faire des backups trimestriels (en important le JSON dans KeyPassXC) depuis un client BitWarden et sauver le `*.kdbx` sur clef USB et Cloud
- Dans les mail, toujours vérifier l’expéditeur, et ne pas cliquer sur les liens, il vaut mieux se connecter soi-même au site pour éviter le pishing
- Verrouiller son ordinateur dès que l'on est plus devant l'écran
- N'utiliser que des mots de passe unique avec VaultWarden (il est fait pour), ainsi toute brèche est limitée
- Vérifier les expéditeurs des mails (le phishing fait toujours autant de ravages)
- Se connecter au VPS uniquement via clef SSH et **désactiver la connexion SSH par mot de passe au VPS**
- Se servir du client BitWarden pour l'auto remplissage des identifiants (évitant ainsi le problème d'un KeyLogger)

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
