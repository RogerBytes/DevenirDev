#!/bin/sh

# Vérifie si env.local existe, sinon le crée (requis pour compose up, pour le service database)
if [ ! -f ".env.local" ]; then
    echo "Création de .env.local"
    cat > .env.local <<'EOF'
POSTGRES_DB="MaBaseDeDonnees"
POSTGRES_USER="root"
POSTGRES_PASSWORD="root"
DATABASE_URL="postgresql://$POSTGRES_USER:$POSTGRES_PASSWORD@database:5432/$POSTGRES_DB?serverVersion=16&charset=utf8"
EOF
fi

# Vérifie si la pile de conteneur existe déjà, sinon lance la commande
if [ -n "$(docker compose ps --all -q 2>/dev/null)" ]; then
  echo "La pile existe déjà"
else
  docker compose --env-file .env.local up -d --build
fi

# Initialise node
docker compose exec -T php zsh -c "npm install"

