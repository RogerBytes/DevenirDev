# Dictionnaire de données

## Premier jet

Dans la conception d'une application, la première chose que l'on fait est le dictionnaire des données, dans un premier temps on doit laisser la colonne `Contraintes` vide et ne pas s'occuper des FK dans les tables, on se contente de faire du merise.

|     | **Code**           | **Type, longueur** | **Table**            | **Contraintes** | **Descriptif**                                          |
| :-: | ------------------ | ------------------ | -------------------- | --------------- | ------------------------------------------------------- |
| 🔴  | `user_id`          | UUID               | user                 |                 | Identifiant unique de l'utilisateur                     |
| 🔴  | `email`            | VARCHAR(255)       | user                 |                 | Adresse email de l'utilisateur                          |
| 🔴  | `password_hash`    | VARCHAR(255)       | user                 |                 | Hash du mot de passe (BCrypt/Argon2)                    |
| 🔴  | `first_name`       | VARCHAR(100)       | user                 |                 | Prénom de l'utilisateur                                 |
| 🔴  | `last_name`        | VARCHAR(100)       | user                 |                 | Nom de l'utilisateur                                    |
| 🔴  | `phone`            | VARCHAR(20)        | user                 |                 | Numéro de téléphone                                     |
| 🔴  | `last_login`       | DATETIME           | user                 |                 | Date et heure du dernier login                          |
| 🔴  | `is_active`        | BOOLEAN            | user                 |                 | Statut actif/inactif de l'utilisateur                   |
| 🔴  | `created_at`       | DATETIME           | user                 |                 | Date de création du compte                              |
| 🔴  | `updated_at`       | DATETIME           | user                 |                 | Date de dernière mise à jour                            |
| 🟠  | `role_id`          | INT                | roles                |                 | Identifiant unique du rôle                              |
| 🟠  | `name`             | VARCHAR(50)        | roles                |                 | Nom du rôle (ex: "Auditeur", "Admin")                   |
| 🟠  | `description`      | TEXT               | roles                |                 | Description des permissions associées au rôle           |
| 🟠  | `permissions`      | JSON               | roles                |                 | Liste des permissions (ex: ["audit:create"])            |
| 🔵  | `company_id`       | UUID               | companies            |                 | Identifiant unique de l'entreprise                      |
| 🔵  | `name`             | VARCHAR(255)       | companies            |                 | Nom de l'entreprise                                     |
| 🔵  | `sector`           | VARCHAR(100)       | companies            |                 | Secteur d'activité                                      |
| 🔵  | `address`          | TEXT               | companies            |                 | Adresse complète (anonymisée après audit)               |
| 🔵  | `contact_email`    | VARCHAR(255)       | companies            |                 | Email de contact principal                              |
| 🔵  | `contact_phone`    | VARCHAR(20)        | companies            |                 | Téléphone de contact                                    |
| 🔵  | `created_at`       | DATETIME           | companies            |                 | Date de création du dossier entreprise                  |
| 🔵  | `updated_at`       | DATETIME           | companies            |                 | Date de dernière mise à jour                            |
| 🟣  | `audit_id`         | UUID               | audits               |                 | Identifiant unique de l'audit                           |
| 🟣  | `status`           | ENUM               | audits               |                 | Statut: "En cours", "Terminé", "Archivé", "Annulé"      |
| 🟣  | `start_date`       | DATE               | audits               |                 | Date de début de l'audit                                |
| 🟣  | `end_date`         | DATE               | audits               |                 | Date de fin prévue de l'audit                           |
| 🟣  | `scope`            | TEXT               | audits               |                 | Portée de l'audit                                       |
| 🟣  | `notes`            | TEXT               | audits               |                 | Notes générales sur l'audit                             |
| 🟣  | `created_at`       | DATETIME           | audits               |                 | Date de création de l'audit                             |
| 🟣  | `updated_at`       | DATETIME           | audits               |                 | Date de dernière mise à jour                            |
| 🟢  | `observation_id`   | UUID               | audit_observations   |                 | Identifiant unique de l'observation                     |
| 🟢  | `type`             | ENUM               | audit_observations   |                 | Type: "Critique", "Mineure", "Information"              |
| 🟢  | `description`      | TEXT               | audit_observations   |                 | Description détaillée de l'observation                  |
| 🟢  | `location`         | VARCHAR(100)       | audit_observations   |                 | Emplacement (ex: "Serveur 1", "Poste de travail")       |
| 🟢  | `recommendation`   | TEXT               | audit_observations   |                 | Recommandation corrective                               |
| 🟢  | `created_at`       | DATETIME           | audit_observations   |                 | Date de création de l'observation                       |
| 🟢  | `updated_at`       | DATETIME           | audit_observations   |                 | Date de dernière mise à jour                            |
| 🟡  | `report_id`        | UUID               | audit_reports        |                 | Identifiant unique du rapport                           |
| 🟡  | `title`            | VARCHAR(255)       | audit_reports        |                 | Titre du rapport                                        |
| 🟡  | `content`          | TEXT               | audit_reports        |                 | Contenu HTML/Markdown du rapport                        |
| 🟡  | `status`           | ENUM               | audit_reports        |                 | Statut: "Brouillon", "En révision", "Validé", "Archivé" |
| 🟡  | `validation_date`  | DATETIME           | audit_reports        |                 | Date de validation                                      |
| 🟡  | `created_at`       | DATETIME           | audit_reports        |                 | Date de création du rapport                             |
| 🟡  | `updated_at`       | DATETIME           | audit_reports        |                 | Date de dernière mise à jour                            |
| 🟤  | `certification_id` | UUID               | certifications       |                 | Identifiant unique de la certification                  |
| 🟤  | `name`             | VARCHAR(255)       | certifications       |                 | Nom de la certification                                 |
| 🟤  | `description`      | TEXT               | certifications       |                 | Description de la certification                         |
| 🟤  | `price`            | DECIMAL(10,2)      | certifications       |                 | Prix en euros                                           |
| 🟤  | `duration`         | INT                | certifications       |                 | Durée en heures                                         |
| 🟤  | `is_active`        | BOOLEAN            | certifications       |                 | Statut actif/inactif de la certification                |
| 🟤  | `created_at`       | DATETIME           | certifications       |                 | Date de création de la certification                    |
| 🟤  | `updated_at`       | DATETIME           | certifications       |                 | Date de dernière mise à jour                            |
| ⚫  | `order_id`         | UUID               | certification_orders |                 | Identifiant unique de la commande                       |
| ⚫  | `status`           | ENUM               | certification_orders |                 | Statut: "Payé", "En cours", "Terminé", "Annulé"         |
| ⚫  | `payment_date`     | DATETIME           | certification_orders |                 | Date de paiement                                        |
| ⚫  | `expiration_date`  | DATETIME           | certification_orders |                 | Date d'expiration de l'accès                            |
| ⚫  | `created_at`       | DATETIME           | certification_orders |                 | Date de création de la commande                         |
| ⚫  | `updated_at`       | DATETIME           | certification_orders |                 | Date de dernière mise à jour                            |
| ⚪  | `document_id`      | UUID               | documents            |                 | Identifiant unique du document                          |
| ⚪  | `title`            | VARCHAR(255)       | documents            |                 | Titre du document                                       |
| ⚪  | `type`             | ENUM               | documents            |                 | Type: "PDF", "Word", "Image", "Autre"                   |
| ⚪  | `path`             | VARCHAR(512)       | documents            |                 | Chemin de stockage                                      |
| ⚪  | `size`             | INT                | documents            |                 | Taille en octets                                        |
| ⚪  | `is_public`        | BOOLEAN            | documents            |                 | Visible par le grand public                             |
| ⚪  | `created_at`       | DATETIME           | documents            |                 | Date de téléchargement                                  |
| ⚪  | `updated_at`       | DATETIME           | documents            |                 | Date de dernière mise à jour                            |
| 🔵  | `content_id`       | UUID               | educational_content  |                 | Identifiant unique du contenu                           |
| 🔵  | `title`            | VARCHAR(255)       | educational_content  |                 | Titre du contenu                                        |
| 🔵  | `description`      | TEXT               | educational_content  |                 | Description courte                                      |
| 🔵  | `content_type`     | ENUM               | educational_content  |                 | Type: "Article", "Vidéo", "Quiz", "Tutoriel"            |
| 🔵  | `is_published`     | BOOLEAN            | educational_content  |                 | Statut de publication                                   |
| 🔵  | `created_at`       | DATETIME           | educational_content  |                 | Date de création                                        |
| 🔵  | `updated_at`       | DATETIME           | educational_content  |                 | Date de dernière mise à jour                            |
| 🟣  | `category_id`      | UUID               | categories           |                 | Identifiant unique de la catégorie                      |
| 🟣  | `name`             | VARCHAR(100)       | categories           |                 | Nom de la catégorie                                     |
| 🟣  | `description`      | TEXT               | categories           |                 | Description de la catégorie                             |
| 🟣  | `created_at`       | DATETIME           | categories           |                 | Date de création                                        |
| 🟤  | `invoice_id`       | UUID               | invoices             |                 | Identifiant unique de la facture                        |
| 🟤  | `amount`           | DECIMAL(10,2)      | invoices             |                 | Montant total en euros                                  |
| 🟤  | `status`           | ENUM               | invoices             |                 | Statut: "Émise", "Payée", "Annulée"                     |
| 🟤  | `due_date`         | DATE               | invoices             |                 | Date d'échéance                                         |
| 🟤  | `payment_date`     | DATETIME           | invoices             |                 | Date de paiement                                        |
| 🟤  | `created_at`       | DATETIME           | invoices             |                 | Date de création de la facture                          |
| ⚫  | `assistant_id`     | UUID               | ai_assistant         |                 | Identifiant unique de l'assistant                       |
| ⚫  | `model_version`    | VARCHAR(50)        | ai_assistant         |                 | Version du modèle de langage                            |
| ⚫  | `last_trained`     | DATETIME           | ai_assistant         |                 | Date de dernière mise à jour du modèle                  |
| ⚫  | `usage_stats`      | JSON               | ai_assistant         |                 | Statistiques d'utilisation                              |
| ⚪  | `history_id`       | UUID               | ai_assistant_history |                 | Identifiant unique de l'historique                      |
| ⚪  | `prompt`           | TEXT               | ai_assistant_history |                 | Requête envoyée à l'assistant                           |
| ⚪  | `response`         | TEXT               | ai_assistant_history |                 | Réponse générée par l'assistant                         |
| ⚪  | `timestamp`        | DATETIME           | ai_assistant_history |                 | Date et heure de l'interaction                          |

