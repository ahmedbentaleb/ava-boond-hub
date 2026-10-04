**57/57 commandes passent leur cas nominal et refusent 57/57 une clé non déclarée — mais 2 🔴 · 4 🟠 · 1 🟡 : D-57 n'est pas tenu, et une clé publique saute la garde que le registre déclare.**

> ⚠️ Numérotation : ce document garde les numéros de travail de son brouillon. Les constats rendus sont dans `CONSTATS.md` (V-179 → V-195), table de correspondance à la fin.


# CONFORMITE11 — les 57 commandes servies contre `_ops/SPEC_COMMANDES_L4.md` · auditeur B

Le lot est refusé par ce document. Une société ne passe plus cliente dès qu'un administrateur ajoute un deuxième code « prospect ». Un besoin se déclare pourvu à 0 poste signé avec `depuis_signature`.

> Banc : serveur `AVA_MODE=banc` sur :4102, base `ava_audit11_b`. L'acteur est `croise@ava.test` ; il reçoit les 57
> permissions sur PAR **par `ManageGroups`** (`conformite11/delegations_croise.txt`). `rh@` sert pour la conversion,
> `adm@` pour l'installation. Les politiques sont variées **par `SetPolicy`** (en SQL seulement si `SetPolicy` refuse, et
> c'est noté), puis remises ; en fin d'audit, 0 politique ≠ défaut.

---

## 1 · Le tableau habituel

Tableau complet, une ligne par commande : `conformite11/tableau_H11.md` (généré par `securite11/scripts/tableau11.mjs`
à partir de `DECLARATION` et des mesures HTTP).

| Mesure | Résultat | Preuve |
|---|---|---|
| Cas nominal | **57/57 ok** | `positifs_et_non.txt` |
| Événement du contrat émis | **55/57** au nominal. Deux commandes répondent `ok` sans événement. `TakeNeedInCharge` au défaut : no-op permis par le registre S-SD2, alors que L4 dit `ETAT` hors cycle (H18). `ManageGroups` : la délégation était déjà posée par ma première passe, l'appel est idempotent. Hors nominal, `ValidateTimesheet` sans ligne à valider rend `ok` sans événement (L4 : `ETAT`, H1g). `RequalifyCompany` et `SignPrestation` émettent en plus `ClientStatusDerived` | `positifs_et_non.txt`, `sondes_ciblees*.txt` H1g, H18 |
| Preuve par « non » — clé non déclarée | **57/57 → `GARDE entrée ambiguë`** | colonne `inc:` |
| Preuve par « non » — identifiant mal typé | **51/52 → `GARDE entrée mal typée`**. Le 52e, `ManageGroups.perimetre` (déclaré `code`), rend `INTROUVABLE` (H17) | colonne `type:` |
| Entrées du contrat **refusées** | **4**, inchangées depuis le 10e tour : `ArchiveService {id}` et `ArchiveContact {id}` → `GARDE motif` ; `ValidateTimesheet {temps_ids}` et `RejectTimesheet {temps_ids, motif}` → `GARDE entrée ambiguë` | H1a → H1e |
| Clés déclarées que L4 ne prévoit pas | **19 commandes** (16 au 10e tour) ; nouvelles : `CreateContact.telephone`, `TransferContact.reaffecter_a`, **`DeclareNeedFilled.depuis_signature`**, `CreatePrestation.taux_change`, `RecordTimesheet.derogation_motif` | `tableau_H11.md` |
| Clé lue et non déclarée | **1** : `RecordQualification.commentaire`, inatteignable (H1f) | `cles_lues_non_declarees.txt` |
| Codes de refus ≠ contrat | `ValidateTimesheet` sans ligne : `ok` (L4 : `ETAT`) · `CreateUnit` parent interne d'une autre agence : `DROIT` (L4 : `GARDE`) · `ManageGroups` périmètre mal typé : `INTROUVABLE` · `TakeNeedInCharge` au défaut : `ok`. Pour cette dernière, **L4 et le registre se contredisent** : L4 dit `ETAT` sans politique, le registre dit `ok · inchangé` | `sondes_ciblees*.txt` |
| UUID déclarés `valeur` (V-171) | il en reste **4** : `CreateUnit.agence`/`agence_id`, `ValidateTimesheet.id`, `RejectTimesheet.id` | extraction `DECLARATION` |

---

## 2 · Les constats

