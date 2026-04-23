# 03 Twig

Voici ce que nous dit [la doc Twig de Symfony](https://symfony.com/doc/current/templates.html)

> The Twig templating language allows you to write concise, readable templates that are more friendly to web designers and, in several ways, more powerful than PHP templates. Take a look at the following Twig template example. Even if it's the first time you see Twig, you probably understand most of it:

Twig est le moteur de template de symfony, il permet de faire du html plus complexe.

## Les layouts

Dans un premier temps on va faire hériter notre vue Home d’un template, pour cela nous allons demander d’étendre `base.html.twig` de la façon suivante :

```twig
{% extends 'base.html.twig' %}
```

Symfony lève l'erreur suivante

> A template that extends another one cannot include content outside Twig blocks. Did you forget to put the content inside a {% block %} tag in home.html.twig at line 4?

<!-- Commentaire caché -->

> [!NOTE] Quand on hérite d'un template, l'on ne peux pas ajouter/modifier du contenu en dehors de blocs.

Dans `base.html.twig` on remarque

```twig
{% block title %}Welcome!{% endblock %}
```

Et le bloc vide `body`

```twig
{% block body %}{% endblock %}
```

Donc on place notre contenu à l'intérieur

```twig
{% extends 'base.html.twig' %}

{% block title %}
  FirstProject - Accueil
{% endblock %}

{% block body %}
<h1>Citation de Roy Batty</h1>
<pre>
I’ve seen things you people wouldn’t believe.
Attack ships on fire off the shoulder of Orion.
I watched C‑beams glitter in the dark near the Tannhäuser Gate.
All those moments will be lost in time, like tears in rain.
Time to die.
</pre>
{% endblock %}
```

Ici l'on change le bloc `title` et l'on place notre contenu dans le bloc `body`.

Dans la barre profiler de symfony, nous avons le statut `200` en vert, signifiant que tout est ok.

On va utiliser une bibliothèque de composants tailwind, [daisyUI](https://daisyui.com/docs/install/)

```bash
npm i -D daisyui@latest
```

et on l'importe dans `assets/styles/app.css`

```css
@import "tailwindcss";
@plugin "daisyui";
```

Voici pour le tester dans `templates/home.html.twig`

```twig
{% extends 'base.html.twig' %}

{% block title %}
	Tailwind Sheep
{% endblock %}

{% block body %}
	<div class="min-h-screen bg-base-200 flex items-center justify-center p-6">

		<div class="card w-full max-w-2xl bg-base-100 shadow-xl">

			<div class="card-body">

				<h1 class="text-3xl font-bold">Listen</h1>

				<div class="divider"></div>

				<pre class="text-base leading-relaxed whitespace-pre-wrap">
I’ve seen things you people wouldn’t believe.
Attack ships on fire off the shoulder of Orion.
I watched C-beams glitter in the dark near the Tannhäuser Gate.
All those moments will be lost in time, like tears in rain.
Time to die.
			</pre>

				<div class="card-actions justify-end mt-4">
					<button class="btn btn-primary">Like</button>
					<button class="btn btn-secondary">Share</button>
				</div>

			</div>
		</div>

	</div>
{% endblock %}
```

On consulte [les thèmes daisyUI](https://daisyui.com/docs/themes/), ici je trouve que `coffee` est sympa en sombre, et `autumn` en thème clair.

On va activer ces thèmes dans `assets/styles/app.css`.

```css
@import "tailwindcss";
@plugin "daisyui" {
  themes: autumn --default, business --prefersdark;
}
@source not "../../public";

body {
    background-color: lightgray;
}
```

Dans `templates/base.html.twig`, on précise le thème avec `<html data-theme="business">` à l'intérieur du `head`.

Dans les [components de daisyUi](https://daisyui.com/components/), je vais dans les navbar et j'en séléctionne [une](https://daisyui.com/components/navbar/#responsive-dropdown-menu-on-small-screen-center-menu-on-large-screen).

On récupère le code de la nav

```html
<div class="navbar bg-base-100 shadow-sm">
  <div class="navbar-start">
    <div class="dropdown">
      <div tabindex="0" role="button" class="btn btn-ghost lg:hidden">
        <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor"> <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h8m-8 6h16" /> </svg>
      </div>
      <ul
        tabindex="-1"
        class="menu menu-sm dropdown-content bg-base-100 rounded-box z-1 mt-3 w-52 p-2 shadow">
        <li><a>Item 1</a></li>
        <li>
          <a>Parent</a>
          <ul class="p-2">
            <li><a>Submenu 1</a></li>
            <li><a>Submenu 2</a></li>
          </ul>
        </li>
        <li><a>Item 3</a></li>
      </ul>
    </div>
    <a class="btn btn-ghost text-xl">daisyUI</a>
  </div>
  <div class="navbar-center hidden lg:flex">
    <ul class="menu menu-horizontal px-1">
      <li><a>Item 1</a></li>
      <li>
        <details>
          <summary>Parent</summary>
          <ul class="p-2 bg-base-100 w-40 z-1">
            <li><a>Submenu 1</a></li>
            <li><a>Submenu 2</a></li>
          </ul>
        </details>
      </li>
      <li><a>Item 3</a></li>
    </ul>
  </div>
  <div class="navbar-end">
    <a class="btn">Button</a>
  </div>
</div>
```

Au lieu de mettre ça dans `base.html.twig`, on va le mettre dans un fichier séparé `_header.html.twig` qui se trouvera dans `templates/partials`.

On créé le répertoire `partials`

```bash
mkdir -p templates/partials
```

puis on créé le fichier `_header.html.twig`

```bash
touch templates/partials/_header.html.twig
```

Et on colle la navbar.

On va ajouter un bloc `header` dans `base.html.twig` et y ajouter un include vers notre header.

```twig
  {% block header %}
    {% include "partials/_header.html.twig" %}
  {% endblock %}
```

Voilà, la navbar est chargée, on va maintenant retirer le fond bleu par défaut de Symfony 7, il suffit d'aller éditer `assets/styles/app.css`.

Et on remplace notre page `home.html.twig` par :

```twig
{% extends "base.html.twig" %}
{% block title %}
	SymfoMarmiton - Accueil
{% endblock %}
{% block body %}
	<div class="container mt-4">
		<div class="jumbotron">
			<h1 class="display-4">Bienvenue sur SymfoMarmiton</h1>
			<p class="lead">
				SymfoMarmiton est une application qui va te
        permettre de créer des recettes à base d'ingrédients que tu auras toi-même
        créé. Tu pourras partager tes recettes à la communauté du site, ou bien les
        garder en privées.
      </p>
			<hr class="my-4">
			<p>Pour commencer, rendez-vous sur la page d'inscription pour utiliser l'application.</p>
			<a class="btn btn-primary btn-lgz" href="#" role="button">Inscription</a>
		</div>
	</div>
{% endblock %}
```

Et on raccourcit `_header.html.twig` ainsi :

```twig
<nav class="navbar navbar-expand-lg bg-primary" data-bs-theme="dark">
  <div class="container-fluid">
    <a class="navbar-brand" href="#">Navbar</a>
    <button
      class="navbar-toggler"
      type="button"
      data-bs-toggle="collapse"
      data-bs-target="#navbarColor01"
      aria-controls="navbarColor01"
      aria-expanded="false"
      aria-label="Toggle navigation"
    >
      <span class="navbar-toggler-icon"></span>
    </button>
    <div class="collapse navbar-collapse" id="navbarColor01">
      <ul class="navbar-nav me-auto">
        <li class="nav-item">
          <a class="nav-link active" href="#"
            >Home
            <span class="visually-hidden">(current)</span>
          </a>
        </li>
      </ul>
    </div>
  </div>
</nav>
```

Voilà, les bases de TWIG sont finies.

<span hidden>
<details><summary></summary>
<style>.spoiler{border-left:4px solid #1abc9c;border-bottom-left-radius:3px;padding-left:10px;padding-top:15px;margin-top:-10px;margin-bottom:15px}.button{cursor:pointer;padding:5px 10px;background-color:#3498db;color:white;border-radius:3px;margin-bottom:5px;display:inline-block;transition:background-color 0.2s}.button:hover{background-color:#217dbb}details[open] .button{background-color:#1ab