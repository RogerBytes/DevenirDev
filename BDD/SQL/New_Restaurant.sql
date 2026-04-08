DROP DATABASE IF EXISTS restaurant;
CREATE DATABASE restaurant;
USE restaurant;

-- Table client
CREATE TABLE client (
    id_client INT AUTO_INCREMENT PRIMARY KEY,
    nom VARCHAR(50) NOT NULL,
    prenom VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE
) ENGINE=InnoDB;

-- Table categorie
CREATE TABLE categorie (
    id_categorie INT AUTO_INCREMENT PRIMARY KEY,
    nom_categorie VARCHAR(50) NOT NULL
) ENGINE=InnoDB;

-- Table plat
CREATE TABLE plat (
    id_plat INT AUTO_INCREMENT PRIMARY KEY,
    nom_plat VARCHAR(50) NOT NULL,
    prix DECIMAL(10,2) NOT NULL,
    id_categorie INT NOT NULL,
    FOREIGN KEY (id_categorie) REFERENCES categorie(id_categorie)
) ENGINE=InnoDB;

-- Table commande
CREATE TABLE commande (
    id_commande INT AUTO_INCREMENT PRIMARY KEY,
    id_client INT NOT NULL,
    date_commande DATE NOT NULL,
    total DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (id_client) REFERENCES client(id_client)
) ENGINE=InnoDB;

-- Table de liaison (clé du modèle)
CREATE TABLE ligne_commande (
    id_commande INT NOT NULL,
    id_plat INT NOT NULL,
    quantite INT NOT NULL DEFAULT 1,
    PRIMARY KEY (id_commande, id_plat),
    FOREIGN KEY (id_commande) REFERENCES commande(id_commande) ON DELETE CASCADE,
    FOREIGN KEY (id_plat) REFERENCES plat(id_plat) ON DELETE CASCADE
) ENGINE=InnoDB;


-- Données pour la table `client`
INSERT INTO client (nom, prenom, email) VALUES
('Martin', 'Lucie', 'lucie.martin@example.com'),
('Bernard', 'Julien', 'julien.bernard@example.com'),
('Kuong', 'Émilie', 'emilie.kuong@example.com'),
('Petit', 'Sophie', 'sophie.petit@example.com'),
('Robert', 'Christophe', 'christophe.robert@example.com');

-- Données pour la table `categorie`
INSERT INTO categorie (nom_categorie) VALUES
('Entrée'),
('Pizza'),
('Pâtes'),
('Burger'),
('Plat principal'),
('Dessert'),
('Boisson');

-- Données pour la table `plat`
INSERT INTO plat (nom_plat, id_categorie, prix) VALUES
-- Entrées
('Soupe à l\'oignon', (SELECT id_categorie FROM categorie WHERE nom_categorie = 'Entrée'), 8.50),
('Bruschetta', (SELECT id_categorie FROM categorie WHERE nom_categorie = 'Entrée'), 7.00),
('Carpaccio de boeuf', (SELECT id_categorie FROM categorie WHERE nom_categorie = 'Entrée'), 9.00),
('Salade César', (SELECT id_categorie FROM categorie WHERE nom_categorie = 'Entrée'), 10.50),
('Tartare de saumon', (SELECT id_categorie FROM categorie WHERE nom_categorie = 'Entrée'), 11.00),

-- Pizzas
('Pizza Margherita', (SELECT id_categorie FROM categorie WHERE nom_categorie = 'Pizza'), 12.00),
('Pizza Quatre Fromages', (SELECT id_categorie FROM categorie WHERE nom_categorie = 'Pizza'), 14.00),
('Pizza Pepperoni', (SELECT id_categorie FROM categorie WHERE nom_categorie = 'Pizza'), 13.50),
('Pizza Végétarienne', (SELECT id_categorie FROM categorie WHERE nom_categorie = 'Pizza'), 12.50),
('Pizza Hawaïenne', (SELECT id_categorie FROM categorie WHERE nom_categorie = 'Pizza'), 13.00),

-- Pâtes
('Spaghetti Carbonara', (SELECT id_categorie FROM categorie WHERE nom_categorie = 'Pâtes'), 14.50),
('Tagliatelles au Saumon', (SELECT id_categorie FROM categorie WHERE nom_categorie = 'Pâtes'), 16.00),
('Lasagnes Bolognese', (SELECT id_categorie FROM categorie WHERE nom_categorie = 'Pâtes'), 15.00),
('Penne Arrabiata', (SELECT id_categorie FROM categorie WHERE nom_categorie = 'Pâtes'), 13.00),
('Raviolis aux Champignons', (SELECT id_categorie FROM categorie WHERE nom_categorie = 'Pâtes'), 15.50),

