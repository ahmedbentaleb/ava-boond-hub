# GRILLE5 — les contrôles de `_ops/GRILLE_AUDIT.md`, un par un

**Cinquième audit · commit `b6ff087` · branche `lot-2` (HEAD détaché).**
Clone de lecture `ava-audit-5-lecture`, base `ava_audit5_b`, serveur `:3502`.
⛔ `outils/make.sh` et `outils/cliquet.sh` **non lancés** (consigne) : leurs recettes ont été
rejouées à la main, et `cliquet.sh` a été **lu** ligne par ligne.

Preuves : `grille5/compte_controles.txt` · `assertions_A1.txt` · `assertions_A2.txt` ·
`famille_A3_A5_front.txt` · `comptes_B.txt` · `famille_C.txt` · `famille_DF.txt` ·
`famille_F.txt` · `migrations_009.txt`.

## LE COMPTE DES CONTRÔLES — ⛔ l'en-tête se trompe

```
mesuré : grep -oE '^\| \*\*([A-KF][0-9]+)\*\*' _ops/GRILLE_AUDIT.md
A=5  B=5  C=5  D=5  E=5  F=13  K=5     →  43 contrôles · 7 familles
en-tête ligne 6 : « 42 contrôles · 7 familles »
en-tête de F    : « 11 contrôles (F1 → F11) »   (le tableau en porte 13 : F1…F13)
```

**43, pas 42.** Les familles sont bien 7. F porte **13** contrôles, pas 11 : F12 et F13 ont été
ajoutés sans relever les deux en-têtes. Et `outils/cliquet.sh` n'a que **12 cases**.

## VERDICT

