# GRILLE10 — dixième audit, lot 2, commit `16ea24d` · auditeur B (base `ava_audit10_b`, port 4002)

> ⚠️ Numérotation : ce document garde les numéros de travail de son brouillon. Les constats rendus sont dans `CONSTATS.md` (V-162 → V-178), table de correspondance à la fin.


**43 contrôles comptés, 43 annoncés — 37 ✅ · 3 🟠 · 1 🟡 · 2 non mesurables sur ce poste. Aucun 🔴 mesuré.**
P-339 est ✅ au journal, jouée sous les 3 valeurs de `societe.perimetre.mode` (et les 2 de `staffing.inter_agences`) : **0 fuite sur 691 identifiants**, rejouée ici.

> Méthode : rien n'est cru. Chaque verdict a sa commande ou son fichier de preuve sous
> `rapport/preuves/grille10/`. ⛔ Ni `outils/make.sh` ni `outils/cliquet.sh` n'ont été lancés :
> `cliquet.sh` est **lu** (F6), les cases sont recalculées à la main.
> Base montée de zéro : `db/migrations/*.sql` dans l'ordre (registre `schema_migrations` + sha256
> posé dans la même transaction, comme `make.sh`), puis `db/fixtures/banc.sql`.

---

## 0 · Le compte

| Famille | Annoncé (titre) | Lignes comptées |
|---|---|---|
| A · La preuve | 5 | A1 → A5 = **5** |
| B · Le paramétrage | 5 | B1 → B5 = **5** |
| C · Les murs | 5 | C1 → C5 = **5** |
| K · L'accès | 5 | K1 → K5 = **5** |
| D · Le dépôt | 5 | D1 → D5 = **5** |
| E · L'écran | 5 | E1 → E5 = **5** |
| F · Le cliquet | 13 (« F1 → F13 ») | F1, F2, F3, F10, F11, F4, F5, F6, F7, F8, F9, F13, F12 = **13** |
| **Total** | **43 · 7 familles** | **43 · 7 familles** ✅ |

⚠️ L'en-tête dit « (A → F, et K) » : il y a bien 7 familles, mais l'ordre des lignes F n'est pas numérique (F10, F11 avant F4 ; F13 avant F12) — sans effet sur le compte.

---

## F · LE CLIQUET (passé en premier)

| # | Verdict | Preuve |
|---|---|---|
| F1 | ✅ | `journal/PORTES.md` : 347 lignes `P-`, toutes à 10 champs (en-tête `Porte · Espèce · Phrase · Test · Vue rouge · État · Lot cible · Tolérance`). |
| F2 | ✅ | Quatre espèces ✅ au journal : A 1 · B 338 · C 1 (+1 ⏳) · D 2 (+4 ⏳). `make.sh test` joue contrat **et** `npx playwright test` (geste + écran) — lu, non lancé. |
| F3 | ✅ | `origin/main` sert 5 portes ; 0 disparue de HEAD, 0 qui n'y serait plus ✅ (`preuves/grille10/f_cliquet_mesures.txt`). |
| F10 | ✅ | Histoire premier parent depuis `merge-base(origin/main, HEAD)` : 5 passages ✅→⏳ (P-062→P-065 @`b2b7d1e`, P-340 @`419f7b2`), **tous** déclarés au tableau D-35 de `_ops/PORTES_EN_ATTENTE.md` avec le même commit. |
| F11 | ✅ | 5 ⏳ (P-061 → P-065), toutes lot cible 3 ≥ lot courant 2. |
| F4 | ✅ | Le grep de la grille ne rend que des faux positifs (`ExitCandidate`, `exitCode`, `animations: "disabled"` de Playwright). Aucun `.skip/.only/todo/xit`. |
| F5 | ✅ | 0 ligne sans date de vue rouge. |
| F6 | ✅ (+ constat G-2) | `outils/cliquet.sh` lu : 19 cases, toutes calculées (aucune question posée) ; case 1 exige `make_rc=0` **et** chaque ✅ exécutée (comm de la liste ✅ contre les titres exécutés). ⚠️ cases 5 et 10 lisent les colonnes **par position** (`$6`, `$7`, `$8`) — voir G-2. |
| F7 | ✅ (lecture) | `outils/installer.sh` pose `core.hooksPath=.githooks` ; `.githooks/pre-push` et `commit-msg` présents ; la CI lance `installer.sh` avant le cliquet ; case 12 le vérifie. ⚠️ Dans le clone d'audit (neuf), `core.hooksPath` est vide — attendu. |
| F8 | ✅ | `.github/workflows/ci.yml` : `fetch-depth: 0`, `main` posé en local, `bash outils/verif_trailers.sh`, `bash outils/installer.sh`, `bash outils/cliquet.sh` — le même script. |
| F9 | ✅ | `set -u` sans `-e` ; chaque case passe par `line()` ; sortie après la case 19. |
| F13 | ✅ | `git merge-base --is-ancestor origin/lot-2-brain HEAD` → vrai (`c63fab8`). |
| F12 | ✅ | 352 ✅ vues sur la branche ; absentes de HEAD : P-333 → P-338, **toutes** déclarées retirées (D-41) et leurs portes gardées P-326 → P-331 sont ✅. |

