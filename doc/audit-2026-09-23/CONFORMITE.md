# CONFORMITE3 — les 55 commandes contre `_ops/SPEC_COMMANDES_L4.md`

**55 handlers servis = 55 commandes contractées.** Aucune commande servie hors contrat, aucune commande contractée non servie.

```bash
# servies : les exports des 5 fichiers de commandes
grep -hoE "^export async function [A-Za-z_]+" server/src/commandes/*.ts | sed 's/.*function //' | sort -u | wc -l   # 55
```
Détail : `crm.ts` 11 · `identite.ts` 13 · `besoin.ts` 14 · `projet.ts` 11 · `admin.ts` 6 = **55**.
`HANDLERS` (`executer.ts:11`) est l'union des cinq modules : **aucune fonction interne n'y fuit** — `gardePourvu` répond désormais `INTROUVABLE` (H-10 fermé).

| | |
|---|---|
| Commandes servies | **55** |
| Commandes contractées (L4) | **55** |
| Servies absentes du contrat | **0** |
| Contractées non servies | **0** |
| Permissions posées au seed | **50** — 5 commandes n'en ont aucune |
| Écarts mesurés | **11** (0 critique · 4 elevee · 7 moyenne) |

⚠️ **Les 5 commandes sans permission au seed** : `ArchiveCompany`, `ArchiveContact`, `ArchiveService`, `ArchiveObject`, `UpdateResourceCost`. La matrice les marque toutes **D** (délégation) — c'est **conforme**. ⛔ Mais L4 l.114 écrit « `UpdateResourceCost` est la **seule** commande que PERSONNE n'a au départ » : elles sont **cinq**, et l'archivage est fermé aux neuf groupes, ADM compris.

---

## Le tableau des 55

Mesuré par **appels HTTP réels** sur un serveur de banc (`AVA_MODE=banc`, port 3302, base `ava_audit3_b`), sauf mention. Preuves : `rapport/preuves/conformite3/banc3.json`, `banc3b.json`, `banc3c.json`, `suivi_H.json`.

