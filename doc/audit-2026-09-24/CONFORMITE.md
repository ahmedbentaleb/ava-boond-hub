# CONFORMITE5 — les 55 commandes contre `_ops/SPEC_COMMANDES_L4.md`

**Cinquième audit · commit `b6ff087`.** Tout ce qui suit est mesuré par **appels HTTP réels** sur
`http://127.0.0.1:3502` (serveur `AVA_MODE=banc`, base `ava_audit5_b` montée par
`db/migrations/001→009` puis `db/fixtures/banc.sql`), puis **relu en base**.

Preuves : `conformite5/sweep55.txt` (les 55 au nominal) · `refus5.txt` (37 refus nommés) ·
`decisions_litterales.txt` (§III) · `blocs_et_suivi.txt` (les 5 blocs, C-03/C-07/H-2/H-4) ·
`securite5/perimetre5.txt` (périmètre).

## LE COMPTE, RECOMPTÉ CINQ FOIS — et il tombe juste

```
_ops/SPEC_COMMANDES_L4.md  (1re colonne des 6 tableaux)          57 − 2  = 55
                            (les 2 écartés : `PrestationSigned` et `ClientStatusDerived`,
                             qui sont des ÉVÉNEMENTS en 1re colonne du tableau §C-3)
_ops/MATRICE_DROITS_v1.md  (commandes distinctes / lignes)        55 / 48
server/src/commandes/*.ts  (export async function)                55
server/src/agence.ts       (CORRESPONDANCE)                       55
ava.permission             (count)                                55
ava.groupe_permission_perimetre (permission_code distinct, seed)  50   ⚠️ 5 sans titulaire
```

**Écarts, dans les deux sens : aucun.** `comm -3` entre les handlers et `CORRESPONDANCE` → vide ;
entre L4 (nettoyé) et les handlers → vide. Une commande inconnue rend
`INTROUVABLE « commande inconnue »` et une commande sans ligne d'agence est refusée avant toute
mutation (`executer.ts:150`).

⚠️ **Attention à mon propre bruit** : pendant le balayage j'ai posé `ArchiveCompany` sur le groupe
IA avec `ManageGroups`, ce qui fait **51** dans ma base. Le seed en sert **50**, et les
**5 sans titulaire** sont `ArchiveCompany`, `ArchiveContact`, `ArchiveService`,
`ArchiveObject`, `UpdateResourceCost` — **inchangé depuis le 4ᵉ audit**, constat **H-1 toujours
ouvert**. Mesuré : les neuf comptes du seed rendent tous `DROIT` sur `ArchiveCompany` **avant**
ma pose.

---

## LES 55 AU NOMINAL — existe · entrée · sortie · événement · politiques lues

**Lecture.** *Existe* = un handler **et** une ligne d'agence. *Sortie* = la commande rend l'objet
avec son `id`. *Événement* = le(s) type(s) réellement écrits dans `evenement_metier`.
*Politiques lues* = les clés retrouvées dans `liens.politiques`, **avec leur valeur**.

### I · CRM — 11/11

| Commande | Sortie | Événement mesuré | Politiques lues |
|---|---|---|---|
| `CreateCompany` | ✅ | `CompanyCreated` | `doublon.societe.mode`, `.cles` |
| `UpdateCompany` | ✅ | `CompanyUpdated` | — |
| `RequalifyCompany` | ✅ | `CompanyStatusChanged` | `societe.retour_prospect` |
| `CreateUnit` | ✅ | `UnitCreated` | — |
| `UpdateUnit` | ✅ | `UnitUpdated` | — |
| `ArchiveService` | ✅ `{id}` | `UnitArchived` ⛔ **sans motif** | `service.archivage.garde` |
| `CreateContact` | ✅ | `ContactCreated` | `doublon.contact.mode`, `.cles` |
| `UpdateContact` | ✅ | `ContactUpdated` | — |
| `TransferContact` | ✅ | `ContactTransferred` | `contact.transfert.objets_actifs` |
| `ArchiveContact` | ✅ `{id}` | `ContactArchived` ⛔ **sans motif** | — |
| `ArchiveCompany` | ✅ `{id}` | `CompanyArchived` + motif ✅ | `societe.archivage.garde` |

⭐ **Faux soupçon écarté, et il vaut d'être dit** : mon premier balayage a montré `pol=` vide sur
`RequalifyCompany`, et j'ai failli en faire un constat. En réalité **mon balayage ne l'avait
jamais menée au vert** (elle tombait en `ETAT`, la société étant déjà `client`). Rejouée sur une
société neuve `prospect → client` : `crm.ts:86` appelle `pol()` **sans condition**, et la base
porte `liens = {"politiques": {"societe.retour_prospect": "manuel"}}`. ⛔ **Un `pol=` vide sur un
refus ne prouve rien** — c'est le piège de ce contrôle.

