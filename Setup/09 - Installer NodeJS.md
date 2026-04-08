# NodeJS

Le code ici permet d'installer la LTS dynamiquement (curl va chercher automatiquement la version) de NodeJS avec NPM (source depuis [nodejs.org](https://nodejs.org/fr/download)).

<details><summary class="button">🔍 Spoiler</summary><div class="spoiler">

```bash
NVM_CMD=$(curl -s https://raw.githubusercontent.com/nvm-sh/nvm/master/install.sh)
VERSION=$(curl -s https://nodejs.org/dist/index.json | jq -r '.[] | select(.lts != false) | .version' | head -1 | cut -d. -f1 | tr -d 'v')
bash -c "$NVM_CMD"
\. "$HOME/.nvm/nvm.sh"
nvm install "$VERSION"
```

Pour vérifier votre installation

```bash
node -v
npm -v
```

</div></details>

## Pour installer la current

<details><summary class="button">🔍 Spoiler</summary><div class="spoiler">

Si vous voulez la current au lieu de la LTS utilisez.

```bash
VERSION=$(curl -s https://nodejs.org/dist/index.json | jq -r '.[] | select(.lts == false) | .version' | head -1 | cut -d. -f1 | tr -d 'v')
```

</div></details>

## Pour désinstaller

<details><summary class="button">🔍 Spoiler</summary><div class="spoiler">

On le vire avec nvm

```bash
LOCAL_VERSION=$(echo "$VERSION" | cut -d. -f1)
nvm deactivate
nvm uninstall "$LOCAL_VERSION"
```

Et on le dégage du shell

```bash
sed -i '/NVM_DIR/d' ~/.zshrc
sed -i '/nvm.sh/d' ~/.zshrc
sed -i '/bash_completion/d' ~/.zshrc
source ~/.zshrc
```

</div></details>

<span hidden>
<details><summary></summary>
<style>.spoiler{border-left:4px solid #1abc9c;border-bottom-left-radius:3px;padding-left:10px;padding-top:15px;margin-top:-10px;margin-bottom:15px}.button{cursor:pointer;padding:5px 10px;background-color:#3498db;color:white;border-radius:3px;margin-bottom:5px;display:inline-block;transition:background-color 0.2s}.button:hover{background-color:#217dbb}details[open] .button{background-color:#1abc9c}</style>
</details></span>

<p align="right"><a href="#">🔝 Retour en haut</a></p>
