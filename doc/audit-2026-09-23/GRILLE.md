# GRILLE3 — troisième audit · lot 2 · commit `416a7a3`

**42 contrôles comptés dans `_ops/GRILLE_AUDIT.md`, 42 passés.** 7 familles : A 5 · B 5 · C 5 · **K 5** · D 5 · E 5 · **F 12**.

| Verdict | Nombre |
|---|---|
| ✅ | 34 |
| 🟠 | 6 |
| 🟡 | 1 |
| 🔴 | 1 (K4) |

⛔ **Un seul 🔴 refuse le lot** : **K4 — le périmètre ne se juge pas sur l'objet pour les trois commandes d'unité.**

⚠️ Ce que je **n'ai pas** pu passer en entier : A1 (interdiction de lancer `make.sh` / `cliquet.sh`). J'ai mesuré ses deux moitiés mesurables : les assertions et l'égalité `test/` = `_ops/`.

---

## Le compte de la grille — recompté, pas recopié

La famille K annoncée par le BRAIN **existe** (K1→K5, 5 contrôles). Les contrôles **F12, B5, F9, A4, D5, F7** annoncés **existent tous les six**.

⚠️ **Écart de la grille elle-même** : le titre de F dit « **11 contrôles (F1 → F11)** » et le tableau en liste **12** (F1→F12). Le total d'en-tête, 42, est juste ; c'est le sous-titre de F qui est resté en arrière.

---

## A · LA PREUVE

| # | Verdict | Preuve mesurée |
|---|---|---|
| **A1** | ✅ *partiel* | `psql -f test/SPEC_ASSERTIONS_L7.sql` → **rc=0, 31 lignes `OK   M-`** ; `bash outils/plancher_assertions.sh _ops/SPEC_ASSERTIONS_L7.sql` → **31**. `cmp _ops/SPEC_ASSERTIONS_L7.sql test/SPEC_ASSERTIONS_L7.sql` → identiques. 15 murs distincts couverts (M-1→M-15). ⛔ `make test` non lancé (interdit par le mandat) : les espèces B/C/D ne sont pas dans ce verdict. `rapport/preuves/grille3/A1_assertions.txt` |
| **A2** | ✅ | `DROP TRIGGER tg_m10 ON ava.temps` puis relance → **rc=3, 18 OK au lieu de 31**, et le message exact : « ⛔ un temps saisi pour une autre ressource (M-10) — LE GESTE EST PASSÉ. » Trigger remis, 31 OK. `A2_apres_casse.txt` |
| **A3** | ✅ | `.github/workflows/ci.yml` : `fetch-depth: 0` (l.49), `git branch -f main origin/main` (l.51-57), `run: bash outils/cliquet.sh` (l.97). Aucun `db.yml`. `A3_F8_ci.txt` |
| **A4** | ✅ | `python _ops/outils/dossier.py` → **rc=0**, « OK · … 93 fichiers », aucun cri. `_ops/DOSSIER.html` restauré par `git checkout`, `git status` vide. `A4_dossier.txt` |
| **A5** | ✅ | `audit/` : **18 fiches**, dont E1→E7 et 9 fiches L2. |

---

## B · LE PARAMÉTRAGE

