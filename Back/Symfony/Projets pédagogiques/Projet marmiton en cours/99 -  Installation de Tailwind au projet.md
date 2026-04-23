# Tailwind

Depuis [la page d'install dédiée à Symfony](https://tailwindcss.com/docs/installation/framework-guides/symfony).

```bash
composer remove symfony/ux-turbo symfony/asset-mapper symfony/stimulus-bundle
composer require symfony/webpack-encore-bundle symfony/ux-turbo symfony/stimulus-bundle
```

Puis on install via npm

```bash
npm install tailwindcss @tailwindcss/postcss postcss postcss-loader
```

Dans `webpack.config.js`, juste en dessous du bloc `Encore`, on ajoute `.enablePostCssLoader()` ainsi

```javascript
Encore.enablePostCssLoader();
```

On créé `postcss.config.mjs`

```bash
touch postcss.config.mjs
```

et le remplir ainsi

```mjs
export default {
  plugins: {
    "@tailwindcss/postcss": {},
  },
};
```

Et on ouvre `assets/styles/app.css` et on ajoute ces imports (en début de fichier)

```css
@import "tailwindcss";
@source not "../../public";
```

Pour lancer Tailwind, il faut lancer watch (il va compiler le css en continu)

```bash
npm run watch
```

---

Petit exemple dans twig

```twig
{% extends 'base.html.twig' %}

{% block title %}
  Tailwind Sheep
{% endblock %}

{% block body %}
<h1 class="text-3xl font-bold underline bg-red-500">Listen</h1>
<pre class="text-xl">
I’ve seen things you people wouldn’t believe.
Attack ships on fire off the shoulder of Orion.
I watched C‑beams glitter in the dark near the Tannhäuser Gate.
All those moments will be lost in time, like tears in rain.
Time to die.
</pre>
{% endblock %}
```