| Commande | Existe | Entrée conforme | Sortie conforme | Refus conformes | Événement écrit | Politique lue | Mur touché |
|---|---|---|---|---|---|---|---|
| `CreateCompany` | ✅ | ✅ | ✅ | ✅ | `CompanyCreated` ✅ | `doublon.societe.mode`+`.cles` ✅ | — |
| `UpdateCompany` | ✅ | ✅ | ✅ | ✅ | `CompanyUpdated` ✅ | — ✅ | — |
| `RequalifyCompany` | ✅ | ✅ | ✅ | ✅ | `CompanyStatusChanged` ✅ | `societe.retour_prospect` ✅ | — |
| `ArchiveCompany` | ✅ | — | — | ✅ `DROIT` | — *(non atteignable)* | `societe.archivage.garde` *(non jouée)* | M-8 *(non jouée)* |
| `CreateUnit` | ✅ | ✅ | ✅ | ⚠️ **non** | `UnitCreated` ✅ | — ✅ | **M-12 contourné** — C-01 |
| `UpdateUnit` | ✅ | ✅ | ✅ | ⚠️ **non** | `UnitUpdated` ✅ | — ✅ | **M-12 contourné** — C-01 |
| `ArchiveService` | ✅ | ✅ | ✅ | ⚠️ **non** | `UnitArchived` ✅ | `service.archivage.garde` ✅ | **M-8 / périmètre** — C-01 |
| `CreateContact` | ✅ | ✅ | ✅ | ✅ | `ContactCreated` ✅ | `doublon.contact.*` ✅ | M-12 ✅ |
| `UpdateContact` | ✅ | ✅ | ✅ | ✅ | `ContactUpdated` ✅ | — ✅ | M-12 ✅ |
| `TransferContact` | ✅ | ✅ | ✅ | ✅ | `ContactTransferred` ✅ | `contact.transfert.objets_actifs` ✅ | M-12 ✅ |
| `ArchiveContact` | ✅ | — | — | ✅ `DROIT` | — *(non atteignable)* | — | M-8 *(non jouée)* |
| `CreatePerson` | ✅ | ✅ | ✅ | ✅ | `PersonCreated` ✅ | `doublon.personne.*` ✅ | — |
| `CreateCandidate` | ✅ | ✅ | ✅ | ⚠️ `GARDE` au lieu de `MUR` | `CandidateCreated` ✅ | — | M-3 *(intercepté avant)* |
| `UpdateCandidate` | ✅ | ✅ | ✅ | ✅ | `CandidateUpdated` ✅ | ⚠️ `candidat.note.echelle` **hors contrat** | — |
| `CompleteCandidate` | ✅ | ✅ | ✅ | ✅ | `CandidateCompleted` ✅ | `candidat.complete.champs_requis` ✅ | — |
| `ExitCandidate` | ✅ | ✅ | ✅ | ✅ | `CandidateExited` ✅ | — ✅ | ✅ n'écrit pas `ref_etat_candidat` (D-8) |
| `ReactivateCandidate` | ✅ | ✅ | ✅ | ✅ | `CandidateReactivated` ✅ | — ✅ | — |
| `ConvertCandidateToResource` | ✅ | ✅ | ✅ identité **non copiée** | ⚠️ 3/4 (`MUR`→`GARDE`) | `CandidateConverted` ✅ | `candidat.conversion.acteur` + `ressource.externe.*` ✅ | M-3 |
| `CreateResource` | ✅ | ✅ | ✅ | ⚠️ `GARDE` au lieu de `MUR` | `ResourceCreated` ✅ | `ressource.externe.societe_fournisseur` ✅ | M-3 |
| `UpdateResource` | ✅ | ✅ | ✅ **ne touche pas le coût** | ✅ | `ResourceUpdated` ✅ | — ✅ | — |
| `SetResourceState` | ✅ | ✅ | ✅ | ✅ | `ResourceStateChanged` ✅ | `ressource.etat.mode` ✅ | — |
| `UpdateResourceCost` | ✅ | — | — | ✅ `DROIT` pour tous | — *(non atteignable)* | — | M-15 *(non jouée)* |
| `UploadDocument` | ✅ | ✅ | ✅ | ✅ `GARDE` « exactement un porteur » | `DocumentUploaded` ✅ | — ✅ | CHECK un porteur ✅ |
| `RecordQualification` | ✅ | ✅ | ✅ | ✅ | `QualificationRecorded` ✅ | `qualification.besoin_obligatoire` ✅ | — |
| `CreateNeed` | ✅ | ✅ | ✅ | ✅ | `NeedCreated` ✅ | `besoin.contact` ✅ | M-11, M-12 ✅ |
| `UpdateNeed` | ✅ | ✅ | ✅ | ✅ | `NeedUpdated` ✅ | — ✅ | M-12 ✅ |
| `SetNeedPriority` | ✅ | ✅ | ✅ | ✅ | `NeedPriorityChanged` ✅ | — ✅ | — |
| `TakeNeedInCharge` | ✅ | ✅ | — | 🔴 `ETAT` sur un refus de **politique** | `NeedTakenInCharge` ✅ *(hors seed)* | ⚠️ `besoin.staffing.declencheur` **hors contrat** | — |
| `DeclareNeedFilled` | ✅ | ✅ | ✅ | ✅ §C-2 les 3 gardes | `NeedFilled` ✅ | `besoin.pourvu.garde_minimale` ✅ | ⚠️ vue fausse — E-03 |
| `SuspendNeed` | ✅ | ✅ | ✅ | ✅ | `NeedSuspended` ✅ motif dans l'événement | — ✅ | — |
| `ResumeNeed` | ✅ | ✅ | ✅ | ✅ | `NeedResumed` ✅ | — ✅ | — |
| `CloseNeed` | ✅ | ✅ | ✅ | ✅ | `NeedClosed` ✅ | — ✅ | — |
| `ReopenNeed` | ✅ | ✅ | ✅ | ✅ | `NeedReopened` ✅ | — ✅ | — |
| `PositionCandidate` | ✅ | ✅ | ✅ | ✅ unicité | `CandidatePositioned` + `NeedStateChanged` | ⚠️ +2 hors contrat | M-2 ✅ |
| `PositionResource` | ✅ | ✅ | ✅ | ✅ | `ResourcePositioned` ✅ | ⚠️ +2 hors contrat | M-2 ✅ |
| `DeclareCVShared` | ✅ | ✅ | ✅ état `presente` | ✅ | `CVShared` ✅ | — ✅ | étape système `cv_partage` ✅ |
| `RecordClientDecision` | ✅ | ✅ | ✅ | ✅ `DROIT` IA seul · `GARDE` décision inconnue | `ClientDecisionRecorded` ✅ | ⚠️ +3 hors contrat | motif dans l'événement ✅ |
| `WithdrawPositioning` | ✅ | ✅ | ✅ | ✅ | `PositioningWithdrawn` ✅ | — ✅ | P-5 ✅ motif hors colonne |
| `CreateProject` | ✅ | ✅ | ✅ | ✅ | `ProjectCreated` ✅ | `projet.contact` ✅ ⚠️ +1 | M-12 ✅ |
| `CreateProjectFromNeed` | ✅ | ✅ | ✅ `besoin_id` rempli | ✅ | `ProjectCreatedFromNeed` ✅ | `projet.depuis_besoin.garde_profil` ✅ ⚠️ +2 | M-12 ✅ |
| `UpdateProject` | ✅ | ✅ | ✅ | ✅ | `ProjectUpdated` ✅ | — ✅ | M-12 ✅ |
| `CloseProject` | ✅ | ✅ | ✅ | ✅ cascade fonctionne | `ProjectClosed` ✅ | `projet.cloture.garde` ✅ ⚠️ hors contrat | — |
| `CreatePrestation` | ✅ | ✅ | ✅ | 🔴 **passe sur un projet CLOS** | `PrestationCreated` ✅ | ✅ | M-1, M-4, M-15 ✅ |
| `SignPrestation` | ✅ | ✅ | ✅ | ✅ §C-3 porte de derrière gardée | `PrestationSigned` **+** `ClientStatusDerived` ✅ | **5 clés avec valeurs** ✅ | M-14 s'arme ✅ |
| `ClosePrestation` | ✅ | ✅ | ✅ | ✅ | `PrestationClosed` ✅ | ⚠️ +3 hors contrat | **snapshot écrit dans la même transaction** ✅ M-6 |
| `CancelPrestation` | ✅ | ✅ | ✅ | ✅ | `PrestationCancelled` ✅ | ⚠️ +1 hors contrat | — |
| `RecordTimesheet` | ✅ | ✅ | ✅ | ✅ période · plafond en **alerte** · règle **S** | `TimesheetRecorded` ✅ | 5 clés avec valeurs ⚠️ +2 hors contrat | M-1, M-10 ✅ |
| `AdjustTimesheetAfterClose` | ✅ | ✅ | ✅ `ajustement` | ✅ | `TimesheetAdjusted` ✅ | `temps.correction_apres_cloture` ✅ | **M-6 : le snapshot ne bouge pas** ✅ |
| `RecordAbsence` | ✅ | ✅ | ✅ | ✅ | `AbsenceRecorded` ✅ | `absence.chevauchement` ✅ ⚠️ +1 | — |
| `CreateAction` | ✅ | ✅ | ✅ | ✅ `GARDE` un seul porteur | `ActionCreated` ✅ | — ✅ | M-9 ✅ |
| `ArchiveObject` | ✅ | ✅ | ✅ | ✅ gardes présentes | 🔴 **3 types sur 10 émettent un autre événement, et perdent le motif** | `*.archivage.garde` ✅ | M-8 ✅ jamais de DELETE |
| `SetPolicy` | ✅ | ✅ | 🔴 **liste vide sur la clé rouge de §C-5** | ✅ `DROIT` ADM seul · `GARDE` hors valeurs | `PolicyChanged` ✅ **ancienne + nouvelle** | — | `mur_touche` indicatif ✅ |
| `ManageRefs` | ✅ | ✅ | ✅ | ✅ **les 3 gardes** | `RefChanged` ✅ | — ✅ | CHECK catégorie ✅ |
| `ManageGroups` | ✅ | ⚠️ périmètre = UUID ou `global` | ✅ | ⚠️ `GARDE « entrée mal typée »` au lieu d'`INTROUVABLE` | `GroupPermissionChanged` ✅ | — ✅ | M-13 ✅ |
| `SetOwnTheme` | ✅ | ⚠️ clés `ui.*` figées en TS | ✅ `theme_json` | ✅ | `ThemeChanged` ✅ | `ui.theme.choix_utilisateur` ✅ | — |

