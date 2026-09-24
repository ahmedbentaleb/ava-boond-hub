# GRILLE6 — les contrôles de `_ops/GRILLE_AUDIT.md`, recomptés et mesurés

**Sixième audit · branche `lot-2` · commit `a26291c`.** Base `ava_audit6_b` (migrations `001` →
`013` puis `db/fixtures/banc.sql`), serveur `AVA_MODE=banc` sur `127.0.0.1:3602`, rôle
`ava_serveur`. Rien n'est recopié : chaque ligne porte la commande qui l'a produite.

⛔ **Le cliquet n'a pas été lancé** (consigne). Il a été **lu**, case par case.
⛔ **Aucun fichier du dépôt n'a été modifié.**

---

## LE COMPTE DES CONTRÔLES — l'en-tête de la grille est faux de deux façons

```bash
grep -cE '^\| \*\*[A-K][0-9]+\*\*' _ops/GRILLE_AUDIT.md   # par famille, voir ci-dessous
```

| Famille | Contrôles réellement écrits | Ce que la grille annonce |
|---|---|---|
| A · la preuve | 5 | 5 |
| B · le paramétrage | 5 | 5 |
| C · les murs | 5 | 5 |
| K · l'accès | 5 | 5 |
| D · le dépôt | 5 | 5 |
| E · l'écran | 5 | 5 |
| **F · le cliquet** | **13** (F1→F13) | ⛔ **« 11 contrôles (F1 → F11) »** |
| **Total** | **43** | ⛔ **« 42 contrôles »** |

⚠️ **G-01 · l'en-tête de la grille ne se recompte pas.** F12 et F13 ont été ajoutés au tableau
sans que le titre de la famille ni le total en tête de fichier bougent. Le cliquet, lui, dit
bien « treize cases ». *(constat détaillé plus bas)*

---

## A · LA PREUVE — 4 ✅ · 1 non mesurable

| # | Verdict | Mesure |
|---|---|---|
| **A1** | ✅ | `bash outils/plancher_assertions.sh _ops/SPEC_ASSERTIONS_L7.sql` → **40**. `psql -f _ops/SPEC_ASSERTIONS_L7.sql` sur base neuve → **40 lignes `OK   M-`**, 0 échec. `cmp _ops/SPEC_ASSERTIONS_L7.sql test/SPEC_ASSERTIONS_L7.sql` → **identiques**. Preuve : `grille6/assertions.txt` |
| **A2** | ✅ | `DROP TRIGGER tg_m10 ON temps; DROP TRIGGER tg_m7 ON evenement_metier;` puis relance → **40 → 9 `OK   M-`** et une `ERREUR` à la ligne 259. Les assertions testent bien quelque chose. Preuve : `grille6/assertions_mur_casse.txt` |
| **A3** | ✅ | `.github/workflows/ci.yml` : `fetch-depth: 0` (l. 50), `git branch -f main origin/main` (l. 55), `run: bash outils/cliquet.sh` (l. 97). Pas de `db.yml`. |
| **A4** | ⚪ **non mesuré** | `python _ops/outils/dossier.py` **réécrit `_ops/DOSSIER.html`**. La consigne de cet audit interdit de modifier un fichier du clone ; la procédure de la grille et la consigne se contredisent. Le script existe (`_ops/outils/dossier.py`). |
| **A5** | ✅ | `audit/` porte **18 fiches** dont `E1.md` → `E7.md` et `L2-*.md`. |

---

## B · LE PARAMÉTRAGE — 3 ✅ · 1 🔴 · 1 🟠

| # | Verdict | Mesure |
|---|---|---|
| **B1** | 🟠 | Le grep de la grille rend **7 occurrences**, toutes relues : aucune n'est un `if` métier en dur *(4 comparent une **catégorie** lue en base, 3 comparent `perimetre.type_code`, mécanique des droits)*. ⛔ **Mais le grep est aveugle sur un cas réel** — voir **G-02**. |
| **B2** | ✅ | `SELECT count(*) FROM politique` → **201**. Registre §E : **201 au 24/09 au soir**. Égal. |
| **B3** | ✅ | `WHERE valeur IS DISTINCT FROM valeur_defaut` → **0 ligne**. |
| **B4** | ✅ | `ref_*` dans `information_schema` → **71**. Registre §E : **71 au 24/09 au soir**. Égal. |
| **B5** | 🔴 | **Un CHECK fige une liste de codes métier sans référentiel ni justification** — voir **G-03**. |

