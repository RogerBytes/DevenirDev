# 13 Crud recette part 2

Maintenant que nous avons géré la partie entité/bdd nous nous occupons de l'affichage de l'ensemble de nos recettes

On commence par faire notre contrôleur `Recipe`

```bash
symfony console ma:con Recipe
```

Qui nous a créé `src/Controller/RecipeController.php`

```php
<?php

namespace App\Controller;

use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Attribute\Route;

final class RecipeController extends AbstractController
{
    #[Route('/recipe', name: 'app_recipe')]
    public function index(): Response
    {
        return $this->render('recipe/index.html.twig', [
            'controller_name' => 'RecipeController',
        ]);
    }
}
```

On remarque notre template n'est pas dans notre répertoire page, on corrige donc le chemin du `render('pages/recipe/index.html.twig')`.

Et on déplace le répertoire de vue `templates/recipe` dans `templates/pages`

```bash
mv templates/recipe templates/pages/recipe
```

On remplace également la route par `/recette` et on précise la méthode en GET dans l'attribut route, voici ce que ça donne

```php
<?php

namespace App\Controller;

use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Attribute\Route;

final class RecipeController extends AbstractController
{
    #[Route('/recette', name: 'app_recipe', methods:['GET'])]
    public function index(): Response
    {
        return $this->render('pages/recipe/index.html.twig', [
            'controller_name' => 'RecipeController',
        ]);
    }
}
```

Dans le navigateur, on vérifie <https://localhost:8000/recette>, le rendu fonctionne.

On en profite pour ajouter dans le header `templates/partials/_header.html.twig`

on ajoute donc

```twig
<li class="nav-item">
    <a class="nav-link active" href="{{ path('app_recipe') }}">Recettes
        <span class="visually-hidden">(current)</span>
    </a>
</li>
```

Par la suite, pour faire un crud et le formulaire associé, on utilisera

```bash
symfony console make:crud Recipe
```

Pour l'instant on continue de générer manuellement, afin de comprendre le fonctionnement de PHP/Symfony

Maintenant on va récupérer la vue de l'index des ingrédients et la coller sur la vue de l'index des recettes

```bash
rm -f templates/pages/recipe/index.html.twig
cp templates/pages/ingredient/index.html.twig templates/pages/recipe/index.html.twig
```

On récupère la vue des ingrédients pour garder la même structure de tableau et l’adapter aux recettes, afin de ne pas réinventer complètement l’affichage et faciliter la pagination.

Et on ajuste le fichier

```twig
{% extends 'base.html.twig' %}

{% block title %}SymfoMarmiton - Recettes
{% endblock %}

{% block body %}
	<div class="container mt-4">
		<h1>Mes recettes</h1>

		{% for message in app.flashes('success') %}
			<div class="alert alert-success mt-4">{{message}}</div>
		{% endfor %}

		{# <a href="{{ path('app_recipe_new') }}" class="btn btn-primary mt-4">Ajouter une recette</a> #}


		{% if recipes.items is not empty %}
			<div class="count mt-4">
				Il y a
				{{ recipes.getTotalItemCount }}
				{% if recipes.getTotalItemCount >= 2  %}
					recettes
				{% else %}
					recette
				{% endif %}
			</div>

			<table class="table table-hover">
				<thead>
					<tr>
						<th scope="col">ID</th>
						<th scope="col">Nom</th>
						<th scope="col">Prix</th>
						<th scope="col">Difficulté</th>
						<th scope="col">Date de création</th>
						<th scope="col">Modification</th>
						<th scope="col">Suppression</th>
					</tr>
				</thead>
				{% for recipe in recipes %}

					<tbody>
						<tr class="table-primary">
							<th scope="row">{{ recipe.id }}</th>
							<td>{{ recipe.name }}</td>
							<td>{{ recipe.price }}</td>
							<td>{{ recipe.difficulty }}</td>
							<td>{{ recipe.createdAt|date("m/d/Y") }}</td>
							<td>
								<a href="{{ path('app_recipe_edit', { id : recipe.id }) }}" class="btn btn-info">Modifier</a>
							</td>
							<td>
								<form action="{{ path('app_recipe_delete', { id: recipe.id }) }}" method="POST" style="display:inline">
									<button type="submit" class="btn btn-danger">Supprimer</button>
								</form>
							</td>
						</tr>
					</tbody>
				{% endfor %}
			</table>
			<div class="navigation d-flex justify-content-center">
				{{ knp_pagination_render(recipes) }}
			</div>
		{% else %}
			<h4>Il n'y a pas de recettes.</h4>
		{% endif %}
	</div>
{% endblock %}
```

On retourne sur `src/Controller/RecipeController.php` afin de créer (avec le paginate etc) et de passer la variable `$recipes` en vue, on prend garde à bien injecter les dépendances avec les `use`.

```php
<?php

namespace App\Controller;

use App\Repository\RecipeRepository;
use Knp\Component\Pager\PaginatorInterface;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Attribute\Route;

final class RecipeController extends AbstractController
{
    #[Route('/recette', name: 'app_recipe', methods:['GET'])]
    public function index(RecipeRepository $recipeRepository, PaginatorInterface $paginator, Request $request): Response
    {
        $recipes = $paginator->paginate(
            $recipeRepository->findAll(),
            $request->query->getInt('page', 1),
            10
        );
        return $this->render('pages/recipe/index.html.twig', [
            'recipes' => $recipes
        ]);
    }
}
```

 On utilise KnpPaginator pour gérer la pagination, limitant l’affichage à 10 recettes par page et permettant de naviguer facilement entre elles.

On fait la documentation avec `/**` sur notre méthode `index()`.

Dans la vue `templates/pages/recipe/index.html.twig`, on va faire des ternaires pour les cas où la valeur est nulle.
On gère les valeurs null pour price et difficulty afin d’éviter un affichage vide dans le tableau, ce qui améliore la lisibilité et l’expérience utilisateur.

```twig
<td>{{ recipe.price ?? 'Non renseigné' }}</td>
<td>{{ recipe.difficulty ?? 'Non renseigné' }}</td>
```

S'il ne trouve pas de valeur, il affiche le texte.

C'est une manière condensée de faire :

```twig
<td>{{ (recipe.price is same as(null)) ? "Non renseigné" : recipe.price }}</td>
```

Cela conclue cette partie.
