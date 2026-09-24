# SECURITE5 — SQL, périmètre par objet, accès, secrets, front

**Cinquième audit · commit `b6ff087`.** Base `ava_audit5_b`, port `3502`, clone de lecture
**intact** (`git status` vide en fin de passe ; `_ops/DOSSIER.html`, réécrit par `dossier.py`, a
été restauré).

Preuves : `securite5/perimetre5.txt` (46 sondes hors agence + 6 témoins) ·
`refus_acces.txt` (refus avant écriture, K2, K3) · `hors_banc.txt` (K1 / V-078, 13 routes) ·
`vues_sante.txt` (V-102, V-103) · `verif_serveur.txt` (K5) · `sql_secrets.txt` ·
`conformite5/decisions_litterales.txt`.

## VERDICT

| | |
|---|---|
| 🔴 critique | **0** |
| 🟠 elevee | **1** — **I-11** *(l'agence nulle : trois commandes écrivent hors périmètre)* |
| 🟡 moyenne | **5** — I-12 · I-13 · I-14 · I-15 · I-16 |
| ✅ bonne | SQL paramétré · refus avant écriture · GRANT réels · K1 / V-078 · `/sante` · secrets · front · **46 sondes de périmètre sur 42 commandes** |

---

## 1 · SQL paramétré

**Les valeurs passent toujours en `$n`.**
`grep -rnE '(SELECT|INSERT|UPDATE|WHERE|FROM)[^"'"'"']*" *\+' server/src` → **vide** : aucune
concaténation de valeur, nulle part.

**15 requêtes interpolent un identifiant** (`${table}`, `${colonne}`, `${clause}`). Remontées une
par une jusqu'à leur source :

| Emplacement | Origine | Barrière | Atteignable depuis l'entrée ? |
|---|---|---|---|
| `agence.ts:170`, `:179` | table littérale `CORRESPONDANCE` | **`ident()` `/^[a-z_]+$/`** | non |
| `admin.ts:31` | `pg_constraint` (catalogue) | `/^[a-z_]+$/` relu | non |
| `admin.ts:63` | `PORTEURS_ACTION`, const | énumération fermée | non |
| `admin.ts:88`, `:115` | `ARCHIVE`, map const | map fermée | non |
| `admin.ts:187`, `:210`, `:230`, `:235` | ⭐ **l'entrée `referentiel`** | **`/^ref_[a-z_]+$/` + existence dans `pg_class` schéma `ava`** | **oui, et c'est le mieux gardé des quinze** |
| `besoin.ts:236` | une des 2 clauses littérales choisies par `positionnement.unicite` | littéraux | non |
| `cycle.ts:125`, `:145` | `TRANSITIONS[].ref` / appels littéraux | **aucune** | non |
| `kernel.ts:124`, `:166` | appels littéraux | **aucune** | non |

⭐ **Aucune injection n'est atteignable aujourd'hui.** Éprouvé : `ManageRefs` avec
`referentiel: "licorne"` → `GARDE « référentiel inconnu »`. ⚠️ Mais les **quatre aides partagées
sans barrière** sont inchangées depuis le 4ᵉ audit — constat **I-14**.

---

## 2 · Refus avant écriture

**12 refus de 5 familles** (`DROIT`, `GARDE`, `ETAT`, `INTROUVABLE`, entrée mal typée) joués
d'affilée, puis **20 tables recomptées** :

```
societe contact unite_organisation personne profil_candidat profil_ressource besoin
positionnement projet prestation temps absence document action qualification
evenement_metier snapshot_marge prestation_version politique groupe_permission_perimetre

>>> AUCUNE TABLE N'A BOUGE
tentative_refusee : 59 -> 71        (les 12, tracés « à part »)
```

✅ `executer.ts` ouvre `BEGIN`, pose `SET LOCAL search_path`, résout le compte, appelle
`exigeAgence` **avant** le handler, et `ROLLBACK` sur tout `Refus`. L'événement part **dans la
même transaction** que la mutation (l. 166-176).

---

## 3 · Périmètre par objet — 46 sondes, 42 commandes, et un trou

`server/src/agence.ts` porte la table `commande → table → colonne d'agence` : **55 lignes pour
55 commandes**, aucune manquante (`comm -3` vide contre les handlers). Une commande sans sa ligne
est refusée avant toute mutation (`executer.ts:150`).

**Protocole** : agence **LON** créée à côté de **PAR** ; un monde PAR construit **par les
commandes elles-mêmes** (société, unité, contact, personne, candidat, ressource, besoin,
positionnement, projet, prestation), puis cloné en SQL dans LON à l'identique. Deux comptes de
sonde, chacun avec **les 55 permissions** mais **un seul périmètre** : `par@ava.test` → agence PAR,
`lon@ava.test` → agence LON. Chaque commande est appelée sur le clone LON (**doit** rendre
`DROIT`) et, quand c'est possible, sur l'original PAR (**témoin positif**).

| | |
|---|---|
| Sondes hors agence | **46** sur **42 commandes distinctes** → `DROIT « permission absente ou hors périmètre »`, **46/46** |
| Témoins positifs dans le périmètre | **6** → `ok=true`, **6/6** (`UpdateNeed`, `SetNeedPriority`, `UpdateProject`, `UpdateCandidate`, `UpdateResource`, `UpdateUnit`) |
| Créations : l'agence **demandée** est-elle jugée ? | **oui pour 5 sur 6** — `CreateCandidate`, `CreateResource`, `CreateNeed`, `CreateProject` (le lecteur `agence(["agence","agence_id"])` lit l'agence demandée et `exigeDroit` la juge) et `CreateUnit` (par `entreeAgence`, **et** par le parent). ⛔ **Non pour `ConvertCandidateToResource`** — I-12 |
| Filtrage des **vues** | ✅ mesuré : `lon@ava.test` → `["Besoin LON"]` ; `par@ava.test` → le besoin PAR ; `adm@ava.test` (périmètre global) → les 2 ; fiche d'un besoin LON par un compte PAR → **HTTP 404** |

