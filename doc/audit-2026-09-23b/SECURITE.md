# SECURITE4 — SQL, périmètre, accès, secrets, front

**Quatrième audit · commit `cc3ff64`.** Base `ava_audit4_b`, port 3402, clone de lecture intact.
Preuves : `securite4/perimetre4.txt` (72 sondes) · `perimetre4b.txt` (les objets sans agence) ·
`acces4.txt` (K1/K2/K3/V-078) · `refus_avant_ecriture.txt` · `verif_serveur.txt` ·
`sql.txt` + `sql_appels.txt` · `secrets_front.txt`.

## VERDICT

| | |
|---|---|
| 🔴 critique | **0** |
| 🟠 elevee | **2** — I-01 · I-02 |
| 🟡 moyenne | **3** — I-03 · I-04 · I-05 |
| ✅ bonne | SQL paramétré · refus avant écriture · GRANTs · K1/V-078 · secrets · front |

---

## 1 · SQL paramétré — serveur et tests

**Les valeurs passent toujours en `$n`.** `grep -rnE '(SELECT\|INSERT\|UPDATE\|WHERE\|FROM)[^"'"'"']*" *\+' server/src`
→ **vide** : aucune concaténation de valeur. 14 requêtes interpolent un **identifiant**
(`${table}`, `${colonne}`) ; je les ai toutes remontées jusqu'à leur source :

| Emplacement | Origine de l'identifiant | Barrière | Atteignable depuis l'entrée ? |
|---|---|---|---|
| `agence.ts:170,179` | table littérale `CORRESPONDANCE` | **`ident()` `/^[a-z_]+$/`** | non |
| `admin.ts:31` | `pg_constraint` (catalogue) | **`/^[a-z_]+$/` relu** | non |
| `admin.ts:63` | `PORTEURS_ACTION`, const | énumération fermée | non |
| `admin.ts:88,115` | `ARCHIVE`, const | map fermée | non |
| `admin.ts:187,210,230,235` | ⭐ **l'entrée `referentiel`** | **`/^ref_[a-z_]+$/` + existence dans `pg_class` schéma `ava`** | **oui, et couvert par deux barrières** |
| `besoin.ts:236` | une des 2 clauses littérales choisies par `positionnement.unicite` | littéraux | non |
| `cycle.ts:125,145` | `TRANSITIONS[].ref` / appels littéraux | aucune | non |
| `kernel.ts:124,166` | appels littéraux (23 `exigeRef`, 9 `etatDe`) | aucune | non |

**Tests** : `test/contrat/db.ts:36-46` valide l'identifiant (`/^[a-z_][a-z0-9_]*$/`) **et** refuse
une clause contenant `'`, `"`, `;`, `--`, `/*` — « les valeurs passent en `$n` ». Les deux autres
interpolations de test (`monde.ts:39`, `v011-lignes.ts:118`) prennent un nom de table écrit dans
le fichier.

⭐ **Aucune injection n'est atteignable aujourd'hui**, et le seul point où un identifiant vient de
l'utilisateur (`ManageRefs`) est le mieux gardé des quatorze. ⚠️ Mais quatre aides partagées
interpolent sans valider — constat **I-04**.

---

## 2 · Refus avant écriture

12 refus de 5 familles (`DROIT`, `GARDE`, `ETAT`, `INTROUVABLE`, entrée mal typée) joués d'affilée,
puis **20 tables recomptées** (`societe`, `contact`, `unite_organisation`, `personne`,
`profil_candidat`, `profil_ressource`, `besoin`, `positionnement`, `projet`, `prestation`, `temps`,
`absence`, `document`, `action`, `qualification`, `evenement_metier`, `snapshot_marge`,
`prestation_version`, `politique`, `groupe_permission_perimetre`) :

```
tables qui ont bouge : AUCUNE
tentative_refusee : 643 -> 654
```

✅ `executer.ts` ouvre `BEGIN`, résout le droit, appelle la garde, et `ROLLBACK` sur tout `Refus`.
L'événement part **dans la même transaction** que la mutation (l. 166-176).

