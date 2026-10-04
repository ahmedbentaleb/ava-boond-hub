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
| **D-73** | **Les colonnes d'une liste sont un réglage par compte** (`ui.liste.<liste>.colonnes`, une clé par liste — nom réel en base, écart Design 13) : le serveur rend le **catalogue** des colonnes de la liste et celles choisies, dans l'ordre ; le défaut est celui de Boond | porte : chaque colonne du catalogue est triable et filtrable côté serveur, ou déclarée « non triable » |
| **D-74** | **Recherche, filtres, tri et pagination se font au serveur**, jamais dans la page. Page de **50** lignes ; le compte total est rendu | porte : une liste de 500 lignes rend 50 lignes et le total 500 |
| **D-75** | **Un état s'affiche par son libellé (référentiel) et sa pastille par sa catégorie** — jamais par son code, jamais par `ordre` (D-57) | porte : renommer un libellé au référentiel change l'écran sans toucher le code |
| **D-76** | **Une donnée dérivée de l'horloge se lit dans sa vue** (D-53) : l'état d'une ressource, le statut commercial lu, la charge du jour | même vue que les gardes (V-168) |
| **D-77** | **Rien d'un lot non servi n'apparaît** : ni onglet, ni colonne, ni widget d'une commande du lot 5.8. Le serveur ne les rend pas | porte : chaque onglet, colonne, widget rendu a une route ou une commande **servie** |
| **D-90** | ⭐ **Le cadre est celui du Style Ava validé** (`ava-design/_ops/maquettes/styles.html`, 24-25/09) — on ne le redessine pas : **en haut à droite, le nom et l'agence sous le nom** (le compte connecté, jamais un code) ; **le rail de droite** (`ui.rail.position = droite`, `ui.rail.outils` : alertes, notes, assistant, tâches, indicateurs, calendrier ; `ui.rail.ouvert`) avec son panneau ; **le menu de gauche groupé et repliable** (CRM ▸ Sociétés, Contacts ; Projets ▸ Projets, Prestations…) ; le réglage du thème **dans le rail**, pas dans le bandeau. Le contenu de chaque écran (§2) se peint **dans ce cadre** | porte Captures : chaque écran comparé au cadre du Style Ava (même bandeau, même menu, même rail) |

## 1 · Les trois contrats — la forme exacte des réponses

### 1.1 La vue liste — `GET /vues/<liste>?q=&filtre.<cle>=&tri=&sens=&page=`

| Champ | Contenu |
|---|---|
| `titre` · `compte` | le titre de la liste, le **total** de lignes du périmètre après filtres |
| `catalogue` | toutes les colonnes possibles : `{cle, libelle, triable, filtre: aucun · texte · ref(ref_x) · date · nombre}` |
| `colonnes` | celles du compte (`ui.liste.<liste>.colonnes`), dans son ordre ; défaut = §2 |
| `lignes` | `{id, href, cellules: [{cle, libelle, sous?, pastille?, nature}], actions?}` — 50 au plus ; `nature` ∈ `texte` · `donnee` · `jours` (plan de charge) · `choix` (un menu, écran Politiques) · `matrice` (✓ D S —) ; `actions` d'une ligne : même format que les actions de page (D-80) |
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
| Captures | chaque écran sous **chaque thème servi** (les valeurs servies de `ui.theme`, lues au serveur — pas un nombre fixe), dans le groupe qui s'en sert (STAF, DP, RES, ADM), et Mes temps en téléphone ; un thème ne déplace rien et ne change aucun mot |

## 5 · Le lot 3 en commandes nouvelles

**Deux** : `SetOwnDashboardWidgets` (L4 §IX, lot 5.7 — écart Design 17) et `SetOwnListColumns` (D-103 : le choix des colonnes d'une liste, par compte ; `SetOwnTheme` reste l'apparence seule). Pour le reste, le lot 3 n'ajoute **que des lectures** et des formulaires générés : toutes ses autres actions sont des
commandes du lot 2 déjà servies et déjà gardées. Ce qui demande une commande nouvelle (export, actions sur une
sélection, envoi de mail…) est au lot 5.8.

## 6 bis · Les 4 écarts du 03/10 et le cadre (04/10)

