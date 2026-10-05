# Matrice des droits Ava Manager v1

Date : 18/09/2026 · Statut : **tranchée par Brain sur délégation** — se conteste avec une source, comme les DEC.
Source de forme : `CADRAGE_METIER_RECONCILIE` §Matrice (configuration retenue **F8–F14**), `MACHINES_ETAT_V1` (les commandes), `MODELE_DONNEES` §7 (les tables), `REGISTRE_POLITIQUES_v1` (ce qui reste réglable).

**C'est le lot « Droits » du brief exécutant** (⚠️ pas le lot 8 du plan, qui est le connecteur MCP). Sans elle, la moitié des services n'a pas de garde.

Le motif ligne par ligne, et les cas contestés : [annexes/MATRICE_DROITS_MOTIFS_2026-09-18.md](annexes/MATRICE_DROITS_MOTIFS_2026-09-18.md)

<quand_utiliser>

| ✅ On l'ouvre | ⛔ On ne l'ouvre pas |
|---|---|
| Écrire la garde `droit()` d'une commande | Pour savoir **ce que** fait une commande — c'est `MACHINES_ETAT_V1` |
| Peupler `groupe_permission_perimetre` (lot « Droits » du brief) | Pour savoir si une règle est réglable — c'est le registre |
| Répondre à « qui peut faire ça ? » | Pour la lecture des **objets** — c'est BM-45, pas cette grille |

⚠️ **Cette matrice porte les commandes ET, depuis le 29/09, la lecture** (bloc « Lecture », D-46). « Lire CreateCompany » n'a pas de sens ; « Lire les besoins » en a un. ⛔ *Avant le 29/09 elle renvoyait la lecture « au périmètre » sans dire de quelle permission : le code a pris celui de n'importe laquelle (V-150).*

</quand_utiliser>

## Les quatre symboles

| | Sens | Ce que l'exécutant écrit |
|---|---|---|
| **✓** | attribué au groupe par défaut | une ligne dans `groupe_permission_perimetre` |
| **D** | **délégation explicite** — la permission existe, elle n'est pas donnée au départ | rien au seed ; l'admin l'ajoute |
| **S** | **soi-même** seulement | la garde lit `compte.personne_id` |
| **—** | aucune exécution par ce groupe | rien, et la commande refuse |

⛔ **Un `—` n'est pas un oubli.** C'est un refus attendu, et il a un test.

<procedure>

**Comment un droit se résout, à l'exécution — dans cet ordre, toujours :**

**1.** Rassembler les paires `(permission, périmètre)` de **tous** les groupes du compte — c'est une **union** (DEC-17, BM-42).

**2.** Appliquer les surcharges nominatives de `compte_surcharge` — elles ne peuvent qu'**enlever** (F28, P-4).

**3.** Trancher les conflits selon **POL `droits.surcharge_restrictive`** — défaut : **la restriction gagne**.

**4.** Vérifier que le **périmètre** de la paire contient l'objet visé. Lire sur B et écrire sur A ne donne **jamais** écrire sur B (S14).

**5.** Si la commande porte un `S`, vérifier en plus que l'objet est celui du compte : `compte.personne_id` → `profil_ressource.personne_id` → ses prestations.

**6.** Refuser **avant** toute mutation, et tracer selon **POL `historique.tentatives_refusees`** (défaut : à part, jamais mêlé aux réussites).

</procedure>

## Les neuf groupes

| Groupe | Ce dont il répond | Périmètre par défaut |
|---|---|---|
| **IA** | la relation commerciale | ses agences |
| **RH** | les candidatures et les fiches personnes | son agence |
| **RR** | le cadre du recrutement | son périmètre de processus |
| **ÉVAL** | mesurer un profil pour un besoin confié | les besoins qui lui sont assignés |
| **STAF** | affecter les ressources aux besoins | son équipe / pôle |
| **DP** | tenir l'exécution et les conditions | ses projets / pôle |
| **RES** | déclarer son activité | **soi-même** |
| **ADM** | habilitations, listes, apparence | global **administratif** |
| **SUP** | lire pour assister | global, **lecture seule** |

⚠️ **« Commercial » n'est pas un dixième groupe** — c'est le nom d'affichage d'IA (F12). Karim **cumule** STAF et DP (F8) ; c'est l'union qui lui donne ses droits, pas un groupe fusionné.

---

# La grille — 48 lignes, 55 commandes × 9 groupes

## CRM — sociétés, unités, contacts

