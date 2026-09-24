# CONFORMITÉ 7 — famille H · commit `ba9a284`

**103 cas conformes sur 104, sur les 55 commandes servies — mesurés par appels HTTP réels.**
Le contrat tient commande par commande. Les écarts viennent du contrat lui-même, pas du code : une sortie
`MUR` promise qui est devenue `GARDE`, des comptes périmés et un geste (archiver un temps) qu'aucune commande ne sert.

| Compte | Mesure | Comment |
|---|---|---|
| Commandes **contractées** (L4) | **98** | `bash outils/compte_commandes.sh` → 98 ; recompté en Python → 98 |
| dont sections I → V (lot 2) | **55** | même extraction, bornée à `# I ·` … `# VII` |
| Commandes **servies** | **55** | `export async function` de `server/src/commandes/*.ts` = clés de `HANDLERS` |
| Lignes de la table d'agence (`CORRESPONDANCE`) | **55** | `server/src/agence.ts` : 55 entrées, 0 servie sans ligne, 0 ligne sans commande |
| Lignes de `server/src/agence.ts` | **425** | `wc -l` |
| Servies non contractées | **0** | `comm` → `preuves/conformite7/servies.txt` / `contractees.txt` |
| Contractées non servies | **43** | toutes en sections VII, VIII, IX, X, XI (lots 5.7 / 5.8) |
| Permissions en base | 56 | 55 commandes + `LireDonneesRHSensibles` |
| Permissions sans titulaire au seed | **5** | `UpdateResourceCost`, `ArchiveCompany`, `ArchiveService`, `ArchiveContact`, `ArchiveObject` = D-30 ✅ |

**V-122 — le lot cible par section : ✅ présent.** I → V `lot 2` · VII, VIII, X, XI `lot 5.8` · IX `lot 5.7 (écrans)`.
⚠️ Mais l'en-tête (« 20/09/2026 · **55 commandes** ») et le bloc `<etat>` (« Commandes contractées **55** · 6 familles ») contredisent le « 98 » mesuré plus bas dans le même fichier (H-03).

---

## Le tableau — une ligne par commande

⭐ Colonnes : **OUI** = chemin nominal, événement émis ; **NON** = refus promis par « Refuse si », code mesuré ;
**Pol.** = les clés du contrat retrouvées dans `liens.politiques` de l'événement. Acteur `rr@ava.test` (toutes permissions,
agence PAR, posées par `ManageGroups`) sauf mention ; `ia`, `rh`, `staf`, `res` = comptes du seed.
Preuve : `rapport/preuves/conformite7/h_resultats.txt` (104 cas) + `h_sondes.jsonl` + `evenements_mesures.json`.