| # | Verdict | Preuve mesurée |
|---|---|---|
| **B1** | ✅ | **4 occurrences**, lues une par une, **aucune n'est un `if` métier** : `identite.ts:249,276` comparent une **catégorie** de référentiel (`extType?.categorie === "externe"`), `droits.ts:32,66` comparent un **type de périmètre** (`global`/`soi`), justifié D-9. `B1_server_web.txt` · `db/` : 0 ligne. |
| **B2** | ✅ | `SELECT count(*) FROM politique` = **173**. L'awk du registre §E sur §C = **172**, + `ui.theme.personnalise` déclarée en prose = **173**. Recoupement clé par clé : **une seule** clé en base hors tableau, c'est celle-là. |
| **B3** | ✅ | `WHERE valeur IS DISTINCT FROM valeur_defaut` → **0 ligne** au seed. |
| **B4** | ✅ | `ref_*` en base = **40** = registre §E (« 40 au 21/09 »). |
| **B5** | ✅ | ⚠️ **Le grep de la grille donne un faux positif.** Sur `db/migrations/*.sql` il rend **7 lignes** ; **en base, à l'état final, il n'en reste que 3** : `perimetre_type_code_check` et `ck_x6` (justifiés D-9), et `personne_coordonnee_check` qui n'est pas une liste de codes mais une cohérence (`type_code='reseau_social') = (reseau IS NOT NULL)`). Les CHECK de `contact.statut_code`, `personne_coordonnee.type_code` et `usage_code` **ont été retirés par 007** au profit de `ref_statut_contact`, `ref_type_coordonnee`, `ref_usage_coordonnee`. `B5_base.txt` |

---

## C · LES MURS

| # | Verdict | Preuve mesurée |
|---|---|---|
| **C2** | ✅ | `has_table_privilege('ava_app', …, 'DELETE'/'TRUNCATE')` → **0 ligne**. Serveur connecté : `pg_stat_activity.usename = ava_serveur`, `rolsuper = f` (le serveur refuse de démarrer sinon, `index.ts:310`). |
| **C3** | ✅ | UPDATE sur `evenement_metier`, `snapshot_marge`, `prestation_version` → **0 ligne**. |
| **C4** | ✅ | `ava_lecture_agregats` atteint **exactement 7 relations** : `politique`, `ref_devise`, `ref_pays`, `v_ca_provisoire_par_devise`, `v_ca_realise_par_devise`, `v_marge_par_devise`, `v_occupation_valorisee_par_devise`. Aucune fuite. `C4.txt` |
| **C5** | ✅ | Les 7 murs-triggers sont posés : `tg_m4_m14` (prestation), `tg_m6` (snapshot_marge), `tg_m7` + `tg_m7_tentative`, `tg_m10` (temps), `tg_m12` (×4 tables), `tg_ajout_seul` (prestation_version). 70 triggers non internes au total. `C5_triggers.txt` |
| **C1** | ✅ | `grep -rn tenant db/` → **3 lignes, toutes des commentaires** expliquant l'absence délibérée (ADR-000). Aucune colonne. |

---

## K · L'ACCÈS — la famille ajoutée le 22/09

| # | Verdict | Preuve mesurée |
|---|---|---|
| **K1** | 🟠 | Serveur démarré **sans `AVA_MODE`** : les **7 commandes sondées** (CreateCompany, SetPolicy ×2, ManageGroups, RecordTimesheet, avec et sans `x-ava-groupe`, avec `x-ava-session`) rendent **HTTP 401 / `DROIT` / « authentification non livrée (lot 2c) »**, et **0 écriture métier** (`evenement_metier` 99→99, `societe` 2589→2589). ⛔ **Mais « 0 ligne écrite » est faux** : `tentative_refusee` passe de 55 à 62, et **60 POST anonymes y écrivent 60 lignes**. Et `/vues/besoins` sert **1932 besoins sans aucun en-tête** — voir SECURITE3 I-01. `securite3/hors_banc.txt` |
| **K2** | ✅ | Aucune table de session dans le schéma (`%session%` → aucune). L'UUID du compte ADM envoyé comme `x-ava-session` → `DROIT « session absente »` ; envoyé comme `x-ava-groupe` → `DROIT « groupe inconnu ou sans compte de banc »`. Une session n'est donc jamais un identifiant de compte. ⚠️ Le jeton aléatoire/haché/expirant de D-10 n'existe pas encore (lot 2c). `securite3/K2_K3.txt` |
| **K3** | ✅ | `UPDATE compte SET actif=false WHERE email='adm@ava.test'` puis appel `x-ava-groupe: ADM` → `DROIT`, `evenement_metier` **100→100**. Compte réactivé. |
| **K4** | 🔴 | **Trois commandes mutent un objet d'une autre agence.** Objets semés en agence **AVFR**, session en agence **PAR** : `CreateUnit` crée une unité interne rattachée à AVFR (**OK**, événement `UnitCreated`), `UpdateUnit` la renomme (**OK**), `ArchiveService` l'archive (**OK**). Contrôle positif : les mêmes commandes réussissent sur un objet PAR, et **9 autres commandes refusent bien `DROIT` sur l'objet AVFR**. `securite3/perimetre_objet.txt` + `perimetre_controle_positif.txt` |
| **K5** | 🟠 | `pg_hba_file_rules` : **6 règles `trust`** (local all, host 127.0.0.1, host ::1, + réplication). C'est le poste de dev, donc toléré par la lettre du contrôle — ⚠️ mais **rien dans le dépôt ne mesure le `pg_hba` d'un serveur** : ni la CI, ni le cliquet, ni une assertion. `K5.txt` |

