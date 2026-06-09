# Tests unitaires

Un test unitaire est un test automatisé qui vérifie qu’une classe ou une méthode produit le comportement attendu.
Il permet de s’assurer qu’un morceau de code fonctionne correctement de manière isolée.
Dans une application, il est souvent utilisé pour vérifier la logique métier, mais aussi les comportements simples d’une classe.
Dans Symfony, on utilise généralement PHPUnit.

## Dépendances

On vérifie que le répertoire `tests` se trouve bien à la racine du projet.
Et on vérifie que `PhpUnit` est installé avec

```bash
composer show phpunit/phpunit
```

S'il ne retourne rien, on l'installe avec

```bash
composer require --dev phpunit/phpunit:^11.0
```

## Contexte du cours

Ici on va utiliser l'entité `src/Entity/Market.php`

```php
<?php

namespace App\Entity;

use App\Repository\MarketRepository;
use Doctrine\Common\Collections\ArrayCollection;
use Doctrine\Common\Collections\Collection;
use Doctrine\DBAL\Types\Types;
use Doctrine\ORM\Mapping as ORM;

#[ORM\Entity(repositoryClass: MarketRepository::class)]
class Market
{
    #[ORM\Id]
    #[ORM\GeneratedValue]
    #[ORM\Column]
    private ?int $id = null;

    #[ORM\Column(length: 50)]
    private ?string $name = null;

    #[ORM\OneToOne(cascade: ['persist', 'remove'])]
    #[ORM\JoinColumn(nullable: false)]
    private ?Address $location = null;

    /**
     * @var Collection<int, Shop>
     */
    #[ORM\OneToMany(targetEntity: Shop::class, mappedBy: 'location')]
    private Collection $shops;

    #[ORM\Column(length: 255, nullable: true)]
    private ?string $image = null;

    #[ORM\Column(type: Types::TEXT, nullable: true)]
    private ?string $description = null;

    /**
     * @var Collection<int, MarketSlot>
     */
    #[ORM\OneToMany(targetEntity: MarketSlot::class, mappedBy: 'market')]
    private Collection $marketSlots;

    public function __construct()
    {
        $this->shops = new ArrayCollection();
        $this->marketSlots = new ArrayCollection();
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

    public function getLocation(): ?Address
    {
        return $this->location;
    }

    public function setLocation(Address $location): static
    {
        $this->location = $location;

        return $this;
    }

    /**
     * @return Collection<int, Shop>
     */
    public function getShops(): Collection
    {
        return $this->shops;
    }

    public function addShop(Shop $shop): static
    {
        if (!$this->shops->contains($shop)) {
            $this->shops->add($shop);
            $shop->setLocation($this);
        }

        return $this;
    }

    public function removeShop(Shop $shop): static
    {
        if ($this->shops->removeElement($shop)) {
            // set the owning side to null (unless already changed)
            if ($shop->getLocation() === $this) {
                $shop->setLocation(null);
            }
        }

        return $this;
    }

    public function getImage(): ?string
    {
        return $this->image;
    }

    public function setImage(?string $image): static
    {
        $this->image = $image;

        return $this;
    }

    public function getDescription(): ?string
    {
        return $this->description;
    }

    public function setDescription(?string $description): static
    {
        $this->description = $description;

        return $this;
    }

    /**
     * @return Collection<int, MarketSlot>
     */
    public function getMarketSlots(): Collection
    {
        return $this->marketSlots;
    }

    public function addMarketSlot(MarketSlot $marketSlot): static
    {
        if (!$this->marketSlots->contains($marketSlot)) {
            $this->marketSlots->add($marketSlot);
            $marketSlot->setMarket($this);
        }

        return $this;
    }

    public function removeMarketSlot(MarketSlot $marketSlot): static
    {
        if ($this->marketSlots->removeElement($marketSlot)) {
            // set the owning side to null (unless already changed)
            if ($marketSlot->getMarket() === $this) {
                $marketSlot->setMarket(null);
            }
        }

        return $this;
    }
}
```

## Ce que l'on ne test pas

- getters simples
- setters simples sans logique
- stockage de données pur
- Doctrine gère la persistance (mais pas la logique métier ni la cohérence des relations en mémoire)
- retour d'erreur (à faire dans les tests fonctionnels)

Les getters et setters simples ne sont pas testés car ils ne contiennent aucune logique métier : ils se contentent de stocker et retourner une valeur.

Il ne sert donc à rien de tester `setName()`, `setImage()` ni `setDescription()` (ni les getters associés) qui n'ont aucun comportement particulier en dehors de stocker et lire.

L’objectif d’un test unitaire est de vérifier du comportement, pas du simple stockage de données.

## Ce que l'on doit tester

Un test unitaire vérifie le comportement métier d’une classe.

- Relations entre entités (addShop, removeShop)
- Cohérence bidirectionnelle
- Logique métier dans les méthodes
- Effets de bord (modification de plusieurs objets)

Donc ici on va tester

- `addShop()` / `removeShop()`
- `addMarketSlot()` / `removeMarketSlot()`

### Typologie des tests

