# GRILLE 7 — `_ops/GRILLE_AUDIT.md` passée en entier · commit `ba9a284`

**LOT 2 — REFUSÉ · 35 ✅ · 3 🔴 · 3 🟠 · 1 🟡 · 1 non mesurable ici — sur 43 contrôles comptés (l'en-tête en annonce 43 ✅).**
Hors verdict de contrôle : 3 🟠 de plus (deux cases du cliquet mal bâties, G-08 ; le jeu d'essai mort, G-11).
K4 tombe avec les droits du seed : la garde d'agence ne lit pas la même clé que la commande. B5 et F10 tombent aussi, mais sur mesure : les grep de la grille ne les voient pas.

```
LOT 2 — REFUSÉ · 3 🔴 · 3 🟠 · 1 🟡
K4   7 commandes écrivent hors agence avec les droits du seed (SECURITE7 I-01 → I-06)
B5   2 listes d'états figées en CHECK (013), invisibles au grep de la grille
F10  P-062 → P-065 passées de ✅ à ⏳ sur la branche ; le cliquet ne compare qu'à main
→ la liste complète : GRILLE7 G-01 → G-11, SECURITE7 I-01 → I-11, CONFORMITE7 H-01 → H-06
```

| Famille | Contrôles comptés | ✅ | 🔴 | 🟠 | 🟡 | non mesuré ici |
|---|---|---|---|---|---|---|
| A · preuve | 5 | 4 | — | A4 | — | A1 : partiel (voir A1) |
| B · paramétrage | 5 | 3 | B5 | B1 | — | — |
| C · murs | 5 | 5 | — | — | — | — |
| K · accès | 5 | 3 | K4 | — | — | K5 (VPS) |
| D · dépôt | 5 | 3 | — | D3 | D4 | — |
| E · écran | 5 | 5 | — | — | — | — |
| F · cliquet | **13** (l'en-tête de F en annonce 11) | 12 | F10 | — (G-08 : cases 5 et 10) | — | F6 lu, non lancé |
| **Total** | **43** | **35** | **3** | **3** | **1** | **1** |

⭐ Le compte : `grep -cE '^\| \*\*[A-Z][0-9]+\*\* \|' _ops/GRILLE_AUDIT.md` = **43** (A5 B5 C5 K5 D5 E5 **F13**) — preuve `grille7/controles.txt`.

---

## A · LA PREUVE

| # | Verdict | Preuve mesurée |
|---|---|---|
| **A1** | ✅ assertions · ⚠️ `make test` non lancé | migrations 001 → 014 rc 0 (`grille7/migrations.txt`) ; `test/SPEC_ASSERTIONS_L7.sql` = `_ops/` (`cmp`) ; **41 lignes `OK   M-` = plancher 41** (`plancher_assertions.sh`) — sur base neuve et encore 41 sur la base salie par mes sondes (`A1_assertions.txt`, `A1_assertions_apres.txt`). Les portes contrat/geste/écran n'ont pas tourné : `make.sh` interdit. |
| **A2** | ✅ | `DROP TRIGGER tg_m10` → l'assertion lève à la ligne 347 « LE GESTE EST PASSÉ », rc 3 ; trigger remis (`pg_get_triggerdef`), 41 OK — `A2_sabotage.txt` |
| **A3** | ✅ | `.github/workflows/ci.yml` : `fetch-depth: 0`, `main` posé en local, `verif_trailers.sh`, `installer.sh`, puis `bash outils/cliquet.sh` |
| **A4** | 🟠 | `dossier.py` joué **sur une copie** de `_ops/` (scratchpad) : il crie « ⚠️ ECART : le SQL crée 34 référentiels, le registre en compte 72. Un des deux ment. » — `A4_dossier.txt` (G-01) |
| **A5** | ✅ | `audit/` : `E1.md` → `E7.md` + 9 fiches `L2-*` |

## B · LE PARAMÉTRAGE

| # | Verdict | Preuve mesurée |
|---|---|---|
| **B1** | 🟠 | 3 grep de la grille + un 4e (`=== "…"`) lus un par un — `B1.txt`. Les comparaisons à une **valeur de politique** ou à une **catégorie** sont légitimes. Restent en dur : G-02 (codes de couverture), G-03 (requalification par numéro d'ordre), SECURITE7 I-04 (`SOI_MEME`) et I-06 (`TransferContact`), CONFORMITE7 H-06 (gardes d'`ArchiveObject`). |
| **B2** | ✅ | `count(politique)` = **201** ; tableau §C = **200** clés + `ui.theme.personnalise` en prose = 201 ; différence ensembliste base/registre : **exactement** cette clé — `B2_B3_B4.txt` |
| **B3** | ✅ | `valeur <> valeur_defaut` : 0 au seed ; la seule ligne vue ensuite est `candidat.conversion.acteur`, posée par moi (S3, déclaré) |
| **B4** | ✅ | `ref_*` en base = **72** = registre §E « 72 au 24/09 au soir » ; 73 noms cités au registre, l'écart est `ref_theme`, déclaré retiré |
| **B5** | 🔴 | Le grep de la grille ne rend que des lignes justifiées ou retirées (`perimetre.type_code` D-9 ; `contact.statut_code`, `personne_coordonnee.*`, `paiement.etat_code` retirés — mesuré en base). **Mesuré en base** (`B5_base.txt`) : `envoi_email_destinataire.etat IN ('en_attente','envoye','echec')` et `preparation_paie.etat IN ('brouillon','figee','exportee')` — **deux machines d'état figées en CHECK, le motif exact de V-121**, absentes du registre ; le grep les rate parce que la colonne s'appelle `etat` et non `*_code` (G-04). |

## C · LES MURS

| # | Verdict | Preuve mesurée |
|---|---|---|
| **C1** | ✅ | `grep -rn tenant db/` : 3 lignes, **toutes des commentaires** (001:34, :39, :1368) |
| **C2** | ✅ | requête de la grille → **0 ligne** ; `pg_stat_activity` pendant une commande : `ava_serveur`, `rolsuper = f` — `C.txt` |
| **C3** | ✅ | même requête, volet UPDATE → 0 ligne |
| **C4** | ✅ | exactement 7 relations : `politique`, `ref_devise`, `ref_pays`, les 4 `v_*_par_devise` |
| **C5** | ✅ | `tg_m4_m14`, `tg_m6`, `tg_m7`, `tg_m10`, `tg_m12` (×3 tables), `tg_ajout_seul` présents (`C.txt`) |

## K · L'ACCÈS

| # | Verdict | Preuve mesurée |
|---|---|---|
| **K1** | ✅ | serveur **sans** `AVA_MODE` : 56 POST → 401 ; `/vues/*`, `/tuyau`, `/acquitter`, `/`, `/%73ante`, `/SANTE`, `/sante/../vues/besoins`, HEAD, OPTIONS → 401 ; `/sante` → 200 ; **0 table modifiée**, rien tracé — `securite7/s8_hors_banc.txt` |
| **K2** | ✅ (réserve) | UUID de compte en en-tête → `DROIT` ; sans en-tête → `DROIT`. ⚠️ En banc l'en-tête **est** un identifiant de compte (l'email) : le jeton D-10 n'existe pas (lot 2c) |
| **K3** | ✅ | `eval` désactivé : `CreateAction` → `DROIT`, 0 écriture ; vue → 403 |
| **K4** | 🔴 | la table existe et couvre les **55** commandes servies (0 manquante) ; 52 sondes directes → `DROIT` ✅ ; mais **7 commandes écrivent hors agence** par une clé que la garde ne lit pas, **avec les droits du seed** — SECURITE7 I-01 → I-06 |
| **K5** | ⚠️ non mesuré | `verif_serveur.sh` sur le poste de dev : KO (6 `trust`, `listen *`, `ava_serveur` sans mot de passe) ; OK avec `AVA_POSTE_DEV=1`. Le VPS n'est pas joignable d'ici — `securite7/K5_verif_serveur.txt` |

## D · LE DÉPÔT

| # | Verdict | Preuve mesurée |
|---|---|---|
| **D1** | ✅ | `git diff --name-only origin/main -- _ops/` → **0 fichier** (`main` n'existe pas en local dans le clone : mesuré contre `origin/main`) |
| **D2** | ✅ | 0 ORM dans `server/`, `test/`, `web/package.json` (pas de `package.json` racine) |
| **D3** | 🟠 | `git log --diff-filter=M origin/main..HEAD -- db/migrations/` → **2 commits de la branche réécrivent 001/002** : `4b74720` (23/09) et `d1776e3` (24/09, ajoute `ref_decision_client` dans 001 et son seed dans 002) — G-05 |
| **D4** | 🟡 | `REMARQUES.md` **absent** du dépôt (ni racine, ni `_ops/`, ni ailleurs) |
| **D5** | ✅ | `verif_trailers.sh origin/main` : OK, 200 commits, 29 antérieurs à D-29, 3 exceptions nommées |

## E · L'ÉCRAN

| # | Verdict | Preuve mesurée |
|---|---|---|
| **E1 → E4** | ✅ | grep vides — `E.txt` |
| **E5** | ✅ | une seule touche : `fonts/JetBrainsMono-Regular.woff2` (binaire, faux positif) |
| lecture à l'œil | ✅ | 631 lignes de `web/src` : aucun libellé d'état, aucun calcul, `PASTILLE` et `variante` sont du rendu. ⚠️ Côté serveur, `/vues/besoins` renvoie **le code** d'état comme libellé (`b.etat_code AS etat` → `libelle`) — E3 respecté à la lettre, pas dans l'esprit (G-06) |

## F · LE CLIQUET — `outils/cliquet.sh` lu, ⛔ non lancé

| # | Verdict | Preuve mesurée |
|---|---|---|
| **F1** | ✅ | `journal/PORTES.md` : **323 portes**, 323 numéros distincts, 10 champs par ligne (en-tête `Porte · Espèce · Phrase · Test · Vue rouge · État · Lot cible · Tolérance`) ; trou : **P-255** n'a jamais existé (`git log -S`) |
| **F2** | ✅ | les 4 espèces ont au moins une ✅ : A 1 · B 314 · C 1 · D 2 (sur 6) |
| **F3** | ✅ | 5 portes servies sur `origin/main`, toutes présentes et ✅ dans HEAD (case 3 + case 9) |
| **F10** | 🔴 | **P-062, P-063, P-064, P-065 : ✅ le 20/09 (`6dc1e89`) → ⏳ le 21/09 (`b2b7d1e`)** — mesuré commit par commit. Couvert par la décision D-020 (journal), pas par un ADR. ⛔ Et **le cliquet ne peut pas le voir** : la case 9 ne compare qu'à `main`, la case 11 ne vérifie que la **présence** — G-07 |
| **F11** | ✅ · 🟠 case | 5 ⏳ (P-061 → P-065), lot cible 3 > lot courant 2. ⚠️ La case 10 lit `$7`/`$8` **par position**, **ignore une ⏳ sans lot cible** (le « parking » que F11 interdit) et transforme « 5.8 » en 58 — G-08 |
| **F4** | ✅ | 20 touches, toutes lues : `ExitCandidate` (« xit »), `exitCode`, `toBeDisabled`, `animations: "disabled"` |
| **F5** | ✅ · 🟠 case | 323 dates de vue rouge au format `AAAA-MM-JJ`. ⚠️ La case 5 accepte **tout texte non vide** (pas une date) et lit la colonne `$6` par position — G-08 |
| **F6** | ✅ | 13 cases, toutes calculées ; la case 1 exige `make_rc=0`, aucune ✅ en échec, **et chaque ✅ exécutée** (V-008) ; `reset` avant les portes (D-20) |
| **F7** | ✅ | `.githooks/pre-push` → `exec bash outils/cliquet.sh` ; `installer.sh` pose `core.hooksPath` ; ⚠️ la case 12 vérifie `commit-msg`, pas `pre-push` ; `core.hooksPath` vide dans ce clone neuf (attendu) |
| **F8** | ✅ | la CI appelle `bash outils/cliquet.sh`, pas une copie |
| **F9** | ✅ | `set -u` sans `-e`, 13 appels `line`, sortie à la fin seulement |
| **F13** | ✅ | `git merge-base --is-ancestor origin/lot-2-brain HEAD` → vrai (pas de `lot-2-brain` local : la case 13 cherche `origin/`, bien) |
| **F12** | ✅ | 322 portes ✅ vues sur la branche depuis `afc1683` + `origin/main` : **toutes** présentes dans HEAD |

---

## Les constats

### G-01 · 🟠 A4 — `dossier.py` crie : SPEC_SQL crée 34 référentiels, le registre en compte 72
**Cible** `_ops/SPEC_SQL_AVAMANAGER_V1.sql` vs `_ops/REGISTRE_POLITIQUES_v1.md` §E · **Famille** A · **Preuve** `grille7/A4_dossier.txt` ·
**Reproduire** `cp -r _ops /tmp/x/_ops && python /tmp/x/_ops/outils/dossier.py` (⛔ jamais dans le dépôt : il réécrit `_ops/DOSSIER.html`) ·
**Prétend** A4 « ne crie pas » · **Mesure** « ECART : 34 / 72 » ; il affiche aussi `assertions=37` (41 comptées) ·
**Correction** la SPEC_SQL suit les migrations 012–014, ou le dossier compte la base plutôt que la SPEC.

### G-02 · 🟠 B1 — la couverture d'un besoin bifurque sur le **code**, pas sur la catégorie
`couverture === "fte" || couverture === "postes_et_fte"` (`server/src/commandes/besoin.ts:68`), `unite === "fte" ? … : unite === "postes_et_fte" ? …`
(`server/src/couverture.ts:23`). `ref_unite_couverture` a ses trois codes en catégorie `defaut` : la sémantique vit dans le code.
Un code ajouté par `ManageRefs` tombe silencieusement dans la branche « postes ». **Gravité** 🟠 · **Correction** catégories `postes`/`fte`/`postes_et_fte`, le code lit la catégorie.

### G-03 · 🟠 B1 — requalification d'une société par numéro d'ordre écrit en dur
`REQUALIF_ORDRE` (`server/src/cycle.ts:87-92`) et `actuelOrdre === 2 && viseOrdre === 1 && mode === "manuel"` (`server/src/commandes/crm.ts:103`) :
la machine du statut commercial est dans le code, adressée par la colonne `ordre` d'un référentiel administrable (`ManageRefs` réordonne → la machine change).
**Gravité** 🟠 · **Correction** transitions en catégories (comme les autres machines), ou en table.

### G-04 · 🔴 B5 — deux machines d'état figées en CHECK, invisibles au grep de la grille
| | |
|---|---|
| **Défaut** | `envoi_email_destinataire.etat CHECK IN ('en_attente','envoye','echec')`, `preparation_paie.etat CHECK IN ('brouillon','figee','exportee')` ; plus `envoi_email.nature`, `lien_outlook.nature`, `document_genere.format`, `calendrier_jour_non_ouvre.motif` |
| **Cible** | `db/migrations/013_applications_boond.sql:125`, `:188` |
| **Famille** | B5 |
| **Preuve** | `grille7/B5_base.txt` (`pg_constraint` : tout CHECK `= ANY (ARRAY[…])` hors `ref_*` et `ck_cat`) |
| **Prétend** | V-121 a retiré « la seule liste d'états sans référentiel » (`paiement`) |
| **Mesure** | il en reste deux, de la même espèce, écrites le même jour |
| **Correction** | `ref_etat_envoi`, `ref_etat_paie` + clés étrangères ; et le grep B5 cherche `CHECK *\(.*(IN|= *ANY)` sur **toute** colonne, pas seulement `*_code` |

### G-05 · 🟠 D3 — deux migrations déjà jouées réécrites sur la branche
`d1776e3` ajoute `ref_decision_client` à **001** et son seed à **002** ; `4b74720` modifie 001. `make.sh` saute un fichier « déjà joué » :
une base migrée avant le 24/09 n'a **pas** `ref_decision_client`, et `RecordClientDecision` y lèverait. **Preuve** `grille7/D.txt` ·
**Correction** une migration 015 qui crée ce que 001/002 ont reçu après coup, et 001/002 rendus à leur état d'origine.

### G-06 · 🟡 E3 — la vue « Besoins » envoie le code d'état comme libellé
`server/src/index.ts:232` (`b.etat_code AS etat`) puis `libelle: b.etat` ; pastille toujours `neutre`. Le front affiche `staffing`. **Correction** joindre `ref_etat_besoin.libelle`.

### G-07 · 🔴 F10 — quatre portes ✅ → ⏳ sur la branche, et le cliquet est aveugle à ce cas
| | |
|---|---|
| **Défaut** | P-062 → P-065 (écran, captures besoin) repassent ⏳ le 21/09. La case 9 ne regarde que les servies de `main` (5) ; la case 11 regarde la **présence**, pas l'**état**. |
| **Cible** | `journal/PORTES.md:73-76` · `outils/cliquet.sh` cases 9 et 11 |
| **Preuve** | `grille7/F_portes.txt` (transitions commit par commit) ; D-020 dans `journal/DECISIONS.md` |
| **Prétend** | F10 « numéro par numéro, pas par compte » |
| **Mesure** | ✅ `6dc1e89` (20/09 17:53 UTC) → ⏳ `b2b7d1e` (21/09 17:52 UTC) |
| **Correction** | la case 11 compare aussi l'**état** : toute porte ✅ vue sur la branche doit être ✅ dans HEAD, sauf ADR nommé dans une liste d'exceptions (comme `TRAILERS_EXCEPTIONS`) |

### G-08 · 🟠 F5 / F11 — deux cases lisent des colonnes par position et laissent passer ce qu'elles doivent refuser
Case 5 : `v=$6` — accepte « — » exclu, mais aussi « bientôt » ; F5 exige **la date**. Case 10 : `$7 ~ /⏳/` et `gsub(/[^0-9]/,"",$8)` — une ⏳
**sans lot cible passe**, « 5.8 » devient 58. La case 1 et la case 3 trouvent l'« État » par son **en-tête** (V-009) : ces deux-là non.
**Cible** `outils/cliquet.sh` cases 5 et 10 · **Correction** en-tête → colonne, date `^[0-9]{4}-[0-9]{2}-[0-9]{2}$`, ⏳ sans lot = KO.

### G-09 · 🟡 L'en-tête de la famille F annonce 11 contrôles, elle en porte 13
« F · LE CLIQUET — 11 contrôles (F1 → F11) » ; F12 et F13 sont dessous. Le total d'en-tête (43) est juste. **Cible** `_ops/GRILLE_AUDIT.md`, titre de F.

### G-10 · 🟡 La grille parle de `make up && make migrate && make test` et de `JOURNAL_BUGS.md`, `PROMPT_GROK_LOT1.md` ; `<etat>` date du 19/09 (« aucun lot encore audité »)
Informationnel. **Cible** `_ops/GRILLE_AUDIT.md` `<procedure>`, `<etat>`.

### G-11 · 🟠 `_ops/JEU_ESSAI.sql` ne se charge plus
`psql -v ON_ERROR_STOP=1 -f _ops/JEU_ESSAI.sql` → rc 3 à la ligne 208 : `societe.agence_responsable_id` est NOT NULL depuis 011, le jeu ne le remplit pas.
Le « banc simulé aux volumes réels » (et son usage de test du script de reprise) est mort depuis 011. **Preuve** `grille7/jeu_essai.txt` · **Cible** `_ops/JEU_ESSAI.sql:200-208`.

---

## ANGLES MORTS

1. **A1 incomplet** : les assertions L7 ont tourné (41/41) ; les portes contrat, geste et écran (`make test`) non — `make.sh` et `cliquet.sh` interdits. Le « 318 portes » n'est **mesuré que comme compte** (318 ✅ sur 323 lignes), pas comme exécution.
2. **F6** : lu, pas lancé ; la case 1 dépend d'un format de sortie (✔/✖, `P-XXX` dans le nom) que je n'ai pas vu tourner. Une ligne qui nomme deux portes compte les deux comme exécutées (`grep -oE 'P-[0-9]+'` sans `head`).
3. **K5** : le VPS.
4. **D1** : `main` absent en local, mesuré contre `origin/main` tel que récupéré dans ce clone.
5. **A4** : `dossier.py` a lu `git` depuis le scratchpad (commit affiché `b51278e`, pas `ba9a284`) : seuls ses comptes de fichiers valent.
6. **B1** : lu occurrence par occurrence dans `server/src` ; les littéraux de catégorie **dans le SQL** (`etat_categorie <> 'ferme'`…) ne sont pas dans le grep et n'ont pas été tous relus.
