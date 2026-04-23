# 05 Assert et contraintes

Dans ce chapitre nous traitons la validation des données en nous basant [sur la documentation de validation](https://symfony.com/doc/current/validation.html), nous nous concentrons donc sur l'entité `src/Entity/Ingredient.php`.
Pour info, quand on utilise `as Assert`, on peut traduire `Assert` en `Assertion`, c'est à dire une affirmation (ce qui entraîne la contrainte, donc `Assert` c'est la contrainte.

Nous allons sur la [partie des contraintes](https://symfony.com/doc/current/validation.html#supported-constraints) et en particulier [String Constraints](https://symfony.com/doc/current/validation.html#string-constraints) dans la partie [Length](https://symfony.com/doc/current/reference/constraints/Length.html).

La documentation montre comment appliquer cette contrainte directement dans les entités.

Dans le bloc de code, on est sur `Attributes` et l'on voit :

```php
// src/Entity/Participant.php
namespace App\Entity;

use Symfony\Component\Validator\Constraints as Assert;

class Participant
{
    #[Assert\Length(
        min: 2,
        max: 50,
        minMessage: 'Your first name must be at least {{ limit }} characters long',
        maxMessage: 'Your first name cannot be longer than {{ limit }} characters',
    )]
    protected string $firstName;
}
```

On commence par importer la classe suivante.  
Pour faire l'import auto et ensuite faire l'alias `as`, il faut appeler la classe `NotBlank` et corriger/compléter ensuite

```php
use Symfony\Component\Validator\Constraints as Assert;
```

On ajoute ensuite des attributs sur la propriété `name` :

```php
    #[ORM\Column(length: 50)]
    #[Assert\Length(
        min: 2,
        max: 50,
        minMessage: 'Your first name must be at least {{ limit }} characters long',
        maxMessage: 'Your first name cannot be longer than {{ limit }} characters',
    )]
    private ?string $name = null;
```

Le minimum est fixé à deux caractères et le maximum à cinquante, ce qui correspond aux contraintes souhaitées. Nous pouvons maintenant passer à la contrainte de la deuxième propriété.

Pour les [Number Constraints](https://symfony.com/doc/current/reference/constraints.html#number-constraints) il y a [Positive](https://symfony.com/doc/current/reference/constraints/Positive.html) comme option.

Dans le bloc de code, on est sur `Attributes` et l'on voit :

```php
// src/Entity/Employee.php
namespace App\Entity;

use Symfony\Component\Validator\Constraints as Assert;

class Employee
{
    #[Assert\Positive]
    protected int $income;
}
```

Nous avons donc déjà importé la classe avec `use`.

On ajoute ensuite l'attribut de contrainte sur la propriété `price` :

```php
    #[ORM\Column]
    #[Assert\Positive]
    private ?float $price = null;
```

En plus d'être une valeur positive, regardons maintenant [les Comparison Constraints](https://symfony.com/doc/current/reference/constraints.html#comparison-constraints) et en particulier [LessThan](https://symfony.com/doc/current/reference/constraints/LessThan.html) afin de mettre une limite maximum.

Dans le bloc de code, on est sur `Attributes` et l'on voit :

```php
// src/Entity/Person.php
namespace App\Entity;

use Symfony\Component\Validator\Constraints as Assert;

class Person
{
    #[Assert\LessThan(5)]
    protected int $siblings;

    #[Assert\LessThan(
        value: 80,
    )]
    protected int $age;
}
```

L’import (via `use`) ayant déjà été réalisé précédemment, il n’est pas nécessaire de le répéter.

On ajoute ensuite la contrainte sur la propriété :

```php
    #[ORM\Column]
    #[Assert\Positive]
    #[Assert\LessThan(200)]
    private ?float $price = null;
```

Je ne re-détaille pas toute la démarche, mais on fait de même pour la [Basic Constraints NotBlank](https://symfony.com/doc/7.4/reference/constraints/NotBlank.html) sur l'attribut `name` (afin d’empêcher l’enregistrement d’une valeur vide) et la [Basic Constraints NotNull](https://symfony.com/doc/current/reference/constraints/NotNull.html) sur les attributs `price` (La contrainte `NotNull` empêche l’enregistrement d’une valeur `null`, même si la propriété est typée en `?float`) et `createdAt`.

Ce qui nous donne :

```php
    #[ORM\Column(length: 50)]
    #[Assert\NotBlank]
    #[Assert\Length(
        min: 2,
        max: 50,
        minMessage: 'Your first name must be at least {{ limit }} characters long',
        maxMessage: 'Your first name cannot be longer than {{ limit }} characters',
    )]
    private ?string $name = null;

    #[ORM\Column]
    #[Assert\Positive]
    #[Assert\LessThan(200)]
    #[Assert\NotNull]
    private ?float $price = null;

    #[ORM\Column]
    #[Assert\NotNull]
    private ?\DateTimeImmutable $createdAt = null;
```

Les contraintes `Assert` sont utilisées par le système de validation de Symfony et n'affectent pas directement le schéma de la base de données.
Il est donc probable que Doctrine ne détecte aucune modification lors de la génération de migration.

Ces contraintes permettent de garantir la validité des données avant leur enregistrement en base de données.
