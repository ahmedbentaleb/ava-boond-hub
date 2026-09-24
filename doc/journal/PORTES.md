# Portes — le cliquet. Une porte ✅ ne redevient jamais ⏳.

Tolérance écrans (espèce D) : `maxDiffPixelRatio = 0,01` (1 % des pixels).  
Navigateur épinglé : Playwright **1.55.0**, Chromium bundlé (build v1187 / Chromium 140.0.7339.16).  
Polices : JetBrains Mono embarquée (`web/src/fonts/JetBrainsMono-Regular.woff2`), jamais le réseau.  
Animations : coupées (`animations: disabled`, `reducedMotion: reduce`).

Colonnes **État** et **Lot cible** : parade ⏳ (`_ops/PORTES_EN_ATTENTE.md`), 20/09/2026.

| Porte | Espèce | Phrase | Test | Vue rouge | État | Lot cible | Tolérance |
|---|---|---|---|---|---|---|---|
| P-001 | A BASE | Les 15 murs tiennent dans la base : 22 assertions + 1 contre-test. | `test/SPEC_ASSERTIONS_L7.sql` | 2026-09-19 | ✅ | 1 | — |
| P-002 | B CONTRAT | GET /sante répond, sans interroger la base. | `test/contrat/sante.test.ts` | 2026-09-23 | ✅ | 2 | égalité stricte |
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
| P-133 | B CONTRAT | temps.plafond_jour : 1,5 j sous alerte écrit, sous refus GARDE. | `test/contrat/politiques.test.ts` | 2026-09-22 | ✅ | 2 | base relue |
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
| P-201 | B CONTRAT | ManageRefs : catégorie inconnue GARDE, valeur système protégée, renommage sans actif. | `test/contrat/correctifs.test.ts` | 2026-09-22 | ✅ | 2 | base relue |
| P-202 | B CONTRAT | CloseProject en cascade clôture les prestations puis le projet. | `test/contrat/correctifs.test.ts` | 2026-09-22 | ✅ | 2 | base relue |
| P-203 | B CONTRAT | Matrice CRM : passe, hors périmètre, sans le groupe. | `test/contrat/v011-lignes.ts` | 2026-09-22 | ✅ | 2 | base relue |
| P-204 | B CONTRAT | Matrice identité : passe, hors périmètre, sans le groupe. | `test/contrat/v011-lignes.ts` | 2026-09-22 | ✅ | 2 | base relue |
| P-205 | B CONTRAT | Matrice besoin : passe, hors périmètre, sans le groupe. | `test/contrat/v011-lignes.ts` | 2026-09-22 | ✅ | 2 | base relue |
| P-206 | B CONTRAT | Matrice projet : passe, hors périmètre, sans le groupe. | `test/contrat/v011-lignes.ts` | 2026-09-22 | ✅ | 2 | base relue |
| P-207 | B CONTRAT | Matrice admin : passe, hors périmètre, sans le groupe. | `test/contrat/v011-lignes.ts` | 2026-09-22 | ✅ | 2 | base relue |
| P-208 | B CONTRAT | S : RecordTimesheet et RecordAbsence, soi permis, autrui refusé. | `test/contrat/v011-lignes.ts` | 2026-09-22 | ✅ | 2 | base relue |
| P-209 | B CONTRAT | positionnement.unicite : actifs, historique, aucune — trois résultats. | `test/contrat/v011-lignes.ts` | 2026-09-22 | ✅ | 2 | base relue |
| P-210 | B CONTRAT | besoin.staffing.declencheur : deux valeurs, deux résultats. | `test/contrat/v011-politiques.ts` | 2026-09-22 | ✅ | 2 | base relue |
| P-211 | B CONTRAT | besoin.pourvu.garde_minimale : deux valeurs, deux résultats. | `test/contrat/v011-politiques.ts` | 2026-09-22 | ✅ | 2 | base relue |
| P-212 | B CONTRAT | positionnement.sur_besoin_inactif : refus garde, alerte écrit. | `test/contrat/v011-politiques.ts` | 2026-09-22 | ✅ | 2 | base relue |
| P-213 | B CONTRAT | positionnement.cv_partage_obligatoire : deux valeurs, deux résultats. | `test/contrat/v011-politiques.ts` | 2026-09-22 | ✅ | 2 | base relue |
| P-214 | B CONTRAT | qualification requise avant décision : deux valeurs, deux résultats. | `test/contrat/v011-politiques.ts` | 2026-09-22 | ✅ | 2 | base relue |
| P-215 | B CONTRAT | projet.creation_depuis_besoin : alerte ou non. | `test/contrat/v011-politiques.ts` | 2026-09-22 | ✅ | 2 | base relue |
| P-216 | B CONTRAT | projet.contact : obligatoire garde, facultatif écrit. | `test/contrat/v011-politiques.ts` | 2026-09-22 | ✅ | 2 | base relue |
| P-217 | B CONTRAT | projet.origine_besoin : deux valeurs, deux résultats. | `test/contrat/v011-politiques.ts` | 2026-09-22 | ✅ | 2 | base relue |
| P-218 | B CONTRAT | besoin.projets_max : un seul garde, illimité écrit. | `test/contrat/v011-politiques.ts` | 2026-09-22 | ✅ | 2 | base relue |
| P-219 | B CONTRAT | projet.depuis_besoin.garde : deux valeurs, deux résultats. | `test/contrat/v011-politiques.ts` | 2026-09-22 | ✅ | 2 | base relue |
| P-220 | B CONTRAT | projet.depuis_besoin.garde_profil : deux valeurs, deux résultats. | `test/contrat/v011-politiques.ts` | 2026-09-22 | ✅ | 2 | base relue |
| P-221 | B CONTRAT | projet.cloture.garde : prestations closes garde, cascade clôt. | `test/contrat/v011-politiques.ts` | 2026-09-22 | ✅ | 2 | base relue |
| P-222 | B CONTRAT | prestation.avenant.mode : version datée ou non. | `test/contrat/v011-politiques.ts` | 2026-09-22 | ✅ | 2 | base relue |
| P-223 | B CONTRAT | societe.passage_client.declencheur : client ou prospect. | `test/contrat/v011-politiques.ts` | 2026-09-22 | ✅ | 2 | base relue |
| P-224 | B CONTRAT | societe.passage_client.propagation : société seule ou tous les contacts. | `test/contrat/v011-politiques.ts` | 2026-09-22 | ✅ | 2 | base relue |
| P-225 | B CONTRAT | besoin.pourvu.mode : manuel ou auto. | `test/contrat/v011-politiques.ts` | 2026-09-22 | ✅ | 2 | base relue |
| P-226 | B CONTRAT | projet.devises_mixtes : autorise ou refus. | `test/contrat/v011-politiques.ts` | 2026-09-22 | ✅ | 2 | base relue |
| P-227 | B CONTRAT | prestation.surcharge.seuil_pct : deux seuils, deux alertes. | `test/contrat/v011-politiques.ts` | 2026-09-22 | ✅ | 2 | base relue |
| P-228 | B CONTRAT | prestation.surcharge.mode : alerte ou refus. | `test/contrat/v011-politiques.ts` | 2026-09-22 | ✅ | 2 | base relue |
| P-229 | B CONTRAT | frais.mode : ignorés ou imputés. | `test/contrat/v011-politiques.ts` | 2026-09-22 | ✅ | 2 | base relue |
| P-230 | B CONTRAT | change.mode : marge nulle ou mur sur devises mixtes. | `test/contrat/v011-politiques.ts` | 2026-09-22 | ✅ | 2 | base relue |
| P-231 | B CONTRAT | marge.taux.si_ca_nul : nul ou zéro. | `test/contrat/v011-politiques.ts` | 2026-09-22 | ✅ | 2 | base relue |
| P-232 | B CONTRAT | prestation.annulation.garde : temps saisi garde, libre annule. | `test/contrat/v011-politiques.ts` | 2026-09-22 | ✅ | 2 | base relue |
| P-233 | B CONTRAT | temps.periode : hors dates garde ou écrit. | `test/contrat/v011-politiques.ts` | 2026-09-22 | ✅ | 2 | base relue |
| P-234 | B CONTRAT | capacite.jour_ouvre : alerte ou non. | `test/contrat/v011-politiques.ts` | 2026-09-22 | ✅ | 2 | base relue |
| P-235 | B CONTRAT | temps.facturable.mode : saisie séparée ou égal au produit. | `test/contrat/v011-politiques.ts` | 2026-09-22 | ✅ | 2 | base relue |
| P-236 | B CONTRAT | temps.validation : aucune écrit, par DP garde. | `test/contrat/v011-politiques.ts` | 2026-09-22 | ✅ | 2 | base relue |
| P-237 | B CONTRAT | temps.correction_apres_cloture : refus ou ajustement. | `test/contrat/v011-politiques.ts` | 2026-09-22 | ✅ | 2 | base relue |
| P-238 | B CONTRAT | absence.chevauchement : refus ou alerte. | `test/contrat/v011-politiques.ts` | 2026-09-22 | ✅ | 2 | base relue |
| P-239 | B CONTRAT | absence.sans_prestation : refusée ou autorisée. | `test/contrat/v011-politiques.ts` | 2026-09-22 | ✅ | 2 | base relue |
| P-240 | B CONTRAT | doublon.societe.cles : nom bloque, siren seul non. | `test/contrat/v011-politiques.ts` | 2026-09-22 | ✅ | 2 | base relue |
| P-241 | B CONTRAT | societe.retour_prospect : manuel ou jamais. | `test/contrat/v011-politiques.ts` | 2026-09-22 | ✅ | 2 | base relue |
| P-242 | B CONTRAT | societe.archivage.garde : objets actifs ou libre. | `test/contrat/v011-politiques.ts` | 2026-09-22 | ✅ | 2 | base relue |
| P-243 | B CONTRAT | service.archivage.garde : besoin lié ou libre. | `test/contrat/v011-politiques.ts` | 2026-09-22 | ✅ | 2 | base relue |
| P-244 | B CONTRAT | doublon.contact.mode : bloquer ou ignorer. | `test/contrat/v011-politiques.ts` | 2026-09-22 | ✅ | 2 | base relue |
| P-245 | B CONTRAT | doublon.contact.cles : email ou nom. | `test/contrat/v011-politiques.ts` | 2026-09-22 | ✅ | 2 | base relue |
| P-246 | B CONTRAT | contact.transfert.objets_actifs : réaffectation ou conserver. | `test/contrat/v011-politiques.ts` | 2026-09-22 | ✅ | 2 | base relue |
| P-247 | B CONTRAT | doublon.personne.mode : bloquer ou ignorer. | `test/contrat/v011-politiques.ts` | 2026-09-22 | ✅ | 2 | base relue |
| P-248 | B CONTRAT | doublon.personne.cles : email ou naissance. | `test/contrat/v011-politiques.ts` | 2026-09-22 | ✅ | 2 | base relue |
| P-249 | B CONTRAT | candidat.complete.champs_requis : deux listes, deux résultats. | `test/contrat/v011-politiques.ts` | 2026-09-22 | ✅ | 2 | base relue |
| P-250 | B CONTRAT | ressource.externe.societe_fournisseur : obligatoire ou facultatif. | `test/contrat/v011-politiques.ts` | 2026-09-22 | ✅ | 2 | base relue |
| P-251 | B CONTRAT | ressource.etat.mode : manuel ou dérivé. | `test/contrat/v011-politiques.ts` | 2026-09-22 | ✅ | 2 | base relue |
| P-252 | B CONTRAT | qualification.besoin_obligatoire : oui ou non. | `test/contrat/v011-politiques.ts` | 2026-09-22 | ✅ | 2 | base relue |
| P-253 | B CONTRAT | candidat.conversion.acteur : groupe RH ou tout habilité. | `test/contrat/v011-politiques.ts` | 2026-09-22 | ✅ | 2 | base relue |
| P-254 | B CONTRAT | historique.tentatives_refusees : tracées ou non. | `test/contrat/v011-politiques.ts` | 2026-09-22 | ✅ | 2 | base relue |
| P-256 | B CONTRAT | SignPrestation et RecordClientDecision portent les politiques lues. | `test/contrat/correctifs.test.ts` | 2026-09-22 | ✅ | 2 | base relue |
| P-257 | B CONTRAT | Un groupe inconnu est tracé, sans uuid vide. | `test/contrat/correctifs.test.ts` | 2026-09-22 | ✅ | 2 | base relue |
| P-258 | B CONTRAT | SetPolicy refuse une liste qui n'est pas du JSON. | `test/contrat/correctifs.test.ts` | 2026-09-22 | ✅ | 2 | base relue |
| P-259 | B CONTRAT | SetOwnTheme refuse une clé hors ui connu. | `test/contrat/correctifs.test.ts` | 2026-09-22 | ✅ | 2 | base relue |
| P-260 | B CONTRAT | Une entrée mal typée est GARDE, pas un HTTP 500. | `test/contrat/correctifs.test.ts` | 2026-09-22 | ✅ | 2 | base relue |
| P-261 | B CONTRAT | ArchiveObject rend l'id de l'objet. | `test/contrat/correctifs.test.ts` | 2026-09-22 | ✅ | 2 | base relue |
| P-262 | B CONTRAT | ArchiveObject sur un projet engagé est GARDE. | `test/contrat/correctifs.test.ts` | 2026-09-22 | ✅ | 2 | base relue |
| P-263 | B CONTRAT | DATABASE_URL manquant lève ; aucun port fixe ni base ava en dur. | `test/contrat/correctifs.test.ts` | 2026-09-22 | ✅ | 2 | — |
| P-264 | B CONTRAT | nom+prenom+naissance bloque un doublon, un autre jour passe. | `test/contrat/correctifs.test.ts` | 2026-09-22 | ✅ | 2 | base relue |
| P-265 | B CONTRAT | Les statuts commerciaux se lisent dans le référentiel. | `test/contrat/correctifs.test.ts` | 2026-09-22 | ✅ | 2 | base relue |
| P-266 | B CONTRAT | L'écran lit les besoins en base, plus le bouchon. | `test/contrat/correctifs.test.ts` | 2026-09-22 | ✅ | 2 | base relue |
| P-267 | B CONTRAT | Un compte RES déjà lié retrouve son profil ressource. | `test/contrat/correctifs.test.ts` | 2026-09-22 | ✅ | 2 | base relue |
| P-268 | B CONTRAT | compter lie les valeurs et refuse un littéral SQL. | `test/contrat/correctifs.test.ts` | 2026-09-22 | ✅ | 2 | — |
| P-269 | B CONTRAT | gardePourvu n'est pas une commande ; un service avec besoin ouvert est GARDE. | `test/contrat/correctifs.test.ts` | 2026-09-22 | ✅ | 2 | base relue |
| P-270 | B CONTRAT | La règle S se lit sur le périmètre soi. | `test/contrat/correctifs.test.ts` | 2026-09-22 | ✅ | 2 | base relue |
| P-271 | B CONTRAT | Hors banc les vues rendent 401 ; en banc PAR ne voit pas CAS. | `test/contrat/audit3.test.ts` | 2026-09-23 | ✅ | 2 | base relue |
| P-272 | B CONTRAT | CreateUnit, UpdateUnit, ArchiveService hors agence : DROIT, rien écrit. | `test/contrat/audit3.test.ts` | 2026-09-23 | ✅ | 2 | base relue |
| P-273 | B CONTRAT | Une commande sans ligne de correspondance d'agence est refusée. | `test/contrat/audit3.test.ts` | 2026-09-23 | ✅ | 2 | base relue |
| P-274 | B CONTRAT | Hors banc, un refus anonyme n'écrit pas tentative_refusee. | `test/contrat/audit3.test.ts` | 2026-09-23 | ✅ | 2 | base relue |
| P-275 | B CONTRAT | CreatePrestation sur un projet clos est ETAT, rien écrit. | `test/contrat/audit3.test.ts` | 2026-09-23 | ✅ | 2 | base relue |
| P-276 | B CONTRAT | SetPolicy liste les commandes qui lisent la clé, jamais vide. | `test/contrat/audit3.test.ts` | 2026-09-23 | ✅ | 2 | base relue |
| P-277 | B CONTRAT | ArchiveObject émet ObjectArchived avec le motif. | `test/contrat/audit3.test.ts` | 2026-09-23 | ✅ | 2 | base relue |
| P-278 | B CONTRAT | v_besoin_couverture ignore une prestation archivée. | `test/contrat/audit3.test.ts` | 2026-09-23 | ✅ | 2 | base relue |
| P-279 | B CONTRAT | TakeNeedInCharge passe sous le seed et refuse ETAT hors cycle. | `test/contrat/audit3.test.ts` | 2026-09-23 | ✅ | 2 | base relue |
| P-280 | B CONTRAT | ManageRefs refuse une catégorie inconnue sur ref_pays. | `test/contrat/audit3.test.ts` | 2026-09-23 | ✅ | 2 | base relue |
| P-281 | B CONTRAT | Après migration, les 9 comptes de banc sont inactifs. | `test/contrat/comptes-avant-fixture.test.ts` | 2026-09-23 | ✅ | 2 | base relue |
| P-282 | B CONTRAT | NeedStateChanged porte de et vers en catégorie. | `test/contrat/audit3.test.ts` | 2026-09-23 | ✅ | 2 | base relue |
| P-283 | B CONTRAT | ArchiveCompany, ArchiveContact, ArchiveService, UpdateResourceCost réussissent, base relue. | `test/contrat/audit3.test.ts` | 2026-09-23 | ✅ | 2 | base relue |
| P-284 | B CONTRAT | ManageGroups : un périmètre non uuid est INTROUVABLE. | `test/contrat/audit3.test.ts` | 2026-09-23 | ✅ | 2 | base relue |
| P-285 | B CONTRAT | L'en-tête est l'e-mail du compte, l'événement porte cet auteur. | `test/contrat/audit3.test.ts` | 2026-09-23 | ✅ | 2 | base relue |
| P-286 | B CONTRAT | Doublon contact nom+prenom+societe, et la propagation écrit le statut. | `test/contrat/audit3.test.ts` | 2026-09-23 | ✅ | 2 | base relue |
| P-287 | B CONTRAT | Agence de l'objet lue : un compte d'une autre agence est DROIT, rien n'est écrit. | `test/contrat/audit4.test.ts` | 2026-09-23 | ✅ | 2 | base relue |
| P-288 | B CONTRAT | Agence nulle d'un candidat : un compte d'une autre agence est DROIT, rien n'est écrit. | `test/contrat/audit4.test.ts` | 2026-09-23 | ✅ | 2 | base relue |
| P-289 | B CONTRAT | Objet introuvable à la résolution d'agence → INTROUVABLE. | `test/contrat/audit4.test.ts` | 2026-09-23 | ✅ | 2 | — |
| P-290 | B CONTRAT | ConvertCandidateToResource écrit l'agence du compte, pas celle de l'entrée. | `test/contrat/audit4.test.ts` | 2026-09-23 | ✅ | 2 | base relue |
| P-291 | B CONTRAT | Agence demandée différente de l'agence lue → DROIT, rien écrit. | `test/contrat/audit4.test.ts` | 2026-09-23 | ✅ | 2 | base relue |
| P-292 | B CONTRAT | Vue sans en-tête ou groupe inconnu → DROIT, pas une liste vide. | `test/contrat/audit4.test.ts` | 2026-09-23 | ✅ | 2 | — |
| P-293 | B CONTRAT | Une unité de société cliente porte l'agence du compte qui la crée. | `test/contrat/audit4.test.ts` | 2026-09-23 | ✅ | 2 | base relue |
| P-294 | B CONTRAT | ArchiveCompany pose le droit, joue la garde, le retire. | `test/contrat/audit4.test.ts` | 2026-09-23 | ✅ | 2 | base relue |
| P-295 | B CONTRAT | ArchiveService pose le droit, joue la garde, le retire. | `test/contrat/audit4.test.ts` | 2026-09-23 | ✅ | 2 | base relue |
| P-296 | B CONTRAT | ArchiveContact pose le droit, joue la garde, le retire. | `test/contrat/audit4.test.ts` | 2026-09-23 | ✅ | 2 | base relue |
| P-297 | B CONTRAT | ArchiveObject pose le droit, joue la garde, le retire. | `test/contrat/audit4.test.ts` | 2026-09-23 | ✅ | 2 | base relue |
| P-298 | B CONTRAT | Quatre commandes sans succès au seed réussissent, le droit est retiré. | `test/contrat/audit4.test.ts` | 2026-09-23 | ✅ | 2 | base relue |
| P-299 | B CONTRAT | Le fichier d'assertions porte `\set ON_ERROR_STOP on` en tête, et la copie `test/` est le canon. | `test/contrat/outils.test.ts` | 2026-09-23 | ✅ | 2 | égalité stricte |
| P-300 | B CONTRAT | `verif_serveur.sh` refuse une base ouverte et nomme le motif ; poste de dev déclaré, il accepte. | `test/contrat/outils.test.ts` | 2026-09-23 | ✅ | 2 | — |
| P-301 | B CONTRAT | Un candidat ne peut plus perdre son agence : la base refuse `agence_id` NULL. | `test/contrat/audit4.test.ts` | 2026-09-24 | ✅ | 2 | mur NOT NULL |
| P-302 | B CONTRAT | UpdateCompany dans l'agence responsable, nom et agence relus. | `test/contrat/audit4.test.ts` | 2026-09-24 | ✅ | 2 | base relue |
| P-303 | B CONTRAT | Sept commandes société et contact hors agence → DROIT, rien écrit. | `test/contrat/audit4.test.ts` | 2026-09-24 | ✅ | 2 | 0 écriture |
| P-304 | B CONTRAT | `societe.perimetre.mode` = agence_responsable : l'autre agence est DROIT. | `test/contrat/audit4.test.ts` | 2026-09-24 | ✅ | 2 | — |
| P-305 | B CONTRAT | `societe.perimetre.mode` = par_besoins : l'agence d'un besoin passe, relue. | `test/contrat/audit4.test.ts` | 2026-09-24 | ✅ | 2 | base relue |
| P-306 | B CONTRAT | `societe.perimetre.mode` = partagee : l'autre agence écrit, relue. | `test/contrat/audit4.test.ts` | 2026-09-24 | ✅ | 2 | base relue |
| P-307 | B CONTRAT | UpdateCandidate écrit le responsable RH, relu. | `test/contrat/audit4.test.ts` | 2026-09-24 | ✅ | 2 | base relue |
| P-308 | B CONTRAT | UpdateCandidate écrit le pôle lu dans `ref_pole`. | `test/contrat/audit4.test.ts` | 2026-09-24 | ✅ | 2 | base relue |
| P-309 | B CONTRAT | UpdateResource écrit la mobilité, relue. | `test/contrat/audit4.test.ts` | 2026-09-24 | ✅ | 2 | base relue |
| P-310 | B CONTRAT | UpdateResource écrit le matricule, relu. | `test/contrat/audit4.test.ts` | 2026-09-24 | ✅ | 2 | base relue |
| P-311 | B CONTRAT | UpdateNeed écrit les critères du besoin, relus. | `test/contrat/audit4.test.ts` | 2026-09-24 | ✅ | 2 | base relue |
| P-312 | B CONTRAT | UpdateNeed écrit le lieu de mission, relu. | `test/contrat/audit4.test.ts` | 2026-09-24 | ✅ | 2 | base relue |
| P-313 | B CONTRAT | UpdateProject écrit l'intermédiaire de facturation, relu. | `test/contrat/audit4.test.ts` | 2026-09-24 | ✅ | 2 | base relue |
