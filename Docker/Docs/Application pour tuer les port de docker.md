# En cas de galere avec les ports coincés part des processus de docker

On va créer une petite application pour tuer un processus docker qui est bloqué (et qui bloque un port pour rien))

```bash
sudo tee /usr/local/bin/dport-kill > /dev/null << 'EOF'
#!/bin/bash
PORT=$1

if [ -z "$PORT" ]; then
    echo "Usage: $0 <port>"
    exit 1
fi

# Récupère les PIDs sur le port avec sudo pour inclure docker-proxy
PIDS=$(sudo lsof -t -i :${PORT})

if [ -z "$PIDS" ]; then
    echo "Aucun processus trouvé sur le port $PORT"
    exit 0
fi

# Active la correspondance insensible à la casse pour docker*
shopt -s nocasematch

# Parcourt chaque PID et vérifie si c'est un processus Docker
for PID in $PIDS; do
    CMD=$(ps -p $PID -o comm=)
    if [[ "$CMD" == *docker* ]]; then
        sudo kill -9 $PID
        echo "Processus Docker $PID ($CMD) tué sur le port $PORT"
    else
        echo "Processus $PID ($CMD) n'est pas Docker, on ne le tue pas"
    fi
done
EOF

sudo chmod +x /usr/local/bin/dport-kill
```

Pour l'utiliser il suffira de faire (par exemple pour le port 8123)


```bash
dport-kill 8123
```

