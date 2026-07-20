# 01 - Utilisation Zellij

Pour utiliser zellij en persistance (très important sur mon VPS)

```bash
zellij attach -c ma-session
```

Quand tu tapes `zellij` (ou `zellij attach -c ma-session`), ton écran change et une barre verte ou grise apparaît tout en bas. C'est ton tableau de bord.

## Étape 1 : Diviser son écran (Créer des terminaux)

Au lieu d'ouvrir une deuxième fenêtre SSH, tu vas diviser ton écran actuel.

1. Appuie sur `Ctrl` + `p` (p pour _Panes_ / Vitres). Tu passes en mode "gestion des fenêtres".
2. Regarde la barre du bas, elle te donne les options.
3. Appuie sur `n` (pour _New_) : Hop, ton écran se sépare en deux verticalement. Tu as maintenant deux terminaux actifs en même temps.
4. Pour te déplacer de l'un à l'autre, utilise les flèches de ton clavier.

## Étape 2 : Le mode "Locked" (Super important !)

Parfois, tu vas vouloir utiliser un outil dans ton terminal qui utilise les mêmes raccourcis que Zellij (comme l'éditeur `nano`). Pour éviter que Zellij n'intercepte tes touches :

- Appuie sur `Ctrl` + `g`. Zellij se verrouille (_Locked_). Tu peux bosser normalement.
- Rappuie sur `Ctrl` + `g` pour le déverrouiller quand tu as fini.

## Étape 3 : Quitter en laissant tourner (Le mode détaché)

C'est LA fonction magique pour ton VPS. Tu as fini ta session pour la journée, mais tu as un script ou un conteneur qui tourne.

1. Appuie sur `Ctrl` + `o` (o pour _Session_ / Options).
2. Appuie sur `d` (pour _Detach_).
3. Zellij va se fermer et tu vas te retrouver sur le terminal classique de ton VPS.

Tu peux taper `exit` pour te déconnecter du VPS et éteindre ton PC. **Tout ce que tu faisais dans Zellij continue de tourner sur le serveur.**

## Comment se reconnecter le lendemain ?

Quand je me reconnecte en SSH sur ton VPS

```bash
zellij attach ma-session
```

L'écran reprend sa disposition.