⛔ **Le trou est l'agence NULLE.** `profil_candidat.agence_id` est la **dernière** colonne d'agence
encore `NULL`-able parmi celles que le périmètre lit (mesuré dans `information_schema` :
`besoin`, `projet`, `profil_ressource`, `unite_organisation`, `compte`, `periode_emploi`,
`calendrier_jour_non_ouvre` sont **NOT NULL** ; seuls `profil_candidat`, `perimetre`, `modele`,
`alerte_regle` sont nullables). Voir **I-11**.

---

## 4 · Hors `AVA_MODE=banc` — K1 et V-078

Serveur relancé **sans `AVA_MODE`**, **13 routes** sondées :

```
GET  /sante                           -> 200   {"ok":true}          (la seule)
GET  /vues/besoins                    -> 401   {"ok":false,"code":"DROIT",
GET  /vues/besoins/<uuid>             -> 401    "message":"authentification non livrée (lot 2c)"}
GET  /vues/besoins  + en-tête ADM     -> 401
GET  /tuyau                           -> 401
POST /acquitter                       -> 401
POST /commandes/CreateCompany         -> 401
POST /commandes/SetPolicy             -> 401
POST /commandes/ManageRefs            -> 401
GET  /  ·  /besoins  ·  /index.html   -> 401   (le statique et le SPA fallback aussi)
GET  /n-importe-quoi                  -> 401   (setNotFoundHandler aussi)
POST anonyme avec corps               -> 401
POST avec en-tête ADM et corps        -> 401

besoin             : 2  -> 2
evenement_metier   : 35 -> 35
tentative_refusee  : 77 -> 77      ⭐ V-078 tenu
societe            : 1  -> 1       societe LIKE 'PIRATE%' : 0
```

✅ **Le hook `preHandler` de `index.ts:114-125` ferme TOUTES les routes**, vues et fiche comprises,
statique compris, 404 compris — **un seul garde** (D-14). ✅ **Aucune trace n'est écrite par un
POST anonyme** : le 401 part avant `executerCommande`, donc avant `tracerRefus`.

**K2** — l'UUID d'un compte comme session → `DROIT « compte inconnu ou inactif »` ; aucun en-tête
→ `DROIT « session absente »` ; témoin e-mail → `ok`. ⛔ Mais l'identifiant **est** une adresse
e-mail : **I-15**.

**K3** — `UPDATE compte SET actif=false` → `DROIT « compte inconnu ou inactif »`, `besoin 2 → 2` ;
réactivé → `ok=true`.

**V-102 — `/sante`** ✅ : `HTTP 200`, corps `{"ok":true}`, **11 octets**. `index.ts:138-140` rend un
littéral : **aucune requête à la base**, donc la route de santé reste verte même si la base tombe
— et elle ne devient pas un canal de lecture.

---

## 5 · GRANT réels, `pg_hba`, secrets, front

**GRANT** — mesurés par `has_table_privilege` / `has_any_column_privilege` sur **toutes** les
relations du schéma `ava`, jamais par une liste de noms :