### C-1 🔴 — D-57 n'est pas tenu : le métier passe encore par `ordre`, par le premier code d'une catégorie, par des noms de commande et des littéraux de code
- **Famille** : une décision métier portée par l'ordre d'affichage, par l'identité d'un code (au lieu de sa catégorie), par un nom de commande ou par un littéral. D-57 l'interdit mot pour mot : « `ordre` est l'ordre d'affichage, rien d'autre… le code ne lit que la catégorie… plus aucun nom de commande dans la garde générique… plus aucun littéral métier ».
- **Ce qui est fait** : `ref_statut_commercial` a ses catégories fermées (`CHECK categorie IN ('prospect','client','ancien_client')`). L'exemption `CreateNeed` a disparu. `ManageRefs … client ordre=7` puis une signature → **ok, société cliente** : la porte P-359 rejouée passe.
- **Étendue mesurée** (`conformite11/d57_ordre_et_categorie.txt`, `d57_litteraux.txt`) :

| Forme | Où | Effet **prouvé par appel HTTP** |
|---|---|---|
| **Comparaison au « premier code de la catégorie »**, pas à la catégorie | `projet.ts:304` (signature), `:29` (création de projet), `:53` (retour prospect), `crm.ts:120` (propagation) : `statut_commercial_code === codeStatutCommercial(ctx, 1)` = le premier code actif de la catégorie, `ORDER BY ordre` | `ManageRefs ref_statut_commercial zz_prospect_chaud categorie=prospect ordre=0` (geste permis à ADM) → **la signature d'une société en `prospect` ne la fait plus passer cliente** : `ok`, société restée `prospect`, **aucun `CompanyStatusChanged`**. `CreateCompany` écrit `zz_prospect_chaud`. Témoin : 2e code désactivé → la signature requalifie. |
| **Code par défaut choisi par `ordre`** | `projet.ts:179` (`ref_type_mission`), `crm.ts:355` (`ref_type_contact`), plus `cycle.ts:101,129` et `projet.ts:63` (codes d'état) | Passe de permutation : `ordre` **inversé dans les 75 `ref_*`**, puis les 56 positifs rejoués → **1 commande sur 56 change ce qu'elle écrit** : `CreateProjectFromNeed` écrit `type_code = forfait` au lieu de `regie`. Le type de contrat dépend de l'ordre d'affichage. Ordre remis ensuite. |
| **Noms de commande dans le noyau** | `agence.ts:335` (`ArchiveObject`), `agence.ts:433` (`TransferContact`), **`executer.ts:244`** (`RecordClientDecision` → `CreateProjectFromNeed` : la fille ne passe pas par la garde), `kernel.ts:226` `SOI_MEME = {UploadDocument, RecordTimesheet, RecordAbsence}`, lu par `droits.ts:34,66` et `agence.ts:304` | `executer.ts:244` contourne un droit retiré : SECURITE11 I-3. `SOI_MEME` double la `nature: "soi"` de `DECLARATION` : ce sont deux listes pour un même concept. |
| **Littéraux de code** (pas de catégorie) | `'ouvert'` inséré (`projet.ts:122,186`), `'cv_partage'`/`'fait'` (`besoin.ts:305`), `'autre'` motif d'avenant (`projet.ts:279`), `role_code = 'interne'` (`crm.ts:220`), `?? "postes"` (`couverture.ts:17,41`) | aucun n'est paramétrable. `ref_type_mission`, `ref_type_contact`, `ref_role_societe` et `ref_etape_suivi_positionnement` n'ont **aucune catégorie fermée** (aucun CHECK) : le code s'accroche donc à des codes. |

  Au total **20 sites**. La porte P-359 ne permute `ordre` qu'**entre** catégories (un code par catégorie) : elle ne peut voir ni le deuxième code d'une catégorie, ni le défaut d'un `ref_*` sans catégorie. Et elle est ⏳ (GRILLE11 G-1).
- **Correction de construction** : (1) toute lecture d'un statut ou d'un état se fait **par catégorie** (`categorieStatutCommercial(code) = 'prospect'`), jamais par égalité de code. (2) Un code par défaut est une **politique** (`projet.type_defaut`, `contact.type_defaut`, `suivi.etape_cv`…) ou une catégorie fermée `defaut` **unique** (contrainte d'unicité partielle `WHERE categorie = 'defaut_unique'`). `ORDER BY ordre` n'apparaît plus que dans les vues d'affichage. (3) Les exceptions de commande se déclarent dans `DECLARATION` (`nature`, `soiMeme: true`, `cascade: { sansGarde: false }`) et le noyau ne compare plus `ctx.commande`.
- **Porte** : (a) une porte AST sur `server/src` qui rougit à tout `ORDER BY ordre` hors vue d'affichage, toute comparaison `=== codeX` sur un `*_code`, tout `ctx.commande ===` / `nom ===` hors `executer.ts`, et tout littéral de code dans un `INSERT`/`WHERE`. Aujourd'hui : 20 rouges. (b) Une passe différentielle qui, pour **chaque** `ref_*` lu, (i) inverse `ordre`, puis (ii) ajoute un deuxième code actif d'ordre 0 dans chaque catégorie lue, et rejoue les 57 positifs : issue **et** colonnes écrites identiques. Aujourd'hui : 2 rouges (signature, type de mission).

### C-2 🔴 — Une clé réservée à la cascade est une entrée publique : `depuis_signature` saute la garde §C-2 que le registre déclare « sous tous les modes »
- **Famille** : un paramètre interne (marqueur de cascade) est déclaré comme `valeur` publique. N'importe quel appelant peut donc se faire passer pour la cascade. C'est la famille V-162 ③ (« servie mais sans le comportement écrit »), corrigée en apparence.
- **Étendue mesurée** (`conformite11/sondes_ciblees.txt`, H5bis) : sous `besoin.pourvu.mode = auto_par_personne_signee` (valeur servie, posée par `SetPolicy`) :
  - S-PM3 tel que le registre l'écrit (2 postes, 1 engagé, appel direct `{id}`) → `GARDE couverture insuffisante 1/2` : conforme ;
  - **le même appel avec `{depuis_signature: "oui"}` → `ok`, `NeedFilled`, besoin `pourvu` à 1/2** ;
  - **un besoin à 0 prestation, `{depuis_signature: "n'importe quoi"}` → `ok`, `pourvu` à 0/1**.
  Le registre dit : « ⛔ la garde minimale (au défaut) s'applique sous **tous** les modes (V-162 ③) ». La porte différentielle (P-355) est verte parce que son scénario ne passe pas la clé. La règle 7 du registre la déclare donc fausse.
- **Correction de construction** : le contexte de cascade est porté par `executerDans` (`ctx.cascade = { mere, fille }`), **jamais** par l'entrée. `DECLARATION` refuse un rôle « interne » : un champ que seul le serveur pose n'est pas déclaré, et `refuserAmbigu` le rejette donc venant du client.
- **Porte** : pour chaque cascade de `CASCADES` (10), la fille appelée **directement** avec, en plus, toute clé que sa mère lui passe (`depuis_signature`, `contact_id`, `besoin_id`…) rend la même issue que sans ces clés, sinon rouge. Aujourd'hui : 1 rouge mesuré.

### C-3 🟠 — Une transition s'écrit hors de sa commande : `CreatePrestation {etat: "signee"}` crée une prestation engagée sans TJM ni jours (V-166, D-60, non codé)
- **Famille** : un effet atteignable par deux entrées, chacune avec sa garde.
- **Étendue mesurée** (H4a, H4b) : `CreatePrestation` sans `tjm`, sans `jours_vendus`, avec `etat: "signee"` → **ok**, `PrestationCreated + PrestationSigned + CompanyStatusChanged + ClientStatusDerived`, `tjm_vendu = null`, `jours_vendus = null`. M-14 fige ensuite ces nulls. `SignPrestation` sur la même prestation refuse `GARDE tjm_vendu, jours_vendus et taux_occupation requis`. D-60 : « `CreatePrestation` naît `proposee`, jamais `signee` ». Les clés `etat`, `etat_code` et `date_signature` restent déclarées.
- **Correction de construction** : l'état initial n'est pas une entrée. `CreatePrestation` écrit le code de catégorie `previsionnel`, et `signer()` est une fonction unique qui porte sa garde.
- **Porte** : pour chaque table à machine d'état, aucune commande de création ne déclare de clé `etat*`. Le jeu de refus de `SignPrestation` est rejoué par toute entrée qui produit `PrestationSigned`.

### C-4 🟠 — Les commandes jugent l'état écrit, l'écran montre l'état lu (V-168, D-60, non codé)
- **Étendue mesurée** (H12) : sous `societe.retour_prospect = auto_apres_delai`, une société cliente sans prestation depuis plus que le délai se lit `prospect` (vue `v_societe_statut`, et `UpdateCompany` rend `statut.code = prospect`). Pourtant `RequalifyCompany → client` refuse `ETAT requalification client → client hors cycle`.
- **Correction** : `RequalifyCompany`, `effetsSignature`, `retourSiDernierContrat` et `SetResourceState` lisent la vue D-53.
- **Porte** : pour chaque vue D-53, un scénario lu ≠ écrit où les actions offertes par la vue et le verdict des commandes concordent.

### C-5 🟠 — Le contrat et la déclaration divergent encore, et aucune porte ne les compare (V-174, non codé)
- **Famille** : les clés d'une commande vivent dans deux textes, et aucun ne dérive de l'autre. `inventaire.test.ts` vérifie seulement que le **nom** de chaque commande figure dans L4.
- **Étendue mesurée** : 4 entrées L4 refusées · **19** commandes avec des clés hors L4 (+3 depuis le 10e tour, dont `depuis_signature`, à l'origine de C-2) · 1 clé lue et non déclarée · 4 codes de refus différents du contrat · `TakeNeedInCharge` sur lequel L4 et le registre se contredisent.
- **Correction de construction** : la colonne Entrée et la colonne « Refuse si » de L4 se **génèrent** depuis `DECLARATION` et le registre, ou l'inverse. Une clé ajoutée par décision entre au contrat par le même geste.
- **Porte** : pour chaque commande de `HANDLERS`, les clés L4 = les clés déclarées (alias compris), et les codes de refus de L4 = ceux qu'on mesure. Aujourd'hui : 4 + 19 + 1 + 4 rouges.

### C-6 🟠 — `commandes_affectees` de `SetPolicy` dérive du registre, pas des lecteurs (V-172, à moitié)
- **Étendue mesurée** (`commandes_affectees_contre_lues.txt`) : `SetPolicy societe.perimetre.mode=partagee` rend `["UpdateCompany","UpdateProject"]`. Or les événements des positifs tracent cette politique dans **11 commandes** (UpdateCompany, RequalifyCompany, ArchiveCompany, CreateUnit, CreateContact, UpdateContact, TransferContact, ArchiveContact, CreateNeed, CreateProject, CreateAction). La liste ne compte que les commandes qui ont une ligne au registre, pas celles qui lisent la politique (garde d'agence).
- **Correction** : la liste se dérive des **lecteurs**, c'est-à-dire de la même extraction que la carte D-42 (`pol(ctx, …)` atteignables depuis chaque handler et la garde), complétée par le registre.
- **Porte** : `commandes_affectees(cle)` ⊇ l'ensemble des commandes dont un événement porte `cle` dans `liens.politiques` sur le banc.

### C-7 🟡 — Des valeurs écrites hors du domaine servi : le thème, l'échelle de note, le taux de change
- **Étendue mesurée** : `SetOwnTheme {ui.palette: zz_non_servie, ui.mode: zz}` → **écrit** dans `compte.theme_json`, alors que `SetPolicy ui.palette=zz_non_servie` est refusé (H8). Ces valeurs dorment aujourd'hui (aucune lecture), mais l'écran du lot 3 les lira. `UpdateCandidate note=0` sous l'échelle `1_5` → ok (H7) : le registre n'a aucun scénario de borne basse. `CreatePrestation taux_change = 123456789012345678901234567890` → **écrit** (colonne `numeric` sans borne), puis repris par `ClosePrestation`.
- **Correction** : `SetOwnTheme` passe par la même table de valeurs servies que `SetPolicy`. Une échelle déclare ses deux bornes. `taux_change` reçoit une borne (`politique_bornes`) et une précision.
- **Porte** : la sonde de domaine de SECURITE11 I-1, étendue aux valeurs **acceptées** : 0 valeur hors domaine écrite.

---

## 3 · Ce qui est conforme, prouvé

`temps.periode` stricte refuse un jour hors période (le 10e tour l'avait vu accepté). `DeclareNeedFilled` direct sans la clé refuse sous `auto_par_personne_signee`. Les politiques liste hors domaine sont refusées `GARDE valeur non servie` (3/3). `projet.creation_depuis_besoin = automatique_au_retenu` crée bien le projet. `change.mode = taux_saisi` refuse sans taux. La dérogation tracée lève le plafond et écrit `temps.derogation_motif`. `ManageRefs … ordre=7` ne fait plus tomber la signature. D-58 (`par_besoins` = union) et D-59 (délégation sur LYO) se vérifient à l'appel. Les gardes d'objets actifs et les doublons sont conformes.

---

**Angles morts** : voir `SECURITE11.md` §3. Propres à ce document : je n'ai pas rejoué le registre exécutable ligne à ligne (un autre vérificateur le fait), j'en ai seulement cité S-PM3, S-SD2, S-CH1/2 et S-NE ; les sections VII → XI de L4 ne sont pas servies et n'ont pas été jugées ; les sorties sont comparées au contrat par leurs clés de tête ; la passe de permutation compare les colonnes `*_code` de l'objet du **dernier** événement, pas toutes les tables écrites.