### II · Identité et recrutement — 13/13

| Commande | Sortie | Événement mesuré | Politiques lues |
|---|---|---|---|
| `CreatePerson` | ✅ | `PersonCreated` | `doublon.personne.mode`, `.cles` |
| `CreateCandidate` | ✅ | `CandidateCreated` | — |
| `UpdateCandidate` | ✅ | `CandidateUpdated` | `candidat.note.echelle` |
| `CompleteCandidate` | ✅ | `CandidateCompleted` | `candidat.complete.champs_requis` |
| `ExitCandidate` | ✅ | `CandidateExited` + motif | — |
| `ReactivateCandidate` | ✅ | `CandidateReactivated` | — |
| `ConvertCandidateToResource` | ✅ ressource, **personne inchangée** | `CandidateConverted` | `candidat.conversion.acteur`, `ressource.externe.societe_fournisseur` |
| `CreateResource` | ✅ | `ResourceCreated` | `ressource.externe.societe_fournisseur` |
| `UpdateResource` | ✅ | `ResourceUpdated` | — |
| `SetResourceState` | ✅ | `ResourceStateChanged` | `ressource.etat.mode` |
| `UpdateResourceCost` | ✅ | `ResourceCostChanged` | — |
| `UploadDocument` | ✅ | `DocumentUploaded` | — |
| `RecordQualification` | ✅ | `QualificationRecorded` | `qualification.besoin_obligatoire` |

⛔ **`ConvertCandidateToResource` ignore l'`agence_id` de son entrée** — constat **H-5** et
SECURITE5 **I-12**.

### III · Besoin et positionnement — 14/14

| Commande | Sortie | Événement mesuré | Politiques lues |
|---|---|---|---|
| `CreateNeed` | ✅ | `NeedCreated` | `besoin.contact` |
| `UpdateNeed` | ✅ | `NeedUpdated` | — |
| `SetNeedPriority` | ✅ | `NeedPriorityChanged` | — |
| `TakeNeedInCharge` | ✅ | `NeedTakenInCharge` | **—** ✅ *(C-07 fermé)* |
| `DeclareNeedFilled` | ✅ | `NeedFilled` | `besoin.pourvu.garde_minimale` |
| `SuspendNeed` | ✅ | `NeedSuspended` + motif | — |
| `ResumeNeed` | ✅ | `NeedResumed` | — |
| `CloseNeed` | ✅ | `NeedClosed` + motif | — |
| `ReopenNeed` | ✅ | `NeedReopened` | — |
| `PositionCandidate` | ✅ | `CandidatePositioned` | `positionnement.unicite`, `.sur_besoin_inactif` |
| `PositionResource` | ✅ | `ResourcePositioned` **+ `NeedStateChanged`** ✅ | idem |
| `DeclareCVShared` | ✅ état `presente` | `CVShared` | — |
| `RecordClientDecision` | ✅ | `ClientDecisionRecorded` + motif | `positionnement.cv_partage_obligatoire`, `.qualification_requise_avant_decision`, `projet.creation_depuis_besoin` |
| `WithdrawPositioning` | ✅ | `PositioningWithdrawn` + motif (**P-5**) | — |

⛔ **Les décisions admises par `RecordClientDecision` sont un tableau littéral en TypeScript** —
constat **H-7**, le plus grave de ce rapport.

### IV · Projet, prestation, production — 11/11

| Commande | Sortie | Événement mesuré | Politiques lues |
|---|---|---|---|
| `CreateProject` | ✅ | `ProjectCreated` | `projet.contact`, `projet.origine_besoin` |
| `CreateProjectFromNeed` | ✅ `besoin_id` rempli | `ProjectCreatedFromNeed` | `projet.contact`, `besoin.projets_max`, `projet.depuis_besoin.garde`, `.garde_profil` |
| `UpdateProject` | ✅ | `ProjectUpdated` | — |
| `CloseProject` | ✅ | `ProjectClosed` | `projet.cloture.garde` |
| `CreatePrestation` | ✅ | `PrestationCreated` (+ **`PrestationSigned`** si `signee`) | `projet.devises_mixtes`, `prestation.surcharge.mode`, `.seuil_pct` (+ `projet.contact` en signature) |
| `SignPrestation` | ✅ `engage` | `PrestationSigned` **+ `ClientStatusDerived`** | `projet.contact`, `prestation.avenant.mode`, `societe.passage_client.declencheur`, `.propagation`, `besoin.pourvu.mode` |
| `ClosePrestation` | ✅ `clos` | `PrestationClosed` | `frais.mode`, `change.mode`, `marge.taux.si_ca_nul` |
| `CancelPrestation` | ✅ `annule` | `PrestationCancelled` + motif | `prestation.annulation.garde` |
| `RecordTimesheet` | ✅ | `TimesheetRecorded` | `temps.periode`, `temps.plafond_jour`, `capacite.jour_ouvre`, `temps.facturable.mode`, `temps.validation` |
| `AdjustTimesheetAfterClose` | ✅ `ajustement` | `TimesheetAdjusted` + motif | `temps.correction_apres_cloture` |
| `RecordAbsence` | ✅ | `AbsenceRecorded` | `absence.chevauchement`, `absence.sans_prestation` |

