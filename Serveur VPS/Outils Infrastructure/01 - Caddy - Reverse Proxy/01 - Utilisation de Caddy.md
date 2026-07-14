# 01 - Utilisation de Caddy

## Configurer un reverse proxy

Il suffit de modifier le `Caddyfile` comme on l'a déjà fait.

```bash
sudo nano /opt/docker/caddy/Caddyfile
```

On y colle une nouvelle entrée (ici l'exemple pour `VaultWarden`)

```plaintext
dash.mondomaine.com {
        import crowdsec_bouncer
        reverse_proxy portainer:9000
}

www.mondomaine.com, mondomaine.com {
        import crowdsec_bouncer
        reverse_proxy portainer:9000
}
```

on utilise le formateur intégré avec

```bash
sudo docker compose -f /opt/docker/caddy/compose.yml exec -w /etc/caddy caddy caddy fmt --overwrite
```

et on relance caddy

```bash
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

## Voir les logs de Caddy

```bash
sudo docker compose -f /opt/docker/caddy/compose.yml logs -f caddy
```

## Voir si le fichier Caddyfile est correctement formaté

```bash
sudo docker compose -f /opt/docker/caddy/compose.yml exec -w /etc/caddy caddy caddy validate
```

S'il ne retourne que des `INFO` et se termine par `Valid configuration`, c'est que tout est bon.

En cas de `WARN` il suffit de lancer le formateur intégré de Caddy

```bash
sudo docker compose -f /opt/docker/caddy/compose.yml exec -w /etc/caddy caddy caddy fmt --overwrite
```

Ah, d'accord ! Tu parles du routing par **sous-dossier** (ou _path routing_) au lieu d'utiliser des sous-domaines. C'est-à-dire faire pointer `rogerbytes.com/caca` vers un service et `rogerbytes.com/autre` vers un autre.

Voici comment on fait ça proprement et simplement avec Caddy :

## Le Path Routing

Dans ton `Caddyfile`, au lieu de créer plusieurs blocs avec des sous-domaines, tu utilises le domaine principal et tu définis des règles selon le chemin (le _path_) avec l'instruction `handle`.

> [!CAUTION] Ce type de routing par chemin (`/truc`) peut casser l'affichage de ton site si ton code (tes fichiers CSS ou tes liens) s'attend à être uniquement sur le domaine principal tout court.

### 1. Exemple de configuration dans le Caddyfile

```plaintext
rogerbytes.com {
        # Tout ce qui commence par /truc va vers le service sur le port 8000
        handle /truc* {
                log {
                output file /var/log/caddy/caddy.log
                }
                reverse_proxy 127.0.0.1:8000
        }

        # Tout ce qui commence par /machin va vers le service sur le port 9000
        handle /machin* {
                log {
                output file /var/log/caddy/caddy.log
                }
                reverse_proxy 127.0.0.1:9000
        }

        # Le reste du site (la racine /) va vers ton site principal
        handle {
                log {
                output file /var/log/caddy/caddy.log
                }
                reverse_proxy 127.0.0.1:3000
        }
}
```
