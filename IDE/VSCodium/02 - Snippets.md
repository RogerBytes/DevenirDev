# Les snippets dans VSC

Pour faire un snippet dans VSC
`'CTRL+SHIFT+P'`\ `"Snippets configurer user snippet"`
Et choisissez le language `javascript/css/html/etc...`
Vous aurez à copier les blocs de code de cette doc au sein des objets, entre les accolades du fichier .json du langage sélectionné.

---

## Snippets JavaScript

- JS - Init
  - Permet de faire un template de script vierge avec des catégories, on appelle le snippet avec `init`
- JS - Strict
  - Permet d'ajouter l'entête "use strict", on appelle le snippet avec `strict`
- JS - Selector
  - Permet de générer un "Query Selector", on appelle le snippet avec `selector`
- JS - Class Init
  - Permet de faire un template de script vierge avec des catégories, on appelle le snippet avec `initClass`

```json
  "Template javascript":{
    "prefix": "init",
    "body":[
      "\"use strict\";"
      "\/\/ Coloration des commentaires avec l'extension vsc \"Better Comments\"//\n\n\n"
      "\/\/?-------------  Déclaration des Imports  -----------------//\n\n\n"
      "\/\/*-------------  Déclaration des Variables  ---------------//\n\n\n"
      "\/\/!-------------  Déclaration des Events  ------------------//\n\n\n"
      "\/\/!-------------  Instructions  ----------------------------//\n\n\n"
      "\/\/?-------------  Déclaration des Fonctions  ---------------//\n\n\n"
      "\/\/todo----------  TODO  ------------------------------------//\n\n\n"
      "\/\/*-------------  Zone Test  -------------------------------//\n\n\n"
      "\/\/*-------------  Fin  -------------------------------------//\n\n\n"
    ]
  },
  "use strict":{
    "prefix": "strict",
    "body": "\"use strict\";",
    "description": "Template pour un script, avec un strict"
  },
  "querySelector":{
    "prefix": "selector",
    "body": "const $1 = ${2:document}.querySelector$3('$4');",
    "description": "Fait apparaître un querySelector"
  },
  "Template classe javascript":{
    "prefix": "classInit",
    "body":[
      "\"use strict\";"
      "\/\/ Coloration des commentaires avec l'extension vsc \"Better Comments\"//\n\n\n"
      "\/\/?-------------  Imports de Modules  -----------------//\n\n\n"
      "\/\/?-------------  Déclaration de la Classe  ---------------//\n"
      "export default class ${1:MaClasse} {\n"
      "  \/\/?-------------  Déclaration de Propriétés  ---------------//\n\n"
      "  constructor(${2:param1}, ${3:param2}) {\n"
      "    \/\/*-------------  Initialisation de Propriétés  -------------//\n"
      "    this.${4:prop1} = ${2:param1}"
      "    this.${5:prop2} = \"exemple\"\n"
      "  }\n"
      "  \/\/?-------------  Déclaration de Méthodes ------------------//"
      "  \/\/!-------------  Déclaration des Events  ------------------//\n\n\n"
      "  \/\/?-------------  Déclaration de Méthodes auxiliaires ------//\n\n\n"
      "  \/\/todo----------  TODO  ------------------------------------//\n\n\n"
      "  \/\/*-------------  Zone Test  -------------------------------//\n\n\n}\n"
      "\/\/*-------------  Fin  -------------------------------------//\n\n"
    ]
  }
```

---

## Snippets CSS

- CSS - Reset
  - Permet d'ajouter le reset de préformatage, on appelle le snippet avec `reset`

```json
  "reset CSS":{
    "prefix": "reset",
    "body": [
      "*, ::before, ::after {\r",
      "\tmargin: 0;"
      "\tpadding: 0;"
      "\tbox-sizing: border-box;\r}"
    ]
  }
```

---

## Snippets HTML

- HTML - Defer
  - Permet d'ajouter un script en asynchrone différer, on appelle le snippet avec `defer`
- HTML - PHP Line
  - Permet d'ajouter un bloc de php, on appelle le snippet avec `php`
- HTML - PHP Block
  - Permet d'ajouter un bloc de php, on appelle le snippet avec `phpb`
- HTML - PHP Echo Block
  - Permet d'ajouter un bloc echo de php, on appelle le snippet avec `phpe`
- HTML - PHP Debug
  - Permet d'ajouter un bloc echo de php, on appelle le snippet avec `phpd`
- HTML - Image full attributes
  - Balise image avec tous ses attributs, on appelle le snippet avec `imgA`

