# Septième audit — suivi des constats sur `ba9a284` (branche `lot-2`)

⛔ **Verdict : le mur d'agence est encore percé — par une autre porte.** La ligne de repli a bien disparu et
`ArchiveObject` est fermé (prouvé). Mais un compte **PAR** fait passer un positionnement **CAS** de « proposé » à
« présenté », puis à « refusé par le client » (`DeclareCVShared`, `RecordClientDecision`) : le contrôle lit `id`, le
handler lit `positionnement_id`. **314 portes vertes** pendant que la faille est vivante.

Auditeur indépendant. Code lu dans `ava-audit-7-lecture` sur `ba9a284` — `git status` **vide** au début et à la fin.
Base **`ava_audit7_a`** construite depuis rien (`db/migrations/001 → 014` + `db/fixtures/banc.sql`, `rc=0` × 15),
serveur port **3701**. Mutations jouées sur une **copie jetable** (scratchpad, `node_modules` en jonction, jonctions
retirées, `node_modules` du clone vérifiés intacts). Sorties longues : `rapport/preuves/suivi7/`.
⛔ Rien n'est « Fermé » sans une commande exécutée ou un `fichier:ligne` lu et rejoué.

## Ce qui a tourné, sur base NEUVE (`preuves/suivi7/10_*`, `11_*`)

| Suite | Résultat |
|---|---|
| `sante` · `inventaire` · `outils` | 1/1 · 1/1 · **2/2** (avec `psql` dans le PATH) |
| `commandes` · `chemin` · `politiques` · `matrice` | **56/56** · **56/56** · **50/50** · **52/52** |
| `audit3` · `audit4` · `audit6` (neuve, P-314 → P-324) | **15/15** · **25/25** · **11/11** |
| `correctifs` | **45/46** — ✖ P-148 : `test/test-results/` n'existe pas dans un clone propre (environnement, voir N7-9) |
| `comptes-avant-fixture` | 0/1 — attendu : la porte se joue **avant** la fixture |
| Assertions L7 | **41 OK**, plancher **41** (`plancher_assertions.sh`), `cmp` canon/copie **identiques**, `rc=0`, 0 « LE GESTE EST PASSÉ » (`90_*`) |

⭐ **314 portes vertes, 1 rouge d'environnement.** ⛔ Toutes vertes pendant que N7-1, N7-2, N7-3, N7-4 sont vivantes.

---

## Les 11 constats du 6ᵉ audit (V-117 → V-127)

