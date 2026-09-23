# GRILLE4 — les 42 contrôles de `_ops/GRILLE_AUDIT.md`, mesurés

**Quatrième audit · lot 2 · commit `cc3ff64` · 23/09/2026.**
Poste : clone de lecture `ava-audit-4-lecture` (aucun fichier modifié) · base `ava_audit4_b` · port 3402.
⛔ `outils/make.sh` et `outils/cliquet.sh` n'ont **pas** été lancés. `cliquet.sh` a été **lu**.

**Compte des contrôles, recompté dans le fichier** — `grep -oE '^\| \*\*([A-FK][0-9]+)\*\*' _ops/GRILLE_AUDIT.md` :
**42 contrôles · 7 familles** (A 5 · B 5 · C 5 · D 5 · E 5 · F 12 · K 5). Le chiffre annoncé en tête du canon est juste.

## VERDICT

| | |
|---|---|
| 🔴 | **1** — A1 |
| 🟠 | **7** — A3 · A4 · D5 · F2 · F7 · K2 · K5 |
| 🟡 | **1** — D4 |
| ✅ | **33** |

⛔ **Un seul 🔴 refuse le lot entier** (canon, ligne 5). **LOT 2 — REFUSÉ.**

---

## A · LA PREUVE

| # | Verdict | Preuve mesurée |
|---|---|---|
| **A1** | 🔴 | Base **neuve** (`DROP`/`CREATE`, 9 migrations, `banc.sql`), 8 fichiers de contrat joués un par un : **1 porte rouge, P-207**. Voir le constat **G-01**. Le reste de A1 tient : `cmp _ops/SPEC_ASSERTIONS_L7.sql test/SPEC_ASSERTIONS_L7.sql` → **identiques** ; plancher compté = **31** ; `OK   M-` comptés à l'exécution = **31** ; `psql -f` sort **0**. Preuves : `grille4/assertions.txt`, `grille4/portes_base_neuve.txt` |
| **A2** | ✅ | `DROP TRIGGER tg_m10 ON ava.temps` puis relance : `psql` sort **3** et lève `⛔ un temps saisi pour une autre ressource (M-10) — LE GESTE EST PASSÉ`. 31 → **18** lignes `OK   M-`. Trigger remis, retour à 31/rc=0. Preuve : `grille4/a2_sans_tg_m10.txt` |
| **A3** | 🟠 | `.github/workflows/ci.yml` : `fetch-depth: 0` ✅, `main` reconstruit en local avant le cliquet ✅, `run: bash outils/cliquet.sh` (l. 97) ✅. 🟠 **non exécutable ici** : la CI dépend de deux secrets GitHub (`CI_POSTGRES_PASSWORD`, `CI_SERVEUR_PASSWORD`) qu'un auditeur ne peut pas voir ; rien dans le dépôt ne prouve qu'ils sont posés. Voir **G-02** |
| **A4** | 🟠 | `python _ops/outils/dossier.py` (joué sur une **copie** de `_ops/`, pour ne pas toucher le clone) **CRIE** : `⚠️ ECART : le SQL cree 34 referentiels, le registre en compte 40. Un des deux ment.` Voir **G-03** |
| **A5** | ✅ | `audit/` : `E1.md` → `E7.md` (7 étapes) + 10 fiches `L2-*.md` + `README.md`. Le lot 1 en a 5, le lot 2 en a 10 |

---

## B · LE PARAMÉTRAGE

