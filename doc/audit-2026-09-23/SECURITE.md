# SECURITE3 — famille I · lot 2 · commit `416a7a3`

**Deux failles exploitables, l'une sans aucun en-tête.** Le reste de la famille I est propre.

| Sujet | Verdict | Mesure |
|---|---|---|
| Requêtes paramétrées — serveur | ✅ | 0 concaténation de valeur ; 13 identifiants interpolés, **tous** issus d'une liste blanche ou validés |
| Requêtes paramétrées — `test/contrat` | ✅ | 3 interpolations d'identifiant, aucune de valeur |
| Refus **avant** toute écriture | ✅ | 0 écriture métier sur **135+ refus** sondés ; `BEGIN` → garde → mutation → `emit` → `COMMIT` |
| **Périmètre par objet** | 🔴 | **3 commandes sur 55** mutent un objet d'une autre agence |
| GRANT réels des rôles | ✅ | `ava_app` : 0 DELETE/TRUNCATE/UPDATE interdit · `ava_lecture_agregats` : exactement 7 relations |
| `pg_hba.conf` | 🟠 | 6 règles `trust` sur ce poste ; **rien ne mesure celui d'un serveur** |
| Secrets | ✅ | 0 secret dans le dépôt ; la CI les lit dans les secrets GitHub |
| Front (HTML injecté, SVG) | ✅ | 0 `innerHTML`, 0 `dangerouslySetInnerHTML`, 2 `<svg>` statiques, 0 `eval` |
| **Hors `AVA_MODE=banc`** | 🟠 | 401 sur **toutes** les commandes, 0 écriture métier — mais **1 écriture anonyme par POST**, et **les vues servent tout** |

---

## I-1 · Requêtes paramétrées

**Serveur.** Aucune valeur n'entre dans une chaîne SQL. Les **13 interpolations d'identifiant** ont été lues une par une :

| Endroit | Interpolé | D'où il vient |
|---|---|---|
| `admin.ts:39` | `${fk.tbl}`, `${fk.col}` | `pg_constraint`, **puis validés** `/^[a-z_]+$/` (`admin.ts:35`) |
| `admin.ts:50` | `${table}` | table `AGENCE_PORTEUR`, 4 entrées fixes |
| `admin.ts:79` | `${col}` | `PORTEURS_ACTION`, 6 entrées `as const` |
| `admin.ts:99,127` | `${spec.table}` | table `ARCHIVE`, 10 entrées fixes |
| `admin.ts:199,234,239` | `${referentiel}` | **validé** `/^ref_[a-z_]+$/` **et** vérifié dans `pg_class` |
| `besoin.ts:240` | `${clause}` | ternaire à **deux branches littérales** sur une valeur de politique |
| `cycle.ts:125,145` | `${table}`, `${tableObjet}` | constantes `TRANSITIONS` / appels littéraux |
| `kernel.ts:124,166` | `${table}` | appels littéraux uniquement (grep : 1 seul appel avec variable, `vues.ts:110`, valeur interne) |

⭐ **Verdict : aucune injection possible.** Le seul motif à surveiller est `ManageRefs`, qui construit un `INSERT` sur un nom de table fourni par l'admin — mais la double validation (forme + existence) le referme, et l'admin est déjà ADM.

**`test/contrat`.** `db.ts:48`, `monde.ts:39`, `v011-lignes.ts:118` interpolent un nom de table de banc ; `db.ts` passe par une fonction `identifiant()`. Aucune valeur concaténée.

**V-051 — `correctifs.test.ts` ne vise plus la base « ava » en dur : ✅.** `test/contrat/correctifs.test.ts:74` lit `DATABASE_URL: databaseUrl`. ⭐ Le fichier contient même le contre-test : `const marque = "postgres:" + "ava"` (l.669), écrit en deux morceaux pour qu'un grep sur le dépôt ne le confonde pas avec une URL en dur.

---

## I-2 · Refus avant écriture

Mesuré à chaque appel en encadrant par `SELECT count(*) FROM evenement_metier`.

| Sonde | Refus | Écriture métier |
|---|---|---|
| 12 commandes sur un objet d'une autre agence | 9 `DROIT` | **0** |
| 7 commandes hors mode banc | 7 `DROIT`/401 | **0** (`evenement_metier` 99→99, `societe` 2589→2589) |
| Compte désactivé | `DROIT` | **0** (100→100) |
| ~35 refus de garde du banc de conformité | `GARDE`/`ETAT`/`INTROUVABLE` | **0** |

