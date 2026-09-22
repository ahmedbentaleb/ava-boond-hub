# Brief Opus — simulateur v6 : aligner sur le canon final — 18 septembre 2026

**Mot d'Hamada (18/09, 1h30) : « L'artefact, il faut le corriger. »** — correction **et republication** autorisées par ce mot.

Fichier : `_ops/ava-simulateur-metier.html` (v5, 1 306 lignes, 27 politiques). Le canon a bougé **après** v5 : passes 3, 4, 5 du livrable 5 (`git log 1978bb4..3d5c891`), toutes tracées dans [RELECTURE_5_MODELE_DONNEES](RELECTURE_5_MODELE_DONNEES_2026-09-17.md) §0. Ce brief est la liste exacte de ce que v5 ne porte pas encore. Rien d'autre.

## ⛔ Ce que tu ne fais pas

| | |
|---|---|
| ⛔ | Toucher au canon (registre, machines, livrable, ADR, feuilles). Il est clos : 5c ✅. Une contradiction sim ↔ canon = le canon gagne ; si le canon est muet, tu notes, tu ne tranches pas |
| ⛔ | Un chiffre de compte recopié (« 61 politiques », « 32 tables ») : l'en-tête du sim dit **« n réglages sur ceux du registre §E »**, avec n calculé depuis `POL_DEF.length` |
| ⛔ | Un `if` métier sans clé ; une comparaison d'état sur le code au lieu de `categorie()` |
| ⛔ | Ajouter une politique absente du registre §C |

## Ce qui manque à v5 — 6 points, dans cet ordre

### 1 · D-3 — rôle ≠ statut

Le registre §B : `ref_role_societe` = **fournisseur · interne** seulement ; `prospect` / `client` sont le **statut commercial** (`ref_statut_commercial`).

| Où | Faire |
|---|---|
| Monde initial | `roles` ne contient plus jamais `"client"` ni `"prospect"` : ALPHA = `roles:[]`, `statut:"client"` ; BETA = `roles:[]`, `statut:"prospect"` ; GAMMA = `roles:["fournisseur"]` ; AVALIANCE = `roles:["interne"]` |
| `CreateCompany` | le formulaire propose **statut** (prospect · client) **et** rôles cumulables (fournisseur, interne) — deux champs, pas un |
| `SignPrestation`, `RequalifyCompany` | ne touchent que `statut`, jamais `roles` |
| Écran Sociétés | deux colonnes : Statut (pastille) · Rôles (étiquettes) |

### 2 · D-2 — la propagation du statut client

Le livrable §3.1 : `unite_organisation.statut` et `contact.statut`, **NULL = prospect, jamais « hérite »** ; `ClientStatusDerived` écrit `client` **explicitement** sur ce que la politique désigne.

| Où | Faire |
|---|---|
| `POL_DEF` | **ajouter** `societe.passage_client.propagation` — options **branche_contractante_et_contacts_du_service** (défaut) · societe_seule · toute_la_societe · source BM-15, CdC II.F · effet : « jusqu'où descend le statut client » |
| Monde | `unite.statut` et `contact.statut` : `null` partout au départ (= prospect) sauf chez ALPHA où le Service 1 et CT-0101 sont `"client"` (ALPHA a déjà une mission signée) |
| `effetsPassageClient(soc, prestation)` | selon la politique : `societe_seule` → la société ; `branche_contractante…` → la société **+** l'unité du contact du projet **+ ses parents** + les contacts de cette unité ; `toute_la_societe` → tout. Chaque écriture est **explicite**, une branche sœur reste `null`. Événement `ClientStatusDerived` avec la liste de ce qui a été écrit |
| Écran Sociétés | l'arbre des unités d'ALPHA avec la pastille de chacune — c'est là qu'Hamada verra que le Service 2 reste prospect |

### 3 · O-2 — signer demande le droit de signer

Machines §5 : `CreatePrestation` en état initial `signee` exige la permission **`SignPrestation`**, qui est celle du **directeur de projet**, pas du staffing. Dans v5, un seul rôle « Staffing et directeur de projet » cache le problème.

| Où | Faire |
|---|---|
| `ROLES` | **séparer** : `staffing` (nom « Staffing ») garde PositionResource, DeclareNeedFilled, CreateProject, CreateProjectFromNeed, CreatePrestation, CancelPrestation, RecordTimesheet, DeclareCVShared, WithdrawPositioning, CreateAction ; **nouveau** `dp` (« Directeur de projet ») porte SignPrestation, ClosePrestation, CloseProject, CreatePrestation, RecordTimesheet, CreateAction. Le sélecteur passe à **9 rôles** |
| `CreatePrestation` | si `d.etat === "signee"` → `droit("SignPrestation")` **avant** toute écriture ; message de refus : « Créer une mission déjà signée, c'est la signer : il faut le droit de signature (O-2). Créez-la prévisionnelle, ou changez de rôle. » |
| Tableau de bord | le rôle par défaut au chargement reste `staffing` ; l'étape 1 du « Par où commencer » gagne : « essayez de créer une mission directement signée : vous êtes staffing, pas DP » |

