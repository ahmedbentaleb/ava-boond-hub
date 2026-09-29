# GRILLE9 — la grille d'audit passée en entier sur `071b7b2`

**Verdict : 43 contrôles comptés = 43 annoncés. 33 ✅ · 5 🟠 (B1 B5 K1 D3 F6) · 1 🟡 (D4) · 1 🔴 (K2) · 3 ⬜ non jouables ici (A4 K5 F10).**
Le 🔴 est **K2** : en banc, l'identité est l'e-mail d'un compte dans un en-tête — n'importe qui agit sous n'importe quel compte ; hors banc, rien n'est servi (401), donc aucune session n'existe à juger.

> Poste : clone `ava-audit-9-lecture` sur `071b7b2` (détaché), base `ava_audit9_b` (migrations 001→017 + `db/fixtures/banc.sql` + `_ops/JEU_ESSAI.sql`), serveur `:3902`.
> ⛔ Ni `outils/make.sh` ni `outils/cliquet.sh` lancés. Preuves : `rapport/preuves/grille9/`.

---

## 1. Le compte de la grille, re-mesuré

| Où | Annoncé | Mesuré | |
|---|---|---|---|
| En-tête | 43 contrôles · 7 familles | 43 lignes `| **X9** |` · 7 familles (A B C K D E F) | ✅ |
| A · B · C · K · D · E | 5 chacune | 5 · 5 · 5 · 5 · 5 · 5 | ✅ |
| F | 13 (F1 → F13) | 13 (F1…F13, dans le désordre F1 F2 F3 F10 F11 F4…F9 F13 F12) | ✅ |
| `outils/cliquet.sh` | « dix-sept cases » | 17 appels `line 1…17` | ✅ |
| Assertions (A1) | 41 | `plancher_assertions.sh` = 41 ; 41 `OK   M-` sur ma base | ✅ |
| Portes | 336 | 336 lignes `P-` ; 330 ✅ · 6 ⏳ | ✅ |
| Politiques | 173 (prompt) | **202** en base = **202** au registre (201 en tableau + 1 en prose) | ⚠️ « 173 » est périmé ; §E le cite encore (« seul le total 173 est mesuré », ligne 429) |

Preuve : `grille9/compte_grille.txt`, `securite9/05_*.txt`.

⚠️ **La grille décrit un monde disparu à trois endroits** : `<etat>` dit « 19/09 — aucun lot encore audité », « JOURNAL_BUGS 0 ligne », et « le lot 2 ajoutera une famille F — les contrats » (F est devenue le cliquet). Un auditeur qui suit `<etat>` part faux.

---

## 2. Les 43 contrôles

