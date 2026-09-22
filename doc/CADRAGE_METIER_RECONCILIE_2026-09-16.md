# Cadrage métier réconcilié Ava Manager

Date de lecture : 16 septembre 2026. Canon de cette version : ce fichier. Pièce de décision F1–F36 (texte original d’Ahmed) : [FEUILLE_F1-F36_AHMED_2026-09-16.md](FEUILLE_F1-F36_AHMED_2026-09-16.md). La [note de transmission](TRANSMISSION_SESSION_CADRAGE_2026-09-16.md) est un **historique du 16 sept en fin d’après-midi**, antérieur à la feuille et à ATL : ne plus l’exécuter comme liste de corrections.

Les décisions DEC-01 à DEC-18 restent applicables et **ne se rouvrent pas**. Le 16 septembre 2026 au soir, Ahmed a tranché la feuille **F1–F36**. L’atelier chiffres **ATL** clôt F35–F36 : les **formules** sont nommées ; aucun tarif Avaliance n’a été saisi, donc **aucun euro d’exemple n’est certifié**. Aucun code produit. Les quinze parcours sont des simulations de spécification, pas quinze tests logiciels passés.

## Sources et statut des règles

Sources lues dans l’ordre prescrit après lecture initiale du brief :

1. [SPEC 2024](../AVA%20MANAGER-SPEC%201.docx), US1 à US8 et personnalisation des emails. Lecture du texte et des tableaux du DOCX, des onze illustrations et des commentaires. Un commentaire d’US5 demande d’ajouter la ressource au niveau des prestations lors de la création.
2. [CdC 2022](../COCKPIT2-Cahier%20de%20charge-v0.1.docx), sections II à IV, avec sa note de bas de page qui réserve la finance à un atelier métier. Le diagramme du statut client distingue explicitement la branche cliente des branches sœurs restées prospects.
3. [Fonctionnement Boond](cartographie/FONCTIONNEMENT_BOOND.md).
4. [Diagnostic métier](cartographie/DIAGNOSTIC_METIER.md).
5. [Audit des écrans](cartographie/AUDIT_ECRANS.md), intégralité du texte. Le document décrit 33 écrans, et non les 59 fichiers image présents dans le dossier. Il indique lui-même que l’audit n’est pas clos.
6. [Brief canonique](BRIEF_BRAIN_2026-09-16.md), relu après les sources.

Le [plan précédent](PLAN_2026-09-16.md) est confronté à ces sources ; il ne les remplace pas.

Dans ce document : **ACQUISE** signifie explicitement décidée dans les DEC, dans la feuille **F1–F36**, ou dans la convention **ATL**. **PROPOSÉE** désigne une règle de complétion encore non signée. **DIFFÉRÉ** = exigence au backlog, hors V1. Les observations Boond ne deviennent pas automatiquement des exigences Ava.

Les identifiants BM sont stables pour cette édition. La correspondance avec R01–R34 et P01–P15 est donnée après le registre ; ces anciennes références ne sont pas réutilisées avec un sens différent.

Pour toutes les commandes, les règles de droits BM-41 à BM-45 et d’historique BM-46 s’appliquent. Un refus ne modifie pas l’état métier ; son motif est présenté à l’utilisateur. Une tentative refusée peut être tracée comme telle, mais ne produit jamais un événement de réussite. Les noms d’événements et les textes de refus ci-dessous sont des propositions de vocabulaire. Les attributions de commandes aux rôles sont détaillées et qualifiées dans la matrice : elles ne deviennent pas des DEC par leur présence dans le registre.

Dans chaque règle, **V / L / I** désignent respectivement un exemple valide, limite et invalide. « Aucun autre effet » exclut notamment les créations implicites non décrites. Les opérations en lot appliquent les mêmes invariants à chaque objet ; leur politique de réussite partielle reste à spécifier si elles entrent en V1.

## Registre complet des règles

### Identité et recrutement

**BM-01 — Identité commune — ACQUISE, DEC-01.** Objet : Personne et profils. Acteur : créateur habilité. Entrées : identité et type de profil demandé ; précondition : identité à créer ou Personne existante explicitement sélectionnée. Résultat : identité commune, profils Candidat et Ressource distincts rattachés à cette Personne. Refus : « Le profil doit être rattaché à une personne. » Effet : aucun clonage d’identité ; événements proposés `PersonCreated`, `ProfileAttached`. V : création candidat ; L : même personne avec les deux profils ; I : conversion créant une seconde identité.

**BM-02 — Unicité des profils d’une personne — PROPOSÉE, précision de DEC-01.** Commande : attacher un profil. Acteur : RH habilitée. Entrées : personne, type ; précondition : absence de profil de ce type. Résultat : au plus un profil Candidat et un profil Ressource par personne. Refus : « Ce profil existe déjà ; ouvrez-le. » Effet : aucune seconde fiche ; `ProfileAttached` seulement à la première création. V : ajout Ressource ; L : répétition retournant la fiche existante sans création ; I : deuxième Ressource sur la même personne. Cette règle ne résout pas la détection de deux Personnes représentant le même humain.

**BM-03 — Candidat hors production — ACQUISE, DEC-02 et DEC-14.** Commandes : créer une prestation, enregistrer des temps ou créer un projet depuis un candidat. Acteur : tout utilisateur. Entrée : candidat seul ; précondition de production non satisfaite. Résultat : refus « Convertissez d’abord le candidat en ressource ; créez ensuite le projet et la prestation par leurs commandes. » Effet : zéro projet, prestation ou temps ; aucun événement de réussite. V : positionner le candidat ; L : personne ayant aussi un profil Ressource, utilisé explicitement ; I : prestation portant le profil Candidat.

**BM-04 — Création et enrichissement du candidat — ACQUISE, CdC IV.B.1–2.** Acteur : RH ou autre contributeur habilité. Entrées : nom, prénom, civilité, localisation, mail et/ou téléphone, puis CV, formation, expérience, compétences, références et prétentions. Précondition : droit sur l’onglet. Résultat : fiche Draft hors processus, puis enrichissement. Refus : « Vous ne pouvez pas modifier cet onglet » ; impossible de retirer une donnée rendue obligatoire à une étape déjà franchie. Effet : historique ; `CandidateCreated`, `CandidateUpdated`. V : création avec coordonnées ; L : dossier Draft incomplet sur ses compétences ; I : effacer une donnée obligatoire après transition. La liste détaillée des champs bloquants de création doit être distinguée des champs simplement demandés.

**BM-05 — Transitions du candidat — ACQUISE, CdC IV.B.3 et II.J, cycle V1 = F19.** Acteur : détenteur du droit de transition défini par le processus. Entrées : candidat, transition, champs requis ; précondition : transition applicable et champs obligatoires renseignés. Résultat : nouvel état. Le CdC distingue **Draft** et **Complété** ; un motif de complétion peut exister. **La conversion n’est pas un troisième statut candidat** : c’est la commande BM-06 (ou un motif), pas une étape de cycle. Refus : « Complétez les champs requis pour cette transition. » Effet : conservation des données et historique ; `CandidateStateChanged`. V : Draft vers Complété ; L : Complété pour un motif autre que conversion ; I : inventer un statut « Converti » à la place de BM-06. Éditeur de process souple : hors V1 (F16).

**BM-06 — Conversion explicite — ACQUISE, DEC-01/02, SPEC US2 RG1–4, F9.** Acteur : RH (Sophie dans la config) ; RR seulement par délégation. Pas d’étape Nadia `ApproveRecruitment` (F10). Entrées : candidat, confirmation et informations nécessaires au profil Ressource. Préconditions : candidat existant, confirmation et profil Ressource non déjà créé selon BM-02. Résultat : activation du profil Ressource sur la même Personne, identité et historique candidat conservés. Refus/annulation : « Conversion annulée » sans changement, ou « Profil ressource déjà présent ». Effet : aucun projet ni prestation ; `CandidateConverted`. V : confirmer ; L : annuler puis confirmer ultérieurement ; I : supprimer le candidat ou recopier son identité comme nouvelle personne.

**BM-07 — Création directe d’une ressource — ACQUISE, SPEC US1 compatible avec DEC-01/12.** Acteur : contributeur Ressource habilité. Entrées : civilité, nom, prénom, titre et type obligatoires ; managers, agence, coordonnées, disponibilité et mobilité selon formulaire. Précondition : Personne créée ou sélectionnée. Résultat : profil Ressource ; type INTERNAL ou EXTERNAL. Refus : « Renseignez les champs obligatoires de la ressource. » Effet : pas de candidat imposé ; `ResourceProfileCreated`. V : interne créé directement ; L : externe lié à une société fournisseur ; I : obligation inventée de passer par le recrutement. EUR/USD/MAD sont les devises citées ; les formats téléphone/adresse nécessitent la correction BM-58.

**BM-08 — Données propres à la ressource — ACQUISE, SPEC US1 et DEC-08/12.** Acteur : contributeur autorisé aux informations concernées. Entrées : état En cours/Intercontrat/Sortie, disponibilité, managers, coût de référence, TJM indicatif et devise. Précondition : ressource existante. Résultat : fiche actualisée. Refus : « Vous ne pouvez pas modifier ces informations RH ou économiques. » Effet : aucune réécriture des conditions historiques de prestation ; `ResourceUpdated`. V : coût de référence actualisé ; L : ressource sans mission ; I : répercuter ce coût sur une mission clôturée. L’état En cours/Intercontrat/Sortie est **saisi à la main** en V1 (F26) ; pas de calcul automatique depuis les missions.

**BM-09 — Qualification contextualisée — ACQUISE, CdC II.K et IV.B.5.** Acteur : évaluateur habilité. Entrées : candidat, besoin, type, compétences, notes, commentaires et éléments non mesurés. Précondition : besoin existant ; recrutement sur profil rattaché à un besoin de l’agence. Résultat : qualification contextualisée ; critères préremplis depuis le besoin, ajouts possibles. Refus : « Sélectionnez le besoin de cette qualification. » Effet : mise à jour de la vue des compétences ; `QualificationRecorded`. V : technique pour N1 ; L : compétence non mesurée, sans l’assimiler à zéro ; I : qualification flottante. Le CdC demande qu’une nouvelle mesure remplace la valeur affichée de la même compétence ; BM-46 conserve les mesures historiques.