```
ava_app        : DELETE/TRUNCATE  -> 0 ligne   ·  UPDATE sur les 3 tables d'histoire -> 0 ligne
ava_serveur    : DELETE/TRUNCATE  -> 0 ligne   ·  UPDATE sur les 3 tables d'histoire -> 0 ligne
ava_lecture_agregats -> EXACTEMENT 7 relations :
   politique · ref_devise · ref_pays · v_ca_provisoire_par_devise · v_ca_realise_par_devise
   · v_marge_par_devise · v_occupation_valorisee_par_devise
rôles : ava_app / ava_lecture_agregats / ava_migration = NOLOGIN ; ava_serveur = LOGIN, non super
```

Le serveur tourne en `ava_serveur`, et `index.ts:309-317` **refuse de démarrer** si `current_user`
était superutilisateur. **Murs éprouvés par le geste** : `UPDATE prestation SET tjm_vendu=999` sur
une engagée → `MUR M-14` ; `UPDATE snapshot_marge SET marge=0` → `ajout seul (MUR M-6)`.
Les **7 murs-triggers** sont en place (`tg_m4_m14`, `tg_m6`, `tg_m7`, `tg_m10`, `tg_m12` ×4,
`tg_ajout_seul`).

**`pg_hba`** — `bash outils/verif_serveur.sh` → **rc=1**, et il **nomme les lignes** :
6 règles `trust` (lignes 113, 115, 117, 120, 121, 122 : `(socket)`, `127.0.0.1`, `::1`),
`listen_addresses = *`, `ava_serveur` sans mot de passe. Avec `AVA_POSTE_DEV=1` → **rc=0**.
⭐ Poste de dev assumé (V-022) ; **jamais mesuré sur un serveur**, il n'y en a pas. À décharge :
aucune adresse distante n'a de règle, donc `listen_addresses = *` n'ouvre rien **en fait**.

**Secrets** ✅ **aucun.** `git ls-files | grep -iE "\.env|secret|password"` → vide.
`POSTGRES_PASSWORD: ${POSTGRES_PASSWORD:?…}` dans `docker-compose.yml` ; `${{ secrets.* }}` dans
`ci.yml` ; le seul `PASSWORD` littéral (`ci.yml:79`) est un `CREATE ROLE … PASSWORD :'pw'` —
une **variable psql**, pas une valeur. `.env` et `*.log` sont ignorés.

**Front** ✅ — **1 130 lignes lues en entier** (`contrat.ts`, `App.tsx`, `Cadre.tsx`,
`FicheBesoin.tsx`, `ListeBesoins.tsx`, `Tuyau.tsx`, `rendu.tsx`, `main.tsx`, `index.css`).
Aucun `if` sur un état métier, aucun calcul d'argent, aucun libellé d'état en dur, **aucun objet
`LABELS`**, aucune couleur hexadécimale dans le TSX, aucun import de `/server` ni de `/db`, aucun
SQL. Trois appels réseau : `/tuyau`, `/acquitter`, `fetch(chemin)`. Les seuls ternaires portent
sur des **champs de forme envoyés par le serveur** (`champ.nature`, `cellule.sous`,
`entree.courant`).

---

# LES CONSTATS DE SÉCURITÉ

---

