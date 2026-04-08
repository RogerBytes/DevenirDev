# 05 - UX Icons

Ce bundle est conçu pour sa rapidité.
Basé sur [la partie icônes de Symfony UX](https://ux.symfony.com/icons) et sa [doc](https://symfony.com/bundles/ux-icons/current/index.html).

## Installation

Pour l'installer, ainsi que l'outil pour importer des icône en local

```bash
composer require symfony/ux-icons
composer require symfony/http-client
```

## Importer auto en local via Lock

Afin d’empêcher une màj de l'icon set distante de changer l’icône utilisée dans votre projet, on verrouille, ça va chercher toutes les icônes utilisée en twig présentes et les importer en local, donc plus de risque de changement.

```bash
php bin/console ux:icons:lock
```

## Importer manuellement des icônes en local

En me basant [sur la partie icon sets](https://symfony.com/bundles/ux-icons/current/index.html#icon-sets), on sait qu'il faut par exemple, pour importer [Tabler](https://tabler.io/icons), on fait :

On peut importer une icône (ici pour l’icône `check`)

```bash
symfony console ux:icons:import tabler:check
```

On peut bien sûr en importer autant que l'on veut d'un coup

Si je cherche une icône (ici pour une `arrow`), je fais

```bash
symfony console ux:icons:search tabler arrow
```

Exemple en twig

```twig
{{ ux_icon('user-profile', {class: 'w-6 h-6'}) }}

# renders "user-profile.svg" with fill="currentColor"
{{ ux_icon('user-profile') }}

# renders "user-profile.svg" with fill="red"
{{ ux_icon('user-profile', {fill: 'red'}) }}

{{ ux_icon('user-profile', {class: 'w-4 h-4', 'aria-label': 'User Profile'}) }}
```

## Charger les icônes dans le cache avec warm

Pour dev, on utilise les icônes à la demandes, mais une fois en prod, on va importer via lock (expliqué plus haut) et les précharger dans le cache via warm

```bash
symfony console ux:icons:warm-cache
```