| Commande | IA | RH | RR | ÉVAL | STAF | DP | RES | ADM | SUP |
|---|---|---|---|---|---|---|---|---|---|
| `CreateCompany` | ✓ | — | — | — | — | — | — | D | — |
| `UpdateCompany` | ✓ | — | — | — | — | — | — | D | — |
| `RequalifyCompany` | ✓ | — | — | — | ✓ *(D-55)* | ✓ *(D-48)* | — | D | — |
| `ArchiveCompany` | D | — | — | — | — | — | — | D | — |
| `CreateUnit` · `UpdateUnit` | ✓ | — | — | — | — | — | — | D | — |
| `ArchiveService` | D | — | — | — | — | — | — | D | — |
| `CreateContact` · `UpdateContact` | ✓ | — | — | — | D | D | — | D | — |
| `TransferContact` | ✓ | — | — | — | — | — | — | D | — |
| `ArchiveContact` | D | — | — | — | — | — | — | D | — |

## Identité et recrutement

| Commande | IA | RH | RR | ÉVAL | STAF | DP | RES | ADM | SUP |
|---|---|---|---|---|---|---|---|---|---|
| `CreatePerson` | ✓ | ✓ | ✓ | — | ✓ | — | — | D | — |
| `CreateCandidate` | D | ✓ | ✓ | — | — | — | — | D | — |
| `UpdateCandidate` | — | ✓ | D | — | — | — | — | D | — |
| `CompleteCandidate` | — | ✓ | D | — | — | — | — | D | — |
| `ExitCandidate` · `ReactivateCandidate` | — | ✓ | D | — | — | — | — | D | — |
| **`ConvertCandidateToResource`** | — | ✓ | **D** | — | **D** | — | — | D | — |
| `CreateResource` | — | ✓ | — | — | D | — | — | D | — |
| `UpdateResource` | — | ✓ | — | — | — | — | — | D | — |
| `SetResourceState` | — | ✓ | — | — | ✓ | — | — | D | — |
| ⛔ **`UpdateResourceCost`** | — | **D** | — | — | — | **D** | — | D | — |
| `UploadDocument` | ✓ | ✓ | D | D | ✓ | ✓ | S | D | — |
| `RecordQualification` | — | D | D | ✓ | — | — | — | D | — |

⚠️ **`UpdateResourceCost` est la ligne sensible.** Le coût de référence n'est donné à personne au départ : ni RH ni DP ne l'obtiennent en entrant dans leur groupe. C'est le cadrage — « coût de référence sous permission spécifique ».

## Besoin et positionnement

| Commande | IA | RH | RR | ÉVAL | STAF | DP | RES | ADM | SUP |
|---|---|---|---|---|---|---|---|---|---|
| `CreateNeed` · `UpdateNeed` | ✓ | — | — | — | D | — | — | D | — |
| `SetNeedPriority` | ✓ | — | — | — | D | — | — | D | — |
| `TakeNeedInCharge` | D | — | — | — | ✓ | — | — | D | — |
| `DeclareNeedFilled` | — | — | — | — | ✓ | ✓ *(D-48)* | — | D | — |
| `SuspendNeed` · `ResumeNeed` | ✓ | — | — | — | ✓ | — | — | D | — |
| `CloseNeed` · `ReopenNeed` | ✓ | — | — | — | D | — | — | D | — |
| `PositionCandidate` | ✓ | ✓ | — | — | D | — | — | D | — |
| `PositionResource` | D | D | — | — | ✓ | — | — | D | — |
| `DeclareCVShared` | ✓ | ✓ | — | — | ✓ | — | — | D | — |
| **`RecordClientDecision`** | **✓** | — | — | — | — | — | — | D | — |
| `WithdrawPositioning` | ✓ | ✓ | — | — | ✓ | — | — | D | — |

⚠️ **`RecordClientDecision` n'appartient qu'à IA.** C'est lui qui parle au client ; personne d'autre ne peut enregistrer sa réponse. C'est ce qui empêche un staffing pressé de « supposer » un accord.

## Projet, prestation, production

| Commande | IA | RH | RR | ÉVAL | STAF | DP | RES | ADM | SUP |
|---|---|---|---|---|---|---|---|---|---|
| `CreateProject` · `CreateProjectFromNeed` | — | — | — | — | ✓ | ✓ | — | D | — |

⭐ D-48 appliqué à `societe.passage_client.declencheur = creation_projet` (D-55) : STAF reçoit aussi `RequalifyCompany` sur son périmètre, la fille de cette cascade.

