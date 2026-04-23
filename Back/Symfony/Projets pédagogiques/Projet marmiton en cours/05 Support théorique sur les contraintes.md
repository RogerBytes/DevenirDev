# 05 Support théorique sur les contraintes

Il existe des contraintes côté serveur (validation de la logique métier et contraintes de base de données ORM) et des contraintes côté client (validation HTML5 exécutée dans le navigateur).

Dans cette documentation se trouvent les grandes lignes du fonctionnement des contraintes.

## Rappel sur la logique métier

La logique métier regroupe l’ensemble des règles qui définissent le comportement et la cohérence d’une application (règles de gestion, transitions d’état, calculs et invariants de données).

Elle ne se limite pas à la validation des formulaires ou aux contraintes Symfony, et doit être portée principalement par le modèle de domaine (entités et services), afin de garantir une cohérence indépendante de l’interface utilisateur.

## Contraintes Client Vs contraintes côté serveur

### Côté client (navigateur)

- HTML5 (`required`, `maxlength`, etc.)
- s’exécute sur l’ordinateur de l’utilisateur
- sert à **bloquer ou signaler avant l’envoi**
- ❌ contournable facilement → rôle non sécurisé

### Côté serveur (Symfony + DB/ORM)

- Symfony Validator (`NotBlank`, règles métier)
- Doctrine / ORM + base de données (`nullable=false`, `unique`)
- s’exécute après réception de la requête
- ✔ **couche de validation et d’intégrité côté serveur**

### Résumé Client vs Serveur

- Client = confort + pré-filtre (optionnel)
- Serveur = règles + intégrité des données

Pour conclure, la contrainte côté client (via la validation HTML5) est **optionnelle** mais permet d'améliorer l'UX avant l'envoi de la requête. Tandis que les validations serveur sont le **noyau dur** de l'intégrité des données.

## Contraintes HTML5

Voici un exemple de contraintes HTML5.

```twig
<form method="post">

    <input
        type="email"
        name="email"
        required
        maxlength="180"
    >

    <input
        type="password"
        name="password"
        minlength="8"
        required
    >

    <button type="submit">Envoyer</button>

</form>
```

- `required` → empêche l’envoi si vide
- `type="email"` → vérifie format (ici `email`)
- `maxlength` / `minlength` → contraintes navigateur

Encore une fois, ce n'est pas une couche de sécurité suffisante dans un projet avec validation serveur.

## Contraintes de validation serveur

Il y a trois cas de figures (les Assert validator et les FormType constraints utilisent le Validator Symfony via une syntaxe différente)

- **Assert (Validator)** → `src/Entity/` → règles métier
- **FormType constraints (via Assert également)** → `src/Form/` → règles d’un formulaire
- **ORM** → `src/Entity/` → règles base de données

### Exemples de syntaxe

- Assert (Validator)

```php
#[Assert\NotBlank]
private string $email;
```

- FormType constraints

```php
'constraints' => [new Assert\NotBlank()]
```

- ORM

```php
#[ORM\Column(nullable: false)]
```

### Duplicité de contrainte ORM et Symfony validator

Ici dans `src/Entity/User.php`

```php
#[ORM\Column(nullable: false)]

#[Assert\NotBlank]
private string $email;
```

Il n’y a pas de problème à avoir une redondance de contraintes, car elles agissent à des niveaux différents : la validation Symfony sert de contrôle applicatif, tandis que les contraintes ORM/DB assurent l’intégrité finale des données.

Plus précisément, `Assert\NotBlank` rejette : `null`, `""`, `"   "` et permet ainsi de valider la donnée avant son enregistrement lorsque la validation est déclenchée par Symfony lors du traitement d’un Form avant l’enregistrement en base, avec des messages d’erreur propres côté application. La contrainte `nullable: false` est une garantie au niveau base de données lors de l’insertion.

Un des avantages de la validation Symfony est de pouvoir personnaliser proprement les messages d’erreur, ce qui est utile aussi bien pour une API que pour une application web.

