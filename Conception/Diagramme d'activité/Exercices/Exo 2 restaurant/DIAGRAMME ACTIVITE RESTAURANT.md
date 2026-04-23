# DIAGRAMME ACTIVITE RESTAURANT

## Le diagramme infernal du restaurant

Réalisez le diagramme d'activité d'un restaurant.
Nous partons du principe que le serveur a encore de la place dans son rang.
Lorsque le client arrive, il est accueilli par un serveur qui l'installe à une de ses
tables. Il lui apporte la carte.
Il repasse alors un peu plus tard pour prendre la commande.
Si le client n'a pas choisi il repasse alors plus tard.
Une fois la commande prise, il la transmet à la cuisine qui va la préparer.
Il apporte pendant ce temps les boissons s'il y a lieu ainsi que le pain et les
couverts.

Lorsque la cuisine a fini de préparer le repas, il l'apporte à table.
Si le client refuse le plat, il l'apporte à nouveau en cuisine pour une nouvelle
cuisson.
Une fois que le client a terminé de manger, il apporte l'addition et encaisse à
table.
Une fois le client parti il la débarrasse.

Réalisez le diagramme d’activité .

Etapes

1. Identifiez tous les acteurs : vous devrez en trouver 3
2. Déterminez quelles sont les différentes actions réalisées par chaque acteur
3. Identifiez les embranchements (mot clef 'if', 'elseif' et 'else', voir doc)
4. Prêtez attention aux étapes qui impliquent de revenir en arrière. Sur
   plantuml, le mot clef 'repeat' vous sera utile (cf doc)
5. Vous autre besoin du mot clef 'fork' au moins une fois, pour définir des
   actions simultanées
6. Saisissez dans l'ordre les étapes de l'action Indices Il s'agit du point de vue
   du serveur, donc c'est lui qui contiendra le plus d'actions,
