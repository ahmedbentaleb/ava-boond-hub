# Conformité au contrat `_ops/SPEC_COMMANDES_L4.md` — commande par commande (famille H)

**55 commandes au contrat · 55 servies · 0 servie hors contrat** (`rapport/preuves/H_commandes_servies.txt`).
Hors contrat, le serveur expose aussi : `GET /sante`, `POST /acquitter` (tuyau du lot 1, sans droit) et
`GET /bouchon/*.json` (données fictives de l'écran, V-018).

Méthode : lecture de `server/src/commandes/*.ts` contre les six colonnes de L4, puis sondes réelles sur
le port 3100 (`rapport/preuves/H_sondes_fonctionnelles.txt`, `H_sonde_pourvu_auto_et_cycle.txt`,
`I_perimetre_et_S.txt`). « oui » = vérifié conforme ; « non » = preuve dans la dernière colonne ;
« — » = rien au contrat.

## Écarts communs aux 55 commandes (ils ne sont pas répétés ligne par ligne)

| Écart | Colonne | Preuve |
|---|---|---|
| Le **périmètre** n'est jamais comparé à l'objet | Refus (`DROIT`) | `executer.ts:156` ; sonde CAS (V-004) |
| Le **groupe** vient d'un en-tête, sans authentification | Refus (`DROIT`) | `index.ts:77-83`, `executer.ts:48-60` (V-003) |
| L'**événement rendu** est le dernier du compte, pas celui de la transaction | Sortie | `executer.ts:62-80` ; S2b (V-007) |
| Refus rendus en HTTP 200 ; erreurs en 500 avec le message SQL | Refus | `executer.ts:162-174` (V-030) |
| `emit()` : l'événement est bien écrit dans la même transaction que la mutation, avec `liens.politiques` | Événement | `kernel.ts:84-107`, `executer.ts:153-160` ; S3a (V-041) ✅ |

## Le tableau

| # | Commande | Existe | Entrée conforme | Sortie conforme | Refus conformes | Événement écrit | Politique lue | Mur touché | Preuve de chaque « non » |
|---|---|---|---|---|---|---|---|---|---|
| 1 | CreateCompany | oui | oui | oui | oui (`bloquer` = « refus » du contrat, V-029) | oui | **non** | — | `doublon.societe.cles` lue, ignorée : recherche sur `nom_normalise` seul, jamais `siren` (`crm.ts:25-31`) |
| 2 | UpdateCompany | oui | oui | oui | oui | oui | — | — | |
| 3 | RequalifyCompany | oui | oui | oui | **non** | oui | oui | — | cycle codé sur les codes, `prospect→client` manuel permis alors que MACHINES §7 le dérive de la signature, `ancien_client` hors machine (`crm.ts:75-79`, V-015) |
| 4 | ArchiveCompany | oui | oui | oui | oui | oui (motif dans l'événement) | oui | oui (M-8 : `archive_le`) | injoignable au seed (D) |
| 5 | CreateUnit | oui | oui | oui | oui (3 messages distincts) | oui | — | oui (M-12) | |
| 6 | UpdateUnit | oui | oui | oui | **non** | oui | — | oui | cycle indirect non gardé → `MUR erreur interne` (`crm.ts:173`, V-033) |
| 7 | ArchiveService | oui | oui | oui | oui | oui | oui | oui | injoignable au seed (D) |
| 8 | CreateContact | oui | oui | oui | **non** | oui | **non** | oui (M-12) | type inconnu → MUR (pas de garde, V-017) ; `doublon.contact.cles` ignorée (`crm.ts:253-262`) |
| 9 | UpdateContact | oui | oui | oui | oui | oui | — | oui | |
| 10 | TransferContact | oui | oui | oui | oui | oui | oui | oui | |
| 11 | ArchiveContact | oui | oui | oui | oui | oui | — | oui | injoignable au seed (D) |
| 12 | CreatePerson | oui | oui | oui | **non** | oui | **non** | — | `civilite:"M"` → `MUR erreur interne` (sonde) ; `doublon.personne.cles` ignorée (`identite.ts:17-27`) |
| 13 | CreateCandidate | oui | oui | oui | oui (MUR M-3 levé par la commande, comme écrit) | oui | — | oui (M-3) | |
| 14 | UpdateCandidate | oui | oui | oui | oui | oui | — | — | |
| 15 | CompleteCandidate | oui | oui | oui | oui | oui | oui | — | code cible `'complete'` en dur (`identite.ts:115`, V-015) |
| 16 | ExitCandidate | oui | oui | oui | oui | **non** | — | — | écrit dans `ref_etat_candidat` sans `RefChanged` (`identite.ts:132-143`, V-016) |
| 17 | ReactivateCandidate | oui | oui | oui | oui | oui | — | — | |
| 18 | ConvertCandidateToResource | oui | oui | **non** | oui (les 4 refus du §C-1) | oui | oui | oui (M-3) | sortie non déballée : pas d'`id`, `actions: []` (`executer.ts:17-45`, sonde, V-032) ; acteur codé sur des noms de groupe (`droits.ts:70-81`) |
| 19 | CreateResource | oui | oui | oui | oui | oui | oui | oui (M-3) | |
| 20 | UpdateResource | oui | oui | oui | oui (refuse le coût) | oui | — | — | |
| 21 | SetResourceState | oui | oui | oui | oui | oui | oui | — | transitions en dur (`identite.ts:268-272`, V-015) |
| 22 | UpdateResourceCost | oui | oui | oui | oui (personne au seed) | oui | — | oui (M-15 paire) | |
| 23 | UploadDocument | oui | oui | oui | **non** | oui | — | oui (un porteur) | règle S contournée par `projet_id` (sonde RES, V-020) ; seul le nom du fichier est stocké |
| 24 | RecordQualification | oui | oui | oui | oui | oui | oui | — | |
| 25 | CreateNeed | oui | oui | oui | **non** | oui | oui | oui (M-11, M-12) | type ou couverture inconnus → MUR (sonde, V-017) |
| 26 | UpdateNeed | oui | oui | oui | oui | oui | — | oui | |
| 27 | SetNeedPriority | oui | oui | oui | **non** | oui | — | — | priorité inconnue → MUR (sonde, V-017) |
| 28 | TakeNeedInCharge | oui | oui | oui | oui | oui | oui | — | |
| 29 | DeclareNeedFilled | oui | oui | oui | oui | oui | **non** | — | `besoin.pourvu.garde_minimale` lue puis ignorée (`besoin.ts:128`, V-014) |
| 30 | SuspendNeed | oui | oui | oui | oui | oui (motif dans l'événement) | — | — | |
| 31 | ResumeNeed | oui | oui | oui | oui | oui | — | — | |
| 32 | CloseNeed | oui | oui | oui | oui | oui | — | — | |
| 33 | ReopenNeed | oui | oui | oui | oui | oui | — | — | |
| 34 | PositionCandidate | oui | oui | **non** | oui | oui | oui | oui (M-2) | la réponse annonce `NeedStateChanged`, pas `CandidatePositioned` (sonde, V-032) |
| 35 | PositionResource | oui | oui | **non** | oui | oui | oui | oui (M-2) | idem (même code, `besoin.ts:206-261`) |
| 36 | DeclareCVShared | oui | oui | oui | oui | oui | — | oui (étape `cv_partage`) | |
| 37 | RecordClientDecision | oui | oui | oui | oui (IA seul, motif si négatif) | oui | oui | — | vocabulaire de décision en dur (`besoin.ts:308`) |
| 38 | WithdrawPositioning | oui | oui | oui | oui | oui (motif dans l'événement) | — | — | |
| 39 | CreateProject | oui | oui | oui | oui | oui | oui | oui (M-12) | référence `count+1` (V-035) |
| 40 | CreateProjectFromNeed | oui | oui | oui | oui | oui | oui | oui | |
| 41 | UpdateProject | oui | oui | oui | oui | oui | — | oui | |
| 42 | CloseProject | oui | oui | oui | oui | oui | oui | — | |
| 43 | CreatePrestation | oui | oui | oui | oui (O-2 tenu : sonde STAF → DROIT) | oui | oui | oui (M-1, M-4, M-15) | |
| 44 | SignPrestation | oui | oui | **non** | oui | oui | **non** | oui (M-14) | réponse = dernier événement d'effet ; pourvu automatique sans garde (sonde : `pourvu` à 1/2, V-013) ; `societe.passage_client.propagation` ignorée (`projet.ts:177`) |
| 45 | ClosePrestation | oui | oui | oui | **non** | oui | oui | oui (M-6, snapshot dans la transaction) | garde « date ≤ fin » absente (V-034) |
| 46 | CancelPrestation | oui | oui | oui | oui | oui (motif) | oui | — | |
| 47 | RecordTimesheet | oui | oui | oui | **non** | oui | **non** | oui (M-10) | refuse toute saisie sous `temps.periode` par défaut (V-005) ; `temps.validation` ignorée (`projet.ts:420`) ; S non testable (RES sans personne, V-038) |
| 48 | AdjustTimesheetAfterClose | oui | oui | oui | oui | oui | oui | oui (M-6 : snapshot inchangé, sonde) | |
| 49 | RecordAbsence | oui | oui | oui | oui | oui | oui | — | |
| 50 | CreateAction | oui | oui | oui | **non** | oui | — | oui (M-9) | type inconnu → MUR (sonde, V-017) |
| 51 | ArchiveObject | oui | oui | oui | **non** | oui | — | oui (M-8) | « GARDE selon l'objet » absente : contourne ArchiveCompany/Contact/Service (`admin.ts:44-62`, V-037) |
| 52 | SetPolicy | oui | oui | **non** | **non** | **non** | — | **non** | HTTP 500 sur `permission_code`, transaction annulée, aucune politique ne se règle ; garde `mur_touche` absente (`admin.ts:67-94`, V-006) |
| 53 | ManageRefs | oui | **non** | oui | **non** | oui | — | oui (CHECK catégorie) | ni `ordre` ni `actif` ; catégorie inconnue → MUR au lieu de GARDE (sonde, V-017, V-036) |
| 54 | ManageGroups | oui | oui | oui | oui | **non** | — | oui (M-13) | `GroupPermissionChanged` émis même quand rien ne change (`admin.ts:147-156`, V-036) |
| 55 | SetOwnTheme | oui | oui | oui | oui | oui | oui | — | `theme_json` = l'entrée brute, non validée (`admin.ts:163`) ; SUP autorisé (contradiction de la matrice, V-029) |

## Compte

| Colonne | « non » |
|---|---|
| Existe | 0 / 55 |
| Entrée conforme | 1 (ManageRefs) |
| Sortie conforme | 5 (Convert, PositionCandidate, PositionResource, SignPrestation, SetPolicy) + l'écart commun V-007 |
| Refus conformes | 13 + l'écart commun du périmètre (V-004) sur les 55 |
| Événement écrit | 3 (ExitCandidate, SetPolicy, ManageGroups) |
| Politique lue | 6 (CreateCompany, CreateContact, CreatePerson, DeclareNeedFilled, SignPrestation, RecordTimesheet : clés lues sans effet) |
| Mur touché | 1 (SetPolicy) |

⭐ **Commandes entièrement conformes (hors écarts communs) : 34 sur 55.** ⚠️ Aucune porte n'en
vérifie l'effet en base : les 3 portes de succès ne relisent pas la base, les 52 autres ne prouvent
qu'un refus (V-010).