### V · Transverse et administration — 6/6

| Commande | Sortie | Événement mesuré | Politiques lues |
|---|---|---|---|
| `CreateAction` | ✅ | `ActionCreated` | — |
| `ArchiveObject` | ✅ | `ObjectArchived` + motif ✅ | — |
| `SetPolicy` | ✅ + **`commandes_affectees`** | `PolicyChanged` (ancienne + nouvelle) | — |
| `ManageRefs` | ✅ | `RefChanged` | — |
| `ManageGroups` | ✅ paire | `GroupPermissionChanged` | — |
| `SetOwnTheme` | ✅ `theme_json` | `ThemeChanged` | `ui.theme.choix_utilisateur` |

⭐ **Les 55 émettent.** Aucune commande ne mute sans écrire son événement, et `liens.politiques`
porte **la clé et sa valeur** partout où une politique est lue.

---

## LES 37 REFUS NOMMÉS PAR L4, REJOUÉS CE TOUR

| Refus attendu (L4) | Code rendu | Message mesuré |
|---|---|---|
| doublon société si `bloquer` | `GARDE` | société déjà connue (doublon.societe.mode = bloquer) |
| doublon personne si `bloquer` | `GARDE` | personne déjà connue (doublon.personne.mode = bloquer) |
| `UpdateCompany` sur archivée | `INTROUVABLE` | société introuvable ou archivée |
| `RequalifyCompany` hors cycle | `ETAT` | requalification client → client hors cycle |
| `ArchiveCompany` objets actifs | `GARDE` | des objets actifs empêchent l'archivage |
| `CreateUnit` parent autre agence | `DROIT` | permission absente ou hors périmètre |
| `CreateUnit` agence demandée hors périmètre | `DROIT` | idem — ⭐ `entreeAgence` confronte bien l'entrée |
| profil candidat déjà présent (V-085) | `GARDE` | profil candidat déjà présent |
| note hors échelle (`1_5`) | `GARDE` | note hors échelle 0..5 |
| profil ressource déjà présent | `GARDE` | profil ressource déjà présent |
| externe sans fournisseur | `GARDE` | fournisseur obligatoire pour une ressource externe |
| `UpdateResource` ne touche pas le coût | `GARDE` | le coût se change par UpdateResourceCost |
| `UpdateResourceCost` — personne ne l'a | `DROIT` | mesuré sur **rh** et **dp** |
| `SetResourceState` hors cycle | `ETAT` | transition ressource hors cycle |
| `UploadDocument` 0 porteur | `GARDE` | exactement un porteur |
| `CreateAction` 2 porteurs | `GARDE` | exactement un porteur |
| `TakeNeedInCharge` hors cycle | `ETAT` | TakeNeedInCharge hors cycle |
| positionnement sur besoin inactif | `GARDE` | positionnement sur besoin inactif refusé |
| unicité de positionnement | `GARDE` | unicité de positionnement violée |
| décision avant CV partagé | `ETAT` | décision client hors cycle (CV non présenté) |
| décision inconnue | `GARDE` | décision inconnue |
| motif obligatoire si négatif | `GARDE` | motif obligatoire si décision négative *(code `refuse_client`)* |
| `RecordClientDecision` — IA seul | `DROIT` | mesuré sur **staf** |
| motif de retrait inconnu | `GARDE` | motif de retrait inconnu ou inactif : licorne |
| `DeclareCVShared` hors cycle | `ETAT` | DeclareCVShared hors cycle |
| `CreateProject` contact obligatoire | `GARDE` | contact obligatoire |
| `CreateProjectFromNeed` garde profil | `GARDE` | retenu avec profil ressource requis |
| `CreatePrestation` en `signee` sans `SignPrestation` | `DROIT` | **CreatePrestation en signée exige SignPrestation** |
| devises mixtes (`projet.devises_mixtes = refus`) | `GARDE` | devises mixtes refusées sur ce projet |
| `CreatePrestation` début > fin | `GARDE` | debut > fin |
| couverture insuffisante | `GARDE` | couverture insuffisante (postes) : 0/1 postes |
| jour hors des dates | `GARDE` | jour hors des dates de la prestation |
| plafond du jour | ⭐ **`ok=true` + alerte** | `[{"code":"PLAFOND_JOUR","message":"1.5 > 1"}]` — **jamais un refus** |
| règle **S** (RES pour un autre) | `DROIT` | la ressource ne peut agir que pour elle-même |
| chevauchement d'absence | `GARDE` | chevauchement d'absence |
| `SetPolicy` — ADM seul | `DROIT` | mesuré sur **ia** |
| `SetPolicy` valeur hors `valeurs_possibles` | `GARDE` | valeur hors valeurs_possibles pour besoin.contact |
| `ManageRefs` catégorie inconnue | `GARDE` | catégorie inconnue |
| `ManageRefs` valeur système | `GARDE` | valeur système : on ne la désactive pas |
| `ManageRefs` référentiel inconnu | `GARDE` | référentiel inconnu |
| `ManageGroups` périmètre introuvable | `INTROUVABLE` | périmètre introuvable *(C-11 tenu)* |
| `ManageGroups` permission inconnue | `GARDE` | permission inconnue : Inconnue |
| `ArchiveObject` type inconnu | `GARDE` | type d'objet inconnu : licorne |
| `ArchiveObject` besoin non fermé | `GARDE` | le besoin n'est pas fermé |
| `SetOwnTheme` clé inconnue | `GARDE` | clé de thème inconnue : ui.licorne |
| `SetOwnTheme` politique = `non` | `GARDE` | ui.theme.choix_utilisateur = non |
| entrée mal typée (UUID) | `GARDE` | entrée mal typée — **HTTP 200** |
| session absente / compte inactif | `DROIT` | session absente · compte inconnu ou inactif |