⭐ **Ce que tout le tableau confirme** : `liens.politiques` porte **la clé ET sa valeur**, partout, sans exception — exemple mesuré sur `SignPrestation` : `{"projet.contact":"obligatoire","besoin.pourvu.mode":"manuel_avec_garde","prestation.avenant.mode":"nouvelle_prestation","societe.passage_client.declencheur":"premiere_prestation_signee","societe.passage_client.propagation":"…"}`. H-6 est fermé.

---

# Les constats de conformité

---

**C-01 · `CreateUnit`, `UpdateUnit` et `ArchiveService` n'ont aucune garde de périmètre.**
Cible **CODE** · famille **H/I** · **critique** · voir GRILLE3 G-01 et SECURITE3 I-02 (même défaut, une seule correction).

---

**C-02 · `CreatePrestation` réussit sur un projet clos.**
Cible **CODE** · famille **H** · **elevee** ·
preuve : `conformite3/banc3c.json` — `CloseProject` OK puis `CreatePrestation` sur le même projet → `{"ok":true,…,"etat_code":"previsionnelle"}` ·
reproduire :
```bash
node banc3c.mjs   # section « 2. CreatePrestation sur un projet CLOS »
```
· prétend : `MACHINES_ETAT_V1.md` l.125, invariant **« un projet clos n'a plus de mission ouverte (F7) »** ; `cycle.ts:72` déclare pourtant `CreatePrestation: { depuis: [CAT.projet.ouvert] }` ·
mesure : `projetOuvert()` (`projet.ts:14-19`) ne teste que `archive_le IS NULL` — il ne lit jamais `etat_categorie`, et `exigeTransition` n'est appelée nulle part pour cette commande. Une prestation `previsionnelle` naît sur un projet `clos`, et son CA entre dans le prévisionnel ·
correction : appeler `exigeTransition(ctx, projet.etat_categorie)` dans `CreatePrestation`, ou refuser `ETAT` si la catégorie du projet n'est pas `ouvert`.