-- Burgers
('Cheeseburger', (SELECT id_categorie FROM categorie WHERE nom_categorie = 'Burger'), 12.50),
('Bacon Burger', (SELECT id_categorie FROM categorie WHERE nom_categorie = 'Burger'), 13.50),
('Chicken Burger', (SELECT id_categorie FROM categorie WHERE nom_categorie = 'Burger'), 12.00),
('Veggie Burger', (SELECT id_categorie FROM categorie WHERE nom_categorie = 'Burger'), 11.50),
('Double Burger', (SELECT id_categorie FROM categorie WHERE nom_categorie = 'Burger'), 14.50),

-- Plats principaux
('Poulet Rôti', (SELECT id_categorie FROM categorie WHERE nom_categorie = 'Plat principal'), 18.00),
('Côte de Boeuf', (SELECT id_categorie FROM categorie WHERE nom_categorie = 'Plat principal'), 24.00),
('Saumon Grillé', (SELECT id_categorie FROM categorie WHERE nom_categorie = 'Plat principal'), 20.00),
('Magret de Canard', (SELECT id_categorie FROM categorie WHERE nom_categorie = 'Plat principal'), 22.50),
('Ratatouille', (SELECT id_categorie FROM categorie WHERE nom_categorie = 'Plat principal'), 17.00),

-- Desserts
('Crème Brûlée', (SELECT id_categorie FROM categorie WHERE nom_categorie = 'Dessert'), 7.50),
('Tiramisu', (SELECT id_categorie FROM categorie WHERE nom_categorie = 'Dessert'), 6.50),
('Profiteroles', (SELECT id_categorie FROM categorie WHERE nom_categorie = 'Dessert'), 8.00),
('Cheesecake', (SELECT id_categorie FROM categorie WHERE nom_categorie = 'Dessert'), 7.00),
('Panna Cotta', (SELECT id_categorie FROM categorie WHERE nom_categorie = 'Dessert'), 6.50),

-- Boissons
('Coca-Cola', (SELECT id_categorie FROM categorie WHERE nom_categorie = 'Boisson'), 3.00),
('Eau Minérale', (SELECT id_categorie FROM categorie WHERE nom_categorie = 'Boisson'), 2.50),
('Jus d\'Orange', (SELECT id_categorie FROM categorie WHERE nom_categorie = 'Boisson'), 3.50),
('Café Espresso', (SELECT id_categorie FROM categorie WHERE nom_categorie = 'Boisson'), 2.00),
('Thé Vert', (SELECT id_categorie FROM categorie WHERE nom_categorie = 'Boisson'), 2.50);


-- Données pour la table `commande`
INSERT INTO commande (id_client, date_commande, total) VALUES
((SELECT client.id_client FROM client WHERE client.email = 'lucie.martin@example.com'), '2023-09-16', 55.75),
((SELECT client.id_client FROM client WHERE client.email = 'julien.bernard@example.com'), '2023-09-17', 37.50),
((SELECT client.id_client FROM client WHERE client.email = 'emilie.kuong@example.com'), '2023-09-18', 45.25),
((SELECT client.id_client FROM client WHERE client.email = 'sophie.petit@example.com'), '2023-09-19', 50.00),
((SELECT client.id_client FROM client WHERE client.email = 'christophe.robert@example.com'), '2023-09-20', 42.75),
((SELECT client.id_client FROM client WHERE client.email = 'lucie.martin@example.com'), '2023-09-21', 52.00),
((SELECT client.id_client FROM client WHERE client.email = 'julien.bernard@example.com'), '2023-09-22', 41.75),
((SELECT client.id_client FROM client WHERE client.email = 'emilie.kuong@example.com'), '2023-09-23', 46.50),
((SELECT client.id_client FROM client WHERE client.email = 'sophie.petit@example.com'), '2023-09-24', 55.25),
((SELECT client.id_client FROM client WHERE client.email = 'christophe.robert@example.com'), '2023-09-25', 47.00);

-- Données pour la table `ligne` correspondant aux commandes supplémentaires
-- Correction: la table s'appelle ligne_commande et les colonnes sont (id_commande, id_plat, quantite).
INSERT INTO ligne_commande (id_commande, id_plat, quantite) VALUES
-- Commande du 2023-09-16 par Lucie Martin
((SELECT commande.id_commande FROM commande WHERE commande.date_commande = '2023-09-16' AND commande.id_client = (SELECT client.id_client FROM client WHERE client.email = 'lucie.martin@example.com')),
 (SELECT plat.id_plat FROM plat WHERE plat.nom_plat = 'Salade César'), 1),