| `UpdateProject` | — | — | — | — | D | ✓ | — | D | — |
| `CloseProject` | — | — | — | — | — | ✓ | — | D | — |
| `CreatePrestation` | — | — | — | — | ✓ | ✓ | — | D | — |
| ⛔ **`SignPrestation`** | — | — | — | — | **—** | **✓** | — | D | — |
| `ClosePrestation` | — | — | — | — | D | ✓ | — | D | — |
| `CancelPrestation` | — | — | — | — | ✓ | ✓ | — | D | — |
| `RecordTimesheet` | — | — | — | — | ✓ | ✓ | **S** | D | — |
| `AdjustTimesheetAfterClose` | — | — | — | — | D | ✓ | — | D | — |
| `ValidateTimesheet` · `RejectTimesheet` *(D-50)* | — | — | — | — | — | ✓ | — | D | — |
| `RecordAbsence` | — | ✓ | — | — | D | D | **S** | D | — |

⭐ **D-48 (30/09) — qui a la mère a les filles.** Signer une prestation déclenche en cascade `RequalifyCompany` (le prospect devient client) et `DeclareNeedFilled` (le besoin est pourvu) ; depuis D-43 une cascade exige le droit de la fille. Le DP reçoit donc les deux, sur son périmètre. Une porte le garde : pour chaque cascade déclarée, tout groupe qui a la mère a les filles au seed.

⚠️ **`SignPrestation` au DP seul, `—` pour le staffing (O-2).** Créer une mission déjà signée, **c'est la signer** : `CreatePrestation` avec l'état initial `engage` exige **en plus** la permission `SignPrestation`. Sans cette règle, le staffing signait par la porte de derrière.

## RH — contrats, documents, coût, blacklist *(24/09)*

| Commande | IA | RH | RR | ÉVAL | STAF | DP | RES | ADM | SUP |
|---|---|---|---|---|---|---|---|---|---|
| `CreateHrContract` · `RenewHrContract` · `EndHrContract` | — | ✓ | ✓ | — | — | — | — | D | — |
| `AddTrackedDocument` | — | ✓ | ✓ | — | — | — | S | D | — |
| `SetBlacklistFlag` · `ClearBlacklistFlag` | ✓ | ✓ | ✓ | — | — | — | — | D | — |
| `UpdateEmployeeCost` | — | — | — | — | — | — | — | D | — |
| `UpdateSensitiveHrData` | — | ✓ | — | — | — | — | — | D | — |

⚠️ `UpdateEmployeeCost` suit la règle de `UpdateResourceCost` : **personne au départ**, délégué
nommément. ⚠️ Les données RH sensibles (R8) sont lues sous une permission dédiée,
`LireDonneesRHSensibles`, donnée au seul groupe RH.

## Facturation et achats *(24/09)*

| Commande | IA | RH | RR | ÉVAL | STAF | DP | RES | ADM | SUP |
|---|---|---|---|---|---|---|---|---|---|
| `CreateQuote` · `ChangeQuoteState` | ✓ | — | — | — | — | ✓ | — | D | — |
| `CreateInvoiceDraft` · `UpdateInvoiceDraft` | — | — | — | — | — | ✓ | — | D | — |
| `IssueInvoice` · `SendInvoice` · `IssueCreditNote` | — | — | — | — | — | ✓ | — | D | — |
| `RecordInvoiceReminder` · `RecordInvoicePayment` | — | — | — | — | — | ✓ | — | D | — |
| `CreatePurchase` · `ValidatePurchase` | — | — | — | — | — | ✓ | — | D | — |
| `RecordSupplierInvoice` · `RecordPayment` | — | — | — | — | — | ✓ | — | D | — |

⭐ **Un groupe « Comptabilité » n'est pas codé** : les groupes sont des données. L'admin le crée et lui
délègue ces lignes, sans une ligne de code.

## Grille de parité *(24/09)*

| Commande | IA | RH | RR | ÉVAL | STAF | DP | RES | ADM | SUP |
|---|---|---|---|---|---|---|---|---|---|
| `CreateTechnicalFile` · `UpdateTechnicalFile` · `RecordExperience` · `RecordDiploma` | ✓ | ✓ | ✓ | — | ✓ | — | S | D | — |
| `RecordBenefit` | — | ✓ | — | — | — | — | — | D | — |
| `CreateMilestone` · `ChangeMilestoneState` · `AddAdditionalRevenue` | — | — | — | — | — | ✓ | — | D | — |
| `SetConfidential` | ✓ | ✓ | ✓ | — | ✓ | ✓ | — | D | — |

## Réglages du compte *(24/09)*

| Commande | IA | RH | RR | ÉVAL | STAF | DP | RES | ADM | SUP |
|---|---|---|---|---|---|---|---|---|---|
| `SetOwnDashboardWidgets` · `SetOwnListColumns` *(D-103)* | S | S | S | S | S | S | S | S | S |

