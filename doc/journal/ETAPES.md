# Étapes — lot 1. Une ligne par étape. On ne supprime jamais.

| Étape | Quoi | Quand | Commit | Auditeur |
|---|---|---|---|---|
| E1 | docker-compose PG16, Makefile, CI vide | 2026-09-19 | `3cd95e8` | ACCEPTÉ `audit/E1.md` |
| E2 | `001_schema.sql` identique au SPEC | 2026-09-19 | `3cd95e8` | ACCEPTÉ `audit/E2.md` |
| E3 | 34 ref + 167 politiques, valeur = défaut | 2026-09-19 | `3cd95e8` | ACCEPTÉ `audit/E3.md` |
| E4 | L7 dans `/test`, `make test`, 22 OK | 2026-09-19 | `3cd95e8` | ACCEPTÉ `audit/E4.md` |
| E5 | `tg_m4_m14` retiré → M-4 tombe ; remis | 2026-09-19 | `3cd95e8` | ACCEPTÉ `audit/E5.md` |
| E6 | Fastify sert `/web` ; `/sante` sans métier | 2026-09-19 | `3cd95e8` | ACCEPTÉ `audit/E6.md` |
| E7 | 5 portes, `cliquet.sh`, hooks, CI | 2026-09-19 | `3cd95e8` | ACCEPTÉ `audit/E7.md` |
| L2-0 | Lot 2 ouvert ; 0 JSON contrat ; solo HALT puis parallèle | 2026-09-20 | `2df9bd6` | REFUSÉ `audit/L2-00.md` (mesure `4a119ed`) |
| L2-1 | Greffe : 55 écarts ; kernel/vues/écrans besoin en WT, 0 route L4 | 2026-09-20 | — | ⏳ `journal/CONTRAT.md` · `audit/L2.md` REFUSÉ |
| L2-2 | Parade ⏳ : 5 portes lot 1 ✅ · 55 contrat ⏳ lot 2 · cliquet cases 1/3/9/10 | 2026-09-20 | `781b810` `fc35217` | ACCEPTÉ |
| L2-3 | 55 POST /commandes servies ; Archive* = DROIT (matrice D) | 2026-09-20 | `6031243` `d028582` | ACCEPTÉ cliquet 10/10 |
| L2-4 | C1–C7 et E4 vus rouge puis vert. P-061–P-065 restent ⏳ lot 3. Cliquet 9/10 : case 7 = `_ops/` déjà différent de `main`, non touché. | 2026-09-21 | `8ae5d16` | KO case 7 |
| L2-5 | Canon `afc1683` ancêtre de `lot-2` ; `_ops/` identique à `main`. Cliquet 10/10 (case 7 OK). §3 E1–E9 et §4 M1–M14 : témoin rouge puis vert, SHA dans `CORRECTIFS.md`. P-061–P-065 restent ⏳ lot 3. | 2026-09-22 | `da85e91` `8d57a7e` | cliquet 10/10 |