((SELECT commande.id_commande FROM commande WHERE commande.date_commande = '2023-09-16' AND commande.id_client = (SELECT client.id_client FROM client WHERE client.email = 'lucie.martin@example.com')),
 (SELECT plat.id_plat FROM plat WHERE plat.nom_plat = 'Pizza Quatre Fromages'), 1),
((SELECT commande.id_commande FROM commande WHERE commande.date_commande = '2023-09-16' AND commande.id_client = (SELECT client.id_client FROM client WHERE client.email = 'lucie.martin@example.com')),
 (SELECT plat.id_plat FROM plat WHERE plat.nom_plat = 'Tagliatelles au Saumon'), 1),
((SELECT commande.id_commande FROM commande WHERE commande.date_commande = '2023-09-16' AND commande.id_client = (SELECT client.id_client FROM client WHERE client.email = 'lucie.martin@example.com')),
 (SELECT plat.id_plat FROM plat WHERE plat.nom_plat = 'Crème Brûlée'), 2),

-- Commande du 2023-09-17 par Julien Bernard
((SELECT commande.id_commande FROM commande WHERE commande.date_commande = '2023-09-17' AND commande.id_client = (SELECT client.id_client FROM client WHERE client.email = 'julien.bernard@example.com')),
 (SELECT plat.id_plat FROM plat WHERE plat.nom_plat = 'Pizza Hawaïenne'), 1),
((SELECT commande.id_commande FROM commande WHERE commande.date_commande = '2023-09-17' AND commande.id_client = (SELECT client.id_client FROM client WHERE client.email = 'julien.bernard@example.com')),
 (SELECT plat.id_plat FROM plat WHERE plat.nom_plat = 'Spaghetti Carbonara'), 2),
((SELECT commande.id_commande FROM commande WHERE commande.date_commande = '2023-09-17' AND commande.id_client = (SELECT client.id_client FROM client WHERE client.email = 'julien.bernard@example.com')),
 (SELECT plat.id_plat FROM plat WHERE plat.nom_plat = 'Salade César'), 1),
((SELECT commande.id_commande FROM commande WHERE commande.date_commande = '2023-09-17' AND commande.id_client = (SELECT client.id_client FROM client WHERE client.email = 'julien.bernard@example.com')),
 (SELECT plat.id_plat FROM plat WHERE plat.nom_plat = 'Thé Vert'), 3),

-- Commande du 2023-09-18 par Émilie Kuong
((SELECT commande.id_commande FROM commande WHERE commande.date_commande = '2023-09-18' AND commande.id_client = (SELECT client.id_client FROM client WHERE client.email = 'emilie.kuong@example.com')),
 (SELECT plat.id_plat FROM plat WHERE plat.nom_plat = 'Tagliatelles au Saumon'), 1),
((SELECT commande.id_commande FROM commande WHERE commande.date_commande = '2023-09-18' AND commande.id_client = (SELECT client.id_client FROM client WHERE client.email = 'emilie.kuong@example.com')),
 (SELECT plat.id_plat FROM plat WHERE plat.nom_plat = 'Raviolis aux Champignons'), 1),
((SELECT commande.id_commande FROM commande WHERE commande.date_commande = '2023-09-18' AND commande.id_client = (SELECT client.id_client FROM client WHERE client.email = 'emilie.kuong@example.com')),
 (SELECT plat.id_plat FROM plat WHERE plat.nom_plat = 'Poulet Rôti'), 2),
((SELECT commande.id_commande FROM commande WHERE commande.date_commande = '2023-09-18' AND commande.id_client = (SELECT client.id_client FROM client WHERE client.email = 'emilie.kuong@example.com')),
 (SELECT plat.id_plat FROM plat WHERE plat.nom_plat = 'Coca-Cola'), 2),

-- Commande du 2023-09-19 par Sophie Petit
((SELECT commande.id_commande FROM commande WHERE commande.date_commande = '2023-09-19' AND commande.id_client = (SELECT client.id_client FROM client WHERE client.email = 'sophie.petit@example.com')),
 (SELECT plat.id_plat FROM plat WHERE plat.nom_plat = 'Cheeseburger'), 2),
((SELECT commande.id_commande FROM commande WHERE commande.date_commande = '2023-09-19' AND commande.id_client = (SELECT client.id_client FROM client WHERE client.email = 'sophie.petit@example.com')),
 (SELECT plat.id_plat FROM plat WHERE plat.nom_plat = 'Tiramisu'), 1),