**BM-10 — Processus de recrutement — ACQUISE, CdC II.J et IV.F.** Acteur : RR possesseur de la fonctionnalité. Entrées : processus source, étapes, transitions, habilitations, champs requis, périmètre agence/poste/séniorité/secteur/client. Préconditions : droits et étape de conversion préservée. Résultat : brouillon, édition versionnée, puis publication pour les futurs recrutements ; processus le plus spécifique applicable. Refus : « La conversion ne peut pas être supprimée. » Effet : pas de migration silencieuse des dossiers en cours ; `RecruitmentProcessDrafted`, `RecruitmentProcessPublished`. V : publier une variante client ; L : ancienne version encore utilisée ; I : supprimer la conversion. Égalité de spécificité et migration des dossiers : BM-61, **hors V1** (éditeur différé, F16).

### Société et contacts

**BM-11 — Société et rôles commerciaux — ACQUISE pour la création Prospect, CdC IV.C.1 ; PROPOSÉE pour le cumul des rôles, observations Boond.** Acteur : IA ou contributeur CRM. Entrées : identité et coordonnées société, rôles. Précondition : autorisation. Résultat : société, statut initial Prospect ; recommandation : fournisseur est un rôle distinct pouvant coexister avec client. Refus : « Renseignez l’identité de la société. » Effet : aucun besoin ou contrat automatique ; `CompanyCreated`. V : prospect ; L : client également fournisseur ; I : dupliquer la même société uniquement pour ses deux rôles. La détection des doublons relève de BM-57.

**BM-12 — Organisation cliente variable — ACQUISE, CdC II.C–D et IV.C.2–3.** Acteur : contributeur CRM. Entrées : société, parent, type, nom, description. Précondition : parent appartenant à la société. Résultat : pôle, BU ou service ; service sous BU, pôle ou directement sous société. Refus proposé : « Le parent doit appartenir à cette société ; la hiérarchie ne peut pas être cyclique. » Effet : navigation contacts/besoins/projets ; `OrganizationUnitCreated/Updated`. V : service sous BU ; L : service directement sous société ; I : cycle. La représentation générique OrganizationUnit est recommandée ; les agences internes et la structure du client ne sont pas une même hiérarchie par défaut.

**BM-13 — Contact lié à une société — ACQUISE, CdC II.E et IV.C.5–6.** Acteur : IA/contributeur CRM. Entrées : société, identité, poste, coordonnées, périmètres techniques/fonctionnels, unité facultative. Précondition : société existante. Résultat : contact lié, unité renseignée si connue. Refus : « Choisissez la société du contact. » Effet : aucun besoin automatique ; `ContactCreated/Updated`. V : contact d’un service ; L : société connue sans unité connue ; I : contact sans société. Le rattachement obligatoire à une unité pour créer un besoin est remplacé par DEC-04.

**BM-14 — Transfert d’un contact — ACQUISE, CdC IV.C.7.** Acteur : contributeur CRM habilité sur origine et destination. Entrées : contact, nouvelle société ou unité et réaffectations des besoins/projets en cours. Précondition : inventaire de ces objets et choix de leurs nouveaux services/contacts. Résultat : contact transféré ; objets actifs réaffectés explicitement. Refus proposé : « Traitez les besoins et projets en cours avant de terminer le transfert. » Effet : historique des rattachements conservé ; `ContactTransferred` et événements des objets concernés. V : transfert avec réaffectation ; L : aucun objet actif ; I : déplacer silencieusement un projet client vers la nouvelle société du contact.

**BM-15 — Statut Client ascendant — ACQUISE, CdC II.F et IV.C.2.** Acteur : système à partir d’un contrat signé. Entrées : service contractant, contrat, ascendants. Précondition : rattachement connu. Résultat : service, BU, pôle et société deviennent clients ; contacts du service également. Refus de propagation implicite : « Aucun contrat ou rattachement ne justifie ce changement. » Effet : pas de propagation aux branches sœurs ; `ClientStatusDerived`. V : Service31 client et Contact42 client sans contrat personnel ; L : Pôle2 reste prospect ; I : tous les services deviennent clients parce que la société l’est. Le retour Prospect et les corrections manuelles relèvent de BM-16.

**BM-16 — Retour Prospect et dérogation manuelle — ACQUISE, F23–F24.** Acteur : responsable CRM habilité. Entrées : requalification manuelle écrite. Résultat : le statut Client **reste** après la fin du dernier contrat jusqu’à cette requalification. Refus : aucun déclassement automatique (immédiat ou à six mois). Effet : `ClientStatusOverridden` seulement sur correction tracée. V : Alpha reste cliente, contrat clos ; L : contrat terminé hier ; I : repasser Prospect tout seul au bout de six mois (exemple du CdC = question, pas règle).

**BM-17 — Archivage d’un service — ACQUISE, CdC IV.C.4 et DEC-18.** Acteur : contributeur habilité à archiver. Entrées : service et motif proposé. Précondition : aucun besoin ni projet en cours. Résultat : service archivé, retiré de l’organisation active ; contacts, besoins et projets restent accessibles depuis la société. Refus : « Ce service porte encore des besoins ou projets en cours. » Effet : aucun effacement d’historique ; `ServiceArchived`. V : service sans activité en cours ; L : ancien projet clos conservé ; I : archivage masquant un projet actif.

### Besoin et positionnement

**BM-18 — Création du besoin — ACQUISE, DEC-04 et CdC II.H/IV.D.** Acteur : IA/contributeur habilité. Entrées : société, objet et contexte, contact facultatif, compétences/niveaux/obligatoires, informations tarifaires. Précondition : société existante. Résultat : besoin ouvert, consultable et positionnable. Refus : « Choisissez une société pour le besoin. » Effet : aucun projet ; `NeedCreated`. V : besoin avec contact ; L : besoin sans contact ni unité ; I : blocage pour absence de contact. Un besoin interne de recrutement sur profil peut être lié à l’agence, conformément au CdC II.K.

**BM-19 — Cohérence du contact de besoin — PROPOSÉE, cohérence CdC II.H + DEC-04.** Acteur : contributeur Besoin. Entrées : société, contact facultatif. Précondition : si présent, contact rattaché à cette société. Résultat : rattachement cohérent. Refus : « Ce contact appartient à une autre société. » Effet : aucun transfert automatique du contact ; `NeedContactChanged`. V : contact Alpha sur besoin Alpha ; L : contact retiré, besoin conservé ; I : contact Beta sur Alpha. Un intermédiaire de facturation sur un projet est un rôle différent et ne justifie pas de contourner cette règle.

**BM-20 — Priorité et cycle du besoin — ACQUISE, DEC-13.** Acteur : contributeur habilité. Entrées : priorité P1/P2/P3 ou état ouvert/staffing/pourvu/suspendu/fermé. Précondition : besoin existant, transition autorisée. Résultat : une dimension modifiée sans écraser l’autre. Refus : « Cette valeur n’appartient pas au cycle du besoin. » Effet : aucun projet automatique ; `NeedPriorityChanged`, `NeedStateChanged`. V : P1 et staffing simultanés ; L : besoin pourvu toujours lié à ses projets ; I : état P1 ou gagné ajouté au cycle. Le graphe précis de transitions est BM-60 (F6/F3). « Gagnée » n’entre pas dans le cycle.

**BM-21 — Positionnement unitaire — ACQUISE, DEC-03, CdC IV.B.4/IV.D.3/IV.E.1.** Acteur : IA, RH ou Staffing habilité. Entrées : besoin et exactement un profil Candidat ou Ressource, état initial et tarif proposé éventuel. Précondition : besoin et profil existants. Résultat : un positionnement par couple proposé ; plusieurs besoins ou humains produisent plusieurs positionnements. Refus : « Choisissez un besoin et un seul profil. » Effet : aucun projet ni prestation ; `PositioningCreated`. V : candidat sur N1 ; L : même humain sur N1 et N2 ; I : candidat et ressource simultanément sur la même ligne. L’unicité historique du couple n’est pas spécifiée par les sources : pas de blocage inventé.

**BM-22 — Positionnement sur besoin non actif — ACQUISE, F5.** Acteur : contributeur Positionnement. Entrées : besoin et commande de positionnement. Précondition : besoin **ouvert ou staffing**. Sur pourvu, suspendu ou fermé : refus « Réactivez le besoin avant un nouveau positionnement. » Effet : aucune réouverture automatique ; `PositioningCreated` seulement si accepté. V : staffing ; L : reprise explicite d’un besoin suspendu ; I : nouveau matching sur fermé.

**BM-23 — Suivi du positionnement — ACQUISE, CdC IV.E et IV.G.4.** Acteur : contributeur du positionnement ; Admin pour le catalogue. Entrées : état, CV partagé, entretien, qualification, événements complémentaires. Précondition : positionnement existant. Résultat : trois suivis par défaut, état modifiable par utilisateur habilité ; types administrables. Refus : « Le suivi obligatoire de partage du CV ne peut pas être retiré. » Effet : voyants et historique ; `PositioningStateChanged`, `PositioningEventUpdated`. V : entretien planifié puis réalisé ; L : ajout d’un événement personnalisé ; I : supprimer un type standard protégé du catalogue. Les événements d’entretien et qualification peuvent être retirés d’un dossier selon IV.E, sans supprimer leurs types du catalogue IV.G ; cette lecture distingue les deux niveaux.

**BM-24 — Qualification et décision client — ACQUISE, CdC II.H et IV.D.3, F10–F11.** Acteurs : évaluateur pour la mesure ; IA pour enregistrer le retour client. **Pas d’approbateur interne** de recrutement (F10). Entrées : qualification, retour client, décision. Précondition : positionnement existant. Résultat : résultats et décision conservés séparément. Refus : « Une qualification seule ne vaut pas accord client. » Effet : aucune conversion implicite ; `QualificationRecorded`, `ClientDecisionRecorded`. V : bien évalué puis refusé par client ; L : compétence non mesurée ; I : score suffisant déclenchant automatiquement projet et prestation.

**BM-25 — Répartition sur plusieurs projets — ACQUISE, DEC-03/05/06 et F2.** Acteur : Staffing/DP habilité. Entrées : besoin, projet choisi, ressource issue du parcours, conditions de prestation. Préconditions : projet lié au besoin, ressource existante, confirmation. Résultat : positionnement conservé sur le besoin ; chaque prestation désigne explicitement un projet. Refus : « Choisissez le projet et les conditions de cette affectation. » Effet : aucune duplication automatique du positionnement ou de la prestation ; `PrestationCreated`. V : un projet sélectionné parmi deux ; L : deux prestations volontaires, charges distinctes ; I : même prestation recopiée sur tous les projets. Après conversion, **CreatePrestation suffit** si le profil Ressource existe (F2). Le matching candidat reste lisible (DEC).

