# 01 - Cloudlfare

Cloudflare gère le DNS et sert de proxy entre les visiteurs et le serveur.

## Les offres

- **L'offre gratuite :** Propose la protection DDoS ainsi que la dissimulation d'IP (Cloudflare joue le rôle de proxy).
- **L'offre payante :** Protège également contre les requêtes malveillantes en analysant le trafic applicatif.

## Réglage DNS

1. Se connecter [au dashboard de Cloudflare](https://dash.cloudflare.com), puis aller dans `Domaines > Vue d'ensemble`.
2. Cliquer sur `Ajouter un domaine` et choisir `Connecter un domaine`.
3. Entrer le nom de domaine (la configuration s'appliquera également aux sous-domaines).
4. Laisser l'option `Importer automatiquement les enregistrements DNS` cochée.
5. Gestion des bots : pour un projet professionnel, les autoriser. Pour un domaine personnel/privé, les bloquer pour limiter la visibilité.
6. Laisser coché `Orienter le trafic des bots IA avec robots.txt`.
7. Cliquer sur `Continuer` et choisir l'offre (gratuite ou payante, gratuit c'est très bien de base).

### Vérification et avertissements

Pour des entrées de type :

```text
A - mondomaine - xxx.xxx.xx.x
A - www - xxx.xxx.xx.x
CNAME - ftp - mondomaine.com
```

L'avertissement `Nom d'hôte n'est pas couvert par un certificat` peut apparaître. S'il s'agit des anciennes configurations par défaut d'OVH inutilisées, cet avertissement peut être ignoré.

On peut cliquer sur `Passer à l'activation`.

### Régler la zone DNS d'OVH

1. Se connecter [au compte OVH](https://www.ovh.com/auth/?onsuccess=https%3A//manager.eu.ovhcloud.com&ovhSubsidiary=FR).
2. Aller dans la section `Web Cloud > Noms de domaine` et sélectionner le domaine concerné (`mondomaine.com`).
3. Dans l'onglet **Informations générales**, désactiver la ligne **Délégation sécurisée (DNSSEC)**. _Note : Maintenir la "Protection contre le transfert" activée._
4. Aller dans l'onglet **Serveurs DNS**.
5. Cliquer sur le bouton `Modifier les DNS`.
6. Cocher le choix `Utiliser mes propres DNS`.
7. Renseigner les serveurs de noms fournis par Cloudflare :
   - `renan.ns.cloudflare.com`
   - `veda.ns.cloudflare.com`
8. Cliquer sur `Appliquer la configuration`.

Et on attends que les nouveaux serveurs DNS soient actifs (5 minutes chez moi).

### Validation et finalisation sur Cloudflare

1. Retourner sur le tableau de bord Cloudflare, sur la page du domaine en attente (la page `Mettez à jour vos serveurs de noms pour activer Cloudflare.`).
2. En bas de page, cliquer sur le bouton `J'ai modifié mes serveurs DNS`.

**Délai de propagation :**
Le message `En attente que votre serveur d’inscription propage vos nouveaux serveurs de noms` s'affiche. Bien que le système indique un délai potentiel de 1h à 2h, la détection peut être effective en quelques minutes (environ 2 minutes après un rafraîchissement de la page).

La validation finale est confirmée par le message :

- `Votre domaine est désormais protégé par Cloudflare.`

Ça y est, c'est fini.

## Options de CloudFlare à activer

Dans la vue d'ensemble, il faut activer les Options

- Page Shield
- Mode Bot Fight
- Détection des informations d'identification divulguées

## Option `Mode Under Attack`

Si jamais une attaque DDoS a lieu contre mon site/app !

Dans la vue d'ensemble, dans le panel latérale de droite, activer l'option `Mode Under Attack`

## Régler la vraie IP du VPS

Cloudflare a importé la zone DNS depuis OVH, mais il faut vérifier et corriger les enregistrements A pour qu’ils pointent vers l’IP du VPS (sinon rien ne fonctionnera).

- Aller sur [le dashboard CloudFlare](https://dash.cloudflare.com) dans le menu de gauche et aller dans `Domaine/Vue d'ensemble`, cliquer sur le domaine.
- Dans le menu de gauche, aller dans `DNS/Enregistrements`
- Pour les entrées `A` avec `mondomaine` `www.mondomaine`, cliquer sur `Modifier` et mettre l'IP de votre VPS

## Résumé

- **Objectif :** Migration de la gestion de la zone DNS d'OVH vers Cloudflare.
- **Modification des serveurs DNS :** Accès à l'onglet `Serveurs DNS` dans l'espace client OVH. Sélection de l'option `Utiliser mes propres DNS` pour y renseigner les serveurs de noms Cloudflare fournis.
- **Ajustement de la sécurité :** Désactivation de la délégation sécurisée (`DNSSEC`) chez le registraire pour permettre la validation par Cloudflare. Maintien de la `Protection contre le transfert` active pour sécuriser le domaine.
- **Statut final :** Détection automatique validée par Cloudflare. Le domaine est désormais actif et sécurisé sur la nouvelle infrastructure.
- **Gestion future :** Toute l'administration et la configuration de la zone DNS (ajouts ou modifications d'entrées) s'effectuent désormais exclusivement depuis le compte Cloudflare, et plus depuis l'interface d'OVH.