## Applications — mail, sélection, documents, Outlook, paie *(24/09)*

| Commande | IA | RH | RR | ÉVAL | STAF | DP | RES | ADM | SUP |
|---|---|---|---|---|---|---|---|---|---|
| `SendEmail` · `GenerateDocument` | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | — | D | — |
| `PushCVToContacts` | ✓ | — | — | — | ✓ | ✓ | — | D | — |
| `BulkUpdate` · `BulkArchive` · `ExportSelection` | ✓ | ✓ | ✓ | — | ✓ | ✓ | — | D | — |
| `ParseCV` | ✓ | ✓ | ✓ | — | ✓ | — | — | D | — |
| `SyncOutlookEvent` · `RecordOutlookMail` | S | S | S | S | S | S | S | S | S |
| `PreparePayroll` · `FreezePayroll` · `ExportPayroll` | — | ✓ | — | — | — | — | — | D | — |

⚠️ Sur une sélection, chaque ligne garde **son** périmètre : le ✓ ouvre la commande, pas les lignes.
⚠️ Outlook est « soi » : chacun ne relie que **son** agenda et **ses** mails.

## Lecture — qui voit quoi *(D-46, 29/09)*

⭐ Une route de lecture exige **sa** permission, jugée sur **son** périmètre. Aucune autre permission n'ouvre une
lecture : avoir `SetOwnTheme` en global ne fait rien lire.

| Permission | IA | RH | RR | ÉVAL | STAF | DP | RES | ADM | SUP |
|---|---|---|---|---|---|---|---|---|---|
| `LireSocietes` (sociétés, unités) | ✓ | — | — | — | ✓ | ✓ | — | D | ✓ |
| `LireContacts` | ✓ | — | — | — | ✓ | ✓ | — | D | ✓ |
| `LireCandidats` | ✓ | ✓ | ✓ | ✓ | ✓ | — | S | D | ✓ |
| `LireRessources` (ressources, leurs absences — D-110) | ✓ | ✓ | ✓ | — | ✓ | ✓ | S | D | ✓ |
| `LireBesoins` (besoins, positionnements) | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | — | D | ✓ |
| `LireProjets` (projets, prestations, temps) | ✓ | — | — | — | ✓ | ✓ | S | D | ✓ |

⚠️ `SUP` lit sur son périmètre global et n'écrit rien. `RES` ne voit que **lui-même** (son profil, ses
prestations, ses temps). Les champs sensibles restent sous `LireDonneesRHSensibles`.

⭐ **D-109 (04/10, Q12 du lot 3) — ce que « soi » rend en lecture.** Sous `S`, les objets du compte sont
**exactement** ceux-ci, lus par `compte.personne_id` :

| Permission en `S` | Objets rendus (liste 200 et fiche 200) | Tout autre objet |
|---|---|---|
| `LireRessources` | **sa** ressource (la personne du compte) | fiche 404 · absent des listes |
| `LireCandidats` | **son** profil candidat, s'il en a un | fiche 404 · absent des listes |
| `LireProjets` | **ses** prestations et **ses** temps | fiche 404 · absent des listes |

⛔ Un **projet** n'est pas un objet du compte : `/vues/projets` rend 0 ligne et la fiche projet 404 sous `S`.
Le nom du projet et celui de la société cliente se lisent **comme champs de sa prestation** — jamais la fiche
du projet, qui montre les prestations des autres. La garde de lecture et la porte du juge lisent **la même
déclaration** (objet → colonne qui le relie à `personne_id`), jamais deux listes écrites à part.

⭐ **D-110 (04/10, lot 3) — une lecture se garde par sa permission `Lire*`, jamais par une commande.**
« Mes temps » se lit sous `LireProjets`, « Mes absences » sous `LireRessources` (une absence appartient à sa
ressource). `RecordTimesheet` et `RecordAbsence` décident seulement si le **bouton** est permis (D-71) — avoir
le droit d'écrire ne donne rien à lire (V-150). Le **périmètre** d'une permission se lit en base
(`groupe_permission_perimetre`, ou `S` → `compte.personne_id`), jamais déduit du symbole : `✓` veut dire
« donné au seed, avec le périmètre écrit au seed », pas « global » ; `D` veut dire « rien au seed ».
**Exception unique, écrite** : les écrans d'**administration** (réglages, listes, groupes et comptes — canon
du lot 3 §2.4) ne montrent aucune donnée métier, seulement la configuration ; ils se lisent sous `SetPolicy`,
`ManageRefs`, `ManageGroups`, comme le canon le dit. Toute autre lecture passe par une `Lire*`.