Source : `ava-design/_ops/maquettes/lot3/ECARTS_POUR_BRAIN_2026-10-03.md`, et la comparaison faite par Hamada le
04/10 : les maquettes du lot 3 ne reprenaient pas le Style Ava validé (l'agence à gauche du nom au lieu de dessous,
pas de rail à droite, un menu à titres de section). ⛔ **La faute est au canon** : il renvoyait « le dessin » à la
session Design sans fixer le cadre. Corrigé par **D-90**.

| # | Écart | Tranché |
|---|---|---|
| — | Le cadre | **D-90** : le cadre du Style Ava, tel qu'il a été validé — Design reprend les 28 écrans dedans |
| 1 | `ui.theme` sert une valeur « 27 » | ⛔ donnée fausse : `ui.theme` n'est pas au registre exécutable, **seul son défaut** (`avaliance`) est servi (règle 2). Le BRAIN CODE régénère et vérifie |
| 2 | `SetOwnTheme` ne déclare pas `ui.theme` | ⛔ défaut du lot 2 (D-45) : `SetOwnTheme` déclare **chaque** clé `ui.*` qu'il accepte, typée par ses valeurs servies |
| 3 | `CreatePrestation` déclare ses alias comme des champs (21 pour 13 données) | ⛔ défaut du lot 2 (D-37 : un objet = un nom, plus de synonymes) : un champ par donnée ; le formulaire en a 13 |
| 4 | `ManageRefs` : la catégorie n'a pas de liste de valeurs | la déclaration donne, pour chaque `ref_*`, ses **catégories fermées** comme domaine du champ `categorie` |

### Les 4 écarts du 04/10 — D-90 contre D-77

⭐ **D-91 — le cadre est une forme, pas un contenu.** D-90 fixe la **forme** du Style Ava : où sont le bandeau,
le nom et l'agence, le menu, le rail, et à quoi ils ressemblent. Leur **contenu** (entrées du menu, outils du rail,
thèmes proposés) vient du serveur et obéit à D-77 et à la règle 2 du registre. Quand les deux semblent se
contredire, **la forme vient du Style Ava, le contenu de ce qui est servi**.

