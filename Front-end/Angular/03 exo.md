# Sans titre

## 1. Interpolation (`{{ }}`)

👉 Sert à afficher des données dans ton HTML.

**Exemple :**

```html
<h1>Bienvenue {{ username }}</h1>
<p>Vous avez {{ messagesCount }} nouveaux messages.</p>

```

```tsx
username = "Alice";
messagesCount = 5;

```

---

## 2. Property Binding (`[ ]`)

👉 Permet de lier une **propriété HTML** à une donnée Angular.

**Exemple :**

```html
<img [src]="imageUrl" [alt]="username">
<input [value]="username">

```

```tsx
imageUrl = "https://angular.io/assets/images/logos/angular/angular.png";
username = "Alice";

```

---

## 3. Event Binding (`( )`)

👉 Permet d’écouter un **événement** (click, input, keyup, etc.).

**Exemple :**

```html
<button (click)="increment()">+1</button>
<p>Compteur : {{ count }}</p>

```

```tsx
count = 0;
increment() {
  this.count++;
}

```

---

## 4. `ngClass`

👉 Applique dynamiquement des classes CSS selon une condition.

**Exemple :**

```html
<p [ngClass]="{ 'active': isActive, 'inactive': !isActive }">
  Statut : {{ isActive ? 'Actif' : 'Inactif' }}
</p>
<button (click)="toggle()">Changer</button>

```

```tsx
isActive = true;
toggle() {
  this.isActive = !this.isActive;
}

```

---

## 5. `ngStyle`

👉 Applique des styles CSS dynamiquement.

**Exemple :**

```html
<p [ngStyle]="{ 'color': isActive ? 'green' : 'red', 'font-size': fontSize + 'px' }">
  Texte stylisé dynamiquement
</p>

```

```tsx
isActive = true;
fontSize = 20;
```

---

## 6. Two-Way Binding (`[(ngModel)]`)

👉 Combine **property binding `[ ]`** et **event binding `( )`**.

Permet de **lier une variable Angular et un champ HTML dans les deux sens**.

⚠️ Il faut importer **FormsModule** dans `app.module.ts` :

```tsx
import { FormsModule } from '@angular/forms';

@NgModule({
  imports: [BrowserModule, FormsModule],
  ...
})
export class AppModule { }

```

**Exemple :**

```html
<input [(ngModel)]="username" placeholder="Entre ton nom">
<p>Bonjour {{ username }}</p>

```

```tsx
username = "Alice";

```

👉 Quand tu tapes dans l’input, `username` change, et l’affichage suit en direct.

---

### Exemple compteur

```html
<input type="number" [(ngModel)]="count">
<p>Valeur actuelle : {{ count }}</p>
<button (click)="count = count + 1">+1</button>

```

```tsx
count = 0;

```

---

# Exercices pratiques

### Exercice 1 – Interpolation

Crée un composant qui affiche :

```
Bonjour [ton nom], tu as [x] notifications.

```

---

### Exercice 2 – Property Binding

- Crée un input qui affiche une valeur venant du TS (`defaultText = "Hello Angular"`).
- Ajoute une image dont le `src` est lié à une variable.

---

### Exercice 3 – Event Binding

- Crée un bouton `Ajouter +1` qui incrémente un compteur affiché dans le HTML.

---

### Exercice 4 – ngClass

- Crée un paragraphe avec deux classes CSS : `vert` (texte vert) et `rouge` (texte rouge).
- Selon `isGreen`, applique l’une ou l’autre via `ngClass`.
- Ajoute un bouton pour basculer.

---

### Exercice 5 – ngStyle

- Crée un paragraphe dont la taille du texte augmente de +2px à chaque clic sur un bouton.

---

### Exercice 6 – Two-Way Binding (Nom et prénom)

- Crée deux champs `input` liés à `firstName` et `lastName`.
- Affiche : `Bonjour [Prénom] [Nom]`.

---

### Exercice 7 – Two-Way Binding (Slider dynamique)

- Crée un `<input type="range">` lié à une variable `fontSize`.
- Applique `fontSize` sur un paragraphe via `ngStyle`.
    
    👉 Le texte grossit/rétrécit quand tu bouges le slider.
    

---

### Exercice 8 – Two-Way Binding (Choix de couleur)

- Crée un `<input type="color">` lié à une variable `color`.
- Applique `color` sur un paragraphe via `ngStyle`.

---