# Constats de l'audit indépendant — commit `3b59ca5` (branche `lot-2`)

Audit du 21/09/2026. Clone `ava-audit` (mur d'indépendance vérifié : « mur : OK »), base `ava_audit`,
serveur sur le port 3100. Aucune écriture dans « Ava Manager », dans la base `ava` ni sur le port 3000.
Les preuves sont dans `rapport/preuves/` ; les scripts qui les produisent dans `rapport/preuves/scripts/`.

| Gravité | Nombre |
|---|---|
| critique | 12 (V-001 → V-012) |
| elevee | 11 (V-013 → V-023) |
| moyenne | 17 (V-024 → V-040) |
| bonne | 7 (V-041 → V-047) |

---

## CRITIQUE

### V-001 — Le mur M-15 est percé dans la base, et la porte P-001 le déclare intact
Cible        les deux (CODE : migration non alignée · BRAIN : canon corrigé sans migration ni copie de test)
Famille      C · C4 ; G ; J
Gravité      critique
Preuve       `db/migrations/001_schema.sql:1572-1574` pose `GRANT SELECT ON ALL TABLES … TO ava_lecture_agregats` puis ne retire que 6 tables. Le canon `_ops/SPEC_SQL_AVAMANAGER_V1.sql:1571-1572` fait `REVOKE SELECT ON ALL TABLES` puis ne rend que `ref_devise, ref_pays, politique` — la correction n'a jamais été portée en migration.
             Mesuré (`rapport/preuves/C4_M15_perce.txt`) : sous `SET ROLE ava_lecture_agregats`, `v_conditions_du_jour` rend **34 170 lignes de TJM/CJM** (jeu d'essai), `personne` **21 000 lignes**, plus `prestation_version`, `evenement_metier` (qui porte les lignes `avant/apres` des prestations), `compte`.
             `test/SPEC_ASSERTIONS_L7.sql:363-367` (la copie jouée par `outils/make.sh` et le cliquet) énumère encore trois tables → **23 OK**. La version canon `_ops/SPEC_ASSERTIONS_L7.sql:375` lève : « `ava_lecture_agregats` n'atteint QUE les 4 vues par devise (M-15) — FAUX » (`rapport/preuves/J_assertions_canon_ops.txt`).
Reproduire   `psql -h 127.0.0.1 -U postgres -d ava_audit -v ON_ERROR_STOP=1 -f _ops/SPEC_ASSERTIONS_L7.sql` (rc=3) puis la même avec `test/SPEC_ASSERTIONS_L7.sql` (rc=0)
Prétend      P-001 « Les 15 murs tiennent dans la base : 22 assertions + 1 contre-test » ✅
Mesure       la copie de banc est l'ancienne assertion — celle-là même que le canon dit avoir été verte « pendant que le mur était percé ». Elle l'est toujours.
Correction   Une migration 007 porte le `REVOKE … / GRANT` du canon, et la copie `test/` est remplacée par la version `_ops/` (un seul fichier, ou une égalité vérifiée par le cliquet).

### V-002 — L'application se connecte en superutilisateur `postgres` : les murs posés en GRANT ne la concernent pas
Cible        les deux (CODE · et le prompt d'audit §2.3 prescrit la même URL)
Famille      C · C2, C3 ; I
Gravité      critique
Preuve       `server/src/index.ts:10-11` : `DATABASE_URL ?? "postgres://postgres@127.0.0.1:5432/ava"` ; `outils/make.sh:36` idem ; aucun `SET ROLE` dans `server/src` (grep vide). `pg_roles` : `postgres|rolsuper=t` ; `ava_app|NOLOGIN` (`rapport/preuves/grille_commandes.txt`).
Reproduire   `psql -h 127.0.0.1 -U postgres -d postgres -Atc "select rolname, rolsuper, rolcanlogin from pg_roles where rolname in ('postgres','ava_app')"`
Prétend      `001_schema.sql:1538-1541` « M-6, M-7, M-8 et la moitié de M-15 … un droit qu'on n'a pas ne se retrouve pas »
Mesure       le rôle `ava_app` n'est jamais utilisé : le serveur a DELETE partout (M-8), UPDATE sur l'historique et les snapshots (seuls les triggers, désactivables par ce même superutilisateur, tiennent encore).
Correction   Le serveur se connecte avec un rôle LOGIN membre de `ava_app` (sans superutilisateur), et une porte vérifie `current_user` au démarrage.

### V-003 — Aucune authentification : l'appelant choisit son groupe dans un en-tête
Cible        CODE
Famille      I
Gravité      critique
Preuve       `server/src/index.ts:77-83` lit `x-ava-groupe` ; `server/src/executer.ts:48-60` prend « le premier compte actif du groupe » (`LIMIT 1` sans `ORDER BY`). Sonde : `SUP SetOwnTheme` passe, tout appel `x-ava-groupe: ADM` est administrateur (`rapport/preuves/H_sondes_fonctionnelles.txt`, sections 4 et 8).
Reproduire   `curl -s -X POST http://127.0.0.1:3100/commandes/ManageRefs -H 'x-ava-groupe: ADM' -H 'content-type: application/json' -d '{"referentiel":"ref_pays","code":"XB","libelle":"x"}'`
Prétend      MATRICE « Aucune impersonation — un acte attribué à la mauvaise personne »
Mesure       n'importe quel processus de la machine agit comme n'importe quel groupe, et l'événement est signé du compte tiré au hasard dans ce groupe.
Correction   Une session authentifiée désigne le compte ; le groupe se déduit du compte, jamais de la requête.

### V-004 — Le périmètre n'est jamais comparé à l'objet : écrire sur A donne écrire sur B
Cible        CODE
Famille      H ; I
Gravité      critique
Preuve       `server/src/executer.ts:156` `exigeDroit(ctx, nom)` sans agence ; `server/src/droits.ts:30-31` retombe alors sur l'agence **du compte**. Sonde : IA (périmètre agence PAR) crée un besoin dans l'agence CAS puis change sa priorité → `ok:true` deux fois ; la vue du même besoin rend `actions: []` (`rapport/preuves/I_perimetre_et_S.txt`).
Reproduire   `node rapport/preuves/scripts/sonde.mjs` après avoir créé une seconde agence (voir la preuve)
Prétend      MATRICE §procedure étape 4 « Lire sur B et écrire sur A ne donne jamais écrire sur B (S14) » ; L4 « Résout le droit … puis le périmètre »
Mesure       le périmètre ne filtre que les boutons ; la commande passe.
Correction   Chaque commande résout l'agence de l'objet visé (ou de l'objet créé) et la passe à `exigeDroit` avant toute écriture.

### V-005 — `RecordTimesheet` refuse toujours sous la politique par défaut
Cible        CODE
Famille      H
Gravité      critique
Preuve       `server/src/commandes/projet.ts:397` compare la chaîne `jour` à `String(prest.date_debut)` ; `pg` rend un `Date`, donc `String()` vaut « Thu Oct 01 2026 00:00:00 GMT+0100 » et `"2026-10-02" < "Thu…"` est vrai (`rapport/preuves/H_RecordTimesheet_date.txt`). Sonde : trois saisies DANS les dates → `GARDE jour hors des dates de la prestation`.
Reproduire   `node rapport/preuves/scripts/sonde.mjs` (section 3)
Prétend      P-052 « RecordTimesheet refuse INTROUVABLE » ✅
Mesure       la commande n'enregistre aucun temps tant que `temps.periode = dates_prestation` (défaut) ; la porte ne l'exécute jamais.
Correction   Comparer des dates (côté SQL ou après normalisation ISO), et poser une porte qui saisit un temps réel.

### V-006 — `SetPolicy` ne peut jamais réussir, et sa garde `mur_touche` n'existe pas
Cible        CODE
Famille      H
Gravité      critique
Preuve       `server/src/commandes/admin.ts:87-90` interroge `permission_code` sur la table `permission` (la colonne est `code`) → HTTP 500 `42703`, transaction annulée (`rapport/preuves/H_sondes_fonctionnelles.txt`, sections 4-5). `mur_touche` est lu (`admin.ts:67-72`) et jamais testé ; `commandes_affectees` rendrait toutes les permissions, pas celles de la clé.
Reproduire   `curl -s -X POST http://127.0.0.1:3100/commandes/SetPolicy -H 'x-ava-groupe: ADM' -H 'content-type: application/json' -d '{"cle":"doublon.societe.mode","valeur":"bloquer"}'`
Prétend      P-057 « SetPolicy refuse DROIT » ✅ ; L4 §C-5 « la sortie liste ce qui change »
Mesure       aucune politique ne se règle par l'application ; « tout est paramétrable » ne l'est que par SQL.
Correction   Corriger la requête, implémenter la garde et la liste des commandes réellement affectées, et poser une porte de succès.

### V-007 — La réponse porte le dernier événement du compte, pas celui de la transaction
Cible        CODE
Famille      G · S2 ; H
Gravité      critique
Preuve       `server/src/executer.ts:62-80` (`dernierEvenement` : `WHERE auteur_compte_id = $1 ORDER BY id DESC LIMIT 1`, sans borne de transaction) et `:158`. S2b : `emit()` neutralisé, base déjà jouée une fois (ce que fait `make.sh test`, qui ne remet pas la base à zéro) → **55/55 portes vertes**, 3 sociétés pour 1 `CompanyCreated` (`rapport/preuves/banc/S2b_base_jouee.txt`, `S2b_etat_base.txt`).
Reproduire   `bash rapport/preuves/scripts/banc.sh S2_prepare contrat && python rapport/preuves/scripts/s2.py && AUDIT_S2=1 bash rapport/preuves/scripts/banc.sh S2b contrat`
Prétend      L4 « une commande qui mute et n'émet pas est un bug » ; `assert-fige.ts:40-42` « type d'événement »
Mesure       la porte lit un événement d'une exécution précédente.
Correction   L'événement rendu est celui inséré dans la transaction (`RETURNING id` de `emit`), jamais relu par auteur.

### V-008 — Le cliquet déclare « portes ✅ passent » quand aucune porte n'a tourné
Cible        les deux (banc du CODE · règle F6 du BRAIN)
Famille      F · F6
Gravité      critique
Preuve       `outils/cliquet.sh:40-72` : `make_rc` est imprimé mais n'entre pas dans le verdict ; seules les lignes `✖`/`✘`/`N) [` nommées comptent. Un serveur qui ne démarre pas (`make.sh:220-230`, sortie 1 avant tout test) ne produit aucune de ces lignes. Rejoué sans toucher `ava` : **cases OK=10 KO=0** (`rapport/preuves/banc/S11b_cliquet.txt`).
Reproduire   `AUDIT_MAKE_LOG=rapport/preuves/banc/S11b_make_log_serveur_mort.txt bash rapport/preuves/scripts/cliquet_sans_make.sh`
Prétend      « Cliquet — dix cases mesurées, aucune déclarée »
Mesure       zéro porte contrat, geste ou écran exécutée = cliquet vert.
Correction   La case 1 exige `make_rc = 0` ou un compte de portes exécutées égal au nombre de lignes ✅ de `PORTES.md`.

### V-009 — Les cases 3 et 9 du cliquet mesurent contre un `main` qui n'a pas de colonne « État »
Cible        les deux
Famille      F · F3, F10, F8
Gravité      critique
Preuve       `outils/cliquet.sh:22-24` compte `| ✅ |` ; `git show origin/main:journal/PORTES.md` n'a pas de colonne État → `servies(main)=0`. Supprimer P-002..P-005 (4 portes ✅) : case 3 « 60 >= 0 OK », case 9 OK (`rapport/preuves/banc/S11_portes_supprimees.txt`). En CI, `actions/checkout@v4` sans `fetch-depth` n'a pas de `main` du tout (`.github/workflows/ci.yml:12`) : cases 3, 7, 8, 9 vides.
Reproduire   `bash rapport/preuves/scripts/cliquet_sans_make.sh` après avoir retiré quatre lignes ✅ de `journal/PORTES.md`
Prétend      GRILLE F3 « le contrôle du cliquet » ; F10 « numéro par numéro »
Mesure       on peut supprimer des portes servies sans qu'aucune case ne bouge.
Correction   Comparer numéro par numéro les portes de `main` (quelle que soit la forme de la table) et faire un checkout complet en CI.

### V-010 — 40 portes contrat sur 55 restent vertes quand toutes les commandes refusent sans rien faire
Cible        CODE (banc)
Famille      G · S1 ; A
Gravité      critique
Preuve       S1 (toute commande rend INTROUVABLE avant tout droit) : **15 tombées, 40 vertes** (`rapport/preuves/banc/S1.txt`). `test/contrat/cas.ts` : 52 cas sur 55 sont des refus, dont 40 sur l'UUID nul `NIL` ; `test/contrat/assert-fige.ts` ne lit jamais la base. Les 3 cas de succès (P-006, P-017, P-060) ne vérifient que quelques clés, pas « égalité stricte » comme l'annonce `journal/PORTES.md`.
Reproduire   `python rapport/preuves/scripts/s1.py && bash rapport/preuves/scripts/banc.sh S1 contrat`
Prétend      « 55 portes B lot 2 servies ✅ »
Mesure       40 portes prouvent seulement qu'un UUID nul n'existe pas.
Correction   Une porte par commande sur un cas qui réussit, avec l'état de la base relu après (ligne écrite, événement de la transaction).

### V-011 — Les portes ne voient ni un droit retiré, ni une politique écrite en dur
Cible        CODE (banc)
Famille      G · S4, S5
Gravité      critique
Preuve       S4 : retirer le droit de `DeclareNeedFilled`, la règle S de `RecordTimesheet`, ou la porte de derrière O-2 (`CreatePrestation` en signée sans `SignPrestation`) → **P-034, P-052, P-048 restent vertes**. S5 : `besoin.contact`, `temps.plafond_jour`, `positionnement.unicite` remplacées par leur défaut → **P-030, P-052, P-039 vertes**. S5bis : lire `doublon.societe.mode` et `ui.theme.choix_utilisateur` puis ignorer la valeur → **P-006 et P-060 vertes** (`rapport/preuves/banc/S4_*.txt`, `S5_*.txt`, `S5bis_lue_ignoree.txt`).
Reproduire   `python rapport/preuves/scripts/s4.py CreatePrestation_Sign && bash rapport/preuves/scripts/banc.sh S4 contrat`
Prétend      MATRICE « Un — n'est pas un oubli. C'est un refus attendu, et il a un test » ; ADR-005
Mesure       aucune porte ne joue une commande avec un groupe qui n'a pas le droit dans un cas qui réussirait, ni ne fait varier une politique.
Correction   Pour chaque ligne de la matrice : un cas qui passe, un cas hors périmètre, un cas sans le groupe ; pour chaque politique lue : deux valeurs, deux résultats.

### V-012 — P-001 ne teste pas les moitiés GRANT des murs
Cible        les deux (assertions du BRAIN, copiées par le CODE)
Famille      G · S12, S13, S14 ; C
Gravité      critique
Preuve       `GRANT UPDATE ON evenement_metier TO ava_app` (M-7), `GRANT UPDATE ON prestation_version TO ava_app`, `GRANT SELECT ON prestation_version, v_conditions_du_jour TO ava_lecture_agregats` → **23 OK, rc=0** à chaque fois (`rapport/preuves/banc/S12_*.txt`, `S13_*.txt`, `S14_*.txt`). Seuls M-6 (UPDATE snapshot) et M-8 (DELETE) sont testés par privilège.
Reproduire   `psql … -c "GRANT UPDATE ON ava.evenement_metier TO ava_app"` puis `psql … -f test/SPEC_ASSERTIONS_L7.sql`
Prétend      `001_schema.sql:1590-1592` « M-7 : trigger + REVOKE UPDATE »
Mesure       les assertions jouent en superutilisateur et ne vérifient que les triggers.
Correction   Pour chaque mur « trigger + GRANT », une assertion par privilège, par ce qu'on peut atteindre (comme la nouvelle M-15 du canon).

---

## ELEVEE

### V-013 — Le pourvu automatique à la signature ignore la couverture (le trou F3 revient)
Cible        CODE
Famille      H ; B
Gravité      elevee
Preuve       `server/src/commandes/projet.ts:189-196` : si `besoin.pourvu.mode ≠ manuel_avec_garde`, le besoin passe `pourvu` sans lire `besoin.pourvu.garde_minimale` ni `v_besoin_couverture`. Sonde : besoin de 2 postes, **une** prestation à 50 % signée → `pourvu | postes 1/2 | fte 0.5` alors que `garde_minimale = tous_les_postes_signes` (`rapport/preuves/H_sonde_pourvu_auto_et_cycle.txt`).
Reproduire   `node rapport/preuves/scripts/sonde2.mjs`
Prétend      L4 §C-3 « Pourvu automatique selon `besoin.pourvu.garde_minimale` » ; MACHINES §1
Mesure       deux mi-temps ou un seul poste sur deux suffisent à déclarer pourvu.
Correction   L'effet automatique appelle la même garde que `DeclareNeedFilled`.

### V-014 — Des politiques sont lues puis ignorées : l'événement dit une règle qui n'a pas joué
Cible        CODE
Famille      B ; H
Gravité      elevee
Preuve       lues sans effet : `besoin.pourvu.garde_minimale` (`besoin.ts:128`), `societe.passage_client.propagation` (`projet.ts:177`), `temps.validation` (`projet.ts:420`), `doublon.societe.cles` / `doublon.contact.cles` / `doublon.personne.cles` (`crm.ts:25,253`, `identite.ts:18` — la recherche est codée sur `nom_normalise` ou `email`, jamais `siren` ni `nom+prenom+naissance`). Chacune est écrite dans `liens.politiques`.
Reproduire   `grep -nE 'await pol\(ctx, "[^"]+"\);' server/src -r`
Prétend      L4 « Porte dans `liens.politiques` les clés lues et leur valeur » ; ADR-005
Mesure       changer ces réglages ne change rien, et l'historique affirme le contraire.
Correction   Chaque clé lue gouverne une branche ; une clé non implémentée n'est pas lue.

### V-015 — Des `if` métier en dur dans le serveur : états, codes et rôles
Cible        CODE (et BRAIN : la grille B1 ne les cherche pas)
Famille      B · B1 ; E
Gravité      elevee
Preuve       36 occurrences (`rapport/preuves/B1_if_serveur.txt`), dont : cycle du statut commercial codé sur les **codes** (`crm.ts:75-79`, catégories toutes `defaut`), transitions ressource (`identite.ts:268-272`), codes cibles écrits en dur (`'complete'` `identite.ts:115,160`, `'staffing'` `besoin.ts:19,117`, `'pourvu'` `besoin.ts:146`, `'signee'` `projet.ts:292`…), vocabulaire de décision client (`besoin.ts:308`), rôles (`droits.ts:52` `includes("RES")`, `droits.ts:76-80` `RH`/`RR`), machine d'état recopiée dans `vues.ts:13-81`. La grille B1 ne grep que `db/` → vide.
Reproduire   `grep -rnE "(etat_categorie|etat_code|statut_commercial_code|categorie)\)? *[=!]==|includes\(\"R[HR]\"\)|includes\(\"RES\"\)" server/src`
Prétend      prompt §1 « Un if métier écrit en dur dans le code est un REFUS D'AUDIT » ; L4 interdits
Mesure       les transitions vivent dans le code en deux exemplaires (commandes et vues), pas en référentiel.
Correction   Une table de transitions par catégorie (et un code cible par transition) lue par les commandes et par les vues ; la politique d'acteur désigne un groupe par sa donnée, pas par un littéral.

### V-016 — `ExitCandidate` crée une valeur de référentiel à l'exécution
Cible        les deux
Famille      B ; J
Gravité      elevee
Preuve       `server/src/commandes/identite.ts:132-143` insère `('sorti','Sorti','sorti',…)` dans `ref_etat_candidat` si la catégorie est vide, sans `ManageRefs` ni `RefChanged` ; `db/migrations/005_droits_lot2.sql:18-20` sème ce même code. `_ops/MACHINES_ETAT_V1.md` §2 : « sorti : **aucun code par défaut**, l'admin en ajoute ».
Reproduire   `sed -n 132,143p server/src/commandes/identite.ts`
Prétend      L4 « `ManageRefs` ne peut pas inventer une catégorie »
Mesure       une commande métier écrit dans un référentiel, sans trace.
Correction   Refus `GARDE` explicite quand la catégorie n'a pas de code actif ; le code `sorti` se crée par `ManageRefs`, et le canon tranche s'il existe au seed.

### V-017 — Les codes de référentiel ne sont pas gardés : l'utilisateur voit « MUR erreur interne »
Cible        CODE
Famille      H
Gravité      elevee
Preuve       Sondes : `CreatePerson civilite:"M"` (le code est `m`), `CreateNeed type/couverture inconnus`, `SetNeedPriority "P_INVENTEE"`, `CreateAction type inconnu`, `ManageRefs categorie inconnue`, `UpdateUnit` en cycle indirect → **MUR « erreur interne »** (`rapport/preuves/H_sondes_fonctionnelles.txt` §1, 6, 7 ; `H_sonde_pourvu_auto_et_cycle.txt`). `tentative_refusee` ne garde que « erreur interne » (`executer.ts:118-129`, `kernel.ts:124-134`) : la cause est perdue.
Reproduire   `node rapport/preuves/scripts/sonde.mjs`
Prétend      L4 « Un refus MUR en production est TOUJOURS un bug de commande » ; « ManageRefs : GARDE catégorie inconnue »
Mesure       6 commandes laissent la base refuser à leur place.
Correction   Vérifier chaque code contre son `ref_*` actif avant l'écriture (GARDE), et tracer la cause technique d'un MUR.

### V-018 — Les écrans « Besoins » affichent un bouchon statique servi par le serveur ; les portes écran testent ce bouchon
Cible        les deux
Famille      E ; G
Gravité      elevee
Preuve       `web/src/contrat.ts:159-165` `chargerBouchon` lit `/bouchon/<Commande>.json` ; `web/src/ListeBesoins.tsx:16`, `web/src/FicheBesoin.tsx:71-86` (un clic « joue » un JSON, aucun appel serveur) ; `web/vite.config.ts:35-39` copie le bouchon dans `dist/` ; le serveur le sert (`curl /bouchon/ListerBesoins.json` → 200). Libellés d'état, pastilles et « 1 / 2 postes » écrits à la main dans `web/bouchon/_gen.mjs:127-137`. Le contrat attendu par l'écran (`VueListe`, `action.permise`, `action.refus`) n'existe pas côté serveur (`server/src/vues.ts` rend `{id, libelle}`), et aucune route ne liste les besoins.
Reproduire   `curl -s http://127.0.0.1:3100/bouchon/ListerBesoins.json | head -c 200`
Prétend      P-062 → P-065 ✅ « servies » ; GRILLE E3 « le serveur envoie le libellé »
Mesure       les 4 portes écran et la porte geste P-061 ne touchent pas le serveur ; le grep E3 est vide parce que les libellés sont dans `web/bouchon/`, pas `web/src/`.
Correction   Le serveur expose la vue (libellés, pastilles, permis/refus) ; le bouchon reste un outil de développement, non livré, et les portes D visent le serveur.

### V-019 — Les portes écran ne voient pas un changement de couleur, en clair comme en sombre
Cible        CODE (banc)
Famille      G · S9 ; F
Gravité      elevee
Preuve       S9a pastille `ok` → `#ff0000`, S9b `structure` → `#FF00FF`, S9c titres en rouge (CSS), S9d fond de page `#000000` → `#330000` et `#FFFFFF` → `#FFDDDD` : **P-062, P-063, P-064, P-065 vertes** à chaque fois (`rapport/preuves/banc/S9*.txt`). Capture du fond rouge sombre accepté : `rapport/preuves/S9d_besoins_sombre.png`. `test/playwright.config.ts:12-16` : `maxDiffPixelRatio 0.01` + seuil par pixel par défaut.
Reproduire   `python rapport/preuves/scripts/sw.py S9a_couleur_ok && (cd web && npm run build) && bash rapport/preuves/scripts/banc.sh S9a play`
Prétend      prompt S9 « une porte D doit tomber, en clair ET en sombre »
Mesure       la tolérance absorbe une couleur de thème fausse sur toute la page.
Correction   Une porte D sur les jetons calculés (`getComputedStyle` des variables) en plus de la capture, ou un seuil par pixel resserré.

### V-020 — La règle « soi-même » de `UploadDocument` se contourne par le porteur
Cible        CODE
Famille      H ; I
Gravité      elevee
Preuve       `server/src/commandes/identite.ts:319-320` ne contrôle S que pour `personne_id` et `profil_ressource_id`. Sonde : RES dépose un document sur un **projet** → `ok:true` (`rapport/preuves/I_perimetre_et_S.txt`).
Reproduire   voir la preuve (requête `UploadDocument` avec `projet_id`, groupe RES)
Prétend      MATRICE `UploadDocument` RES = **S**
Mesure       la ressource écrit sur n'importe quel projet, société ou candidat.
Correction   Sous S, seul un porteur rattaché à la personne du compte est admis.

### V-021 — Des listes de valeurs sont figées en CHECK au lieu d'un référentiel
Cible        CODE
Famille      B · B5
Gravité      elevee
Preuve       `db/migrations/001_schema.sql:658` `contact.statut_code IN ('actif','parti')` ; `:1192` `perimetre.type_code IN ('agence','pole','equipe','global')` ; `006_releve_boond.sql:105,108` `personne_coordonnee.type_code`, `usage_code`.
Reproduire   `grep -niE "CHECK *\(.*code *(IN|=)" db/migrations/*.sql`
Prétend      prompt §1 « RÉFÉRENTIEL toute liste de valeurs → tables ref_* »
Mesure       B5 ne cherche que `CHECK (code` et ne voit pas ces quatre listes.
Correction   Quatre référentiels (ou justification écrite au canon de ce qui n'est pas métier).

### V-022 — PostgreSQL accepte toute connexion locale sans mot de passe
Cible        les deux (poste de travail ; `outils/make.sh` en dépend)
Famille      I
Gravité      elevee
Preuve       `pg_hba_file_rules` : `local all all trust`, `host all all 127.0.0.1 trust`, `host all all ::1 trust` (+ réplication) ; `listen_addresses = *` (`rapport/preuves/I_pg_hba.txt`).
Reproduire   `psql -h 127.0.0.1 -U postgres -d postgres -c "select type,database,user_name,address,auth_method from pg_hba_file_rules"`
Prétend      —
Mesure       toute application de la machine lit et écrit toutes les bases (`ava`, et les dix autres du cluster) en superutilisateur.
Correction   `scram-sha-256` pour les connexions TCP et un rôle applicatif à mot de passe hors dépôt.

### V-023 — La grille d'audit ne mesure plus ce qu'elle croit
Cible        BRAIN
Famille      J ; A
Gravité      elevee
Preuve       `_ops/GRILLE_AUDIT.md` : A3 vise `.github/workflows/db.yml` (absent ; `ci.yml`) ; B2 « 167 » (base et registre : 173) ; B4 « 34 » (37) ; A1 « 22 assertions » (23 lignes OK attendues par `make.sh:167`) ; « F — 5 contrôles » (11) ; B1 ne grep que `db/` (les `if` sont dans `server/`, V-015) ; C4 énumère 3 tables (le mur fuit par d'autres, V-001).
Reproduire   `psql … -Atc "select count(*) from ava.politique"` ; `ls .github/workflows`
Prétend      « Écrite AVANT qu'il code … Celle-ci ne discute pas »
Mesure       quatre chiffres périmés et deux greps qui ne peuvent pas trouver ce qu'ils cherchent.
Correction   La grille renvoie aux comptes du registre §E et cherche les `if` dans `server/` et `web/`.

---

## MOYENNE

### V-024 — Le jeu d'essai du canon vide les droits et l'historique, et ne les recrée pas
Cible        BRAIN
Famille      J
Gravité      moyenne
Preuve       `_ops/JEU_ESSAI.sql:77-86` `TRUNCATE … evenement_metier, … groupe_permission_perimetre, compte_groupe, perimetre, groupe, compte …` ; seul `compte` est réinséré (`:157`). Après chargement : `CreateCompany` par IA → `DROIT groupe inconnu ou sans compte de banc` (`rapport/preuves/J_jeu_essai_casse_droits.txt`).
Reproduire   `bash rapport/preuves/scripts/base.sh jeu` puis une commande quelconque
Prétend      « On vide le MÉTIER, jamais les référentiels ni les politiques »
Mesure       le banc « aux volumes réels » ne peut exécuter aucune commande du lot 2.
Correction   Le jeu d'essai recrée groupes, périmètres et droits de 005, ou ne les vide pas.

### V-025 — P-002 teste le port 3000 en dur
Cible        CODE (banc)
Famille      F ; G
Gravité      moyenne
Preuve       `test/contrat/sante.test.ts:19` `fetch("http://127.0.0.1:3000/sante")` ignore `AVA_BASE_URL`.
Reproduire   `grep -n 3000 test/contrat/sante.test.ts`
Prétend      P-002 teste le serveur sous test
Mesure       lancée par l'audit, elle aurait interrogé le serveur du CODE ; rejouée à la main sur 3100 (`curl`), le JSON est conforme.
Correction   Lire `AVA_BASE_URL` comme `http.ts`.

### V-026 — `candidat.note.echelle` : lue par un trigger, écrite par aucune commande, couverte par aucune porte
Cible        les deux
Famille      G · S5 ; H
Gravité      moyenne
Preuve       `db/migrations/006_releve_boond.sql:330-354` ; aucune occurrence de `note_globale` dans `server/src`, `web/src`, `test/contrat`. Sabotage du trigger (échelle écrite en dur à 5) : **23 OK + 55/55 vertes** (`rapport/preuves/banc/S5_candidat.note.echelle*`).
Reproduire   `grep -rn note_globale server/src web/src test/contrat`
Prétend      prompt S5 (« dont candidat.note.echelle »)
Mesure       aucune porte ne peut voir cette politique.
Correction   Une commande qui écrit la note et une porte par échelle.

### V-027 — `tentative_refusee` n'a aucun droit pour `ava_app`, et l'échec de trace est avalé
Cible        CODE
Famille      C ; I
Gravité      moyenne
Preuve       créée par `005_droits_lot2.sql:23-35` après les GRANT de 001, sans GRANT (seule table sans INSERT pour `ava_app`, `rapport/preuves/grille_commandes_2.txt`) ; `server/src/executer.ts:111-113` `catch {}`.
Reproduire   `psql … -Atc "select has_table_privilege('ava_app','ava.tentative_refusee','INSERT')"`
Prétend      L4 « Trace les refus selon `historique.tentatives_refusees` »
Mesure       sous le bon rôle (V-002), aucun refus ne serait tracé, sans alerte.
Correction   GRANT INSERT, SELECT dans une migration, et un échec de trace journalisé.

### V-028 — La migration 001 a été réécrite après publication
Cible        CODE
Famille      D · D3
Gravité      moyenne
Preuve       `git log --diff-filter=M -- db/migrations/` : `98aae74` et `f54c73b` modifient `001_schema.sql`.
Reproduire   la commande ci-dessus
Prétend      D3 « numérotées et jamais réécrites »
Mesure       une base montée avant ces commits diffère d'une base neuve.
Correction   Toute correction passe par une migration nouvelle.

### V-029 — Le canon se contredit sur les événements, les valeurs, `mur_touche` et les acteurs
Cible        BRAIN
Famille      J
Gravité      moyenne
Preuve       (1) Événements : `_ops/MACHINES_ETAT_V1.md` §4 `PositioningCreated`, `CVShareDeclared`, `PositioningStateChanged`, §1 `NeedStateChanged` pour Suspend/Resume/Close/Reopen — `_ops/SPEC_COMMANDES_L4.md` §III `CandidatePositioned`, `CVShared`, `PositioningWithdrawn`, `NeedSuspended`… (le code suit L4). (2) L4 « GARDE doublon si politique = `refus` » — registre et base : `avertir · bloquer · ignorer`. (3) L4 §C-5 « GARDE si `mur_touche` l'interdit » — `SPEC_SQL:253-261` « INDICATIVE pour l'écran, jamais pour la garde » ; 0 politique sur 173 a un `mur_touche`. (4) MATRICE « SUP ne mute rien — la colonne est vide sur les 48 lignes » — même matrice : `SetOwnTheme` ✓ pour SUP (sonde : SUP mute `compte.theme_json`). (5) MACHINES §3 `SetResourceState` « RH ou DP » — MATRICE RH, STAF ; MACHINES §6 création de projet « DP ; Staffing par délégation » — MATRICE STAF ✓. (6) Le registre double `doublon.contact.mode` (lignes 149 et 151) ; sa commande de comptage rend 202, pas 173.
Reproduire   `grep -n "PositioningCreated\|CandidatePositioned" _ops/*.md`
Prétend      « Les fichiers qui font foi »
Mesure       deux documents qui font foi disent deux choses ; le code en choisit une sans trace.
Correction   Le BRAIN tranche chaque paire et corrige l'autre document.

### V-030 — Réponses HTTP : refus en 200, erreurs internes en 500 avec le message SQL
Cible        CODE
Famille      I ; H
Gravité      moyenne
Preuve       `server/src/executer.ts:162-174` rend les refus sans statut ; aucun `setErrorHandler` dans `server/src/index.ts` → la sonde SetPolicy reçoit `{"statusCode":500,"code":"42703","message":"la colonne « permission_code » n'existe pas"}`.
Reproduire   voir V-006
Prétend      L4 « un refus … jamais une erreur 500 »
Mesure       le schéma fuit au client.
Correction   Un gestionnaire d'erreurs qui rend un code générique et journalise le détail.

### V-031 — Un mot de passe de base est écrit en clair dans le dépôt
Cible        CODE
Famille      I
Gravité      moyenne
Preuve       `docker-compose.yml:8` (`POSTGRES_PASSWORD`), `outils/make.sh:37,39`, `db/README.md:22`, `journal/adr/ADR-R-001-port-postgres-hote.md:11` — valeur non recopiée (`rapport/preuves/I_securite_scan.txt`). Présent dans l'historique depuis `1a30280`.
Reproduire   `git grep -nIE "postgres(ql)?://[^@/ ]+:[^@/ ]+@"`
Prétend      prompt §3 « Aucun identifiant, aucun mot de passe »
Mesure       mot de passe de développement (conteneur local), versionné.
Correction   Variable d'environnement hors dépôt, `.env` ignoré.

### V-032 — Sorties non conformes : réponse sans objet, événement d'effet à la place de celui de la commande
Cible        CODE
Famille      H
Gravité      moyenne
Preuve       `ConvertCandidateToResource` rend `sortie = {profil_ressource, personne_id}` sans `id` et `actions: []` (`WRAP` sans `profil_ressource`, `executer.ts:17-45`). `PositionCandidate` annonce `NeedStateChanged`, `SignPrestation` `ClientStatusDerived` ou `NeedFilled`, pas l'événement de la commande (`rapport/preuves/H_sondes_fonctionnelles.txt`).
Reproduire   `node rapport/preuves/scripts/sonde.mjs`
Prétend      L4 colonnes « Sortie » et « Événement »
Mesure       l'écran ne peut pas lire l'objet créé ni l'événement propre de la commande.
Correction   La réponse porte l'objet sous une forme unique et la liste des événements de la transaction.

### V-033 — `UpdateUnit` ne garde pas le cycle indirect
Cible        CODE
Famille      H
Gravité      moyenne
Preuve       `server/src/commandes/crm.ts:173` ne compare que `parentId === id`. Sonde : U1 → parent U2 (fille de U1) → `MUR erreur interne`.
Reproduire   `node rapport/preuves/scripts/sonde2.mjs` (fin)
Prétend      L4 « CreateUnit porte trois refus … la garde doit les distinguer » (et `UpdateUnit` : idem)
Mesure       le troisième refus n'est gardé qu'à la création.
Correction   Remonter l'arbre du parent visé comme dans `CreateUnit`.

### V-034 — `ClosePrestation` n'a pas la garde de date de clôture
Cible        CODE
Famille      H
Gravité      moyenne
Preuve       `server/src/commandes/projet.ts:301-352` n'examine pas la date ; `_ops/MACHINES_ETAT_V1.md` §5 « date de clôture ≤ fin ou = fin ».
Reproduire   `sed -n 301,310p server/src/commandes/projet.ts`
Prétend      MACHINES §5
Mesure       une clôture datée après la fin passe.
Correction   GARDE sur la date.

### V-035 — La référence projet se calcule par `count(*) + 1`
Cible        CODE
Famille      H
Gravité      moyenne
Preuve       `server/src/commandes/projet.ts:5-8`.
Reproduire   deux `CreateProject` simultanés
Prétend      —
Mesure       deux transactions concurrentes tirent la même référence → violation d'unicité → MUR.
Correction   Une séquence.

### V-036 — `ManageRefs` et `ManageGroups` ne font pas ce que dit le contrat
Cible        CODE
Famille      H
Gravité      moyenne
Preuve       `server/src/commandes/admin.ts:97-128` : ni `ordre` ni `actif` (L4 : « renomme, réordonne, désactive ») ; catégorie par défaut `"defaut"` inventée (`:101`). `admin.ts:147-156` : `ON CONFLICT DO NOTHING` puis `GroupPermissionChanged` même sans changement.
Reproduire   lecture des lignes citées
Prétend      L4 §V
Mesure       l'admin ne peut ni désactiver ni réordonner une valeur ; l'historique enregistre des changements qui n'ont pas eu lieu.
Correction   Entrée complète, et événement seulement si une ligne a changé.

### V-037 — `ArchiveObject` contourne les gardes d'archivage de chaque objet ; aucun `Archive*` n'est exécutable
Cible        CODE
Famille      H ; G
Gravité      moyenne
Preuve       `server/src/commandes/admin.ts:44-62` archive une société ou un contact sans les gardes de `ArchiveCompany`/`ArchiveContact`/`ArchiveService` (L4 : « GARDE selon l'objet »). Au seed, personne n'a `ArchiveCompany`, `ArchiveContact`, `ArchiveService`, `ArchiveObject` (`rapport/preuves/H_droits_seed.txt`, conforme aux « D » de la matrice) : leurs portes P-009, P-012, P-016, P-056 ne prouvent que ce refus.
Reproduire   lecture des lignes citées
Prétend      L4 §V
Mesure       le jour où la délégation est donnée, la garde saute par la commande générique.
Correction   `ArchiveObject` délègue à la garde de l'objet.

### V-038 — Les comptes de banc RES n'ont pas de personne : la règle S n'est pas testable
Cible        CODE
Famille      H ; G
Gravité      moyenne
Preuve       `rapport/preuves/H_droits_seed.txt` : `res@ava.test|RES|…|f` (pas de `personne_id`) ; `droits.ts:53-55` refuse alors toujours.
Reproduire   `psql … -Atc "select email, personne_id from ava.compte"`
Prétend      MATRICE S
Mesure       RES ne peut rien saisir pour lui-même ; le cas « soi-même permis » n'existe pas.
Correction   Un compte RES relié à une personne ressource au seed de banc.

### V-039 — La CI ne peut pas passer : captures Linux absentes pour quatre portes écran
Cible        CODE
Famille      A · A3 ; F · F8
Gravité      moyenne
Preuve       `test/ecran/besoin.spec.ts-snapshots/` ne contient que des `*-win32.png` ; la CI tourne sur `ubuntu-latest` (`.github/workflows/ci.yml:9`).
Reproduire   `ls test/ecran/besoin.spec.ts-snapshots`
Prétend      GRILLE F8 « la CI est le vrai mur »
Mesure       P-062 → P-065 échoueraient en CI (capture absente).
Correction   Captures de référence Linux, ou CI Windows.

### V-040 — Un seul auteur git, et le crochet pre-push n'existe pas dans un clone neuf
Cible        les deux
Famille      D · D5 ; F · F7
Gravité      moyenne
Preuve       `git log --format=%an -- server web test db _ops journal outils` : `ahmedbentaleb` partout ; `bf7df47 [ecran]` touche `test/` et `web/`. `git config core.hooksPath` vide dans le clone (la configuration n'est pas versionnée).
Reproduire   les deux commandes citées
Prétend      D5 « personne n'écrit dans /test sauf le sous-agent 3 » ; F7
Mesure       la séparation des auteurs n'est pas mesurable par git ; le crochet dépend d'un réglage local.
Correction   Un auteur (ou un trailer) par rôle, et `core.hooksPath` posé par un script d'installation vérifié par le cliquet.

---

## BONNE

### V-041 — Une commande qui écrit puis lève est annulée en entier
Cible        CODE · Famille G · S3 · Gravité bonne
Preuve       S3a : `CreateCompany` écrit société + événement puis lève → 0 société, 0 événement (`rapport/preuves/banc/S3a_etat_base.txt`) ; la politique reste inchangée après le 500 de `SetPolicy`. ⚠️ Aucune porte ne relit la base : sous S3b (COMMIT au lieu de ROLLBACK), P-006 tombe à cause du 500, pas de la ligne persistée (`S3b_etat_base.txt` : 1 société).

### V-042 — Les triggers de murs sont vraiment testés
Cible        les deux · Famille A · A2 ; G · S6, S7 · Gravité bonne
Preuve       `DISABLE TRIGGER` sur `tg_m10`, `tg_m7`, `tg_m4_m14`, `tg_m12`, `tg_m6` → P-001 tombe à chaque fois ; `GRANT DELETE` (personne, tentative_refusee) → M-8 tombe (`rapport/preuves/banc/S6_*`, `S7*`).

### V-043 — La matrice et le seed des droits concordent
Cible        les deux · Famille H · Gravité bonne
Preuve       55 commandes, cases ✓/S de `_ops/MATRICE_DROITS_v1.md` = `groupe_permission_perimetre` : **0 écart** (`rapport/preuves/H_matrice_vs_seed.txt`) ; `UpdateResourceCost` à personne au seed.

### V-044 — Aucune valeur utilisateur n'est concaténée dans une requête
Cible        CODE · Famille I · Gravité bonne
Preuve       8 interpolations (`rapport/preuves/I_securite_scan.txt`) : noms de colonne ou de table tirés de constantes (`admin.ts:3-23`, `besoin.ts:227-230`) ou d'une regex + existence dans `pg_class` (`admin.ts:102-109`) ; toutes les valeurs passent en `$n`. Front : aucun `dangerouslySetInnerHTML`, React échappe.

### V-045 — Le coût de référence est protégé à l'exécution
Cible        CODE · Famille H · Gravité bonne
Preuve       `server/src/vues.ts:159-163` masque le coût sans `UpdateResourceCost` (sonde : RH ne le reçoit pas) ; `identite.ts:237-239` `UpdateResource` refuse le coût.

### V-046 — O-2 et M-6 tiennent à l'exécution
Cible        CODE · Famille H · Gravité bonne
Preuve       STAF `CreatePrestation` état `signee` → `DROIT` ; `ClosePrestation` écrit `snapshot_marge` dans la transaction ; après `AdjustTimesheetAfterClose` le snapshot n'a pas bougé (`rapport/preuves/H_etat_apres_sondes.txt`). ⚠️ aucune porte ne le prouve (V-011).

### V-047 — Canon et base concordent sur les comptes et les défauts ; `_ops/` n'a pas bougé
Cible        les deux · Famille B, D, J · Gravité bonne
Preuve       173 politiques = registre §E (172 en tableau + `ui.theme.personnalise`) ; 37 référentiels = registre ; défauts métier : 0 écart (1 en prose) ; `valeur = valeur_defaut` partout ; `git diff origin/main -- _ops/` vide ; `python _ops/outils/dossier.py` ne signale aucun écart (`rapport/preuves/A4_dossier_py.txt`).
