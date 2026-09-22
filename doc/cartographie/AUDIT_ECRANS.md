# Audit visuel Boond Manager — écran par écran

Verdict **auditeur** : le diagnostic précédent était un **modèle**, pas un audit. Un audit d’écran exige une capture + les zones + ce que l’écran crée. Cette passe pose la méthode et **16 preuves visuelles**. Il en reste.

Verdict **chef de projet** : on screenshotte le **chrome** (barre, filtres, colonnes, Créer), pas les gens. Les captures viennent d’un tenant réel ; le texte ci-dessous ne recopie pas les fiches personnes.

Source : `ui.boondmanager.com` · 15/09/2026 · session connectée.

---

## Couverture

| | n |
|---|---|
| Capturés + décrits ici | **33** |
| Listes menu (01–16) | 16 |
| Fiches + modales cliquées (17–33) | 17 |
| Encore (contact, Kanban, self-service, reporting, achats frs, apps, autres +) | **~20** |

### Encore à shooter

Fiches : onglets restants ressource / société / contact · Kanban.  
Listes : Prestations, Factures fournisseurs, Paiements, Plans de charge, Reporting (4).  
Self-service : Mes temps / frais / absences, Mon compte, Flags, Logs.  
Modales + restantes : Besoin, Contrat, Prestation, Achat, Formulaire depuis les fiches.  
Apps : les 9 écrans internes.

---

## Chrome commun (toutes les listes)

Vu sur Candidats, Ressources, Sociétés, Contacts, Besoins, Positionnements, Projets :

1. Fil d’Ariane  
2. Titre + **compteur**  
3. Mots-clefs + pastille Filtres  
4. Recherche libre + sélecteur de colonnes (roue)  
5. Table triable, cases à cocher  
6. Pagination implicite / scroll  
7. **+** bleu en haut à droite = Créer (sauf Actions et Positionnements : création depuis une fiche)  
8. Liste / Kanban sur Candidats, Ressources, CRM, Besoins, Positionnements — **pas** sur Projets

---

## 01 — Tableau de bord / Synthèse

![Dashboard synthèse](ecrans/01-dashboard-synthese.png)

| | |
|---|---|
| Chemin | Lecture de C1–C4 |
| Il fait | Agrège. Ne crée rien. |
| Zones | Menu gauche · recherche Ctrl+K · Synthèse / Mes alertes · 6 widgets · roue de config |
| Widgets | Répartition besoins (A traiter, P1–P3) · CA facturé/signé · Synthèse d’indicateurs (projets, positionnements, contacts, sociétés, ressources, candidats) · CA période/production/signé · Marge signée · Répartition candidats |
| CP | Hors v1. On le branche quand les objets existent. |
| Auditeur | Les widgets **lisent** le graphe. Un dashboard sans positionnement ni besoin est décoratif. |

---

## 02 — Tableau de bord / Mes alertes

![Dashboard alertes](ecrans/02-dashboard-alertes.png)

| | |
|---|---|
| Il fait | File d’alertes configurées en admin. Vide = « Vous n'avez aucune alerte ». |
| CP | Hors v1. |
| Auditeur | Les alertes sont un **réglage admin**, pas un objet métier. |

---

## 03 — Actions (liste)

![Actions](ecrans/03-actions.png)

| | |
|---|---|
| Chemin | C1 C2 C3 — le journal |
| Il fait | Une file de **tous** les faits CRM. |
| Il ne fait pas | Créer (pas de +). La création est sur la fiche porteuse. |
| Colonnes | Date, Catégorie, Type, Référence, Contact, Action, Manager, Doc. |
| Filtres vus | Périmètre manager, 5 Types |
| Vide | « Aucune action trouvée » + Réinitialiser + texte *créer votre première action* |
| Auditeur | Liste filtrée par défaut sur **un** manager. Compter 0 n’est pas « le module est vide ». |

---

## 04 — Candidats (liste)

![Candidats](ecrans/04-candidats.png)

| | |
|---|---|
| Chemin | C2 |
| Il fait | Vivier hors staff. |
| Il crée | **+** → fiche nouvelle (`/candidates/0/information`) |
| Colonnes | Candidat, Titre, Étape (pastille couleur), Pos., Dispo., Coordonnées (tel, mail, LinkedIn), MAJ, Manager, CV |
| Vues | Liste / Kanban |
| Étapes vues | A relancer, En cours, A traiter, A supprimer, Collaborateur, Vivier |
| CP | Objet n°2 du miniature après Société/Besoin. |
| Auditeur | L’étape est un **référentiel admin** (14 étapes), pas un enum figé. |

---

## 05 — Fiche candidat / Synthèse

![Fiche candidat synthèse](ecrans/05-fiche-candidat-synthese.png)

