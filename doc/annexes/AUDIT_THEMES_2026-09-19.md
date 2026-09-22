# Audit des 28 thèmes — 19 septembre 2026

## ✅ CORRIGÉ LE 19/09 AU SOIR — 0 DÉFAUT SUR 13 944 POINTS MESURÉS

| | Avant | Après |
|---|---|---|
| Défauts de contraste | **34** | **0** |
| Pire mesure | **1,25:1** | **4,51:1** |
| Thèmes livrant une colonne sans mot | **9** | **0** |
| Points mesurés | 84 combinaisons × 9 | **13 944** |

⭐ **Une seule règle**, écrite une fois dans `encre(couleur, fond, repli)` : une couleur qui sert
d'**encre** ne descend jamais sous 4,5:1 sur le fond qu'elle touche — sinon elle reprend la
couleur du texte. ⛔ Elle ne s'applique **pas** à un aplat : un filet, une bordure, un
remplissage ne se lisent pas.

⚠️ **Deux corrections que la règle seule ne donnait pas :**

| Cas | Ce qu'il a fallu en plus |
|---|---|
| **Le repli ne passait pas non plus** | velours teinte le fond à 24 % et `--t2` y tombe à 3,94:1 → l'encre descend d'un cran de plus, vers `--t1` |
| **L'échelle de SENS** | ⛔ un danger ne devient pas gris. `remonte()` la pousse vers le blanc ou le noir par pas de 8 %, douze pas au plus, jusqu'à ce qu'elle passe |

---

**34 défauts distincts sur 84 combinaisons** (28 thèmes × 3 fonds), mesurés dans le navigateur,
contraste WCAG calculé sur le fond réellement peint derrière chaque élément.

<quand_utiliser>

Ce fichier dit **ce qui est cassé et pourquoi**. Le plan du jour renvoie ici.
⛔ Il ne se lit pas pour savoir quoi faire : il se lit pour savoir **ce qui a été mesuré**.

</quand_utiliser>

---

## ⬜ LES QUATRE CAUSES

⭐ **Une seule règle les couvre toutes les quatre** : *une couleur qui sert d'ENCRE ne descend
jamais sous 4,5:1 — sinon elle reprend la couleur du texte courant.* C'est exactement la règle
déjà posée le 19/09 sur les libellés de tuiles, appliquée aux trois autres endroits.

| # | Cause | Combien | Pire mesure |
|---|---|---|---|
| **1** | **La couleur d'entrée du menu**, sur fond clair, quand `ui.menu.coloration` vaut `icone`, `titre` ou `les_deux` : la variante vive s'écrit sur du blanc | **17** | `corail / clair` — **1,30:1** |
| **2** | **`--action-encre`** : la couleur d'ACTION sert d'encre sur les boutons sans vérifier le fond | **5** | `encre / sombre` — **1,25:1** |
| **3** | **Le texte mélangé à `--struct`** (journal, file d'attente) : sur clair et intermédiaire, STRUCTURE est trop pâle | **11** | `lagon / gris` — **3,13:1** |
| **4** | **`--t3` sur fond teinté** — velours pousse la teinte à 24 %, le gris moyen ne suit pas | **1** | `velours / clair` — **3,29:1** |

---

## ⚠️ ET UN CINQUIÈME, QUI N'EST PAS UN CONTRASTE

⛔ **Neuf thèmes affichent une colonne de gauche SANS AUCUN MOT** — `ti:"non"` :

```
ardoise · terminal · bloom · phosphore · glace · fluo · neon · lavande · craie
```

> **Hamada, 19/09 :** « Regarde, comme ici, on ne voit pas ce qui est à gauche. »
> (capture : thème ARDOISE, fond sombre — treize icônes grises, aucun nom)

⭐ Le réglage `ui.menu.titre` **reste** : masquer les titres est un choix légitime quand la
colonne est repliée. ⛔ Mais **aucun thème ne doit le livrer par défaut sur une colonne
dépliée** : une colonne de treize pictogrammes muets n'est pas un menu.

---

## LE DÉTAIL MESURÉ — 34 lignes

| Thème / fond | Quoi | Mesuré |
|---|---|---|
| encre / sombre | bouton | 1.25 |
| encre / gris | bouton | 1.18 |
| acier / sombre | bouton | 3.96 |
| acier / gris | bouton | 2.68 |
| brique / gris | bouton | 3.41 |
| olive / clair | menu — titre et icône | 1.57 |
| mural / clair | menu — titre et icône | 1.57 |
| ocean / clair | menu — titre et icône | 1.48 |
| emeraude / clair | menu — titre et icône | 1.49 |
| corail / clair | menu — titre et icône | 1.30 |
| prune / clair | menu — titre et icône | 1.38 |
| citron / clair | menu — titre et icône | 1.48 |
| rouge_levres / clair | menu — titre et icône | 1.33 |
| neon / clair | menu — icône | 1.27 |
| lagon / gris | journal | 3.13 |
| velours / clair | journal | 3.87 |
| prune / gris | journal | 4.01 |
| foret / clair | journal | 4.24 |
| cuivre / clair | journal | 4.24 |
| lin / clair | journal | 4.24 |
| rouge_levres / gris | journal | 4.29 |
| sable / gris | journal | 4.40 |
| lavande / gris | journal | 4.43 |
| glace / gris | journal | 4.47 |
| velours / clair | journal — détail | 3.29 |
| velours / clair | texte de file | 3.29 |

---

<interdits>

| ⛔ Jamais | Le problème que ça évite |
|---|---|
| **Corriger un thème à la main** | 34 retouches qui se défont au thème suivant. La règle se pose une fois, à la source |
| Retirer `ui.menu.titre` du registre | c'est un vrai choix — ⛔ ce qui est faux, c'est de le livrer par défaut |
| Mesurer le contraste sur la couleur déclarée | le fond réellement peint est teinté : `--f-col` n'est pas `--f1` |
| Lire `getComputedStyle().color` sans parser `color(srgb …)` | ⚠️ **c'est arrivé pendant cet audit** : 207 faux positifs sur le journal, à 1,1:1. Chrome rend les `color-mix` en `color(srgb 0.846 0.698 0.904)`, et un parseur qui n'attend que `rgb()` lit 0,846 comme 0,846/255 |

</interdits>

<source>

Mesuré le 19/09/2026 dans le navigateur, sur `_ops/share-hub/terminal.html` à `ebf9098`.
28 thèmes × 3 fonds × 9 points de mesure. Seuil 4,5:1 pour le texte, 3:1 pour une icône
accompagnée d'un mot.

</source>
