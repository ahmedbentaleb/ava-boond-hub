# L4 — le contrat des commandes

**20/09/2026 · 55 commandes.** Pour chacune : ce qui entre, ce qui sort, **quand elle refuse**,
l'événement qu'elle émet, la politique qu'elle lit, le mur qu'elle touche.

⛔⛔ **« 44 » était faux.** La matrice annonçait 44 ; elle porte **48 lignes de permission** et
**55 commandes distinctes** — sept lignes en groupent deux (`CreateUnit · UpdateUnit`…).
⭐ **Mesuré le 20/09, pas retenu.** Un compte qui se retient diverge ; celui-ci se recompte :

```bash
python - <<'EOF'
import re,pathlib
s=pathlib.Path('_ops/MATRICE_DROITS_v1.md').read_text(encoding='utf-8')
i=s.find('# La grille')
c=[x for l in s[i:].splitlines() if re.match(r'^\|\s*[⛔*\s]*`[A-Z]',l)
     for x in re.findall(r'`([A-Z][A-Za-z]+)`', l.split('|')[1])]
print(len(set(c)),'commandes ·',len([l for l in s[i:].splitlines() if re.match(r'^\|\s*[⛔*\s]*`[A-Z]',l)]),'lignes')
EOF
```

---

<quand_utiliser>

| ✅ On ouvre ce fichier | ⛔ On ne l'ouvre pas pour |
|---|---|
| Écrire **une** commande côté serveur | savoir **qui** a le droit → `MATRICE_DROITS_v1.md` |
| Écrire l'**écran** qui l'appelle, **avant** que le serveur existe | savoir **ce que** l'objet est → `MODELE_DONNEES` |
| Écrire le **test de contrat** (porte espèce B) | régler une bifurcation → registre §C |

⭐ **C'est ce fichier qui permet DEUX LOTS EN PARALLÈLE.** L'écran code contre le contrat, le
serveur code le contrat. ⚠️ **Si l'écran n'arrive pas à s'en servir, le contrat est faux** — et
c'est la meilleure relecture qu'on aura.

</quand_utiliser>

---

## La forme d'un contrat — six colonnes, et pas une de plus

| Colonne | Ce qu'elle porte | ⛔ Ce qu'elle ne porte jamais |
|---|---|---|
| **Entrée** | les champs reçus | un champ que l'écran calcule |
| **Sortie** | ce qui revient | une liste que l'écran doit filtrer |
| **Refus** | chaque cas, avec son **code** | un « erreur 500 » |
| **Événement** | le type écrit dans `evenement_metier` | rien — ⛔ **une commande qui mute et n'émet pas est un bug** |
| **Politique** | la clé lue, avec son défaut | un `if` sur un état |
| **Mur** | ce que la base refusera si la garde passe quand même | — |

### Les codes de refus — cinq familles, et elles se lisent

| Code | Quand | L'écran fait |
|---|---|---|
| `DROIT` | la matrice dit non, ou le périmètre ne contient pas l'objet | grise le bouton **avant** le clic |
| `ETAT` | la transition n'existe pas dans la machine | grise, et dit pourquoi |
| `GARDE` | une politique refuse (seuil, unicité, champ requis) | affiche le message **du serveur** |
| `MUR` | ⛔ la base a refusé — **la garde avait un trou** | ⭐ affiche « erreur interne » **et ouvre un bug** |
| `INTROUVABLE` | l'objet n'existe pas, ou est archivé | — |

⭐⭐ **Un refus `MUR` en production est TOUJOURS un bug de commande.** Le mur est le dernier
rempart, pas le premier. ⚠️ Si l'utilisateur le voit, c'est que la garde ne l'a pas vu venir.

### Ce que TOUTE commande fait, sans le répéter 55 fois

**1.** Résout le droit — union des groupes, puis surcharges, puis `POL droits.surcharge_restrictive`
(défaut : **la restriction gagne**), puis le **périmètre** (`MATRICE_DROITS_v1.md` §procedure).
**2.** Refuse **avant toute mutation**.
**3.** Écrit `evenement_metier` **dans la même transaction** que la mutation.
**4.** Porte dans `liens.politiques` **les clés lues et leur valeur au moment de l'exécution**.
⭐ Sans ça, changer un réglage réécrirait le sens de tout l'historique.
**5.** Trace les refus selon `POL historique.tentatives_refusees` (défaut : **à part**).

---

# I · CRM — 11 commandes

| Commande | Entrée | Sortie | Refuse si | Événement | Politique | Mur |
|---|---|---|---|---|---|---|
| `CreateCompany` | nom, secteur, pays, manager | la société | `GARDE` doublon si politique = `bloquer` *(D-6, 21/09 : valeurs `avertir · bloquer · ignorer`, registre)* | `CompanyCreated` | `doublon.societe.*` (défaut **avertir**) | — |
| `UpdateCompany` | id + champs | la société | `INTROUVABLE` si archivée | `CompanyUpdated` | — | — |
| `RequalifyCompany` | id, statut visé | la société | `ETAT` hors cycle | `CompanyStatusChanged` | `societe.retour_prospect` (défaut **manuel**) | — |
| `ArchiveCompany` | id, motif | — | `GARDE` si objets actifs | `CompanyArchived` | `societe.archivage.garde` | **M-8** |
| `CreateUnit` | societe_id, parent_id, type, nom | l'unité | `GARDE` parent d'une autre société · d'une autre **agence** si interne · **cycle** | `UnitCreated` | — | **M-12** |
| `UpdateUnit` | id + champs | l'unité | idem | `UnitUpdated` | — | **M-12** |
| `ArchiveService` | id | — | `GARDE` besoin ou projet actif | `UnitArchived` | `service.archivage.garde` (défaut **aucun actif**) | **M-8** |
| `CreateContact` | societe_id, nom, fonction, type | le contact | `GARDE` unité d'une autre société | `ContactCreated` | `doublon.contact.*` | **M-12** |
| `UpdateContact` | id + champs | le contact | idem | `ContactUpdated` | — | **M-12** |
| `TransferContact` | id, nouvelle société | le contact | `GARDE` objets actifs non réaffectés | `ContactTransferred` | `contact.transfert.objets_actifs` (défaut **réaffectation obligatoire**) | **M-12** |
| `ArchiveContact` | id | — | `GARDE` objets actifs | `ContactArchived` | — | **M-8** |

⚠️ **`CreateUnit` porte trois refus dans un seul trigger** — même société, même agence si interne,
pas de cycle. ⭐ **La garde doit les distinguer** : trois messages, pas un « M-12 ».

---

# II · IDENTITÉ ET RECRUTEMENT — 13 commandes

| Commande | Entrée | Sortie | Refuse si | Événement | Politique | Mur |
|---|---|---|---|---|---|---|
| `CreatePerson` | nom, prénom, coordonnées | la personne | `GARDE` doublon si politique = `bloquer` *(D-6)* | `PersonCreated` | `doublon.personne.*` (défaut **avertir**) | — |
| `CreateCandidate` | personne_id, titre, provenance | le profil | `MUR` si un profil candidat existe déjà | `CandidateCreated` | — | **M-3** |
| `UpdateCandidate` | id + champs | le profil | `INTROUVABLE` si archivé | `CandidateUpdated` | — | — |
| `CompleteCandidate` | id | le profil, état `complete` | `GARDE` **champ requis manquant** — la liste vient de la politique | `CandidateCompleted` | ⭐ `candidat.complete.champs_requis` (**liste de colonnes**) | — |
| `ExitCandidate` | id, motif | le profil | `ETAT` hors cycle · `GARDE` aucun code actif de catégorie `sorti` | `CandidateExited` | — | ⛔ *D-8, 21/09* : la commande **n'écrit jamais** `ref_etat_candidat` — le code `sorti` est au seed (005) |
| `ReactivateCandidate` | id | le profil | `ETAT` hors cycle | `CandidateReactivated` | — | — |
| **`ConvertCandidateToResource`** | profil_candidat_id, type, agence, fournisseur | le profil ressource | voir le bloc **§C-1** | `CandidateConverted` | `candidat.conversion.acteur` · `ressource.externe.societe_fournisseur` | **M-3** |
| `CreateResource` | personne_id, type, titre, agence | le profil | `MUR` si un profil ressource existe · `GARDE` externe sans fournisseur | `ResourceCreated` | `ressource.externe.societe_fournisseur` (défaut **obligatoire**) | **M-3** |
| `UpdateResource` | id + champs | le profil | ⛔ **jamais le coût** — c'est une autre commande | `ResourceUpdated` | — | — |
| `SetResourceState` | id, état visé | le profil | `ETAT` hors cycle | `ResourceStateChanged` | `ressource.etat.mode` (défaut **manuel**) | — |
| ⛔ **`UpdateResourceCost`** | id, coût, devise | le profil | `DROIT` — ⭐ **personne ne l'a au seed** | `ResourceCostChanged` | — | **M-15** (montant + devise) |
| `UploadDocument` | **un seul** porteur, type, fichier | le document | `GARDE` zéro ou deux porteurs | `DocumentUploaded` | — | CHECK **un porteur** |
| `RecordQualification` | personne_id, besoin_id, type, mesures | la séance | `GARDE` besoin absent si politique = oui | `QualificationRecorded` | `qualification.besoin_obligatoire` (défaut **oui**) | — |

⛔⛔ **`UpdateResourceCost` est la seule commande que PERSONNE n'a au départ.** Ni RH, ni DP.
⭐ C'est une délégation écrite une par une, et elle se voit dans le journal.

⭐ **`UpdateResource` ne touche jamais le coût.** Deux commandes, deux permissions — sinon la
permission sensible se contourne par la commande ordinaire.

---

# III · BESOIN ET POSITIONNEMENT — 14 commandes

| Commande | Entrée | Sortie | Refuse si | Événement | Politique | Mur |
|---|---|---|---|---|---|---|
| `CreateNeed` | **societe_id**, agence, titre, type, couverture | le besoin | `GARDE` contact d'une autre société · FTE manquant si couverture le demande | `NeedCreated` | `besoin.contact` (défaut **facultatif**) | **M-11**, **M-12** |
| `UpdateNeed` | id + champs | le besoin | idem | `NeedUpdated` | — | **M-12** |
| `SetNeedPriority` | id, priorité | le besoin | `INTROUVABLE` | `NeedPriorityChanged` | — | — |
| `TakeNeedInCharge` | id | le besoin | `ETAT` hors cycle | `NeedTakenInCharge` | — | — |

⭐ **Événement d'effet (V-064, 22/09)** : quand un `Position*` ou un retenu fait passer le besoin de `a_pourvoir` à `en_recherche`, la transaction émet **`NeedStateChanged`** `{de, vers}` — les états **lus en catégorie**, jamais écrits en dur.

| **`DeclareNeedFilled`** | id | le besoin | voir le bloc **§C-2** | `NeedFilled` | ⭐ `besoin.pourvu.garde_minimale` × `unite_couverture_code` | — |
| `SuspendNeed` | id, **motif** | le besoin | `ETAT` hors cycle | `NeedSuspended` | — | ⭐ le motif va dans l'**événement** |
| `ResumeNeed` | id | le besoin | `ETAT` hors cycle | `NeedResumed` | — | — |
| `CloseNeed` | id, motif | le besoin | `ETAT` hors cycle | `NeedClosed` | — | — |
| `ReopenNeed` | id | le besoin | `ETAT` hors cycle | `NeedReopened` | — | — |
| `PositionCandidate` | besoin_id, profil_candidat_id | le positionnement | `GARDE` unicité selon la politique | `CandidatePositioned` | ⭐ `positionnement.unicite` (défaut **actifs**) | **M-2** |
| `PositionResource` | besoin_id, profil_ressource_id | le positionnement | idem | `ResourcePositioned` | idem | **M-2** |
| `DeclareCVShared` | positionnement_id, date | le positionnement, état `presente` | `ETAT` hors cycle | `CVShared` | — | ⭐ étape **système** `cv_partage` |
| **`RecordClientDecision`** | positionnement_id, décision, date, **motif si négatif** | le positionnement | `DROIT` — ⭐ **IA seul** · `ETAT` hors cycle | `ClientDecisionRecorded` | — | ⭐ le motif va dans l'**événement** |
| `WithdrawPositioning` | id, **motif** (`ref_motif_retrait`) | le positionnement | `ETAT` hors cycle | `PositioningWithdrawn` | — | ⭐ **P-5** : jamais en colonne |

⛔ **`RecordClientDecision` n'appartient qu'à IA.** C'est lui qui parle au client. ⭐ C'est ce qui
empêche un staffing pressé de **supposer** un accord.

⭐⭐ **Les motifs vont TOUS dans `evenement_metier.motif`, jamais en colonne de l'objet** (P-5).
Une seule place, et les codes admis restent dans `ref_motif_retrait`.

---

# IV · PROJET, PRESTATION, PRODUCTION — 11 commandes

| Commande | Entrée | Sortie | Refuse si | Événement | Politique | Mur |
|---|---|---|---|---|---|---|
| `CreateProject` | societe_id, agence, type, titre | le projet | `GARDE` contact requis si politique = obligatoire | `ProjectCreated` | `projet.contact` (défaut **obligatoire**) | **M-12** |
| `CreateProjectFromNeed` | besoin_id + champs | le projet, `besoin_id` rempli | idem, + `ETAT` si le besoin est fermé | `ProjectCreatedFromNeed` | `projet.depuis_besoin.garde_profil` | **M-12** |
| `UpdateProject` | id + champs | le projet | `GARDE` contacts d'une autre société | `ProjectUpdated` | — | **M-12** |
| `CloseProject` | id | le projet | `ETAT` hors cycle | `ProjectClosed` | — | — |
| `CreatePrestation` | projet_id, ressource, dates, TJM, CJM, devises, taux | la prestation | voir le bloc **§C-3** | `PrestationCreated` *(+ `PrestationSigned` si `engage`)* | `projet.devises_mixtes` (défaut **autorise**) · `prestation.surcharge.*` | **M-1**, **M-4**, **M-15** |
| ⛔ **`SignPrestation`** | id, date de signature | la prestation `engage` | voir le bloc **§C-3** | `PrestationSigned` **+** `ClientStatusDerived` | `societe.passage_client.*` · `prestation.avenant.mode` | **M-14** dès cet instant |
| `ClosePrestation` | id, date | la prestation `clos` | `ETAT` hors cycle | `PrestationClosed` | — | ⭐ **écrit `snapshot_marge` dans la MÊME transaction** · **M-6** |
| `CancelPrestation` | id, motif | la prestation `annule` | `ETAT` hors cycle | `PrestationCancelled` | — | — |
| `RecordTimesheet` | prestation_id, jour, quantité *(+ facturable)* | la ligne | voir le bloc **§C-4** | `TimesheetRecorded` | `temps.periode` · `temps.plafond_jour` (défaut **alerte**) · `temps.facturable.mode` · `temps.validation` | **M-1**, **M-10** |
| `AdjustTimesheetAfterClose` | prestation_id, jour, quantité, motif | la ligne, `ajustement = true` | `GARDE` si politique = `refus` | `TimesheetAdjusted` | `temps.correction_apres_cloture` (défaut **ajustement tracé**) | ⛔⛔ **M-6 : le snapshot ne bouge PAS** |
| `RecordAbsence` | ressource_id, type, dates, quantité/jour | l'absence | `GARDE` chevauchement selon la politique | `AbsenceRecorded` | `absence.chevauchement` | — |

⛔⛔ **`AdjustTimesheetAfterClose` est la commande la plus dangereuse du lot.** Elle corrige un
temps **après** la clôture. ⭐ **Le snapshot de marge ne bouge pas** — M-6, et le rôle SQL n'a
même pas l'`UPDATE`. ⚠️ **Un chiffre montré à un client ne se recalcule pas six mois plus tard.**

---

# V · TRANSVERSE ET ADMINISTRATION — 6 commandes

| Commande | Entrée | Sortie | Refuse si | Événement | Politique | Mur |
|---|---|---|---|---|---|---|
| `CreateAction` | **un seul** porteur, type, date, contenu | l'action | `GARDE` zéro ou deux porteurs | `ActionCreated` | — | **M-9** |
| `ArchiveObject` | type, id, motif | — | `GARDE` selon l'objet | `ObjectArchived` | — | **M-8** — ⛔ jamais de `DELETE` |
| ⛔ **`SetPolicy`** | clé, valeur | la politique | `DROIT` **ADM seul** · `GARDE` valeur hors `valeurs_possibles` | `PolicyChanged` | — | `mur_touche` est **indicatif** : il s'affiche, il ne garde rien *(D-3, 21/09)* |
| ⛔ `ManageRefs` | référentiel, code, libellé, catégorie | la valeur | `GARDE` catégorie inconnue · valeur **système** · valeur **utilisée** | `RefChanged` | — | CHECK **catégorie** |
| ⛔ `ManageGroups` | groupe, permission, **périmètre** | la paire | `GARDE` permission sans périmètre | `GroupPermissionChanged` | — | ⭐ **M-13** |
| `SetOwnTheme` | les réglages d'apparence | `compte.theme_json` | `GARDE` si `ui.theme.choix_utilisateur` = non | `ThemeChanged` | `ui.theme.choix_utilisateur` | — |

⭐ **`SetOwnTheme` est la seule commande que les neuf groupes ont.** Choisir son apparence n'est
pas un pouvoir métier — et **une politique la ferme pour tout le monde d'un coup**.

⛔ **`ManageRefs` ne peut pas inventer une catégorie.** L'admin ajoute une valeur **dans** une
catégorie existante, renomme un libellé, réordonne, désactive. ⭐ **C'est ce qui permet aux 14
états Boond d'entrer sans migration** — et c'est aussi ce que Boond, lui, ne sait pas faire.

---

# VI · LES CINQ COMMANDES QUI MÉRITENT UN BLOC

## §C-1 · `ConvertCandidateToResource` — la garde G1

```
ENTRÉE    profil_candidat_id · type_code · agence_id · [societe_fournisseur_id]
SORTIE    le profil_ressource créé · la personne INCHANGÉE
```

| Refus | Code |
|---|---|
| La personne a déjà un profil ressource | `MUR` **M-3** |
| Le candidat n'a **aucun** positionnement de catégorie `terminal_positif` | `GARDE` |
| `type_code = EXTERNAL` sans fournisseur, et la politique l'exige | `GARDE` |
| Le groupe n'est pas celui que `candidat.conversion.acteur` désigne | `DROIT` |

⭐⭐ **L'identité NE SE COPIE PAS.** On crée un `profil_ressource` sur la **même** `personne`.
⛔ Deux fiches pour un humain, c'est le doublon qu'on passe trois ans à réconcilier.

⭐ **La garde se lit en une jointure** grâce à `positionnement.personne_id` dénormalisé — sans
lui, il faudrait savoir si le positionnement était candidat ou ressource.

## §C-2 · `DeclareNeedFilled` — trois gardes selon la couverture

```
PÉRIMÈTRE   E = prestation WHERE etat_categorie='engage'
              AND projet_id IN (SELECT id FROM projet WHERE besoin_id = :id)
