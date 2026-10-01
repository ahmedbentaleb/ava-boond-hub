# CONFORMITE10 — les 57 commandes servies contre `_ops/SPEC_COMMANDES_L4.md` · auditeur B

> ⚠️ Numérotation : ce document garde les numéros de travail de son brouillon. Les constats rendus sont dans `CONSTATS.md` (V-162 → V-178), table de correspondance à la fin.


**57/57 commandes répondent OK sur leur cas nominal, émettent l'événement du contrat, et refusent 57/57 une clé non déclarée (`GARDE « entrée ambiguë »`).**
Mais **4 entrées du contrat sont refusées**, **16 commandes** déclarent des clés que L4 ne prévoit pas, et **16 commandes** ont un écart de comportement prouvé par appel HTTP.

> Banc : serveur `AVA_MODE=banc` sur :4002, base `ava_audit10_b`. Acteur `croise@ava.test`, qui reçoit
> les 57 permissions sur PAR **par `ManageGroups`** (57 lignes `groupe_permission_perimetre`
> posées, déclarées) ; `rh@` pour la conversion, `adm@` pour l'installation.
> Toute politique variée est remise à sa valeur : `preuves/conformite10/sondes_ciblees.txt`, dernière ligne.

---

## 1 · Le tableau habituel

Le tableau complet, une ligne par commande, est **mesuré** et **généré** : `preuves/conformite10/tableau_H.md`
(script `preuves/securite10/scripts_a10b/tableau.mjs`, entrées : `DECLARATION`, `positifs_et_non.json`, colonne Politique de L4).
Résumé :

| Mesure | Résultat | Preuve |
|---|---|---|
| Cas nominal | **57/57 ok** | `positifs_et_non.txt` |
| Événement du contrat émis | **57/57** (noms identiques à L4 ; `SignPrestation` émet en plus `CompanyStatusChanged` de sa cascade) | idem |
| Preuve par « non » — clé non déclarée `zz_non_declaree` | **57/57 → `GARDE entrée ambiguë`** | idem, colonne `inc:` |
| Preuve par « non » — identifiant mal typé | **51/52 → `GARDE entrée mal typée`** ; le 52e, `ManageGroups.perimetre` (déclaré `code`), → `INTROUVABLE` | idem, colonne `type:` |
| Entrée du contrat **refusée** | **4** : `ArchiveService {id}`, `ArchiveContact {id}` (motif exigé) · `ValidateTimesheet {temps_ids}`, `RejectTimesheet {temps_ids, motif}` | H-1 |
| Clé déclarée que le contrat ne prévoit pas | **16 commandes** | H-1 |
| Clé lue par le handler et non déclarée | **1** : `RecordQualification.commentaire` (inatteignable) | `cles_lues_non_declarees.txt` (les 2 autres lignes sont des faux positifs : `positionner` lit les deux profils selon le genre) |
| Politique lue absente de la colonne L4 | **19 commandes** (surtout `societe.perimetre.mode`, lue par la garde) ; **2** commandes dont la politique L4 n'est pas lue (`ValidateTimesheet`, `RejectTimesheet` : `temps.validation`) | `tableau_H.md` |

---

## 2 · Les constats

### H-1 🟠 — Le contrat et la déclaration divergent (« une commande, une déclaration » n'a pas rejoint L4)
- **Famille** : les clés d'une commande vivent dans **deux** textes, L4 (prose, colonne Entrée) et `server/src/declaration.ts` (`DECLARATION`, d'où dérivent les clés admises). Aucun des deux ne dérive de l'autre.
- **Étendue mesurée** :

| Sens | Commandes |
|---|---|
| Entrée L4 **refusée** par le serveur (4) | `ArchiveService` et `ArchiveContact` : L4 dit « id », le serveur exige `motif` (`GARDE Champ requis manquant : motif`, H1a/H1b) · `ValidateTimesheet` : L4 dit « temps_ids (ou prestation_id + période) », `temps_ids` → `GARDE entrée ambiguë` (H1c, H1d) · `RejectTimesheet` : « temps_ids, motif » → idem (H1e) |
| Clés déclarées **hors** L4 (16) | `CreateCompany` (siren, ville, telephone) · `RequalifyCompany` (contact_id, besoin_id — D-49) · `CreateUnit` (agence, agence_id) · `CreateContact` (unite_organisation_id/unite_id, prenom, email) · `CreateCandidate` (agence, agence_id) · `CreateResource` (societe_fournisseur_id) · `SetResourceState` (motif, jusquau — D-53) · `UploadDocument` (chemin_stockage) · `CreateNeed` (contact_id, unité, priorité, fte_vise, nb_postes_vises) · `CreateProject` (contact_id, besoin_id) · `CreatePrestation` (jours_vendus, etat, date_signature) · `ValidateTimesheet` (id) · `RejectTimesheet` (prestation_id, id, jour_debut, jour_fin) · `ManageRefs` (ordre, actif) · … |
| Clé **lue** et non déclarée (1) | `RecordQualification` lit `commentaire` (`identite.ts`) : déclarée nulle part → `GARDE entrée ambiguë` (H1f) → la colonne n'est jamais écrite |
| Contrat incomplet sur les refus | `ValidateTimesheet` sans ligne à valider → `ok`, aucun événement (H1g) ; L4 : « `ETAT` pas `a_valider` » |

