conforme, porte ouverte

Lu : grep `= 59|59 politiques|32 tables|hérite si NULL|devise unique` sur `_ops/*.md` et `_ops/adr/*.md`, hors `RELECTURE_5*` → **rien**. Les 9 points de DIFF2, attaques D-1 / D-2 / D-9 / T-2. Canon intact. Pas de patch. Pas de commit.

| # | Verdict | Ligne |
|---|---|---|
| D-1 | repris conforme | MODELE L183 : parent interne = même agence. |
| D-8 | repris conforme | §E seule source ; titre carte L40 = « compte : registre §E ». |
| D-9 | repris conforme | L276 `devise_defaut_code` dans la table. L297 `cjm_devise_code`. L310 dans M-14. L353–355 CA et coût, chacun sa devise. |
| T-2 | repris conforme | ADR-005 L81 : une devise par montant + CHECK facultatifs. Livrable L116, L214, L477 : CHECK, vues, rôle `ava_lecture_agregats`. |
| X-3 | repris conforme | 17+7 au §E. |
| X-4 | repris conforme | PLAN L40 motif : plus « 32 tables ». |
| D-2 | repris conforme | L173 et L188 : NULL = prospect, jamais hérite. |
| O-2 | repris conforme | MACHINES L88 ; MODELE L313. |
| neuf murs | repris conforme | L481 : M-4, M-6, M-7, M-8, M-10, M-12, M-14, nommés. |

Grep des chaînes de DIFF3 : vide. Brief L49 → « le compte du registre §E ». Cahier L243, livrable L42, plan L39 (sim v3) : exceptions déjà classées.

⚠️ L177 n’inventorie toujours pas `agence_id` (écrit L181). Ce n’est plus un des 9 ; l’exécutant qui ne lit que la liste L177 l’omettrait. Hors de cette porte.