| # | Verdict | Preuve mesurée |
|---|---|---|
| **B1** | ✅ *(avec réserve lue)* | Le grep du canon rend **5 occurrences**, toutes **justes** : `identite.ts:215,241` compare une **catégorie de référentiel** lue en base (`ref_type_ressource.categorie === "externe"`), `droits.ts:32,62` et `index.ts:201` comparent un **`perimetre.type_code`** — les 4 valeurs sont figées par un CHECK justifié (D-9). ⚠️ Le grep du canon **ne voit pas** deux familles que j'ai lues à l'œil : **2 listes de codes métier en dur** (`besoin.ts:313-314`) et **20 littéraux de catégorie dans le SQL du serveur**. Voir **G-04** et **G-05**. Preuve : `grille4/greps.txt` |
| **B2** | ✅ | `SELECT count(*) FROM ava.politique` = **173**. Registre §E = **173** (recompté par l'`awk` du registre : 172 en tableau + 1 en prose). Égalité |
| **B3** | ✅ | `WHERE valeur <> valeur_defaut` → **0** ligne sur base fraîchement migrée |
| **B4** | ✅ | `ref_*` en base = **40**. Registre §E = **40**. Égalité. ⚠️ mais le **canon SQL** n'en décrit que 37 — c'est le cri de A4, constat **G-03** |
| **B5** | ✅ | 7 `CHECK ... IN` mesurés, tous justifiés : `contact.statut_code` (D-9 · 001:658), `perimetre.type_code` (D-9 · 001:1192 + 008:40), `personne_coordonnee.type_code`/`usage_code` (D-9 · 006:105,108,115), `snapshot_marge` devises (M-15 · 001:1153). **Aucun CHECK ne fige une liste d'états métier** |

---

## C · LES MURS

| # | Verdict | Preuve mesurée (`grille4/murs.txt`) |
|---|---|---|
| **C1** | ✅ | `grep -rn "tenant" db/` → 3 lignes, **toutes des commentaires** qui expliquent pourquoi il n'y en a pas (001:34, 39, 1365). Aucune colonne |
| **C2** | ✅ | La requête du canon → **0 ligne** pour `ava_app`. Idem pour `ava_serveur` (le rôle réellement utilisé), que j'ai mesuré en plus. `pg_stat_activity` pendant que le serveur tourne : `usename = ava_serveur`, `rolsuper = f` |
| **C3** | ✅ | 0 ligne `UPDATE` sur `evenement_metier`, `snapshot_marge`, `prestation_version`. Vérifié aussi **par le geste** : `UPDATE snapshot_marge SET marge = 0` → `snapshot_marge est en ajout seul (MUR M-6)` |
| **C4** | ✅ | **Exactement 7 relations** atteintes par `ava_lecture_agregats` : `politique`, `ref_devise`, `ref_pays`, `v_ca_provisoire_par_devise`, `v_ca_realise_par_devise`, `v_marge_par_devise`, `v_occupation_valorisee_par_devise`. Ni plus, ni moins |
| **C5** | ✅ | Les 7 murs-triggers sont là : `tg_m4_m14` (prestation), `tg_m6` (snapshot_marge), `tg_m7` (evenement_metier) **+ `tg_m7_tentative`**, `tg_m10` (temps), `tg_m12` (×4 : besoin, contact, projet, unite_organisation), `tg_ajout_seul` (prestation_version). 70 triggers non internes au total |

---

## K · L'ACCÈS

| # | Verdict | Preuve mesurée (`securite4/acces4.txt`) |
|---|---|---|
| **K1** | ✅ | Serveur lancé **sans `AVA_MODE`**. 11 routes sondées : `/sante` → 200 ; `/vues/besoins`, `/vues/besoins/<uuid>`, `/acquitter`, `/commandes/CreateCompany`, `/commandes/SetPolicy`, `/commandes/ManageRefs`, `/`, `/besoins`, `/index.html`, `/n-importe-quoi` → **401** tous, corps `{"ok":false,"code":"DROIT"}`, **`lignes` absent**. Compteurs avant/après : `besoin` 118→118, `evenement_metier` 1855→1855, **`tentative_refusee` 551→551**. ⭐ **V-078 est fermé** : un POST anonyme hors banc n'écrit plus rien. Le hook `preHandler` de `index.ts:114-125` est le seul garde, et il couvre le `setNotFoundHandler` et le statique |
| **K2** | 🟠 | ✅ L'UUID d'un compte envoyé comme session est **refusé** (`DROIT « compte inconnu ou inactif »` en banc, 401 hors banc) ; témoin e-mail → `ok=true`. 🟠 **Mais le jeton n'existe pas** : l'en-tête `x-ava-groupe` est un **e-mail en clair**, ni aléatoire, ni haché, ni expirant. D-10 est annoncé **lot 2c** par le message du serveur lui-même (`authentification non livrée (lot 2c)`). Voir **G-06** |
| **K3** | ✅ | `UPDATE compte SET actif=false WHERE email='ia@ava.test'` → `CreateCompany` rend `DROIT « compte inconnu ou inactif »`, `societe` 134→**134**. Compte réactivé → `ok=true` |
| **K4** | ✅ | `server/src/agence.ts` porte la table `commande → table → colonne d'agence`. Recomptée : **55 lignes**, **55 handlers**, **55 commandes L4**, **0 écart** dans les deux sens. Une commande sans sa ligne est refusée (`executer.ts:150`, `GARDE « commande sans correspondance d'agence »`). **40 sondes hors agence → `DROIT`, 0 écriture ; 25 témoins positifs dans le périmètre → `ok=true`** (`securite4/perimetre4.txt`). ⚠️ **Deux trous subsistent** — ils ne tombent pas sous K4, qui parle des 55 lignes : voir **I-01** et **I-02** dans SECURITE4 |
| **K5** | 🟠 | `bash outils/verif_serveur.sh` **tourne et mesure** (lu ligne à ligne : `pg_hba_file_rules`, `listen_addresses`, `rolpassword`, `rolcanlogin`). Sur ce poste il sort **1** : 6 règles `trust`, `listen_addresses = *`, `ava_serveur` **sans mot de passe** ; avec `AVA_POSTE_DEV=1` il sort **0**. 🟠 **Il n'a jamais été passé sur un serveur** — il n'y en a pas encore. Voir **G-07** |

---

## D · LE DÉPÔT

| # | Verdict | Preuve mesurée (`grille4/depot.txt`) |
|---|---|---|
| **D1** | ✅ | `git diff --stat origin/main HEAD -- _ops/` → **vide**. ⭐ Le contrôle le plus important de la grille tient : le canon commande, il ne suit pas. *(le clone n'a pas de branche `main` locale ; `origin/main` = `777714c`, c'est la référence que `cliquet.sh` prend lui-même en secours)* |
| **D2** | ✅ | `grep -rniE "prisma\|typeorm\|sequelize\|drizzle\|knex"` sur les `package.json` → vide. Le serveur parle `pg` |
| **D3** | ✅ | `git log --diff-filter=M origin/main..HEAD -- db/migrations/` → **vide**. Aucune migration réécrite sur 141 commits |
| **D4** | 🟡 | `REMARQUES.md` **n'existe pas**. Le canon veut qu'il dise « aucune » plutôt que de manquer |
| **D5** | 🟠 | 141 commits depuis `origin/main`. **20 sans trailer `Role:`** — tous antérieurs au crochet (`19237f6` et plus anciens). Les 121 récents en portent un, et le crochet `commit-msg` l'exige désormais. Voir **G-08** |

---

## E · L'ÉCRAN

⭐ **Lu à l'œil en entier** : `web/src` fait **631 lignes** en 9 fichiers.

| # | Verdict | Preuve |
|---|---|---|
| **E1** | ✅ | Grep vide. À l'œil : les seules conditions de `rendu.tsx` sont `cellule.nature === "donnee"`, `action.variante === "plus"/"export"`, `cellule.pastille` — de la **présentation**, pas du métier |
| **E2** | ✅ | Grep vide. Aucun calcul d'argent |
| **E3** | ✅ | Grep vide, **et** aucun objet `const LABELS = {…}` — c'est ce que le canon dit qu'aucun grep n'attrape. Les libellés arrivent du serveur (`etat.libelle`, `action.libelle`) |
| **E4** | ✅ | Vide |
| **E5** | ✅ | Le seul hit est `JetBrainsMono-Regular.woff2` (fichier binaire). Aucun SQL, aucun ORM. Les 3 appels réseau sont `fetch("/sante")`, `fetch("/acquitter")`, `fetch(chemin)` |

---

## F · LE CLIQUET — `outils/cliquet.sh` **lu, jamais lancé**

`journal/PORTES.md` recompté : **285 portes · 280 ✅ · 5 ⏳** (P-061 → P-065, toutes lot cible **3**).

| # | Verdict | Preuve mesurée (`grille4/portes.txt`) |
|---|---|---|
| **F1** | ✅ | Le tableau existe, en-tête `\| Porte \| Espèce \| Phrase \| Test \| Vue rouge \| État \| Lot cible \| Tolérance \|`, une ligne par porte |
| **F2** | 🟠 | Les quatre espèces sont **déclarées** : `A BASE` 1 · `B CONTRAT` 276 · `C GESTE` 2 · `D ÉCRAN` 6. J'ai fait tourner A (31 assertions) et B (277 tests, 8 fichiers). 🟠 **C et D n'ont pas été rejoués** : Playwright exige `web/dist`, donc un `npm run build` **dans le clone de lecture**, ce que ma consigne interdit. Les goldens sont versionnés et la case 1 du cliquet exige leur exécution ; je ne peux pas le prouver moi-même |
| **F3** | ✅ | **Numéro par numéro** : 5 portes servies sur `origin/main`, **0 disparue** de HEAD |
| **F10** | ✅ | Aucune porte servie sur `origin/main` n'est autre chose que ✅ dans HEAD |
| **F11** | ✅ | Les 5 ⏳ portent toutes **lot cible 3** ; le lot courant est 2. Aucun parking |
| **F4** | ✅ | `grep -rniE '\.skip\|test\.only\|xit\(\|xdescribe'` hors `node_modules` → **vide**. ⚠️ **Ce que F4 ne voit pas** : `test/playwright.config.ts` porte `testIgnore: ["**/besoin.spec.ts"]`. J'ai vérifié : les 4+1 tests ainsi exclus sont **exactement** P-061 → P-065, c'est-à-dire **les 5 ⏳**. La parade ⏳ est donc légitime — mais elle passe par un mécanisme que le grep de F4 ne regarde pas. Seule la case 1 du cliquet (« porte ✅ non jouée ») l'attraperait. Voir **G-09** |
| **F5** | ✅ | Aucune porte sans date de vue rouge |
| **F6** | ✅ | **Lu** : 12 cases, **aucune ne se déclare**. La case 1 exige les trois conditions de V-008 : `make_rc = 0` **et** aucune porte ✅ en échec **et** `non_jouees` vide (chaque ✅ retrouvée dans la sortie de `make test`). Aucune question n'est posée à personne |
| **F7** | 🟠 | Dans ce clone, `git config --get core.hooksPath` est **vide** → la case 12 du cliquet sortirait **KO**. C'est le comportement documenté d'un clone neuf (`bash outils/installer.sh` le pose) ; je ne peux pas mesurer le dépôt de travail, je n'ai pas le droit d'y toucher. `.githooks/pre-push` existe et appelle bien `outils/cliquet.sh` |
| **F8** | ✅ | `ci.yml:97` → `run: bash outils/cliquet.sh`. Le **même** script, pas une copie |
| **F9** | ✅ | **Lu** : chaque case appelle `line`, qui `printf` puis incrémente `ok`/`ko` ; le script ne sort qu'à la fin (l. 296-299). Aucun `exit` intermédiaire, aucun `set -e` (`set -u` seulement) |
| **F12** | ✅ | Fenêtre `merge-base main HEAD` → HEAD, plus `main` : aucune porte ✅ perdue. La case ajoute `f12_hors` — une porte **exécutée** absente du tableau est KO (D-17) |

---

# LES CONSTATS

---

**G-01 · Sur une base neuve, la porte P-207 est rouge : elle exige de `ManageRefs` exactement ce que la porte P-280 lui interdit.**
Cible **CODE** (banc) · famille **A1 / F** · **critique** ·
preuve : base neuve, 8 fichiers de contrat, **1 seul échec** —
```
✖ P-207 matrice admin : passe, hors périmètre, sans le groupe
  AssertionError: ManageRefs ADM: {"ok":false,"code":"GARDE","message":"catégorie inconnue"}
```
et, dans le **même** tour, `✔ P-280 ManageRefs refuse une catégorie inconnue sur ref_pays`.
reproduire :
```bash
export PGCLIENTENCODING=UTF8
psql -U postgres -d postgres -c "DROP DATABASE IF EXISTS b WITH (FORCE);" -c "CREATE DATABASE b;"
for f in db/migrations/*.sql; do psql -U postgres -d b -v ON_ERROR_STOP=1 --single-transaction -f "$f"; done
psql -U postgres -d b -f db/fixtures/banc.sql
curl -s -X POST http://127.0.0.1:3402/commandes/ManageRefs -H 'content-type: application/json' \
  -H 'x-ava-groupe: adm@ava.test' \
  -d '{"referentiel":"ref_pays","code":"zaud4","libelle":"V11","categorie":"europe"}'
# {"ok":false,"code":"GARDE","message":"catégorie inconnue"}
```
prétend : `journal/PORTES.md:218` — `P-207 | B CONTRAT | Matrice admin : passe, hors périmètre, sans le groupe | ✅ | lot 2 | base relue`.
mesure : `test/contrat/v011-lignes.ts:988-999` envoie `{referentiel:"ref_pays", categorie:"europe"}` et attend `ok=true`. Au seed, `ref_pays` ne contient que `AE, FR, MA, US`, **toutes en catégorie `defaut`**, et la table n'a **pas** de contrainte `ck_cat` (`ref_pays_pkey` est sa seule contrainte). `admin.ts:207-215` lit alors les catégories **déjà présentes** et refuse `europe`. ⭐ **La porte ne peut passer que sur une base où une ligne `categorie='europe'` existe déjà** — c'est-à-dire une base où le test a tourné **avant** que V-055 (`5b1e1a4`) n'ajoute la garde de catégorie. Elle est verte sur le poste du codeur et rouge partout ailleurs. Témoin : la même commande avec `categorie:"defaut"` rend `ok=true`.
correction : la ligne P-207 vise un référentiel **qui a une catégorie autre que `defaut`** (`ref_etat_besoin`, `ref_type_action`…), ou crée d'abord la catégorie. ⛔ **Ne pas retirer la garde** : P-280 la protège, et H-4 la réclamait.

---

**G-02 · Sept portes ✅ ne prouvent que l'absence d'une permission au seed : elles passent au rouge le jour où la délégation est posée.**
Cible **CODE** (banc) · famille **F / A1** · **elevee** ·
preuve : après avoir posé les 5 permissions absentes du seed (`ArchiveCompany`, `ArchiveContact`, `ArchiveService`, `ArchiveObject`, `UpdateResourceCost`) — exactement ce que fera une délégation en production, et ce que le 3ᵉ audit avait déjà fait — le **second tour** des mêmes fichiers rend :
```
✖ P-009 ArchiveCompany refuse DROIT     ✖ P-012 ArchiveService refuse DROIT
✖ P-016 ArchiveContact refuse DROIT     ✖ P-027 UpdateResourceCost refuse DROIT
   actual: 'INTROUVABLE' - expected: 'DROIT'
✖ P-056 ArchiveObject refuse DROIT
✖ P-127 matrice : sans le groupe → DROIT   (« CreateResource par IA: GARDE »)
✖ P-204 matrice identité : sans le groupe  (« CreateResource sans IA : ok=true »)
```
reproduire : `grille4/portes_second_tour.txt` · poser une permission d'agence puis rejouer `contrat/commandes.test.ts`.
prétend : `journal/PORTES.md` donne ces 7 portes ✅ pour le lot 2 ; L4 §I et §V décrivent pour ces commandes des **gardes** détaillées (« GARDE si objets actifs », « besoin ou projet actif »).
mesure : c'est le constat **C-10** du 3ᵉ audit, toujours ouvert et maintenant **reproduit dans les deux sens**. Les gardes existent et fonctionnent — je les ai jouées (`conformite4/refus4.txt` : `ArchiveCompany` → `des objets actifs empêchent l'archivage`, `ArchiveService` → `besoin ou projet actif sur cette unité`). ⛔ Mais **aucune porte ne les exerce**, et les portes qui portent leur nom testent le **seed**, pas la commande. Une porte qui devient rouge le jour où l'on fait ce qu'elle est censée protéger ne protège rien.
correction : 5 portes qui **posent la permission, jouent la garde, puis la retirent** — le motif `accorder`/`retirer` existe déjà dans `v011-lignes.ts`. Garder à part les portes « sans permission → DROIT ».

---

**G-03 · `dossier.py` crie : le canon SQL ignore les trois référentiels que la migration 007 a posés.**
Cible **BRAIN** · famille **A4 / B4** · **moyenne** ·
preuve :
```
⚠️  ECART : le SQL cree 34 referentiels, le registre en compte 40. Un des deux ment.
```
reproduire : `cp -r _ops /tmp/a4 && cd /tmp/a4 && python _ops/outils/dossier.py`
prétend : registre §E — « **40 au 21/09** · **+3 le 21/09 (D-9, migration 007)** : `ref_statut_contact`, `ref_type_coordonnee`, `ref_usage_coordonnee` ».
mesure : `comm` entre les noms `ref_*` de `_ops/SPEC_SQL_AVAMANAGER_V1.sql` et ceux de `db/migrations/*.sql` → **3 manquants dans le canon, et ce sont exactement ces trois-là**. Le registre a été mis à jour, la spec SQL non. ⚠️ Le fichier qui « fait foi » pour ce que la base refuse décrit un schéma que les migrations ont dépassé — et c'est lui que lira le lot 3.
correction : porter les trois tables dans `SPEC_SQL_AVAMANAGER_V1.sql`. ⛔ Sur `main` d'abord : D1 interdit de toucher `_ops/` depuis une branche de lot.

---

**G-04 · `RecordClientDecision` décide sur deux listes de codes métier écrites en dur.**
Cible **CODE** · famille **B1 / ADR-005** · **elevee** ·
preuve : `server/src/commandes/besoin.ts:313-314`
```ts
const positif = ["retenu", "terminal_positif", "oui", "accepte"].includes(decision);
const negatif = ["refuse", "refus", "refuse_client", "terminal_negatif", "non"].includes(decision);
```
reproduire : `grep -n 'const positif' server/src/commandes/besoin.ts`
prétend : ADR-005 et le registre — « tout ce qui bifurque est une politique » ; L4 §V — « `ManageRefs` : c'est ce qui permet aux **14 états Boond** d'entrer sans migration ».
mesure : le grep B1 du canon ne les voit pas (pas de `===`). Un admin qui ajoute `accepte_sous_reserve` dans `ref_etat_positionnement` avec `ManageRefs` verra la commande rendre `GARDE « décision inconnue »` : le référentiel est ouvert, la décision ne l'est pas. Les deux listes contiennent d'ailleurs des **catégories** (`terminal_positif`) mélangées à des **codes** (`retenu`) et à des mots libres (`oui`, `non`).
correction : lire la catégorie du code visé dans `ref_etat_positionnement` (`terminal_positif` / `terminal_negatif`) comme le fait déjà `SetResourceState` avec `ref_etat_ressource`, et refuser tout code hors référentiel actif.

---

**G-05 · Vingt requêtes du serveur comparent une catégorie d'état à un littéral SQL au lieu de la table `CAT`.**
Cible **CODE** · famille **B1** · **moyenne** ·
preuve : `grille4/greps.txt` §B1c — `crm.ts:111,112,244,246,369,370,397,398` · `admin.ts:96,109` · `besoin.ts:199,233` · `identite.ts:207,299` · `projet.ts:84,87,141,317,595`. Exemple : `WHERE ... AND etat_categorie NOT IN ('ferme')`. S'y ajoutent `crm.ts:138` (`role_code = 'interne'`), `crm.ts:267` (`?? "principal"`) et `projet.ts` (`etat_code,'ouvert'` à l'INSERT, `?? "regie"`).
reproduire : `grep -rnE "(etat_categorie|role_code) *(=|<>|IN|NOT IN) *\(?'" server/src`
prétend : `cycle.ts:22` — « **Catégories — les seules chaînes d'état du serveur. Les commandes lisent cette table.** »
mesure : la table `CAT` existe et sert partout **en TypeScript** ; dans le SQL, les mêmes valeurs sont recopiées à la main. Deux cas sortent du lot et sont plus graves que du style : `CreateProject` et `CreateProjectFromNeed` écrivent `etat_code = 'ouvert'` — un **code de référentiel**, pas une catégorie — alors que toutes les autres créations passent par `codeCategorie(ctx, 'ref_etat_projet', CAT.projet.ouvert)`. Un `ManageRefs` qui renomme ou désactive `ouvert` casse la création de projet, sans qu'aucune porte ne le voie. Et `SetResourceState` (`identite.ts:290,296`) compare une catégorie de **ressource** à `CAT.candidat.sorti`.
correction : `etat_code` par `codeCategorie` partout ; les littéraux SQL interpolés depuis `CAT` (la valeur passe en `$n`, pas le nom de colonne).

---

**G-06 · L'identifiant de session est un e-mail en clair dans un en-tête HTTP.**
Cible **CODE** · famille **K2** · **moyenne** *(annoncé lot 2c, donc non bloquant ici)* ·
preuve : `securite4/acces4.txt` — `x-ava-groupe: adm@ava.test` → `ok=true` ; le même en-tête portant l'UUID du compte → `DROIT « compte inconnu ou inactif »`. `executer.ts:62-73` résout le compte par `lower(c.email) = lower($1)`.
prétend : grille K2 — « le jeton est **aléatoire, haché, expirant** (D-10) ».
mesure : la moitié du contrôle tient (une session n'est pas l'identifiant d'un compte) ; l'autre moitié n'existe pas. ⭐ **Le serveur le dit lui-même** dans chaque refus hors banc : `authentification non livrée (lot 2c)`. Ce n'est donc pas un oubli, c'est une dette déclarée — mais la grille K2 est 🟠 tant qu'elle n'est pas payée.
correction : lot 2c. ⛔ D'ici là, ne jamais exposer le port hors `127.0.0.1` : n'importe qui connaissant une adresse e-mail est administrateur.

---

**G-07 · `verif_serveur.sh` mesure bien, mais n'a jamais mesuré un serveur.**
Cible **BRAIN** · famille **K5** · **moyenne** ·
preuve : `securite4/verif_serveur.txt` — sur ce poste, sortie **1** : `6 règle(s) trust/password`, `listen_addresses : *`, `ava_serveur : login=oui superutilisateur=non mot de passe=(aucun)`. Avec `AVA_POSTE_DEV=1` : sortie **0**.
prétend : grille K5 — « `bash outils/verif_serveur.sh` **sur le serveur** : 0 `trust`, `listen_addresses` borné, `ava_serveur` avec mot de passe ».
mesure : l'outil est bon — il lit `pg_hba_file_rules`, `listen_addresses` et `pg_authid`, il exige `SCRAM-SHA-256`, il refuse de conclure s'il n'est pas superutilisateur (sortie 2), et il sépare le poste de dev par une variable **déclarée**, pas par une exception silencieuse. ⚠️ Mais K5 porte sur **un serveur**, et il n'y en a pas : le contrôle ne peut être que 🟠 jusqu'au premier déploiement. *(à décharge : les 6 règles `trust` ne visent que `(socket)`, `127.0.0.1` et `::1` ; aucune adresse distante n'a de règle, donc `listen_addresses = *` n'ouvre rien en pratique.)*
correction : au premier déploiement, exiger la sortie **0 sans `AVA_POSTE_DEV`**, et l'inscrire dans la recette de déploiement.

---

**G-08 · Vingt commits sur 141 n'ont pas de trailer `Role:`.**
Cible **BRAIN** · famille **D5** · **moyenne** ·
preuve : `git log --format="%h|Role=%(trailers:key=Role,valueonly)" origin/main..HEAD | grep -c "Role=$"` → **20**.
reproduire : idem ; les 20 sont `19237f6` et ses ancêtres.
prétend : grille D5 — « chaque commit porte un trailer `Role:` ; un commit qui touche `test/` porte `Role: banc`, et le crochet le refuse sinon ».
mesure : tous les 20 sont **antérieurs** au crochet (`fce4647 [banc] V-040 : le hook exige le trailer Role`). Les 121 suivants en portent un, et le champ est juste (`banc`, `brain`, `serveur`, `ecran`, `greffe`, `integrateur`). C'est une dette d'histoire, pas une fuite en cours — mais le canon ne prévoit pas d'exception, donc 🟠.
correction : soit accepter l'exception par écrit (une ligne dans `DECISIONS`), soit faire commencer la mesure du cliquet au commit qui a posé le crochet.

---

**G-09 · La parade ⏳ passe par `testIgnore`, que le grep de F4 ne regarde pas.**
Cible **BRAIN** · famille **F4** · **bonne** *(rien de cassé aujourd'hui)* ·
preuve : `test/playwright.config.ts:5` → `testIgnore: ["**/besoin.spec.ts"]` ; les tests ainsi exclus sont `P-061` (geste) et `P-062` → `P-065` (écran) — **exactement les 5 ⏳ de lot cible 3**.
mesure : la parade est **juste** et cohérente. ⚠️ Mais elle montre que `testIgnore` est un chemin de désactivation que F4 ne balaie pas : ajouter `contrat/**` à cette liste retirerait des portes ✅ sans qu'un seul grep ne bronche. Seule la case 1 du cliquet (`non_jouees`) l'attraperait — et elle ne couvre que ce qui est déclaré ✅.
correction : une ligne de F4 qui lit `testIgnore` et vérifie que chaque fichier exclu ne contient que des portes ⏳.

---

**G-10 · `npm run contrat` ne joue que 3 des 8 fichiers de portes.**
Cible **CODE** (banc) · famille **F** · **moyenne** ·
preuve : `test/package.json` → `"contrat": "... contrat/sante.test.ts contrat/inventaire.test.ts contrat/commandes.test.ts"` · `outils/make.sh:318-326` en joue **huit** (+ `correctifs`, `audit3`, `chemin`, `matrice`, `politiques`).
mesure : les 5 fichiers absents portent **219 tests sur 277** — dont P-207 et les 15 portes de l'audit 3. Qui lance `npm run contrat` voit du vert avec 79 % des portes non jouées. ⚠️ Deux listes, une seule mesure ; c'est la seconde qu'on oublie.
correction : `"contrat"` lit la même liste que `make.sh`, ou `make.sh` appelle `npm run contrat`.

---

**G-11 · bien fait (bonne).**
Le compte annoncé par la grille (**42 contrôles, 7 familles**) est juste. **A2 tient** — c'est le contrôle que personne ne fait, et la suite **tombe** quand on retire `tg_m10`. **D1 tient** : `_ops/` n'a pas bougé d'un octet sur 141 commits. Les 4 murs de grants (C2 → C5) tiennent, mesurés **par ce qu'on atteint**, et je les ai re-mesurés sur `ava_serveur` en plus de `ava_app` : 0 ligne des deux côtés. `ava_lecture_agregats` atteint **exactement 7 relations**. L'écran est propre à l'œil comme au grep, en 631 lignes. `cliquet.sh` ne déclare **aucune** de ses 12 cases : la case 1 exige que chaque porte ✅ ait **tourné**, la case 3 compare numéro par numéro, la case 11 part du `merge-base` — et le script imprime ses douze lignes même après un échec. `verif_serveur.sh` est un bon outil, écrit pour être passé, pas pour être coché.
