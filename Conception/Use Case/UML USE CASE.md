# UML USE CASE

UML DIAGRAMME DE CAS D’UTILISATION 

## UTILISATION

Les Use case représentent le comportement fonctionnel d’un système.
Ils sont très utiles pour être présentés aux profils non -techniques.
On y indique les objectifs de l’utilisateur.
On décrit l’ensemble des interactions possibles pour un /plusieurs acteurs précis
Dans la large majorité des cas, chaque personne aura sa propre interprétation des
diagrammes UML, voire sa propre notation.
On peut donc trouver en ligne des exemples très différentes les uns des autres.

## LEGENDE

Comme tous les langages, l’UML dispose de ses propres caractères et de sa propre syntaxe.
On y représente schématiquement les actions, acteurs, activités…
Chaque symbole, flèche, signe dispose de sa propre sémantique.

## LES ACTEURS

Le terme ‘Acteur’ peut désigner un rôle et non une personne.
• Un acteur peut représenter plusieurs personnes et inversement

## LES ACTIONS

Les actions possibles sont représentées de cette façon
Le terme ‘Action’ désigne les actions réalisables

## LES CONNECTEURS

Les connecteurs représentent une connexion directe
Ils sont souvent entre l’acteur et l’activité

## LES RELATIONS

Les connecteurs en ‘-- >’ peuvent être tag avec une appellation pour représenter un
prérequis :
• On parle de stéréotypes
On peut utiliser des termes comme :
• Include
• Require
• Extends…
Le connecteur pointe vers le prérequis concerné

## INCLUDE / REQUIRE

Par exemple l’action ‘Consulter ses comptes’ implique d’être authentifié
On retrouve aussi le terme ‘Require’ qui désigne la même chose

## EXTENDS

Il représente un lien fort entre deux actions
Ici, effectuer un virement déclenchera une vérification du solde
On peut toutefois vérifier son solde indépendamment de l’action ‘virement’

## GENERALISATION

Indique un cas particulier d’une action, qui n’implique pas forcément de changement de
comportement.
On peut consulter ses comptes sur un ATM, ou en ligne.
Consulter en ligne implique d’être authentifié, mais ne permet pas de retirer de l’argent

## L’HERITAGE

La flèche peut aussi être utilisée pour déterminer un héritage entre acteurs.
Ici, le directeur des ventes hérite des actions du préposé aux commandes en plus des actions
qui lui sont réservées.