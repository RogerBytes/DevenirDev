#!/bin/sh
set -e

# On vérifie s'il faut faire le composer install
if [ ! -d "vendor" ]; then
    echo "💡 Installation des dépendances PHP..."
    composer install --no-interaction --prefer-dist
fi

# ici c'est les dépendances composer requises par tailwind
# https://tailwindcss.com/docs/installation/framework-guides/symfony
# on vérifie s'il faut installer les paquets tailwind
if ! composer show symfony/webpack-encore-bundle >/dev/null 2>&1; then
    echo "💡 Mise à jour des librairies pour Tailwind..."
    composer remove -n symfony/ux-turbo symfony/asset-mapper symfony/stimulus-bundle
    composer require -n symfony/webpack-encore-bundle symfony/ux-turbo symfony/stimulus-bundle
fi

# Autocomplétion Symfony seulement si pas déjà fait
if [ ! -f /root/.symfony_completion ]; then
    grep -q compinit ~/.zshrc || echo -e "\nautoload -Uz compinit\ncompinit" >> /root/.zshrc
    symfony completion zsh > /root/.symfony_completion
    echo "source /root/.symfony_completion" >> /root/.zshrc
fi

# ------ PARTIE NODE [ON NE PEUT UTILISER UN SERVICE SÉPARÉ pour NODE CAR les PAQUETS NODE DEPENDENT DE COMPOSER ET INVERSEMENT pour TAILWIND]

# verification si paquet est présent (requis pour tailwind)
if [ ! -d "node_modules/tailwindcss" ]; then
    echo "💡 Installation des paquets Tailwind..."
    npm install tailwindcss @tailwindcss/postcss postcss postcss-loader
fi

# ------ FIN PARTIE NODE

# Vérifie si PostCSS est activé dans webpack.config.js (requis pour tailwind)
if ! grep -q "\.enablePostCssLoader()" webpack.config.js; then
    sed -i '/^Encore/ a\    .enablePostCssLoader()' webpack.config.js
fi

# Vérifie si postcss.config.mjs existe, sinon le crée (requis pour tailwind)
if [ ! -f "postcss.config.mjs" ]; then
    echo "💡 Création de postcss.config.mjs"
    cat > postcss.config.mjs <<'EOF'
export default {
  plugins: {
    "@tailwindcss/postcss": {},
  },
};
EOF
fi

# fais l'import de tailwind dans le css. (requis pour tailwind)
if ! grep -q '@import "tailwindcss";' assets/styles/app.css; then
    echo "💡 Ajout de l'import Tailwind dans assets/styles/app.css"
    sed -i '1i @import "tailwindcss";\n@source not "../../public";' assets/styles/app.css
fi

# Démarrer PHP-FPM en arrière-plan
php-fpm -F