### Projet et prestation

**BM-26 — Création explicite du projet — ACQUISE, DEC-05/06 et SPEC US5/US6 corrigée.** Acteur : détenteur CreateProject/CreateProjectFromNeed. Entrées : titre, agence, type Régie/Forfait, contact, société, paramètres contractuels confirmés ; besoin si création depuis besoin. Préconditions : références existantes et confirmation. Résultat : projet créé, lien au besoin conservé ; plusieurs projets possibles pour un besoin. Refus : « Confirmez les paramètres du projet. » Effet : ni clôture automatique du besoin ni affectation implicite ; `ProjectCreated`. V : deuxième projet du même besoin ; L : projet sans prestation initiale ; I : création silencieuse en passant le besoin à pourvu. La création directe reste permise par SPEC US5 et CdC II.I ; elle n’est pas une création depuis candidat.

**BM-27 — Contact et ressource selon le parcours de création — ACQUISE, US5 manuel, DEC-07, F4.** Acteur : créateur du projet. Entrées US5 (création manuelle) : contact obligatoire et société cohérente ; ressource uniquement si commande explicite de prestation. DEC-07 : pas de ressource structurelle unique sur le projet. Besoin **sans contact** (DEC-04) : `CreateProjectFromNeed` **demande un contact au moment du projet**, sans bloquer le besoin (F4). Refus projet : « Choisissez le contact du projet. » V : création manuelle avec Alice ; L : besoin Beta sans contact, projet créé dès qu’un contact est fourni à la commande projet ; I : ressource unique portée par Projet. Ne pas généraliser l’obligation US5 au besoin lui-même.

**BM-28 — Précondition de création depuis un besoin — ACQUISE, F1.** Acteur : Staffing/DP. Entrées : besoin, positionnement ressource retenu, paramètres du projet. Précondition : **positionnement ressource retenu** ; besoin non fermé. Résultat : création explicite sans modification du positionnement d’origine. Refus : « Aucun positionnement ressource retenu ne permet ce parcours. » Effet : aucun contournement implicite ; `ProjectCreated` si accepté. V : ressource retenue ; L : projet direct US5, commande distincte, sans cette garde ; I : candidat seul converti en prestation. Aucune exception nommée par Ahmed.

**BM-29 — Prestation comme affectation — ACQUISE, DEC-07/08/11 et SPEC US5.** Acteur : contributeur Prestation. Entrées : projet, ressource, état Signée/Prévisionnelle, début, fin, tarif journalier HT, jours vendus, taux d’occupation ; autres champs US5 facultatifs sauf règle explicite. Préconditions : projet et ressource existants, dates cohérentes proposées. Résultat : prestation liée à un projet et une ressource. Refus : « Choisissez un projet et une ressource, puis renseignez les conditions obligatoires. » Effet : charge et prévisions dérivées ; `PrestationCreated`. V : ressource externe ; L : prestation prévisionnelle ; I : candidat ou fin antérieure au début. États commerciaux et clôture opérationnelle sont deux dimensions à distinguer.

**BM-30 — Conditions économiques historisées — ACQUISE, DEC-08.** Acteur : détenteur du droit de tarification. Entrées : TJM proposé au positionnement, TJM vendu et coût retenu à la prestation, devise ; précondition : objet modifiable. Résultat : valeurs propres à chaque niveau. Refus : « Les conditions historiques ne peuvent pas être remplacées par le tarif courant de la ressource. » Effet : actualisation de la marge en activité, pas des prestations closes ; `PositioningPriced`, `PrestationPriced`. V : deux missions à tarifs différents ; L : tarif de référence change ensuite ; I : coût courant utilisé rétroactivement. La politique d’avenants à effet daté est proposée, pas décrite complètement par les sources.

**BM-31 — Simultanéité et surcharge — ACQUISE, DEC-10.** Acteur : contributeur Prestation ; système pour l’alerte. Entrées : affectations et taux sur périodes communes. Précondition : prestations valides. Résultat : plusieurs prestations autorisées ; somme supérieure à 100 % sur période commune signalée. Refus interdit : « Impossible car une autre prestation existe. » Effet : alerte sans annulation ; `PrestationCreated` et signal de surcharge. V : 60 % + 40 % ; L : exactement 100 %, sans alerte de dépassement ; I : additionner 60 % en avril et 50 % en juin pour annoncer 110 % simultanés.

**BM-32 — Calcul temporel de charge — ACQUISE, F29–F31 et ATL-01–04.** Acteur : système ; lecteurs habilités. Entrées : dates, taux, calendrier d’agence, absences et catégories. Occupation calculée **au jour**, affichée à la semaine ou au mois (F29). Capacité : **calendrier d’agence** (week-end et fériés, F30). Prestations **prévisionnelles incluses** dans l’occupation, distinguées du contractualisé/réalisé (F31). Aucun recouvrement signifie aucune surcharge simultanée. Refus : « Convention de calendrier ou de capacité manquante pour cet indicateur. » Effet : vue calculée ; aucun événement métier à chaque lecture. V : dépassement uniquement du 15 au 19 ; L : jour de frontière commun ; I : compter 7j/7 sans calendrier d’agence. Les euros suivent la convention ATL ; un agrégat multi-devises sans taux reste refusé.

**BM-33 — Remplacement d’une ressource — ACQUISE, DEC-11.** Acteur : contributeur habilité à clôturer puis créer. Entrées : prestation initiale, date de fin, nouvelle ressource et nouvelles conditions. Précondition : ancienne prestation existante. Résultat : ancienne clôturée, nouvelle créée ; identités et temps passés inchangés. Refus : « La ressource d’une prestation est immuable. » Effet : deux historiques et recalcul de charge ; `PrestationClosed`, `PrestationCreated`. V : Paul remplace Jean ; L : remplacement au milieu du mois ; I : remplacer resource_id sur la prestation de Jean.

**BM-34 — Clôture et marge figée — ACQUISE, DEC-09.** Acteur : contributeur de clôture. Entrées : prestation, date et éléments économiques utilisés. Précondition : prestation non clôturée et données nécessaires au calcul disponibles. Résultat : marge courante calculée durant l’activité ; snapshot conservé à clôture. Refus : « Cette clôture historique ne peut pas être recalculée avec de nouvelles valeurs de référence. » Effet : données et convention du calcul attachées au snapshot, proposition de complétion ; `PrestationClosed`. V : clôture puis hausse du CJM de référence sans effet historique ; L : marge nulle ; I : snapshot réécrit. Le montant suit ATL-11 au moment de la clôture. Une correction de temps après clôture (F34) ne réécrit **jamais** ce snapshot (DEC-09).

**BM-35 — Clôture du projet — ACQUISE, F7.** Acteur : DP habilité. Entrées : projet et date ; précondition : toutes les prestations clôturées. Résultat : projet clos ; clôture distincte de l’archivage. Refus : « Clôturez d’abord les prestations ouvertes. » Effet : pas de suppression ni de recalcul des snapshots ; `ProjectClosed`. V : projet sans prestation ouverte ; L : projet sans prestation ; I : clôturer avec une mission active. La **validation** des temps n’est pas une porte V1 : le CA produit régie utilise les temps **saisis** (ATL-06).

**BM-36 — Temps de production — ACQUISE, DEC-02, F32–F34.** Acteurs : ressource pour elle-même ; DP habilité sur son périmètre. Entrées : prestation, date, quantité, auteur et ressource. Préconditions : prestation **de cette ressource** (F32), période autorisée et droit de saisie. Résultat : ligne de temps persistante. Temps interne/intercontrat sans prestation : **hors V1** (F33). Correction **après clôture** de la prestation : autorisée comme **ajustement distinct tracé** (F34) ; elle ne réécrit jamais le snapshot de marge (DEC-09). Refus : « Cette prestation ne correspond pas à la ressource ou à la période autorisée. » Effet : `TimesheetRecorded/Corrected` ; l’ajustement post-clôture a son propre événement. V : temps sur sa mission ; L : externe saisissant ses temps ; I : temps sur candidat, ou réécriture silencieuse de M1. Valorisation CA produit : ATL-06 (saisis × TJM vendu).

**BM-37 — Absence indépendante d’une prestation — ACQUISE, DEC-16 et F25.** Acteurs : ressource pour elle-même, gestionnaire habilité. Entrées : ressource, période, quantité et type ; précondition : ressource existante, droit applicable. Résultat : absence rattachée à la ressource, **y compris sans mission**. Refus : « Choisissez une ressource et une période d’absence valides. » Effet : planning/capacité recalculés selon BM-32 ; `AbsenceRecorded`. V : congé entre deux missions ; L : journée partielle ; I : exiger une prestation pour déclarer l’absence. Saisie, demande et validation restent des commandes distinctes ; la validation n’est **pas** une porte du CA V1 (ATL-08).

**BM-38 — Chiffres et devises — ACQUISE, convention ATL (F35–F36).** Grain et calendrier : F29–F34. Formules : ATL-01 à ATL-18 ci-dessous. Un snapshot porte la version de convention. Agrégat EUR+MAD sans taux : refus. CA facturé nommé, **non calculé en V1** (F16).

**BM-39 — Planning dérivé — ACQUISE, DEC-16.** Acteur : lecteur habilité. Entrées : prestations, absences, positionnements et temps visibles. Précondition : droits sur le périmètre. Résultat : vues de planning, charge et occupation ; catégories distinguées. Refus : « Modifiez l’affectation ou l’absence à l’origine de cette valeur. » Effet : aucun stockage parallèle faisant autorité ; aucun événement de mutation à la consultation. V : nouvelle prestation visible ; L : ressource sans mission avec absence ; I : écriture autonome de charge contredisant les prestations.

### Actions et règles transverses

**BM-40 — Action à porteur unique — ACQUISE, DEC-15 ; date/type/responsable proposés depuis audit 19–21.** Acteur : contributeur autorisé sur la fiche porteuse. Entrées : exactement une Société, un Contact, un Candidat, une Ressource, un Besoin ou un Projet ; type, date, contenu, responsable éventuel. Précondition : porteur existant et accessible. Résultat : action rattachée, visible dans la timeline et la liste filtrée. Refus : « Choisissez un seul porteur pour cette action. » Effet : `ActionCreated/Updated`. V : appel sur Contact ; L : même personne ayant deux profils, porteur explicitement choisi ; I : une action à deux porteurs. Porteur métier, responsable utilisateur et possesseur d’un droit ne sont pas synonymes.