| | |
|---|---|
| 🔴 | **1** — **K4** (le périmètre par objet fuit sur l'agence nulle, voir SECURITE5 **I-11**) |
| 🟠 | **6** — B1 · D3 · **D5** · F7 · F13 *(la règle, pas le fait)* · K2 |
| 🟡 | **1** — D4 |
| ✅ | 35 |

⛔ **Un seul 🔴 refuse le lot entier** (règle de la grille). **LOT 2 — REFUSÉ.**

---

## A · LA PREUVE — 5/5 ✅

| # | Verdict | Preuve mesurée |
|---|---|---|
| **A1** | ✅ | `cmp _ops/SPEC_ASSERTIONS_L7.sql test/SPEC_ASSERTIONS_L7.sql` → **identiques**. `bash outils/plancher_assertions.sh` → **32**. Le canon joué sur `ava_audit5_b` : `rc=0`, **32 lignes `OK   M-`** = 32/32. *(`make test` interdit : la recette a été rejouée — migrations 001→009, `db/fixtures/banc.sql`, puis le fichier d'assertions)* |
| **A2** | ✅ | ⭐ **élargi à 3 murs** (le 4ᵉ audit n'en cassait qu'un) : `DROP TRIGGER tg_m10` → `rc=3`, 18/32 ; `tg_m12` → `rc=3`, 23/32 ; `tg_m6` → `rc=3`, 6/32. Triggers remis, témoin **32/32**. Les assertions **mordent** |
| **A3** | ✅ | `ci.yml:50 fetch-depth: 0` · `:55 git branch -f main origin/main` · `:97 bash outils/cliquet.sh`. `db.yml` n'existe pas |
| **A4** | ✅ | `python _ops/outils/dossier.py` → `rc=0`, « OK · 109 fichiers ». ⚠️ Il réécrit `_ops/DOSSIER.html` — **restauré par `git checkout --`**, le clone est reparti propre. ⭐ Faux soupçon écarté : `assertions=31` chez lui n'est pas une divergence — il compte les **tests** (31 appels `t.doit_*`), le plancher compte les **lignes attendues** (31 + 1 contre-test = 32) |
| **A5** | ✅ | `audit/` : 18 fiches, dont `E1.md` → `E7.md` |

---

## B · LE PARAMÉTRAGE — 4 ✅ · 1 🟠

| # | Verdict | Preuve mesurée |
|---|---|---|
| **B1** | 🟠 | **5 occurrences, lues une par une** (⛔ jamais comptées) — voir le détail ci-dessous, + **1 que le grep de la grille ne voit pas** |
| **B2** | ✅ | `SELECT count(*) FROM politique` → **173**. Registre §C recompté : **172** en tableau + 1 en prose (`ui.theme.personnalise`) = **173** |
| **B3** | ✅ | `WHERE valeur <> valeur_defaut` → **0** |
| **B4** | ✅ | `count(*) … tablename LIKE 'ref\_%'` → **40** = registre §E |
| **B5** | ✅ | ⭐ Mesuré **en base**, pas dans les fichiers : 2 CHECK seulement portent une liste de codes — `perimetre.ck_x6` (justifié D-9, étendu à `soi` par 008) et `personne_coordonnee` (`reseau_social` ⇔ `reseau`, structurel). Les CHECK de `006` (`type_code`, `usage_code`, `statut_code`) ont bien été **remplacés par des FK en 007** : ils ne sont plus là |

**Les 5 occurrences de B1, relues :**

| Emplacement | Ce que c'est | Verdict |
|---|---|---|
| `droits.ts:32` `type_code === "global" \|\| "soi"` | **type de périmètre**, figé par un CHECK (M-13) | ✅ structurel |
| `droits.ts:62` `type_code !== "soi"` | idem | ✅ structurel |
| `index.ts:207` `type_code === "global"` | idem | ✅ structurel |
| `identite.ts:215` `extType?.categorie === "externe"` | ⚠️ **catégorie métier écrite en dur** | 🟠 |
| `identite.ts:241` idem | 🟠 |

⛔ **Et une sixième que le grep de B1 ne peut pas voir** : `agence.ts:204` porte
`WHERE … AND p.type_code = 'global'` **dans une chaîne SQL**. Le grep de la grille cherche
`=== '…'` en TypeScript ; un littéral métier passé en SQL lui échappe entièrement. ⭐ C'est
structurel ici, donc pas un défaut — mais **le contrôle B1 a un angle mort**, et il grandira
avec le SQL.

---

## C · LES MURS — 5/5 ✅

| # | Verdict | Preuve mesurée |
|---|---|---|
| **C1** | ✅ | `grep -rn "tenant" db/` → **3 lignes, toutes des commentaires** de 001 qui expliquent l'absence. Aucune colonne |
| **C2** | ✅ | `has_table_privilege` sur **toutes** les relations de `ava` : `ava_app` → **0 ligne** DELETE/TRUNCATE. ⭐ Recontrôlé aussi sur `ava_serveur` → **0 ligne**. `ava_app`, `ava_lecture_agregats`, `ava_migration` sont **NOLOGIN** ; `ava_serveur` n'est pas superutilisateur et `index.ts:309-317` refuse de démarrer s'il l'était |
| **C3** | ✅ | Aucun `UPDATE` atteint sur `evenement_metier`, `snapshot_marge`, `prestation_version` — ni pour `ava_app` ni pour `ava_serveur`. Éprouvé **par le geste** : `UPDATE snapshot_marge SET marge=0` → `ajout seul (MUR M-6)` |
| **C4** | ✅ | `ava_lecture_agregats` atteint **exactement 7 relations** : `politique`, `ref_devise`, `ref_pays`, et les 4 `v_*_par_devise`. Mesuré par `has_any_column_privilege` sur tout le schéma |
| **C5** | ✅ | Les 7 murs-triggers sont là : `tg_m4_m14` (M-4 **et** M-14), `tg_m6`, `tg_m7`, `tg_m10`, `tg_m12` (×4 tables), `tg_ajout_seul`. 70 triggers non internes au total |

---

## K · L'ACCÈS — 3 ✅ · 1 🔴 · 1 🟠

| # | Verdict | Preuve mesurée |
|---|---|---|
| **K1** | ✅ | Serveur relancé **sans `AVA_MODE`** sur `:3502`, **13 routes** sondées : `/sante` → 200, **tout le reste → 401** — vues, fiche, `/tuyau`, `/acquitter`, commandes, `/`, `/besoins`, `/index.html`, 404. ⭐ **V-078 fermé, recompté** : `besoin 2→2`, `evenement_metier 35→35`, `tentative_refusee 77→77`, `societe 1→1`, 0 société « PIRATE ». Un seul garde (`index.ts:114-125`), aucune route ne décide d'elle-même |
| **K2** | 🟠 | La moitié tient : l'**UUID** d'un compte envoyé comme session → `DROIT « compte inconnu ou inactif »` ; aucun en-tête → `DROIT « session absente »` ; témoin e-mail → `ok`. ⛔ L'autre moitié n'existe pas : **l'identifiant EST l'adresse e-mail, en clair** — pas de jeton, pas de hachage, pas d'expiration (D-10 non livré). Voir SECURITE5 **I-15** |
| **K3** | ✅ | `UPDATE compte SET actif=false` → `DROIT « compte inconnu ou inactif »`, `besoin 2→2`. Réactivé → `ok=true` |
| **K4** | 🔴 | La table existe et couvre les **55** (`agence.ts CORRESPONDANCE` = 55 lignes = 55 handlers = 55 permissions). **46 sondes hors agence sur 42 commandes distinctes → `DROIT`, 46/46** ; **6 témoins positifs → `ok`**. ⛔ **Mais sur un objet dont `agence_id` est NULL, trois commandes écrivent hors périmètre** — `CreateAction`, `UploadDocument`, `ArchiveObject` : mesuré, un compte de LON a **archivé** un candidat qui n'était pas dans son périmètre. Voir SECURITE5 **I-11** |
| **K5** | ⚠️ | `bash outils/verif_serveur.sh` → **rc=1** : 6 règles `trust`, `listen_addresses = *`, `ava_serveur` sans mot de passe. `AVA_POSTE_DEV=1` → **rc=0**. ⭐ L'outil **mesure** au lieu de promettre, et il nomme les lignes du `pg_hba`. Poste de dev assumé (V-022) ; **jamais mesuré sur un serveur** — il n'y en a pas. À décharge : les 6 règles ne visent que `(socket)`, `127.0.0.1`, `::1` |

---

## D · LE DÉPÔT — 3 ✅ · 1 🟠 · 1 🟡

⚠️ `main` **n'existe pas en local** dans le clone (HEAD détaché ; seuls `origin/main`, `origin/lot-1`,
`origin/lot-2`, `origin/lot-2-brain`). Mesuré contre `origin/main`, comme `cliquet.sh` le fait
lui-même en secours.

| # | Verdict | Preuve mesurée |
|---|---|---|
| **D1** | ✅ | `git diff --name-only origin/main HEAD -- _ops/` → **0 fichier**. ⭐ Le canon n'a pas bougé : c'est le contrôle le plus important de la grille, et il tient |
| **D2** | ✅ | Aucun ORM |
| **D3** | 🟠 | `git log --diff-filter=M -- db/migrations/` n'est **pas vide** : **`001_schema.sql` a été modifié dans 3 commits** — `f54c73b`, `98aae74`, `4b74720`. ⛔ Et c'est le contraire de ce que `009_unite_agence.sql` écrit de lui-même (« 001 → 008 sont publiées : on ne les réécrit pas ») |
| **D4** | 🟡 | **`REMARQUES.md` n'existe pas** — ni à la racine, ni ailleurs. La grille veut qu'il dise « aucune » plutôt que de manquer |
| **D5** | 🟠 | ⛔ **Compté, et il ne passe pas.** Sur les **157 commits** de `origin/main..HEAD` : **20 ne portent AUCUN trailer `Role:`** (tous à un seul parent, donc `commit-msg` aurait dû les refuser). **67 touchent `test/`**, dont **15 sans `Role: banc`** ; le crochet en excuse **4** (`d315808`, une fusion à 2 parents ; `ef4eb4a`, `87ef942`, `5fbf7b4`, qui ne touchent que `test/SPEC_ASSERTIONS_L7.sql`) — **11 restent en faute**, dont `3f70442` en `Role: ecran` sur `test/ecran/tuyau.spec.ts`. Constat **G-05** |

---

## E · L'ÉCRAN — 5/5 ✅ · et relu à l'œil

| # | Verdict | Preuve |
|---|---|---|
| **E1** | ✅ | vide |
| **E2** | ✅ | vide |
| **E3** | ✅ | vide |
| **E4** | ✅ | vide |
| **E5** | ✅ | un seul hit : `web/src/fonts/JetBrainsMono-Regular.woff2` — **fichier binaire**, faux positif du grep |

⭐ **Relu à l'œil, 1 130 lignes** (`contrat.ts` 165, `FicheBesoin.tsx` 139, `ListeBesoins.tsx` 107,
`Tuyau.tsx` 74, `rendu.tsx` 69, `Cadre.tsx` 52, `index.css` 499) : **aucun objet `LABELS`**, aucune
couleur hexadécimale dans le TSX, aucune règle métier. Les seuls ternaires portent sur des
**champs de forme** envoyés par le serveur (`champ.nature`, `cellule.sous`, `entree.courant`) —
c'est le serveur qui décide, l'écran met en page. Trois appels réseau : `/tuyau`, `/acquitter`,
`fetch(chemin)` pour les vues.

