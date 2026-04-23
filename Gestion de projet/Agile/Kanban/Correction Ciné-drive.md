# Correction Ciné-drive

## 1. Exemple de Product Backlog (Priorisé)

- Visualisation de la carte des snacks et prix.
- Panier et sélection des quantités.
- Paiement en ligne (Carte Bancaire / Apple Pay).
- Génération d'un QR Code de commande.
- Interface "Vendeur" pour valider la récupération des commandes.
- Notification "Commande prête".

On commence par le parcours d'achat (1 à 4) car c'est la valeur principale. L'interface vendeur (5) est vitale pour l'opérationnel. Les notifications (6) sont un plus pour l'expérience utilisateur mais moins critiques au début.

## 2. Exemples de User Stories

- **US #1 :** En tant que **Spectateur pressé**, je veux **commander mon pop-corn via l'app** afin de **ne pas rater le début du film**.
    - *Critère :* Le montant total doit s'afficher avant de payer.
- **US #2 :** En tant que **Vendeur au comptoir**, je veux **scanner le QR code du client** afin de **marquer la commande comme "livrée"**.
    - *Critère :* Le système doit empêcher de scanner deux fois le même code.

## 3. Simulation du Tableau Kanban

| **À faire (Backlog)** | **En cours** | **À tester** | **Terminé** |
| --- | --- | --- | --- |
| Configurer les notifications | Design de l'interface Panier | Système de paiement (API) | Création de la base de données snacks |
| Historique des commandes |  |  |  |
- Le Kanban permet de visualiser le **flux de travail**.
- Si la colonne "À tester" est pleine, l'équipe sait qu'elle doit arrêter de coder de nouvelles choses et aider à tester pour débloquer le flux (principe du *Stop starting, start finishing*).
- C’est l’outil idéal pour voir où se situent les **goulots d'étranglement**.