**BM-41 — Groupes et permissions — ACQUISE, DEC-17 et CdC IV.A.7/IV.G.1–2.** Acteur : Admin, ou possesseur sur une fonctionnalité déléguée. Entrées : utilisateur, groupes, application/onglet, permissions de lecture/contribution/possession et périmètres. Précondition : habilitation à administrer ce périmètre. Résultat : droits effectifs par union des habilitations. Refus : « Vous ne pouvez pas déléguer ce droit sur ce périmètre. » Effet : droits affichables ; `GroupMembershipChanged`, `PermissionGranted/Revoked`. V : deux groupes complémentaires ; L : un groupe de lecture n’annule pas un groupe contributeur ; I : premier groupe seul pris en compte.

**BM-42 — Union sans extension indue du périmètre — ACQUISE dans son principe, DEC-17.** Acteur : système à chaque commande et lecture. Entrées : ensembles liés permission–périmètre. Précondition : au moins une habilitation couvre à la fois la commande et la cible. Résultat : union de ces ensembles, jamais produit croisé des permissions et des périmètres. Refus : « Cette opération est hors de votre périmètre autorisé. » Effet : aucun changement sur cible refusée ; pas d’événement de succès. V : écriture A + lecture B ; L : lecture A et B ; I : écriture B obtenue en combinant ces deux groupes.

**BM-43 — Possession et surcharge administrative — ACQUISE, CdC IV.A.7/IV.G.2 ; modalités PROPOSÉES.** Acteurs : possesseur fonctionnel et Admin. Entrées : droit délégué ou surcharge explicite. Précondition : fonctionnalité possédée ou pouvoir administratif. Résultat : délégation dans le périmètre ; surcharge documentée et visible. Refus : « La possession de cette fonctionnalité ne donne pas la propriété de toutes les fiches. » Effet : historique de droits ; `PermissionOverrideSet`. V : RR gère l’accès au processus ; L : surcharge nominative sur un onglet ; I : Admin présumé autorisé à signer tous les contrats sans habilitation métier. La priorité d’une surcharge restrictive sur l’union : **la restriction gagne** (F28).

**BM-44 — Même contrôle pour toute commande — ACQUISE, DEC-17.** Acteur : tout utilisateur. Entrées : commande, cible et contexte. Précondition : habilitation vérifiée au moment de l’exécution. Résultat : application identique depuis fiche, recherche ou import. Refus : « Permission absente pour cette opération. » Effet : aucune mutation refusée ; trace de refus distincte du journal des réussites. V : CreateCompany par IA ; L : bouton visible mais commande refusée ; I : CreateCompany accepté pour RH seule parce que le validateur ne couvre que CreateNeed.

**BM-45 — Lecture, recherche et reporting filtrés — ACQUISE, CdC II.G/IV.A.5–7/IV.H et DEC-17.** Acteur : lecteur habilité. Entrées : filtres simples/avancés, relations, période, colonnes et périmètre demandé. Précondition : intersection avec les objets réellement autorisés. Résultat : listes, compteurs, exports et agrégats cohérents avec la visibilité. Refus : « Ce périmètre n’est pas accessible. » Effet : sauvegarde des préférences ou recherches seulement si demandée ; `SearchSaved/Shared` pour ces mutations. V : recherche partagée réévaluée chez le destinataire ; L : zéro résultat dû aux droits ; I : total global révélant des objets hors périmètre.

**BM-46 — Historique métier — ACQUISE, DEC-18 et CdC IV.A.1 ; contenu précis PROPOSÉ.** Acteur : système. Entrées : commande acceptée, auteur, cible, horodatage, valeurs avant/après pertinentes, motif et liens. Précondition : mutation importante réussie. Résultat : événement métier consultable avec la fiche ; refus, annulation et réussite distingués. Refus : « La modification et son historique doivent rester cohérents. » Effet : événement de création, transition, modification contractuelle, qualification, réaffectation, droits ou archivage ; pas un simple log technique. V : transfert retraçable ; L : commande annulée sans événement de conversion ; I : effacement d’une ancienne note de qualification dans l’historique. Les libellés proposés ne sont pas des noms imposés par les cahiers.

**BM-47 — Archivage des objets historiques — ACQUISE, DEC-18.** Acteur : détenteur explicite du droit d’archivage, pas tout « owner » implicite. Entrées : objet, motif recommandé. Précondition : règles métier de l’objet satisfaites ; BM-17 pour un service. Résultat : archivage, liens et historique conservés. Refus : « Cet objet porte un historique ; il ne peut pas être supprimé physiquement. » Effet : retrait des vues actives sans disparition des références ; `ObjectArchived`. V : dossier clos ; L : ancien contact référencé ; I : cascade supprimant ses actions. La restauration est **hors V1** (F27) ; si elle est ajoutée plus tard, c’est une commande distincte qui ne rouvre pas automatiquement contrats et prestations.

**BM-48 — Notifications et discussions — DIFFÉRÉ, F17.** Commentaires et mentions **hors V1**. Les **Actions** (BM-40) et l’**historique** (BM-46) restent dans le premier lot. L’exigence CdC IV.A.2–3 est conservée au backlog, pas abandonnée.

**BM-49 — Référentiels et présentation — ACQUISE, CdC IV.G.3–4/IV.A.6/8.** Acteur : Admin pour listes et colonnes par défaut ; utilisateur pour ses préférences. Entrées : valeurs, types d’événements, libellés, colonnes, langue. Précondition : valeur protégée identifiée. Résultat : listes administrables, certaines valeurs renommables mais non supprimables ; préférences conservées ; français et anglais au minimum. Refus : « Cette valeur est protégée ; renommez-la sans la supprimer. » Effet : `ReferenceValueUpdated`, `DisplayPreferenceSaved`. V : ajouter compétence ; L : renommer valeur standard ; I : supprimer un type standard de qualification déjà utilisé.

**BM-50 — Objectifs et indicateurs — ACQUISE comme exigence CdC IV.H ; formules QUESTION.** Acteur : manager habilité pour objectifs ; utilisateur pour lecture personnelle. Entrées : membre d’équipe, période, indicateur, objectif. Précondition : périmètre couvert. Résultat : comparaison réalisé/objectif sur période ; vues performance, dépendance, profitabilité. Refus : « Vous ne pouvez pas fixer cet objectif hors de votre équipe. » Effet : `ObjectiveSet/Updated` ; consultation sans mutation. V : objectif trimestriel ; L : période sans activité ; I : calculer un taux sans définir numérateur/dénominateur. Le parcours d’approbation des objectifs reste hors V1. Les **noms** de KPI du CdC (TJM, CJM, TACE, marge) se calculent selon ATL ; la forme graphique reste libre.

### Extensions et politiques à compléter

**BM-51 — Import LinkedIn vers Ava — ACQUISE comme demande SPEC US3–4, non réalisée par le userscript.** Acteur : contributeur Candidat ou CRM. Entrées : informations disponibles du profil, destination Candidat/CRM, corrections et validation. Précondition : droits de création et données minimales suffisantes. Résultat attendu : création réelle dans Ava après confirmation ; contrôle des doublons selon BM-57. Refus : « Complétez les informations nécessaires avant de créer la fiche. » Effet : `CandidateCreated` ou `ContactCreated`, provenance conservée. V : candidat confirmé ; L : téléphone indisponible à compléter ; I : CSV local présenté comme fiche Ava créée. CV, DT, email et téléphone ne sont pas réputés disponibles du seul fait de l’US.

**BM-52 — Envoi et déclaration du partage CV — ACQUISE comme demande SPEC US7 et CdC IV.E.3.** Acteur : contributeur habilité à partager. Entrées : candidat, CV, contacts sélectionnés, objet et corps, modèle éventuel. Préconditions : sélection explicite des destinataires, document présent. Résultat : préparation puis envoi ; possibilité distincte de déclarer un partage déjà réalisé. Refus : « Sélectionnez un CV et les destinataires. » Effet : statut de partage et historique cohérents avec envoi réel ou déclaration ; `CVShareDeclared`, `CVEmailSent/Failed`. V : plusieurs contacts ; L : déjà partagé, avertir puis autoriser confirmation ; I : marquer envoyé après échec. Ces règles ne constituent pas une autorisation d’envoyer des messages pendant ce cadrage.

**BM-53 — Modèles d’email — ACQUISE comme demande SPEC US8 et personnalisation.** Acteur : utilisateur habilité à la rubrique. Entrées : nom, objet, contenu, variables société/contact. Précondition : modèle renseigné. Résultat : modèle enregistré, sélectionnable et préremplissant l’email. Refus proposé : « Une variable ne peut pas être résolue pour ce destinataire. » Effet : aucun envoi à la création ; `EmailTemplateCreated/Updated`. V : modèle nominatif ; L : plusieurs destinataires, rendu propre à chacun ; I : reprendre les coordonnées du premier contact dans tous les messages.

**BM-54 — Achat et facture — PROPOSÉE comme lot ultérieur, fonctionnement Boond C5 et diagnostic.** Acteur envisagé : acheteur/finance habilité, à définir seulement si inclus. Entrées : projet, société fournisseur, achat, facture et paiement. Précondition : périmètre retenu et contrat de traitement défini. Résultat cible : chaîne distincte des prestations et temps. Refus provisoire : « Ce module n’est pas défini dans le périmètre retenu. » Effet envisagé : `PurchaseCreated`, puis événements finance à spécifier ; aucun effet dans les simulations du noyau. V : coût externe identifié ; L : fournisseur aussi client ; I : considérer une Ressource EXTERNAL comme une facture payée. La facture client hors V1 est une recommandation du diagnostic, pas une DEC.

**BM-55 — Compte candidat et assistance Support — ACQUISE pour Support lecture, F13 ; portail hors V1, F16.** Support : **lecture seule**, pas d’impersonation. Fonctions candidat portail différées. Profil métier et rôle utilisateur restent distincts.

**BM-56 — Alertes intelligentes — DIFFÉRÉ, F18.** Exigence CdC IV.A.5 conservée au backlog ; pas en V1.

**BM-57 — Doublons et fusion — ACQUISE, F20–F22.** À la création : **avertir**, l’utilisateur choisit une fiche existante ou continue (F20). Pas de fusion automatique, jamais sur l’email seul. Fusion un jour : habilité **par type d’objet** (F21). Contact et Personne : **deux objets distincts** en V1 (F22). Effet : `DuplicateSuspected` ; `RecordsMerged` seulement après procédure explicite. V : rapprochement confirmé ; L : adresse email partagée ; I : email identique = preuve suffisante pour fusionner.

