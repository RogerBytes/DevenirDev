# Sans titre

Votre objectif est de créer un composant qui va dynamiquement afficher l’heure actuelle dans différentes villes (Paris, New York, Amsterdam etc.).

Vous devez avoir un composant enfant, et un composant parent.

Vous ne mettrez AUCUNE logique dans le composant enfant.

L’heure doit se mettre à jour toutes les secondes

Vous ferez en sorte de découper votre application comme suit :

- Le composant parent sera en charge d’appeler le composant enfant autant de fois que nécessaire.
- Il aura :
    - Une liste de timezone, qui comprendra au moins 3 timzeones différentes
    - Une méthode pour définir l’heure en fonction de la timezone
- Le composant enfant ne sera chargé QUE d’afficher l’heure