⭐ **Refus avant écriture, recompté** : 12 refus de 5 familles joués d'affilée, puis **20 tables
recomptées** → **aucune n'a bougé**. `tentative_refusee : 59 → 71` (les 12 tracés, `à part`).

---

## LES CINQ BLOCS DE L4

| Bloc | Verdict | Mesure |
|---|---|---|
| **§C-1** `ConvertCandidateToResource` | 🟠 | L'identité **ne se copie pas** : le `profil_ressource` naît sur la **même** `personne` ✅. Les quatre refus sont là ✅ (`DROIT` acteur mesuré sur un compte hors `groupe_rh`, `GARDE` terminal_positif, `GARDE` fournisseur, M-3 en filet). ⛔ **Mais l'`agence_id` de l'entrée n'est ni honorée ni refusée** : `identite.ts:196` fait `const agenceId = ctx.compte.agence_id;`. Constat **H-5** |
| **§C-2** `DeclareNeedFilled` | 🟠 | Les trois gardes existent et la vue les rend lisibles (`v_besoin_couverture` : `postes_engages`, `fte_engage`, et **elle cite `archive_le`** — C-06 tenu). ⛔ **Le message reste faux**, et plus faux qu'au 4ᵉ tour : sous `unite_couverture_code = fte`, `fte_vise = 2.0`, `fte_engage = 0.00`, le refus dit `« couverture insuffisante (fte) : 0/1 postes »` — **la mauvaise unité ET le mauvais seuil** (1 = `nb_postes_vises`). Constat **H-4** |
| **§C-3** `CreatePrestation` / `SignPrestation` | ✅ | La porte de derrière est **fermée** : STAF (0 droit `SignPrestation`, 1 droit `CreatePrestation`) avec `etat:"signee"` → `DROIT « CreatePrestation en signée exige SignPrestation »` ; la même en prévisionnelle → `ok`. La création en `signee` par un titulaire émet `PrestationCreated` **+** `PrestationSigned`. **M-14 s'arme** : `UPDATE prestation SET tjm_vendu=999` sur l'engagée → `MUR M-14 : les conditions économiques d'une prestation engagée sont figées` |
| **§C-4** `RecordTimesheet` | ✅ | Hors dates → `GARDE` ; `1.5` sous `plafond_jour = alerte` → **`ok=true`** + `{"code":"PLAFOND_JOUR","message":"1.5 > 1"}` ; règle **S** → `DROIT` sans nommer RES ; `prestation_id` non-UUID → `GARDE « entrée mal typée »`, HTTP 200. **M-6 tenu** au geste : `UPDATE snapshot_marge SET marge=0` → `ajout seul (MUR M-6)` |
| **§C-5** `SetPolicy` | ✅ | `commandes_affectees` rend **55** pour `droits.surcharge_restrictive` **et** pour `historique.tentatives_refusees` *(C-03 tenu)*, et `["TakeNeedInCharge","PositionCandidate","PositionResource"]` pour `besoin.staffing.declencheur`. `PolicyChanged` porte `cle` + `valeur`. `DROIT` pour un non-ADM du seed |

