# 14 Crud recette part 3

Maintenant que la vue est finie nous nous occupons du create.

## La méthode publique `new()`

Dans `src/Controller/RecipeController.php`, derrière la méthode `index()`, on ajoute la méthode `new()`

```php
#[Route('/recette/nouvelle', name: 'app_recipe_new', methods: ['GET', 'POST'])]
public function new(): Response
{
    return $this->render('pages/recipe/new.html.twig');
}
```

Et l'on crée le template de vue

```bash
touch templates/pages/recipe/new.html.twig
```

Et on y met

```twig
{% extends "base.html.twig" %}

{% block body %}
  <div class="container">
  <h1 class="mt-4">Création d'une recette</h1>
  </div>
{% endblock %}
```

Dans `templates/pages/recipe/index.html.twig`, on peut décommenter

```php
{# <a href="{{ path('app_recipe_new') }}" class="btn btn-primary mt-4">Ajouter une recette</a> #}
```

En pensant à commenter les `a href` modifier/supprimer qui n'existent pas encore.

Maintenant on va créer notre formulaire

```bash
symfony console ma:fo Recipe Recipe
```

Le premier argument sert à nommer le formulaire (sera ajoué `Type` au nom) et le deuxième à indiquer sur quelle entité il s'applique.

Dans `src/Form/RecipeType.php` on vire `created_at` et `updates_at` qui sont respectivement gérés par le constructeur et le lifecycle callback.

On y ajoute également un `submit`

```php
<?php

namespace App\Form;

use App\Entity\Ingredient;
use App\Entity\Recipe;
use Symfony\Bridge\Doctrine\Form\Type\EntityType;
use Symfony\Component\Form\AbstractType;
use Symfony\Component\Form\FormBuilderInterface;
use Symfony\Component\OptionsResolver\OptionsResolver;

class RecipeType extends AbstractType
{
    public function buildForm(FormBuilderInterface $builder, array $options): void
    {
        $builder
            ->add('name')
            ->add('time')
            ->add('nb_people')
            ->add('difficulty')
            ->add('description')
            ->add('price')
            ->add('is_favorite')
            ->add('ingredients', EntityType::class, [
                'class' => Ingredient::class,
                'choice_label' => 'id',
                'multiple' => true,
            ])
            ->add('submit')
        ;
    }

    public function configureOptions(OptionsResolver $resolver): void
    {
        $resolver->setDefaults([
            'data_class' => Recipe::class,
        ]);
    }
}
```

Maintenant il faut inclue le formulaire dans la vue, on ouvre le contrôleur `src/Controller/RecipeController.php`

```php
#[Route('/recette/nouvelle', name: 'app_recipe_new', methods: ['GET', 'POST'])]
public function new(): Response
{
    $recipe = new Recipe();
    $form = $this->createForm(RecipeType::class, $recipe);
    return $this->render('pages/recipe/new.html.twig', [
        'form' => $form
    ]);
}
```

On l'ajoute dans sa vue `templates/pages/recipe/new.html.twig`

```twig
{% extends "base.html.twig" %}

{% block body %}
  <div class="container">
  <h1 class="mt-4">Création d'une recette</h1>
    {{ form(form) }}
  </div>
{% endblock %}
```

Et dans `src/Form/RecipeType.php` on corrige notre submit, et on simplifie le `->add('ingredients')`

```php
<?php

namespace App\Form;

use App\Entity\Ingredient;
use App\Entity\Recipe;
use Symfony\Bridge\Doctrine\Form\Type\EntityType;
use Symfony\Component\Form\AbstractType;
use Symfony\Component\Form\Extension\Core\Type\SubmitType;
use Symfony\Component\Form\FormBuilderInterface;
use Symfony\Component\OptionsResolver\OptionsResolver;

class RecipeType extends AbstractType
{
    public function buildForm(FormBuilderInterface $builder, array $options): void
    {
        $builder
            ->add('name')
            ->add('time')
            ->add('nb_people')
            ->add('difficulty')
            ->add('description')
            ->add('price')
            ->add('is_favorite')
            ->add('ingredients')
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
            'data_class' => Recipe::class,
        ]);
    }
}
```

