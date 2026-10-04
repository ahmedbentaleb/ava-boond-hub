**43 contrôles comptés, 43 annoncés — 39 ✅ · 3 🟠 · 0 🔴 · 1 non mesurable sur ce poste. P-339 rejouée ici : 846 identifiants, 6 passes, 0 fuite, 0 ligne sans attendu.**

> ⚠️ Numérotation : ce document garde les numéros de travail de son brouillon. Les constats rendus sont dans `CONSTATS.md` (V-179 → V-195), table de correspondance à la fin.


# GRILLE11 — onzième audit, lot 2, commit `34d98a4` · auditeur B (base `ava_audit11_b`, port 4102)

La grille ne voit aucun 🔴, mais trois portes vertes restent ⏳ et ne protègent donc rien. Le 🔴 du lot est ailleurs : D-57 n'est pas tenu (CONFORMITE11 C-1, C-2).

> Méthode : rien n'est cru. Chaque verdict a sa commande ou son fichier de preuve sous
> `rapport/preuves/grille11/`. ⛔ Ni `outils/make.sh` ni `outils/cliquet.sh` n'ont été lancés.
> `cliquet.sh` est **lu**. Les cases qui n'ont pas besoin de `make test` sont recalculées par une **copie**
> sans `make test` (`preuves/securite11/scripts/cliquet_sans_make.sh`, sortie `grille11/cliquet_sans_make.txt`).
> Base montée de zéro par `preuves/securite11/scripts/rebuild.sh` : `db/migrations/*.sql` dans l'ordre, une
> transaction par fichier, ligne `schema_migrations` avec rang et sha256 dans la même transaction (comme
> `cmd_migrate`), comptes `@ava.test` désactivés, `horloge_banc` vidée, puis `db/fixtures/banc.sql`. La base a été
> reconstruite une fois, après A2.

---

## 0 · Le compte

| Famille | Annoncé | Lignes comptées | Verdicts |
|---|---|---|---|
| A · La preuve | 5 | A1 → A5 = **5** | 5 ✅ (A1 partiel) |
| B · Le paramétrage | 5 | **5** | 4 ✅ · 1 🟠 |
| C · Les murs | 5 | **5** | 5 ✅ |
| K · L'accès | 5 | **5** | 4 ✅ · 1 ⬜ |
| D · Le dépôt | 5 | **5** | 4 ✅ · 1 🟠 |
| E · L'écran | 5 | **5** | 5 ✅ |
| F · Le cliquet | 13 (« F1 → F13 ») | **13** | 12 ✅ · 1 🟠 |
| **Total** | **43 · 7 familles** | **43** ✅ | **39 ✅ · 3 🟠 · 1 ⬜** |

`_ops/GRILLE_AUDIT.md` n'a pas bougé depuis le 10e tour : mêmes 43 contrôles. L'ordre des lignes F n'est toujours pas numérique, sans effet sur le compte.

---

## F · LE CLIQUET (passé en premier)

