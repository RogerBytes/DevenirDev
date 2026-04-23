# USE CASE PAS A PAS

Considérons une station-service de distribution d'essence. Les clients se servent de l'essence et le
pompiste remplit les cuves.

**Question :**Le client se sert de l'essence de la façon suivante : il prend un pistolet accroché à une
pompe et appuie sur la gâchette pour prendre de l'essence. Qui est l'acteur du système ? Est-ce le client, le pistolet ou la gâchette ?

**C'est le client. Un acteur est toujours extérieur au système. Dénir les acteurs d'un système, c'est
aussi en dénir les bornes.**

**Question :** Jojo, dont le métier est pompiste, peut se servir de l'essence pour sa voiture. Pour
modéliser cette activité de Jojo, doit-on dénir un nouvel acteur ? Comment modélise-t-on ça ?

Jojo est ici considéré comme un client. Pour dénir les acteurs, il faut raisonner en termes de
rôles

**Question :** Lorsque Jojo vient avec son camion citerne pour remplir les réservoirs des pompes, est-il
considéré comme un nouvel acteur ? Comment modélise-t-on cela ?
Jojo est ici considéré comme pompiste

**Question :** Certains pompistes sont aussi qualifiés pour opérer des opérations de maintenance en plus des opérations habituelles des pompistes telles que le remplissage des réservoirs. Ils sont donc réparateurs en plus d'être pompistes. Comment modéliser cela ?

La seule relation possible entre deux acteurs est la généralisation. Elle permet de spécier des usages
particuliers.