**I-11 · V-097 n'est fermé qu'à moitié : sur un objet dont `agence_id` est NULL, trois commandes écrivent encore hors périmètre — et l'une d'elles archive.**
Cible **CODE** · famille **I / K4** · **elevee** ·
preuve : `securite5/perimetre5.txt`, dernier bloc. Compte `lon@ava.test`, dont **le seul**
périmètre est l'agence LON, sur un candidat dont `agence_id IS NULL` :
```
UpdateCandidate       -> DROIT  « permission absente ou hors périmètre »      ✅ corrigé
CompleteCandidate     -> DROIT                                                 ✅ corrigé
ExitCandidate         -> DROIT                                                 ✅ corrigé
ReactivateCandidate   -> DROIT                                                 ✅ corrigé
RecordQualification   -> DROIT   (via le besoin, qui porte une agence)         ✅
CreateAction          -> ok=true                                               ⛔
UploadDocument        -> ok=true                                               ⛔
ArchiveObject         -> ok=true                                               ⛔

relu en base : profil_candidat.archive_le = 2026-09-23 13:41:55+00
               action    sur ce candidat = 1
               document  sur ce candidat = 1
```
reproduire :
```bash
# 1. un compte dont le SEUL périmètre est une autre agence
psql -c "INSERT INTO ava.agence(id,code,nom,pays_code) VALUES ('…a1','LON','Londres','FR');"
psql -c "INSERT INTO ava.perimetre(id,type_code,agence_id) VALUES ('…b1','agence','…a1');"
psql -c "INSERT INTO ava.groupe(id,nom,description) VALUES ('…c1','LOCLON','x');"
psql -c "INSERT INTO ava.groupe_permission_perimetre SELECT '…c1', code, '…b1' FROM ava.permission;"
psql -c "INSERT INTO ava.compte(id,email,actif,agence_id) VALUES ('…d1','lon@ava.test',true,'…a1');"
psql -c "INSERT INTO ava.compte_groupe VALUES ('…d1','…c1');"
# 2. un candidat sans agence (la colonne l'autorise)
psql -c "INSERT INTO ava.profil_candidat(id,personne_id,titre,etat_code,agence_id)
         SELECT '…02','…01','Cand sans agence',etat_code,NULL FROM ava.profil_candidat LIMIT 1;"
# 3. le compte de LON l'archive
curl -s -X POST :3502/commandes/ArchiveObject -H 'x-ava-groupe: lon@ava.test' \
  -d '{"type":"candidat","id":"…02","motif":"autre"}'      # {"ok":true,…}
```
prétend : grille **K4** — « le périmètre se juge **sur l'objet visé** … par commande : un cas hors
agence → `DROIT`, **0 écriture** ». Et `db/migrations/009_unite_agence.sql` en tête :
« ⛔ une colonne toujours nulle est une colonne morte — et c'était elle qui portait la garde de
périmètre (V-097). **Une garde qui lit NULL ne garde rien.** »
mesure : la correction de V-097 est **réelle mais partielle**. `agence.ts:232-243` a gagné les
trois cas de D-21 :
```ts
if (trouve && !agenceId && !ligne.sinonCompte) {
  const gouv = await agenceGouvernante(ctx, tableTrouve, idTrouve);
  if (!gouv) { await exigeGlobal(ctx, ctx.commande); return; }   // ⭐ seul global passe
  agenceId = gouv;
}
if (!agenceId && ligne.sinonCompte) agenceId = ctx.compte.agence_id;   // ⛔ l. 244
```
⭐ La branche `else` **appelle bien `exigeGlobal`** : c'est la question posée, et la réponse est
oui — **pour les lignes `sinonCompte: false`**. ⛔ **Mais la ligne 244 n'a pas bougé** : quand la
ligne porte `sinonCompte: true`, une agence nulle retombe sur **l'agence du demandeur**, et
`exigeDroit(ctx, commande, <mon agence>)` passe forcément. Cinq lignes de `CORRESPONDANCE` sont
dans ce cas et peuvent viser un candidat : `CreateAction`, `UploadDocument`, `ArchiveObject`,
`RecordQualification`, `ConvertCandidateToResource`. Trois l'atteignent réellement, et je les ai
jouées : **elles passent toutes les trois**.
⚠️ **Et la migration `009` a fermé la mauvaise colonne.** Elle rend `unite_organisation.agence_id`
NOT NULL — ce qui, mesuré, rend `agenceGouvernante()` **définitivement inatteignable** (elle ne
répond que pour `unite_organisation`, seule table où l'agence ne peut plus être nulle). Pendant
ce temps `profil_candidat.agence_id` **reste nullable**, alors que le constat I-01 du 4ᵉ audit
nommait **les deux** colonnes. La moitié du mur a été bâtie, et c'est la moitié devenue inutile.
⚠️ Le chemin d'entrée n'est pas une commande — `CreateCandidate` (`identite.ts:68`) pose
`opt(…) ?? ctx.compte.agence_id`, donc jamais NULL. C'est la **reprise Boond** (`reprise_boond`,
sans aucune commande L4 ni aucune porte) qui fera entrer ces lignes en masse.
correction : **deux lignes, et l'une suffit** —
(a) `profil_candidat.agence_id SET NOT NULL` dans une migration `010`, comme `009` l'a fait pour
les unités : c'est un mur, il ne se contourne pas ;
(b) à la ligne 244, ne retomber sur `ctx.compte.agence_id` **que si aucun objet n'a été trouvé**
(`!trouve`) — un objet trouvé sans agence doit passer par `exigeGlobal`, exactement comme dans la
branche `sinonCompte: false`.
⭐ **(a) et (b) ensemble** : sinon la prochaine table d'objet nullable rouvrira le même trou, et
rien dans `agence.ts` ne dit que `sinonCompte: true` suppose une agence non nulle.

---

