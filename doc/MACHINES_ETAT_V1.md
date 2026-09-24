# Machines d'état Ava Manager v1

Date : 17/09/2026 · Statut : **décidé** — G1–G15 tranchés le 17/09/2026. Les marques `[Gn]` restent pour la traçabilité.
Règle commune : chaque transition est une **commande** nommée, avec un acteur, une garde, un événement (ADR-004). Un état stocké n'est jamais modifié autrement que par sa commande.

**Patch 4d (ADR-005, 17/09 soir).** Un état n'est plus un CHECK sur une liste de codes : c'est une **FK vers `ref_etat_<objet>`**, dont chaque ligne a une **catégorie fermée**. Les transitions, gardes et vues raisonnent sur la **catégorie** ; l'admin renomme, ajoute une valeur dans une catégorie, désactive une valeur non système — sans code. Les noms ci-dessous sont les **codes système par défaut**, avec leur catégorie entre parenthèses. Là où une garde est une bifurcation, la clé de politique est citée : la valeur par défaut reproduit exactement le comportement écrit.

## 0. L'archivage n'est pas un état

`archive_le` est une colonne transverse (ADR-004), possible seulement depuis un état **terminal** du cycle de l'objet (ou pour un objet sans cycle : société, contact, unité — sous BM-17). Aucun cycle ci-dessous ne contient « archivé ». `[G12]`

## 1. Besoin — 5 catégories (DEC-13, F6, F3) · codes système : ouvert (a_pourvoir) · staffing (en_recherche) · pourvu · suspendu · ferme

```
ouvert ──(1er positionnement)──▶ staffing ──(DeclareNeedFilled)──▶ pourvu
  │                                 │                                 │
  └──── SuspendNeed ─────────────── ┼──── SuspendNeed ───────────────┘──▶ suspendu ──(ResumeNeed)──▶ état d'origine
  └──── CloseNeed ───────────────── ┴──── CloseNeed ────────────────────▶ fermé ──(ReopenNeed)──▶ ouvert ou staffing
```