| # | Commande | OUI (événement) | NON mesuré | Pol. | Verdict |
|---|---|---|---|---|---|
| 1 | CreateCompany | `CompanyCreated` (+ alerte doublon sous `avertir`) | doublon sous `bloquer` → `GARDE` | `doublon.societe.*` | ✅ |
| 2 | UpdateCompany | `CompanyUpdated` | archivée → `INTROUVABLE` | — | ✅ |
| 3 | RequalifyCompany | `CompanyStatusChanged` | prospect → ancien_client → `ETAT` | `societe.retour_prospect` | ✅ |
| 4 | ArchiveCompany | `CompanyArchived` | objets actifs → `GARDE` (S4) | `societe.archivage.garde` | ✅ |
| 5 | CreateUnit | `UnitCreated` | parent d'une autre société → `GARDE` | — | ✅ |
| 6 | UpdateUnit | `UnitUpdated` | cycle → `GARDE` · parent autre société → `GARDE` | — | ✅ |
| 7 | ArchiveService | `UnitArchived` | besoin actif → `GARDE` | `service.archivage.garde` | ✅ |
| 8 | CreateContact | `ContactCreated` | unité d'une autre société → `GARDE` | `doublon.contact.*` | ✅ |
| 9 | UpdateContact | `ContactUpdated` | unité d'une autre société → `GARDE` | — | ✅ |
| 10 | TransferContact | `ContactTransferred` | objets actifs non réaffectés → `GARDE` | `contact.transfert.objets_actifs` | ✅ |
| 11 | ArchiveContact | `ContactArchived` | objets actifs → `GARDE` | — | ✅ |
| 12 | CreatePerson | `PersonCreated` | doublon sous `bloquer` → `GARDE` | `doublon.personne.*` | ✅ |
| 13 | CreateCandidate | `CandidateCreated` | profil existant → `GARDE` | — | ✅ |
| 14 | UpdateCandidate | `CandidateUpdated` | note hors échelle → `GARDE` | `candidat.note.echelle` | ✅ |
| 15 | CompleteCandidate | `CandidateCompleted` | champs manquants → `GARDE` · déjà actif → `ETAT` | `candidat.complete.champs_requis` | ✅ |
| 16 | ExitCandidate | `CandidateExited` | depuis brouillon → `ETAT` | — | ✅ |
| 17 | ReactivateCandidate | `CandidateReactivated` | déjà actif → `ETAT` | — | ✅ |
| 18 | ConvertCandidateToResource | `CandidateConverted` (par RH, seed) | externe sans fournisseur → `GARDE` · acteur non désigné → `DROIT` · aucun retenu → `GARDE` · **déjà un profil ressource → `GARDE`, le contrat §C-1 dit `MUR`** | les 2 clés | ⚠️ H-01 |
| 19 | CreateResource | `ResourceCreated` | externe sans fournisseur → `GARDE` · profil existant → `GARDE` | `ressource.externe.societe_fournisseur` | ✅ |
| 20 | UpdateResource | `ResourceUpdated` | coût → `GARDE` | — | ✅ |
| 21 | SetResourceState | `ResourceStateChanged` | disponible → disponible → `ETAT` | `ressource.etat.mode` | ✅ |
| 22 | UpdateResourceCost | `ResourceCostChanged` (délégué) | RH du seed → `DROIT` | — | ✅ |
| 23 | UploadDocument | `DocumentUploaded` | deux porteurs → `GARDE` · zéro → `GARDE` | — | ✅ |
| 24 | RecordQualification | `QualificationRecorded` | sans besoin (politique oui) → `GARDE` | `qualification.besoin_obligatoire` | ✅ |
| 25 | CreateNeed | `NeedCreated` | contact d'une autre société → `GARDE` · FTE manquant → `GARDE` | `besoin.contact` | ✅ |
| 26 | UpdateNeed | `NeedUpdated` | contact d'une autre société → `GARDE` | — | ✅ |
| 27 | SetNeedPriority | `NeedPriorityChanged` | inexistant → `INTROUVABLE` | — | ✅ |
| 28 | TakeNeedInCharge | `NeedTakenInCharge` | déjà en recherche → `ETAT` | — | ✅ |
| 29 | DeclareNeedFilled | `NeedFilled` | 0/1 poste → `GARDE` | `besoin.pourvu.garde_minimale` | ✅ |
| 30 | SuspendNeed | `NeedSuspended` | déjà suspendu → `ETAT` | — | ✅ |
| 31 | ResumeNeed | `NeedResumed` | non suspendu → `ETAT` | — | ✅ |
| 32 | CloseNeed | `NeedClosed` | déjà fermé → `ETAT` | — | ✅ |
| 33 | ReopenNeed | `NeedReopened` | non fermé → `ETAT` | — | ✅ |
| 34 | PositionCandidate | `CandidatePositioned` (+ `NeedStateChanged`) | unicité → `GARDE` | `positionnement.unicite` · `…sur_besoin_inactif` · ⚠️ `besoin.staffing.declencheur` absent si le besoin ne change pas d'état | ⚠️ H-04 |
| 35 | PositionResource | `ResourcePositioned` | unicité → `GARDE` | idem | ⚠️ H-04 |
| 36 | DeclareCVShared | `CVShared` | déjà présenté → `ETAT` | — | ✅ |
| 37 | RecordClientDecision | `ClientDecisionRecorded` (IA) | STAF → `DROIT` · CV non présenté → `ETAT` · négatif sans motif → `GARDE` | les 3 clés | ✅ |
| 38 | WithdrawPositioning | `PositioningWithdrawn` | déjà décidé → `ETAT` | — | ✅ |
| 39 | CreateProject | `ProjectCreated` | sans contact (obligatoire) → `GARDE` | `projet.contact` | ✅ |
| 40 | CreateProjectFromNeed | `ProjectCreatedFromNeed` | besoin fermé → `ETAT` | `projet.depuis_besoin.garde_profil` | ✅ |
| 41 | UpdateProject | `ProjectUpdated` | contact d'une autre société → `GARDE` | — | ✅ |
| 42 | CloseProject | `ProjectClosed` | déjà clos → `ETAT` | — | ✅ |
| 43 | CreatePrestation | `PrestationCreated` (+ `PrestationSigned` + `ClientStatusDerived` en signée) | signée par STAF sans `SignPrestation` → `DROIT` | `projet.devises_mixtes` · `prestation.surcharge.*` | ✅ |
| 44 | SignPrestation | `PrestationSigned` + `ClientStatusDerived` | déjà signée → `ETAT` | `societe.passage_client.*` · `prestation.avenant.mode` | ✅ |
| 45 | ClosePrestation | `PrestationClosed` + `snapshot_marge` | prévisionnelle → `ETAT` · date après la fin → `GARDE` | `frais.mode` · `change.mode` · `marge.taux.si_ca_nul` | ✅ |
| 46 | CancelPrestation | `PrestationCancelled` | close → `ETAT` | — | ✅ |
| 47 | RecordTimesheet | `TimesheetRecorded` | hors dates → `GARDE` · RES pour autrui → `DROIT` | les 5 clés | ✅ |
| 48 | AdjustTimesheetAfterClose | `TimesheetAdjusted`, **snapshot inchangé (md5)** | non close → `ETAT` · politique refus → `GARDE` | `temps.correction_apres_cloture` | ✅ |
| 49 | RecordAbsence | `AbsenceRecorded` | chevauchement sous `refus` → `GARDE` | `absence.chevauchement` | ✅ |
| 50 | CreateAction | `ActionCreated` | deux porteurs → `GARDE` | — | ✅ |
| 51 | ArchiveObject | `ObjectArchived` | société → `GARDE utiliser ArchiveCompany` · besoin non fermé → `GARDE` · hors agence → `DROIT` | — | ✅ (voir H-02) |
| 52 | SetPolicy | `PolicyChanged` (ancienne + nouvelle), sortie `commandes_affectees` | hors `valeurs_possibles` → `GARDE` · RR → `DROIT` | — | ✅ |
| 53 | ManageRefs | `RefChanged` | catégorie inconnue → `GARDE` · système → `GARDE` · utilisée → `GARDE` | — | ✅ |
| 54 | ManageGroups | `GroupPermissionChanged` | sans périmètre → `GARDE` · permission inconnue → `GARDE` | — | ✅ |
| 55 | SetOwnTheme | `ThemeChanged` | politique = non → `GARDE` · clé hors thème → `GARDE` | `ui.theme.choix_utilisateur` | ✅ |

