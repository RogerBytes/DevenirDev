# 02 Nouveau projet

Je vous recommande de [consulter la doc de Symfony](https://symfony.com/doc), elle est est d'une grande aide pour créer une projet Symfony.

## 02 La première page

Ici l'on va voir les premières actions après avoir initialisé le projet.
<kbd>Ctrl</kbd> + <kbd>Shift</kbd> + <kbd>I</kbd> permet de formater votre code dans VSC.

## Suppression de l'erreur 404

On consulte le [doc de première page](https://symfony.com/doc/current/page_creation.html) et regardons comment on peut créer une page.

La doc nous dit bien de créer un contrôleur et une route :

> 1. **Create a controller**: A controller is the PHP function you write that builds the page. You take the incoming request information and use it to create a Symfony Response object, which can hold HTML content, a JSON string or even a binary file like an image or PDF;
> 2. **Create a route**: A route is the URL (e.g. /about) to your page and points to a controller.

Effectivement pour créer la route, nous avons besoin du controller, car c’est dans le controller que nous allons notifier la route.

Exemple de la doc :

```php
// src/Controller/LuckyController.php

  // ...
+ use Symfony\Component\Routing\Attribute\Route;

  class LuckyController
  {
+     #[Route('/lucky/number')] // On voit la route ici
      public function number(): Response
      {
          // this looks exactly the same
      }
  }
```

Ici, dans une démarche pédagogique nous allons créé le controller manuellement. Mais il est recommandé dans un usage pratique d'utiliser la commande :

```bash
symfony console make:controller
```

Nous allons donc créer notre controller pour créer la route afin de ne plus avoir notre erreur dans le profiler.

Créons ce controller à la main pour que l’on puisse comprendre mieux les choses.

Dans le dossier `src` -> dossier controller il faut créer le fichier `HomeController.php`

```bash
touch src/Controller/HomeController.php
```

On ouvre la balise et l'on met le namespace

```php
<?php

namespace App\Controller;
```

Un namespace sert à organiser le code en regroupant les classes sous un espace de nom unique pour éviter les conflits et structurer ton application.

On créé la classe HomeController

```php
class HomeController
{
  public function index():Response
  {

  }
}
```

Avec l'extension `Php Intelephense` l'import (pour le `Response`) avec le `use` se fait automatiquement. S'il ne se fait pas (ou si erreur tierce) il suffit de mettre le sélecteur sur lui puis de faire <kbd>Ctrl</kbd> + <kbd>Alt</kbd> + <kbd>I</kbd>.

Voici ce que ça donne :

```php
<?php

namespace App\Controller;

use Symfony\Component\HttpFoundation\Response;

class HomeController
{
  public function index():Response
  {

  }
}
```

Pour l'erreur `Not all paths return a value`, c'est normal, l'on ne retourne rien pour l'instant.

A propos de la classe la doc nous dit :

> Make sure that `LuckyController` extends Symfony's base `AbstractController class:`

La classe doit donc être étendue de `AbstractController`.

Dans la création de classe on ajoute donc `extends AbstractController`. Attention de ne pas oublier de faire l'import avec `use` (sélecteur sur la classe puis <kbd>Ctrl</kbd> + <kbd>Alt</kbd> + <kbd>I</kbd>).

Nous avons ajouté cette classe pour pouvoir utiliser la méthode `render` qu'il fournit, elle permet de générer un visuel (généralement dans le return).

Voici ce que ça donne pour render `home.html.twig`.

```php
<?php

namespace App\Controller;

use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\Response;

class HomeController extends AbstractController
{
  public function index(): Response
  {
    return $this->render("home.html.twig");
  }
}
```

Si l'on rafraîchit la page du localhost, on se rend compte que l'erreur 404 est toujours présente, la route étant manquante dans la classe.

Symfony va également signaler une exception si le template Twig n’existe pas encore. Il faudra créer le fichier `home.html.twig` dans le dossier templates pour que `render()` fonctionne correctement.

Au dessus de la méthode `index`, nous ajoutons donc `#[Route('/', name: 'home', methods:['GET'])]`, ce qui donne :

```php
<?php

namespace App\Controller;

use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Attribute\Route;

class HomeController extends AbstractController
{
  #[Route('/', name: 'home', methods:['GET'])]
  public function index(): Response
  {
    return $this->render("home.html.twig");
  }
}
```

`Route` est en réalité une classe (d'où l'import avec `use`).

`#[Route('/', name: 'home', methods:['GET'])]` dit à Symfony : « associe l’URL `/` à cette méthode `index()`, appelle la route `home` et n’accepte que les requêtes GET ».

`return $this->render("home.html.twig");` utilise la méthode `render` héritée d’`AbstractController` pour retourner une **Response HTML** en affichant le template `home.html.twig`.

Quand je rafraîchit le localhost, Symfony relève une exception :

> Unable to find template "home.html.twig" (looked into: /home/harry/Local/Git/FirstProject/templates, /home/harry/Local/Git/FirstProject/vendor/symfony/twig-bridge/Resources/views/Form).

Nous n'avons pas encore créé le template, donc `render()` ne peut rien afficher.

On va changer de répertoire (deux niveaux de répertoire au dessus) et créer le fichier `home.html.twig` dans le répertoire `templates`.

```bash
touch templates/home.html.twig
```

On y ajoute un peu de texte

```twig
<pre>
{# (cet exemple est un clin d' œil à Roy Batty) #}
I’ve seen things you people wouldn’t believe.
Attack ships on fire off the shoulder of Orion.
I watched C‑beams glitter in the dark near the Tannhäuser Gate.
All those moments will be lost in time, like tears in rain.
Time to die.
</pre>
```

Voilà, la première page est finie !

<span hidden>
<details><summary></summary>
<style>.spoiler{border-left:4px solid #1abc9c;border-bottom-left-radius:3px;padding-left:10px;padding-top:15px;margin-top:-10px;margin-bottom:15px}.button{cursor:pointer;padding:5px 10px;background-color:#3498db;color:white;border-radius:3px;margin-bottom:5px;display:inline-block;transition:background-color 0.2s}.button:hover{background-color:#217dbb}details[open] .button{background-color:#1abc9c}</style>
</details></span>

<p align="right"><a href="#">🔝 Retour en haut</a></p>
