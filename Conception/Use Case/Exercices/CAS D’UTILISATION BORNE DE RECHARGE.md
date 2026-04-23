# CAS D’UTILISATION BORNE DE RECHARGE

Vous devez modéliser le comportement d'une borne de recharge publique. Voici les règles de gestion :

- **L'Utilisateur (Conducteur)** peut **S'authentifier** (via une carte RFID ou une application mobile).
- Une fois authentifié, il peut **Lancer la recharge** et **Consulter l'état d'avancement** de la charge.
- Le **Technicien de maintenance** peut **Relever les compteurs** et **Effectuer un diagnostic** du système.
- Le cas d'utilisation **S'authentifier** est un prérequis obligatoire pour **Lancer la recharge**.
- Lorsqu'un utilisateur **Lance la recharge**, le système peut proposer en option l'**Envoi d'un SMS de notification** une fois la charge terminée.
- Le système communique avec un **Serveur Monétique externe** pour valider l'authentification.

Votre mission :

- Identifier les acteurs (principaux et secondaires).
- Identifier les cas d'utilisation et leurs relations (`<<include>>`, `<<extend>>`).
- Rédiger le code **PlantUML** correspondant.