# Annexe — les cases contestables de la matrice des droits

Étage 2 de [MATRICE_DROITS_v1.md](../MATRICE_DROITS_v1.md). **Ne contient aucune règle** : seulement *pourquoi* une case est ce qu'elle est. Pour agir, l'étage 1 suffit.

<source>

Écrit le 18/09/2026, en même temps que la matrice. Chaque motif cite le document qui le fonde, ou se déclare comme un arbitrage de Brain.

</source>

## Les onze cases qui se discutent

| # | Case | Ce qu'elle dit | Pourquoi, et ce qui la conteste |
|---|---|---|---|
| 1 | `CreateCompany` — RH `—` | Sophie ne crée pas de société | **S10 le prouve** : « Sophie tente CreateCompany → refus ; Martin exécute → Delta existe ». Ce n'est pas un choix, c'est une simulation canon. |
| 2 | `ConvertCandidateToResource` — RR `D` | le responsable recrutement ne convertit pas au départ | ⚠️ **Deux textes se croisent.** F9 : Sophie (RH) convertit. Le banc donne la permission à RR. Mais **POL `candidat.conversion.acteur`** vaut `groupe_rh` par défaut : même avec la permission, RR serait refusé. Mettre `✓` créerait un droit que la politique annule — un bouton visible et toujours refusé, exactement ce que DEC-17 veut éviter. Donc `D` : l'admin qui passe la politique à `groupe_rh_ou_rr` donne aussi la permission, d'un même geste. |
| 3 | `ConvertCandidateToResource` — STAF `D` | le staffing ne convertit pas au départ | Le banc le lui donnait ; la politique le refuse pareil. Même raisonnement que la ligne 2. **S2** montre Sophie convertir, pas Karim. |
| 4 | `UpdateResourceCost` — **personne en `✓`** | le coût de référence n'est donné à aucun groupe | Cadrage : « coût de référence **sous permission spécifique** ». Une permission spécifique qui serait dans le paquet de départ n'est plus spécifique. RH et DP en `D` parce que ce sont les deux seuls métiers qui ont une raison d'y toucher. ⚠️ **Conséquence à assumer** : au premier jour, personne ne peut saisir un coût. C'est voulu — c'est un geste d'admin, tracé. |
| 5 | `RecordClientDecision` — IA seul | personne d'autre n'enregistre la réponse du client | Le cadrage donne « retour client » à IA seul. **Arbitrage de Brain** : ne pas l'ouvrir au staffing, même en `D`. Celui qui parle au client est le seul à pouvoir dire ce qu'il a répondu ; sinon le champ devient une supposition. ⚠️ Si Avaliance travaille autrement — un staffing qui rappelle le client directement — c'est une ligne à changer, et elle changera toute la garde F1. |
| 6 | `SignPrestation` — STAF `—`, DP `✓` | signer est un acte de directeur de projet | **O-2**, tranché le 17/09 au soir et vérifié au banc. Et `CreatePrestation` en état `signee` **exige la même permission** — sinon la porte de derrière rouvre. |
| 7 | `ClosePrestation` — STAF `D` | clôturer n'est pas donné au staffing | La clôture **écrit le snapshot de marge**, que rien ne réécrira (**M-6**). Un geste irréversible qui fige un chiffre appartient à celui qui répond des chiffres. `D` parce que Karim cumule les deux groupes de toute façon (F8) : dans les faits il l'aura, mais par son groupe DP. |
| 8 | `RecordTimesheet` — RES `S` | Jean saisit ses temps, pas ceux de Paul | Matrice, colonne « soi-même ». La garde est double : la permission **et** `compte.personne_id`. ⭐ Et même si les deux tombaient, **M-10** refuse la ligne en base. |
| 9 | `AdjustTimesheetAfterClose` — RES `—` | la ressource ne corrige pas après clôture | **Arbitrage de Brain.** F34 autorise l'ajustement tracé ; rien ne dit qui. Après clôture, la marge est figée : un ajustement change le CA courant sans toucher au snapshot. C'est une décision de gestion, pas une saisie. Au DP, donc. |
| 10 | ADM — 39 `D` et 3 `✓` | l'admin n'a aucun pouvoir métier implicite | **F14**, littéralement. Les trois `✓` sont ses vraies commandes : `SetPolicy`, `ManageRefs`, `ManageGroups`. Tout le reste, il se l'attribue explicitement — et ça se voit. |
| 11 | SUP — **44 `—`** | le support ne mute rien, jamais | **F13** : « lecture globale, aucune mutation ». Reste réglable par **POL `droits.support.mutation`** (`assistance_active_deleguee`, **hors V1**). Le jour où cette option s'ouvre, c'est toute cette colonne qui change — d'où la politique plutôt qu'un `D`. |

## Ce que les simulations imposent — cinq refus qu'on ne peut pas changer sans les rouvrir

| Simulation | Ce qu'elle fixe |
|---|---|
| **S9** | Karim, qui a `CreatePrestation`, ne peut pas mettre un candidat dessus. **Refus métier, pas refus de droit** — la distinction est dans le message. |
| **S10** | Sophie (RH) ne crée pas de société ; Martin (IA) oui. |
| **S13** | Même commande, deux agences : autorisée dans A, refusée dans B. |
| **S14** | Lecture sur B + contribution sur A **ne fait pas** contribution sur B. |
| **S15** | Léa (évaluateur) qualifie, et ne convertit pas. |

⭐ **Ces cinq-là sont des tests, pas des opinions.** Le lot 8 les rejoue.

## Ce qu'il faudra ajouter quand le métier aura relu

| | |
|---|---|
| La lecture des **champs sensibles** onglet par onglet — salaire, coût, documents administratifs. Aujourd'hui : « pas aux salaires par défaut » pour l'évaluateur, rien pour les autres |
| Le **portail candidat** — aucune commande définie en V1 (F17/F18) |
| La **validation des temps** — `POL temps.validation` est hors V1 ; si elle s'ouvre, `ValidateTimesheet` est une 45e commande, au DP |
| L'**approbation de recrutement** — `POL recrutement.approbation` hors V1 ; si elle s'ouvre, `ApproveRecruitment` au RR |
