# 12 - CloudFlared IP

Dans Cloudflare, cela s'appelle une **Règle de contournement (Bypass)** ou une stratégie d'accès basée sur les IP.

Voici comment mettre ça en place simplement :

---

### Étape 1 : Créer l'application SSH dans le Dashboard (si ce n'est pas déjà fait)

1. Va dans ton dashboard **Zero Trust** > **Contrôle d'accès** (Access) > **Applications**.
2. Clique sur **Ajouter une application** $\rightarrow$ Choisis **Auto-hébergée (Self-hosted)**.
3. Remplis les infos :
* **Nom de l'application :** `SSH VPS`
* **Sous-domaine :** `hub.rogerbytes.com`


4. Clique sur **Suivant (Next)**.

---

### Étape 2 : Configurer la liste blanche d'IP (La stratégie)

C'est ici que la magie opère. Par défaut, si tu ne mets que tes IP, tout le reste du monde sera bloqué automatiquement.

1. Sur la page des politiques (**Policies**), donne un nom (ex: `Autoriser mes IPs`).
2. Dans la section **Action**, choisis **Bypass** (Contourner).
*(Pourquoi Bypass ? Parce que comme tu as déjà ton TOTP sur le VPS, tu veux juste que Cloudflare laisse passer le flux réseau pour ces IP spécifiques sans te demander une authentification Cloudflare en plus).*
3. Dans la section **Configurer une règle (Configure a rule)** :
* **Sélecteur :** Choisis **Plages d'IP (IP ranges)**.
* **Valeur :** Tape ton adresse IP actuelle (ou le bloc d'IP de ton choix).


4. Si tu as plusieurs IP (ex: ton IP fixe de la maison, celle du boulot), clique sur **Ajouter une condition (Add include)** et remets **IP ranges** pour la deuxième IP.

---

### Étape 3 : Verrouiller tout le reste

Pour être sûr que personne d'autre ne puisse même essayer de se connecter :

1. Juste en dessous de ta première règle, clique sur **Ajouter une stratégie (Add a policy)**.
2. Donne-lui un nom (ex: `Bloquer le reste du monde`).
3. Dans **Action**, choisis **Block** (Bloquer).
4. Dans la règle : **Include** $\rightarrow$ **Everyone** (Tout le monde).
5. Clique sur **Suivant** puis **Enregistrer**.

---

### Résultat ?

* Si tu te connectes depuis une IP de ta liste blanche : Cloudflare te laisse passer instantanément, et ton terminal te demandera ta clé SSH + ton code TOTP (la sécurité locale qu'on a configurée avant).
* Si quelqu'un essaie de se connecter depuis n'importe quelle autre IP dans le monde : Cloudflare bloque la connexion avant même qu'elle n'atteigne ton tunnel. Pas de prise de tête !