((SELECT commande.id_commande FROM commande WHERE commande.date_commande = '2023-09-19' AND commande.id_client = (SELECT client.id_client FROM client WHERE client.email = 'sophie.petit@example.com')),
 (SELECT plat.id_plat FROM plat WHERE plat.nom_plat = 'Pizza Végétarienne'), 1),
((SELECT commande.id_commande FROM commande WHERE commande.date_commande = '2023-09-19' AND commande.id_client = (SELECT client.id_client FROM client WHERE client.email = 'sophie.petit@example.com')),
 (SELECT plat.id_plat FROM plat WHERE plat.nom_plat = 'Eau Minérale'), 3),

-- Commande du 2023-09-20 par Christophe Robert
((SELECT commande.id_commande FROM commande WHERE commande.date_commande = '2023-09-20' AND commande.id_client = (SELECT client.id_client FROM client WHERE client.email = 'christophe.robert@example.com')),
 (SELECT plat.id_plat FROM plat WHERE plat.nom_plat = 'Pizza Pepperoni'), 1),
((SELECT commande.id_commande FROM commande WHERE commande.date_commande = '2023-09-20' AND commande.id_client = (SELECT client.id_client FROM client WHERE client.email = 'christophe.robert@example.com')),
 (SELECT plat.id_plat FROM plat WHERE plat.nom_plat = 'Poulet Rôti'), 1),
((SELECT commande.id_commande FROM commande WHERE commande.date_commande = '2023-09-20' AND commande.id_client = (SELECT client.id_client FROM client WHERE client.email = 'christophe.robert@example.com')),
 (SELECT plat.id_plat FROM plat WHERE plat.nom_plat = 'Lasagnes Bolognese'), 1),
((SELECT commande.id_commande FROM commande WHERE commande.date_commande = '2023-09-20' AND commande.id_client = (SELECT client.id_client FROM client WHERE client.email = 'christophe.robert@example.com')),
 (SELECT plat.id_plat FROM plat WHERE plat.nom_plat = 'Café Espresso'), 2),

-- Commande du 2023-09-21 par Lucie Martin
((SELECT commande.id_commande FROM commande WHERE commande.date_commande = '2023-09-21' AND commande.id_client = (SELECT client.id_client FROM client WHERE client.email = 'lucie.martin@example.com')),
 (SELECT plat.id_plat FROM plat WHERE plat.nom_plat = 'Bruschetta'), 1),
((SELECT commande.id_commande FROM commande WHERE commande.date_commande = '2023-09-21' AND commande.id_client = (SELECT client.id_client FROM client WHERE client.email = 'lucie.martin@example.com')),
 (SELECT plat.id_plat FROM plat WHERE plat.nom_plat = 'Pizza Margherita'), 1),
((SELECT commande.id_commande FROM commande WHERE commande.date_commande = '2023-09-21' AND commande.id_client = (SELECT client.id_client FROM client WHERE client.email = 'lucie.martin@example.com')),
 (SELECT plat.id_plat FROM plat WHERE plat.nom_plat = 'Penne Arrabiata'), 1),
((SELECT commande.id_commande FROM commande WHERE commande.date_commande = '2023-09-21' AND commande.id_client = (SELECT client.id_client FROM client WHERE client.email = 'lucie.martin@example.com')),
 (SELECT plat.id_plat FROM plat WHERE plat.nom_plat = 'Cheesecake'), 2),

-- Commande du 2023-09-22 par Julien Bernard
((SELECT commande.id_commande FROM commande WHERE commande.date_commande = '2023-09-22' AND commande.id_client = (SELECT client.id_client FROM client WHERE client.email = 'julien.bernard@example.com')),
 (SELECT plat.id_plat FROM plat WHERE plat.nom_plat = 'Tartare de saumon'), 1),
((SELECT commande.id_commande FROM commande WHERE commande.date_commande = '2023-09-22' AND commande.id_client = (SELECT client.id_client FROM client WHERE client.email = 'julien.bernard@example.com')),
 (SELECT plat.id_plat FROM plat WHERE plat.nom_plat = 'Pizza Quatre Fromages'), 1),
((SELECT commande.id_commande FROM commande WHERE commande.date_commande = '2023-09-22' AND commande.id_client = (SELECT client.id_client FROM client WHERE client.email = 'julien.bernard@example.com')),
 (SELECT plat.id_plat FROM plat WHERE plat.nom_plat = 'Spaghetti Carbonara'), 1),