### P-339 — la porte croisée (demande expresse)

| Mesure | Résultat |
|---|---|
| État au journal | **✅** (ligne 343), lot 2, tolérance « 0 fuite » — plus ⏳. |
| Canon = copie | `cmp _ops/PORTE_CROISEE.mjs test/contrat/porte_croisee.test.mjs` → identiques. |
| Passes | Construites par la porte : politiques lues dans `server/src/agence.ts` (`societe.perimetre.mode`, `staffing.inter_agences`), valeurs lues dans `politique.valeurs_possibles` → **5 passes** : `agence_responsable`, `par_besoins`, `partagee`, `non`, `oui`. |
| Rejouée ici (`preuves/grille10/p339_rejouee.txt`, détail `p339_detail.json`) | **57 commandes servies · 5 passes · 691 identifiants hors agence · 0 fuite · 0 autre code · 0 positif KO · 4 permis inter-agences · 0 permis refusé · rc=0**. |
| ⚠️ Première passe | **2 « fuites » fausses**, causées par MES sondes lancées en parallèle (elles écrivaient `ref_statut_commercial`, `societe`, `contact`) : conservée telle quelle, `preuves/grille10/p339_passe1_PARASITEE_*`. Voir G-3. |

⚠️ Nommage : la demande cite « P-340 comportements ». Au journal, **P-340** est la porte RES/STAF sur absence et document (`audit7.test.ts`) ; la porte des comportements est **P-352** (valeurs servies = `COMPORTEMENTS`), avec **P-350** (une branche par valeur) et **P-351** (la carte). Leurs trous sont dans CONFORMITE10 (H-2) et SECURITE10 (I-4).

---

## A · LA PREUVE

| # | Verdict | Preuve |
|---|---|---|
| A1 | ✅ partiel | Assertions L7 jouées sur base neuve : **41 `OK   M-` / plancher 41** (`bash outils/plancher_assertions.sh`), rc=0 ; `cmp test/ _ops/` identiques. Contrat : 57/57 positifs OK, P-339 verte. ⛔ `make test` complet (Playwright) **non lancé** (interdit au poste). |
| A2 | ✅ | `DROP TRIGGER tg_m10` puis assertions : rc=3, l'assertion lève « un temps saisi pour une autre ressource (M-10) — LE GESTE EST PASSÉ » ; 19 OK seulement (`preuves/grille10/a2_m10.txt`). Base reconstruite ensuite. |
| A3 | ✅ | `ci.yml` lu : `fetch-depth: 0`, `main` en local, `cliquet.sh`. |
| A4 | ✅ | `python _ops/outils/dossier.py` joué dans une **copie** (`git archive`, scratchpad) : OK, `politiques=202 · referentiels=75` ; seuls avertissements : les deux .docx non copiés. |
| A5 | ✅ | `audit/` : E1 → E7, plus 10 fiches L2-*. |

## B · LE PARAMÉTRAGE

| # | Verdict | Preuve |
|---|---|---|
| B1 | ✅ au grep · 🟠 hors grep (G-1) | 10 occurrences du grep A, 8 du grep B, 0 du grep C, **lues une à une** (`preuves/grille10/b1_et_hors_grille.txt`) : catégories fermées (`positive`, `negative`, `externe`), types de périmètre, routage web — pas de `if` métier sur un **code**. ⚠️ Le grep ne voit ni les littéraux SQL, ni les noms de commande, ni la sémantique portée par `ordre` → G-1 et CONFORMITE10 H-3. |
| B2 | ✅ | `select count(*) from ava.politique` = **202** ; registre §C : 201 en tableau + 1 en prose (`ui.theme.personnalise`) — la seule clé en base hors tableau. |
| B3 | ✅ | Base neuve : `valeur <> valeur_defaut` → 0 ligne. |
| B4 | ✅ | `ref_*` en base = **75** = registre §E. |
| B5 | ✅ | 9 CHECK à liste hors `ref_*`, tous justifiés au registre §D (`politique.type`, `politique.categorie`, `calendrier_jour_non_ouvre.motif`, `tentative_refusee.code`, `perimetre.type_code` ×2, `envoi_email.nature`, `document_genere.format`, `lien_outlook.nature`). |

