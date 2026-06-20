# 06 - DevOps - à apprendre

- **Le Pipeline CI/CD** apporte les nouveaux vêtements et l'épicerie automatiquement tous les jours sans que tu n'aies rien à faire (les mises à jour de tes applications).
- **Terraform** construit la maison (le VPS).
- **Ansible** installe les meubles et l'électricité (Docker, Caddy, les répertoires).

## 1. Le Pipeline CI/CD (Le Convoyeur Automatique)

Le pipeline (Continuous Integration / Continuous Deployment), c'est **le chef d'orchestre automatisé**.

- **Son rôle :** C'est un robot (comme GitHub Actions ou GitLab CI) qui s'active dès que tu fais un `git push` sur ton code. Il va par exemple lancer des tests pour vérifier que ton application n'a pas de bug, puis, si tout est vert, il va **ordonner à Ansible ou à Docker** de déployer la nouvelle version sur ton serveur.

## 2. Terraform (L'Architecte)

Terraform sert à **créer l'infrastructure** à partir de fichiers de code (on appelle ça l' _Infrastructure as Code_ ou IaC).

- **Son rôle :** Au lieu d'aller sur le site d'OVH ou de AWS et de cliquer partout pour acheter un VPS, ouvrir des ports, et configurer un réseau, tu écris un script Terraform. Tu lances le script, et magiquement, 5 VPS et 1 base de données se créent tout seuls chez ton hébergeur.

## 3. Ansible (Le Chef de Chantier)

Ansible sert à **configurer les machines** une fois qu'elles existent.

- **Son rôle :** Une fois que Terraform a créé tes 5 VPS, ils sont totalement vides. Au lieu de te connecter en SSH sur les 5 machines une par une pour installer Docker, créer les dossiers `/opt/docker`, et copier tes fichiers, tu donnes un "Playbook" à Ansible. Il va se connecter aux 5 serveurs en même temps et installer tout ce que tu as demandé en quelques secondes.