---

## D · LE DÉPÔT

| # | Verdict | Preuve mesurée |
|---|---|---|
| **D1** | ✅ | `git diff --stat origin/main HEAD -- _ops/` → **vide**. Le canon n'a pas bougé. |
| **D2** | ✅ | Aucun ORM : grep prisma/typeorm/sequelize/drizzle/knex → 0. |
| **D3** | ✅ | `git log --diff-filter=M origin/main..HEAD -- db/migrations/` → **vide**. |
| **D4** | 🟡 | **`REMARQUES.md` n'existe nulle part** (`find . -iname "REMARQUES*"` → 0). Le contrôle demande qu'il dise « aucune » plutôt que de manquer. |
| **D5** | 🟠 | **20 commits sur 128 n'ont pas de trailer `Role:`.** Répartition : banc 66 · *(vide)* 20 · brain 17 · greffe 16 · serveur 4 · ecran 3 · integrateur 2. Et **10 commits touchent `test/` sans `Role: banc`** (brain, greffe ×5, ecran, 3 vides). Cause : `core.hooksPath` **n'est pas posé** dans un clone neuf (F7), donc `commit-msg` n'a jamais été appelé. `D5_compte.txt`, `D5_test.txt` |

---

## E · L'ÉCRAN — ⛔ « jamais patcher le front »

| # | Verdict | Preuve mesurée |
|---|---|---|
| **E1** | ✅ | 0 occurrence. |
| **E2** | ✅ | 0 occurrence. |
| **E3** | ✅ | 0 occurrence. |
| **E4** | ✅ | 0 occurrence. |
| **E5** | ✅ | 1 « occurrence » : `web/src/fonts/JetBrainsMono-Regular.woff2`, **fichier binaire** — faux positif du grep. |

⭐ **Lu à l'œil, comme la grille l'exige** : `web/src/` = 10 fichiers. Aucun objet `LABELS`, aucun libellé d'état en dur ; `rendu.tsx` ne connaît que des formes (`pastille`, `bouton`), les libellés viennent tous du serveur (`cellules[].libelle`, `etats[].libelle`). ⭐ **La frontière tient.**

---

## F · LE CLIQUET — 12 cases lues, jamais lancées

⛔ `outils/cliquet.sh` **lu**, pas exécuté (mandat). **12 cases, 12 mesurées, 0 déclarée.**