| | |
|---|---|
| Onglets | Synthèse, Informations, Administratif, DTs, Actions, Positionnements |
| Toolbar | Demander à l’IA · partager / mail / CV / DT · **+** (Action, Positionnement, Besoin, Projet, Contrat) |
| Colonne gauche | Identité, coordonnées, provenance, managers, agence/pôle, administratif (nationalité, salaires, contrat) |
| Colonne droite | Action (n) · Positionnement (n) · Dossier technique (compétences, expérience, formation, langues, domaines, secteurs, XP) |
| CP | C’est **l’écran qui enchaîne** C2 → C3. Le + est le métier. |
| Auditeur | Pas d’onglet Prestation / Temps. Preuve : candidat ≠ ressource. |

---

## 06 — Fiche candidat / Informations

![Fiche candidat informations](ecrans/06-fiche-candidat-informations.png)

| | |
|---|---|
| Il fait | Formulaire d’identité, pas le matching. |
| Blocs | Informations personnelles (civilité, nom, prénom, titre, type, naissance, emails, tél, adresse, LinkedIn, réseaux) · CV (fichier + dropzone) · Commentaires · Informations RH (étape, provenance, dispo, mobilité, managers, agence, pôle, visible uniquement de vous) · Évaluation |
| CP | Champs v1 : nom, titre, étape, manager, CV. Le reste est confort. |
| Auditeur | « Visible uniquement de vous » = cloisonnement. À prévoir dans les droits. |

---

## 07 — Ressources (liste)

![Ressources](ecrans/07-ressources.png)

| | |
|---|---|
| Chemin | C3 C4 |
| Différence vs candidats | Colonnes **État** + **Tarif HT**. Pas « Étape ». |
| Il crée | **+** |
| Vues | Liste / Kanban · bouton Apps |
| CP | Même gabarit de liste que Candidats, **autre objet**. Ne pas fusionner les tables si on veut les temps. |
| Auditeur | Filtre « 2 États » par défaut : la liste n’est pas exhaustive sans reset. |

---

## 08 — Profils types

![Profils types](ecrans/08-profils-types.png)

| | |
|---|---|
| Il fait | Gabarit tarifaire (titre, TJ vente, coût, marge, renta, agence). |
| État | Vide + « Créer un profil type » |
| CP | Hors v1. On tarife sur la ressource / la prestation. |
| Auditeur | Module catalogue, pas un flux quotidien. |

---

## 09 — Produits

![Produits](ecrans/09-produits.png)

| | |
|---|---|
| Il fait | Catalogue vendable (référence, nom, tarif HT, responsable). |
| CP | Hors staffing v1. |
| Auditeur | Présent dans le menu donc **activé** sur ce contrat. Ne pas conclure « inutilisé » sans usage réel. |

---

## 10 — Sociétés

![Sociétés](ecrans/10-societes.png)

| | |
|---|---|
| Chemin | C1 C3 C5 |
| Il crée | **+** |
| Colonnes | Société, Secteur, Informations, État (Prospect / Client), Coordonnées, Lieu, Manager |
| Nav | CRM ouvert → Sociétés / Contacts |
| CP | Objet n°1. Sans société, pas de besoin. |
| Auditeur | Une société est client **et** peut être fournisseur d’achat (C5). Un seul objet, deux rôles. |

---

## 11 — Contacts

![Contacts](ecrans/11-contacts.png)

| | |
|---|---|
| Chemin | C1 |
| Il crée | **+** · aussi **Exporter** |
| Colonnes | Contact, Fonction, Type (ex. Décisionnaire), Société, État (Prospect / Contact / Archivé), Coordonnées, Lieu, Manager |
| CP | Un contact n’existe pas sans société. |
| Auditeur | Type ≠ État. Deux référentiels. |

---

## 12 — Besoins

![Besoins](ecrans/12-besoins.png)

| | |
|---|---|
| Chemin | C3 — pivot commercial |
| Il crée | **+** |
| Ligne | Titre + type (Régie/Forfait) + réf AO · Client + contact · État (A traiter, P1…) · Pos. Actif · Date de démarrage · CA Pond. HT · Manager |
| Vues | Liste / Kanban |
| CP | Objet n°1 du métier staffing. Chaque ligne **attend** des positionnements. |
| Auditeur | CA pondéré = CA × pondération (vu sur la fiche). La liste affiche le résultat, pas les deux champs. |

---

## 13 — Positionnements

![Positionnements](ecrans/13-positionnements.png)

| | |
|---|---|
| Chemin | C2 ∩ C3 — **le lien** |
| Il crée | **Pas de +**. Créé depuis Besoin / Candidat / Ressource. |
| Colonnes | MAJ, Profil positionné, Besoin (titre + AO), État, Commentaire, Client, Responsable |
| États vus | Proposé, CV envoyé, Validé, Gagné, NO GO interne, Désistement |
| Vues | Liste / Kanban |
| CP | Si on ne code que ça + besoin + profil, on a le staffing. |
| Auditeur | Un profil (candidat **ou** ressource) × un besoin. L’état est un référentiel (9 états admin). |