## Version finale

|     | **Code**           | **Type, longueur** | **Table**            | **Contraintes**               | **Descriptif**                                               |
| :-: | ------------------ | ------------------ | -------------------- | ----------------------------- | ------------------------------------------------------------ |
| 🔴  | `user_id`          | UUID               | user                 | PK, NOT NULL                  | Identifiant unique de l'utilisateur                          |
| 🔴  | `email`            | VARCHAR(255)       | user                 | UNIQUE, NOT NULL              | Adresse email de l'utilisateur                               |
| 🔴  | `password_hash`    | VARCHAR(255)       | user                 | NOT NULL                      | Hash du mot de passe (BCrypt/Argon2)                         |
| 🔴  | `first_name`       | VARCHAR(100)       | user                 | NOT NULL                      | Prénom de l'utilisateur                                      |
| 🔴  | `last_name`        | VARCHAR(100)       | user                 | NOT NULL                      | Nom de l'utilisateur                                         |
| 🔴  | `phone`            | VARCHAR(20)        | user                 | Optional                      | Numéro de téléphone                                          |
| 🔴  | `role_id`          | INT                | user                 | FK, NOT NULL                  | Rôle de l'utilisateur (référence à `Roles`)                  |
| 🔴  | `company_id`       | UUID               | user                 | FK (NULL si interne)          | ID de l'entreprise cliente (pour auditeurs/clients)          |
| 🔴  | `last_login`       | DATETIME           | user                 | Optional                      | Date et heure du dernier login                               |
| 🔴  | `is_active`        | BOOLEAN            | user                 | DEFAULT TRUE                  | Statut actif/inactif de l'utilisateur                        |
| 🔴  | `created_at`       | DATETIME           | user                 | NOT NULL, DEFAULT NOW()       | Date de création du compte                                   |
| 🔴  | `updated_at`       | DATETIME           | user                 | NOT NULL, DEFAULT NOW()       | Date de dernière mise à jour                                 |
| 🟠  | `role_id`          | INT                | roles                | PK, NOT NULL                  | Identifiant unique du rôle                                   |
| 🟠  | `name`             | VARCHAR(50)        | roles                | UNIQUE, NOT NULL              | Nom du rôle (ex: "Auditeur", "Admin")                        |
| 🟠  | `description`      | TEXT               | roles                | Optional                      | Description des permissions associées au rôle                |
| 🟠  | `permissions`      | JSON               | roles                | NOT NULL                      | Liste des permissions (ex: ["audit:create"])                 |
| 🔵  | `company_id`       | UUID               | companies            | PK, NOT NULL                  | Identifiant unique de l'entreprise                           |
| 🔵  | `name`             | VARCHAR(255)       | companies            | NOT NULL                      | Nom de l'entreprise                                          |
| 🔵  | `sector`           | VARCHAR(100)       | companies            | Optional                      | Secteur d'activité                                           |
| 🔵  | `address`          | TEXT               | companies            | Optional                      | Adresse complète (anonymisée après audit)                    |
| 🔵  | `contact_email`    | VARCHAR(255)       | companies            | Optional                      | Email de contact principal                                   |
| 🔵  | `contact_phone`    | VARCHAR(20)        | companies            | Optional                      | Téléphone de contact                                         |
| 🔵  | `created_at`       | DATETIME           | companies            | NOT NULL, DEFAULT NOW()       | Date de création du dossier entreprise                       |
| 🔵  | `updated_at`       | DATETIME           | companies            | NOT NULL, DEFAULT NOW()       | Date de dernière mise à jour                                 |
| 🟣  | `audit_id`         | UUID               | audits               | PK, NOT NULL                  | Identifiant unique de l'audit                                |
| 🟣  | `company_id`       | UUID               | audits               | FK, NOT NULL                  | ID de l'entreprise auditée                                   |
| 🟣  | `auditor_id`       | UUID               | audits               | FK, NOT NULL                  | ID de l'auditeur assigné                                     |
| 🟣  | `status`           | ENUM               | audits               | NOT NULL, DEFAULT "En cours"  | Statut: "En cours", "Terminé", "Archivé", "Annulé"           |
| 🟣  | `start_date`       | DATE               | audits               | NOT NULL                      | Date de début de l'audit                                     |
| 🟣  | `end_date`         | DATE               | audits               | Optional                      | Date de fin prévue de l'audit                                |
| 🟣  | `scope`            | TEXT               | audits               | NOT NULL                      | Portée de l'audit                                            |
| 🟣  | `notes`            | TEXT               | audits               | Optional                      | Notes générales sur l'audit                                  |
| 🟣  | `created_at`       | DATETIME           | audits               | NOT NULL, DEFAULT NOW()       | Date de création de l'audit                                  |
| 🟣  | `updated_at`       | DATETIME           | audits               | NOT NULL, DEFAULT NOW()       | Date de dernière mise à jour                                 |
| 🟢  | `observation_id`   | UUID               | audit_observations   | PK, NOT NULL                  | Identifiant unique de l'observation                          |
| 🟢  | `audit_id`         | UUID               | audit_observations   | FK, NOT NULL                  | ID de l'audit associé                                        |
| 🟢  | `type`             | ENUM               | audit_observations   | NOT NULL                      | Type: "Critique", "Mineure", "Information"                   |
| 🟢  | `description`      | TEXT               | audit_observations   | NOT NULL                      | Description détaillée de l'observation                       |
| 🟢  | `location`         | VARCHAR(100)       | audit_observations   | Optional                      | Emplacement (ex: "Serveur 1", "Poste de travail")            |
| 🟢  | `recommendation`   | TEXT               | audit_observations   | Optional                      | Recommandation corrective                                    |
| 🟢  | `document_id`      | UUID               | audit_observations   | FK (NULL si aucun document)   | ID du document joint                                         |
| 🟢  | `created_at`       | DATETIME           | audit_observations   | NOT NULL, DEFAULT NOW()       | Date de création de l'observation                            |
| 🟢  | `updated_at`       | DATETIME           | audit_observations   | NOT NULL, DEFAULT NOW()       | Date de dernière mise à jour                                 |
| 🟡  | `report_id`        | UUID               | audit_reports        | PK, NOT NULL                  | Identifiant unique du rapport                                |
| 🟡  | `audit_id`         | UUID               | audit_reports        | FK, NOT NULL                  | ID de l'audit associé                                        |
| 🟡  | `title`            | VARCHAR(255)       | audit_reports        | NOT NULL                      | Titre du rapport                                             |
| 🟡  | `content`          | TEXT               | audit_reports        | NOT NULL                      | Contenu HTML/Markdown du rapport                             |
| 🟡  | `status`           | ENUM               | audit_reports        | NOT NULL, DEFAULT "Brouillon" | Statut: "Brouillon", "En révision", "Validé", "Archivé"      |
| 🟡  | `validated_by`     | UUID               | audit_reports        | FK (NULL si non validé)       | ID du responsable ayant validé le rapport                    |
| 🟡  | `validation_date`  | DATETIME           | audit_reports        | Optional                      | Date de validation                                           |
| 🟡  | `created_at`       | DATETIME           | audit_reports        | NOT NULL, DEFAULT NOW()       | Date de création du rapport                                  |
| 🟡  | `updated_at`       | DATETIME           | audit_reports        | NOT NULL, DEFAULT NOW()       | Date de dernière mise à jour                                 |
| 🟤  | `certification_id` | UUID               | certifications       | PK, NOT NULL                  | Identifiant unique de la certification                       |
| 🟤  | `name`             | VARCHAR(255)       | certifications       | NOT NULL                      | Nom de la certification                                      |
| 🟤  | `description`      | TEXT               | certifications       | NOT NULL                      | Description de la certification                              |
| 🟤  | `price`            | DECIMAL(10,2)      | certifications       | NOT NULL                      | Prix en euros                                                |
| 🟤  | `duration`         | INT                | certifications       | NOT NULL                      | Durée en heures                                              |
| 🟤  | `is_active`        | BOOLEAN            | certifications       | DEFAULT TRUE                  | Statut actif/inactif de la certification                     |
| 🟤  | `created_at`       | DATETIME           | certifications       | NOT NULL, DEFAULT NOW()       | Date de création de la certification                         |
| 🟤  | `updated_at`       | DATETIME           | certifications       | NOT NULL, DEFAULT NOW()       | Date de dernière mise à jour                                 |
| ⚫  | `order_id`         | UUID               | certification_orders | PK, NOT NULL                  | Identifiant unique de la commande                            |
| ⚫  | `user_id`          | UUID               | certification_orders | FK, NOT NULL                  | ID du candidat                                               |
| ⚫  | `certification_id` | UUID               | certification_orders | FK, NOT NULL                  | ID de la certification achetée                               |
| ⚫  | `status`           | ENUM               | certification_orders | NOT NULL, DEFAULT "Payé"      | Statut: "Payé", "En cours", "Terminé", "Annulé"              |
| ⚫  | `payment_date`     | DATETIME           | certification_orders | Optional                      | Date de paiement                                             |
| ⚫  | `expiration_date`  | DATETIME           | certification_orders | Optional                      | Date d'expiration de l'accès                                 |
| ⚫  | `created_at`       | DATETIME           | certification_orders | NOT NULL, DEFAULT NOW()       | Date de création de la commande                              |
| ⚫  | `updated_at`       | DATETIME           | certification_orders | NOT NULL, DEFAULT NOW()       | Date de dernière mise à jour                                 |
| ⚪  | `document_id`      | UUID               | documents            | PK, NOT NULL                  | Identifiant unique du document                               |
| ⚪  | `title`            | VARCHAR(255)       | documents            | NOT NULL                      | Titre du document                                            |
| ⚪  | `type`             | ENUM               | documents            | NOT NULL                      | Type: "PDF", "Word", "Image", "Autre"                        |
| ⚪  | `path`             | VARCHAR(512)       | documents            | NOT NULL                      | Chemin de stockage                                           |
| ⚪  | `size`             | INT                | documents            | NOT NULL                      | Taille en octets                                             |
| ⚪  | `is_public`        | BOOLEAN            | documents            | DEFAULT FALSE                 | Visible par le grand public                                  |
| ⚪  | `created_at`       | DATETIME           | documents            | NOT NULL, DEFAULT NOW()       | Date de téléchargement                                       |
| ⚪  | `updated_at`       | DATETIME           | documents            | NOT NULL, DEFAULT NOW()       | Date de dernière mise à jour                                 |
| 🔵  | `content_id`       | UUID               | educational_content  | PK, NOT NULL                  | Identifiant unique du contenu                                |
| 🔵  | `title`            | VARCHAR(255)       | educational_content  | NOT NULL                      | Titre du contenu                                             |
| 🔵  | `description`      | TEXT               | educational_content  | Optional                      | Description courte                                           |
| 🔵  | `content_type`     | ENUM               | educational_content  | NOT NULL                      | Type: "Article", "Vidéo", "Quiz", "Tutoriel"                 |
| 🔵  | `category_id`      | UUID               | educational_content  | FK, NOT NULL                  | ID de la catégorie (référence à `Categories`)                |
| 🔵  | `is_published`     | BOOLEAN            | educational_content  | DEFAULT FALSE                 | Statut de publication                                        |
| 🔵  | `created_at`       | DATETIME           | educational_content  | NOT NULL, DEFAULT NOW()       | Date de création                                             |
| 🔵  | `updated_at`       | DATETIME           | educational_content  | NOT NULL, DEFAULT NOW()       | Date de dernière mise à jour                                 |
| 🟣  | `category_id`      | UUID               | categories           | PK, NOT NULL                  | Identifiant unique de la catégorie                           |
| 🟣  | `name`             | VARCHAR(100)       | categories           | NOT NULL                      | Nom de la catégorie                                          |
| 🟣  | `parent_id`        | UUID               | categories           | FK (NULL si racine)           | ID de la catégorie parente                                   |
| 🟣  | `description`      | TEXT               | categories           | Optional                      | Description de la catégorie                                  |
| 🟣  | `created_at`       | DATETIME           | categories           | NOT NULL, DEFAULT NOW()       | Date de création                                             |
| 🟤  | `invoice_id`       | UUID               | invoices             | PK, NOT NULL                  | Identifiant unique de la facture                             |
| 🟤  | `audit_id`         | UUID               | invoices             | FK (NULL si certification)    | ID de l'audit associé (NULL si facture de certification)     |
| 🟤  | `order_id`         | UUID               | invoices             | FK (NULL si audit)            | ID de la commande de certification (NULL si facture d'audit) |
| 🟤  | `amount`           | DECIMAL(10,2)      | invoices             | NOT NULL                      | Montant total en euros                                       |
| 🟤  | `status`           | ENUM               | invoices             | NOT NULL, DEFAULT "Émise"     | Statut: "Émise", "Payée", "Annulée"                          |
| 🟤  | `due_date`         | DATE               | invoices             | NOT NULL                      | Date d'échéance                                              |
| 🟤  | `payment_date`     | DATETIME           | invoices             | Optional                      | Date de paiement                                             |
| 🟤  | `created_at`       | DATETIME           | invoices             | NOT NULL, DEFAULT NOW()       | Date de création de la facture                               |
| ⚫  | `assistant_id`     | UUID               | ai_assistant         | PK, NOT NULL                  | Identifiant unique de l'assistant                            |
| ⚫  | `model_version`    | VARCHAR(50)        | ai_assistant         | NOT NULL                      | Version du modèle de langage                                 |
| ⚫  | `last_trained`     | DATETIME           | ai_assistant         | NOT NULL                      | Date de dernière mise à jour du modèle                       |
| ⚫  | `usage_stats`      | JSON               | ai_assistant         | NOT NULL                      | Statistiques d'utilisation                                   |
| ⚪  | `history_id`       | UUID               | ai_assistant_history | PK, NOT NULL                  | Identifiant unique de l'historique                           |
| ⚪  | `assistant_id`     | UUID               | ai_assistant_history | FK, NOT NULL                  | ID de l'assistant associé                                    |
| ⚪  | `user_id`          | UUID               | ai_assistant_history | FK, NOT NULL                  | ID de l'utilisateur ayant utilisé l'assistant                |
| ⚪  | `prompt`           | TEXT               | ai_assistant_history | NOT NULL                      | Requête envoyée à l'assistant                                |
| ⚪  | `response`         | TEXT               | ai_assistant_history | NOT NULL                      | Réponse générée par l'assistant                              |
| ⚪  | `timestamp`        | DATETIME           | ai_assistant_history | NOT NULL, DEFAULT NOW()       | Date et heure de l'interaction                               |
