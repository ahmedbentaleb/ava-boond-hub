**REFUSÉ** — lot 2, commit `b6ff087`, cinquième audit du 24/09/2026, clone isolé `ava-audit-5`, base `ava_audit5`, port 3500.
Le banc part enfin de rien et tient (294 portes, 32 assertions, cliquet case 1 verte) ; ce qui refuse le lot, c'est le même trou déplacé d'un cran : le périmètre ne protège que les objets qui portent une agence.

| Mesure | 3e | 4e | 5e (`b6ff087`) |
|---|---|---|---|
| Banc de référence, base refaite | vert | ⛔ rouge (P-207) | ✅ **vert** — V-096 fermé |
| Portes aveugles / sabotages | 0 / 50 | 1 / 57 | **1 / 62** (W1) |
| Constats du tour précédent | 21 neufs | 11 neufs | **10 fermés · 3 partiels · 3 ouverts** |
| Cliquet réel, clone neuf | 11/12 | 10/12 | **11/12** (seule la case 12 : crochet non posé, la CI le pose) |
| Grille · conformité | 1 🔴 | 1 🔴 | **1 🔴 (K4) · 6 🟠 · 1 🟡** · 55/55 commandes, 0 écart |

1. **V-107 (critique)** — `agence.ts:244` : pour `UploadDocument`, `CreateAction` et `ArchiveObject`, un objet sans agence retombe sur l'agence **du demandeur**. Un compte de Londres archive un candidat de Paris. ⛔ Et c'est la **seule porte aveugle** : le sabotage W1 laisse 294 portes vertes.
2. **V-108 (critique, BRAIN)** — `societe` et `contact` n'ont **aucune colonne d'agence** : pour 7 commandes, le périmètre compare le demandeur à lui-même. Un compte de Paris archive une société de Casablanca. ⚠️ À trancher : une société porte-t-elle une agence, ou le canon assume-t-il qu'elle est partagée ?
3. **V-111 · V-112 (elevee)** — deux migrations portent le numéro **009** et le registre n'a aucun rang ; la règle **F13**, née de deux faux départs d'audit, est écrite dans la grille mais **absente du cliquet**.

⭐ Ce qui tient, mesuré : V-096, V-098, V-100 à V-105 fermés **et gardés** (retirer un correctif fait tomber une porte à chaque fois, y compris pour les outils de garde : P-299, P-300) ; 15 sabotages SQL sur 15 font tomber les assertions ; hors banc, toutes les routes en 401, rien d'écrit.

❓ Angles morts : CI GitHub non exécutée ; case 12 KO dans un clone neuf (normal) ; écrans besoin ⏳ lot 3, 7 sabotages d'écran ne visent aucune porte servie ; sabotage T6 sans effet (la fixture réactive les comptes) ; VPS, `.zip`, `.docx` et `Fonds ERP` non ouverts ; un des deux vérificateurs a lui-même posé une délégation `ArchiveCompany` dans sa base (déclaré dans ses angles morts).
