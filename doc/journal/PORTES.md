# Portes — le cliquet. Une porte ✅ ne redevient jamais ⏳.

Tolérance écrans (espèce D) : `maxDiffPixelRatio = 0,01` (1 % des pixels).  
Navigateur épinglé : Playwright **1.55.0**, Chromium bundlé (build v1187 / Chromium 140.0.7339.16).  
Polices : JetBrains Mono embarquée (`web/src/fonts/JetBrainsMono-Regular.woff2`), jamais le réseau.  
Animations : coupées (`animations: disabled`, `reducedMotion: reduce`).

Colonnes **État** et **Lot cible** : parade ⏳ (`_ops/PORTES_EN_ATTENTE.md`), 20/09/2026.

| Porte | Espèce | Phrase | Test | Vue rouge | État | Lot cible | Tolérance |
|---|---|---|---|---|---|---|---|
| P-001 | A BASE | Les 15 murs tiennent dans la base : 22 assertions + 1 contre-test. | `test/SPEC_ASSERTIONS_L7.sql` | 2026-09-19 | ✅ | 1 | — |
| P-002 | B CONTRAT | GET /sante renvoie le JSON figé (titre, état, actions, thème). | `test/contrat/sante.test.ts` | 2026-09-19 | ✅ | 1 | égalité stricte |
| P-003 | C GESTE | Ouvrir le tuyau, cliquer Acquitter, lire le libellé serveur « Acquitté ». | `test/geste/tuyau.spec.ts` | 2026-09-19 | ✅ | 1 | — |
| P-004 | D ÉCRAN | Capture du tuyau, thème sombre, comparée au golden. | `test/ecran/tuyau.spec.ts` sombre | 2026-09-19 | ✅ | 1 | 1 % pixels |
| P-005 | D ÉCRAN | Capture du tuyau, thème clair, comparée au golden. | `test/ecran/tuyau.spec.ts` clair | 2026-09-19 | ✅ | 1 | 1 % pixels |
| P-006 | B CONTRAT | CreateCompany rend la société créée. | `test/contrat/commandes.test.ts` | 2026-09-20 | ✅ | 2 | égalité stricte |
| P-007 | B CONTRAT | UpdateCompany réussit, base relue. | `test/contrat/commandes.test.ts` | 2026-09-20 | ✅ | 2 | — |
| P-008 | B CONTRAT | RequalifyCompany réussit, base relue. | `test/contrat/commandes.test.ts` | 2026-09-20 | ✅ | 2 | — |
| P-009 | B CONTRAT | ArchiveCompany refuse DROIT. | `test/contrat/commandes.test.ts` | 2026-09-20 | ✅ | 2 | — |
| P-010 | B CONTRAT | CreateUnit réussit, base relue. | `test/contrat/commandes.test.ts` | 2026-09-20 | ✅ | 2 | — |
| P-011 | B CONTRAT | UpdateUnit réussit, base relue. | `test/contrat/commandes.test.ts` | 2026-09-20 | ✅ | 2 | — |
| P-012 | B CONTRAT | ArchiveService refuse DROIT. | `test/contrat/commandes.test.ts` | 2026-09-20 | ✅ | 2 | — |
| P-013 | B CONTRAT | CreateContact réussit, base relue. | `test/contrat/commandes.test.ts` | 2026-09-20 | ✅ | 2 | — |
| P-014 | B CONTRAT | UpdateContact réussit, base relue. | `test/contrat/commandes.test.ts` | 2026-09-20 | ✅ | 2 | — |
| P-015 | B CONTRAT | TransferContact réussit, base relue. | `test/contrat/commandes.test.ts` | 2026-09-20 | ✅ | 2 | — |
| P-016 | B CONTRAT | ArchiveContact refuse DROIT. | `test/contrat/commandes.test.ts` | 2026-09-20 | ✅ | 2 | — |
| P-017 | B CONTRAT | CreatePerson rend la personne créée. | `test/contrat/commandes.test.ts` | 2026-09-20 | ✅ | 2 | égalité stricte |
| P-018 | B CONTRAT | CreateCandidate réussit, base relue. | `test/contrat/commandes.test.ts` | 2026-09-20 | ✅ | 2 | — |
| P-019 | B CONTRAT | UpdateCandidate réussit, base relue. | `test/contrat/commandes.test.ts` | 2026-09-20 | ✅ | 2 | — |
| P-020 | B CONTRAT | CompleteCandidate réussit, base relue. | `test/contrat/commandes.test.ts` | 2026-09-20 | ✅ | 2 | — |
| P-021 | B CONTRAT | ExitCandidate réussit, base relue. | `test/contrat/commandes.test.ts` | 2026-09-20 | ✅ | 2 | — |
| P-022 | B CONTRAT | ReactivateCandidate réussit, base relue. | `test/contrat/commandes.test.ts` | 2026-09-20 | ✅ | 2 | — |
| P-023 | B CONTRAT | ConvertCandidateToResource réussit, base relue. | `test/contrat/commandes.test.ts` | 2026-09-20 | ✅ | 2 | — |
| P-024 | B CONTRAT | CreateResource réussit, base relue. | `test/contrat/commandes.test.ts` | 2026-09-20 | ✅ | 2 | — |
| P-025 | B CONTRAT | UpdateResource réussit, base relue. | `test/contrat/commandes.test.ts` | 2026-09-20 | ✅ | 2 | — |
| P-026 | B CONTRAT | SetResourceState réussit, base relue. | `test/contrat/commandes.test.ts` | 2026-09-20 | ✅ | 2 | — |
| P-027 | B CONTRAT | UpdateResourceCost refuse DROIT. | `test/contrat/commandes.test.ts` | 2026-09-20 | ✅ | 2 | — |
| P-028 | B CONTRAT | UploadDocument refuse GARDE. | `test/contrat/commandes.test.ts` | 2026-09-20 | ✅ | 2 | — |
| P-029 | B CONTRAT | RecordQualification réussit, base relue. | `test/contrat/commandes.test.ts` | 2026-09-20 | ✅ | 2 | — |
| P-030 | B CONTRAT | CreateNeed réussit, base relue. | `test/contrat/commandes.test.ts` | 2026-09-20 | ✅ | 2 | — |
| P-031 | B CONTRAT | UpdateNeed réussit, base relue. | `test/contrat/commandes.test.ts` | 2026-09-20 | ✅ | 2 | — |
| P-032 | B CONTRAT | SetNeedPriority réussit, base relue. | `test/contrat/commandes.test.ts` | 2026-09-20 | ✅ | 2 | — |
| P-033 | B CONTRAT | TakeNeedInCharge réussit, base relue. | `test/contrat/commandes.test.ts` | 2026-09-20 | ✅ | 2 | — |
| P-034 | B CONTRAT | DeclareNeedFilled réussit, base relue. | `test/contrat/commandes.test.ts` | 2026-09-20 | ✅ | 2 | — |
| P-035 | B CONTRAT | SuspendNeed réussit, base relue. | `test/contrat/commandes.test.ts` | 2026-09-20 | ✅ | 2 | — |
| P-036 | B CONTRAT | ResumeNeed réussit, base relue. | `test/contrat/commandes.test.ts` | 2026-09-20 | ✅ | 2 | — |
| P-037 | B CONTRAT | CloseNeed réussit, base relue. | `test/contrat/commandes.test.ts` | 2026-09-20 | ✅ | 2 | — |
| P-038 | B CONTRAT | ReopenNeed réussit, base relue. | `test/contrat/commandes.test.ts` | 2026-09-20 | ✅ | 2 | — |
| P-039 | B CONTRAT | PositionCandidate réussit, base relue. | `test/contrat/commandes.test.ts` | 2026-09-20 | ✅ | 2 | — |
| P-040 | B CONTRAT | PositionResource réussit, base relue. | `test/contrat/commandes.test.ts` | 2026-09-20 | ✅ | 2 | — |
| P-041 | B CONTRAT | DeclareCVShared réussit, base relue. | `test/contrat/commandes.test.ts` | 2026-09-20 | ✅ | 2 | — |
| P-042 | B CONTRAT | RecordClientDecision refuse DROIT. | `test/contrat/commandes.test.ts` | 2026-09-20 | ✅ | 2 | — |
| P-043 | B CONTRAT | WithdrawPositioning réussit, base relue. | `test/contrat/commandes.test.ts` | 2026-09-20 | ✅ | 2 | — |
| P-044 | B CONTRAT | CreateProject réussit, base relue. | `test/contrat/commandes.test.ts` | 2026-09-20 | ✅ | 2 | — |
| P-045 | B CONTRAT | CreateProjectFromNeed réussit, base relue. | `test/contrat/commandes.test.ts` | 2026-09-20 | ✅ | 2 | — |
| P-046 | B CONTRAT | UpdateProject réussit, base relue. | `test/contrat/commandes.test.ts` | 2026-09-20 | ✅ | 2 | — |
| P-047 | B CONTRAT | CloseProject réussit, base relue. | `test/contrat/commandes.test.ts` | 2026-09-20 | ✅ | 2 | — |
| P-048 | B CONTRAT | CreatePrestation réussit, base relue. | `test/contrat/commandes.test.ts` | 2026-09-20 | ✅ | 2 | — |
| P-049 | B CONTRAT | SignPrestation refuse DROIT. | `test/contrat/commandes.test.ts` | 2026-09-20 | ✅ | 2 | — |
| P-050 | B CONTRAT | ClosePrestation réussit, base relue. | `test/contrat/commandes.test.ts` | 2026-09-20 | ✅ | 2 | — |
| P-051 | B CONTRAT | CancelPrestation réussit, base relue. | `test/contrat/commandes.test.ts` | 2026-09-20 | ✅ | 2 | — |
| P-052 | B CONTRAT | RecordTimesheet réussit, base relue. | `test/contrat/commandes.test.ts` | 2026-09-20 | ✅ | 2 | — |
| P-053 | B CONTRAT | AdjustTimesheetAfterClose réussit, base relue. | `test/contrat/commandes.test.ts` | 2026-09-20 | ✅ | 2 | — |
| P-054 | B CONTRAT | RecordAbsence réussit, base relue. | `test/contrat/commandes.test.ts` | 2026-09-20 | ✅ | 2 | — |
| P-055 | B CONTRAT | CreateAction refuse GARDE. | `test/contrat/commandes.test.ts` | 2026-09-20 | ✅ | 2 | — |
| P-056 | B CONTRAT | ArchiveObject refuse DROIT. | `test/contrat/commandes.test.ts` | 2026-09-20 | ✅ | 2 | — |
| P-057 | B CONTRAT | SetPolicy refuse DROIT. | `test/contrat/commandes.test.ts` | 2026-09-20 | ✅ | 2 | — |
| P-058 | B CONTRAT | ManageRefs refuse DROIT. | `test/contrat/commandes.test.ts` | 2026-09-20 | ✅ | 2 | — |
| P-059 | B CONTRAT | ManageGroups refuse DROIT. | `test/contrat/commandes.test.ts` | 2026-09-20 | ✅ | 2 | — |
| P-060 | B CONTRAT | SetOwnTheme rend le thème enregistré. | `test/contrat/commandes.test.ts` | 2026-09-20 | ✅ | 2 | égalité stricte |
| P-061 | C GESTE | Liste besoin → fiche → Prendre en charge. | `test/geste/besoin.spec.ts` | 2026-09-20 | ⏳ | 3 | — |
| P-062 | D ÉCRAN | Capture liste besoins, thème sombre. | `test/ecran/besoin.spec.ts` liste sombre | 2026-09-20 | ⏳ | 3 | 1 % pixels |
| P-063 | D ÉCRAN | Capture liste besoins, thème clair. | `test/ecran/besoin.spec.ts` liste clair | 2026-09-20 | ⏳ | 3 | 1 % pixels |
| P-064 | D ÉCRAN | Capture fiche besoin, thème sombre. | `test/ecran/besoin.spec.ts` fiche sombre | 2026-09-20 | ⏳ | 3 | 1 % pixels |
| P-065 | D ÉCRAN | Capture fiche besoin, thème clair. | `test/ecran/besoin.spec.ts` fiche clair | 2026-09-20 | ⏳ | 3 | 1 % pixels |
| P-066 | B CONTRAT | Hors banc, sans AVA_MODE, x-ava-session = UUID ADM : ManageRefs et SetPolicy → 401, rien d'écrit, refus tracé. | `test/contrat/correctifs.test.ts` | 2026-09-22 | ✅ | 2 | base relue |
| P-067 | B CONTRAT | IA de PAR sur un besoin de CAS → DROIT, rien d'écrit. | `test/contrat/correctifs.test.ts` | 2026-09-21 | ✅ | 2 | — |
| P-068 | B CONTRAT | L'événement rendu est celui de la transaction. | `test/contrat/correctifs.test.ts` | 2026-09-21 | ✅ | 2 | — |
| P-069 | B CONTRAT | Un temps saisi DANS les dates est écrit. | `test/contrat/correctifs.test.ts` | 2026-09-21 | ✅ | 2 | — |
| P-070 | B CONTRAT | SetPolicy : politique relue, PolicyChanged de la transaction. | `test/contrat/correctifs.test.ts` | 2026-09-21 | ✅ | 2 | — |
| P-071 | B CONTRAT | CreateCompany chemin nominal, base relue. | `test/contrat/chemin.test.ts` | 2026-09-21 | ✅ | 2 | — |
| P-072 | B CONTRAT | UpdateCompany chemin nominal, base relue. | `test/contrat/chemin.test.ts` | 2026-09-21 | ✅ | 2 | — |
| P-073 | B CONTRAT | RequalifyCompany chemin nominal, base relue. | `test/contrat/chemin.test.ts` | 2026-09-21 | ✅ | 2 | — |
| P-074 | B CONTRAT | ArchiveCompany chemin nominal, base relue. | `test/contrat/chemin.test.ts` | 2026-09-21 | ✅ | 2 | — |
| P-075 | B CONTRAT | CreateUnit chemin nominal, base relue. | `test/contrat/chemin.test.ts` | 2026-09-21 | ✅ | 2 | — |
| P-076 | B CONTRAT | UpdateUnit chemin nominal, base relue. | `test/contrat/chemin.test.ts` | 2026-09-21 | ✅ | 2 | — |
| P-077 | B CONTRAT | ArchiveService chemin nominal, base relue. | `test/contrat/chemin.test.ts` | 2026-09-21 | ✅ | 2 | — |
| P-078 | B CONTRAT | CreateContact chemin nominal, base relue. | `test/contrat/chemin.test.ts` | 2026-09-21 | ✅ | 2 | — |
| P-079 | B CONTRAT | UpdateContact chemin nominal, base relue. | `test/contrat/chemin.test.ts` | 2026-09-21 | ✅ | 2 | — |
| P-080 | B CONTRAT | TransferContact chemin nominal, base relue. | `test/contrat/chemin.test.ts` | 2026-09-21 | ✅ | 2 | — |
| P-081 | B CONTRAT | ArchiveContact chemin nominal, base relue. | `test/contrat/chemin.test.ts` | 2026-09-21 | ✅ | 2 | — |
| P-082 | B CONTRAT | CreatePerson chemin nominal, base relue. | `test/contrat/chemin.test.ts` | 2026-09-21 | ✅ | 2 | — |
| P-083 | B CONTRAT | CreateCandidate chemin nominal, base relue. | `test/contrat/chemin.test.ts` | 2026-09-21 | ✅ | 2 | — |
| P-084 | B CONTRAT | UpdateCandidate chemin nominal, base relue. | `test/contrat/chemin.test.ts` | 2026-09-21 | ✅ | 2 | — |
| P-085 | B CONTRAT | CompleteCandidate chemin nominal, base relue. | `test/contrat/chemin.test.ts` | 2026-09-21 | ✅ | 2 | — |
| P-086 | B CONTRAT | ExitCandidate chemin nominal, base relue. | `test/contrat/chemin.test.ts` | 2026-09-21 | ✅ | 2 | — |
| P-087 | B CONTRAT | ReactivateCandidate chemin nominal, base relue. | `test/contrat/chemin.test.ts` | 2026-09-21 | ✅ | 2 | — |
| P-088 | B CONTRAT | ConvertCandidateToResource chemin nominal, base relue. | `test/contrat/chemin.test.ts` | 2026-09-21 | ✅ | 2 | — |
| P-089 | B CONTRAT | CreateResource chemin nominal, base relue. | `test/contrat/chemin.test.ts` | 2026-09-21 | ✅ | 2 | — |
| P-090 | B CONTRAT | UpdateResource chemin nominal, base relue. | `test/contrat/chemin.test.ts` | 2026-09-21 | ✅ | 2 | — |
| P-091 | B CONTRAT | SetResourceState chemin nominal, base relue. | `test/contrat/chemin.test.ts` | 2026-09-21 | ✅ | 2 | — |
| P-092 | B CONTRAT | UpdateResourceCost chemin nominal, base relue. | `test/contrat/chemin.test.ts` | 2026-09-21 | ✅ | 2 | — |
| P-093 | B CONTRAT | UploadDocument chemin nominal, base relue. | `test/contrat/chemin.test.ts` | 2026-09-21 | ✅ | 2 | — |
| P-094 | B CONTRAT | RecordQualification chemin nominal, base relue. | `test/contrat/chemin.test.ts` | 2026-09-21 | ✅ | 2 | — |
| P-095 | B CONTRAT | CreateNeed chemin nominal, base relue. | `test/contrat/chemin.test.ts` | 2026-09-21 | ✅ | 2 | — |
| P-096 | B CONTRAT | UpdateNeed chemin nominal, base relue. | `test/contrat/chemin.test.ts` | 2026-09-21 | ✅ | 2 | — |
| P-097 | B CONTRAT | SetNeedPriority chemin nominal, base relue. | `test/contrat/chemin.test.ts` | 2026-09-21 | ✅ | 2 | — |
| P-098 | B CONTRAT | TakeNeedInCharge chemin nominal, base relue. | `test/contrat/chemin.test.ts` | 2026-09-21 | ✅ | 2 | — |
| P-099 | B CONTRAT | DeclareNeedFilled chemin nominal, base relue. | `test/contrat/chemin.test.ts` | 2026-09-21 | ✅ | 2 | — |
| P-100 | B CONTRAT | SuspendNeed chemin nominal, base relue. | `test/contrat/chemin.test.ts` | 2026-09-21 | ✅ | 2 | — |
| P-101 | B CONTRAT | ResumeNeed chemin nominal, base relue. | `test/contrat/chemin.test.ts` | 2026-09-21 | ✅ | 2 | — |
| P-102 | B CONTRAT | CloseNeed chemin nominal, base relue. | `test/contrat/chemin.test.ts` | 2026-09-21 | ✅ | 2 | — |
| P-103 | B CONTRAT | ReopenNeed chemin nominal, base relue. | `test/contrat/chemin.test.ts` | 2026-09-21 | ✅ | 2 | — |
| P-104 | B CONTRAT | PositionCandidate chemin nominal, base relue. | `test/contrat/chemin.test.ts` | 2026-09-21 | ✅ | 2 | — |
| P-105 | B CONTRAT | PositionResource chemin nominal, base relue. | `test/contrat/chemin.test.ts` | 2026-09-21 | ✅ | 2 | — |
| P-106 | B CONTRAT | DeclareCVShared chemin nominal, base relue. | `test/contrat/chemin.test.ts` | 2026-09-21 | ✅ | 2 | — |
| P-107 | B CONTRAT | RecordClientDecision chemin nominal, base relue. | `test/contrat/chemin.test.ts` | 2026-09-21 | ✅ | 2 | — |
| P-108 | B CONTRAT | WithdrawPositioning chemin nominal, base relue. | `test/contrat/chemin.test.ts` | 2026-09-21 | ✅ | 2 | — |
| P-109 | B CONTRAT | CreateProject chemin nominal, base relue. | `test/contrat/chemin.test.ts` | 2026-09-21 | ✅ | 2 | — |
| P-110 | B CONTRAT | CreateProjectFromNeed chemin nominal, base relue. | `test/contrat/chemin.test.ts` | 2026-09-21 | ✅ | 2 | — |
| P-111 | B CONTRAT | UpdateProject chemin nominal, base relue. | `test/contrat/chemin.test.ts` | 2026-09-21 | ✅ | 2 | — |
| P-112 | B CONTRAT | CloseProject chemin nominal, base relue. | `test/contrat/chemin.test.ts` | 2026-09-21 | ✅ | 2 | — |
| P-113 | B CONTRAT | CreatePrestation chemin nominal, base relue. | `test/contrat/chemin.test.ts` | 2026-09-21 | ✅ | 2 | — |
| P-114 | B CONTRAT | SignPrestation chemin nominal, base relue. | `test/contrat/chemin.test.ts` | 2026-09-21 | ✅ | 2 | — |
| P-115 | B CONTRAT | ClosePrestation chemin nominal, base relue. | `test/contrat/chemin.test.ts` | 2026-09-21 | ✅ | 2 | — |
| P-116 | B CONTRAT | CancelPrestation chemin nominal, base relue. | `test/contrat/chemin.test.ts` | 2026-09-21 | ✅ | 2 | — |
| P-117 | B CONTRAT | RecordTimesheet chemin nominal, base relue. | `test/contrat/chemin.test.ts` | 2026-09-21 | ✅ | 2 | — |
| P-118 | B CONTRAT | AdjustTimesheetAfterClose chemin nominal, base relue. | `test/contrat/chemin.test.ts` | 2026-09-21 | ✅ | 2 | — |
| P-119 | B CONTRAT | RecordAbsence chemin nominal, base relue. | `test/contrat/chemin.test.ts` | 2026-09-21 | ✅ | 2 | — |
| P-120 | B CONTRAT | CreateAction chemin nominal, base relue. | `test/contrat/chemin.test.ts` | 2026-09-21 | ✅ | 2 | — |
| P-121 | B CONTRAT | ArchiveObject chemin nominal, base relue. | `test/contrat/chemin.test.ts` | 2026-09-21 | ✅ | 2 | — |
| P-122 | B CONTRAT | SetPolicy chemin nominal, base relue. | `test/contrat/chemin.test.ts` | 2026-09-21 | ✅ | 2 | — |
| P-123 | B CONTRAT | ManageRefs chemin nominal, base relue. | `test/contrat/chemin.test.ts` | 2026-09-21 | ✅ | 2 | — |
| P-124 | B CONTRAT | ManageGroups chemin nominal, base relue. | `test/contrat/chemin.test.ts` | 2026-09-21 | ✅ | 2 | — |
| P-125 | B CONTRAT | SetOwnTheme chemin nominal, base relue. | `test/contrat/chemin.test.ts` | 2026-09-21 | ✅ | 2 | — |
| P-126 | B CONTRAT | O-2 CreatePrestation en signée par STAF → DROIT. | `test/contrat/chemin.test.ts` | 2026-09-21 | ✅ | 2 | — |
| P-127 | B CONTRAT | Matrice : sans le groupe → DROIT, rien d'écrit. | `test/contrat/matrice.test.ts` | 2026-09-21 | ✅ | 2 | — |
| P-128 | B CONTRAT | Matrice : IA hors périmètre CAS → DROIT. | `test/contrat/matrice.test.ts` | 2026-09-21 | ✅ | 2 | — |
| P-129 | B CONTRAT | S : soi-même permis, autrui refusé. | `test/contrat/matrice.test.ts` | 2026-09-21 | ✅ | 2 | — |
| P-130 | B CONTRAT | Politique doublon.societe.mode : deux valeurs, deux résultats. | `test/contrat/politiques.test.ts` | 2026-09-21 | ✅ | 2 | — |
| P-131 | B CONTRAT | Politique ui.theme.choix_utilisateur : deux valeurs, deux résultats. | `test/contrat/politiques.test.ts` | 2026-09-21 | ✅ | 2 | — |
| P-132 | B CONTRAT | Politique besoin.contact : deux valeurs, deux résultats. | `test/contrat/politiques.test.ts` | 2026-09-21 | ✅ | 2 | — |
| P-133 | B CONTRAT | Politique temps.plafond_jour : deux valeurs, deux résultats. | `test/contrat/politiques.test.ts` | 2026-09-21 | ✅ | 2 | — |
| P-134 | B CONTRAT | Politique candidat.note.echelle : 1_5 / 1_10 / hors échelle. | `test/contrat/politiques.test.ts` | 2026-09-21 | ✅ | 2 | — |
| P-135 | B CONTRAT | ExitCandidate sans code sorti actif → GARDE, ref inchangé. | `test/contrat/correctifs.test.ts` | 2026-09-21 | ✅ | 2 | — |
| P-136 | B CONTRAT | Démarrage en postgres superutilisateur → le serveur s'arrête. | `test/contrat/correctifs.test.ts` | 2026-09-21 | ✅ | 2 | — |
| P-137 | B CONTRAT | Pourvu auto à la signature : même garde que DeclareNeedFilled. | `test/contrat/correctifs.test.ts` | 2026-09-21 | ✅ | 2 | — |
| P-138 | B CONTRAT | Clé lue = branche ; clé non implémentée absente de liens.politiques. | `test/contrat/correctifs.test.ts` | 2026-09-21 | ✅ | 2 | — |
| P-139 | B CONTRAT | Aucun code d'état ni de groupe en littéral hors de la table. | `test/contrat/correctifs.test.ts` | 2026-09-21 | ✅ | 2 | — |
| P-140 | B CONTRAT | Un code hors ref actif est GARDE, pas un MUR. | `test/contrat/correctifs.test.ts` | 2026-09-21 | ✅ | 2 | — |
| P-141 | B CONTRAT | Le bouchon JSON n'est pas servi et n'est pas dans dist/. | `test/contrat/correctifs.test.ts` | 2026-09-21 | ✅ | 2 | — |
| P-142 | B CONTRAT | Statut contact et coordonnées sont des ref_* ; périmètre reste un CHECK. | `test/contrat/correctifs.test.ts` | 2026-09-21 | ✅ | 2 | — |
| P-143 | B CONTRAT | P-002 lit AVA_BASE_URL, sans port 3000 en dur. | `test/contrat/correctifs.test.ts` | 2026-09-21 | ✅ | 2 | — |
| P-144 | B CONTRAT | La note candidat est écrite, une valeur par échelle. | `test/contrat/correctifs.test.ts` | 2026-09-21 | ✅ | 2 | — |
| P-145 | B CONTRAT | Le catch de la trace de refus journalise l'échec. | `test/contrat/correctifs.test.ts` | 2026-09-21 | ✅ | 2 | — |
| P-146 | B CONTRAT | Un refus n'est jamais un 500 ; le détail reste au journal. | `test/contrat/correctifs.test.ts` | 2026-09-21 | ✅ | 2 | — |
| P-147 | B CONTRAT | Aucun mot de passe postgres versionné dans le dépôt. | `test/contrat/correctifs.test.ts` | 2026-09-21 | ✅ | 2 | — |
| P-148 | B CONTRAT | Le hook commit-msg exige Role et admet brain. | `test/contrat/correctifs.test.ts` | 2026-09-21 | ✅ | 2 | — |
| P-149 | B CONTRAT | La réponse porte l'id et les événements de la transaction. | `test/contrat/correctifs.test.ts` | 2026-09-21 | ✅ | 2 | — |
| P-150 | B CONTRAT | ClosePrestation refuse une date de clôture après la fin. | `test/contrat/correctifs.test.ts` | 2026-09-21 | ✅ | 2 | — |
| P-151 | B CONTRAT | La référence projet n'est pas count(*)+1. | `test/contrat/correctifs.test.ts` | 2026-09-21 | ✅ | 2 | — |
| P-152 | B CONTRAT | UpdateUnit refuse un cycle en remontant l'arbre. | `test/contrat/correctifs.test.ts` | 2026-09-21 | ✅ | 2 | — |
| P-153 | B CONTRAT | ManageRefs écrit ordre et actif ; ManageGroups n'émet que si ça change. | `test/contrat/correctifs.test.ts` | 2026-09-21 | ✅ | 2 | — |
| P-154 | B CONTRAT | ArchiveObject délègue à la garde de la société. | `test/contrat/correctifs.test.ts` | 2026-09-21 | ✅ | 2 | — |
| P-155 | B CONTRAT | Le compte RES de banc est relié à une personne ressource. | `test/contrat/correctifs.test.ts` | 2026-09-21 | ✅ | 2 | — |
| P-156 | B CONTRAT | Les captures Linux du tuyau sont versionnées pour la CI. | `test/contrat/correctifs.test.ts` | 2026-09-21 | ✅ | 2 | — |
| P-157 | B CONTRAT | CreateNeed hors périmètre CAS → DROIT, rien d'écrit. | `test/contrat/matrice.test.ts` | 2026-09-22 | ✅ | 2 | base relue |
| P-158 | B CONTRAT | UpdateNeed hors périmètre CAS → DROIT, rien d'écrit. | `test/contrat/matrice.test.ts` | 2026-09-22 | ✅ | 2 | base relue |
| P-159 | B CONTRAT | SetNeedPriority hors périmètre CAS → DROIT, rien d'écrit. | `test/contrat/matrice.test.ts` | 2026-09-22 | ✅ | 2 | base relue |
| P-160 | B CONTRAT | TakeNeedInCharge hors périmètre CAS → DROIT, rien d'écrit. | `test/contrat/matrice.test.ts` | 2026-09-22 | ✅ | 2 | base relue |
| P-161 | B CONTRAT | DeclareNeedFilled hors périmètre CAS → DROIT, rien d'écrit. | `test/contrat/matrice.test.ts` | 2026-09-22 | ✅ | 2 | base relue |
| P-162 | B CONTRAT | SuspendNeed hors périmètre CAS → DROIT, rien d'écrit. | `test/contrat/matrice.test.ts` | 2026-09-22 | ✅ | 2 | base relue |
| P-163 | B CONTRAT | ResumeNeed hors périmètre CAS → DROIT, rien d'écrit. | `test/contrat/matrice.test.ts` | 2026-09-22 | ✅ | 2 | base relue |
| P-164 | B CONTRAT | CloseNeed hors périmètre CAS → DROIT, rien d'écrit. | `test/contrat/matrice.test.ts` | 2026-09-22 | ✅ | 2 | base relue |
| P-165 | B CONTRAT | ReopenNeed hors périmètre CAS → DROIT, rien d'écrit. | `test/contrat/matrice.test.ts` | 2026-09-22 | ✅ | 2 | base relue |
| P-166 | B CONTRAT | PositionCandidate hors périmètre CAS → DROIT, rien d'écrit. | `test/contrat/matrice.test.ts` | 2026-09-22 | ✅ | 2 | base relue |
| P-167 | B CONTRAT | PositionResource hors périmètre CAS → DROIT, rien d'écrit. | `test/contrat/matrice.test.ts` | 2026-09-22 | ✅ | 2 | base relue |
| P-168 | B CONTRAT | DeclareCVShared hors périmètre CAS → DROIT, rien d'écrit. | `test/contrat/matrice.test.ts` | 2026-09-22 | ✅ | 2 | base relue |
| P-169 | B CONTRAT | RecordClientDecision hors périmètre CAS → DROIT, rien d'écrit. | `test/contrat/matrice.test.ts` | 2026-09-22 | ✅ | 2 | base relue |
| P-170 | B CONTRAT | WithdrawPositioning hors périmètre CAS → DROIT, rien d'écrit. | `test/contrat/matrice.test.ts` | 2026-09-22 | ✅ | 2 | base relue |
| P-171 | B CONTRAT | CreateProject hors périmètre CAS → DROIT, rien d'écrit. | `test/contrat/matrice.test.ts` | 2026-09-22 | ✅ | 2 | base relue |
| P-172 | B CONTRAT | CreateProjectFromNeed hors périmètre CAS → DROIT, rien d'écrit. | `test/contrat/matrice.test.ts` | 2026-09-22 | ✅ | 2 | base relue |
| P-173 | B CONTRAT | UpdateProject hors périmètre CAS → DROIT, rien d'écrit. | `test/contrat/matrice.test.ts` | 2026-09-22 | ✅ | 2 | base relue |
| P-174 | B CONTRAT | CloseProject hors périmètre CAS → DROIT, rien d'écrit. | `test/contrat/matrice.test.ts` | 2026-09-22 | ✅ | 2 | base relue |
| P-175 | B CONTRAT | CreatePrestation hors périmètre CAS → DROIT, rien d'écrit. | `test/contrat/matrice.test.ts` | 2026-09-22 | ✅ | 2 | base relue |
| P-176 | B CONTRAT | SignPrestation hors périmètre CAS → DROIT, rien d'écrit. | `test/contrat/matrice.test.ts` | 2026-09-22 | ✅ | 2 | base relue |
| P-177 | B CONTRAT | ClosePrestation hors périmètre CAS → DROIT, rien d'écrit. | `test/contrat/matrice.test.ts` | 2026-09-22 | ✅ | 2 | base relue |
| P-178 | B CONTRAT | CancelPrestation hors périmètre CAS → DROIT, rien d'écrit. | `test/contrat/matrice.test.ts` | 2026-09-22 | ✅ | 2 | base relue |
| P-179 | B CONTRAT | RecordTimesheet hors périmètre CAS → DROIT, rien d'écrit. | `test/contrat/matrice.test.ts` | 2026-09-22 | ✅ | 2 | base relue |
| P-180 | B CONTRAT | RecordAbsence hors périmètre CAS → DROIT, rien d'écrit. | `test/contrat/matrice.test.ts` | 2026-09-22 | ✅ | 2 | base relue |
| P-181 | B CONTRAT | UpdateCandidate hors périmètre CAS → DROIT, rien d'écrit. | `test/contrat/matrice.test.ts` | 2026-09-22 | ✅ | 2 | base relue |
| P-182 | B CONTRAT | CompleteCandidate hors périmètre CAS → DROIT, rien d'écrit. | `test/contrat/matrice.test.ts` | 2026-09-22 | ✅ | 2 | base relue |
| P-183 | B CONTRAT | ExitCandidate hors périmètre CAS → DROIT, rien d'écrit. | `test/contrat/matrice.test.ts` | 2026-09-22 | ✅ | 2 | base relue |
| P-184 | B CONTRAT | ReactivateCandidate hors périmètre CAS → DROIT, rien d'écrit. | `test/contrat/matrice.test.ts` | 2026-09-22 | ✅ | 2 | base relue |
| P-185 | B CONTRAT | ConvertCandidateToResource hors périmètre CAS → DROIT, rien d'écrit. | `test/contrat/matrice.test.ts` | 2026-09-22 | ✅ | 2 | base relue |
| P-186 | B CONTRAT | CreateResource hors périmètre CAS → DROIT, rien d'écrit. | `test/contrat/matrice.test.ts` | 2026-09-22 | ✅ | 2 | base relue |
| P-187 | B CONTRAT | UpdateResource hors périmètre CAS → DROIT, rien d'écrit. | `test/contrat/matrice.test.ts` | 2026-09-22 | ✅ | 2 | base relue |
| P-188 | B CONTRAT | SetResourceState hors périmètre CAS → DROIT, rien d'écrit. | `test/contrat/matrice.test.ts` | 2026-09-22 | ✅ | 2 | base relue |
| P-189 | B CONTRAT | UpdateResourceCost hors périmètre CAS → DROIT, rien d'écrit. | `test/contrat/matrice.test.ts` | 2026-09-22 | ✅ | 2 | base relue |
| P-190 | B CONTRAT | UploadDocument hors périmètre CAS → DROIT, rien d'écrit. | `test/contrat/matrice.test.ts` | 2026-09-22 | ✅ | 2 | base relue |
| P-191 | B CONTRAT | RecordQualification hors périmètre CAS → DROIT, rien d'écrit. | `test/contrat/matrice.test.ts` | 2026-09-22 | ✅ | 2 | base relue |
| P-192 | B CONTRAT | CreateAction hors périmètre CAS → DROIT, rien d'écrit. | `test/contrat/matrice.test.ts` | 2026-09-22 | ✅ | 2 | base relue |
| P-193 | B CONTRAT | UploadDocument ressource et candidat CAS → DROIT. | `test/contrat/matrice.test.ts` | 2026-09-22 | ✅ | 2 | base relue |
| P-194 | B CONTRAT | CreateAction projet et ressource CAS → DROIT. | `test/contrat/matrice.test.ts` | 2026-09-22 | ✅ | 2 | base relue |
| P-195 | B CONTRAT | ArchiveObject projet, ressource et besoin CAS → DROIT. | `test/contrat/matrice.test.ts` | 2026-09-22 | ✅ | 2 | base relue |
| P-196 | B CONTRAT | CreateCandidate agence CAS → DROIT, rien d'écrit. | `test/contrat/matrice.test.ts` | 2026-09-22 | ✅ | 2 | base relue |
| P-197 | B CONTRAT | AdjustTimesheetAfterClose hors périmètre CAS → DROIT, rien d'écrit. | `test/contrat/matrice.test.ts` | 2026-09-22 | ✅ | 2 | base relue |
| P-198 | B CONTRAT | K3 : un compte désactivé → DROIT, rien d'écrit. | `test/contrat/matrice.test.ts` | 2026-09-22 | ✅ | 2 | base relue |
| P-199 | B CONTRAT | SetPolicy rend la liste des commandes affectées. | `test/contrat/correctifs.test.ts` | 2026-09-22 | ✅ | 2 | base relue |
| P-200 | B CONTRAT | Une décision client inconnue est GARDE, l'état ne change pas. | `test/contrat/correctifs.test.ts` | 2026-09-22 | ✅ | 2 | base relue |
