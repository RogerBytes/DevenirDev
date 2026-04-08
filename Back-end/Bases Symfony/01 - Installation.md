# Installation de Symfony

En me basant sur [la doc de Symfony](https://symfony.com/doc/current/setup.html) ainsi que [la page de téléchargement de Symfony](https://symfony.com/download).

## Dépendances

Il faut installer `PHP` puis `Composer`.

### Installer Php

<details>
  <summary class="button">
    Spoiler
  </summary>
  <div class="spoiler">

On installe Php en suivant [doc d'install de PHP](https://www.php.net/downloads.php?usage=web&os=linux&osvariant=linux-ubuntu&version=8.5).

```bash
sudo apt update
sudo apt install -y software-properties-common
sudo LC_ALL=C.UTF-8 add-apt-repository ppa:ondrej/php -y
sudo apt update
```

On choisit d'installer `php 8.3`, la version utilisée par la dernière LTS de Symfony (la v7.4).

```bash
sudo apt install -y php8.3
```

Et on installe quelques paquets php

```bash
sudo nala install -y php8.3-cli php8.3-common php8.3-xml php8.3-mbstring php8.3-intl php8.3-sqlite3 php8.3-mysql php8.3-pgsql php8.3-curl
```

Et on choisis la version utilisée par le système

```bash
sudo update-alternatives --config php
```

  </div>
</details>

### Installer Composer

<details>
  <summary class="button">
    Spoiler
  </summary>
  <div class="spoiler">

On installe la dernière version de Composer ([doc d'install de composer](https://getcomposer.org/download/))

```bash
php -r "copy('https://getcomposer.org/installer','composer-setup.php');" && \
php -r "copy('https://composer.github.io/installer.sig','sig');" && \
[ "$(php -r "echo hash_file('sha384','composer-setup.php');")" = "$(cat sig)" ] && \
php composer-setup.php --quiet && rm composer-setup.php sig || \
{ echo 'ERROR: Invalid installer checksum' >&2; rm composer-setup.php sig; exit 1; }
sudo mv composer.phar /usr/local/bin/composer
```

Pour désinstaller composer

```bash
sudo rm /usr/local/bin/composer
```

On paramètre composer pour qu'il utilise notre version de PHP (afin de pas générer des dépendances supérieures).

```bash
php -v
composer config --global platform.php 8.3.29
composer update
```

  </div>
</details>

## Installation

<details>
  <summary class="button">
    Spoiler
  </summary>
  <div class="spoiler">

On peut enfin lancer l'installation de Symfony :

```bash
wget https://get.symfony.com/cli/installer -O - | bash
sudo mv /home/$USER/.symfony5/bin/symfony /usr/local/bin/symfony
```

Le `sudo mv` ci-dessus est optionnel, mais il permet un accès global à l'executable.

On peut forcer Symfony à utiliser une version particulière de php, on affiche quel est le php système :

```bash
symfony local:php:list
```

Ici le système utilise `bin/php8.3`, donc on a l'imposer à Symfony.

```bash
echo 8.3 > ~/.php-version
```

On termine en vérifiant que nous ayons tous les outils et dépendances prérequis.

```bash
symfony check:requirements
```

Tout devrait être en vert, sinon résolvez les erreurs ou les recommendations.

  </div>
</details>

## Extensions Codium

```bash
codium --install-extension cvergne.vscode-php-getters-setters-cv
codium --install-extension bmewburn.vscode-intelephense-client
codium --install-extension nadim-vscode.symfony-code-snippets
codium --install-extension nadim-vscode.symfony-super-console
codium --install-extension TheNouillet.symfony-vscodeDotENV
codium --install-extension mikestead.dotenv
codium --install-extension redhat.vscode-yaml
codium --install-extension mblode.twig-language
codium --install-extension tmrdh.symfony-helper
codium --install-extension TheNouillet.symfony-vscode
vsix-dl klesun.deep-assoc-completion-vscode
```

<style>
.spoiler {
  border-left: 4px solid #1abc9c;
  border-bottom-left-radius:3px;
  padding-left:10px;
  padding-top:15px;
  margin-top:-10px;
  margin-bottom:15px;
}
.button {
  cursor:pointer;
  padding:5px 10px;
  background-color:#3498db;
  color:white;
  border-radius:3px;
  margin-bottom:5px;
  display:inline-block;
  transition: background-color 0.2s;
}
.button:hover {
  background-color: #217dbb;
}
details[open] .button {
  background-color: #1abc9c;
}
</style>
