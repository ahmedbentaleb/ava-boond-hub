# Fonctionnement Boond Manager

Produit, pas un tenant. Aucune fiche personne. Lu dans l’UI : boutons **Créer**, onglets de fiche, types d’action par objet, référentiels admin.

Boond n’est pas une suite de listes. C’est **un graphe d’objets** + **cinq métiers** qui le traversent.

---

## Le graphe (ce qui est lié à quoi)

```
Société ── Contact
    │
    └── Besoin ── Positionnement ── Candidat
    │                  │
    │                  └── Ressource ── Prestation ── Projet
    │                                      │              │
    │                                      └── Temps      └── Achat
    │
    └── Projet (peut naître du Besoin)

Action se pose sur : Candidat | Ressource | Contact | Besoin | Projet
                     (+ commande | facture si le module est ouvert)

Compte Manager ── liée à une Ressource
Rôle ── Manager
Agence / Pôle ── Besoin, Projet, Ressource, Manager
```

| Objet | C’est quoi | Porte | Naît depuis |
|---|---|---|---|
| **Société** | Client ou prospect | Contacts, besoins, projets, achats (fournisseur) | Liste CRM |
| **Contact** | Personne chez la société | Actions | Société, ou liste Contacts |
| **Candidat** | Profil hors staff (vivier) | Actions, positionnements, DT, contrat | Liste, HRFlow, fiche |
| **Ressource** | Profil staffé (salarié, interne, freelance interne) | Actions, positionnements, prestations, projets, DT, contrat, temps, frais, absences, avantages, formulaires | Liste, ou passage candidat → ressource |
| **Besoin** | Demande à pourvoir (Régie / Forfait) | Positionnements, actions, projets | Société / fiche candidat ou ressource |
| **Positionnement** | Un profil **sur** un besoin + un état | — | Fiche besoin, candidat ou ressource |
| **Projet** | Mission contractualisée | Prestations, actions, achats, lots/jalons | Besoin, ou création directe |
| **Prestation** | Une ressource **sur** un projet, dates + CA + renta | Temps | Fiche projet ou ressource |
| **Action** | Fait CRM daté (note, todo, entretien, appel…) | Pièces jointes | N’importe quelle fiche porteuse |
| **Achat** | Dépense sur projet (fournisseur = société) | Paiements, factures frs | Projet |
| **Temps / Frais / Absences** | Saisie de la ressource | Validations, paie (app) | Fiche ressource |
| **Manager** | Compte qui ouvre Boond | Périmètre de listes | Créé depuis une ressource |

Le **positionnement** est l’objet pivot du staffing : il est le seul qui relie un **humain** (candidat ou ressource) à un **besoin client**.

Le **projet** est l’objet pivot de la production : il relie le **client** à des **prestations** (qui travaille) et des **achats** (ce que ça coûte).

---

## Les cinq métiers (enchaînement d’écrans)

Chaque métier est un chemin dans le graphe. L’écran suivant n’est pas un menu : c’est un **Créer** depuis la fiche.

### 1. CRM — trouver et nourrir le client

`Sociétés` → fiche société → `Contacts` → fiche contact → **Créer une Action** (appel, RDV, mail)

Le contact n’existe pas sans société. L’action est l’historique. Sans action, le CRM est un carnet d’adresses.

### 2. Recrutement — faire grandir le vivier

`Candidats` → fiche → **Action** (entretien, qualification, todo) → DT / CV

Sorties possibles depuis la fiche candidat : **Positionnement** (le tester sur un besoin), **Besoin**, **Projet**, **Contrat**.

Un candidat n’est pas une ressource. Tant qu’il n’est pas staffé, il n’a ni prestation, ni temps, ni absences.

### 3. Staffing — pourvoir un besoin

`Besoins` → fiche (client, type Régie/Forfait, dates, CA pondéré, état) → **Créer un Positionnement** (choisir candidat **ou** ressource)

Le positionnement a son propre cycle d’états (à traiter, P1…, gagné, perdu, no go…).

Quand c’est gagné : **Créer un Projet** depuis le besoin.

### 4. Production — exécuter

`Projets` → fiche → **Créer une Prestation** (ressource + dates + CA)

La ressource saisit **Mes temps / Mes frais / Mes absences**.

Le **plan de charge** n’est pas un objet : c’est une **vue** ressource × mois qui superpose prestation signée, prévisionnelle, interne, absence, positionnement, contrat RH.

### 5. Achat — ce qui n’est pas produit en interne

`Projets` → **Achat** (fournisseur = société) → facture fournisseur → paiement

La **facturation client** (commandes, factures, échéanciers) est un **module / app** (PostProduction), pas un onglet du projet sur tous les comptes.

---

## Ce que chaque écran *fait* dans le graphe

| Écran | Rôle dans le métier | Objets enfants (onglets / Créer) |
|---|---|---|
| Tableau de bord | Lire des agrégats | — (widgets sur besoins, CA, candidats, alertes) |
| Actions | File unique de tous les faits CRM | Filtre par objet porteur |
| Candidats | Vivier | Synthèse, Info, Admin, DTs, Actions, Positionnements |
| Ressources | Staff | + Prestations, Projets, Formulaires ; hors onglets : temps, frais, absences |
| Profils types | Gabarit de profil | (non ouvert : catalogue, pas un flux quotidien) |
| Produits | Catalogue vendable | (hors staffing quotidien) |
| Sociétés / Contacts | CRM | Fiches + actions |
| Besoins | Demande à pourvoir | Positionnements, Actions, Projets |
| Positionnements | Matching humain × besoin | — |
| Projets | Mission signée | Actions, Prestations ; option Lots/Jalons |
| Prestations | Affectation | Groupements |
| Achats | Coût externe | Factures frs, Paiements |
| Planning / Plans de charge | Vue charge | Lecture de prestations + absences + positionnements |
| Reporting | Vue CA / volumes | Lecture de besoins, positionnements, projets, actions |
| Apps | Greffons | Emailing, HRFlow, templates, paie, facture, Microsoft… |
| Administration | Référentiels + droits | Rôles, agences, états, types d’action |

---

## Ce qui n’est pas le cœur (d’où l’abonnement)

Boond facture une **plateforme + marketplace**. Le graphe ci-dessus tient **sans** :

- Apps : Emailing, HRFlow, DocTemplates, Viewer, Célébrations, Microsoft, ExtractPayroll, PlanProduction, PostProduction
- Intranet / digital workplace
- Facturation client complète, banque, webhooks, automations
- Produits, profils types, lots/jalons, groupements avancés

Le miniature, c’est le graphe + les cinq métiers. Le reste est ce qu’on **n’achète plus**.

---

## Conséquence pour Ava Manager

Reproduire Boond = reproduire **des listes**. Ça ne sert à rien.

Reproduire Boond miniature = reproduire **ces liens** :

1. Société → Contact → Action  
2. Candidat | Ressource → Positionnement ← Besoin ← Société  
3. Besoin → Projet → Prestation ← Ressource  
4. Action polymorphe sur les fiches  
5. Un compte = une ressource + un rôle + un périmètre