**BM-58 — Qualité des coordonnées et données internationales — PROPOSÉE, correction SPEC US1/US2 et CdC IV.A.8.** Acteur : contributeur identité. Entrées : pays, téléphone, adresse et code postal. Précondition : format cohérent avec le pays. Résultat recommandé : adresse postale distincte de l’email, code postal textuel, téléphone international sans limite universelle de dix chiffres. Refus : « Vérifiez le format de cette coordonnée pour le pays indiqué. » Effet : `PersonUpdated` ou `ContactUpdated`, aucune conversion automatique hasardeuse. V : numéro international ; L : code postal avec zéro initial ; I : rejeter tous les codes alphanumériques. Ces corrections sont proposées explicitement, pas attribuées aux DEC.

**BM-59 — Noyau V1 et fonctions différées — ACQUISE, F15–F19.** V1 : CRM, candidat/ressource, matching, projet, prestation, temps, droits, historique, planning dérivé simple. **Actions** dans V1. **Commentaires/mentions hors V1** (F17). Différés (F16, F18) : éditeur de process, LinkedIn intégré, emailing, portail, facture client, achats, alertes intelligentes. Exigences différées au backlog, pas abandonnées. Cycle candidat V1 = Draft / Complété, conversion = BM-06 (F19).

**BM-60 — Graphe des transitions du besoin — ACQUISE, F6 et F3.** Acteurs : IA pour demande/état ; Staffing pour prise en charge selon matrice. Graphe : ouvert → staffing → pourvu ; ouvert/staffing/pourvu → suspendu ou fermé ; reprise suspendu vers état opérationnel explicite ; réouverture de fermé par commande dédiée. **« Pourvu » sur un besoin à plusieurs postes : seulement quand tous les postes visés ont une prestation signée.** Une première prestation signée **ne** passe **pas** le besoin à pourvu ; il **reste en staffing** (F3). Ce n’est pas une DEC existante : c’est F3. Refus : « Cette transition nécessite une réactivation ou une décision explicite. » Effet : `NeedStateChanged`, zéro projet implicite. V : dernier poste signé → pourvu ; L : une prestation sur deux, besoin encore staffing ; I : confondre « gagné » avec un sixième état.

**BM-61 — Version de processus et départage — DIFFÉRÉ, F16.** Éditeur hors V1. Si l’éditeur revient : futurs dossiers sur la nouvelle version ; anciens inchangés sauf migration écrite.

### Correspondance avec le plan précédent

| Anciennes références | Nouvelle couverture et correction |
|---|---|
| R01–R02 | BM-01/02/57 : identité ; doublons F20–F22. |
| R03–R05 | BM-03/06 : conversion ; acteur RH = F9. |
| R06–R08 | BM-21/22 : XOR ; garde d’état F5. |
| R09–R11 | BM-18/19 : société obligatoire, contact facultatif. |
| R12–R15 | BM-25–28/60 : N projets ; pourvu = tous les postes (F3) ; garde F1 ; contact projet F4. |
| R16–R21 | BM-07/30–34/38 : économie historisée ; formules ATL. |
| R22–R24 | BM-03/20/60 : priorité séparée ; pas de projet depuis candidat. |
| R25–R26 | BM-39/40 : porteur distinct ; planning DEC-16. |
| R27–R30 | BM-41–47 : union + restriction Admin F28 ; archivage ; restauration hors V1 F27. |
| R31–R34 | BM-29/36/37/13/55 : absence F25 ; temps F32–F34 ; Support lecture F13. |
| P01–P04 | BM-12/41–43/23/09. |
| P05–P08 | BM-10/59/32/28/35 : cycle Draft/Complété F19 ; grain F29 ; clôture projet F7 ; éditeur hors V1 F16. |
| P09–P12 | BM-38/15/24/36 : formules ATL ; Client manuel F23. |
| P13–P15 | BM-57/46/59 : doublons F20 ; V1 = F15–F18. |

## Matrice des rôles des commandes et des périmètres

### Catalogue et limites

Les cahiers définissent les rôles et les mécanismes de droits, mais pas une matrice exhaustive de commandes. La matrice suivante est la **configuration retenue F8–F14**, ancrée dans ces responsabilités, **pas une DEC**. Sophie = RH, Nadia = RR, Karim = Staffing + DP. Une fonction permise au groupe n’est permise à l’utilisateur que sur son périmètre. Le CdC **n’impose pas** une commande `ApproveRecruitment` ; elle n’entre dans aucun parcours de base (F10).

| Rôle | Objectif et objets lisibles | Mutations, transitions et données sensibles | Validation, périmètre et refus attendus |
|---|---|---|---|
| IA | Relation commerciale ; sociétés, contacts, besoins, profils utiles au positionnement | CRM, besoins, priorité, retour client et tarif proposé ; pas de modification RH globale | Affaires/agences attribuées ; pas de conversion ni de clôture de prestation par défaut. |
| Commercial | Appellation d’affichage du groupe IA (F12), pas un groupe distinct | Mêmes mutations que IA | Seul le groupe IA fait foi. |
| RH | Gérer les candidatures et informations RH des personnes autorisées | Candidat, CV/DT, qualifications si habilitée, conversion et fiche Ressource proposées ; coût de référence sous permission spécifique | Périmètre RH configuré, par exemple agence A ; pas de société créée par le seul rôle RH. |
| RR | Définir le recrutement et ses droits | Processus, critères obligatoires, droits sur la fonctionnalité possédée ; pas de modification de tous les candidats par possession seule | Périmètre du processus ; approbation de recrutement proposée, non acquise par les sources. |
| Évaluateur | Mesurer un candidat pour un besoin confié | Qualification, notes, commentaires ; accès aux pièces nécessaires, pas aux salaires par défaut | Dossiers/besoins assignés ; pas de conversion, projet, prestation ni accord client en tant qu’évaluateur. |
| Staffing | Affecter les ressources aux besoins et projets | Positionnements ressource, conditions d’affectation, prestations ; lecture disponibilité et tarifs autorisés | Périmètre équipe/pôle configuré ; création projet si cette permission lui est déléguée. |
| Directeur de projet | Tenir l’exécution et les conditions des missions | Projet, tarifs/coûts retenus, prestation, temps délégués, clôture | Projets/pôle attribués ; validation des temps proposée ; ne modifie pas l’identité RH par défaut. |
| Ressource en self-service | Consulter ses missions et déclarer son activité | Ses temps et absences ; aucune modification des tarifs ou droits | Soi-même ; ni temps d’un collègue ni prestation arbitraire. Fonction proposée depuis le besoin de production. |
| Admin | Administrer utilisateurs, groupes, listes et apparence | Habilitations et paramètres, surcharges explicites | Périmètre administratif global ; contribution métier seulement par permission métier explicite, pas par raccourci implicite. |
| Support | Lire pour assister | Lecture globale ; **aucune** mutation (F13) | Pas d’impersonation. |
| Candidat portail | Fonctions futures possibles sur son dossier | Aucune commande active définie pour V1 à ce stade | Soi-même si portail retenu ; pas de CRM/staffing par défaut. Posséder une fiche candidat n’enlève aucun autre rôle utilisateur. |

Staffing et DP restent deux profils de permissions distincts ; Karim **cumule** les deux groupes (F8). RH et RR restent distincts ; Sophie convertit (F9) ; Nadia n’a pas d’étape d’approbation (F10). Léa évalue seulement (F11). Admin sans pouvoir métier implicite (F14).

### Exécution des commandes

`✓` : attribution proposée ; `D` : délégation explicite nécessaire ; `S` : soi-même ; `—` : aucune exécution accordée par ce groupe. La lecture des objets est définie au catalogue ci-dessus et par BM-45 : « lire CreateCompany » n’est pas une permission cohérente.

| Commande ou famille cohérente | IA | RH | RR | Éval. | Staffing | DP | Ressource | Admin | Support | Candidat |
|---|---|---|---|---|---|---|---|---|---|---|
| Créer/modifier société, unités, contacts | ✓ | — | — | — | — | — | — | D | — | — |
| Transférer contact, archiver service | ✓ | — | — | — | — | — | — | D | — | — |
| Créer/modifier besoin | ✓ | D interne | D interne | — | D | — | — | D | — | — |
| Prioriser besoin, enregistrer retour client | ✓ | — | — | — | D | D | — | D | — | — |
| Prendre en charge/pourvoir/suspendre/fermer besoin | ✓ | — | — | — | ✓ | D | — | D | — | — |
| Créer/modifier candidat, CV et DT | D | ✓ | D | — | — | — | — | D | — | — |
| Transitions candidat | D | ✓ selon processus | D | — | — | — | — | D | — | — |
| Positionner candidat | ✓ | ✓ | D | — | D | — | — | D | — | — |
| Qualifier candidat | D | D | D | ✓ | — | — | — | D | — | — |
| Approuver recrutement | — | — | **hors parcours de base** | — | — | — | — | D | — | — |
| Convertir candidat, créer profil Ressource | — | ✓ | D | — | — | — | — | D | — | — |
| Modifier données RH et coût de référence | — | ✓ selon onglet | D | — | — | D coût | S coordonnées si autorisé | D | — | — |
| Positionner ressource | D | D | — | — | ✓ | D | — | D | — | — |
| Créer projet direct ou depuis besoin | D | — | — | — | D | ✓ | — | D | — | — |
| Créer/modifier prestation et tarif vendu | — | — | — | — | ✓ | ✓ | — | D | — | — |
| Clôturer prestation/projet | — | — | — | — | D | ✓ | — | D | — | — |
| Saisir/corriger temps de production | — | — | — | — | — | D périmètre | S | D | — | — |
| Déclarer absence | — | D | — | — | — | D | S | D | — | — |
| Valider temps/absence si contrôle retenu | — | D absence | — | — | — | D temps | — | D | — | — |
| Créer/modifier Action | ✓ cible | ✓ cible | D cible | D cible | ✓ cible | ✓ cible | D cible | D | — | — |
| Archiver objet historique | D objet | D objet | D objet | — | D objet | D objet | — | D | — | — |
| Créer/éditer/publier processus | — | — | ✓ possession | — | — | — | — | D | — | — |
| Administrer groupes/utilisateurs/listes | — | — | D fonctionnalité | — | — | — | — | ✓ | — | — |
| Affecter objectifs | D équipe | D équipe | D équipe | — | D équipe | D équipe | — | D | — | — |
| Sauvegarder recherche/préférence/alerte | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | D | ✓ | D | — |
| Commenter/mentionner une fiche | — hors V1 (F17) | — | — | — | — | — | — | — | — | — |
| Import LinkedIn si lot retenu | D CRM/candidat | D candidat | — | — | — | — | — | D | — | — |
| Partager CV, gérer modèle email si lot retenu | D | D | D | — | D | — | — | D | — | — |
| Assistance active/fusion de doublons | — | — | — | — | — | — | — | D | D assistance | — |

