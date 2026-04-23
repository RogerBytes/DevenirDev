# 04 Les entités

Nous nous basons sur [la doc de conf des bdd](https://symfony.com/doc/current/doctrine.html#configuring-the-database).

Nous allons créer notre première entité. Pour information lors de notre installation de projet avec l'option `--webapp`, doctrine a été installé.
Doctrine est un ORM (Object Relationnel Mapping) pour php, il va nous servir de mapping. C’est grâce
à doctrine que l’on interagit avec la bdd, il mappe les entités php vers la bdd.

## Configuration

Pour des raisons de sécurité nous utilisons le `.env.dev.local` (voir la première partie sur PostgreSQL).

```bash
symfony console doctrine:database:create
```

Symfony gère bien les abbreviations de commandes (si ambiguïté, il propose les commandes possibles), l'on peut utiliser

```bash
symfony console do:da:cr
```

Dans DBeaver, faire une nouvelle connexion, dans le champ `Database` il faut donc mettre `marmiton` et renseigner également le mdp.

Nous allons maintenant créer une entité `ingrédient` qui contient les attributs :

- un nom `name`
- un prix au kilo `price`
- date de création `createdAt`

```bash
symfony console make:entity
```

ou

```bash
symfony console ma:en
```

On peut directement donner le nom de l'entité

```bash
symfony console ma:en ingredient
```

Et l'on créé nos attributs (properties dans la CLI) `name` (type `string` taille 50), `price` (type `float`) et `createdAt` (type `datetime_immutable`).

Vu que nous avons interagit avec les entité, il faut faire la migration :

```bash
symfony console make:migration
```

ou

```bash
symfony console ma:mi
```

Cela créé un fichier `Version20260304123943.php` dans le repertoire `migrations`.

Ce script php stocke les requêtes postgres (ou sql ou mariadb).

Maintenant nous allons executer ces script de migrations pour ajouter les entité à la bdd.

```bash
symfony console doctrine:migration:migrate
```

ou

```bash
symfony console do:mi:mi
```

La migration est terminée :

```output
 [OK] Successfully migrated to version:
      DoctrineMigrations\Version20260304123943
```

Dans DBeaver, on peut voir la table `ingredient` que l'on vient de créer (ainsi que `doctrine_migration_versions` et `messenger_messages` générés automatiquement par Symfony).

Nous avons fini de créer nos entités.
