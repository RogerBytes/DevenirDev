# Inline, Block et Inline Block

Voici trois mini-démos très parlantes à coller dans un fichier HTML et ouvrir avec Live Server.

## **1. Block : ils prennent toute la largeur et se mettent l’un sous l’autre**

```html
<div style="background:lightblue;">Bloc 1</div>
<div style="background:lightgreen;">Bloc 2</div>
<p style="background:lightcoral;">Bloc 3 (un paragraphe)</p>
```

---

## **2. Inline : restent dans la ligne et ignorent hauteur/largeur**

```html
<p>
  Texte avant
  <span style="background:yellow;">Span inline</span>
  <span style="background:pink;">Encore inline</span>
  texte après.
</p>
```

Essayez ceci :

```html
<span style="background:yellow; width:200px; height:50px;">Test</span>
```

→ Vous verrez que la largeur/hauteur ne s’applique pas vraiment.

---

## **3. Inline-block : reste dans la ligne, mais accepte taille et centrage**

```html
<p>
  <span
    style="display:inline-block; background:orange; width:150px; height:40px; text-align:center;"
  >
    Inline-block 1
  </span>

  <span
    style="display:inline-block; background:lightgray; width:150px; height:40px; text-align:center;"
  >
    Inline-block 2
  </span>
</p>
```

Vous verrez deux petites “boîtes” dans la même ligne, mais contrôlables comme des div.
