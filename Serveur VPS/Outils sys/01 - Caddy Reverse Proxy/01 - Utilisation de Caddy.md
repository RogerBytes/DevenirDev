# 01 - Utilisation de Caddy

## Configurer un reverse proxy

Il suffit de modifier le `Caddyfile` comme on l'a déjà fait.

```bash
sudo nano /opt/docker/caddy/Caddyfile
```

On y colle une nouvelle entrée (ici l'exemple pour `VaultWarden`)

```plaintext
vw.rogerbytes.com {
        log {
                output file /var/log/caddy/caddy.log
        }
        reverse_proxy 127.0.0.1:8000
}

autre.rogerbytes.com {
        log {
                output file /var/log/caddy/caddy.log
        }
        reverse_proxy 127.0.0.1:9000
}
```

Au besoin, on peut formater/améliorer l'indentation du `Caddyfile` avec

```bash
sudo docker compose exec -w /etc/caddy caddy caddy fmt --overwrite
```

**Très important** : Après chaque modification du `Caddyfile`, il faut recharger la configuration de Caddy pour qu'elle soit prise en compte, sans pour autant couper le service

On va dans le répertoire de  `Caddy`

```bash
sudo docker compose exec -w /etc/caddy caddy caddy reload

# ou

sudo docker compose -f /opt/docker/caddy/compose.yml exec -w /etc/caddy caddy caddy reload
```

Et voilà, la nouvelle configuration est prise en compte.

## Explication et exemple

Ici l'exemple pour `VaultWarden`

On ouvre `/opt/docker/caddy/Caddyfile`

```bash
sudo nano /opt/docker/caddy/Caddyfile
```

```plaintext
vw.rogerbytes.com {
        log {
                output file /var/log/caddy/caddy.log
        }
        reverse_proxy 127.0.0.1:8000
}
```

Pour la ligne `reverse_proxy 127.0.0.1:8000`

Il faut lire cet extrait du `compose.yml` de `VaultWarden` pour comprendre

```yml
ports:
  - 127.0.0.1:8000:80
```

Voici la lecture

- `127.0.0.1:8000:80`
- `localhost:hôte:conteneur`

- `hôte` **(8000)** C'est la prise sur laquelle le service est disponible uniquement au sein du VPS (grâce au 127.0.0.1). C'est pour cela que Caddy doit pointer vers cette prise locale
- `conteneur` **(80)** C'est le port interne du conteneur Docker, en général on s'abstient de le modifier, car les services interagissent les uns les autres via ce port
