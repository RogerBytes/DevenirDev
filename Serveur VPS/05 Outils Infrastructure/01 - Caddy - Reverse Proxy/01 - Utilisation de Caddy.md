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