⭐ **« Refus avant toute mutation »** : sur les 52 refus hors agence de S4 et les 12 d'`ArchiveObject` (S6), l'empreinte md5 des tables métier ne bouge pas ; les refus de H ne sont pas empreints un par un (angle mort 6).
⭐ **« Une commande qui mute et n'émet pas »** : aucune (ManageGroups sans changement rend `inchange: true`, sans événement ni écriture).

⛔ **Ce tableau mesure la conformité au contrat, pas au périmètre.** Les 7 contournements d'agence sont dans SECURITE7 (I-01 → I-06) — le contrat
les autorise par omission : il ne dit jamais qu'**une seule** clé désigne l'objet.

---

## Les constats

### H-01 · Contrat : `ConvertCandidateToResource` promet `MUR M-3`, la commande rend `GARDE`

| | |
|---|---|
| **Défaut** | Le bloc §C-1 n'a pas suivi V-085 (qui a fait intercepter le doublon de profil **avant** le mur pour `CreateCandidate`/`CreateResource`). |
| **Cible** | `_ops/SPEC_COMMANDES_L4.md` §C-1 (« La personne a déjà un profil ressource \| `MUR` **M-3** ») · `server/src/commandes/identite.ts:209-214` |
| **Famille** | H |
| **Gravité** | 🟡 faible — le code a raison (un `MUR` visible est un bug de garde, dit L4 lui-même) |
| **Preuve** | `h_resultats.txt`, cas « déjà un profil ressource » |
| **Reproduire** | `rh@ava.test` : `ConvertCandidateToResource` deux fois sur le même candidat |
| **Prétend** | `MUR` · **Mesure** `GARDE « profil ressource déjà présent »` |
| **Correction** | Aligner §C-1 sur V-085 (`GARDE`, M-3 reste le filet). |

