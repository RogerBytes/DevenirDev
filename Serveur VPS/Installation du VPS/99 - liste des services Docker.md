# 99 - liste des services Docker

## Conteneurs d'administration sur tous mes VPS

1. Caddy (base reverse proxy pour les conteneurs)
2. ClamAv
3. WatchTower (voir pour mettre le mode notification)
4. Uptime Kuma
5. Offen Docker Volume Backup (pour envoyer un roulement de 7 jour à `Cloudflare R2` et dire à R2 de virer ce qui a plus de 7 jours)
6. Portainer CE

## Mes conteneurs pour ma boite

1. VaultWarden
2. Penpot
3. OpenProject
4. Outline
5. forgejo (pour mon code privé)

et éventuellement

1. Invoice Ninja ou Crater - gestion de devis / facture / suivi de revenus
2. Umami pour analyser les visites, aussi les direction de mes app vers des api (les requetes passant par https)
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
- n* VPS de prod (avec le déploiement de conteneurs y compris postgres symfo etc)
- 1 VPS de preprod (pour tester avant de déployer sur la prod)
