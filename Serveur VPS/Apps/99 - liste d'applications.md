# Liste d'applications

- VaultWarden
- OpenProject
- [Penpot](https://help.penpot.app/technical-guide/getting-started/docker/)

## A faire en premier

J'ai pas le temps, c'est la bourre, mais à faire en urgence quand j'aurais rattrapé le temps perdu

- [Forgejo](https://forgejo.org/docs/latest/admin/installation/docker/) -> pour hoster mon propre git, pas le temps tout de suite, mais très important pour la suite (et surtout il faut voir les sous service pour gérer le CI/CD avec dockerhub  etc).

## À faire quand mon applications sera déployée

- Umami pour analyser les visites, tracking des redirections ou des événements vers API (les requêtes passant par https)

## À faire quand je commence à prospecter

- Invoice Ninja ou Crater - gestion de devis / facture / suivi de revenus -> Quand je commencerais à démarcher
- Listmonk - envoyer des newsletters ou des e-mails transactionnels (pour mon entreprise)
- Cal.com - gestion de mon CalDav Pro, permet de montrer un CalDav en lecture seule, et aussi de le modifier

## À faire quand j'aurais des salariés

- Bettershift - planning horaires (que j'utiliserais avec le site/webapp PayFit pour générer les fiches de paies avec les exports de planning)
- [Matrix](https://github.com/spantaleev/matrix-docker-ansible-deploy) -> pour imposer l'utilisation de canaux de communication sécurisées

## À faire quand j'aurais beaucoup de salariés

- [Outline](https://docs.getoutline.com/s/hosting/doc/docker-7pfeLP5a8t) -> pour très gros projet ou si mon entreprise grossit assez, sinon la partie "document" d'un projet openproject suffit largement

## À faire sur un serveur à la maison

- [NextCloud](https://nextcloud.com/fr/installer/#instructions-server) -> Si je fais mon serveur à la maison

## Pour le S3 de mes applications

Ne pas se prendre la tête avec garage S3 ou autre, j'ai l'abo pro `Cloudflare R2`.

## Combien de VPS

- 1 VPS pour mon entreprise et ses services requis
- n\* VPS de prod (avec le déploiement de conteneurs y compris postgres symfo etc)
- 1 VPS de preprod (pour tester avant de déployer sur la prod)
