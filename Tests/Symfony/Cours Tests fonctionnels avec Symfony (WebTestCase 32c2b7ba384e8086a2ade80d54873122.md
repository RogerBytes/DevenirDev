# Cours : Tests fonctionnels avec Symfony (WebTestCase)

---

## 🧠 1. Définition

Un **test fonctionnel** vérifie le comportement global d’une application du point de vue utilisateur.

👉 Contrairement :

- aux tests unitaires → logique interne
- aux tests d’intégration → interaction avec la base

👉 Ici on teste :

- routes
- contrôleurs
- formulaires
- réponses HTTP

---

## ⚖️ 2. Différence avec les autres tests

| Type | Ce qui est testé |
| --- | --- |
| Unitaire | une classe seule |
| Intégration | base de données |
| Fonctionnel | application complète |

---

## 🧱 3. Classe de base : WebTestCase

```php
use Symfony\Bundle\FrameworkBundle\Test\WebTestCase;
```

Exemple :

```php
final class ProduitControllerTest extends WebTestCase
{
    public function testPageIsSuccessful(): void
    {
        $client = static::createClient();
        $client->request('GET', '/produit');

        self::assertResponseIsSuccessful();
    }
}
```

---

## 🌐 4. Simuler une requête HTTP

```php
$client = static::createClient();

$client->request('GET', '/');
```

👉 Méthodes HTTP possibles :

- GET
- POST
- PUT
- DELETE

---

## 🧪 5. Vérifier la réponse

```php
self::assertResponseIsSuccessful();
self::assertResponseStatusCodeSame(200);
```

---

## 🧪 6. Tester le contenu HTML

```php
$client = static::createClient();
$crawler = $client->request('GET', '/produit');

self::assertSelectorTextContains('h1', 'Produit');
```

👉 Permet de vérifier le contenu rendu.

---

## 🧪 7. Tester un formulaire

```php
$client = static::createClient();
$crawler = $client->request('GET', '/produit/new');

$form = $crawler->selectButton('Submit')->form([
    'produit[name]' => 'Produit Test'
]);

$client->submit($form);

self::assertResponseRedirects();
```

👉 Simule un utilisateur qui remplit un formulaire.

---

## 🧪 8. Suivre une redirection

```php
$client->followRedirect();

self::assertResponseIsSuccessful();
```

---

## 🧪 9. Exemple complet (Produit)

```php
public function testCreateProduit(): void
{
    $client = static::createClient();
    $crawler = $client->request('GET', '/produit/new');

    $form = $crawler->selectButton('Submit')->form([
        'produit[name]' => 'Produit Test'
    ]);

    $client->submit($form);

    self::assertResponseRedirects();

    $client->followRedirect();

    self::assertResponseIsSuccessful();
}
```

---

## 🧼 10. Accès à la base de données

Tu peux combiner avec Doctrine :

```php
$em = static::getContainer()->get('doctrine')->getManager();
```

👉 Permet de vérifier que les données sont bien enregistrées.

---

## 🧠 11. Bonnes pratiques

- tester des scénarios utilisateur réels
- vérifier les statuts HTTP
- vérifier le contenu HTML
- garder les tests simples et lisibles

---

## 📝 Exercices

---

### 🟢 Exercice 1

Tester qu’une page `/produit` retourne un statut 200.

---

### 🟡 Exercice 2

Tester qu’un formulaire de création fonctionne.

---

### 🔵 Exercice 3

Tester qu’un produit est bien enregistré en base après soumission.

## 🧠 Conclusion

Les tests fonctionnels permettent de :

- tester l’application comme un utilisateur
- valider les routes et contrôleurs
- vérifier les formulaires

👉 Ils complètent les tests unitaires et d’intégration.

---