# Boond — les applications, installées et disponibles (24/09/2026)

> **Hamada, 24/09 :** « tout en V1 · relève les 9 applications · regarde toutes les applications de
> Boond, ce qu'elles font et qui les fait. »

Relevé à l'écran dans l'instance Avaliance (les 9 installées, ouvertes une par une, lecture seule) et
sur la page publique des intégrations de Boond (les 31 partenaires). Sources en fin de fichier.

<quand_utiliser>

| ✅ On ouvre ce fichier | ⛔ On ne l'ouvre pas pour |
|---|---|
| Savoir ce que chaque application fait chez Avaliance, et ce que la V1 doit reprendre | les écrans du cœur de Boond → `BOOND_ECRANS_2026-09-22.md` |
| Décider ce qui se code chez nous et ce qui reste un partenaire externe | les réglages → `BOOND_REGLAGES_2026-09-23.md` |

</quand_utiliser>

<etat>

## 1 · Les 9 applications installées chez Avaliance — toutes faites par Boond

| Application | Ce qu'elle fait, vu à l'écran | Utilisée ? | En V1 chez nous |
|---|---|---|---|
| **Emailing** | ⭐ envoi de messages et **push de CV** à des contacts depuis une sélection ; **3 modèles** (envoi de facture, relance de validation des temps, envoi de devis) ; une **signature** avec variables (prénom, nom, fonction) ; boîte **Office 365 synchronisée** — les mails partent du vrai compte de l'utilisateur | ✅ oui | ✅ **oui** : actions sur une sélection, envoi groupé, push de CV avec action créée, modèles, signature, envoi par le compte Microsoft de l'utilisateur |
| **DocTemplates** | génère des documents **Word/PDF depuis des modèles** : dossiers techniques, contrats RH et de sous-traitance, factures, avoirs, devis, achats, commandes, prestations, **ordres de mission**, besoins, données administratives | ✅ | ✅ **oui** : la table `modele` s'étend à ces 12 familles de documents |
| **ExtractPayroll** | **préparation de la paie** du mois : par contrat, jours de production, internes, absences, salaire, **avantages versés**, notes de frais, état des temps et des frais | ✅ (6 contrats) | ✅ **oui** : un écran « préparation de la paie » + export, lu sur `contrat_rh`, `temps`, `absence`, `avantage_verse` |
| **HRFlow** | **lecture automatique d'un CV** (PDF, Word, image) pour créer la fiche candidat | ✅ | ✅ **oui** : « pré-remplir depuis un CV » à la création d'un candidat — le moteur de lecture est un **réglage** (`cv.lecteur` : aucun · hrflow · autre) |
| **Microsoft** | agenda **Outlook** lu et écrit depuis Boond ; synchronisation des événements avec les **actions** ; recherche et enregistrement des mails Outlook dans Boond (gadget « Boond for Outlook ») | ✅ | ✅ **oui** : une action ↔ un événement Outlook, un mail Outlook ↔ une action ; branché sur le compte Microsoft de la connexion (R4) |
| **PlanProduction** | calendrier graphique jour par jour des **temps saisis et des demandes d'absence**, par ressource (263) | ⚠️ vide (temps fermés) | ✅ **oui** : c'est notre plan de charge en vue **jour**, en plus de la vue mois |
| **PostProduction** | **facturation du CA de production** et des **échéanciers** : par projet, commande, production, CA de production ou d'échéances, CA facturé, état des temps | ⚠️ 0 projet | ✅ **oui** : l'écran d'entrée du lot facturation — ce qui est produit face à ce qui est facturé |
| **Célébrations** | anniversaires, **anciennetés** et arrivées de la semaine | ⚠️ vide | ✅ **oui** : un widget du tableau de bord (`ui.tableau_de_bord.widgets` + `celebrations`) |
| **Viewer** | visionneuse de documents intégrée | ✅ | ✅ **oui** : aperçu des pièces jointes dans l'écran, sans téléchargement |

## 2 · Les 31 partenaires de la place de marché — tous faits par des tiers

⛔ Aucun n'est installé chez Avaliance. Ce sont des **produits d'autres éditeurs** qui se branchent sur
Boond par son API. Chez nous, ils relèvent du **connecteur** (lot 8, et l'API du serveur), pas du code.

| Famille | Partenaires |
|---|---|
| Sourcing, diffusion d'offres | Turnover-IT · Broadbean (Veritone) · RSight · Collective · Pylote · Jean-Michel.io |
| Évaluation, compétences, IA | IRIS · Trimoji · Clustor · Betterfolio · Showcase · Neylia |
| Réunions, téléphonie | Leexi · Noota · Flunter · Ringover · SipSim |
| RH, onboarding, formation | Legipilot · Yuno · Wobee · Zola · LearnPilot · Day One · Rzilient |
| Paie, portage, finance | Payfit · Linc · Karburan Pro · Fygr · Powens |
| Données, signature | Peeramid (Power BI) · Signaturit (signature électronique) |

## 3 · Ce que ça ajoute au canon

| Où | Ajout |
|---|---|
| Commandes (§XI du contrat L4) | `SendEmail` · `PushCVToContacts` · `BulkUpdate` · `BulkArchive` · `ExportSelection` · `GenerateDocument` · `ParseCV` · `SyncOutlookEvent` · `RecordOutlookMail` · `PreparePayroll` — **10**, compte **96** |
| Tables (§13.6 du modèle) | `envoi_email` · `envoi_email_destinataire` · `document_genere` · `lien_outlook` · `preparation_paie` · `preparation_paie_ligne` — **6**, compte **≈ 63** |
| Politiques (§C.ter du registre) | `email.fournisseur` · `email.push_cv.action_auto` · `email.envoi_groupe.max` · `cv.lecteur` · `outlook.synchro` · `paie.export.format` · `celebrations.types` — **7**, compte **201** |
| Référentiels | `ref_famille_document` (les 12 familles de DocTemplates) — compte **71** ; `ref_type_modele` reçoit `document` et `signature` (valeurs, pas de liste nouvelle) |
| Widgets | `celebrations` rejoint les widgets proposés de `ui.tableau_de_bord.widgets` |
| Signature | ⭐ pas une politique : un `modele` de type `signature`, portée **personnelle**, avec ses variables |
| Partenaires | ⛔ aucun code : l'API du serveur et le connecteur (lot 8) les rendront branchables |

</etat>

<source>

Relevé le 24/09/2026 : `ui.boondmanager.com/apps` et les pages `apps/1002` → `apps/1844`, ouvertes
une à une, sans rien régler. Partenaires : page publique
[boondmanager.com/en/integrations](https://www.boondmanager.com/en/integrations) et
[boondmanager.com/marketplace](https://www.boondmanager.com/marketplace), lues le même jour.

</source>
