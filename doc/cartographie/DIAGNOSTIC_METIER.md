# Diagnostic Boond Manager

Produit, pas un tenant. Preuve : boutons **Créer** des fiches, onglets, types d’action.
Deux lectures : chef de projet · auditeur senior.

---

## Les cinq chemins (une couleur = un métier)

| # | Métier | Chaîne d’objets | Ce que ça produit |
|---|---|---|---|
| **C1** | CRM | Société → Contact → Action | Un historique chez un client |
| **C2** | Recrutement | Candidat → Action → Positionnement | Un vivier testé sur des besoins |
| **C3** | Staffing | Société → Besoin → Positionnement → Projet | Un besoin pourvu, puis signé |
| **C4** | Production | Projet → Prestation ← Ressource | Qui travaille, quand, quel CA |
| **C5** | Achat | Projet → Achat (fournisseur = Société) | Le coût qui n’est pas interne |

Règle : le bouton **Créer** d’une fiche **est** le menu. L’inverse n’existe pas (un positionnement ne crée pas un besoin).

---

## Chef de projet

**Le miniature n’est pas 13 listes. C’est C3 + C4.** Sans positionnement, le staffing n’existe pas. Sans prestation, le projet est un titre.

Ordre de build (chaque lot a un Créer qui passe au lot suivant) :

1. Société + Besoin  
2. Candidat et/ou Ressource  
3. Positionnement (le lien)  
4. Projet  
5. Prestation  
6. Action (journal)  
7. Vues en dernier : dashboard, reporting, plan de charge — elles ne créent rien

Hors v1 : Apps, facture client, paie, intranet, profils types, produits. C’est l’abonnement à 2 500 €, pas le métier quotidien.

Risque n°1 : livrer les listes avant les **Créer**. On obtient un clone visuel qui n’enchaîne pas.

---

## Auditeur senior

| Constat | Preuve | Gravité si on l’ignore dans le miniature |
|---|---|---|
| Candidat ≠ ressource | Onglets fiche différents ; seule la ressource a prestations / temps / absences | On mélange vivier et staff : la saisie de temps n’a plus de sens |
| Positionnement = 1 besoin × (1 candidat XOR 1 ressource) | Créer Positionnement depuis les trois fiches ; un seul profil par ligne de liste | Matching cassé ou doublons |
| Action polymorphe | Filtre Types par objet (candidat, ressource, contact, besoin, projet) | Journal éclaté ou types inventés |
| Compte = ressource + rôle + périmètre | Admin Managers « créer depuis une ressource » ; listes filtrées sur le manager | Fuite de données entre commerciaux |
| Facture client hors cœur | `/invoices` → 403 sur le compte ouvert | Recoder un module non contractuel |
| Plan de charge n’est pas un objet | Légende = superposition de prestations, absences, positionnements, contrats | Table « planning » orpheline |
| Limite du constat | Fiches société / contact / produit / profil type / Kanban / Apps non ouvertes | Ne pas figer leurs champs |

---

## Écran par écran

| Écran | Chemin | Il fait | Il crée | Il ne fait pas |
|---|---|---|---|---|
| Tableau de bord | lecture | Agrège | — | Traiter un besoin |
| Actions | C1–C3 | File des faits | — (depuis une fiche) | Porter un matching |
| Candidats | C2 | Vivier, CV, DT, étape | Action, Positionnement, Besoin, Projet, Contrat | Temps, prestation |
| Ressources | C3 C4 | Staff | + Prestation, Formulaire, Avantage | Recruter un inconnu (ça c’est Candidat) |
| Sociétés | C1 C3 C5 | Client / prospect / fournisseur | Contact, Besoin, Projet | Staffer |
| Contacts | C1 | Personne chez la société | Action | Être un candidat |
| Besoins | C3 | Demande Régie/Forfait + état + CA pondéré | Positionnement, Action, Projet | Affecter le temps |
| Positionnements | C2 C3 | Matching + état | — (c’est le lien) | Facturer |
| Projets | C3 C4 C5 | Mission signée | Prestation, Action, Groupement | Recruter |
| Prestations | C4 | Ressource × projet + CA + renta | — | CRM |
| Achats | C5 | Coût externe | Paiements / factures frs | Staffing |
| Plans de charge | C4 | Vue ressource × mois | — | Créer une mission |
| Reporting | lecture | Compte les cinq chemins | — | Décider un matching |
| Apps | hors cœur | Greffons | selon l’app | Remplacer C1–C5 |
| Administration | tous | Rôles, agences, états, types | Référentiels | Produire du CA |
| Mes temps / frais / absences | C4 | Saisie ressource | Feuilles à valider | Créer un projet |

---

## Intégrité (ce qui doit rester vrai)

- Besoin et projet ont une **société**
- Positionnement a un **besoin** et **un seul** humain (candidat XOR ressource)
- Prestation a un **projet** et une **ressource**
- Action a **un** porteur
- Manager a une **ressource** et un **rôle**
- Temps s’appuient sur une **prestation**, pas sur un candidat