---

## SUIVI DES 12 CONSTATS DU 4ᵉ AUDIT (C-01 → C-12)

| # | État au 5ᵉ tour | Mesure |
|---|---|---|
| **C-01** garde de périmètre sur `CreateUnit`/`UpdateUnit`/`ArchiveService` | **🟢 fermé, confirmé** | Les trois → `DROIT` sur LON, `ok` sur PAR. Élargi : **46 sondes hors agence sur 42 commandes → 46/46 `DROIT`**, 6 témoins positifs |
| **C-02** `CreatePrestation` sur projet clos | **🟢 fermé** | `CloseProject` puis `CreatePrestation` → `ETAT` ; et `debut > fin` → `GARDE`. 0 écriture |
| **C-03** `SetPolicy` rend une liste vide | **🟢 fermé** | **55 entrées** mesurées sur les deux clés transverses |
| **C-04** `ArchiveObject` sans événement ni motif | **🟢 fermé** | `ObjectArchived` **avec** `motif = autre`, relu en base |
| **C-05** `NeedStateChanged` avec un code en dur | **🟢 fermé** | `PositionResource` émet `ResourcePositioned` **+ `NeedStateChanged`** |
| **C-06** `v_besoin_couverture` compte les archivées | **🟢 fermé** | `pg_get_viewdef('ava.v_besoin_couverture') LIKE '%archive_le%'` → **`true`**, revérifié après rejeu de la migration |
| **C-07** `TakeNeedInCharge` refuse toujours | **🟢 fermé** | `a_pourvoir` → `ok`, `liens.politiques = {}` ; déjà pris → `ETAT « hors cycle »`. ⚠️ Mais **H-3 reste ouvert** : `politiques.ts:23` l'annonce encore comme lectrice, et `SetPolicy` le répète à l'admin |
| **C-08** politiques lues non annoncées | **🟢 fermé** | Les clés du paragraphe V-089 sont toutes retrouvées dans `liens.politiques`, avec leur valeur. Vérifié aussi **dans l'autre sens** sur les clés que L4 annonce : `societe.retour_prospect` est bien lue par `RequalifyCompany` (mesurée en base) |
| **C-09** le contrat dit `MUR`, le code dit `GARDE` | **🟢 fermé** | `GARDE « profil candidat déjà présent »` et `GARDE « profil ressource déjà présent »` |
| **C-10** quatre commandes jouées seulement par leur `DROIT` | **🔴 ouvert, inchangé** | Les 9 comptes du seed rendent `DROIT` sur `ArchiveCompany`. Les 4 permissions manquent toujours : `ArchiveContact`, `ArchiveObject`, `ArchiveService`, `UpdateResourceCost` — et `ArchiveCompany`, que je n'ai vue passer qu'**après** l'avoir posée moi-même |
| **C-11** `ManageGroups` déguise un 22P02 | **🟢 fermé** | `{"perimetre":"agence"}` → `INTROUVABLE « périmètre introuvable »` |
| **C-12** bien fait | **🟢 tenu** | et élargi : voir le tableau des 55 |

**10 fermés · 1 tenu · 1 ouvert (C-10).** ⚠️ Et **H-2, H-3, H-4 du 4ᵉ audit sont tous les trois
restés ouverts**, mesurés à nouveau ci-dessous.

---

# LES CONSTATS DE CONFORMITÉ

---

