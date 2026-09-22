# État du projet Ava Manager

⭐ **Une seule source pour « où on en est ».** Le hub (vue « État du projet ») et le dossier
(`dossier.html` §08) lisent ce fichier. ⛔ On ne recopie pas cet état ailleurs : on le met à jour ici.

<quand_utiliser>

| ✅ On ouvre ce fichier | ⛔ On ne l'ouvre pas pour |
|---|---|
| Savoir quel lot est fini, en cours, à venir | le détail d'un lot → son prompt (`_ops/prompt-*.txt`) |
| Savoir ce qui bloque aujourd'hui | les constats d'audit → `_ops/ARBITRAGE_AUDIT_2026-09-21.md` |
| Mettre à jour l'état après un rapport de session | les tâches du jour → le dernier `_ops/PLAN_<date>.md` |

Extraire l'état sans lire le reste :

```bash
sed -n '/<etat>/,/<\/etat>/p' _ops/ETAT_PROJET.md
```

</quand_utiliser>

<etat>

Mis à jour le 22/09/2026.

| Lot | Contenu | État |
|---|---|---|
| 1 | Fondations : dépôt, base, 15 murs, seeds, CI | ✅ accepté — 69 min |
| 2 | Serveur : les 55 commandes | ⏳ refusé par l'audit du 21/09 (47 constats) — critiques C1 → C7 corrigés, élevés et moyens en cours |
| 2c | Connexion par compte Microsoft | ⬜ décidé (T2, D-2) — attend la réponse R4 de la réunion |
| 3 | Les 26 écrans | ⬜ après le lot 2 accepté |
| 7 | Reprise Boond et recette | ⬜ attend l'export Boond (R3) et la liste des missions (R2) |
| 8 | Connecteur MCP pour Claude, lecture seule d'abord | ⬜ en dernier |

| Aujourd'hui | État |
|---|---|
| Second audit du lot 2 | ⬜ quand Grok écrit « prêt pour le second audit » |
| Réunion avec la direction d'Avaliance | ⬜ 23/09 — 10 questions, hub `#reunion` |
| Relevé Boond | ✅ clos le 19/09 |

</etat>

<source>

Lots 1 et 2 : rapports de Grok et audit indépendant du 21/09 (`ARBITRAGE_AUDIT_2026-09-21.md`).
Lot 2c : `DECISIONS_TECHNIQUES_v1.md` T2 et arbitrage D-2. Lot 8 : `PLAN_2026-09-20.md`.
⚠️ Les lots 3 à 6 du plan du 20/09 (CRM, staffing, production, écrans) sont absorbés : les 55
commandes sont toutes au lot 2, les écrans au lot 3. Le numéro 7 reste à la reprise.

</source>
