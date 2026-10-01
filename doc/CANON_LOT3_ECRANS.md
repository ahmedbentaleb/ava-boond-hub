# Canon du lot 3 — les écrans (01/10/2026)

> **Hamada, 01/10 :** « on ne peut pas encore coder les écrans ? » — « commence le canon du lot 3 ».
> Préparé pendant que le lot 2 finit, pour que les écrans partent **avec leur spécification complète**,
> comme le registre exécutable pour les politiques. ⛔ Rien ne se code avant le lot 2 accepté.

<quand_utiliser>

| ✅ On ouvre ce fichier | ⛔ On ne l'ouvre pas pour |
|---|---|
| Savoir ce qu'un écran lit, sous quelle permission, quelles colonnes, quelles commandes il déclenche | le dessin, les couleurs, les thèmes → `THEMES_v1.md`, maquettes de la session Design |
| Écrire une route de lecture du serveur, ou un composant de `web/` | le comportement d'une commande → `SPEC_COMMANDES_L4.md`, `REGISTRE_EXECUTABLE.md` |

</quand_utiliser>

<procedure>

## 0 · Les règles du lot 3 — posées avant la première ligne

| # | Règle | Ce qui la tient |
|---|---|---|
| **D-68** | ⭐ **La page peint ce que le serveur lui envoie, rien d'autre.** Titres, libellés, colonnes, onglets, boutons, états, pastilles, messages de refus : tout vient de la réponse du serveur. `web/` ne contient **aucun** mot métier et **aucune** règle | porte statique : aucun littéral métier dans `web/src` (liste fermée des mots de structure permis) |
| **D-69** | **Trois composants génériques**, pas un écran écrit à la main : la **liste**, la **fiche**, le **formulaire de commande**. Un écran = une **vue** déclarée côté serveur | porte : chaque route `/vues/*` rend un des trois contrats du §1 |
| **D-70** | ⭐ **Le formulaire se génère de la déclaration de la commande** (D-45) : un champ par clé déclarée, son type donne le contrôle (date, décimal, liste de `ref_*`, choix d'un objet). Un champ « référence » est un sélecteur alimenté par la route de lecture de sa table, **filtrée par le périmètre** du compte | porte : champs du formulaire = clés déclarées, une à une |
| **D-71** | **Un bouton visible n'est pas une autorisation**, mais il dit la vérité : chaque action rendue porte `permise` et, sinon, le **refus que la commande rendrait** (code + motif) | porte : une action `permise = false` appelée → **le même** refus ; `permise = true` → jamais `DROIT` |
| **D-72** | **Une lecture exige sa permission** (D-46), jugée sur son périmètre, et rend **seulement** les lignes de ce périmètre. Une fiche hors périmètre → `404`, jamais une fiche vide | porte croisée de lecture : routes × groupes × agences (comme la porte croisée des commandes) |
| **D-73** | **Les colonnes d'une liste sont un réglage par compte** (`ui.liste.colonnes`, parité Boond) : le serveur rend le **catalogue** des colonnes de la liste et celles choisies, dans l'ordre ; le défaut est celui de Boond | porte : chaque colonne du catalogue est triable et filtrable côté serveur, ou déclarée « non triable » |
| **D-74** | **Recherche, filtres, tri et pagination se font au serveur**, jamais dans la page. Page de **50** lignes ; le compte total est rendu | porte : une liste de 500 lignes rend 50 lignes et le total 500 |
| **D-75** | **Un état s'affiche par son libellé (référentiel) et sa pastille par sa catégorie** — jamais par son code, jamais par `ordre` (D-57) | porte : renommer un libellé au référentiel change l'écran sans toucher le code |
| **D-76** | **Une donnée dérivée de l'horloge se lit dans sa vue** (D-53) : l'état d'une ressource, le statut commercial lu, la charge du jour | même vue que les gardes (V-168) |
| **D-77** | **Rien d'un lot non servi n'apparaît** : ni onglet, ni colonne, ni widget d'une commande du lot 5.8. Le serveur ne les rend pas | porte : chaque onglet, colonne, widget rendu a une route ou une commande **servie** |

## 1 · Les trois contrats — la forme exacte des réponses

### 1.1 La vue liste — `GET /vues/<liste>?q=&filtre.<cle>=&tri=&sens=&page=`

| Champ | Contenu |
|---|---|
| `titre` · `compte` | le titre de la liste, le **total** de lignes du périmètre après filtres |
| `catalogue` | toutes les colonnes possibles : `{cle, libelle, triable, filtre: aucun · texte · ref(ref_x) · date · nombre}` |
| `colonnes` | celles du compte (`ui.liste.colonnes`), dans son ordre ; défaut = §2 |
| `lignes` | `{id, href, cellules: [{cle, libelle, sous?, pastille?}]}` — 50 au plus |
| `actions` | les actions de **page** (Créer…) : `{id = commande, libelle, permise, refus?}` |
| `pagination` | `{page, pages, total}` |
| `menu` · `session` · `theme` | comme aujourd'hui (`web/src/contrat.ts`) |

### 1.2 La vue fiche — `GET /vues/<objet>/:id`

`titre` · `etat {libelle, pastille}` · `onglets: [{cle, libelle, contenu: synthese | liste | historique}]` (un onglet
« liste » a le contrat 1.1, borné à l'objet) · `actions` de l'objet avec `permise` / `refus` · `historique` (les
événements datés de l'objet, `evenement_metier`).

### 1.3 Le formulaire de commande — `GET /formulaires/<Commande>?contexte=<id>`

Généré de `DECLARATION` (D-70) : `champs: [{cle, libelle, type, obligatoire, valeurs? (ref), source? (route de
sélection), valeur_initiale?}]`. L'envoi part à `POST /commandes/<Commande>` ; la réponse `ok` · `refus {code,
message}` · `alertes [{code, message}]` est **peinte telle quelle**.

</procedure>

<etat>

## 2 · Les 28 écrans

⭐ 26 écrans de la maquette jouable (`ava-terminal.html`) **+ 2** : la liste des **Positionnements** (parité Boond)
et la **Validation des temps** (D-50).

### 2.1 Les listes — 8

| # | Écran | Route | Lecture | Colonnes par défaut (Boond) | Catalogue en plus | Actions de page |
|---|---|---|---|---|---|---|
| 1 | Sociétés | `/vues/societes` | `LireSocietes` | Société · Secteur · Statut commercial (lu, D-76) · Coordonnées · Ville · Responsable manager | Rôles · Agence responsable · Nb besoins · Nb projets · Création · MAJ | `CreateCompany` |
| 2 | Contacts | `/vues/contacts` | `LireContacts` | Contact · Fonction · Type · Société · Statut · Coordonnées · Ville · Responsable manager | Unité · État de la société · Dernière action · Création · MAJ · Agence | `CreateContact` |
| 3 | Candidats | `/vues/candidats` | `LireCandidats` | Candidat · Titre · Étape · Nb positionnements actifs · Disponibilité · Coordonnées · MAJ · Responsable manager | Mobilité · Provenance · Responsable RH · Pôle · Création · Dernière action · Profil ressource ? · Agence | `CreatePerson` → `CreateCandidate` |
| 4 | Ressources | `/vues/ressources` | `LireRessources` | Ressource · Titre · État (lu, D-76) · Disponibilité · Coordonnées · Positionnement actif · Responsable manager | Type · Société fournisseur · Charge engagée aujourd'hui % · Mobilité · Responsable RH · Pôle · Matricule · Agence · Création · MAJ | `CreatePerson` → `CreateResource` |
| 5 | Besoins | `/vues/besoins` | `LireBesoins` | Création · Titre · Client · État · Priorité · Positionnements actifs · Couverture (« n signés / m » selon l'unité) · Démarrage · Responsable manager | Lieu · Durée · Origine · CA envisagé + devise · Budget envisagé + devise · Pondération · Date de réponse · Clôture · Responsable RH · Pôle · Agence · MAJ | `CreateNeed` |
| 6 | Positionnements | `/vues/positionnements` | `LireBesoins` | MAJ · Profil (candidat ou ressource) · Besoin · État · Commentaire · Client · Responsable du besoin | Création · Agence · Qualification ? · CV partagé ? | — |
| 7 | Projets | `/vues/projets` | `LireProjets` | Début · Fin · Référence · Client · Interlocuteur (contact, unité ou société, R10) · Type · État · Responsable manager | Nb prestations · Intermédiaire de facturation · Lieu · Besoin d'origine · Agence · Création · MAJ | `CreateProject` |
| 8 | Prestations | `/vues/prestations` | `LireProjets` | Début · Fin · Ressource · Projet · Client · État · Taux d'occupation % · TJM + devise · Responsable manager | Jours vendus · Jours saisis · Jours validés · Marge (snapshot, « — » avec son motif) · Jours gratuits · Agence · Création · MAJ | `CreatePrestation` |

⚠️ Aucune colonne de facturation (CA facturé, factures) : lot 5.8 (D-77). Les montants : **une devise par
ligne**, jamais un total qui mélange (M-15).

### 2.2 Les fiches — 7

| # | Écran | Route | Lecture | Onglets | Commandes de l'objet |
|---|---|---|---|---|---|
| 9 | Fiche société | `/vues/societes/:id` | `LireSocietes` | Synthèse (identité, statut lu, rôles, agence responsable) · **Organisation** (arbre des unités, statut de chacune) · Contacts · Besoins · Projets · Actions · Historique | `UpdateCompany` · `RequalifyCompany` · `ArchiveCompany` · `CreateUnit` · `UpdateUnit` · `ArchiveService` · `CreateContact` · `CreateNeed` · `CreateProject` · `CreateAction` · `UploadDocument` |
| 10 | Fiche contact | `/vues/contacts/:id` | `LireContacts` | Synthèse · Besoins · Projets · Actions · Historique | `UpdateContact` · `TransferContact` · `ArchiveContact` · `CreateAction` |
| 11 | Fiche candidat | `/vues/candidats/:id` | `LireCandidats` | Synthèse · Informations · Documents · Positionnements · Qualifications · Actions · Historique — ⛔ **ni Prestations ni Temps** | `UpdateCandidate` · `CompleteCandidate` · `ExitCandidate` · `ReactivateCandidate` · `ConvertCandidateToResource` · `RecordQualification` · `UploadDocument` · `CreateAction` · `PositionCandidate` (choix du besoin) · `ArchiveObject` |
| 12 | Fiche ressource | `/vues/ressources/:id` | `LireRessources` | Synthèse (état lu, exception en cours) · Informations · **Coût de référence** (cadenassé sans `UpdateResourceCost` : l'onglet dit la permission qui manque) · Prestations · Temps · Absences · Documents · Historique | `UpdateResource` · `SetResourceState` · `UpdateResourceCost` · `RecordAbsence` · `UploadDocument` · `CreateAction` · `PositionResource` · `ArchiveObject` |
| 13 | Fiche besoin | `/vues/besoins/:id` | `LireBesoins` | Synthèse (couverture selon l'unité, priorité, démarrage, budget + devise) · Compétences · **Positionnements** (avec leurs actions) · Projets · Actions · Historique | `UpdateNeed` · `SetNeedPriority` · `TakeNeedInCharge` · `DeclareNeedFilled` · `SuspendNeed` · `ResumeNeed` · `CloseNeed` · `ReopenNeed` · `PositionCandidate` · `PositionResource` · `DeclareCVShared` · `RecordClientDecision` · `WithdrawPositioning` · `CreateProjectFromNeed` · `ArchiveObject` |
| 14 | Fiche projet | `/vues/projets/:id` | `LireProjets` | Synthèse (interlocuteur, type, lieu, dates, validation des temps) · **Prestations** (avec Signer, Clôturer, Annuler selon l'état ; marge « — » avec son motif) · Temps · Actions · Historique | `UpdateProject` · `CloseProject` · `CreatePrestation` · `SignPrestation` · `ClosePrestation` · `CancelPrestation` · `ArchiveObject` |
| 15 | Fiche prestation | `/vues/prestations/:id` | `LireProjets` | Synthèse (ressource **verrouillée**, projet, dates, taux) · Conditions économiques (TJM + devise, coût + sa devise, taux de change si saisi, jours vendus — **cadenassées dès la signature**, M-14) · Versions (si `version_datee`) · Temps · Snapshot de marge · Historique | `SignPrestation` · `ClosePrestation` · `CancelPrestation` · `RecordTimesheet` · `AdjustTimesheetAfterClose` |

### 2.3 Le transverse — 6

| # | Écran | Route | Lecture | Contenu | Commandes |
|---|---|---|---|---|---|
| 16 | Tableau de bord | `/vues/tableau-de-bord` | celle de chaque widget | les widgets de `ui.tableau_de_bord.widgets` **servis** au lot 3 : répartition des besoins, répartition des candidats, synthèse, CA de production signé et marge (**une ligne par devise**), mes alertes, mes temps, mes absences. ⛔ « CA facturé » : lot 5.8 (D-77) | `SetOwnDashboardWidgets` · `SetOwnTheme` (le choix du thème est dans la barre du haut, sur **tous** les écrans) |
| 17 | Plan de charge | `/vues/plan-de-charge?mois=&vue=mois·jour` | `LireRessources` | une personne par ligne ; vue **mois** (barre par jour : signé, prévisionnel empilé, au-dessus du seuil, absence, non ouvré) et vue **jour** (PlanProduction : temps saisis et absences) ; seuil = `prestation.surcharge.seuil_pct` | — |
| 18 | Mes temps | `/vues/mes-temps` | soi | mes prestations `engage`, un champ date et quantité (+ facturable sous `saisie_separee`, + motif de dérogation si demandé), l'état de chaque ligne (à valider, validé, rejeté avec son motif). ⭐ **version téléphone** | `RecordTimesheet` · `AdjustTimesheetAfterClose` |
| 19 | **Validation des temps** *(nouveau, D-50)* | `/vues/validation-temps?projet=&periode=` | `LireProjets` | les lignes `a_valider` des projets du périmètre, par ressource et par semaine ; sélection multiple | `ValidateTimesheet` · `RejectTimesheet` |
| 20 | Mes absences | `/vues/mes-absences` | soi | mes absences, type, période, et le formulaire | `RecordAbsence` |
| 21 | Actions | `/vues/actions` | celle de l'objet porteur | le journal : type, date, contenu, **le dossier porteur — un seul** (M-9), le responsable | `CreateAction` |

### 2.4 L'administration — 7

| # | Écran | Route | Lecture | Contenu | Commandes |
|---|---|---|---|---|---|
| 22 | Politiques | `/vues/politiques` | `SetPolicy` | un tableau par famille ; par clé : la valeur, le menu des **valeurs servies** (registre exécutable, D-56), les valeurs non servies **visibles et désactivées** avec leur lot, le défaut, l'effet (une phrase), les commandes affectées | `SetPolicy` |
| 23 | Modèles | `/vues/modeles` | `ManageRefs` | les modèles (action, recherche, liste de tâches, formulaire, e-mail), par portée | `ManageRefs` |
| 24 | Alertes | `/vues/alertes` | `ManageRefs` | les règles d'alerte (`alerte_regle`) : déclencheur, gravité, destinataires | `ManageRefs` |
| 25 | Référentiels | `/vues/referentiels` | `ManageRefs` | par liste : code, libellé modifiable, **catégorie non modifiable**, ordre (affichage seulement, D-57), cadenas « système » | `ManageRefs` |
| 26 | Groupes et droits | `/vues/droits` | `ManageGroups` | la matrice : commandes **et lectures** (D-46) × groupes, ✓ D S — ; le périmètre d'une case ; les surcharges de compte | `ManageGroups` |
| 27 | Comptes | `/vues/comptes` | `ManageGroups` | nom, e-mail, personne liée, groupes, agence, thème, actif | `ManageGroups` |
| 28 | Agences et calendrier | `/vues/agences` | `ManageRefs` | les agences, leur fuseau, et leur calendrier des jours non ouvrés | `ManageRefs` |

## 3 · Ce que le serveur doit ajouter

| Quoi | Combien |
|---|---|
| Routes de vue liste | 8 (+ les listes d'onglets, même contrat, bornées à l'objet) |
| Routes de vue fiche | 7 |
| Routes transverses et administration | 13 |
| `GET /formulaires/<Commande>` | 1 route, générée pour **chacune** des 57 commandes servies |
| Sélecteurs de référence | 1 par table d'objet, filtrés par périmètre (D-70) |
| Le catalogue de colonnes | 1 par liste, avec son tri et son filtre au serveur (D-73, D-74) |

⛔ Chaque route a sa **permission de lecture** (D-46, D-72) ; la porte croisée de lecture la juge comme la
porte croisée des commandes juge les écritures.

## 4 · Les portes du lot 3 — écrites avec la première vue, jamais après

| Porte | Ce qu'elle énumère (tiré du serveur, jamais d'une liste) |
|---|---|
| Lecture croisée | chaque route `/vues/*` × chaque groupe × chaque agence : les lignes rendues ⊂ périmètre ; fiche hors périmètre → 404 |
| Page muette | `web/src` ne contient aucun mot métier ni aucune règle (D-68) |
| Formulaire = déclaration | pour chacune des 57 commandes, les champs du formulaire = les clés déclarées (D-70) |
| Bouton honnête | chaque action rendue `permise = false`, appelée, rend le refus annoncé ; `permise = true` ne rend jamais `DROIT` (D-71) |
| Couverture | chaque commande servie est déclenchable depuis au moins un écran |
| Lot servi | chaque onglet, colonne, widget rendu repose sur une route ou une commande servie (D-77) |
| Libellé au référentiel | renommer un libellé change l'écran ; changer `ordre` ne change aucune règle (D-75) |
| Captures | chaque écran dans les 7 thèmes, et Mes temps en téléphone ; un thème ne déplace rien et ne change aucun mot |

## 5 · Le lot 3 en commandes nouvelles

**Aucune.** Le lot 3 n'ajoute **que des lectures** et des formulaires générés : toutes ses actions sont des
commandes du lot 2 déjà servies et déjà gardées. Ce qui demande une commande nouvelle (export, actions sur une
sélection, envoi de mail…) est au lot 5.8.

</etat>

<source>

Écrit par le BRAIN le 01/10/2026. Les écrans : la maquette jouable `ava-terminal.html` (26) et
`PROMPT_CHATGPT_ECRANS.md` ; les colonnes : `cartographie/BOOND_PARITE_2026-09-24.md` (défaut Boond) ; les
commandes : `SPEC_COMMANDES_L4.md` §I → §V ; les lectures : `MATRICE_DROITS_v1.md` bloc « Lecture » (D-46) ;
le contrat existant : `web/src/contrat.ts`, `server/src/vues.ts`.

</source>
