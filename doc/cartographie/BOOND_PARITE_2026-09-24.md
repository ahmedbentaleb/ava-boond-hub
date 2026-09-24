# La grille de parité Boond → Ava Manager — 24/09/2026

> **Hamada, 24/09 :** « faire un tour pour voir si on n'a rien oublié, ni réglage, ni colonne, ni
> ligne. Tout doit être pareil, rien ne doit être en dur, tout doit être paramétrable. »

Relevé **à l'écran** le 24/09, en lecture seule : les colonnes de 10 listes (affichées **et**
disponibles), les champs de 8 fiches, le formulaire de contrat RH (capture 93). ⭐ Chaque ligne dit
si Ava Manager l'a déjà (✅), l'a reçu aujourd'hui (➕), ou l'écarte avec un motif (⛔).

<quand_utiliser>

| ✅ On ouvre ce fichier | ⛔ On ne l'ouvre pas pour |
|---|---|
| Vérifier qu'un champ ou une colonne de Boond existe chez nous | les valeurs des listes → `BOOND_REGLAGES_2026-09-23.md` |
| Écrire la reprise champ par champ | les écrans → `BOOND_ECRANS_2026-09-22.md` |

</quand_utiliser>

<etat>

## 0 · La règle qui couvre toutes les listes

⭐ **Chez Boond, chaque utilisateur choisit ses colonnes** (« Configuration des colonnes » : disponibles
à gauche, affichées à droite, dans l'ordre). Chez nous : ✅ réglage par compte, `ui.liste.colonnes`
(famille Apparence). Les colonnes ci-dessous sont donc **toutes** proposées ; le défaut est celui de Boond.

## 1 · Les listes — colonnes

| Liste | Affichées par défaut chez Boond | Disponibles en plus | Chez nous |
|---|---|---|---|
| Candidats | Candidat · Titre · Étape · Nb positionnements actifs · Disponibilité · Coordonnées · MAJ · Responsable manager · CV | Mobilité · Provenance · Responsable RH · Création · Dernière action · Outils · Secteurs · Domaines · Diplômes · Expérience · Expériences professionnelles · Langues · Évaluation globale · Évaluations · Agence | ✅ sauf ➕ **responsable RH**, ➕ **mobilité**, ➕ **diplômes**, ➕ **expériences professionnelles** (§2) |
| Ressources | Ressource · Titre · État · Disponibilité · Tarif HT · Coordonnées · Pos. actif · Responsable manager · CV | Mobilité · Responsable RH · Création · Dernière action · MAJ · Outils · Secteurs · Domaines · Diplômes · Expérience · Expériences pro · Langues · Pôle · Agence | ✅ sauf ➕ **pôle** (§2) |
| Sociétés | Société · Secteur · Informations · État · Coordonnées · Lieu · Responsable manager | Création · MAJ · Agence | ✅ (agence : D-25) |
| Contacts | Contact · Fonction · Type · Société · État · Coordonnées · Lieu · Responsable manager | État de la société · Dernière action · Création · MAJ · Agence | ✅ |
| Besoins | Création · Titre · Client · État · Pos. actifs · Démarrage · **CA pondéré** · Responsable manager | Lieu · Durée · **CA envisagé** · **Budget envisagé** · Fin · Clôture · **Date de réponse** · Domaines · Secteur · Outils · Provenance · Responsable RH · Pôle · Agence · MAJ | ➕ **8 champs de besoin** (§2) |
| Positionnements | MAJ · Profil · Besoin · État · Commentaire · Client · Responsable du besoin | Création · Agence | ✅ |
| Projets | Début · Fin · Référence · Client · CA HT · Rentabilité · Responsable manager | **Marge HT** · Création · MAJ · **Intermédiaire de facturation** | ✅ marge calculée · ➕ **intermédiaire de facturation** (§2) |
| Prestations | Début · Fin · Référence · Projet · Client · CA HT · Rentabilité · Responsable manager | Marge HT · Tarif HT · Création · MAJ · Intermédiaire de facturation | ✅ · ➕ intermédiaire |
| Actions | Date/Début · Catégorie · Type · Référence · Contact · Action · Responsable manager · Pièces jointes | Création · MAJ | ✅ |
| Profils types · Produits | (pas de configuration de colonnes) | — | ⛔ produits hors métier d'Avaliance (0 utilisé) · profils types = `ref_metier` |

## 2 · Les fiches — champs que nous n'avions pas

| Fiche Boond | Champ | Décision |
|---|---|---|
| Candidat, ressource, besoin | **« Visible uniquement de vous »** | ➕ colonne `confidentiel` + politique `confidentialite.autorisee` (**oui** · non) — un objet confidentiel n'est vu que de son responsable et des groupes délégués |
| Candidat, ressource, besoin | **Responsable RH** (en plus du responsable manager) | ➕ `responsable_rh_compte_id` |
| Candidat, ressource, besoin | **Pôle** | ➕ `pole_code` → `ref_pole` (POLE RH, POLE SALES) |
| Candidat, ressource | **Mobilité** | ➕ `mobilite` (liste de zones) → `ref_mobilite` |
| Candidat, ressource (DT) | **Dossier technique** : titre, description, compétences, expérience, formation, diplômes, niveau, langues, domaines, secteurs — **plusieurs DT par personne** | ➕ table `dossier_technique` (+ `dossier_technique_ligne`) |
| Candidat, ressource | **Expériences professionnelles**, **diplômes** | ➕ tables `personne_experience` · `personne_diplome` |
| Ressource (administratif) | **Matricule**, **Fonction** | ➕ `profil_ressource.matricule` (unique par agence) · `fonction` |
| Ressource (administratif) | **Avantages versés** | ➕ table `avantage_verse` (type, montant + devise, période) → `ref_type_avantage` |
| Contrat RH | salaire annuel et mensuel brut · **coefficient de charge** · jours ouvrés annuels · temps de travail · **durée hebdomadaire** · salaire horaire · devise · **calendrier contractuel** · **CJM contrat calculé** · frais journaliers et mensuels | ➕ ces colonnes vont sur **`contrat_rh`**, pas sur le profil : ⭐ le coût d'un salarié **dépend du contrat en cours** (R5) |
| Besoin | **Critères requis** · **Lieu** · **Durée** · **Secteur** · **Budget envisagé** · **Pondération** (probabilité) · **CA envisagé** · CA pondéré (calculé) · **Date de réponse** · Date de clôture | ➕ 9 colonnes de besoin ; le CA pondéré se **calcule** (CA × pondération), jamais stocké |
| Besoin, projet, prestation | **Taux de change de l'agence juridique** | ⛔ **écarté** — T-2 et M-15 : aucune colonne convertie, un montant garde sa devise. Les agrégats sont par devise |
| Projet | **Adresse, code postal, ville, pays** (le lieu de mission) | ➕ colonnes de lieu sur `projet` |
| Projet | **Onglet Lots / Jalons** | ➕ table `jalon` (projet, libellé, date, montant + devise, état) — sert au forfait |
| Projet, prestation | **Intermédiaire de facturation** (une société qui facture à la place du client) | ➕ `intermediaire_facturation_id` (FK société) |
| Prestation | **Jours gratuits** · **calendrier propre** · **CA additionnels** | ➕ `jours_gratuits` · `calendrier_code` · table `ca_additionnel` |
| Positionnement | CA · coût · marge · rentabilité · tarif · jours vendus · taux · **coût journalier moyen** | ➕ colonnes financières **prévisionnelles** sur `positionnement` (Boond les porte avant la mission) |
| Contact | **Domaines · outils** (en plus du périmètre technique) | ➕ `contact_domaine` · `contact_outil` |
| Toutes les fiches | **« Demander à l'IA »** (bouton Boond) | ⛔ hors V1 — c'est le lot 8 (connecteur Claude) |

## 3 · Les listes de valeurs que la grille ajoute

| Liste | Valeurs Boond |
|---|---|
| `ref_critere_evaluation` | relationnelle, technique — ⚠️ **oubliée** le 23/09 |
| `ref_pole` | POLE RH, POLE SALES |
| `ref_mobilite` | à relever sur une fiche remplie (l'admin la remplit) |
| `ref_type_avantage` | à relever (vide chez Avaliance : 0 avantage versé saisi) |

## 4 · Le compte

| | Avant la grille | Après |
|---|---|---|
| Colonnes et champs manquants | — | **≈ 45**, tous ➕ au modèle |
| Tables | ≈ 49 | **≈ 57** (+ dossier technique, ligne de DT, expérience, diplôme, avantage, jalon, CA additionnel, domaine et outil de contact) |
| Référentiels | 66 | **70** |
| Écartés, avec motif | — | 3 (taux de change converti · produits · « Demander à l'IA ») |

</etat>

<source>

Relevé le 24/09/2026 dans `ui.boondmanager.com`, session ouverte par Hamada, en lecture seule. Les
colonnes viennent de la fenêtre « Configuration des colonnes » de chaque liste ; les champs, des
libellés des fiches existantes (besoin 1928, projet 167, ressource du compte) et du formulaire
« Nouveau contrat », ouvert puis quitté sans enregistrer.

</source>