`executer.ts:189` fait `ROLLBACK` avant de tracer. ⭐ **L'ordre tient.**

---

## I-3 · Le périmètre par objet — commande par commande

Protocole : objets semés dans l'agence **AVFR** (`f0000000-…-0001`), sessions de banc toutes dans l'agence **PAR**, périmètres des groupes tous `agence/PAR` (sauf ADM et SUP en `global`, RES en `soi`). **Contrôle positif obligatoire** : les mêmes commandes rejouées sur un objet PAR.

| Commande | Objet **AVFR** | Objet **PAR** (contrôle positif) | Verdict |
|---|---|---|---|
| `WithdrawPositioning` | `DROIT` · 0 écriture | **OK** `PositioningWithdrawn` | ✅ **fermé** |
| `RecordQualification` | `DROIT` · 0 écriture | **OK** `QualificationRecorded` | ✅ **fermé** |
| `UploadDocument` | `DROIT` · 0 écriture | **OK** `DocumentUploaded` | ✅ **fermé** |
| `CreateAction` | `DROIT` · 0 écriture | **OK** `ActionCreated` | ✅ **fermé** |
| `ArchiveObject` | `DROIT` · 0 écriture | `GARDE « le besoin n'est pas fermé »` *(refus **différent** : le périmètre a été franchi, la garde a parlé)* | ✅ **fermé** |
| `UpdateNeed` | `DROIT` | **OK** | ✅ |
| `UpdateProject` | `DROIT` (avec DP) | **OK** (avec DP) | ✅ |
| `UpdateCandidate` | `DROIT` | **OK** | ✅ |
| `UpdateResource` | `DROIT` | **OK** | ✅ |
| **`CreateUnit`** | **OK** — unité créée avec `agence_id = AVFR` | OK | 🔴 **percé** |
| **`UpdateUnit`** | **OK** — unité AVFR renommée | OK | 🔴 **percé** |
| **`ArchiveService`** | **OK** — unité AVFR archivée | OK | 🔴 **percé** |

⭐ **Les cinq trous du 2ᵉ audit sont fermés, et prouvés fermés** — un `DROIT` qui serait le symptôme d'une commande cassée aurait été démasqué par le contrôle positif.

---

**I-01 · Les vues servent la base entière à un appelant anonyme, dans tous les modes.**
Cible **CODE** · famille **I / K1** · **critique** (donnée servie sans droit) ·
preuve : serveur démarré **sans `AVA_MODE`**, aucun en-tête —
```
GET /vues/besoins → HTTP 200
{"titre":"Besoins","compte":"1932","lignes":[{"cellules":[{"libelle":"Analyste Risques de marché"},{"libelle":"Société 280"},{"libelle":"ferme"}]},…
```
**1932 besoins**, avec le titre du besoin, le **nom de la société cliente** et l'état, servis sans authentification ·
reproduire :
```bash
curl -s http://127.0.0.1:3302/vues/besoins | head -c 400
curl -s http://127.0.0.1:3302/vues/besoins/<uuid>
```
· prétend : K1, « hors `AVA_MODE=banc`, **aucun** appel n'écrit tant que le lot 2c n'est pas livré » — et, plus largement, `index.ts:234` ferme `POST /commandes/:nom` mais **rien** ne ferme les vues ·
mesure : `index.ts:164` et `index.ts:200` ne lisent ni `modeBanc()`, ni `x-ava-groupe`, ni le périmètre. Elles interrogent `besoin` **sans filtre d'agence**. Un porte-carnet d'adresses complet du CRM, en GET, sans en-tête ·
correction : passer les vues par le même garde que les commandes — refus 401 hors banc, et filtre de périmètre en banc.

---

