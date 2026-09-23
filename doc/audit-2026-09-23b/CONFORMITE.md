# CONFORMITE4 — les 55 commandes contre `_ops/SPEC_COMMANDES_L4.md`

**Quatrième audit · commit `cc3ff64`.** Tout ce tableau est mesuré par **appels HTTP réels** sur
`http://127.0.0.1:3402` (serveur `AVA_MODE=banc`, base `ava_audit4_b`), puis relu en base.
Preuves : `conformite4/conformite4.txt` (55 nominaux) · `conformite4/refus4.txt` (30 refus nommés) ·
`conformite4/couverture_c2.txt` (§C-2) · `conformite4/suivi_c01_c12.txt` · `securite4/perimetre4.txt` (périmètre).

## Le compte, recompté trois fois — et il tombe juste

```
L4 (colonne Commande des 6 tableaux)                     55
MATRICE_DROITS_v1.md  (commandes distinctes / lignes)    55 / 48
server/src/commandes/*.ts  (export async function)       55
server/src/agence.ts  (CORRESPONDANCE)                   55
groupe_permission_perimetre au seed (permission_code)     50   ⚠️ 5 sans titulaire
```
**Écarts, dans les deux sens : aucun.** Ni commande servie hors contrat, ni commande contractée
sans handler, ni handler sans ligne d'agence. `POST /commandes/gardePourvu` →
`INTROUVABLE « commande inconnue »`. Les **5 sans titulaire** sont `ArchiveCompany`,
`ArchiveContact`, `ArchiveService`, `ArchiveObject`, `UpdateResourceCost` — voulu pour la
dernière (L4 : « personne ne l'a au seed »), **non voulu** pour les quatre autres (constat **H-1**).

---

## Le tableau des 55

**Lecture.** *Existe* = un handler et une ligne d'agence. *Entrée / Sortie* = la commande accepte
ce que L4 annonce et rend l'objet. *Refus* = les cas nommés par L4, joués sur un objet **dans le
bon état**. *Événement* = le type écrit dans `evenement_metier`. *Politique lue* = les clés
retrouvées dans `liens.politiques`, **avec leur valeur**. *Mur* = le mur que L4 désigne.

### I · CRM — 11

| Commande | Existe | Entrée | Sortie | Refus | Événement | Politique lue | Mur |
|---|---|---|---|---|---|---|---|
| `CreateCompany` | ✅ | ✅ | ✅ société | ✅ `GARDE` doublon si `bloquer` | `CompanyCreated` ✅ | `doublon.societe.mode`+`.cles` ✅ | — |
| `UpdateCompany` | ✅ | ✅ | ✅ | ✅ `INTROUVABLE` si archivée | `CompanyUpdated` ✅ | — | — |
| `RequalifyCompany` | ✅ | ✅ | ✅ | ✅ `ETAT` hors cycle | `CompanyStatusChanged` ✅ | `societe.retour_prospect` ✅ | — |
| `ArchiveCompany` | ✅ | ✅ | ✅ `{id}` | ✅ `GARDE « des objets actifs empêchent l'archivage »` | `CompanyArchived` ✅ +motif | `societe.archivage.garde` ✅ | M-8 ✅ |
| `CreateUnit` | ✅ | ✅ | ✅ unité | ✅ **trois messages distincts** : autre société · autre agence · cycle | `UnitCreated` ✅ | — | M-12 ✅ |
| `UpdateUnit` | ✅ | ✅ | ✅ | ✅ idem + `INTROUVABLE` | `UnitUpdated` ✅ | — | M-12 ✅ |
| `ArchiveService` | ✅ | ✅ | ✅ `{id}` | ✅ `GARDE « besoin ou projet actif sur cette unité »` | `UnitArchived` ⚠️ **sans motif** | `service.archivage.garde` ✅ | M-8 ✅ |
| `CreateContact` | ✅ | ✅ | ✅ contact | ✅ `GARDE « unité d'une autre société »` | `ContactCreated` ✅ | `doublon.contact.mode`+`.cles` ✅ | M-12 ✅ |
| `UpdateContact` | ✅ | ✅ | ✅ | ✅ | `ContactUpdated` ✅ | — | M-12 ✅ |
| `TransferContact` | ✅ | ✅ | ✅ | ✅ `GARDE « objets actifs non réaffectés »` | `ContactTransferred` ✅ | `contact.transfert.objets_actifs` ✅ | M-12 ✅ |
| `ArchiveContact` | ✅ | ✅ | ✅ `{id}` | ✅ `GARDE « objets actifs sur ce contact »` | `ContactArchived` ⚠️ **sans motif** | — | M-8 ✅ |

### II · Identité et recrutement — 13

| Commande | Existe | Entrée | Sortie | Refus | Événement | Politique lue | Mur |
|---|---|---|---|---|---|---|---|
| `CreatePerson` | ✅ | ✅ | ✅ personne | ✅ `GARDE` doublon si `bloquer` | `PersonCreated` ✅ | `doublon.personne.mode`+`.cles` ✅ | — |
| `CreateCandidate` | ✅ | ✅ | ✅ profil | ✅ `GARDE « profil candidat déjà présent »` | `CandidateCreated` ✅ | — | M-3 filet ✅ |
| `UpdateCandidate` | ✅ | ✅ | ✅ | ✅ `INTROUVABLE` si archivé · `GARDE` note hors échelle | `CandidateUpdated` ✅ | `candidat.note.echelle` ✅ | — |
| `CompleteCandidate` | ✅ | ✅ | ✅ état `complete` | ✅ `GARDE « champs requis manquants : civilite, localisation, email_ou_telephone »` | `CandidateCompleted` ✅ | `candidat.complete.champs_requis` ✅ | — |
| `ExitCandidate` | ✅ | ✅ | ✅ | ✅ `ETAT` hors cycle | `CandidateExited` ✅ +motif | — | code `sorti` au seed ✅ |
| `ReactivateCandidate` | ✅ | ✅ | ✅ | ✅ `ETAT` hors cycle | `CandidateReactivated` ✅ | — | — |
| `ConvertCandidateToResource` | ✅ | ✅ | ✅ profil ressource, **personne inchangée** | ✅ `GARDE « aucun positionnement terminal_positif »` · `GARDE` fournisseur · `DROIT` acteur | `CandidateConverted` ✅ | `candidat.conversion.acteur` · `ressource.externe.societe_fournisseur` ✅ | M-3 ✅ |
| `CreateResource` | ✅ | ✅ | ✅ | ✅ `GARDE « profil ressource déjà présent »` · `GARDE « fournisseur obligatoire »` | `ResourceCreated` ✅ | `ressource.externe.societe_fournisseur` ✅ | M-3 ✅ |
| `UpdateResource` | ✅ | ✅ | ✅ | ✅ `GARDE « le coût se change par UpdateResourceCost »` | `ResourceUpdated` ✅ | — | — |
| `SetResourceState` | ✅ | ✅ | ✅ | ✅ `ETAT` hors cycle · `GARDE` état inconnu | `ResourceStateChanged` ✅ | `ressource.etat.mode` ✅ | — |
| `UpdateResourceCost` | ✅ | ✅ | ✅ | ✅ `DROIT` — **personne ne l'a au seed** | `ResourceCostChanged` ✅ | — | M-15 ✅ |
| `UploadDocument` | ✅ | ✅ | ✅ document | ✅ `GARDE « exactement un porteur »` (0 et 2 porteurs) | `DocumentUploaded` ✅ | — | CHECK un porteur ✅ |
| `RecordQualification` | ✅ | ✅ | ✅ séance | ✅ `GARDE` besoin absent si politique = oui | `QualificationRecorded` ✅ | `qualification.besoin_obligatoire` ✅ | — |

### III · Besoin et positionnement — 14

| Commande | Existe | Entrée | Sortie | Refus | Événement | Politique lue | Mur |
|---|---|---|---|---|---|---|---|
| `CreateNeed` | ✅ | ✅ | ✅ besoin | ✅ `GARDE « contact d'une autre société »` · `GARDE « FTE manquant »` | `NeedCreated` ✅ | `besoin.contact` ✅ | M-11, M-12 ✅ |
| `UpdateNeed` | ✅ | ✅ | ✅ | ✅ + `INTROUVABLE` | `NeedUpdated` ✅ | — | M-12 ✅ |
| `SetNeedPriority` | ✅ | ✅ | ✅ | ✅ `INTROUVABLE` · `GARDE` priorité hors réf | `NeedPriorityChanged` ✅ | — | — |
| `TakeNeedInCharge` | ✅ | ✅ | ✅ | ✅ `ETAT « TakeNeedInCharge hors cycle »` | `NeedTakenInCharge` ✅ | **—** ✅ *(C-07 fermé)* | — |
| `DeclareNeedFilled` | ✅ | ✅ | ✅ | ✅ les **trois** gardes de §C-2 | `NeedFilled` ✅ | `besoin.pourvu.garde_minimale` ✅ | — |
| `SuspendNeed` | ✅ | ✅ | ✅ | ✅ `ETAT` | `NeedSuspended` ✅ **motif dans l'événement** | — | — |
| `ResumeNeed` | ✅ | ✅ | ✅ | ✅ `ETAT` · `ETAT` sans état d'origine | `NeedResumed` ✅ | — | — |
| `CloseNeed` | ✅ | ✅ | ✅ | ✅ `ETAT` · `GARDE « Champ requis manquant : motif »` | `NeedClosed` ✅ +motif | — | — |
| `ReopenNeed` | ✅ | ✅ | ✅ | ✅ `ETAT` | `NeedReopened` ✅ | — | — |
| `PositionCandidate` | ✅ | ✅ | ✅ positionnement | ✅ `GARDE « unicité de positionnement violée »` | `CandidatePositioned` **+ `NeedStateChanged`** ✅ | `positionnement.unicite` · `.sur_besoin_inactif` ✅ | M-2 ✅ |
| `PositionResource` | ✅ | ✅ | ✅ | ✅ idem | `ResourcePositioned` ✅ | idem ✅ | M-2 ✅ |
| `DeclareCVShared` | ✅ | ✅ | ✅ état `presente` | ✅ `ETAT` hors cycle | `CVShared` ✅ · étape système `cv_partage` ✅ | — | — |
| `RecordClientDecision` | ✅ | ✅ | ✅ | ✅ `DROIT` IA seul · `ETAT` CV non présenté · `GARDE « décision inconnue »` · `GARDE « motif obligatoire si décision négative »` | `ClientDecisionRecorded` ✅ +motif | `positionnement.cv_partage_obligatoire` · `.qualification_requise_avant_decision` · `projet.creation_depuis_besoin` ✅ | — |
| `WithdrawPositioning` | ✅ | ✅ | ✅ | ✅ `ETAT` · `GARDE « motif de retrait inconnu ou inactif »` | `PositioningWithdrawn` ✅ **motif, P-5** | — | — |

### IV · Projet, prestation, production — 11

| Commande | Existe | Entrée | Sortie | Refus | Événement | Politique lue | Mur |
|---|---|---|---|---|---|---|---|
| `CreateProject` | ✅ | ✅ | ✅ projet | ✅ `GARDE` contact obligatoire · `GARDE « contact d'une autre société »` | `ProjectCreated` ✅ | `projet.contact` · `projet.origine_besoin` ✅ | M-12 ✅ |
| `CreateProjectFromNeed` | ✅ | ✅ | ✅ `besoin_id` rempli | ✅ `ETAT « besoin fermé »` · `GARDE « besoin.projets_max »` · `GARDE « retenu avec profil ressource requis »` | `ProjectCreatedFromNeed` ✅ | `projet.contact` · `besoin.projets_max` · `projet.depuis_besoin.garde` · `.garde_profil` ✅ | M-12 ✅ |
| `UpdateProject` | ✅ | ✅ | ✅ | ✅ `GARDE` contacts d'une autre société · `ETAT` projet clos | `ProjectUpdated` ✅ | — | M-12 ✅ |
| `CloseProject` | ✅ | ✅ | ✅ | ✅ `ETAT` · `GARDE « des prestations ne sont pas closes »` | `ProjectClosed` ✅ | `projet.cloture.garde` ✅ | — |
| `CreatePrestation` | ✅ | ✅ | ✅ prestation | ✅ `ETAT « hors cycle »` sur projet clos · `DROIT « CreatePrestation en signée exige SignPrestation »` · `GARDE « devises mixtes refusées »` · `GARDE « debut > fin »` | `PrestationCreated` (+ `PrestationSigned` si `engage`) ✅ | `projet.devises_mixtes` · `prestation.surcharge.mode` · `.seuil_pct` ✅ | M-1, M-4, M-15 ✅ |
| `SignPrestation` | ✅ | ✅ | ✅ `engage` | ✅ `ETAT` · `GARDE « tjm_vendu, jours_vendus et taux_occupation requis »` | `PrestationSigned` **+ `ClientStatusDerived`** ✅ | `projet.contact` · `prestation.avenant.mode` · `societe.passage_client.declencheur` · `.propagation` · `besoin.pourvu.mode` ✅ | **M-14 s'arme** ✅ |
| `ClosePrestation` | ✅ | ✅ | ✅ `clos` | ✅ `ETAT` · `GARDE « date de clôture après la fin »` | `PrestationClosed` ✅ | `frais.mode` · `change.mode` · `marge.taux.si_ca_nul` ✅ | **snapshot dans la même transaction** ✅ · M-6 ✅ |
| `CancelPrestation` | ✅ | ✅ | ✅ `annule` | ✅ `ETAT` · `GARDE « des temps sont déjà saisis »` | `PrestationCancelled` ✅ +motif | `prestation.annulation.garde` ✅ | — |
| `RecordTimesheet` | ✅ | ✅ | ✅ ligne | ✅ `GARDE « jour hors des dates »` · `GARDE` facturable · `DROIT` règle S · `GARDE « entrée mal typée »` · ⭐ plafond = **alerte**, jamais refus | `TimesheetRecorded` ✅ | `temps.periode` · `temps.plafond_jour` · `capacite.jour_ouvre` · `temps.facturable.mode` · `temps.validation` ✅ | M-1, M-10 ✅ |
| `AdjustTimesheetAfterClose` | ✅ | ✅ | ✅ `ajustement = true` | ✅ `GARDE` si politique = refus | `TimesheetAdjusted` ✅ +motif | `temps.correction_apres_cloture` ✅ | **M-6 : le snapshot ne bouge PAS** ✅ mesuré |
| `RecordAbsence` | ✅ | ✅ | ✅ absence | ✅ `GARDE` chevauchement · `GARDE « absence sans prestation refusée »` | `AbsenceRecorded` ✅ | `absence.chevauchement` · `absence.sans_prestation` ✅ | — |

### V · Transverse et administration — 6

| Commande | Existe | Entrée | Sortie | Refus | Événement | Politique lue | Mur |
|---|---|---|---|---|---|---|---|
| `CreateAction` | ✅ | ✅ | ✅ action | ✅ `GARDE « exactement un porteur »` (0 **et** 2) | `ActionCreated` ✅ | — | M-9 ✅ |
| `ArchiveObject` | ✅ | ✅ | ✅ `{id, type}` | ✅ `GARDE « le besoin n'est pas fermé »` · `GARDE « des prestations ne sont pas closes »` · `GARDE « type d'objet inconnu »` | `ObjectArchived` ✅ **avec motif, même pour les types délégués** | `societe.archivage.garde` · `service.archivage.garde` | M-8 ✅ · aucun `DELETE` |
| `SetPolicy` | ✅ | ✅ | ✅ + **`commandes_affectees`** | ✅ `DROIT` ADM seul · `GARDE « valeur hors valeurs_possibles »` · `GARDE` type | `PolicyChanged` ✅ **ancienne + nouvelle** | — | `mur_touche` rendu, **indicatif** ✅ (D-3) |
| `ManageRefs` | ✅ | ✅ | ✅ valeur | ✅ **les trois** : `GARDE « catégorie inconnue »` · `GARDE « valeur système : on ne la désactive pas »` · `GARDE « valeur utilisée : on ne la désactive pas »` · + `GARDE « référentiel inconnu »` | `RefChanged` ✅ | — | CHECK catégorie ✅ |
| `ManageGroups` | ✅ | ✅ | ✅ paire | ✅ `INTROUVABLE « périmètre introuvable »` *(C-11 fermé)* · `GARDE « permission inconnue »` | `GroupPermissionChanged` ✅, **et seulement si une ligne change** | — | M-13 ✅ |
| `SetOwnTheme` | ✅ | ⚠️ clés `ui.*` figées en TS | ✅ `theme_json` | ✅ `GARDE « clé de thème inconnue »` · `GARDE` si politique = non | `ThemeChanged` ✅ | `ui.theme.choix_utilisateur` ✅ | — |

⭐ **Les 55 émettent.** Aucune commande ne mute sans événement. `liens.politiques` porte la clé
**et sa valeur** sur les 55, sans exception — exemple mesuré sur `SignPrestation` :
`{"projet.contact":"obligatoire","besoin.pourvu.mode":…,"prestation.avenant.mode":…,
"societe.passage_client.declencheur":…,"societe.passage_client.propagation":…}`.

⭐ **Refus avant écriture, mesuré globalement** : 12 refus de 5 familles différentes joués d'affilée,
puis 20 tables recomptées → **aucune n'a bougé** (`securite4/refus_avant_ecriture.txt`).

---

## Les cinq blocs de L4

| Bloc | Verdict | Mesure |
|---|---|---|
| **§C-1** `ConvertCandidateToResource` | 🟠 | L'identité **ne se copie pas** : le `profil_ressource` naît sur la **même** `personne` ✅. Les quatre refus sont là ✅. ⛔ Mais la ressource peut naître dans **n'importe quelle agence** — constat **I-02** de SECURITE4 |
| **§C-2** `DeclareNeedFilled` | ✅ | Le trou est bouché, mesuré à la main : 2 personnes à 50 % = `postes_engages = 2`, `fte_engage = 1.00`. Sous `postes` (2/2) → passe ; sous `postes_et_fte` avec `fte_vise = 2.0` → **refuse** ; sous `fte` seul avec `fte_vise = 2.0` → **refuse** ; témoin `fte_vise = 1.0` → passe. ⚠️ Le **message** de refus cite toujours les postes (`« couverture insuffisante (fte) : 2/1 postes »`) alors que la cause est le FTE — constat **H-4** |
| **§C-3** `CreatePrestation` / `SignPrestation` | ✅ | La porte de derrière est fermée : `etat:"signee"` par STAF → `DROIT « CreatePrestation en signée exige SignPrestation »`. Par DP, la création en `signee` émet `PrestationCreated` **+** `PrestationSigned` et déclenche `effetsSignature`. **M-14 s'arme** : `UPDATE prestation SET tjm_vendu = 999` sur une prestation engagée → `MUR M-14 : les conditions économiques d'une prestation engagée sont figées` |
| **§C-4** `RecordTimesheet` | ✅ | Hors dates → `GARDE` ; 1,5 j sous `plafond_jour = alerte` → **`ok=true` + `{"code":"PLAFOND_JOUR","message":"1.5 > 1"}`**, jamais un refus ; règle **S** → `DROIT « la ressource ne peut agir que pour elle-même »` sans nommer RES ; `prestation_id` non-UUID → `GARDE « entrée mal typée »`, HTTP 200. **M-6 tenu** : `snapshot_marge` avant/après `AdjustTimesheetAfterClose` = `{"ca_produit":"900.00","marge":"375.00"}` → **identique** |
| **§C-5** `SetPolicy` | ✅ | `commandes_affectees` rend **55 entrées** pour `droits.surcharge_restrictive` **et** pour `historique.tentatives_refusees` *(C-03 fermé)*, et `["TakeNeedInCharge","PositionCandidate","PositionResource"]` pour `besoin.staffing.declencheur`. `PolicyChanged` porte `ancienne` **et** `valeur`. `mur_touche` est rendu et ne garde rien (D-3) |

---

## Suivi des 12 constats du 3ᵉ audit

| # | État | Mesure du 4ᵉ audit |
|---|---|---|
| **C-01** `CreateUnit`/`UpdateUnit`/`ArchiveService` sans garde de périmètre | **🟢 fermé** | `server/src/agence.ts` est né. Les trois refusent `DROIT` sur un objet d'une autre agence, **et réussissent dans le périmètre** (témoins). Et 37 autres commandes avec elles : **40 sondes → `DROIT`, 25 témoins positifs** |
| **C-02** `CreatePrestation` sur un projet clos | **🟢 fermé** | `projet.ts:283` teste `etat_categorie !== CAT.projet.ouvert` → `ETAT « CreatePrestation hors cycle »`, 0 écriture. Porte P-275 verte |
| **C-03** `SetPolicy` rend une liste vide | **🟢 fermé** | `politiques.ts:336-337` pose `TOUTES_COMMANDES` sur les deux clés. Mesuré : **55 entrées** chacune |
| **C-04** `ArchiveObject` sans événement ni motif | **🟢 fermé** | `ArchiveObject {type:"unite"}` rend **deux** événements : `["UnitArchived", null]` **et** `["ObjectArchived", "autre"]`. Le motif exigé à l'entrée arrive dans l'événement. ⚠️ Séquelle : `UnitArchived` et `ContactArchived` restent sans motif quand on appelle `ArchiveService`/`ArchiveContact` **directement** — voir **H-2** |
| **C-05** `NeedStateChanged` avec un code en dur | **🟢 fermé** | `apres = {"de":"a_pourvoir","vers":"en_recherche"}` — deux **catégories**, lues dans `CAT` |
| **C-06** `v_besoin_couverture` compte les archivées | **🟢 fermé** | migration `009_couverture_sans_archive.sql` ; `pg_get_viewdef(...) LIKE '%archive_le%'` → **`true`**. Porte P-278 verte |
| **C-07** `TakeNeedInCharge` refuse toujours, mauvais code | **🟢 fermé** | Depuis `a_pourvoir` → `ok=true`, `liens.politiques = {}` ; sur un besoin déjà `en_recherche` → `ETAT « TakeNeedInCharge hors cycle »`. La commande ne lit plus `besoin.staffing.declencheur`. ⚠️ Mais `politiques.ts:302` l'annonce encore comme lectrice — voir **H-3** |
| **C-08** onze politiques lues non annoncées | **🟢 fermé** | L4 §III porte le paragraphe V-089 qui les nomme toutes ; j'ai vérifié les onze dans `liens.politiques`, une par une |
| **C-09** le contrat dit `MUR`, le code dit `GARDE` | **🟢 fermé** | L4 §II dit maintenant « `GARDE` si un profil candidat existe déjà *(V-085, 23/09 : la commande intercepte **avant** le mur ; M-3 reste le filet)* ». Mesuré : `GARDE « profil candidat déjà présent »`, `GARDE « profil ressource déjà présent »` |
| **C-10** quatre commandes jouées seulement par leur `DROIT` | **🔴 ouvert, et démontré** | Les gardes existent et je les ai toutes jouées. Mais poser les 5 permissions manquantes fait **passer 7 portes ✅ au rouge** — voir **G-02** de GRILLE4 |
| **C-11** `ManageGroups` déguise un 22P02 en garde | **🟢 fermé** | `admin.ts:252-255` valide la forme UUID avant la requête. `{"perimetre":"agence"}` → `INTROUVABLE « périmètre introuvable »` |
| **C-12** bien fait | **🟢 tenu** | et élargi : voir le tableau des 55 |

**10 fermés · 1 tenu · 1 ouvert (C-10).**

---

# LES CONSTATS DE CONFORMITÉ

---

**H-1 · Quatre commandes de L4 n'ont aucun titulaire au seed, sans que rien ne le dise.**
Cible **BRAIN** · famille **H** · **moyenne** ·
preuve : `SELECT DISTINCT permission_code FROM ava.groupe_permission_perimetre` → **50** lignes ;
`ArchiveCompany`, `ArchiveContact`, `ArchiveService`, `ArchiveObject` sont absents, comme
`UpdateResourceCost`.
reproduire :
```bash
psql -Atc "SELECT DISTINCT permission_code FROM ava.groupe_permission_perimetre" | sort > /tmp/a
grep -oE '^  [A-Za-z]+:' server/src/agence.ts | tr -d ' :' | sort > /tmp/b   # 55
comm -13 /tmp/a /tmp/b
```
prétend : L4 §I donne à `ArchiveCompany` / `ArchiveService` / `ArchiveContact` des gardes
détaillées, et §V à `ArchiveObject` un « `GARDE` selon l'objet ». ⛔ **L4 ne signale comme
délibérément sans titulaire que `UpdateResourceCost`** (« la seule commande que PERSONNE n'a au
départ »).
mesure : quatre permissions sur cinq manquent **sans décision écrite**. `MATRICE_DROITS_v1.md`
porte pourtant une colonne D (archivage). Ce n'est pas un défaut du code — c'est un trou du
seed 005, et il produit **G-02** : les portes de ces quatre commandes ne testent que l'absence.
correction : soit semer la colonne D de la matrice, soit écrire dans L4 §I que ces quatre-là
sont, comme `UpdateResourceCost`, des délégations nominatives — et alors leurs gardes doivent
avoir des portes qui **posent** la permission.

---

**H-2 · `ArchiveService` et `ArchiveContact` appelées directement jettent le motif.**
Cible **CODE** · famille **H / P-5** · **moyenne** ·
preuve : `conformite4/conformite4.txt` — `ArchiveService | ok | id | UnitArchived` ; aucun motif.
`crm.ts:258` → `emit(ctx, "UnitArchived", "unite", id, avant, null)` — septième argument absent.
Idem `crm.ts:407` pour `ContactArchived`.
reproduire :
```bash
curl -s -X POST http://127.0.0.1:3402/commandes/ArchiveService -H 'content-type: application/json' \
  -H 'x-ava-groupe: ia@ava.test' -d '{"id":"<uuid unité>","motif":"autre"}'
psql -Atc "SELECT type, motif FROM ava.evenement_metier ORDER BY id DESC LIMIT 1"
```
prétend : L4 — « ⭐⭐ Les motifs vont **TOUS** dans `evenement_metier.motif`, jamais en colonne de
l'objet (P-5) ».
mesure : `ArchiveObject` a été corrigé (C-04 fermé) et réémet `ObjectArchived` avec le motif
**après** la délégation. Mais les trois commandes déléguées, **appelées par leur propre nom**,
n'écrivent toujours pas de motif. `ArchiveCompany` et `ArchiveContact` exigent un `motif` à
l'entrée ; `ArchiveService` ne le demande même pas. Trois chemins, deux comportements.
correction : `ArchiveService` exige `motif` comme ses deux sœurs, et les trois le passent à `emit`.

---

**H-3 · `politiques.ts` annonce que `TakeNeedInCharge` lit `besoin.staffing.declencheur` — elle ne la lit plus.**
Cible **CODE** · famille **H §C-5** · **moyenne** ·
preuve : `politiques.ts:302` → `"besoin.staffing.declencheur": ["TakeNeedInCharge","PositionCandidate","PositionResource"]` ; mais `TakeNeedInCharge` sur un besoin `a_pourvoir` rend
`liens.politiques = {}`.
reproduire : `curl … /commandes/TakeNeedInCharge` puis lire `evenement.liens.politiques`.
prétend : §C-5 — « la sortie liste ce qui change » ; `politiques.ts:284` — « Clé lue → commandes
qui **LISENT** cette clé ».
mesure : la correction de C-07 a retiré la lecture de la politique dans `TakeNeedInCharge`
(`besoin.ts:133-141` n'appelle plus `pol`) sans retirer la ligne de la table. Un admin qui
bascule `besoin.staffing.declencheur` lit « TakeNeedInCharge est affectée » — c'est faux, et
c'est précisément le mensonge que §C-5 veut éviter. ⚠️ `vues.ts:53` continue par ailleurs de
n'afficher le bouton « Prendre en charge » que si la politique vaut `commande_prise_en_charge` :
l'écran et la commande ne disent plus la même chose.
correction : retirer `TakeNeedInCharge` de cette clé, **ou** mieux — générer la table depuis
`liens.politiques` observé, comme le 3ᵉ audit le proposait déjà.

---

**H-4 · Le refus de couverture cite un nombre qui n'est pas la cause du refus.**
Cible **CODE** · famille **H §C-2** · **moyenne** ·
preuve : `conformite4/couverture_c2.txt`
```
postes_et_fte (2 postes, 1,0 FTE sur 2,0) -> GARDE « couverture insuffisante (postes_et_fte) : 2/2 postes »
fte seul       (1,0 FTE sur 2,0)          -> GARDE « couverture insuffisante (fte) : 2/1 postes »
```
reproduire : deux prestations signées à 50 % sur un besoin, puis `unite_couverture_code='fte'`,
`fte_vise=2.0`, `DeclareNeedFilled`.
prétend : L4 — le code de refus `GARDE` implique que « l'écran affiche le message **du
serveur** » ; §C-2 insiste : « **deux missions = deux postes est faux** ».
mesure : `couverture.ts:367` écrit `` `couverture insuffisante (${unite}) : ${postes}/${vises} postes` ``
quelle que soit l'unité. Sous `fte`, le message annonce « 2/1 postes » alors que les postes sont
suffisants et que c'est le FTE (1,0 sur 2,0) qui manque. ⭐ La **garde est juste** — c'est le
message qui envoie l'utilisateur chercher au mauvais endroit, et c'est exactement le piège
que §C-2 décrit.
correction : trois messages, un par unité, chacun citant **son** chiffre — `fte_engage`/`fte_vise`
sous `fte`, les deux sous `postes_et_fte`.

---

**H-5 · Une commande dont le nom est inconnu ne laisse aucune trace.**
Cible **CODE** · famille **H** · **moyenne** ·
preuve : `securite4/refus_avant_ecriture.txt` — 12 refus joués, **11** lignes dans
`tentative_refusee` (643 → 654). Le manquant est `POST /commandes/ZorglubCommand`.
reproduire :
```bash
n=$(psql -Atc "SELECT count(*) FROM ava.tentative_refusee")
curl -s -X POST http://127.0.0.1:3402/commandes/ZorglubCommand -H 'x-ava-groupe: adm@ava.test' \
  -H 'content-type: application/json' -d '{}'
psql -Atc "SELECT count(*) FROM ava.tentative_refusee"   # inchangé
```
prétend : L4 — « **5.** Trace les refus selon `POL historique.tentatives_refusees` (défaut : **à
part**) » ; la politique vaut `tracees_a_part` au seed.
mesure : `executer.ts:146-152` sort **avant** d'ouvrir la transaction, et donc avant
`tracerRefus`. Les deux refus précoces (`INTROUVABLE` commande inconnue, `GARDE` commande sans
correspondance d'agence) ne sont jamais tracés. ⚠️ C'est le seul refus qu'un attaquant produit
en boucle : balayer 500 noms de commandes ne laisse **aucune ligne** dans le journal.
correction : tracer ces deux refus comme les autres — `refuserAuthentificationNonLivree` montre
déjà comment tracer sans transaction ouverte.

---

**H-6 · Du code mort marque l'endroit exact où les gardes de périmètre ont été retirées.**
Cible **CODE** · famille **H** · **moyenne** ·
preuve : requêtes dont le résultat n'est jamais lu — `besoin.ts:276` (`const besoin`),
`besoin.ts:299` (`besoinDec`), `besoin.ts:341` (`besoin`), `identite.ts:392` (`const b`),
`identite.ts:394-405` (`pr`, `pc`), `projet.ts:347` (`projetTs`), `projet.ts:571` (`agR`) ;
plus `projet.ts:534-536` `function idSafe(s) { return s; }` et `projet.ts:387` `void projet`.
reproduire : `npx tsc --noEmit` ou `grep -n "const besoinDec\|idSafe\|const agR" server/src/commandes/*.ts`
prétend : rien dans L4 — c'est une lecture à l'œil.
mesure : **neuf** `SELECT agence_id …` inutiles, un par commande qui portait sa garde de
périmètre avant `agence.ts`. Ils coûtent un aller-retour SQL chacun, et surtout ils **font
croire** à un lecteur que la commande vérifie encore quelque chose. `idSafe()` est une fonction
identité qui ne protège rien mais porte un nom qui promet le contraire.
correction : les supprimer. Le périmètre est dans `agence.ts`, une seule fois, et c'est bien.

---

**H-7 · bien fait (bonne).**
**55 = 55 = 55 = 55**, dans les quatre sens, sans une commande fantôme. Les **55 nominaux passent**
et **chacune émet l'événement que L4 lui donne**, avec `liens.politiques` portant clé **et**
valeur. Les **30 refus nommés** par L4 rendent tous le bon code des cinq familles, jamais un 500 ;
un `prestation_id` non-UUID est une `GARDE`, pas un plantage. Les trois gardes de `ManageRefs`
tiennent **toutes les trois**, y compris « valeur utilisée » que j'ai dû fabriquer (créer un
`ref_type_action`, l'employer, puis tenter de le désactiver). §C-2 est correct au chiffre près :
deux mi-temps font deux postes et une charge, et les trois unités de couverture donnent trois
verdicts différents. §C-3 : la porte de derrière est fermée, M-14 s'arme, et le mur répond au
geste direct. §C-4 : M-6 ne bouge pas, mesuré avant/après. §C-5 : 55 commandes affectées, ancienne
et nouvelle valeur. Et 12 refus d'affilée ne font bouger **aucune** des 20 tables mesurées.
