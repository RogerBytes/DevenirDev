# 02 - Utiliser GIT

[![Build Status](https://travis-ci.org/votre-utilisateur/votre-projet.svg?branch=master)](https://travis-ci.org/votre-utilisateur/votre-projet)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](https://opensource.org/licenses/MIT)

Git est un système de contrôle de version qui permet de suivre les modifications apportées à un ensemble de fichiers au fil du temps. Il facilite la collaboration entre les développeurs en permettant de gérer les différentes versions d'un projet et de fusionner les modifications apportées par plusieurs personnes.

---

## Commandes basiques

```bash
git init
git remote add origin <url-du-repo>
git branch -M master
touch README.md
git add --all && git commit -m "First commit"
git push -u origin master
```

Ici dans l'ordre

- `git init` initialise le repo local
- `git remote add origin <url-du-repo>` lie une branche distante (par exemple un repo github)
- `git branch -M master` on définit la branche principale qui va être utilisée
- `touch README.md` créé un readme (on ne peux par merge ni push si le dépôt est vide)
- `git add -A && git commit -m "First commit"` on selection avec `add` et on fait le commit derrière
- `git push -u origin master` on crée le lien de synchronisation entre la branche distante et la locale (cela créé la branche `master` distante), et on push sur la distante (à faire une seule fois, ensuite on utilise `git push`)

---

## Faire un Merge

On va sur la branche de destination

```bash
git switch master
```

Et ensuite on lance merge avec la branche émettrice

```bash
git merge dev
```

-> Ici, on a pull les modifications de la branche `dev` sur la branche principale `master`.

On corrige les conflits de fichiers puis on fait le add/commit/push

```bash
git add --all && git commit -m "integration du merge" && git push
```

## Forcer un reset depuis la branche distante

On peut aussi forcer le reset de la branche actuelle avec la branche émettrice.
ATTENTION ! CA EFFACE TOUT POUR CLONER la branche émettrice

```bash
git reset --hard master
```

---

## Commandes diverses

### Supprimer l'initialisation de dépôt local

Pour supprimer l'initialisation, il suffit de faire dans le même chemin:

```bash
rm -r .git
```

### Voir la branche actuelle

```bash
git branch
```

### Créer une branche

Ici pour créer une branche nommée `dev`

```bash
git branch dev
```

#### Lier ma branche au dépôt distant (créé la branche distante)

```bash
git push -u origin dev
```

### Supprimer une branche locale

```bash
git branch -D dev
```

### Supprimer une branche distante

```bash
git push origin --delete dev
```

### Nettoyer les connexions de branches locales vers distantes

A utiliser après avoir supprimé une branche distante

```bash
git fetch --prune
```

### Renommer une branche

```bash
git branch -M dev2
```

### Changer de branche

Ici on veut sauter sur une branche nommée `test`

```bash
git switch test
```

### Voir le réglage du remote

Cette commande permet de voir le référentiels des associations du depot local vers un depot distant :

```bash
git remote -v
```

### Lister les branches distantes

```bash
git branch -r
```

### Lister les branches distantes et locales

```bash
git branch -a
```

### Réinitialiser le remote

Si vous vous trompez dans le nom d'org de dépôt (ou autre) faites :

```bash
git remote remove origin
```

Et recommencez le remote add suivi du push --set-upstream

## Récupérer toutes les branches et les pull distantes incluses

Pour récupérer toutes les branches, s'il n'y a qu'un seul remote et idéalement pour un repo perso (s'il y a 500 branches il va tous les télécharger)

```bash
git fetch --all

current_branch=$(git branch --show-current)

for remote in $(git branch -r | grep -v 'HEAD'); do
  [[ "$remote" != */* ]] && continue
  local_branch="${remote#*/}"
  [[ "$local_branch" == "HEAD" ]] && continue
  if ! git show-ref --verify --quiet "refs/heads/$local_branch"; then
    echo "Création de la branche locale : $local_branch"
    git checkout -b "$local_branch" "$remote"
  fi
done

for branch in $(git for-each-ref --format='%(refname:short)' refs/heads/); do
  [[ "$branch" == origin* ]] && continue
  upstream=$(git for-each-ref --format='%(upstream:short)' "refs/heads/$branch")
  [[ -z "$upstream" ]] && continue
  echo "Mise à jour de la branche : $branch"
  git checkout "$branch"
  git pull
done

git checkout "$current_branch"
```

---

## Auteurs

- [Harry RICHMOND](https://github.com/RogerBytes)

<span hidden>
<details><summary></summary>
<style>.spoiler{border-left:4px solid #1abc9c;border-bottom-left-radius:3px;padding-left:10px;padding-top:15px;margin-top:-10px;margin-bottom:15px}.button{cursor:pointer;padding:5px 10px;background-color:#3498db;color:white;border-radius:3px;margin-bottom:5px;display:inline-block;transition:background-color 0.2s}.button:hover{background-color:#217dbb}details[open] .button{background-color:#1abc9c}</style>
</details></span>

<p align="right"><a href="#">🔝 Retour en haut</a></p>