| Type de test    | Exemple      | Importance  |
| --------------- | ------------ | ----------- |
| Getter / Setter | setName      | inutile     |
| Logique métier  | addImage     | très élevée |
| Effet de bord   | setImageFile | élevée      |
| Cas limite      | doublon      | élevée      |

## Création d'un fichier de test

Pour plus de praticité, on s'inspire de l'arborescence de fichier du projet, ici par exemple, pour faire un test unitaire sur `src/Entity/Market.php` on va faire `tests/Unit/MarketTest.php`.

```bash
mkdir -p tests/Unit/
touch tests/Unit/MarketTest.php
```

## Namespace et TestCase

On pense à mettre namespace `namespace App\Tests\Unit;` et à mettre l'héritage de la classe `TestCase`.

```php
namespace App\Tests\Unit;
use PHPUnit\Framework\TestCase;
```

La classe **TestCase** fournit :

- les méthodes d’assertion (`assertTrue`, `assertSame`, etc.)
- le cycle de vie des tests (initialisation, nettoyage)
- les outils pour structurer les tests

### Méthodes d'assertions de TestCase

Quelques assertions importantes :

```php
self::assertTrue($condition);
self::assertFalse($condition);
self::assertSame($expected, $actual);
self::assertNull($value);
self::assertCount(1, $collection);
```

## Structure d’un test (AAA)

Un test suit toujours 3 étapes :

1. Arrange
2. Act
3. Assert

### 1. Arrange (préparation)

En gros on instancie les entités.

```php
$market = new Market();
$shop = new Shop();
```

### 2. Act (action)

On utilise les méthodes d'entité.

```php
$market->addShop($shop);
```

### 3. Assert (vérification)

Et on vérifie le résultat de la méthode.

```php
self::assertCount(1, $market->getShops());
```

### Exemple pédagogique

Voici un petit exemple pour une classe `MarketTest`, ici c'est sur un getter/setter, c'est purement à titre pédagogique, comme expliqué ça ne sert à rien de tester des getters/setters simples.

```php
<?php

namespace App\Tests\Unit;

use App\Entity\Market;
use PHPUnit\Framework\TestCase;

final class MarketTest extends TestCase
{
  public function testNameSetterGetter(): void
  {
    $market = new Market();

    $market->setName('Central Market');

    self::assertSame('Central Market', $market->getName());
  }
}
```

#### Analyse test simple

- test trivial
- peu de logique
- utile pour apprentissage

## Test métier (important)

Voici le test unitaire pour `src/Entity/Market.php`

```php
<?php

namespace App\Tests\Unit;

use App\Entity\Market;
use App\Entity\MarketSlot;
use App\Entity\Shop;
use PHPUnit\Framework\TestCase;

final class MarketTest extends TestCase
{
  public function testAddShop(): void
  {
    $market = new Market();
    $shop = new Shop();

    $market->addShop($shop);

    self::assertCount(1, $market->getShops());
    self::assertSame($market, $shop->getLocation());
  }

  public function testRemoveShop(): void
  {
    $market = new Market();
    $shop = new Shop();

    $market->addShop($shop);
    $market->removeShop($shop);

    self::assertCount(0, $market->getShops());
    self::assertNull($shop->getLocation());
  }

  public function testAddMarketSlot(): void
  {
    $market = new Market();
    $slot = new MarketSlot();

    $market->addMarketSlot($slot);

    self::assertCount(1, $market->getMarketSlots());
    self::assertSame($market, $slot->getMarket());
  }

  public function testRemoveMarketSlot(): void
  {
    $market = new Market();
    $slot = new MarketSlot();

    $market->addMarketSlot($slot);
    $market->removeMarketSlot($slot);

    self::assertCount(0, $market->getMarketSlots());
    self::assertNull($slot->getMarket());
  }
}
```

### Analyse

Ce test vérifie :

- ajout dans la collection `self::assertCount(1, $market->getShops());`
- cohérence de la relation et effet de bord `self::assertSame($market, $shop->getLocation());`

### Conclusion

Les tests unitaires permettent de :

- garantir la fiabilité du code
- détecter les régressions
- documenter le comportement

Dans une application Symfony :

- les tests de logique métier sont prioritaires
- les tests de getters/setters sont secondaires
- les relations Doctrine doivent être testées

## Executer le test

On lance les test avec

```bash
php bin/phpunit --testdox
```

`--testdox` est utilise pour avoir un beau rendu de test.

On pourrait aussi préciser quel fichier on veut tester

```bash
php bin/phpunit tests/Unit/MarketTest.php --testdox
```

ou par classe

```bash
php bin/phpunit --filter MarketTest --testdox
```

ou par méthode

```bash
php bin/phpunit --filter testAddShop --testdox
```

## Exercices

### Exercice 1 — Getter / Setter

Écrire un test pour :

```php
$produit->setName('Test');
```

### Exercice 2 — Booléen

Tester :

```php
$produit->setIsActive(false);
```

---

### Exercice 3 — Valeur nullable

Tester :

```php
$produit->setDescription(null);
```

### Exercice 4 — Entité Image

Tester :

```php
$image->setImageName('photo.jpg');
```

### Exercice 5 — Relation simple

Tester :

```php
$image->setProduit($produit);
```

### Exercice 6 — Effet de bord

Tester :

```php
$image->setImageFile($file);
```
