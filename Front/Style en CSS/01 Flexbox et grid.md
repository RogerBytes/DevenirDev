# Flexbox et Grid

## Préambule

En premier lieu, consultez cette [introduction au html](https://developer.mozilla.org/fr/docs/Learn_web_development/Core/Structuring_content) et [cette introduction au css](https://web.dev/learn/css). Puis suivez ce [cours de responsive design](https://web.dev/learn/design/).

Pour vous remettre aux sélecteur CSS, je recommande d'utiliser [CSS Diner](https://flukeout.github.io/) en premier lieu. Pour de la 3D il y a [Unfold](https://rupl.github.io/unfold/) (à faire après grid garden) et CSS Battle.

## Introduction

Ces deux outils sont très pratiques dans le cadre de l'affichage, grid permet de créer une espèce de découpage en tableau d'une boite, et Flexbox permet de déplacer les éléments dans une boîte.

Ces deux outils CSS sont indépendants mais peuvent être complémentaires.
Il n'est pas rare qu'ils soient utilisés conjointement, notamment en utilisant flexbox à l'intérieur de grid (le cas inverse n'existant pas à ma connaissance).

## Supports éducatifs

### Supports Flexbox

- [MDN Flexbox](https://developer.mozilla.org/fr/docs/Learn_web_development/Core/CSS_layout/Flexbox)
- [CSS Flexbox Layout Guide](https://css-tricks.com/snippets/css/a-guide-to-flexbox/)
- [Flexbox Froggy](https://flexboxfroggy.com/#fr)
- [Flexbox Zombies](https://flexboxzombies.com/)
- [Anchoreum](https://codepip.com/games/anchoreum/)

### Supports Grid

- [MDN Grid](https://developer.mozilla.org/fr/docs/Web/CSS/Guides/Grid_layout)
- [Grid Garden](https://cssgridgarden.com/#fr)
- [Outil de test Grid Playground](https://michalgrochowski.github.io/grid-playground/dist/)
- [cours freecodecamp](https://www.freecodecamp.org/news/heres-my-free-css-grid-course-merry-christmas-3826dd24f098/)

## Flexbox

Pour utiliser cette fonction CSS, sur chacun j'ai laissé la valeur par défaut.

On applique ce display sur un conteneur de la sorte

```css
.conteneur {
  display: flex; /* active Flexbox */
}
```

### Direction

Permet de changer les row en column, et au passage il permet de les inverser.

```css
flex-direction: row;
```

Attention, si l'on change l'axe des éléments d'une boîte élément avec `flex-directions`, `align-items` et `justify-content` ont leur rôles intervertis.

### Alignement horizontal du contenu d'une boîte

```css
justify-self: flex-start;
```

### Alignement vertical du contenu d'une boîte

```css
align-items: flex-start;
```

### Ordination d'un élément avec flex

Permet de changer l'ordre de l'élément dans sa boîte, fonctionne comme une array avec une indexation qui commence à zéro (l'index peut être également négatif tout comme une array).

```css
order: 0;
```

La valeur par défaut d'un élément est zéro, dont si un on met la valeur `1` à un ou plusieurs éléments, ils apparaîtront à la fin du flux (ou tout au début si on met `-1`).

### Alignement horizontal d'un élément

**Cela n'existe pas, car il faut passer par du margin-left/right en auto, ou via l'ordre du conteneur !**

### Alignement vertical d'un élément

Permet de forcer l'alignement d'un élément en faisant fi de l'alignement donné au contenu de la boîte parente

```css
align-self: flex-start;
```

### Overflow et étalage sur une nouvelle row

Par défaut, avec `display: flex`, **les éléments peuvent rétrécir grâce à `flex-shrink`** pour éviter l’overflow, mais pas en dessous de leur **taille minimale** (par exemple la taille du contenu s'il y a la valeur `auto` pour la taille).

Pour gérer l’espace quand les éléments sont trop serrés, on peut utiliser `flex-wrap`, qui les **fait passer sur une nouvelle ligne ou colonne** selon l’axe principal.

```css
flex-wrap: wrap; /* active le passage à la ligne ou colonne suivante */
```

On peut combiner direction et wrapping avec :

```css
flex-flow: column wrap; /* axe principal en colonne et wrapping activé */
```

## Grid

Pour utiliser cette fonction CSS, sur chacun j'ai laissé la valeur par défaut.

On applique ce display sur un conteneur de la sorte

```css
#conteneur {
  display: grid;
  grid-template-columns: 20% 20% 20% 20% 20%;
  grid-template-rows: 20% 20% 20% 20% 20%;
}
```

Ici on se retrouve avec 5 colonnes et 5 rows de même taille.

### Étendre un élément

```css
#garden {
  display: grid;
  grid-template-columns: 20% 20% 20% 20% 20%;
  grid-template-rows: 20% 20% 20% 20% 20%;
}

#water {
  grid-column-start: 1;
}
```

`#water` est un enfant de `#garden`, ici il ne se déploie que sur la toute première cellule.

```css
#water {
  grid-column-start: 1;
  grid-column-end: 4;
}
```

Dans l'exemple ici, `#water` s’étend sur les 3 premières cellules. On pourrait parfaitement utiliser des index négatifs et/ou inverser les coordonnées de début et de fin.
Attention, quand on rentre des coordonnée de cellule, les index correspondents aux lignes qui séparent les cellules et non les cellules elles-mêmes.

## Déterminer une largeur en fonction d'une largeur de span

Au lieu

```css
#garden {
  display: grid;
  grid-template-columns: 20% 20% 20% 20% 20%;
  grid-template-rows: 20% 20% 20% 20% 20%;
}

#water {
  grid-column-start: 2;
  grid-column-end: span 2;
}
```

Ici on utilise 2 cellule à partir de la deuxième ligne, donc sur les cellules 2 et 3.

### Ordination d'un élément avec grid

Permet de changer l'ordre de l'élément dans sa boîte, fonctionne comme une array avec une indexation qui commence à zéro (l'index peut être également négatif tout comme une array).

```css
order: 0;
```

La valeur par défaut d'un élément est zéro, dont si un on met la valeur `1` à un ou plusieurs éléments, ils apparaîtront à la fin du flux (ou tout au début si on met `-1`).

### Fonction repeat

Le fait de spécifier un ensemble de colonnes avec des largeurs identiques peut devenir fastidieux. Heureusement, il y a une fonction repeat pour nous aider.

```css
#garden {
  display: grid;
  grid-template-columns: repeat(8, 12.5%)
  grid-template-rows: 20% 20% 20% 20% 20%;
}

#water {
  grid-column: 1;
  grid-row: 1;
}

```

Par exemple, nous avons défini précédemment huit colonnes de 12.5% avec la règle `grid-template-columns: repeat(8, 12.5%)`.

### Unité fractionnaire FR

La grille introduit également une nouvelle unité, le fractionnaire `fr`.  
Chaque unité fr alloue une partie de l'espace disponible.  
Par exemple, si deux éléments sont définies respectivement avec 1fr et 3fr, l'espace est divisé en 4 parts égales, le premier élément occupant 1/4 et  
le deuxième élément 3/4 de l'espace disponible.

```css
#garden {
  display: grid;
  grid-template-columns: 1fr 5fr;
  grid-template-rows: 20% 20% 20% 20% 20%;
}
```

Ici, la première colonne représente 1/6 de votre première ligne et la deuxième les 5/6 restants.

### association des fr avec d'autre unités et grid area

Lorsque les colonnes sont définies avec des pixels, des pourcentages ou des ems, toutes les autres colonnes définies avec fr se répartiront l'espace restant.
Et `grid-area` permet de donner les index de ligne des colonnes et des row en une seul fois, ça fait `height-start/width-start/height-end/width-end`.

```css
#garden {
  display: grid;
  grid-template-columns: 50px 1fr 50px;
  grid-template-rows: 20% 20% 20% 20% 20%;
}

#water {
  grid-area: 1 / 1 / 6 / 2;
}

#poison {
  grid-area: 1 / 5 / 6 / 6;
}
```

Si on met `grid-template-columns: 50px repeat(3, 1fr) 50px;`, la grille créera 3 autres colonnes de taille identique sur l'espace restant.

### Créer des columns ou rows nulles

Ca permet de créer une colonne invisible s'il n'y a pas de contenu à l'intérieur.

```css
#garden {
  display: grid;
  grid-template-columns: 20% 20% 20% 20% 20%;
  grid-template-rows: 50px repeat(3, 0fr) 1fr;
}

#water {
  grid-column: 1 / 6;
  grid-row: 5 / 6;
}
```

Ici l'on a fait trois colonnes faisait une taille nulle (`0fr`).

### Grid Template

À la manière de `grid-area` pour le placement des contenus, `grid-template` permet de générer sa grille en donnant en même temps les rows et les columns.

```css
#garden {
  display: grid;
  grid-template: 60% 1fr / 200px 1fr;
}

#water {
  grid-column: 1;
  grid-row: 1;
}
```

Pour les valeurs ça fait `height-start/width-start/height-end/width-end`.
