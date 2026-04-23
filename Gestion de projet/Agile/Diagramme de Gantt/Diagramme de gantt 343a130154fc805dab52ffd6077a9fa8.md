# Diagramme de gantt

## 1. Définition et Origine

Le **diagramme de Gantt** est l'outil de gestion de projet le plus utilisé pour visualiser l'ordonnancement des tâches. Inventé par Henry Gantt vers 1910, il permet de représenter graphiquement l'évolution d'un projet dans le temps.

C'est un graphique à deux axes :

- **Axe horizontal (X) :** L'échelle de temps (jours, semaines, mois).
- **Axe vertical (Y) :** La liste des tâches à accomplir.

![image.png](/assets/img/image.png)

project management concept

## 2. Les Composants Clés du Diagramme

- **Les Barres :** Chaque barre horizontale représente une tâche. Sa longueur indique sa **durée**.
- **Les Dépendances (Liens) :** Des flèches relient les tâches entre elles. Elles indiquent que certaines tâches ne peuvent commencer que si la précédente est terminée (Lien Fin-à-Début).
- **Les Jalons (Milestones) :** Représentés souvent par des losanges, ce sont des événements clés ou des dates butoirs (ex: "Validation client", "Fin de phase"). Ils ont une durée de zéro.
- **Les Ressources :** Les noms des personnes ou services assignés à chaque tâche sont souvent inscrits à côté des barres.
- **Le Chemin Critique :** C'est la suite de tâches qui n'ont aucune marge de manœuvre. Si une seule de ces tâches prend du retard, tout le projet est retardé.

## 3. Pourquoi utiliser un Gantt ?

Le diagramme de Gantt répond à trois questions fondamentales :

- **Quoi ?** Quelles sont les tâches à réaliser ?
- **Quand ?** Quand commence et finit chaque étape ?
- **Qui ?** Qui travaille sur quoi et à quel moment ?

| **Avantages** | **Inconvénients** |
| --- | --- |
| Vision globale et claire du planning. | Peut devenir illisible sur des projets trop complexes. |
| Identification des chevauchements de tâches. | Demande une mise à jour constante pour rester utile. |
| Facilite la communication avec les parties prenantes. | Ne montre pas directement la charge de travail réelle (effort). |

## 4. Méthodologie de Création (Pas à pas)

Pour réussir votre planification, suivez ces étapes :

### Étape 1 : Lister les tâches (WBS)

Avant de dessiner, listez tout ce qui doit être fait. Regroupez les petites tâches en "phases".

### Étape 2 : Estimer les durées

Déterminez le temps nécessaire pour chaque tâche (ex: 3 jours, 2 semaines).

### Étape 3 : Établir les dépendances

Définissez l'ordre logique. *Exemple : On ne peut pas peindre le mur (Tâche B) avant d'avoir construit le mur (Tâche A).*

### Étape 4 : Assigner les ressources

Identifiez qui est responsable de chaque barre.

### Étape 5 : Tracer et ajuster

Utilisez un logiciel (Microsoft Project, GanttProject, Excel ou Monday) pour générer le visuel et vérifiez la cohérence des dates.

## 5. Gantt et Méthodes Agiles ?

**Note importante :** Le diagramme de Gantt est l'outil roi des méthodes **Waterfall** (en cascade). En **Agile**, on lui préfère souvent le **Kanban** ou le **Burndown Chart**. Cependant, de nombreuses entreprises utilisent une approche "Hybride" : un Gantt pour la vision macro (long terme) et du Kanban pour la gestion micro (quotidienne).