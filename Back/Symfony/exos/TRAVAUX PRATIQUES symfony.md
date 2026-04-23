# TRAVAUX PRATIQUES

---

## Développement d’une Application Web de Monitoring de Modules IoT

### Objectif pédagogique

L’objectif de ce TP est d’évaluer vos compétences en **développement web et programmation**, à travers la conception d’une application permettant de **simuler et superviser des modules IoT (objets connectés)**.

Les objets connectés sont de plus en plus présents dans notre environnement, mais les outils permettant de surveiller leur fonctionnement et leur disponibilité restent limités.

Vous devez donc développer une **application web de monitoring** permettant de visualiser l’état et l’historique de modules IoT simulés.

---

## Technologies à utiliser

Les technologies recommandées sont :

- **HTML**
- **CSS**
- **Bootstrap**
- **JavaScript** (librairies autorisées, mais pas de frameworks JS)
- **PHP**
- **MySQL**
- Frameworks PHP autorisés : **Symfony**

---

## Consignes générales

- Les modules IoT **ne doivent pas être réellement connectés**.
- Vous devez développer un **script simulant leur fonctionnement**.
- L’application devra être **fonctionnelle et testable**.
- Fournir toutes les instructions nécessaires à l’installation et à l’exécution du projet.
- Le script de génération des données doit continuer à fonctionner même lors de la navigation sur le site.

---

## Travail demandé

### 1️⃣ Création de la Base de Données

Créer une base de données contenant :

- Une table des **modules IoT**
    - Identifiant
    - Nom
    - Type de mesure (température, vitesse, etc.)
    - Date d’ajout
    - État (en marche / en panne)
    - Etc.
- Une table d’**historique des mesures**
    - Identifiant
    - ID du module
    - Valeur mesurée
    - Date/heure
    - Statut du module

---

### 2️⃣ Formulaire d’ajout de modules

Créer une interface permettant :

- L’ajout d’un nouveau module
- La définition de son type de mesure
- L’enregistrement des informations en base de données

---

### 3️⃣ Page de monitoring

Créer une page affichant pour chaque module :

- ✅ Valeur actuelle mesurée
- ⏱ Durée de fonctionnement
- 📊 Nombre total de données envoyées
- 🔄 État actuel (en marche / en panne)
- 📈 Un graphique représentant l’évolution des mesures

---

### 4️⃣ Notifications visuelles

Mettre en place :

- Des alertes visuelles (ex : badge rouge, icône d’erreur, alerte Bootstrap)
- Indication claire lorsqu’un module est en panne

---

### 5️⃣ Script de simulation automatique

Créer un script permettant :

- La génération automatique de données numériques (ex : température aléatoire)
- L’enregistrement régulier des données en base
- La simulation aléatoire :
    - Des pannes
    - Des redémarrages
- La continuité de génération même pendant la navigation utilisateur

---

## Éléments d’évaluation

Votre travail sera évalué sur :

- ✔ Respect des consignes
- ✔ Qualité du code (structure, logique, commentaires)
- ✔ Organisation du projet
- ✔ Choix techniques
- ✔ Facilité d’installation
- ✔ Design et ergonomie
- ✔ Améliorations ou fonctionnalités supplémentaires

---

## Bonus (facultatif, mais valorisé)

- Dashboard amélioré
- Filtrage des modules
- Système d’authentification
- API interne
- Architecture MVC propre
- Utilisation AJAX pour rafraîchissement en temps réel