⭐ **D-111 (04/10) — l'agence d'un objet qui n'en a pas.** Prestation, temps, positionnement, absence n'ont pas
d'agence propre : ils prennent celle du **dossier qui les porte**, lue par leurs clés — prestation et temps →
leur **projet** ; positionnement → son **besoin** ; absence → sa **ressource** ; à défaut, la **société**. Le
serveur et le juge appliquent cette chaîne, chacun de son côté, et une porte compare leurs deux résultats objet
par objet : un écart est une fuite ou un refus à tort.

## Transverse et administration

| Commande | IA | RH | RR | ÉVAL | STAF | DP | RES | ADM | SUP |
|---|---|---|---|---|---|---|---|---|---|
| `CreateAction` | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | — | D | — |
| `ArchiveObject` | D | D | — | — | D | D | — | D | — |
| ⛔ `SetPolicy` | — | — | — | — | — | — | — | **✓** | — |
| ⛔ `ManageRefs` | — | — | — | — | — | — | — | **✓** | — |
| ⛔ `ManageGroups` | — | — | — | — | — | — | — | **✓** | — |
| `SetOwnTheme` | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |

⭐ **`SetOwnTheme` est la seule ligne pleine.** Choisir son apparence n'est pas un pouvoir métier — et la politique `ui.theme.choix_utilisateur` peut la fermer pour tout le monde d'un coup.

<interdits>

| ⛔ Jamais | Le problème que ça évite |
|---|---|
| **ADM n'obtient aucun droit métier par sa qualité d'admin** (F14) — tous ses `D` sont des délégations écrites, une par une | l'administrateur qui « corrige » une prestation un vendredi soir |
| **SUP ne mute rien de MÉTIER** (F13) — sa colonne est vide sur 47 lignes sur 48. ⭐ *D-7, 21/09* : la 48e, `SetOwnTheme`, est **son propre** thème — une préférence de lecteur, pas une mutation métier. Il ne touche jamais le thème ni la fiche d'un autre | l'assistance qui répare en cassant, sans trace |
| **Aucune impersonation** — SUP ne devient jamais quelqu'un d'autre | un acte attribué à la mauvaise personne dans le journal |
| Une permission **sans périmètre** | **MUR M-13** — la table de jointure porte les trois colonnes |
| Un `✓` obtenu par **union** de deux lectures | S14 : lire sur B + écrire sur A ≠ écrire sur B |
| Une **surcharge qui ajoute** un droit | F28, P-4 : `compte_surcharge` ne peut qu'enlever |
| Coder un rôle en dur dans un service | c'est la matrice qui répond, jamais un `if role === "dp"` |

</interdits>

<etat>

**Au 18/09/2026**

| | |
|---|---|
| Commandes couvertes | ⛔ **corrigé le 20/09 : 55 commandes distinctes, sur 48 lignes de permission.** Le « 44 » comptait mal — sept lignes en groupent deux (`CreateUnit · UpdateUnit`…). ⭐ Mesuré, pas retenu : voir la commande dans [SPEC_COMMANDES_L4.md](SPEC_COMMANDES_L4.md) |
| Groupes | **9** — plus « Commercial », nom d'affichage d'IA, et « Candidat portail », hors V1 |
| Cases `✓` | attribuées au seed |
| Cases `D` | **rien au seed** : l'admin les ajoute une par une, et ça se voit dans le journal |
| Ce qui reste réglable | `droits.surcharge_restrictive`, `candidat.conversion.acteur`, `droits.support.mutation` — registre §C |
| ⬜ Ce qui n'est **pas** ici | la lecture des objets (BM-45), les champs sensibles onglet par onglet, le portail candidat (hors V1) |

**Le test du lot « Droits »**, une ligne par case non vide : la commande **passe** dans le périmètre, **refuse** hors périmètre, **refuse** sans le groupe. Les `—` ont leur test de refus.

</etat>

<source>

Tranchée par Brain le 18/09/2026 sur la délégation d'Hamada (« c'est toi qui tranches »), à partir de : le catalogue en prose du `CADRAGE_METIER_RECONCILIE` §Matrice (F8–F14), les 40 commandes des machines d'état, les rôles du banc d'essai (référence exécutable, 9 rôles), les simulations **S9, S10, S13, S14, S15** qui fixent cinq refus attendus, et l'arbitrage **O-2** du 17/09 au soir sur le droit de signature.

Ce qui vient du cadrage : les responsabilités de chaque groupe, et les symboles `✓ D S —`.
Ce qui est tranché ici : les 396 cases, qu'aucun document ne portait.

</source>
