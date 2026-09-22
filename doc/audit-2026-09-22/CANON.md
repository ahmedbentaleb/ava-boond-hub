# Famille J — le canon face à la base, commit `7e3f78c`

**14 constats J : 9 chiffres faux ou périmés, 4 contradictions entre documents, 1 règle qu'on ne peut pas mesurer telle qu'elle est écrite.**
⭐ Quand la spec et les migrations divergent, c'est la **base** qui a raison : chaque constat vise le document.
Base de mesure : `ava_audit2_c`, migrations 001 → 007 jouées dans l'ordre. Sorties longues dans `rapport/preuves/canon/`.

## Les chiffres du canon contre la base

| Chiffre | Ce que dit le canon | Base (mesure) | Verdict |
|---|---|---|---|
| Politiques | `SPEC_SQL:9,226,1646` 167 · `ASSERTIONS:19,463` 167 · `SPEC_SQL` §16 bis « 169 → 173 » · `REGISTRE:329` **173** · `REGISTRE:332` « 79 métier · 2 installation · 86 apparence » (= **167**) | **173** = 85 métier · 2 installation · 86 apparence | ⛔ trois chiffres en circulation ; la cellule « seule source » se contredit elle-même |
| Les politiques, clé par clé | registre §C : 172 clés en tableau + `ui.theme.personnalise` en prose | 173 ; `comm` registre/base : un seul écart, `ui.theme.personnalise` (celle en prose) | ✅ |
| Référentiels | `REGISTRE` §E : 40 (33 en §B + 7 techniques) · `SPEC_SQL:9` 34 | 40 ; §B et base concordent un à un | ✅ au registre · ⚠️ spec restée au lot 1 |
| Tables (hors `ref_*`) | `REGISTRE:333` « **36** + `reprise_boond` » (= 37) · `SPEC_SQL:9` 37 | **43** (+5 de 006, + `tentative_refusee` de 005) | ⛔ le §E, qui se dit « seule source », est faux |
| Commandes | `ETAT:29` 55 · `L4:3` 55 · `MATRICE:69` 55 · `SPEC_SQL:1175,1648` **44** · `ASSERTIONS:465` 44 · `LISEZ-MOI:70` 44 · `GRILLE:213` 44 | 55 permissions = 55 handlers = 55 commandes de la MATRICE (`diff` vide) | ⚠️ 4 documents disent encore 44 |
| Assertions | `SPEC_SQL:1634,1652` 22 · `LISEZ-MOI:73` 22 | plancher **29** = 29 lignes `OK   M-`, rc 0 | ⚠️ périmé (la grille, elle, ne recopie plus le chiffre) |
| Murs | 15 partout | M-1 → M-15, les 15 ont au moins une assertion | ✅ |
| Écrans | `ETAT:31` **26** · `SPEC_SQL:1535`, `ASSERTIONS:271`, `LISEZ-MOI:72`, `ava-terminal.html:2498,2512` **24** | la maquette qui « fait foi » déclare **26** écrans dans `ECRANS` (`ava-terminal.html:2350-2464`) | ⚠️ la maquette contredit son propre commentaire |
| Cases de la matrice | `MATRICE:188` « les **396** cases » | 55 × 9 = **495** (48 lignes × 9 = 432) ; 83 ✓ · 3 S · 90 D · 319 — | ⚠️ chiffre de l'époque « 44 » |
| Concordance MATRICE ↔ seed | V-043 | ✓ et S de la matrice = paires de `groupe_permission_perimetre`, 0 écart dans les deux sens ; aucune case D n'est semée | ✅ |
| Constats (arbitrage) | « 42 retenus · 5 requalifiés » | le tableau en marque 6 : 41 + 6 | ⛔ voir CONTESTATION ligne 1 |

## `ETAT_PROJET.md`, qui se dit « source unique »