### 4 · D-9 — la devise du coût, la devise proposée du projet

Livrable §5.2, §5.5, §5.1.

| Où | Faire |
|---|---|
| `prestation` | champ `cjm_devise`, **par défaut = `devise`** ; le formulaire Prestation montre un second sélecteur de devise à côté du CJM (EUR · MAD · USD), pré-rempli |
| `projet` | champ `devise_defaut` (null par défaut) ; le formulaire Projet le propose ; le formulaire Prestation **pré-remplit** `devise` avec `projet.devise_defaut` si présent — et rien d'autre n'y touche |
| `ClosePrestation` → snapshot | `ca_devise = p.devise`, `cout_devise = p.cjm_devise` ; **`marge = null` si elles diffèrent** ; l'écran Projets montre « marge — (EUR / MAD, pas de taux) » sur une telle mission |
| Banc M-15 | second essai : clôturer une prestation vendue EUR / coût MAD → la marge vaut « — », **pas un chiffre**. Message : « M-15 : deux devises, aucun taux saisi (`change.mode = aucune_conversion`) — on n'invente pas une marge » |

### 5 · M-14 — un vrai trigger, plus une convention

Livrable §5.2 trigger 2 : dès la catégorie `engage`, `tjm`, `cjm`, `devise`, `cjm_devise`, `jours`, `frais_*` sont **immuables**.

| Où | Faire |
|---|---|
| couche `db` | `db.update("prestation", id, patch)` : si `categorie(etat) ∈ {engage, clos}` et que `patch` touche une colonne économique → refus « M-14 · trigger BEFORE UPDATE : conditions figées dès la signature — avenant = nouvelle prestation (ATL-18) ». Avant signature (`previsionnel`) : autorisé |
| Banc M-14 | **deux essais** dans le même bouton : (a) `db.update` du TJM d'une mission **signée** → refus M-14 ; (b) `db.update("pr", …, {tjm: 999})` sur la fiche → passe, et la mission n'a pas bougé (l'ancien test, gardé). Le message montre les deux |

### 6 · M-15 — la surface de lecture

ADR-005 amendement + livrable §9 : les agrégats ne s'exposent que par des **vues groupées par devise**.

| Où | Faire |
|---|---|
| couche `db` | `db.agrege(table, champ)` **n'existe plus** telle quelle : elle devient `db.vue("ca_par_devise")`, `db.vue("marge_par_devise")`, `db.vue("occupation_valorisee_par_devise")`, qui rendent **une ligne par devise**. Toute tentative `db.agrege` directe sur `prestation` / `temps` / `snap` → refus « M-15 · le rôle d'agrégation n'a pas SELECT sur cette table : passez par une vue » |
| Tableau de bord | la tuile « jours saisis » reste ; ajouter « CA signé » **par devise** (une ligne par devise, jamais une somme) — c'est la preuve visible de M-15 |
| Banc M-15 | essai (a) : `db.agrege("prestation","tjm")` → refus ; essai (b) : `db.vue("ca_par_devise")` → deux lignes EUR / MAD, jamais additionnées |

## Ce que tu ne changes pas

`temps.plafond_jour`, `projet.devises_mixtes`, T-1, la couche `db`, les 15 boutons du banc déjà réels, les trois apparences, `localStorage` (mais `charger()` doit **migrer** un monde v5 : `roles` nettoyés de client/prospect, `cjm_devise` = `devise`, `statut` des unités/contacts à `null`, rôle `staffing` conservé).

## Comment tu vérifies

| Scénario | Attendu |
|---|---|
| Rôle Staffing, créer une prestation « signée » | refus O-2 ; en « prévisionnelle » : passe ; rôle DP : passe et BETA devient cliente |
| BETA devient cliente sous le défaut de propagation | la société + l'unité du contact + ses parents + les contacts de cette unité en `client` ; une unité sœur reste prospect — visible à l'écran |
| Prestation EUR / CJM MAD, clôturée | snapshot avec deux devises, marge « — » |
| Banc M-14 | (a) refus sur mission signée, (b) fiche modifiée / mission intacte |
| Banc M-15 | (a) refus de l'agrégat direct, (b) une ligne par devise |
| Sociétés | ALPHA : statut client, rôles vides ; GAMMA : rôle fournisseur, statut prospect |
| En-tête | « 28 réglages sur ceux du registre §E », calculé |
| Monde v5 en `localStorage` | migré sans erreur console |

## Ce que tu rends

1. Le fichier corrigé, **republié** sur `https://claude.ai/artifact/H8yAb1Cbw4wdL9V1Jama1Y` (version 6) — le mot est donné.
2. Plan 17/09, ligne 5b+ : « v6 le 18/09 : D-2, D-3, D-9, O-2, M-14 trigger, M-15 vues ; 9 rôles ; n réglages calculé ».
3. Un commit :

```
Simulateur v6 : role et statut separes, propagation du statut client, droit de signature, devise du cout, M-14 trigger, M-15 vues ; 9 roles
```

4. Ta réponse à Hamada : ligne 1 = les 8 scénarios vérifiés, puis ce que tu n'as pas pu faire, puis rien — pas de question, il ne relit pas le code.