- **Correction de construction** : L4 cesse d'être la source des clés : sa colonne Entrée se **génère** depuis `DECLARATION` (ou l'inverse : `DECLARATION` se génère d'un L4 balisé). Une clé ajoutée par décision (D-49, D-53) entre au contrat par le même geste.
- **Porte qui énumère la famille** : pour chaque commande de `HANDLERS`, (a) chaque clé de la colonne Entrée de L4 (lue par le même parseur que `outils/compte_commandes.sh`) est une clé ou un alias déclaré ; (b) chaque clé déclarée est au contrat ; (c) chaque `opt/req(ctx.valeurs, "k")` et `resolu(ctx, "k")` du handler et de ses aides est déclaré. Aujourd'hui : 4 + 16 + 1 rouges.

### H-2 🟠 (gravité élevée) — Des valeurs de politique « servies » n'ont aucun comportement propre (D-42 tenu en déclaration, pas en conduite)
- **Famille** : `COMPORTEMENTS` déclare qu'une valeur est servie ; P-352 compare cette déclaration à la table ; P-350 vérifie qu'il existe **une** branche sur la clé. Aucune porte ne vérifie que **chaque valeur** produit un comportement distinct. Une valeur sans branche tombe dans le `else` d'une autre.
- **Étendue mesurée** : 124 valeurs servies sur les 55 clés lues ; **35 jamais nommées** dans `server/src` (la plupart sont le `else` légitime : `libre`, `ignorer`…) — `preuves/conformite10/politiques_lues_et_servies.txt`. **Cinq** sont prouvées sans comportement :

| Valeur servie | Ce qu'elle fait réellement | Preuve |
|---|---|---|
| `temps.periode = dates_prestation_et_mois_ouvert` | **aucun** contrôle de période : un temps au **01/01/2031** sur une prestation du 01/09 au 31/12/2026 est accepté — la valeur la plus stricte est la plus lâche | H6 (témoin : refusé sous `dates_prestation`) |
| `temps.plafond_jour = refus_avec_derogation_tracee` | = `refus` ; aucune clé de dérogation (`derogation` → `entrée ambiguë`) | H16, `valeurs_sans_entree.txt` |
| `change.mode = taux_saisi` | refus permanent des devises mixtes ; aucune clé pour saisir le taux (`taux_change` → `entrée ambiguë`) | H15 |
| `projet.creation_depuis_besoin = automatique_au_retenu` | une alerte ; **0 projet** créé | H10 |
| `besoin.pourvu.mode = auto_par_personne_signee` | saute la garde §C-2 aussi pour l'appel **direct** : besoin déclaré pourvu avec 0/1 poste engagé (témoin `manuel_avec_garde` : refusé) | H5 |

  Et les politiques **liste** (33 en base, aucune contrôlée par D-42) : `doublon.societe.cles = ["telephone"]` accepté → sous `bloquer`, deux sociétés identiques sont créées (H9a) ; `candidat.complete.champs_requis = ["zz_colonne_inexistante"]` accepté → `CompleteCandidate` devient impossible (H9b). Les valeurs de `SetOwnTheme` ne passent pas par `COMPORTEMENTS` : `ui.palette = zz_non_servie` écrit dans `compte.theme_json` alors que `SetPolicy` la refuse (H8).
- **Correction de construction** : une valeur servie = **une entrée d'une table de stratégies** (`COMPORTEMENTS[cle][valeur] = fonction`), appelée par recherche, sans `if`/`else` ; une valeur qui exige une entrée (taux, dérogation) déclare cette clé dans `DECLARATION`. Les politiques liste déclarent le domaine de leurs éléments (`politique_valeur_servie` par élément) ; `SetOwnTheme` passe par la même garde que `SetPolicy`.
- **Porte** : pour chaque (clé, valeur) servie, un **différentiel** : le même scénario joué sous chaque valeur de la clé ; deux valeurs au résultat identique sur tous les scénarios → rouge, sauf alias déclaré. Pour les listes : chaque élément de chaque valeur possible doit être nommé par le lecteur.

