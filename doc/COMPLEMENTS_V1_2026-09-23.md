# Ce que la V1 doit porter en plus — décidé le 23/09/2026

> **Hamada, 23/09 :** « on fait tout en V1, il faut compléter tout, ne rien oublier. »

⭐ Le relevé complet des réglages de Boond (`cartographie/BOOND_REGLAGES_2026-09-23.md`) a montré
ce que notre canon n'avait pas. **Tout est repris en V1.** Ce fichier dit quoi ajouter, et où.

<quand_utiliser>

| ✅ On ouvre ce fichier | ⛔ On ne l'ouvre pas pour |
|---|---|
| Savoir ce qui reste à ajouter au canon et au code après la décision du 23/09 | les valeurs elles-mêmes → le relevé des réglages |
| Écrire la migration des nouveaux référentiels et des nouvelles tables | l'état des lots → `ETAT_PROJET.md` |

</quand_utiliser>

<etat>

## 1 · Les référentiels — ✅ inscrits au registre

**+24 listes**, portant le total à **64**. Écrites au registre §B le 23/09.
⬜ Reste : la migration qui les crée et les sème (BRAIN CODE), puis les commandes qui les lisent.

| Famille | Listes ajoutées |
|---|---|
| Compétences et profils | `ref_secteur` (30 valeurs) · `ref_metier` (13) · `ref_certification` · `ref_niveau_experience` · `ref_niveau_formation` · `ref_langue` · `ref_niveau_langue` · `ref_disponibilite_candidat` |
| RH | `ref_type_contrat` · `ref_categorie_contrat` · `ref_classification_contrat` (**21 positions Syntec**) · `ref_temps_travail` · `ref_situation_familiale` · `ref_type_document_suivi` |
| Exploitation | `ref_calendrier` · `ref_categorie_achat` · `ref_type_message` (19 modèles) |
| Facturation | `ref_taux_tva` · `ref_condition_reglement` · `ref_mode_reglement` · `ref_mode_envoi_facture` · `ref_etat_facture` · `ref_etat_facture_fournisseur` · `ref_etat_devis` |

## 2 · Les tables et colonnes à ajouter — ⬜ à écrire au modèle de données

| Objet | Ce qu'il porte | Pourquoi |
|---|---|---|
| **`contrat_rh`** (nouvelle table) | personne, type, catégorie, classification Syntec, temps de travail, dates, motif de fin, renouvellements | Boond le porte ; nos `periode_emploi` n'ont que les dates. C'est aussi la base des alertes « sans contrat », « période d'essai », « dates qui se chevauchent » |
| **`document_suivi`** (nouvelle table) | personne ou ressource, type, date d'expiration, pièce jointe | l'alerte « document arrivant à expiration dans moins de 60 jours » |
| **`devis`**, **`facture`**, **`facture_fournisseur`**, **`echeance`** | client, projet, lignes, TVA, conditions et mode de règlement, mode d'envoi, état, relances | la facturation entre en V1 |
| `personne` (+ colonnes) | situation familiale, langues et niveaux, formations, certifications, disponibilité candidat | relevés chez Boond, absents chez nous |
| `societe` (+ colonne) | `secteur_code` | 30 secteurs administrables |
| `agence` (+ colonnes) | `calendrier_code`, `jours_ouvres_annuel`, `coefficient_charge` | les 5 agences de Boond les portent déjà |
| `modele` (+ portée) | modèles de **texte de mission** (règlement intérieur, absences, temps de travail) et les **19 modèles de message** | Boond les a ; ils servent aux documents et aux notifications |

## 3 · Les politiques à ajouter — ⬜ à écrire au registre §C

| Clé proposée | Valeurs | Ce qu'elle règle |
|---|---|---|
| `facturation.tva_defaut` | un code de `ref_taux_tva` | le taux proposé à la création d'une facture |
| `facturation.condition_reglement_defaut` | un code de `ref_condition_reglement` | l'échéance proposée |
| `facturation.mode_envoi_defaut` | un code de `ref_mode_envoi_facture` | email · courrier · Chorus |
| `facturation.relance.jours` | liste de jours (ex. 7 · 15 · 30) | quand relancer une facture impayée |
| `rh.contrat.obligatoire_avant_prestation` | **non** · oui | Boond alerte « prestation non couverte par un contrat RH » |
| `rh.document.alerte_jours` | 60 | le seuil de l'alerte d'expiration |
| `temps.signature.demandee` | **non** · oui | Boond envoie une demande de signature de la feuille de temps |

## 4 · Ce que ça change sur le calendrier

| | Avant le 23/09 | Après la décision |
|---|---|---|
| Référentiels | 40 | **64** |
| Tables | 37 | **≈ 44** (contrat RH, document suivi, devis, facture, facture fournisseur, échéance) |
| Périmètre V1 | facturation et achats **hors V1** | ⭐ **tout en V1** |
| Temps machine restant | 17 – 29 h | ⚠️ **+8 à 14 h** : un lot « RH et facturation » s'ajoute après les écrans |

⛔ **Ce qui ne change pas** : les 15 murs, la règle « rien en dur », et l'ordre des lots. La
facturation vient **après** que le cœur (besoin → mission → temps → marge) soit accepté.

## 5 · L'ordre d'exécution

| # | Quoi | Qui |
|---|---|---|
| 1 | ✅ Les 24 référentiels au registre | BRAIN, fait |
| 2 | ⬜ Le modèle de données : les 6 tables et les colonnes du §2 | BRAIN |
| 3 | ⬜ Les 7 politiques du §3 au registre §C | BRAIN |
| 4 | ⬜ Migration 010 : les 24 référentiels, leurs valeurs, les nouvelles tables | BRAIN CODE, **après** le lot 2 accepté |
| 5 | ⬜ Les commandes RH et facturation, et leurs écrans | CODE, nouveau lot |

</etat>

<source>

Décision d'Hamada le 23/09/2026, après le relevé complet des réglages de Boond. Les valeurs et les
comptes viennent de `cartographie/BOOND_REGLAGES_2026-09-23.md`, lu à l'écran le même jour.

</source>
