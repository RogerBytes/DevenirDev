# Gestion du trousseau SSH

## Ajout automatique de clef

```bash
mkdir -p ~/.ssh && touch ~/.ssh/config && grep -qxF "  AddKeysToAgent yes" ~/.ssh/config || echo -e "Host *\n  AddKeysToAgent yes" >> ~/.ssh/config
```

Cette option `AddKeysToAgent yes` élimine la nécessité d'ajouter manuellement les clef à l'agent via `ssh-add` avant chaque connexion.
En plus, il n'y a besoin d'entrer son mdp qu'une seule fois par session (ou par clé), lors du premier accès nécessitant l'authentification.

Toute clef placée dans `~/.ssh/` est automatiquement ajoutée.

## Génération de clef SSH

Générer une clef avec :

```bash
ssh-keygen -t ed25519 -C "your_email@example.com"
```

Il retournera

```bash
Generating public/private ed25519 key pair.
Enter file in which to save the key (/home/USERNAME/.ssh/id_ed25519):
```

-> Faites 'Entrée' pour choisir le chemin/noms de fichiers par défaut, tapez ensuite un mdp pour votre clef SSH.

Il retourne :

```bash
Your identification has been saved in /home/USERNAME/.ssh/id_ed25519
Your public key has been saved in /home/USERNAME/.ssh/id_ed25519.pub
The key fingerprint is:
SHA256:V4t2iPZV9co4tCq4r3s8qOwfw3Ft8q/Lz3C7CnJ9Qd9k your_email@example.com
The key's randomart image is:
+--[ED25519 256]--+
|         ..      |
|        . o      |
|       . o .     |
|      . o +      |
|     . S = .     |
|      * = +      |
|     o = o .     |
|    . o .        |
|     .           |
+----[SHA256]-----+
```

La clef est automatiquement ajouté à SSH Agent, graĉe à l'option `AddKeysToAgent yes` !

Sinon on aurait du faire `ssh-add ~/.ssh/*clefSSH*`
