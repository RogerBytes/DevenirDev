# 06 - Network Firewall CloudFlare et Fail2Ban

Pour info Caddy journalise déjà les vraies IP

## À faire

Les grandes étapes pour que Fail2Ban intéragisse avec le pare-feu de CloudFlare ()

1. **Créer un jeton d'accès sécurisé (Token API)** sur ton compte Cloudflare, avec les droits spécifiques pour modifier les règles de pare-feu de ton domaine.
2. **Configurer l'action Cloudflare dans Fail2ban** (dans le dossier `action.d/`) en lui indiquant ton jeton secret pour qu'il ait le droit de parler à Cloudflare.
3. **Créer une règle de surveillance (Jail) dans Fail2ban** qui va analyser les logs de Caddy et déclencher l'action Cloudflare (l'appel API) au lieu du pare-feu local du VPS dès qu'un comportement suspect est détecté.
4. **Tester et valider**, en vérifiant dans les logs de Fail2ban que l'appel API part bien, et en allant voir dans l'interface de Cloudflare si l'adresse IP du robot y a bien été ajoutée automatiquement.