⭐ **Ce que B5 donne, mesuré EN BASE** (pas dans les fichiers — un CHECK de `001` peut avoir été
retiré par `007`, et c'est le cas de `contact.statut_code`) :

```sql
SELECT cl.relname||' : '||pg_get_constraintdef(c.oid)
FROM pg_constraint c JOIN pg_class cl ON cl.oid=c.conrelid JOIN pg_namespace n ON n.oid=cl.relnamespace
WHERE n.nspname='ava' AND c.contype='c' AND pg_get_constraintdef(c.oid) ~ '_code[^)]*(IN |= )';
```

| Contrainte vivante | Justifiée ? |
|---|---|
| `perimetre.type_code` (×2) | ✅ registre §B l. 75 — « mécanique des droits, pas une liste métier » |
| `personne_coordonnee` (réseau social) | ✅ structurelle, pas une liste de codes |
| `snapshot_marge` (devises égales) | ✅ M-15 |
| ⛔ **`paiement.etat_code IN ('planifie','confirme','regle')`** | ❌ **aucune ligne au registre** |

---

## C · LES MURS — 5 ✅

| # | Verdict | Mesure |
|---|---|---|
| **C1** | ✅ | `grep -rn "tenant" db/` → 3 lignes, toutes des **commentaires** de `001_schema.sql` expliquant l'absence de `tenant_id`. Aucune colonne. |
| **C2** | ✅ | La requête de la grille sur `ava_app` → **0 ligne**. ⭐ Rejouée sur **`ava_serveur`** (le rôle qui se connecte réellement) → **0 ligne** aussi. |
| **C3** | ✅ | `UPDATE` sur `evenement_metier`, `snapshot_marge`, `prestation_version` → **0 ligne**. |
| **C4** | ✅ | `has_any_column_privilege('ava_lecture_agregats', …)` → **exactement 7** : `politique`, `ref_devise`, `ref_pays`, `v_ca_provisoire_par_devise`, `v_ca_realise_par_devise`, `v_marge_par_devise`, `v_occupation_valorisee_par_devise`. |
| **C5** | ✅ | **107 triggers** hors internes ; les sept murs sont là : `tg_m4_m14` (M-4 + M-14), `tg_m6`, `tg_m7`, `tg_m10`, `tg_m12` (×4 tables), `tg_ajout_seul` (×3). |

Preuve : `grille6/famille_C.txt`.

---

## K · L'ACCÈS — 2 ✅ · 1 🔴 · 1 🟠 · 1 ⚪

| # | Verdict | Mesure |
|---|---|---|
| **K1** | ✅ | Serveur relancé **sans `AVA_MODE`**. `GET /sante` → **200**. `GET /tuyau`, `/vues/besoins`, `/vues/besoins/:id`, `/`, `/index.html`, `/besoins`, `POST /acquitter`, `POST /commandes/*` (5 testées) → **401** avec `{"code":"DROIT","message":"authentification non livrée (lot 2c)"}`. **`evenement_metier` 0→0, `tentative_refusee` 0→0, `societe` 0→0.** Preuve : `securite6/hors_banc.txt` |
| **K2** | 🟠 | Le sous-contrôle littéral passe : l'UUID d'un compte en `x-ava-groupe` → `DROIT « compte inconnu ou inactif »`. ⛔ **Le fond ne passe pas** — voir **G-04**. |
| **K3** | ✅ | `UPDATE compte SET actif=false` puis sa session : commande → `DROIT « compte inconnu ou inactif »` ; vue → **HTTP 403** ; `societe` **2 → 2**. Preuve : `securite6/K2_K3.txt` |
| **K4** | 🔴 | La table existe et **couvre les 55** (`CORRESPONDANCE`, 55 entrées = 55 handlers). **49 commandes à objet sur 49 refusent `DROIT` sur un objet d'une autre agence, 0 ligne écrite, contrôle positif concluant pour les 49.** ⛔ **Mais quatre chemins d'entrée écrivent quand même** — voir **G-05**. |
| **K5** | ⚪ **outil OK, serveur non mesuré** | `bash outils/verif_serveur.sh` tourne et **mesure vraiment** (`pg_hba_file_rules`, `listen_addresses`, `pg_authid`). Sur ce poste il rend **KO** : 6 règles `trust`, `listen_addresses = *`, `ava_serveur` **sans mot de passe**. C'est le poste de dev, assumé (V-022) — mais **aucun serveur de production n'a été mesuré ici**, et « scram sur le VPS » (T3) reste une phrase. Preuve : `securite6/verif_serveur.txt` |

---

## D · LE DÉPÔT — 2 ✅ · 2 🟠 · 1 🟡

| # | Verdict | Mesure |
|---|---|---|
| **D1** | ✅ | `git diff --name-only origin/main HEAD -- _ops/` → **0 fichier**. ⚠️ `main` **n'existe pas en local** dans un clone neuf ; il a fallu viser `origin/main`. Cela a une conséquence sur le cliquet — voir **G-07**. |
| **D2** | ✅ | Aucun ORM dans les `package.json`. |
| **D3** | 🟠 | `git log --diff-filter=M origin/main..HEAD -- db/migrations/` → **2 commits** (`d1776e3`, `4b74720`) qui **réécrivent `001_schema.sql`** et `002_seed_ref.sql`. Les migrations publiées ont bougé. |
| **D4** | 🟡 | `REMARQUES.md` **absent** à la racine comme dans `_ops/`. |
| **D5** | 🟠 | `origin/main..HEAD` : **189 commits**, **169 portent `Role:`** → **20 commits sans trailer** (dont `19237f6`, `2cf7300`, `5f9427b`, `aa4da72`, `c9b3067`). |

---

## E · L'ÉCRAN — 5 ✅

| # | Verdict | Mesure |
|---|---|---|
| **E1** | ✅ | grep → aucune occurrence dans `web/src/`. |
| **E2** | ✅ | aucune. |
| **E3** | ✅ | aucun libellé d'état en dur. ⭐ **Et à l'œil** (les 1 130 lignes de `web/src` lues) : le seul `Record<…>` est `PASTILLE` dans `rendu.tsx` — une table **classe CSS**, pas des libellés. Tous les libellés viennent du serveur (`cellule.libelle`, `action.libelle`, `etat.libelle`). |
| **E4** | ✅ | aucun import vers `server/` ou `db/`. |
| **E5** | ✅ | une seule « occurrence » : le fichier binaire `JetBrainsMono-Regular.woff2`. Faux positif. |

---

## F · LE CLIQUET — 13 cases lues, 12 ✅ · 1 🟠, plus une réserve sur la case 7

⛔ Le script **n'a pas été lancé**. Chaque case a été **lue**, puis sa mesure **rejouée à la main**.

| # | Case du script | Verdict | Mesure rejouée |
|---|---|---|---|
| **F1** | — | ✅ | `journal/PORTES.md` : **312 portes**, colonnes `Porte · Espèce · Phrase · Test · Vue rouge · État · Lot cible · Tolérance`. |
| **F2** | — | ✅ | les **quatre espèces** sont servies : `A BASE`, `B CONTRAT`, `C GESTE`, `D ÉCRAN`. |
| **F3** | 3 | ✅ | `origin/main` porte **5 portes servies** (tableau sans colonne État → toutes servies, V-009). **0 disparue** dans HEAD. |
| **F10** | 9 | ✅ | **0 porte de `main` rétrogradée** ✅ → autre chose. |
| **F11** | 10 | ✅ | **5 ⏳** : `P-061` → `P-065`, toutes **lot cible 3** ; lot courant 2 → aucune échéance dépassée. |
| **F4** | 4 | ✅ | aucun `skip/only/todo/xit/disabled` dans `test/`. |
| **F5** | 5 | ✅ | **aucune porte sans date de vue rouge** sur les 312. |
| **F6** | — | ✅ (réserve) | Les 13 cases se **calculent** : `make_rc`, `grep -c 'OK   M-'` contre le plancher, `cmp`, `comm` sur les numéros de portes, `git diff`, `git merge-base`, `git config`. ⭐ La case 1 exige bien les **trois** conditions de V-008 (`make_rc=0`, aucune ✅ en échec, **chaque ✅ exécutée** par `comm -23`). ⛔ **Réserve : la case 7 — voir G-07.** |
| **F7** | 12 | 🟠 | Dans ce clone `git config --get core.hooksPath` est **vide** : le crochet n'est pas posé tant que `bash outils/installer.sh` n'a pas tourné. La case le détecte et le dit (`— lancer : bash outils/installer.sh`). C'est le comportement voulu, mais **l'état mesuré du clone est « crochet absent »**. |
| **F8** | — | ✅ | `ci.yml` l. 97 : `run: bash outils/cliquet.sh`. Le **même** script, pas une copie. |
| **F9** | — | ✅ | `line()` imprime et compte ; aucune case ne sort du script. Le `exit` est à la fin. |
| **F12** | 11 | ✅ | Fenêtre `merge-base(origin/main, HEAD)` → `HEAD`, **189 commits** relus : **0 porte ✅ perdue**. |
| **F13** | 13 | ✅ | `git merge-base --is-ancestor origin/lot-2-brain HEAD` → **vrai** (`origin/lot-2-brain` = `18757b7`). ⭐ **Ce que la case mesure est juste** : elle cherche `lot-2-brain` puis `origin/lot-2-brain`, tente un `git fetch`, et **rend KO avec son motif** si la référence reste introuvable — jamais verte par défaut. |

---

# LES CONSTATS

## G-01 — l'en-tête de la grille annonce 42 contrôles et « F : 11 » ; elle en porte 43 et F en porte 13

| | |
|---|---|
| **défaut** | Le titre de la famille F (« **11 contrôles (F1 → F11)** ») et le total en tête de fichier (« **42 contrôles · 7 familles** ») n'ont pas suivi l'ajout de **F12** (V-050, 22/09) et **F13** (posé le 23/09 au soir). |
| **cible** | `_ops/GRILLE_AUDIT.md` l. 5 et l. 168 |
| **famille** | grille (méta) |
| **gravité** | **faible** |
| **preuve** | `grep -cE '^\| \*\*F[0-9]+\*\*' _ops/GRILLE_AUDIT.md` → **13**. Le tableau F liste, dans cet ordre : F1, F2, F3, F10, F11, F4, F5, F6, F7, F8, F9, F13, F12. Somme des familles : 5+5+5+5+5+5+13 = **43**. |
| **reproduire** | `grep -cE '^\| \*\*[A-K][0-9]+\*\*' _ops/GRILLE_AUDIT.md` |
| **prétend** | « 42 contrôles · 7 familles » · « F · LE CLIQUET — 11 contrôles (F1 → F11) » |
| **mesure** | **43 contrôles**, F en porte **13** — et `outils/cliquet.sh` l. 2 dit, lui, « treize cases ». |
| **correction** | Recompter les deux nombres dans l'en-tête, ou les remplacer par la commande qui les compte — le fichier fait déjà cela pour les politiques et les référentiels (« ⛔ ne pas recopier le chiffre ici »). |

## G-02 — le grep de B1 ne voit pas un `if` métier en dur quand le code est passé par une variable

| | |
|---|---|
| **défaut** | `server/src/couverture.ts` et `server/src/commandes/besoin.ts` comparent les **codes du référentiel `ref_unite_couverture`** (`postes`, `fte`, `postes_et_fte`) à des littéraux. Le grep de B1 cherche `…_code === "…"` ; ici le code a été copié dans une variable nommée `unite` / `couverture`, et le grep passe à côté. ⛔ Un quatrième code ajouté par `ManageRefs` tombe **silencieusement dans la branche `postes`** : la garde de couverture ne le voit pas. |
| **cible** | `server/src/couverture.ts` l. 24-30 · `server/src/commandes/besoin.ts` l. 68 |
| **famille** | B — paramétrage (ADR-005) |
| **gravité** | **moyenne** |
| **preuve** | `couverture.ts:26` — `const ok = unite === "fte" ? fteOk : unite === "postes_et_fte" ? postesOk && fteOk : postesOk;` ⭐ `ref_unite_couverture` est bien une **table de référentiel** (`select code from ref_unite_couverture` → `postes, fte, postes_et_fte`), donc extensible par `ManageRefs`. |
| **reproduire** | `grep -rnE '\b[a-zA-Z_]+ *(===\|!==) *"[a-z_]+"' server/src --include=*.ts` — le grep élargi rend **40 lignes** ; relues une par une, la grande majorité compare des **valeurs de politique** (légitime, `valeurs_possibles` est fermé) ou des **catégories** (couche invariante). Les deux ci-dessus comparent des **codes de référentiel**. |
| **prétend** | B1 : « Aucun `if` métier en dur », vérifié par un grep sur `…_code ===`. |
| **mesure** | 0 occurrence au grep de la grille, **2 fichiers** au grep élargi. |
| **correction** | Deux choses, séparément : (1) élargir le motif de B1 — la grille dit elle-même « je lis chaque occurrence, je ne compte pas », mais encore faut-il que le grep les montre ; (2) faire porter la règle par la **catégorie** de `ref_unite_couverture` comme partout ailleurs, plutôt que par son code. |

## G-03 — `paiement.etat_code` fige trois codes d'état métier dans un CHECK, sans référentiel ni justification

| | |
|---|---|
| **défaut** | `012_schema_v1_complet.sql` crée `paiement` avec `etat_code TEXT NOT NULL CHECK (etat_code IN ('planifie','confirme','regle'))`. Aucun `ref_etat_paiement` n'existe. C'est le seul état métier du schéma qui ne passe pas par un référentiel. |
| **cible** | `db/migrations/012_schema_v1_complet.sql` l. 883 |
| **famille** | B5 — 🔴 selon la grille |
| **gravité** | **élevée** (verdict de la grille : 🔴 non justifiée) |
| **preuve** | En base : `paiement : paiement_etat_code_check CHECK ((etat_code = ANY (ARRAY['planifie'::text,'confirme'::text,'regle'::text])))`. Les 11 autres états du schéma ont chacun leur table : `ref_etat_besoin`, `ref_etat_candidat`, `ref_etat_positionnement`, `ref_etat_prestation`, `ref_etat_projet`, `ref_etat_ressource`, `ref_etat_devis`, `ref_etat_facture`, `ref_etat_facture_fournisseur`… |
| **reproduire** | la requête `pg_constraint` du §B5 ci-dessus ; puis `select count(*) from information_schema.tables where table_schema='ava' and table_name='ref_etat_paiement'` → **0**. |
| **prétend** | Registre §E, l. 419 : seules trois listes figées en CHECK sont assumées, toutes converties en référentiel par la migration 007 (D-9, V-021) ; « ⛔ `perimetre.type_code` **reste** un CHECK ». `paiement.etat_code` n'est cité nulle part. |
| **mesure** | `grep -n "paiement" _ops/REGISTRE_POLITIQUES_v1.md` → **0 ligne**. |
| **correction** | Soit une ligne au registre §B qui assume le gel (comme `perimetre.type_code`), soit un `ref_etat_paiement` et une FK — c'est exactement ce que la migration 007 a fait pour `contact.statut_code`, qui portait le même défaut et qui est aujourd'hui propre. |

## G-04 — la « session » est l'adresse e-mail du compte, en clair, dans un en-tête

| | |
|---|---|
| **défaut** | `x-ava-groupe` porte l'**e-mail** du compte ; `executer.ts:compteDuGroupe` et `index.ts:compteEntete` font `WHERE lower(c.email) = lower($1) AND c.actif`. Il n'y a **aucune** table de session, **aucun** jeton, **aucun** mot de passe, **aucune** expiration. D-10 demande un jeton aléatoire, haché, expirant. |
| **cible** | `server/src/index.ts` l. 176-188 · `server/src/executer.ts` l. 62-73 |
| **famille** | K2 — 🔴 selon la grille |
| **gravité** | **moyenne** *(et non élevée : hors `AVA_MODE=banc`, K1 mesure que **rien** ne répond — la porte n'est pas ouverte, elle n'existe pas encore)* |
| **preuve** | `curl -H "x-ava-groupe: ia@ava.test" -d '{"nom":"K2-email","pays_code":"FR"}' -XPOST .../commandes/CreateCompany` → `{"ok":true, …}`. Idem en majuscules (`IA@AVA.TEST`). Tables `%session%`/`%jeton%`/`%token%` dans `ava` → **0**. Colonnes de `compte` : `id, email, personne_id, actif, agence_id, theme_json, widgets` — **aucun mot de passe**. |
| **reproduire** | `securite6/K2_K3.txt` |
| **prétend** | K2 : « Une session n'est jamais l'identifiant d'un compte … le jeton est aléatoire, haché, expirant (D-10) ». Le code dit, lui : `MSG_AUTH_NON_LIVREE = "authentification non livrée (lot 2c)"`. |
| **mesure** | Le sous-contrôle littéral (envoyer l'UUID) **passe** ; le fond **ne passe pas**. |
| **correction** | Rien à corriger dans le code du lot 2 : c'est un **lot non livré**, et le garde `preHandler` le tient. ⭐ **La grille, elle, doit trancher** : K2 ne peut pas être « 🔴 » et « lot 2c » en même temps. Soit K2 devient ⏳ avec un lot cible, comme les portes, soit il refuse le lot. |

## G-05 — quatre chemins écrivent sur un objet d'une autre agence (détaillé dans SECURITE6)

Rappel ici pour la grille : **K4 tombe.** `CreateAction` avec `societe_id` ou `contact_id`,
`UploadDocument` avec `societe_id`, et `ArchiveObject` avec `type = "societe"` ou `"contact"`
franchissent la garde d'agence et **écrivent**. ⛔ Le plus net : sur **la même société d'une
autre agence**, `ArchiveCompany` rend `DROIT` et `ArchiveObject type="societe"` **l'archive**.
Constat complet, preuve et correction : **SECURITE6 · I-01**.

## G-06 — le contrôle K4 est **inopérant** tant que 5 commandes n'ont pas de titulaire

| | |
|---|---|
| **défaut** | `ArchiveCompany`, `ArchiveContact`, `ArchiveService`, `ArchiveObject`, `UpdateResourceCost` n'ont **aucun titulaire au seed** (D-30, assumé). Un balayage K4 fait sur le seed les voit rendre `DROIT` des **deux** côtés : le refus prouve l'absence de permission, **pas** le périmètre. ⛔ **Ce n'est pas un détail de méthode** : c'est précisément en posant ces permissions que j'ai trouvé les deux chemins d'`ArchiveObject` de **G-05**. Un K4 passé sur le seed nu les déclare verts. |
| **cible** | `_ops/GRILLE_AUDIT.md` K4 (la procédure) · `db/fixtures/banc.sql` |
| **famille** | K4 — couverture du contrôle |
| **gravité** | **moyenne** *(un contrôle 🔴 qui ne peut pas rougir sur 5 commandes sur 55)* |
| **preuve** | Premier balayage, `securite6/perimetre_par_objet.json` : pour ces cinq commandes `hors_agence.code = "DROIT"` **et** `controle_positif.code = "DROIT"`. Second balayage après pose par `ManageGroups` (`securite6/cinq_sans_titulaire.txt`) : les cinq refusent `DROIT` hors agence avec un contrôle positif concluant — **et** `ArchiveObject` laisse passer deux types. |
| **reproduire** | `select code from permission except select distinct permission_code from groupe_permission_perimetre;` → **6 lignes** (les 5 commandes + `LireDonneesRHSensibles`, voir CONFORMITE6 · H-03). Puis `ManageGroups {groupe:"IA", permission:"ArchiveObject", perimetre:<id du périmètre agence PAR>}` et remesurer. |
| **prétend** | K4 : « par commande : un cas hors agence → `DROIT`, 0 écriture ». |
| **mesure** | Sur le seed nu : **5 des 49 contrôles positifs sont muets**. Après pose : **49/49 concluants**, et **2 trous trouvés**. |
| **correction** | Le banc doit **poser** la permission le temps du contrôle, par `ManageGroups` — pas par SQL, pour que le chemin soit celui du produit — puis la retirer. ⭐ Et K4 doit l'exiger explicitement : « un cas hors agence → `DROIT` **et** un cas dans l'agence qui ne rend pas `DROIT` ». Sans la seconde moitié, le contrôle est vert par construction. |

## G-07 — case 7 du cliquet : `_ops/` est déclaré intact **par défaut** si `main` est introuvable

| | |
|---|---|
| **défaut** | La case 7 mesure `git diff --quiet "$base" HEAD -- _ops/`. Si `$base` est **vide** — ni `main` ni `origin/main` — la condition `[[ -n "$base" ]] && …` est fausse, `n_ops` reste à `0`, et la case imprime **OK**. ⛔ Les cases **3**, **9** et **13** traitent, elles, la référence absente comme **KO avec son motif**. La case la plus importante de la grille (« D1 est le contrôle le plus important ») est la seule à passer au vert sans avoir rien mesuré. |
| **cible** | `outils/cliquet.sh` l. 236-244 (case 7) |
| **famille** | F6 — « aucune case ne se déclare, toutes se calculent » |
| **gravité** | **moyenne** |
| **preuve** | ```bash\nn_ops=0\nif [[ -n "$base" ]] && ! git diff --quiet "$base" HEAD -- _ops/ 2>/dev/null; then\n  n_ops="$(git diff --name-only "$base" HEAD -- _ops/ | grep -c . || true)"\nfi\nif [[ "$n_ops" == "0" ]]; then\n  line 7 "_ops/ intact vs ${base:-main}" OK ""\n``` — comparer à la case 3 : `if [[ -z "$base" ]]; then line 3 … KO "main introuvable"`. |
| **reproduire** | Ce n'est pas théorique : **dans ce clone, `git rev-parse --verify main` échoue** (`fatal: Needed a single revision`) — seul `origin/main` existe. Le script retombe sur `origin/main` ici, mais un clone fait avec `--single-branch`, ou une CI sans le `git fetch` de `ci.yml`, n'aurait **ni l'un ni l'autre**, et la case 7 serait verte. C'est précisément le scénario que V-009 a corrigé pour les cases 3 et 9, et qui n'a pas été reporté sur la 7. |
| **prétend** | Case 7 : « ⛔ `_ops/` INTACT — BLOQUANT. Mesure le DIFF vs main (A-013). » |
| **mesure** | Aucune référence → **0 fichier de différence** → **OK**. |
| **correction** | La même garde que la case 3 : `if [[ -z "$base" ]]; then line 7 … KO "main introuvable"`. Trois lignes. |

---

## VERDICT

```
GRILLE — 43 contrôles · 2 🔴 · 6 🟠 · 1 🟡 · 2 ⚪ non mesurables
B5  paiement.etat_code fige 3 codes d'état sans référentiel         (G-03)
K4  4 chemins écrivent hors agence ; ArchiveObject contourne
    la garde de ArchiveCompany sur la MÊME société                  (G-05 → SECURITE6 I-01)
→ 🟠 : B1 (grep aveugle, G-02) · K2 (session = e-mail, G-04) · D3 (001 réécrite)
       D5 (20 commits sans Role:) · F7 (crochet non posé dans le clone)
       G-06 (K4 muet sur 5 commandes sans titulaire) · G-07 (case 7 verte sans main)
→ 🟡 : D4 (REMARQUES.md absent)
→ ⚪ : A4 (dossier.py réécrit _ops/) · K5 (aucun serveur de production mesuré)
→ méta : G-01 (l'en-tête compte 42, il y en a 43 ; F annonce 11, il en porte 13)
```

⭐ **Ce qui tient, et qui n'est pas rien.** Les 40 assertions passent et **tombent** quand on
casse un mur (A2 — le contrôle que personne ne fait). Les quatre murs en GRANT sont exacts au
privilège près, y compris sur le rôle qui se connecte vraiment. Les 307 portes servies sont
toutes là, aucune rétrogradée, aucune perdue sur 189 commits. `_ops/` n'a pas bougé d'un octet.
Et l'écran est **propre** : pas un `if` métier, pas un calcul d'argent, pas un libellé en dur.
