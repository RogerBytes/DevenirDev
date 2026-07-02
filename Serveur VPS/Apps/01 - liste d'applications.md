# Liste d'applications

- VaultWarden
- OpenProject
- [Penpot](https://help.penpot.app/technical-guide/getting-started/docker/)

## A faire

- [Matrix](https://github.com/spantaleev/matrix-docker-ansible-deploy) -> Pas le temps tout de suite
- [NextCloud](https://nextcloud.com/fr/installer/#instructions-server) -> Si je fais mon serveur à la maison
- [Forgejo](https://forgejo.org/docs/latest/admin/installation/docker/) -> pour hoster mon propre git, pas le temps tout de suite.
- [Outline](https://docs.getoutline.com/s/hosting/doc/docker-7pfeLP5a8t) -> pour très gros projet ou si mon entreprise grossit assez, sinon la partie "document" d'un projet openproject suffit largement

et éventuellement

1. Invoice Ninja ou Crater - gestion de devis / facture / suivi de revenus
2. Umami pour analyser les visites, aussi les direction de mes app vers des api (les requêtes passant par https)
3. Listmonk - envoyer des newsletters ou des e-mails transactionnels
4. Cal.com - gestion de mon CalDav Pro, permet de montrer un caldav en lecture seule, et aussi de le modifier
5. Budibase ou Appsmith - pour faire les plannings de mes salariés

## Les trucs optionnels

- Matrix synapse
- NextCloud (POUR MACHINE PERSO/NAS SEULEMENT)

## Pour le S3 de mes applications

Ne pas se prendre la tête avec garage S3, mais prendre abo gratuit `Cloudflare R2`.

## Combien de VPS

- 1 VPS pour mon entreprise et ses services requis
- n\* VPS de prod (avec le déploiement de conteneurs y compris postgres symfo etc)
- 1 VPS de preprod (pour tester avant de déployer sur la prod)
