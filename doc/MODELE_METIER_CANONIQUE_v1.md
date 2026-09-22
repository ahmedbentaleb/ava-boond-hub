# Modèle métier canonique Ava Manager v1

Date : 17/09/2026 · Statut : **décidé** — G1–G15 tranchés le 17/09/2026 (feuille G, sur délégation d'Ahmed). Les marques `[Gn]` restent pour la traçabilité.
Sources : DEC-01→18, F1–F36, ATL, BM-01→61, ADR-000→**005**. **Patch 4d (17/09 soir)** : les états sont des référentiels à catégorie, les bifurcations sont des politiques (registre), les murs sont les 15 du registre §A. Ce document dit **quels objets existent, comment ils se tiennent, et ce qui est physiquement interdit**. Les colonnes détaillées sont le livrable 5.

## 1. Les objets — 21, en cinq familles

| Famille | Objet | Il existe parce que | Nouveau ? |
|---|---|---|---|
| **Identité** | Personne | DEC-01 : l'identité commune | |
| | ProfilCandidat | DEC-01/02, F19 | |
| | ProfilRessource | DEC-01/02/12 | |
| | Document (CV, DT, pièce) | BM-04, BM-52, US3 — un fichier rattaché à un porteur | ➕ |
| **Client** | Société | DEC-04 ; statut commercial prospect / client **et** rôles fournisseur / **interne** `[G6]` — rôle ≠ statut (D-3) | |
| | UnitéOrganisation (pôle, BU, service, équipe) | BM-12, arbre à profondeur variable — **client et interne** : les pôles / équipes d'Avaliance sont les unités de la société `interne`, rattachées à une agence (D-1) | |
| | Contact | F22 : distinct de Personne | |
| **Commerce & staffing** | Besoin | DEC-04/05/13 ; porte `nb_postes_vises` `[G4]` | |
| | Positionnement | DEC-03 : 1 besoin × 1 profil (XOR) | |
| | Qualification | BM-09/24 : une mesure d'un profil **pour un besoin**, par un évaluateur | ➕ |
| | Compétence (référentiel) + niveau requis / mesuré | CdC IV.B.5, IV.D | ➕ |
| **Production** | Projet | DEC-05/06/07 | |
| | Prestation | DEC-07/08/10/11 | |
| | Temps | DEC-02, F32–F34 | |
| | Absence | F25, DEC-16 | |
| **Structure & transverse** | Agence interne | US1/US5 lookup, F30, CdC II.K | ➕ |
| | Périmètre (agence, pôle, équipe) | DEC-17 : ce sur quoi une permission s'applique | ➕ |
| | Calendrier d'agence (jours non ouvrés) | F30, ATL-01/02/04/09 | ➕ |
| | Compte, Groupe, Permission | DEC-17, F28 | |
| | Action | DEC-15 : un porteur unique | |
| | ÉvénementMétier · SnapshotMarge | DEC-18, DEC-09, ADR-004 | |
| | **Politique** (clé, valeur, options, défaut) | ADR-005 : toute bifurcation | ➕ |
| | **RéférentielÉtat** ×6 (besoin, candidat, ressource, positionnement, prestation, projet), à catégorie fermée | ADR-005 §3, CdC IV.G | ➕ |
| | Référentiels : Devise, TypeAbsence, TypeAction, ÉtapeSuivi | BM-49 | ➕ (devise, type absence) |

Hors V1, **nommés pour ne pas être oubliés** : Achat, Facture (client et fournisseur), Commentaire/Mention, Alerte, ModèleEmail, ProcessusRecrutement versionné, Objectif/KPI stockés, Portail candidat. Le livrable 5 les **tague**, ne les modélise pas.

## 2. Les liens et leurs cardinalités

| Lien | Card. | Garde physique | Source |
|---|---|---|---|
| Personne → ProfilCandidat | 0..1 | `UNIQUE(personne_id)` | DEC-01, BM-02 |
| Personne → ProfilRessource | 0..1 | `UNIQUE(personne_id)` | DEC-01, BM-02 |
| Personne → Document | 0..N | porteur = personne | BM-04 |
| ProfilRessource → Société fournisseur | 0..1, **obligatoire si EXTERNAL** | CHECK `(type='EXTERNAL') = (societe_fournisseur_id IS NOT NULL)` | DEC-12 |
| ProfilRessource → Agence | 1 | NOT NULL | US1 |
| Société → UnitéOrganisation | 0..N, arbre | `parent_id` même société ; pas de cycle (trigger) | BM-12 |
| Société → Contact | 1 → N | NOT NULL | BM-13 |
| Contact → UnitéOrganisation | 0..1 | unité de la même société (trigger) | BM-13 |
| Société → Besoin | 1 → N | NOT NULL ; société `interne` pour un besoin de recrutement sur profil `[G6]` | DEC-04 |
| Besoin → Contact | 0..1 | contact de la même société (trigger) | DEC-04, BM-19 |
| Besoin → Agence | 1 | NOT NULL | CdC II.K |
| Besoin → Positionnement | 1 → N | NOT NULL ; besoin de catégorie `a_pourvoir` ou `en_recherche` à la création — politique `positionnement.sur_besoin_inactif` | DEC-03, F5 |
| Positionnement → ProfilCandidat **XOR** ProfilRessource | exactement 1 | CHECK `(cand IS NULL) <> (ress IS NULL)` | DEC-03 |
| (Besoin, Personne) actifs | unique | **garde de commande** sur les catégories `propose`, `presente` — politique `positionnement.unicite` `[G7]` ; aucun index unique (D-6) | BM-21 |
| Besoin → Qualification | 1 → N | NULL en base, exigé par la commande — politique `qualification.besoin_obligatoire` (défaut oui, D-5) | BM-09 |
| Qualification → Positionnement | 0..1 | facultatif : un profil peut être qualifié pour un besoin sans être (encore) positionné | CdC IV.B.5 |
| Besoin → Projet | **0..N** | `projet.besoin_id NULL` | DEC-05, US5 |
| Société → Projet | 1 → N | NOT NULL | US5, BM-26 |
| Projet → Contact | 1 | NULL en base, exigé par la commande — politique `projet.contact` (défaut obligatoire, D-5) ; demandé si le besoin n'en a pas | US5, F4 |
| Projet → Prestation | **0..N** | un projet sans prestation est légal | S3, ADR-003 |
| Prestation → ProfilRessource | 1, **immuable** | trigger `BEFORE UPDATE` refuse | DEC-11 |
| Prestation → Temps | 0..N | `temps.profil_ressource_id = prestation.profil_ressource_id` (trigger, **mur**) ; date dans `[debut, fin]` — politique `temps.periode` `[G9]` | F32 |
| Prestation → SnapshotMarge | 0..1 | écrit à l'entrée en catégorie `clos`, jamais réécrit | DEC-09 |
| ProfilRessource → Absence | 0..N | **sans prestation** | F25 |
| Action → porteur | exactement 1 parmi Société, Contact, ProfilCandidat, ProfilRessource, Besoin, Projet | CHECK « exactement une FK non nulle » | DEC-15 |
| Compte → Personne | 0..1 | requis pour le self-service (« soi-même ») | matrice |
| Compte → Groupe | N ↔ N | union des habilitations | DEC-17 |
| Groupe → (Permission × Périmètre) | N ↔ N, **par paire** | jamais permission et périmètre en deux listes séparées | BM-42 |
| Compte → surcharge restrictive | 0..N | la restriction gagne | F28 |
| Agence → Calendrier (jours non ouvrés) | 1 → N | | F30 |
| Objet historique → ÉvénementMétier | 1 → N | ajout seul ; `liens` porte les politiques lues | ADR-004, ADR-005 |
| Cycle → RéférentielÉtat | FK | `etat_code` → `ref_etat_<objet>.code` ; CHECK sur la **catégorie**, jamais sur le code | ADR-005 |

## 3. Ce qui est interdit — les 15 murs, en structure, pas en écran

La liste canonique est le **§A du registre des politiques** (M-1 → M-15). Rappel de la forme physique :

| # | Mur | Comment c'est rendu impossible |
|---|---|---|
| M-1 | Candidat sur prestation ou temps | FK vers `profil_ressource` seulement ; aucune colonne candidat. |
| M-2 | Positionnement à 0 ou 2 humains | CHECK XOR. |
| M-3 | Deux profils du même type sur une personne | `UNIQUE(personne_id)` sur chaque table de profil. |
| M-4 | Changer la ressource d'une prestation | trigger `BEFORE UPDATE` refuse. |
| M-5 | Ressource portée par le projet | pas de colonne. |
| M-6 | Réécrire un snapshot | trigger anti-UPDATE + rôle SQL sans UPDATE. |
| M-7 | Modifier / effacer un événement | idem. |
| M-8 | DELETE d'un objet historique | rôle SQL sans DELETE ; `archive_le`. |
| M-9 | Action sans porteur ou à deux porteurs | CHECK « exactement une FK non nulle ». |
| M-10 | Temps sur la prestation d'une autre ressource | trigger d'égalité. |
| M-11 | Besoin sans société | NOT NULL (société `interne` pour le recrutement sur profil, G6). |
| M-12 | Contact / unité d'une autre société ; cycle d'unités | triggers de cohérence et de parcours. |
| M-13 | Permission sans périmètre | la jointure exige la paire. |
| M-14 | Conditions économiques qui suivent la fiche ressource, ou qui changent après signature | colonnes propres à la prestation, **immuables dès `engage`** (trigger, T-2). |
| M-15 | Montant stocké sans devise ; agrégat multi-devises stocké | `devise_code NOT NULL` à côté de chaque montant ; aucune colonne convertie (T-2). |

*Règle de code R-1, hors des quinze* : les agrégats groupent par devise — une addition EUR + MAD est un refus en revue, pas un mur (registre §A).

**Deux anciens interdits sont devenus des politiques** (ADR-005) : la création automatique de projet (`projet.creation_depuis_besoin`, DEC-06 vs US6) et le passage à pourvu avant que tous les postes visés soient signés (`besoin.pourvu.garde_minimale`, F3 / G4 — défaut : tous les postes, T-1). Leur défaut reproduit l'interdit d'aujourd'hui ; ils ne sont plus des murs parce qu'ils sont des **choix**.

## 4. Ce que ce modèle ne décide pas

| Sujet | Où c'est décidé |
|---|---|
| Les états et transitions de chaque cycle | `MACHINES_ETAT_V1.md` |
| Les colonnes, types, index | livrable 5 |
| Le contenu de la matrice rôles × commandes | étape 8 — configuration, pas schéma |
| Les formules | ATL-01→18 — le schéma porte les **entrées** (`tjm_vendu`, `cjm_contrat`, `jours_vendus`, `taux_occupation`, frais, CA additionnel) |
| La détection des doublons de Personne | politiques `doublon.*` (F20) — logique de service, pas de contrainte |
| **Toute bifurcation** (contact facultatif, projet auto, surcharge, retour prospect, grain…) | `REGISTRE_POLITIQUES_v1.md` §C, compte au §E — défaut = décision du 17/09 |