---

## F · LE CLIQUET — 11 ✅ · 2 🟠

⛔ `cliquet.sh` **lu, jamais lancé**. **12 cases**, mesurées une par une dans le code :
aucune ne se déclare, toutes se calculent. ⭐ **Case 1 refait la base à neuf** (`make.sh reset`,
D-20) **avant** de jouer les portes, sauf `AVA_RAPIDE=1` — et le commentaire dit explicitement
qu'on ne met jamais le chemin rapide dans un crochet. C'est la bonne décision : le « 12/12 » de
la veille était vrai sur une base qui traînait.

| # | Verdict | Preuve mesurée |
|---|---|---|
| **F1** | ✅ | `journal/PORTES.md` : **299 lignes `P-`**, colonnes Porte / Espèce / Phrase / Test / Vue rouge / État / Lot cible / Tolérance. **0 doublon de numéro** |
| **F2** | ✅ | Les **quatre** espèces tournent : `A BASE` 1 · `B CONTRAT` 290 · `C GESTE` 2 · `D ÉCRAN` 6 |
| **F3** | ✅ | ⭐ **294 portes servies** (✅) dans HEAD, **5 ⏳** — le chiffre annoncé « 294 » est **recompté juste**. `origin/main` en sert 5 ; **0 disparue**, numéro par numéro |
| **F4** | ✅ | 0 `skip`/`only`/`todo`/`xit`/`disabled` dans `test/` |
| **F5** | ✅ | **0 porte** sans date de vue rouge |
| **F6** | ✅ | Les 12 cases **mesurent**. Case 1 exige les trois conditions de V-008 : `make_rc = 0`, aucune porte ✅ en échec, aucun échec anonyme, **et chaque porte ✅ exécutée** (`non_jouees`). Case 2 exige `cmp` canon/copie **et** `n_ok ≥ plancher` compté dans le fichier |
| **F7** | 🟠 | `git config core.hooksPath` → **vide** dans le clone d'audit. `.githooks/commit-msg` et `.githooks/pre-push` existent et sont exécutables ; `pre-push` appelle bien `outils/cliquet.sh`. ⛔ **Non mesurable ici** : un clone neuf est toujours vide, c'est `outils/installer.sh` qui pose le chemin — et la case 12 du cliquet le vérifie |
| **F8** | ✅ | `ci.yml:97` → `bash outils/cliquet.sh`, **le même script**, pas une copie |
| **F9** | ✅ | La fonction `line()` imprime et compte ; **aucun `exit` avant la fin**. Les 12 lignes sortent même après un échec |
| **F10** | ✅ | **0 porte rétrogradée** ✅ → ⏳, numéro par numéro contre `origin/main` |
| **F11** | ✅ | **0 ⏳** au-delà du lot 2, et **0 ⏳ sans lot cible** |
| **F12** | ✅ | Fenêtre `merge-base(main, HEAD) → HEAD` ; **0 porte ✅ perdue** |
| **F13** | 🟠 | Le **fait** est vrai : `git merge-base --is-ancestor origin/lot-2-brain HEAD` → **oui**. ⛔ Mais la **règle** a deux trous, ci-dessous |