### H-02 · Un temps saisi ne peut pas être annulé : aucune commande n'archive `temps`

| | |
|---|---|
| **Défaut** | §C-4 : « Annuler une saisie = l'**ARCHIVER**, jamais une quantité négative ». `ArchiveObject` ne connaît que 10 types ; `temps`, `absence`, `document`, `positionnement`, `qualification`, `prestation` → `GARDE type d'objet inconnu`. |
| **Cible** | `server/src/commandes/admin.ts:38-49` · `_ops/SPEC_COMMANDES_L4.md` §C-4 |
| **Famille** | H |
| **Gravité** | 🟡 moyenne — une saisie fausse reste comptée dans la marge (`ClosePrestation` somme `temps`) jusqu'à un ajustement |
| **Preuve** | `rapport/preuves/securite7/s7_resultats.txt` (`ArchiveObject type=prestation/positionnement`) |
| **Correction** | Trancher au contrat : type `temps` dans `ArchiveObject` (garde : prestation non close), ou une commande dédiée. |

### H-03 · L4 se contredit sur son propre compte

En-tête « **55 commandes** » et `<etat>` « Commandes contractées **55** · 6 familles », contre « **98** » mesuré (§V, V-122) et 11 sections.
Ordre des sections : I, II, III, IV, V, **VII, VIII, IX, X, XI, VI**. **Cible** `_ops/SPEC_COMMANDES_L4.md:3`, bloc `<etat>`.
**Gravité** 🟡 faible. **Correction** : l'en-tête renvoie à la commande de mesure, il ne recopie pas le nombre.

### H-04 · Une politique lue APRÈS l'événement n'est pas dans `liens.politiques`

`PositionCandidate`/`PositionResource` émettent `CandidatePositioned` puis lisent `besoin.staffing.declencheur` (`maybeStaffingPremierPositionnement`).
Quand le besoin ne change pas d'état, la clé lue n'apparaît dans **aucun** événement. Règle 4 de L4 (« les clés lues et leur valeur »).
**Cible** `server/src/commandes/besoin.ts:256-264`. **Gravité** 🟡 faible. **Preuve** `politiques_vs_L4.txt`.
**Correction** : lire les politiques avant d'émettre, ou émettre en dernier.

### H-05 · `commandes_affectees` annonce `ArchiveObject` pour deux politiques qu'il ne lit pas

`POLITIQUE_COMMANDES` : `societe.archivage.garde` et `service.archivage.garde` → `ArchiveCompany`/`ArchiveService` **et `ArchiveObject`** ;
or `ArchiveObject` renvoie ces types vers la commande dédiée (D-31). La sortie de `SetPolicy` (§C-5 : « la LISTE des commandes dont le
comportement change ») ment d'une ligne. **Cible** `server/src/politiques.ts:10-11`. **Gravité** 🟡 faible.

### H-06 · `ArchiveObject` garde en dur, sans politique

`besoin` non fermé, `projet` à prestation ouverte, `ressource` à prestation signée : trois gardes écrites dans le code par `if (type === …)`,
aucune clé du registre. L4 dit seulement « `GARDE` selon l'objet ». **Cible** `server/src/commandes/admin.ts:86-107`. **Gravité** 🟡 moyenne (ADR-005).

---

## ANGLES MORTS

1. **Un seul « non » par cas de refus** : chaque colonne « Refuse si » est couverte au moins une fois, pas chaque combinaison de politique × état.
2. **Formes de sortie** : comparées au contrat par l'événement et le code ; les schémas JSON n'existent pas (L4 `<etat>`), donc aucune comparaison champ à champ.
3. **`CreateUnit` « d'une autre agence si interne »** : aucune société interne dans le décor — non sondé.
4. **`besoin.pourvu.mode` autres que `manuel_avec_garde`/`auto_par_prestation_signee`**, et `societe.passage_client.propagation` : non sondés.
5. **Les 43 commandes non servies** : rien à mesurer ; leurs tables sont fermées en écriture (SECURITE7).
6. **Écriture sur refus en H** : vérifiée par transaction (code) et par S4/S6, pas par empreinte à chacun des 47 refus de H.
