# 09 CRUD Create

La pagination étant finie, dans `src/Controller/IngredientController.php` nous allons nous occuper de documenter notre code.
Pour information, le terme `Assert` signifie "Contrainte".

## Documentation

Le snippet pour lancer la doc, c'est `/**`, vous permettant de suivre les bonnes pratiques, par exemple dans `src/Controller/IngredientController.php`.

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
    /**
     * This method display all ingredients
     * @param IngredientRepository $ingredientRepository
     * @param PaginatorInterface $paginator
     * @param Request $request
     * @return Response
     */
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

## Si la table est vide

Dans `templates/pages/ingredient/index.html.twig` nous allons faire une condition sous la div `.container`.

```twig
{% extends 'base.html.twig' %}

{% block title %}FirstProject - Mes ingrédients
{% endblock %}

{% block body %}

	<div class="container mt-4">
		{% if ingredients.items is not empty %}
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
		{% else %}
			<h4>Il n'y a pas d'ingrédients</h4>
		{% endif %}

	</div>

{% endblock %}
```

On vire les fixtures de la table `ingredient` pour tester.

```bash
symfony console doctrine:query:sql "TRUNCATE TABLE ingredient"
```

Notre condition fonctionne, <http://127.0.0.1:8000/ingredient> montre bien le contenu de notre `else`.

On pourrait relancer les fixtures avec

```bash
symfony console do:fi:lo -n
```

Mais on va garder ça vide pour l'instant.

## Le Create