**F13 — la règle, pas le fait.** Deux mesures :

1. ⛔ **F13 n'est nulle part dans `cliquet.sh`** : `grep -n "lot-2-brain\|merge-base --is-ancestor" outils/cliquet.sh` → **rien**. Les 12 cases ne la connaissent pas, la CI ne la relance donc pas non plus. Une règle posée pour empêcher un faux départ n'existe que dans la tête de l'auditeur — c'est exactement ce que F6 interdit.
2. ⚠️ La commande écrite (`git merge-base --is-ancestor lot-2-brain HEAD`) **échoue dans un clone neuf** : `lot-2-brain` n'existe pas en local, seul `origin/lot-2-brain` est là. Elle rendrait « faux », donc « on n'audite pas », sur une branche parfaitement descendante.

---

## LES DEUX MIGRATIONS `009` — mesurées

Relevé par l'auditeur principal : `009_couverture_sans_archive.sql` **et** `009_unite_agence.sql`.

| Question | Mesure |
|---|---|
| **L'ordre réel** | `make.sh:151` fait `for f in db/migrations/*.sql` : l'ordre est **celui du glob, alphabétique** → `009_couverture_sans_archive.sql` **puis** `009_unite_agence.sql`. Identique en `LC_ALL=C` et en `sort -V` : aucun risque de bascule par la locale |
| **Ce que le registre enregistre** | `ava.schema_migrations (filename TEXT PRIMARY KEY, applied_at TIMESTAMPTZ)` — **le nom de fichier, et rien d'autre**. Les deux `009` prennent donc bien **deux lignes** distinctes et chacune ne joue qu'une fois. ⛔ **Aucune colonne de rang** : l'ordre appliqué ne se relit que par `applied_at`, et **le numéro ne l'identifie plus** |
| **Un ordre différent casserait-il la construction ?** | **Non.** Les deux fichiers n'ont **aucun objet en commun** : `couverture` remplace la vue `v_besoin_couverture` (besoin/projet/prestation) ; `unite_agence` remplace la fonction `unite_arbre()`, remplit `unite_organisation.agence_id` et pose `NOT NULL`. Vérifié **par le geste** : les deux rejoués **en ordre inverse** sur la base montée → `rc=0` les deux fois, et l'état tient (`unités sans agence = 0`, `pg_get_viewdef … LIKE '%archive_le%'` → `true`) |

