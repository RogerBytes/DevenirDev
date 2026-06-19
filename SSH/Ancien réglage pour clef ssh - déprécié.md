
JE GARDE LE TEMPS D'ETRE SUR QUE LA NOUVELLE MANIERE FONCTIONNE CORRECTEMENT

## Lier sa connexion à sa session

Afin d'éviter d'avoir un timer et de retaper sans cesse son mdp, on va lier le trousseau à la session active

```bash

mkdir -p ~/.config/systemd/user
cat << 'EOF' > ~/.config/systemd/user/ssh-agent.service
[Unit]
Description=SSH key agent

[Service]
Type=forking
ExecStart=/usr/bin/ssh-agent -s
ExecStop=/usr/bin/ssh-agent -k
RemainAfterExit=yes

[Install]
WantedBy=default.target
EOF


systemctl --user enable ssh-agent
systemctl --user start ssh-agent


LINE='export SSH_AUTH_SOCK=$(systemctl --user show-environment | grep SSH_AUTH_SOCK | cut -d= -f2)'
grep -qxF "$LINE" ~/.zshrc || echo "$LINE" >> ~/.zshrc
source ~/.zshrc
```

- Crée le dossier et le service systemd utilisateur
- Active et démarre le service
- Ajoute la ligne magique au .zshrc si elle n'y est pas et recharge

Ainsi, le trousseau reste actif tant que l'on ne vérouille/déconnecte pas le poste ou que l'on redémmare.


