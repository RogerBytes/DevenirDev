# 03 - CloudFlare

Cloudflare est un service de proxy sécurisé, les DNS vont rediriger le nom de domaine vers l'adresse ip de CloudFlare et non la vraie adresse ip de la machines.

## Les offres

- l'offre gratuite propose la protection DDoS ainsi que la dissimulation d'IP.
- l'offre payante protège aussi contre des requêtes malveillantes (en analysant justement les requêtes)

## Truc

On se connecte [au dashboard de Cloudflare](https://dash.cloudflare.com), puis l'on va sur `Domaines/Vue d'ensemble`.

On clique sur `Ajouter un domaine` et choisir `Connecter un domaine`, et

- Entrer son nom de domaine (il prendra les sous domaines également)
- on laisse l'option `Importer automatiquement les enregistrements DNS`
- pour les robots, si c'est un projet pro, on les autorise, si c'est un domaines avec service pro perso, on les bloque (pas besoin de visibilité)
- On laisse coché `Orienter le trafic des bots IA avec robots.txt`
- On clique sur `Continuer`
- On choisit son offre

On clique sur `Ajouter un domaine` et choisir `Connecter un domaine`, et

On va sur `Domaines/Vue d'ensemble` on clique sur le domaine en question, il faut vérifier que les entrées sont les mêmes que celle du fournisseur.

## Vérifier avec OVH

CORRIGER A A PARTIR D'ICI

- Se connecter [au compte OVH](https://www.ovh.com/auth/?onsuccess=https%3A//manager.eu.ovhcloud.com&ovhSubsidiary=FR)
et allez dans la partie `Web Cloud/Zone DNS` et cliquer sur le nom de domaine, ici `nimportequoiquoi.com`

S'il y a plus de deux entrées `MX` (c'est pout Mail Exchanger), supprimez les pour qu'il n'y en ait plus que deux.
S'il y a une entrée `SPF`, il faut la supprimer.
Ajouter les entrées dans le registrar en se basant sur les indications de mxroute.com

Sous domaine on met rien si c'est @ dans le NAME ! C'est une convention en informatique.

Il faut être patient pour les modifications de type MX et SPF, car elles sont gardées en cache, ça peut prendre entre 30 minutes et 2 heures.

OVH précise que
