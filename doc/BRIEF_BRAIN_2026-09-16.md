# Brief canonique Brain — Ava Manager

Date : 16 septembre 2026  
Usage : cadrage produit interne Ahmed + Brain  
Phase : règles métier et simulations — aucun code produit

## 1. Mission de Brain

Transformer le cadrage existant en contrat métier cohérent avant toute conception
de base de données ou développement.

Brain doit :

1. conserver les décisions déjà prises par Ahmed ;
2. repérer les contradictions entre les cahiers des charges, Boond et ces décisions ;
3. compléter les règles métier manquantes ;
4. simuler des parcours qui modifient un état métier étape par étape ;
5. poser uniquement les questions dont la réponse change réellement le produit ;
6. produire une roadmap courte, ordonnée par dépendances.

Brain ne doit pas :

- coder ;
- refaire un audit de sécurité ;
- cloner les écrans de Boond ;
- rouvrir une décision sans contradiction précise et sourcée ;
- considérer le simulateur HTML actuel comme une preuve de validité ;
- inventer une règle parce que Boond la possède.

## 2. Sources à lire dans cet ordre

1. `AVA MANAGER-SPEC 1.docx` — demandes fonctionnelles d’octobre 2024.
2. `COCKPIT2-Cahier de charge-v0.1.docx` — vision complète de 2022.
3. `_ops/cartographie/FONCTIONNEMENT_BOOND.md` — fonctionnement observé.
4. `_ops/cartographie/DIAGNOSTIC_METIER.md` — graphe et invariants observés.
5. `_ops/cartographie/AUDIT_ECRANS.md` — preuves par écran.
6. Le présent fichier — décisions actuelles d’Ahmed, prioritaires sur les
   propositions anciennes lorsqu’une divergence est explicitement indiquée.

Le hub publié est un outil de visualisation, pas la source canonique :
`https://ahmedbentaleb.github.io/ava-boond-hub`

## 3. Vision produit acquise

Ava Manager doit réunir :

- CRM ;
- recrutement ;
- staffing ;
- gestion de projets et prestations ;
- fonctions complémentaires ajoutées seulement lorsqu’elles servent le métier.

Le noyau n’est pas une collection de listes. Il est organisé autour des objets :

`Personne, CandidatProfile, RessourceProfile, Société, Contact, Besoin,
Positionnement, Projet, Prestation, Action`.

Les deux pivots sont :

- `Positionnement` : un humain proposé sur un besoin ;
- `Prestation` : une ressource affectée à un projet avec ses conditions
  opérationnelles et économiques.

## 4. Décisions déjà prises — ne pas reposer ces questions

### DEC-01 — Identité humaine

Une `Personne` porte l’identité commune. `CandidatProfile` et
`RessourceProfile` sont deux profils distincts rattachés à cette personne.

### DEC-02 — Candidat et Ressource

Un Candidat ne porte jamais de Prestation ni de Temps. La conversion active un
profil Ressource sans copier ni supprimer l’identité et l’historique candidat.

### DEC-03 — Positionnement

Un Positionnement appartient à un Besoin et porte exactement un humain :
un Candidat ou une Ressource, jamais les deux.

### DEC-04 — Besoin et Contact

Une Société est obligatoire sur le Besoin. Le Contact est facultatif mais
recommandé dans l’interface. Cette décision remplace la contrainte du cahier 2022.

### DEC-05 — Besoin et Projets

Un Besoin peut ouvrir plusieurs Projets. Un seul projet sera le cas fréquent,
mais la cardinalité ne doit pas être figée à 1–1.

### DEC-06 — Création du Projet

Un positionnement retenu ou un besoin pourvu ne crée pas silencieusement un
Projet. La création est une commande explicite avec confirmation des paramètres
contractuels.

### DEC-07 — Ressources du Projet

Le Projet ne porte pas un `resource_id` unique. Ses ressources sont dérivées de
ses Prestations.

### DEC-08 — Valeurs économiques

- Ressource : coût de référence et éventuellement TJM indicatif.
- Positionnement : TJM proposé ou négocié.
- Prestation : TJM vendu et coût retenu pour cette mission.

Les valeurs historiques d’une Prestation ne suivent pas les changements futurs
de la fiche Ressource.

### DEC-09 — Marge

