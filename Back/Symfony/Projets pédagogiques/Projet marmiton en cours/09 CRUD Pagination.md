# 08 CRUD Pagination

Maintenant que notre table `Ingredient` est lisible on va améliorer son rendu (car ayant de nombreuses entrées cela fait une énorme page à scroller).

Nous allons utiliser [KnpPaginatorBundle](https://github.com/KnpLabs/KnpPaginatorBundle) pour y remédier.

On l'installe via composer

```bash
composer require knplabs/knp-paginator-bundle
```

On voit dans `composer.json` qu'il est installé

```json
// (...)
"knplabs/knp-paginator-bundle": "^6.10",
// (...)
```

---

On crée le fichier de configuration `config/packages/knp_paginator.yaml`

```bash
touch config/packages/knp_paginator.yaml
```

Dans la [documentation](https://github.com/KnpLabs/KnpPaginatorBundle) on y trouve cet exemple de configuration dudit Bundle, on le colle à l'intérieur :

```yml
knp_paginator:
  convert_exception: false # throw a 404 exception when an invalid page is requested
  page_range: 5 # number of links shown in the pagination menu (e.g: you have 10 pages, a page_range of 3, on the 5th page you'll see links to page 4, 5, 6)
  remove_first_page_param: false # remove the page query parameter from the first page link
  default_options:
    page_name: page # page query parameter name
    sort_field_name: sort # sort field query parameter name
    sort_direction_name: direction # sort direction query parameter name
    distinct: true # ensure distinct results, useful when ORM queries are using GROUP BY statements
    filter_field_name: filterField # filter field query parameter name
    filter_value_name: filterValue # filter value query parameter name
    page_out_of_range: ignore # ignore, fix, or throwException when the page is out of range
    default_limit: 10 # default number of items per page
  template:
    pagination: "@KnpPaginator/Pagination/sliding.html.twig" # sliding pagination controls template
    rel_links: "@KnpPaginator/Pagination/rel_links.html.twig" # <link rel=...> tags template
    sortable: "@KnpPaginator/Pagination/sortable_link.html.twig" # sort link template
    filtration: "@KnpPaginator/Pagination/filtration.html.twig" # filters template
```

Et plus bas, dans la doc, on prend cet exemple d'utilisation

```php
// App\Controller\ArticleController.php

public function listAction(EntityManagerInterface $em, PaginatorInterface $paginator, Request $request)
{
    $dql   = "SELECT a FROM AcmeMainBundle:Article a";
    $query = $em->createQuery($dql);

    $pagination = $paginator->paginate(
        $query, /* query NOT result */
        $request->query->getInt('page', 1), /* page number */
        10 /* limit per page */
    );

    // parameters to template
    return $this->render('article/list.html.twig', ['pagination' => $pagination]);
}
```

L'on remarque ici l'injection de dépendances `PaginatorInterface $paginator` et `Request $request`, nous allons en faire de même dans `src/Controller/IngredientController.php` et nous y ajoutons/modifions ce bloc :

```php
    $pagination = $paginator->paginate(
        $query, /* query NOT result */
        $request->query->getInt('page', 1), /* page number */
        10 /* limit per page */
    );
```

Ce qui nous donne :

```php
<?php

namespace App\Controller;

use App\Repository\IngredientRepository;
use Knp\Component\Pager\PaginatorInterface;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Attribute\Route;

final class IngredientController extends AbstractController
{
    #[Route('/ingredient', name: 'app_ingredient')]
    public function index(IngredientRepository $ingredientRepository, PaginatorInterface $paginator, Request $request): Response
    {
        $ingredients = $paginator->paginate(
            $ingredientRepository->findAll(),
            $request->query->getInt('page', 1),
            10
        );

        return $this->render('pages/ingredient/index.html.twig', [
            'ingredients' => $ingredients,
        ]);
    }
}
```

La variable `$pagination` devient `$ingredients`. Ici, contrairement à l’exemple, nous utilisons directement le repository avec `$ingredientRepository->findAll()`.

`findAll()` retournant tous les objets en mémoire, pouvant être très lourd sur une énorme table, nous créons la query `findAllQuery()` dans `src/Repository/IngredientRepository.php`  :

```php
<?php

namespace App\Repository;

use App\Entity\Ingredient;
use Doctrine\Bundle\DoctrineBundle\Repository\ServiceEntityRepository;
use Doctrine\ORM\Query;
use Doctrine\Persistence\ManagerRegistry;

/**
 * @extends ServiceEntityRepository<Ingredient>
 */
class IngredientRepository extends ServiceEntityRepository
{
    public function __construct(ManagerRegistry $registry)
    {
        parent::__construct($registry, Ingredient::class);
    }

    public function findAllQuery(): Query
    {
        return $this->createQueryBuilder('i')
            ->getQuery();
    }
}
```

Cela va permettre au paginator du `src/Controller/IngredientController.php` de récupérer directement la requête sans charger tous les objets en mémoire :

```php
<?php

namespace App\Controller;

use App\Repository\IngredientRepository;
use Knp\Component\Pager\PaginatorInterface;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Attribute\Route;

final class IngredientController extends AbstractController
{
    #[Route('/ingredient', name: 'app_ingredient')]
    public function index(IngredientRepository $ingredientRepository, PaginatorInterface $paginator, Request $request): Response
    {
        $ingredients = $paginator->paginate(
            $ingredientRepository->findAllQuery(),
            $request->query->getInt('page', 1),
            10
        );

        return $this->render('pages/ingredient/index.html.twig', [
            'ingredients' => $ingredients,
        ]);
    }
}
```

Testons maintenant l'affichage de notre vue sur la page <http://127.0.0.1:8000/ingredient>.

Nous ne pouvons pas changer de page.

Dans la doc, nous voyons dans la partie **View**

```php
{# total items count #}
<div class="count">
    {{ pagination.getTotalItemCount }}
</div>
<table>
    <tr>
        {# sorting of properties based on query components #}
        <th>{{ knp_pagination_sortable(pagination, 'Id', 'a.id') }}</th>
        <th{% if pagination.isSorted('a.title') %} class="sorted"{% endif %}>
            {{ knp_pagination_sortable(pagination, 'Title', 'a.title') }}
        </th>
        <th{% if pagination.isSorted(['a.date', 'a.time']) %} class="sorted"{% endif %}>
            {{ knp_pagination_sortable(pagination, 'Release', ['a.date', 'a.time']) }}
        </th>
    </tr>

    {# table body #}
    {% for article in pagination %}
        <tr {% if loop.index is odd %}class="color"{% endif %}>
            <td>{{ article.id }}</td>
            <td>{{ article.title }}</td>
            <td>{{ article.date | date('Y-m-d') }}, {{ article.time | date('H:i:s') }}</td>
        </tr>
    {% endfor %}
</table>
{# display navigation #}
<div class="navigation">
    {{ knp_pagination_render(pagination) }}
</div>
```

Nous allons utiliser `{# display navigation #}` dans `templates/pages/ingredient/index.html.twig`, c'est à dire y ajouter :

```php
<div class="navigation">
    {{ knp_pagination_render(pagination) }}
</div>
```

Comme ceci, derrière la table :

```php
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

		<div class="navigation">
			{{ knp_pagination_render(ingredients) }}
		</div>

	</div>

{% endblock %}
```

On remarque que nous avons modifié `pagination` par `ingredients`, conformement à la variable utilisée par le paginator dudit contrôleur.

Le défilement des pages est fonctionnel.

Nous allons maintenant styliser les liens de pagination.

Dans [la partie templates de la doc](https://github.com/KnpLabs/KnpPaginatorBundle?tab=readme-ov-file#additional-pagination-templates).

On va copier le second lien `@KnpPaginator/Pagination/bootstrap_v5_pagination.html.twig` dans `config/packages/knp_paginator.yaml` comme valeur de la clef `pagination`.

```yaml
knp_paginator:
  convert_exception: false # throw a 404 exception when an invalid page is requested
  page_range: 5 # number of links shown in the pagination menu (e.g: you have 10 pages, a page_range of 3, on the 5th page you'll see links to page 4, 5, 6)
  remove_first_page_param: false # remove the page query parameter from the first page link
  default_options:
    page_name: page # page query parameter name
    sort_field_name: sort # sort field query parameter name
    sort_direction_name: direction # sort direction query parameter name
    distinct: true # ensure distinct results, useful when ORM queries are using GROUP BY statements
    filter_field_name: filterField # filter field query parameter name
    filter_value_name: filterValue # filter value query parameter name
    page_out_of_range: ignore # ignore, fix, or throwException when the page is out of range
    default_limit: 10 # default number of items per page
  template:
    pagination: "@KnpPaginator/Pagination/bootstrap_v5_pagination.html.twig" # sliding pagination controls template
    rel_links: "@KnpPaginator/Pagination/rel_links.html.twig" # <link rel=...> tags template
    sortable: "@KnpPaginator/Pagination/sortable_link.html.twig" # sort link template
    filtration: "@KnpPaginator/Pagination/filtration.html.twig" # filters template
```

et dans le template `templates/pages/ingredient/index.html.twig` on pense à ajouter `d-flex justify-content-center` dans la classe, bootstrap va ainsi centrer le bloc de pagination.

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

		<div class="navigation d-flex justify-content-center">
			{{ knp_pagination_render(ingredients) }}
		</div>

	</div>

{% endblock %}
```

Depuis [la partie in body de la doc](https://github.com/KnpLabs/KnpPaginatorBundle?tab=readme-ov-file#in-body) :

```twig
{# total items count #}
<div class="count">
    {{ pagination.getTotalItemCount }}
</div>
<table>
    <tr>
        {# sorting of properties based on query components #}
        <th>{{ knp_pagination_sortable(pagination, 'Id', 'a.id') }}</th>
        <th{% if pagination.isSorted('a.title') %} class="sorted"{% endif %}>
            {{ knp_pagination_sortable(pagination, 'Title', 'a.title') }}
        </th>
        <th{% if pagination.isSorted(['a.date', 'a.time']) %} class="sorted"{% endif %}>
            {{ knp_pagination_sortable(pagination, 'Release', ['a.date', 'a.time']) }}
        </th>
    </tr>

    {# table body #}
    {% for article in pagination %}
        <tr {% if loop.index is odd %}class="color"{% endif %}>
            <td>{{ article.id }}</td>
            <td>{{ article.title }}</td>
            <td>{{ article.date | date('Y-m-d') }}, {{ article.time | date('H:i:s') }}</td>
        </tr>
    {% endfor %}
</table>
{# display navigation #}
<div class="navigation">
    {{ knp_pagination_render(pagination) }}
</div>
```

On récupère le `count`

```twig
<div class="count">
    {{ pagination.getTotalItemCount }}
</div>
```

Sans oublier de remplacer `pagination` par `ingredients`, on l'ajoute au dessus du bloc de la table.

Voici le template `templates/pages/ingredient/index.html.twig` terminé :

```twig
{% extends 'base.html.twig' %}

{% block title %}FirstProject - Mes ingrédients
{% endblock %}

{% block body %}

	<div class="container mt-4">
		<h1>Mes ingrédients</h1>
		<div class="count">
			<p>Nombre d'ingrédients en mémoire :
			<strong>
			{{ ingredients.getTotalItemCount }}
			</strong></p>
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

		<div class="navigation d-flex justify-content-center">
			{{ knp_pagination_render(ingredients) }}
		</div>

	</div>

{% endblock %}
```