| Ligne | Ce qu'elle dit | Mesure | Verdict |
|---|---|---|---|
| 28 | 15 murs | 15 | ✅ |
| 29 | 55 commandes ; « élevés et moyens en cours » | 55 ✅. Au moment où ce fichier est commité (`6503168`, 22/09 10h34), **37 V- ont déjà leur commit**, V-013 → V-039 compris ; le dernier (`1231bc8`) date du 21/09 23h30. Seul V-011 n'a aucun commit | ⚠️ l'état était déjà dépassé le jour où il a été écrit |
| 29 | « critiques C1 → C7 corrigés » | la numérotation C1 → C7 n'existe dans aucun document que j'ai le droit de lire (elle vient des prompts, que je ne lis pas) | ⚠️ invérifiable à ce niveau de lecture |
| 30 | Lot 2c ⬜ | le code accepte déjà une « session » hors banc (`index.ts:149-157`, `executer.ts:72-82`) | ⛔ le code a un état que le canon ne décrit pas |
| 31 | 26 écrans | 26 dans la maquette ; 24 dans 5 autres endroits du canon | ⚠️ |

## Spec contre migrations : la base a raison

| # | Divergence | Preuve |
|---|---|---|
| a | `SPEC_SQL` §16 bis : « LE SCHÉMA CIBLE = CE FICHIER + LA MIGRATION 006 ». Faux : la base a aussi 005 (`tentative_refusee`, 2 politiques, comptes et droits) et 007 (3 `ref_*`, FK, `ava_serveur`, GRANT) | `comm` tables de la spec / de la base : présentes en base seulement → `besoin_domaine besoin_outil candidat_domaine candidat_outil personne_coordonnee tentative_refusee` et `ref_statut_contact ref_type_coordonnee ref_usage_coordonnee` |
| b | `SPEC_SQL:658` garde `CHECK (statut_code IN ('actif','parti'))` ; la base l'a remplacé par `fk_contact_statut` → `ref_statut_contact` (007:107-110). Qui lit la spec réintroduit la liste figée que D-9 a retirée | `grep -n statut_code _ops/SPEC_SQL_AVAMANAGER_V1.sql` |
| c | 004 (`positionnement.personne_id` nullable) **est** reportée dans la spec (`SPEC_SQL:752-757`) | ✅ aucun écart |
| d | M-15 : la spec fait `REVOKE SELECT` (`:1571`), 007 fait `REVOKE ALL` (`007:154`). L'effet mesuré est le même : 7 relations en SELECT, rien d'autre | ✅ équivalent |

## Documents entre eux

| # | Contradiction | Preuve |
|---|---|---|
| J-4 | `MACHINES:23` : `NeedStateChanged` « *L4 fait foi* » — L4 ne le contient pas | `grep -c NeedStateChanged _ops/SPEC_COMMANDES_L4.md` → 0 ; `server/src/commandes/besoin.ts:24` l'émet |
| J-5 | `MACHINES:91` `CancelPrestation` : DP — MATRICE `:132` et base : DP, STAF | requête `groupe_permission_perimetre` → `CancelPrestation\|DP,STAF` |
| J-6 | `MACHINES:32` : `sorti` est un « code système » — la base dit `systeme = false` | `select code,systeme from ava.ref_etat_candidat` → `sorti\|f` |
| J-12 | `L4` §C-5 : « SORTIE la politique · ⭐ et la LISTE des commandes dont le comportement change » — la réponse HTTP ne porte pas cette liste | `admin.ts:95` renvoie `commandes_affectees` ; `executer.ts:42-46` ne garde que l'objet `politique` (clé de `WRAP`) ; sortie mesurée : `{"id","cle","valeur","ancienne","mur_touche"}` |

## Règles qu'on ne peut pas tenir ou mesurer telles qu'elles sont écrites

