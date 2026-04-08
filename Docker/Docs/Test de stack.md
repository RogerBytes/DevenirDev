# Tests de stack docker

Une fois que la stack a été build/monté on va faire les tests afin de vérifier que tout fonctionne.


## 01 Postgres et Doctrine

Ici on test que l'ORM parvient à envoyer les entités base (toujours depuis notre conteneur php).

On fait une entité, une migration et on l'execute

```bash
symfony console ma:en TestI
```

Et mainteant la migration

```bash
symfony console ma:mi
symfony console do:mi:mi -n
```

On fait une page home

```bash
symfony console ma:con Home
```

Et on corrige sa route pour diriger vers `/` (dans `src/Controller/HomeController.php`)

Tout fonctionne, on sort du shell du conteneur via

et on modifie sa vue dans `templates/home/index.html.twig`

On lui met

```twig
{% extends 'base.html.twig' %}

{% block body %}
	<h1 class="text-3xl font-bold underline bg-fuchsia-700">
		Hello world!
	</h1>
{% endblock %}
```

Tout fonctionne si le texte dans le navigateur est souligné en gras dans un fond violet


```bash
exit
```

---


## 02 Autres vérifications


On se connecte au conteneur du service php

```bash
docker compose exec -it php zsh
```

La CLI de Symfony

```bash
symfony check:requirements
```

PHP et extensions

```bash
php -v
php -m
```


Composer

```bash
composer --version
composer -v
composer diagnose
```

Starship + Zsh

```bash
echo $0
zsh --version
starship --version
```