((SELECT commande.id_commande FROM commande WHERE commande.date_commande = '2023-09-22' AND commande.id_client = (SELECT client.id_client FROM client WHERE client.email = 'julien.bernard@example.com')),
 (SELECT plat.id_plat FROM plat WHERE plat.nom_plat = 'Panna Cotta'), 2),

-- Commande du 2023-09-23 par Émilie Kuong
((SELECT commande.id_commande FROM commande WHERE commande.date_commande = '2023-09-23' AND commande.id_client = (SELECT client.id_client FROM client WHERE client.email = 'emilie.kuong@example.com')),
 (SELECT plat.id_plat FROM plat WHERE plat.nom_plat = 'Carpaccio de boeuf'), 1),
((SELECT commande.id_commande FROM commande WHERE commande.date_commande = '2023-09-23' AND commande.id_client = (SELECT client.id_client FROM client WHERE client.email = 'emilie.kuong@example.com')),
 (SELECT plat.id_plat FROM plat WHERE plat.nom_plat = 'Pizza Pepperoni'), 1),
((SELECT commande.id_commande FROM commande WHERE commande.date_commande = '2023-09-23' AND commande.id_client = (SELECT client.id_client FROM client WHERE client.email = 'emilie.kuong@example.com')),
 (SELECT plat.id_plat FROM plat WHERE plat.nom_plat = 'Tagliatelles au Saumon'), 1),
((SELECT commande.id_commande FROM commande WHERE commande.date_commande = '2023-09-23' AND commande.id_client = (SELECT client.id_client FROM client WHERE client.email = 'emilie.kuong@example.com')),
 (SELECT plat.id_plat FROM plat WHERE plat.nom_plat = 'Profiteroles'), 2),

-- Commande du 2023-09-24 par Sophie Petit
((SELECT commande.id_commande FROM commande WHERE commande.date_commande = '2023-09-24' AND commande.id_client = (SELECT client.id_client FROM client WHERE client.email = 'sophie.petit@example.com')),
 (SELECT plat.id_plat FROM plat WHERE plat.nom_plat = 'Tartare de saumon'), 1),
((SELECT commande.id_commande FROM commande WHERE commande.date_commande = '2023-09-24' AND commande.id_client = (SELECT client.id_client FROM client WHERE client.email = 'sophie.petit@example.com')),
 (SELECT plat.id_plat FROM plat WHERE plat.nom_plat = 'Pizza Végétarienne'), 1),
((SELECT commande.id_commande FROM commande WHERE commande.date_commande = '2023-09-24' AND commande.id_client = (SELECT client.id_client FROM client WHERE client.email = 'sophie.petit@example.com')),
 (SELECT plat.id_plat FROM plat WHERE plat.nom_plat = 'Raviolis aux Champignons'), 1),
((SELECT commande.id_commande FROM commande WHERE commande.date_commande = '2023-09-24' AND commande.id_client = (SELECT client.id_client FROM client WHERE client.email = 'sophie.petit@example.com')),
 (SELECT plat.id_plat FROM plat WHERE plat.nom_plat = 'Tiramisu'), 2),

-- Commande du 2023-09-25 par Christophe Robert
((SELECT commande.id_commande FROM commande WHERE commande.date_commande = '2023-09-25' AND commande.id_client = (SELECT client.id_client FROM client WHERE client.email = 'christophe.robert@example.com')),
 (SELECT plat.id_plat FROM plat WHERE plat.nom_plat = 'Soupe à l\'oignon'), 1),
((SELECT commande.id_commande FROM commande WHERE commande.date_commande = '2023-09-25' AND commande.id_client = (SELECT client.id_client FROM client WHERE client.email = 'christophe.robert@example.com')),
 (SELECT plat.id_plat FROM plat WHERE plat.nom_plat = 'Pizza Hawaïenne'), 1),
((SELECT commande.id_commande FROM commande WHERE commande.date_commande = '2023-09-25' AND commande.id_client = (SELECT client.id_client FROM client WHERE client.email = 'christophe.robert@example.com')),
 (SELECT plat.id_plat FROM plat WHERE plat.nom_plat = 'Lasagnes Bolognese'), 1),
((SELECT commande.id_commande FROM commande WHERE commande.date_commande = '2023-09-25' AND commande.id_client = (SELECT client.id_client FROM client WHERE client.email = 'christophe.robert@example.com')),
 (SELECT plat.id_plat FROM plat WHERE plat.nom_plat = 'Cheesecake'), 2);