**H-7 · Les décisions client admises sont un tableau littéral en TypeScript : un état ajouté par `ManageRefs` est refusé par la commande.**
Cible **CODE** · famille **H / ADR-005** · **elevee** ·
preuve : `conformite5/decisions_litterales.txt` — `server/src/commandes/besoin.ts:313-314`
```ts
const positif = ["retenu", "terminal_positif", "oui", "accepte"].includes(decision);
const negatif = ["refuse", "refus", "refuse_client", "terminal_negatif", "non"].includes(decision);
if (!positif && !negatif) throw new Refus("GARDE", "décision inconnue");
```
Et la démonstration, de bout en bout :
```
ManageRefs {referentiel:"ref_etat_positionnement", code:"no_go_client",
            libelle:"No go client", categorie:"terminal_negatif"}       -> ok
SELECT code, categorie, actif FROM ref_etat_positionnement
  WHERE code='no_go_client'   ->  no_go_client / terminal_negatif / true
RecordClientDecision {decision:"no_go_client", motif:"autre"}
                                                          -> GARDE « décision inconnue »
```
reproduire :
```bash
curl -s -X POST :3502/commandes/ManageRefs -H 'x-ava-groupe: adm@ava.test' \
 -d '{"referentiel":"ref_etat_positionnement","code":"no_go_client","libelle":"No go client","categorie":"terminal_negatif"}'
# un positionnement en `presente`, puis :
curl -s -X POST :3502/commandes/RecordClientDecision -H 'x-ava-groupe: ia@ava.test' \
 -d '{"positionnement_id":"<id>","decision":"no_go_client","motif":"autre"}'
```
prétend : **ADR-005** — « tout ce qui bifurque est une politique ». L4 §V —
« ⛔ **`ManageRefs` ne peut pas inventer une catégorie.** L'admin ajoute une valeur **dans** une
catégorie existante… ⭐ **C'est ce qui permet aux 14 états Boond d'entrer sans migration** ».
Grille **B1** — « Aucun `if` métier en dur ».
mesure : la commande ne lit pas `ref_etat_positionnement` pour savoir ce qu'est une décision ;
elle compare à **neuf chaînes écrites dans le fichier**. La destination, elle, est bien lue en
catégorie (`codeCategorie(ctx, "ref_etat_positionnement", "terminal_positif")`) — **l'entrée est
en dur, la sortie est paramétrée**. Conséquence mesurée : l'admin peut ajouter l'état, le
référentiel l'accepte, la catégorie est la bonne, et **la seule commande qui sait l'écrire le
refuse**. C'est exactement la reprise Boond que L4 promet, et elle ne passera pas.
⚠️ **Le grep de B1 ne peut pas le voir** : il cherche `=== '…'`, pas
`["…","…"].includes(x)`. Ce `if` métier en dur a traversé quatre audits sans être vu.
correction : remplacer les deux tableaux par une lecture de la catégorie —
`SELECT categorie FROM ref_etat_positionnement WHERE code = $1 AND actif`, puis
`categorie === CAT.positionnement.terminal_positif / terminal_negatif` (les deux catégories sont
déjà dans `CAT`). Et ajouter `\.includes\(` au grep de B1.

---