| # | Verdict | Preuve mesurée |
|---|---|---|
| **F1** | ✅ | `journal/PORTES.md` : **269 portes**, colonnes `Porte · Espèce · Phrase · Test · Vue rouge · État · Lot cible · Tolérance`. |
| **F2** | ✅ *avec réserve* | Les **quatre espèces tournent** : A BASE **1** · B CONTRAT **260** · C GESTE **2** · D ÉCRAN **6**. ⚠️ L'écran et le geste, celles qu'on oublie, pèsent 8 portes sur 269. |
| **F3** | ✅ | Contre **`origin/main`** (⛔ `main` n'existe pas en local dans le clone — le cliquet le rattrape, mon premier calcul l'avait pris pour « rien à comparer ») : **5 portes servies sur main, 0 disparue** de HEAD. |
| **F10** | ✅ | Aucune porte servie de `origin/main` n'est autre chose que ✅ dans HEAD. |
| **F11** | ✅ | **5 portes ⏳**, toutes avec un lot cible, **aucune** en deçà du lot 2. Aucun parking. |
| **F12** | ✅ | Servies de `HEAD~1` disparues de HEAD : **aucune**. Servies de `origin/main` : aucune. **264 ✅ / 5 ⏳ / 269 total** — le chiffre « 264 portes » du BRAIN est **vérifié**. |
| **F4** | ✅ | `grep -RInE '\.only|\.skip|xit|todo|disabled:true' test/` (hors node_modules) → **0 ligne**. |
| **F5** | ✅ | Colonne « Vue rouge » : **0 porte vide**. |
| **F6** | ✅ | Les 12 cases se **calculent**. Case 1 exige bien les **trois** conditions de V-008 : `make_rc=0`, aucune porte ✅ en échec ni échec anonyme, **et chaque porte ✅ exécutée** (`non_jouees` par `comm`). Case 2 compte `OK   M-` contre le plancher **et** exige `cmp` canon/copie. Aucune case ne pose de question. |
| **F7** | 🟠 | `git config core.hooksPath` → **vide** dans un clone neuf. La case 12 le mesure et serait **KO**. La CI le pose (`bash outils/installer.sh`, l.94) — mais le poste d'un agent ne l'a pas tant qu'il n'a pas lancé le script, et c'est précisément ce que D5 montre : 20 commits sans trailer. |
| **F8** | ✅ | `ci.yml:97` → `run: bash outils/cliquet.sh`. **Le même script**, pas une copie. |
| **F9** | ✅ | Aucun `set -e`, aucun `exit` dans `line()` : les 12 cases s'impriment toutes, puis `exit 0/1` en fin de fichier. |

---

# Les constats de la grille

---

**G-01 · Le périmètre ne se juge pas sur l'objet pour les trois commandes d'unité.**
Cible **CODE** · famille **K4 / C** · **critique** ·
preuve : `rapport/preuves/securite3/perimetre_objet.txt` — `CreateUnit` → `{"ok":true,…"agence_id":"f0000000-…-0001"}` alors que le compte est en agence PAR ; `UpdateUnit` et `ArchiveService` de même sur l'unité `aa000000-…-0003` ·
reproduire : serveur de banc sur `ava_audit3_b`, objets semés en AVFR, puis
```bash
curl -s -X POST http://127.0.0.1:3302/commandes/UpdateUnit -H 'content-type: application/json' -H 'x-ava-groupe: IA' -d '{"id":"aa000000-0000-4000-8000-000000000003","nom":"Renomme par PAR"}'
```
· prétend : MATRICE §procedure étape 4, « le périmètre se juge sur l'objet visé » ·
mesure : `server/src/commandes/crm.ts` ne contient **aucun** appel à `exigeObjet` — c'est le seul des cinq fichiers de commandes dans ce cas, et `unite_organisation` porte pourtant `agence_id` ·
correction : résoudre l'agence de l'unité (et de son parent) et appeler `exigeObjet` dans `CreateUnit`, `UpdateUnit`, `ArchiveService`.

---