La marge est recalculée pendant l’activité. Elle est figée à la clôture par un
snapshot historique non réécrit.

### DEC-10 — Prestations simultanées

Une Ressource peut avoir plusieurs Prestations simultanées. Une charge cumulée
supérieure à 100 % produit une alerte, pas un refus automatique.

### DEC-11 — Changement de Ressource

La Ressource d’une Prestation existante est immuable. Pour remplacer la
personne : clôturer l’ancienne Prestation puis en créer une nouvelle.

### DEC-12 — Interne et externe

Un seul `RessourceProfile`, avec un type `INTERNAL` ou `EXTERNAL`. Une Ressource
externe peut être liée à une Société ayant le rôle fournisseur.

### DEC-13 — Priorité et statut du Besoin

`P1`, `P2`, `P3` sont des priorités. Le statut décrit le cycle :
`ouvert, staffing, pourvu, suspendu, fermé`.

### DEC-14 — Projet depuis un Candidat

Il n’existe pas de création directe d’un Projet lié à un Candidat. Le chemin est :
Candidat → Positionnement → conversion en Ressource → Projet → Prestation.

### DEC-15 — Action

Une Action est transversale et possède exactement un porteur parmi Société,
Contact, Candidat, Ressource, Besoin ou Projet.

### DEC-16 — Planning

Planning, occupation et charge sont des vues calculées depuis les Prestations,
Absences, Positionnements et Temps. Ce ne sont pas des sources de vérité
parallèles.

### DEC-17 — Droits

Les droits viennent de groupes et permissions appliqués par commande et
périmètre. L’union des groupes donne les droits effectifs. Cacher un bouton ne
constitue pas une autorisation.

### DEC-18 — Historique

Les commandes importantes écrivent un événement métier distinct des logs
techniques. Les objets portant un historique sont archivés, pas supprimés.

## 5. Questions réellement ouvertes

Brain doit d’abord chercher la réponse dans les deux cahiers des charges. Si la
réponse existe mais se contredit, il présente le conflit et recommande une
décision. Il ne demande à Ahmed que ce qui reste indécidable.

1. Structure Société : niveaux fixes Pôle / BU / Service, ou arbre générique
   `OrganizationUnit` ?
2. Quand un Besoin ouvre plusieurs Projets, comment répartir les
   positionnements et prestations entre ces projets ?
3. Charge supérieure à 100 % : calcul par jour, semaine ou mois, et comment
   traiter les périodes qui ne se chevauchent pas ?
4. Définitions exactes de CA signé, prévisionnel, produit et facturé.
5. Formules exactes : jours ouvrés, occupation, TJM, CJM, frais,
   investissements, marge et gestion des devises.
6. Matrice complète rôle × commande × périmètre.
7. Détection et traitement des doublons pour Personne, Candidat, Ressource,
   Contact et Société.
8. Contenu exact d’un événement d’historique et liste des changements à
   journaliser.
9. Périmètre V1 : quelles fonctions du cahier 2022 sont noyau, version
   suivante ou abandonnées ?
10. Processus de recrutement configurable : nécessaire en V1 ou cycle court
    figé pour commencer ?

### Chantier obligatoire — rôles et périmètres

Les rôles ne sont pas une simple règle `RULE-018`. Ils constituent un catalogue
métier et une matrice de décisions à part entière.

Le cahier 2022 cite au minimum :

- Responsable Recrutement ;
- Ressource Humaine ;
- Ingénieur d’affaires ;
- Évaluateur ;
- Administrateur ;
- Candidat ;
- Support.

Le cadrage actuel utilise aussi Commercial, Staffing / Directeur de projet et
Ressource en self-service. Brain doit réconcilier ces appellations sans supposer
qu’elles sont synonymes.

Pour chaque rôle, Brain doit établir :

- son objectif métier ;
- les objets qu’il peut voir selon son périmètre ;
- les commandes qu’il peut exécuter ;
- les transitions d’état qu’il peut déclencher ;
- les données sensibles métier qu’il peut modifier ;
- ses capacités de validation ou d’approbation ;
- le comportement lorsqu’un utilisateur appartient à plusieurs groupes ;
- les surcharges explicites autorisées ;
- les opérations self-service ;
- les refus attendus.

Le simulateur devra permettre de choisir un compte, ses groupes et son
périmètre, puis appliquer la même matrice à toutes les commandes. Les trois
comptes actuels sont des exemples, pas le catalogue complet.