**I-02 · Un compte de l'agence PAR crée, renomme et archive une unité de l'agence AVFR.**
Cible **CODE** · famille **I / K4** · **critique** (mur percé) ·
preuve : `securite3/perimetre_objet.txt` —
```
[IA] CreateUnit     evts:0->1  {"ok":true,…,"agence_id":"f0000000-0000-0000-0000-000000000001"}
[IA] UpdateUnit     evts:1->2  {"ok":true,…,"nom":"Renomme par PAR","agence_id":"f0000000-…-0001"}
[IA] ArchiveService evts:12->13 {"ok":true,…,"UnitArchived"}
```
· reproduire : serveur de banc, unité interne `aa000000-…-0003` en agence AVFR, puis
```bash
curl -s -X POST http://127.0.0.1:3302/commandes/UpdateUnit -H 'content-type: application/json' -H 'x-ava-groupe: IA' -d '{"id":"aa000000-0000-4000-8000-000000000003","nom":"Renomme par PAR"}'
```
· prétend : `MATRICE_DROITS_v1.md` §procedure étape 4 et grille **K4**, « le périmètre se juge **sur l'objet visé** » ·
mesure : `server/src/commandes/crm.ts` est le **seul** des cinq fichiers de commandes sans un seul appel à `exigeObjet` —
```bash
grep -c exigeObjet server/src/commandes/*.ts
# admin.ts:2  besoin.ts:5  crm.ts:0  identite.ts:9  projet.ts:6
```
Or `unite_organisation` porte `agence_id`, et `CreateUnit` l'accepte **en entrée** (`crm.ts:136`, `:172`). La garde M-12 vérifie la cohérence société/agence du **parent**, pas le droit de l'appelant ·
correction : dans `CreateUnit`, `exigeObjet(ctx, agenceId ?? ctx.compte.agence_id)` ; dans `UpdateUnit` et `ArchiveService`, `exigeObjet(ctx, avant.agence_id)`. ⭐ **Mieux** : la résolution de l'agence de l'objet dans `executerCommande`, d'après une table commande → table → colonne, plutôt que 55 appels à ne pas oublier — c'était déjà la correction proposée pour H-1, et elle n'a été appliquée que commande par commande.

---

**I-03 · Hors mode banc, un POST anonyme écrit une ligne dans `tentative_refusee`.**
Cible **CODE** · famille **I / K1** · **elevee** (faille exploitable : remplissage de base sans authentification) ·
preuve : `securite3/hors_banc.txt` —
```
tentative_refusee : 63 -> 123   (60 POST anonymes)
commande      | code  | message                              | anonyme
CreateCompany | DROIT | authentification non livrée (lot 2c) | t
```
· reproduire :
```bash
for i in $(seq 1 60); do curl -s -o /dev/null -X POST http://127.0.0.1:3302/commandes/CreateCompany -H 'content-type: application/json' -d '{}'; done
psql -Atc "SELECT count(*) FROM ava.tentative_refusee"
```
· prétend : K1, « toute commande → refus, **0 ligne écrite** » ·
mesure : `index.ts:236` appelle `refuserAuthentificationNonLivree(pool, nom, entree)` **avant** de rendre le 401 ; `executer.ts:129` insère la commande, le message, **et le corps de la requête** (`entree` en jsonb) sans aucun contrôle. Aucun plafond, aucune limite de débit, aucun compte associé (`auteur_compte_id IS NULL`). Le corps étant recopié tel quel, un POST de 1 Mo écrit 1 Mo ·
correction : hors `AVA_MODE=banc`, rendre le 401 sans tracer. La trace d'un refus n'a de sens qu'après identification de l'appelant — c'est justement ce que le lot 2c apportera.

---

**I-04 · La session est un nom de groupe dans un en-tête, et l'auteur enregistré n'est pas l'acteur.**
Cible **CODE** · famille **I / K2** · **moyenne** *(attendu du lot 2c, mais il faut le nommer)* ·
preuve : `securite3/K2_K3.txt` — aucune table `%session%` dans le schéma ; `compteDuGroupe` (`executer.ts:64-79`) fait
```sql
… WHERE g.nom = $1 AND c.actif ORDER BY c.email LIMIT 1
```
· reproduire : deux appels `x-ava-groupe: ADM`, puis `SELECT auteur_compte_id FROM ava.evenement_metier` ·
prétend : D-10, « le jeton est aléatoire, haché, expirant » ·
mesure : ✅ **K2 tient à la lettre** — l'UUID d'un compte envoyé comme `x-ava-session` rend `DROIT « session absente »`, envoyé comme `x-ava-groupe` rend `DROIT « groupe inconnu »`. ✅ **K3 tient** — un compte désactivé ne fait rien, 0 écriture. ⚠️ Mais `evenement_metier.auteur_compte_id` porte **le premier compte actif du groupe par ordre alphabétique d'email** : l'historique nomme un compte qui n'a pas agi. Le jour où plusieurs comptes partagent un groupe, la trace est fausse ·
correction : le jeton de session du lot 2c — et, d'ici là, refuser si le groupe compte plus d'un compte actif, plutôt que d'en choisir un.