**G-02 · Hors mode banc, un POST anonyme écrit une ligne en base.**
Cible **CODE** · famille **K1** · **elevee** ·
preuve : `securite3/hors_banc.txt` — `tentative_refusee` 63 → **123** après 60 POST anonymes ; `auteur_compte_id IS NULL` sur toutes ·
reproduire :
```bash
for i in $(seq 1 60); do curl -s -o /dev/null -X POST http://127.0.0.1:3302/commandes/CreateCompany -H 'content-type: application/json' -d '{}'; done
```
· prétend : K1, « toute commande → refus, **0 ligne écrite** » ·
mesure : `index.ts:236` appelle `refuserAuthentificationNonLivree` **avant** le 401 ; `executer.ts:129` insère dans `tentative_refusee` sans aucune authentification ni limite ·
correction : hors `AVA_MODE=banc`, rendre le 401 **sans tracer** — la trace d'un refus n'a de sens qu'une fois l'appelant identifié.

---

**G-03 · `REMARQUES.md` manque.**
Cible **CODE** · famille **D4** · **bonne→moyenne** (🟡) ·
preuve : `find . -iname "REMARQUES*"` → aucun résultat ·
reproduire : `ls REMARQUES.md _ops/REMARQUES.md` ·
prétend : « il doit dire *aucune* plutôt que manquer » ·
mesure : absent des deux emplacements ·
correction : créer le fichier avec une ligne « aucune ».

---

**G-04 · Un commit sur six n'a pas de trailer `Role:`, parce que le crochet n'est pas posé.**
Cible **CODE** · famille **D5 / F7** · **moyenne** ·
preuve : `grille3/D5_compte.txt` — 20/128 sans trailer, 10 commits touchant `test/` sans `Role: banc` ; `git config core.hooksPath` vide ·
reproduire :
```bash
git log --format='%h %(trailers:key=Role,valueonly)' origin/main..HEAD | awk 'NF<2'
```
· prétend : D5, « le crochet le refuse sinon » ·
mesure : dans un clone neuf, `commit-msg` n'est jamais appelé ; la case 12 du cliquet le voit, mais elle ne tourne qu'au `push` — les 20 commits sont déjà écrits ·
correction : poser `core.hooksPath` dans `outils/installer.sh` **et** le faire lancer au premier `make`, pas seulement en CI.

---

**G-05 · Le grep de B5 accuse quatre CHECK qui n'existent plus.**
Cible **BRAIN** · famille **B5** · **moyenne** ·
preuve : `grille3/B5_checks.txt` (7 lignes dans les migrations) contre `B5_base.txt` (**3 contraintes en base**) ·
reproduire :
```bash
psql -d ava_audit3_b -c "SELECT cl.relname, pg_get_constraintdef(c.oid) FROM pg_constraint c JOIN pg_class cl ON cl.oid=c.conrelid JOIN pg_namespace n ON n.oid=cl.relnamespace WHERE n.nspname='ava' AND c.contype='c';"
```
· prétend : B5, « chaque ligne doit être justifiée au registre » ·
mesure : `contact.statut_code`, `personne_coordonnee.type_code` et `usage_code` ont été **remplacés par des référentiels en 007** ; le grep lit l'histoire, pas l'état ·
correction : B5 se mesure sur `pg_constraint`, comme C2/C3/C4 le font déjà — « par ce qu'on atteint, pas par ce qu'on a écrit ».

---

**G-06 · Les cases 5 et 10 du cliquet lisent les colonnes par position.**
Cible **CODE** · famille **F6** · **moyenne** ·
preuve : `outils/cliquet.sh` — case 5 lit `$6` (vue rouge), case 10 lit `$7` et `$8` (état, lot cible), alors que `portes_etats()` cherche « État » **par son en-tête** (V-009) ·
reproduire : lire les lignes de `awk -F'|'` des cases 5 et 10 ·
prétend : V-009, « l'état d'une porte se lit dans la colonne trouvée par son en-tête, jamais par sa position » ·
mesure : aujourd'hui les positions coïncident (col 6/7/8 = Vue rouge/État/Lot cible), donc **aucune fausse mesure** — mais une colonne insérée les décale en silence ·
correction : faire lire ces deux cases par `portes_etats()` ou par la même recherche d'en-tête.

---