## 6. Corrections connues du simulateur actuel

Le simulateur HTML n’est pas un oracle métier :

- Sophie, compte RH sans `CreateCompany`, peut créer une Société ;
- Karim peut créer un Projet depuis un Besoin encore ouvert sans
  positionnement retenu ;
- les scénarios valident des étapes indépendantes sans appliquer les étapes
  précédentes au même monde ;
- la charge ne tient pas compte des dates de chevauchement ;
- le monde simulé annonce une Personne centrale mais stocke encore séparément
  candidats et ressources ;
- les trois comptes de démonstration ne couvrent pas les rôles du cahier 2022 ;
- la permission générique n’est pas branchée sur toutes les commandes ;
- aucun périmètre agence / pôle / équipe n’est réellement simulé ;
- plusieurs opérations annoncées n’ont aucun effet réel, notamment les Temps.

Brain doit utiliser ces points comme cas rouges à corriger dans la spécification,
pas comme décisions produit.

## 7. Partie LinkedIn — état exact

Les trois suites de tests locales du userscript passent.

Ce qui existe :

- collecte de profils LinkedIn accessibles ;
- extraction nom, titre, lieu, URL et libellé de recherche ;
- déduplication, arrêt/reprise et export CSV.

Ce qui n’existe pas encore par rapport aux US 3 et 4 de 2024 :

- création réelle d’un Candidat dans Ava Manager ;
- création réelle d’un Contact dans Ava Manager ;
- choix Candidat / CRM dans l’extension ;
- recherche de doublon côté Ava ;
- récupération fiable de l’email, du téléphone, du CV ou du DT ;
- transfert via une API Ava.

Cette partie est un chantier séparé. Elle ne doit pas déterminer le modèle du
noyau métier.

## 8. Format attendu du travail de Brain

### A. Registre des règles

Pour chaque règle :

- identifiant stable ;
- objet ou commande ;
- acteur ;
- préconditions ;
- données d’entrée ;
- résultat autorisé ;
- refus et message métier ;
- effets secondaires ;
- événement d’historique ;
- exemples valide, limite et invalide ;
- statut : `ACQUISE`, `PROPOSÉE` ou `QUESTION`.

### B. Simulations

Chaque simulation part d’un état initial, exécute les commandes dans l’ordre et
vérifie l’état final. Minimum :

1. placement d’une Ressource déjà active ;
2. Candidat retenu puis converti ;
3. Besoin ouvrant deux Projets ;
4. Ressource partagée 60/40 sur deux missions ;
5. surcharge avec périodes qui se chevauchent ;
6. mêmes charges sur des périodes sans chevauchement ;
7. remplacement d’une Ressource en cours de mission ;
8. clôture Prestation puis Projet ;
9. tentative interdite Candidat → Prestation ;
10. tentative par un rôle sans permission ;
11. création de Besoin sans Contact ;
12. archivage d’un objet portant un historique.
13. même commande autorisée dans son périmètre et refusée hors périmètre ;
14. utilisateur appartenant à deux groupes : union des permissions ;
15. parcours de validation entre créateur, évaluateur et approbateur.

### C. Sortie de séance

Brain rend uniquement :

1. les règles acquises ;
2. la matrice rôles × commandes × périmètres ;
3. les contradictions trouvées ;
4. les simulations passées ou non définies ;
5. les questions restantes, sans répéter les décisions DEC-01 à DEC-18 ;
6. les cinq prochaines actions dans l’ordre.

## 9. Prompt court à donner à Brain

> Lis intégralement `_ops/BRIEF_BRAIN_2026-09-16.md`, puis les sources qu’il
> référence dans l’ordre indiqué. Nous sommes en phase de cadrage métier :
> ne code rien. Considère DEC-01 à DEC-18 comme décidées par Ahmed et ne les
> rouvre qu’en présence d’une contradiction précise, que tu dois citer.
> Construis le registre des règles et la matrice rôles × commandes × périmètres,
> puis simule les quinze
> scénarios séquentiellement. Commence par répondre toi-même aux questions
> ouvertes à partir des cahiers des charges. Ne demande à Ahmed que les choix
> réellement indécidables. Termine par les contradictions, les questions encore
> ouvertes et les cinq prochaines actions.
