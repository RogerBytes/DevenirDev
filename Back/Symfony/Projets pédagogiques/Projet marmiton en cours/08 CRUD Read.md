# 07 CRUD Read

Nous allons créer un CRUD dans l'entité `Ingredient`, pour rappel :

- **C**reate
- **R**ead
- **U**pdate
- **D**elete

On consulte ici [la doc pour fetcher les objets depuis la BDD](https://symfony.com/doc/current/doctrine.html#fetching-objects-from-the-database).

Regardons ce que l’on nous dit : il suffit d’utiliser le repository fourni par Doctrine pour récupérer les objets depuis la base de données, et nous allons utiliser une méthode qui permet de récupérer un ou plusieurs objets. Ici on voudra récupérer tous les ingrédients.

Regardons dans notre projet le repository `src/Repository/IngredientRepository.php`.

Dans l'exemple de la documentation :

```php
$product = $entityManager->getRepository(Product::class)->find($id);
```

La doc utilise la méthode `find()` avec la var `$id` comme paramètre.

Nous souhaitons tout récupérer et comme nous l’avons vu dans notre repository nous pouvons
utiliser le `findAll()` (car `src/Repository/IngredientRepository.php` étend `ServiceEntityRepository`), la méthode `findAll()` ne prend aucun paramètre.

## Création du contrôleur

Pour réaliser un crud nous aurons besoin du controller, il faudra donc le créer avec la commande

```bash
symfony console make:controller Ingredient
```

Ici nous utilisons la commande en mettant directement le nom du contrôleur, mais nous aurions pu ne pas le passer, les interactions de la CLI de symfony aurait demandé comment nommer le contrôleur.

Cette commande créé le contrôleur ainsi que le template qui va avec.

Pour mieux organiser notre projet nous allons créer un répertoire `pages` dans le répertoire `templates`.

```bash
mkdir -p templates/pages
```

Nous y déplaçons le répertoire `templates/ingredient`, ainsi que le fichier `/home/harry/Local/Git/FirstProject/templates/home.html.twig`

Maintenant on va `src/Controller/HomeController.php` et l'on y modifie le chemin dans `render()` (càd `render("pages/home.html.twig");`).

Idem dans `src/Controller/IngredientController.php`; voici ce que cela donne

```php
<?php

namespace App\Controller;

use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Attribute\Route;

final class IngredientController extends AbstractController
{
    #[Route('/ingredient', name: 'app_ingredient')]
    public function index(): Response
    {
        return $this->render('pages/ingredient/index.html.twig', [
            'controller_name' => 'IngredientController',
        ]);
    }
}
```

- `/ingredient` est la route, c'est ce qu'il faut taper dans l'url
- `name: 'app_ingredient'` c'est le nom de la route.
- `pages/ingredient/index.html.twig` c'est le chemin du template dont il fait le rendu
- `'controller_name' => 'IngredientController',` c'est une déclaration/affectation de variable (ici `$controller_name`) pour la vue.

Sur notre navigateur web, sur la page <http://127.0.0.1:8000/ingredient>, nous voyons le rendu par défaut du template créé par Symfony.

Maintenant l'on modifie `templates/pages/ingredient/index.html.twig`.

On y met juste le bloc `title` modifié

```twig
{% extends 'base.html.twig' %}

{% block title %}SymfoMarmiton - Mes ingrédients{% endblock %}

{% block body %}

{% endblock %}
```

Maintenant on retourne sur le contrôleur `src/Controller/IngredientController.php`, dans sa méthode publique `index()`, on commence par injecter en dépendance le repository `IngredientRepository` dans ses paramètres (et on nomme la variable locale qui reçoit cet objet).
L'injection est automatisée par Symfony, contrairement à une instanciation manuelle.

Voici comment faire

```php
// (...)
public function index(IngredientRepository $ingredientRepository): Response
// (...)
```

Ainsi l'on pourra appeler les méthodes du IngredientRepository avec la variable `$ingredientRepository`.

Dans la méthode `index()`, avant le `return`, on ajoute

```php
  $ingredients = $ingredientRepository->findAll();
  dd($ingredients);
```

Vérifiez que `use App\Repository\IngredientRepository;` est bien présent dans le fichier (sans import l'injection ne peut se faire).

Sur <http://127.0.0.1:8000/ingredient> on peut voir que le dump `dd` nous retourne bien une liste d'objets (les entrées de la table `ingredient`).

Nous pouvons retirer le `dd()`, le dump ayant réussi nous avons la confirmation que les données ont bien été converties dans `$ingredients` avec `findAll()`.

Maintenant nous allons transmettre cette variable dans la vue.

```php
// (...)
    return $this->render('pages/ingredient/index.html.twig', [
        'ingredients' => $ingredients,
    ]);
// (...)
```

Voici le fichier :

```php
<?php

namespace App\Controller;

use App\Repository\IngredientRepository;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Attribute\Route;

final class IngredientController extends AbstractController
{
    #[Route('/ingredient', name: 'app_ingredient')]
    public function index(IngredientRepository $ingredientRepository): Response
    {
        $ingredients = $ingredientRepository->findAll();
        return $this->render('pages/ingredient/index.html.twig', [
            'ingredients' => $ingredients,
        ]);
    }
}
```

Maintenant on retourne sur `templates/pages/ingredient/index.html.twig` et on retourne sur [la doc de Symfony](https://symfony.com/doc/current/templates.html).

> Twig syntax is based on these three constructs:
>
> - `{{ ... }}`, used to display the content of a variable or the result of evaluating an expression;
> - `{% ... %}`, used to run some logic, such as a conditional or a loop;
> - `{# ... #}`, used to add comments to the template (unlike HTML comments, these comments are not included in the rendered page).
>
> ---

Ici l'on nous explique avec `{% ... %}` la syntaxe pour les boucles ou les conditions, c'est ce que l'on va utiliser pour afficher nos ingrédients.

```twig
{% extends 'base.html.twig' %}

{% block title %}SymfoMarmiton - Ingrédients
{% endblock %}

{% block body %}
	<div class="container">
		<h1>Mes ingrédients</h1>
		{% for ingredient in ingredients %}{% endfor %}
	</div>
{% endblock %}
```

- `<div class="container">` est le conteneur Bootstrap
- `{% for ingredient in ingredients %}{% endfor %}` est notre boucle for.

Il est à noter que twig [a une documentation dédiée](https://twig.symfony.com/) distincte de celle de Symfony.

Dans cette boucle, nous organisons nos données

```twig
    <div>
      <p>{{ ingredient.name }}</p>
    </div>
```

Nous avons la liste des ingrédients qui s’affichent sur notre navigateur. Par contre nous voyons que cela n’est pas très joli on va venir agrémenter notre code de notre template afin de fournir une liste plus belle à regarder.

On commence par ajouter du margin top au conteneur (`<div class="container mt-4">`).

Maintenant on retourne [sur le theme bootswatch](https://bootswatch.com/lumen/) et on récupère le code du tableau, on le colle en dessous du `<h1>` le bloc `<thead>` et l'on ne garde qu'un `<tr class="table-primary"></tr>` dans le bloc `<tbody>`.

Ensuite on fait démarrer la boucle au dessus du `<tr>` (et on met le `endfor` derrière).

Ce qui nous donne :

```twig
{% extends 'base.html.twig' %}

{% block title %}FirstProject - Mes ingrédients
{% endblock %}

{% block body %}

	<div class="container mt-4">
		<h1>Mes ingrédients</h1>

		<table class="table table-hover">
			<thead>
				<tr>
					<th scope="col">ID</th>
					<th scope="col">Nom</th>
					<th scope="col">Prix</th>
					<th scope="col">Date</th>
				</tr>
			</thead>
			<tbody>
				{% for ingredient in ingredients %}
					<tr class="table-primary">
						<th scope="row">{{ingredient.id}}</th>
						<td>{{ingredient.name}}</td>
						<td>{{ingredient.price}}</td>
						<td>{{ingredient.createdAt}}</td>
					</tr>
				{% endfor %}
			</tbody>
		</table>
	</div>

{% endblock %}
```

Dans le navigateur, nous avons l'erreur

> Object of class DateTimeImmutable could not be converted to string

En effet, `createdAt` est un object instancié depuis `DateTimeImmutable`, twig ne sait pas en faire le rendu (il attend un type string).

D'après la [documentation de twig sur les filtres de date](https://twig.symfony.com/doc/3.x/filters/date.html)

L'on remarque qu'il faut filtrer la date avec cette syntaxe : `|date("m/d/Y")`, dans twig on appelle les filtre grâce à `|` (on appelle ça un "pipe").

Voici ce que donne le fichier corrigé :

```twig
{% extends 'base.html.twig' %}

{% block title %}FirstProject - Mes ingrédients
{% endblock %}

{% block body %}

	<div class="container mt-4">
		<h1>Mes ingrédients</h1>

		<table class="table table-hover">
			<thead>
				<tr>
					<th scope="col">ID</th>
					<th scope="col">Nom</th>
					<th scope="col">Prix</th>
					<th scope="col">Date</th>
				</tr>
			</thead>
			<tbody>
				{% for ingredient in ingredients %}
					<tr class="table-primary">
						<th scope="row">{{ ingredient.id }}</th>
						<td>{{ ingredient.name }}</td>
						<td>{{ ingredient.price }}</td>
						<td>{{ ingredient.createdAt|date("m/d/Y") }}</td>
					</tr>
				{% endfor %}
			</tbody>
		</table>
	</div>

{% endblock %}
```

Nous avons finit la partie `READ` du CRUD.