**G-07 · Deux compteurs d'assertions, deux chiffres.**
Cible **CODE** · famille **A1/A4** · **moyenne** ·
preuve : `dossier.py` imprime `assertions=30` ; `plancher_assertions.sh` rend **31** ; l'exécution produit **31** lignes `OK   M-` ·
reproduire :
```bash
python _ops/outils/dossier.py | grep assertions ; bash outils/plancher_assertions.sh _ops/SPEC_ASSERTIONS_L7.sql
```
· prétend : registre §E, « un compte ne se retient pas, il se mesure » ·
mesure : deux règles de comptage différentes sur le même fichier ·
correction : faire appeler `plancher_assertions.sh` par `dossier.py` — un seul compteur.

---

**G-08 · Le sous-titre de la famille F annonce 11 contrôles et en liste 12.**
Cible **BRAIN** · famille **F** · **moyenne** ·
preuve : `_ops/GRILLE_AUDIT.md` — « ## F · LE CLIQUET — 11 contrôles (F1 → F11) », tableau F1…F12 ·
reproduire : `grep -n "F · LE CLIQUET" _ops/GRILLE_AUDIT.md` ·
prétend : 42 contrôles au total ·
mesure : 5+5+5+5+5+5+**12** = 42 — le total est juste, le sous-titre non ·
correction : écrire « 12 contrôles (F1 → F12) ».

---

**G-09 · Rien ne mesure le `pg_hba` d'un serveur.**
Cible **CODE** · famille **K5** · **moyenne** ·
preuve : `grille3/K5.txt` — 6 règles `trust` ; aucune assertion ni case de cliquet ne lit `pg_hba_file_rules` ·
reproduire : `psql -c "SELECT auth_method, count(*) FROM pg_hba_file_rules GROUP BY 1;"` ·
prétend : K5, « 0 `trust` sur un serveur » ·
mesure : le contrôle existe dans la grille, **pas dans le cliquet** — il ne tournera donc jamais tout seul ·
correction : une 13ᵉ case, conditionnée à un `AVA_ENV != dev`.

---

**G-10 · bien fait (bonne).** A2 **prouvé** : le mur retiré, la suite tombe avec le bon message — c'est le contrôle que personne ne fait. C4 : exactement 7 relations, aucune fuite (V-001 refermé). F3/F10/F12 numéro par numéro, **264 servies, 0 perdue**. B2 : 173 = 173, recoupé clé par clé contre le registre. D1 : le canon n'a pas bougé d'une ligne. La frontière de l'écran tient à l'œil comme au grep. Le cliquet **mesure** ses 12 cases et les imprime toutes.

---

## Verdict

```
LOT 2 — REFUSÉ · 1 🔴 · 6 🟠 · 1 🟡
K4  CreateUnit, UpdateUnit, ArchiveService mutent une unité d'une autre agence
K1  hors banc, 60 POST anonymes = 60 lignes dans tentative_refusee
→ la liste complète : GRILLE3.md, G-01 à G-10 ; la fuite des vues : SECURITE3.md, I-01
```

---

# ANGLES MORTS — ce que ce troisième audit n'a pas vu

⛔ **À lire avant de prendre un ✅ pour une garantie.**

