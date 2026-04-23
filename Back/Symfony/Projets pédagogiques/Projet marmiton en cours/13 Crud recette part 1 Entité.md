# 12 Crud recette part 1

Maintenant on va créer une entité `recipe`.

Voici les paramètres de l'objet

- `name` de type `string` 50
- `time` de type `integer`
- `nb_people` de type `integer` nullable
- `difficulty` de type `integer` nullable
- `description` de type `text`
- `price` de type `decimal` [precision 6 et scale 2] (de -9999.99 à 9999.99, mais on limitera par la suite à 1000) nullable
- `is_favorite` de type `bool`
- `created_at` de type `datetime_immutable`
- `updated_at` de type `datetime_immutable` nullable
- `ingredients` de type `relation` ManyToMany vers la classe `Ingredient`

On préfère `DECIMAL` à `float` pour les prix car `DECIMAL` conserve **tous les chiffres exactement**, alors que `float` peut provoquer des **erreurs d’arrondi** en raison de sa représentation binaire approximative. Cela garantit que les calculs financiers restent précis et fiables.

Le `updated_at` est nullable, car lors de l’insertion initiale seule la propriété `created_at` est remplie dans le constructeur. La date de mise à jour sera gérée plus tard via le `PreUpdate` (expliqué plus tard).

Pour la relation on choisit `ManyToMany` car la collection `ingredients` peut avoir plusieurs ingredients et un ingrédient peut être dans plusieurs recettes.

On accepte les choix par défaut pour la relation ensuite,

Donc on utilise la commande

```bash
symfony console ma:en Recipe
```

Et on lui passe les paramètres listés au-dessus.

On n'oublie pas de faire la migration et de migrer pour que Doctrine puisse convertir nos entités en BDD

```bash
symfony console ma:mi
symfony console do:mi:mi
```

On utilise `UniqueEntity()` sur la classe `Recipe` et lui précise `name` comme propriété, doctrine empêchera deux recettes d'avoir le même nom, c'est ce que l'on appelle un attribut de classe, il s'impose à l'ensemble et pas seulement à une seule propriété.

```php
#[ORM\Entity(repositoryClass: RecipeRepository::class)]
#[UniqueEntity('name')]
class Recipe
```

Maintenant on passe aux attributs de propriétés.

Pour récupérer la bonne classe, on peut appeler `Length` afin de faire l'import `use Symfony\Component\Validator\Constraints\Length;` et le modifier en `use Symfony\Component\Validator\Constraints as Assert;`

Pour la propriété `name`, on reprend simplement les mêmes attributs de contrainte que pour le `name` de l'entité `Ingredient.php`

```php
#[Assert\NotBlank]
#[Assert\Length(
    min: 2,
    max: 50,
    minMessage: 'Votre nom doit faire minimum {{ limit }} caractères en longueur',
    maxMessage: 'Votre nom doit faire maximum {{ limit }} caractères en longueur'
)]
```