En revanche, il ne faut pas dupliquer inutilement les mêmes contraintes Symfony Validator (`Assert`) entre l’entité et le FormType lorsqu’elles expriment exactement la même règle métier. Dans ce cas, la redondance est inutile car elles sont appliquées dans le même système de validation.

### Contraintes dans un formulaire

Le FormType ne doit pas être utilisé pour redéfinir la logique métier. Toute règle métier doit être portée par l’Entity. Les contraintes dans le FormType doivent rester exceptionnelles et liées au contexte de soumission utilisateur, sinon elles indiquent un problème de conception.

Pour rappel, **la logique métier doit s'effectuer dans l'entité, et non dans un formulaire**.

La possibilité d'en faire sur le FormType permet de combler une carence à la conception ou des modifications structurelles et/ou dette technique, mais ne représente absolument pas une méthodologie standard de logique métier. La logique métier est censée se trouver sur l'entité.

Par exemple, une case à cocher “acceptation des CGU” peut être obligatoire uniquement dans un formulaire d’inscription via une contrainte `IsTrue`, car elle conditionne l’envoi du formulaire sans être une donnée métier persistée.

```php
->add('accept_cgu', CheckboxType::class, [
    'constraints' => [
        new Assert\IsTrue(message: 'Vous devez accepter les CGU')
    ]
])
```

#### Cas exceptionnel de contrainte contextuelle

Lorsqu’une contrainte existe dans l’entité, il est généralement déconseillé de la redéfinir dans le FormType afin d’éviter les incohérences de validation.

Dans certains cas, le FormType peut appliquer des contraintes de validation sur les données saisies par l’utilisateur, en amont du traitement métier, sans modifier ni redéfinir les règles métier définies dans l’Entity. Il agit uniquement comme couche de validation avant transformation des données en modèle métier.

Cela ne modifie pas la règle métier, mais adapte uniquement la validation au contexte du formulaire.

Par exemple, une entité peut autoriser un mot de passe avec une longueur minimale de 8 caractères :

```php
#[Assert\Length(min: 8)]
private string $password;
```

Mais dans un formulaire d’inscription, on peut imposer une règle plus stricte :

```php
'constraints' => [
    new Assert\Length(min: 12)
]
```

Ici, la règle du FormType est plus restrictive que celle de l’entité, car le contexte (création de compte) exige un niveau de sécurité supérieur.

Et encore une fois, c'est un cas d'usage exceptionnel, la validation de logique métier doit quasiment toujours se faire uniquement sur l'entité. De plus ce genre de pratique peut générer une incohérence ou une surcharge du feedback utilisateur.

### Exemples pratiques de duplicité ORM et Symfony Validator

Le tableau ci-dessous synthétise les principales règles de validation et leur répartition entre base de données et Symfony Validator, afin d’illustrer des cas où une duplication est pertinente ou non.

| Règle        | DB | Symfony Assert   | Doubler ?        |
| ------------ | -- | ---------------- | ---------------- |
| unique       | ✔  | ✔ (UniqueEntity) | OUI (recommandé) |
| nullable     | ✔  | ❌               | NON              |
| not blank    | ✔  | ✔                | OUI              |
| length       | ✔  | ✔                | OUI              |
| email format | ❌ | ✔                | NON              |

- `unique` → ✔ DB + ✔ Symfony (UniqueEntity pour UX) → donc **OUI recommandé**
- `nullable` → ❌ côté Symfony (pas utile si déjà géré par type PHP + NotBlank)
- `not blank` → ✔ Symfony + ✔ DB (via `nullable=false`, uniquement pour null, par pour chaîne d'espace ou chaîne vide) → OUI (partiel côté DB)
- `length` → ✔ DB (limite physique des données) + ✔ Symfony (validation + UX) → **complémentaires et recommandés**
- `email format` → ✔ Symfony uniquement