⭐ **Donc : rien ne casse aujourd'hui.** ⚠️ **Mais le numéro a cessé d'être une clé** — `009` désigne
deux choses, le registre ne porte pas de rang, et la promesse de D3 (« numérotées ») est déjà
entamée par la réécriture de `001`. Constat **G-03** ci-dessous.

---

# LES CONSTATS DE GRILLE

---

**G-01 · L'en-tête de la grille annonce 42 contrôles ; elle en porte 43, et sa famille F en annonce 11 pour 13.**
Cible **BRAIN** · famille **grille** · **moyenne** ·
preuve : `grille5/compte_controles.txt`
```
grep -oE '^\| \*\*([A-KF][0-9]+)\*\*' _ops/GRILLE_AUDIT.md | wc -l   → 43
A=5 B=5 C=5 D=5 E=5 K=5 F=13
ligne 6   : « 42 contrôles · 7 familles »
ligne 136 : « ## F · LE CLIQUET — 11 contrôles (F1 → F11) »  (F1…F13 dans le tableau)
```
reproduire : la commande ci-dessus, puis `sed -n '6p;136p' _ops/GRILLE_AUDIT.md`.
prétend : la grille s'ouvre sur son propre compte, et c'est ce compte qu'un auditeur lit pour
savoir s'il a tout passé.
mesure : F12 et F13 ont été ajoutés (V-050, puis le 23/09 au soir) **sans relever les deux
en-têtes**. Un auditeur qui s'arrête à 42 saute un contrôle — et c'est justement F13, celui qui
décide si l'audit a le droit de commencer. ⚠️ Le fichier qui exige « ⛔ ne pas recopier le chiffre
ici » en B2 et B4 recopie le sien.
correction : remplacer les deux chiffres par la commande qui les compte, comme B2 et B4 le font
déjà pour les politiques et les référentiels.

