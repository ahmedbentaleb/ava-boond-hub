# SÉCURITÉ 7 — famille I · commit `ba9a284` (branche `lot-2`)

**Verdict : 🔴 — la garde d'agence se contourne avec les droits du SEED, sans aucune délégation.**
Trois commandes lisent une autre clé d'entrée que celle que la garde vérifie : un compte d'agence PAR
écrit un positionnement de LYO (dont la décision client) et crée des profils dans LYO. Le périmètre
`soi`, posé par `ManageGroups`, vaut `global`.

| Mesure | Résultat |
|---|---|
| Sondes « hors agence » directes, 52 commandes × objet LYO, avec contrôle positif PAR | ✅ **52/52 `DROIT`, 0 écriture** (empreinte md5 de 24 tables avant/après) |
| `ArchiveObject` sur les 10 types (+ personne à profils PAR+LYO, action portée par société) | ✅ **12/12** : 4 renvois vers la commande dédiée, 8 `DROIT`, 0 écriture |
| Contournements de la garde (une référence que la garde ne lit pas) | ⛔ **7 commandes écrivent hors agence** (I-01 → I-06), **toutes reproduites avec les droits du SEED** ; 4 autres références secondaires à trancher (I-07) |
| Périmètre `soi` posé par `ManageGroups` | ⛔ **3/3 écritures dans LYO** (`UpdateNeed`, `SuspendNeed`, `RecordTimesheet`) |
| GRANT d'écriture de `ava_app` | ✅ 27 tables du lot 3 fermées · ⛔ **19 tables écrivables sans aucune commande** (dont `compte_groupe`, `groupe`, `permission`, `perimetre`, `agence`) |
| SQL paramétré | ✅ aucune valeur d'entrée interpolée ; noms de table tirés de listes fermées |
| Refus avant écriture | ✅ transaction unique, `ROLLBACK` sur tout refus (0 écriture mesurée sur 60+ refus) |
| Hors `AVA_MODE=banc` | ✅ 56/56 `POST /commandes/*` et toutes les routes en **401**, `/sante` seul en 200, **0 table modifiée** |
| `paiement.etat_code` | ✅ clé étrangère vers `ref_etat_paiement` (le CHECK de 012 est retiré) |
| pg_hba (`outils/verif_serveur.sh`) | ⚠️ poste de dev : KO sans `AVA_POSTE_DEV=1` (trust), OK avec — **le VPS n'est pas mesurable d'ici** |
| Secrets suivis par git | ✅ aucun (valeurs masquées dans la preuve) |

---

## 0 · Le décor — DÉCLARÉ

⭐ Tout est dans `rapport/preuves/securite7/scripts/` ; base `ava_audit7_b`, port 3702, serveur `AVA_MODE=banc`,
connecté en `ava_serveur` (mesuré : `pg_stat_activity` → `ava_serveur`, `rolsuper = f`).

| Étape | Comment | Pourquoi |
|---|---|---|
| Migrations 001 → 014 + `db/fixtures/banc.sql` | `psql --single-transaction -v ON_ERROR_STOP=1`, rc 0 partout | la consigne |
| `_ops/JEU_ESSAI.sql` | ⛔ **ne se charge pas** (voir G-11 dans GRILLE7) | — |
| **S1 — SQL, rôle `postgres`** | agence `LYO` (`…00b1`), périmètre d'agence LYO (`…00b2`), compte `lyo@ava.test` (agence LYO) rattaché au groupe SUP | aucune commande ne crée d'agence, de périmètre ni de compte |
| **S2 — `ManageGroups` par `adm`** | SUP reçoit 52 permissions en `global` | bâtir le décor de LYO **par les commandes** (`s2_setup.jsonl`) |
| **S3 — `ManageGroups` par `adm`** | RR reçoit **les 56 permissions sur l'agence PAR seule** ; DP reçoit les **5 permissions que le seed ne donne à personne** (`UpdateResourceCost`, `ArchiveCompany`, `ArchiveService`, `ArchiveContact`, `ArchiveObject`) sur PAR ; `candidat.conversion.acteur = tout_habilite` | la leçon du 6e audit : poser d'abord ce que le seed ne donne pas |
| Décor | 1 exemplaire de chaque objet dans LYO (par `lyo`) et dans PAR (par `sup`) — `decor.json` | objets réels, pas de SQL direct |
| S6 (puis retiré en SQL, déclaré) | RES reçoit `UpdateNeed`/`SuspendNeed` en `soi`, `RecordTimesheet` sur l'agence PAR | sonder `soi` ; retiré avant la conformité pour rendre à RES son état du seed |

