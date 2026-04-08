# Bootstrap

Bootstrap est un framework CSS qui accélère la création d’interfaces responsive grâce à une grille flexible et de nombreux composants prêts à l’emploi ; cette documentation vous guide pas à pas, de l’installation avec Vite jusqu’à l’utilisation pratique des classes, de la grille et du SCSS.

## Index

- [Bootstrap](#bootstrap)
  - [Index](#index)
  - [Ajouter Bootstrap à un projet](#ajouter-bootstrap-à-un-projet)
    - [Utiliser le CDN](#utiliser-le-cdn)
    - [Installer avec NPM](#installer-avec-npm)
  - [Utilisation de Bootstrap](#utilisation-de-bootstrap)
    - [Extensions Codium](#extensions-codium)
    - [Initialisation du projet](#initialisation-du-projet)
    - [Balisage et couleurs](#balisage-et-couleurs)
    - [Les breakpoints](#les-breakpoints)
    - [La grille Bootstrap](#la-grille-bootstrap)
    - [Breakpoint dans une grid Bootstrap](#breakpoint-dans-une-grid-bootstrap)
    - [Utilisation du margin et du padding](#utilisation-du-margin-et-du-padding)
    - [Mettre du gap entre les colonnes](#mettre-du-gap-entre-les-colonnes)
    - [Utiliser des components Bootstrap](#utiliser-des-components-bootstrap)
    - [Boutons](#boutons)
    - [Modales](#modales)
    - [Modification de variables Bootstrap](#modification-de-variables-bootstrap)
      - [Utiliser une variable Bootstrap](#utiliser-une-variable-bootstrap)
      - [Modifier une variable Bootstrap](#modifier-une-variable-bootstrap)
  - [Mise en place de Vite pour React/Angular](#mise-en-place-de-vite-pour-reactangular)
    - [Initialisation du projet Vite](#initialisation-du-projet-vite)
    - [Initialiser le dépôt local](#initialiser-le-dépôt-local)
    - [Créer un dépôt distant](#créer-un-dépôt-distant)
    - [Activer le remote](#activer-le-remote)
    - [Premier envoi](#premier-envoi)
      - [Création d'un fichier `README.md`](#création-dun-fichier-readmemd)
      - [Premier "git add" et "git commit"](#premier-git-add-et-git-commit)
      - [Premier "git push" (IMPORTANT)](#premier-git-push-important)
    - [Création de la structure du projet](#création-de-la-structure-du-projet)
    - [Configurer Vite](#configurer-vite)
      - [Remplir `vite.config.js`](#remplir-viteconfigjs)
      - [Remplir `src/index.html`](#remplir-srcindexhtml)
      - [Ajout du script npm](#ajout-du-script-npm)
      - [Démarrer Vite](#démarrer-vite)
    - [Importer Bootstrap](#importer-bootstrap)
      - [Import du CSS](#import-du-css)
      - [Import du JS](#import-du-js)
    - [Utilisation de Sass en custom scss](#utilisation-de-sass-en-custom-scss)
      - [Modifier des variables Bootstrap](#modifier-des-variables-bootstrap)
  - [Auteur](#auteur)

---

## Ajouter Bootstrap à un projet

Pour installer Bootstrap on peut passer par le CDN (une connexion au site de Bootstrap) ou via npm, un gestionnaire de paquets Node.js (qui l'installe dans votre projet).

Les instructions suivantes proviennent [de la page dédiée bootstrap](https://getbootstrap.com/), vérifiez qu'elles soient à jour.

### Utiliser le CDN

Incluez-le dans votre `<head>`.

```html
<link
  href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.8/dist/css/bootstrap.min.css"
  rel="stylesheet"
  integrity="sha384-sRIl4kxILFvY47J16cr9ZwB07vP4J8+LH7qKQnuqkuIAvNWLzeN8tE5YBujZqJLB"
  crossorigin="anonymous"
/>
<script
  defer
  src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.8/dist/js/bootstrap.bundle.min.js"
  integrity="sha384-FKyoEForCGlyvwx9Hj09JcYn3nv7wiPVlz7YYwJrWVcXK/BmnVDxM+D2scQbITxI"
  crossorigin="anonymous"
></script>
```

Le defer est recommandé afin de ne pas bloquer le rendu quand le script se charge.

### Installer avec NPM

```bash
npm install bootstrap@5.3.8
```

Installez-le à la racine de votre projet git, puis incluez-le dans votre `<head>`.

```html
<link
  href="./node_modules/bootstrap/dist/css/bootstrap.min.css"
  rel="stylesheet"
/>
<script
  defer
  src="./node_modules/bootstrap/dist/js/bootstrap.bundle.min.js"
></script>
```

Si vous l'utilisez dans un projet côté serveur, du genre avec un environnement node.js suivez les indications [depuis cette page](https://getbootstrap.com/docs/5.3/getting-started/download/#package-managers).

## Utilisation de Bootstrap

Pour rédiger ce qui suit, j'ai suivi [ce tutoriel vidéo](https://www.youtube.com/watch?v=MTRHi0gxPEo).

### Extensions Codium

Depuis le marketplace avec mon petit programme `vsix-dl` conçu pour VSCodium (pour les extensions disponibles seulement pour VSCode), je lance l'installation via :

```bash
vsix-dl AnbuselvanRocky.Bootstrap5-vscode
vsix-dl hossaini.Bootstrap-intellisense
```

Cela permet d'installer `Bootstrap 5 Quick Snippets`, `Bootstrap IntelliSense`.

### Initialisation du projet

Je crée un index

```bash
touch index.html
```

et à l'intérieur j'utilise le snippet natif `!` (qui utilise la dernière version de html) et je lance live server via `clic droit` + `Open with Live Server`,  le lien généré par Live Server est

```https
http://127.0.0.1:5500/
```

### Balisage et couleurs

Voici les balises html textuelles habituelles, pour rappel.

```html
<p>Texte <mark>surligné</mark></p>
<p>Texte <del>supprimé</del></p>
<p>Texte <s>dépassé et barré</s></p>
<p>Texte <ins>Ajouté au document</ins></p>
<p>Texte <u>souligné</u></p>
<p>Texte <small>en petits caractères</small></p>
<p>Texte <strong>mis en évidence en gras</strong></p>
<p>Texte <em>mis en italique</em></p>
```

On peut changer la couleur du texte via des classes BS.

```html
<p class="text-primary">.text-primary en bleu</p>
<p class="text-secondary">.text-secondary en gris</p>
<p class="text-success">.text-success en vert</p>
<p class="text-danger">.text-danger en rouge</p>
<p class="text-warning">.text-warning en jaune</p>
<p class="text-info">.text-info en bleu ciel</p>
<p class="text-light bg-secondary">.text-light en gris clair</p>
<p class="text-dark bg-secondary">.text-dark en noir</p>
<p class="text-muted">.text-muted en gris, utile pour les liens désactivés</p>
<p class="text-white bg-secondary">.text-white en blanc</p>
```

Les couleurs de Bootstrap sont `primary`, `secondary`, `success`, `danger`, `warning`, `info`, `light`, `dark`, `muted` et `white`.

### Les breakpoints

Les _breakpoints_ sont des largeurs personnalisables qui déterminent comment votre mise en page responsive se comporte selon la taille de l’appareil ou de la fenêtre dans Bootstrap.

Pour faire simple, les valeurs à utiliser pour du responsive sont

- Vue Mobile (extra small) : col ou col-{nombre}, implicite, pas de xs (pour du <576px)
- Vue Tablette (medium) : col-md-{nombre} (pour du ≥768px, dispensable, tablette et desktop ont la le même rendu)
- Vue Desktop (large) : col-lg-{nombre} (pour du ≥992px)

C'est en réalité une media query interne à Bootstrap.

Chaque breakpoint remplace le précédent dès que la largeur devient suffisante, si une classe existe. Pour le mobile extra small, on n’écrit rien, c’est implicite.
Voici un exemple de code permettant de comprendre le breakpoint

```html
<style>
  .container-fluid {
    background-color: aqua;
    border: 1px darkblue;
  }
</style>

<div class="container-fluid">Container</div>
```

Si vous remplacez `container-fluid` par `container` vous verrez alors qu'en étirant en largeur, le container ne s'étalera plus à 100% du viewport passé une certaine largeur.

`fluid` est une valeur spéciale de breakpoint, indiquant de s'étendre à 100% tout le temps.

### La grille Bootstrap

Bootstrap utilise un système de grille inspiré du CSS Grid, basé sur un layout de 12 colonnes par ligne (`row`).

- Si vous utilisez des classes `col-{nombre}`, la somme des colonnes est limitée à 12 par ligne, et les colonnes excédentaires passent à la ligne suivante.
- Si vous utilisez simplement `col`, chaque colonne prend une part égale de l’espace disponible, et vous pouvez avoir plus de 12 colonnes sur une seule ligne si la largeur le permet, mais uniquement si on utilise `col` sans chiffre, en auto répartition.

on utilise `.row` et `.col` pour générer les row et les columns.

```html
<body>
  <style>
    .container,
    .row div {
      background-color: aqua;
      border: 1px dashed red;
    }
  </style>

  <div class="container">
    <div class="row text-center">
      <div class="col-3">col 3</div>
      <div class="col-3">col</div>
      <div class="col-3">col</div>
      <div class="col-3">col</div>
    </div>
  </div>
</body>
```

(le style inline est acceptable pour le tuto, dans un vrai projet on importe un fichier css dans le `<head>`)

Ici, il y a 4 colonnes de 3/12 de largeur, elles s’étirent donc correctement.
Si vous ajoutez une colonne supplémentaire ou modifiez une colonne en col-4 de façon à dépasser 12, elle ira automatiquement à la ligne suivante.

Pour que vos lignes s’étendent proprement avec les colonnes, il est recommandé que la somme des tailles fasse 12 colonnes.

### Breakpoint dans une grid Bootstrap

Si l'on commence à faire notre site en "mobile-first" (c'est à dire la version portrait et plus petite en premier, ce qui est recommandé).

Pour le mobile : on écrit simplement `col` ou `col-{nombre}` (ex. `col-12`). Il n’existe pas de préfixe `xs` dans Bootstrap 5 ; c’est implicite par défaut. Pour la tablette on utilise `col-md-` et pour la vue desktop on se sert de `col-lg-`.

Mis en pratique cela donne ceci :

```html
<body>
  <style>
    .container,
    .row div {
      background-color: aqua;
      border: 1px dashed darkblue;
    }
  </style>

  <div class="container">
    <div class="row text-center justify-content-center">
      <div class="col-12 col-md-6 col-lg-4">col 1</div>
      <div class="col-12 col-md-6 col-lg-4">col 2</div>
      <div class="col-12 col-md-6 col-lg-4">col 3</div>
      <div class="col-12 col-md-6 col-lg-4">col 4</div>
    </div>
  </div>
</body>
```

Chaque breakpoint remplace le précédent dès que la largeur devient suffisante, si une classe existe, comme ici, il y a la largeur par défaut (vue mobile), `md` et `lg` (xs est implicite, utilisé par défaut, on ne peut pas le préciser).

Explication :

- `col-12` en vue mobile "extra small" (on n'écrit pas "xs" c'est mis par défaut) étend l'élément sur l'ensemble du layout (de douze colonnes), donc un élément par ligne en mobile
- `col-md-6` en vue tablet "medium" étend l'élément sur 6/12e du layout, donc deux éléments par ligne en tablet
- `col-lg-4` en vue desktop "large" étend l'élément sur 4/12e du layout, donc trois éléments par ligne en desktop

Et si on ne souhaite pas faire de breakpoint (en gros le même affichage peu importe le support) on peut également définir un nombre de colonne par défaut par ligne (pour des colonnes avec la même taille) avec `row-cols-` suivi du nombre de colonnes désirées.

```html
<body>
  <style>
    .container,
    .row div {
      background-color: aqua;
      border: 1px dashed darkblue;
    }
  </style>

  <div class="container">
    <div class="row text-center justify-content-center row-cols-3">
      <div class="col">col 1</div>
      <div class="col">col 2</div>
      <div class="col">col 3</div>
      <div class="col">col 4</div>
    </div>
  </div>
</body>
```

On utilise `col` comme classe pour chaque élément, ici nous avons donc trois colonnes par ligne. Attention, si l'on donne une largeur à `col-{nombre}` à un ou des éléments, ça prend le dessus sur `row-cols-` sur la ligne modifiée.

On remarque aussi que j'ai utilisé `justify-content-center` dans mon exemple, (il s'agit bien de Flexbox derrière Bootstrap), donc l'on peut utiliser ses variantes :

- `justify-content-start` → aligne les éléments au début de la ligne (à gauche en LTR)
- `justify-content-end` → aligne les éléments à la fin de la ligne (à droite en LTR)
- `justify-content-center` → centre les éléments horizontalement
- `justify-content-between` → espace les éléments pour qu’il y ait le maximum d’espace entre eux
- `justify-content-around` → espace les éléments avec un espace égal autour de chaque élément
- `justify-content-evenly` → espace les éléments avec un espacement égal entre eux et aux extrémités

Pareil pour `align-items` et `align-self` (voir documentation de Flexbox).

Il est aussi parfaitement possible de faire du nesting (de l'imbrication), à l'intérieur des cellules d'un grid Bootstrap, le fonctionnement est similaire à du Grid classique, voici un exemple :

```html
<body>
  <style>
    .container,
    .row div {
      background-color: aqua;
      border: 1px dashed darkblue;
    }
  </style>

  <div class="container">
    <div class="row text-center justify-content-center">
      <div class="col-12 col-md-6 col-lg-4">col 1</div>
      <div class="col-12 col-md-6 col-lg-4">col 2</div>
      <div class="col-12 col-md-6 col-lg-4">col 3</div>
      <div class="col-12 col-md-6 col-lg-4">
        <div class="row row-cols-2">
          <div class="col bg-success">nested 1 in col 4</div>
          <div class="col bg-warning">nested 2 in col 4</div>
        </div>
      </div>
    </div>
  </div>
</body>
```

### Utilisation du margin et du padding

- **Padding** : c’est l’espace **à l’intérieur** d’un élément, entre le contenu et sa bordure. Exemple : `padding: 10px`, le texte ne touchera pas directement les bords du div.
- **Margin** : c’est l’espace **à l’extérieur** d’un élément, entre cet élément et les autres éléments autour. Exemple : `margin: 10px` éloigne le div de ses voisins.

En Bootstrap, il y a des classes pratiques pour les deux :

- `p-1` à `p-5` → padding sur tous les côtés
- `pt-1` → padding-top, `pb-2` → padding-bottom, etc.
- `m-1` à `m-5` → margin sur tous les côtés
- `mt-2` → margin-top, `mx-3` → margin horizontal, `my-4` → margin vertical
- `ms` → margin-start (gauche), `me` → margin-end (droit)

`ms` et `me` sont ici expliqué pour une écriture LTR (Left To Right).

On peut aussi utiliser `px-` et `py-` pour le paddings, ainsi que `m-` et `p-` si la marge et le pad sont identiques sur les axes x et y.

Représentation simplifiée :

```text
Margin
┌───────────────────────────┐
│ Border                    |
│ ┌───────────────────────┐ |
│ │ Padding               | |
│ │ ┌───────────────────┐ │ |
│ │ │     Content       │ │ |
│ │ └───────────────────┘ │ |
│ └───────────────────────┘ |
└───────────────────────────┘
```

Explications :

- **Content** : le texte, image ou élément à l'intérieur du div.
- **Padding** : espace entre le contenu et la bordure du div.
- **Border** : la bordure du div (optionnelle).
- **Margin** : espace entre ce div et les autres éléments autour.

Par exemple, en reprenant une grid Bootstrap

```html
<body>
  <style>
    .container,
    .row div {
      background-color: aqua;
      border: 1px dashed darkblue;
    }
  </style>

  <div class="container">
    <div
      class="row text-center justify-content-center row-cols-2 p-5 m-2 bg-danger"
    >
      <div class="col bg-primary text-light">nested</div>
      <div class="col bg-secondary text-light">nested</div>
    </div>

    <div class="row text-center justify-content-center">
      <div class="col-12 col-md-6 col-lg-4">col 1</div>
      <div class="col-12 col-md-6 col-lg-4">col 2</div>
      <div class="col-12 col-md-6 col-lg-4">col 3</div>
      <div class="col-12 col-md-6 col-lg-4">
        <div class="row row-cols-2 bg-primary pt-2 pb-5 mx-2 my-3">
          <div class="col bg-success">nested 1 in col 4</div>
          <div class="col bg-warning">nested 2 in col 4</div>
        </div>
      </div>
    </div>
  </div>
  <body></body>
</body>
```

On voit (via live server) assez nettement les marges et les pad avec les différentes couleurs.

### Mettre du gap entre les colonnes

Au niveau de la classe, c'est pareil que pour le margin et le padding, mais avec la lettre `g`.

```html
<body>
  <style>
    .container,
    .row div {
      background-color: aqua;
      border: 1px dashed darkblue;
    }
  </style>

  <div class="container">
    <div
      class="row text-center justify-content-center my-3 gx-2 gy-1 bg-danger"
    >
      <div class="col-10 col-md-5 col-lg-3 bg-primary text-light">nested</div>
      <div class="col-10 col-md-5 col-lg-3 bg-secondary text-light">nested</div>
    </div>

    <div class="row text-center justify-content-center g-2 bg-secondary">
      <div class="col-10 col-md-5 col-lg-2">col 1</div>
      <div class="col-10 col-md-5 col-lg-2">col 2</div>
      <div class="col-10 col-md-5 col-lg-2">col 3</div>
      <div class="col-10 col-md-5 col-lg-2">
        <div class="row row-cols-2 bg-primary pt-2 pb-5 mx-2 my-3">
          <div class="col bg-success">nested 1 in col 4</div>
          <div class="col bg-warning">nested 2 in col 4</div>
        </div>
      </div>
    </div>
  </div>
</body>
```

Attention, il faut faire attention à ce que les colonnes ne s'étalent pas sur l’entièreté du display de la grid avant d'ajouter un gap, sinon ça provoque un overflow !
Il vaut mieux une grid avec des colonnes bien réglées que de tricher en mettant la classe Bootstrap `overflow-hidden` sur le conteneur.

### Utiliser des components Bootstrap

Les composants Bootstrap sont des éléments préconçus (boutons, cartes, alertes, modals…) que l’on peut directement intégrer dans sa page pour gagner du temps et conserver une cohérence visuelle.

Les components (ou composants dans la langue de Molière) sont disponible dans la nav latérale de [la page "Docs" du site](https://getbootstrap.com/docs/5.3/getting-started/introduction/), c'est sur ces pages que j'ai pris les exemples qui vont suivre, il y a plein d'éléments prêts à être utilisés sur la documentation officielle de Bootstrap.

### Boutons

Voici des exemples de [boutons](https://getbootstrap.com/docs/5.3/components/buttons/).

```md
<button type="button" class="btn btn-primary">Primary</button>
<button type="button" class="btn btn-secondary">Secondary</button>
<button type="button" class="btn btn-success">Success</button>
<button type="button" class="btn btn-danger">Danger</button>
<button type="button" class="btn btn-warning">Warning</button>
<button type="button" class="btn btn-info">Info</button>
<button type="button" class="btn btn-light">Light</button>
<button type="button" class="btn btn-dark">Dark</button>

<button type="button" class="btn btn-link">Link</button>
```

On peut assigner les classes de boutons à d'autres éléments

```md
<a class="btn btn-primary" href="#" role="button">Link</a>
<a class="btn btn-outline-primary" href="#" role="button">Link outline</a>
<button class="btn btn-primary" type="submit">Button</button>
<input class="btn btn-primary" type="button" value="Input">
<input class="btn btn-primary" type="submit" value="Submit">
<input class="btn btn-primary" type="reset" value="Reset">
```

### Modales

Voici des exemples de [modales](https://getbootstrap.com/docs/5.3/components/modal/).

Ici je vais me servir du snippet (grâce aux extensions) `bs5-modal-toggle`, il va me copier tout le bloc nécessaire.

```html
<body>
  <div
    class="modal fade"
    id="exampleModalToggle"
    aria-hidden="true"
    aria-labelledby="exampleModalToggleLabel"
    tabindex="-1"
  >
    <div class="modal-dialog modal-dialog-centered">
      <div class="modal-content">
        <div class="modal-header">
          <h5 class="modal-title" id="exampleModalToggleLabel">Modal 1</h5>
          <button
            type="button"
            class="btn-close"
            data-bs-dismiss="modal"
            aria-label="Close"
          ></button>
        </div>
        <div class="modal-body">
          Show a second modal and hide this one with the button below.
        </div>
        <div class="modal-footer">
          <button
            class="btn btn-primary"
            data-bs-target="#exampleModalToggle2"
            data-bs-toggle="modal"
          >
            Open second modal
          </button>
        </div>
      </div>
    </div>
  </div>
  <div
    class="modal fade"
    id="exampleModalToggle2"
    aria-hidden="true"
    aria-labelledby="exampleModalToggleLabel2"
    tabindex="-1"
  >
    <div class="modal-dialog modal-dialog-centered">
      <div class="modal-content">
        <div class="modal-header">
          <h5 class="modal-title" id="exampleModalToggleLabel2">Modal 2</h5>
          <button
            type="button"
            class="btn-close"
            data-bs-dismiss="modal"
            aria-label="Close"
          ></button>
        </div>
        <div class="modal-body">
          Hide this modal and show the first with the button below.
        </div>
        <div class="modal-footer">
          <button
            class="btn btn-primary"
            data-bs-target="#exampleModalToggle"
            data-bs-toggle="modal"
          >
            Back to first
          </button>
        </div>
      </div>
    </div>
  </div>
  <a
    class="btn btn-primary"
    data-bs-toggle="modal"
    href="#exampleModalToggle"
    role="button"
    >Open first modal</a
  >
</body>
```

`data-bs-toggle="modal"` et `data-bs-target="#id"` sont essentiels pour que le bouton ouvre la modale correspondante dans cet exemple.

On peut maintenant modifier chaque classe et id au besoin, pareil pour les contenu des éléments.

### Modification de variables Bootstrap

Cette section explique comment exploiter les variables CSS de Bootstrap directement, pour adapter rapidement certaines couleurs, espacements et styles sans avoir besoin de compiler les fichiers SCSS.

#### Utiliser une variable Bootstrap

On ajoute une classe `.custom-button` au style de la page, et au lieu de.

```html
<body>
  <style>
    .container,
    .row div {
      background-color: aqua;
      border: 1px dashed darkblue;
    }

    .custom-button {
      border: 2px solid red;
    }
  </style>

  <button type="button" class="btn btn-primary custom-button">Primary</button>
  <!-- on a ajouté notre classe sur le bouton au dessus -->
  <button type="button" class="btn btn-secondary">Secondary</button>
  <button type="button" class="btn btn-success">Success</button>
  <button type="button" class="btn btn-danger">Danger</button>

  <p>Texte <mark>surligné</mark></p>
  <p>Texte <del>supprimé</del></p>
  <p>Texte <s>dépassé et barré</s></p>
  <p>Texte <ins>Ajouté au document</ins></p>
  <p>Texte <u>souligné</u></p>
  <p>Texte <small>en petits caractères</small></p>
  <p>Texte <strong>mis en évidence en gras</strong></p>
  <p>Texte <em>mis en italique</em></p>
</body>
```

Maintenant on va apprendre à modifier les variables de Bootstrap pour changer la famille de fonts.

Dans le navigateur, ouvrez les outils développeur avec F12, allez dans `Inspecteur` (ou Elements sur Chrome) et cliquez sur `html` (il se trouve en premier dans le flux).

On peut également utiliser une variable couleur pour notre classe custom de bouton, par exemple var(--bs-orange). Que Bootstrap soit chargé via CDN ou local, ces variables CSS sont déjà disponibles.

```html
<body>
  <style>
    .container,
    .row div {
      background-color: aqua;
      border: 1px dashed darkblue;
    }

    .custom-button {
      border: 2px solid var(--bs-orange);
    }
  </style>

  <button type="button" class="btn btn-primary custom-button">Primary</button>
  <!-- on a ajouté notre classe sur le bouton au dessus -->
  <button type="button" class="btn btn-secondary">Secondary</button>
  <button type="button" class="btn btn-success">Success</button>
  <button type="button" class="btn btn-danger">Danger</button>

  <p>Texte <mark>surligné</mark></p>
  <p>Texte <del>supprimé</del></p>
  <p>Texte <s>dépassé et barré</s></p>
  <p>Texte <ins>Ajouté au document</ins></p>
  <p>Texte <u>souligné</u></p>
  <p>Texte <small>en petits caractères</small></p>
  <p>Texte <strong>mis en évidence en gras</strong></p>
  <p>Texte <em>mis en italique</em></p>
</body>
```

#### Modifier une variable Bootstrap

Maintenant, changeons les familles de fonts grâce à la pseudo-classe CSS `:root` pour modifier `--bs-font-sans-serif` que l'on voit dans la fenêtre style de l'inspecteur F12.

```css
--bs-font-sans-serif: system-ui, -apple-system, "Segoe UI", Roboto, "Helvetica Neue",
  "Noto Sans", "Liberation Sans", Arial, sans-serif, "Apple Color Emoji", "Segoe UI Emoji",
  "Segoe UI Symbol", "Noto Color Emoji";
--bs-font-monospace: SFMono-Regular, Menlo, Monaco, Consolas, "Liberation Mono",
  "Courier New", monospace;
```

```html
<body>
  <style>
    .container,
    .row div {
      background-color: aqua;
      border: 1px dashed darkblue;
    }

    .custom-button {
      border: 2px solid var(--bs-orange);
    }

    :root {
      --bs-font-sans-serif: "Poppins";
    }
  </style>

  <button type="button" class="btn btn-primary custom-button">Primary</button>
  <!-- on a ajouté notre classe sur le bouton au dessus -->
  <button type="button" class="btn btn-secondary">Secondary</button>
  <button type="button" class="btn btn-success">Success</button>
  <button type="button" class="btn btn-danger">Danger</button>

  <p>Texte <mark>surligné</mark></p>
  <p>Texte <del>supprimé</del></p>
  <p>Texte <s>dépassé et barré</s></p>
  <p>Texte <ins>Ajouté au document</ins></p>
  <p>Texte <u>souligné</u></p>
  <p>Texte <small>en petits caractères</small></p>
  <p>Texte <strong>mis en évidence en gras</strong></p>
  <p>Texte <em>mis en italique</em></p>
</body>
```

---

## Mise en place de Vite pour React/Angular

Pour développer rapidement des applications React ou Angular, nous allons configurer Vite, un bundler (outil qui regroupe tous vos fichiers JS, CSS et assets en un seul paquet optimisé) avec hot reload (rechargement instantané de la page quand vous modifiez votre code, sans perdre l’état de l’application).

### Initialisation du projet Vite

On crée le projet (en suivant [la doc officielle BS](https://getbootstrap.com/docs/5.3/getting-started/vite/))

```bash
mkdir BootstrapLearning && cd BootstrapLearning
npm init -y
```

Nb: Remplacez `BootstrapLearning` par le nom de votre projet.

Ensuite on installe la version dev de vite

```bash
npm i --save-dev vite
```

Puis on installe Bootstrap et Sass (requis pour importer et compiler le CSS)

```bash
npm i --save bootstrap @popperjs/core
npm i --save-dev sass
```

### Initialiser le dépôt local

```bash
git init
```

### Créer un dépôt distant

Je créé un dépôt distant du même nom sur mon org de github

```bash
gh repo create RogerBytes/BootstrapLearning --public
```

Nb: Remplacez `RogerBytes` par le nom de votre repo gh ou de votre organisation gh.

### Activer le remote

```bash
git remote add origin git@github.com:RogerBytes/BootstrapLearning.git
```

### Premier envoi

#### Création d'un fichier `README.md`

Il est impossible de push depuis votre dépôt local vers le distant si le premier est vide
Créez donc un fichier `README.md` (vide) avec :

```bash
touch README.md
```

#### Premier "git add" et "git commit"

```bash
git add --all && git commit -m "First commit"
```

#### Premier "git push" (IMPORTANT)

Le premier push est différent :

```bash
git push --set-upstream origin master
```

Voilà, `Vite` ainsi que notre branche distante et locale sont initialisés correctement.

### Création de la structure du projet

```bash
mkdir {src,src/js,src/scss}
touch src/index.html src/js/main.js src/scss/styles.scss vite.config.js
```

Voici une représentation visuelle de la structure

```text
BootstrapLearning/
├── src/
│   ├── js/
│   │   └── main.js
│   └── scss/
│   |   └── styles.scss
|   └── index.html
├── package-lock.json
├── package.json
└── vite.config.js
```

Tout est en place, il nous reste plus qu'à configurer Vite en complétant `vite.config.js`.

### Configurer Vite

#### Remplir `vite.config.js`

Ouvrez `vite.config.js` dans votre IDE, il est vide, copiez dedans :

```js
import { resolve } from "path";

export default {
  root: resolve(__dirname, "src"),
  build: {
    outDir: "../dist",
  },
  server: {
    port: 8080,
  },
  // Optional: Silence Sass deprecation warnings. See note below.
  css: {
    preprocessorOptions: {
      scss: {
        silenceDeprecations: [
          "import",
          "mixed-decls",
          "color-functions",
          "global-builtin",
        ],
      },
    },
  },
};
```

Lorsque l'on compile le sass (en css) on peut ignorer les éventuels messages d'alertes comme quoi c'est déprécié, c'est pas un souci (un fix est en cours dans l'équipe de Vite).

#### Remplir `src/index.html`

Maintenant on va éditer `src/index.html` (la page lancée dans le navigateur par Vite)

```html
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>Bootstrap w/ Vite</title>
    <script type="module" src="./js/main.js"></script>
  </head>
  <body>
    <div class="container py-4 px-3 mx-auto">
      <h1>Hello, Bootstrap and Vite!</h1>
      <button class="btn btn-primary">Primary button</button>
    </div>
  </body>
</html>
```

#### Ajout du script npm

Il faut ouvrir `package.json` et y inclure (en ajoutant la ligne "start" aux scripts) ce script de démarrage :

```js
{
  // ...
  "scripts": {
    "start": "vite",
    "test": "echo \"Error: no test specified\" && exit 1"
  },
  // ...
}
```

#### Démarrer Vite

Nous pouvons lancer Vite de puis la racine du projet (via notre script npm)

```bash
npm start
```

Par défaut l'adesse en localhost est

```http
http://localhost:8080/
```

### Importer Bootstrap

#### Import du CSS

Pour importer bootstrap ouvrez `src/scss/styles.scss` dans votre IDE et ajoutez

```scss
// Import all of Bootstrap’s CSS
@import "bootstrap/scss/bootstrap";
```

#### Import du JS

Ouvrez `src/js/main.js` et ajoutez-y :

```js
// Import our custom CSS
import "../scss/styles.scss";

// Import all of Bootstrap’s JS
import * as bootstrap from "bootstrap";
```

Au besoin c'est dans ce fichier que vous pouvez importer des plugins JS de Bootstrap individuellement (afin de limiter la taille du bundle).

Par exemple (facultatif, destiné aux utilisateurs avancés)

```js
import Alert from "bootstrap/js/dist/alert";

// or, specify which plugins you need:
import { Tooltip, Toast, Popover } from "bootstrap";
```

Voilà, Vite ainsi que Bootstrap et Sass sont correctement configurés et prêts à l'usage !

---

### Utilisation de Sass en custom scss

Maintenant que l'on sait utiliser Bootstrap avec Vite il est très simple de faire du CSS customisé et de modifier Bootstrap. Pour des informations plus détaillées, consultez la page `Customize` [de la doc de Bootstrap](https://getbootstrap.com/docs/5.3/customize/overview/)

#### Modifier des variables Bootstrap

En bas de chaque section de la doc de Bootstrap, on trouve une section "CSS" qui contiennent les variables et informations nécessaires pour modifier Bootstrap.

Voici la structure correcte à utiliser pour les imports

```scss
// 1) Vos variables perso
$primary: #ff00aa;

// 2) Import Bootstrap
@import "bootstrap/scss/bootstrap";

// 3) Votre CSS additionnel
.card { border-radius: 1rem; }
```

Nous allons utiliser ici la [doc de la typographie](https://getbootstrap.com/docs/5.3/content/typography/), pour la typo on récupère ce qu'il y a à la fin de [Display Headings](https://getbootstrap.com/docs/5.3/content/typography/#display-headings).

```css
$display-font-sizes: (
  1: 5rem,
  2: 4.5rem,
  3: 4rem,
  4: 3.5rem,
  5: 3rem,
  6: 2.5rem
);

$display-font-family: null;
$display-font-style: null;
$display-font-weight: 300;
$display-line-height: $headings-line-height;
```

Pour chacune des sections de la doc de Bootstrap, vous trouverez les variables en bas de page, souvent dans une section `Sass variables`.

Pour modifier des variables bootstrap, ouvrir `src/scss/styles.css` faire ces modification avant l'import. Par exemple

```scss
$body-bg: green;
$primary: #ff4136;
$h1-font-size: 5rem;
$body-color: white;

// Import all of Bootstrap’s CSS
@import "bootstrap/scss/bootstrap";
```

On va modifier une card, on va se servir du snippet `bs5-card-background`, je vais le nest dans une `.row` et régler les `.col`, et l'on y ajoute aussi une modale avec `bs5-modal-default`

```html
<!-- Modal trigger button -->
<button
  type="button"
  class="btn btn-primary btn-lg"
  data-bs-toggle="modal"
  data-bs-target="#modalId"
>
  Launch
</button>

<!-- Modal Body -->
<!-- if you want to close by clicking outside the modal, delete the last endpoint:data-bs-backdrop and data-bs-keyboard -->
<div
  class="modal fade"
  id="modalId"
  tabindex="-1"
  data-bs-backdrop="static"
  data-bs-keyboard="false"
  role="dialog"
  aria-labelledby="modalTitleId"
  aria-hidden="true"
>
  <div
    class="modal-dialog modal-dialog-scrollable modal-dialog-centered modal-sm"
    role="document"
  >
    <div class="modal-content">
      <div class="modal-header">
        <h5 class="modal-title" id="modalTitleId">Modal title</h5>
        <button
          type="button"
          class="btn-close"
          data-bs-dismiss="modal"
          aria-label="Close"
        ></button>
      </div>
      <div class="modal-body">Body</div>
      <div class="modal-footer">
        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">
          Close
        </button>
        <button type="button" class="btn btn-primary">Save</button>
      </div>
    </div>
  </div>
</div>

<!-- Optional: Place to the bottom of scripts -->
<script>
  const myModal = new bootstrap.Modal(
    document.getElementById("modalId"),
    options
  );
</script>

<div class="container pt-1">
  <div class="row justify-content-center">
    <div class="col-12 col-md-6 col-lg-4 card text-white bg-primary">
      <img class="card-img-top" src="img/arale.webp" alt="Title" />
      <div class="card-body">
        <h4 class="card-title">Title</h4>
        <p class="card-text">Text</p>
      </div>
    </div>
    <div class="col-12 col-md-6 col-lg-4 card text-white bg-primary">
      <img class="card-img-top" src="img/arale.webp" alt="Title" />
      <div class="card-body">
        <h4 class="card-title">Title</h4>
        <p class="card-text">Text</p>
      </div>
    </div>
    <div class="col-12 col-md-6 col-lg-4 card text-white bg-primary">
      <img class="card-img-top" src="img/arale.webp" alt="Title" />
      <div class="card-body">
        <h4 class="card-title">Title</h4>
        <p class="card-text">Text</p>
      </div>
    </div>
    <div class="col-12 col-md-6 col-lg-4 card text-white bg-primary">
      <img class="card-img-top" src="img/arale.webp" alt="Title" />
      <div class="card-body">
        <h4 class="card-title">Title</h4>
        <p class="card-text">Text</p>
      </div>
    </div>
  </div>
</div>
```

et le style associé (vous pouvez décommenter et/ou faire vos essais).

```scss
// $body-bg: #181818;
// $primary: red;
// $h1-font-size: 5rem;
// $body-color: white;

// Import all of Bootstrap’s CSS
@import "bootstrap/scss/bootstrap";

.card {
  display: flex;
  flex-direction: column;
  align-items: center;
}

.card-img-top {
  width: 80%;
  height: auto;
}
```

Les bases de Bootstrap sont désormais acquises.

## Auteur

- [Harry RICHMOND](https://github.com/RogerBytes)
