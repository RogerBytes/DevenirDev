# Exo SQL avec les dep

> [!WARNING]
> Je dois refaire cette doc, c'est un repo ayant vertu à devenir ma source pour mes docs

## Import du script sql

```bash
mariadb -u harry -p < dep_ville.sql
```

et je me connecte à mariadb

```bash
mariadb -u harry -p
```

Et je cherche dans mes BDD

```mariadb
SHOW DATABASES;
```

Et je choisis la bonne

```mariadb
USE dep_ville
```

## Obtenir la liste des 10 villes les plus peuplées en 2012

On commance par chercher les tables présentes

```mariadb
USE dep_ville
```

## Obtenir la liste des 50 villes ayant la plus faible superficie

## Obtenir la liste des départements d’outres-mer, c’est-à-dire ceux dont le numéro de département commencent par “97”

## Obtenir le nom des 10 villes les plus peuplées en 2012, ainsi que le nom du département associé

## Obtenir la liste du nom de chaque département, associé à son code et du nombre de commune au sein de ces département, en triant afin d’obtenir en

## priorité les départements qui possèdent le plus de communes

## Obtenir la liste des 10 plus grands départements, en terme de superficie

## Compter le nombre de villes dont le nom commence par “Saint”

## Obtenir la liste des villes qui ont un nom existants plusieurs fois, et trier afin d’obtenir en premier celles dont le nom est le plus souvent utilisé par plusieurs communes

## Obtenir en une seule requête SQL la liste des villes dont la superficie est supérieur à la superficie moyenne
Premier commit effectué
