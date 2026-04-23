# 10 CRUD Update

Dans cette partie, nous faisons la partie **Update** du CRUD.

On va mettre en place les flash messages (les notification "feedback" pour l'user) lors d'un ajout de produit dans l'index.

## Flash message

Dans la méthode `new()` de `src/Controller/IngredientController.php`, on ajoute (avant le `return`)

```bash
$this->addFlash(
    'success',
    'Votre ingrédient a été créé avec succès !'
);
```

Pour afficher cela, ce ne sera pas sur la vue `pages/ingredient/new.html.twig` mais sur `pages/ingredient/index.html.twig` à cause de la redirection.

On fait donc la boucle suivante en dessous de `<h1>Mes ingrédients</h1>` dans `pages/ingredient/index.html.twig`.

```twig
{% for message in app.flashes('success') %}
  <div class="alert alert-success mt-4">{{message}}</div>
{% endfor %}
```

Ce qui donne

```twig
{% extends 'base.html.twig' %}

{% block title %}SymfoMarmiton - Ingrédients
{% endblock %}

{% block body %}
	<div class="container mt-4">
		<h1>Mes ingrédients</h1>

		{% for message in app.flashes('success') %}
			<div class="alert alert-success mt-4">{{message}}</div>
		{% endfor %}


		{% if ingredients.items is not empty %}
		<div class="count">
			Nombre d'ingredients : {{ ingredients.getTotalItemCount }}
		</div>

		<table class="table table-hover">
			<thead>
				<tr>
					<th scope="col">ID</th>
					<th scope="col">Nom</th>
					<th scope="col">Prix</th>
					<th scope="col">Date</th>
				</tr>
			</thead>
			{% for ingredient in ingredients %}

				<tbody>
					<tr class="table-primary">
						<th scope="row">{{ ingredient.id }}</th>
						<td>{{ ingredient.name }}</td>
						<td>{{ ingredient.price }}</td>
						<td>{{ ingredient.createdAt|date("m/d/Y") }}</td>
					</tr>
				</tbody>
			{% endfor %}
		</table>
		<div class="navigation d-flex justify-content-center">
			{{ knp_pagination_render(ingredients) }}
		</div>
		{% else %}
			<h4>Il n'y a pas d'ingrédients.</h4>
		{% endif %}
	</div>
{% endblock %}
```

Ainsi, une fois la redirection effectuée vers cet index, il affichera le flash message.

On ajoute aussi un bouton pour créer un ingrédient à `templates/pages/ingredient/index.html.twig`.

```twig
<a href="{{ path('app_ingredient_new') }}" class="btn btn-primary mt-4">Ajouter un ingrédient</a>
```

Et je met la classe `mt-4` au count (pour espacer verticalement), ce qui donne

```php
{% extends 'base.html.twig' %}

{% block title %}SymfoMarmiton - Ingrédients
{% endblock %}

{% block body %}
	<div class="container mt-4">
		<h1>Mes ingrédients</h1>

		{% for message in app.flashes('success') %}
			<div class="alert alert-success mt-4">{{message}}</div>
		{% endfor %}

		<a href="{{ path('app_ingredient_new') }}" class="btn btn-primary mt-4">Ajouter un ingrédient</a>


		{% if ingredients.items is not empty %}
			<div class="count mt-4">
				Il y a
				{{ ingredients.getTotalItemCount }}
				ingrédients
			</div>

			<table class="table table-hover">
				<thead>
					<tr>
						<th scope="col">ID</th>
						<th scope="col">Nom</th>
						<th scope="col">Prix</th>
						<th scope="col">Date</th>
					</tr>
				</thead>
				{% for ingredient in ingredients %}

					<tbody>
						<tr class="table-primary">
							<th scope="row">{{ ingredient.id }}</th>
							<td>{{ ingredient.name }}</td>
							<td>{{ ingredient.price }}</td>
							<td>{{ ingredient.createdAt|date("m/d/Y") }}</td>
						</tr>
					</tbody>
				{% endfor %}
			</table>
			<div class="navigation d-flex justify-content-center">
				{{ knp_pagination_render(ingredients) }}
			</div>
		{% else %}
			<h4>Il n'y a pas d'ingrédients.</h4>
		{% endif %}
	</div>
{% endblock %}
```

On modifie maintenant le header `templates/partials/_header.html.twig`

```twig
<nav class="navbar navbar-expand-lg bg-primary" data-bs-theme="dark">
	<div class="container-fluid">
		<a class="navbar-brand" href="#">SymfoMarmiton</a>
		<button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarColor01" aria-controls="navbarColor01" aria-expanded="false" aria-label="Toggle navigation">
			<span class="navbar-toggler-icon"></span>
		</button>
		<div class="collapse navbar-collapse" id="navbarColor01">
			<ul class="navbar-nav me-auto">
				<li class="nav-item">
					<a class="nav-link active" href="{{ path('home') }}">Accueil
						<span class="visually-hidden">(current)</span>
					</a>
				</li>
				<li class="nav-item">
					<a class="nav-link active" href="{{ path('app_ingredient') }}">Ingrédients
						<span class="visually-hidden">(current)</span>
					</a>
				</li>

			</ul>
		</div>
	</div>
</nav>
```

Ici, au lieu de passer un chemin, on utilise `path('#RouteName#')`, il ira chercher automatiquement le path dans le contrôleur.

Et on commente `new()` (dans `src/Controller/IngredientController.php`), on peut utiliser le snippet `/**` juste au dessus de son attribut de route.

## Update

Toujours dans `src/Controller/IngredientController.php`, on créé une méthode `edit()`.

```php
<?php

namespace App\Controller;

use App\Entity\Ingredient;
use App\Form\IngredientType;
use App\Repository\IngredientRepository;
use Doctrine\ORM\EntityManagerInterface;
use Knp\Component\Pager\PaginatorInterface;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Attribute\Route;

final class IngredientController extends AbstractController
{
    #[Route('/ingredient', name: 'app_ingredient')]

    /**
     * This method display all ingredients
     * @param IngredientRepository $ingredientRepository
     * @param PaginatorInterface $paginator
     * @param Request $request
     * @return Response
     */
    public function index(IngredientRepository $ingredientRepository, PaginatorInterface $paginator, Request $request): Response
    {
        $ingredients = $paginator->paginate(
            $ingredientRepository->findAllQueries(),
            $request->query->getInt('page', 1),
            10
        );

        return $this->render('pages/ingredient/index.html.twig', [
            'ingredients' => $ingredients,
        ]);
    }

    /**
     * This controller show the form to add an ingredient
     *
     * @param Request $request
     * @param EntityManagerInterface $em
     * @return Response
     */
    #[Route('/ingredient/nouveau', name: 'app_ingredient_new')]
    public function new(Request $request, EntityManagerInterface $em): Response
    {
        $ingredient = new Ingredient();
        $form = $this->createForm(IngredientType::class, $ingredient);

        $form->handleRequest($request);
        if ($form->isSubmitted() && $form->isValid()) {
            $ingredient = $form->getData();
            $em->persist($ingredient);
            $em->flush();

            $this->addFlash(
                'success',
                'Votre ingrédient a été créé avec succès !'
            );

            return $this->redirectToRoute('app_ingredient');
        }

        return $this->render('pages/ingredient/new.html.twig', [
            'form' => $form
        ]);
    }

    #[Route('/ingredient/edition/{id}', name:'app_ingredient_edit', methods:['GET', 'POST'] )]
    public function edit(): Response
    {
        return $this->render('pages/ingredient/edit.html.twig');
    }

}
```

On duplique `templates/pages/ingredient/new.html.twig` en `templates/pages/ingredient/edit.html.twig`

```bash
cp templates/pages/ingredient/new.html.twig templates/pages/ingredient/edit.html.twig
```

On remplace juste le titre par `<h1 class="mt-4">Modification d'un ingrédient</h1>`.

Maintenant on va lancer la création du formulaire dans la méthode `edit()` du contrôleur `IngredientController.php`.

```php
#[Route('/ingredient/edition/{id}', name: 'app_ingredient_edit', methods: ['GET', 'POST'])]
public function edit(Request $request, EntityManagerInterface $em, IngredientRepository $ingredientRepository, int $id): Response
{
		$ingredient = $ingredientRepository->findOneBy(["id" => $id]);
		$form = $this->createForm(IngredientType::class, $ingredient);

		$form->handleRequest($request);
		if ($form->isSubmitted() && $form->isValid()) {
				$ingredient = $form->getData();
				$em->persist($ingredient);
				$em->flush();

				$this->addFlash(
						'success',
						'Votre ingrédient a été modifié avec succès !'
				);

				return $this->redirectToRoute('app_ingredient');
		}

		return $this->render('pages/ingredient/edit.html.twig', [
				'form' => $form
		]);
}
```

Ainsi on peut éditer un ingrédient avec le chemin `/ingredient/edition/{id}`.

On ajoute le bouton d'édition dans notre vue d'index `templates/pages/ingredient/index.html.twig`

```php
<td><a href="{{ path('app_ingredient_edit', { id : ingredient.id }) }}" class="btn btn-info">Modifier</a></td>
```

ça donne

```php
{% extends 'base.html.twig' %}

{% block title %}SymfoMarmiton - Ingrédients
{% endblock %}

{% block body %}
	<div class="container mt-4">
		<h1>Mes ingrédients</h1>

		{% for message in app.flashes('success') %}
			<div class="alert alert-success mt-4">{{message}}</div>
		{% endfor %}

		<a href="{{ path('app_ingredient_new') }}" class="btn btn-primary mt-4">Ajouter un ingrédient</a>


		{% if ingredients.items is not empty %}
			<div class="count mt-4">
				Il y a
				{{ ingredients.getTotalItemCount }}
				{% if ingredients.getTotalItemCount >= 2  %}
				ingrédients
				{% else %}
				ingrédient
				{% endif %}
			</div>

			<table class="table table-hover">
				<thead>
					<tr>
						<th scope="col">ID</th>
						<th scope="col">Nom</th>
						<th scope="col">Prix</th>
						<th scope="col">Date</th>
					</tr>
				</thead>
				{% for ingredient in ingredients %}

					<tbody>
						<tr class="table-primary">
							<th scope="row">{{ ingredient.id }}</th>
							<td>{{ ingredient.name }}</td>
							<td>{{ ingredient.price }}</td>
							<td>{{ ingredient.createdAt|date("m/d/Y") }}</td>
							<td><a href="{{ path('app_ingredient_edit', { id : ingredient.id }) }}" class="btn btn-info">Modifier</a></td>
						</tr>
					</tbody>
				{% endfor %}
			</table>
			<div class="navigation d-flex justify-content-center">
				{{ knp_pagination_render(ingredients) }}
			</div>
		{% else %}
			<h4>Il n'y a pas d'ingrédients.</h4>
		{% endif %}
	</div>
{% endblock %}
```

On peut désormais passer via le bouton d'édition de chaque ingrédient pour update, cette partie est donc finie.
