# Quatrième audit — suivi des constats sur `cc3ff64` (branche `lot-2`)

Auditeur indépendant. Code lu dans `ava-audit-4-lecture` sur `cc3ff64` (`git status` **vide** au
début et à la fin). Base `ava_audit4_a` (db/migrations 001 → **009** + `db/fixtures/banc.sql`),
serveur port **3401**. Mutations jouées sur une **copie jetable** (scratchpad, `node_modules` en
jonction), jamais sur le clone. Sorties longues : `rapport/preuves/suivi4/`.

⛔ **Rien n'est « Fermé » sans une commande exécutée ou un `fichier:ligne` lu.** Les verdicts posés
sur pièce (cliquet, CI, Playwright — tous interdits ou hors périmètre) sont marqués **Partiel** et
repris dans les angles morts.

## Ce qui a tourné, sur base NEUVE

| Suite | Résultat |
|---|---|
| `contrat/sante` · `inventaire` | 1/1 · 1/1 |
| `contrat/commandes` · `chemin` | 56/56 · 56/56 |
| `contrat/audit3` (P-271 → P-286) | **15/15** |
| `contrat/politiques` | **50/50** |
| `contrat/correctifs` | **45/46** — P-148 tombe hors `make.sh` (artefact, voir ci-dessous) |
| `contrat/matrice` | **51/52** — ⛔ **P-207 ROUGE** |
| Assertions L7 (`test/SPEC_ASSERTIONS_L7.sql`) | **31 OK**, plancher 31, `cmp` avec `_ops/` : identiques |
| Les 9 migrations + fixture | `rc=0` × 10 (`preuves/suivi4/00_base.txt`) |