Pour le `time`, on veut qu'il soit positif et qu'il ne soit pas supérieur à 1440 (1440 c'est le nombre de minutes dans une journée). Pour combiner les deux on utilise

```php
#[Assert\Range(
    min: 1,
    max: 1440,
    notInRangeMessage: 'Votre durée doit être comprise entre {{ min }} et {{ max }} minutes'
)]
```

Pareil pour `nbPeople`, où on va limiter à 12 personnes,

```php
#[Assert\Range(
    min: 1,
    max: 12,
    notInRangeMessage: 'Votre nombre de participants doit être compris entre {{ min }} et {{ max }} participants'
)]
```

Et pour `difficulty` on limite à 5

```php
#[Assert\Range(
    min: 1,
    max: 5,
    notInRangeMessage: 'La difficulté doit doit être comprise entre {{ min }} et {{ max }}'
)]
```

Pour la description, on ajoute `Assert\NotBlank()` comme attribut.

```php
#[Assert\NotBlank(message : "Veuillez remplir la description")]
```

Pour le prix on limite à 1000.

```php
#[Assert\Range(
    min: 1,
    max: 1000,
    notInRangeMessage: 'Le prix doit doit doit être compris entre {{ min }} et {{ max }} euros'
)]
```

Et on met l'attribut `Assert\NotNull()` à `createdAt`.

Maintenant on passe au constructeur (que l'on met à la fin des déclarations de propriétés), on y ajoute l'affectation automatique de `DateTimeImmutable()` à `created_at`.

```php
public function __construct()
{
    $this->ingredients = new ArrayCollection();
    $this->created_at = new DateTimeImmutable();
}
```

Pour faciliter les calculs on modifie le type du getter de price, afin que ça retourne du float.
En gros si ce n'est pas null, en retour on convertit en float `(float) $this->price` sinon sinon on retourne null

```php
public function getPrice(): ?float
{
    return $this->price !== null ? (float) $this->price : null;
}
```

Attention, le setter reste en string (pour Doctrine) lui on ne doit pas le changer !

Maintenant on va consulter [la documentation des events doctrine](https://symfony.com/doc/current/doctrine/events.html).

Si on s'intéresse au [lifecycle callbacks](https://symfony.com/doc/current/doctrine/events.html#doctrine-lifecycle-callbacks) on peut observer dans le bloc de démo, l'attribut `PrePersist`

```php
#[ORM\PrePersist]
public function setCreatedAtValue(): void
{
    $this->createdAt = new \DateTimeImmutable();
}
```

`#[ORM\PrePersist]` permet de remplir automatiquement certaines propriétés, comme `createdAt`, **uniquement au moment où l’entité est réellement insérée en base**, contrairement au constructeur qui s’exécute dès que l’objet est créé.

- **`PrePersist`** → juste avant d’insérer **une nouvelle entité** en base.
- **`PostPersist`** → juste après l’insertion.
- **`PreUpdate`** → juste avant de **mettre à jour** une entité existante.
- **`PostUpdate`** → juste après la mise à jour.

Pour `created_at`, on peut utiliser `PrePersist`. Pour `updated_at`, c’est **`PreUpdate`**.
Nous n'allons pas ajouter pour `created_at` car c'est déjà géré par le constructeur.

Donc on ajoute le lifecycle callbacks suivant comme attribut de méthode.

```php
#[ORM\PreUpdate]
public function setUpdatedAtValue(): void
{
    $this->updated_at = new DateTimeImmutable();
}
```

Et on ajoute l’attribut de classe `#[ORM\HasLifecycleCallbacks]`, qui indique à Doctrine d’exécuter automatiquement les méthodes annotées avec `#[ORM\PrePersist]` ou `#[ORM\PreUpdate]` au moment de persister ou de mettre à jour cette entité.

Maintenant que nous avons fini de paramétrer l'entité, nous faisons la migration.

```bash
symfony console ma:mi
symfony console do:mi:mi
```

En ouvrant `Dbeaver`, nous remarquons que Doctrine a crée une table de jointure nommée `recipe_ingredient`.

Cette table contient uniquement les IDs de Recipe et Ingredient pour gérer la relation ManyToMany

## Ajout de fixtures

On retourne dans `src/DataFixtures/AppFixtures.php`, on ajoute des commentaires

```php
// data ingredient
```

et

```php
// data recipes
```

Afin de distinguer nos fixtures. avant de faire notre boucle pour ingredient, on ajoute `$ingredients = [];` et `$ingredients[]= $ingredient;` avant le persist.

Maintenant pour la boucle des recettes, on la fait sur 25.

Ensuite on set chacune des propriétés.

```php
<?php

namespace App\DataFixtures;

use App\Entity\Ingredient;
use App\Entity\Recipe;
use Doctrine\Bundle\FixturesBundle\Fixture;
use Doctrine\Persistence\ObjectManager;
use Faker\Factory;

class AppFixtures extends Fixture
{
    public function load(ObjectManager $manager): void
    {
        $faker = Factory::create('fr_FR');

        // Data ingrédient
        $ingredients = [];
        for ($i = 0; $i < 50; $i++) {
            $ingredient = new Ingredient();
            $ingredient
                ->setName("ingrédient \"$faker->word\"")
                ->setPrice($faker->randomFloat(2, 0.5, 199.9));
            $ingredients[] = $ingredient;
            $manager->persist($ingredient);
        }

        // Data recipe
        for ($j = 0; $j < 25; $j++) {
            $recipe = new Recipe();
            $recipe
                ->setName("recette \"$faker->word\"")
                ->setTime(mt_rand(1, 1440))
                ->setNbPeople(mt_rand(0, 1) === 1 ? mt_rand(1, 12) : null)
                ->setDifficulty(mt_rand(0, 1) === 1 ? mt_rand(1, 5) : null)
                ->setDescription($faker->text(300))
                ->setPrice(mt_rand(0, 1) === 1 ? (string) mt_rand(1, 1000) : null)
                ->setIsFavorite(mt_rand(0, 5) === 5 ? true : false);
            $manager->persist($recipe);
        }


        $manager->flush();
    }
}
```

- **`setName()`** – Définit le nom de la recette. On utilise `$faker->word` pour générer un mot aléatoire et unique.
- **`setTime()`** – Définit la durée de préparation en minutes (1 à 1440).
- **`setNbPeople()`** – Définit le nombre de personnes pour la recette. Peut être `null` aléatoirement pour simuler des recettes sans restriction.
- **`setDifficulty()`** – Définit la difficulté (1 à 5) ou `null` si pas défini.
- **`setDescription()`** – Définit la description de la recette avec du texte aléatoire de 300 caractères.
- **`setPrice()`** – Définit le prix de la recette, ou `null` pour certaines recettes.
- **`setIsFavorite()`** – Définit si la recette est favorite (`true` ou `false`) de manière aléatoire.
- On a fait attention à changer `$i` dans la boucle, sinon ça casse le code !

Il nous manque encore `$ingredients` avant de persister `$recipe` on fait cette boucle

```php
for ($k=0; $k < mt_rand(3,12) ; $k++) {
    $recipe->addIngredient($ingredients[mt_rand(0,count($ingredients)-1)]);
}
```

- Elle ajoute entre 3 et 12 ingrédients aléatoires à la recette `$recipe`.
- `mt_rand(3,12)` décide combien d’ingrédients seront ajoutés pour cette recette.
- À chaque itération, `mt_rand(0,count($ingredients)-1)` choisit un ingrédient aléatoire dans le tableau `$ingredients`.
- `addIngredient()` ajoute cet ingrédient à la collection `ingredients` de la recette, créant ainsi la relation ManyToMany.

Voici `src/DataFixtures/AppFixtures.php` terminé

```php
<?php

namespace App\DataFixtures;

use App\Entity\Ingredient;
use App\Entity\Recipe;
use Doctrine\Bundle\FixturesBundle\Fixture;
use Doctrine\Persistence\ObjectManager;
use Faker\Factory;

class AppFixtures extends Fixture
{
    public function load(ObjectManager $manager): void
    {
        $faker = Factory::create('fr_FR');

        // Data ingrédient
        $ingredients = [];
        for ($i = 0; $i < 50; $i++) {
            $ingredient = new Ingredient();
            $ingredient
                ->setName("ingrédient \"$faker->word\"")
                ->setPrice($faker->randomFloat(2, 0.5, 199.9));
            $ingredients[] = $ingredient;
            $manager->persist($ingredient);
        }

        // Data recipe
        for ($j = 0; $j < 25; $j++) {
            $recipe = new Recipe();
            $recipe
                ->setName("recette \"$faker->word\"")
                ->setTime(mt_rand(1, 1440))
                ->setNbPeople(mt_rand(0, 1) === 1 ? mt_rand(1, 12) : null)
                ->setDifficulty(mt_rand(0, 1) === 1 ? mt_rand(1, 5) : null)
                ->setDescription($faker->text(300))
                ->setPrice(mt_rand(0, 1) === 1 ? (string) mt_rand(1, 1000) : null)
                ->setIsFavorite(mt_rand(0, 5) === 5 ? true : false);

            for ($k=0; $k < mt_rand(3,12) ; $k++) {
                $recipe->addIngredient($ingredients[mt_rand(0,count($ingredients)-1)]);
            }

            $manager->persist($recipe);
        }


        $manager->flush();
    }
}
```

Il nous reste encore à lancer les fixtures.

```bash
symfony console do:fi:lo -n
```

On peut ouvrir `Dbeaver` et remarquer que nos tables (y compris la table de jointures qui met plusieurs ingrédients à une recette) sont bien remplies avec nos fixtures.

Voilà, cette partie est finie.
