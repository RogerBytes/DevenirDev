# 02 - Configuration et durcissement du serveur

## Les 4 points de sécurité

Voici les 4 piliers de sécurité à respecter

1. **Le Moindre Privilège** - Gestion des utilisateurs avancée : sudo impératif, retrait de connexion à l'user `debian`, root verrouillé.
2. **Le Security by Design** - Conception sécurisée de l'architecture en amont : [Cloudflare -> Caddy -> Docker] avant même de coder quoi que ce soit.
3. **La Défense en Profondeur** - Empilement de couches : Cloudflare + Pare-feu + Fail2ban + Clés SSH + Rkhunter.
4. **Le Zero Trust** - Cloisonnement : chaque service est un conteneur isolé passant par son `localhost`.

## La Checklist de sécurité

- [x] connexion uniquement par clef ssh (avec mdp)
- [x] rkhunter pour détecter rootkit et backdoor
- [x] changement du port ssh par défaut
- [x] ajout d'un user supplémentaire (moi) avec accès sudo
- [x] pare-feu fermé par défaut pour les entrées sauf http, https, port ssh et localhost
- [x] fail2ban pour protéger mon port SSH
- [x] lock de l'user initial de la debian
- [x] verrouillage de la connexion ssh à root
- [x] gestion des logs
- [x] màj auto avec unattended-upgrades
- [x] la pare-feu bloque tous les ports, sauf le local host et le port ssh
- [x] le pare-feu a une liste blanche d'ip de CloudFlare, seules ces ip peuvent acceder à http et https
- [x] fail2ban contrôle le pare-feu de CloudFlare via API, bloquant automatiquement les IP malveillantes
- [x] docker installé en mode standard, nécessitant sudo (pour éviter un hack depuis un conteneur)
- [x] gestion des logs docker
- [x] mise en place de reverse proxy avec caddy (avec CloudFlare) + paramétrage de fail2ban sur caddy
- [x] déploiements via conteneurs docker (c'est caddy qui prend en charge la redirection des connexion entrantes vers les localhost des différents conteneurs)

## Représentation du flux entrant

Seules les connexions entrantes sont filtrées, toutes les connexions sortantes sont traitées par les conteneurs Docker (qui gèrent nativement iptables sur Debian).

```mermaid
graph TD
  %% Définition des styles
  classDef internet fill:#eceff1,stroke:#37474f,stroke-width:2px,color:#000;
  classDef cloudflare fill:#f57c00,stroke:#e65100,stroke-width:2px,color:#fff;
  classDef ufw fill:#d32f2f,stroke:#c62828,stroke-width:2px,color:#fff;
  classDef caddy fill:#00acc1,stroke:#006064,stroke-width:2px,color:#fff;
  classDef docker fill:#1e88e5,stroke:#0d47a1,stroke-width:2px,color:#fff;
  classDef f2b fill:#7b1fa2,stroke:#4a148c,stroke-width:2px,color:#fff;

  %% Flux Légitime via CloudFlare
  A([🌐 Visiteur Web Légitime]) -->|1. Requête domaine.com| B{☁️ Pare-feu CloudFlare}
  B -->|2. ALLOW: Trafic via IP CloudFlare| C{🛡️ Pare-feu UFW}
  C -->|3. ALLOW: Ports 80 et 443| D[🔀 Caddy Reverse Proxy]

  %% Flux Malveillant (Tentative de contournement direct)
  E([🥷 Attaquant / Robot Scan]) -.->|Tentative IP directe du serveur| C
  C -.->|DENY: Pas une IP CloudFlare| X((❌ Connexion rejetée Timeout))

  %% Interne au Serveur et Boucle Fail2Ban
  D -->|4. Redirection Localhost| F[🐳 Conteneurs Docker Applications]
  D -.->|5. Analyse des logs de Caddy| G[🔒 Fail2Ban]
  G -.->|6. Action de blocage via API| B

  %% Blocage au niveau de Cloudflare pour les récidivistes
  B -.->|DENY: IP bannie par Fail2Ban| Y((❌ Bloqué par CloudFlare))

  %% Application des styles
  class A,E internet;
  class B cloudflare;
  class C ufw;
  class D caddy;
  class F docker;
  class G f2b;
```

## Perspectives : Sécurité Applicative (Symfony & Docker)

Pour compléter ce plan de durcissement, la sécurité du code et des conteneurs sera validée via trois piliers indispensables :

1. **Le Scan Statique (SAST) :** Analyse automatisée du code source Symfony (via des outils comme PHPStan ou SonarQube) directement lors du `git push` pour détecter les failles logiques (injections, variables non nettoyées) avant la mise en production.
2. **Le Scan Dynamique (DAST) :** Simulation d'attaques en conditions réelles sur l'API en cours d'exécution (via OWASP ZAP) pour éprouver la résistance des routes et des formulaires face aux comportements malveillants.
3. **Le Contrôle des Dépendances (Indispensable Symfony) :** Utilisation systématique de la commande `local:check:security` de Symfony pour scanner instantanément le fichier `composer.lock` et bloquer le déploiement si une bibliothèque tierce contient une vulnérabilité connue.
*(Note : La mise à jour automatisée des images de conteneurs sera assurée par Watchtower).*

## Reste à faire (Perspectives de production)

Pour finaliser la mise en production du serveur et garantir une sécurité maximale lors du déploiement, les points suivants devront être configurés et respectés :

### 1. Règle de pare-feu UFW spécifique à Cloudflare

Lors de la configuration finale du pare-feu de la machine (UFW/iptables), restreindre le trafic entrant sur les ports HTTP (80) et HTTPS (443) pour n'accepter **que** les requêtes provenant des adresses IP officielles de Cloudflare.

- *Objectif :* Empêcher qu'un attaquant puisse contourner le proxy et le bouclier Cloudflare en attaquant directement l'adresse IP publique (et théoriquement cachée) du VPS.

### 2. Politique de sauvegarde applicative (Backup)

En complément des sauvegardes trimestrielles de Vaultwarden/KeePassXC, mettre en place un script automatisé de sauvegarde pour la base de données de l'application Symfony.

- *Objectif :* Externaliser quotidiennement ou hebdomadairement les données applicatives vers un espace de stockage distant et sécurisé, totalement indépendant du serveur principal.

### 3. Injection sécurisée des secrets (Zéro fichier .env en production)

Bien que l'usage d'un fichier `.env.local` soit la norme en phase de développement (avec exclusion stricte dans le `.gitignore`), bannir la présence de tout fichier `.env` physique sur le disque dur du serveur de production.

- *Fonctionnement :* Les variables sensibles (clés d'API, `APP_SECRET`, identifiants de base de données) seront définies directement au niveau du système hôte ou injectées via les secrets d'un outil de déploiement (CI/CD).

- *Configuration Docker :* Le fichier `docker-compose.yml` récupérera ces variables via l'interpolation (ex: `DATABASE_URL=${DB_PASSWORD}`) et les injectera directement dans l'environnement du conteneur au démarrage.

- *Objectif :* Garantir que les données ultra-sensibles ne vivent que dans la mémoire vive (RAM) des processus isolés de Docker. Même en cas d'accès SSH frauduleux aux fichiers du projet, aucun secret ne sera lisible en clair sur le stockage.

### 4. Supervision et Alerting : Notifications d'alertes Rkhunter par e-mail

Configurer un service d'envoi de mail local (comme `postfix` ou `ssmtp` configuré en relais SMTP sécurisé) pour permettre au système de communiquer avec l'extérieur.

- *Fonctionnement :* Paramétrer le fichier de configuration de l'outil (`/etc/rkhunter.conf`) via la directive `MAIL-ON-WARNING="ton-adresse@email.com"` pour lier le cron quotidien de Rkhunter à une boîte mail dédiée.

- *Objectif :* Être alerté instantanément en cas de détection de rootkit, de modification suspecte de fichiers système ou d'anomalie de sécurité (`WARNING`), évitant ainsi d'avoir un outil de détection passif qui tourne en tâche de fond sans supervision humaine active.

### 5. Maintenance et cycle de vie : Gestion des mises à niveau (Upgrades)

Planifier une routine de veille et de mise à jour majeure pour le framework (Symfony), le langage (PHP) et le système de gestion de base de données, au-delà des simples patchs de sécurité automatisés.

- *Fonctionnement :* Suivre la feuille de route (*roadmap*) de Symfony pour caler les montées de versions (par exemple, migrer d'une version mineure à une autre, ou planifier le passage à une version LTS - *Long Term Support*). Utiliser les outils de migration de Symfony (`maker-bundle` ou outils de dépréciation) pour adapter le code aux nouvelles normes.

- *Objectif :* Éviter l'obsolescence logicielle et la perte de support de sécurité (*End of Life*). Un système maintenu à jour régulièrement demande un effort minime à chaque étape, alors qu'attendre plusieurs années rend la mise à niveau complexe, risquée et crée une dette technique critique.

### 6. Gestion des accès de l'équipe (Identity and Access Management - IAM)

Appliquer une politique stricte d'accès nominatif et restreint pour les futurs collaborateurs ou développeurs devant intervenir sur l'infrastructure.

- *Accès SSH Nominatif (Zéro partage) :* Bannir le partage de clés SSH ou de comptes génériques. Chaque membre de l'équipe possède sa propre clé SSH publique, ajoutée manuellement par l'administrateur dans les `authorized_keys`. Cela garantit la traçabilité totale des actions dans les journaux système (`/var/log/auth.log`).

- *Refus du groupe Docker (Contre l'escalade de privilèges) :* Ne jamais ajouter un utilisateur standard au groupe système `docker` pour lui éviter l'usage direct de Docker sans élévation. Le démon Docker tournant en `root`, cette pratique permettrait une escalade de privilèges (possibilité de monter la racine du serveur dans un conteneur et d'en modifier les fichiers).

- *Privilèges Sudo et Révocation :* Privilégier l'attribution des droits `sudo` classiques (nécessitant le mot de passe de l'utilisateur) uniquement aux profils de confiance absolue pour les tâches de déploiement. En cas de départ d'un collaborateur, la révocation est immédiate et sans impact sur les autres via la simple suppression de sa clé SSH.

- *Objectif :* Maintenir le pilier du **Moindre Privilège** au niveau humain, assurer l'imputabilité des commandes lancées sur le serveur et bloquer les vecteurs d'attaques internes par contournement des droits système.
