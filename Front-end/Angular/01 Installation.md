# installation

<https://discordapp.com/channels/1435905878372126802/1480851681238319236/1480851794468016199>

## NPM

npm est un gestionnaire de paquets NodeJs

Il nous permettra d'installer Angular avec la commande

```bash
npm install -g @angular/cli

```

et on va installer des extensions pour symfony et tailwind

```bash
codium --install-extension bradlc.vscode-tailwindcss
codium --install-extension esdete.tailwind-rainbow
codium --install-extension esbenp.prettier-vscode
codium --install-extension SonarSource.sonarlint-vscode
codium --install-extension Gydunhn.vsc-essentials
codium --install-extension Gydunhn.angular-essentials
codium --install-extension johnpapa.Angular2
codium --install-extension Angular.ng-template
codium --install-extension Mikael.Angular-BeastCode
codium --install-extension ecmel.vscode-html-css
codium --install-extension vincaslt.highlight-matching-tag
codium --install-extension naumovs.color-highlight
codium --install-extension html-validate.vscode-html-validate
codium --install-extension pranaygp.vscode-css-peek
codium --install-extension anseki.vscode-color
codium --install-extension stylelint.vscode-stylelint
```

## Le Projet

### La CLI

- Command Line Interface
- Ou, interface en ligne de commande
- Dans un terminal, taper la commande suivante pour vérifier la bonne installation de Angular :

```bash
ng version
```

### Nouveau Projet

- La commande suivante nous permet de générer un nouveau projet
- Notez qu'il vous faudra au préalable démarrer votre terminal à l'emplacement où vous souhaitez créer le projet.

```bash
ng new nom_du_projet
```

On peut fait en sorte que le typage soit strict avec `--strict`.

```bash
ng new nom_du_projet --strict
```

En prime on installe ce qu'il faut en plus pour tailwind [d'après cette doc](https://angular.dev/guide/tailwind)

```bash
npm install tailwindcss @tailwindcss/postcss postcss
```

et dans le fichier `src/styles.css` on peut y mettre nos components de tailwind etc

```css
@import "tailwindcss";

@layer components {
  .btn {
    @apply bg-amber-300 text-white px-4 py-2 rounded;
  }
}
```

### **LANCER LE PROJET**

Une fois le projet initialisé, on peut le lancer avec la commande suivante :

```bash
ng serve -o
```

La commande se chargera de build l’application, et ouvrira le navigateur

_Le port par défaut est_ 4200

## **A VOUS DE JOUER !**

Créez une application Angular

## Pour tailwind

```css
@layer components {
  .btn {
    @apply bg-amber-300 text-white px-4 py-2 rounded;
  }
}
```

- `@layer base` → styles globaux, reset CSS, polices…
- `@layer components` → classes réutilisables comme `.btn`, `.card`…
- `@layer utilities` → styles utilitaires personnalisés si tu veux en créer.

Ça **facilite la maintenance** et évite que des styles soient écrasés par les utilitaires de Tailwind.

Pour un plus petit projet on peut parfaitement faire

```css
.btn {
  @apply bg-amber-300 text-white px-4 py-2 rounded;
}
```

Même s'il manque l'organisation par layer, cela marchera correctement.