Toutes les délégations sont liées à une cible ou à un périmètre. Les tarifs vendus, coûts de référence, salaires, éléments administratifs et droits font l’objet de permissions séparées ; un accès à la synthèse candidat n’accorde pas automatiquement l’accès aux onglets RH. Une ressource externe bénéficie des mêmes règles de self-service qu’une interne si elle a le groupe correspondant. La validation ne peut pas être attribuée par simple déduction d’un bouton visible.

Pour les simulations, configuration **retenue** (F8–F14) : Martin = IA agence A ; Sophie = RH agence A ; Nadia = RR agence A ; Léa = Évaluateur sur les dossiers assignés ; Karim = Staffing + DP agence A avec CreateProject et clôture ; Jean, Sara, Paul et, après activation, Amina = self-service sur leurs propres prestations. L’administrateur peut affecter ces groupes. Aucun de ces comptes n’a de contribution dans l’agence B avant une délégation explicite.

## Quinze simulations séquentielles

### État initial commun et conventions

Un seul monde est utilisé : l’état final de S1 devient l’état initial de S2, et ainsi de suite. Aucune remise à zéro implicite. Les commandes de préparation sont mentionnées ; aucune référence à un projet créé seulement dans une phrase de résultat.

Au départ existent : agences internes A et B ; sociétés Alpha et Beta suivies par A, Gamma fournisseur, Zeta suivie par B ; Alpha possède Service1 et Service2 ; contacts Alice dans Alpha/Service1, Benoît dans Alpha/Service2 et Zoé dans Zeta. Beta n’a aucun contact. Personnes Jean et Paul avec profils Ressource INTERNAL, Sara avec profil Ressource EXTERNAL lié à Gamma, Mehdi avec profil Candidat seulement. Aucun besoin, positionnement, projet, prestation ni temps. Les comptes ont les groupes de la matrice précédente. Les données minimales de ces fiches sont renseignées.

Dates fictives de mission en 2027, précision journalière (F29). Les taux des prestations signées sont additionnés seulement sur dates communes. Pas d’absence dans les calculs de charge des S1–S8. Calendrier d’agence (F30). Les décisions « retenu » sont des retours client explicitement enregistrés par Martin. L’approbation du recrutement **n’existe pas** dans le parcours de base (F10). Les projets utilisent un contact Alpha valide, un type Régie, une agence et des paramètres confirmés.

**S1 — Placement d’une ressource déjà active.** Départ : monde initial. (1) Martin crée N1 pour Alpha/Service1, contact Alice. (2) Karim positionne Jean : X1 relie N1 et le profil Ressource Jean ; **N1 passe en staffing** — premier positionnement (G3). (3) Martin enregistre le retour client retenu : **X1 passe à `retenu`** (G2) ; N1 reste en staffing. (4) Karim confirme la création de P1 depuis N1 — garde « ressource retenue » (BM-28, F1). (5) Karim crée T1 sur P1 pour Jean, du 1 au 31 janvier, signée, taux 60 %, conditions complètes. (6) Jean saisit 0,6 jour de production le 4 janvier sur T1. État final : 1 besoin, 1 positionnement, 1 projet, 1 prestation, 1 ligne de temps ; pas de nouvelle Personne. **Résultat : DEC/CdC + F1/F6.** N1 n’est « pourvu » que si tous ses postes visés ont une prestation signée (F3) — ici un poste unique, T1 signée le permet ; le monde S12 conserve N1 actif jusqu’à fermeture explicite.

**S2 — Candidat retenu puis converti.** Départ : état S1 ; aucune Ressource Amina. (1) Sophie crée Personne Amina et profil Candidat C-A en Draft. (2) Martin crée N2 pour Alpha/Service2, contact Benoît. (3) Sophie crée X2, C-A sur N2. (4) Léa est habilitée sur ce dossier puis enregistre une qualification de N2. (5) Martin enregistre le retour client retenu. (6) Sophie annule une première demande de conversion : aucun effet. (7) Sophie confirme ensuite : profil Ressource R-A ajouté à la même Personne, historique C-A et X2 conservé. Le statut candidat reste Draft ou Complété ; la conversion n’invente pas un troisième statut (F19). (8) Karim crée P2 puis T2, Amina à 100 % en février : **CreatePrestation suffit**, pas de nouveau matching ressource obligatoire (F2). X2 candidat reste lisible. État final ajouté : une seule Personne Amina, deux profils, un matching candidat conservé, un projet et une prestation ; aucune prestation portée par C-A. **Résultat : DEC/CdC + F2/F9/F19.**

**S3 — Un besoin ouvre deux projets.** Départ : S2. (1) Martin crée N3 Alpha/Service2 avec Benoît — **deux postes visés**. (2) Karim positionne Sara en X3 ; Martin enregistre retenu. (3) Karim confirme P3A depuis N3, puis confirme P3B depuis le même N3. (4) Vérification : zéro prestation créée automatiquement. (5) Karim choisit P3A et crée T3A pour Sara, 60 %, du 1 au 31 mars. État final : N3 a deux projets ; X3 reste sur N3 ; T3A existe, P3B sans prestation. N3 **reste staffing** : une prestation signée ne pourvoit pas tout le besoin (F3). **Cardinalité : DEC/CdC. Pourvu multi-postes : F3.**

**S4 — Partage 60/40 sur deux missions.** Départ : S3, Sara a T3A 60 % sur P3A. (1) Karim choisit P3B. (2) Il crée T3B pour Sara, signée, 40 %, du 1 au 31 mars. (3) Recalcul au jour (F29) : 60 + 40 = 100 % chaque jour commun, calendrier d’agence (F30). État final : deux prestations de Sara ; aucune duplication de X3 ; pas d’alerte de dépassement. Si les deux postes de N3 sont ainsi pourvus, N3 peut passer à pourvu (F3). **DEC-10 + F29/F30.**

**S5 — Surcharge avec chevauchement.** Départ : S4, Sara à 100 % en mars. (1) Martin crée N5 ; Karim crée X5 ressource Sara ; Martin enregistre retenu. (2) Karim confirme P5 depuis N5. (3) Il crée T5, Sara à 10 % du 15 au 19 mars. (4) Le système conserve T5 et signale 110 % sur ces cinq dates uniquement (grain jour F29 ; week-end/fériés selon calendrier d’agence F30). État final : trois prestations de Sara ; 100 % avant/après, 110 % dedans. **Alerte sans refus : DEC/CdC. Fenêtre : F29/F30 / ATL-02.** Occupation 110 %, pas un euro.

**S6 — Mêmes charges sans chevauchement.** Départ : S5, Paul n’a aucune prestation. (1) Martin crée N6 ; Karim positionne Paul en X6 ; Martin enregistre retenu. (2) Karim confirme P6A puis P6B depuis N6. (3) Il crée T6A, Paul 60 %, du 1 au 9 avril. (4) Il crée T6B, Paul 50 %, du 12 au 30 avril. (5) Recalcul au jour : 60 % du 1 au 9, zéro les 10–11 (ou selon calendrier d’agence), 50 % du 12 au 30. État final : deux prestations de Paul sans surcharge. **DEC-10 + F29/F30.**

**S7 — Remplacement en cours de mission.** Départ : S6 ; T1 porte toujours Jean, 0,6 jour historique le 4 janvier. (1) Karim tente de remplacer la ressource de T1 par Paul : refus, T1 et temps inchangés. (2) Karim clôture T1 à effet du 15 janvier ; snapshot M1 = ATL-14/15 sur T1 — **formule connue, montant numérique impossible** sans TJM/CJM de T1 dans ce monde. Un ajustement de temps post-clôture resterait distinct (F34). (3) Karim crée T1B sur P1 pour Paul, 60 %, du 16 au 31 janvier. (4) Les prestations d’avril de Paul ne se chevauchent pas avec T1B. État final : T1 à Jean, clôturée ; T1B porte Paul ; la ligne du 4 janvier reste à Jean. **Remplacement : DEC-11. Snapshot : DEC-09 + ATL-15.**

**S8 — Clôture prestation puis projet.** Départ : S7, P1 contient T1 clôturée et T1B ouverte. (1) Karim tente CloseProject(P1) : refus (BM-35, F7). (2) Paul saisit 0,6 jour le 18 janvier sur T1B. (3) Karim clôture T1B au 31 janvier, snapshot M1B = ATL-15. (4) Karim clôture P1. (5) Une modification ultérieure du coût de référence Jean par RH ne modifie ni M1 ni T1. État final : P1 clos, deux prestations closes, deux lignes de temps conservées. **Ordre : F7. Snapshots : DEC-09. CA produit T1B = 0,6 × TJM(T1B) (ATL-08).**

**S9 — Candidat vers prestation interdit.** Départ : S8 ; Mehdi n’a que son profil Candidat ; P2 existe. (1) Karim, habilité à créer une prestation, présente Mehdi candidat comme exécutant de P2. (2) Refus métier BM-03/29, même si Karim possède la permission de commande. (3) Contrôle : aucune prestation, aucun profil Ressource ni temps créé pour Mehdi. État final identique à S8 sur les objets métier. **Résultat : DEC/CdC (DEC-02).** Pas un refus d’habilitation.

**S10 — Rôle sans permission.** Départ : S9 ; Sophie est RH seule, sans contribution CRM (config **retenue** F8–F14). (1) Sophie tente CreateCompany(Delta). (2) Refus de permission, zéro société Delta. (3) Martin, IA agence A, exécute la même création : Delta existe et est suivie par A. État final : exactement une Delta, événement attribué à Martin. **Résultat : DEC-17 + F12/F14.**

**S11 — Besoin sans contact.** Départ : S10 ; Beta existe sans contact. (1) Martin crée N11 pour Beta, contact absent. (2) N11 est enregistré ouvert ; aucun contact fictif ni service obligatoire créé (DEC-04). (3) Si Karim lance `CreateProjectFromNeed` : le système **demande un contact au moment du projet** (F4), sans bloquer N11. Dans cette simulation on **ne crée pas** le projet, pour ne pas changer le monde S12. État final : un besoin Beta sans contact, zéro projet Beta. **Besoin : DEC-04. Contact projet : F4.**

