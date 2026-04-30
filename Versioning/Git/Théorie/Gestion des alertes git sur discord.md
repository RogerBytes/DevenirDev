# Gestion des alertes git sur discord

## Étape 1 : Créer le Webhook sur Discord

Le Webhook est "l'adresse de réception" que Discord va donner à GitHub pour envoyer les messages.

1. Ouvre **Discord** et va dans les **Paramètres du salon** (la roue crantée à côté du nom du salon textuel).
2. Clique sur l'onglet **Intégrations**.
3. Sélectionne **Webhooks**, puis clique sur **Nouveau Webhook**.
4. Donne-lui un nom (ex: "GitHub Bot") et choisis le salon de destination.
5. **Important :** Clique sur **Copier l'URL du webhook**.

## Étape 2 : Configurer GitHub

Maintenant, il faut dire à GitHub où envoyer les informations.

1. Va sur ton dépôt (**Repository**) sur GitHub.
2. Clique sur l'onglet **Settings** (Paramètres) en haut à droite.
3. Dans le menu de gauche, clique sur **Webhooks**.
4. Clique sur le bouton **Add webhook**.

## Étape 3 : Paramétrage du Webhook

C'est ici que la magie opère. Remplis les champs comme suit :

- **Payload URL :** Colle l'URL que tu as copiée sur Discord.
    
    > **⚠️ Astuce cruciale :** Discord utilise un format spécifique. À la fin de ton URL, ajoute `/github`.
    *Exemple :* `https://discord.com/api/webhooks/.../github`
    > 
- **Content type :** Sélectionne `application/json`.
- **Secret :** Tu peux laisser vide (sauf si tu souhaites sécuriser davantage la connexion).
- **Which events would you like to trigger this webhook?**
    - Si tu veux tout : coche `Send me everything`.
    - Si tu veux filtrer : coche `Let me select individual events` et choisis **Pushes**, **Pull Requests**, **Issues**, etc.

Clique sur **Add webhook**.

## Étape 4 : Vérification

Si tout est bien configuré, GitHub va envoyer un "Ping" de test. Une coche verte apparaîtra à côté de ton Webhook dans GitHub, et tu recevras peut-être un message de confirmation sur Discord.

Désormais, à chaque `git push`, un message structuré apparaîtra dans ton salon Discord avec :

- Le nom de l'auteur.
- Le message du commit.
- Le lien direct vers les modifications.

### 💡 Quelques conseils pour ta doc interne

- **Sécurité :** Ne partage jamais l'URL du Webhook publiquement (sinon n'importe qui peut "spammer" ton salon).
- **Bruit :** Si ton équipe est très active, évite de cocher "Everything", sinon le salon Discord deviendra illisible. Concentre-toi sur les **Pushes** et les **Pull Requests**.