**I-12 · Le périmètre ne juge toujours pas l'agence demandée à `ConvertCandidateToResource` ; le trou d'écriture est bouché ailleurs, en silence.**
Cible **CODE** · famille **I / §C-1** · **moyenne** *(l'écriture inter-agences est fermée ; la garde, non)* ·
preuve : RH de **PAR**, candidat de **PAR** (`terminal_positif` obtenu par les commandes),
`agence_id = <LON>` dans l'entrée :
```
ConvertCandidateToResource  -> ok=true
SELECT agence_id FROM ava.profil_ressource WHERE personne_id='<p>'   ->  PAR   (pas LON)
témoin : CreateResource, même agence demandée -> DROIT « … hors périmètre »
agence.ts:73-76 : pas de `entreeAgence` sur cette ligne, et la boucle fait toujours `break`
identite.ts:196 : const agenceId = ctx.compte.agence_id;   // l'entrée n'est jamais lue
```
reproduire : voir CONFORMITE5 **H-5**.
prétend : grille **K4** ; L4 §C-1 — `ENTRÉE profil_candidat_id · type_code · agence_id`.
mesure : ⭐ **I-02 du 4ᵉ audit ne permet plus d'écrire dans une autre agence** — c'est le résultat
qui compte, et il est acquis. ⛔ Mais il a été obtenu en **cessant de lire le champ**, pas en le
jugeant : `agence.ts` est inchangé (ni `entreeAgence`, ni accumulation des lecteurs), et c'est le
handler qui écrase l'entrée par `ctx.compte.agence_id`. Deux conséquences mesurables :
(1) un appelant reçoit `ok` et obtient **autre chose** que ce qu'il a demandé, sans alerte ;
(2) un opérateur au périmètre **global** convertira un candidat de LON **dans sa propre agence** —
la garde ne dira rien, puisqu'elle n'a plus d'agence demandée à confronter.
⚠️ La garde de périmètre reste donc borgne sur cette commande ; c'est le handler qui la sauve.
correction : poser `entreeAgence: ["agence_id","agence"]` sur la ligne de `CORRESPONDANCE` **et**
décider dans le handler quelle agence est la bonne (celle du candidat, à mon sens) — puis l'écrire
dans L4. ⛔ Un champ contractuel qu'on ne lit pas n'est pas une garde.

---

**I-13 · La boucle de `exigeAgence` ne juge toujours que la première agence trouvée.**
Cible **CODE** · famille **I** · **moyenne** · *(reconduit du 4ᵉ audit, non corrigé ; cause commune de I-12)*
preuve : `server/src/agence.ts:220-231`
```ts
for (const l of ligne.lecteurs) {
  const id = valeur(ctx.entree, l.cle);
  if (!id) continue;
  vu = true;
  const lu = await lire(ctx, l, id);
  if (lu === undefined) continue;
  trouve = true; … agenceId = lu;
  break;                                  // ⛔ la première gagne
}
```
reproduire : `grep -n "break;" server/src/agence.ts` puis lire les 5 lignes à plusieurs lecteurs.
mesure : cinq lignes de `CORRESPONDANCE` ont plusieurs lecteurs —
`ConvertCandidateToResource` (2), `UploadDocument` (5), `RecordQualification` (3),
`CreateAction` (4), `ArchiveObject` (5). Pour les quatre dernières les lecteurs sont **exclusifs**
(un seul porteur possible), donc le `break` est sans effet **aujourd'hui**. Pour la première ils
sont **cumulatifs** — d'où I-12. ⚠️ Rien dans le fichier ne dit que les lecteurs doivent être
exclusifs, et le commentaire de `Ligne` n'en parle pas : la prochaine ligne à deux agences
réelles rouvrira le trou sans qu'aucun test ne le voie.
correction : accumuler les agences trouvées et appeler `exigeDroit` **pour chacune** ; écrire en
commentaire que plusieurs lecteurs = plusieurs droits exigés. ⭐ Cette forme ferme aussi I-12 et
tous les futurs cas à deux agences.

---

**I-14 · Quatre aides SQL partagées interpolent un nom de table sans le valider, et `ident()` n'est toujours pas exportée.**
Cible **CODE** · famille **I** · **moyenne** · *(reconduit du 4ᵉ audit, non corrigé)*
preuve :
```
kernel.ts:124  `SELECT code FROM ${table} WHERE code = $1 AND actif`          (exigeRef)
kernel.ts:166  `SELECT code, libelle, categorie FROM ${table} WHERE code = $1` (libelleRef)
cycle.ts:125   `SELECT code FROM ${table} WHERE categorie = $1 AND actif …`   (codeCategorie)
cycle.ts:145   `UPDATE ${tableObjet} SET etat_code = $2 WHERE id = $1`        (appliquerTransition)
grep -rn "export function ident" server/src/  ->  rien   (agence.ts:152, non exportée)
```
reproduire : les deux greps ci-dessus, puis remonter les appelants
(`grep -rn "exigeRef(\|libelleRef(\|codeCategorie(\|appliquerTransition(" server/src`).
prétend : rien dans L4 — c'est une lecture de défense en profondeur. Mais `agence.ts:152-155` et
`admin.ts:177-186` **valident**, eux : la fonction existe déjà dans le dépôt.
mesure : **tous les appels sont des littéraux**, donc **rien n'est exploitable aujourd'hui**.
⚠️ La défense repose sur une **convention non écrite**. Le jour où quelqu'un écrira
`exigeRef(ctx, ctx.entree.referentiel, …)` — ce que `ManageRefs` fait déjà, avec sa propre
barrière — il n'y aura rien pour l'arrêter, et la revue ne verra qu'un appel de plus. ⭐ Le code a
la fonction qu'il faut, elle est juste au mauvais endroit.
correction : exporter `ident()` depuis `kernel.ts` et l'appeler dans les quatre aides. **4 lignes.**

---

**I-15 · L'identifiant de session est une adresse e-mail en clair dans un en-tête HTTP.**
Cible **CODE** · famille **I / K2** · **moyenne** *(dette déclarée lot 2c, bornée par K1)* ·
preuve : `x-ava-groupe: adm@ava.test` → la commande passe en ADM.
`executer.ts:62-73` — `WHERE lower(c.email) = lower($1) AND c.actif`. `index.ts:184-195` fait la
même chose pour les vues.
prétend : grille **K2** — « Une session n'est jamais l'identifiant d'un compte … le jeton est
aléatoire, haché, expirant (D-10) ».
mesure : ✅ la moitié du contrôle tient — l'UUID d'un compte **n'est pas** une session, et un
appel sans en-tête rend `DROIT « session absente »`. ⛔ L'autre moitié n'existe pas : connaître
une adresse e-mail suffit à être n'importe qui, **sans mot de passe, sans expiration**, et
l'en-tête voyage en clair. ⭐ Le serveur l'assume à voix haute : hors banc, **aucune** route ne
répond (`authentification non livrée (lot 2c)`), mesuré sur 13 routes. C'est donc une dette
**bornée par K1**, pas une faille ouverte — **à la condition** que personne ne pose
`AVA_MODE=banc` ailleurs que sur un poste.
correction : lot 2c (D-10). ⛔ D'ici là : ne jamais publier le port. ⭐ Que
`app.listen({ host: "127.0.0.1" })` soit codé en dur (`index.ts:320`) est la bonne décision et
doit rester.

---

**I-16 · Les vues renvoient une identité par défaut, la même pour tout le monde : « Banc / IA ».**
Cible **CODE** · famille **I / V-103** · **moyenne** ·
preuve : `securite5/vues_sante.txt`
```
GET /vues/besoins  -H 'x-ava-groupe: adm@ava.test'  -> session = {'nom':'Banc','groupe':'IA'}
GET /vues/besoins  -H 'x-ava-groupe: res@ava.test'  -> session = {'nom':'Banc','groupe':'IA'}
GET /vues/besoins  -H 'x-ava-groupe: lon@ava.test'  -> session = {'nom':'Banc','groupe':'IA'}
GET /vues/besoins/<id> -H 'x-ava-groupe: par@ava.test' -> session = {'nom':'Banc','groupe':'IA'}
index.ts:248  session: { nom: "Banc", groupe: "IA" },      ← liste
index.ts:286  session: { nom: "Banc", groupe: "IA" },      ← fiche
```
reproduire :
```bash
for c in adm res lon par; do
  curl -s :3502/vues/besoins -H "x-ava-groupe: $c@ava.test" \
  | python -c "import sys,json;print(json.load(sys.stdin)['session'])"; done
```
prétend : L4 — « Renvoyer une liste que l'écran doit **filtrer** » est interdit, et c'est bien le
serveur qui filtre ici. Grille **E3** — « Aucun libellé d'état écrit en dur … le serveur envoie le
libellé » : le principe vaut pour ce que le serveur envoie, pas seulement pour ce que l'écran
écrit. Et **ADR-005** pour le groupe.
mesure : ⭐ **le filtrage, lui, est juste** — mesuré : `lon@ava.test` ne voit que `Besoin LON`,
`par@ava.test` que le sien, `adm@ava.test` (périmètre global) les deux, et la fiche d'un besoin
d'une autre agence rend **404**. C'est la partie qui protège, et elle tient.
⛔ Ce qui est faux est **ce que l'écran affiche de l'utilisateur** : un administrateur voit
« groupe IA » dans sa barre. Deux conséquences, et la seconde est la vraie :
(1) l'écran ment sur l'identité de qui le regarde — c'est le défaut déjà payé le 10/08 avec
l'heure d'un conteneur montrée aux clientes ;
(2) `"IA"` est un **code de groupe écrit en dur dans le serveur**, dans le seul endroit où
l'écran le lit. Le jour où l'écran grisera un bouton d'après `session.groupe`, il le grisera
d'après une constante. ⚠️ Et le grep **B1** ne le voit pas : ce n'est pas une comparaison.
correction : rendre le compte et ses groupes lus en base, comme `filtreAgence()` le fait déjà
juste au-dessus (`index.ts:197-210` sait déjà interroger `v_droits_effectifs` pour ce compte) —
`SELECT c.email, array_agg(g.nom) FROM compte c JOIN compte_groupe … WHERE c.id = $1`.

---

**I-17 · bien fait (bonne).**
⭐ **Le périmètre par objet tient sur 42 commandes** : **46 sondes hors agence → 46 `DROIT`**,
**6 témoins positifs**, et les **cinq créations sur six** confrontent l'agence **demandée** à celle
qu'on a le droit d'écrire. Les trois trous du 3ᵉ audit et les cinq du 2ᵉ restent fermés, et
**les quatre commandes d'état sur un candidat sans agence** (`UpdateCandidate`,
`CompleteCandidate`, `ExitCandidate`, `ReactivateCandidate`) rendent maintenant `DROIT` — alors
que `UpdateCandidate`, la seule des quatre que le 4ᵉ audit avait jouée dans ce cas, passait.
**V-097 a vraiment progressé** : la branche `else` appelle bien `exigeGlobal`.
⭐ **Les vues filtrent sur le périmètre, y compris la fiche** : une agence ne lit pas les besoins
d'une autre, et un identifiant d'une autre agence rend **404**, pas 403 — l'existence même n'est
pas révélée.
⭐ **Hors banc, rien ne répond et rien ne s'écrit** : 12 routes sur 13 en 401, statique et 404
compris, **quatre compteurs immobiles** (V-078 tenu sur les chiffres, pas sur le code).
⭐ **`/sante` rend un littéral de 11 octets sans toucher la base** : elle reste vraie quand la base
tombe, et elle n'est pas un canal de lecture.
⭐ **Les valeurs passent toujours en `$n`**, sans exception ; le seul identifiant qui vienne de
l'utilisateur passe **deux** barrières dont une qui interroge `pg_class` — éprouvé
(`referentiel: "licorne"` → `GARDE`).
⭐ **Les GRANT sont mesurés par ce qu'on ATTEINT**, sur `ava_app` **comme** sur `ava_serveur`, et
ils sont vides là où ils doivent l'être ; `ava_lecture_agregats` atteint **exactement 7**
relations. Les deux murs les plus chers (M-6, M-14) répondent au **geste direct**.
⭐ **Aucun secret versionné**, nulle part, CI comprise.
⭐ **Le front est propre**, 1 130 lignes relues : zéro règle métier, zéro libellé d'état, zéro
couleur en dur dans le TSX.
⭐ **Le refus précède l'écriture** : 12 refus de 5 familles, **20 tables immobiles**.