### H-3 🔴 — Du métier écrit en dur hors des politiques
- **Famille** : une décision métier portée par un littéral, un nom de commande, ou une colonne administrable détournée — au lieu d'une politique ou d'une catégorie fermée.
- **Étendue mesurée** :

| Forme | Où | Effet prouvé |
|---|---|---|
| **Sémantique portée par `ordre`** | `cycle.ts` : `codeStatutCommercial(ctx, 1|2|3)`, `REQUALIF_ORDRE` ; `crm.ts:100` (`actuelOrdre === 2 && viseOrdre === 1`) ; vue `v_societe_statut` (migration 022) | `ManageRefs ref_statut_commercial client ordre=7` (un réordonnancement d'affichage, permis à ADM) → **toute signature d'un prospect tombe** : `GARDE aucun statut commercial actif d'ordre 2` (`ordre_semantique.txt`). Les 3 codes ont tous la catégorie `defaut` : la catégorie ne porte rien. |
| Noms de commande dans la garde générique | `agence.ts:251` (`CreateNeed` exempté sous `par_besoins`), `:326` (`ArchiveObject`), `:420` (`TransferContact`) | l'exemption `CreateNeed` permet, sous `par_besoins`, de créer un besoin sur une société de n'importe quelle agence (P-339 la classe « permis ») — règle qui n'est écrite dans aucune déclaration |
| Défauts métier en dur | `crm.ts:322` type de contact `"principal"` ; `projet.ts:159` type de mission `"regie"` ; `couverture.ts:17,41` couverture `"postes"` ; `projet.ts` code d'état `'ouvert'` inséré tel quel (au lieu de `codeCategorie`) | non paramétrables |
| Échelle de note | `identite.ts` : borne basse **0** pour toutes les échelles | `note = 0` acceptée sous `1_5` (H7) |
| Littéraux de catégorie en SQL | 27 littéraux de codes/catégories métier dans les requêtes (GRILLE10 G-1) | invisibles du grep B1 |

- **Correction de construction** : `ref_statut_commercial` reçoit une **catégorie fermée** (`prospect`, `client`, `ancien_client`) et le serveur lit par catégorie (comme les autres machines) ; `ordre` ne sert plus qu'au tri. Les exemptions de garde se **déclarent** dans `DECLARATION` (ex. `societe: { libreSous: "par_besoins" }`), la garde lit la déclaration. Les défauts deviennent des politiques (`contact.type_defaut`, `projet.type_defaut`).
- **Porte** : (a) pour chaque `ref_*` lue par le serveur, une passe qui **permute `ordre`** puis rejoue les 57 positifs : résultats identiques, sinon rouge ; (b) AST : aucune comparaison `ctx.commande === "…"` hors `executer.ts` ; (c) G-1.

### H-4 🟠 — Deux portes d'entrée vers le même effet, deux gardes différentes (G8)
- **Famille** : un effet (signer, déclarer pourvu) atteignable par deux chemins dont chacun porte **sa** garde.
- **Étendue mesurée** : 2 paires sur les 9 `CASCADES` + l'entrée `etat` de `CreatePrestation` :
  - `CreatePrestation {etat: "signee"}` crée une prestation **engagée sans TJM ni jours vendus** (`tjm_vendu = null`, `jours_vendus = null`, 4 événements) ; `SignPrestation` sur la même prestation refuse `GARDE tjm_vendu, jours_vendus et taux_occupation requis pour signer` (H4a/H4b). M-14 fige ensuite ces `null`.
  - `DeclareNeedFilled` : la garde §C-2 est sautée sous `auto_par_personne_signee` pour l'appel direct comme pour la cascade (H5).
- **Correction** : l'effet est **une** fonction qui porte sa garde (`signer(prestation)`), appelée par les deux entrées ; la garde du pourvu sait si elle est appelée en cascade par un paramètre déclaré, pas par la politique seule.
- **Porte** : pour chaque effet atteignable par plusieurs commandes (la table `CASCADES` + les états initiaux admis par `CreatePrestation`), le même jeu de refus joué par chaque entrée ; résultats identiques.

### H-5 🟠 — `liens.politiques` est photographié à l'émission : les politiques lues après manquent à l'histoire
- **Famille** : `emit()` copie `ctx.polLues` **au moment** de l'insert ; tout `pol()` appelé ensuite dans la transaction (cascade, effet) n'apparaît dans aucun événement antérieur, et M-7 interdit de compléter.
- **Étendue mesurée** (base après les sondes) : **100 %** des `ProjectCreated` (2/2) et `ProjectCreatedFromNeed` (2/2) sans `societe.passage_client.declencheur` ; des `PrestationClosed` (3/3) et `PrestationCancelled` (3/3) sans `societe.retour_prospect` ; des `CandidatePositioned` (2/2), `ResourcePositioned` (2/2), `ClientDecisionRecorded` (3/3) sans `besoin.staffing.declencheur` ; 2/5 `CompanyStatusChanged` sans `societe.passage_client.propagation`. Et 5 clés lues **en SQL** ne sont jamais tracées : `droits.surcharge_restrictive` (`v_droits_effectifs`), `temps.facturable.mode`, `candidat.note.echelle` (triggers), `ressource.etat.mode`, `societe.retour_prospect(.delai_mois)` (vues D-53).
- **Correction** : les événements s'accumulent en mémoire et s'insèrent **au COMMIT** avec la photographie finale de `polLues` ; les lectures SQL de politique passent par une fonction qui note la clé dans une table temporaire de la transaction, relue avant l'insert.
- **Porte** : pour chaque commande jouée, l'ensemble des clés de la carte (D-42) ⊆ `liens.politiques` de **chaque** événement de la transaction.

### H-6 🟠 — La sortie de `SetPolicy` (« les commandes dont le comportement change », §C-5) est une liste écrite à la main
- **Famille** : `POLITIQUE_COMMANDES` (`server/src/politiques.ts`) recopie à la main ce que le code lit.
- **Étendue mesurée** : 3 clés lues absentes → `commandes_affectees: []` pour `societe.perimetre.mode`, `staffing.inter_agences` (les deux politiques de périmètre !) et `besoin.unite_couverture` (H2) ; 2 clés listées pour **toutes** les commandes alors qu'aucune commande ne les lit (`droits.surcharge_restrictive` en SQL, `historique.tentatives_refusees` dans `tracerRefus`).
- **Correction** : la liste se **dérive** de la même extraction que P-350/P-351 (lecteurs de `pol(ctx, …)` atteignables depuis chaque handler, plus les lectures SQL déclarées).
- **Porte** : `POLITIQUE_COMMANDES` = extraction, égalité stricte, pour les 202 clés.

### H-7 🟠 — Règles d'horloge (D-53) : l'écran lit l'état dérivé, la commande juge l'état écrit
- **Famille** : D-53 calcule l'état à la **lecture** (vues `v_societe_statut`, `v_ressource_etat`) ; les commandes, elles, lisent la colonne écrite.
- **Étendue mesurée** : sous `auto_apres_delai`, une société cliente sans prestation depuis plus de 6 mois se **montre** `prospect` (`UpdateCompany` rend `statut.code = prospect`), mais `RequalifyCompany → client` refuse `ETAT requalification client → client hors cycle` (H12). Consommateurs de l'état écrit : `RequalifyCompany`, `effetsSignature` (test « prospect » sur la colonne), `retourSiDernierContrat`, `SetResourceState` (transitions sur `etat_categorie` écrit).
- **Correction** : les commandes lisent la **même** vue que l'écran (l'état lu) pour juger une transition.
- **Porte** : pour chaque vue D-53, un scénario où lu ≠ écrit : les actions offertes par la vue et le verdict de chaque commande concernée concordent.

