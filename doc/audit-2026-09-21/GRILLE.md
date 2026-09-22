# Grille — les 36 contrôles de `_ops/GRILLE_AUDIT.md`, commit `3b59ca5`

⛔ **Verdict de la grille : REFUSÉ** — 5 🔴 (C2 · C3 · C4 · F3 · F6) ; un seul suffit.
`make up/migrate/test` n'ont pas été lancés (ils visent la base `ava`) : leurs étapes ont été rejouées sur `ava_audit`. Les preuves citées sont sous `rapport/preuves/`.

| # | Contrôle | Verdict | Preuve |
|---|---|---|---|
| A1 | Les assertions passent | ✅ | 6 migrations sans erreur ; `test/SPEC_ASSERTIONS_L7.sql` : 23 lignes « OK M- », rc=0 (`preuves/A1_construction_base.txt`). Contrat 55/55 + inventaire, Playwright 7/7 servies (`preuves/banc/S0_base.txt`). ⚠️ la copie jouée est périmée (V-001) |
| A2 | Elles tombent quand on casse un mur | ✅ | `DISABLE TRIGGER tg_m10` → « M-10 — LE GESTE EST PASSÉ », rc=3 ; idem M-7, M-4/M-14, M-12, M-6 (`preuves/banc/S6_*`). ⚠️ pas sur les moitiés GRANT (V-012) |
| A3 | La CI fait la même chose que moi | 🟠 | `.github/workflows/db.yml` n'existe pas ; `ci.yml` lance `outils/cliquet.sh` sans `fetch-depth` (pas de `main`), sans captures Linux pour P-062→065 (V-009, V-039). Exécutions CI non vérifiées (angle mort) |
| A4 | Le compte correspond au registre §E | ✅ | `python _ops/outils/dossier.py` : aucun « ECART » ; politiques=173, référentiels=37, assertions=22 (`preuves/A4_dossier_py.txt`) |
| A5 | Les fiches de l'auditeur interne existent | ✅ | `audit/` : E1→E7 + 11 fiches L2 (existence seule ; non lues, pour l'indépendance) |
| B1 | Aucun `if` métier en dur | 🟠 | grep de la grille sur `db/` : vide. Sur `server/src` : 36 occurrences (`preuves/B1_if_serveur.txt`, V-015) |
| B2 | Les 167 politiques sont chargées | ✅ (écart de canon) | `count(*) = 173` = registre §E (173) ; « 167 » de la grille est périmé (V-023) |
| B3 | `valeur = valeur_defaut` au seed | ✅ | `WHERE valeur <> valeur_defaut` → 0 ligne (`preuves/grille_commandes.txt`) |
| B4 | Les 34 référentiels existent | ✅ (écart de canon) | 37 tables `ref_*` = registre §E (37) ; « 34 » périmé |
| B5 | Aucun CHECK sur un code de référentiel | ✅ | aucun `CHECK (code` ; ⚠️ 4 listes figées en CHECK hors référentiel (V-021) |
| C1 | Aucune colonne `tenant_id` | ✅ | `grep -rn tenant db/` : 3 lignes, toutes des commentaires |
| C2 | Le rôle applicatif n'a aucun DELETE | 🔴 | la requête sur `ava_app` rend 0 ligne, **mais le rôle applicatif réel est `postgres`, superutilisateur** : il a DELETE partout (V-002) |
| C3 | `evenement_metier` et `snapshot_marge` sans UPDATE | 🔴 | 0 ligne pour `ava_app` ; même cause (V-002) ; et un GRANT UPDATE rendu n'est vu par aucune porte (S12) |
| C4 | Le rôle d'agrégats ne voit pas prestation, temps, snapshot | 🔴 | ces trois-là : refusés ; mais `v_conditions_du_jour` (TJM/CJM, 34 170 lignes), `prestation_version`, `evenement_metier`, `personne`, `compte` : lisibles (`preuves/C4_M15_perce.txt`, V-001) |
| C5 | Les 7 murs-triggers existent | ✅ | `tg_m4_m14`, `tg_m6`, `tg_m7`, `tg_m10`, `tg_m12` ×4, `tg_ajout_seul` présents (`preuves/grille_commandes.txt`) |
| D1 | `_ops/` n'a pas bougé | ✅ | `git diff --stat origin/main -- _ops/` : vide (HEAD a 15 commits d'avance) |
| D2 | Aucun ORM | ✅ | `grep -niE "prisma\|typeorm\|sequelize\|drizzle\|knex" */package.json` : vide |
| D3 | Migrations jamais réécrites | 🟠 | `001_schema.sql` modifiée par `98aae74` et `f54c73b` (V-028) |
| D4 | `REMARQUES.md` existe | ✅ | `git ls-files journal` : `journal/REMARQUES.md` + 3 sous-dossiers (contenu non lu : hors du mur) |
| D5 | Un seul auteur par dossier | 🟠 | un seul auteur git partout ; `bf7df47 [ecran]` touche `test/` et `web/` (V-040) |
| E1 | Aucun `if` d'état dans `/web` | ✅ | grep vide (`preuves/E_greps.txt`) |
| E2 | Aucun calcul d'argent dans `/web` | ✅ | grep vide ; ⚠️ « 1 / 2 postes » est écrit à la main dans `web/bouchon/_gen.mjs`, et un calcul front (S10) n'est vu par aucune porte |
| E3 | Aucun libellé d'état en dur | 🟠 | `web/src` vide, mais les libellés d'état et leurs pastilles sont dans `web/bouchon/*.json` (« à pourvoir », « en recherche », « signée »…) servis tels quels (V-018) |
| E4 | `/web` n'importe rien de `/server` ni `/db` | ✅ | grep vide |
| E5 | Aucun ORM ni SQL dans `/web` | ✅ | seule occurrence : la police binaire `JetBrainsMono-Regular.woff2` (faux positif) |
| F1 | `journal/PORTES.md` existe et est à jour | ✅ | 65 lignes P-001 → P-065, numéro, espèce, vue rouge, état, lot cible |
| F2 | Les quatre espèces tournent | ✅ | base (P-001), contrat (P-002, P-006→060), geste (P-003, P-061), écran (P-004, 005, 062→065) — ⚠️ P-002 vise 3000 en dur (V-025) |
| F3 | Les portes servies n'ont pas baissé | 🔴 | à la lettre 64 ≥ 5 ; mais la mesure du cliquet vaut « 64 >= 0 » (`main` n'a pas de colonne État) et reste OK quand on supprime 4 portes ✅ (S11, V-009) |
| F10 | Aucune porte ✅ → ⏳ | ✅ | P-001 → P-005 de `origin/main` toujours ✅ ici, numéro par numéro |
| F11 | Aucune ⏳ au-delà de son lot cible | ✅ | une seule ⏳ : P-061, lot cible 3, lot courant 2 |
| F4 | Aucune porte désactivée | ✅ | 5 occurrences, toutes des faux positifs : `ExitCandidate`, `toBeDisabled()` ×2, `animations: "disabled"` |
| F5 | Chaque porte a été vue rouge | ✅ (déclaratif) | colonne remplie partout (2026-09-19 / 2026-09-20) ; aucune trace du rouge dans le dépôt |
| F6 | `cliquet.sh` existe et mesure | 🔴 | la case 1 ignore `make_rc` : serveur mort = 10/10 OK (S11b, V-008) ; cases 3/9 vides contre `main` (V-009) |
| F7 | Branché en pre-push | 🟠 | `.githooks/pre-push` appelle bien `cliquet.sh` ; `core.hooksPath` vide dans un clone neuf (réglage local, non versionné) |
| F8 | La CI relance le même script | ✅ | `ci.yml:17` `bash outils/cliquet.sh` (pas une copie) — ⚠️ mais sans `main` (V-009) |
| F9 | Le script ne s'arrête pas à la première case | ✅ | `set -u` sans `-e` ; rejoué : 10 lignes imprimées après un KO en case 2 (`preuves/banc/S11_temoin.txt`) |

**Bilan : 25 ✅ · 6 🟠 (A3 B1 D3 D5 E3 F7) · 5 🔴 (C2 C3 C4 F3 F6).** B2 et B4 sont ✅ contre le registre, avec un écart de la grille elle-même (V-023).
