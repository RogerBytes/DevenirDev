# Cours : Tests d’intégration avec Doctrine (Symfony)

---

## 🧠 1. Définition

Un **test d’intégration** vérifie que plusieurs composants fonctionnent ensemble.

👉 Dans Symfony avec Doctrine, cela signifie :

- démarrer le kernel Symfony
- utiliser l’EntityManager
- interagir avec une base de données réelle (souvent une base de test)

---

## ⚖️ 2. Différence avec les tests unitaires

| Tests unitaires           | Tests d’intégration       |
| ------------------------- | ------------------------- |
| pas de base de données    | utilisent la base         |
| rapides                   | plus lents                |
| testent une classe isolée | testent plusieurs couches |
| pas de container Symfony  | utilisent le container    |

## Contexte

Dans ce tutoriel on utilise `src/Entity/Market.php` comme base conceptuelle (pour simplifier)

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

## Création d'un fichier de test

Pour plus de praticité, on s'inspire de l'arborescence de fichier du projet, ici par exemple, pour faire un test unitaire sur `src/Integration/Market.php` on va faire `tests/Integration/MarketTest.php`.

```bash
mkdir -p tests/Integration/
touch tests/Integration/MarketTest.php
```

## Réglage du env

Il faut faire une copie de `.env.dev.local` utilisé

```bash
cp .env.dev.local .env.test.local
```

## Commandes pour setup les tests fonctionnels

### Création de la BDD de test

En une fois, détail après

```bash
cp .env.dev.local .env.test.local
symfony console do:da:dr --force --if-exists --env=test
symfony console do:da:cr --env=test
symfony console do:mi:mi -n --env=test
symfony console do:fi:lo -n --env=test
```

Supprime la BDD si elle existe

```bash
symfony console do:da:dr --force --if-exists --env=test
```

On créé la bdd

```bash
symfony console do:da:cr --env=test
```

Créer les migrations

```bash
symfony console do:mi:mi -n --env=test
```

Créer les fixtures

```bash
symfony console do:fi:lo -n --env=test
```

Execute les test unitaire

```bash
php bin/phpunit --testdox tests/Unit/
```

Execute les test d'integration

```bash
php bin/phpunit --testdox tests/Integration/
```

## Namespace et TestCase

On pense à mettre namespace `namespace App\Tests\Functional;` et à mettre l'héritage de la classe `KernelTestCase`.

```php
namespace App\Tests\Functional;
use Symfony\Bundle\FrameworkBundle\Test\KernelTestCase;
```

Exemple :

```php
final class ProduitIntegrationTest extends KernelTestCase
{
    public function testKernelBoot(): void
    {
        self::bootKernel();
        self::assertTrue(true);
    }
}
```

👉 `bootKernel()` démarre l’application Symfony.

---

## ⚙️ 4. Accès à Doctrine

```php
$entityManager = static::getContainer()
    ->get('doctrine')
    ->getManager();
```

👉 Permet de :

- persister des entités
- exécuter des requêtes
- tester la base de données

---

## 🧪 5. Exemple : persistance d’un Produit

```php
public function testPersistProduit(): void
{
    self::bootKernel();

    $em = static::getContainer()->get('doctrine')->getManager();

    $produit = new Produit();
    $produit->setName('Produit Test');

    $em->persist($produit);
    $em->flush();

    self::assertNotNull($produit->getId());
}
```

👉 Vérifie que Doctrine enregistre correctement l’entité.

---

## 🧪 6. Exemple : relation Produit / Image

```php
public function testPersistProduitWithImage(): void
{
    self::bootKernel();

    $em = static::getContainer()->get('doctrine')->getManager();

    $produit = new Produit();
    $produit->setName('Produit');

    $image = new Image();
    $image->setImageName('test.jpg');

    $produit->addImage($image);

    $em->persist($produit);
    $em->flush();

    self::assertNotNull($produit->getId());
    self::assertNotNull($image->getId());
}
```

👉 Vérifie :

- la persistance du produit
- la persistance de l’image
- le fonctionnement du `cascade persist`

---

## 🧪 7. Exemple : récupération via Repository

```php
public function testFindProduit(): void
{
    self::bootKernel();

    $em = static::getContainer()->get('doctrine')->getManager();

    $produit = new Produit();
    $produit->setName('Produit A');

    $em->persist($produit);
    $em->flush();

    $repo = $em->getRepository(Produit::class);
    $found = $repo->find($produit->getId());

    self::assertSame('Produit A', $found->getName());
}
```

---

## 🧼 8. Gestion de la base de test

Bonnes pratiques :

- utiliser une base de données dédiée (env `test`)
- éviter les données persistantes entre tests
- réinitialiser la base si nécessaire

---

## 🧠 9. Bonnes pratiques

- tester uniquement les interactions importantes avec Doctrine
- garder les tests lisibles
- ne pas surcharger un test avec trop de logique
- isoler les données de test

---

## 🧠 Conclusion

Les tests d’intégration permettent de :

- valider le fonctionnement réel de Doctrine
- tester les relations entre entités
- sécuriser la persistance en base

👉 Ils sont complémentaires des tests unitaires.

## 📝 Exercices

---

### 🟢 Exercice 1

Créer un test qui persiste un `Produit` et vérifie son `id`.

---

### 🟡 Exercice 2

Créer un test qui persiste un `Produit` avec une `Image`.

---

### 🔵 Exercice 3

Créer un test qui récupère un produit depuis la base.