Dans [la doc de formulaires symfonye](https://symfony.com/doc/current/forms.html#usage), on peut voir

> **Usage**
>
> The recommended workflow when working with Symfony forms is the following:
>
> 1. Build the form in a Symfony controller or using a dedicated form class;
> 2. Render the form in a template so the user can edit and submit it;
> 3. Process the form to validate the submitted data, transform it into PHP data and do something with it (e.g. persist it in a database).

Il faut donc :

1. Construire le formulaire
2. En faire le rendu
3. En faire la validation et la soumission

Pour ce faire, nous allons utiliser l'entité `Ingredient` en construisant un formulaire qui permettra de créer une nouvelle instance et de valider ses données avant de la persister.

Pour chercher la commande adéquate, on fait `symfony console`, l'on voit la ligne

```output
make:form                                  Create a new form class
```

Donc pour créer un formulaire `IngredientType` avec la commande `make:form`

```bash
symfony console ma:fo Ingredient Ingredient
```

Ici en premier argument on lui a donné le nom voulu pour le formulaire (`Type` sera ajouté automatiquement au nom), et de quel entité il est censé instancier en second argument. Symfony a automatiquement généré `src/Form/IngredientType.php`.

Voici ce que l'on trouve dedans :

- Un namespace, indique où se situe la classe dans l’arborescence du projet.

```php
namespace App\Form;
```

- Les `use`, importe les classes nécessaires pour construire et configurer le formulaire.

```php
use App\Entity\Ingredient;
use Symfony\Component\Form\AbstractType;
use Symfony\Component\Form\FormBuilderInterface;
use Symfony\Component\OptionsResolver\OptionsResolver;
```

- L'extend de classe abstraite, indique que cette classe est un formulaire Symfony et hérite des fonctionnalités de base

```php
class IngredientType extends AbstractType
```

- La méthode `buildForm()` et ses dépendances, définit les champs que l’utilisateur pourra remplir dans le formulaire.

```php
public function buildForm(FormBuilderInterface $builder, array $options): void
// (...)
```

- La propriété `$builder`, qui fait les ajouts sur `name`, `price` et `createdAt`, propriétés de l'entité

```php
$builder
    ->add('name')
    ->add('price')
    ->add('createdAt', null, [
        'widget' => 'single_text',
    ])
;
```

- La méthode `configureOptions()` et ses dépendances, il lie le formulaire à l’entité Ingredient pour que les données saisies soient automatiquement mappées sur un objet.

```php
    public function configureOptions(OptionsResolver $resolver): void
    {
        $resolver->setDefaults([
            'data_class' => Ingredient::class,
        ]);
    }
```

Il faut noter que `createdAt` est automatiquement instancié via le constructeur que nous avons fait dans l'entité `Ingredient` (dans la partie `06 Fixtures.md`), on le supprime donc du `buildForm()`.

Maintenant nous allons l'appeler via une méthode `new()` dans le contrôleur `src/Controller/IngredientController.php`.

```php
    public function new():Response
    {
        return $this->render('pages/ingredient/new.html.twig');
    }
```

et l'on y ajoute l'attribut de sa route

```php
    #[Route('/ingredient/nouveau', name: 'app_ingredient_new')]
    public function new(): Response
    {
        return $this->render('pages/ingredient/new.html.twig');
    }
```

On créé maintenant son template vierge dans `templates/pages/ingredient/`.

```bash
touch  templates/pages/ingredient/new.html.twig
```

Dans ce fichier nous étendons la base, puis dans un block `body` un titre `Création d'un ingrédient`.

```twig
{% extends "base.html.twig" %}

{% block body %}
  <div class="container">
  <h1 class="mt-4">Création d'un ingrédient</h1>
  </div>
{% endblock %}
```

Dans <http://localhost:8000/ingredient/nouveau> on voit bien notre vue apparaître.

Dans [la doc de Symfony](https://symfony.com/doc/current/forms.html#creating-form-classes), dans le bloc de code on voit

```php
// src/Controller/TaskController.php
namespace App\Controller;

use App\Form\Type\TaskType;
// ...

class TaskController extends AbstractController
{
    public function new(): Response
    {
        // creates a task object and initializes some data for this example
        $task = new Task();
        $task->setTask('Write a blog post');
        $task->setDueDate(new \DateTimeImmutable('tomorrow'));

        $form = $this->createForm(TaskType::class, $task);

        // ...
    }
}
```

Ceci permet de paramétrer la gestion du formulaire en fonction du contrôleur, on intègre cela dans notre méthode `new()`.

```php
<?php

namespace App\Controller;

use App\Entity\Ingredient;
use App\Form\IngredientType;
use App\Repository\IngredientRepository;
use Knp\Component\Pager\PaginatorInterface;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Attribute\Route;

final class IngredientController extends AbstractController
{
    /**
     * This method display all ingredients
     * @param IngredientRepository $ingredientRepository
     * @param PaginatorInterface $paginator
     * @param Request $request
     * @return Response
     */
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

    #[Route('/ingredient/nouveau', name: 'app_ingredient_new')]
    public function new(): Response
    {
        $ingredient = new Ingredient();
        $form = $this->createForm(IngredientType::class, $ingredient);
        return $this->render('pages/ingredient/new.html.twig');
    }
}
```

Nous avons instancié un objet `$ingredient`, puis dans `$form` nous appelons la méthode `createForm()` héritée de `AbstractController` à qui l'on passe la var `$ingredient` en paramètre ainsi que la classe du formulaire (`IngredientType::class`), qui définit la structure et les champs du formulaire. `$ingredient` sert de **données liées** : Symfony va remplir cet objet avec les valeurs envoyées par le formulaire lors de la soumission, ce qui permet ensuite de le persister facilement en base.

Pour rappel la syntaxe `::class` sur une classe veut dire

- `::` on appelle une constante de classe
- `class` est une constante implicite fournie par PHP (qui contient le namespace), mais l'on pourrait également faire une constante `const VERSION = 1;` que l'on appellerait avec `IngredientType::VERSION`

Maintenant on va transmettre notre var `$form` dans la vue, via `render()`

```php
<?php

namespace App\Controller;

use App\Entity\Ingredient;
use App\Form\IngredientType;
use App\Repository\IngredientRepository;
use Knp\Component\Pager\PaginatorInterface;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Attribute\Route;

final class IngredientController extends AbstractController
{
    /**
     * This method display all ingredients
     * @param IngredientRepository $ingredientRepository
     * @param PaginatorInterface $paginator
     * @param Request $request
     * @return Response
     */
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

    #[Route('/ingredient/nouveau', name: 'app_ingredient_new')]
    public function new(): Response
    {
        $ingredient = new Ingredient();
        $form = $this->createForm(IngredientType::class, $ingredient);
        return $this->render('pages/ingredient/new.html.twig',[
            'form' => $form
        ]);
    }
}
```

La doc nous dit :

> Internally, the render() method calls $form->createView() to transform the form into a form view instance.

Avant nous aurions du utiliser `'form' => $form->createView()` mais `render()` s'en occupe automatiquement désormais.

Maintenant on appelle le formulaire dans `templates/pages/ingredient/new.html.twig`, via `{{ form(form) }}`.

```twig
{% extends "base.html.twig" %}

{% block body %}
  <div class="container">
  <h1 class="mt-4">Création d'un ingrédient</h1>
  {{ form(form) }}
  </div>
{% endblock %}
```

## Amélioration du formulaire

On voit bien le formulaire apparaître, il est rudimentaire, nous allons l'améliorer dans `src/Form/IngredientType.php`.

Sur la [doc des Form Type](https://symfony.com/doc/current/reference/forms/types.html), dans `IngredientType.php` tous les éléments qu'il y a dans le builder ont un type.

On passe ces attributs au name, en lisant [la doc des champs TextType](https://symfony.com/doc/current/reference/forms/types/text.html#attr).

```php
<?php

namespace App\Form;

use App\Entity\Ingredient;

use Symfony\Component\Form\AbstractType;
use Symfony\Component\Form\Extension\Core\Type\TextType;
use Symfony\Component\Form\FormBuilderInterface;
use Symfony\Component\OptionsResolver\OptionsResolver;
use Symfony\Component\Validator\Constraints as Assert;

class IngredientType extends AbstractType
{
    public function buildForm(FormBuilderInterface $builder, array $options): void
    {
        $builder
            ->add('name', TextType::class,[
                'attr' => [
                    'class' => 'form-control',
                    'minlength'=>2,
                    'maxlength'=>50
                ],
                'label'=>'Nom',
                'label_attr'=>[
                    'class' => 'form-label mt-4'
                ],
                'constraints'=>[
                    new Assert\Length(min: 2, max: 50),
                    new Assert\NotBlank()
                ]
            ])
            ->add('price')
        ;
    }

    public function configureOptions(OptionsResolver $resolver): void
    {
        $resolver->setDefaults([
            'data_class' => Ingredient::class,
        ]);
    }
}
```

- `attr` correspond aux attributs et on y passe
  - La classe de Bootstrap
  - Le minimum car c’est le minimum de caractères qu’il nous faut
  - Le maximum car c’est le maximum autorisé
- Ensuite le label pour remplacer name par Nom
  - L’attribut du label on y reprend des class de bootstrap pour que ce soit plus élégant au visuel
- Puis nous avons les contraintes de notre entité
  1. Nous reprenons le use utilisé dans notre entité pour les constraints
  2. Nous appliquons les contraintes pour le min et le max
  3. Nous appliquons la contrainte pour le notblank.

Pour la ligne `new Assert\Length(min: 2, max: 50),`, on remarque qu'il faut passer des arguments nommés en paramètre.

Maintenant que nous avons fait la propriété `name`, occupons-nous de `price`, et l'on ajoute un bouton `submit`.

Voici ce que ça donne dans `src/Form/IngredientType.php`

```php
<?php

namespace App\Form;

use App\Entity\Ingredient;

use Symfony\Component\Form\AbstractType;
use Symfony\Component\Form\Extension\Core\Type\MoneyType;
use Symfony\Component\Form\Extension\Core\Type\SubmitType;
use Symfony\Component\Form\Extension\Core\Type\TextType;
use Symfony\Component\Form\FormBuilderInterface;
use Symfony\Component\OptionsResolver\OptionsResolver;
use Symfony\Component\Validator\Constraints as Assert;

class IngredientType extends AbstractType
{
    public function buildForm(FormBuilderInterface $builder, array $options): void
    {
        $builder
            ->add('name', TextType::class,[
                'attr' => [
                    'class' => 'form-control',
                    'minlength'=>2,
                    'maxlength'=>50
                ],
                'label'=>'Nom',
                'label_attr'=>[
                    'class' => 'form-label mt-4'
                ],
                'constraints'=>[
                    new Assert\Length(min: 2, max: 50),
                    new Assert\NotBlank()
                ]
            ])
            ->add('price', MoneyType::class,[
                'currency' => false,
                'attr'=> [
                    'class'=>'form-control'
                ],
                'label' => 'Prix ',
                'label_attr'=>[
                    'class' => 'form-label mt-4'
                ],
                'constraints' => [
                    new Assert\Positive(),
                ]
            ])
            ->add ('submit', SubmitType::class, [
                'attr'=>[
                    'class' => 'btn btn-primary mt-4'
                ],
                'label' => 'créer mon ingrédient'
            ])
        ;
    }

    public function configureOptions(OptionsResolver $resolver): void
    {
        $resolver->setDefaults([
            'data_class' => Ingredient::class,
        ]);
    }
}
```

> [!Note] On fait attention à ne pas remettre des contraintes qui existe déjà dans l'entité, le cas échéant on garde celle de l'entité.

Et `'currency' => false,` permet de supprimer le `£/€/$` qui s'ajoute automatiquement à la fin du label.

On peut voir la différence sur notre page <http://localhost:8000/ingredient/nouveau>, mais le bouton de submit ne fonctionne pas encore.

On va faire le traitement du formulaire, comme expliqué [dans la doc](https://symfony.com/doc/current/forms.html#processing-forms), on observe ce bloc de code

```php
// src/Controller/TaskController.php

// ...
use Symfony\Component\HttpFoundation\Request;

class TaskController extends AbstractController
{
    public function new(Request $request): Response
    {
        // set up a fresh $task object (remove the example data)
        $task = new Task();

        $form = $this->createForm(TaskType::class, $task);

        $form->handleRequest($request);
        if ($form->isSubmitted() && $form->isValid()) {
            // $form->getData() holds the submitted values
            // but, the original `$task` variable has also been updated
            $task = $form->getData();

            // ... perform some action, such as saving the task to the database

            return $this->redirectToRoute('task_success');
        }

        return $this->render('task/new.html.twig', [
            'form' => $form,
        ]);
    }
}
```

Dans `src/Controller/IngredientController.php` nous l'adaptons pour faire le traitement et la validation du formulaire, dans sa méthode `new()` :

- on injecte la dépendance `Request`
- on fait un handleRequest
- on fait la condition de la validation du formulaire

Dans la condition, on fait passer un dd des données de l'objet.

```php
<?php

namespace App\Controller;

use App\Entity\Ingredient;
use App\Form\IngredientType;
use App\Repository\IngredientRepository;
use Knp\Component\Pager\PaginatorInterface;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Attribute\Route;

final class IngredientController extends AbstractController
{
    /**
     * This method display all ingredients
     * @param IngredientRepository $ingredientRepository
     * @param PaginatorInterface $paginator
     * @param Request $request
     * @return Response
     */
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

    #[Route('/ingredient/nouveau', name: 'app_ingredient_new')]
    public function new(Request $request): Response
    {
        $ingredient = new Ingredient();
        $form = $this->createForm(IngredientType::class, $ingredient);

        $form->handleRequest($request);

        if($form->isSubmitted() && $form->isValid()){
            dd($form->getData());
        }

        return $this->render('pages/ingredient/new.html.twig',[
            'form' => $form
        ]);
    }
}
```

Dans notre page, quand on valide le formulaire <> on voit

```json
IngredientController.php on line 46:
App\Entity\Ingredient {#754 ▼
  -id: null
  -name: "Chocolat"
  -price: 4.0
  -createdAt: DateTimeImmutable @1773844551 {#755 ▶}
}
```

Dans cet exemple j'ai ajouté un produit "chocolat" à 4€, il n'y a pas encore d'id car il sera initialisé une fois les données envoyées à la bdd.

Maintenant nous allons persister et flush ces données grâce à `EntityManagerInterface` que l'on injecte dans `new()`.

On ajoute alors :

```php
$manager->persist($ingredient);
$manager->flush();
```

Et aussi on ajoute le `return` avec la redirection.

```php
return $this->redirectToRoute('app_ingredient');
```

Ce qui donne

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
    /**
     * This method display all ingredients
     * @param IngredientRepository $ingredientRepository
     * @param PaginatorInterface $paginator
     * @param Request $request
     * @return Response
     */
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

    #[Route('/ingredient/nouveau', name: 'app_ingredient_new')]
    public function new(Request $request, EntityManagerInterface $manager): Response
    {
        $ingredient = new Ingredient();
        $form = $this->createForm(IngredientType::class, $ingredient);

        $form->handleRequest($request);

        if($form->isSubmitted() && $form->isValid()){
            $manager->persist($ingredient);
            $manager->flush();

            return $this->redirectToRoute('app_ingredient');

        }

        return $this->render('pages/ingredient/new.html.twig',[
            'form' => $form
        ]);
    }
}
```

On a supprimé le `$ingredient = $form->getData();` de la condition, il retourne l’objet lié au formulaire ici à `Ingredient`. Mais comme `$ingredient` est passé à `createForm()`, `$form` **modifie directement cet objet** pendant `handleRequest()`. Donc `$ingredient` contient déjà les données soumises et persistées ; l’assignation `$ingredient = $form->getData()` est ainsi redondante.

On customise aussi le message sur l'attribut de contrainte du paramètre `price` sur l'entité `src/Entity/Ingredient.php`

```php
#[Assert\LessThan(value: 200, message: "Le prix doit être inférieur à {{ compared_value }}.")]
```

et

```php
#[Assert\Positive(message: "Le prix doit être un nombre positif")]
```

Pareil pour le formulaire `src/Form/IngredientType.php`, on modifie l'attribut de contrainte de longueur sur `name`

```php
'constraints' => [
    new Assert\Length(
        min: 2,
        max: 50,
        minMessage: "Minimum {{ limit }} caractères.",
        maxMessage: "Maximum {{ limit }} caractères."
    ),
    new Assert\NotBlank()
]
```

et on retire cette contrainte de `price`

```bash
'constraints' => [
    new Assert\Positive(),
]
```

L'attribut de contrainte est en doublon avec celui de l'entité; donc on préfère supprimer celui du formulaire.

On évite ainsi les messages d'erreur génériques en anglais, que ce soit des contraintes sur le formulaire, ou directement sur l'entité.

Voilà, nous avons fini cette partie.

---

J'ai corrigé les contrainte en doublon, c'est un peu n'importe quoi

`src/Entity/Ingredient.php`

```php
<?php

namespace App\Entity;

use App\Repository\IngredientRepository;
use DateTimeImmutable;
use Doctrine\ORM\Mapping as ORM;
use Symfony\Component\Validator\Constraints as Assert;


#[ORM\Entity(repositoryClass: IngredientRepository::class)]
class Ingredient
{
    #[ORM\Id]
    #[ORM\GeneratedValue]
    #[ORM\Column]
    private ?int $id = null;


    #[ORM\Column(length: 50)]
    #[Assert\NotBlank]
    #[Assert\Length(
        min: 2,
        max: 50,
        minMessage: 'Votre nom doit faire minimum {{ limit }} caractères en longueur',
        maxMessage: 'Votre nom doit faire maximum {{ limit }} caractères en longueur'
    )]
    private ?string $name = null;


    #[ORM\Column]
    #[Assert\Positive(message: "Le prix doit être un nombre positif")]
    #[Assert\LessThan(value: 200, message: "Le prix doit être inférieur à {{ compared_value }}.")]
    #[Assert\NotNull]
    private ?float $price = null;


    #[ORM\Column]
    #[Assert\NotNull]
    private ?\DateTimeImmutable $createdAt = null;

    public function __construct()
    {
        $this->createdAt = new DateTimeImmutable();
    }

    public function getId(): ?int
    {
        return $this->id;
    }

    public function getName(): ?string
    {
        return $this->name;
    }

    public function setName(string $name): static
    {
        $this->name = $name;

        return $this;
    }

    public function getPrice(): ?float
    {
        return $this->price;
    }

    public function setPrice(float $price): static
    {
        $this->price = $price;

        return $this;
    }

    public function getCreatedAt(): ?\DateTimeImmutable
    {
        return $this->createdAt;
    }

    public function setCreatedAt(\DateTimeImmutable $createdAt): static
    {
        $this->createdAt = $createdAt;

        return $this;
    }
}

```

et aussi `src/Form/IngredientType.php`

```php
<?php

namespace App\Form;

use App\Entity\Ingredient;

use Symfony\Component\Form\AbstractType;
use Symfony\Component\Form\Extension\Core\Type\MoneyType;
use Symfony\Component\Form\Extension\Core\Type\SubmitType;
use Symfony\Component\Form\Extension\Core\Type\TextType;
use Symfony\Component\Form\FormBuilderInterface;
use Symfony\Component\OptionsResolver\OptionsResolver;
use Symfony\Component\Validator\Constraints as Assert;

class IngredientType extends AbstractType
{
    public function buildForm(FormBuilderInterface $builder, array $options): void
    {
        $builder
            ->add('name', TextType::class, [
                'attr' => [
                    'class' => 'form-control',
                ],
                'label' => 'Nom',
                'label_attr' => [
                    'class' => 'form-label mt-4'
                ],
                'constraints' => [
                    new Assert\NotBlank()
                ]
            ])
            ->add('price', MoneyType::class, [
                'currency' => false, // supprime le €
                'attr' => [
                    'class' => 'form-control'
                ],
                'label' => 'Prix',
                'label_attr' => [
                    'class' => 'form-label mt-4'
                ],
            ])
            ->add('submit', SubmitType::class, [
                'attr' => [
                    'class' => 'btn btn-primary mt-4'
                ]
            ])
        ;
    }

    public function configureOptions(OptionsResolver $resolver): void
    {
        $resolver->setDefaults([
            'data_class' => Ingredient::class,
        ]);
    }
}
```

Pour uniformiser, j'ai viré

```php
->add('name', TextType::class,[
    'attr' => [
        'class' => 'form-control',
        'minlength'=>2,
        'maxlength'=>50
    ],
```

et

```php
'label' => 'créer mon ingrédient'
```

minlength et maxlength sont des vérifications html `<input minlength="2" maxlength="50">`, il vaut mieux uniformiser le feedback utilisateur et le dégager à la grenade, car ils sont interprété par le navigateur et non par symfony.

Pour le label, je le met dans la vue, permettant au formulaire d'être utilisé par la suite pour l'édition.

## Gestion erreur et custom des form

JE FERAIS LA PARTIE DES GESTION DES ERREURS APRÈS !!!!
<https://symfony.com/doc/current/form/form_customization.html>

dans la doc périmée de marmiton, j'ai ce bloc pour `templates/pages/ingredient/new.html.twig`, je l'ai modifié car c'était vraiment crade

```twig
{% extends "base.html.twig" %}

{% block body %}
	<div class="container">
		<h1 class="mt-4">Création d'un ingrédient</h1>

		{{ form_start(form) }}

		<div class="mb-3">
			{{ form_label(form.name, null, {'label_attr': {'class': 'form-label'}}) }}
			{{ form_widget(form.name, {
      'attr': {
        'class': 'form-control' ~ (form_errors(form.name) ? ' is-invalid' : '')
      }
    }) }}
			<div class="invalid-feedback">
				{{ form_errors(form.name) }}
			</div>
		</div>

		<div class="mb-3">
			{{ form_label(form.price, null, {'label_attr': {'class': 'form-label'}}) }}
			{{ form_widget(form.price, {
      'attr': {
        'class': 'form-control' ~ (form_errors(form.price) ? ' is-invalid' : '')
      }
    }) }}
			<div class="invalid-feedback">
				{{ form_errors(form.price) }}
			</div>
		</div>

		<div class="mt-4">
			{{ form_widget(form.submit, {'attr': {'class': 'btn btn-primary'}, 'label': 'Créer mon ingrédient'}) }}
		</div>

		{{ form_end(form) }}
	</div>
{% endblock %}
```
