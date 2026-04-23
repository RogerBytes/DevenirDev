# 06 Les fixtures

Les fixtures permettent de générer rapidement de fausses données en nous basant sur [la documentation des fixtures](https://symfony.com/bundles/DoctrineFixturesBundle/current/index.html).

## Installation des bundles

Vu que nous avons utilisé l'option `--webapp` lors de la création du projet, nous utilisons déjà `Symfony Flex` par défaut.

Nous importons donc ce bundle avec :

```bash
composer require --dev orm-fixtures
```

Cela créé `src/DataFixtures/AppFixtures.php`.

Nous installons également [le bundle FakerPHP](https://fakerphp.org/), qui permettra de générer automatiquement de fausses données réalistes.

```bash
composer require fakerphp/faker
```

## Modification et premier ajout de fixture

Ouvrons `src/DataFixtures/AppFixtures.php`

```php
<?php

namespace App\DataFixtures;

use Doctrine\Bundle\FixturesBundle\Fixture;
use Doctrine\Persistence\ObjectManager;

class AppFixtures extends Fixture
{
    public function load(ObjectManager $manager): void
    {
        // $product = new Product();
        // $manager->persist($product);

        $manager->flush();
    }
}
```

C'est dans la méthode `load()` que l'on va créer de faux ingrédients via ces étapes :

1. Créer une variable `$ingredient` qui sera un nouvel objet `Ingredient`.
2. Définir le nom avec `$ingredient->setName("ingrédient #1")`.
3. Définir le prix avec `$ingredient->setPrice(3.0)`.
4. Persister l’objet avec l’`ObjectManager` injecté en paramètre `$manager` puis exécuter `$manager->flush()` pour enregistrer en base.

Doctrine étant un ORM, c'est lui qui va gérer les fixtures et leur envoie en bdd.

Le flush signifie que l'on execute en bdd toutes les actions le précédant.

Voilà ce que ça donne

```bash
<?php

namespace App\DataFixtures;

use App\Entity\Ingredient;
use Doctrine\Bundle\FixturesBundle\Fixture;
use Doctrine\Persistence\ObjectManager;

class AppFixtures extends Fixture
{
    public function load(ObjectManager $manager): void
    {
        $ingredient = new Ingredient();
        $ingredient
            ->setName("ingrédient #1")
            ->setPrice(3.0);
        $manager->persist($ingredient);

        $manager->flush();
    }
}
```

Maintenant dans `src/Entity/Ingredient.php`, l'on va faire un constructeur, entre les propriétés et les getters/setters.

```php
<?php

namespace App\Entity;

use App\Repository\IngredientRepository;
use DateTimeImmutable;
// on a bien importé le DateTimeImmutable
use Doctrine\ORM\Mapping as ORM;
use Symfony\Component\Validator\Constraints as Assert;

#[ORM\Entity(repositoryClass: IngredientRepository::class)]
class Ingredient
{
    // les propriétés de la classe
    public function __construct()
    {
        $this->createdAt = new DateTimeImmutable();
    }
    // les getters et les setters de la classe
}
```

Ainsi, il va automatiquement remplir l'attribut `createdAt` avec un `DateTimeImmutable` lors d'une entrée dans la table.

## Chargement des fixtures

Nous lançons l'envoie des fixtures avec

```bash
symfony console doctrine:fixtures:load
```

On peut forcer la validation directement

```bash
symfony console doctrine:fixtures:load -n
```

L'option `-n` dit de passer en mode non interactif (diminutif de `--no-interaction`), évitant ainsi la confirmation.

On peut noter dans **DBeaver** que les données sont bien en base.

## Ajout de fixtures avec des données multiples

Maintenant, en passant par une boucle, nous allons ajouter 50 ingrédients d'un coup.

Notez que l'interpolation de `$i` est gérée entre double quotes et aussi que nous utilisons le randomizer `md_rand()` pour le prix.

```php
<?php

namespace App\DataFixtures;

use App\Entity\Ingredient;
use Doctrine\Bundle\FixturesBundle\Fixture;
use Doctrine\Persistence\ObjectManager;

class AppFixtures extends Fixture
{
    public function load(ObjectManager $manager): void
    {
        for ($i = 0; $i < 50; $i++) {
            $ingredient = new Ingredient();
            $ingredient
                ->setName("ingrédient $i")
                ->setPrice(mt_rand(0,100));
            $manager->persist($ingredient);
        }

        $manager->flush();
    }
}
```

On lance le chargement des fixtures :

```bash
symfony console doctrine:fixtures:load -n
```

Dans DBeaver nous observons que nos données sont bien ajoutées dans la table `ingredient`.

## Utilisation de FakerPHP

On retourne dans `src/DataFixtures/AppFixtures.php`.

Dans `$faker`, on appelle la méthode statique `create()` de la classe `Factory`, qui retourne une instance de Faker configurée en français (`fr_FR`). Il faut déclarer cette variable dans notre méthode `load()`.

Ensuite, dans la boucle, on va passer par la syntaxe `$faker->word` et `$faker->randomFloat(2, 0.5, 199.9)`, ces formateurs sont listés dans [la doc de FakerPHP](https://fakerphp.org/).

En pratique, cela donne :

```php
<?php

namespace App\DataFixtures;

use App\Entity\Ingredient;
use Doctrine\Bundle\FixturesBundle\Fixture;
use Doctrine\Persistence\ObjectManager;
use Faker\Factory;


class AppFixtures extends Fixture
{
    public function load(ObjectManager $manager): void
    {
        $faker = Factory::create('fr_FR');
        for ($i = 0; $i < 50; $i++) {
            $ingredient = new Ingredient();
            $ingredient
                ->setName($faker->word)
                ->setPrice($faker->randomFloat(2, 0.5, 199.9));
            $manager->persist($ingredient);
        }

        $manager->flush();
    }
}
```

Pour information, `word` (par exemple) est en fait une propriété magique qui appelle une méthode interne, pas une méthode “normale”.

On peut relancer le chargement des DataFixtures :

```bash
symfony console doctrine:fixtures:load -n
```

Dans DBeaver, nous voyons que les données ont bien été chargées, la partie sur les fixtures est finie.
