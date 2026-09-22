# Transmission à la session de cadrage Ava Manager

**Statut : historique.** Rédigée le 16 septembre 2026 en fin d’après-midi, **avant** la feuille F1–F36 et la convention ATL. Ne plus l’exécuter comme liste de corrections. Ne pas la citer comme canon.

Canon actuel : [CADRAGE_METIER_RECONCILIE_2026-09-16.md](CADRAGE_METIER_RECONCILIE_2026-09-16.md).  
Pièce de décision F1–F36 (texte original d’Ahmed) : [FEUILLE_F1-F36_AHMED_2026-09-16.md](FEUILLE_F1-F36_AHMED_2026-09-16.md).  
Hub : `https://ahmedbentaleb.github.io/ava-boond-hub/?v=coh#ava-metier`

---

Objet d’origine : reprendre le cadrage métier avec les décisions déjà prises par Ahmed et les corrections de l’audit. Ce fichier est une note de transmission, pas une nouvelle décision d’Ahmed. Aucun développement n’est demandé à cette étape.

## Sources à lire

1. [Brief canonique et DEC-01 à DEC-18](BRIEF_BRAIN_2026-09-16.md). C’est la référence des décisions actuelles.
2. [SPEC fonctionnelle 2024](../AVA%20MANAGER-SPEC%201.docx), notamment US1, US2, US5 et US6.
3. [Cahier COCKPIT2 2022](../COCKPIT2-Cahier%20de%20charge-v0.1.docx), notamment définitions, rôles, droits, organisation cliente et atelier finance.
4. [Fonctionnement Boond](cartographie/FONCTIONNEMENT_BOOND.md), [diagnostic métier](cartographie/DIAGNOSTIC_METIER.md) et [audit d’écrans](cartographie/AUDIT_ECRANS.md). Ce sont des observations, pas des décisions Ava.
5. [Cadrage réconcilié et quinze simulations](CADRAGE_METIER_RECONCILIE_2026-09-16.md). **Devenu le canon** après F1–F36 et ATL ; la phrase « document de travail à corriger » ci-dessous est datée.
6. [Plan précédent](PLAN_2026-09-16.md), à consulter pour comprendre les anciennes références R01–R34 et P01–P15, pas pour rétablir ses « PASS » non démontrés.