---

**C-03 · `SetPolicy` rend une liste vide pour la clé même que §C-5 cite comme sa raison d'être.**
Cible **CODE** · famille **H §C-5** · **elevee** ·
preuve :
```json
{"cle":"droits.surcharge_restrictive","valeur":"union_gagne","ancienne":"restriction_gagne","commandes_affectees":[]}
```
· reproduire :
```bash
curl -s -X POST http://127.0.0.1:3302/commandes/SetPolicy -H 'content-type: application/json' -H 'x-ava-groupe: ADM' -d '{"cle":"droits.surcharge_restrictive","valeur":"union_gagne"}'
```
· prétend : §C-5, « un admin qui bascule `droits.surcharge_restrictive` vers `union_gagne` doit **voir** qu'il affaiblit toutes les restrictions nominatives d'un coup » — « c'est la politique signalée **en rouge** dans l'écran d'administration » ·
mesure : `server/src/politiques.ts:53-54` pose `"droits.surcharge_restrictive": []` et `"historique.tentatives_refusees": []`. La clé **est** lue — par la vue SQL `v_droits_effectifs`, pas par un handler. L'écran affichera « aucune commande affectée » au moment exact où l'admin désarme toutes les surcharges. *(Le reste de §C-5 fonctionne : `commandes_affectees` vaut bien `["TakeNeedInCharge","PositionCandidate","PositionResource"]` sur `besoin.staffing.declencheur` — H-7 est fermé.)* ·
correction : deux entrées particulières — `["(toutes)"]` pour la surcharge, `["(tous les refus)"]` pour la trace — ou mieux : générer la table depuis le registre §C au lieu de la tenir à la main.

---

**C-04 · `ArchiveObject` n'émet pas son événement pour trois types sur dix, et perd le motif.**
Cible **CODE** · famille **H** · **elevee** ·
preuve : `evenement_metier` après un `ArchiveObject {type:"unite"}` →
```
     type      | objet_type | motif
 UnitArchived  | unite      | (vide)
 ObjectArchived| projet     | autre
```
· reproduire :
```bash
curl -s -X POST http://127.0.0.1:3302/commandes/ArchiveObject -H 'content-type: application/json' -H 'x-ava-groupe: IA' -d '{"type":"unite","id":"<uuid>","motif":"autre"}'
psql -c "SELECT type, motif FROM ava.evenement_metier ORDER BY id DESC LIMIT 1;"
```
· prétend : L4, `ArchiveObject` → événement **`ObjectArchived`**, entrée « type, id, **motif** », et P-5 « les motifs vont TOUS dans `evenement_metier.motif` » ·
mesure : `admin.ts:92-94` délègue `societe`/`contact`/`unite`/`service` à `ArchiveCompany`/`ArchiveContact`/`ArchiveService`, qui émettent leur propre événement **sans motif** (`crm.ts:260`, `crm.ts:395`). Le motif exigé à l'entrée est **jeté** pour les trois types les plus courants ·
correction : après la délégation, émettre `ObjectArchived` avec le motif, ou passer le motif aux trois commandes déléguées.

