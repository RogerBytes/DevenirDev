# Installer GIT

Git est un système de contrôle de version qui permet de suivre les modifications apportées à un ensemble de fichiers au fil du temps. Il facilite la collaboration entre les développeurs en permettant de gérer les différentes versions d'un projet et de fusionner les modifications apportées par plusieurs personnes.

## Installation

### GIT

```bash
sudo nala install -y git
# ou
sudo apt install -y git
```

## Régler Git

### Informations d'utilisateur

```bash
git config --global user.email "your_email@example.com"
git config --global user.name "John Doe"
```

### Branche par défaut

Afin d'éviter des avertissement ridicules, faites ceci :

```bash
git config --global init.defaultBranch master
```

Ainsi par défaut, il n'y aura plus de sous-entendus déplacés, hors-sujet et irrespectueux.