---

**G-02 · F13 n'existe que dans la grille : le cliquet ne la mesure pas, et la commande qu'elle écrit échoue dans un clone neuf.**
Cible **BRAIN** · famille **F / F6** · **elevee** ·
preuve :
```
grep -n "lot-2-brain\|merge-base --is-ancestor" outils/cliquet.sh   → (rien)
grep -cE '^ *line [0-9]+ ' outils/cliquet.sh → 12 cases, numéros 1..12
git rev-parse --verify lot-2-brain        → échec (branche locale absente)
git rev-parse --verify origin/lot-2-brain → OK
git merge-base --is-ancestor origin/lot-2-brain HEAD → vrai
```
reproduire : les quatre commandes ci-dessus dans le clone d'audit.
prétend : grille **F13** — « ⛔ La branche auditée descend de `lot-2-brain` …
`git merge-base --is-ancestor lot-2-brain HEAD` → vrai. Sinon … l'audit les déclare ouverts
*(posé le 23/09 au soir : deux tours de suite ont commencé par ce faux départ)* ».
Et grille **F6** — « aucune case ne se déclare, toutes se calculent ».
mesure : la règle a été écrite pour arrêter une panne qui a coûté **deux tours**. Elle est posée
dans le document qu'un humain lit, pas dans le script qui mesure : **les 12 cases du cliquet ne
la connaissent pas**, la CI relance le même script (F8) et ne la connaît donc pas davantage.
⛔ Et la commande telle qu'elle est écrite rendrait « faux » sur cette branche même — qui
*descend* bien de `lot-2-brain` — parce qu'un clone n'a pas la branche locale. Le fait est bon,
la garde ne l'est pas.
correction : une case 13 dans `cliquet.sh`, calculée, qui résout la référence comme la case 3
résout `main` (`lot-2-brain` **sinon** `origin/lot-2-brain`, et « introuvable » = KO), et la même
résolution dans le texte de F13.

---