| De | Vers | Commande | Acteur | Garde | Événement |
|---|---|---|---|---|---|
| a_pourvoir | en_recherche | selon `besoin.staffing.declencheur` : **effet du premier `Position*`** (défaut) · `TakeNeedInCharge` · effet du retenu | IA, RH, Staffing | `[G3]` | `NeedTakenInCharge` (commande) · `NeedStateChanged` (effet d'un `Position*` ou du retenu) *(D-4 ; ⭐ V-064, 22/09 : L4 le porte désormais comme événement d'effet)* |
| en_recherche | pourvu | selon `besoin.pourvu.mode` : **`DeclareNeedFilled` manuel** (défaut) · automatique à `SignPrestation` | Staffing | garde `besoin.pourvu.garde_minimale` (défaut : **`count(prestations engage du besoin) ≥ nb_postes_vises`**, F3 — *T-1 tranché 17/09 soir* ; options : ≥ 1 · aucune) `[G4]` ; l'écran montre *n prestations signées / m postes visés*, et à part le nombre de personnes distinctes | `NeedFilled` (manuel ; automatique : même événement, `auto: true`) *(D-4)* |
| ouvert, staffing, pourvu | suspendu | `SuspendNeed` | IA, Staffing | motif obligatoire | `NeedSuspended` *(D-4)* |
| suspendu | état précédent | `ResumeNeed` | IA, Staffing | l'état d'origine est mémorisé dans l'événement | `NeedResumed` *(D-4)* |
| ouvert, staffing, pourvu, suspendu | fermé | `CloseNeed` | IA | motif ; **ne touche pas** les projets | `NeedClosed` *(D-4)* |
| fermé | ouvert (ou staffing s'il a des positionnements actifs) | `ReopenNeed` | IA | commande dédiée (F6) | `NeedReopened` *(D-4)* |

Positionner sur `pourvu`, `suspendu`, `ferme` : selon `positionnement.sur_besoin_inactif` — **refus** (défaut, F5) · alerte · libre. La priorité P1–P3 est une colonne indépendante, sans machine.

## 2. Candidat — 3 catégories (F19) · codes système : draft (brouillon) · complete (actif) · **sorti** — ⚠️ **code semé, NON système** (`systeme = false`, migration 005) : l'admin peut le désactiver, et `ExitCandidate` répond alors `GARDE` *(D-8 ; V-064, 22/09)* · l'admin en ajoute d'autres (Boond : « A supprimer », « Vivier »…). ⛔ **Une commande n'écrit jamais un référentiel** : `ExitCandidate` sans code de catégorie `sorti` actif = refus `GARDE`

```
draft ──(CompleteCandidate)──▶ complete
```

| De | Vers | Commande | Garde |
|---|---|---|---|
| brouillon | actif | `CompleteCandidate` | champs de la politique `candidat.complete.champs_requis` renseignés |
| actif | sorti | `ExitCandidate` | motif ; réversible par `ReactivateCandidate` |

**La conversion n'est pas un état** : `ConvertCandidateToResource` (RH, F9) crée `profil_ressource` sur la même personne. Le candidat reste `draft` ou `complete`. Un motif `converti` peut être porté par l'événement `CandidateConverted`, pas par la colonne.

## 3. Ressource — 3 catégories (US1, F26) · codes système : en_cours (en_mission) · intercontrat (disponible) · sortie (sorti)

```
en_cours ◀──▶ intercontrat ──▶ sortie
```

| De | Vers | Commande | Garde |
|---|---|---|---|
| en_mission ↔ disponible | `SetResourceState` | RH, Staffing *(D-5, 21/09 : la MATRICE fait foi)* | selon `ressource.etat.mode` : **manuel** (défaut, F26) · dérivé des prestations `engage` couvrant aujourd'hui |
| en_cours, intercontrat | sortie | `SetResourceState` | alerte (pas refus) si une prestation est encore `signee` non clôturée |
| sortie | en_cours | `SetResourceState` | retour possible (réembauche), tracé |

## 4. Positionnement — 5 catégories `[G10]` · codes système : propose · presente · retenu (terminal_positif) · refuse_client (terminal_negatif) · retire

```
propose ──(DeclareCVShared)──▶ presente ──(RecordClientDecision: retenu)──▶ retenu
   │                              │
   │                              └──(RecordClientDecision: refusé)──▶ refuse_client
   └──── WithdrawPositioning ──── ┴───────────────────────────────────▶ retire  (motif : désistement | no_go_interne | autre)
```

| De | Vers | Commande | Acteur | Garde | Événement |
|---|---|---|---|---|---|
| — | propose | `PositionCandidate` / `PositionResource` | IA, RH, Staffing | besoin `a_pourvoir` / `en_recherche` (`positionnement.sur_besoin_inactif`) ; unicité selon `positionnement.unicite` (défaut : pas de positionnement actif de la même personne) `[G7]` | `CandidatePositioned` / `ResourcePositioned` *(D-4)* |
| propose | presente | `DeclareCVShared` (ou effet de `SendCV` si le lot email est retenu) | contributeur | document CV présent | `CVShared` *(D-4)* |
| presente | retenu | `RecordClientDecision(retenu)` | IA | — | `ClientDecisionRecorded` *(D-4 : un seul événement, la décision porte l'état)* |
| presente | refuse_client | `RecordClientDecision(refusé)` | IA | motif | idem |
| propose, presente | retire | `WithdrawPositioning` | IA, RH, Staffing | motif dans {désistement, no_go_interne, autre} | `PositioningWithdrawn` *(D-4)* |

⭐ **R1, direction d'Avaliance, 24/09 : « valider n'est pas gagner ».** Chez Boond, `Validé` = le
dossier technique est posé, on attend la validation financière. ⇒ un code comme `valide` se range
dans la catégorie **`presente`** (active), **jamais** en `terminal_positif`. Seul un code de
`terminal_positif` (`retenu`, le `Gagné` de Boond) ouvre le projet. Reprise : les 80 « Validé » restent
ouverts, les 198 « Gagné » deviennent `retenu`.

Terminaux : `retenu`, `refuse_client`, `retire`. **Aucune** transition sortant de `retenu` : la suite est `CreateProjectFromNeed` (garde G1) puis `CreatePrestation` (F2), qui **ne modifient pas** le positionnement. Entretiens et qualifications sont des **événements / objets**, pas des états (CdC IV.E). « Gagné » n'existe pas (DEC-13).

`propose → terminal_positif` direct : selon `positionnement.cv_partage_obligatoire` — **oui** (défaut : la décision client se prend sur un CV présenté, BM-23 ; `presente` obligatoire avant `RecordClientDecision`) · non (saut direct autorisé). *Tranché C-1, 17/09 soir : le registre faisait foi, cette ligne disait « non » par erreur.* `positionnement.qualification_requise_avant_decision` (défaut non) peut exiger une qualification avant `RecordClientDecision`.

## 5. Prestation — 4 catégories `[G11]` · codes système : previsionnelle (previsionnel) · signee (engage) · cloturee (clos) · annulee (annule)

```
previsionnelle ──(SignPrestation)──▶ signee ──(ClosePrestation)──▶ cloturee
      │                                 │
      └──── CancelPrestation ───────────┴──▶ annulee
```

| De | Vers | Commande | Acteur | Garde | Événement |
|---|---|---|---|---|---|
| — | previsionnelle **ou** signee | `CreatePrestation` | Staffing, DP — **en `signee` : permission `SignPrestation` requise** (O-2) | projet existant ; ressource existante ; `debut ≤ fin` ; conditions obligatoires US5 ; selon `prestation.surcharge.mode` : **alerte** (défaut, DEC-10) · refus · silencieux, seuil `prestation.surcharge.seuil_pct` (100), sur l'occupation `engage` d'un jour commun (ATL-02) | `PrestationCreated` ; **si l'état initial est `engage` : + tous les effets de `SignPrestation`** (`PrestationSigned`, `ClientStatusDerived`, pourvu auto) — O-2, G8 : le résultat ne dépend pas de la commande d'entrée |
| previsionnel | engage | `SignPrestation` | DP | `tjm_vendu`, `jours_vendus`, `taux_occupation` renseignés | `PrestationSigned` ; **+ `ClientStatusDerived`** selon `societe.passage_client.declencheur` (défaut : première `engage` de la société) `[G8]` ; **+ `NeedFilled` (`auto: true`) → pourvu** *(D-4)* si `besoin.pourvu.mode` est automatique |
| signee | cloturee | `ClosePrestation` | DP | date de clôture ≤ `fin` ou = `fin` ; écrit **`snapshot_marge`** (ATL-15) dans la même transaction | `PrestationClosed` |
| previsionnel, engage | annule | `CancelPrestation` | DP, Staffing *(V-064 : la MATRICE et la base font foi)* | selon `prestation.annulation.garde` : **aucun temps saisi** (défaut) · libre | `PrestationCancelled` |

Terminaux : `cloturee`, `annulee`. Temps saisissable : catégorie `engage` uniquement, période selon `temps.periode` (défaut : `[debut, fin]`) `[G9]`. Après `clos` : `AdjustTimesheetAfterClose` selon `temps.correction_apres_cloture` (défaut : ajustement tracé, `temps.ajustement = true`) ; le snapshot **ne bouge pas** — mur M-6 (F34, DEC-09). Remplacement de ressource = `ClosePrestation` + `CreatePrestation` (DEC-11, ATL-18). ATL-02 compte `previsionnelle` **et** `signee` dans l'occupation, distinguées ; ATL-07 : `previsionnelle` seule dans le CA prévisionnel.

## 6. Projet — 2 catégories `[G12]` · codes système : ouvert · clos

```
ouvert ──(CloseProject)──▶ clos
```

| De | Vers | Commande | Acteur | Garde | Événement |
|---|---|---|---|---|---|
| — | ouvert | `CreateProject` (US5) ou `CreateProjectFromNeed` — ou effet de `RecordClientDecision(retenu)` si `projet.creation_depuis_besoin = automatique_au_retenu` | Staffing, DP *(D-5 : la MATRICE fait foi — les deux ✓, aucune délégation)* | contact selon `projet.contact` (défaut obligatoire, F4). **Depuis besoin** : besoin non `ferme` ; garde `projet.depuis_besoin.garde` (défaut : retenu requis, F1) lue selon `projet.depuis_besoin.garde_profil` (défaut : positionnement `terminal_positif` dont la **personne** a un profil Ressource actif) `[G1]` ; `besoin.projets_max` | `ProjectCreated` |
| ouvert | clos | `CloseProject` | DP | selon `projet.cloture.garde` : **toutes les prestations `clos` ou `annule`** (défaut, F7) · cascade (clôture les `engage` restantes avec snapshot, même transaction) ; un projet sans prestation se clôt | `ProjectClosed` |

Terminal : `clos`. Archivage possible depuis `clos` seulement. `ReopenProject` : hors V1 — rouvrir un projet clos rouvrirait des snapshots ; si le besoin revient, c'est un nouveau projet sur le même besoin (DEC-05).

## 7. Société — statut commercial, pas un cycle strict (BM-15/16, F23–F24)

`prospect → client` : déclencheur `societe.passage_client.declencheur` (défaut : première prestation `engage`, G8) ; portée `societe.passage_client.propagation` (défaut : branche contractante + contacts du service). `client → prospect` : `societe.retour_prospect` (défaut : **manuel**, `RequalifyCompany` par CRM habilité, motif écrit, F23–F24 ; options : fin du dernier contrat · après `societe.retour_prospect.delai_mois`). Le « 6 mois » du CdC est devenu une option, pas une règle. Rôles (`fournisseur`, `interne`) : un ensemble, pas un état — `client` et `prospect` **ne sont pas des rôles**, c'est le statut de ce cycle (D-3).

## 7 bis. Les cycles ajoutés le 24/09 — tout en V1

⭐ Même règle que les six premiers : **des catégories fixes, des codes administrables**. Les codes semés
sont ceux de Boond (`cartographie/BOOND_REGLAGES_2026-09-23.md`) ; l'admin en ajoute dans une catégorie.

| Objet | Catégories (fixes) | Codes semés (Boond) | Transitions et commandes | Mur |
|---|---|---|---|---|
| **Devis** | `en_cours` · `accepte` · `refuse` · `archive` | creation, transmis_client, attente → en_cours · accord_client → accepte · refuse → refuse · archive → archive | `CreateQuote` → en_cours ; `ChangeQuoteState` entre catégories ; un devis `accepte` ou `refuse` ne revient pas en `en_cours` | — |
| **Facture** | `brouillon` · `emise` · `payee` · `litige` | proforma, creation → brouillon · transmis_client, relance_1, relance_2, email_client → emise · impayee → litige · payee → payee | `CreateInvoiceDraft` → brouillon ; `IssueInvoice` → emise (numéro attribué) ; `RecordInvoiceReminder` reste en emise ; `RecordInvoicePayment` → payee ; ⛔ **une facture émise n'est jamais modifiée : `IssueCreditNote` crée un avoir** | **M-16**, **M-18** |
| **Facture fournisseur** | `brouillon` · `valide` · `paye` · `rejete` | brouillon, a_valider → brouillon · validee → valide · payee → paye · rejetee → rejete | `RecordSupplierInvoice` → brouillon ; `ChangeSupplierInvoiceState` | — |
| **Contrat RH** | `actif` · `termine` | (pas de code : la catégorie se déduit des dates) | `CreateHrContract` → actif ; `RenewHrContract` → le contrat courant `termine`, un nouveau `actif` lié par `renouvelle_id` ; `EndHrContract` → termine, avec motif | **M-17** |
| **Achat** | `planifie` · `valide` | planifie, valide | `CreatePurchase` → planifie ; `ValidatePurchase` → valide | — |
| **Paiement** | `planifie` · `confirme` · `regle` | planifie, confirme, regle | `RecordPayment` → planifie ; `ChangePaymentState` en avant seulement | — |

⭐ **La blacklist n'est pas un cycle** (R7) : c'est un drapeau posé et retiré (`SetBlacklistFlag`,
`ClearBlacklistFlag`), avec son historique. L'étape du candidat ne change pas.

## 8. Correction à reporter dans le cadrage

S1 étape 3 : « N1 passe en staffing sur le retour client retenu » → **faux sous G3** : N1 passe en `staffing` à l'étape 2 (positionnement de Jean). L'étape 3 fait passer X1 à `retenu`. Le résultat final de S1 ne change pas. Corrigé dans `CADRAGE_METIER_RECONCILIE` le 17/09. **Le hub reste à aligner** (régénération + publication = déploiement, attend le mot).

## 9. Ce que ces machines garantissent, en une ligne chacune

| Machine | La propriété qui ne peut plus casser |
|---|---|
| Besoin | sous les défauts : on ne positionne jamais sur un besoin qui ne cherche plus (F5) ; « pourvu » n'est jamais déclaré sans engagement signé (F3). Une autre société règle autrement — et l'événement dit sous quelle règle. |
| Candidat | la conversion ne laisse pas un troisième statut ambigu (F19). |
| Ressource | aucun état inventé par un calcul (F26). |
| Positionnement | la garde F1 lit **une** catégorie ; un `terminal_positif` ne redevient jamais `propose`. |
| Prestation | un snapshot existe pour toute prestation clôturée, et rien ne l'écrase (DEC-09). |
| Projet | un projet clos n'a plus de mission ouverte (F7). |