| # | Règle | Pourquoi elle ne se mesure pas |
|---|---|---|
| J-7 | `GRILLE:49` B5 « `grep -n "CHECK (code" db/migrations/` → vide », 🔴 | (1) Le grep **n'est pas vide** : `005_droits_lot2.sql:26` `code … CHECK (code IN ('DROIT',…))` sur `tentative_refusee`, qui n'est pas un référentiel. Appliquée à la lettre, la grille refuse le lot (faux 🔴). (2) Il ne voit pas `perimetre.type_code IN (…)` ni les CHECK de 006 que V-021 avait trouvés. V-023 a corrigé B1, pas B5 |
| J-8 | `GRILLE:98` D5 « personne n'écrit dans `/test` sauf le sous-agent 3 » | Un seul auteur git. Même par trailer, `test/` a été touché par `banc` (18), `greffe` (5), `ecran` (1) et un commit sans rôle (`c9b3067`). Et `GRILLE:140` F7 (`core.hooksPath`) est vide dans un clone neuf, sans script qui le pose |
| J-13 | La condition de V-022, « `scram-sha-256` obligatoire sur le VPS » | Elle n'existe que dans l'arbitrage (`ARBITRAGE:69`). Ni T3 ni aucune porte ne la porte : rien ne peut échouer le jour où elle est oubliée |
| J-14 | `GRILLE:213` : « le lot 2 (les 44 commandes) ajoutera une famille F — les contrats » | F est déjà le cliquet (`GRILLE:126`, 11 contrôles) : la phrase désigne une famille qui n'existe pas |

---

## Constats candidats

Format : défaut · cible · famille · gravité · preuve · reproduire · prétend · mesure · correction.
Pour reproduire : `export PATH="/c/Program Files/PostgreSQL/16/bin:$PATH"`, depuis le dépôt `ava-audit-2-lecture`.

