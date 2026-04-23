# TP DIAGRAMME DE CLASS : Welcome to the hotel california !!

Un hôtel est composé d'au moins deux chambres

Chaque chambre dispose d'une salle d'eau : douche ou bien baignoire

Un hôtel héberge des personnes.

Il peut employer du personnel et il est impérativement dirigé par un directeur.

On ne connaît que le nom et le prénom des employés, des directeurs et des occupants

Certaines personnes sont des enfants et d'autres des adultes (faire travailler des enfants est interdit).

Un hôtel a les caractéristiques suivantes :

● une adresse,
● un nombre de pièces et une catégorie.

Une chambre est caractérisée par

● le nombre et de lits qu'elle contient,
● son prix
● son numéro.

On veut savoir qui occupe quelle chambre à quelle date.

Pour chaque jour de l'année

on veut pouvoir calculer le loyer de chaque chambre en fonction de son prix et de son occupation (le loyer est nul si la chambre est inoccupée).

La somme de ces loyers permet de calculer le chiffre d'affaires de l'hôtel entre deux dates.

**Question : Donnez une diagramme de classes pour modéliser le problème de l'hôtel.**

```puml
@startuml hotel
title Hotel Deluxe

class Hotel {
    - name : string
    - address : string
    + getNbRooms(): int
    + getTotalRentBetween(start: Date, end: Date): double

}

class Room {
    - bed : int
    - price : float
    - number : int
    + getRent(day: Date): double
}

class Bathroom {
    - type : Bathtype
}

enum Bathtype {
    shower
    bathtub
}

enum Role {
    director
    hotel_worker
}

abstract class Human {
    # firstname : string
    # lastname : string
    # adult : boolean
}

class Employee extends Human {
    - role : Role
    + invoice()
}

class Customer extends Human {
    - id : int
}

class Bill {
    - customer_id : int
    - occupant : int
    - total : float
}

class Occupy {
    - startDate: date
    - endDate: date
}

Bathroom --> Bathtype
Employee --> Role
Room "1" *--> "1" Bathroom : content

Hotel "1" *--> "2..*" Room : content
Hotel "1" o--> "2..*" Employee : employ
Employee "1" --> "1..*" Employee : manages
Employee "1" --> "0..*" Bill : generates
Bill "0..*" --> "1" Customer : is issued to
(Room, Customer) <.. Occupy


@enduml
```