---

# ANGLES MORTS

⭐ **Ce que je n'ai PAS mesuré, et pourquoi. À lire avant de conclure quoi que ce soit de ces trois rapports.**

| # | Angle mort | Pourquoi | Ce que ça pourrait cacher |
|---|---|---|---|
| 1 | **Les espèces C GESTE et D ÉCRAN** — 8 portes | Playwright exige `web/dist`, donc un `npm run build` **dans le clone de lecture** : ma consigne interdit de modifier un fichier | une capture qui ne correspond plus, un geste cassé ; la case 1 du cliquet le verrait, moi non |
| 2 | **`outils/cliquet.sh` et `outils/make.sh` en exécution** | interdits. Je les ai **lus** en entier et rejoué leurs recettes à la main (migrations 001→009, fixture, assertions, contre-tests) | une case qui se comporte autrement que ce que son code dit ; un effet de `trap`. ⭐ En particulier : je n'ai **pas** vu la case 1 refaire la base — je l'ai lue |
| 3 | **Les 290 portes de contrat (espèce B)** | `make test` interdit ; je n'ai joué **aucune** porte, j'ai joué les **commandes**. Le « 294 ✅ » est donc un compte **du tableau**, pas une exécution | une porte déclarée ✅ qui échouerait ; c'est exactement ce que la case 1 mesure et que je ne peux pas mesurer |
| 4 | **La CI réelle** | les deux secrets GitHub sont invisibles à un auditeur ; aucun run n'est consultable depuis le dépôt | une CI jamais verte, ou qui saute le cliquet faute de secrets |
| 5 | **`core.hooksPath` (F7)** | vide dans tout clone neuf ; seul le dépôt de travail — interdit — le dit | F7 pourrait être ✅ chez lui. La case 12 du cliquet le vérifie, et je ne l'ai pas lancée |
| 6 | **`main` en tant que branche locale** | le clone est en HEAD détaché : D1, D3, D5, F3, F10, F12 sont mesurés contre **`origin/main`**. C'est le secours que `cliquet.sh` prend lui-même, mais pas ce que la grille écrit. ⭐ Idem pour F13 : `origin/lot-2-brain` | rien de probable ; mais c'est **précisément** le trou que G-02 décrit |
| 7 | **Ma propre contamination, et elle a compté** | j'ai créé l'agence LON, deux groupes de sonde à 55 permissions, deux comptes, et — sans y penser — **posé `ArchiveCompany` sur le groupe IA** via `ManageGroups` pendant le balayage. J'ai aussi ajouté `no_go_client` à `ref_etat_positionnement` et basculé 6 politiques (toutes remises à `valeur_defaut`) | ⛔ **mes chiffres de titulaires sont 51, pas 50** : le seed en sert 50, et je ne l'ai su qu'en excluant mes propres groupes. Un auditeur qui relit `refus5.txt` sans ce paragraphe croira `ArchiveCompany` semée |
| 8 | **Le volume** | `_ops/JEU_ESSAI.sql` (5 agences, 2 580 sociétés, 21 000 personnes) est **chargeable** mais je ne l'ai pas chargé : il `TRUNCATE` le métier et aurait effacé mes objets de sonde | `GET /vues/besoins` sans pagination réelle (`pagination.libelle` = le compte total), une garde en `count(*)` qui s'effondre à 21 000 lignes |
| 9 | **La concurrence** | toutes mes sondes sont séquentielles | l'unicité de positionnement, le plafond journalier et la garde de couverture sont des `SELECT` puis `INSERT` : deux requêtes simultanées peuvent les franchir toutes les deux. M-2 et M-11 sont censés rattraper ; **non mesuré** |
| 10 | **`reprise_boond`** | table présente, aucune commande L4 ne la touche, aucune porte | ⛔ **c'est le chemin par lequel les `profil_candidat.agence_id` NULL entreront en masse** — exactement I-11, et personne ne le teste |
| 11 | **Les 12 autres murs en contre-test** | A2 casse 3 triggers sur 7 (`tg_m10`, `tg_m12`, `tg_m6`). Trois valent mieux qu'un, sept vaudraient mieux que trois | un mur dont l'assertion ne mord pas ; il faudrait 15 contre-tests |
| 12 | **`verif_serveur.sh` sur un vrai serveur** | il n'y en a pas. Mesuré sur le poste de dev : rc=1, et `AVA_POSTE_DEV=1` → rc=0 | T3 (« scram sur le VPS ») reste une phrase que rien n'a encore mesurée en situation |
| 13 | **L'écran d'administration de `SetPolicy`** | §C-5 veut la politique « signalée **en rouge** » ; `web/src` n'a que 5 composants (Tuyau, Cadre, ListeBesoins, FicheBesoin, rendu) | la sortie `commandes_affectees` est juste et **personne ne la lit encore** — d'où H-3, qui ne fait encore mal à personne |
| 14 | **Le mur d'indépendance a marché, et il coûte** | je n'ai lu ni `_ops/PLAN_*`, ni prompts, ni journaux de bugs, ni `REMARQUES`, ni `ARBITRAGE_*` | certains de mes constats sont peut-être déjà arbitrés ailleurs — **H-1** en particulier (« 4 permissions sans titulaire » peut être une décision écrite dans un fichier que je n'ai pas le droit d'ouvrir) |
| 15 | **Un faux constat évité de justesse, et il dit ce que je risque** | j'ai cru `RequalifyCompany` muette sur sa politique, sur la foi d'un `pol=` vide — **qui venait d'un refus `ETAT`, pas d'un succès**. Rejouée au vert : la clé est là | ⚠️ **les autres cases de mon tableau des 55 ont la même faiblesse** quand la commande n'a pas atteint `ok`. Je n'ai pas mené les 55 au vert du premier coup ; celles rattrapées dans un second tour sont mesurées, les politiques des refus ne prouvent rien |