**S12 — Archivage d’un objet historique.** Départ : S11 ; Service1 porte N1 encore actif et P1 désormais clos. (1) Martin tente ArchiveService(Service1) : refus à cause de N1 actif. (2) Martin ferme explicitement N1, sans modifier P1. (3) Il archive Service1 avec le droit d’archivage qui lui est attribué pour l’exercice. (4) Depuis Alpha, contrôle de visibilité des références : Alice, N1, P1, T1/T1B et leurs historiques restent consultables selon droits. État final : Service1 absent de l’organisation active, objets historiques conservés ; Service2 actif. **Résultat : DEC/CdC (CdC IV.C.4 et DEC-18).**

**S13 — Même commande dans et hors périmètre.** Départ : S12 ; Martin contribue dans A et n’a pas d’accès B (F8–F14). (1) CreateNeed sur Alpha, agence A : N13 créé. (2) Même commande sur Zeta, agence B : refus. (3) Contrôle : N13 existe, aucune demande Zeta supplémentaire. État final : un seul besoin ajouté. **Résultat : DEC-17.**

**S14 — Union de deux groupes sans croisement abusif.** Départ : S13. (1) Admin ajoute à Martin un groupe LectureCRM-B ; son groupe IA-A demeure. (2) Martin lit Zeta : autorisé. (3) Il crée N14 sur Alpha/A : autorisé, le groupe de lecture B n’annule pas sa contribution A. (4) Il tente CreateNeed sur Zeta/B : toujours refusé. État final : groupe supplémentaire, N14 créé dans A, zéro nouveau besoin B. **Résultat : DEC/CdC (DEC-17).** Lecture B + contribution A ne devient pas contribution B.

**S15 — Créateur, évaluateur ; conversion refusée à l’évaluatrice.** Départ : S14. (1) Martin crée N15 Alpha/Service2, Benoît. (2) Sophie crée Personne Nora et profil Candidat Draft, puis complète les données ; aucun profil Ressource Nora. (3) Sophie positionne Nora sur N15. (4) Léa qualifie ; aucun projet ni conversion. (5) Léa tente ConvertCandidateToResource : refus (F11). **État certain : Nora candidate ; aucune conversion par Léa. La simulation s’arrête là. C’est le parcours de base (F10).** Pas d’ApproveRecruitment.

### Bilan de couverture

Les quinze scénarios font évoluer le même monde. Ce ne sont pas quinze tests logiciels. Étiquettes : **DEC/CdC + F1–F34 + ATL**. S1 CA produit = 0,6 × TJM(T1) (ATL-08) — TJM non saisi dans l’exercice. S11 : besoin sans contact = DEC-04, contact au projet = F4. S15 s’arrête après le refus de Léa. Commentaires hors V1 (F17) ; Actions et historique dans V1.

## Contradictions et corrections sourcées

| Sujet | Sources précises en désaccord ou insuffisantes | Traitement |
|---|---|---|
| Contact obligatoire sur besoin | CdC IV.D.1 et IV.C.1 exigent contact et unité ; DEC-04 rend le contact facultatif | DEC-04 prévaut ; société suffisante pour le rattachement obligatoire. Pas de nouvelle question. |
| Projet automatique | SPEC US6 RG1 contre DEC-06 | Création explicite confirmée ; passage d’état seul ne crée rien. |
| Identité à conversion | SPEC US2 RG3 parle de nouvelle ressource avec transfert de champs ; DEC-01/02 imposent identité commune | Nouvelle ressource signifie profil ajouté à la même Personne, historique préservé. |
| Ressource obligatoire sur projet | SPEC US5 formulaire initial contre DEC-07 ; commentaire Word demande l’ajout au niveau des prestations | Ressource sur prestation, pas sur projet. Une création groupée éventuelle reste explicite. |
| Projet depuis candidat | Audit 05 et 22 décrit le bouton Boond ; DEC-14 l’interdit dans Ava | DEC-14 prévaut ; ne pas reproduire ce bouton comme règle métier Ava. |
| Priorité et état | Audit 12 décrit A traiter/P1 ; DEC-13 distingue priorité et cycle | P1–P3 séparés ; l’ancien plan R13/S9 introduisait gagné sans base dans DEC-13. |
| Contact du projet | US5 formulaire manuel vs DEC-04 vs US6 | Obligation US5 **seulement** sur le manuel. `CreateProjectFromNeed` sans contact du besoin : **demander le contact au projet** (F4). |
| Création directe Ressource | Ancien plan contradiction 11 oppose US1 à DEC-01 | Aucune contradiction : création directe d’une Personne + RessourceProfile, sans candidat imposé. |
| Projet direct | SPEC US5 et CdC II.I autorisent création directe ; ancien plan concentre tout sur CreateProjectFromNeed | Maintenir deux commandes distinctes ; confirmer leurs gardes précises, pas supprimer US5 silencieusement. |
| Cycle court présenté comme sourcé | Ancien P05 vs CdC II.J/IV.F | V1 = Draft et Complété (CdC). Conversion = commande/motif BM-06, **pas** un troisième statut (F19). Éditeur souple hors V1 (F16). |
| Grain calendaire présenté comme acquis | Ancien P06 vs SPEC/CdC | Grain jour + calendrier d’agence : **F29–F31 / ATL**. |
| Approbation et droits supposés acquis | Ancien registre vs CdC III/IV.G | Matrice **retenue** F8–F14 ; pas d’ApproveRecruitment (F10). |
| Conversion de Jean déjà ressource | Ancien état initial §4 contient Jean candidat et ressource, puis S4 annonce une conversion qui doit créer sa ressource | Remplacé par Amina initialement candidate seule ; tentative répétée ne crée pas un second profil. |
| Quinze simulations revendiquées | Ancien §4 ne contient pas les parcours spécifiques archivage, clôture, même commande hors périmètre demandés au brief §8.B | Rétablis dans S8, S12, S13 et S14 ; résultat attendu et hypothèses distingués. |
| Absence liée à prestation | Ancien R32 fusionne RecordTimesheet/Absence et TimesheetRecorded ; DEC-16 distingue les sources, Boond rattache l’absence à la ressource | Commandes séparées ; absence possible sans mission proposée explicitement. |
| Porteur confondu avec owner | Ancien R25 impose « 1 owner » ; DEC-15 impose un objet porteur | Séparer porteur, responsable utilisateur et droit de possession. |
| Vue de planning incomplète | Ancien R26 ne cite que prestations/absences ; DEC-16 ajoute positionnements/temps | Conserver les quatre sources et distinguer réalisé/prévisionnel. |
| Dédoublonnage présenté comme acquis | Ancien R01 vs P13 | Politique = F20–F22 : avertir, pas de fusion auto sur l’email. |
| Suppression d’événements | CdC IV.E.1 autorise retrait d’événements sauf CV ; IV.G.4 protège trois événements par défaut | Lecture recommandée : instance de suivi et type du catalogue sont distincts ; préserver historique. Pas besoin d’arbitrage si cette distinction satisfait le métier. |
| Notes remplacées | CdC IV.B.5 parle de compétence écrasée ; DEC-18 impose historique | Valeur courante actualisée, ancienne qualification conservée. Pas de contradiction nécessitant de rouvrir DEC-18. |
| Support | CdC III.G combine lecture globale et possibilité éventuelle d’agir comme un utilisateur | Aucune impersonation automatique acquise ; définir délégation si assistance active retenue. |
| Champs internationaux | SPEC US1/US2 : téléphone dix chiffres, code postal numérique, « Adresse » de type email ; CdC IV.A.8 prévoit localisation/internationalisation | Corriger les libellés/formats proposés ; ne pas figer ces anomalies de tableau. |
| Couverture Boond | AUDIT_ECRANS annonce 16 preuves en introduction, 33 dans la couverture et s’arrête à 33 ; ancien plan invoque 59 écrans | Distinguer fichiers capturés et descriptions auditées ; aucune preuve manquante n’est inventée. |

Les bugs connus du simulateur HTML restent des défauts de démonstration. La note de bas de page du CdC demandait un atelier métier : il a eu lieu le 16 sept 2026 (ATL). La forme graphique des KPI reste libre.

## Réponses tirées des cahiers et questions résiduelles

### Réponses possibles sans Ahmed

La structure cliente est hiérarchique à profondeur variable ; un service peut dépendre directement de la société. Le choix d’une représentation générique est une recommandation de conception qui n’a pas besoin d’être transformée en question métier sur trois tables.

Une qualification a toujours un besoin ; pour un recrutement sur profil, ce besoin appartient à l’agence. Un contact peut exister sans unité organisationnelle connue. Son transfert exige le traitement explicite des besoins/projets actifs. L’archivage d’un service exige l’absence de besoin/projet en cours et conserve l’accès à l’historique depuis la société.

US5 rend le contact obligatoire **dans le formulaire de création manuelle d’un projet**. Cela ne contredit pas le contact facultatif du besoin (DEC-04). `CreateProjectFromNeed` quand le besoin n’a pas de contact : **demander un contact au moment du projet** (F4), sans bloquer le besoin.

Le statut Client remonte la branche contractante et s’applique aux contacts de son service ; il ne descend pas automatiquement dans toutes les branches sœurs. La valeur courante d’une compétence peut évoluer sans détruire l’historique. Les droits sont l’union d’habilitations liées à leurs périmètres, et la possession permet de gérer les droits d’une fonctionnalité.

### Convention ATL — atelier chiffres 16 sept 2026

Ahmed a demandé l’atelier **maintenant**. Ce n’est pas une DEC. Ce n’est pas un tarif Avaliance. Les objets US5 (TJM HT, jours vendus, occupation, CJM contrat, CA/invest additionnels, frais j/m) sont les **entrées**. F16 : pas de module facture en V1.

Capacité d’un jour ouvré d’agence = 1 pour une ressource à temps plein V1. Jour non ouvré (F30) : capacité 0, pas de surcharge, pas de CA jour.

