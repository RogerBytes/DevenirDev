# 03 - Roadmap sécurité

Cette roadmap liste les mesures de sécurité à ajouter au fil de la croissance de l'infrastructure, en trois paliers progressifs (court, moyen, long terme), suivis d'un dernier palier réservé à un scénario extrême : si je deviens un acteur vraiment important, avec des informations de milliardaires ou de dignitaires de premier plan, avec le risque d'une attaque venant d'un État hostile comme la Russie ou la Chine.

## Court terme (dès que l'infra grossit, avant le stade "risque étatique")

1. **Lynis** — audit de durcissement système, en complément de RKhunter.
2. **chkrootkit** — complément à RKhunter, cron à un horaire différent.
3. **HashiCorp Vault** — gestion centralisée des secrets, avec chiffrement au repos et journalisation des accès.
4. **Grafana Loki + règles d'alerting** (Grafana Alerting) — centralisation des logs avec de vraies règles de corrélation entre sources, pas juste du stockage. À déployer une fois l'API professionnelle en ligne.

## Moyen terme (infra avec plusieurs services sensibles, montée en charge)

1. **Segmentation réseau par niveau de sensibilité** — réseaux Docker séparés par sensibilité (ex: Vaultwarden isolé des autres services) plutôt qu'un seul réseau partagé, avec règles explicites entre eux.
2. **Détection comportementale** — Falco en premier (plus léger à déployer que Wazuh), pour repérer les comportements anormaux au-delà des signatures connues de CrowdSec/RKhunter.
3. **Rotation automatique des secrets** — une fois Vault en place, activer la rotation planifiée plutôt qu'une gestion manuelle.

## Long terme (si l'activité devient vraiment conséquente, CA ou données sensibles en jeu)

1. **Pentest externe professionnel** — regard extérieur par un tiers, à faire une fois l'infra stable et l'investissement justifié ; pour du code perso, un audit spécialisé type crypto/DeFi.
2. **Wazuh** (SIEM complet avec agents), si Falco seul ne suffit plus.
3. **Formalisation d'un post-mortem** après chaque test ou incident réel — documentation structurée de ce qui s'est passé et pourquoi, au-delà du simple "ça a marché".

## Si risque d'attaque étatique avéré (milliardaires, dignitaires, État hostile)

1. **Air-gap physique** — isoler les données vraiment critiques sur un support jamais connecté à internet, transfert uniquement par clé USB dédiée.
2. **Clé matérielle (HSM/Yubikey)** — remplacer la passphrase SSH par une clé physique, pour que la clé ne soit jamais exposée même si le système est compromis.
3. **Isolation renforcée des conteneurs** — AppArmor/SELinux en mode strict, ou changer de runtime (gVisor/Kata Containers) pour une vraie barrière noyau entre conteneurs et hôte.
4. **Accès réseau encore plus restreint** — VPN WireGuard dédié entre toi et le VPS, éventuellement port knocking avant même d'autoriser une tentative SSH.
5. **Diversification des fournisseurs** — répartir entre plusieurs hébergeurs/juridictions indépendantes, pour qu'aucun point unique (OVH, Cloudflare) ne concentre tout le risque.

Le principe général à retenir : chaque point augmente le coût/temps nécessaire pour te compromettre, sans garantir l'impossibilité absolue — seul l'air-gap (point 11) est une vraie limite dure.

## Faut-il mettre cela en place maintenant ?

**Non, pas pour l'instant.** Le niveau de menace actuel sur ton infrastructure ne justifie pas un tel investissement humain, technique et financier, en particulier pour les points 11 à 15.

L'architecture actuelle est déjà protégée contre les attaques opportunistes et automatisées, et les points 1 à 10 forment une progression naturelle à mesure que l'activité grossit — chacun a une justification indépendante du risque étatique. Les points 11 à 15 restent, eux, réservés au scénario spécifique d'un adversaire étatique ciblé, à activer uniquement si la valeur des données hébergées augmente significativement dans cette direction précise.