**H-5 · `ConvertCandidateToResource` reçoit une `agence_id` au contrat, ne l'honore pas et ne la refuse pas.**
Cible **CODE** · famille **H / §C-1** · **moyenne** *(le trou d'écriture est fermé ; il reste un contrat faux)* ·
preuve : `server/src/commandes/identite.ts:196`
```ts
const agenceId = ctx.compte.agence_id;      // ⛔ `ctx.entree.agence_id` n'est jamais lu
```
Mesuré : RH de **PAR**, candidat de **PAR**, `agence_id = <LON>` en entrée → `ok=true`, et
```
SELECT agence_id FROM ava.profil_ressource WHERE personne_id='<p>'  ->  PAR
```
reproduire :
```bash
curl -s -X POST :3502/commandes/ConvertCandidateToResource -H 'x-ava-groupe: rh@ava.test' \
  -d '{"profil_candidat_id":"<candidat PAR>","type":"INTERNAL","agence_id":"<LON>"}'
psql -Atc "SELECT agence_id FROM ava.profil_ressource WHERE personne_id='<personne>'"
```
prétend : L4 §C-1 — `ENTRÉE profil_candidat_id · type_code · agence_id · [societe_fournisseur_id]`.
Et son témoin : `CreateResource` avec la même agence → `DROIT « permission absente ou hors
périmètre »`.
mesure : ⭐ **I-02 du 4ᵉ audit est fermé sur le fond** — la ressource ne naît plus dans une
agence qu'on n'a pas le droit d'écrire. ⛔ Mais elle est fermée **en supprimant le champ du
code**, pas en le jugeant : un appelant qui envoie `agence_id` reçoit `ok` et obtient **autre
chose que ce qu'il a demandé**, sans un mot. Deux commandes sœurs, deux comportements :
`CreateResource` **exige** l'agence (`req`) et la fait juger, `ConvertCandidateToResource`
l'ignore. ⚠️ Et le jour où un opérateur au périmètre **global** convertira un candidat de LON,
la ressource naîtra dans **son** agence à lui — un déplacement silencieux entre agences.
correction : soit `req(ctx.entree, "agence_id", "agence")` + `entreeAgence` sur la ligne de
`CORRESPONDANCE` (comme `CreateUnit`), soit prendre **l'agence du candidat** (`cand.agence_id`) et
retirer `agence_id` de l'entrée dans L4. ⛔ Les deux sont défendables ; **ne pas lire un champ
contractuel n'en est pas une**.

---

**H-1 · Quatre commandes de L4 n'ont toujours aucun titulaire au seed (C-10 ouvert).**
Cible **BRAIN** · famille **H** · **moyenne** · *(reconduit du 4ᵉ audit, mesuré à nouveau)*
preuve :
```
SELECT count(DISTINCT permission_code) FROM ava.groupe_permission_perimetre   -> 50 (seed)
sans titulaire : ArchiveCompany, ArchiveContact, ArchiveObject, ArchiveService, UpdateResourceCost
ArchiveCompany joué par les 9 comptes du seed  ->  DROIT × 9
```
reproduire :
```bash
psql -Atc "SELECT code FROM ava.permission p WHERE NOT EXISTS (
  SELECT 1 FROM ava.groupe_permission_perimetre g WHERE g.permission_code = p.code)" | sort
for c in ia rh staf dp adm sup rr eval res; do
  curl -s -X POST :3502/commandes/ArchiveCompany -H "x-ava-groupe: $c@ava.test" \
    -d '{"id":"<societe>","motif":"autre"}'; echo; done
```
prétend : L4 ne signale comme délibérément sans titulaire que `UpdateResourceCost`
(« la seule commande que PERSONNE n'a au départ »). §I donne à `ArchiveCompany` /
`ArchiveService` / `ArchiveContact` des gardes détaillées, §V à `ArchiveObject` un
« `GARDE` selon l'objet ».
mesure : inchangé depuis le 4ᵉ audit. **Quatre permissions sur cinq manquent sans décision
écrite**, et leurs gardes ne sont donc jouables que par un auditeur qui pose la permission —
ce que j'ai dû faire, et qui contamine mes propres mesures (voir angles morts).
correction : semer la colonne D de `MATRICE_DROITS_v1.md`, **ou** écrire dans L4 que ces quatre-là
sont des délégations nominatives comme `UpdateResourceCost`.

---

**H-2 · `ArchiveService` et `ArchiveContact` appelées directement jettent toujours le motif.**
Cible **CODE** · famille **H / P-5** · **moyenne** · *(reconduit du 4ᵉ audit, non corrigé)*
preuve : `conformite5/blocs_et_suivi.txt`
```
ArchiveService {id, motif:"autre"} -> ok  ;  SELECT type, motif ... -> UnitArchived | NULL
ArchiveContact {id, motif:"autre"} -> ok  ;                          -> ContactArchived | NULL
crm.ts:125  emit(ctx, "CompanyArchived", "societe", id, avant, null, motif);   ← 7e argument
crm.ts:258  emit(ctx, "UnitArchived",    "unite",   id, avant, null);          ← absent
crm.ts:407  emit(ctx, "ContactArchived", "contact", id, avant, null);          ← absent
```
reproduire : les deux `curl` ci-dessus, puis
`psql -Atc "SELECT type, motif FROM ava.evenement_metier ORDER BY id DESC LIMIT 2"`.
prétend : L4 — « ⭐⭐ Les motifs vont **TOUS** dans `evenement_metier.motif`, jamais en colonne de
l'objet (P-5) ».
mesure : `ArchiveObject` réémet bien `ObjectArchived` **avec** le motif (C-04 fermé), donc le
motif n'est perdu que par le **chemin direct** — trois commandes, deux comportements, et c'est
le chemin direct qu'un écran d'administration appellera. Le motif est **reçu** à l'entrée et
**jeté** au moment d'écrire l'histoire.
correction : ajouter `motif` au 7ᵉ argument des deux `emit`, et exiger `motif` dans
`ArchiveService` comme ses deux sœurs.

---

**H-3 · `SetPolicy` annonce encore `TakeNeedInCharge` comme lectrice d'une politique qu'elle ne lit plus.**
Cible **CODE** · famille **H / §C-5** · **moyenne** · *(reconduit du 4ᵉ audit, non corrigé)*
preuve :
```
politiques.ts:23  "besoin.staffing.declencheur": ["TakeNeedInCharge","PositionCandidate","PositionResource"],
SetPolicy besoin.staffing.declencheur -> commandes_affectees = 3, dont TakeNeedInCharge
TakeNeedInCharge nominal -> ok, liens.politiques = {}          ← elle ne la lit PAS
grep -n "staffing.declencheur" server/src/commandes/besoin.ts -> une seule occurrence, l. 17
```
reproduire :
```bash
curl -s -X POST :3502/commandes/SetPolicy -H 'x-ava-groupe: adm@ava.test' \
  -d '{"cle":"besoin.staffing.declencheur","valeur":"premier_positionnement"}'
curl -s -X POST :3502/commandes/TakeNeedInCharge -H 'x-ava-groupe: staf@ava.test' -d '{"id":"<besoin>"}'
```
prétend : L4 §C-5 — « ⭐⭐ **La sortie liste ce qui change.** Un admin … doit **voir** qu'il
affaiblit … ». La liste est faite pour être crue.
mesure : `TakeNeedInCharge` a cessé de lire la clé quand C-07 a été corrigé ; la table de
`politiques.ts` n'a pas suivi. L'admin qui bascule la clé croit toucher trois commandes, il en
touche deux. ⚠️ **Une liste d'effets qui exagère se paie plus tard** : on cesse de la lire.
correction : retirer `TakeNeedInCharge` de la ligne 23, ou — mieux — dériver la liste des
`pol()` réellement appelés, puisque `liens.politiques` le sait déjà à l'exécution.

---

**H-4 · Le refus de `DeclareNeedFilled` cite la mauvaise unité ET le mauvais seuil.**
Cible **CODE** · famille **H / §C-2** · **moyenne** · *(reconduit du 4ᵉ audit, aggravé)*
preuve : `conformite5/blocs_et_suivi.txt`
```
besoin : unite_couverture_code = fte · nb_postes_vises = 1 · fte_vise = 2.00
v_besoin_couverture : postes_engages = 0 · fte_engage = 0.00000000000000000000
DeclareNeedFilled -> GARDE « couverture insuffisante (fte) : 0/1 postes »
```
reproduire :
```bash
psql -c "UPDATE ava.besoin SET unite_couverture_code='fte', fte_vise=2.0 WHERE id='<b>'"
curl -s -X POST :3502/commandes/DeclareNeedFilled -H 'x-ava-groupe: staf@ava.test' -d '{"id":"<b>"}'
```
prétend : L4 — le code de refus « porte chaque cas, avec son **code** », et §C-2 distingue
explicitement `postes`, `fte`, `postes_et_fte`. L4 interdit aussi à l'écran de deviner : il
« affiche le message **du serveur** ».
mesure : le calcul est **juste** (la garde refuse bien), mais le message annonce `0/1 postes`
quand le seuil réel est `fte_vise = 2.0` et la mesure `fte_engage = 0.00`. **Le mot est faux et
le chiffre aussi** : il affiche `nb_postes_vises` au lieu de `fte_vise`. Un staffing qui lit
« 0/1 postes » va chercher un poste ; il lui manque deux ETP. ⚠️ Au 4ᵉ audit seule l'unité était
fausse ; le chiffre s'y est ajouté.
correction : composer le message avec la grandeur qui a décidé — `fte_engage`/`fte_vise` sous
`fte`, `postes_engages`/`nb_postes_vises` sous `postes`, **les deux** sous `postes_et_fte`.

---

**H-6 · bien fait (bonne).**
⭐ **Les 55 existent, les 55 émettent, et les 55 portent la valeur de chaque politique lue** —
aucune commande ne mute sans trace, `liens.politiques` n'est jamais un nom sans valeur. Cinq
comptes indépendants (L4, matrice, handlers, `CORRESPONDANCE`, table `permission`) tombent tous
sur **55**, dans les deux sens.
⭐ **Les 37 refus nommés par L4 répondent tous, avec le bon code** — et surtout : le plafond
journalier est une **alerte**, jamais un refus ; une entrée mal typée est une `GARDE` en HTTP 200,
pas un 500 ; `ManageGroups` rend `INTROUVABLE` et non un 22P02 déguisé.
⭐ **La porte de derrière de §C-3 est fermée pour de bon**, mesurée sur un compte qui a
`CreatePrestation` et **pas** `SignPrestation` : le droit ne dépend plus de la porte d'entrée.
⭐ **M-6 et M-14 répondent au geste direct**, pas seulement aux assertions — et le snapshot ne
bouge pas après `AdjustTimesheetAfterClose`.
⭐ **Dix des douze constats du 4ᵉ audit sont fermés**, dont les quatre qui touchaient l'historique
(C-04, C-05, C-07, C-08). C'est le tour où le contrat et le code ont cessé de se contredire sur
les événements.