```

| `unite_couverture_code` | La garde exige |
|---|---|
| **`postes`** ⭐ *défaut Avaliance* | `count(E) >= nb_postes_vises` |
| `fte` | `sum(E.taux_occupation_pct)/100 >= fte_vise` |
| `postes_et_fte` | **les deux à la fois** |

⛔⛔ **Le trou que ça bouche** : « deux missions = deux postes » est **faux**. Deux personnes à
50 % font **une** charge pleine et **deux** postes occupés. ⚠️ Sous `postes` seul, un besoin de
2 postes se déclarait pourvu avec deux mi-temps, **et rien ne le signalait**.

⭐ La vue `v_besoin_couverture` rend les trois calculs lisibles en une ligne.

## §C-3 · `CreatePrestation` et `SignPrestation` — la porte de derrière

⛔⛔ **`CreatePrestation` avec un état initial `signee` EST une signature.** Elle exige **en
plus** la permission `SignPrestation`, et déclenche **les mêmes effets**.

| Effet, dans les deux cas | |
|---|---|
| `PrestationSigned` | émis |
| `ClientStatusDerived` | la société passe `client`, selon `societe.passage_client.propagation` |
| Pourvu automatique | selon `besoin.pourvu.garde_minimale` |
| ⭐ **`prestation_version` version 1** | écrite **si** `prestation.avenant.mode = version_datee` |
| ⛔ **M-14 s'arme** | TJM, CJM, devises, jours, frais deviennent **immuables** |

⭐ **Le résultat et le droit ne dépendent pas de la porte d'entrée** (G8). ⚠️ Sans cette règle,
le staffing signait sans en avoir le droit, par la commande de création.

⛔ **La ressource est immuable dès l'INSERT** (M-4). Se tromper de personne se corrige en
annulant et en recréant — pas en changeant la colonne.

## §C-4 · `RecordTimesheet` — quatre politiques, un mur

| Refus | Politique / mur |
|---|---|
| Le jour est hors des dates de la prestation | `temps.periode` (défaut : **dans les dates**) |
| La personne n'est pas celle de la prestation | ⛔ **M-10**, trigger |
| ⛔ Le porteur est un **candidat** | **M-1** — il n'y a pas de colonne, c'est **impossible** |
| Le total du jour dépasse la capacité | `temps.plafond_jour` (défaut **alerte**, jamais refus) |
| Le facturable est absent alors qu'il est exigé | `temps.facturable.mode` |
| Ce n'est pas soi-même, et le groupe est RES | `DROIT` — le **`S`** de la matrice |

⭐ **Annuler une saisie = l'ARCHIVER**, jamais une quantité négative. ⚠️ Une contre-passation est
une ligne qu'on relit mal six mois plus tard.

⛔ **Pas d'unicité `(prestation, jour)`** : deux lignes le même jour sont **deux faits**.

## §C-5 · `SetPolicy` — la commande qui change les autres

```
ENTRÉE    cle · valeur
SORTIE    la politique · ⭐ et la LISTE des commandes dont le comportement change
```

| Refus | Code |
|---|---|
| Le groupe n'est pas ADM | `DROIT` |
| La valeur n'est pas dans `valeurs_possibles` | `GARDE` |
| ~~La valeur franchirait le mur de `mur_touche`~~ | ⛔ **Retiré le 21/09 (D-3, V-029).** `mur_touche` est **indicatif pour l'écran, jamais pour la garde** (SPEC_SQL §3) : un mur est dans la base, pas dans une politique. L'écran d'administration **affiche** le mur voisin ; aucune garde ne le lit |

⭐⭐ **La sortie liste ce qui change.** Un admin qui bascule `droits.surcharge_restrictive` vers
`union_gagne` doit **voir** qu'il affaiblit toutes les restrictions nominatives d'un coup.
⚠️ C'est la politique signalée **en rouge** dans l'écran d'administration.

⛔ **`PolicyChanged` porte l'ancienne et la nouvelle valeur.** Sans ça, on ne saurait jamais
sous quel réglage un fait passé s'est produit.

---

<interdits>

| ⛔ Jamais | Le problème que ça évite |
|---|---|
| Une commande qui **mute sans émettre** d'événement | un fait sans trace ; l'historique ment par omission |
| Un `if` sur un **rôle** dans un service | c'est la matrice qui répond, pas `if role === "dp"` |
| Un `if` sur un **état** sans clé de politique | ADR-005 — la bifurcation d'une autre société |
| Émettre l'événement **hors** de la transaction | un fait tracé qui n'a pas eu lieu, ou l'inverse |
| Un refus `MUR` visible par l'utilisateur | ⭐ **c'est un bug de garde**, toujours |
| Renvoyer une liste que l'écran doit **filtrer** | le filtre finirait dans `/web`, et ce serait une règle métier |
| Mettre un **motif** en colonne de l'objet | **P-5** — les motifs vivent dans l'événement |
| Faire porter un temps par un candidat | **M-1** — et il n'y a même pas de colonne |

</interdits>

---

<etat>

**20/09/2026 — contrat écrit, aucune commande codée.**

| | |
|---|---|
| Commandes contractées | **55** · 6 familles |
| Blocs détaillés | **5** — les seules qui ne tiennent pas en une ligne |
| ⛔ Écart signalé | la matrice annonce **44**, elle porte **48 lignes** et **55 commandes** |
| ⬜ Ce qui manque encore | le **schéma JSON** de chaque entrée et sortie — à écrire avec le lot 2, pas avant |

⭐ **Ce fichier débloque DEUX LOTS EN PARALLÈLE** : `/server` code le contrat, `/web` code
contre lui, avec un serveur bouchonné qui rend les sorties figées.

⚠️ **La porte du lot 2** : chaque commande a **une porte de contrat** (espèce B) — sa réponse
figée pour un cas donné. Un champ qui disparaît fait tomber la porte.

</etat>

---

<source>

Tiré de : `MATRICE_DROITS_v1.md` (les 48 lignes, les 9 groupes) · `MACHINES_ETAT_V1.md` (les
transitions) · `MODELE_DONNEES_AVAMANAGER_V1.md` (les tables et les 15 murs) ·
`REGISTRE_POLITIQUES_v1.md` §C (les clés) · `SPEC_SQL_AVAMANAGER_V1.sql` (ce que la base refuse).

⭐ **Ce qui est tranché ici, et que personne n'avait écrit** : les codes de refus, l'ordre des
gardes, et **quelle commande émet quel événement**.

⚠️ **Ce qui n'est pas ici** : les schémas JSON. ⭐ Les écrire maintenant, c'est les écrire deux
fois — le lot 2 les produira, et la porte de contrat les figera.

</source>