| # | Verdict | Preuve |
|---|---|---|
| F1 | ✅ | `journal/PORTES.md` : **354** lignes `P-`, toutes à 10 champs, en-tête `Porte · Espèce · Phrase · Test · Vue rouge · État · Lot cible · Tolérance` (`grille11/f_cliquet_mesures.txt`). |
| F2 | ✅ | Quatre espèces : A 1 ✅ · B **342 ✅ + 3 ⏳** · C 1 ✅ + 1 ⏳ · D 2 ✅ + 4 ⏳. `make test` joue le contrat (23 fichiers) **et** `npx playwright test` (lu, non lancé). |
| F3 | ✅ | `origin/main` sert 5 portes, toutes présentes dans HEAD (case 3 recalculée : « 5 servies sur origin/main, 0 disparue »). |
| F10 | ✅ | Passages ✅→⏳ en premier parent depuis `merge-base(origin/main, HEAD)` : P-062 → P-065 @`b2b7d1e`, P-340 @`419f7b2`, tous déclarés D-35. Mon script voit aussi P-340 @`4a6a832` et @`08ede17` : ce sont les deux lignes P-340 de la collision de numéro, déjà expliquée en D-35. **Aucun passage depuis `16ea24d`.** Case 9 : OK. |
| F11 | ✅ par la lettre · voir G-1 | 8 ⏳ : P-061 → P-065 (lot 3) et **P-359, P-360, P-361 (lot cible 2 = lot courant)**. Aucune n'a dépassé son lot. |
| F4 | ✅ | Le grep de la grille ne rend que des faux positifs (`CandidateExited`, `exit`, `toBeDisabled`). Case 4 : OK. |
| F5 | ✅ | 0 ligne sans date de vue rouge (case 5, qui lit maintenant par en-tête : V-177 fermé). |
| F6 | ✅ | `outils/cliquet.sh` lu : **22 cases**, toutes calculées. La case 1 exige `make_rc=0` et que chaque ✅ ait été exécutée. Les cases 5 et 10 lisent par en-tête (`portes_colonnes`). Nouveau : la case 22 (D-78) dit que le juge ne change que par `lot-2-brain`. |
| F7 | ✅ (lecture) | `outils/installer.sh` pose `core.hooksPath=.githooks`. `pre-push` et `commit-msg` sont présents. Dans le clone d'audit, `core.hooksPath` est vide, ce qui est attendu (case 12 KO ici). |
| F8 | 🟠 (G-2) | `ci.yml` relance bien `bash outils/cliquet.sh`. ⚠️ Mais la CI ne pose en local que `main` : **la case 22 cherche `lot-2-brain` en local** (`git rev-parse --verify -q lot-2-brain`) et rend **KO « introuvable » dans tout clone**. C'est mesuré ici (`grille11/cliquet_sans_make.txt`, case 22) ; la même case avec `C22_JUGE=origin/lot-2-brain` rend OK (`cliquet_case22_origin.txt`). |
| F9 | ✅ | `set -u` sans `-e` ; 22 appels `line` ; sortie après la case 22. |
| F13 | ✅ | `git merge-base --is-ancestor origin/lot-2-brain HEAD` → vrai (`adc78a3`). |
| F12 | ✅ | Case 11 recalculée : origin/main + 337 commits. Les seules ✅ absentes de HEAD sont P-333 → P-338, déclarées retirées (D-41), et leurs portes gardées sont ✅. Aucune porte disparue depuis `16ea24d`. 7 nouvelles : P-355 → P-358 ✅, P-359 → P-361 ⏳. |

Recalculées sans `make test` (`grille11/cliquet_sans_make.txt`) : cases 3, 4, 5, 6, 7, 8, 9, 10, 11, 13, 15, 18, 20, 21 → **OK** (la case 20 rend « 287 couples = registre (140) + défauts des clés absentes (147) » sur ma base). La case 22 est OK contre `origin/lot-2-brain`. Les cases 1, 2, 14, 16, 17 et 19 lisent la sortie de `make test`, que je n'ai pas lancé : je les ai remplacées par A1, A2 et P-339 ci-dessous.

### P-339 — la porte croisée (demande expresse)

| Mesure | Résultat |
|---|---|
| Canon = copie | `cmp _ops/PORTE_CROISEE.mjs test/contrat/porte_croisee.test.mjs` → identiques |
| État au journal | ✅, lot 2, tolérance « 0 fuite » |
| Passes | Politiques lues dans `agence.ts`, valeurs lues dans la table → **5 passes** (`agence_responsable`, `par_besoins`, `partagee`, `non`, `oui`) **+ 1 passe D-59** (acteur `croise.lyo@`, droit seul sur LYO) |
| Rejouée contre :4102 (`grille11/p339_rejouee.txt`, détail `p339_detail.json`, analyse `analyse_p339.txt`) | **57 commandes · 846 identifiants hors agence · 0 fuite** (0 dans chaque passe) **· 0 refus d'un autre code · 0 positif KO** (71 × 5 passes + 68 en D-59, plus 6 « création chez soi » refusés comme attendu) **· 27 permis tenus · 0 permis refusé · 8 permis arrêtés par une règle métier · 0 ligne sans attendu · rc=0** |
| Lancée seule | Lancée **avant** toutes mes sondes, sur une base neuve : aucun processus concurrent, aucune fuite fausse cette fois |
| Les 8 « arrêtés par une règle métier » | Tous en passe `partagee`, tous `GARDE contact d'une autre société` (CreateNeed, UpdateNeed, CreateProject ×2, CreateProjectFromNeed, UpdateProject ×3). Le refus est juste, mais la porte le **note** sans le juger : voir G-3 |
| Refus attendus | 811 : **799 DROIT · 12 GARDE**. Les 12 GARDE sont `ValidateTimesheet.id` et `RejectTimesheet.id` : « temps d'une autre prestation » |