## C · LES MURS

| # | Verdict | Preuve |
|---|---|---|
| C1 | ✅ | `grep -rn tenant db/` : 3 lignes de **commentaire** qui disent qu'il n'y en a pas. |
| C2 | ✅ | Requête de la grille : 0 ligne pour `ava_app` et pour `ava_serveur` ; `pg_stat_activity` pendant une commande : `ava_serveur` (`preuves/securite10/k2_k3_c2.txt`) ; le serveur refuse de démarrer en superutilisateur (code lu). |
| C3 | ✅ | `has_any_column_privilege(..., 'UPDATE')` = faux sur `evenement_metier`, `snapshot_marge`, `prestation_version`, `tentative_refusee`. |
| C4 | ✅ | `ava_lecture_agregats` atteint **exactement 7** relations : `politique`, `ref_devise`, `ref_pays`, les 4 `v_*_par_devise` ; 0 fonction SECURITY DEFINER exécutable. |
| C5 | ✅ | `tg_m4_m14`, `tg_m6`, `tg_m7`, `tg_m10`, `tg_m12` (×4 tables), `tg_ajout_seul` (×3), + `tg_m7_tentative`. |

## K · L'ACCÈS

| # | Verdict | Preuve |
|---|---|---|
| K1 | ✅ | Serveur sans `AVA_MODE` : 29 sondes, tout en 401 sauf `/sante` (et `POST /sante` mal formé → 400, sans écriture) ; JSON mal formé, `text/plain`, form-urlencoded, corps de 1,1 Mo → **401** ; empreinte (compte + md5) des 147 tables du schéma `ava` : **0 modifiée** (`preuves/securite10/hors_banc.txt`). |
| K2 | ✅ (jugé au lot 2c) | En banc, l'UUID d'un compte comme en-tête → `DROIT compte inconnu ou inactif` ; hors banc tout est 401. |
| K3 | ✅ | Compte `ia@` désactivé : commande → DROIT, lecture → 403, 0 événement écrit. |
| K4 | ✅ | `CORRESPONDANCE` dérive de `DECLARATION` : 57 lignes = 57 `HANDLERS` ; contractées mesurées `bash outils/compte_commandes.sh` = **100** (le lot 2 en sert 57) ; hors agence : P-339 ci-dessus. ⚠️ `HANDLERS[nom]` accepte aussi `constructor`, `toString`… → SECURITE10 I-2. |
| K5 | ⬜ non mesurable | `outils/verif_serveur.sh` se joue sur le VPS ; le poste est en `trust` assumé (V-093). |

## D · LE DÉPÔT

