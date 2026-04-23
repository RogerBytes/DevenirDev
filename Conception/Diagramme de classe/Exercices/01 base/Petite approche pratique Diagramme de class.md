# Petite approche pratique Diagramme de class

### Exercice 1 : Le "Hello World" des classes (La Bibliothèque)

**L'objectif :** Créer deux classes simples et une relation d'association.

**Énoncé :**

- Crée une classe `Livre` avec les attributs : `titre` (String) et `auteur` (String).
- Crée une classe `Bibliotheque` avec un attribut : `nom` (String).
- Établis un lien : Une bibliothèque **contient** des livres.

**Indice syntaxique :**

Extrait de code

`@startuml
ClasseA -- ClasseB : relation
@enduml`

## CORRECTION

Ici, on se contente de relier les deux entités. Le texte sur le trait permet de clarifier le rôle de la relation.

Extrait de code

`@startuml
class Livre {
  titre : String
  auteur : String
}

class Bibliotheque {
  nom : String
}

Bibliotheque "1" -- "0..*" Livre : contient >
@enduml`