| # | Verdict | Preuve (mesurée) |
|---|---|---|
| **A1** | ✅ assertions · ⬜ `make test` | 41/41 `OK   M-` sur `ava_audit9_b` ; `cmp` canon = copie (0). `make test` interdit ici → portes non jouées par moi (sauf P-325, P-339) · `A1_assertions_base_audit.txt`, `A1_case2_case14.txt` |
| **A2** | ✅ | `DROP TRIGGER tg_m10` dans la transaction du fichier → **M-10 lève** (rc=3, arrêt à 19 OK) ; trigger intact après (ROLLBACK) · `A2_sans_tg_m10.txt` |
| **A3** | ✅ | `ci.yml` : `fetch-depth: 0`, `main` local, `verif_trailers.sh`, `installer.sh`, puis `cliquet.sh` |
| **A4** | ⬜ | `dossier.py` réécrit `_ops/DOSSIER.html` : non joué dans un clone en lecture seule |
| **A5** | ✅ | `audit/E1.md … E7.md` (7 fiches) + `L2-*.md` |
| **B1** | 🟠 | grep de la grille : 10 + 8 lignes, lues une à une. ⛔ Il ne voit pas l'essentiel : **132 comparaisons à un littéral** dans `server/src`, dont ~25 sites de codes métier en dur (constat G-1) · `B1_greps.txt`, `B1_elargi.txt`, `B1_comparaisons_litterales.txt` |
| **B2** | ✅ | `count(*) politique` = 202 = registre §E |
| **B3** | ✅ | `valeur <> valeur_defaut` → 0 (mesuré au seed, et après remise en place de mes réglages) |
| **B4** | ✅ | 74 `ref_*` = §E |
| **B5** | 🟠 (9/9 justifiés, mais angle mort) | 9 CHECK `ANY(ARRAY[…])`, tous justifiés au §D. ⛔ **3 listes de codes échappent à la regex** (écrites `= 'x' OR`) : `personne.ck_blackliste_portee` (agence · installation), `personne_coordonnee_check` (`type_code = 'reseau_social'`), `preparation_paie_check` (`etat = 'brouillon'` — un CODE, alors que `etat` est devenu un `ref_*` en 015) · `B5_C5.txt` |
| **C1** | ✅ (🟡 contrôle mal posé) | 0 colonne `tenant*` en base ; le grep « → vide » rend 3 lignes de **commentaires** : le contrôle écrit ne peut pas passer |
| **C2** | ✅ | 0 ligne DELETE/TRUNCATE ; `pg_stat_activity` du serveur = `ava_serveur`, non superutilisateur · `C2_C3_C4.txt`, `securite9/01_roles.txt` |
| **C3** | ✅ | 0 UPDATE (table et colonne) sur `evenement_metier`, `snapshot_marge`, `prestation_version`, `tentative_refusee` |
| **C4** | ✅ | exactement 7 relations : `politique`, `ref_devise`, `ref_pays`, 4 vues `v_*_par_devise` (⚠️ + EXECUTE sur 27 fonctions `ava.*` via PUBLIC, dont `dechiffre_rh` — inoffensif sans lecture des tables, voir SECURITE9) |
| **C5** | ✅ | `tg_m4_m14`, `tg_m6`, `tg_m7`, `tg_m10`, `tg_m12` (×4 tables), `ajout_seul` (×3) présents |
| **K1** | 🟠 | 22 routes sur 25 → 401, 0 écriture, 0 trace. ⛔ **3 → 500** avant la garde (JSON mal formé, `application/xml`, corps > 1 Mo) · `securite9/hors_banc.json` |
| **K2** | 🔴 | aucune session : `x-ava-groupe: IA@AVA.TEST` → la commande passe sous le compte IA. L'UUID d'un compte est refusé, mais l'e-mail **est** un identifiant de compte · `securite9/supp.json` |
| **K3** | ✅ | `rr@ava.test` désactivé (déclaré) → `DROIT`, 0 écriture |
| **K4** | ✅ | table `CORRESPONDANCE` : 55 lignes = 55 servies = 55 de L4 §I–V ; **50 commandes × cas hors agence → 50 `DROIT`, 0 écriture** ; P-339 rejouée : 117 identifiants, **0 fuite** · `securite9/hors_agence.json`, `P339_porte_croisee.txt` |
| **K5** | ⬜ | se mesure sur le VPS, pas sur le poste de dev (`trust` assumé) |
| **D1** | ✅ | `git diff --stat origin/main HEAD -- _ops/` vide |
| **D2** | ✅ | aucun ORM dans `server/`, `web/`, `test/package.json` (le grep de la grille vise `package.json` à la racine, qui n'existe pas) |
| **D3** | 🟠 | `git log --diff-filter=M -- db/migrations/` → **5 commits, 7 réécritures** (001 ×5, 002 ×2) + 1 renommage `009_unite_agence → 010` (R100, invisible au filtre M). 001/002 sont revenues identiques à `main` (ddffd0a). ⛔ Le contrôle, écrit sur l'historique, ne peut plus jamais repasser au vert · `D1_D5.txt` |
| **D4** | 🟡 | `REMARQUES.md` **introuvable** dans tout le dépôt (`find -iname '*REMARQUES*'` vide) |
| **D5** | ✅ | 78 commits depuis `9f5281d` : 0 sans `Role:` ; 4 touchent `test/` en `Role: brain`, tous dans les exemptions écrites de `verif_trailers.sh` (copie canon `SPEC_ASSERTIONS_L7.sql`, fusion à 3 parents) ; `verif_trailers.sh` → OK |
| **E1** | ✅ | 0 |
| **E2** | ✅ | 0 |
| **E3** | ✅ · ⚠️ | 0 dans `web/` ; mais le **serveur** envoie le **code** comme libellé : `/vues/besoins` rend `etat: b.etat_code` (`a_pourvoir`) |
| **E4** | ✅ | 0 |
| **E5** | ✅ | 1 ligne : la police binaire `JetBrainsMono-Regular.woff2` (faux positif, lu) |
| **F1** | ✅ | `journal/PORTES.md`, colonnes Porte · Espèce · Phrase · Test · Vue rouge · État · Lot cible · Tolérance |
| **F2** | ✅ déclaré · ⬜ joué | A 1 · B 327 · C 2 · D 6 — les quatre espèces ont des ✅ ; les faire tourner = `make test` |
| **F3** | ✅ | 5 servies sur `origin/main`, 0 disparue |
| **F4** | ✅ (🟡 grep de la grille) | le grep de la grille rend 10 fichiers, **tous faux positifs** (`ExitCandidate` contient `xit`, `exitCode`, `toBeDisabled`, `animations: "disabled"`) ; aucune forme `{ skip:` / `{ todo:` |
| **F5** | ✅ | 0 vue rouge vide sur 336 |
| **F6** | 🟠 | lu en entier : 3 cases se déclarent au lieu de se mesurer (constat G-3) |
| **F7** | ✅ | `core.hooksPath = .githooks` dans le dépôt de travail ; `pre-push` → `cliquet.sh` |
| **F8** | ✅ | `ci.yml` appelle `bash outils/cliquet.sh` |
| **F9** | ✅ | pas de `set -e`, 17 `line` imprimées puis `exit` |
| **F10** | ⬜ | se juge sur l'historique complet par la case 9 ; non rejouée (cliquet interdit) |
| **F11** | ✅ | ⏳ : P-061→P-065 (lot 3), P-339 (lot 2 = lot courant) ; aucune dépassée |
| **F12** | ✅ | 340 ✅ historiques ; 6 absentes (P-333→P-338), toutes déclarées D-41 avec leur jumelle ✅ (P-326→P-331) |
| **F13** | ✅ | `origin/lot-2-brain` est ancêtre de HEAD |

---

## 3. Le cliquet, lu case par case (famille F, sans le lancer)

| Case | Ce qu'elle mesure | Constat |
|---|---|---|
| 1 | make 0 + portes ✅ jouées et vertes | ⚠️ une porte **⏳ qui échoue est ignorée** (ni `servies_ko`, ni `inconnus`) |
| 2 | copie = canon + `n_ok ≥ plancher` | ⚠️ le plancher se compte **dans le fichier qu'il protège** : retirer une assertion du canon baisse le plancher d'autant |
| 5 | vue rouge non vide | ⛔ lit la colonne **par position** (`$6`) |
| 10 | ⏳ au-delà du lot cible | ⛔ colonnes par position (`$7`, `$8`) **et** lot courant **déclaré** : `LOT_COURANT:-2` — au lot 3, la case reste verte tant que personne ne tape 3 |
| 14 | `_ops/PORTE_CROISEE.mjs` = `test/contrat/porte_croisee.test.mjs` | ✅ `cmp` = 0. ⛔ **Mais P-339 est ⏳** : la case garantit que la copie est exacte, pas qu'elle protège — une fuite future rougit P-339 **sans bloquer** (case 1). Mesuré aujourd'hui : **0 fuite** sur 55 commandes, 117 identifiants → rien n'empêche de la passer ✅ |
| 15 | migrations de `main` identiques ici | ⚠️ couvre les **5** migrations de `main` ; les **12** de la branche (005, 007→017) ne sont protégées par rien ; `schema_migrations` n'a **pas d'empreinte** : une base déjà migrée ne voit pas une réécriture |
| 7 | `_ops/` = `main` | ⚠️ passe dès que le canon modifié est aussi poussé sur `main` (commits « Canon porté sur main ») : le mur vaut ce que vaut la garde de `main` |

---

## 4. Constats (famille · étendue · correction de construction · porte)

### G-1 🟠 · Codes métier écrits en dur dans le serveur (ADR-005)
- **Famille** : une bifurcation ou un code de référentiel vit dans le code au lieu d'une politique ou d'un `ref_*`.
- **Étendue, mesurée** : 132 comparaisons à un littéral dans `server/src` ; hors valeurs de politique et catégories fermées, **~25 sites** :

| Sous-famille | Sites |
|---|---|
| Code de référentiel en dur | `besoin.ts:43` et `couverture.ts:43` défaut `"postes"` — ⛔ **alors que la politique `besoin.unite_couverture` existe et n'est lue nulle part** ; `besoin.ts:68`, `couverture.ts:45` `=== "fte" / "postes_et_fte"` ; `crm.ts:271` `"principal"` ; `projet.ts:95` `"regie"` ; `crm.ts:141` `role_code = 'interne'` ; `projet.ts:58,99` `etat_code 'ouvert'` écrit sans `codeCategorie` ; `projet.ts:191` `motif_code 'autre'` ; `besoin.ts:288` `'cv_partage','fait'` ; `admin.ts:186` catégorie `"defaut"`, ordre `50` |
| Formule et numérotation | `projet.ts:434` `version_atl 'ATL-2026-09-16'` ; `projet.ts:7-11` `PRJ-`, minimum 100, 4 chiffres ; `identite.ts:99` `1_5→5, 1_10→10, sinon 100` |
| Machines d'état dans le code | `cycle.ts` : `TRANSITIONS` (27 commandes), `RESSOURCE_CAT` (5), `REQUALIF_ORDRE` (4) + `crm.ts:98` `ordre 2 → 1` ; `codeStatutCommercial(ctx, 1/2)` : le **rang** d'un référentiel porte le sens |
| Groupes nommés | `cycle.ts` `GROUPE`, `ACTEUR_POLITIQUE` (`groupe_rh → RH`, `groupe_rh_ou_rr → RH, RR`) |
| Exceptions par nom de commande dans la garde générique | `agence.ts` `=== "ArchiveObject" / "CreateNeed" / "TransferContact"`, `SOI_MEME` (3 noms) ; `admin.ts:76-78` refait en dur la table `refusType` d'`agence.ts` |
| Données de banc dans le serveur | `index.ts:69-109` écrit `personne`/`profil_ressource` au démarrage (`'PAR'`, `'INTERNAL'`, `'intercontrat'`, `res@ava.test`) |

- **Correction de construction** : tout code de référentiel se lit par **catégorie** (`codeCategorie`) ou par **politique** ; les machines (`TRANSITIONS`, requalification, ressource) deviennent une table `transition(commande, ref, depuis_categorie, vers_categorie)` lue par `exigeTransition` ; les défauts deviennent des politiques (`besoin.unite_couverture` existe déjà) ; les exceptions de garde deviennent des colonnes de `CORRESPONDANCE`.
- **Porte** : P-B1 — le banc parcourt l'AST de `server/src` et rougit sur **tout** littéral comparé ou inséré qui figure comme `code` dans un `ref_*` en base (liste lue en base, pas écrite).

### G-2 🟠 · Des contrôles de la grille qui ne peuvent pas passer, ou qui voient à côté
- **Famille** : un contrôle écrit sur un texte (grep, historique) au lieu de l'objet mesuré.
- **Étendue** : **6 contrôles** — B1 (ne voit pas 132 − 18 sites), B5 (3 CHECK hors regex), C1 (grep sur commentaires), D2 (vise un `package.json` absent), D3 (historique → rouge à vie), F4 (`xit` ⊂ `ExitCandidate`).
- **Correction de construction** : chaque contrôle se mesure sur l'objet : B5 et C1 **en base** (`pg_constraint` complet, `information_schema.columns`) ; D3 par la case 15 **étendue à toutes les migrations** + une empreinte sha256 par migration dans `schema_migrations` ; F4 par la regex de la case 4 (qui est juste) recopiée dans la grille.
- **Porte** : P-G2 — le banc exécute les commandes de la grille elle-même contre une base et un dépôt témoins, et rougit si l'une rend « KO » sur le témoin propre.

### G-3 🟠 · Trois cases du cliquet se déclarent au lieu de se mesurer (F6)
- **Famille** : une case qui lit une position de colonne, un réglage d'environnement ou un état ⏳ à la place d'une mesure.
- **Étendue** : cases **5, 10** (colonnes par position, contre la règle V-009 que les cases 1, 3, 9 respectent), case **10** (`LOT_COURANT:-2`), case **14** (vérifie la copie d'une porte ⏳ qui ne bloque rien) ; case 2 (plancher tiré du fichier protégé).
- **Correction de construction** : une seule fonction `colonne(en-tête)` pour toutes les cases ; le lot courant se **lit** (un fichier unique `LOT` ou la branche) ; une porte à 0 défaut mesuré passe ✅ ; les planchers (assertions, portes) se comparent à **`main`**, pas au fichier courant.
- **Porte** : P-G3 — sabotage : insérer une colonne dans `PORTES.md`, mettre `LOT_COURANT` à 3, retirer une assertion du canon → les cases 5, 10 et 2 doivent rougir.

### G-4 🟡 · Le texte qui décrit un monde disparu
- **Étendue** : `<etat>` de la grille (3 phrases), §E du registre (« 173 », « la migration qui les sème reste à écrire » alors que 202 sont semées), L4 « 20/09 — aucune commande codée », P-001 « 22 assertions » (41 mesurées).
- **Correction de construction** : aucun compte écrit en prose ; les blocs `<etat>` se génèrent depuis la mesure.

---

## 5. Données posées par moi (déclarées)
Toutes dans `ava_audit9_b`, jamais ailleurs : `_ops/JEU_ESSAI.sql` chargé ; schéma `t` créé par le fichier d'assertions ; P-339 a donné ses permissions au groupe CROISE (sur PAR) ; `DROP TRIGGER tg_m10` et deux `GRANT` **annulés par ROLLBACK** (vérifié après).
