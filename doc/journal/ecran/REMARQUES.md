# Remarques écran — lot 2. Le canon n'est pas corrigé.

| Ligne / fichier | Écart constaté | On n'a pas inventé |
|---|---|---|
| `prompt-lot2.txt` L7 | `_ops/share-hub/terminal.html` — le dossier n'existe pas. | Lu `_ops/ava-terminal.html`, déjà dans le dépôt. |
| `SPEC_COMMANDES_L4.md` L122–139 | 14 commandes d'écriture, **zéro lecture**. L'écran a besoin d'une liste et d'une fiche. | Bouchons `ListerBesoins` / `LireBesoin` signalés en Q-E1. |
| `SPEC_COMMANDES_L4.md` L336 | « Les schémas JSON… le lot 2 les produira » — `/server/contrat/` est vide au moment de l'écran. | Sorties figées dans `/web/bouchon/`. |
| `ava-terminal.html` L2526 vs L2512 | L'en-tête pose `+` puis export ; le commentaire dit l'inverse (S-8). | Ordre du markup jouable : `+` puis export. |
| `THEMES_v1.md` L173 | « 9 polices », 8 noms listés. | JetBrains Mono embarquée, déjà lot 1. |
