# GRILLE — second audit, auditeur B · lot 2 · commit 7e3f78c

> ⭐ **Rejoué en réel par l'auditeur principal, après ce brouillon** : A1 par `outils/make.sh test` complet sur
> `ava_audit2:3200` (151/151, `preuves/banc/S0_reference.txt`) ; F6 par `outils/cliquet.sh` réel sous 4 sabotages
> (`preuves/banc/C_*.txt`) → **F6 passe 🟠 → 🔴** : 4 portes ✅ propres à `lot-2` retirées, cliquet 10/10 (V-050).
> **Compte final : ✅ 30 · 🟠 5 · 🔴 1.**

**36 contrôles · ✅ 30 · 🟠 6 · 🔴 0 (brouillon, avant rejeu de F6).** La grille, passée à la lettre, ne refuse pas le lot — ⛔ alors que
le lot porte une faille d'authentification critique et un périmètre percé sur 5 commandes
(voir CONFORMITE.md et SECURITE.md). **La grille n'a aucun contrôle d'authentification ni de
périmètre par objet** : c'est son premier angle mort (constat G-1).

Poste : clone `ava-audit-2-lecture` (7e3f78c, non modifié — vérifié `git status --ignored` propre),
base `ava_audit2_b`, port 3202. Sorties longues : `rapport/preuves/grille/`.

⚠️ Écarts de méthode, déclarés : `outils/make.sh` et `outils/cliquet.sh` **non lancés** (consigne) —
A1 est rejoué pièce par pièce (assertions psql + 6 fichiers de contrat node:test sur mon serveur ;
`contrat/correctifs.test.ts` et Playwright non joués). F est jugé en **lisant** `outils/cliquet.sh`.