---

## 1 · Les constats

### I-01 · ⛔ `DeclareCVShared` et `RecordClientDecision` : la garde lit `id`, la commande lit `positionnement_id`

| | |
|---|---|
| **Défaut** | La ligne `POSITION` de la table d'agence cherche l'objet par `["id", "positionnement_id"]` et s'arrête au premier trouvé ; les deux commandes prennent `req(entree, "positionnement_id", "id")`. Deux clés, deux objets : la garde juge l'un, la commande écrit l'autre. |
| **Cible** | `server/src/agence.ts:54-57` · `server/src/commandes/besoin.ts:276` et `:297` |
| **Famille** | I — périmètre par objet (K4) |
| **Gravité** | 🔴 **critique** — droits du SEED, aucune délégation, décision client d'une autre agence réécrite |
| **Preuve** | `rapport/preuves/securite7/s5_resultats_partie1.txt`, `s5_sondes.jsonl` |
| **Reproduire** | `ia@ava.test` (seed : IA sur l'agence PAR) : `DeclareCVShared {"id": <positionnement PAR>, "positionnement_id": <positionnement LYO>}` puis `RecordClientDecision {même paire, "decision": "retenu"}` |
| **Prétend** | L4 §V : « `DROIT` dans l'agence **lue** de l'objet » ; grille K4 : « par commande : un cas hors agence → `DROIT`, 0 écriture » |
| **Mesure** | témoin `{"positionnement_id": LYO}` seul → `DROIT` ✅ ; la paire → **OK**, positionnement LYO `propose → presente → retenu` (ia), `→ refuse_client` (rr) ; l'événement porte `objet_id` = le positionnement de LYO |
| **Correction** | Une seule source pour l'identifiant : la table d'agence doit **fournir** l'id à la commande (ou refuser `GARDE` si plusieurs clés candidates sont présentes et désignent des objets différents). Même ordre de clés partout ; une porte par commande avec **les deux clés** posées. |

### I-02 · ⛔ `CreateCandidate` et `CreateResource` : la garde lit `agence`, la commande écrit `agence_id`

| | |
|---|---|
| **Défaut** | Garde : `agence(["agence", "agence_id"])` (premier trouvé). Commandes : `opt(entree, "agence_id")` (candidat) et `req(entree, "agence_id", "agence")` (ressource). |
| **Cible** | `server/src/agence.ts:88` et `:97` · `server/src/commandes/identite.ts:68` et `:246` |
| **Famille** | I — K4 (création hors agence) |
| **Gravité** | 🔴 **critique** — droits du SEED (RH, RR) |
| **Preuve** | `s5_resultats_partie2.txt` (C3, C3bis, C4) |
| **Reproduire** | `rh@ava.test` : `CreateCandidate {"personne_id": P, "titre": "t", "agence": <PAR>, "agence_id": <LYO>}` ; idem `CreateResource` |
| **Prétend** | S4 (contrôle direct) : `{"agence_id": LYO}` seul → `DROIT` ✅ |
| **Mesure** | la paire → **OK**, `profil_candidat.agence_id` = LYO, `profil_ressource.agence_id` = LYO |
| **Correction** | Comme I-01 : un seul nom de champ (`agence_id`) lu par la garde ET écrit par la commande ; refuser une entrée qui porte deux clés d'agence différentes. |

### I-03 · ⛔ `CreateCompany` : l'agence responsable est celle du `manager` passé en entrée

| | |
|---|---|
| **Défaut** | Nature `creation` sans lecteur : la garde juge l'agence **du demandeur** ; la commande écrit `agence_responsable_id` = agence du compte `manager` fourni. |
| **Cible** | `server/src/agence.ts:73` · `server/src/commandes/crm.ts:52-58` |
| **Famille** | I — K4 |
| **Gravité** | 🟠 **élevée** — droits du SEED (IA) ; une société naît dans une agence où l'auteur n'a aucun droit (il ne peut ensuite plus la modifier : `UpdateCompany` → `DROIT`) |
| **Preuve** | `s5_resultats_partie2.txt` (C5) |
| **Reproduire** | `ia@ava.test` : `CreateCompany {"nom": "X", "manager": "00000000-0000-4000-8000-0000000000b3"}` |
| **Mesure** | OK, `agence_responsable = LYO` |
| **Correction** | Déclarer l'agence écrite dans la ligne (`entreeAgence`) et l'exiger ; ou relire l'agence du `manager` dans la garde. |

### I-04 · ⛔ Le périmètre `soi` vaut `global` hors des trois commandes « S »

| | |
|---|---|
| **Défaut** | `couvre()` accepte `type_code = "soi"` pour **n'importe quelle agence** ; la garde S (`exigeSoiMeme`) ne s'applique qu'à la liste en dur `SOI_MEME` (3 commandes) et **se désarme** dès que le compte a aussi un autre périmètre sur la même permission. `ManageGroups` accepte `soi` pour toute permission. |
| **Cible** | `server/src/droits.ts:31-32`, `:53`, `:62` · `server/src/kernel.ts:187` · `server/src/commandes/admin.ts:237-272` |
| **Famille** | I — périmètre ; B1 (liste de commandes en dur) |
| **Gravité** | 🟠 **élevée** — exige une délégation par `ManageGroups`, mais une délégation **légitime en apparence** |
| **Preuve** | `s6_resultats.txt` (§ « Le périmètre soi ») |
| **Reproduire** | `adm` : `ManageGroups {"groupe":"RES","permission":"UpdateNeed","perimetre":"<soi>"}` → `res@ava.test` : `UpdateNeed {"id": <besoin LYO>}` ; et `ManageGroups RES RecordTimesheet <agence PAR>` → `res` : `RecordTimesheet` sur une prestation LYO d'une autre ressource |
| **Mesure** | `UpdateNeed` et `SuspendNeed` dans LYO : **OK, écrit** ; `RecordTimesheet` LYO (soi + agence PAR) : **OK, 1 temps saisi** sur la prestation d'une autre ressource d'une autre agence |
| **Correction** | `soi` ne couvre **aucune** agence : il n'ouvre que les commandes dont la ligne déclare une nature « soi-même », et la garde S s'applique **par périmètre**, pas « si tous les périmètres sont soi ». `ManageGroups` refuse `soi` pour une commande qui n'a pas de sens « soi-même » (paramétré dans la table, pas en dur). |

### I-05 · ⛔ `CreateProject` accepte un `besoin_id` d'une autre agence — la signature fait passer ce besoin à « pourvu »

| | |
|---|---|
| **Défaut** | `besoin_id` n'est lu par aucun lecteur de la garde ; `v_besoin_couverture` et `effetsSignature` suivent ensuite ce lien sans regarder l'agence. |
| **Cible** | `server/src/agence.ts:134` · `server/src/commandes/projet.ts:50-58`, `:263-278` |
| **Famille** | I — périmètre (effet de bord hors agence) |
| **Gravité** | 🟠 **élevée** — droits du SEED (DP) ; avec `besoin.pourvu.mode = auto_par_prestation_signee` (valeur du registre), l'écriture est directe |
| **Preuve** | `s5_resultats_partie2.txt` (C6) · `s9_pourvu_auto.txt` |
| **Reproduire** | `dp@ava.test` : `CreateProject {agence PAR, besoin_id: <besoin LYO>}` → `CreatePrestation` → `SignPrestation` |
| **Mesure** | besoin LYO `staffing → pourvu`, événement `NeedFilled` **signé `dp@ava.test`** ; témoin : `dp UpdateNeed` sur ce besoin → `DROIT`. Sous le défaut (`manuel_avec_garde`) : la couverture LYO compte la prestation PAR et `DeclareNeedFilled` passe. |
| **Correction** | Lire `besoin_id` dans la garde de `CreateProject` (même agence, ou droit dans l'agence du besoin) ; la vue de couverture ne compte que les projets de l'agence du besoin (ou le choix est une politique). |

### I-06 · 🟠 Les lectures multiples s'arrêtent au premier objet trouvé — `RecordQualification` qualifie une personne d'une autre agence

| | |
|---|---|
| **Défaut** | La boucle de `exigeAgence` fait `break` au premier lecteur trouvé, **sauf** pour `TransferContact` (nom de commande en dur). `RecordQualification` déclare besoin **et** personne ; seul le besoin est jugé. Le code de la commande calcule l'agence du besoin/profil… et ne s'en sert pas (lignes mortes). |
| **Cible** | `server/src/agence.ts:112-119`, `:394-397` · `server/src/commandes/identite.ts:420-435` |
| **Famille** | I — K4 ; B1 |
| **Gravité** | 🟡 **moyenne** (droits du SEED : EVAL) |
| **Preuve** | `s5_resultats_partie2.txt` (C7) |
| **Reproduire** | `eval@ava.test` : `RecordQualification {"personne_id": <candidat LYO>, "besoin_id": <besoin PAR>, "type": "technique"}` |
| **Mesure** | OK, 1 qualification sur la personne LYO ; témoin besoin LYO → `DROIT` |
| **Correction** | Une propriété de la ligne (`tous: true`) au lieu du test `ctx.commande !== "TransferContact"` : toutes les références déclarées sont jugées. |

### I-07 · 🟠 Références secondaires jamais jugées — ⚠️ à trancher

| Sonde (droits du SEED) | Résultat |
|---|---|
| `dp` `CreatePrestation` projet PAR + **ressource LYO** (100 %) | OK — occupation d'une ressource LYO engagée par PAR |
| `ia` `CreateUnit` sous une **société LYO** | OK — unité d'agence PAR dans la société de LYO |
| `ia` `PositionCandidate` besoin PAR + **candidat LYO** | OK |
| `ia` `CreateNeed` agence PAR sur **société + contact LYO** | OK |

**Cible** `server/src/agence.ts` (lignes `CreatePrestation`, `CreateUnit`, `PositionCandidate`, `CreateNeed`) · **Famille** I · **Gravité** 🟡 moyenne ·
**Preuve** `s5_resultats_partie2.txt` (C8–C11). **Prétend** : rien — ni L4 ni la MATRICE ne disent si le staffing inter-agences est voulu.
**Correction** : trancher par une **politique** (« une ressource/un candidat d'une autre agence peut être engagé ») et la lire dans la garde.
⚠️ Avec `societe.perimetre.mode = par_besoins`, le besoin PAR posé sur une société LYO (C11) **ouvre cette société à PAR** : chaîne à vérifier.

### I-08 · 🟠 `ava_app` écrit 19 tables qu'aucune commande n'écrit — dont les tables des droits

| | |
|---|---|
| **Défaut** | V-122 (« le GRANT vient avec la commande ») n'a été appliqué qu'aux 27 tables du lot 3. |
| **Cible** | `db/migrations/001_schema.sql` §14 (GRANT hérités), `db/migrations/014_corrections_012.sql:64-89` · assertion `test/SPEC_ASSERTIONS_L7.sql:318-328` |
| **Famille** | I — GRANT réels |
| **Gravité** | 🟠 **élevée** — une injection ou un bug de commande se change en élévation de privilèges en une requête ; et l'assertion M-8 **porte un nom plus large que ce qu'elle mesure** |
| **Preuve** | `rapport/preuves/securite7/grants_ava_app.txt`, `ecrivables_non_ref.txt`, `ecrites_par_serveur.txt` |
| **Reproduire** | `has_table_privilege('ava_app', oid, 'INSERT'/'UPDATE')` sur toutes les relations de `ava`, moins les `ref_*`, moins les tables nommées dans un `INSERT INTO`/`UPDATE` de `server/src` |
| **Prétend** | assertion « `ava_app` n'écrit aucune table dont la commande n'est pas servie » → OK |
| **Mesure** | ✅ les 27 tables de 012/013 : `SELECT` seul. ⛔ écrivables sans commande : **`agence`, `compte_groupe`, `compte_surcharge`, `groupe`, `permission`, `perimetre`**, `alerte_regle`, `besoin_competence`, `besoin_domaine`, `besoin_outil`, `calendrier_jour_non_ouvre`, `candidat_domaine`, `candidat_outil`, `modele`, `periode_emploi`, `personne_coordonnee`, `prestation_ligne_ca`, `reprise_boond`, `societe_role` (+ GRANT sur 7 vues non modifiables). `compte` : UPDATE sur toutes ses colonnes (`actif`, `agence_id`…) alors que seule `theme_json` est écrite. |
| **Correction** | Retirer INSERT/UPDATE partout où aucune commande servie n'écrit ; GRANT par colonne sur `compte (theme_json)` ; l'assertion se **calcule** (tables écrites par le code = liste tenue dans le dépôt) au lieu d'une liste figée. |

### I-09 · 🟡 Les vues de lecture prennent le périmètre de N'IMPORTE QUELLE permission

| | |
|---|---|
| **Défaut** | `filtreAgence` réunit les périmètres de toutes les permissions du compte, y compris `SetOwnTheme`. |
| **Cible** | `server/src/index.ts:212-225`, `:227-239` |
| **Famille** | I — lecture |
| **Gravité** | 🟡 faible |
| **Mesure** | `res@ava.test` (seed : `SetOwnTheme` sur PAR, tout le reste en `soi`) lit **les 4 besoins de PAR** ; `rr` : 4 lignes, 0 besoin LYO, `/vues/besoins/<LYO>` → 404 ✅ |
| **Correction** | Un périmètre de lecture explicite (BM-45), jamais déduit d'une préférence d'apparence. |

### I-10 · 🟡 Robustesse : noms hérités du prototype JS

`POST /commandes/constructor|__proto__|toString` → `GARDE « nature d'agence inconnue »` ; `ArchiveObject {"type":"constructor"}` →
`GARDE « utiliser function Object() { [native code] } »`. Aucune écriture, aucun 500, mais une table `Record<string,…>` indexée par
l'entrée sans `Object.hasOwn`. **Cible** `server/src/executer.ts:146-152`, `server/src/agence.ts:352`, `server/src/commandes/admin.ts:78`.
**Correction** : `Object.hasOwn` ou `Map`. **Preuve** `s7_resultats.txt`.

### I-11 · 🟡 `dechiffre_rh` exécutable par `ava_app`, aucune commande ne l'utilise, et la clé n'est jamais posée

`GRANT EXECUTE ON FUNCTION dechiffre_rh(BYTEA) TO ava_app` (`db/migrations/012_schema_v1_complet.sql:1131`) ; `grep cle_rh server/src` → 0.
Le commentaire de 012 (« posé par le serveur au démarrage ») est faux au commit. **Gravité** faible (la clé absente lève). **Correction** : le GRANT vient avec la commande RH.

---

## 2 · Ce qui tient (mesuré)

| Contrôle | Mesure |
|---|---|
| 52 commandes « hors agence » directes | `DROIT`, 0 écriture, contrôle positif PAR passé pour chacune — `s4_resultats.txt` |
| `ArchiveObject` 10 types | société/contact/unité/service → `GARDE utiliser …` ; personne, personne PAR+LYO, candidat, ressource, besoin, projet, action, action portée par société → `DROIT` ; positifs PAR OK — `s6_resultats.txt` |
| `TransferContact` dans les deux sens | `DROIT` (contact LYO → société PAR ; contact PAR → société LYO) ; positif PAR OK |
| Installation (`SetPolicy`, `ManageRefs`, `ManageGroups`) par RR (agence) | `DROIT` ; par `adm` (global) OK |
| K2 / K3 | UUID de compte en en-tête → `DROIT` ; sans en-tête → `DROIT` ; compte désactivé → `DROIT`, 0 écriture, vue 403 |
| Entrées hostiles | tableau/objet en `id` → `GARDE entrée mal typée` ; `referentiel` injecté → `GARDE` ; corps `[1,2]`, `"x"`, `null` → `GARDE` |
| SQL | 15 interpolations `${…}` : toutes sur des noms tirés de constantes, de `pg_catalog` filtré par `^[a-z_]+$`, ou d'une regex `^ref_[a-z_]+$` + existence |
| K1 hors banc | `s8_hors_banc.txt` : 56 POST → 401 ; `/vues/*`, `/tuyau`, `/acquitter`, `/`, `/index.html`, `/%73ante`, `/SANTE`, `/sante/../vues/besoins`, HEAD, OPTIONS → 401 ; `/sante` et `/sante?x=1` → 200 ; **0 table modifiée** (empreinte de toutes les tables) |
| `agence.ts` teste `ArchiveObject` et `TransferContact` en dur | ⚖️ **mécanique**, pas métier (aucun état, aucune politique) — mais c'est **la cause d'I-06** : la sémantique « juger toutes les références » est attachée à un nom de commande au lieu d'être une propriété de la ligne |

---

## ANGLES MORTS

1. **Le VPS** : `verif_serveur.sh` n'a tourné que sur le poste de dev ; K5 n'est pas mesuré là où il compte.
2. **Commandes au-delà des lots servis** : aucune (43 contractées non servies) — rien à sonder, mais les 19 GRANT d'I-08 les précèdent déjà.
3. **Concurrence** : aucune sonde en parallèle (course entre garde et écriture, `nextRef`, compteur).
4. **Périmètres `pole`/`equipe`** : jamais couverts par `aLeDroit` (refus par défaut) — non sondés au-delà de la lecture.
5. **`societe.perimetre.mode = partagee | par_besoins`** : lus, non sondés en hors-agence.
6. **Front** : pas de build (`web/dist` absent, je ne modifie rien) ; le front n'envoie aucun en-tête d'identité (`web/src/contrat.ts:160`) — authentification non livrée (lot 2c).
7. **Binaires suivis** (`*.docx`, `*.zip`) : seuls les noms de fichiers des zip ont été lus pour les secrets.
8. **Journaux du serveur** : non relus pour une fuite de données dans `console.error`.
