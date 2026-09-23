# Troisième audit — suivi des constats sur `416a7a3` (branche `lot-2`)

Auditeur indépendant A. Clone de lecture `ava-audit-3-lecture` sur `416a7a3` (`git status` vide au
début et à la fin). Base `ava_audit3_a` (001 → 008 + `db/fixtures/banc.sql`), serveur sur le port
**3301**. Mutations jouées sur une **copie jetable** (scratchpad, `node_modules` en jonction), jamais
sur le clone de lecture. Sorties longues : `rapport/preuves/suivi3/`.

⛔ **Rien n'est « Fermé » sans une commande exécutée ou un `fichier:ligne` lu.** Les deux verdicts
posés **sur pièce** (CI, cliquet — tous deux interdits d'exécution) sont marqués « Partiel » et
repris dans les angles morts.

## Ce qui a tourné

| Suite | Résultat |
|---|---|
| `contrat/sante` · `inventaire` | 1/1 · 1/1 |
| `contrat/commandes` · `chemin` | 56/56 · 56/56 |
| `contrat/matrice` (dont les 40 portes de périmètre) | **52/52** |
| `contrat/politiques` (dont `v011-*`) | **50/50** |
| `contrat/correctifs` (P-066 → P-270) | **46/46** |
| Assertions L7 (`test/SPEC_ASSERTIONS_L7.sql`) | **31 OK**, plancher 31, `cmp` avec `_ops/` : identiques |
| Portes ✅ du tableau exécutées | **260 / 264** (restent P-001 compté à part, P-003/004/005 = écran Playwright) |
| Portes exécutées **hors** tableau | **0** |

Les 8 migrations passent `rc=0` sur une base neuve.

---

## Les 27 constats neufs du 2e audit (V-048 → V-074)

| Constat | Gravité | Verdict | Preuve |
|---|---|---|---|
| **V-048** | critique | **Fermé** | D-10. Serveur **sans** `AVA_MODE`, port 3301 : `ManageRefs`/`SetPolicy` avec `x-ava-session: …0108`, `x-ava-groupe: ADM`, et sans en-tête → **4 × HTTP 401** `authentification non livrée (lot 2c)`. Avant/après : `evenements=0→0`, `ref_pays=4→4`, `tentative_refusee=0→4`. `index.ts:234-244` refuse avant tout routage ; `grep -rn x-ava-session server/src` → 0. `preuves/suivi3/03_D10_hors_banc.txt` |
| **V-049** | critique | **Fermé** | K1 = P-066 ✅ ; K3 = P-198 (compte désactivé → DROIT, 0 écriture) ✅ ; K4 = **40 portes** P-157 → P-196 (`matrice.test.ts:306-396`), 52/52 vertes. Famille **K, 5 contrôles** dans `_ops/GRILLE_AUDIT.md:90-98`. Sonde indépendante : les 4 commandes qui passaient (`WithdrawPositioning`, `RecordQualification`, `UploadDocument`, `CreateAction` sur objet CAS) → **DROIT, 0 événement écrit**. `20_sonde.txt` |
| **V-050** | critique | **Partiel** | `outils/cliquet.sh:236-271` : case 11 (F12) compare le tableau à **HEAD, HEAD~1 et `main`** ; case 12 vérifie `core.hooksPath`. F12 est dans la grille (`GRILLE_AUDIT.md:153`). ⛔ **Lu, non exécuté** (cliquet interdit). ⚠️ Deux restes mesurés par lecture → candidats N3-1. |
| **V-051** | elevee | **Fermé** | `test/contrat/db.ts:6-9` lève si `DATABASE_URL` manque (plus de défaut `…/ava`) ; `outils/make.sh:79` `export DATABASE_URL="$AVA_URL_MIGRATION"` ; `correctifs.test.ts:58-68` `portLibre()` (plus de 3010/3011), `:122` lit `AVA_URL_SERVEUR`. `grep -rn "5432/ava\|:3010\|:3011" test/contrat/` → **vide**. Suite lancée sans danger : 46/46. Porte P-263. |
| **V-052** | elevee | **Fermé** | `politiques.test.ts` P-133 joue bien `RecordTimesheet` : 1,5 j sous `alerte` → `ok:true` + alerte `PLAFOND_JOUR` + 1 ligne `temps` ; sous `refus` → `GARDE`, 0 ligne. **Mutation** « `temps.plafond_jour` rendu en dur » (copie, `kernel.ts:38`) → **P-133 tombe**. `41_mut_politiques.txt` |
| **V-053** | elevee | **Fermé** | D-11. Après 001 → 008 **sans** fixture : les 9 comptes `@ava.test` sont `actif = f` (`01_D11_comptes.txt`). `008_banc_hors_production.sql:26-27`. `db/fixtures/banc.sql` les réactive ; **deux passes** → `rc=0` les deux fois, même état. `04_fixture.txt` |
| **V-054** | elevee | **Fermé** | `RecordClientDecision decision:"decision_inventee"` → `GARDE « décision inconnue »` ; `positionnement.etat_code` reste `presente`. P-200. `21_sonde2.txt` |
| **V-055** | elevee | **Fermé** | Les trois gardes existent (`admin.ts` ManageRefs) : catégorie hors `ck_cat` → `GARDE « catégorie inconnue »` ; valeur système → `GARDE « valeur système : on ne la désactive pas »` ; valeur utilisée → `GARDE`. Renommage **n'active plus** : `false` → renommé → **`false`**. P-201. ⚠️ Deux angles neufs → N3-2, N3-3. |
| **V-056** | elevee | **Fermé** | `SetPolicy projet.cloture.garde = cascade_cloture_prestations` puis `CloseProject` → **`ok:true`**, `etat_code = clos`, événement `ProjectClosed` portant la clé lue. P-202. `21_sonde2.txt` |
| **V-057** | elevee | **Fermé** | `evenement_metier` du type `PrestationSigned` : `liens.politiques` porte **8 clés** (`prestation.avenant.mode`, `prestation.surcharge.*`, `societe.passage_client.*`, `besoin.pourvu.mode`, `projet.contact`, `projet.devises_mixtes`). P-256. `21_sonde2.txt` |
| **V-058** | elevee | **Fermé** | D-12. `grep -rn "includes(GROUPE" server/src` → **0**. Base : `perimetre_type_code_check` porte `'soi'`, 1 ligne `soi`, les 3 cases S de RES y sont déplacées (`008` §2). `droits.ts:30-32,66` lit le type. **Mutation** « un `"RES"` en littéral dans `droits.ts` » → **P-139 tombe**. `02_D12_perimetre.txt`, `42_mut_litteral.txt` |
| **V-059** | elevee | **Fermé** | `_ops/GRILLE_AUDIT.md:90-98` — famille **K · L'ACCÈS**, 5 contrôles K1 → K5, chacun 🔴, chacun nommant son V-. |
| **V-060** | moyenne | **Fermé** | D-13. `outils/installer.sh` pose `core.hooksPath=.githooks` ; `cliquet.sh:275-284` case 12 le vérifie ; `.githooks/commit-msg:18-32` refuse un commit qui touche `test/` sans `Role: banc`. Sur 116 commits depuis `3b59ca5` : **8 sans trailer**, exactement les 8 antérieurs au crochet (arbitrage, contestation 7). |
| **V-061** | moyenne | **Fermé** | 11 lignes `tentative_refusee` avec `auteur_compte_id` **NULL** (plus d'`''` sur une colonne uuid, plus de 22P02). Les 4 refus hors banc sont tracés avec leur entrée. P-257. `03_D10_hors_banc.txt` |
| **V-062** | moyenne | **Fermé** | `REGISTRE_POLITIQUES_v1.md:329-332` : la répartition « 79+2+86 = 167 » est déclarée périmée, **seul le total 173 est mesuré**. Base : `count(*) politique = 173`, `permission = 55`. `MATRICE_DROITS_v1.md:172` : 55 commandes sur 48 lignes. ⚠️ un reste → N3-7. |
| **V-063** | moyenne | **Fermé (requalifié)** | La spec SQL se déclare « état du lot 1 » ; l'arbitrage a requalifié le constat. |
| **V-064** | moyenne | **Fermé** | `MACHINES_ETAT:23` porte `NeedStateChanged` comme événement d'effet ; `CancelPrestation` → « DP, Staffing » ; `sorti` → « code semé, **NON système** (`systeme = false`) ». |
| **V-065** | moyenne | **Fermé** | `GRILLE_AUDIT.md` : B5 avec le grep corrigé (`:49`), A4 marqué « clone de l'audit seulement » (`:33`), F9 (`:152`), F12 ajouté (`:153`), famille F présente (`:136`). ⚠️ deux restes → N3-7. |
| **V-066** | moyenne | **Fermé (sur pièce)** | `_ops/ETAT_PROJET.md:1-6` : « on le met à jour ici, après chaque rapport de session ». Discipline, non mesurable depuis un clone. |
| **V-067** | moyenne | **Fermé** | `ARBITRAGE_AUDIT_2026-09-21.md:83` : « **41 retenus · 6 requalifiés** *(corrigé le 22/09 — V-067)* », et le tableau marque bien 🔁 sur 003, 006, 016, 021, 022, 040. La condition de V-022 est écrite dans `DECISIONS_TECHNIQUES_v1.md:29` (T3) **et** vérifiée par K5 (`GRILLE_AUDIT.md:98`). |
| **V-068** | moyenne | **Fermé** | `admin.ts` `valeurDuType()` + `valeurs_possibles`. Sonde : `candidat.complete.champs_requis = "pas du json"` → `GARDE « valeur incompatible avec le type list »` ; `temps.plafond_jour = "pas un nombre"` → `GARDE « valeur hors valeurs_possibles »`. P-258. `20_sonde.txt` |
| **V-069** | moyenne | **Fermé** | `db/fixtures/banc.sql` crée la personne **et** le `profil_ressource`, et relie `res@ava.test`. Mesuré après deux passes : `profil_ressource` du compte RES = **1**. P-267. `04_fixture.txt` |
| **V-070** | moyenne | **Fermé** | Assertions M-12 sur `contact` (`:343`) et `projet` (`:351`). **Sabotage** `ALTER TABLE ava.contact DISABLE TRIGGER tg_m12` → `⛔ … LE GESTE EST PASSÉ`, **21 OK** au lieu de 31 ; idem `projet` → **22 OK**. `make.sh:204-207` compare au plancher (31) → KO. `31_…txt`, `32_…txt`. ⚠️ le `rc` de psql reste 0 → N3-6. |
| **V-071** | moyenne | **Fermé** | `SetOwnTheme {"<script>": "alert(1)", …}` → `GARDE « clé de thème inconnue »`, rien d'enregistré. P-259. `20_sonde.txt` |
| **V-072** | basse | **Fermé** | `test/contrat/db.ts:40-51` : `identifiant()` valide le nom de table par regex, `clause()` **lève** sur `'`, `"`, `;`, `--`, `/*`. P-268. |
| **V-073** | moyenne | **Fermé** | `POST /commandes/gardePourvu` → `INTROUVABLE « commande inconnue »` (plus routé) ; `UpdateNeed id:"pas-un-uuid"` → **HTTP 200 `GARDE « entrée mal typée »`**, +1 ligne `tentative_refusee` (plus de 500 non tracé) ; garde d'`ArchiveService` vivante (P-269). `21_sonde2.txt`, `20_sonde.txt` |
| **V-074** | bonne | **Tient** | Serveur en `postgres` → `exit=1`, « refuse de démarrer : current_user=postgres est superutilisateur », 0 écriture. `ava_app` : **INSERT 90 · SELECT 90 · UPDATE 86 · 0 DELETE · 0 TRUNCATE**. 31 assertions, `test/` = `_ops/` (`cmp` identiques). 262 portes vertes. `60_superuser.txt` |

---

## Les constats du 1er audit encore Partiels ou Ouverts

| Constat | Gravité | Verdict | Preuve |
|---|---|---|---|
| **V-003** | critique | **Fermé** | Fermé **par D-10**, pas par une serrure : hors banc, il n'y a plus de session du tout. Voir V-048. L'en-tête `x-ava-session` n'existe plus dans `server/src`. |
| **V-004** | critique | **Fermé** | Sonde indépendante (objets déplacés en agence CAS, comptes en PAR) : `WithdrawPositioning`, `RecordQualification`, `UploadDocument`, `CreateAction` → **4 × DROIT, 0 écriture**. `exigeObjet` appelé dans 28 chemins (`grep -rn exigeObjet server/src`). 40 portes P-157 → P-196 + P-193 → P-196. `20_sonde.txt` |
| **V-006** | critique | **Fermé** | `SetPolicy` rend désormais `{id, cle, valeur, ancienne, mur_touche, **commandes_affectees**:["CreateCompany"]}`. P-199. `20_sonde.txt` |
| **V-011** | critique | **Fermé** | Les **trois** cas nommés tombent maintenant, mutation par mutation (copie jetable, base neuve) : `temps.plafond_jour` en dur → **P-133** ; règle S de `RecordTimesheet` retirée → **P-208** ; `positionnement.unicite` en dur → **P-209**. `41_mut_*.txt` |
| **V-014** | elevee | **Partiel** | ✅ `doublon.personne.cles` : la branche `nom+prenom+naissance` existe (`identite.ts:51-74`), `CreatePerson` reçoit la date. ⛔ **Reste** : `doublon.contact.cles` n'a toujours que la branche `email` (`crm.ts:285-289`) — `nom+prenom+societe` n'est pas codé. ⛔ **Reste** : `societe.passage_client.propagation` (`projet.ts:203-231`) ne modifie **aucune** donnée de contact ; seules la liste et la clé partent dans l'événement, et `toute_la_societe` = `branche_contractante_…`. → N3-4, N3-5 |
| **V-015** | elevee | **Fermé** | `grep -rn "prospect\|ancien_client" server/src` → seulement des **noms de politique**, plus aucun code d'état. Statuts lus au référentiel (`codeStatutCommercial()`, P-265). **Mutation** : un `"a_pourvoir"` ajouté dans `commandes/besoin.ts` → **P-139 tombe**. `42_mut_litteral.txt` |
| **V-017** | elevee | **Fermé** | `ManageRefs categorie:"categorie_inventee"` sur un référentiel à `ck_cat` → `GARDE`, **plus de MUR** ; P-201 l'exige explicitement (`assert.notEqual(code,"MUR")`). |
| **V-018** | elevee | **Fermé** | `grep -rn bouchon web/src web/vite.config.ts` → **0** ; `web/public/bouchon` absent ; `server/src/index.ts:164` sert `/vues/besoins` et `:200` `/vues/besoins/:id` ; `web/src/contrat.ts:159` `chargerVue(chemin)` sur une route serveur. P-266. |
| **V-019** | elevee | **Partiel** | ✅ `test/ecran/tuyau.spec.ts:16-28` compare désormais la **couleur calculée du titre** au jeton `--structure` : le sabotage « titres en `#ff0000` dans le CSS » tombe. ⛔ **Reste** : le **fond de page** n'est lu que comme variable (`s.getPropertyValue("--fond")`), jamais comme couleur calculée du `body` ; seul le golden le verrait. → N3-8. ⛔ Portes écran **non exécutées** (Playwright hors périmètre). |
| **V-021** | elevee | **Tient (accepté D-9)** | `perimetre_type_code_check` toujours un CHECK, élargi à `'soi'` par 008 ; P-142 l'exige. FK `fk_contact_statut`, `fk_coordonnee_*` en base. |
| **V-022** | elevee | **Ouvert (accepté, poste de dev)** | `pg_hba_file_rules` : **6 lignes `trust`** (`local all`, `host 127.0.0.1`, `host ::1`, + réplication). Inchangé et assumé : `DECISIONS_TECHNIQUES_v1.md:29` (T3) impose `scram-sha-256` **hors poste de dev**, et K5 le vérifie. Rien à corriger ici ; tout à vérifier au déploiement. |
| **V-030** | moyenne | **Fermé** | `UpdateNeed id:"pas-un-uuid"` → **HTTP 200 `GARDE « entrée mal typée »`** + 1 ligne `tentative_refusee`. Le 500 non tracé a disparu. P-146. *(Le choix « tout refus en HTTP 200 » relève du contrat, pas du constat.)* |
| **V-032** | moyenne | **Partiel** | ✅ Le chemin générique d'`ArchiveObject` rend `{id, type}` (`ArchiveObject projet` → `sortie.id` présent). ⛔ **Reste** : les trois types délégués rendent `sortie = {}` sans id — `contact` mesuré (`ArchiveContact` ne retourne rien, `crm.ts:391-394`), idem `societe` et `unite/service`. → N3-9 |
| **V-036** | moyenne | **Fermé** | Sonde : `ZA` désactivé (`actif=false`), puis renommé **sans** `actif` → reste **`false`**. P-201 le couvre. `20_sonde.txt` |
| **V-037** | moyenne | **Fermé** | Périmètre : P-195 (`ArchiveObject` projet/ressource/besoin CAS → DROIT). Gardes : `besoin` non fermé → `GARDE « le besoin n'est pas fermé »` (mesuré) ; `projet` avec prestations non closes → `GARDE` ; `ressource` en mission → `GARDE` (`admin.ts:104-126`). `société` déléguée à `ArchiveCompany`. |
| **V-039** | moyenne | **Partiel** | `.github/workflows/ci.yml` porte maintenant un service `postgres:16`, `AVA_URL_MIGRATION`/`AVA_URL_SERVEUR`, un garde-fou « secrets présents », la création de `ava_serveur` **avec mot de passe hors dépôt**, `fetch-depth: 0` + `main` local, `bash outils/installer.sh`, puis le cliquet. ⛔ **La CI n'a pas été exécutée** (impossible depuis un clone) : verdict **sur pièce**. |
| **V-040** | moyenne | **Fermé** | Voir V-060 : `installer.sh` + case 12 du cliquet + crochet qui exige `Role: banc` dès que `test/` est touché. Les 5 commits `greffe` mêlant `server/src` et `test/contrat` ne peuvent plus se reproduire. |

---

## Les 7 constats « bonne » (V-041 → V-047)

| Constat | Verdict | Preuve |
|---|---|---|
| **V-041** transaction atomique | **Tient** | Les 46 portes `correctifs` vertes, dont P-149 (« la réponse porte l'id et les événements de la transaction »). ⚠️ le point faible nommé au 2e audit (S3b `ROLLBACK`→`COMMIT`) n'est toujours couvert par aucune porte exécutable — non rejoué ici. |
| **V-042** murs SQL | **Tient, et mieux** | 31 assertions (plancher 31). Les deux trous nommés sont bouchés : `tg_m12` désactivé sur `contact` → 21 OK, sur `projet` → 22 OK (voir V-070). |
| **V-043** matrice = base | **Tient** | `matrice.test.ts` 52/52, dont les lignes A·B dépliées et les 3 cases S passées au périmètre `soi` par 008 (la migration **refuse** si une case S garde une ligne agence — `DO $$ … RAISE EXCEPTION`). |
| **V-044** pas d'injection | **Tient, et mieux** | Les interpolations SQL restent tirées de constantes ; `ManageRefs` valide par regex + `pg_class` ; et les aides de test sont maintenant durcies (V-072, P-268). |
| **V-045** coût protégé | **Tient** | `commandes` 56/56 et `chemin` 56/56 ; `UpdateResourceCost` a sa porte de périmètre dédiée (P-189). |
| **V-046** O-2 et snapshot | **Tient** | P-126 dans `politiques` (50/50) ; `matrice` 52/52. |
| **V-047** canon gelé | **Tient** | `count(*) politique = **173**` en base ; `cmp _ops/SPEC_ASSERTIONS_L7.sql test/SPEC_ASSERTIONS_L7.sql` → **identiques** ; `git status` vide. |

---

## Compte

| Verdict | Nombre | Lesquels |
|---|---|---|
| **Fermé** | **37** | neufs : 048 049 051 052 053 054 055 056 057 058 059 060 061 062 063 064 065 066 067 068 069 070 071 072 073 · anciens : 003 004 006 011 015 017 018 030 036 037 040 |
| **Partiel** | **6** | 050 (lu, non exécuté) · 014 · 019 · 032 · 039 (lu, non exécuté) |
| **Ouvert** | **1** | **022** — assumé, poste de dev (T3 + K5) |
| **Bonne — tient** | **8** | 041 → 047 · 074 |
| Tient (accepté D-9) | 1 | 021 |

⭐ **Les quatre critiques du 2e audit et les quatre critiques restés ouverts ou partiels au 1er
(V-003, V-004, V-006, V-011) sont tous fermés, avec mutation ou sonde à l'appui.**

### Critiques encore ouverts ou partiels

| # | État | Pourquoi |
|---|---|---|
| **V-050** (critique) | **Partiel** | Le correctif est écrit et complet à la lecture, mais `outils/cliquet.sh` m'était **interdit d'exécution** : personne dans cet audit n'a vu la case 11 tomber. ⛔ Le point bloquant du projet reste le seul à n'avoir aucun témoin exécuté. |

Aucun autre critique n'est ouvert. V-022 (élevé) reste ouvert par décision.

---

## Constats neufs candidats

| # | Défaut · une phrase | Cible | Gravité | Preuve | Reproduire | Correction |
|---|---|---|---|---|---|---|
| **N3-1** | La case 11 (F12) ne protège les portes ✅ que sur une fenêtre d'**un** commit — effacées deux commits plus tôt, elles ne sont plus dans HEAD, ni HEAD~1, ni `main`, et plus personne ne les exige ; et « porte exécutée hors tableau » n'est qu'une ⚠️, jamais un KO | CODE (banc) | **elevee** | `outils/cliquet.sh:248` (`for ref in HEAD HEAD~1 "${base:-}"`), `:262-264` (`f12_note`, jamais compté en KO) | effacer des lignes ✅ de `PORTES.md`, commiter, commiter autre chose, relancer le cliquet | Comparer au `PORTES.md` du **commit de base de la branche** (`git merge-base main HEAD`), pas à HEAD~1 ; et faire de `f12_hors` un KO. |
| **N3-2** | La garde « catégorie inconnue » de `ManageRefs` n'existe que si la table porte une contrainte `ck_cat` : sur `ref_pays`, qui n'en a aucune, une catégorie inventée est **écrite sans garde** | CODE | **moyenne** | `admin.ts` ManageRefs (la garde est conditionnée par `WHERE … c.conname = 'ck_cat'`) ; sonde : `{referentiel:"ref_pays",code:"ZY",categorie:"categorie_inventee"}` → `ok:true`, `ref_pays.categorie = 'categorie_inventee'` ; `pg_constraint` sur `ava.ref_pays` = **PK seule**. P-201 ne teste que `ref_etat_besoin`, qui a la contrainte. `21_sonde2.txt` | la sonde ci-dessus | Tirer les catégories admises d'un référentiel de catégories (ou refuser toute catégorie sur une table sans `ck_cat`), et jouer la porte sur un référentiel **sans** contrainte. |
| **N3-3** | Le **libellé** d'une valeur système se change sans garde : `ManageRefs ref_pays FR libelle:"pirate"` → `ok:true`, `ref_pays.libelle = 'pirate'`, `systeme` toujours `true` | CODE | **moyenne** | sonde `21_sonde2.txt` ; `admin.ts` ne consulte `actuel.systeme` que pour la désactivation et le changement de catégorie | `curl … ManageRefs -d '{"referentiel":"ref_pays","code":"FR","libelle":"pirate"}'` | Soit assumer le renommage d'une valeur système et l'écrire au contrat, soit le garder comme les deux autres gestes. |
| **N3-4** | `doublon.contact.cles` déclare deux clés mais une seule est codée : `nom+prenom+societe` n'est jamais cherchée | CODE | **moyenne** | `server/src/commandes/crm.ts:285-289` (seul `cles.includes("email")`) ; base : `valeur = ["email","nom+prenom+societe"]` | régler la politique à `["nom+prenom+societe"]` et créer deux fois le même contact | Coder la branche, comme `identite.ts:62-74` le fait pour `nom+prenom+naissance`. |
| **N3-5** | `societe.passage_client.propagation` ne modifie **aucune** donnée : elle ne change que la liste écrite dans l'événement, et ses deux valeurs non triviales donnent le même résultat | CODE | **moyenne** | `projet.ts:203-231` : `prop === "societe_seule" ? [] : tous les contacts` — `toute_la_societe` et `branche_contractante_et_contacts_du_service` sont indistinguables ; aucune écriture sur `contact` | `SetPolicy … toute_la_societe`, signer une prestation, relire `contact` | Écrire l'effet sur les contacts, ou retirer les valeurs qui ne produisent rien. |
| **N3-6** | Les assertions L7 rendent **`rc = 0`** même quand une assertion tombe : seul le comptage des lignes « OK M- » les rattrape | BRAIN + CODE | **moyenne** | `psql -f test/SPEC_ASSERTIONS_L7.sql` avec `tg_m12` désactivé sur `contact` → **`rc=0`** alors que la sortie porte `⛔ … LE GESTE EST PASSÉ` et 21 OK sur 31. `31_assert_m12_contact.txt` | `ALTER TABLE ava.contact DISABLE TRIGGER tg_m12` puis lancer le fichier | Lancer avec `-v ON_ERROR_STOP=1`, et l'écrire dans la grille : un `rc` de psql sur ce fichier ne veut rien dire sans le compte. |
| **N3-7** | Deux restes dans la grille après V-062/V-065 : l'en-tête de la famille F dit « 11 contrôles (F1 → F11) » alors que **F12 existe**, et un paragraphe annonce encore que « le lot 2 (les **44** commandes) ajoutera une famille F » — déjà présente, et le compte est 55 depuis le 20/09 | BRAIN | **moyenne** | `_ops/GRILLE_AUDIT.md:136` et `:223` ; l'en-tête du fichier dit pourtant « 42 contrôles · 7 familles » (`:6`) | lire les trois lignes | Corriger « F1 → F12 » et supprimer le paragraphe ⏳ périmé. |
| **N3-8** | La porte du tuyau vérifie la couleur **calculée** du titre mais pas celle du fond de page : un fond écrit en dur dans le CSS ne fait tomber que le golden | CODE (banc) | **moyenne** | `test/ecran/tuyau.spec.ts:14-28` — `fond` est lu sur `getPropertyValue("--fond")`, jamais sur le `backgroundColor` calculé du `body` (le `titre`, lui, l'est) ; c'est le sabotage S9d resté vert aux deux audits précédents | écrire `body{background:#330000}` dans le CSS, relancer P-004 | Lire `getComputedStyle(document.body).backgroundColor` et le comparer à `rgb(--fond)`, comme c'est fait pour le titre. |
| **N3-9** | `ArchiveObject` rend `sortie = {}` sans id pour les trois types délégués (`contact`, `societe`, `unite`/`service`), alors que le chemin générique rend `{id, type}` | CODE | **basse** | sonde : `ArchiveObject type:"contact"` → `sortie: {}` mais `ArchiveObject type:"projet"` → `sortie: {id, type}` ; `admin.ts` `if (type === "contact") return ArchiveContact(ctx);`, et `crm.ts:391-394` ne retourne rien | les deux appels ci-dessus | Faire retourner `{id, type}` aux trois commandes déléguées. |
| **N3-10** | `assurerBancRes()` tourne encore au démarrage du serveur et **lève bruyamment** sur une base vide, alors que D-11 a déplacé ce travail dans `db/fixtures/banc.sql` | CODE | **basse** | `server/src/index.ts:74` et `:271` ; log au démarrage : `banc RES : error: la relation « compte » n'existe pas` (serveur démarre quand même). `srv_mut.log` | démarrer le serveur banc sur une base sans migrations | Retirer `assurerBancRes` : la fixture fait le travail, et P-267 la garde. |

---

## Angles morts

| Non vérifié | Pourquoi |
|---|---|
| **`outils/cliquet.sh` et `outils/make.sh`** | interdits par le poste de travail (l'auditeur principal s'en charge). **V-050 et V-060 reposent donc sur une lecture**, pas sur une exécution — c'est le trou le plus gênant de cet audit, puisque V-050 est un critique. |
| **CI GitHub** | non exécutable depuis un clone. V-039 est établi en lisant `ci.yml` et `make.sh:36-70` : sur un runner Linux, `pg_isready` existe et le moteur « local » est pris. Reste non prouvé : que le cliquet passe **réellement** en CI. |
| **Portes écran P-003 / P-004 / P-005** | Playwright non joué (build web + navigateur). V-019 est jugé en lisant `tuyau.spec.ts`. 260 des 264 portes ✅ ont tourné ; ces trois-là et P-001 (compté à part, joué en direct) sont les seules absentes. |
| **Mutations : 4 jouées, pas la série complète** | `temps.plafond_jour` en dur, règle S retirée, `positionnement.unicite` en dur, littéraux d'état et de groupe. Les sabotages SQL (13 du 2e audit) n'ont pas été rejoués un par un : seuls les deux trous M-12 nommés par V-070 l'ont été. |
| **S3b (`ROLLBACK` → `COMMIT` sur refus)** | non rejoué. Le 2e audit l'avait vu passer avec 120/120 portes vertes ; rien n'indique qu'une porte le verrait aujourd'hui. À reprendre. |
| **Les 40 portes « refuse INTROUVABLE » de `commandes.test.ts`** | toujours aveugles par construction (`cas.ts`) : une porte qui n'assure qu'un `INTROUVABLE` reste verte sous presque toute mutation. L'arbitrage n'a retenu de V-049 que les portes K1 → K4 ; ce reste n'est donc pas un constat ouvert, mais il pèse sur la valeur du chiffre « 264 portes ✅ ». |
| **Périmètre : 40 commandes sondées, pas 55** | les 40 portes K4 couvrent les commandes qui visent un objet ; les créations pures et les commandes d'administration ne sont jugées que sur le périmètre du compte. |
| **Artefact Git Bash** | `psql -f … >/dev/null` rend `rc=3` même quand tout passe — et m'a fait croire une fois que les 8 migrations avaient échoué. **Toutes les mesures de `rc` de ce rapport ont été prises avec une sortie vers un fichier.** |
| **Rôles globaux au cluster** | 007 fait `ALTER ROLE ava_serveur …` à chaque construction : mes deux reconstructions de base ont remis les attributs du rôle **pour tout le cluster**, donc pour les autres auditeurs. Aucun `CREATE/ALTER/DROP ROLE` à la main n'a été fait. |
| **V-022, V-066** | réglage de poste et discipline humaine : constat seulement, rien à mesurer depuis un clone. |
