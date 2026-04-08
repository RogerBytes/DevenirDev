# 03 - Installer GH GitHub CLI

GitHub est une plateforme en ligne basée sur Git qui facilite le partage, la collaboration et l'hébergement de projets Git. Cela permet aux développeurs de travailler ensemble sur des projets, de contribuer aux dépôts existants, de signaler des problèmes ou de demander des fonctionnalités, et de suivre les modifications apportées aux projets via l'interface web conviviale de GitHub.

Préambule IMPORTANT : la version gratuite de GitLab est bien plus limitée que celle de github, il n'y a pas ou prou de CLI et de nombreuses options dérangeantes servent de paywall pour prendre un abonnement payant. Faites votre compte sur github pour commencer (voir les autres alternatives et leurs limitations, si vous en avez le temps). **Edito** -> à voir en 2026

## Installation

Depuis [la page officielle de GH](https://github.com/cli/cli/blob/trunk/docs/install_linux.md)

```bash
(type -p wget >/dev/null || (sudo apt update && sudo apt install wget -y)) \
  && sudo mkdir -p -m 755 /etc/apt/keyrings \
  && out=$(mktemp) && wget -nv -O$out https://cli.github.com/packages/githubcli-archive-keyring.gpg \
  && cat $out | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null \
  && sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg \
  && sudo mkdir -p -m 755 /etc/apt/sources.list.d \
  && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
  && sudo apt update \
  && sudo apt install -y gh
```

## Connexion via token

Commande pour connecter votre système à votre compte github si vous avez déjà votre token dans `~/.github/mytoken.txt`.

Il faut avoir fait la partie [Générer un token API pour Github](### Générer un token API pour Github), puis :

```bash
gh auth login --with-token < ~/.github/mytoken.txt
```

### Pour se déconnecter

```bash
gh auth logout
```

## Démarrage automatique de l'agent SSH

Ceci va permettre à votre session ssh de rester active tant que vous ne verrouillez pas ou vous déconnectez, ainsi le mot de passe de votre clef SSH sera demandé qu'une fois (de base il faut le faire toutes les 30 minutes).

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
grep -qxF 'export SSH_AUTH_SOCK=$(systemctl --user show-environment | grep SSH_AUTH_SOCK | cut -d= -f2)' ~/.zshrc || \
echo 'export SSH_AUTH_SOCK=$(systemctl --user show-environment | grep SSH_AUTH_SOCK | cut -d= -f2)' >> ~/.zshrc
source ~/.zshrc
```

## Générer sa clef SSH

Générez votre clef avec :

```bash
ssh-keygen -t ed25519 -C "your_email@example.com"
```

Il retournera

```bash
Generating public/private ed25519 key pair.
Enter file in which to save the key (/home/USERNAME/.ssh/id_ed25519):
```

-> Faites 'Entrée' pour choisir le chemin/noms de fichiers par défaut, tapez ensuite un mdp pour votre clef SSH.

il vous retournera :

```bash
Your identification has been saved in /home/USERNAME/.ssh/id_ed25519
Your public key has been saved in /home/USERNAME/.ssh/id_ed25519.pub
The key fingerprint is:
SHA256:V4t2iPZV9co4tCq4r3s8qOwfw3Ft8q/Lz3C7CnJ9Qd9k your_email@example.com
The key's randomart image is:
+--[ED25519 256]--+
|         ..      |
|        . o      |
|       . o .     |
|      . o +      |
|     . S = .     |
|      * = +      |
|     o = o .     |
|    . o .        |
|     .           |
+----[SHA256]-----+
```

Et, enfin, ajoutez votre clef ssh au ssh-agent :

```bash
ssh-add ~/.ssh/id_ed25519
```

[A VERIFIER, je pense que c'est faux]
Attention, il faut refaire `ssh-add ~/.ssh/id_ed25519` dans votre terminal VSCode.

Pour faire en sorte que votre clef soit accessible via votre IDE
[A VERIFIER / FIN]

Vous pouvez vérifier

```bash
ssh -T git@github.com
```

### Changer le protocole de connexion

Pour le passer en ssh (vous pouvez faire la même chose pour https)

```bash
gh config set -h github.com git_protocol ssh
```

## Lier sa clef SSH à son compte github

vérifier que l'on est bien co avec

```bash
gh auth status
```

Donner les privilèges :

```bash
gh auth refresh -h github.com -s admin:org,admin:public_key,repo
```

puis ajouter la clef au compte github :

```bash
gh ssh-key add ~/.ssh/id_ed25519.pub
```

-> Désormais, vu que votre clef SSH est reconnue par votre compte github, ssh-agent se chargera tout seul de vous connecter à votre compte, plus besoin de rentrer vos infos et mdp ou même devoir taper 'gh auth login --with-token < ~/.github/mytoken.txt' pour vous connecter.

Lancez la connexion ssh à github avec :

```bash
ssh -T git@github.com
```

Tapez yes pour confirmer, et tapez le mdp de votre clef SSH (et cochez "Déverrouiller automatiquement cette clé quand je suis connecté").

Il retourne :

```bash
Hi @Username! You've successfully authenticated, but GitHub does not provide shell access.
```

### Reset gh (Github CLI)

En cas de souci avec gh (qui peut être capricieux avec un changement de token ou de compte), vous pouvez le reset avec

```bash
rm -r ~/.config/gh
```

### Générer un token API pour Github

Afin d'avoir un token disposant de tous les droits administrateur, je vous conseille de faire ce qui suit.

Générez votre token ici :
[Page de création de token Github](https://github.com/settings/tokens/new)

mettre la durée et tout cocher, puis "Generate token"
copiez le token, par exemple :
`ghp_1aBcDeFgHiJkLmNoPqRsTuVxYz1234567890`

Faites la commande suivante

```bash
mkdir -p ~/.github
# puis (en remplaçant le token avant entre guillemets bien sûr)
echo "ghp_1aBcDeFgHiJkLmNoPqRsTuVxYz1234567890" > ~/.github/mytoken.txt

# Si vous désirez une copie du token :
cp ~/.github/mytoken.txt ~/
```
