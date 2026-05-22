# Installer Docker Desktop

## Prérequis

Avoir suivi l'installation de docker engine `Installer Docker Engine sur LM`

## Téléchargement

```bash
wget -O docker-desktop-amd64.deb "https://desktop.docker.com/linux/main/amd64/docker-desktop-amd64.deb?utm_source=docker&utm_medium=webreferral&utm_campaign=docs-driven-download-linux-amd64"
```

## Installation

```bash
sudo nala install -y docker-desktop-amd64.deb
rm docker-desktop-amd64.deb
```

## Initialisation de Docker Desktop

`Docker Desktop` étant installé, nous pouvons le lancer pour la première fois.

```bash
systemctl --user start docker-desktop
```

## Retirer la sources 32bit

Chez moi mon gestionnaire de paquet se plaint d'un binaire 32x manquant, voici comment retirer la source :

```bash
echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu noble stable" | sudo tee /etc/apt/sources.list.d/docker.list
sudo mv /etc/apt/sources.list.d/docker.sources /etc/apt/sources.list.d/docker.sources.disabled
sudo apt update
```
