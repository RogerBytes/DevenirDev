# 02 - Installation de Docker

[Documentation d'installation de Docker Engine sur debian](https://docs.docker.com/engine/install/debian/)
[Documentation Post Install de Docker](https://docs.docker.com/engine/install/linux-postinstall)

## Prérequis

### Particularités

- Sur la machine hôte (ici mon serveur VPS), j'ai installé UFW (surtout pour protéger la connexion SSH), Docker outrepasse les règles uwf quand il le souhaite, ayant un accès direct à `iptables`.
- Docker ne fonctionne qu'avec `iptables`, il est vain de vouloir utiliser autre chose avec Docker, ça ne marchera pas.
- Pour filtrer le traffic vers mes conteneurs, au lieu de passer par UFW, on doit rajouter des règles dans `DOCKER-USER`, qui est spécialement dédié à cet usage.

### Prérequis OS

Il est officiellement compatible avec les versions 11, 12 et 13 de Debian. Mon VPS étant sous `Debian Trixie 13`, c'est parfait (il s'agit de la `stable`).

Il faut vérifier que certains paquets ne sont pas présents avant installation, on utilise cette commande

```bash
sudo apt remove $(dpkg --get-selections docker.io docker-compose docker-doc podman-docker containerd runc | cut -f1)
```

Si au lieu de lancer la désinstallation, il retourne

```bash
dpkg: no packages found matching docker.io
dpkg: no packages found matching docker-compose
dpkg: no packages found matching docker-doc
dpkg: no packages found matching podman-docker
dpkg: no packages found matching containerd
dpkg: no packages found matching runc
Summary:
  Upgrading: 0, Installing: 0, Removing: 0, Not Upgrading: 0
```

C'est parfait également, on est sur une base propre, on peut passer à l'installation.

## Installation

Depuis [cette partie](https://docs.docker.com/engine/install/debian/#install-using-the-repository).

### Paramétrage du repository APT

On ajoute la clef GPG officielle

```bash
sudo nala update
sudo nala install -y ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
```

On ajoute le repository au source d'apt

```bash
sudo tee /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/debian
Suites: $(. /etc/os-release && echo "$VERSION_CODENAME")
Components: stable
Architectures: $(dpkg --print-architecture)
Signed-By: /etc/apt/keyrings/docker.asc
EOF
```

Et on met à jour la liste des paquets

```bash
sudo nala update
```

### Installation des paquets Docker

```bash
sudo nala install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

On vérifie ensuite que Docker tourne

```bash
sudo systemctl status docker
```

S'il est sur `active (running)`, c'est parfait, sinon on le lance avec

```bash
sudo systemctl start docker
```

### Vérification

Puis on vérifie qu'il fonctionne correctement avec

```bash
sudo docker run hello-world
```

Voilà, `docker-engine` est correctement installé !

## Post Installation

En suivant cette [documentation officielle](https://docs.docker.com/engine/install/linux-postinstall).

### Pourquoi ne pas l'utiliser en mode sans `sudo`

Sur [cette page](https://docs.docker.com/engine/security/#docker-daemon-attack-surface)

> First of all, only trusted users should be allowed to control your Docker daemon [...] This means that you can start a container where the /host directory is the / directory on your host; and the container can alter your host filesystem without any restriction.

Si jamais il y a une faille de sécurité sur un service déployé, il sera aisé à l'assaillant d'accéder à la racine du serveur, car Docker aura un accès root complet.
Pour cette raison, **il ne faut jamais se passer du protocole sudo pour lancer mes commandes docker sur le serveur !**

De ce fait, l'on ignore la partie `Manage Docker as a non-root user` de la [documentation de post install](https://docs.docker.com/engine/install/linux-postinstall).

### Configuration pour démarrage automatique au démarrage avec `systemd`

Mon VPS étant sous `Debian 13`, le service Docker est déjà configuré pour démarrer automatiquement au boot du serveur par défaut. Il n'y a donc aucune action requise.

On peut vérifier avec

```bash
sudo systemctl status docker
```

Il retourne bien `active (running)`, c'est parfait !

### Configuration de la rotation des logs Docker

Pour éviter de saturer le disque du VPS, on configure Docker pour qu'il limite la taille des fichiers de logs de chaque conteneur.
On doit éditer le fichier de configuration `/etc/docker/daemon.json`, info [sur cette doc](https://docs.docker.com/reference/cli/dockerd/#on-linux), nous utilisons bien le `regular setup` et non `rootless`

On crée le fichier (par défaut il n'existe pas, c'est normal) et on l'ouvre avec `nano`

```bash
sudo nano /etc/docker/daemon.json
```

et on colle

```json
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3",
    "compress": "true"
  }
}
```

On lance vérification sur le fichier

```bash
sudo dockerd --validate --config-file=/etc/docker/daemon.json
```

S'il retourne `configuration OK`, c'est qu'il est valide !
Petite information, si via des arguments de commandes, il y a des conflits avec les options se trouvant dans ce fichier de configuration, Docker refusera de démarrer.

Maintenant, nous pouvons relancer Docker pour qu'il prenne en compte ces options de configuration

```bash
sudo systemctl restart docker
```

On va tester que tout est opérationnel

```bash
sudo docker inspect --format '{{json .HostConfig.LogConfig}}' $(sudo docker run -d alpine sleep 1)
```

Cette commande crée un conteneur de test éphémère et extrait instantanément sa configuration de logs pour vérifier que les limites (10m, 3) définies dans le daemon.json sont bien appliquées par défaut.
S'il retourne `{"Type":"json-file","Config":{"compress":"true","max-file":"3","max-size":"10m"}}`, c'est la preuve que les options s'appliquent automatiquement.

Voilà, Docker Engine est correctement installé sur le VPS.

Allez faire la partie `Serveur VPS/03 - Caddy Reverse Proxy.md`, c'est ce qui va permettre à Docker de fonctionner correctement.
