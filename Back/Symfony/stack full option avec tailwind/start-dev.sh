#!/bin/sh

# Lance la pile
docker compose start

# Lance le shell du conteneur
docker compose exec -it php zsh