| Id | Indicateur | Formule V1 | Garde |
|---|---|---|---|
| ATL-01 | Jours ouvrés d’une prestation | Nombre de jours du calendrier d’agence entre début et fin, inclus | Affichage US5 « jour ouvré » |
| ATL-02 | Occupation engagée (j) | Somme des taux d’occupation des prestations qui couvrent j / 1 | Signée et prévisionnelle **distinguées** (F31). Alerte si signées > 100 % (DEC-10) |
| ATL-03 | Occupation réalisée (j) | Quantité de temps saisie ce jour / 1 | Temps sur la prestation de cette ressource (F32) |
| ATL-04 | TACE | Temps saisi / (capacité − absences) sur la période | Absence sans mission : F25. Hors jours non ouvrés |
| ATL-05 | CA signé régie | Σ (jours_vendus × TJM vendu HT) des prestations **signées** | Pas l’occupation × calendrier. Devise = celle de la prestation |
| ATL-06 | CA signé forfait | Même champs US5 : jours_vendus × TJM HT, plus lignes CA additionnel HT | Type projet Forfait. Pas de module à part |
| ATL-07 | CA prévisionnel | Même formules sur état **Prévisionnelle** | Quand elle passe Signée, elle sort du prévisionnel. Pas de double compte |
| ATL-08 | CA produit régie | Σ (quantité temps **saisie** × TJM vendu HT) sur la période | F35 : saisis, pas validés. V1 n’a pas de porte de validation. F34 : l’ajustement post-clôture entre dans le CA **courant**, pas dans le snapshot |
| ATL-09 | CA produit forfait | (ATL-06) × (ouvrés de la prestation ∩ période) / ouvrés totaux de la prestation | Pas les temps. Si dénominateur 0 : 0 |
| ATL-10 | CA facturé | HT factures émises − avoirs, date de facture | **Hors V1** (F16). ≠ encaissement. L’indicateur existe au backlog |
| ATL-11 | CA besoin pondéré | budget_besoin × pondération | Vu audit Boond. Si budget vide : 0. Pas un CA de production |
| ATL-12 | Coût produit | Σ (temps saisi × CJM **contrat** de la prestation) | DEC-08 : pas le CJM courant de la fiche ressource |
| ATL-13 | Frais imputés | frais_j × ouvrés ∩ période + frais_m × (jours de chaque mois / ouvrés du mois) + invest. HT à leur date | Les frais **baissent la marge**. Ils n’augmentent le CA que s’il existe une ligne CA additionnel |
| ATL-14 | Marge courante | CA produit (ATL-08 ou 09) − coût produit − frais imputés | Pendant l’activité. Même devise |
| ATL-15 | Marge clôturée | ATL-14 calculée à ClosePrestation, stockée avec la version ATL | DEC-09. F34 ne réécrit pas |
| ATL-16 | Taux de marge | ATL-14 / CA produit du même périmètre | Si CA produit = 0 : afficher « — », jamais Inf |
| ATL-17 | Change | Pas de conversion automatique V1 | Agrégat mixte EUR/USD/MAD : refus « non comparable ». Taux = lot ultérieur |
| ATL-18 | Avenant | Nouvelle prestation à compter d’une date (clôturer l’ancienne) | DEC-11. Pas un troisième objet. Pas de réécriture du passé |

KPI CdC (TJM, CJM, Turnover, TACE, Marge, taux de transformation, time to hire) : TJM/CJM affichés = moyenne des **prestations** pondérée par les jours de la période, pas la fiche ressource. Turnover et time-to-hire : backlog reporting, pas le noyau V1. Forme graphique : toujours l’atelier de restitution du CdC, pas une formule.

Rejeu S1–S8 **sans inventer un tarif** : S1 CA produit = 0,6 × TJM(T1). S4 occupation 100 %, pas d’alerte. S5 110 % les 15–19 mars ouvrés. S7 snapshot M1 = ATL-14 sur T1 au 15 janvier, avec TJM/CJM **de T1** — montant numérique impossible tant que T1 n’a pas ces champs dans le monde d’exercice.

### Deux familles — ne pas confondre

Les **DEC-Q01 à DEC-Q12** du hub (onglet Boond → Questions) sont des réponses d’Ahmed déjà prises ; elles correspondent aux DEC-01 à DEC-18. **Ne pas les rouvrir.**

Les **F1 à F36** ci-dessous sont les arbitrages du 16 septembre 2026 au soir. Ils ne remplacent pas les DEC. F35–F36 sont clos par la convention **ATL**, pas par un euro certifié.

### Feuille F1–F36 (Ahmed, 16 sept 2026)

Précisions jointes par Ahmed, essentielles :

- **F3 = B** : besoin à plusieurs postes — une première prestation signée ne signifie pas « pourvu ». Il **reste en staffing** jusqu’à ce que **tous** les postes visés le soient. Sens du statut, **pas** une DEC existante.
- **F17 = B** : commentaires et mentions hors V1. **Actions** et **historique** restent dans le premier lot.
- **F19 = A** : le CdC distingue Draft et Complété ; la conversion est un motif ou une commande, **pas** un troisième statut candidat.
- **F34 = B** : correction de temps après clôture = ajustement distinct tracé. **Jamais** réécrire le snapshot DEC-09.
- **F35 = C et F36 = A, puis atelier tenu** : convention ATL. CA produit régie = temps **saisis** × TJM. Facturé hors V1. Aucun tarif Avaliance saisi.

| # | Réponse | Règle |
|---|---|---|
| 1 | A | CreateProjectFromNeed sans ressource retenue : **refuser**. |
| 2 | A | Après conversion : **CreatePrestation suffit** ; pas de matching ressource obligatoire. |
| 3 | B | Pourvu multi-postes : **tous** les postes visés. Sinon staffing. |
| 4 | A | Besoin sans contact → projet : **demander le contact au projet**. |
| 5 | A | Matching si pourvu/suspendu/fermé : **refuser**, réactiver d’abord. |
| 6 | A | Graphe : ouvert → staffing → pourvu ; suspendu/fermé ; rouverture dédiée. |
| 7 | A | Clôturer un projet seulement si toutes les prestations sont closes. |
| 8 | A | Karim = Staffing **et** DP. |
| 9 | A | Conversion = Sophie RH seulement. |
| 10 | A | Pas d’ApproveRecruitment. |
| 11 | A | Léa évalue ; ni conversion, ni projet, ni prestation. |
| 12 | A | Commercial = nom d’affichage du groupe IA. |
| 13 | A | Support = lecture seule. |
| 14 | A | Admin sans pouvoir métier implicite. |
| 15 | A | V1 = CRM + candidat/ressource + matching + projet + prestation + temps + droits + historique. |
| 16 | A | Différer : éditeur, LinkedIn, emailing, portail, facture, achats. |
| 17 | B | Commentaires/mentions **hors V1**. Actions + historique **dans V1**. |
| 18 | A | Alertes intelligentes hors V1. |
| 19 | A | V1 : Draft / Complété. Conversion = BM-06, pas un statut. |
| 20 | A | Doublons : avertir, l’utilisateur choisit. Jamais fusion auto sur l’email. |
| 21 | A | Fusion un jour : habilité par type d’objet. |
| 22 | A | Contact et Personne distincts en V1. |
| 23 | A | Client jusqu’à requalification manuelle écrite. |
| 24 | A | Qui corrige : CRM habilité. |
| 25 | A | Absence sans mission : oui. |
| 26 | A | État ressource saisi à la main. |
| 27 | A | Restauration hors V1. |
| 28 | A | Restriction Admin gagne sur l’union. |
| 29 | A | Occupation au jour, affichage semaine/mois. |
| 30 | A | Capacité = calendrier d’agence. |
| 31 | A | Prévisionnelles dans l’occupation, distinguées. |
| 32 | A | Temps de production seulement sur une prestation de cette ressource. |
| 33 | A | Temps interne/intercontrat sans prestation : hors V1. |
| 34 | B | Correction post-clôture = ajustement tracé ; snapshot DEC-09 intact. |
| 35 | C→ATL | CA produit régie = temps **saisis** × TJM vendu (ATL-08). Pas de porte de validation V1. |
| 36 | A→ATL | Forfait, frais, change, marge, facturé : ATL-05 à ATL-18. Facturé **hors V1**. Aucun euro d’exemple. |

Correspondance ARB → feuille : ARB-1 = F1–F7 ; ARB-6 = F8–F14 ; ARB-5 = F15–F19 ; ARB-3 = F20–F22 ; ARB-4 = F23–F24 ; gardes = F25–F28 ; ARB-2 = F29–F34 + **ATL**.

Texte original d’Ahmed (pièce de décision) : [FEUILLE_F1-F36_AHMED_2026-09-16.md](FEUILLE_F1-F36_AHMED_2026-09-16.md).

## Modèle conceptuel

Un projet **peut naître sans besoin** (`CreateProject` US5). Un projet **peut exister sans prestation**. Les cardinalités ci-dessous ne disent pas « tout projet vient d’un besoin » ni « tout projet a déjà une prestation ».

Objets persistants V1 : Personne, CandidatProfile, RessourceProfile, Société, OrganizationUnit, Contact, Besoin, Positionnement, Projet, Prestation, Temps (sur prestation), Absence (sur ressource), Action (1 porteur), Compte (utilisateur ∪ groupe ∪ permission).

| Lien | Cardinalité | Garde |
|---|---|---|
| Personne → CandidatProfile / RessourceProfile | 0..1 chacun | Même identité à la conversion |
| Société → Besoin | 1 → N | Société obligatoire, contact facultatif |
| Société → Projet | 1 → N | Tout projet a une société. **CreateProject** (US5) ne passe pas par un besoin |
| Besoin → Positionnement | 1 → N | XOR candidat/ressource ; besoin ouvert ou staffing |
| Besoin → Projet | **0..N** | Un besoin peut n’avoir **aucun** projet. Un projet **peut n’avoir aucun besoin** |
| Projet → Prestation | **0..N** | Un projet encore **sans** prestation est autorisé (S3 : P3B) |
| Prestation → Temps | 0..N | Même ressource ; ajustement post-clôture ≠ snapshot |

Commandes V1 (familles) : CreateCompany/Contact/Need, Position*, ConvertCandidateToResource (Sophie), CreateProject (contact obligatoire), CreateProjectFromNeed (ressource retenue + contact à la commande si besoin vide), CreatePrestation, RecordTimesheet, RecordAbsence, ClosePrestation, CloseProject (prestations closes), Archive*. Pas de commentaires, pas d’éditeur de process, pas de facture.

Planning = vue (prestations, absences, positionnements, temps). Occupation au jour, calendrier d’agence. Marge = ATL-14/15. **Pas de montant numérique** sans TJM/CJM saisis sur la prestation.

## Les prochaines actions dans l’ordre

1. **17 sept.** — livrable **Modèle de données AvaManager v1** (~20–30 tables, relations, contraintes, statuts, matrice de droits). Plan : [PLAN_2026-09-17.md](PLAN_2026-09-17.md).
2. **Pas de code produit** (écrans, API, migrations) tant que ce livrable n’est pas validé.
3. Si un ATL est faux : le corriger par son id, puis **mettre à jour le hub**.