**G-03 · Deux migrations portent le numéro `009` ; le registre n'enregistre aucun rang, et `001` a été réécrit trois fois.**
Cible **BRAIN** · famille **D / D3** · **moyenne** ·
preuve : `grille5/migrations_009.txt`
```
ls db/migrations/*.sql | sed 's/_.*//' | uniq -c   →  1 001 … 1 008 · 2 009
ordre du glob (make.sh:151)  : 009_couverture_sans_archive.sql, puis 009_unite_agence.sql
registre (make.sh:140-143)   : schema_migrations (filename TEXT PRIMARY KEY, applied_at)
rejeu en ordre INVERSE        : rc=0 / rc=0 ; unités sans agence = 0 ; viewdef cite archive_le
git log --diff-filter=M -- db/migrations/ → f54c73b, 98aae74, 4b74720  (001_schema.sql)
```
reproduire :
```bash
for f in db/migrations/*.sql; do basename "$f"; done | sed 's/_.*//' | uniq -c
git log --diff-filter=M --oneline --name-only -- db/migrations/
psql -v ON_ERROR_STOP=1 --single-transaction -f db/migrations/009_unite_agence.sql
psql -v ON_ERROR_STOP=1 --single-transaction -f db/migrations/009_couverture_sans_archive.sql
```
prétend : grille **D3** — « Les migrations sont numérotées et jamais réécrites ».
`009_unite_agence.sql` écrit lui-même « ⛔ `001` → `008` sont publiées : on ne les réécrit pas ».
mesure : ⭐ **la construction ne casse pas** — les deux `009` ne partagent aucun objet, le glob
donne le même ordre sous toutes les locales, le registre les distingue par leur nom de fichier,
et les deux sont **rejouables dans les deux sens** (mesuré). ⚠️ **Mais le numéro a cessé d'être
une clé** : `009` désigne deux fichiers, `schema_migrations` ne porte **aucun rang**, donc l'ordre
appliqué n'est plus reconstituable autrement que par un horodatage. Et `001_schema.sql` **a été
réécrit dans 3 commits**, ce que D3 interdit et ce que `009` déclare ne pas faire. Deux
promesses tenues à voix haute, deux promesses fausses dans le dépôt.
correction : renuméroter l'une des deux en `010` (elles ne sont pas encore sur `main` :
`git diff origin/main HEAD -- db/migrations/` le dit), ajouter une colonne `rang SERIAL` au
registre, et — pour `001` — écrire l'ADR qui autorise sa réécriture, ou cesser de le faire.

---

**G-04 · `REMARQUES.md` n'existe pas.**
Cible **BRAIN** · famille **D / D4** · **moyenne** ·
preuve : `ls REMARQUES.md` → absent ; `find . -maxdepth 2 -iname 'REMARQUES*'` → rien.
reproduire : les deux commandes ci-dessus.
prétend : grille **D4** — « `REMARQUES.md` existe, même vide · il doit dire « aucune » plutôt que manquer ».
mesure : le contrôle est coté 🟡 par la grille, et il tombe depuis le premier lot. ⭐ Le motif
écrit dans la grille est bon : un fichier absent ne se distingue pas d'un fichier oublié. Là,
personne ne sait si le codeur n'avait rien à dire ou s'il ne l'a pas écrit.
correction : le créer avec « aucune », ou retirer D4 de la grille. ⛔ Le laisser tomber à chaque
tour, c'est apprendre à l'auditeur à ignorer un 🟡.

---