---

**C-05 · `NeedStateChanged` porte un code d'état écrit en dur, et pas `{de, vers}`.**
Cible **CODE** · famille **H / ADR-005** · **elevee** ·
preuve :
```
 type             | apres
 NeedStateChanged | {"etat": "staffing"}
```
· reproduire : `PositionCandidate` sur un besoin `a_pourvoir`, puis lire `evenement_metier` ·
prétend : L4 §III, V-064 du 22/09 — « la transaction émet **`NeedStateChanged` `{de, vers}`** — les états **lus en catégorie, jamais écrits en dur** » ·
mesure : `besoin.ts:25` → `emit(ctx,"NeedStateChanged","besoin",besoinId,b,{ etat: "staffing" })`. `"staffing"` n'est ni `de`, ni `vers`, ni une catégorie de `CAT.besoin` (`a_pourvoir`, `en_recherche`, `pourvu`, `suspendu`, `ferme`) : c'est le **code** du référentiel, recopié. Un référentiel renommé par `ManageRefs` et l'historique ment ·
correction : `{ de: b.etat_categorie, vers: CAT.besoin.enRecherche }`.

---

**C-06 · `v_besoin_couverture` compte les prestations archivées.**
Cible **CODE** · famille **H §C-2** · **elevee** ·
preuve : mesuré en transaction, `conformite3/couverture_archive.txt` —
```
 AVANT archivage | postes_engages = 1
 APRES archivage | postes_engages = 1
```
· reproduire :
```sql
BEGIN; UPDATE ava.prestation SET archive_le=now() WHERE etat_categorie='engage';
SELECT postes_engages FROM ava.v_besoin_couverture WHERE postes_engages>0; ROLLBACK;
```
· prétend : §C-2, `PÉRIMÈTRE E = prestation WHERE etat_categorie='engage' AND projet_id IN (…)` ; et toutes les gardes TypeScript équivalentes portent `archive_le IS NULL` ·
mesure : `001_schema.sql:1037` — `LEFT JOIN prestation pr ON pr.projet_id = p.id AND pr.etat_categorie = 'engage'`, **aucun filtre d'archive** ; `pg_get_viewdef(…) LIKE '%archive_le%'` → `f`. `couverture.ts` s'en remet entièrement à cette vue : `DeclareNeedFilled` peut déclarer pourvu un besoin couvert **uniquement par des prestations archivées** ·
correction : ajouter `AND pr.archive_le IS NULL` à la vue.

---

**C-07 · `TakeNeedInCharge` refuse toujours sous le seed livré, avec le mauvais code.**
Cible **CODE+BRAIN** · famille **H** · **moyenne** ·
preuve : `{"ok":false,"code":"ETAT","message":"la prise en charge n'est pas le déclencheur configuré"}` ; après `SetPolicy besoin.staffing.declencheur = commande_prise_en_charge`, la commande passe (`NeedTakenInCharge`) ·
reproduire :
```bash
curl -s -X POST http://127.0.0.1:3302/commandes/TakeNeedInCharge -H 'content-type: application/json' -H 'x-ava-groupe: STAF' -d '{"id":"<uuid de besoin>"}'
```
· prétend : L4 — `TakeNeedInCharge` · « Refuse si **`ETAT` hors cycle** » · Politique « — » ·
mesure : `besoin.ts:136-139` refuse sur la valeur de `besoin.staffing.declencheur` (seed : `premier_positionnement`). Le refus est une **politique**, donc `GARDE` selon L4 ; le code rend `ETAT`. Et la colonne Politique du contrat est vide alors que la commande en lit une ·
correction : rendre `GARDE`, et écrire la clé dans la ligne de contrat.

---