| # | Écart | Tranché |
|---|---|---|
| 1 | Le menu montre Profils types, Produits, Achats (hors lot) | ⛔ retirés (D-77) : le menu est rendu par le serveur et ne contient que des écrans servis. Le badge « hors lot » du Style Ava était une démonstration, pas un écran |
| 2 | Le rail propose 29 thèmes et 2 styles, `ui.theme` n'en sert qu'un | le rail garde son réglage de thème, mais ne propose **que les valeurs servies** (aujourd'hui : Avaliance seul) ; les autres arrivent avec le registre du lot 3 |
| 3 | « Voir l'écran comme » ne propose pas l'Administrateur | c'est un outil de la maquette, pas du produit : ajoute ADM, pour les 7 écrans d'administration |
| 4 | Le menu Reporting répète 4 écrans sans lecture servie | ⛔ retiré (D-77) : aucun reporting n'est servi au lot 3 |

### Les questions du codeur du lot 3 (05/10)

| Question | Tranché |
|---|---|
| Q1 — les valeurs `ui.*` servies sont celles du style terminal (sombre, JetBrains), D-90 veut le Style Ava (clair, Lato) | ⭐ **D-96 : l'apparence par défaut d'Avaliance est le Style Ava validé** (thème `ava_avaliance` : clair, Lato, intensité aucune, pastille carré plein, bouton plein, carte sans trait). Le registre §C est corrigé ; le BRAIN CODE aligne les défauts et `politique_valeur_servie` (migration) ; le style terminal reste une valeur de `ref_theme`, servie avec le registre exécutable du lot 3 |
| Q2 — l'identité dans la page | **D-97** : **un seul** module de `web/src` lit le compte (`?compte=` en banc) et l'envoie au serveur ; sans compte, la page peint le refus du serveur. Aucun compte écrit en dur (`Tuyau.tsx` se corrige). C'est ce module, et lui seul, que le lot 2c (connexion Microsoft) remplacera ; hors banc, le serveur continue de tout refuser |

## 6 · Réponses aux 18 écarts de la session Design (03/10)

Source : `ava-design/_ops/maquettes/lot3/ECARTS_POUR_BRAIN.md`. Tous tranchés par le BRAIN.

| # | Écart | Tranché |
|---|---|---|
| 1 | Trois composants ? | **D-79** : trois composants, plus des **natures de cellule** (`jours`, `choix`, `matrice`) et une vue **« page »** qui empile des blocs (liste · formulaire · répartition) — le tableau de bord, le plan de charge. Écrit au §1.1 |
| 2 | Actions d'une ligne d'onglet | **D-80** : `ligne.actions`, même format que les actions de page. Écrit au §1.1 |
| 3 | Sélection multiple (Validation des temps) | ⭐ permise : `ValidateTimesheet` et `RejectTimesheet` prennent **une liste** `temps_ids` (L4 §IV) — c'est leur contrat, pas une action de masse générique (celles-là restent au lot 5.8). ⚠️ Mesuré le 03/10 : la déclaration actuelle prend `prestation_id` + **un** `id` ; au lot 3, elle passe à `temps_ids` (liste, min 1), comme le contrat L4 le dit |
| 4 | Plan de charge, vue jour | ✅ la proposition : une ligne par personne pour un jour — prestation, temps saisi, état, absence |
| 5 | Une capture par groupe ? | oui : chaque écran dans le groupe qui s'en sert (§4, porte Captures) |
| 6 | « D » non délégué | ✅ refusé `DROIT`, avec le motif du serveur : c'est la vérité |
| 7 | Libellé du refus de couverture | ✅ le texte du serveur, mot pour mot (D-71) |
| 8 | Pas de code `PERIMETRE` | ✅ `DROIT` partout ; une **fiche** hors périmètre → 404 (D-72) |
| 9 | La déclaration n'a pas `obligatoire` | **D-81** : la déclaration porte `obligatoire`, `min`, `max`, `defaut` ; la porte « formulaire = déclaration » vérifie aussi qu'une clé obligatoire absente rend `GARDE` |
| 10 | `derogation_motif`, `taux_change` non déclarés | ✅ **déclarés depuis** (mesuré le 03/10 dans `declaration.ts`) : Design a lu une version du 01/10 — les formulaires les montrent |
| 11 | Qui décide la pastille ? | **D-82** : un référentiel `ref_pastille_categorie` (machine, catégorie → pastille), **administrable**, semé avec la proposition de Design ; le serveur rend la pastille, la page la peint |
| 12 | Valeurs non servies « avec leur lot » | le lot s'affiche **quand il est connu** (au registre exécutable de son lot) ; sinon « non servie », sans lot. La maquette est juste |
| 13 | `ui.liste.colonnes` | ✅ nom réel `ui.liste.<liste>.colonnes`. Corrigé au §0 et au §1.1 |
| 14 | Les 7 thèmes | chaque **thème servi** (valeurs servies de `ui.theme`), pas un nombre fixe. Corrigé au §4 |
| 15 | Sélection vide | ⛔ pas une règle de page : la déclaration dit `temps_ids` liste `min 1` (D-81) ; le formulaire le sait par la donnée, et la commande refuse `GARDE` si elle reçoit vide |
| 16 | Commandes d'administration sans déclaration | ✅ **déclarées depuis** (`declaration.ts`, mesuré le 03/10) : les formulaires se génèrent comme les autres |
| 17 | `SetOwnDashboardWidgets` hors des 57 | ✅ c'est une commande **du lot 3** (L4 §IX). Le §5 est corrigé : le lot 3 en ajoute **une** |
| 18 | `/vues/besoins` rend le code brut | ✅ le canon fait foi (D-75) ; le serveur se corrige au lot 3 |

⭐ Les écarts 10 et 16 venaient d'une lecture du 01/10 : le lot 2 les a fermés depuis. Aucun écart ne bloque le onzième audit.

</etat>

<source>

Écrit par le BRAIN le 01/10/2026. Les écrans : la maquette jouable `ava-terminal.html` (26) et
`PROMPT_CHATGPT_ECRANS.md` ; les colonnes : `cartographie/BOOND_PARITE_2026-09-24.md` (défaut Boond) ; les
commandes : `SPEC_COMMANDES_L4.md` §I → §V ; les lectures : `MATRICE_DROITS_v1.md` bloc « Lecture » (D-46) ;
le contrat existant : `web/src/contrat.ts`, `server/src/vues.ts`.

</source>