**G-05 · Le crochet `commit-msg` n'a jamais tourné sur une partie de la branche : 20 commits sans `Role:`, et 11 qui touchent `test/` sans être du banc.**
Cible **BRAIN** · famille **D / D5 · F7** · **moyenne** ·
preuve :
```
git rev-list origin/main..HEAD | wc -l                                   157
commits SANS aucun trailer Role:                                          20
   19237f6 2cf7300 5f9427b aa4da72 c9b3067 3b59ca5 8f1f0d4 466fe4e d028582
   6dc1e89 a47b8d7 eba309f 6031243 fc35217 781b810 01ecc9c 46bd3f1 bf7df47
   652bfba 1c80244        (tous à UN seul parent : ce ne sont pas des fusions)
commits qui touchent test/                                                67
   dont sans « Role: banc »                                               15
   excusés par le crochet                                                  4
      d315808 (fusion, 2 parents, Role: brain)
      ef4eb4a · 87ef942 · 5fbf7b4 (test/SPEC_ASSERTIONS_L7.sql SEUL, Role: brain)
   en faute                                                               11
      3f70442 Role: ecran  ->  test/ecran/tuyau.spec.ts, test/playwright.config.ts
      0e61751 bbf0e3a f42d0e3 2af4270 fa32680  Role: greffe, 1 parent
      c9b3067 a47b8d7 781b810 46bd3f1 bf7df47  aucun trailer
```
reproduire :
```bash
for c in $(git rev-list origin/main..HEAD); do
  r=$(git log -1 --format='%(trailers:key=Role,valueonly)' $c | tr -d '\n\r ')
  f=$(git show --name-only --format= $c)
  if printf '%s' "$f" | grep -q '^test/' && [ "$r" != banc ]; then
    echo "$(git log -1 --format=%h $c) role=${r:-∅} parents=$(git log -1 --format=%p $c | wc -w)"
  fi
done
```
prétend : grille **D5** — « Chaque dossier n'a qu'un seul auteur · chaque commit porte un trailer
`Role:` ; un commit qui touche `test/` porte `Role: banc`, **et le crochet le refuse sinon**
*(V-060, 22/09)* ». Et `.githooks/commit-msg`, qui énumère lui-même ses deux seules exceptions.
mesure : ⭐ **le crochet est juste** : je l'ai lu, il exige le trailer, il exige `banc` sur `test/`,
et il écrit ses exceptions au lieu de les taire. ⛔ **Mais il n'a pas tourné sur 20 commits**, et
11 autres passent `test/` sous un rôle qu'il refuserait aujourd'hui. C'est cohérent avec **F7** :
`core.hooksPath` est posé par `outils/installer.sh`, donc sur un clone neuf — ou avant D-13, le
22/09 — **rien ne s'exécute**. ⚠️ Le contrôle D5 mesure donc l'histoire d'un dépôt où la règle est
arrivée après coup, et il n'a aucun moyen de le dire.
⚠️ Et la case 12 du cliquet vérifie que le crochet **est posé aujourd'hui** ; elle ne relit
jamais les commits déjà faits. La règle protège l'avenir, pas ce qui est déjà dans l'historique.
correction : décider — soit D5 ne juge que les commits **postérieurs à `d272388`** (l'arbitrage
qui pose D-13) et le dit, soit le dépôt porte un `.mailmap`-like qui excuse l'antériorité. ⛔ Le
laisser rouge sans explication apprend à l'ignorer, exactement comme D4.

---

**G-06 · bien fait (bonne).**
⭐ **Le cliquet refait la base avant de juger** (case 1, D-20), et le script dit pourquoi : un
« 12/12 » sur une base qui traîne ne prouve rien. C'est la correction la plus solide de ce tour,
parce qu'elle attaque la **méthode**, pas un symptôme.
⭐ **A2 élargi** : trois murs cassés au lieu d'un, trois fois `rc=3`, témoin 32/32 — les
assertions mordent vraiment, et pas seulement sur `tg_m10`.
⭐ **Les 294 portes servies sont recomptées juste**, numéro par numéro, et **aucune n'a
disparu ni été rétrogradée** depuis le départ de la branche. Les quatre espèces tournent.
⭐ **`_ops/` n'a pas bougé d'un octet** vs `origin/main` (D1, le contrôle que la grille dit le plus
important). Et le crochet `commit-msg` qui exige `Role:` **écrit ses propres exceptions** au lieu
de les taire — c'est ce qui m'a permis de les compter au lieu de les deviner.
⭐ **B5 mesuré en base et non dans les fichiers** : les trois CHECK que 006 avait posés sont bien
devenus des FK en 007 — le grep seul aurait crié à tort.
⭐ **L'écran tient** : 1 130 lignes relues, zéro règle métier, zéro libellé d'état, zéro couleur
en dur dans le TSX, et les seuls ternaires portent sur de la forme envoyée par le serveur.
⭐ **`verif_serveur.sh`** nomme les lignes du `pg_hba` au lieu de promettre qu'elles sont bonnes,
et sépare le poste de dev par une variable **déclarée**.