**C-08 · Onze commandes lisent des politiques que leur ligne de contrat n'annonce pas.**
Cible **BRAIN** · famille **H** · **moyenne** ·
preuve : mesuré dans `liens.politiques` des événements. Exemples : `UpdateCandidate` lit `candidat.note.echelle` ; `PositionCandidate`/`PositionResource` lisent `positionnement.sur_besoin_inactif` et `besoin.staffing.declencheur` ; `RecordClientDecision` lit `positionnement.cv_partage_obligatoire`, `positionnement.qualification_requise_avant_decision`, `projet.creation_depuis_besoin` ; `RecordTimesheet` lit `capacite.jour_ouvre` et `temps.validation` ; `ClosePrestation` lit `frais.mode`, `change.mode`, `marge.taux.si_ca_nul` ·
reproduire :
```bash
psql -c "SELECT type, liens->'politiques' FROM ava.evenement_metier ORDER BY id;"
```
· prétend : L4, colonne **Politique** = « la clé lue, avec son défaut » ·
mesure : les clés existent toutes au registre §C et sont **bien tracées avec leur valeur** — c'est le **contrat** qui est en retard, pas le code ·
correction : compléter la colonne Politique de L4 pour ces onze lignes.

---

**C-09 · Le contrat dit `MUR`, le code dit `GARDE` — et le code a raison.**
Cible **BRAIN** · famille **H** · **moyenne** · *(H-8 du 2ᵉ audit, toujours ouvert : `_ops/` n'a pas bougé)* ·
preuve : `CreateCandidate` sur une personne qui a déjà un profil → `GARDE « profil candidat déjà présent »` ; `CreateResource` → `GARDE « profil ressource déjà présent »` ·
reproduire : deux `CreateCandidate` de suite sur le même `personne_id` ·
prétend : L4 §II — `CreateCandidate` « `MUR` si un profil candidat existe déjà », idem `CreateResource` et §C-1 ligne 1 ·
mesure : le code intercepte avant le mur, ce que L4 l.60 réclame par ailleurs (« un refus `MUR` en production est TOUJOURS un bug de commande ») ·
correction : L4 écrit `GARDE`, et garde M-3 en colonne « Mur » — la garde et le mur ne sont pas le même refus.

---

**C-10 · Quatre commandes contractées ne sont jouées par aucune porte autrement que par leur absence de droit.**
Cible **BRAIN** · famille **H / porte aveugle** · **moyenne** ·
preuve : `journal/PORTES.md` — P-009 « ArchiveCompany refuse DROIT », P-012 « ArchiveService refuse DROIT », P-016 « ArchiveContact refuse DROIT » ; `ArchiveObject` n'a aucune permission au seed ·
reproduire :
```bash
psql -Atc "SELECT DISTINCT permission_code FROM ava.groupe_permission_perimetre" | sort > /tmp/p
# puis comparer aux 55 handlers
```
· prétend : L4 donne à ces commandes des gardes détaillées (« `GARDE` si objets actifs », « besoin ou projet actif ») ·
mesure : les gardes **existent** dans le code (`crm.ts:246-248`) et **fonctionnent** — je les ai jouées en posant la permission à la main (`ArchiveService` a bien archivé). Mais aucune porte ne les exerce : le jour où la délégation sera posée en production, ces gardes n'auront jamais été vues rouges ·
correction : trois portes de contrat qui **posent la permission** puis vérifient la garde, pas le `DROIT`.

---

**C-11 · `ManageGroups` déguise une erreur de type en garde.**
Cible **CODE** · famille **H** · **moyenne** ·
preuve : `{"perimetre":"agence"}` → `{"code":"GARDE","message":"entrée mal typée"}` ·
reproduire :
```bash
curl -s -X POST http://127.0.0.1:3302/commandes/ManageGroups -H 'content-type: application/json' -H 'x-ava-groupe: ADM' -d '{"groupe":"RR","permission":"CreateNeed","perimetre":"agence"}'
```
· prétend : L4 §V — `ManageGroups` refuse « `GARDE` permission sans périmètre » ; un périmètre introuvable est un `INTROUVABLE` (`admin.ts:262` le prévoit) ·
mesure : `admin.ts:261` fait `WHERE id = $1` avec une chaîne non-UUID → erreur PostgreSQL 22P02, rattrapée en « entrée mal typée » **avant** d'atteindre la branche `INTROUVABLE` ·
correction : valider la forme UUID avant la requête. ⭐ *C'est la seule séquelle de H-9 : le 500 a disparu partout ailleurs, la réponse est un refus des cinq familles, en HTTP 200.*

---

**C-12 · bien fait (bonne).**
55 = 55, aucune commande fantôme, aucun trou. `liens.politiques` porte clé **et** valeur sur les 55, sans exception. L'ordre garde → mutation → événement tient dans la même transaction (`executer.ts:166-176`). §C-1 : l'identité **n'est pas copiée**, le profil ressource naît sur la même `personne`. §C-3 : la porte de derrière est **fermée** — `CreatePrestation` avec `etat:"signee"` **et** `etat_code:"signee"` rendent tous deux `DROIT « CreatePrestation en signée exige SignPrestation »` pour STAF ; `SignPrestation` émet bien `PrestationSigned` **+** `ClientStatusDerived`. §C-4 : la règle **S** tient sans nommer RES (`DROIT « la ressource ne peut agir que pour elle-même »`), le plafond rend une **alerte** `{"code":"PLAFOND_JOUR","message":"5 > 1"}` et jamais un refus, la période refuse en `GARDE`. **M-6 tenu** : `ClosePrestation` écrit le snapshot dans la même transaction, avec les politiques dans `entrees`, et `AdjustTimesheetAfterClose` ne le touche pas. §C-5 : `PolicyChanged` porte **ancienne et nouvelle** valeur.

---

## Suivi des 11 constats H du 2ᵉ audit

| # | État | Mesure du 3ᵉ audit |
|---|---|---|
| **H-1** cinq commandes hors périmètre | **🟢 fermé** — ⚠️ **3 nouveaux trous** | `WithdrawPositioning`, `RecordQualification`, `UploadDocument`, `CreateAction`, `ArchiveObject` refusent toutes `DROIT` sur un objet d'une autre agence, **et réussissent sur un objet du périmètre** (contrôle positif). ⛔ Mais `CreateUnit`, `UpdateUnit`, `ArchiveService` passent — C-01 |
| **H-2** décision inconnue rangée en refus client | **🟢 fermé** | `decision:"Retenu"` et `decision:"zorglub"` → `GARDE « décision inconnue »`, 0 mutation |
| **H-3** ArchiveObject sans garde | **🟢 fermé** | projet avec prestation **signée** → `GARDE « des prestations ne sont pas closes »` ; besoin actif → `GARDE « le besoin n'est pas fermé »` |
| **H-4** ManageRefs, 2 gardes manquantes | **🟢 fermé** | désactiver `ref_etat_besoin.ouvert` → `GARDE « valeur système : on ne la désactive pas »` ; catégorie inventée → `GARDE « catégorie inconnue »` (plus de MUR) |
| **H-5** CloseProject en cascade impossible | **🟢 fermé** | politique `cascade_cloture_prestations` posée → `CloseProject` **OK**, `ProjectClosed` |
| **H-6** `liens.politiques` incomplet | **🟢 fermé** | `PrestationSigned` porte **5 clés avec leurs valeurs** |
| **H-7** SetPolicy ne rend pas les commandes affectées | **🟠 partiel** | la liste est rendue (`["TakeNeedInCharge","PositionCandidate","PositionResource"]`) — mais **vide** sur `droits.surcharge_restrictive` et `historique.tentatives_refusees` : C-03 |
| **H-8** le contrat dit MUR, le code dit GARDE | **🔴 ouvert** | cible BRAIN ; `_ops/` n'a pas bougé (D1 vide), L4 dit toujours `MUR` : C-09 |
| **H-9** entrée mal typée → HTTP 500 | **🟢 fermé** | `id` non-UUID → HTTP **200**, `GARDE « entrée mal typée »`, tracé. Séquelle mineure sur `ManageGroups` : C-11 |
| **H-10** `gardePourvu` routé comme commande | **🟢 fermé** | `POST /commandes/gardePourvu` → `INTROUVABLE « commande inconnue »` ; 55 handlers exactement |
| **H-11** garde morte d'ArchiveService | **🟢 fermé** | `CreateNeed` accepte `unite_organisation_id` (`besoin.ts:57,74`) et la garde d'`ArchiveService` le lit (`crm.ts:246-248`) |

**9 fermés · 1 partiel · 1 ouvert (BRAIN).**