| Constat | Gravité | Verdict | Preuve |
|---|---|---|---|
| **V-117** `ArchiveObject` porte dérobée | critique | ✅ **Fermé** (sa porte) | Sonde du 6ᵉ rejouée et élargie (`30_sondes_d31.sh` → `30_*_sortie.txt`, droit `ArchiveObject` posé à IA par `ManageGroups` sur `agence PAR`) : société CAS → **`GARDE « utiliser ArchiveCompany »`** ; contact CAS → **`GARDE « utiliser ArchiveContact »`** ; personne, candidat, ressource, besoin, projet, action CAS → **`DROIT`** ×6 ; relu en base : **0 objet CAS archivé**. Identifiant qui ne mène à rien → **`INTROUVABLE`** pour les 6 types lus. Témoin positif : candidat PAR → **`ok:true`**. La ligne `else await exigeDroit(ctx, ctx.commande, ctx.compte.agence_id)` (`a26291c:agence.ts:285`) **n'existe plus** ; `ctx.compte.agence_id` n'apparaît plus qu'à `agence.ts:402`, branche `creation` (déclarée). ⛔ **Mais la famille du constat n'est pas fermée : voir N7-1** |
| **V-118** repli non gardé | elevee | ⚠️ **Partiel** | Ligne supprimée ✅. ⛔ « Rien ne la garde » reste vrai : **mutation M3** (le repli rétabli à `agence.ts:415` : objet non résolu → droit dans l'agence du compte) → **0 porte sur 215 ne tombe** (`audit6` 11/11, `audit4` 25/25, `audit3` 15/15, `matrice` 52/52, `commandes` 56/56, `chemin` 56/56 ; `63_M3*`). Mutant prouvé vivant : le refus d'un id inexistant passe de « objet introuvable » (contrôle) à « besoin introuvable » (handler) |
| **V-119** `TransferContact` | elevee | ⚠️ **Partiel** | Code ✅ (`crm.ts:393-402`) et mesuré : contact PAR → société CAS → **`DROIT`** ; contact CAS → société PAR → **`DROIT`** ; droit ajouté sur CAS → transfert **`ok:true`**, la base rend société **CAS**, contact **CAS** ; puis `UpdateContact` par le compte PAR → **`DROIT`**. ⛔ **La porte P-323 est aveugle** : **mutation M1** (la recopie d'`agence_responsable_id` retirée) → `audit6` **11/11**, `audit4` **25/25** ; mutant vivant (contact resté **PAR** sous une société **CAS**, `61_M1.txt`). P-323 transfère entre deux sociétés **PAR** : l'agence « suit » sans bouger |
| **V-120** le banc efface les délégations | elevee | ⛔ **Ouvert** | 6 délégations posées par `ManageGroups` sur `agence PAR`, puis 8 suites → **4 disparues** (`ArchiveCompany`, `ArchiveContact`, `ArchiveObject`, `ArchiveService`) ; diff complet de `groupe_permission_perimetre` : **95 → 91 lignes**, rien d'autre ne bouge (`40_v120.txt`). Attribution, une suite à la fois : **`matrice` 4 → 0 · `audit4` 4 → 0 · `chemin` 4 → 0**. Cause lue : `v011-lignes.ts:127` `accorder(…, PERIMETRE_PAR)` est `ON CONFLICT DO NOTHING` sur une ligne déjà là, puis `:132` `retirer(…, PERIMETRE_PAR)` l'efface. ⛔ **P-324 est aveugle** : elle teste une délégation sur **CAS** contre une pose **globale** — jamais le même périmètre |
| **V-121** `paiement.etat_code` | elevee | ✅ **Fermé** | `ref_etat_paiement` : `planifie`, `confirme`, `regle` ; `fk_paiement_etat FOREIGN KEY (etat_code) REFERENCES ava.ref_etat_paiement(code)` (`70_base.txt`) |
| **V-122** lot 3 écrivable | elevee | ✅ **Fermé** (réserve → N7-7) | Les **27** tables de `014_corrections_012.sql:77-88` : `has_table_privilege` → **27 lisibles, 0 écrivable** par `ava_app` (`72_*`). ⚠️ Le principe (« le GRANT vient avec la commande ») n'a été appliqué **qu'à elles** : 19 autres tables restent écrivables sans aucune commande — N7-7 |
| **V-123** branche agence nulle | moyenne | ✅ **Fermé** | Mesuré sur MA base : `besoin.agence_id` rendu nullable, un besoin PAR passé à NULL → `UpdateNeed` par IA → **`DROIT`** (plus « périmètre global ») ; et **P-322 rougit** (`AssertionError: besoin.agence_id`, 10/11). NOT NULL rétabli, relu `NO` (`50_*`) |
| **V-124** commits sans `Role:` | moyenne | ✅ **Fermé** | `.github/workflows/ci.yml:65-66` lance `bash outils/verif_trailers.sh`. Commande exacte : **rc=0** sur HEAD (200 commits, 3 exceptions nommées, 29 antérieurs à D-29). Témoin négatif sur un clone jetable : un commit vide sans trailer → **`KO ddba18b sans trailer Role:`, rc=1** (`81_*`). `a26291c..HEAD` : **11 commits, 11 avec `Role:`** (`80_*`) |
| **V-125** `LireDonneesRHSensibles` | moyenne | ✅ **Fermé** | Seed : groupe **RH**, périmètre **agence PAR** (`70_base.txt`). Permissions sans titulaire au seed : **4** (`ArchiveCompany`, `ArchiveContact`, `ArchiveService`, `UpdateResourceCost`) — assumé D-30 |
| **V-126** grille 42/43 | moyenne | ⚠️ **Partiel** | Total juste : **43** annoncés (`GRILLE_AUDIT.md:6`) = **43** lignes de contrôle. ⛔ Mais la section F dit « **11 contrôles (F1 → F11)** » (`:136`) et en porte **13** (F12, F13). B1 cherche bien `.includes(` / `.startsWith(` (`:45`) |
| **V-127** bien fait | bonne | ✅ **Tient sur ce qui a été rejoué** (2 points sur 5 : un numéro = un fichier, hors banc fermé) | modèle paramétrable, cliquet 13 cases, 69 sabotages : **non rejoués** — voir angles morts |

---

## ⭐ LE POINT QUI DÉCIDE : D-31 vérifié commande par commande

Table complète des 55 : `preuves/suivi7/21_natures_55.md`. **55 lignes = 55 handlers.** Natures : **44 objet ·
7 creation · 3 installation · 1 soi**. Le critère : la clé lue par le **contrôle** et la clé lue par le **handler**
désignent-elles le même objet ; en `creation`, l'agence **contrôlée** est-elle l'agence **écrite** ?

| Question posée | Réponse mesurée |
|---|---|
| La ligne de repli a-t-elle disparu ? | ✅ oui (`git show a26291c:…:285` vs `ba9a284`) — ⛔ mais sa réintroduction ne fait tomber **0/215** portes (M3) |
| Chaque nature est-elle la bonne ? | ✅ les 55 natures sont **cohérentes** ; aucune commande mal classée `creation` ou `soi` pour échapper à la lecture de l'objet |
| Objet introuvable → `INTROUVABLE` ? | ✅ les 6 types lus d’`ArchiveObject` (S1b) |
| Objet d'agence nulle → `DROIT` ? | ✅ mesuré (V-123) |
| Une `soi` modifie-t-elle autrui ? | ✅ non : `SetOwnTheme` n'écrit que `compte.id` du demandeur (`admin.ts:310`) |
| Une `creation` modifie-t-elle un objet existant d'une autre agence ? | ⛔ **oui, une** : `CreateProject` accepte un `besoin_id` CAS sans le lire ; `SignPrestation` sur ce projet PAR fait passer le besoin **CAS** à **`pourvu`** (N7-4, S6) |
| Une `creation` écrit-elle dans une autre agence ? | ⛔ **oui, trois** : `CreateCandidate`, `CreateResource` (clés désynchronisées), `CreateCompany` (agence du manager fourni) — N7-2, N7-3 |
| Une `objet` modifie-t-elle un objet d'une autre agence ? | ⛔ **oui, deux** : `DeclareCVShared`, `RecordClientDecision` — **N7-1, critique** |

⭐ **Pourquoi la série continue.** D-31 a supprimé le repli, mais le contrôle et le handler **lisent toujours l'entrée
chacun de leur côté**, avec leurs propres listes de clés et leur propre ordre. Dès que les deux listes divergent, le
contrôle juge un objet et le handler en écrit un autre. **Cinquième tour, cinquième porte** (V-076 → V-097 → V-107/108 →
V-117 → N7-1).

---

## Les restes des tours précédents

| Constat | Gravité | Verdict | Preuve |
|---|---|---|---|
| **V-107** repli sur l'agence du demandeur | critique | ✅ **Fermé** (le repli n'accorde plus rien) | `sinonCompte`, `agenceGouvernante` : **0** ligne en `server/src`. ⚠️ Reste `agence.ts:338` : le droit est exigé **aussi** dans l'agence du compte pour toute commande — un **ET**, pas un repli (fermé par défaut ; conséquence : N7-8) |
| **V-108** société et contact sans agence | critique | ✅ **Fermé** | Les 6 commandes société/contact et `ArchiveObject` refusent sur objet CAS (S1, S2). ⚠️ Nouvelle façon d'**écrire** une société dans une autre agence à sa création : N7-3 |
| **V-109** `RecordClientDecision` hors référentiel | elevee | ✅ **Fermé** | Code : `besoin.ts:321-329` lit `ref_decision_client`. Grille : B1 cherche `.includes(` (`GRILLE_AUDIT.md:45`) ; rejoué : 8 `.includes(` en `server/src`, tous sur des **listes de politique** (`doublon.*.cles`), aucun sur un état |
| **V-110** délégations | elevee | ⛔ **Ouvert** | = V-120 |
| **V-111** deux migrations 009 | elevee | ✅ **Tient** | `db/migrations/` : **14 fichiers, 14 numéros** |
| **V-112** F13 au cliquet | elevee | **Partiel** (lu, 7ᵉ tour) | `outils/cliquet.sh` interdit d'exécution |
| **V-113** trailers | moyenne | ✅ **Fermé** | par V-124 |
| **V-114** NOT NULL | moyenne | ✅ **Tient, et gardé** | P-322 lit toutes les colonnes d'agence de la table ; mesuré rouge quand l'une redevient nullable |
| **V-115** écarts du 4ᵉ tour | moyenne | **Partiel** (assumé D-30) | 4 permissions sans titulaire (5 au 5ᵉ, 6 au 6ᵉ) |
| **V-019** portes écran | elevee | **Partiel** (7ᵉ tour) | Playwright hors périmètre : P-003, P-004, P-005 |
| **V-022** `pg_hba` en `trust` | elevee | **Ouvert, assumé et gardé** | `verif_serveur.sh` → **rc=1** (règles `trust`, `ava_serveur` sans mot de passe) ; `AVA_POSTE_DEV=1` → **rc=0** ; P-300 vert (`92_*`) |
| **V-077** cliquet jamais exécuté par un tiers | elevee | **Partiel** (7ᵉ tour) | interdit d'exécution |
| **N4-2** catégorie auto-référentielle | elevee | ⛔ **Ouvert, inchangé** | `ManageRefs ref_pays categorie:"afrique"` → **`GARDE « catégorie inconnue »`** ; `"defaut"` → **`ok:true`** ; `ref_pays` n'a qu'une catégorie (`91_*`) |
| **N4-5** F12 repliée sur HEAD | moyenne | ⛔ **Ouvert, inchangé** (lu) | `cliquet.sh:284` `f12_liste="HEAD"` ; `:302` ne pose KO que si `f12_n -eq 0` |
| **N6-4** registre des migrations dans `make.sh` seul | moyenne | ⛔ **Ouvert** | base construite à `psql` : `schema_migrations` → **0 table** ; `014` ne l'a pas ajouté |
| **N6-5** 56 permissions, 55 lignes | basse | ⛔ **Ouvert** | `permission` = **56** ; P-321 parcourt `HANDLERS` → table, **jamais** `permission` → table |

---

## Les constats « bonne » — tiennent-ils ?

| Point | Verdict | Mesure de ce tour |
|---|---|---|
| Murs de rôles | ✅ **Tient, et se resserre** | `ava_app` : **INSERT 122 · SELECT 149 · UPDATE 118 · 0 DELETE** (148/148/144 au 6ᵉ : −26 tables) ; `ava_lecture_agregats` 7 relations, SELECT seul ; `ava_app`/`ava_lecture_agregats`/`ava_migration` NOLOGIN ; `ava_serveur` login, **pas** superutilisateur |
| Assertions, plancher compté | ✅ **Tient, et monte** | **41 OK** (40 au 6ᵉ), plancher **41**, `cmp` identique, `rc=0` |
| Paramétrage | ✅ **Tient** | **201** politiques, **72** tables `ref_*` (71 au 6ᵉ), **0** `valeur <> valeur_defaut` après mes sondes |
| D-14 ferme tout hors banc | ✅ **Tient** | serveur sans `AVA_MODE` : `/tuyau`, `/vues/besoins`, `/vues/besoins/<id>`, `/`, `/index.html`, `/contrat.js`, `/acquitter`, `/vues/besoins` avec en-tête → **401** ; `/sante` → 200 (`93_*`) |
| Pas d'écriture par un anonyme | ✅ **Tient** | **30 POST** `/commandes/*` (sans en-tête, en-tête `adm`, en-tête `ia`) → **30 × 401** ; `evenement_metier` 5206 → 5206, `societe` 378 → 378, `positionnement` 240 → 240 |
| `/sante` n'interroge pas la base | ✅ **Tient** | 30 appels → connexions **1 → 1** |
| Choix de modèle paramétrable (V-127) | **Non rejoué** | les trois modes de `societe.perimetre.mode` n'ont pas été resondés ce tour (angle mort) |
| « 0 porte aveugle » | ⛔ **Rouge, 3ᵉ tour de suite** | M1 (V-119) et M3 (V-118) : **0 porte ne tombe** ; N7-1 à N7-4 vivants sous 314 portes vertes |

---

## Mutations jouées (copie jetable, serveur mutant sur 3701, portes relancées)

| # | Mutation | Attendu | Mesuré |
|---|---|---|---|
| **M1** | `TransferContact` ne recopie plus `agence_responsable_id` (`crm.ts:400-401`) | P-323 tombe | ⛔ `audit6` **11/11**, `audit4` **25/25** ; mutant vivant (contact PAR sous société CAS) |
| **M3** | le repli rétabli : `if (!trouve)` → `exigeDroit(…, ctx.compte.agence_id)` (`agence.ts:415`) | une porte tombe | ⛔ **0/215** (`audit6`, `audit4`, `audit3`, `matrice`, `commandes`, `chemin`) ; mutant vivant |
| **V-123** (sur base, pas sur code) | `besoin.agence_id` nullable | P-322 tombe | ✅ **P-322 tombe** (10/11) |

---

## Compte

| Verdict | Nombre | Lesquels |
|---|---|---|
| **Fermé** | **6** | V-117 · V-121 · V-122 (réserve) · V-123 · V-124 · V-125 |
| **Partiel** | **3** | V-118 · V-119 · V-126 |
| **Ouvert** | **1** | V-120 |
| Restes | **Fermés** V-107 V-108 V-109 V-113 · **Tiennent** V-111 V-114 · **Partiels** V-019 V-077 V-112 V-115 · **Ouverts** V-110 (=V-120) N4-2 N4-5 N6-4 N6-5 · V-022 assumé | |
| **Bonne** | 6 tiennent · 1 non rejoué · **« 0 porte aveugle » rouge** | |

### Critiques encore ouverts

| # | État | Pourquoi |
|---|---|---|
| **N7-1** (neuf) | ⛔ **Ouvert, critique** | un compte PAR modifie le positionnement d'un besoin CAS par `DeclareCVShared` et `RecordClientDecision` : le contrôle lit `id`, le handler lit `positionnement_id`. Mesuré, relu en base, événements signés `ia@ava.test` |
| **V-077** | **Partiel, 7ᵉ tour** | le cliquet n'a toujours aucun témoin exécuté par un tiers |

---

## Constats neufs candidats

| # | Défaut · une phrase | Cible | Gravité | Preuve | Reproduire | Correction |
|---|---|---|---|---|---|---|
| **N7-1** | **Le contrôle et le handler ne lisent pas la même clé** : `DeclareCVShared` et `RecordClientDecision` jugent le positionnement désigné par `id` et écrivent celui désigné par `positionnement_id` | CODE | **critique** (mur percé) | `agence.ts:54-57` lecteur `POSITION` sur `["id","positionnement_id"]` ; `besoin.ts:276` et `:297` `req(ctx.entree, "positionnement_id", "id")` — ordre inverse (`WithdrawPositioning`, `:347`, est dans le bon ordre). **Mesuré** (S3) : clé seule sur positionnement CAS → **`DROIT`** ×2 ; `{id: <positionnement PAR>, positionnement_id: <positionnement CAS>}` → **`ok:true`** ×2 ; base : CAS `propose → presente`, CAS `presente → refuse_client`, `decision_client_le` posé ; événements `CVShared` et `ClientDecisionRecorded` sur les objets CAS, auteur `ia@ava.test`. ⛔ **Porte aveugle** : 314 portes vertes | `bash rapport/preuves/suivi7/30_sondes_d31.sh` (section S3) | ① remettre l'ordre des clés ; ⭐ ② **structurel** : `exigeAgence` résout l'identifiant **une fois** et le handler le reçoit (`ctx.objetId`), il ne relit plus l'entrée ; ou refuser `GARDE` une entrée qui porte **deux** clés différentes pour le même objet ; ③ une porte qui, pour **chaque** ligne à plusieurs clés, envoie deux ids d'agences différentes et exige `DROIT` |
| **N7-2** | **Même désynchronisation en création** : `CreateCandidate` et `CreateResource` contrôlent l'agence de `agence`, écrivent celle de `agence_id` | CODE | **elevee** | `agence.ts:88`, `:97` lisent `["agence","agence_id"]` ; `identite.ts:68` lit `agence_id` **seul**, `:246` lit `agence_id` puis `agence`. **Mesuré** (S4) par `rh@ava.test` (PAR) : `agence_id` CAS seule → **`DROIT`** ; `{agence: PAR, agence_id: CAS}` → **`ok:true`** ×2, base : candidat **CAS**, ressource **CAS** | S4 du même script | même correction que N7-1 : l'agence résolue par le contrôle est **celle** que le handler écrit |
| **N7-3** | **`CreateCompany` écrit la société dans l'agence du manager fourni, et contrôle l'agence du compte** : un compte PAR crée une société CAS, puis la perd | CODE | **elevee** | `crm.ts:24`, `:52-58` : `agence_responsable_id` = agence du compte `manager` lu dans l'**entrée** ; `agence.ts:73` `creation()` sans lecteur → contrôle sur l'agence du compte. D-31 : « droit dans l'agence **où il sera écrit** ». **Mesuré** : `CreateCompany {manager: <compte CAS>}` par ia (PAR) → **`ok:true`**, `agence_responsable = CAS` ; `UpdateCompany` par le même compte → **`DROIT`**. Même geste lu (non sondé) : `ConvertCandidateToResource` écrit la ressource dans l'agence **du compte** (`identite.ts:207`), pas dans celle du candidat contrôlé | S4 | un lecteur `manager` → `compte.agence_id` dans la ligne `CreateCompany`, ou refuser un manager d'une autre agence ; `ConvertCandidateToResource` écrit l'agence du candidat |
| **N7-4** | **Une création se rattache à un objet d'une autre agence sans le lire** : `CreateProject` accepte le `besoin_id` d'un besoin CAS ; signer la prestation du projet PAR fait passer le besoin **CAS** à « pourvu » | CODE | **elevee** | `projet.ts:50-58` insère `besoin_id` sans lecture (ni agence, ni cohérence de société : projet sur `SocPAR`, besoin sur `SocCAS`). **Mesuré** (S4 + S6) : `dp@ava.test` (PAR) crée le projet, puis avec `besoin.pourvu.mode = auto_par_prestation_signee` (valeur du registre) `SignPrestation` → besoin **CAS** `staffing → pourvu`, événement `NeedFilled` signé `dp@ava.test`. Au réglage par défaut, `v_besoin_couverture` compte déjà la prestation PAR dans la couverture du besoin CAS. Même famille, moyenne : `CreateUnit` pose une unité **PAR** sous une société **CAS** (`crm.ts:137-179` ne lit jamais l'agence de `societe_id`) | `31_sonde_projet_besoin_cas.sh <suffixe>` | lire `besoin_id` (et exiger la même société) dans `CreateProject` ; lire la société dans `CreateUnit` ; ⭐ règle : **tout identifiant d'objet existant présent dans une entrée a un lecteur** — une porte qui compare les clés `*_id` lues par chaque handler aux clés de sa ligne |
| **N7-5** | **La porte P-323 et la porte P-324 ne voient pas ce qu'elles gardent** | CODE (banc) | **elevee** | M1 : P-323 verte sans la recopie d'agence (le transfert « permis » reste dans PAR). P-324 : délégation CAS vs pose globale ; le cas réel (même périmètre, `v011-lignes.ts:127-132`) efface 4 délégations sur 6 | `61_M1.txt`, `40_v120.txt` | P-323 : transférer vers une société d'**une autre** agence avec droit aux deux, relire `CAS` ; P-324 : poser la délégation sur **`agence PAR`** puis lancer `matrice` ; `v011-lignes.ts` : photographier avant `accorder`, ne retirer que si la ligne n'existait pas |
| **N7-6** | **Rien ne garde la suppression du repli** | CODE (banc) | **elevee** | M3 : 0/215 | `63_M3.txt` | une porte qui envoie à une commande `objet` un id **que le lecteur ne trouve pas mais que le handler trouve** (table voisine) et exige `INTROUVABLE` |
| **N7-7** | **« Le GRANT vient avec la commande » n'est appliqué qu'au lot 3** : 19 tables restent écrivables par `ava_app` sans qu'aucune commande ne les écrive, dont les tables **de droits** | CODE | **moyenne** | `permission`, `perimetre`, `groupe`, `compte_groupe`, `agence`, `compte_surcharge`, `societe_role`, `periode_emploi`, `personne_coordonnee`, `modele`, `reprise_boond`… (001 et 006) ; aucune ligne `INSERT INTO`/`UPDATE` sur elles en `server/src` (`71_*`, `72_*`) | `comm` entre `role_table_grants` et le grep de `server/src` | même traitement que `014` §3, et une assertion L7 qui **compte** les tables écrivables sans commande |
| **N7-8** | **Deux impasses fermées par défaut** : une personne sans profil ne s'archive **jamais** (même au périmètre global) ; un droit délégué dans une autre agence que celle du compte n'ouvre **rien** | CODE | **basse** | `agence.ts:260-261` `exigerToutes([])` → `DROIT` : `ArchiveObject personne` sans profil → **`DROIT`** pour ia **et pour adm (global)** (S1e). `agence.ts:338` + `droits.ts:34` : droit `ArchiveService` posé sur le seul périmètre CAS → `ArchiveService` sur une unité CAS → **`DROIT`** (S5) : D-31 dit « droit dans l'agence lue », le code exige **aussi** l'agence du compte | S1e, S5 | trancher par écrit ; si voulu, le dire dans D-31 |
| **N7-9** | **P-148 ne passe pas dans un clone propre** | CODE (banc) | **basse** | `correctifs.test.ts:660` écrit dans `test/test-results/`, absent d'un clone neuf → `ENOENT` ; P-136 exige `AVA_URL_MIGRATION`, que seul `make.sh` pose | `node --test contrat/correctifs.test.ts` sur un clone neuf | `mkdirSync(…, {recursive:true})` ; documenter l'environnement des portes |

---

## Angles morts

| Non vérifié | Pourquoi |
|---|---|
| **`outils/cliquet.sh`, `outils/make.sh`** | interdits — **7ᵉ audit** : V-077, V-112, N4-5 reposent sur une lecture |
| **CI GitHub, Playwright (P-003/004/005), `web/`** | non exécutables ici |
| **Les trois modes de `societe.perimetre.mode`** | non resondés : seul le mode par défaut (`agence_responsable`) a servi. `TransferContact` n'appelle pas `modeSociete` (deux lectures) : son comportement en mode `partagee`/`par_besoins` n'est pas mesuré |
| **`ConvertCandidateToResource` multi-agences** | lu (N7-3), non sondé : il faut un compte couvrant deux agences |
| **`RecordQualification`** | la personne n'est pas lue quand un besoin est fourni (`agence.ts:394-397` s'arrête au premier trouvé) : conception à trancher, non classée en constat |
| **Création de besoin/projet sur une société d'une autre agence** | admise par le code (modèle `par_besoins`) ; ses effets sur la société (passage prospect → client par `effetsSignature`) non sondés |
| **Mutations : 2 jouées** (M1, M3) + 1 sur la base | les 69 sabotages des tours précédents non rejoués ; S3b (`ROLLBACK` → `COMMIT`) non rejoué, **6ᵉ tour** |
| **Délégations et données posées par moi dans `ava_audit7_a`** | ⚠️ déclarées : un compte `cas-a7…@ava.test` (agence CAS) et un groupe `CAS-a7…` avec 12 droits sur le périmètre CAS, posés **en SQL** (lignes de données, comme `audit6.test.ts:12-32`) ; agence CAS et périmètre CAS (mêmes ids que `db.ts`) ; par `ManageGroups` : IA × `ArchiveObject`/`ArchiveCompany`/`ArchiveContact`/`ArchiveService`/`LireDonneesRHSensibles`/`UpdateResourceCost` sur PAR, IA × `TransferContact` et `ArchiveService` sur CAS (retirées) ; **restent** : IA × `LireDonneesRHSensibles` et `UpdateResourceCost` sur PAR. `SetPolicy besoin.pourvu.mode` posé puis **rétabli** (0 écart). `ManageRefs` : une ligne `ref_pays` `Zdefaut`. `besoin.agence_id` rendu nullable puis **rétabli NOT NULL**. Aucun `CREATE/ALTER/DROP ROLE` |
| **Rôles globaux au cluster** | `007` fait `ALTER ROLE ava_serveur …` à chaque construction : ma construction a remis les attributs du rôle pour tout le cluster |
| **Artefacts de poste** | ① `psql` sous Git Bash : les libellés accentués passés en argument cassent l'encodage (`0xe9`) — retirés des requêtes ; ② les tâches serveur en arrière-plan finissent « exit 127 » quand je les arrête : c'est l'arrêt, pas un échec de démarrage (chaque démarrage a répondu `{"ok":true}` sur `/sante`) |
