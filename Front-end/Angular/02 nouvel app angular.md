# Nouveau projet Angular

On créé notre projet

et on voit dans

App.Ts

```typescript
import { Component, signal } from "@angular/core";
import { RouterOutlet } from "@angular/router";

@Component({
  selector: "app-root",
  imports: [RouterOutlet],
  templateUrl: "./app.html",
  styleUrl: "./app.css",
})
export class App {
  protected readonly title = signal(
    "Mon projet noob project very very aware de himself",
  );
}
```

```bash
ng generate component components/header
```

Et ça me créé le component etc.


Et exercice