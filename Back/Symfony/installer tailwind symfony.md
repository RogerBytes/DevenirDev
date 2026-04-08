# Utiliser tailwind avec Symfony

Je me base sur [la doc de tailwind](https://tailwindcss.com/docs/installation/framework-guides/symfony) qui malheureusement contient une erreur à l’étape 06 où elle fait mettre @source not "../../public"; dans app.css, ce qui bloque la compilation sous Symfony + Webpack Encore (le code correspond à la version standalone de tailwind en cli).

Il y a un bundle symfony, mais je préfère ne pas l'utiliser, il semble bien moins flexible.


## 01 Création de projet Symfony

On créé un projet Symfony et on se met dedans

```bash
symfony new mon-test-tailwind -version=lts --webapp && \
cd mon-test-tailwind && \
codium .
```

## 02 Installation de webpack encore

```bash
composer remove symfony/ux-turbo symfony/asset-mapper symfony/stimulus-bundle
composer require symfony/webpack-encore-bundle symfony/ux-turbo symfony/stimulus-bundle
```

## 03 Installer tailwind css

```bash
npm install tailwindcss @tailwindcss/postcss postcss postcss-loader
```

## 04 Activer le support de PostCSS support

On ajoute dans `webpack.config.js`, dans l'objet `Encore` la ligne `.enablePostCssLoader()`, cettte commande le fait direct

```js
sed -i "/Encore/a \ \ .enablePostCssLoader()" webpack.config.js
```

## 05 Configurer PostCSS Plugins

On génère le fichier `postcss.config.mjs` et on le rempli avec cette commande

```bash
touch postcss.config.mjs
cat << 'EOF' > postcss.config.mjs
export default {
  plugins: {
    "@tailwindcss/postcss": {},
  },
};
EOF
```

## 06 Import de tailwind dans le css

Dans le fichier `assets/styles/app.css` on fait les imports auto avec cette commande

```bash
sed -i '1i\
@tailwind base;\
@tailwind components;\
@tailwind utilities;
' assets/styles/app.css
```

## 07 On lance le processus de tailwind

Avec watch il surveille les changement pour build le css au fur et à mesure

```bash
npm run watch
```

## 08 Utiliser tailwind dans notre projet symfony

Par exemple on créé un controller home pour notre page d'accueil.

```bash
symfony console ma:con Home
```

On l'ouvre (`src/Controller/HomeController.php`), et on lui modifie sa route `/kome` par `/`

Ensuite on va dans sa vue (`templates/home/index.html.twig`) et on la remplace par


```twig
{% extends 'base.html.twig' %}

{% block body %}
    <h1 class="text-3xl font-bold underline">
      Hello world!
    </h1>
{% endblock %}
```