```json
  "script, defer and module": {
    "prefix": "defer",
    "body": "<script src=\"$1\" defer type=\"module\"></script>",
    "description": "utilise script en proposant direct de mettre la source et y ajoute le defer"
  },
  "PHP Line": {
    "prefix": "php",
    "body": [
      "<?php $0 ?>"
    ],
    "description": "Insère un bloc PHP sur une ligne"
  },
  "PHP Block": {
    "prefix": "phpb",
    "body": [
      "<?php",
      "\t$0",
      "?>"
    ],
    "description": "Insère un bloc PHP"
  },
  "PHP Echo Block": {
    "prefix": "phpe",
    "body": [
      "<?= $0 ?>"
    ],
    "description": "Insère un bloc PHP court pour echo"
  },
  "PHP Debug": {
    "prefix": "phpd",
    "body": [
      "<!-- [DEBUG] --><pre><?php var_dump(${1:\\$_REQUEST}); /* print_r(${1:\\$_REQUEST}); */ /* echo var_export(${1:\\$_REQUEST}, true); */ ?></pre>"
    ],
    "description": "Bloc PHP debug compact avec var_dump par défaut sur \\$_REQUEST et alternatives commentées"
  },
  "Image full attribute":{
    "prefix": "imgA",
    "body": "<img src='$1' alt='$2' loading='lazy' decoding='async'>",
    "description": "Crée une balise img avec les attributs loading et decoding"
  }
```

---

## Snippets PHP

- PHP - form
  - NIANIANIA, on appelle le snippet avec `form`
- PHP - Strict mode
  - NIANIANIA, on appelle le snippet avec `printarray`
- PHP - Print Array
  - NIANIANIA, on appelle le snippet avec `printarray`
- PHP - Require path helper
  - Snippet pour charger ma lib pour ma fonction de chemin path()

```json
  "PHP form": {
    "prefix": "form",
    "body": "if(\\$_SERVER['REQUEST_METHOD']==='${1:POST}' ${2:&& isset(\\$_${3:POST}['$4'])})\r{$0}",
    "description": "Condition de traitement de formulaire (POST ou GET) avec vérification optionnelle de champ"
  },
  "Strict mode":{
    "prefix": "strict",
    "body": "declare(strict_types=1);",
    "description": "Empêche les conversions implicites et automatiques de types."
  },
  "Print Array":{
    "prefix": "printarray",
    "body": "echo '<pre>'.print_r($1, 1).'</pre>';$0",
    "description": "Crée un joli affichage pour nos tableaux."
  },
  "Require path helper": {
    "prefix": "reqpath",
    "body": "require_once dirname(__DIR__) . DIRECTORY_SEPARATOR . '${1:lib}' . DIRECTORY_SEPARATOR . 'path.php';",
    "description": "Charge la fonction path() depuis un dossier (lib par défaut)."
  },
  "Require path helper (depuis racine)": {
    "prefix": "reqpathroot",
    "body": "require_once __DIR__ . DIRECTORY_SEPARATOR . '${1:lib}' . DIRECTORY_SEPARATOR . 'path.php';",
    "description": "Charge path.php depuis un dossier, quand on est à la racine du projet."
  }
```

## Snippet MarkDown

- Style perso
  - Importe le style nécessaire à markdown pour mes spoiler.
- Spoiler
  - On fait `'CTRL+SHIFT+P'`\ `"Snippets configurer user snippet"`
  - Et choisissez le language `markdown`
- Snipper signature
- Snipper intro

```json
  "Spoiler style perso": {
    "prefix": "xstyle",
    "body": [
      "<span hidden>",
      "<details><summary></summary>",
      "<style>.spoiler{border-left:4px solid #1abc9c;border-bottom-left-radius:3px;padding-left:10px;padding-top:15px;margin-top:-10px;margin-bottom:15px}.button{cursor:pointer;padding:5px 10px;background-color:#3498db;color:white;border-radius:3px;margin-bottom:5px;display:inline-block;transition:background-color 0.2s}.button:hover{background-color:#217dbb}details[open] .button{background-color:#1abc9c}</style>",
      "</details></span>",
      "",
      "<p align=\"right\"><a href=\"#$1\">🔝 Retour en haut</a></p>",
      ""
    ],
    "description": "Insertion du style et bouton up, remplir le titre 1 pour le bouton"
  },
  "Spoiler collapsible contenu with style": {
    "prefix": "yspoiler",
    "body": [
      "<details><summary class=\"button\">🔍 Spoiler</summary><div class=\"spoiler\">",
      "",
      "$0",
      "",
      "</div></details>"
    ],
    "description": "Insère un spoiler collapsible avec curseur sur le contenu"
  },
  "Insert Author Block": {
    "prefix": "yauthorblock",
    "body": [
      "## Auteur",
      "",
      "[<img src=\"https://github.com/RogerBytes.png\" width=\"40\" height=\"40\" style=\"border-radius:50%;\" alt=\"RogerBytes' avatar\">](https://github.com/RogerBytes) ",
      "[**RogerBytes (Harry Richmond)**](https://github.com/RogerBytes)"
    ],
    "description": "Insère un bloc auteur avec avatar et nom cliquable"
  },
  "Intro": {
    "prefix": "xintro",
    "body": [
      "<table><tr><td>",
      "",
      "$1",
      "</td></tr></table>"
    ],
    "description": "Insère un bloc d'intro"
  },
```

---

## Auteur

[<img src="https://github.com/RogerBytes.png" width="40" height="40" style="border-radius:50%;" alt="RogerBytes' avatar">](https://github.com/RogerBytes)
[**RogerBytes (Harry Richmond)**](https://github.com/RogerBytes)