Le [hub publié](https://ahmedbentaleb.github.io/ava-boond-hub/?v=coh#ava-metier) contient les vues « Métier », « Contrats », « 15 parcours », « Qui décide » et « Décisions ».

## Décisions d’Ahmed à conserver sans nouvelle question

DEC-01 à DEC-18 restent applicables intégralement. En particulier :

| Sujet | Décision déjà prise |
|---|---|
| Identité | Une Personne commune, avec profils Candidat et Ressource distincts. Conversion sans copie ni suppression de l’identité et de l’historique candidat. |
| Production | Un candidat ne porte jamais prestation ni temps. Une prestation associe Projet et Ressource ; la ressource d’une prestation ne change pas après création. |
| Positionnement | Un Besoin et exactement un humain : Candidat ou Ressource. |
| Besoin | Société obligatoire, Contact facultatif. P1–P3 sont des priorités ; le cycle décidé est ouvert, staffing, pourvu, suspendu, fermé. |
| Projets | Un besoin peut ouvrir plusieurs projets. Aucun projet n’est créé silencieusement parce qu’un positionnement est retenu ou qu’un besoin est pourvu. Création explicite avec confirmation des conditions. Pas de projet directement lié à un candidat. |
| Économie | Ressource : coût de référence et TJM indicatif éventuel ; Positionnement : TJM proposé ; Prestation : TJM vendu et coût retenu pour la mission. Marge courante recalculée, snapshot figé à clôture. |
| Charge | Plusieurs prestations simultanées sont autorisées ; dépassement de 100 % = alerte, pas refus automatique. Ressource INTERNAL ou EXTERNAL dans un seul type de profil. |
| Transversal | Action à un seul porteur métier ; planning/charge/occupation dérivés des prestations, absences, positionnements et temps ; permissions par commande et périmètre, union des groupes ; événement métier et archivage des objets historiques. |

Le hub conserve aussi douze anciennes questions marquées « décidées par Ahmed ». Elles correspondent largement à ces DEC : par exemple ancienne Q2 = Besoin vers N Projets, ancienne Q3 = projet non automatique, ancienne Q6 = prestations simultanées, ancienne Q11 = contact facultatif du besoin. **Ne pas confondre ces anciennes Q1–Q12 avec les nouvelles Q1–Q6** du cadrage réconcilié. Renommer les anciennes réponses ou afficher explicitement leur équivalence aux DEC avant de citer un numéro de question.

## Réponses déjà trouvées dans les cahiers

- Le service d’une société peut être sous une BU, un pôle ou directement sous la société. Une représentation hiérarchique variable est fondée ; le choix technique d’une table générique n’est pas une nouvelle décision métier à demander.
- Une qualification de candidat se rattache à un besoin. Pour un recrutement sur profil, le CdC prévoit un besoin de l’agence.
- Un contact peut exister au niveau de sa société sans unité organisationnelle connue. Le transfert de société ou d’unité du contact demande de traiter explicitement ses besoins et projets en cours.
- Un service ne s’archive pas tant qu’il a des besoins ou projets en cours ; ses liens et son historique restent accessibles depuis la société après archivage.
- La qualité de client remonte de la branche contractante vers ses ascendants et concerne les contacts du service. Le CdC ne dit pas que les branches sœurs deviennent clientes.
- La SPEC 2024 permet la création directe d’une ressource et d’un projet. Ces parcours doivent respecter les DEC sur Personne, RessourceProfile et Prestation ; il ne faut pas les supprimer simplement parce que le projet peut aussi naître d’un besoin.
- L’US5 de la SPEC rend le contact obligatoire **dans le formulaire de création manuelle d’un projet**. L’US6 concerne le projet issu d’un besoin et ne définit pas la conduite à tenir lorsque ce besoin n’a pas de contact. Voir correction prioritaire ci-dessous.
- La note finance du CdC renvoie explicitement le détail des calculs à un atelier. Les objets peuvent être décrits, mais les résultats chiffrés de marge ou d’occupation réelle ne sont pas validés sans convention.

## Corrections impératives du document de travail et du hub

1. **Contact sur Projet.** Le cadrage réconcilié, notamment BM-26/BM-27 et sa section « Réponses possibles sans Ahmed », généralise l’obligation de contact d’US5 à tous les projets. Ce n’est pas démontré pour `CreateProjectFromNeed` issu d’un besoin sans contact, cas autorisé par DEC-04. Garder l’obligation explicite d’US5 pour le parcours manuel ; qualifier le parcours depuis besoin comme règle à arbitrer. Corriger aussi les mentions du hub qui déclarent la question entièrement résolue.
2. **Statuts des quinze parcours.** Les quinze scénarios partagent bien un monde cumulatif et couvrent les cas du brief. Ils sont des simulations de spécification, pas quinze tests logiciels passés. Plusieurs étapes utilisent des permissions attribuées pour l’exercice, un calcul journalier proposé, une garde de création de projet proposée ou un ordre de clôture proposé. Étiqueter chaque résultat « DEC/CdC », « sous hypothèse proposée » ou « non défini », sans appeler tout le parcours « acquis » quand une étape dépend d’un arbitrage.
3. **Rôles et approbation.** Les cahiers donnent des responsabilités générales, pas l’intégralité de la matrice de commandes. Sophie = RH, Nadia = RR et Karim = Staffing + DP constituent une configuration de démonstration. Le CdC ne rend pas obligatoire une commande distincte `ApproveRecruitment` par Nadia. Ne pas la mettre dans le parcours de base tant qu’Ahmed ne la demande pas. Léa évalue ; cela ne lui donne pas la conversion.
4. **Deux générations de questions.** L’ancien bloc Q1–Q12 du hub est marqué « décidé » ; la nouvelle liste Q1–Q6 reste ouverte. Employer des identifiants distincts et retirer les vieux textes qui disent que tout le modèle est figé. Dans la vue « Métier », la chaîne Société → Contact → Besoin doit signaler que le contact est facultatif sur le besoin ; la formule `WinNeed() puis CreateProjectFromNeed()` ne doit pas masquer le projet direct d’US5.
5. **Traçabilité des sources.** Dans le cadrage réconcilié, les deux liens Word commencent par `../../` depuis `_ops` ; les fichiers se trouvent à `../`. Réparer ces liens afin que la session puisse vérifier US5/US6 et le CdC.

## Arbitrages réellement restants

Les propositions suivantes ne sont pas des réponses déjà données par Ahmed. Présenter une recommandation et ses conséquences avant de lui demander de trancher ; ne pas reformuler une DEC en question oui/non.

| Référence nouvelle | Ce qui est déjà résolu | Reste à arbitrer ou à traiter en atelier |
|---|---|---|
| Q1 — Besoin, positionnement, projets | N projets possibles ; création explicite ; prestation sur un projet précis ; aucune duplication automatique imposée par les sources. Le positionnement candidat historique reste lisible après conversion. | Projet issu d’un besoin ouvert sans ressource retenue : permis, refusé ou exception explicitement confirmée ? Après conversion, faut-il un nouveau positionnement Ressource pour poursuivre, ou la création de prestation suffit-elle ? Que signifie « pourvu » pour un besoin multi-postes ? |
| Q2 — Calculs et production | Marge figée à clôture ; dépassement de charge = alerte ; le CdC prévoit un atelier finance. | Calendrier, capacité, jours vendus/réalisés, régie/forfait, frais, investissements, devises, CA signé/prévisionnel/produit/facturé, validation et correction des temps. Aucune marge chiffrée définitive avant l’atelier. |
| Q3 — Doublons | Une Personne porte ses profils ; cela ne fournit pas une politique de rapprochement de deux Personnes distinctes. | Clés de détection par objet, avertissement ou blocage, responsabilité et procédure de fusion. Ne pas fusionner automatiquement sur le seul email. |
| Q4 — Statut Client | La propagation vers le haut de la branche signataire et vers ses contacts est décrite par le CdC. | Après le dernier contrat : maintien Client, retour Prospect immédiat ou après délai, et qui peut corriger manuellement. Le « six mois » du CdC est une question, pas une règle. |
| Q5 — Premier périmètre livré | Les sources décrivent CRM, recrutement, staffing et production ; les DEC fixent leurs invariants. | Choix de version : recommandation d’un parcours complet CRM → candidat/ressource → positionnement → projet → prestation → temps, avec droits et historique ; différer éditeur avancé, LinkedIn intégré, emailing, portail et facturation avancée si Ahmed accepte ce découpage. |
| Q6 — Permissions opérationnelles | Union des groupes par permission et périmètre ; RR gère le processus, RH gère les candidats, évaluateur qualifie, IA gère clients/besoins selon CdC. | Mapping Commercial/IA, cumul Staffing/DP, délégation exacte de conversion et des données sensibles, validation des temps/absences, surcharges restrictives, assistance active Support. L’approbation supplémentaire de Nadia est facultative, non prescrite par les sources. |
| Complément Projet sans contact | US5 exige le contact pour la création manuelle ; DEC-04 autorise le besoin sans contact. | Pour `CreateProjectFromNeed` dans ce cas : demander un contact au moment de créer le projet ou permettre un projet sans contact ? Ce point peut être tranché avec Q1 ; ne pas affirmer qu’US5 tranche les deux parcours. |

## Travail attendu de la session de cadrage

1. Reprendre le registre en gardant DEC-01 à DEC-18 et les réponses des cahiers ci-dessus. Marquer toute règle de complétion comme **proposée** tant qu’elle n’est pas acceptée ; aucun « acquis » obtenu par simple cohérence apparente.
2. Corriger les contradictions BM-26/BM-27 et celles du hub, puis réviser les quinze parcours et la matrice avec leurs hypothèses. Pour le parcours 15, arrêter l’état certain après la qualification et le refus de conversion par l’évaluatrice ; montrer l’approbation Nadia seulement comme variante facultative.
3. Préparer une courte fiche d’arbitrage pour Q1/Q6 et la variante Projet sans contact, avec recommandation et effet sur les parcours. Regrouper les décisions liées ; ne pas poser à Ahmed quinze questions dispersées.
4. Proposer le lot V1 Q5 avec les exigences différées explicitement conservées. Préparer ensuite la politique Q3/Q4 pour les fonctions effectivement retenues.
5. Tenir l’atelier Q2 et rejouer les quinze parcours avec les conventions choisies. Après validation du contrat métier seulement, établir un modèle conceptuel. Aucun schéma physique, simulateur ou interface à développer dans cette phase.

Livrable de cette session : un registre corrigé, une matrice qualifiée, quinze états séquentiels avec hypothèses visibles, la liste courte des seuls arbitrages qui restent et un ordre de travail. **Ne pas présenter les recommandations de cette note comme des décisions déjà prises par Ahmed.**
