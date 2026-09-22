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

⚠️ **Cette matrice porte les commandes, pas la lecture.** « Lire CreateCompany » n'est pas une permission cohérente (BM-45). Qui voit quoi se règle par le périmètre, objet par objet.

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
| `RequalifyCompany` | ✓ | — | — | — | — | — | — | D | — |
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
| `DeclareNeedFilled` | — | — | — | — | ✓ | — | — | D | — |
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
| `UpdateProject` | — | — | — | — | D | ✓ | — | D | — |
| `CloseProject` | — | — | — | — | — | ✓ | — | D | — |
| `CreatePrestation` | — | — | — | — | ✓ | ✓ | — | D | — |
| ⛔ **`SignPrestation`** | — | — | — | — | **—** | **✓** | — | D | — |
| `ClosePrestation` | — | — | — | — | D | ✓ | — | D | — |
| `CancelPrestation` | — | — | — | — | ✓ | ✓ | — | D | — |
| `RecordTimesheet` | — | — | — | — | ✓ | ✓ | **S** | D | — |
| `AdjustTimesheetAfterClose` | — | — | — | — | D | ✓ | — | D | — |
| `RecordAbsence` | — | ✓ | — | — | D | D | **S** | D | — |

⚠️ **`SignPrestation` au DP seul, `—` pour le staffing (O-2).** Créer une mission déjà signée, **c'est la signer** : `CreatePrestation` avec l'état initial `engage` exige **en plus** la permission `SignPrestation`. Sans cette règle, le staffing signait par la porte de derrière.

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
