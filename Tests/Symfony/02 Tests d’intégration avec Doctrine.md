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

| Tests unitaires | Tests d’intégration |
| --- | --- |
| pas de base de données | utilisent la base |
| rapides | plus lents |
| testent une classe isolée | testent plusieurs couches |
| pas de container Symfony | utilisent le container |

### Création de la BDD de test

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
symfony console do:fi:lo -n --env=test
```

Execute les test fonctionnel

```bash
php bin/phpunit --testdox tests/Functional/
```



## 3. Classe de base : KernelTestCase

Pour les tests d’intégration Symfony, on utilise :

```php
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