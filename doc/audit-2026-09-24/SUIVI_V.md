# Cinquième audit — suivi des constats sur `b6ff087` (branche `lot-2`)

Auditeur indépendant. Code lu dans `ava-audit-5-lecture` sur `b6ff087` (`git status` **vide** au
début et à la fin). Base `ava_audit5_a` reconstruite **deux fois depuis rien**
(`db/migrations/001 → 009_unite_agence` + `db/fixtures/banc.sql`), serveur port **3501**.
Mutations jouées sur une **copie jetable** (scratchpad, `node_modules` en jonction, jonctions
retirées à la fin), jamais sur le clone. Sorties longues : `rapport/preuves/suivi5/`.

⛔ **Rien n'est « Fermé » sans une commande exécutée ou un `fichier:ligne` lu.** Les verdicts
posés sur pièce (cliquet, CI, Playwright — interdits ou hors périmètre) sont **Partiel**.

## Ce qui a tourné, sur base NEUVE

| Suite | Résultat |
|---|---|
| `contrat/sante` · `inventaire` | 1/1 · 1/1 |
| `contrat/commandes` · `chemin` | **56/56** · **56/56** |
| `contrat/politiques` | **50/50** |
| `contrat/matrice` | **52/52** — ⭐ **P-207 est VERTE** (elle était rouge au 4ᵉ tour) |
| `contrat/correctifs` | **46/46** (P-136 et P-148 passent dès qu'on pose `AVA_URL_MIGRATION` et `test/test-results/`) |
| `contrat/audit3` · `audit4` | **15/15** · **12/12** (P-287 → P-298) |
| `contrat/outils` | **2/2** (P-299, P-300 — psql doit être au `PATH`) |
| `contrat/comptes-avant-fixture` | **P-281 verte AVANT la fixture** ; rouge après, c'est son sens |
| Assertions L7 (`test/SPEC_ASSERTIONS_L7.sql`) | **32 OK**, plancher **32**, `cmp` avec `_ops/` : identiques |
| Les 10 migrations + fixture | `rc=0` × 11, et `rc=0` × 11 aussi dans l'**ordre inverse** des deux `009` |

⭐ **291 portes vertes, 0 rouge**, sur une base construite depuis rien. Le banc n'est plus rouge.
Les 3 portes ✅ que je n'ai pas exécutées sont **P-003, P-004, P-005** (Playwright).

---

## Les 11 constats du 4ᵉ audit (V-096 → V-106)

| Constat | Gravité | Verdict | Preuve |
|---|---|---|---|
| **V-096** P-207 rouge sur base neuve | critique | **Fermé** | Base neuve 001→009+fixture : `matrice` **52/52**, `✔ P-207 matrice admin` (`99_final_matrice.txt`). Cause traitée côté porte : `v011-lignes.ts:994` envoie désormais `categorie:"defaut"` (et non `"europe"`). ⚠️ Le second volet (**D-20**, « le cliquet refait la base ») est **lu non exécuté** : `cliquet.sh:58-73` fait bien `make.sh reset` puis `make.sh test`, avec une trappe `AVA_RAPIDE=1` qui saute le reset |
| **V-097** objet sans agence libre | critique | **Fermé** | `agence.ts:236-243` : plus de `return` muet — `agenceGouvernante()` puis, si elle rend `null`, `exigeGlobal()`. **Sonde en quatre temps** (`30_v097.txt`) : témoin positif agence PAR présente → `ok:true` ; agence mise à `NULL` puis `UpdateCandidate` par `rh@ava.test` (périmètre **agence PAR**, l'agence d'origine de l'objet) → **`DROIT`, événements 1227 → 1227, titre inchangé** ; le même objet avec un périmètre **global** → `ok:true` ; un compte **CAS** (périmètre CAS) → `DROIT`. **Mutation U5** (`exigeGlobal` rendu muet) → **P-288 tombe** |
| **V-098** `ConvertCandidateToResource` | elevee | **Fermé** | `identite.ts:196` : `const agenceId = ctx.compte.agence_id;` — l'entrée n'est plus lue. `✔ P-290`. **Mutation U8** (agence reprise de l'entrée) → **P-290 tombe** |
| **V-099** 7 portes testent le seed | elevee | ⛔ **Partiel — 5 sur 7** | Les 5 permissions absentes du seed posées sur le groupe IA, périmètre agence PAR : `commandes` **56/56** (P-009 P-012 P-016 P-027 P-056 tiennent), mais `matrice` **50/52** : **✖ P-203** (`ArchiveCompany hors périmètre : ok:true`) et **✖ P-207** (`ArchiveObject hors périmètre : ok:true`) (`40_v099_matrice.txt`). **Deux sens** : sans les droits → 52/52 (`42_…`), avec le seul `ArchiveCompany` sur PAR → **51/52** (`43_…`). Motif : la porte pose bien son droit (`delegation: true`, `accorder`/`retirer`), mais elle suppose que la permission n'existe **nulle part ailleurs** — une délégation légitime sur un second périmètre la fait rougir. Voir **N5-2** |
| **V-100** aucune porte sur « agence demandée ≠ agence lue » | elevee | **Fermé** | **Mutation U4** (`entreeAgence` neutralisé dans `agence.ts`) → **P-291 tombe** (`mut_U4_…`), là où le 4ᵉ tour voyait 0 porte sur 280 |
| **V-101** outils de garde non gardés | moyenne | **Fermé** | **U6** : `\set ON_ERROR_STOP on` retiré des **deux** copies (canon + banc), les deux fichiers restant identiques → **P-299 tombe** (« absent de `_ops/SPEC_ASSERTIONS_L7.sql` (V-087) »). **U7** : `verif_serveur.sh` réduit à `exit 0` → **P-300 tombe** (« attendu 1 sur une configuration ouverte, obtenu 0 »). Témoin de retour 2/2 (`mut_U6b_bis.txt`, `mut_U7_…`) |
| **V-102** `/sante` ouverte et interroge la base | moyenne | **Fermé** | `index.ts:137-139` : `app.get("/sante", async () => ({ ok: true }))` — plus de `SELECT 1`, plus de thème. Hors banc : `GET /sante` → **200 `{"ok":true}`**, **50 appels** → connexions sur `ava_audit5_a` **1 → 1** (`70_hors_banc.txt`). ⚠️ La route reste publique et **aucun contrat ne l'écrit** (`grep "route publique"` → 0) |
| **V-103** identité par défaut dans les vues | moyenne | **Fermé** | Banc : `GET /vues/besoins` **sans en-tête** → **403 `DROIT « compte inconnu ou inactif »`**, aucune clé `lignes` ; `x-ava-groupe: ADM` → 403 ; `inconnu@x.test` → 403 ; détail d'un besoin sans en-tête → 403. Témoins : `adm@ava.test` → `compte=200`, `ia@ava.test` → `compte=192` (le filtre d'agence est réel). `✔ P-292`. `60_v103_vues.txt` |
| **V-104** `agence_id` colonne morte + P-285 | moyenne | **Fermé** | `information_schema` : `unite_organisation.agence_id` **`is_nullable = NO`** ; **17 / 17** unités renseignées ; `INSERT` sans agence → **« Une unité appartient à une agence (D-22) : celle du compte qui la crée. »** (`009_unite_agence.sql` §0 remplace `unite_arbre()`, §3 pose le `NOT NULL`). `✔ P-293` (unité de société cliente ⇒ agence du compte). **P-285** : les 17 comptes résiduels (`p285-*`, `p287-*`, `p288-*`) sont tous `actif=f` et à **0 droit effectif** ; **0 compte actif** hors les 9 de banc (`81_bonnes.txt`) |
| **V-105** politiques non annoncées, C-10 | moyenne | **Fermé** (contrat) · C-10 = V-099 | `_ops/SPEC_COMMANDES_L4.md` : les clés sont dans la **colonne Politique** des lignes — `:102 UpdateCandidate → candidat.note.echelle` · `:146-147 PositionCandidate/PositionResource → positionnement.sur_besoin_inactif, besoin.staffing.declencheur` · `:149 RecordClientDecision → cv_partage_obligatoire, qualification_requise_avant_decision, projet.creation_depuis_besoin` · `:170 ClosePrestation → frais.mode, change.mode, marge.taux.si_ca_nul` · `:172 RecordTimesheet → temps.validation, capacite.jour_ouvre`. **C-10 reste ouvert par V-099** |
| **V-106** bien fait, à garder | bonne | **Tient — et le 8ᵉ point revient au vert** | voir la section « constats bonne » |

---

## Les restes des tours précédents

| Constat | Gravité | Verdict | Preuve |
|---|---|---|---|
| **V-019** portes écran | elevee | **Partiel** (inchangé, 5ᵉ tour) | `test/ecran/tuyau.spec.ts:16-17` lit `titre` **et** `fondPage` en couleur **calculée**. ⛔ Playwright hors périmètre : **P-003, P-004, P-005** sont les **3 seules portes ✅ du tableau que personne n'a exécutées ici** |
| **V-022** `pg_hba` en `trust` | elevee | **Ouvert (assumé, poste de dev) — et gardé** | `verif_serveur.sh` sans drapeau → **rc=1**, motifs nommés (`trust`, interfaces, mot de passe) ; `AVA_POSTE_DEV=1` → **rc=0**. Et depuis ce tour la mesure est **gardée par P-300** (V-101) |
| **V-077** le cliquet et la porte ✅ supprimée | elevee | **Partiel** (5ᵉ tour) | `cliquet.sh:277-308` lu : fenêtre `merge-base(main,HEAD) → HEAD` **plus** `main`, et `f12_hors` (porte exécutée hors tableau) en **KO**. ⛔ `outils/cliquet.sh` reste interdit d'exécution : **cinq audits, aucun témoin vu rouge par un indépendant** |
| **V-089** colonne Politique | moyenne | **Fermé** | voir V-105 |
| **N4-1** banc rouge sur base neuve | critique | **Fermé** | voir V-096 |
| **N4-2** garde de catégorie auto-référentielle | elevee | ⛔ **Ouvert** | `admin.ts:207-215` inchangé. Mesuré : `ManageRefs ref_pays categorie:"europe"` → `GARDE « catégorie inconnue »` ; `"afrique"` → idem ; `"defaut"` → `ok:true` (`92_n42_categorie.txt`). ⚠️ Le correctif de V-096 a **aligné la porte sur la limite** (elle envoie `defaut`) au lieu de lever la limite — et il n'existe plus aucune porte qui prouve qu'une catégorie neuve *peut* naître. Voir **N5-3** |
| **N4-3 / N4-4** vue sans en-tête, groupe inconnu | moyenne | **Fermé** | voir V-103 |
| **N4-5** fenêtre F12 repliée sur HEAD | moyenne | ⛔ **Ouvert** (lu) | `cliquet.sh:280-284` : `base=""` ⇒ `f12_liste="HEAD"` ; `:303` ne met KO que si `f12_n -eq 0` — or la boucle compte HEAD, donc `f12_n=1` et la case 11 reste **OK**. Inchangé depuis `cc3ff64`. Voir **N5-5** |
| **N4-6** `/sante` hors banc | moyenne | **Fermé** | voir V-102 |
| **N4-7** `unite_organisation.agence_id` jamais renseignée | basse | **Fermé** | voir V-104 |
| **N4-8** P-285 laisse un compte actif à 23 droits | basse | **Fermé** | voir V-104 |

---

## Les constats « bonne » — tiennent-ils ?

| Point | Verdict | Mesure de ce tour |
|---|---|---|
| Murs de rôles | **Tient** | `ava_app` : **INSERT 90 · SELECT 90 · UPDATE 86 · 0 DELETE · 0 TRUNCATE** ; `ava_lecture_agregats` : **7 relations** ; `ava_app`/`ava_lecture_agregats`/`ava_migration` **NOLOGIN**, `ava_serveur` login sans superutilisateur |
| Assertions, plancher compté | **Tient, et monte** | **32 OK** (31 au 4ᵉ tour), plancher 32, `cmp` canon/copie identiques. **Non aveugles** : `DISABLE TRIGGER tg_m12` sur `contact` → **rc=3** + « LE GESTE EST PASSÉ » ; `DISABLE TRIGGER tg_m6` sur `snapshot_marge` → **rc=3** ; triggers remis → rc=0 (`93_sabotages_sql.txt`) |
| 55 = 55 = 55 | **Tient** | 55 clés dans `CORRESPONDANCE` (`agence.ts`) = 55 permissions en base = `inventaire` 1/1 |
| Paramétrage | **Tient** | **173** politiques, **40** référentiels `ref_*`, **0** ligne `valeur <> valeur_defaut` |
| D-14 ferme tout hors banc | **Tient** | 11 routes mesurées : `/tuyau`, `/vues/besoins`, `/vues/besoins/<id>`, `/`, `/index.html`, `/contrat.js`, `/acquitter`, `/commandes/*` (avec **et** sans en-tête), `/vues/*` avec en-tête `adm` → **401**. Seule `/sante` → 200 |
| Pas d'écriture par un anonyme | **Tient** | **60 POST anonymes** hors banc : `tentative_refusee` **1000 → 1000**, `evenement_metier` **2885 → 2885** |
| Périmètre prouvé par un témoin positif | **Tient** | 52/52 en matrice, plus mes 4 sondes de V-097 dans les deux sens |
| Cliquet : 12 cases | **Non vérifié** | interdit d'exécution — angle mort, 5ᵉ tour |
| **« 0 porte aveugle », N portes vertes** | ⭐ **Revient au vert** | **291 vertes / 0 rouge** sur base neuve, et **4 mutations sur 4** font tomber exactement la porte visée (U4→P-291, U5→P-288, U6→P-299, U7→P-300, U8→P-290 — 5 sur 5) |

---

## Mutations et sabotages joués (copie jetable, portes relancées)

| # | Sabotage | Attendu | Mesuré |
|---|---|---|---|
| T0 | témoin, copie non mutée | vert | `audit4` **12/12**, `outils` **2/2** |
| U4 | `entreeAgence` neutralisé (`agence.ts`) | une porte tombe | **✖ P-291** (11/12) |
| U5 | `exigeGlobal` rendu muet (le repli de V-097 revient) | une porte tombe | **✖ P-288** (11/12) |
| U8 | `ConvertCandidateToResource` reprend l'agence de l'entrée | une porte tombe | **✖ P-290** (11/12) |
| U6a | `\set ON_ERROR_STOP` retiré de `test/` seulement | une porte tombe | **✖ P-299** (« diffère de `_ops/` ») |
| U6b | retiré des **deux** copies | une porte tombe | **✖ P-299** (« absent de `_ops/…` (V-087) ») |
| U7 | `verif_serveur.sh` → `exit 0` | une porte tombe | **✖ P-300** |
| S1 | `tg_m12` désactivé sur `contact` | assertions rouges | **rc=3**, motif nommé |
| S2 | `tg_m6` désactivé sur `snapshot_marge` | assertions rouges | **rc=3** |

---

## Compte

| Verdict | Nombre | Lesquels |
|---|---|---|
| **Fermé** | **10** | V-096 · V-097 · V-098 · V-100 · V-101 · V-102 · V-103 · V-104 · V-105 (contrat) · V-089 |
| **Partiel** | **3** | **V-099** (5 sur 7) · **V-077** (cliquet non exécuté) · **V-019** (Playwright non joué) |
| **Ouvert** | **3** | **N4-2** (garde auto-référentielle) · **N4-5** (fenêtre repliée sur HEAD) · **V-022** (assumé, poste de dev, mesuré et gardé) |
| **Bonne — tient** | 8 sur 8 | le 8ᵉ point (« portes vertes ») **revient au vert** |

⭐ **Les deux critiques du 4ᵉ audit sont fermés, mutation à l'appui.** V-097 est fermé par un
correctif **plus strict** que demandé : agence nulle ⇒ périmètre **global** exigé, pas seulement
celui du demandeur.

### Critiques encore ouverts

| # | État | Pourquoi |
|---|---|---|
| **N5-1** (neuf) | ⛔ **Ouvert, critique** | `societe` et `contact` n'ont **aucune colonne d'agence** : 7 commandes qui visent un objet **existant** sont en ligne `COMPTE` (`sinonCompte:true`, zéro lecteur), donc le périmètre est jugé sur l'agence **du demandeur** — la vérification est une tautologie. C'est V-097 déplacé d'un cran : `unite_organisation` a reçu sa colonne (D-22), `societe` et `contact` non |
| **V-077** | **Partiel, 5ᵉ tour** | `outils/cliquet.sh` reste interdit à l'auditeur indépendant. Le point bloquant du projet n'a **jamais** eu de témoin exécuté par un tiers |

---

## Constats neufs candidats

| # | Défaut · une phrase | Cible | Gravité | Preuve | Reproduire | Correction |
|---|---|---|---|---|---|---|
| **N5-1** | **Une société et un contact n'appartiennent à aucune agence** : les commandes qui les visent lisent le périmètre **du demandeur**, jamais celui de l'objet — un compte de PAR archive et renomme les sociétés et les contacts de CAS | CODE | **critique** | `information_schema` : **0 colonne `agence_id`** sur `ava.societe` et sur `ava.contact`. `agence.ts:52-68` : `UpdateCompany`, `RequalifyCompany`, `ArchiveCompany`, `UpdateContact`, `TransferContact`, `ArchiveContact` = ligne `COMPTE` (`{lecteurs: [], sinonCompte: true}`) ⇒ `agence.ts:244` `agenceId = ctx.compte.agence_id`, et `exigeDroit` compare le périmètre du compte **à sa propre agence**. `ArchiveObject {type:"societe"}` tombe dans le même cas (aucun de ses 5 lecteurs ne lit `societe`, `sinonCompte:true`). **Mesuré** (`50_societe_sans_agence.txt`) : une société créée par un compte **CAS** (manager = ce compte, agence CAS) est **archivée** par `ia@ava.test` (agence PAR, `ArchiveCompany` sur périmètre **agence PAR**) → `ok:true`, `archive_le` posé ; une seconde est **renommée** par `UpdateCompany` → `ok:true` ; un contact CAS est **renommé** par `UpdateContact` → `ok:true`. **Preuve croisée** : c'est exactement ce que dit `✖ P-203` quand on délègue `ArchiveCompany` (`43_matrice_archivecompany.txt`) — la porte voit le trou, mais seulement quand la permission est posée | poser `ArchiveCompany` sur le groupe IA au périmètre PAR, créer une société avec un compte CAS, l'archiver avec `ia@ava.test` | `societe.agence_id` (celle du compte qui crée, comme `009` l'a fait pour `unite_organisation`), un lecteur `col("societe", ["id"])` dans `CORRESPONDANCE`, et `contact` par sa société. **Et une porte par commande**, sinon le trou revient |
| **N5-2** | **D-23 n'est vrai que si la permission n'existe nulle part ailleurs** : P-203 et P-207 posent bien leur droit sur CAS, mais rougissent dès qu'une délégation légitime existe sur PAR — elles testent encore l'état du seed, pas la garde | CODE (banc) | **elevee** | `v011-lignes.ts:83-104` (`triptyque`) : le cas « hors périmètre » fait `accorder(groupe, commande, PERIMETRE_CAS)` **sans retirer** ce qui est déjà accordé, puis exige `DROIT`. Deux sens mesurés : seul → `matrice` **52/52** ; `ArchiveCompany` délégué sur PAR → **51/52, ✖ P-203** ; les 5 permissions posées → **50/52, ✖ P-203 ✖ P-207**. ⚠️ Et `retirer()` (`monde.ts:54-61`) **supprime toutes** les lignes de la permission pour ce groupe : la porte détruit au passage une délégation qu'elle n'a pas posée | `INSERT` une ligne `groupe_permission_perimetre (IA, ArchiveCompany, périmètre PAR)` puis `contrat/matrice.test.ts` | Le cas « hors périmètre » doit **mettre de côté** toutes les lignes existantes de la permission, jouer, puis les remettre — comme `retirerPuis` le fait déjà pour le cas « sans le groupe » ; et `retirer()` ne doit rendre que ce qu'`accorder()` a posé |
| **N5-3** | **La garde de catégorie de `ManageRefs` reste auto-référentielle, et le correctif de V-096 a supprimé le dernier témoin** : aucune catégorie neuve ne peut jamais naître sur un référentiel sans `ck_cat`, et plus aucune porte ne le montre | CODE + BRAIN | **elevee** | `admin.ts:207-215` inchangé (branche `else` : `SELECT DISTINCT categorie FROM <ref>` puis `GARDE` si absente). Mesuré : `europe` → `GARDE`, `afrique` → `GARDE`, `defaut` → `ok:true`. `v011-lignes.ts:994` envoie maintenant `categorie:"defaut"` : la porte a été **alignée sur la limite** au lieu que la limite soit levée. `92_n42_categorie.txt` | `ManageRefs {referentiel:"ref_pays", code:"ZZ", categorie:"afrique"}` avec `adm@ava.test` | Un référentiel des catégories (catégorie × référentiel) lu par la garde, **ou** l'écrire au contrat comme un invariant (« une catégorie neuve passe par une migration ») et poser une porte qui le dit |
| **N5-4** | **Deux migrations portent le numéro `009`** : le registre est clé sur le **nom de fichier**, rien ne contrôle l'unicité du numéro, et le numéro n'ordonne donc plus rien | BRAIN CODE | **basse** | `db/migrations/009_couverture_sans_archive.sql` **et** `009_unite_agence.sql`. `make.sh:151` : `for f in db/migrations/*.sql` — l'ordre est celui du glob ; `make.sh:153` interroge `schema_migrations` par `filename`, jamais par numéro ; aucun test ne lit `schema_migrations`. **Ordre réel mesuré** : `009_couverture_sans_archive.sql` puis `009_unite_agence.sql`, identique en `LC_ALL=C` et en `LC_ALL=fr_FR.UTF-8`. **Ordre inverse joué sur base neuve** : `rc=0` × 11, `pg_get_viewdef(v_besoin_couverture) LIKE '%archive_le%'` → **true**, `unite_organisation.agence_id NOT NULL` → **true** — les deux fichiers sont **indépendants**, l'ordre est aujourd'hui sans effet (`90_double_009.txt`). ⛔ Mais un `009_a….sql` ajouté demain passerait **avant les deux**, et rien ne le signalerait | `touch db/migrations/009_a_xxx.sql` puis `for f in db/migrations/009*.sql; do echo $f; done` | Renommer l'une des deux en `010`, et une porte qui refuse deux fichiers de migration au même numéro |
| **N5-5** | **La fenêtre F12 du cliquet retombe sur HEAD seul et la case 11 reste OK** — le défaut de V-077 revient tel quel sur un clone sans `main` ni `origin/main` (relevé au 4ᵉ tour comme N4-5, **inchangé**) | CODE (banc) | **moyenne** | `cliquet.sh:280-284` (`f12_liste="HEAD"` si `base` est vide) puis `:303` (`if [[ "$f12_n" -eq 0 ]]` → KO) — or la boucle `:286-292` compte HEAD, donc `f12_n=1`. Lu, non exécuté (cliquet interdit) | `git branch -D main; git remote remove origin` sur une copie, puis lancer le cliquet | « Point de départ de branche introuvable » doit être un **KO** de la case 11, non un repli silencieux sur HEAD |

---

## Angles morts

| Non vérifié | Pourquoi |
|---|---|
| **`outils/cliquet.sh` et `outils/make.sh`** | interdits par le poste de travail, **5ᵉ audit de suite**. V-077 et D-20 reposent donc sur une lecture. Le point bloquant du projet n'a toujours aucun témoin exécuté par un indépendant, et la règle qui l'interdit est plus vieille que le défaut |
| **CI GitHub** | non exécutable depuis un clone. `ci.yml` porte `fetch-depth: 0` et reconstruit `main` avant le cliquet — le repli de N5-5 n'y joue pas. Reste non prouvé : que le cliquet passe |
| **Portes écran et geste P-003 / P-004 / P-005** | Playwright non joué (build web + navigateur). V-019 jugé en lisant `tuyau.spec.ts:16-17`. **Ce sont les 3 seules portes ✅ du tableau non exécutées ici** |
| **Mutations : 5 jouées, 2 sabotages SQL** | `entreeAgence`, `exigeGlobal`, agence de conversion, `\set`, `verif_serveur.sh`, `tg_m12`, `tg_m6`. Les 50 sabotages du 3ᵉ audit et les 15 sabotages SQL n'ont **pas** été rejoués un par un : le « 0 porte aveugle » n'est pas revérifié en bloc |
| **S3b (`ROLLBACK` → `COMMIT` sur refus)** | non rejoué, **quatrième** audit de suite |
| **Multi-agences** | mes sondes opposent PAR et CAS. Un compte couvrant **deux** agences sur une même permission n'a pas été construit — et c'est exactement le cas que N5-2 fait rougir |
| **`web/`** | non audité. Les vues serveur sont mesurées, leur consommation non. ⚠️ `/sante` ne rend plus le thème : si un écran le lisait là, il est cassé, et rien ici ne le dit |
| **`societe.manager_compte_id` comme agence** | `009_unite_agence.sql` §2 s'en sert pour déduire l'agence d'une unité, mais personne ne garde ce champ : si le manager change d'agence, l'agence des unités déjà écrites ne suit pas. Non mesuré |
| **Rôles globaux au cluster** | `007` fait `ALTER ROLE ava_serveur …` à chaque construction : mes **trois** reconstructions ont remis les attributs du rôle pour **tout le cluster**, donc pour les autres auditeurs. Aucun `CREATE/ALTER/DROP ROLE` à la main |
| **Artefacts de poste (pas des constats)** | ① `psql` n'accepte pas d'option **après** l'URL de connexion : toutes mes mesures mettent les options avant. ② Au **premier** appel de la session, `psql -f db/migrations/001_schema.sql` a levé « octet `0x90` … WIN1252 sans équivalent UTF8 » ; **non reproductible** ensuite (`SHOW client_encoding` → `UTF8`, `chcp` → 850). Contourné par `PGCLIENTENCODING=UTF8`. ⚠️ `make.sh` en moteur **local** n'impose aucun encodage client : à surveiller, pas un constat |
| **P-299 / P-300 dépendent du `PATH`** | `contrat/outils.test.ts` rend `status=2` (« psql introuvable ») si `psql` n'est pas au `PATH` du processus de test, et l'assertion `notEqual(status, 2)` échoue alors — la porte **dit** qu'elle n'a pas pu mesurer, ce qui est bien, mais elle est rouge pour une raison d'environnement |
