# CONTRAT — lot 2 · intégrateur / greffe

Mesure : **2026-09-20** · branche `lot-2` · HEAD `2df9bd6` · working tree **sale** (serveur / écran / audit non commités).

<quand_utiliser>

| ✅ On ouvre | ⛔ On n'ouvre pas |
|---|---|
| Savoir si une commande L4 a un schéma et une implémentation | Pour coder la commande — c'est le serveur |
| Trancher « conforme / écart » avant un écran | Pour inventer un vert |

</quand_utiliser>

<etat>

Mesure : **2026-09-20 soir** · `lot-2` · moteur **local** PG16.

| | Mesuré |
|---|---|
| Verdict 55 L4 | **55 portes B ✅** (P-006–P-060) |
| Contrat vivant | `test/contrat` + `assert-fige` · `/server/contrat/*.json` encore ⬜ |
| Route | `POST /commandes/:nom` · `x-ava-groupe` |
| P-061 geste besoin | **⏳ lot 3** (strict mode heading) — pas une commande L4 |
| Lectures hors L4 | `ListerBesoins` · `LireBesoin` (Q-011) |
| Cliquet | 10 cases · parade ⏳ |

Les tableaux par commande plus bas sont la mesure du matin (écarts, HEAD `2df9bd6`). ⛔ Ils ne se réécrivent pas : le journal des portes fait foi.

</etat>

<procedure>

1. Pour chaque commande : chercher `/server/contrat/<Commande>.json`.
2. Si absent → **écart**. Si présent → coller aux colonnes L4 (entrée, sortie, refus, événement).
3. Ne jamais marquer conforme sur une intention.

</procedure>

---

## I · CRM — 11

| Commande | L4 | Verdict | Preuve |
|---|---|---|---|
| `CreateCompany` | 79 | **écart** | pas de JSON · `crm.ts` WT non routé |
| `UpdateCompany` | 80 | **écart** | idem |
| `RequalifyCompany` | 81 | **écart** | idem |
| `ArchiveCompany` | 82 | **écart** | idem |
| `CreateUnit` | 83 | **écart** | idem |
| `UpdateUnit` | 84 | **écart** | idem |
| `ArchiveService` | 85 | **écart** | idem |
| `CreateContact` | 86 | **écart** | idem |
| `UpdateContact` | 87 | **écart** | idem |
| `TransferContact` | 88 | **écart** | idem |
| `ArchiveContact` | 89 | **écart** | idem |

## II · Identité, recrutement — 13

| Commande | L4 | Verdict | Preuve |
|---|---|---|---|
| `CreatePerson` | 100 | **écart** | pas de schéma · pas de handler |
| `CreateCandidate` | 101 | **écart** | idem |
| `UpdateCandidate` | 102 | **écart** | idem |
| `CompleteCandidate` | 103 | **écart** | idem |
| `ExitCandidate` | 104 | **écart** | idem |
| `ReactivateCandidate` | 105 | **écart** | idem |
| `ConvertCandidateToResource` | 106 | **écart** | bloc §C-1 L193 non codé |
| `CreateResource` | 107 | **écart** | idem |
| `UpdateResource` | 108 | **écart** | idem |
| `SetResourceState` | 109 | **écart** | idem |
| `UpdateResourceCost` | 110 | **écart** | idem |
| `UploadDocument` | 111 | **écart** | idem |
| `RecordQualification` | 112 | **écart** | idem |

## III · Besoin, positionnement — 14

| Commande | L4 | Verdict | Preuve |
|---|---|---|---|
| `CreateNeed` | 126 | **écart** | pas de schéma · pas de handler |
| `UpdateNeed` | 127 | **écart** | idem |
| `SetNeedPriority` | 128 | **écart** | idem |
| `TakeNeedInCharge` | 129 | **écart** | idem |
| `DeclareNeedFilled` | 130 | **écart** | bloc §C-2 L213 non codé |
| `SuspendNeed` | 131 | **écart** | idem |
| `ResumeNeed` | 132 | **écart** | idem |
| `CloseNeed` | 133 | **écart** | idem |
| `ReopenNeed` | 134 | **écart** | idem |
| `PositionCandidate` | 135 | **écart** | idem |
| `PositionResource` | 136 | **écart** | idem |
| `DeclareCVShared` | 137 | **écart** | idem |
| `RecordClientDecision` | 138 | **écart** | idem |
| `WithdrawPositioning` | 139 | **écart** | idem |

## IV · Projet, production — 11

| Commande | L4 | Verdict | Preuve |
|---|---|---|---|
| `CreateProject` | 153 | **écart** | pas de schéma · pas de handler |
| `CreateProjectFromNeed` | 154 | **écart** | idem |
| `UpdateProject` | 155 | **écart** | idem |
| `CloseProject` | 156 | **écart** | idem |
| `CreatePrestation` | 157 | **écart** | bloc §C-3 L232 non codé |
| `SignPrestation` | 158 | **écart** | bloc §C-3 L232 non codé |
| `ClosePrestation` | 159 | **écart** | idem |
| `CancelPrestation` | 160 | **écart** | idem |
| `RecordTimesheet` | 161 | **écart** | bloc §C-4 L251 non codé |
| `AdjustTimesheetAfterClose` | 162 | **écart** | idem |
| `RecordAbsence` | 163 | **écart** | idem |

## V · Transverse, admin — 6

| Commande | L4 | Verdict | Preuve |
|---|---|---|---|
| `CreateAction` | 175 | **écart** | pas de schéma · pas de handler |
| `ArchiveObject` | 176 | **écart** | idem |
| `SetPolicy` | 177 | **écart** | bloc §C-5 L267 non codé |
| `ManageRefs` | 178 | **écart** | idem |
| `ManageGroups` | 179 | **écart** | idem |
| `SetOwnTheme` | 180 | **écart** | idem |

## Lectures écran — hors des 55

| Nom appelé par `/web` | L4 | Verdict | Preuve |
|---|---|---|---|
| `ListerBesoins` | — | **écart** (hors contrat) | `web/src/ListeBesoins.tsx` · pas de JSON · pas dans L4 |
| `LireBesoin` | — | **écart** (hors contrat) | `web/src/FicheBesoin.tsx` · pas de JSON · pas dans L4 |

Q-011 : ne pas inventer une 56e et 57e commande. D-016.

---

<interdits>

| ⛔ | Pourquoi |
|---|---|
| Marquer conforme sans fichier | un vert inventé |
| Corriger L4 depuis ici | le canon ne se patche pas |
| Confondre P-002 `/sante` avec une porte B de commande | ce n'est pas une des 55 |

</interdits>

<source>

L4 `_ops/SPEC_COMMANDES_L4.md`. HEAD `2df9bd6`. WT lue : `server/src/{index,kernel,droits,vues}.ts`, `web/src/{App,ListeBesoins,FicheBesoin,contrat}.ts(x)`. Audit : `audit/L2.md` et fiches, **citées pas réécrites**.

</source>
