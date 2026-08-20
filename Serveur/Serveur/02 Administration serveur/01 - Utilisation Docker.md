# 01 - Utilisation Docker

Ici je vais mettre les commandes annexes que j'utilise pour gérer mes conteneurs.

## Voir les logs en direct

Dans le répertoire de données du conteneur, faire

```bash
sudo docker compose logs -f
```

## Redémarrer un service

Dans le répertoire de données du conteneur, faire

```bash
sudo docker compose restart
```

## Détruire un conteneur et supprimer son repertoire de données

### Détruire le conteneur

On se place dans le dossier (ici `cloclo` en guise d'exemple)

```bash
cd /opt/docker/cloclo
sudo docker compose down
```

L'argument `-v` supprime les volumes associés, par exemple

```bash
cd /opt/docker/cloclo
sudo docker compose down -v
```

>[!CAUTION] Supprimer les volumes implique de perdre toutes les données etc, par exemple ça supprime toute BDD.

### Supprimer le répertoire de données

A utiliser si on veut repartir de zéro.

```bash
cd /opt/docker
sudo rm -rf cloclo
```
