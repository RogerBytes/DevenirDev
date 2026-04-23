# 11 CRUD Delete

Voici la dernière étape de notre CRUD pour notre entité `Ingrédient`.

On créé un méthode `delete()` dans notre contrôleur `src/Controller/IngredientController.php`

```php
#[Route('/ingredient/suppression/{id}', name: 'app_ingredient_delete', methods: ['GET'])]
public function delete(): Response
{

}
```

Depuis [la doc doctrine pour delete](https://symfony.com/doc/current/doctrine.html#deleting-an-object) on peut voir

```php
$entityManager->remove($product);
$entityManager->flush();
```

> the given object from the database. The DELETE query isn't actually executed until the flush() method is called.

On va donc injecter `EntityManagerInterface` afin de pouvoir utiliser `remove`, on en profite aussi pour injecter `IngredientRepository`, et on lui passe le paramètre de route `$id` et on le type en entier (il interprète le `{id}` et l'affecte à `$id` dans `/ingredient/suppression/{id}`)

```php
#[Route('/ingredient/suppression/{id}', name: 'app_ingredient_delete', methods: ['POST'])]
public function delete(EntityManagerInterface $em, int $id, IngredientRepository $ingredientRepository): Response
{

}
```

Et ensuite on créé `$ingredient` en récupérant la donnée via son $id.

```php
#[Route('/ingredient/suppression/{id}', name: 'app_ingredient_delete', methods: ['GET'])]
public function delete(EntityManagerInterface $em, int $id, IngredientRepository $ingredientRepository): Response
{
    $ingredient = $ingredientRepository->findOneBy(["id" => $id]);
}
```

Ensuite on fait la vérification, pour voir si l'instance existe (on est sur l'entité, c'est la row dans la table qui sera affectée). On s'occupe de faire les flash message ainsi que les redirections, ainsi que le `remove()`.

```php
#[Route('/ingredient/suppression/{id}', name: 'app_ingredient_delete', methods: ['POST'])]
public function delete(EntityManagerInterface $em, int $id, IngredientRepository $ingredientRepository): Response
{
    $ingredient = $ingredientRepository->findOneBy(["id" => $id]);

    if (!$ingredient) {
        $this->addFlash(
            'error',
            "Votre ingrédient n'a pas été trouvé !"
        );
        return $this->redirectToRoute('app_ingredient');
    } else {
        $em->remove($ingredient);
        $em->flush();
        $this->addFlash(
            'success',
            'Votre ingrédient a été supprimé avec succès !'
        );
        return $this->redirectToRoute('app_ingredient');
    }
}
```

Et l'on ajoute le bouton dans notre vue d'index `templates/pages/ingredient/index.html.twig`

```php
<td>
  <form action="{{ path('app_ingredient_delete', { id: ingredient.id }) }}" method="POST" style="display:inline">
    <button type="submit" class="btn btn-danger">Supprimer</button>
  </form>
</td>
```

Ici l'on respecte Rest, donc on ne fait pas un bouton (qui est en GET) mais on passe par un mini formulaire afin d'être en POST.

et également les colonnes du tableau

```php
<th scope="col">Modification</th>
<th scope="col">Suppression</th>
```

Ce qui nous donne

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
						<th scope="col">Modification</th>
						<th scope="col">Suppression</th>
					</tr>
				</thead>
				{% for ingredient in ingredients %}

					<tbody>
						<tr class="table-primary">
							<th scope="row">{{ ingredient.id }}</th>
							<td>{{ ingredient.name }}</td>
							<td>{{ ingredient.price }}</td>
							<td>{{ ingredient.createdAt|date("m/d/Y") }}</td>
							<td>
								<a href="{{ path('app_ingredient_edit', { id : ingredient.id }) }}" class="btn btn-info">Modifier</a>
							</td>
							<td>
								<form action="{{ path('app_ingredient_delete', { id: ingredient.id }) }}" method="POST" style="display:inline">
									<button type="submit" class="btn btn-danger">Supprimer</button>
								</form>
							</td>
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

Notre partie Delete est finie.
