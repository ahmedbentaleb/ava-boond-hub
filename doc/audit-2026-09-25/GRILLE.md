# GRILLE8 — huitième audit, lot 2, commit 48e90c4

**Verdict grille : REFUSÉ — 1 🔴 (K4) · 4 🟠 (A4, B1, D3, D5) · 6 ⚠️ (B5, K2, K5, F1, F2, F6) · 32 ✅ sur 43 contrôles.**
Le 🔴 qui décide : **K4** — le périmètre ne se juge PAS sur chaque objet visé : 15 champs d'identifiant sur 12 commandes écrivent dans une autre agence (détail : SECURITE8.md).

Poste : clone `ava-audit-8-lecture` (propre, 48e90c4, `git status` vide en fin d'audit) · base `ava_audit8_b` · port 3802 · aucun fichier du dépôt modifié · ni `make.sh` ni `cliquet.sh` lancés.
Preuves : `rapport/preuves/grille8/` (et `securite8/`, `conformite8/` quand cité).

---

## 0 · Les comptes de la grille — re-mesurés

| Annoncé | Où | Mesuré | Verdict |
|---|---|---|---|
| 43 contrôles · 7 familles | en-tête | A 5 · B 5 · C 5 · K 5 · D 5 · E 5 · F 13 = **43**, 7 familles | ✅ |
| « 5 contrôles » par famille A, B, C, K, D, E | chaque section | 5 lignes chacune | ✅ |
| F « 13 contrôles (F1 → F13) » | section F | F1…F13 présents, dans le désordre (F10, F11 avant F4 ; F13 avant F12) | ✅ |
| cliquet « treize cases » | `outils/cliquet.sh` l. 2 | 13 appels `line` (1 → 13) | ✅ — mais 13 cases ≠ 13 contrôles F (voir F6) |
| « 41 assertions » | (consigne) | plancher compté = **41** ; lignes `OK   M-` à l'exécution = **41** | ✅ |
| « 173 politiques » | (consigne) | **201** en base = 200 au tableau §C + 1 en prose (`ui.theme.personnalise`) ; « 173 » ne vaut plus nulle part ; l'en-tête de L7 dit encore « 167 clés » | ⚠️ chiffre périmé |
| « 332 portes » | journal/PORTES.md | 337 lignes · **332 ✅** · 5 ⏳ · P-255 n'a jamais existé · **6 paires de doublons** (P-326…331 = P-333…338, même phrase, même test) → **326 tests distincts** derrière 332 ✅ | ⛔ (G-4) |
| « 55 commandes servies » | L4 | L4 contracte **98** (`outils/compte_commandes.sh`) ; `CORRESPONDANCE` = **55** = handlers = 55 | ✅ |

---

## 1 · Les 43 contrôles

| # | Contrôle | Verdict | Preuve (mesure) |
|---|---|---|---|
| A1 | assertions passent, compte = plancher, test/ = _ops/ | ✅ | base neuve 001→016 + fixture : `OK   M-` = 41 / plancher 41, rc 0 ; `cmp` identiques ; rejoué 2× de suite : 41/41 (`A1_verdict.txt`, `A1_assertions.log`). ⚠️ `make test` lui-même NON lancé (interdit) : portes contrat et Playwright non rejouées |
| A2 | elles tombent quand on casse un mur | ✅ | `DROP TRIGGER tg_m10` → M-10 lève « LE GESTE EST PASSÉ », rc 3, 19 OK avant l'arrêt (`A2_sabotage_m10.log`) |
| A3 | CI = moi | ✅ | `.github/workflows/ci.yml` : `fetch-depth: 0`, `git branch -f main origin/main`, `bash outils/verif_trailers.sh`, `bash outils/cliquet.sh` |
| A4 | `dossier.py` ne crie pas | 🟠 | joué sur une COPIE (scratchpad) : « ⚠️ ECART : le SQL crée 44 référentiels, le registre en compte 74. Un des deux ment. » — la base en a 74 : c'est l'outil qui compte mal (`A4_dossier.txt`) |
| A5 | fiches de l'auditeur interne | ✅ | `audit/` : E1…E7 + 10 fiches L2 |
| B1 | aucun `if` métier en dur | 🟠 | 3 greps (`B1_greps.txt`) lus un par un : faux positifs (périmètre, clés de politique, routes web) ; vrais : `besoin.ts:327-328` (catégories de décision hors table `CAT`), `identite.ts:226/252` (`'externe'` hors `CAT`). ⛔ **Le grep ne voit pas le SQL** : `projet.ts:58,99` écrivent `etat_code = 'ouvert'` (un CODE, pas une catégorie), `projet.ts:95` `'regie'`, `crm.ts:271` `'principal'`, `besoin.ts:43` `'postes'` alors que `besoin.unite_couverture` existe ; `admin.ts:87-108` règles d'archivage par type en dur (voir CONFORMITE8 H-6) |
| B2 | politiques en base = registre §E | ✅ | 201 = 200 (tableau §C) + 1 (prose) ; 0 clé d'un côté sans l'autre (`B2_B5.txt`) |
| B3 | `valeur = valeur_defaut` au seed | ✅ | 0 ligne |
| B4 | `ref_*` = registre §E | ✅ | 74 = 74 |
| B5 | CHECK sur liste de codes, mesuré en base | ✅ ⚠️ | 9 contraintes rendues, toutes justifiées au registre §D (V-132 + « quatre de plus »). ⚠️ angle mort de la requête : un CHECK sur **un seul** code n'est pas `ANY (ARRAY[` — `preparation_paie` (`etat = 'brouillon'`), `personne_coordonnee` (`type_code = 'reseau_social'`) échappent (G-7) |
| C1 | aucune colonne `tenant_id` | ✅ | grep non vide (3 commentaires qui disent qu'il n'y en a pas) ; `information_schema` : 0 colonne `%tenant%` |
| C2 | ni DELETE ni TRUNCATE ; serveur en `ava_serveur` | ✅ | requête : 0 ligne ; `pg_stat_activity` au banc : `ava_serveur` ; serveur lancé en `postgres` → « refuse de démarrer » rc 1 (`C2_superutilisateur_refuse.txt`) |
| C3 | événements et snapshot sans UPDATE | ✅ | même requête (evenement_metier, snapshot_marge, prestation_version) : 0 ligne |
| C4 | `ava_lecture_agregats` : 7 relations | ✅ | politique, ref_devise, ref_pays + 4 `v_*_par_devise` ; 0 fonction SECURITY DEFINER exécutable |
| C5 | 7 murs-triggers | ✅ | tg_m4_m14, tg_m6, tg_m7, tg_m10, tg_m12 (×4 tables), ajout_seul (×5) — et M-16/M-18 en plus (`C1_C5.txt`) |
| K1 | hors banc, tout en 401, rien écrit, rien tracé | ✅ | serveur sans `AVA_MODE` : 55 commandes × 3 en-têtes + 9 routes (vues, statique, 404) = 173 appels → 173 × 401 ; `/sante` 200 ; empreinte de TOUTES les tables (tentative_refusee comprise) inchangée (`K1_hors_banc.txt`) |
| K2 | une session n'est jamais l'identifiant d'un compte | ⚠️ | UUID de rh → `DROIT` ✅ ; mais au banc la « session » est l'**e-mail en clair**, sans jeton (D-10 non livré, lot 2c) — ne vaut que parce que K1 ferme tout hors banc (`K2_K3_banc.txt`) |
| K3 | compte désactivé ne fait rien | ✅ | eval passé `actif=false` : commande et vue → `DROIT`, 0 événement |
| K4 | le périmètre se juge sur l'objet visé, pour toutes les commandes | 🔴 | la table couvre les 55 ✅ ; mais **par champ** : 96 champs pointés vers LYO → 79 refus, **15 écritures réelles hors agence** + 2 entrées ignorées ; et `soi` + agence = global sur les commandes S (SECURITE8 I-1 à I-7) |
| K5 | pas d'accès sans mot de passe hors poste de dev | ⚠️ non mesurable | pas de serveur à mesurer ; sur le poste : `trust` loopback seulement, `listen_addresses=*`, `ava_serveur` sans mot de passe — assumé (V-093) (`K5_verif_serveur_poste.txt`) |
| D1 | `_ops/` n'a pas bougé | ✅ | `git diff --stat origin/main HEAD -- _ops/` vide. ⚠️ `main` n'est pas ancêtre de HEAD (31 commits « canon porté sur main ») |
| D2 | aucun ORM | ✅ | grep sur server/web/test package.json : rien |
| D3 | migrations jamais réécrites | 🟠 | `git log --diff-filter=M -- db/migrations/` : **4b74720** (23/09, 001) et **d1776e3** (24/09, 001 + 002 : `ref_decision_client`) (G-2) |
| D4 | REMARQUES.md existe | ✅ | `journal/REMARQUES.md` (+3 par dossier) — non lu (mur d'indépendance) |
| D5 | chaque commit a son trailer `Role:` | 🟠 | `verif_trailers.sh origin/main` : OK, 215 commits, **dont 29 sans trailer tolérés** (antérieurs à D-29) + 3 exceptions nommées (`D5_verif_trailers.txt`) |
| E1 | aucun `if` d'état dans /web | ✅ | 0 ligne |
| E2 | aucun calcul d'argent dans /web | ✅ | 0 ligne |
| E3 | aucun libellé d'état en dur | ✅ | 0 ligne ; lecture à l'œil de `web/src` (631 lignes) : présentation seule |
| E4 | /web n'importe ni server ni db | ✅ | 0 ligne |
| E5 | ni ORM ni SQL dans /web | ✅ | 1 ligne : la police binaire `.woff2` (faux positif) |
| F1 | PORTES.md existe et à jour | ⚠️ | 337 lignes ; phrases périmées : P-001 « 22 assertions + 1 » (41 mesurées), P-066 « x-ava-session… refus tracé » (l'en-tête est `x-ava-groupe`, et K1 exige « rien tracé ») |
| F2 | les quatre espèces tournent | ⚠️ | ✅ par espèce : A 1 · B 328 · C 1 · D 2 — mais C et D servies **seulement sur /tuyau** ; les 5 portes des écrans besoin sont ⏳ (lot 3) |
| F3 | portes servies de main présentes dans HEAD | ✅ | 5 servies sur `origin/main`, 0 disparue. ⚠️ `main` ne porte que 5 ✅ : F3 ne protège que 5 portes sur 332 |
| F10 | aucune ✅ → ⏳ non déclarée | ✅ | histoire premier parent : P-062…065 @ b2b7d1e, déclarés au tableau D-35 avec ce sha |
| F11 | aucune ⏳ au-delà de son lot | ✅ | 5 ⏳, lot cible 3, lot courant 2 |
| F4 | aucun skip | ✅ | grep grille (hors node_modules) : 20 lignes, toutes lues : `ExitCandidate`, `exitCode`, `toBeDisabled`, `animations: "disabled"` |
| F5 | chaque porte vue rouge, avec date | ✅ | 337/337 datées `AAAA-MM-JJ` (la case 5 du cliquet ne vérifie que « non vide ») |
| F6 | le cliquet mesure, case 1 exige l'exécution | ⚠️ | lu (13 cases) : case 1 exige make_rc=0 ET chaque ✅ exécutée ✅. Faiblesses : case 6 = un grep `E[1-7]` n'importe où dans ETAPES.md (se déclare) ; case 5 ne lit pas la date ; case 10 laisse passer une ⏳ **sans** lot cible (`$8 != ""`) alors que F11 l'appelle « un parking » ; case 1 compte une porte « exécutée » par son numéro : 6 tests portent 2 numéros (G-4) |
| F7 | branché en pre-push | ✅ | `.githooks/pre-push` = `exec bash outils/cliquet.sh` ; `installer.sh` pose `core.hooksPath` (vide dans ce clone neuf — attendu, non corrigé par l'auditeur) |
| F8 | la CI relance le même script | ✅ | `run: bash outils/cliquet.sh` |
| F9 | ne s'arrête pas à la première case | ✅ | `set -u` sans `-e`, 13 `line` inconditionnels, sortie après le résumé |
| F13 | descend de `lot-2-brain` | ✅ | `git merge-base --is-ancestor origin/lot-2-brain HEAD` → vrai (pas de branche locale ; la case 13 va chercher `origin`) |
| F12 | aucune ✅ de la branche ne disparaît | ✅ | ✅ de `origin/main` + départ + 215 commits de la branche : 0 absente de HEAD |

---

## 2 · Les constats de la grille

### G-1 · K4 : le périmètre par objet a des trous — 🔴
- **défaut** : la garde `exigeAgence` ne lit que les champs déclarés dans `CORRESPONDANCE`, et s'arrête au premier objet trouvé pour les commandes de nature `objet`.
- **cible** : `server/src/agence.ts` (`CORRESPONDANCE`, boucle `for (const l of ligne.lecteurs)` … `break`).
- **famille** : K (I) · **gravité** : critique.
- **preuve / reproduire / mesure / correction** : SECURITE8.md, I-1 à I-7 (`rapport/preuves/securite8/croise_55.md`).
- **prétend** : K4 « par commande : un cas hors agence → DROIT » ; P-321 « chaque commande servie a une nature ».
- **mesure** : un cas par commande passe ; **un cas par champ** échoue 15 fois.

### G-2 · D3 : deux migrations publiées réécrites — 🟠
- **défaut** : `001_schema.sql` et `002_seed_ref.sql` modifiés après publication.
- **cible** : `db/migrations/001_schema.sql`, `002_seed_ref.sql` · **famille** : D · **gravité** : moyenne.
- **preuve** : `git log --diff-filter=M --oneline -- db/migrations/` → `d1776e3` (24/09, +`ref_decision_client` dans 001 et 002), `4b74720` (23/09, D-22 dans `unite_arbre`).
- **reproduire** : la commande ci-dessus dans le clone.
- **prétend** : 015 l. 4 « 001 → 014 sont publiées : on ne les réécrit pas » ; grille D3.
- **mesure** : une base migrée avant le 23/09 ne rejoue pas 001/002 (`make migrate` saute « déjà joué ») ; elle n'est rattrapée que parce que 010 et 012 refont le même travail — par chance, pas par règle.
- **correction** : figer 001/002 dans leur version publiée ; porter tout changement dans une migration neuve ; ajouter au cliquet la case D3 (`--diff-filter=M` depuis le départ de branche).

### G-3 · A4 : l'outil du dossier crie à tort — 🟠
- **défaut** : `dossier.py` compte les `ref_*` créés par `CREATE TABLE IF NOT EXISTS` seulement → 44 ; la base et le registre disent 74.
- **cible** : `_ops/outils/dossier.py` (calcul `M["ref_sql"]`) · **famille** : A · **gravité** : faible.
- **preuve** : `rapport/preuves/grille8/A4_dossier.txt` · **reproduire** : copier `_ops db journal outils` ailleurs, `python _ops/outils/dossier.py` · **prétend** : « ne crie pas » · **mesure** : crie « 44 vs 74 », et compte 37 assertions (plancher 41).
- **correction** : compter en base (`pg_tables`) ou lire aussi les `FOREACH … ARRAY[...]` des migrations ; aligner le compte d'assertions sur `plancher_assertions.sh`.

### G-4 · 332 portes servies = 326 tests — ⚠️ (F1, F6)
- **défaut** : six tests portent chacun deux numéros de porte ; le tableau compte 12 portes pour 6 tests.
- **cible** : `journal/PORTES.md` l. 336-348 ; `test/contrat/audit7.test.ts` l. 36, 58, 91, 110, 147, 180 (`"P-326 P-333 …"`) · **famille** : F · **gravité** : moyenne.
- **preuve** : phrases identiques P-326 = P-333 … P-331 = P-338 ; noms de test à double numéro.
- **reproduire** : `awk -F'|' '/^\| *P-[0-9]+ *\|/{ph=$4; if (ph in s) print s[ph]" = "$2; else s[ph]=$2}' journal/PORTES.md`.
- **prétend** : « 332 portes » · **mesure** : 326 tests distincts derrière les 332 ✅ ; la case 1 les voit « exécutées » deux fois par un seul test.
- **correction** : un numéro par test ; retirer P-333…P-338 par ADR (ou les rendre à des tests distincts) ; case du cliquet : « une phrase = une porte ».

### G-5 · Trois cases du cliquet se déclarent plus qu'elles ne mesurent — 🟡
- **défaut** : case 6 (grep `E[1-7]` n'importe où), case 5 (colonne non vide, pas une date), case 10 (⏳ sans lot cible acceptée).
- **cible** : `outils/cliquet.sh` l. 180-203, 330-340 · **famille** : F · **gravité** : faible.
- **preuve** : lecture du script (non lancé) · **prétend** : « aucune case ne se déclare » (F6) ; F11 « une ⏳ sans échéance est un parking » · **mesure** : aujourd'hui aucune porte ne tombe dans ces trous (dates toutes au format, 5 ⏳ toutes avec lot 3).
- **correction** : case 5 = regex de date ; case 10 = KO si `$8` vide ; case 6 = lire l'étape courante, pas n'importe quelle mention.

### G-6 · B1 ne voit pas les codes écrits dans le SQL — 🟠
- **défaut** : états, types et défauts écrits en littéral dans des requêtes, invisibles aux trois greps.
- **cible** : `server/src/commandes/projet.ts:58,99` (`'ouvert'`), `:95` (`"regie"`), `crm.ts:271` (`"principal"`), `besoin.ts:43` (`"postes"`), `admin.ts:87-108` (règles d'archivage par type) · **famille** : B · **gravité** : élevée pour `besoin.ts:43` (la politique `besoin.unite_couverture` existe et n'est pas lue — CONFORMITE8 H-7), moyenne pour le reste.
- **preuve** : lecture ; `conformite8/politiques_non_lues.txt` (SetPolicy `besoin.unite_couverture=fte` → CreateNeed écrit `postes`).
- **prétend** : `cycle.ts` « Catégories — les seules chaînes d'état du serveur » · **mesure** : 5 codes métier hors de cette table.
- **correction** : états initiaux par `codeCategorie` ; défauts par politique ou par `ref_*` (colonne `defaut`) ; élargir B1 à `'[a-z_]+'` dans les chaînes SQL des handlers.

### G-7 · B5 ne voit pas un CHECK sur un code seul — 🟡
- **défaut** : la requête B5 cherche `ANY (ARRAY[` ; un CHECK `etat = 'brouillon'` lui échappe.
- **cible** : `preparation_paie` (`etat = 'brouillon' OR figee_le IS NOT NULL`), `personne_coordonnee` (`type_code = 'reseau_social'`) · **famille** : B · **gravité** : faible (commandes non servies au lot 2).
- **preuve** : `psql … pg_get_constraintdef … ~ '= ''[a-z_]+''::text'` (voir `B2_B5.txt` pour la requête B5).
- **prétend** : V-132 « toute liste d'états est un `ref_*` », le code raisonne sur la catégorie · **mesure** : deux CHECK raisonnent sur un code de référentiel.
- **correction** : raisonner sur la catégorie (fonction ou trigger qui lit `ref_*.categorie`) ; élargir la requête B5 à `= '…'::text` hors `ref_*`.

### G-8 · V-131 : égalité vraie à la table, pas au privilège — 🟡
- **défaut** : `ava_app` garde des privilèges qu'aucune commande n'utilise.
- **cible** : UPDATE sur `temps`, `absence`, `document`, `qualification`, `qualification_mesure` ; INSERT sur `politique` ; UPDATE sur `groupe_permission_perimetre` · **famille** : C · **gravité** : faible.
- **preuve** : `grille8/V131_ecrivables_ava_app.txt` (23 tables hors `ref_*` + 74 `ref_*`, égalité P-325 ✅ au niveau table).
- **prétend** : P-325 « exactement celles qu'une commande servie écrit » · **mesure** : vrai par table ; 7 privilèges en trop (dont UPDATE sur `temps` : un temps se réécrit par SQL sans trigger d'immuabilité).
- **correction** : calculer le GRANT par (table, privilège) ; P-325 au même grain.

### G-9 · Textes périmés dans les fichiers qui font foi — 🟡
- **défaut** : `_ops/GRILLE_AUDIT.md` `<etat>` « 19/09, aucun lot audité, JOURNAL_BUGS 0 ligne » et « famille F — les contrats » (F est le cliquet) ; L7 l. 19 « 167 clés » ; P-001 « 22 assertions + 1 » ; P-066 « x-ava-session … refus tracé ».
- **famille** : F/D · **gravité** : faible · **correction** : à porter sur `main` (D1), pas sur la branche.

---

## 3 · ANGLES MORTS

- `make test` non lancé (consigne) : les 13 fichiers de portes contrat et Playwright **n'ont pas été rejoués** ; A1 ne couvre que L7.
- `cliquet.sh` lu, non exécuté : ses verdicts réels (cases 1, 12) non observés.
- `web/dist` absent du clone : les routes statiques n'ont été vues qu'en 401 (K1), jamais servies.
- K5 : aucun serveur de production à mesurer.
- A4 joué sur une copie hors dépôt : la ligne `commit=` qu'il imprime vient d'un autre dépôt git parent (artefact de la copie).
- Périmètres `pole` / `equipe` : acceptés par le schéma, ignorés par `aLeDroit` (seuls `global`, `agence`, `soi` couvrent) — non testés.
- Lecture seulement des fichiers qui font foi ; `JOURNAL_BUGS`, `REMARQUES`, `ARBITRAGE_*`, `PLAN_*` non lus : une décision qui justifierait un écart ici m'est invisible.
