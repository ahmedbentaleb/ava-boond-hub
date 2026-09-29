# SECURITE9 — la sécurité mesurée sur `071b7b2`

**Verdict : périmètre par objet tenu (50/50 commandes hors agence → DROIT, 0 écrit ; P-339 rejouée : 0 fuite sur 117 identifiants) et GRANT « table » exact (98 = 24 + 74). ⛔ Quatre familles restent ouvertes : un droit contourné par cascade, des verbes et colonnes accordés en trop (dont UPDATE sur `groupe_permission_perimetre`), une porte P-325 aveugle aux droits par colonne et au rôle de connexion, et 3 routes hors banc qui répondent 500 avant la garde.**

> Base `ava_audit9_b`, serveur `:3902` (banc puis hors banc), preuves `rapport/preuves/securite9/`. Aucun rôle créé ni modifié ; deux `GRANT` de démonstration faits **dans une transaction annulée** (vérifié après).

---

## 1. Tableau de bord

| Point | Mesure | Verdict |
|---|---|---|
| SQL paramétré | 14 sites interpolent un **identifiant** (`${table}`, `${col}`…), tous tirés d'une constante, du catalogue ou d'une regex (`^ref_[a-z_]+$`, `^[a-z_]+$`) ; **0 valeur** interpolée ; 0 concaténation · `09_sql_interpolation.txt` | ✅ |
| Refus avant écriture | 50 cas hors agence, 15 entrées mal typées, 6 cas RES, K3, sans en-tête : **0 écriture métier** (empreinte `count + max(xmin)` de 23 tables) ; la seule trace est `tentative_refusee` (1 par refus) | ✅ · ⛔ sauf S-1 |
| Périmètre `soi` (RES) | temps, absence, document **pour soi** → ok ; **pour autrui** (temps, absence, document personne, document projet) → DROIT, 0 écrit ; `CreateNeed` → DROIT | ✅ 6/6 |
| GRANT `ava_app` ↔ commandes | 98 relations écrivables = **24** tables nommées par le code + **74** `ref_*` (ManageRefs) ; 0 table écrivable sans commande, 0 table écrite sans droit ; P-325 rejouée → **pass** | ✅ par table · ⛔ S-2, S-3 |
| `ava_lecture_agregats` | exactement 7 relations (C4) ; aucun CREATE ; EXECUTE sur 27 fonctions `ava.*` via PUBLIC | ✅ · 🟡 |
| DELETE / TRUNCATE / UPDATE des tables d'ajout | 0 | ✅ |
| Migrations réécrites | `git log --diff-filter=M` : **5 commits, 7 réécritures** (001 ×5, 002 ×2) + 1 renommage `009→010` | 🟠 S-5 |
| Registre des politiques | **202** en base = **202** au registre (201 + 1 en prose), 0 clé d'un côté seulement ; « 173 » est périmé (§E l. 429 le dit encore) ; 53 clés lues par le code, **149 jamais lues** — dont `besoin.unite_couverture`, pourtant du lot 2 | ✅ compte · 🟠 lecture |
| Hors `AVA_MODE=banc` | 22/25 routes → 401 (statiques, `/`, 404, `/tuyau`, `HEAD`, `OPTIONS`, `/vues/*`, `/commandes/*`) ; `/sante` → 200 ; **3 → 500** ; 0 écrit, 0 trace | ⛔ S-4 |
| Lecture en banc | liste et fiche filtrées par agence ; fiche AVFR par identifiant direct → **404** pour un compte PAR | ✅ · ⚠️ S-6 |

---

## 2. Constats