---

## A · LA PREUVE

| # | Verdict | Preuve |
|---|---|---|
| A1 | ✅ partiel | Assertions L7 jouées sur la base neuve : **41 `OK   M-` pour un plancher de 41** (`plancher_assertions.sh`), rc=0. `cmp test/ _ops/` → identiques (`grille11/a1_a2.txt`). P-339, P-359, P-360 et P-361 sont vertes contre :4102. ⛔ `make test` complet (Playwright) n'a pas été lancé : interdit au poste. |
| A2 | ✅ | `DROP TRIGGER tg_m10 ON ava.temps` puis assertions : **rc=3**, levée « un temps saisi pour une autre ressource (M-10) — LE GESTE EST PASSÉ ». Seulement 19 OK. Base reconstruite ensuite. |
| A3 | ✅ | `ci.yml` : `fetch-depth: 0`, `main` en local, `bash outils/cliquet.sh`. ⚠️ `lot-2-brain` n'est pas récupéré : voir F8. |
| A4 | ✅ | `python _ops/outils/dossier.py` joué dans une copie `git archive` (scratchpad) : `OK`, `politiques=203 · referentiels=75` (`grille11/a3_a4_a5_d5.txt`). |
| A5 | ✅ | `audit/` : E1 → E7, plus 11 fiches L2-*. |

## B · LE PARAMÉTRAGE

| # | Verdict | Preuve |
|---|---|---|
| B1 | ✅ au grep · 🟠 hors grep (G-4) | Grep A : 10 occurrences, grep B : 9, grep C : 0, **lues une à une** (`grille11/b_c_d_e.txt`). On n'y trouve que des types de périmètre (`global`, `agence`, `soi`, `pole`, `equipe`), des catégories fermées (`positive`, `negative`, `externe`), des éléments de politiques liste (`nom_normalise`, `siren`, `email`…) et du routage web. ⚠️ Ce que le grep ne voit pas : `ORDER BY ordre … LIMIT 1` (5 sites), la comparaison d'un code au « premier code de sa catégorie » (4 sites), 4 noms de commande dans le noyau, 7 littéraux de code. CONFORMITE11 C-1 prouve que c'est cassant. |
| B2 | ✅ | `count(*) politique` = **203**. Le registre en a 202 en tableau, plus `ui.theme.personnalise` en prose. C'est la seule clé en base hors tableau, et aucune clé du registre ne manque en base. |
| B3 | ✅ | Base neuve : `valeur <> valeur_defaut` → **0**. Vérifié aussi en fin d'audit : 0. |
| B4 | ✅ | `ref_*` en base = **75** = registre §E. |
| B5 | ✅ | 9 CHECK à liste hors `ref_*`, les mêmes qu'au 10e tour, tous justifiés au §D. |

## C · LES MURS

| # | Verdict | Preuve |
|---|---|---|
| C1 | ✅ | `grep -rn tenant db/` : 3 lignes de commentaire. |
| C2 | ✅ | La requête de la grille, étendue à `ava_serveur`, rend 0 ligne. `rolsuper(ava_serveur) = f`. Pendant une commande, `pg_stat_activity` montre `ava_serveur` (`securite11/k2_k3_c2.txt`). |
| C3 | ✅ | Pas d'UPDATE sur `evenement_metier`, `snapshot_marge`, `prestation_version`, `tentative_refusee`, ni pour `ava_app` ni pour `ava_serveur`. |
| C4 | ✅ | `ava_lecture_agregats` atteint **exactement 7** relations. 0 fonction SECURITY DEFINER exécutable. |
| C5 | ✅ | `tg_m4_m14`, `tg_m6`, `tg_m7`, `tg_m10`, `tg_m12` (×4), `tg_ajout_seul` (×3), plus `tg_m7_tentative`, `tg_m16`, `tg_m16_ligne`, `tg_m18`. |

