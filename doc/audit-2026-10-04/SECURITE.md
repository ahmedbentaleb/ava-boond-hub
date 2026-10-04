**Aucune fuite d'agence (846 identifiants), aucun accès hors banc, GRANT = écritures à l'égalité stricte — mais la chasse trouve 32 réponses 500 et 8 MUR sur 122 entrées bien typées, une cascade qui ignore un droit retiré, un GRANT de production ouvert pour un écrivain de banc, et deux horloges.**

> ⚠️ Numérotation : ce document garde les numéros de travail de son brouillon. Les constats rendus sont dans `CONSTATS.md` (V-179 → V-195), table de correspondance à la fin.


# SECURITE11 — famille I et la chasse · auditeur B (base `ava_audit11_b`, port 4102)

Les murs déclarés tiennent. Les cinq trous ci-dessous sont tous hors des listes que les portes énumèrent. Gravité : 0 🔴 · 4 🟠 · 1 🟡.

---

## 1 · Les contrôles demandés

| Contrôle | Verdict | Mesure | Preuve |
|---|---|---|---|
| SQL paramétré | ✅ | 14 interpolations `${…}` dans du SQL, lues une à une. Toutes viennent d'une constante du code (`DECLARATION`, `TRANSITIONS`, `ARCHIVE`, `PORTEURS_ACTION`), du catalogue (filtré `^[a-z_]+$`) ou d'un `referentiel` vérifié par existence dans `ava`. Toutes les valeurs passent en `$n`. **0 interpolation d'une entrée.** | lecture de `agence.ts:151,160`, `cycle.ts:129,149`, `kernel.ts:163,205`, `admin.ts:31,63,83,110,184,207,227,232`, `besoin.ts:251` |
| Refus avant écriture | ✅ | P-339 : 811 refus hors agence, **0 table modifiée**. Tout refus fait ROLLBACK. ⚠️ L'acceptation à tort de `depuis_signature` est une écriture, mais elle n'a rien d'un refus : CONFORMITE11 C-2. | `grille11/p339_detail.json` |
| GRANT par colonne contre les écritures réelles | ✅ à l'égalité · 🟠 sur ce qui est accordé (I-4) | `ava_app` = `ava_serveur` = **412 privilèges d'écriture** ; `ava_lecture_agregats` = 0. Contre l'extraction `outils/ecritures_serveur.mjs` : 0 INSERT accordé non écrit, 0 écrit non accordé, 0 UPDATE accordé non écrit, 0 écrit non accordé. ⚠️ L'égalité a été obtenue en **accordant** `UPDATE (personne_id) ON compte` (migration 025) à un écrivain de banc. | `securite11/grant_contre_ecritures.txt`, `scripts/priv_*.txt` |
| Lectures par groupe et par agence | ✅ | ADM, RES, CROISE, CROISE_LYO (sans `LireBesoins`) → 403 sur la liste et la fiche. Les 6 groupes d'agence voient PAR (157 lignes), et la fiche LYO leur rend 404. SUP global voit les deux. Sans en-tête → 403, y compris `/tuyau` et `/acquitter`, désormais gardés par `LireBesoins`. Une surcharge restrictive `LireBesoins/PAR` → 403. | `securite11/lectures_banc.txt`, `compte_surcharge.txt` |
| Hors `AVA_MODE=banc` | ✅ | 29 sondes, toutes en 401 sauf `/sante`. JSON mal formé, `text/plain`, form-urlencoded, 1,1 Mo, `[1,2]`, `null` → 401. `POST /sante` mal formé ou de 1,1 Mo → 400. **0 table modifiée.** | `securite11/hors_banc.txt` |
| Routes servies hors `LECTURES` | ✅ | `LECTURES` liste maintenant `/tuyau` et `/acquitter`. P-361 (routes = `LECTURES` ∪ santé ∪ commandes) est **verte** contre :4102 mais **⏳** (GRILLE11 G-1). | `grille11/porte_attente_routes.txt` |
| Noms hérités d'`Object.prototype` | ✅ pour les commandes · 🟡 ailleurs (I-2) | 85 sondes (commande, `type`, `cle`, `referentiel`, `permission`, `groupe`, clé de thème, clé d'entrée, en-tête d'identité, fiche) : **0 × 500, 0 acceptée**. Les commandes rendent `INTROUVABLE` (`Object.hasOwn`). | `securite11/prototype.txt` |
| Sorties de commande sous `partagee` | ✅ | `UpdateCompany`, `UpdateContact`, `CreateContact`, `CreateAction` et `RequalifyCompany` sur des objets de LYO : chaque sortie rend la ligne de l'objet **permis**, et rien d'autre de LYO (inventaire des UUID de la sortie : seul l'objet visé, ou sa société, apparaît). `vueRessource` masque le coût sans `UpdateResourceCost` sur l'agence de la ressource. | `securite11/sorties_partagee_et_par_besoins.txt` |
| `compte_surcharge` | ✅ sur la commande et la lecture · 🟠 en cascade (I-3) | Surcharge `CreateProjectFromNeed/PAR` sur `ia@` : droits effectifs = 0, appel direct → `DROIT`, lecture surchargée → 403. **Mais la cascade passe.** | `securite11/compte_surcharge.txt` |
| Comptes | ✅ | Le serveur tourne en `ava_serveur`. Compte désactivé : `DROIT`, 0 événement. UUID de compte en en-tête : refusé. | `securite11/k2_k3_c2.txt` |

---

## 2 · La chasse — ce que les portes énumératives ne couvrent pas

Les portes énumèrent ce qui est **déclaré** : `HANDLERS`/`DECLARATION`/`CORRESPONDANCE` (P-339), le registre (P-355 → P-358), les écritures extraites (P-325), `LECTURES` (P-349, P-361). Chaque trou ci-dessous est hors de ces listes.

### I-1 🟠 (élevé) — Une entrée bien typée mais hors domaine sort encore en 500 ou en MUR (V-169, non codé)
- **Famille** : `typeRefuse` contrôle la **forme** et la base contrôle le **domaine** ; `pgMur` (`kernel.ts`) ne traduit toujours que `22P02`, `23505`, `23514`, `23503` et « MUR M- ». Rien n'a changé dans `declaration.ts` ni dans `kernel.ts` sur ce point depuis le 10e tour.
- **Étendue mesurée** — sonde automatique : pour chaque commande, sur toutes les clés `valeur` de `DECLARATION`, une valeur de la bonne forme mais invalide (date `2026-02-30`, décimal à 30 chiffres, code `zz_inconnu`, liste `[1]`). Script `securite11/scripts/t_fuzz.mjs`, sortie `fuzz_valeurs.txt` / `.json` :
  **122 sondes · 32 × 500 · 8 × MUR · 10 acceptées.**
  - 500 dans **13 commandes** : CreatePerson, UpdateResourceCost, RecordQualification, CreateNeed, DeclareCVShared, RecordClientDecision, CreatePrestation, SignPrestation, ClosePrestation, RecordTimesheet, AdjustTimesheetAfterClose, RecordAbsence, CreateAction.
  - MUR sur **5 clés de 5 commandes** : `UpdateCompany.pays`, `UpdateCandidate.disponibilite_code`, `UpdateResource.disponibilite_code`, `CreateProjectFromNeed.type`, `CreatePrestation.cjm_devise`.
  - Sondes manuelles (`conformite11/sondes_ciblees.txt` H3) : trigger de couverture → 500, `mesures=[1]` → 500, `taux=1e9` → 500, `date='2026-99-99'` → 500, `nb_postes_vises=0` → MUR, compétence inconnue → MUR.
  - Valeurs invalides **écrites** : `profil_candidat.provenance = 'zz_inconnu'` (2 lignes, aucune clé étrangère, aucun `exigeRef`) et `prestation.taux_change = 123456789012345678901234567890`.
- **Correction de construction** : la déclaration porte le **domaine** de chaque `valeur` : `ref:` pour un code, précision lue dans `information_schema` pour un décimal, aller-retour calendrier pour une date, schéma des éléments pour une liste. `remplirValeurs` refuse `GARDE` avant le handler. `pgMur` traduit **toutes** les classes `22`, `23`, `P0` : jamais 500.
- **Porte** : `t_fuzz.mjs` sur **toutes** les clés `valeur` de `DECLARATION`, pour 0 × 500, 0 × MUR et 0 valeur hors domaine écrite. Aujourd'hui : 42 rouges (40 + 2 écrites).

### I-2 🟡 — Des tables indexées par une entrée héritent encore d'`Object.prototype` (V-170, à moitié)
- **Étendue mesurée** : les commandes sont corrigées (10/10 → `INTROUVABLE`). Mais `ArchiveObject {type: "constructor"}` → `GARDE utiliser function Object() { [native code] }` (10/10 noms) : `ligne.refusType[type]` (`agence.ts:340`) est un objet ordinaire. Le refus tombe **par hasard** (la valeur héritée est vraie), et le message renvoie du texte du moteur. `ARCHIVE[type]` (`admin.ts:79`) a le même défaut, masqué par celui d'avant.
- **Correction** : toute table indexée par une entrée devient une `Map`, ou un `Object.hasOwn` dans une seule fonction `lire(table, cle)`.
- **Porte** : P-360 étendue de la route aux **valeurs** : chaque membre d'`Object.prototype` comme `type`, `cle`, `referentiel`, `permission`, `groupe` et clé d'entrée doit rendre un message qui ne contient ni `function` ni `[object`.

### I-3 🟠 (élevé) — Une cascade ignore un droit retiré : `RecordClientDecision → CreateProjectFromNeed` ne passe pas par la garde de sa fille
- **Famille** : D-43 dit « la fille passe par sa garde ». `executerDans` (`executer.ts:244`) l'exempte pourtant **par son nom** quand la mère est `RecordClientDecision` (C-1 de CONFORMITE11). Un droit retiré à l'acteur (surcharge restrictive, ou `ManageGroups` qui retire `CreateProjectFromNeed` au groupe IA posé par 025) ne vaut donc pas en cascade.
- **Étendue mesurée** (`securite11/compte_surcharge.txt`) : `ia@` avec la surcharge `CreateProjectFromNeed/PAR` a des droits effectifs à **0**. L'appel direct `CreateProjectFromNeed` rend `DROIT`. **`RecordClientDecision retenu` sous `automatique_au_retenu` rend `ok`, `ProjectCreatedFromNeed`, 1 projet créé.** 1 cascade sur les 10 de `CASCADES`. P-339 ne joue pas les cascades sous un droit retiré, et P-349 ne joue aucune surcharge.
- **Correction de construction** : `executerDans` passe **toujours** par `exigeAgence` ; « qui a la mère a la fille » (D-48) reste un fait du seed, vérifié par une porte, jamais une exemption du noyau. Si la décision est que la politique crée le projet au nom du système, cela se **déclare** (`CASCADES: { …, acteur: "systeme" }`) et c'est tracé.
- **Porte** : pour chaque ligne de `CASCADES`, l'acteur de la mère privé du droit de la fille (surcharge restrictive) joue la mère : refus de la mère, ou issue déclarée. Aujourd'hui : 1 rouge.

### I-4 🟠 — Des écritures hors commande, et un GRANT de production ouvert pour l'une d'elles (V-170, à moitié)
- **Famille** : P-325 voit maintenant `index.ts` (plus aucune exclusion), mais il a **aligné le GRANT sur l'écrivain** au lieu de retirer l'écrivain.

| Écrivain | Ce qu'il écrit | Mesure |
|---|---|---|
| `assurerBancRes` (`index.ts:72`, appelé au démarrage) | `INSERT personne`, `INSERT profil_ressource`, `UPDATE compte SET personne_id`, sans événement | La fixture fait déjà ce geste (D-11). **025 accorde `UPDATE (personne_id) ON compte TO ava_app`** pour lui (« P-325 : le démarrage banc écrit compte.personne_id »). Une migration joue en production : le rôle applicatif de production peut donc réécrire `compte.personne_id`, c'est-à-dire le lien qui fonde la règle « soi » (D-33), alors qu'**aucune commande** n'écrit cette colonne. |
| `tracerRefus` (banc) | `tentative_refusee` avec le **corps entier** | 2 requêtes **sans en-tête** → 2 lignes ; la plus grosse entrée fait **1 000 011 octets**. 459 lignes après mes sondes. |
| `noterLecture` (`kernel.ts:7`) | `os.tmpdir()/ava-carte-politiques.jsonl` | Fichier **partagé par tous les serveurs de banc du poste** : **26,3 Mo, 413 070 lignes**. P-351 le relit à partir d'un décalage, et peut verdir sur la ligne d'un autre serveur. |
| Migrations de données 023, 024 | `UPDATE ref_statut_commercial SET categorie`, `UPDATE ref_etat_candidat SET categorie = 'complet' WHERE code = 'complete'`, avec `tg_garde` **désactivé** le temps de l'UPDATE | aucun `RefChanged`. La sélection se fait par littéral de code. |

- **Correction de construction** : `assurerBancRes` disparaît (la fixture le fait) et 025 révoque ce qu'elle a accordé. Un registre unique des écrivains (code, `pg_proc`, migrations) où un écrivain hors commande est **interdit**, pas accordé. Une migration de données émet `DataMigrated`. `tracerRefus` ne trace que le refus d'un compte résolu, avec une entrée tronquée. La carte D-42 est nommée par processus.
- **Porte** : P-325 inversée : tout privilège d'écriture accordé doit être écrit par une **commande** de `HANDLERS` (hors `index.ts`). Aujourd'hui : 1 rouge (`compte.personne_id`).

### I-5 🟠 — Deux horloges pour « aujourd'hui » (V-167, à moitié)
- **Famille** : 023 pose `aujourdhui(agence)` (fuseau de l'agence) et l'utilise à 7 endroits du serveur ainsi que dans les vues D-53. Il reste **2 sites `CURRENT_DATE`**, c'est-à-dire le fuseau de **session** de la base : `CancelPrestation.date_annulation` (`projet.ts:555`) et `RecordQualification.date` (`identite.ts:445`).
- **Étendue mesurée** (`securite11/deux_horloges.txt`) : la base a été réglée le temps de la sonde, serveur redémarré, puis remise (`Africa/Casablanca`).
  - Sous `Etc/GMT+12`, au **même instant** (08:54 UTC) : `date_cloture = 2026-10-04` et `suivi.date = 2026-10-04` (agence) ; mais `date_annulation = 2026-10-03` et `qualification.date = 2026-10-03` (session).
  - **Sous `Pacific/Kiritimati` (UTC+14), rejouée à 10:01 UTC** (`deux_horloges_utc14.txt`) : `date_cloture = 2026-10-04` et `suivi.date = 2026-10-04`, mais **`date_annulation = 2026-10-05` et `qualification.date = 2026-10-05`**, c'est-à-dire le lendemain. À 08:54 UTC, les deux dates coïncidaient encore.
  - Sur ce poste, la session est `Africa/Casablanca` (UTC+0) et PAR est `Europe/Paris` (UTC+2). **Chaque soir entre 22 h et minuit (Casablanca)**, une annulation et une qualification sont datées de la veille par rapport à la clôture faite au même instant.
- **Correction de construction** : une seule fonction de date, `aujourdhui(agence)`. `CURRENT_DATE` et `now()::date` sont interdits dans `server/src`, et le pool pose `TimeZone=UTC` pour que rien ne dépende de la session.
- **Porte** : (a) AST/grep sur `server/src` : 0 `CURRENT_DATE`, 0 `new Date(` dans les commandes ; (b) le banc rejoue les positifs avec la base à UTC−12 **et** UTC+14, et toute date écrite = `aujourdhui(agence de l'objet)`.

---

## 3 · ANGLES MORTS (communs aux trois brouillons)

| Angle mort | Pourquoi | Ce qu'il faudrait |
|---|---|---|
| `make test` complet et le cliquet | interdits au poste ; Playwright (geste, écran) non joué ; cases 1, 2, 14, 16, 17, 19 non recalculées | les jouer sur une base dédiée |
| La CI GitHub | non observée ; G-2 est déduit de `ci.yml` et mesuré dans un clone neuf | lire le dernier run de `lot-2` |
| La base qui a **vécu** (`ava`) | hors périmètre ; la case 18 n'est prouvée que sur ma base neuve, où elle est vraie par construction | `make.sh empreintes` sur la base de travail (023 a été réécrite après sa création, D3) |
| K5, authentification réelle | contrôle de VPS ; l'authentification arrive au lot 2c | audit du VPS, puis K1 → K3 refaits au lot 2c |
| Charge et concurrence | aucune mesure de deux transactions simultanées | deux clients parallèles sur les gardes d'unicité |
| Le registre exécutable ligne à ligne | confié à un autre vérificateur ; je n'en cite que S-PM3, S-SD2, S-CH1/2, S-NE | — |
| **Ce que j'ai posé en base** (`ava_audit11_b`) | — | Base reconstruite une fois (après A2 : `DROP TRIGGER tg_m10`). Puis : P-339 (qui délègue à CROISE et CROISE_LYO) avant toute sonde ; 57 délégations à CROISE sur PAR (`t_grant`) ; 1 délégation SUP/SetOwnTheme sur LYO (cas nominal de `ManageGroups`) ; `ref_statut_commercial.zz_prospect_chaud` créé (catégorie prospect, ordre 0) puis **désactivé** (pas de suppression possible par commande) ; `ordre` du client mis à 7 puis remis à 2, `ordre` des 75 `ref_*` inversé puis remis ; 2 `provenance = zz_inconnu` ; 1 `taux_change` à 30 chiffres ; `theme_json` de `croise@` = valeurs non servies ; des surcharges `compte_surcharge` posées puis retirées (0 restante) ; un `INSERT prestation` direct en `signee`/USD pour H15 ; le fuseau de la base passé à `Etc/GMT+12`, puis à `Pacific/Kiritimati` (deux fois : 08:54 et 10:01 UTC), puis **remis** à `Africa/Casablanca` ; serveur relancé une fois sans `AVA_MODE`. Toutes les politiques variées sont remises : **0 politique ≠ défaut** en fin d'audit. Une de mes sondes (`t_cibles11.mjs`) s'est arrêtée sur M-14 (mon `UPDATE` de banc sur une prestation engagée) ; `change.mode` est resté à `taux_saisi` quelques minutes, puis a été remis par `SetPolicy`. Aucune sonde n'a tourné en parallèle de P-339. |