### J-2 — Hors banc, la session est l'UUID du compte : ADM en 10 essais *(issu de la contestation de D-2)*
Cible        CODE (et BRAIN : le lot 2c ne dit pas ce qui tient lieu de session d'ici là)
Famille      I ; J
Gravité      critique
Preuve       `server/src/executer.ts:72-82` `WHERE c.id::text = $1` ; `server/src/index.ts:149-157` ; `db/migrations/005_droits_lot2.sql:185-193` (UUID `…101` → `…109`) ; `rapport/preuves/canon/J_session_uuid.txt`
Reproduire
```bash
curl -s -X POST http://127.0.0.1:3203/commandes/SetPolicy -H "x-ava-session: 00000000-0000-4000-8000-000000000108" -H 'content-type: application/json' -d '{"cle":"doublon.contact.mode","valeur":"bloquer"}'
```
(serveur lancé sans `AVA_MODE=banc`)
Prétend      ARBITRAGE D-2 « le compte vient d'une session » ; MATRICE « Aucune impersonation »
Mesure       `ok:true` en ADM. Les messages servent d'oracle (« session inconnue » / « permission absente »). L'UUID sort aussi dans les réponses (`manager_compte_id`)
Correction   Tant que le lot 2c n'a pas livré un jeton aléatoire, signé et qui expire : aucune session hors banc, tout appel hors banc refusé.

### J-2b — Les refus « session inconnue » ne sont jamais tracés
Cible        CODE
Famille      I
Gravité      elevee
Preuve       `server/src/executer.ts:121` : `ctx.compte?.id ?? null` vaut `''` (compte vide posé plus haut dans `executerCommande`) → erreur 22P02 sur la colonne uuid, avalée par `:129-131` ; `rapport/preuves/canon/J_trace_refus_session_inconnue.txt`
Reproduire
```bash
psql -h 127.0.0.1 -U postgres -d ava_audit2_c -Atc "select count(*) from ava.tentative_refusee where message like 'session%'"
```
Prétend      POL `historique.tentatives_refusees` ; V-027 corrigé
Mesure       0 ligne, alors que l'énumération a produit des refus « session inconnue »
Correction   Écrire `NULL` quand le compte n'est pas résolu, et poser une porte qui trace un refus d'authentification.

### J-1 — Trois nombres de politiques circulent, et la cellule « seule source » se contredit
Cible        BRAIN · Famille J · Gravité moyenne
Preuve       `_ops/REGISTRE_POLITIQUES_v1.md:329` 173 et `:332` 79 + 2 + 86 (= 167) ; `_ops/SPEC_SQL_AVAMANAGER_V1.sql:9,226,1646` 167 ; `_ops/SPEC_ASSERTIONS_L7.sql:19,463` 167
Reproduire
```bash
psql -h 127.0.0.1 -U postgres -d ava_audit2_c -Atc "select categorie,count(*) from ava.politique group by 1"
```
Prétend      REGISTRE §E « ⭐ la seule source »
Mesure       85 métier · 2 installation · 86 apparence = 173
Correction   « 79 métier » devient « 85 » ; la spec et les assertions renvoient au §E au lieu d'écrire un chiffre.

### J-3 — La spec décrit un schéma cible qui n'est pas la base
Cible        BRAIN · Famille J · Gravité moyenne
Preuve       `_ops/SPEC_SQL_AVAMANAGER_V1.sql` §16 bis « ce fichier + la migration 006 » ; `:658` CHECK `statut_code` ; `db/migrations/007_correctifs_audit.sql:107-110` FK ; la migration 005 n'apparaît nulle part dans la spec
Reproduire
```bash
grep -n "statut_code IN\|tentative_refusee" _ops/SPEC_SQL_AVAMANAGER_V1.sql
```
Prétend      « Le jour où les deux divergent, c'est la BASE qui a raison »
Mesure       6 tables et 3 `ref_*` n'existent qu'en base ; la spec garde un CHECK que la base a retiré
Correction   §16 bis : « ce fichier + les migrations 004 à 007 », une ligne par migration comme pour 006.

### J-4 — `NeedStateChanged` : MACHINES renvoie à L4, qui ne le contient pas
Cible        BRAIN · Famille J · Gravité moyenne
Preuve       `_ops/MACHINES_ETAT_V1.md:23` ; `server/src/commandes/besoin.ts:24`
Reproduire
```bash
grep -c NeedStateChanged _ops/SPEC_COMMANDES_L4.md _ops/MACHINES_ETAT_V1.md
```
Prétend      D-4 « L4 gagne »
Mesure       0 dans L4, 1 dans MACHINES ; le code l'émet
Correction   Écrire dans L4 l'effet de `PositionCandidate` et `PositionResource` sur le besoin (`besoin.staffing.declencheur`), avec son événement.

### J-5 — `CancelPrestation` : MACHINES dit DP, la base dit DP et STAF
Cible        BRAIN · Famille J · Gravité moyenne
Preuve       `_ops/MACHINES_ETAT_V1.md:91` ; `_ops/MATRICE_DROITS_v1.md:132`
Reproduire
```bash
psql -h 127.0.0.1 -U postgres -d ava_audit2_c -Atc "select g.nom from ava.groupe_permission_perimetre p join ava.groupe g on g.id=p.groupe_id where p.permission_code='CancelPrestation'"
```
Prétend      D-5 « MACHINES se corrige »
Mesure       DP, STAF
Correction   `MACHINES:91` → « DP, Staffing ».

### J-6 — MACHINES range `sorti` parmi les codes système ; en base, il ne l'est pas
Cible        BRAIN · Famille J · Gravité bonne *(mineur)*
Preuve       `_ops/MACHINES_ETAT_V1.md:32` ; `db/migrations/005_droits_lot2.sql:18-20`
Reproduire
```bash
psql -h 127.0.0.1 -U postgres -d ava_audit2_c -Atc "select code,systeme from ava.ref_etat_candidat"
```
Prétend      D-8 « la base avait raison »
Mesure       `sorti|f`
Correction   Écrire « code semé par 005, non système, désactivable ».

### J-7 — La règle B5 de la grille donne un faux 🔴 et ne voit pas les vrais
Cible        BRAIN · Famille J · Gravité elevee
Preuve       `_ops/GRILLE_AUDIT.md:49` ; `db/migrations/005_droits_lot2.sql:26` ; `db/migrations/001_schema.sql:1192`
Reproduire
```bash
grep -n "CHECK (code" db/migrations/*.sql ; grep -nE "CHECK *\(.*_code *IN" db/migrations/*.sql
```
Prétend      B5 « → vide », un 🔴 qui refuse le lot
Mesure       1 résultat, sur une table qui n'est pas un référentiel ; 4 CHECK `_code IN` invisibles au grep
Correction   B5 devient une requête sur `pg_constraint` (colonnes `*_code` sous CHECK), qui exclut les exceptions écrites au canon (`perimetre.type_code`, `tentative_refusee.code`).

### J-8 — D5 et F7 ne se mesurent pas, et le trailer `Role:` le montre
Cible        les deux · Famille J ; D · Gravité moyenne
Preuve       `_ops/GRILLE_AUDIT.md:98,140` ; `.githooks/commit-msg` ; 8 commits sur 52 sans `Role:` dans `3b59ca5..7e3f78c`
Reproduire
```bash
git log --format='%h %(trailers:key=Role,valueonly)' 3b59ca5..7e3f78c ; git config core.hooksPath
```
Prétend      ARBITRAGE V-040 « un trailer `Role:` par commit suffit ; crochet posé par script »
Mesure       `test/` écrit par 4 rôles ; `core.hooksPath` vide ; aucun script d'installation
Correction   Un script versionné qui pose `core.hooksPath`, une case du cliquet qui le vérifie, et une D5 réécrite en « rôle → dossiers permis », contrôlée par le crochet.

### J-9 — `ETAT_PROJET`, « source unique », était en retard le jour même où il a été écrit
Cible        BRAIN · Famille J · Gravité moyenne
Preuve       `_ops/ETAT_PROJET.md:29-31` ; `git log --format='%h %ad %s' 3b59ca5..7e3f78c`
Reproduire
```bash
git log --format=%s 3b59ca5..7e3f78c | grep -oE "V-0[0-9]{2}" | sort -u
```
Prétend      « Une seule source pour “où on en est” »
Mesure       37 V- ont un commit avant `6503168`, mais l'état dit « élevés et moyens en cours ». Le lot 2c est ⬜ alors qu'une session existe dans le code. « 26 écrans » ici, 24 ailleurs
Correction   Déduire l'état du journal git (V- commités, V- ouverts) au moment d'écrire, et nommer les V- ouverts (V-011).

### J-10 — Des nombres périmés dans la spec, les assertions, le LISEZ-MOI, la grille, la matrice et le registre
Cible        BRAIN · Famille J · Gravité bonne *(mineur, groupé)*
Preuve       44 commandes (`SPEC_SQL:1175,1648`, `ASSERTIONS:465`, `LISEZ-MOI:70`, `GRILLE:213`) ; 22 assertions (`SPEC_SQL:1634,1652`, `LISEZ-MOI:73`) ; 24 écrans (`SPEC_SQL:1535`, `ASSERTIONS:271`, `LISEZ-MOI:72`, `ava-terminal.html:2498`) ; 396 cases (`MATRICE:188`) ; 36 tables (`REGISTRE:333`)
Reproduire
```bash
grep -noE "[0-9]+ (commandes|assertions|écrans|cases)" _ops/*.md _ops/*.sql
```
Prétend      REGISTRE §E « un compte ne se retient pas, il se mesure »
Mesure       55 · 29 · 26 · 495 · 43
Correction   Remplacer chaque chiffre par un renvoi au §E, ou à la commande qui compte, comme la grille le fait déjà.

### J-11 — L'arbitrage annonce 5 requalifications, son tableau en montre 6
Cible        BRAIN · Famille J · Gravité bonne
Preuve       `_ops/ARBITRAGE_AUDIT_2026-09-21.md:47,52,61,66,69,81` et la ligne « Compte »
Reproduire
```bash
grep -c "🔁" _ops/ARBITRAGE_AUDIT_2026-09-21.md
```
Prétend      « 42 retenus · 5 requalifiés ou partiels · 0 rejeté »
Mesure       41 · 6 · 0
Correction   Corriger le compte.

### J-12 — `SetPolicy` calcule la liste des commandes touchées, puis la jette
Cible        CODE · Famille H ; J · Gravité moyenne
Preuve       `server/src/commandes/admin.ts:93-96` ; `server/src/executer.ts:33,42-46`
Reproduire   la commande de J-2, puis lire `sortie` : `commandes_affectees` n'y est pas
Prétend      L4 §C-5 « ⭐⭐ La sortie liste ce qui change »
Mesure       la sortie vaut `{id, cle, valeur, ancienne, mur_touche}`
Correction   Mettre `commandes_affectees` dans l'objet `politique`, ou sortir `SetPolicy` du dépliage `WRAP`, et poser une porte qui lit la liste.

### J-13 — La condition qui requalifie V-022 n'est écrite nulle part où on la vérifie
Cible        BRAIN · Famille J ; I · Gravité moyenne
Preuve       `_ops/ARBITRAGE_AUDIT_2026-09-21.md:69` ; `_ops/DECISIONS_TECHNIQUES_v1.md:29` (T3 n'en dit rien) ; `rapport/preuves/canon/J_pg_hba.txt`
Reproduire
```bash
grep -rn scram _ops/*.md outils .github
```
Prétend      « `scram-sha-256` obligatoire sur le VPS »
Mesure       une seule occurrence : l'arbitrage lui-même
Correction   L'écrire dans T3 et dans la liste de déploiement, avec une vérification qui échoue (`pg_hba_file_rules` sans `trust`).

### J-14 — La grille annonce une « famille F — les contrats » qui n'existe pas
Cible        BRAIN · Famille J · Gravité bonne
Preuve       `_ops/GRILLE_AUDIT.md:213` contre `:126`
Reproduire
```bash
grep -n "famille \*\*F\|^## F" _ops/GRILLE_AUDIT.md
```
Prétend      « le lot 2 ajoutera une famille F — les contrats »
Mesure       F est le cliquet (11 contrôles) ; aucune famille « contrats »
Correction   Retirer la phrase, ou créer une famille G pour les contrats, avec ses contrôles.

---

## Angles morts

| Non fait | Pourquoi | Ce que ça laisse ouvert |
|---|---|---|
| `outils/cliquet.sh` et `make.sh` non exécutés | ils lancent tout le banc (Docker, ports), hors du poste qui m'est permis | les cases 1, 3 et 9 sont lues, pas vues tourner |
| La spec pas jouée dans une base à elle | une seule base m'est attribuée (`ava_audit2_c`) | la comparaison spec/base couvre les tables, les `ref_*`, les GRANT de M-15 et quelques colonnes, pas chaque colonne |
| « C1 → C7 » (`ETAT:29`) non vérifié | la numérotation vit dans les prompts, derrière le mur d'indépendance | je ne sais pas si les 7 critiques nommés sont les bons |
| Portes `test/contrat` et `test/ecran` non lancées | hors de la famille J | un V- déclaré corrigé peut avoir une porte verte qui ne teste rien (V-010, V-011) |
| V-011 (les portes ne voient pas un droit retiré) | aucun commit ne le cite ; rien de plus n'a été mesuré | probablement encore ouvert |
| Acteurs de MACHINES comparés seulement sur les lignes à une seule commande | certaines lignes mêlent une commande et un « effet de… » (`MACHINES:23` cite IA, RH, Staffing, alors que RH n'a pas `TakeNeedInCharge`) | d'autres écarts restent possibles sur les transitions par effet |
| Documents du 16 au 19/09 (CADRAGE, MODELE_DONNEES, FEUILLES) non recomptés | ils ne se disent pas « faisant foi » pour les comptes | leurs chiffres (33 ou 59 écrans…) sont historiques et non vérifiés |
| Jeu d'essai (V-024) rejoué une seule fois | droits conservés (86 avant, 86 après), mais 30 comptes du banc sans groupe et `evenement_metier` vidé | aucune commande n'a été rejouée sur le banc chargé |
| Base `ava_audit2_c` modifiée par les sondes | SetPolicy (`doublon.*.mode` = bloquer), 2 codes ajoutés par `ManageRefs`, jeu d'essai chargé | la reconstruire avant de la réutiliser |