| # | Verdict | Preuve |
|---|---|---|
| D1 | ✅ | `git diff --stat origin/main HEAD -- _ops/` → vide. |
| D2 | ✅ | Aucun ORM dans `server/`, `web/`, `test/package.json`. |
| D3 | 🟠 (G-1) | La commande de la grille (`git log --diff-filter=M -- db/migrations/`) rend **5 commits** (`f54c73b` → `ddffd0a`, 20-25/09) ; `001_schema.sql` diffère de sa **première** version (`1a30280`). Les 5 migrations de `origin/main` sont identiques dans HEAD (critère D-40 de la case 15) ; les 17 suivantes n'ont jamais été modifiées. Le contrôle écrit ne mesure plus ce qu'il dit. |
| D4 | 🟡 | Aucun `REMARQUES.md` à la racine, ni sous `_ops/`, ni sous `journal/` (existence seule vérifiée — mur d'indépendance). |
| D5 | ✅ | `bash outils/verif_trailers.sh origin/main` : OK, 299 commits, 29 antérieurs à D-29 comptés non bloquants. |

## E · L'ÉCRAN

| # | Verdict | Preuve |
|---|---|---|
| E1 → E5 | ✅ ×5 | Les cinq greps rendent vide (E5 : seul binaire `.woff2`). Lecture à l'œil de `web/src` (631 lignes .ts/.tsx) : seuls branchements sur des **variantes de présentation** envoyées par le serveur (`variante`, `nature`, `cle`) ; aucun libellé d'état, aucun calcul d'argent. |

---

## Constats de la grille (famille · étendue mesurée · correction de construction + porte)

### G-1 🟠 — Les contrôles écrits par grep ne voient pas ce qu'ils prétendent voir
- **Famille** : un contrôle de la grille est une commande figée ; quand la forme de la faute change, il reste vert ou devient faux.
- **Étendue mesurée** : B1 ne voit pas **27 littéraux SQL** de codes et catégories métier dans les requêtes de `server/src` (42 littéraux au total, 15 techniques : catalogue, types de périmètre, banc) (`'ouvert'` inséré en code d'état, `'terminal_positif'`, `'engage'`, `'interne'`…), ni **3 noms de commande** testés dans la garde générique (`agence.ts:251` `CreateNeed`, `:326` `ArchiveObject`, `:420` `TransferContact`), ni la sémantique portée par `ref_statut_commercial.ordre` (prouvée cassante, CONFORMITE10 H-3) ; D3 rend 5 commits de réécritures antérieures à D-40, que la case 15 tolère.
- **Correction de construction** : chaque contrôle B/D de la grille devient une **porte du banc** dont la règle est structurelle (AST, catalogue PostgreSQL), pas un grep : « aucun littéral de code dans une requête », « aucune comparaison sur `ctx.commande` », « aucune lecture d'`ordre` hors tri d'affichage », « migrations de main = HEAD ».
- **Porte qui énumère la famille** : une porte qui parcourt l'AST de `server/src` et liste **toutes** les comparaisons (`===`, `IN (...)`, `= '...'`) dont un membre est un littéral ; chaque littéral doit être déclaré (catégorie fermée de `MACHINES_ETAT_V1.md`, type de périmètre, valeur de politique), sinon rouge.

### G-2 🟡 — Le cliquet lit deux colonnes par position
- **Famille** : V-009 exige que l'état d'une porte se lise par **en-tête** ; les cases 5 (`$6` vue rouge) et 10 (`$7` état, `$8` lot cible) lisent par **position**.
- **Étendue mesurée** : 2 cases sur 19 ; correctes aujourd'hui (347 lignes à 10 champs), fausses en silence au premier `|` dans une Phrase ou à la première colonne insérée — la case 10 rendrait alors OK sans rien lire.
- **Correction** : une seule fonction `colonne "<En-tête>"` (celle de `portes_etats`) pour toute lecture de `PORTES.md`.
- **Porte** : un test du cliquet qui lui donne un `PORTES.md` aux colonnes permutées et exige les mêmes verdicts sur les 19 cases.

### G-3 🟠 — P-339 juge les positifs sous les défauts seulement, et compte tout écrivain concurrent comme une fuite
- **Famille** : une porte énumérative qui ne juge qu'une partie de ce qu'elle énumère.
- **Étendue mesurée** (`p339_detail.json`) : sous `par_besoins`, **13 positifs** dans l'agence de l'acteur sont refusés `DROIT` et seulement « notés » : `UpdateCompany`, `RequalifyCompany`, `ArchiveCompany`, `CreateUnit`, `CreateContact`, `UpdateContact`, `TransferContact`, `ArchiveContact`, `UploadDocument/societe_id`, `CreateProject`, **`SignPrestation`** (la cascade `RequalifyCompany` vise une société sans besoin), `CreateAction/societe_id`, `CreateAction/contact_id`. Une société créée sous `par_besoins` n'est plus gérable par personne d'autre qu'un périmètre global, et une signature y tombe — rien ne dit si c'est voulu. Et l'empreinte étant globale, 2 fausses fuites sont apparues dès qu'un autre processus écrivait.
- **Correction** : pour chaque valeur de politique de périmètre, le **résultat attendu** de chaque positif se déclare (à côté de la valeur dans le registre) ; l'empreinte se prend par transaction (`txid` / `xmin` des lignes) et non par diff global.
- **Porte** : P-339 juge « positif » sous **toutes** les passes contre la table des attendus ; une passe sans attendu déclaré est rouge.

---

**Angles morts** : `SECURITE10.md` §3 (communs aux trois brouillons). Propres à la grille : A1 et la case 14 du cliquet jugés sans `make test` ni cliquet lancés ; K5 non mesurable sur le poste.
