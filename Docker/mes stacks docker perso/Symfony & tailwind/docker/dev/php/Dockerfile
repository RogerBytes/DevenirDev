FROM php:8.4-fpm-alpine

# Dépendances principales
RUN apk --no-cache add curl git wget zsh dpkg bash

# Installation du gestionnaire d'extensions/libs php
ADD https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/
RUN chmod +x /usr/local/bin/install-php-extensions

# Installation de lib/dépendances php pour Symfony | pour mariadb/mysql, il faut ajouter les paquets "mysqli pdo_mysql"
RUN install-php-extensions \
  opcache iconv soap zip intl fileinfo pdo redis gd pdo_pgsql

# Installation de Composer
# RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin/ --filename=composer
# Installation de Composer (dernière version stable "--2 force Composer à installer la dernière version majeure 2 compatible avec PHP 8.5")
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin/ --filename=composer --2

# Définir le répertoire de travail
WORKDIR /var/www/html

# Installation de Symfony
RUN curl -1sLf 'https://dl.cloudsmith.io/public/symfony/stable/setup.alpine.sh' | bash
RUN apk add symfony-cli

# Petit ajout de sécuritaire (bloque les shorts tag php)
RUN echo "short_open_tag = Off" > /usr/local/etc/php/php.ini

# On ajoute node (requis pour l'installation de webpack encore dans le entrypoint)
RUN apk add --no-cache nodejs npm

# --------- Customization pour environnement DEV  --------- #
# --------------------------------------------------------- #

# Installation de https://starship.rs
RUN apk add --no-cache starship

# Configurer Zsh pour utiliser Starship
RUN echo 'eval "$(starship init zsh)"' >> /root/.zshrc

# Configurer Starship avec le preset Gruvbox-Rainbow
RUN mkdir -p /root/.config \
  && starship preset gruvbox-rainbow -o /root/.config/starship.toml

# Définir Zsh comme shell par défaut
SHELL ["/bin/zsh", "-c"]

# Petits outils pour le shell zsh
## Cloner les plugins Zsh dans /root/.zsh
RUN git clone https://github.com/zsh-users/zsh-syntax-highlighting.git /root/.zsh/zsh-syntax-highlighting \
  && git clone https://github.com/zsh-users/zsh-autosuggestions.git /root/.zsh/zsh-autosuggestions

## Les ajouter au .zshrc
RUN echo "source /root/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" >> /root/.zshrc \
  && echo "source /root/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh" >> /root/.zshrc

# --------------------------------------------------------- #
# FIN------ Customization pour environnement DEV  ------INF #

# -------------------------------------------------------------  Installation de node etc de brun



# On copie l'entrypoint dans l'image
COPY ./docker/dev/php/entrypoint.sh /usr/local/bin/entrypoint.sh

# On le rend executable
RUN chmod +x /usr/local/bin/entrypoint.sh

# On l'établit comme entry point exécuté à chaque lancement de l'image
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
