# Remarques greffe — lot 2. On ne patche pas `_ops/`.

Mesure 2026-09-20 · HEAD `2df9bd6` · branche `lot-2`.

| Ligne / fichier | Écart constaté | On n'a pas inventé |
|---|---|---|
| `_ops/prompt-lot2.txt` L131 | « C'est le bug B-002 du journal. » `journal/BUGS.md` B-002 = M-2 `personne_id NOT NULL` (`3cd95e8`). Le cliquet case 7 n'a pas ce numéro. | Pas de B-002 bis. Q-007. |
| `_ops/prompt-lot2.txt` L123–134 | Le lot 2 exige **huit** cases. `outils/cliquet.sh` L2–3 et L104–105 : **sept** cases, sortie `cases OK=… KO=…`. Case 8 (frontière web/server) **absente**. | Pas de 8e ligne ajoutée par greffe. |
| `_ops/prompt-lot2.txt` L128–131 | Case 7 : `git log origin/main..HEAD -- _ops/` vide = OK. Mesuré : **28** SHA. `origin/main` = `e6fc35a` (cadrage). Le lot 1 a déjà commité `_ops/`. | Appliquer la case telle quelle → KO permanent. Q-006. |
| `_ops/prompt-lot2.txt` L57–64 · L132 | Case 8 : aucun commit `web/` **et** `server/`. Mesuré sur `origin/main..HEAD` : `3cd95e8` (locks) et **`1a30280`** (`server/src/index.ts` + `web/src/App.tsx` dans le même commit Boond). | Case 8 vs `origin/main` → KO avant tout code lot 2. Q-006. |
| `_ops/SPEC_COMMANDES_L4.md` L129–134 | Événements `NeedTakenInCharge` · `NeedFilled` · `NeedSuspended` · `NeedResumed` · `NeedClosed` · `NeedReopened`. | L4 fait foi (D-011). |
| `_ops/MACHINES_ETAT_V1.md` L23–28 | Les mêmes transitions émettent `NeedStateChanged`. | Deux noms pour un fait. Q-008. |
| `_ops/prompt-lot2.txt` L87 | « THEMES_v1.md ⭐ 16 couleurs, 9 polices ». | — |
| `_ops/THEMES_v1.md` L152–167 | Titre « Les 12 couleurs » : 12 codes, dont `argent`. Pas de `bleu_roi` · `gris` · `jaune_fluo` · `rose` · `lavande`. | Pas de 13e couleur seedée ici. |
| `_ops/THEMES_v1.md` L173–175 | Titre « Les 9 polices » : **8** identifiants (`jetbrains_mono` … `inter`). | Pas de 9e police inventée. |
| `_ops/REGISTRE_POLITIQUES_v1.md` L66–67 | 16 couleurs nommées (dont `bleu_roi`) · 9 polices (dont `systeme`). Lot 1 R1/R2 en partie **clos dans le registre**, pas dans THEMES. | — |
| `outils/cliquet.sh` L88 | Case 6 : `grep E[1-7]` dans `ETAPES.md`. Les lignes L2-* ne sont pas exigées. | On n'a pas retiré E1–E7. |
| commit `2df9bd6` | `_ops/` modifié sur `lot-2` (interdit 7). Mélange 4 métiers. | B-006. Pas d'amend. |
| `web/src/ListeBesoins.tsx` L16 · `FicheBesoin.tsx` L64 | `ListerBesoins` · `LireBesoin` hors L4. | Q-011. |