### H-8 🟡 — Écarts mineurs de code de refus
- `CreateUnit` avec un parent interne d'une autre agence → **DROIT** ; L4 : « `GARDE` … d'une autre agence si interne » (H13).
- `ConvertCandidateToResource` avec un profil ressource existant → **GARDE** ; §C-1 dit `MUR M-3` (le serveur fait mieux que le contrat : contrat à mettre à jour).
- Porte : celle de H-1, étendue à la colonne « Refuse si ».

---

## 3 · Ce qui est conforme, prouvé

`UpdateCompany` INTROUVABLE si archivée · `ArchiveCompany` / `ArchiveService` / `TransferContact` / `ArchiveContact` : gardes d'objets actifs · `CreateContact` unité d'une autre société → GARDE · doublons `avertir/bloquer` · `CreateCandidate` / `CreateResource` profil existant → GARDE · `UpdateResource` refuse le coût · `UpdateResourceCost` : personne au seed · `UploadDocument` / `CreateAction` un seul porteur · `DeclareCVShared` / `WithdrawPositioning` motifs en événement · `RecordClientDecision` IA seul au seed, motif si négatif · `AdjustTimesheetAfterClose` : snapshot inchangé (M-6) · `ClosePrestation` écrit `snapshot_marge` dans la transaction · `SetPolicy` ADM seul, valeur hors `valeurs_possibles` → GARDE, `PolicyChanged` porte l'ancienne et la nouvelle · `ManageRefs` ne crée pas de catégorie (`ck_cat`).

---

**Angles morts** : `SECURITE10.md` §3. Propres à H : les sections VII → XI de L4 (43 commandes des lots 5.7/5.8) ne sont pas servies et n'ont pas été jugées ; les sorties ont été comparées au contrat par leurs **clés de tête**, pas champ à champ ; la colonne « Mur » de L4 nest