⚠️ **P-136 et P-148** tombent chez moi pour cause d'environnement, non de produit : P-136 exige
`AVA_URL_MIGRATION` (elle passe dès qu'il est exporté — `31_correctifs_env.txt`), P-148 lit
`test/test-results/commit-msg.txt` que seul `make.sh` écrit. **Ce ne sont pas des constats.**

---

## Les 21 constats du 3ᵉ audit (V-075 → V-095)

| Constat | Gravité | Verdict | Preuve |
|---|---|---|---|
| **V-075** les vues servent la base à un anonyme, hors banc | critique | **Fermé** | Serveur **sans** `AVA_MODE`, port 3401 : `GET /vues/besoins` → **401**, `GET /vues/besoins/<uuid>` → **401**, `/acquitter` → **401**, `/` (statique) → **401** ; seul `/sante` → 200. Avec `x-ava-groupe: adm@ava.test` → **401** aussi. Filtre d'agence **réel**, mesuré en comparant deux groupes : ADM (périmètre `global`) → `compte=2` (`BESOIN-CAS`, `BESOIN-PAR`) · IA (périmètre `agence PAR`) → `compte=1` (`BESOIN-PAR` seul). `index.ts:117-125` (hook `preHandler`, D-14) sort avant tout routage. `70_hors_banc.txt`, `11_vues_filtre_agence.txt`. **Porte P-271 non aveugle** : deux mutations la font tomber (voir Mutations) |
| **V-076** `crm.ts` sans garde de périmètre | critique | **Fermé** | Correctif **structurel** : `grep -rn exigeObjet server/src` → **0** ; `exigeAgence(ctx)` est appelé une fois pour toutes dans `executer.ts:173`, avant le handler. `server/src/agence.ts` porte **55 lignes = 55 handlers = 55 permissions en base**. Commande absente de la table → `GARDE « commande sans correspondance d'agence »` (`executer.ts:150` **et** `agence.ts:186`), **fail-closed**, gardé par P-273. Sondes : `UpdateUnit`/`ArchiveService`/`CreateUnit` hors agence → **DROIT, rien écrit** ; contrôle positif : `CreateNeed agence_id=PAR` → `ok:true`, le même avec `agence_id=CAS` → **DROIT**. `40_perimetre_unite.txt`, `42_unite_hors_perimetre.txt`, `10_perimetre_creation.txt` |
| **V-077** le cliquet ne voit pas une porte ✅ supprimée | elevee | **Partiel** (lu, non exécuté) | `cliquet.sh:239-281` : la fenêtre va de `git merge-base main HEAD` à HEAD **plus** `main` (`:253-256`) et `f12_hors` est désormais compté en **KO** (`:274-281`). Fenêtre **simulée** sur ce clone : `merge-base origin/main HEAD = afc1683`, **141 commits couverts**. ⛔ `outils/cliquet.sh` m'est interdit d'exécution. ⚠️ Reste mesuré par lecture → **N4-6** |
| **V-078** un POST anonyme écrit dans `tentative_refusee`, sans plafond | elevee | **Fermé** | Hors banc, **60 POST anonymes** sur `/commandes/CreateCompany` → `tentative_refusee` **972 → 972, delta = 0** ; `evenement_metier` 2056 → 2056. `70_hors_banc.txt` |
| **V-079** `CreatePrestation` réussit sur un projet clos | elevee | **Fermé** | `CloseProject` → `etat_code=clos`, `etat_categorie=clos` ; puis `CreatePrestation` sur ce projet → **`ETAT « CreatePrestation hors cycle »`**, `count(prestation)=0`. `53_v079_prestation_projet_clos.txt` |
| **V-080** `SetPolicy` rend une liste vide sur deux clés | elevee | **Fermé** | `droits.surcharge_restrictive` → `commandes_affectees` = **55 commandes** ; `historique.tentatives_refusees` → **55** ; contrôle positif `projet.cloture.garde` → **`["CloseProject"]`** seule. `50_sondes_H.txt` |
| **V-081** `ArchiveObject` n'émet pas son événement, perd le motif | elevee | **Fermé** | `ArchiveObject {type:"contact"}` → **2 événements** : `ContactArchived` **+** `ObjectArchived` `motif:"sonde4"` ; `{type:"unite"}` → `UnitArchived` + `ObjectArchived` `motif` présent, `liens.politiques` portant `service.archivage.garde`. `50_sondes_H.txt` |
| **V-082** `v_besoin_couverture` compte les prestations archivées | elevee | **Fermé** | Migration **009** présente. `pg_get_viewdef('ava.v_besoin_couverture') LIKE '%archive_le%'` → **t**. En transaction : besoins avec `postes_engages>0` **16 avant** → **0 après** `UPDATE prestation SET archive_le=now()` (`ROLLBACK`). `52_sondes_H3.txt` |
| **V-083** `TakeNeedInCharge` refuse toujours sous le seed | elevee | **Fermé** | Sous le seed livré : `TakeNeedInCharge` → **`ok:true`**, besoin `ouvert` → `staffing`. La garde de politique a été retirée (`besoin.ts:133-141` ne lit plus `besoin.staffing.declencheur`), donc la ligne L4:129 (« `ETAT` hors cycle », Politique « — ») est désormais **exacte**. `51_sondes_H2.txt` |
| **V-084** la garde « catégorie inconnue » n'existe que si `ck_cat` | elevee | **Fermé — mais casse P-207** | `admin.ts:207-213` : sans `ck_cat`, les catégories admises sont tirées des valeurs **déjà présentes** dans la table. Sur `ref_pays` (aucune contrainte, une seule catégorie `defaut` au seed), une catégorie inventée est bien refusée. ⛔ **Effet de bord** : P-207 joue `ManageRefs ref_pays categorie:"europe"` → `GARDE « catégorie inconnue »` → **porte ROUGE**. Voir **N4-1** et **N4-2** |
| **V-085** le contrat dit `MUR` là où le code dit `GARDE` | elevee | **Fermé** | `_ops/SPEC_COMMANDES_L4.md:101` `CreateCandidate` → « `GARDE` si un profil candidat existe déjà *(V-085, 23/09…)* », colonne Mur = **M-3** ; `:107` idem `CreateResource`. `60_brain.txt` |
| **V-086** les comptes de banc réactivés ne font tomber aucune porte | moyenne | **Fermé** | `test/contrat/comptes-avant-fixture.test.ts` porte **P-281** (les 9 comptes `@ava.test` inactifs après migration), listée `journal/PORTES.md:291`. **Témoin vu ROUGE** : jouée sur ma base où la fixture a tourné → `✖ … réactivés avant la fixture : adm@…, dp@…, …` (les 9). `64_v086_temoin.txt` |
| **V-087** sans `ON_ERROR_STOP`, le fichier rend `rc=0` | moyenne | **Fermé** | `test/SPEC_ASSERTIONS_L7.sql:37` → `\set ON_ERROR_STOP on`. **Testé sans le drapeau en ligne de commande** : base saine → `rc=0`, 31 OK ; `ALTER TABLE ava.contact DISABLE TRIGGER tg_m12` → **`rc=3`** + `⛔ … LE GESTE EST PASSÉ` ; trigger remis → `rc=0`. `20_assertions_L7.txt` |
| **V-088** `NeedStateChanged` porte un code en dur | moyenne | **Fermé** | `evenement_metier.apres` → **`{"de": "a_pourvoir", "vers": "en_recherche"}`** — deux catégories, plus un code. `52_sondes_H3.txt` ; porte P-282 |
| **V-089** onze commandes lisent des politiques non annoncées | moyenne | **Partiel** | Les 11 clés sont **écrites** au contrat, mais dans un **paragraphe** sous le tableau (`L4:131-137`), pas dans la colonne Politique des lignes : `L4:102 UpdateCandidate … | — | — |` alors que l'événement `CandidateUpdated` porte `candidat.note.echelle` ; `L4:170 ClosePrestation … | — |` alors que `PrestationClosed` porte `change.mode, frais.mode, marge.taux.si_ca_nul`. La correction demandée était « compléter la **colonne** ». `61_v089_politiques.txt`, `62_v089_L4.txt` |
| **V-090** quatre commandes jouées seulement par leur absence de droit | moyenne | **Fermé** | `audit3.test.ts:515-554` : **P-283** appelle `accorderSql("IA","ArchiveCompany"/"ArchiveContact"/"ArchiveService")`, joue les gardes réelles, puis **`retirerSql`** les trois. `journal/PORTES.md:293`. Suite `audit3` **15/15**. `63_v090_v086.txt` |
| **V-091** `ManageGroups` déguise une erreur de type en garde | moyenne | **Fermé** | Reproduction **exacte** du constat : `{"groupe":"RR","permission":"CreateNeed","perimetre":"agence"}` → **`INTROUVABLE « périmètre introuvable »`** (plus « entrée mal typée »). `admin.ts:252-255` valide la forme UUID avant la requête. Idem pour un nombre et pour un uuid absent. Porte P-284. `51_sondes_H2.txt`, `52_sondes_H3.txt` |
| **V-092** la « session » reste un nom de groupe, l'auteur est faux | moyenne | **Fermé** | `x-ava-groupe` porte **l'e-mail du compte** : `compteDuGroupe` (`executer.ts:62-72`) et `compteEntete` (`index.ts:180-192`) font tous deux `lower(c.email) = lower($1) AND c.actif`. Auteur enregistré = ce compte : `NeedTakenInCharge → staf@ava.test`, `PolicyChanged → adm@ava.test`, `ProjectClosed → dp@ava.test` ; **2056 / 2056** événements ont un `auteur_compte_id`. Porte P-285. `65_v092_auteur.txt`. *(L'absence d'authentification reste assumée jusqu'au lot 2c.)* |
| **V-093** rien ne mesure le `pg_hba` d'un serveur | moyenne | **Fermé** | `outils/verif_serveur.sh` **exécuté sur ce poste** : sans drapeau → **`rc=1`**, « ⛔ 6 règle(s) trust/password », « ⛔ la base écoute toutes les interfaces », « ⛔ ava_serveur n'a pas de mot de passe » ; avec `AVA_POSTE_DEV=1` → **`rc=0`**, les trois passent en ⚠️ « poste de dev déclaré ». Il mesure aussi `ava_serveur : login=oui superutilisateur=non` et les 3 rôles `NOLOGIN`. `21_verif_serveur.txt` |
| **V-094** trois constats anciens restent partiels | moyenne | **Fermé 2 / Partiel 1** | voir le tableau suivant (V-014 **Fermé**, V-032 **Fermé**, V-019 **Partiel**) |
| **V-095** bien fait, à garder | bonne | **Tient, sauf un point** | voir « Les 8 constats bonne » |

---

## Les restes des tours précédents

| Constat | Gravité | Verdict | Preuve |
|---|---|---|---|
| **V-014** | elevee | **Fermé** | ✅ `crm.ts:292-302` code enfin la seconde branche : `cles.includes("nom+prenom+societe")` → `GARDE « contact déjà connu (doublon.contact.cles = nom+prenom+societe) »`. ✅ `projet.ts:210-245` **écrit** désormais sur les contacts (`UPDATE contact SET statut_commercial_code = …`) et **distingue** les deux valeurs non triviales : `branche_contractante_et_contacts_du_service` restreint par `c.id = contact du projet OR c.unite_organisation_id = unité du besoin`, l'autre prend tous les contacts de la société. Porte P-286. `60_brain.txt` |
| **V-019** | elevee | **Partiel** | ✅ `test/ecran/tuyau.spec.ts:17` → `const fondPage = getComputedStyle(document.body).backgroundColor` — le fond est enfin lu en **couleur calculée**, comme le titre (`:16`). ⛔ **Portes écran non exécutées** (Playwright hors périmètre) : verdict **sur pièce** |
| **V-022** | elevee | **Ouvert (assumé, poste de dev) — et désormais mesuré** | `verif_serveur.sh` rend **6 règles `trust`** (lignes 113, 115, 117, 120, 121, 122 du `pg_hba`) et, fait **neuf**, `listen_addresses = *`. Rien à corriger sur ce poste (T3 + K5) ; tout à vérifier au déploiement — et l'outil existe maintenant pour le faire |
| **V-032** | moyenne | **Fermé** | `ArchiveObject {type:"contact"}` → `sortie: {"id":"0336c21f-…","type":"contact"}` ; `{type:"unite"}` → `sortie: {"id":"7e9a8e54-…","type":"unite"}`. Les types délégués rendent l'id, comme le chemin générique. `50_sondes_H.txt` |

---

## Les 8 constats « bonne » — tiennent-ils ?

| Point | Verdict | Mesure de ce tour |
|---|---|---|
| Murs de rôles | **Tient** | `ava_app` : **INSERT 90 · SELECT 90 · UPDATE 86 · 0 DELETE · 0 TRUNCATE** ; `ava_lecture_agregats` : **7 relations**, SELECT seul ; `ava_app`/`ava_lecture_agregats`/`ava_migration` **NOLOGIN**. `80_bonnes.txt` |
| 31 assertions, plancher compté | **Tient** | 31 OK ; `plancher_assertions.sh` = 31 ; `cmp _ops/… test/…` **identiques** |
| Serveur refuse un superutilisateur | **Tient** | `DATABASE_URL=…postgres@…` → **`exit=1`**, « refuse de démarrer : current_user=postgres est superutilisateur (V-002) » |
| 55 = 55, aucun fantôme | **Tient** | 55 clés dans `agence.ts` = 55 permissions en base = `inventaire` 1/1 |
| D-10 tenu sur les commandes | **Tient, et élargi** | D-14 ferme **toutes** les routes hors banc, pas seulement `/commandes/:nom` (V-075) |
| Périmètre prouvé fermé par un contrôle positif | **Tient** | `CreateNeed` PAR `ok:true` / CAS `DROIT` ; `UpdateUnit` dans le périmètre réussit, hors périmètre `DROIT` |
| Cliquet : 12 cases | **Non vérifié** | interdit d'exécution — angle mort |
| **« 0 porte aveugle », 264 portes ✅ vertes** | ⛔ **Ne tient plus** | **280 portes ✅** au tableau aujourd'hui, et **P-207 est ROUGE** sur toute base construite depuis `cc3ff64` → voir **N4-1** |

---

## Mutations jouées (copie jetable, portes relancées)

| Mutation | Effet attendu | Mesuré |
|---|---|---|
| Témoin — copie non mutée | `audit3` vert | **15/15** |
| 1 · le garde D-14 laisse passer `/vues` hors banc | une porte tombe | **P-271 ✖** (14/15) |
| 2 · `filtreAgence` neutralisé (`global:true`) | une porte tombe | **P-271 ✖** (14/15) |
| 3 · `UpdateUnit`/`ArchiveService` retirés de la table **+** fail-closed ouvert | deux portes tombent | **P-272 ✖ et P-273 ✖** |

⭐ Les trois corrections critiques de ce tour (garde unique d'entrée, filtre d'agence, table de
correspondance) sont **protégées par des portes non aveugles**. `90_mutations.txt`

---

## Compte

| Verdict | Nombre | Lesquels |
|---|---|---|
| **Fermé** | **20** | 075 076 078 079 080 081 082 083 084 085 086 087 088 090 091 092 093 · anciens : 014 032 · (094 fermé pour 2 de ses 3 points) |
| **Partiel** | **4** | **077** (lu, non exécuté) · **089** (la colonne n'est pas remplie) · **019** (Playwright non joué) · **094** (par V-019) |
| **Ouvert** | **1** | **022** — assumé, poste de dev, désormais **mesurable** (V-093) |
| **Bonne — tient** | 7 sur 8 | le 8ᵉ (« portes vertes ») tombe avec P-207 |

⭐ **Les deux critiques du 3ᵉ audit (V-075, V-076) sont fermés, avec sonde ET mutation à l'appui.**
Le correctif de V-076 est structurel — une table, un appel dans le noyau — et non 55 rappels.

### Critiques encore ouverts

| # | État | Pourquoi |
|---|---|---|
| **N4-1** (neuf) | **Ouvert** | Le banc est **rouge** sur `cc3ff64` : P-207 tombe sur toute base issue des migrations, donc la case 1 du cliquet (`make_rc=0` **et** aucune porte ✅ en échec) est **KO**, en local comme en CI. Le point bloquant du projet bloque. |
| **V-077** | **Partiel** | Le correctif est complet à la lecture, mais personne, en quatre audits, n'a **vu** la case 11 tomber : `cliquet.sh` reste interdit d'exécution à l'auditeur indépendant. |

---

## Constats neufs candidats

| # | Défaut · une phrase | Cible | Gravité | Preuve | Reproduire | Correction |
|---|---|---|---|---|---|---|
| **N4-1** | **P-207 est ROUGE sur toute base construite depuis `cc3ff64`** : la porte joue `ManageRefs ref_pays categorie:"europe"`, mais le correctif de V-084 n'admet que les catégories **déjà présentes** en table, et le seed de `ref_pays` n'a que `defaut` — le banc est donc rouge, et avec lui la case 1 du cliquet | CODE (banc) | **critique** | `matrice` **51/52** sur base neuve : `AssertionError: ManageRefs ADM: {"code":"GARDE","message":"catégorie inconnue"}` (`30_portes_matrice.txt:65`) ; `select categorie, count(*) from ava.ref_pays` → **`defaut | 6`** ; `pg_constraint` sur `ava.ref_pays` = **PK seule**. **Preuve croisée** : `INSERT INTO ava.ref_pays … categorie='europe'` puis relance → **52/52** (`33_matrice_avec_europe.txt`) ; la ligne retirée → **51/52** de nouveau, y compris au 2ᵉ passage (`32_matrice_2e.txt`). Le 3ᵉ audit voyait 52/52 parce que sa base **héritait** d'une ligne `europe` écrite par l'ancien code sans garde. `cliquet.sh:96-99` exige `make_rc=0` et `servies_ko` vide, et `journal/PORTES.md:218` classe P-207 **✅** | reconstruire une base neuve (001→009 + fixture), lancer `contrat/matrice.test.ts` | Semer une catégorie non-`defaut` dans `ref_pays` par migration, **ou** faire jouer P-207 sur un référentiel qui porte `ck_cat`, **ou** tirer les catégories d'un référentiel de catégories (voir N4-2) |
| **N4-2** | La garde de catégorie de `ManageRefs` est **auto-référentielle** sur un référentiel sans `ck_cat` : les seules catégories admises étant celles déjà en table, **aucune catégorie neuve ne peut jamais être créée par la commande** — le référentiel des catégories est gelé pour toujours | CODE | **elevee** | `server/src/commandes/admin.ts:207-213` : branche `else` du test `ck_cat` → `SELECT DISTINCT categorie FROM <ref>` puis `if (!deja.some(...)) throw GARDE`. Mesuré : `ref_pays` n'accepte que `defaut`, et rien dans les 55 commandes ne permet d'en ajouter une | `ManageRefs {referentiel:"ref_pays",code:"ZY",categorie:"quoi_que_ce_soit"}` | Un référentiel `ref_categorie_referentiel` (catégorie × référentiel), lu par la garde ; **ou** assumer qu'une catégorie neuve passe par une migration, et l'écrire au contrat |
| **N4-3** | En banc, une vue appelée **sans en-tête** prend le périmètre de `ia@ava.test` par défaut, alors qu'une **commande** sans en-tête est refusée — deux règles pour la même absence de session | CODE | **moyenne** | `index.ts:182` → `const cle = nom && nom.length > 0 ? nom : "ia@ava.test"` ; mesuré : `GET /vues/besoins` **sans en-tête** → `compte=1`, `['BESOIN-PAR']` (le périmètre d'IA), là où `POST /commandes/*` sans en-tête lève `Refus("DROIT","session absente")` (`executer.ts:171`). `11_vues_filtre_agence.txt` | `curl -s http://127.0.0.1:3401/vues/besoins` (serveur en banc, sans en-tête) | Refuser les vues sans en-tête comme les commandes, ou faire du compte de banc un **paramètre déclaré** (`AVA_COMPTE_BANC`) et non un défaut caché dans le code |
| **N4-4** | Un en-tête `x-ava-groupe` qui porte un **nom de groupe** (« ADM », l'ancienne convention, encore citée dans les rapports et les `curl` du contrat) rend une liste **vide** au lieu d'un refus : l'appelant mal configuré lit « aucun besoin » et croit la base vide | CODE | **moyenne** | `x-ava-groupe: ADM` → `compte=0`, `lignes=[]`, **HTTP 200** ; `x-ava-groupe: inconnu@x.test` → idem. `compteEntete` (`index.ts:180-192`) rend `undefined`, `filtreAgence` rend `{global:false, ids:[]}`, et la requête ne filtre rien de plus. `11_vues_filtre_agence.txt` | `curl -s -H 'x-ava-groupe: ADM' http://127.0.0.1:3401/vues/besoins` | Rendre un refus (`DROIT « compte inconnu ou inactif »`) quand `compteEntete` ne résout pas, exactement comme `compteDuGroupe` le fait déjà pour les commandes |
| **N4-5** | La fenêtre F12 du cliquet retombe à **HEAD seul** si ni `main` ni `origin/main` n'existe, et la case 11 reste **OK** : le défaut de V-077 revient tel quel sur un clone sans historique | CODE (banc) | **moyenne** | `cliquet.sh:124-128` (`base=""` si aucune des deux réfs) puis `:251-257` → `f12_liste="HEAD"`, et `:275` ne met KO que si `f12_n -eq 0` — or `f12_n` vaut **1**. Sur ce clone, `main` est **absent** (seul `origin/main` existe) : la protection ne tient qu'à la seconde réf | `git branch -D main; git remote remove origin` sur une copie, puis lancer le cliquet | Faire de « point de départ de branche introuvable » un **KO** de la case 11, et non un repli silencieux sur HEAD |
| **N4-6** | Hors banc, `/sante` reste ouvert à tout appelant et **ouvre une connexion à la base** à chaque appel, sans plafond | CODE | **moyenne** | `index.ts:118` (`if (chemin === "/sante") return;` avant le 401) et `:138-143` (`await pool.query("SELECT 1 AS ok")`). Mesuré hors banc : `GET /sante` → **200** avec `db:true` et le thème complet, tandis que toutes les autres routes rendent 401. `70_hors_banc.txt` | `curl -s http://127.0.0.1:3401/sante` (serveur sans `AVA_MODE`) | Répondre à `/sante` **sans toucher la base** hors banc, ou plafonner ; et écrire au contrat que `/sante` est la seule route publique |
| **N4-7** | `unite_organisation.agence_id` est **toujours NULL** (27 / 27) — un mur DB l'interdit pour une unité cliente — donc la ligne `UNITE` de la table de correspondance lit une **colonne morte**, et le périmètre des unités retombe sur l'agence du compte : le résultat est correct, mais par accident | CODE | **basse** | `select count(*) total, count(agence_id) avec_agence from ava.unite_organisation` → **27 / 0** ; un `INSERT` avec agence lève `unite_arbre() : « Une unité cliente n'a pas d'agence : une agence est un site d'Avaliance »` ; `agence.ts:39` `UNITE = col("unite_organisation", ["id"])` sur `agence_id` ; le rattrapage vient de `agence.ts:203` + `droits.ts:32` (sans agence d'objet, le périmètre doit couvrir l'agence **du compte**). `41_unite_agence_nulle.txt`, `40_perimetre_unite.txt` | `curl … CreateUnit …` puis lire `agence_id` | Lire l'agence d'une unité **par sa société** (ou par le compte, explicitement), et retirer un lecteur qui ne rend jamais rien — sinon le prochain qui change `sinonCompte` ouvrira un trou invisible |
| **N4-8** | La suite de contrat laisse en base, à **chaque exécution**, un compte de test porteur de **23 droits réels** ; le premier reste **actif** | CODE (banc) | **basse** | Après mes passages : **6** comptes `p285-…@ava.test`, chacun avec `count(*)=23` dans `v_droits_effectifs`, dont `p285-1790148574177-eppf65@ava.test` **`actif=t`** — il apparaît dans la liste des détenteurs de `CreateUnit`, `UpdateUnit`, `CloseNeed`, `SuspendNeed`, `TransferContact`… `91_residus.txt` | lancer `contrat/audit3.test.ts` deux fois, puis `select email, actif from ava.compte where email ~ '^p[0-9]'` | Faire nettoyer P-285 derrière elle (comme P-283 retire ses permissions), ou une porte qui compte les comptes hors des 9 de banc |

---

## Angles morts

| Non vérifié | Pourquoi |
|---|---|
| **`outils/cliquet.sh` et `outils/make.sh`** | interdits par le poste de travail. **V-077 repose donc sur une lecture** — quatrième audit de suite où le point bloquant du projet n'a aucun témoin exécuté par un indépendant. C'est le trou le plus gênant de ce tour, et il est structurel : la règle qui l'interdit est plus vieille que le défaut |
| **CI GitHub** | non exécutable depuis un clone. `ci.yml:46-57` porte bien `fetch-depth: 0` **et** `git branch -f main origin/main` avant le cliquet — le repli de N4-5 n'y joue donc pas. Reste non prouvé : que le cliquet passe réellement. ⚠️ Et avec N4-1, il ne peut **pas** passer |
| **Portes écran P-003 / P-004 / P-005** | Playwright non joué (build web + navigateur). V-019 est jugé en lisant `tuyau.spec.ts:17` |
| **Mutations : 3 jouées** | garde D-14, filtre d'agence, table de correspondance + fail-closed. Les **50 sabotages** du 3ᵉ audit et les 13 sabotages SQL n'ont pas été rejoués un par un ; le « 0 porte aveugle » n'est donc pas revérifié en bloc |
| **S3b (`ROLLBACK` → `COMMIT` sur refus)** | non rejoué, troisième audit de suite. `executer.ts:199-206` fait bien le `ROLLBACK` avant de tracer, mais rien n'indique qu'une porte le verrait inversé |
| **Une seule agence secondaire** | mes sondes de périmètre opposent PAR et CAS. Un périmètre multi-agences (un compte couvrant deux agences sur une permission) n'a pas été construit |
| **`web/`** | non audité : je n'ai lu que `contrat.ts` par ricochet. Les vues serveur sont mesurées, leur consommation non |
| **Politiques : 173 clés, 32 types d'événements sondés** | `liens.politiques` est mesuré sur les 32 types présents en base après mes sondes et les suites ; les commandes qu'aucune porte ni sonde n'a jouées n'ont pas d'événement à lire |
| **Rôles globaux au cluster** | 007 fait `ALTER ROLE ava_serveur …` à chaque construction : mes **deux** reconstructions de base ont remis les attributs du rôle **pour tout le cluster**, donc pour les autres auditeurs. Aucun `CREATE/ALTER/DROP ROLE` à la main |
| **Artefact Git Bash / psql** | sur ce poste, `psql` **n'accepte pas** d'option après le paramètre de connexion (`psql "postgres://…" -c "…"` → « option supplémentaire ignorée », `rc=0` **et rien d'exécuté**). Toutes les mesures de ce rapport ont été prises avec les options **avant** l'URL. ⚠️ Un script qui met l'URL en premier passe en silence sans rien faire |
| **V-022, discipline humaine** | réglage de poste : `verif_serveur.sh` le mesure désormais, mais le déploiement réel n'existe pas encore |