En plus il nous faut créer une une méthode `__toString()` dans l'entité `src/Entity/Ingredient.php`

```php
public function __toString()
{
    return $this->name;
}
```

La méthode magique `__toString()` définit comment un objet se transforme automatiquement en chaîne de caractères lorsqu’on l’utilise dans un contexte qui attend une string.

Une méthode magique en PHP est une fonction spéciale dont le nom commence par `__` et qui permet à un objet d’interagir automatiquement avec certaines opérations du langage, comme la création, la conversion ou l’accès aux propriétés, c'est pour le `->add('ingredients')` dans notre cas de figure.

## Customiser le formulaire

Maintenant on va customiser le formulaire `src/Form/RecipeType.php`

Par sécurité on met des contraintes ici (en plus des contraintes d'entité), le formulaire permettra de ne pas envoyer de requête vers le serveur (ça bloque au client en gros).

Voici ce que donne `src/Form/RecipeType.php`

```php
<?php

namespace App\Form;

use App\Entity\Ingredient;
use App\Entity\Recipe;
use App\Repository\IngredientRepository;
use Doctrine\ORM\QueryBuilder;
use Symfony\Component\Form\Extension\Core\Type\IntegerType;
use Symfony\Component\Form\Extension\Core\Type\TextType;
use Symfony\Bridge\Doctrine\Form\Type\EntityType;
use Symfony\Component\Form\AbstractType;
use Symfony\Component\Form\Extension\Core\Type\CheckboxType;
use Symfony\Component\Form\Extension\Core\Type\MoneyType;
use Symfony\Component\Form\Extension\Core\Type\RangeType;
use Symfony\Component\Form\Extension\Core\Type\SubmitType;
use Symfony\Component\Form\Extension\Core\Type\TextareaType;
use Symfony\Component\Form\FormBuilderInterface;
use Symfony\Component\OptionsResolver\OptionsResolver;
use Symfony\Component\Validator\Constraints as Assert;

class RecipeType extends AbstractType
{
    public function buildForm(FormBuilderInterface $builder, array $options): void
    {
        $builder
            ->add('name', TextType::class, [
                'attr' => ['class' => 'form-control'],
                'label' => "Nom",
                'label_attr' => ['class' => 'form-label mt-4'],
                'constraints' => [
                    new Assert\NotBlank(),
                    new Assert\Length(
                        min: 2,
                        max: 50,
                        minMessage: 'Votre nom doit faire minimum {{ limit }} caractères en longueur',
                        maxMessage: 'Votre nom doit faire maximum {{ limit }} caractères en longueur'
                    )
                ]
            ])
            ->add('time', IntegerType::class, [
                'attr' => ['class' => 'form-control'],
                'label' => "Durée (minutes)",
                'label_attr' => ['class' => 'form-label mt-4'],
                'constraints' => [
                    new Assert\Range(
                        min: 1,
                        max: 1440,
                        notInRangeMessage: 'Votre durée doit être comprise entre {{ min }} et {{ max }} minutes'
                    )
                ]
            ])
            ->add('nb_people', IntegerType::class, [
                'attr' => ['class' => 'form-control'],
                'label' => "Nombre de participants",
                'label_attr' => ['class' => 'form-label mt-4'],
                'constraints' => [
                    new Assert\Range(
                        min: 1,
                        max: 12,
                        notInRangeMessage: 'Votre nombre de participants doit être compris entre {{ min }} et {{ max }} participants'
                    )
                ]
            ])
            ->add('difficulty', RangeType::class, [
                'attr' => ['class' => 'form-range', 'min' => 1, 'max' => 5],
                'label' => "Difficulté",
                'label_attr' => ['class' => 'form-label mt-4'],
                'constraints' => [
                    new Assert\Range(
                        min: 1,
                        max: 5,
                        notInRangeMessage: 'La difficulté doit doit être comprise entre {{ min }} et {{ max }}'
                    )
                ]
            ])
            ->add('description', TextareaType::class, [
                'attr' => ['class' => 'form-control'],
                'label' => "Description",
                'label_attr' => ['class' => 'form-label mt-4'],
                'constraints' => [
                    new Assert\NotBlank(),
                    new Assert\Length(
                        min: 2,
                        max: 50,
                        minMessage: 'Votre description doit faire minimum {{ limit }} caractères en longueur',
                        maxMessage: 'Votre description doit faire maximum {{ limit }} caractères en longueur'
                    )
                ]
            ])
            ->add('price', MoneyType::class, [
                'currency' => false, // supprime le €
                'attr' => [
                    'class' => 'form-control'
                ],
                'label' => 'Prix (€)',
                'label_attr' => [
                    'class' => 'form-label mt-4'
                ],
                'constraints' => [
                    new Assert\NotBlank(),
                    new Assert\Range(
                        min: 1,
                        max: 1000,
                        notInRangeMessage: 'Le prix doit doit doit être compris entre {{ min }} et {{ max }} euros'
                    ),
                ]
            ])
            ->add('is_favorite', CheckboxType::class, [
                'label' => "Favori ?",
                'label_attr' => ['class' => 'form-label mt-4'],
            ])
            ->add('ingredients', EntityType::class, [
                'class' => Ingredient::class,
                'label' => 'Ingredients',
                'label_attr' => ['class' => 'form-label mt-4'],
                'query_builder' => function (IngredientRepository $ir): QueryBuilder {
                    return $ir->createQueryBuilder('i')
                        ->orderBy('i.name', 'ASC');
                },
                'choice_label' => 'name', // champ affiché dans la liste
                'multiple' => true,
                'expanded' => true, // true pour des checkboxes, false pour un select multiple
            ])
            ->add('submit', SubmitType::class, [
                'attr' => ['class' => 'btn btn-primary mt-4'],
                'label' => 'Créer ma recette'
            ])
        ;
    }

    public function configureOptions(OptionsResolver $resolver): void
    {
        $resolver->setDefaults([
            'data_class' => Recipe::class,
        ]);
    }
}
```

Pour la choix des ingrédients `add('ingredients')` on précise bien que c'est un type d'entité `EntityType::class` et on l'importe dans sa classe `'class' => Ingredient::class,`.

Via `query_builder`, on fait une requête qui permet d'afficher tous les ingrédients dans la liste, et on lui met l'option `multiple` (pour en choisir plusieurs) et `expanded` pour afficher des checkbox (sinon ce sera une espèce de select avec une liste).

On s'est inspiré de [la partie Custom Query de la doc](https://symfony.com/doc/current/reference/forms/types/entity.html#using-a-custom-query-for-the-entities) et de ce bloc :

```php
use App\Entity\User;
use Doctrine\ORM\EntityRepository;
use Doctrine\ORM\QueryBuilder;
use Symfony\Bridge\Doctrine\Form\Type\EntityType;
// ...

$builder->add('users', EntityType::class, [
    'class' => User::class,
    'query_builder' => function (EntityRepository $er): QueryBuilder {
        return $er->createQueryBuilder('u')
            ->orderBy('u.username', 'ASC');
    },
    'choice_label' => 'username',
]);
```

On a aussi regardé [la partie "usage basique"](https://symfony.com/doc/current/reference/forms/types/entity.html#basic-usage) pour comprendre l'utilisation de `multiple` et `expanded`.

## Customiser la vue

Tout comme pour la vue de création d'ingrédients, on va faire un rendu personnalisé pour la vue de création de recette.

Dans le fichier `templates/pages/recipe/new.html.twig` nous avons donc

```twig

```