## K · L'ACCÈS

| # | Verdict | Preuve |
|---|---|---|
| K1 | ✅ | Serveur **sans** `AVA_MODE` sur :4102 : 29 sondes, toutes en 401 sauf `/sante`. `POST /sante` mal formé ou de 1,1 Mo → 400. JSON mal formé, `text/plain`, form-urlencoded, 1,1 Mo, `[1,2]`, `null` → 401. Empreinte des tables : **0 modifiée** (`securite11/hors_banc.txt`). |
| K2 | ✅ (jugé au lot 2c) | En banc, l'UUID d'un compte passé en en-tête → `DROIT compte inconnu ou inactif`. |
| K3 | ✅ | `ia@` désactivé : commande → DROIT, lecture → 403, **0 événement**. |
| K4 | ✅ | `HANDLERS` 57 = `CORRESPONDANCE` 57 = `DECLARATION` 57, aucun écart. Contractées : `compte_commandes.sh` → **100**. Hors agence : P-339, 0 fuite. ⚠️ Une cascade saute la garde de sa fille : SECURITE11 I-3. |
| K5 | ⬜ non mesurable | `verif_serveur.sh` se joue sur le VPS ; le poste est en `trust` assumé. |

## D · LE DÉPÔT

| # | Verdict | Preuve |
|---|---|---|
| D1 | ✅ | `git diff --stat origin/main HEAD -- _ops/` → vide. |
| D2 | ✅ | Aucun ORM dans `server/`, `web/`, `test/`. |
| D3 | 🟠 (G-4) | La commande de la grille rend maintenant **6 commits** (5 au 10e tour). Le nouveau : **`e35b226` (01/10 22:21) réécrit `023_registre_executable.sql`**, 49 minutes après sa création (`bc5bb97`), en retirant 4 `UPDATE politique SET valeurs_possibles`. Le commit l'écrit lui-même : « 023 (non publiée) ». La case 15 ne protège que les migrations de `main` : elle laisse passer. |
| D4 | ✅ | `git ls-tree -r --name-only HEAD` → `journal/REMARQUES.md` existe, avec 3 autres sous `journal/`. ⚠️ C'est une existence prouvée par le nom seul : le contenu est exclu par le mur d'indépendance (le 10e tour l'avait cru absent : la sparse-checkout le masque). |
| D5 | ✅ | `bash outils/verif_trailers.sh origin/main` : OK, 334 commits, dont 29 antérieurs à D-29. |

## E · L'ÉCRAN

| # | Verdict | Preuve |
|---|---|---|
| E1 → E5 | ✅ ×5 | Les cinq greps rendent vide ; E5 ne trouve que la police `.woff2`. `web/src` fait 631 lignes, inchangées sauf `Tuyau.tsx` (en-tête d'identité envoyé). |

---

## Constats de la grille

### G-1 🟠 — Une porte verte laissée ⏳ ne protège rien : la correction de D-57 et de V-170 n'est pas verrouillée
- **Famille** : l'état ✅/⏳ d'une porte se **déclare** à la main. Rien n'oblige à passer ✅ une porte ⏳ qui passe, et la case 1 du cliquet ignore l'échec d'une ⏳ (`etat == "⏳"` : ni `servies_ko`, ni `inconnus`).
- **Étendue mesurée** : P-359 (D-57 : réordonner ne fait tomber aucune signature), P-360 (`Object.prototype` → INTROUVABLE) et P-361 (routes = `LECTURES`) sont **vertes contre :4102** (`grille11/porte_attente_ordre_affichage.txt`, `porte_attente_routes.txt`) mais **⏳, lot cible 2**, au moment où le lot 2 est rendu à l'audit. Une régression de ces trois corrections passerait donc le cliquet sans bruit. Or deux d'entre elles portent des critiques du 10e tour (V-163, V-170).
- **Correction de construction** : le cliquet calcule l'état au lieu de le lire. Une porte ⏳ **exécutée et verte** fait rougir une case (« à promouvoir ») ; une ⏳ dont le lot cible est le lot courant fait rougir la case 10 quand la branche part en audit (`LOT_RENDU`).
- **Porte** : une case du cliquet qui croise `executees ∩ vertes` avec les ⏳ de `PORTES.md`. Aujourd'hui elle rendrait 3 rouges.

### G-2 🟠 — La case 22 ne peut passer que sur le poste qui l'a écrite : la CI est rouge par construction
- **Famille** : un contrôle du cliquet dépend d'une référence locale que la CI ne pose pas. C'est la faute que V-112 avait corrigée pour la case 13 (repli sur `origin/…`), revenue dans la case 22.
- **Étendue mesurée** : la case 22 résout `lot-2-brain` en local seulement. `ci.yml` ne pose que `main`. Tout clone neuf, donc la CI GitHub (`origin = github.com/ahmedbentaleb/ava-manager`), rend **KO « la branche lot-2-brain est introuvable »** : mesuré dans le clone d'audit. Le verdict qui compte (« 0 commit hors de la ligne du juge ») n'est donc jamais rendu par le « vrai mur » (A3, F8). Soit la CI est rouge en permanence, soit on l'ignore.
- **Correction de construction** : une seule fonction `ref_branche NOM` (locale, puis `origin/NOM`, puis `fetch`), utilisée par **toutes** les cases qui lisent une branche (13, 22, et 3, 9, 11, 15 pour `main`) ; `ci.yml` pose les branches du juge comme il pose `main`.
- **Porte** : le cliquet joué dans un clone neuf, sans branche locale, en CI : chaque case rend un verdict mesuré, jamais « introuvable ».

### G-3 🟡 — P-339 note sans les juger les permis « arrêtés par une règle métier », et ne joue jamais le permis de `par_besoins`
- **Famille** : une porte énumérative qui ne juge qu'une partie de ce qu'elle énumère (suite de V-165).
- **Étendue mesurée** : 8 lignes `OK-METIER` sont comptées sans assertion (`analyse_p339.txt`). Sous `par_besoins`, **0 permis** est joué : le générateur `L.societe()` ne crée jamais de société de LYO qui aurait un besoin dans PAR. La branche « union » de D-58 n'est donc jamais vue par la porte. Je l'ai jouée à la main : `UpdateCompany` et `CreateContact` sur une société de LYO qui a un besoin dans PAR → **ok**, le témoin sans besoin → DROIT. D-58 tient aujourd'hui (`securite11/sorties_partagee_et_par_besoins.txt`), mais rien ne le garde.
- **Correction** : chaque issue `OK-METIER` attendue est déclarée (commande, champ, code), et toute autre fait rougir. Le monde de la porte crée, pour chaque valeur de périmètre, l'objet que cette valeur **permet**.
- **Porte** : P-339 exige, par passe, au moins un permis attendu joué et tenu par valeur de politique de périmètre qui en ouvre un (aujourd'hui 0 pour `par_besoins`).

### G-4 🟠 — Les contrôles B1 et D3 de la grille restent des greps figés (suite de G-1 du 10e tour, non traité)
- **Famille** : un contrôle écrit comme une commande figée reste vert quand la forme de la faute change.
- **Étendue mesurée** : B1 ne voit pas les **20 sites** de métier en dur que CONFORMITE11 C-1 prouve cassants. D3 rend 6 réécritures, dont une **après** D-40, que la case 15 tolère parce que la migration n'était « pas publiée ».
- **Correction de construction** : B1 devient une porte AST (toute comparaison ou insertion d'un littéral de code, tout `ORDER BY ordre … LIMIT 1`, toute comparaison de `ctx.commande` hors `executer.ts` → rouge sauf déclaration). D3 devient « une migration ne change plus dès son premier commit sur une branche partagée » : `git log --diff-filter=M` sur `lot-2` et `lot-2-brain`, pas seulement contre `main`.
- **Porte** : celle de CONFORMITE11 C-1 (a) et une case du cliquet : toute modification d'un `db/migrations/*.sql` déjà présent dans un commit antérieur de la branche → KO.

---

**Angles morts** : voir `SECURITE11.md` §3, commun aux trois brouillons. Propres à la grille : A1, F2 et les cases 1, 2, 14, 16, 17, 19 sont jugés sans `make test` ni cliquet lancés ; K5 n'est pas mesurable sur le poste ; la CI GitHub n'a pas été observée (G-2 est déduit de `ci.yml` et mesuré dans un clone neuf).
