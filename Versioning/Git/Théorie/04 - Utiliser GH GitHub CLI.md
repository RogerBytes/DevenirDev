# Utilisation de GIT

[![Build Status](https://travis-ci.org/votre-utilisateur/votre-projet.svg?branch=master)](https://travis-ci.org/votre-utilisateur/votre-projet)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](https://opensource.org/licenses/MIT)

Git est un système de contrôle de version qui permet de suivre les modifications apportées à un ensemble de fichiers au fil du temps. Il facilite la collaboration entre les développeurs en permettant de gérer les différentes versions d'un projet et de fusionner les modifications apportées par plusieurs personnes.

GitHub, quant à lui, est une plateforme en ligne basée sur Git qui facilite le partage, la collaboration et l'hébergement de projets Git. Cela permet aux développeurs de travailler ensemble sur des projets, de contribuer aux dépôts existants, de signaler des problèmes ou de demander des fonctionnalités, et de suivre les modifications apportées aux projets via l'interface web conviviale de GitHub.

---

## Créer un dépôt distant et le lier au local

Je créé un dépôt distant du même nom sur github et on l'associe au git local.

```bash
PROJECT="nom-du-projet"
gh repo create "$PROJECT" --public --source=. --remote=origin
```

Si on voulait le créer dans une organisation, ça donne

```bash
gh repo create "$PROJECT" --public --source=. --remote=origin --org="NomDeLOrga"
```

Et on fait le commit et le push initiaux.

```bash
[[ -f README.md ]] && echo "Premier commit effectué" >> README.md || touch README.md; git add -A && git commit -m "chore: init projet avec README" && git push -u origin master
```

## Faire une Pull Request

Ici on fait la PR avec notre branche `dev`

```bash
gh pr create --base dev --head ma-branche --title "Titre de la PR" --body "Description des changements" --reviewer NOM_UTILISATEUR
```

`--reviewer NOM_UTILISATEUR` est facultatif, il sert à demander en même temps à un collaborateur en particulier de valider la PR.
Par exemple :

```bash
gh pr create --base dev --head feature/harry-section --title "Test de PR avec REVIEW" --body "Coucou Yassine" --reviewer YassineDev01
```

## Faire une PR vers un repo distant depuis fork

```bash
gh pr create --repo owner/original-repo --head ton-user:ta-branche --base main
```

---

### Pour transférer un dépôt distant sur GitHub

je n'ai pas encore trouvé la commande, sinon il faut aller sur la page
[https://github.com/#NomDeCompte#/#Repo#/transfer](https://github.com/#NomDeCompte#/#Repo#/transfer)

### Pour supprimer un dépôt distant sur GitHub

```bash
gh repo delete {[org/]repo} --yes
```

par exemple pour le repo `test`:

```bash
gh repo delete test
```

ou si le repo se trouve dans l'organisation `SuperCorp`

```bash
gh repo delete SuperCorp/test
```

### Pour lister vos dépôts distants sur GitHub

Pour lister les repo de l'organisation `SuperCorp`

```bash
gh repo list SuperCorp
```

Pour lister les repo de votre compte personnel

```bash
gh repo list
```

## Ouvrir une page github en CLI

Attention, ceci semble ne plus fonctionner, github à modifié son api, il semble désormais obligatoire d'activer github page depuis l'interface graphique.

En ligne de commande :

```bash
ORG="RogerBytes"
REPO="Portfolio"
BRANCH="master"
gh api \
  --method POST \
  -H "Accept: application/vnd.github+json" \
  "/repos/$ORG/$REPO/pages" \
  -f "build_type=workflow" \
  -f "source.branch=$BRANCH" \
  -f "source.path=/"
```

Il suffit de modifier les valeurs `$ORG` `$REPO` et `$BRANCH`

Ensuite l'on peut récupérer le lien

```bash
gh api "/repos/$ORG/$REPO/pages" -q '.html_url'
```

## Ouvrir une page github via l'interface graphique

Allez sur la page :
[https://github.com/#NomUser#ouNomOrg/#NomRepo/settings/pages](https://github.com/#NomUser#ouNomOrg/#NomRepo/settings/pages)
Et modifiez `#NomUser#ouNomOrg` et `#NomRepo` pour correspondre à chez vous.

-> Par exemple pour mon repo "testjeuweb" se trouvant dans mon org "RogerBytes-Softworks"
[https://github.com/RogerBytes-Softworks/testjeuweb/settings/pages](https://github.com/RogerBytes-Softworks/testjeuweb/settings/pages)

Sous `Source` choisissez `branche`, cliquez sur `None`, puis `Save`, puis choisissez laquelle contient votre html (chez moi sur master).
Puis cliquez sur `Save`

Au refresh de page le lien n’apparaît pas immédiatement
il faut minimum une minute ou deux avant que le site soit actualisé/créé.

Ca donnera un lien du type
[https://#NomUser#ouNomOrg.github.io/#NomRepo/](https://#NomUser#ouNomOrg.github.io/#NomRepo/)

dans mon cas :
[https://rogerbytes-softworks.github.io/testjeuweb/](https://rogerbytes-softworks.github.io/testjeuweb/)

### Conflit avec NodeJS

Attention, GitHub Pages fait un conflit avec node js, pour le résoudre, à la racine de votre projet :

```bash
touch .nojekyll
```

Cela va créer un fichier nommé `.nojekyll` à la racine de votre projet, empêchant GitHub de semer la zizanie.

---

## Créer une organisation

[Page Organisation de GitHub](https://github.com/settings/organizations)

## Ajouter un collaborateur

Pour ajouter un collaborateur à votre repo (j'arrive pas à le faire en CLI) :

```bash
gh api \
  -X PUT \
  -H "Accept: application/vnd.github+json" \
  /repos/OWNER/REPO/collaborators/USERNAME \
  -f permission="maintain"
```

par exemple :

```bash
gh api \
  -X PUT \
  -H "Accept: application/vnd.github+json" \
  /repos/RogerBytes-Softworks/TPA/collaborators/YassineDev01 \
  -f permission="maintain"
```

- `Read` Recommended for non-code contributors who want to view or discuss your project.
- `Triage` Recommended for contributors who need to manage issues and pull requests without write access.
- `Write` Recommended for contributors who actively push to your project.
- `Maintain` Recommended for project managers who need to manage the repository without access to sensitive or destructive actions.
- `Admin` Recommended for people who need full access to the project, including sensitive and destructive actions like managing security or deleting a repository.

---

## Auteurs

- [Harry RICHMOND](https://github.com/RogerBytes)

<span hidden>
<details><summary></summary>
<style>.spoiler{border-left:4px solid #1abc9c;border-bottom-left-radius:3px;padding-left:10px;padding-top:15px;margin-top:-10px;margin-bottom:15px}.button{cursor:pointer;padding:5px 10px;background-color:#3498db;color:white;border-radius:3px;margin-bottom:5px;display:inline-block;transition:background-color 0.2s}.button:hover{background-color:#217dbb}details[open] .button{background-color:#1abc9c}</style>
</details></span>

<p align="right"><a href="#">🔝 Retour en haut</a></p>