### S-1 🔴 · Un droit contourné par l'effet d'une autre commande
- **Famille** : une commande en exécute une autre sans rejouer sa garde.
- **Étendue, mesurée** : `CloseProject` en `projet.cloture.garde = cascade_cloture_prestations` appelle `ClosePrestation` pour chaque prestation ouverte (`projet.ts:155-167`) en changeant `ctx.commande`, **sans** `exigeAgence` ni droit. STAF, délégué `CloseProject` seul (déclaré), a clôt une prestation **signée** et écrit son `snapshot_marge` ; `ClosePrestation` direct lui est refusé (DROIT). Sites du même motif lus : `effetsSignature` (passage client, pourvu automatique) — effets documentés au contrat, mais sans droit propre. · `supp.json`
- **Correction de construction** : une commande n'appelle jamais un handler ; toute cascade passe par `executer` qui rejoue `exigeAgence` et le droit de la sous-commande, dans la même transaction.
- **Porte** : P-S1 — pour chaque politique à effet « cascade » (lue dans le registre), un compte titulaire de la commande mère sans la fille → DROIT, 0 écrit.

### S-2 🟠 · Des verbes et des colonnes accordés au-delà de ce que le code écrit
- **Famille** : le GRANT se calcule **par table** ; le besoin réel est **par verbe et par colonne**.
- **Étendue, mesurée** (`10_grant_par_verbe.txt`) :
  - **UPDATE accordé, jamais utilisé** sur 6 tables : `groupe_permission_perimetre` ⛔ (une injection change le `perimetre_id` d'une paire existante : agence → global), `temps` (une saisie se réécrit après coup, alors que L4 dit « annuler = archiver »), `absence`, `document`, `qualification`, `qualification_mesure` ;
  - **INSERT accordé, jamais utilisé** sur `politique` (inventer une politique) ;
  - **toutes les colonnes** en UPDATE sur les **19** tables métier qui ont l'UPDATE de table (+ les 74 `ref_*`), alors que `SetPolicy` n'écrit que `valeur` : `ava_app` peut réécrire `valeurs_possibles`, `valeur_defaut`, `type` d'une politique (`politique_garde` ne protège que `cle`). Seule `compte` est taillée à la colonne (`theme_json`).
- **Correction de construction** : le GRANT se **génère** depuis la déclaration des commandes (table × verbe × colonnes écrites), migration par migration ; pas de `GRANT … ON ALL TABLES`.
- **Porte** : P-S2 — égalité stricte `(table, verbe, colonne)` accordés = `(table, verbe, colonne)` écrits par les commandes servies (relevé à l'exécution par le banc, pas par grep).

### S-3 🟠 · P-325 mesure le GRANT à côté
- **Famille** : une porte « calculée » qui garde des exemptions et un mauvais sujet.
- **Étendue, démontrée** (transactions annulées) :
  1. **droit par colonne invisible** : `GRANT UPDATE (nom) ON agence`, `GRANT UPDATE (groupe_id) ON compte_groupe` → la requête (a) de P-325 rend **0 ligne**, `ava_serveur` peut écrire les deux · `08_P325_angle_mort_colonne.txt` ;
  2. **mauvais rôle** : P-325 lit `ava_app` ; le serveur se connecte en `ava_serveur`. `GRANT INSERT ON permission TO ava_serveur` → P-325 voit `f`, le réel est `t` · `08b_P325_role_de_connexion.txt` ;
  3. **tout `ref_*` exempté** d'office, et le côté « code » = tout mot `INSERT INTO x` / `UPDATE x` de `server/src`, y compris le bootstrap de banc (`index.ts:69-109`) et un commentaire.
- **Correction de construction** : mesurer `has_any_column_privilege` pour **chaque rôle qui peut se connecter** (et ses rôles hérités) ; côté code, la liste vient de l'exécution (S-2), pas d'un grep.
- **Porte** : P-S3 — sabotage : les trois GRANT ci-dessus, posés un à un, doivent rougir P-325.

### S-4 🟠 · Hors banc, trois requêtes répondent 500 avant la garde
- **Famille** : la garde unique (`preHandler`, `index.ts:114`) s'exécute **après** l'analyse du corps ; tout échec d'analyse passe par `setErrorHandler`, qui rend 500.
- **Étendue, mesurée** : `POST /commandes/*` avec JSON mal formé → 500 ; `content-type: application/xml` → 500 (415 écrasé) ; corps > 1 Mo → 500 (413 écrasé). La pile complète part dans le journal. 0 écriture, 0 trace. En banc, le même gestionnaire transforme tout 4xx client en 500. · `hors_banc.json`, `serveur_hors_banc.log`
- **Correction de construction** : la garde en `onRequest` (avant l'analyse) ; le gestionnaire d'erreurs rend le statut du client (4xx) et jamais 500 pour une erreur `FST_ERR_CTP_*`.
- **Porte** : P-S4 — serveur sans `AVA_MODE` : toutes les routes déclarées (`app.printRoutes()`) × toutes les méthodes × {corps vide, JSON mal formé, type inconnu, corps trop gros} → 401, sauf `GET /sante`.

### S-5 🟠 · Des migrations publiées réécrites, et rien en base pour le voir
- **Famille** : une migration se reconnaît à son **nom**, pas à son **contenu**.
- **Étendue** : `001_schema.sql` réécrite 5 fois (dont 2 **sur `main`** : f54c73b, 98aae74 le 20/09, après sa création le 19/09), `002_seed_ref.sql` 2 fois ; 001/002 remises à l'identique de `main` par ddffd0a ; `009_unite_agence.sql` renommée `010` (R100, invisible à `--diff-filter=M`), rattrapée par une réécriture **codée en dur** dans `make.sh:162-165`. `ava.schema_migrations` ne porte **aucune empreinte** ; la case 15 ne couvre que les 5 migrations de `main`, pas les 12 de la branche.
- **Correction de construction** : `schema_migrations(filename, sha256)` ; `make migrate` refuse toute migration déjà appliquée dont l'empreinte a changé, et tout fichier renommé.
- **Porte** : P-S5 — modifier un octet d'une migration appliquée, puis `migrate` → refus ; la case 15 étendue à toute migration présente dans un commit publié (main, lot-2, lot-2-brain).

### S-6 ⚠️ à trancher · La lecture s'ouvre par le périmètre de n'importe quelle permission
- **Mesure** (`supp.jsonl`, `t: lecture`) :

| Compte | Liste `/vues/besoins` | Fiche AVFR (id direct) | Fiche PAR |
|---|---|---|---|
| `ia` (PAR) | 3 (les 3 PAR) | 404 ✅ | 200 |
| `res` (PAR, consultant) | 3 | 404 | 200 |
| `eval` (PAR) | 3 | 404 | 200 |
| `sup` (global, lecture seule — MATRICE l. 63) | **1929** (toutes agences) | 200 | 200 |
| `adm` (global, réglages seulement) | **1929** | 200 | 200 |
| `croise` (aucune permission alors) | 0 | 404 | 404 |
| sans en-tête / compte inconnu | 403 | 403 | — |

- **Le fait** : `filtreAgence` (`index.ts:212`) prend l'union des périmètres de **toutes** les permissions du compte. RES lit tous les besoins de son agence parce que `SetOwnTheme` (choisir son thème) lui est donné sur l'agence PAR ; ADM lit toutes les agences par ses droits d'administration. SUP est conforme à la matrice. La MATRICE renvoie la lecture à BM-45, non tranchée.
- **Option recommandée** : une permission de lecture par objet (`LireBesoin`…) portant son périmètre, seule lue par les vues ; `SetOwnTheme` passe en nature `soi` pure (sans périmètre d'agence).
- ⚠️ `listeBesoins` (`vues.ts:245`) lit **tous** les besoins sans filtre : non routée aujourd'hui, prête à fuir dès qu'on la branche.

### S-7 🔴 · Pas de session : l'identité est un e-mail en en-tête (K2)
- En banc, `x-ava-groupe: <e-mail>` suffit à agir sous n'importe quel compte, casse ignorée (`IA@AVA.TEST` → ok) ; l'UUID est refusé. Aucune table de session, aucun jeton. Hors banc, tout est 401 (« authentification non livrée, lot 2c ») : **la garde tient parce que rien n'est servi**.
- **Correction de construction** : D-10 (jeton aléatoire, haché, expirant) avant tout déploiement ouvert ; l'en-tête de banc refusé dès que `AVA_MODE` ≠ `banc`, ce qui est déjà le cas.
- **Porte** : P-S7 — hors banc, un en-tête `x-ava-groupe` valide → 401 (tenu aujourd'hui) ; dès le lot 2c, un e-mail ou un UUID de compte en guise de jeton → 401.

### S-8 🟡 · Fonctions et réglage de clé
- `pol()` n'a pas de `SET search_path` : `v_droits_effectifs` lève « la relation politique n'existe pas » pour tout appelant sans `ava` dans son chemin (mesuré en psql).
- `ava_lecture_agregats` et `ava_app` ont EXECUTE sur les 27 fonctions `ava.*` (PUBLIC), dont `dechiffre_rh` ; inoffensif tant que les colonnes chiffrées restent illisibles. La clé `ava.cle_rh` est « posée par le serveur au démarrage » (012 l. 933) : **aucune ligne de `server/src` ne la pose**.
- **Correction** : `SET search_path = ava, pg_temp` sur toute fonction ; `REVOKE EXECUTE … FROM PUBLIC` puis GRANT par rôle. **Porte** : P-S8 — toute fonction `ava.*` a `proconfig` avec `search_path` et aucun EXECUTE pour PUBLIC.

---

## 3. Données posées (déclarées)
Dans `ava_audit9_b` seulement : `_ops/JEU_ESSAI.sql` ; objets de test en agence PAR ; délégations `ManageGroups` — IA (5 permissions, PAR), STAF (`CloseProject`, PAR), RH (`ConvertCandidateToResource`, **LYO**), CROISE (par P-339) ; `rr@ava.test` désactivé puis réactivé par SQL ; politiques modifiées puis remises au défaut (0 écart relu) ; `GRANT`/`DROP TRIGGER` de démonstration **annulés**.

---

## 4. ANGLES MORTS (des trois brouillons)

| # | Ce que je n'ai pas mesuré | Pourquoi |
|---|---|---|
| 1 | `make test` complet, cliquet (cases 1, 9, 16, 17 exécutées) | interdits ; seules P-325, P-339 et les 41 assertions ont été jouées |
| 2 | K5 : `pg_hba`, `listen_addresses`, mot de passe `ava_serveur` sur le VPS | pas d'accès ; le poste de dev est en `trust` assumé |
| 3 | A4 : `dossier.py` | réécrit `_ops/DOSSIER.html` : interdit dans un clone en lecture |
| 4 | RES `soi` sur **sa** prestation dans une **autre** agence | `soiSurCettePersonne` rend avant tout contrôle d'agence (`agence.ts:660`) ; cas non monté |
| 5 | Concurrence : deux `RecordTimesheet` simultanés (plafond), `nextRef` sous charge | un seul fil d'appels |
| 6 | Sorties comparées champ par champ au contrat | L4 n'a pas de schéma JSON |
| 7 | Les écrans (`web/`) et les portes D ÉCRAN / C GESTE | Playwright non lancé |
| 8 | Les commandes des lots 5.7 / 5.8 (43 contractées, non servies) et leurs tables | hors périmètre servi |
| 9 | L'historique ✅→⏳ complet (F10) | c'est la case 9 du cliquet, non rejouée |
| 10 | Le fuseau : j'ai vu Node lire `Africa/Casablanca` = UTC+1 et Windows UTC+0 ; l'effet sur un serveur en UTC (VPS) n'est pas mesuré | un seul poste |