| n° | Contrôle | Verdict | Preuve |
|---|---|---|---|
| A1 | Toutes les assertions passent | ✅ | `psql -f test/SPEC_ASSERTIONS_L7.sql` rc=0, **29 « OK   M- » = plancher 29** (`bash outils/plancher_assertions.sh _ops/SPEC_ASSERTIONS_L7.sql`) ; `cmp _ops/… test/…` identiques ; contrat : sante 1/1, inventaire 1/1, commandes 56/56, chemin 56/56, matrice 3/3, politiques 5/5 → `preuves/grille/A1_assertions.txt`, `A1_contrat_*.txt`. ⚠️ correctifs.test.ts + Playwright non joués (consigne) |
| A2 | Elles tombent quand on casse un mur | ✅ | `DROP TRIGGER tg_m10 ON ava.temps` puis relance : rc=3, 18 OK puis `ERREUR: ⛔ un temps saisi pour une autre ressource (M-10) — LE GESTE EST PASSÉ` → `preuves/grille/A2_sans_tg_m10.txt` (base reconstruite après) |
| A3 | La CI fait la même chose que moi | 🟠 | `.github/workflows/ci.yml` : fetch-depth 0 ✅, main recréé depuis origin ✅, `bash outils/cliquet.sh` ✅. ⛔ Mais la CI **ne peut pas passer** : aucun service PostgreSQL, aucun `POSTGRES_PASSWORD` ; `outils/make.sh:42-61` ne trouve pas `/c/Program Files/PostgreSQL` sur ubuntu → moteur docker → `exit 1` si `POSTGRES_PASSWORD` vide → case 1 du cliquet KO à chaque push. Le « vrai mur » est rouge en permanence (constat G-3) |
| A4 | Le compte correspond au registre §E | ✅ | `python _ops/outils/dossier.py` rc=0 « OK … politiques=173 · referentiels=40 » → `preuves/grille/A4_dossier.txt`. ⚠️ Le script **écrit** `_ops/DOSSIER.html` et crée `_ops/share-hub/` (dossier.py:556,580,590) : lancer A4 modifie le canon — j'ai restauré le clone (`git checkout -- _ops/DOSSIER.html`, `rm -rf _ops/share-hub`). Il annonce `assertions=28` alors que le plancher compté est 29 (constat G-5) |
| A5 | Les fiches de l'auditeur interne existent | ✅ | `audit/E1.md … E7.md` + 9 fiches `L2-*.md` |
| B1 | Aucun `if` métier en dur | 🟠 | grep de la grille : 4 occurrences **lues** — `identite.ts:203,230` (catégorie `externe`, admissible), `droits.ts:29` (`global`, technique), ⛔ `projet.ts:195` (`statut_commercial_code === "prospect"`). Complément de l'auditeur (le grep ne les voit pas) : `cycle.ts:86-91` REQUALIF sur codes · `crm.ts:54,90` · `projet.ts:196,208` `'client'` · `besoin.ts:42,57,128-130` codes de couverture · `besoin.ts:336` liste de décisions · `projet.ts:59,101` `'ouvert'` · `projet.ts:97` `'regie'` · `projet.ts:171` `'autre'` · `crm.ts:134` `'interne'`. ⭐ Les référentiels visés (`ref_statut_commercial`, `ref_unite_couverture`) ont tous la catégorie `defaut` : le code compare donc des **codes**, pas des catégories → `preuves/grille/B_parametrage.txt` |
| B2 | Toutes les politiques sont chargées | ✅ | `select count(*) from ava.politique` = **173** = registre §E (« 173 au 20/09 », REGISTRE_POLITIQUES_v1.md:327) |
| B3 | `valeur` = `valeur_defaut` au seed | ✅ | `where valeur is distinct from valeur_defaut` → **0** |
| B4 | Tous les référentiels existent | ✅ | `pg_tables … like 'ref\_%'` = **40** = registre §E (« 40 au 21/09 ») |
| B5 | Aucun CHECK sur un code de référentiel | ✅ | 1 occurrence **lue** : `005_droits_lot2.sql:26` `CHECK (code IN ('DROIT','ETAT','GARDE','MUR','INTROUVABLE'))` sur `tentative_refusee.code` — les 5 familles de refus du contrat L4, pas un référentiel. Faux positif du grep (constat G-5) |
| C1 | Aucune colonne `tenant_id` | ✅ | `grep -rn tenant db/` : 3 lignes, toutes des **commentaires** (001:34,39,1365) ; `information_schema.columns ilike '%tenant%'` = 0 |
| C2 | ava_app sans DELETE/TRUNCATE, serveur en ava_serveur | ✅ | requête de la grille → 0 ligne, idem pour `ava_serveur` ; `index.ts:170-178` refuse de démarrer en superutilisateur ; le serveur se connecte en `ava_serveur` (seul rôle `rolcanlogin`, membre de `ava_app`) → `preuves/securite/grants.txt` |
| C3 | evenement_metier / snapshot_marge sans UPDATE | ✅ | même requête, volet UPDATE → 0 ligne (ni `prestation_version`, ni `tentative_refusee`) |
| C4 | Le rôle d'agrégats n'atteint que 7 relations | ✅ | `has_any_column_privilege` sur **toutes** les relations → exactement : politique, ref_devise, ref_pays, 4 vues `v_*_par_devise` ; aucune écriture |
| C5 | Les 7 murs-triggers existent | ✅ | `tg_m4_m14` (prestation), `tg_m6` (snapshot_marge), `tg_m7` (evenement_metier), `tg_m10` (temps), `tg_m12` (besoin, contact, projet, unite_organisation), `tg_ajout_seul` (prestation_version) + `tg_m7_tentative` → `grants.txt` |
| D1 | `_ops/` n'a pas bougé | ✅ | `git diff --stat origin/main -- _ops/` → vide (pas de `main` local dans le clone, `origin/main` utilisé) |
| D2 | Aucun ORM | ✅ | grep sur `*/package.json` → vide (pas de package.json racine) |
| D3 | Migrations jamais réécrites | 🟠 | `git log --diff-filter=M -- db/migrations/` → `001_schema.sql` modifiée **2 fois** : `f54c73b` et `98aae74` (20/09) → `preuves/grille/D_depot.txt` |
| D4 | REMARQUES.md existe | ✅ | `journal/REMARQUES.md` suivi par git (+ 3 sous-dossiers). Contenu non lu (mur d'indépendance) |
| D5 | Un seul auteur par dossier | 🟠 | un seul auteur git (`ahmedbentaleb`) partout ; par préfixe, le codeur serveur `[greffe]` a écrit **5 commits** dans `test/contrat/correctifs.test.ts` (0e61751, bbf0e3a, f42d0e3, 2af4270, fa32680) : il écrit les portes qui le jugent |
| E1 | Aucun `if` sur un état dans /web | ✅ | grep → vide ; lecture de `web/src` (629 lignes) : les seules comparaisons portent sur `variante`/`nature`/`cle` envoyés par le serveur |
| E2 | Aucun calcul d'argent dans /web | ✅ | grep → vide |
| E3 | Aucun libellé d'état en dur | ✅ | grep → vide ; aucun objet `LABELS` à la lecture |
| E4 | /web n'importe rien de /server ni /db | ✅ | grep → vide |
| E5 | Aucun SQL dans /web | ✅ | 1 occurrence : `fonts/JetBrainsMono-Regular.woff2` (binaire) — faux positif → `preuves/grille/E_ecran.txt` |
| F1 | journal/PORTES.md existe et est à jour | ✅ | 156 portes, colonnes Porte·Espèce·Phrase·Test·Vue rouge·État·Lot cible·Tolérance |
| F2 | Les quatre espèces tournent | ✅ | A 1 ✅ · B 147 ✅ · C 1 ✅ + 1 ⏳ · D 2 ✅ + 4 ⏳ ; toutes appelées par `make.sh cmd_test` (node:test + `npx playwright test`). Jugé à la lecture (Playwright non lancé) |
| F3 | Les portes servies n'ont pas baissé | ✅ | `origin/main:journal/PORTES.md` : 5 portes (P-001…P-005), toutes présentes et ✅ dans HEAD |
| F10 | Aucune porte ✅ → ⏳ | ✅ | P-001…P-005 restent ✅ ; les 5 ⏳ (P-061…P-065) n'existent pas sur main |
| F11 | Aucune ⏳ au-delà du lot cible | ✅ | P-061…P-065 : lot cible 3 > lot courant 2 |
| F4 | Aucune porte désactivée | ✅ | grep de la grille : 13 lignes **lues**, toutes faux positifs (`ExitCandidate`, `exitCode`, `toBeDisabled`, `animations: "disabled"`) ; aucun `{ skip: }`/`{ todo: }` |
| F5 | Chaque porte vue rouge | ✅ | colonne « Vue rouge » remplie pour les 156 |
| F6 | cliquet.sh existe et mesure | 🟠 | Il mesure : case 1 exige `make_rc=0`, aucune porte ✅ en échec, aucun échec anonyme, et **chaque porte ✅ exécutée** (cliquet.sh:85-99) ✅. ⚠️ Mais : cases 5 et 10 lisent les colonnes **par position** (`$6`, `$7`, `$8` — cliquet.sh:164,227-229), la classe de défaut que V-009 a corrigée pour les cases 1/3/9 ; case 6 est décorative (un `grep E[1-7]`) ; case 4 ne voit pas l'option `{ skip: true }` de node:test (regex cliquet.sh:150) |
| F7 | Branché en pre-push | 🟠 | `.githooks/pre-push` existe et `exec bash outils/cliquet.sh` ; `git config core.hooksPath` = **vide** dans le clone — réglage local, non versionné, donc non garanti sur un poste neuf |
| F8 | La CI relance le même script | ✅ | ci.yml : `run: bash outils/cliquet.sh`. ⚠️ Voir A3 : ce script ne peut pas y passer |
| F9 | Ne s'arrête pas à la première case | ✅ | `set -u` sans `-e`, chaque case appelle `line()` qui compte, sortie en fin (cliquet.sh:237-242). Imprime **10** lignes — la grille dit encore « 7 » (constat G-5) |

## Constats candidats — famille grille

**G-1 · La grille ne contient aucun contrôle d'authentification ni de périmètre par objet.**
Cible BRAIN · grille entière · **elevee** · preuve : `_ops/GRILLE_AUDIT.md` (familles A–F, 36 lignes, aucune
sur la session ni sur l'agence de l'objet visé) · reproduire :
```bash
grep -niE "session|authent|périmètre|perimetre" /c/Users/Hamada/Desktop/ava-audit-2-lecture/_ops/GRILLE_AUDIT.md
```
· prétend « un seul 🔴 refuse le lot entier » · mesure : 0 🔴 alors que K-1 (session = id) et K-3 (5 commandes hors
périmètre) sont critiques · correction : ajouter une famille « G — accès » (session opaque sondée hors banc ; une
sonde de périmètre par commande qui vise un objet).

**G-2 · 001_schema.sql réécrite deux fois après publication.** Cible CODE · D3 · **elevee** (règle du projet) ·
preuve `preuves/grille/D_depot.txt` · reproduire :
```bash
git -C /c/Users/Hamada/Desktop/ava-audit-2-lecture log --diff-filter=M --format="%h %ad %s" --date=short -- db/migrations/
```
· prétend « jamais réécrites » · mesure 2 commits (f54c73b, 98aae74) · correction : figer 001, toute
correction passe par une migration numérotée suivante.

**G-3 · La CI ne peut jamais passer.** Cible CODE (outils) · A3/F8 · **elevee** (la CI est « le vrai mur ») ·
preuve `.github/workflows/ci.yml` (aucun `services:` ni `env:`), `outils/make.sh:42-61` · reproduire :
```bash
grep -nE "services:|POSTGRES_PASSWORD|env:" /c/Users/Hamada/Desktop/ava-audit-2-lecture/.github/workflows/ci.yml; sed -n 42,61p /c/Users/Hamada/Desktop/ava-audit-2-lecture/outils/make.sh
```
· prétend « la CI relance le même script » · mesure : le script sort en 1 avant le premier test sur ubuntu ·
correction : service `postgres:16` dans le job + `POSTGRES_PASSWORD` en secret + `AVA_MOTEUR`/URL explicites.

**G-4 · Le codeur serveur écrit ses propres portes.** Cible BRAIN · D5 · **elevee** · preuve : 5 commits `[greffe]`
dans `test/contrat/correctifs.test.ts` · reproduire :
```bash
git -C /c/Users/Hamada/Desktop/ava-audit-2-lecture log --format="%h %s" --grep="\[greffe\]" -- test
```
· prétend « personne n'écrit dans /test sauf le sous-agent 3 » · mesure 5 commits · correction : une porte
écrite par le banc, jamais par le codeur ; hook `commit-msg` qui refuse `[greffe]` + `test/`.

**G-5 · La grille et ses outils sont périmés en quatre endroits.** Cible BRAIN · A4/B5/F6/F9 · **moyenne** ·
preuves : F9 dit « 7 lignes » (cliquet en imprime 10) ; B5 attrape `tentative_refusee.code` ; A4 (`dossier.py`)
**réécrit `_ops/DOSSIER.html`** — lancer le contrôle fait tomber D1 — et compte `assertions=28` contre un
plancher de 29 ; cliquet cases 5/10 par position de colonne · correction : un seul compte (le plancher), un
contrôle en lecture seule, colonnes trouvées par en-tête partout.

**G+ · bien fait (bonne).** A2 mord (M-10 lève dès que le trigger tombe) ; C2–C5 mesurés par
`has_table_privilege` sur toutes les relations, pas sur une liste ; B2/B4 égaux au registre §E.
