# Cours_tests_unitaires

---

## 🧠 1. Définition

Un **test unitaire** est un programme qui vérifie automatiquement qu’une **unité de code** (souvent une classe ou une méthode) fonctionne comme prévu.

👉 Dans Symfony, on utilise généralement **PHPUnit** 

Les classes unitaires héritent de la classe :

```html
use PHPUnit\Framework\TestCase;

```

---

Exemple

```html
final class ProduitTest extends TestCase
{    
	public function testExample(): void    
	{        
		self::assertTrue(true);    
	}
}
```

### Rôle de TestCase

La classe **TestCase** fournit :

- les méthodes d’assertion (`assertTrue`, `assertSame`, etc.)
- le cycle de vie des tests (initialisation, nettoyage)
- les outils pour structurer les tests

### Méthodes principales héritées de TestCase

Quelques assertions importantes :

```html
self::assertTrue($condition);
self::assertFalse($condition);
self::assertSame($expected, $actual);
self::assertNull($value);
self::assertCount(1, $collection);
```

## 2. Structure d’un test (AAA)

Un test suit toujours 3 étapes :

### 1. Arrange (préparation)

```php
$produit = new Produit();
```

### 2. Act (action)

```php
$produit->setName('Produit A');
```

### 3. Assert (vérification)

```php
self::assertSame('Produit A', $produit->getName());
```

---

## 3. Exemple concret : entité `Produit`

### Méthode testée

```php
public function addImage(Image $image): static
{
    if (!$this->images->contains($image)) {
        $this->images->add($image);
        $image->setProduit($this);
    }

    return $this;
}
```

---

## 4. Test métier (important)

```php
public function testAddImageSetsBothSidesOfRelation(): void
{
    $produit = new Produit();
    $image = new Image();

    $produit->addImage($image);

    self::assertCount(1, $produit->getImages());
    self::assertSame($produit, $image->getProduit());
}
```

### Analyse :

Ce test vérifie :

- ajout dans la collection ✔️
- cohérence de la relation ✔️

C’est un **test métier critique**

---

## 5. Test simple (getter / setter)

```php
public function testNameGetterSetter(): void
{
    $produit = new Produit();

    $produit->setName('Produit A');

    self::assertSame('Produit A', $produit->getName());
}
```

### Analyse :

- test trivial
- peu de logique
- utile pour apprentissage

---

## 6. Typologie des tests

| Type de test | Exemple | Importance |
| --- | --- | --- |
| Getter / Setter | setName | faible |
| Logique métier | addImage | très élevée |
| Effet de bord | setImageFile | élevée |
| Cas limite | doublon | élevée |

---

## 7. Exemple complet issu du projet

```php
public function testRemoveImageUnsetsInverseRelation(): void
{
    $produit = new Produit();
    $image = new Image();

    $produit->addImage($image);
    $produit->removeImage($image);

    self::assertCount(0, $produit->getImages());
    self::assertNull($image->getProduit());
}
```

Vérifie la cohérence après suppression.

---

# Conclusion

Les tests unitaires permettent de :

- garantir la fiabilité du code
- détecter les régressions
- documenter le comportement

Dans une application Symfony :

- les tests de logique métier sont prioritaires
- les tests de getters/setters sont secondaires
- les relations Doctrine doivent être testées

# Exercices

---

## Exercice 1 — Getter / Setter

Écrire un test pour :

```php
$produit->setName('Test');
```

---

## Exercice 2 — Booléen

Tester :

```php
$produit->setIsActive(false);
```

---

## Exercice 3 — Valeur nullable

Tester :

```php
$produit->setDescription(null);
```

---

## Exercice 4 — Entité Image

Tester :

```php
$image->setImageName('photo.jpg');
```

---

## Exercice 5 — Relation simple

Tester :

```php
$image->setProduit($produit);
```

---

## Exercice 6 — Effet de bord

Tester :

```php
$image->setImageFile($file);
```

---

#