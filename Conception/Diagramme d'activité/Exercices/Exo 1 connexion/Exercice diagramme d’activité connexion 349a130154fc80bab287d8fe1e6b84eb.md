# Exercice diagramme d’activité connexion

# Connexion (diagramme d’activité)

Décrire la connexion d'un client à un serveur telnet.

On considère trois protagonistes: le client, le démon telnet (i.e. le serveur logiciel) et la machine serveur.

Une fois la connexion établie entre le client et le serveur, le démon demande un mot de passe au client, ce dernier dispose de trois tentatives avant que la connexion ne soit rompue.

Les tentatives infructueuses sont enregistrées dans un fichier sur le serveur. Une fois l'identification faite, un terminal est ouvert et l'utilisateur peut alors saisir des  commandes qui sont interprétées par le démon et exécutées sur le serveur. Lacommande exit déconnecte le client du serveur.

Travail à Faire :
● Etablir le diagramme d’activités