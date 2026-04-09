# TP_Contact_Symfony

# TP Symfony — Entity `Contact`

---

## Contexte

Dans ce TP, vous allez concevoir une fonctionnalité complète autour d’une entité `Contact` dans une application Symfony.

---

## 🧾 Énoncé

Créer une entité `Contact` avec les propriétés suivantes :

- `nom`
- `prenom`
- `email` (**ne peut pas être vide**)
- `commentaire`

Ensuite :

1. générer l’entité `Contact`
2. générer la migration et mettre à jour la base de données
3. générer le Controller avec 
    1. l’affichage des messages de contact (R)
    2. et la création (C)
4. ajouter la validation nécessaire sur `email`
5. générer les tests :
    - unitaires
    - d’intégration
    - fonctionnels

---

# Création de l’entité

## Travail demandé

Créer une entité `Contact` contenant :

- un identifiant `id`
- `nom` de type string
- `prenom` de type string
- `email` de type string
- `commentaire` de type text

## Contraintes attendues

Le champ `email` ne doit pas être vide.

## Commandes possibles

```bash
php bin/console make:entity Contact
```

Puis créer les propriétés demandées.

---

# Partie 2 — Validation

## Objectif

Ajouter une contrainte de validation sur la propriété `email`.

## Attendu

Utiliser le composant Validator de Symfony pour que :

- `email` soit obligatoire
- idéalement, `email` soit aussi une adresse valide

## Exemple attendu

```php
use Symfony\Component\Validator\Constraints as Assert;

#[Assert\NotBlank]
#[Assert\Email]
private ?string $email = null;
```

---

# Partie 3 — Migration

Une fois l’entité créée :

1. générer la migration
2. exécuter la migration

## Commandes

```bash
php bin/console make:migration
php bin/console doctrine:migrations:migrate
```

---

# Partie 4 — Génération le Controller

Générer le Controller  pour l’entité `Contact`.

## Commande

```bash
php bin/console make:crud Contact
```

## Attendu

Le Controller doit permettre :

- d’afficher la liste des contacts
- de créer un contact

---

# Partie 5 — Tests unitaires

## Objectif

Tester la logique simple de l’entité `Contact`.

## Travail demandé

Créer un fichier :

```
tests/Unit/ContactTest.php
```

## Tests minimum attendus

### Test 1 — Getter / Setter de `nom`

Vérifier que :

- `setNom()` enregistre correctement la valeur
- `getNom()` retourne la bonne valeur

### Test 2 — Getter / Setter de `prenom`

Vérifier que :

- `setPrenom()` fonctionne correctement

### Test 3 — Getter / Setter de `email`

Vérifier que :

- `setEmail()` fonctionne correctement

### Test 4 — Getter / Setter de `commentaire`

Vérifier que :

- `setCommentaire()` fonctionne correctement

## Exemple de structure

```php
public function testNomGetterSetter(): void
{
   // code
}
```

---

# 🧪 Partie 6 — Tests d’intégration Doctrine

## Objectif

Vérifier que l’entité `Contact` est correctement persistée en base de données.

## Travail demandé

Créer un fichier :

```
tests/Integration/ContactDoctrineTest.php
```

## Classe de base attendue

Utiliser :

```php
KernelTestCase
```

## Tests minimum attendus

### Test 1 — Persistance d’un contact

Créer un contact, le persister, faire un `flush()`, puis vérifier que son `id` n’est pas nul.

### Test 2 — Récupération par identifiant

Créer un contact, le persister, vider l’EntityManager avec `clear()`, puis le rechercher avec le repository.

Vérifier que les données récupérées sont correctes.

## Exemple de points à vérifier

- `id` généré
- `nom` correct
- `prenom` correct
- `email` correct

---

# 🧪 Partie 7 — Tests fonctionnels

## Objectif

Tester le comportement du Controller du point de vue utilisateur.

## Travail demandé

Créer un fichier :

```
tests/Functional/ContactControllerTest.php
```

## Classe de base attendue

Utiliser :

```php
WebTestCase
```

## Tests minimum attendus

### Test 1 — La page liste des contacts est accessible

Faire une requête GET sur la page d’index du Controller et vérifier que la réponse est correcte.

### Test 2 — La page de création est accessible

Faire une requête GET sur la page de création et vérifier que la page s’affiche.

### Test 3 — Création d’un contact via formulaire

Simuler la soumission du formulaire avec les valeurs :

- nom
- prenom
- email
- commentaire

Puis vérifier :

- qu’il y a une redirection
- que le contact est bien enregistré en base

### Test 4 — Formulaire invalide si email vide

Soumettre le formulaire avec un email vide.

Puis vérifier :

- que le formulaire n’est pas validé
- qu’il n’y a pas de redirection
- que le contact n’est pas enregistré

---

# 🧠 Partie 8 — Organisation attendue

Arborescence conseillée :

```
src/
├── Entity/
│   └── Contact.php
├── Controller/
├── Form/
└── Repository/

tests/
├── Unit/
│   └── ContactTest.php
├── Integration/
│   └── ContactDoctrineTest.php
└── Functional/
    └── ContactControllerTest.php
```

---