---

## 14 — Projets

![Projets](ecrans/14-projets.png)

| | |
|---|---|
| Chemin | C3 → C4 C5 |
| Il crée | **+** |
| Colonnes | Début, Fin, Référence PRJ, Client, CA HT, Renta. %, Manager |
| Ligne | Type Régie/Forfait sous la référence |
| Vues | Liste seulement (pas de Kanban) · sous-menu Prestations |
| CP | Un projet sans prestation = un titre. Lot suivant = Prestations. |
| Auditeur | CA à 0 sur beaucoup de lignes : le projet peut exister **avant** le chiffrage. Ne pas exiger le CA à la création. |

---

## 15 — Administration

![Administration](ecrans/15-administration.png)

| | |
|---|---|
| Il fait | Régler le graphe, pas le parcourir. |
| Cartes | Managers/Rôles · Agences juridiques · Paramètres globaux · Modèles · Apps/Marketplace · Mon offre |
| Avancé | Alertes, Business units, Pôles, Traductions |
| Pied | Import, Espace développeur, Webhooks |
| CP | V1 : un rôle + un périmètre. Pas toute la marketplace. |
| Auditeur | C’est ici que vivent les **étapes candidat** et **états positionnement**. Les listes ne font que les afficher. |

---

## 16 — Apps

![Apps](ecrans/16-apps.png)

| | |
|---|---|
| Il fait | Greffons autour du graphe. |
| Installées | Célébrations, DocTemplates, Emailing, ExtractPayroll, HRFlow, Microsoft, PlanProduction, PostProduction, Viewer |
| CP | Hors miniature. PostProduction = facture client (d’où le 403 sur `/invoices`). HRFlow = entrée C2. ExtractPayroll = sortie C4. |
| Auditeur | 9 apps = 9 écrans **non audités**. L’abonnement se joue là. |

---

## Fiches cliquées (17–33)

Les 16 listes du menu sont le hall. Le métier est dans les onglets et les +.

### Carte des onglets

| Objet | Onglets | + Créer |
|---|---|---|
| Candidat | Synthèse, Infos, Admin, DTs, Actions, Positionnements | Action, Positionnement, Besoin, Projet, Contrat |
| Ressource | + Prestations, Projets, Formulaires | + Prestation, Avantage, Formulaire |
| Société | Synthèse, Infos, Contacts, Actions, Besoins, Projets, Achats, Facturation | Action, Besoin, Projet, Achat |
| Besoin | Infos, Positionnements, Actions, Projets | Action, Positionnement, Projet |
| Projet | Infos, Actions, Prestations | Action, Prestation, Groupement |

### 17 — Candidat / Administratif

Contrat souhaité, salaires, + contrat, identité civile. Pas le matching.

### 18 — Candidat / DTs

DT éditable : compétences, diplômes, langues, expériences (+).

### 19–21 — Candidat / Actions + modal + types

Timeline du porteur. Modal : Type, Date, Manager, corps. Types vus : Note, To do, RDV, Entretien tel/physique/visio, Qualification, Mail, Autre.

### 22–23 — Menu + et Créer Positionnement

+ = Action, Positionnement, Besoin, Projet, Contrat. **Pas Contact.**  
Assistant positionnement = choisir un besoin **déjà là** (liste complète sous le bandeau), puis Positionner.

### 24–28 — Fiche besoin

Infos (AO, Régie, CA pondéré = budget × pondération) · Positionnements (totaux CA/marge, état en ligne) · Actions (même gabarit) · Projets (vide + Créer).  
**Créer un projet** : convertir des positionnements en prestations. Texte vu : les positionnements **candidats sont exclus** — convertir en ressource d’abord.

### 29 — Candidat / Positionnements

Vue inverse de 25. Vide + Créer un positionnement = même assistant que 23.

### 30–31 — Fiche ressource

Onglets extra : Prestations, Projets, Formulaires. Prestations : Créer une prestation **ou** de l’inactivité.

### 32 — Fiche société

Huit onglets. Hub C1+C3+C5. Compteurs Actions / Besoins / Projets / Achats.

### 33 — Fiche projet

Infos, Actions, Prestations. Lien vers Client et Besoin. Lots/Jalons = interrupteur. + Prestation, Groupement.

---

## Synthèse des deux lectures

**Chef de projet.** L’ordre tient, maintenant vu **dans les boutons** : Société → Besoin → Positionnement → (candidat → ressource) → Projet → Prestation. Les 16 listes ne suffisent pas : le + de fiche est le produit.

**Auditeur.** Preuve dure : Boond refuse de convertir un positionnement candidat en prestation. Candidat ≠ ressource n’est plus une hypothèse d’onglets, c’est une règle du modal 28. L’audit n’est pas clos (contact, Kanban, C4 profond, apps).