| # | L'angle mort | Ce qu'il laisse passer |
|---|---|---|
| **1** | **Je n'ai pas lancé `make.sh` ni `cliquet.sh`** (interdits par le mandat). A1 est donc **partiel** : les 260 portes B CONTRAT, les 2 C GESTE et les 6 D ÉCRAN **n'ont pas tourné devant moi**. J'ai lu le cliquet et mesuré ses entrées (portes, `_ops/`, skips, hooks) — je n'ai pas vu ses cases s'allumer | une porte ✅ qui échouerait aujourd'hui ; un golden d'écran périmé ; un serveur de banc qui ne démarre pas en CI |
| **2** | **J'ai monté la base moi-même**, pas par `make migrate`. Si `make.sh` fait autre chose que `psql -f db/migrations/*.sql` dans l'ordre, ma base n'est pas celle du banc | une divergence entre la base que je mesure et celle que la CI mesure |
| **3** | **`_ops/` n'a que 9 fichiers qui font foi** pour moi (mandat d'indépendance). Je n'ai lu ni `PLAN_*`, ni les prompts, ni `JOURNAL_BUGS`, ni `ARBITRAGE_*` : **je ne sais pas ce qui a déjà été arbitré**. Certains de mes constats sont peut-être des décisions assumées | je peux signaler comme défaut ce qui a été tranché ; je peux rater un engagement pris ailleurs |
| **4** | **Le périmètre par objet, je l'ai sondé sur 15 commandes sur 55.** J'ai couvert celles du 2ᵉ audit, celles qui portent `agence_id`, et j'ai lu le code des 40 autres — mais je n'ai pas joué chaque commande contre chaque objet d'une autre agence | un 16ᵉ trou dans une commande que je n'ai pas sondée |
| **5** | **Un seul axe de périmètre testé : `agence`.** Le seed ne contient aucun périmètre `pole` ni `equipe`, et aucune ligne de `compte_surcharge`. ⛔ **`droits.surcharge_restrictive` n'a donc jamais été éprouvée sur un cas réel** — et c'est la clé que C-03 signale comme invisible à l'écran | toute la mécanique de surcharge nominative, et les périmètres d'unité |
| **6** | **Un seul compte par groupe.** `compteDuGroupe` prend « le premier actif par email » : je n'ai jamais pu vérifier ce qui se passe quand deux comptes partagent un groupe, ni qu'un compte hors PAR agisse vraiment | le vrai test multi-agences, avec des sessions de plusieurs agences |
| **7** | **Aucune concurrence.** Tout est séquentiel. `nextRef()` prend un `pg_advisory_xact_lock`, l'unicité de positionnement fait un `SELECT … LIMIT 1` puis un `INSERT` — je n'ai pas cherché la course entre deux | un doublon de positionnement, deux références de projet identiques |
| **8** | **Aucune charge, aucune taille.** `/vues/besoins` rend **1932 lignes d'un coup, sans pagination** : je l'ai noté comme fuite (I-01), pas mesuré comme déni de service. Idem pour la taille du corps accepté par `tentative_refusee` | l'effondrement sous volume, la mémoire du serveur |
| **9** | **Le front n'a pas été rendu.** Grep + lecture à l'œil de 10 fichiers ; aucun navigateur ouvert, aucune capture comparée | une régression visuelle, un libellé calculé au rendu, un état deviné en JSX |
| **10** | **Je n'ai pas relu les 15 murs contre `SPEC_SQL_AVAMANAGER_V1.sql`.** J'ai vérifié que les 31 assertions passent et qu'elles **tombent** quand on casse M-10 — je n'ai pas vérifié que les 31 assertions couvrent ce que la spéc décrit | un mur décrit dans la spéc et absent de la base, qu'aucune assertion ne cherche |
| **11** | **Les migrations, jouées une seule fois, dans l'ordre, sur une base vide.** Ni rejeu, ni base existante, ni migration partielle | une migration non idempotente, un `ON CONFLICT` manquant |
| **12** | **J'ai modifié ma base pendant l'audit** : posé `ArchiveObject`/`ArchiveService` en périmètre PAR pour pouvoir jouer leurs gardes, basculé six politiques puis remises au défaut (`valeur = valeur_defaut`, vérifié à 0 écart). ⚠️ Les mesures postérieures à ces gestes portent une base qui n'est plus le seed exact | un effet de mes propres gestes que je n'aurais pas vu |
| **13** | **`dossier.py` a réécrit `_ops/DOSSIER.html`**, restauré par `git checkout` ; `git status` est vide à la fin. Mais j'ai bien écrit dans le clone une fois | rien, si la restauration est complète — elle l'est |
