# Utiliser mail MXROUTE

Ceci est un système de création de boite mail, je peux générer 400 mails par heure par domaine que j'y ajoute, je peux ajouter autant de domaines que je veux et créer autant de boites mails que je souhaite.

Les différent menus du panel

- Dashboard : Page d'accueil, montre les domaines ajoutés et s'ils sont bien actifs
- Domains : Permet d'ajouter des domaines
- Email Account : Permet de gérer/ajouter/modifier des boites mail
- Email Forwarders : Permet de faire des redirection de mails
- Email Clients : C'est les infos pour se connecter sur un client mail type Thunderbird
- Spam Filters : Réglage du filtrage de spam
- DNS : Les infos pour faire les réglages DNS du registrar
- Calendar & Contacts : C'est pour se connecter au service CalDAV, il y en a un par boite mail
- SSL Certificates : Les infos pour faire les réglages SSL du registrar et ensuite demander le certificat SSL
- Advanced : Options avancées

## Ajouter un domaine à mxroute

Il faut avant tout avoir un nom de domaine, par exemple en achetant chez [OVH](https://www.ovhcloud.com/fr/domains/).

### Premier ajout de domaine sur mxroute

Se connecter au [site de mxroute.com](https://management.mxroute.com/dashboard)

Dans le menu `dashboard` (par défaut), cliquer sur le bouton `Login to Panel`, et allez sur le menu `Domains`.

Cliquer sur `+ Add New Domain`, entrer le nom de domaine, par exemple `nimportequoiquoi.com`.
Une modale s'ouvre, nous demandant d'ajouter l'ownership sur notre domaine, avec deux valeurs importantes dans le tas.

```text
Record Name:
_da-verify-xxxxxebbcxxxxxa4f162xxxxx853dxxx

Record Value:
domain-verified
```

Et il dit qu'on peut vérifier en faisant `dig TXT _da-verify-xxxxxebbcxxxxxa4f162xxxxx853dxxx.nimportequoiquoi.com`

Mais d'abord il faut paramétrer l'ownership du domaine (sur CloudFlare attention), ce qui permettra de rediriger sur MXROUTE.com.

### Ajouter l'ownership sur le domaine chez OVH

- Se connecter [au compte CloudFlare](https://dash.cloudflare.com/)
et allez dans la partie `Domaines/Vue d'ensemble` et cliquer sur le nom de domaine, ici `nimportequoiquoi.com`, puis aller dans `DNS/Enregistrements`

- Cliquez (à droite) sur `Ajouter un enregistrement`, choisir Type `TXT`

- Dans **Nom**, ajoutez donc `_da-verify-xxxxxebbcxxxxxa4f162xxxxx853dxxx`
- Dans **TTL**, laissez le réglage par défaut
- Dans **Contenu**, ajoutez donc `domain-verified`

En bas il affiche

`_da-verify-xxxxxebbcxxxxxa4f162xxxxx853dxxx IN TXT "domain-verified"`

Vous pouvez cliquez sur `Suivant`, sur l'étape 3, c'est juste un récapitulatif, cliquez sur `Valider`.

L'ownership est bien réglé, il peut il y a avoir un certain délai, le temps que les DNS soit mis à jour.

### Vérification de l'ownership

Maintenant que nous avons paramétré l'ownership, nous allons pouvoir définitivement l'ajouter dans MXROUTE.

On vérifie la commande de tout à l'heure dans un terminal, la commande `dig TXT _da-verify-xxxxxebbcxxxxxa4f162xxxxx853dxxx.nimportequoiquoi.com`

Dans `ANSWER SECTION:` il faut que ça se termine par `"domain-verified"`.

Par exemple

```bash
 dig TXT _da-verify-xxxxxebbcxxxxxa4f162xxxxx853dxxx.nimportequoiquoi.com

; <<>> DiG xxxxxxxxxxxxxxxx <<>> TXT _da-verify-xxxxxebbcxxxxxa4f162xxxxx853dxxx.nimportequoiquoi.com
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 53518
;; flags: qr rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 65494
;; QUESTION SECTION:
;_da-verify-xxxxxebbcxxxxxa4f162xxxxx853dxxx.nimportequoiquoi.com. IN TXT

;; ANSWER SECTION:
_da-verify-xxxxxebbcxxxxxa4f162xxxxx853dxxx.nimportequoiquoi.com. 3600 IN TXT "domain-verified"

;; Query time: 49 msec
;; SERVER: xxx.x.x.xx#xx(xx.xx.xx.xx) (UDP)
;; WHEN: Wed Jun 28 15:28:52 CEST 2024
;; MSG SIZE  rcvd: 115
```

Le retour de `ANSWER SECTION` confirme que le réglage est pris en compte, on peut terminer le réglage.
Tant que le réglage n'est pas pris en compte, on ne pourra pas l'ajouter dans MXROUTE, avec CloudFlare, c'est instantané.

### Finalisation de l'ajout de domaine sur MXROUTE.com

Se connecter au [site de mxroute.com](https://management.mxroute.com/dashboard)

Dans le menu `dashboard` (par défaut), cliquer sur le bouton `Login to Panel`, et allez sur le menu [Domains](https://panel.mxroute.com/domains.php).

Cliquer sur `+ Add New Domain`, entrer le nom de domaine, par exemple `nimportequoiquoi.com`.
s
Et voilà, le domaine est immédiatement enregistré.

## Paramétrer la boite mail sur mxroute.com

Basé sur [cette doc](https://docs.mxroute.com/docs/quick-setup.html#_3-dns-configuration)
Se connecter au [site de mxroute.com](https://management.mxroute.com/dashboard)

Dans le menu `dashboard` (par défaut), cliquer sur le bouton `Login to Panel`,

Allez dans le menu `DNS`, les entrées présentes doivent être ajoutées auprès du registrar/DNS (ici OVH)

Dans une autre fenêtre

- Se connecter [au compte CloudFlare](https://dash.cloudflare.com/)
et allez dans la partie `Domaines/Vue d'ensemble` et cliquer sur le nom de domaine, ici `nimportequoiquoi.com`, puis aller dans `DNS/Enregistrements`

S'il y a plus de deux entrées `MX` (c'est pout Mail Exchanger), supprimez les pour qu'il n'y en ait plus que deux.
S'il y a une entrée `SPF`, il faut la supprimer (**quand on la copie colle, il faut retirer les guillemets, sinon ça ne marchera pas**).
Ajouter les entrées dans le registrar en se basant sur les indications de mxroute.com

Avec CloudFlare les changements sont instantanés

## Ajout du certificat SSL

Dans le menu `dashboard` (par défaut), cliquer sur le bouton `Login to Panel`,

Allez dans le menu `SSL Certificates`, les entrées présentes doivent être ajoutées auprès du registrar/DNS (ici OVH)

dans une autre fenêtre

- Se connecter [au compte OVH](https://www.ovh.com/auth/?onsuccess=https%3A//manager.eu.ovhcloud.com&ovhSubsidiary=FR)
et allez dans la partie `Web Cloud/Zone DNS` et cliquer sur le nom de domaine, ici `nimportequoiquoi.com`

Pareil faire les entrées en suivant les indications de mxroutes.com

Rafraîchir la page, sélectionner les deux sous-domaines et cliquer sur `Request Certificates`

Voilà la sécurité SSL est mise en place.