---

**I-05 · Rien dans le dépôt ne mesure le `pg_hba` d'un serveur.**
Cible **CODE** · famille **I / K5** · **moyenne** ·
preuve : `grille3/K5.txt` — 6 règles, `auth_method = trust`, dont `host all all 127.0.0.1` ·
reproduire :
```bash
psql -c "SELECT line_number, type, user_name, address, auth_method FROM pg_hba_file_rules;"
```
· prétend : K5, « 0 `trust` sur un serveur » ·
mesure : sur ce poste de dev, c'est toléré. ⛔ Mais ce contrôle n'est ni dans le cliquet (12 cases, aucune ne lit `pg_hba_file_rules`), ni dans les assertions L7, ni dans la CI : **il ne tournera jamais sans un auditeur**. ⭐ Le `docker-compose.yml` est propre de son côté — `POSTGRES_PASSWORD: ${POSTGRES_PASSWORD:?…}`, pas de `POSTGRES_HOST_AUTH_METHOD=trust` ·
correction : une case de cliquet conditionnée à l'environnement.

---

**I-06 · bien fait (bonne).**

| Sujet | Mesure |
|---|---|
| **GRANT `ava_app`** | `has_table_privilege(…,'DELETE'/'TRUNCATE')` sur **toutes** les relations du schéma → **0 ligne** ; UPDATE sur `evenement_metier`, `snapshot_marge`, `prestation_version` → **0 ligne** |
| **GRANT `ava_lecture_agregats`** | `has_any_column_privilege` sur **toutes** les relations → **exactement 7** : `politique`, `ref_devise`, `ref_pays` et les 4 vues `v_*_par_devise`. La fuite V-001 par `v_conditions_du_jour` est refermée |
| **Le serveur n'est pas superutilisateur** | `pg_stat_activity.usename = ava_serveur` pendant une requête ; `index.ts:306-315` **refuse de démarrer** si `rolsuper` |
| **Rôles** | `ava_app`, `ava_lecture_agregats`, `ava_migration`, `ava_serveur` : aucun `rolsuper`, `rolcreaterole`, `rolcreatedb`, `rolbypassrls` |
| **Secrets** | 0 mot de passe, 0 clé, 0 `.env` suivi. `ci.yml` lit `secrets.CI_POSTGRES_PASSWORD` / `CI_SERVEUR_PASSWORD` et **vérifie leur présence** avant de continuer (l.58-67) |
| **Front** | 0 `innerHTML`/`dangerouslySetInnerHTML`/`insertAdjacentHTML`/`document.write`/`eval`/`new Function` dans `web/src/`. Les 2 `<svg>` de `rendu.tsx` sont **statiques** (chemins écrits en dur, `aria-hidden`), aucun `dangerouslySetInnerHTML` de SVG, aucun `srcDoc`. Les `href` viennent du serveur (`ligne.href`), jamais de l'utilisateur |
| **Hors banc, les commandes** | **7/7 refusées**, HTTP 401, corps `{"ok":false,"code":"DROIT","message":"authentification non livrée (lot 2c)"}`, **0 écriture métier** — avec en-tête, sans en-tête, avec `x-ava-session`, avec les deux |

---

## Ce que je n'ai pas pu sonder — et pourquoi

| Angle | Raison |
|---|---|
| Le comportement du `pg_hba` de production | aucun serveur de production dans mon périmètre |
| La CI réellement verte | pas de droit de pousser, et les secrets ne sont pas dans le dépôt |
| Les espèces C GESTE et D ÉCRAN | `make.sh` et `cliquet.sh` interdits par le mandat ; Playwright non lancé |
| Le périmètre `pole` / `equipe` | aucun périmètre de ce type au seed : `aLeDroit` ne les couvre jamais (`droits.ts:32` exige `agence_id`), ce qui est **restrictif**, donc sûr — mais non exercé |
| La surcharge nominative `compte_surcharge` | aucune ligne au seed ; `droits.surcharge_restrictive` n'a donc jamais été mise à l'épreuve sur un cas réel |
