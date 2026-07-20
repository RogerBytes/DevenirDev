# Liste d'applications

- VaultWarden
- OpenProject
- [Penpot](https://help.penpot.app/technical-guide/getting-started/docker/)

## Ce qui manque à la stack

1. Sécuriser les compartiments R2 de CloudFlare, retirer le droit de suppression, et activer Bucket Lock (rétention sur 30 jours) pour qu'aucun attaquant puisse effacer les backups distants.
2. Rajouter le SHA aux compose de services docker
3. Installation de Lynis (audit de défense comment faire un pentesting en attaque)
4. chkrootkit pour compléter RKHunter, penser à mettre son chron à une heure différente du chron de RKH

## A faire en premier

J'ai pas le temps, c'est la bourre, mais à faire en urgence quand j'aurais rattrapé le temps perdu

- [Forgejo](https://forgejo.org/docs/latest/admin/installation/docker/) -> pour hoster mon propre git, pas le temps tout de suite, mais très important pour la suite (et surtout il faut voir les sous service pour gérer le CI/CD avec dockerhub  etc).

## À faire quand mon applications sera déployée

- Umami pour analyser les visites, tracking des redirections ou des événements vers API (les requêtes passant par https)
- Grafana Loki, pour suivi centralisé de tous les logs, sur les satellites il y aura Promtail (Promtail est aussi sur le central, pas seulement sur satellite)

## À faire quand je commence à prospecter

- Invoice Ninja ou Crater - gestion de devis / facture / suivi de revenus -> Quand je commencerais à démarcher
- Listmonk - envoyer des newsletters ou des e-mails transactionnels (pour mon entreprise)
- Cal.com - gestion de mon CalDav Pro, permet de montrer un CalDav en lecture seule, et aussi de le modifier

## À faire quand j'aurais des salariés

- Bettershift - planning horaires (que j'utiliserais avec le site/webapp PayFit pour générer les fiches de paies avec les exports de planning)
- [Matrix](https://github.com/spantaleev/matrix-docker-ansible-deploy) -> pour imposer l'utilisation de canaux de communication sécurisées

## À faire quand j'aurais beaucoup de salariés

- [Outline](https://docs.getoutline.com/s/hosting/doc/docker-7pfeLP5a8t) -> pour très gros projet ou si mon entreprise grossit assez, sinon la partie "document" d'un projet openproject suffit largement
- HashiCorp Vault - c'est un gestionnaire de mdp de fichier d'environnement, pour centraliser les tokens et tout le bazar

## À faire sur un serveur à la maison

- [NextCloud](https://nextcloud.com/fr/installer/#instructions-server) -> Si je fais mon serveur à la maison

## Pour le S3 de mes applications

Ne pas se prendre la tête avec garage S3 ou autre, j'ai l'abo pro `Cloudflare R2`.

## Combien de VPS

- 1 VPS pour mon entreprise et ses services requis
- n\* VPS de prod (avec le déploiement de conteneurs y compris postgres symfony etc)
- 1 VPS de preprod (pour tester avant de déployer sur la prod)

## Garder ou pas Mandos ?

Mandos fait très bien son travail, et depuis que j'ai fais ma doc, ce sera très simple d'ajouter et gérer de nouveaux clients/serveurs.

Sur **Clevis/Tang**, il me faudra programmer un système de KillSwitch par client, ce qu'il n'y a pas par défaut, donc si je peux, je reste sur Mandos.

Après **Clevis/Tang** a peut-être d'autres usages (je ne sais pas), mais il y a surtout le fait qu'administrativement il peut-être obligatoire (je crois que c'est le RHEL).