---

## 3 · Périmètre par objet — 72 sondes

`server/src/agence.ts` porte la table `commande → table → colonne d'agence`, **55 lignes pour 55
commandes**, aucune manquante. Une commande sans sa ligne est refusée avant toute mutation
(`executer.ts:150`).

**Protocole** : agence **LON** créée à côté de **PAR** ; pour chaque type d'objet, un objet PAR
créé **par la commande elle-même**, puis cloné en SQL dans LON à l'identique. Les comptes du banc
(IA, RH, STAF, DP, EVAL) n'ont qu'un périmètre `agence = PAR`. Chaque commande est appelée deux
fois : sur le clone LON (**doit** rendre `DROIT`) et sur l'original PAR (**témoin positif**).

| | |
|---|---|
| Sondes hors agence | **40** → `DROIT « permission absente ou hors périmètre »`, **40/40** |
| Témoins positifs dans le périmètre | **25** → `ok=true`, **25/25** *(après correction de 8 codes de référentiel que j'avais tapés faux au premier tour — `conges_payes` au lieu de `conge`, `haute` au lieu de `P1`…)* |
| Commandes sans objet d'agence (`societe`, `contact`, `personne`, admin, thème) | 12, périmètre jugé sur l'agence du compte — conforme au modèle : `societe` **n'a pas** de colonne `agence_id` |

**Les trois trous du 3ᵉ audit sont fermés** — mesuré une par une :

```
UpdateUnit     | LON | DROIT | permission absente ou hors périmètre     ← C-01
UpdateUnit     | PAR | ok                                              ← témoin
ArchiveService | LON | DROIT | permission absente ou hors périmètre     ← C-01
ArchiveService | PAR | ok                                              ← témoin
CreateUnit     | parent LON            | DROIT                          ← C-01
CreateUnit     | agence LON en entrée  | DROIT                          ← l'entrée est confrontée
CreateUnit     | PAR                   | ok                             ← témoin
```

**Les cinq du 2ᵉ audit** (`WithdrawPositioning`, `RecordQualification`, `UploadDocument`,
`CreateAction`, `ArchiveObject`) : `DROIT` sur LON, `ok` sur PAR, toutes.

**L'agence donnée en entrée est-elle confrontée à celle lue en base ?** Oui pour les quatre
créations (`CreateCandidate`, `CreateResource`, `CreateNeed`, `CreateProject`) : le lecteur
`agence(["agence","agence_id"])` lit l'agence **demandée** puis `exigeDroit` la juge → `DROIT`.
Et oui pour `CreateUnit`, par le champ `entreeAgence` qui compare explicitement. ⛔ **Non pour
`ConvertCandidateToResource`** — constat **I-02**.

---

## 4 · Hors `AVA_MODE=banc` — K1 et V-078

Serveur relancé **sans `AVA_MODE`** sur un port libre, 11 routes sondées :

```
GET  /sante                          -> 200   (la seule)
GET  /vues/besoins                   -> 401  {"ok":false,"code":"DROIT",…}  · pas de « lignes »
GET  /vues/besoins/<uuid>            -> 401
POST /acquitter                      -> 401
POST /commandes/CreateCompany        -> 401
POST /commandes/SetPolicy            -> 401
POST /commandes/ManageRefs           -> 401
GET  /  ·  /besoins  ·  /index.html  -> 401   (le statique et le SPA fallback aussi)
GET  /n-importe-quoi                 -> 401   (setNotFoundHandler aussi)
POST anonyme sans en-tête            -> 401

besoin            : 118  -> 118
evenement_metier  : 1855 -> 1855
tentative_refusee : 551  -> 551      ⭐ V-078 FERMÉ
```

✅ **Le hook `preHandler` de `index.ts:114-125` ferme TOUTES les routes**, commandes et vues, la
fiche comprise, le statique compris, le 404 compris. Un seul garde, aucune route ne décide
d'elle-même (D-14). ✅ **Aucune trace n'est plus écrite par un POST anonyme** : le hook rend 401
avant d'atteindre `executerCommande`, donc avant `tracerRefus`.

**K3** — `UPDATE compte SET actif=false` → `DROIT « compte inconnu ou inactif »`, `societe`
134 → 134 ; réactivé → `ok=true`.

**K2** — l'UUID d'un compte envoyé comme session est refusé (témoin e-mail → `ok`), mais
l'identifiant **est** un e-mail en clair : voir **I-05**.

---

## 5 · GRANT réels, `pg_hba`, secrets, front

**GRANT** (mesurés par `has_table_privilege`, sur **toutes** les relations du schéma) :
`ava_app` et `ava_serveur` n'ont **ni `DELETE` ni `TRUNCATE` nulle part**, et **aucun `UPDATE`** sur
`evenement_metier`, `snapshot_marge`, `prestation_version` — 0 ligne des deux côtés.
`ava_lecture_agregats` atteint **exactement 7 relations** (les 4 vues par devise + `politique` +
`ref_devise` + `ref_pays`). Le serveur tourne bien en `ava_serveur` (`pg_stat_activity`), non
superutilisateur, et `index.ts:301-309` **refuse de démarrer** si `current_user` l'était.
Murs éprouvés **par le geste** : `UPDATE prestation SET tjm_vendu=999` → `MUR M-14` ;
`UPDATE snapshot_marge SET marge=0` → `ajout seul (MUR M-6)`.
`ava_app`, `ava_lecture_agregats`, `ava_migration` sont **NOLOGIN**.

**`pg_hba`** — `bash outils/verif_serveur.sh` : 6 règles `trust`, `listen_addresses = *`,
`ava_serveur` sans mot de passe, sortie **1**. Avec `AVA_POSTE_DEV=1` → **0**. Poste de dev
assumé (V-022) ; **jamais mesuré sur un serveur**, il n'y en a pas. À décharge : les 6 règles
`trust` ne visent que `(socket)`, `127.0.0.1` et `::1` — aucune adresse distante n'a de règle,
donc `listen_addresses = *` n'ouvre rien en fait.

**Secrets** : ✅ aucun. `POSTGRES_PASSWORD: ${POSTGRES_PASSWORD:?…}` dans `docker-compose.yml`,
`${{ secrets.* }}` dans `ci.yml`, `${PASS}` dans `make.sh` — **aucune valeur** versionnée.
`.env` et `*.log` sont ignorés, `git ls-files | grep -iE "\.env|secret|password"` → vide.

**Front** : 631 lignes lues en entier. Aucun `if` sur un état métier, aucun calcul d'argent,
aucun libellé d'état en dur, **aucun objet `LABELS`**, aucun import de `/server` ou `/db`, aucun
SQL. Trois appels réseau : `/sante`, `/acquitter`, et un `fetch(chemin)` pour les vues.
Les libellés et les couleurs viennent du serveur (`etat.libelle`, `theme`).

---

# LES CONSTATS DE SÉCURITÉ

---

**I-01 · Un objet dont `agence_id` est NULL échappe entièrement au périmètre : n'importe quelle agence peut le modifier.**
Cible **CODE** · famille **I / K4** · **elevee** ·
preuve : `securite4/perimetre4b.txt` — compte `lon@ava.test`, dont **le seul** périmètre est
l'agence LON :
```
unite cliente 2ec96442-… · agence_id = null
UpdateUnit     unite SANS agence  · compte LON  :: ok=true          ⛔
UpdateUnit     unite agence PAR   · compte LON  :: DROIT  « … hors périmètre »   ← témoin
ArchiveService unite SANS agence  · compte LON  :: ok=true          ⛔
UpdateCandidate candidat SANS agence · compte LON :: ok=true        ⛔
UpdateCandidate candidat agence PAR  · compte LON :: DROIT          ← témoin
```
reproduire :
```bash
# 1. un groupe dont le périmètre est une AUTRE agence, et un compte dedans
psql -c "INSERT INTO ava.perimetre (id,type_code,agence_id) VALUES ('…b1','agence','<LON>');"
psql -c "INSERT INTO ava.groupe (id,nom,description) VALUES ('…c1','LOCLON','x');"
psql -c "INSERT INTO ava.groupe_permission_perimetre SELECT '…c1', code, '…b1' FROM ava.permission;"
psql -c "INSERT INTO ava.compte (id,email,actif,agence_id) VALUES ('…d1','lon@ava.test',true,'<LON>');"
psql -c "INSERT INTO ava.compte_groupe VALUES ('…d1','…c1');"
# 2. une unité d'une société CLIENTE : CreateUnit lui met agence_id = NULL
curl -s -X POST …/commandes/CreateUnit -H 'x-ava-groupe: ia@ava.test' \
  -d '{"societe_id":"<société cliente>","type":"service","nom":"U"}'
# 3. le compte de LON la renomme
curl -s -X POST …/commandes/UpdateUnit -H 'x-ava-groupe: lon@ava.test' -d '{"id":"<U>","nom":"pirate"}'
# {"ok":true,…}
```
prétend : grille **K4** — « le périmètre se juge **sur l'objet visé** ; par commande : un cas hors
agence → `DROIT`, 0 écriture ».
mesure : `server/src/agence.ts:202`
```ts
if (!agenceId && vu && !ligne.sinonCompte) return;   // ⛔ sort SANS exigeDroit(agence)
```
Quand l'objet est trouvé (`vu = true`) mais que son `agence_id` est **NULL**, la fonction rend la
main sans juger le périmètre. Seul `exigeDroit(ctx, ctx.commande)` de la ligne 187 a tourné, et
il ne vérifie que « ce compte a-t-il la permission **quelque part** » : un périmètre d'agence
couvrant la **sienne** suffit. Le cas n'est pas théorique : `crm.ts:170` écrit
`interne?.ok ? (agenceParent ?? ctx.compte.agence_id) : null` — **toute unité d'une société
cliente naît sans agence**, et un ERP de recrutement en crée à la chaîne (les directions et
services du client). Et `agence_id` est **nullable** sur `unite_organisation` **et** sur
`profil_candidat` (mesuré dans `information_schema`), donc une reprise Boond peut aussi laisser
des candidats sans agence.
⚠️ Ce que ça permet : renommer, rattacher et **archiver** les unités clientes d'une autre agence ;
et, sur un candidat sans agence, le modifier, le compléter, le sortir, l'archiver.
correction : décider ce que « pas d'agence » veut dire, puis l'écrire. Deux options, à trancher —
(a) **fermé par défaut** : si l'objet est trouvé et que son agence est nulle, retomber sur
`ctx.compte.agence_id` (le périmètre du demandeur), ce qui rend le refus ci-dessus immédiat ;
(b) **rendre la colonne NOT NULL** pour `unite_organisation` et `profil_candidat`, et faire porter
à l'unité cliente l'agence qui la gère. ⭐ (a) est une ligne et se teste ; (b) est un mur et ne
se contourne pas. ⛔ Ne pas laisser le trou « en attendant » : c'est un chemin d'écriture
inter-agences, pas une lecture.

---

**I-02 · `ConvertCandidateToResource` crée la ressource dans l'agence qu'on lui demande, sans jamais juger cette agence.**
Cible **CODE** · famille **I / §C-1** · **elevee** ·
preuve : `securite4/perimetre4b.txt` — compte **RH de PAR**, candidat **de PAR** :
```
ConvertCandidateToResource candidat PAR -> agence LON · compte PAR :: ok=true
agence du profil_ressource cree = [{"agence_id":"b0000000-…-a1"}]   (LON)
```
Témoin : la même agence demandée à `CreateResource` → `DROIT « permission absente ou hors
périmètre »`.
reproduire :
```bash
# candidat de PAR avec un positionnement terminal_positif (requis par la garde)
curl … PositionCandidate ; curl … DeclareCVShared ; curl … RecordClientDecision retenu
curl -s -X POST …/commandes/ConvertCandidateToResource -H 'x-ava-groupe: rh@ava.test' \
  -d '{"profil_candidat_id":"<candidat PAR>","type":"INTERNAL","agence_id":"<LON>"}'
psql -Atc "SELECT agence_id FROM ava.profil_ressource WHERE personne_id='<personne>'"
```
prétend : grille **K4** ; L4 §C-1 — `ENTRÉE profil_candidat_id · type_code · agence_id`, et les
quatre refus de la garde G1.
mesure : `agence.ts:73-76` donne deux lecteurs à cette commande —
`col("profil_candidat", …)` **puis** `agence(["agence_id","agence"])`. Mais la boucle de
`exigeAgence` fait `break` **au premier lecteur qui rend une agence non nulle** (l. 196-199) :
l'agence du **candidat** est trouvée, et le second lecteur n'est jamais évalué. Il n'y a pas non
plus de `entreeAgence` sur cette ligne, contrairement à `CreateUnit`. Résultat : la commande
vérifie que je peux lire le candidat, jamais que je peux écrire dans l'agence de destination.
⚠️ Elle est la **seule** des cinq créations de profil à ne pas juger l'agence demandée — les
quatre autres (`CreateCandidate`, `CreateResource`, `CreateNeed`, `CreateProject`) refusent.
correction : ajouter `entreeAgence: ["agence_id", "agence"]` à la ligne, **ou** — plus net —
juger **toutes** les agences trouvées au lieu de la première : remplacer le `break` par une
accumulation et exiger le droit sur chacune. ⭐ La seconde forme ferme aussi tous les futurs cas
à deux agences sans qu'on ait à y penger.

---

**I-03 · La boucle de `exigeAgence` ne juge que la première agence trouvée.**
Cible **CODE** · famille **I** · **moyenne** *(cause commune de I-02, listée à part parce que la correction est structurelle)* ·
preuve : `server/src/agence.ts:190-200`
```ts
for (const l of ligne.lecteurs) {
  …
  if (lu) { agenceId = lu; break; }     // ⛔ la première gagne
}
```
mesure : cinq lignes de `CORRESPONDANCE` ont **plusieurs** lecteurs :
`ConvertCandidateToResource` (2), `UploadDocument` (5), `RecordQualification` (3),
`CreateAction` (4), `ArchiveObject` (5). Pour les quatre dernières les lecteurs sont **exclusifs**
(un seul porteur possible), donc le `break` est sans effet. Pour la première ils sont **cumulatifs**
— d'où I-02. ⚠️ Le motif est fragile : la prochaine ligne à deux agences réelles rouvrira le trou,
et rien dans le fichier ne dit que les lecteurs doivent être exclusifs.
correction : accumuler les agences et appeler `exigeDroit` pour chacune ; écrire en commentaire que
plusieurs lecteurs = plusieurs droits exigés.

---

**I-04 · Quatre aides SQL partagées interpolent un nom de table sans le valider.**
Cible **CODE** · famille **I** · **moyenne** ·
preuve : `kernel.ts:124` (`exigeRef`), `kernel.ts:166` (`libelleRef`), `cycle.ts:125`
(`codeCategorie`), `cycle.ts:145` (`appliquerTransition`) — `` `… FROM ${table} …` ``, aucune
barrière. À comparer avec `agence.ts:152-155` et `admin.ts:28,177` qui, eux, valident.
reproduire : `grep -rnE "(SELECT|UPDATE) .*[$][{]" server/src` puis remonter chaque appelant :
`grep -rn "exigeRef(\|etatDe(\|codeCategorie(\|appliquerTransition(" server/src`
prétend : rien dans L4 — c'est une lecture de défense en profondeur.
mesure : **les 37 appels sont des littéraux**, donc **rien n'est exploitable aujourd'hui** ;
j'ai vérifié les 23 `exigeRef`, les 9 `etatDe`, les 25 `codeCategorie` et les 5
`appliquerTransition`. ⚠️ Mais la défense repose sur une **convention** : le jour où quelqu'un
écrira `exigeRef(ctx, ctx.entree.referentiel, …)` — ce qui est exactement ce que fait déjà
`ManageRefs` avec sa propre barrière — il n'y aura rien pour l'arrêter, et la revue ne verra
qu'un appel de plus. Le code a déjà la fonction qu'il faut (`ident()`), elle est juste au mauvais
endroit.
correction : exporter `ident()` depuis `kernel.ts` et l'appeler dans les quatre aides. Coût : 4 lignes.

---

**I-05 · L'identifiant de session est une adresse e-mail en clair dans un en-tête HTTP.**
Cible **CODE** · famille **I / K2** · **moyenne** *(déclaré lot 2c)* ·
preuve : `securite4/acces4.txt` — `x-ava-groupe: adm@ava.test` → la commande passe en ADM.
`executer.ts:62-73` : `WHERE lower(c.email) = lower($1) AND c.actif`.
prétend : grille **K2** — « le jeton est aléatoire, haché, expirant (D-10) ».
mesure : ✅ la moitié du contrôle tient — l'UUID d'un compte **n'est pas** une session
(`DROIT « compte inconnu ou inactif »`). ⛔ L'autre moitié n'existe pas : connaître une adresse
e-mail suffit à être n'importe qui, sans mot de passe, sans expiration, et l'en-tête voyage en
clair. ⭐ Le serveur l'assume à voix haute : hors banc, tout rend
`authentification non livrée (lot 2c)` et **aucune** route ne répond. C'est donc une dette
**bornée par K1**, pas une faille ouverte — à condition que personne ne lance le serveur avec
`AVA_MODE=banc` ailleurs que sur un poste.
correction : lot 2c (D-10). ⛔ D'ici là : ne jamais publier le port, et ne jamais poser
`AVA_MODE=banc` sur une machine partagée. Le fait que `app.listen({ host: "127.0.0.1" })` soit
codé en dur (`index.ts:312`) est la bonne décision et doit rester.

---

**I-06 · bien fait (bonne).**
**Le périmètre par objet existe, il est lu dans une table, et il tient** : 40 sondes hors agence
refusées, 25 témoins positifs, sur les 55 commandes — les trois trous du 3ᵉ audit et les cinq du
2ᵉ sont fermés, et c'est un progrès qu'aucune des deux passes précédentes n'avait obtenu.
**Hors banc, rien ne répond** : 10 routes sur 11 en 401, vues et fiche comprises, statique et 404
compris, **et plus aucune trace écrite** (V-078 fermé) — mesuré sur les compteurs, pas sur le
code. **Les valeurs passent toujours en `$n`** ; le seul identifiant qui vienne de l'utilisateur
(`ManageRefs`) passe deux barrières dont une qui interroge `pg_class`. Les **tests** eux-mêmes
valident leurs identifiants et refusent une clause avec un quote. Les GRANT sont mesurés par ce
qu'on **atteint**, et ils sont vides là où ils doivent l'être, sur `ava_app` **comme** sur
`ava_serveur` ; les deux murs les plus chers (M-6, M-14) répondent au geste direct.
**Aucun secret versionné**, nulle part, y compris dans la CI. **Le front est propre à l'œil** :
631 lignes, aucune règle métier, aucun libellé d'état, tout vient du serveur.
Et `verif_serveur.sh` est ce qui manquait le plus : un outil qui **mesure** `pg_hba` au lieu de
le promettre, et qui sépare le poste de dev par une variable déclarée plutôt que par une
exception silencieuse.

---

# ANGLES MORTS

⭐ **Ce que je n'ai PAS mesuré, et pourquoi. À lire avant de conclure quoi que ce soit de ce rapport.**

| # | Angle mort | Pourquoi | Ce que ça pourrait cacher |
|---|---|---|---|
| 1 | **Les espèces C GESTE et D ÉCRAN** (8 portes) | Playwright exige `web/dist`, donc un `npm run build` **dans le clone de lecture** — ma consigne interdit de modifier un fichier | une capture qui ne correspond plus, un geste cassé ; la case 1 du cliquet le verrait, moi non |
| 2 | **`outils/cliquet.sh` et `outils/make.sh` en exécution** | interdits par ma consigne. Je les ai **lus** et j'ai rejoué leurs recettes à la main (migrations, fixture, assertions, 8 fichiers de contrat) | une case du cliquet qui se comporte autrement que ce que son code dit ; un effet de `trap`/`stop_server` |
| 3 | **La CI réelle** | les deux secrets GitHub sont invisibles à un auditeur ; aucun run n'est consultable depuis le dépôt | une CI qui n'a jamais tourné au vert, ou qui saute le cliquet faute de secrets (le workflow prévoit justement de s'arrêter proprement dans ce cas) |
| 4 | **Le dépôt de travail et la base `ava`** | interdits. `core.hooksPath`, l'état réel des portes, et la présence d'une ligne `ref_pays.categorie='europe'` (mon hypothèse pour G-01) ne sont vérifiables que là | G-01 pourrait avoir une autre cause que celle que je propose ; F7 pourrait être ✅ chez lui |
| 5 | **`main` en tant que branche locale** | le clone est en HEAD détaché ; j'ai mesuré D1/D3/D5/F3/F12 contre **`origin/main`** — c'est le secours que `cliquet.sh` prend lui-même, mais ce n'est pas exactement ce que la grille écrit | rien de probable ; les deux références pointent le même commit |
| 6 | **Les 4 assertions L7 en moins quand un mur tombe** | A2 prouve que la suite **tombe**, pas qu'elle tombe pour **chacun** des 15 murs. Je n'ai cassé que `tg_m10` | un mur dont l'assertion ne mord pas ; il faudrait 15 contre-tests, pas 1 |
| 7 | **La concurrence** | toutes mes sondes sont séquentielles | `nextRef` prend un `pg_advisory_xact_lock` ✅, mais l'unicité de positionnement, le plafond journalier et la garde de couverture sont des `SELECT` puis `INSERT` — deux requêtes simultanées peuvent les franchir toutes les deux. Les murs M-2 et M-11 sont censés rattraper ; **non mesuré** |
| 8 | **Le volume** | `_ops/JEU_ESSAI.sql` (5 agences, 2 580 sociétés, 21 000 personnes) est **chargeable** mais je ne l'ai pas chargé : il `TRUNCATE` le métier et aurait effacé mes objets de sonde | un `GET /vues/besoins` sans pagination réelle (`pagination.libelle` = le compte total), une garde en `count(*)` qui s'effondre à 21 000 lignes |
| 9 | **Ma propre contamination** | j'ai posé 7 permissions absentes du seed pour jouer les gardes. C'est ce qui a révélé **G-02** — mais ça veut dire que mes tours 2+ ne mesurent plus le seed | les 7 portes rouges du second tour sont **ma** conséquence, pas un défaut spontané ; le défaut est qu'elles y soient sensibles |
| 10 | **L'écran d'administration de `SetPolicy`** | §C-5 veut la politique « signalée **en rouge** » ; il n'y a pas d'écran d'administration dans `web/src` (5 composants : Tuyau, Cadre, ListeBesoins, FicheBesoin) | la sortie `commandes_affectees` est juste et **personne ne la lit encore** |
| 11 | **`reprise_boond`** | table présente, aucune commande L4 ne la touche, aucune porte | le chemin par lequel des `agence_id` NULL entreront en masse — exactement I-01 |
| 12 | **Le mur d'indépendance a marché, et il coûte** | je n'ai lu ni `PLAN_*`, ni prompts, ni journaux de bugs, ni `REMARQUES`, ni `ARBITRAGE_*` | certains de mes constats sont peut-être déjà arbitrés ailleurs (H-1 en particulier : « 4 permissions sans titulaire » peut être une décision que je n'ai pas le droit de lire) |
