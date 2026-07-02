# 01 - Installation VaultWarden

Depuis [Page docker hub](https://hub.docker.com/r/openproject/openproject)
Depuis [la doc All-In-One de déploiement Docker](https://www.openproject.org/docs/installation-and-operations/installation/docker/)

Le mode [All-In-One](https://www.openproject.org/docs/installation-and-operations/installation/docker/)(ce qui est utilisé dans la présente documentation) convient parfaitement pour trente dev travaillant dessus simultanément. Au dessus de 30 personne, on déploiera OpenProject via [une méthode avec un conteneur par service](https://www.openproject.org/docs/installation-and-operations/installation/docker-compose/)

## Prérequis

### Création du répertoire

On prépare un répertoire dans `opt/docker`

```bash
sudo mkdir -p /opt/docker/apps/openproject
cd /opt/docker/apps/openproject
```

### Gestion  domaine / sous domaine CloudFlare

On va sur [dashboard de CloudFlare](dash.cloudflare.com)

- puis `Domaine / Vue d'ensemble` cliquer sur le domaine
- puis `DNS / Enregistrements`
- cliquer sur le bouton `+ Ajouter un enregistrement`
- Type `A`
- Nom `op.domaine.com`
- Adresse IPv4 `192.0.2.1`
- cliquer sur `Enregistrer`

Remplacer `192.0.2.1` par l'ipv4 du VPS.

### Créer nouveau compte mail MXROUTE

Se connecter au [site de mxroute.com](https://management.mxroute.com/dashboard)

- Dans le menu `dashboard` (par défaut), cliquer sur le bouton `Login to Panel`, et allez sur le menu `Email Accounts`.
- Cliquer sur `+ Create New Email Account`, entrer `noreply` comme username et lui générer un mdp (garder précieusement les identifiants) et cliquer sur `Create Account`.
- La mail généré est `noreply@votrenomdedomaine.com`

### Récupérer le serveur MX de MXROUTE

Se connecter au [site de mxroute.com](https://management.mxroute.com/dashboard)

- Dans le menu `dashboard` (par défaut), cliquer sur le bouton `Login to Panel`, et allez sur le menu `DNS`.
- Dans l'encadré `MX Records` prendre la `VALUE` de celui avec la `PRIORITY` 10 (l'autre est un serveur de secours si le premier est en rade).
- Vous aurez une adresse serveur du genre `machin.mxrouting.net`

Si le compte MXROUTE est bien réglé, et pareil du côté du registrar lors de l'ajout du NDD, il n'y a rien d'autre à faire pour le mailing.

On en profite pour créer une boite mail `vault@votrenomdedomaine.com`, attention à ne pas avoir de `$` dans le mot de passe.

### Générer une clef secrète pour openproject

```bash
openssl rand -hex 64
```

Gardez précieusement la chaîne générée de côté, elle va servir dans le fichier de configuration juste après.
