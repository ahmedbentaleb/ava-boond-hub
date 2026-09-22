# Remarques sur le canon `_ops/` — on ne le corrige pas.

| Ligne / fichier | Écart constaté | On n'a pas inventé |
|---|---|---|
| `REGISTRE_POLITIQUES_v1.md` §E | `ref_couleur` : **16** valeurs ; THEMES_v1 en liste **12** + 3 nommées le 19/09 = **15** codes. | Seed des 12 + jaune_fluo, rose, lavande. La 16e n'a pas de nom. |
| `THEMES_v1.md` polices | « 9 valeurs », 8 noms listés. | Seed des 8 noms. |
| `REGISTRE_POLITIQUES_v1.md` §E | `ref_theme` cité le 18/09 ; le SQL L3 n'a pas cette table (34 = 27+7, `ref_etat_besoin` + boucle). | Pas de table inventée. `ui.theme` stocke un code texte. |
| `REGISTRE_POLITIQUES_v1.md` §B | `ref_competence` : « domaines à fixer », aucun code. | Table vide. |
| `SPEC_SQL_AVAMANAGER_V1.sql` L739 | `positionnement.personne_id NOT NULL` lève avant `ck_m2_xor` (L7 L205). | Migration `004` : DROP NOT NULL. La colonne reste écrite par `tg_pers`. |
| `SPEC_ASSERTIONS_L7.sql` L255 | M-8 : `has_table_privilege('ava.'\|\|tablename)` dans le WHERE, sans barrière de plan, lève sur `pg_statistic`. | Copie `/test` : sous-requête `OFFSET 0`. Le mur testé ne change pas. |

Lot 2 — détail : `journal/greffe/REMARQUES.md`.

| Ligne / fichier | Écart constaté | On n'a pas inventé |
|---|---|---|
| `prompt-lot2.txt` L131 | « bug B-002 » = cliquet case 7. Journal B-002 = M-2. | B-005 pour le cliquet, pas un second B-002. |
| `prompt-lot2.txt` L123–134 | Huit cases exigées. `outils/cliquet.sh` : sept. | Pas de case 8. |
| `prompt-lot2.txt` L128–131 | Case 7 vs `origin/main` : **28** SHA `_ops/`. | Q-001 / D-013. |
| `prompt-lot2.txt` L57–64 | Case 8 vs `origin/main` : `3cd95e8` + `1a30280` touchent `web/` et `server/`. | Mesure lot 2 seulement après fork. |
| `SPEC_COMMANDES_L4.md` L129–134 vs `MACHINES_ETAT_V1.md` L23–28 | `NeedFilled`… vs `NeedStateChanged`. | D-011 : L4. |
| `THEMES_v1.md` L152–175 | 12 couleurs listées, 8 polices nommées. Registre 20/09 : 16 + 9 (`bleu_roi`, `systeme`). | Pas de seed greffe. |
| commit `2df9bd6` | Touche `_ops/prompt-lot2.txt` + `JOURNAL_BUGS.md` + `DOSSIER.html` + journal + audit + `make.sh`. | Pas d'amend greffe. B-006. |
| `web/src/ListeBesoins.tsx` / `FicheBesoin.tsx` | Appellent `ListerBesoins` et `LireBesoin`, absents de L4. | Q-011. Pas de 56e commande. |
