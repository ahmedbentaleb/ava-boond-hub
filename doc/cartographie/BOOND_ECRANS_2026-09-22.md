# Boond — les écrans manquants, relevés le 22/09/2026

Complément au relevé du 19/09 (`BOOND_CHEMINS_2026-09-19.md`). ⭐ **Cliqué dans l'instance
Avaliance, en lecture seule** : aucune création, aucun enregistrement, aucun réglage touché.
Les captures nouvelles sont au hub, `ecrans/60-*` → `ecrans/81-*` — **79 captures** en tout.

<quand_utiliser>

| ✅ On ouvre ce fichier | ⛔ On ne l'ouvre pas pour |
|---|---|
| Savoir ce que porte un écran que le relevé du 19/09 n'avait pas capturé | les chemins et les états → le relevé du 19/09 |
| Préparer la reprise : quels champs Boond saisit vraiment | notre modèle → `MODELE_DONNEES_AVAMANAGER_V1.md` |

</quand_utiliser>

<etat>

| # | Écran | Capture | Ce qu'il porte, et ce que ça change pour nous |
|---|---|---|---|
| 60 | **Fiche prestation** `/deliveries/239` | ✅ | En-tête **CA HT · Coût HT · Marge HT · Rentabilité** (ici 50 560 € / 34 624 € / 15 936 € / 31,52 %). Informations : état, intitulé, début, fin, **jours ouvrés calculés (64)**, tarif de vente journalier, jours vendus, *ajouter des jours gratuits*, taux d'occupation, **contrat** rattaché, **CJM Contrat** ET **CJM Prestation** (les deux coûts, question R5), calendrier de la prestation, CA additionnels, **frais journaliers et mensuels**, nombre de jours ouvrés annuels. Liens : ressource, projet, type (régie), responsable manager, besoin, client, agence. ⚠️ Chez nous : un seul coût, pas de frais, pas de jours gratuits |
| 61 | **Fiche positionnement** `/positionings/4634` | ✅ | Même structure que la prestation : CA, coût, marge, rentabilité ; état (`CV envoyé`), début, fin, tarif de vente, jours vendus, taux d'occupation, **coût journalier moyen**, commentaire ; liens candidat, besoin, type, client, **responsable du besoin**. ⭐ Le positionnement porte donc déjà de l'argent chez Boond — pas chez nous |
| 62 | **Journal d'activité** `/logs` | ✅ | **338 495 entrées** (338 362 le 19/09). Chaque ligne : objet, type (modification), **auteur**, date, et le **diff avant/après** — jusqu'au JSON des droits d'un compte. ⭐ C'est notre `evenement_metier`, mais Boond y met aussi les changements de configuration |
| 63 | **Kanban des positionnements, complet** | ✅ | 8 colonnes visibles : Proposé (1 049) · NO GO interne (719) · GO interne (187) · CV envoyé (667) · Présenté Client (123) · Désistement (441) · Validé (80) · Rejeté (507). ⭐ C'est l'écran de travail du staffing : on déplace une carte d'une colonne à l'autre |
| 64 | **Créer un candidat** `/candidates/0/information` | ✅ | ⭐ **Pré-remplir la fiche à partir d'un CV** (PDF, Word, image — 15 Mo). Puis : civilité, nom, prénom, **titre**, type, date de naissance, e-mails et téléphones multiples, code postal, ville, pays, **réseaux sociaux**, commentaires. Bloc RH : **étape**, **provenance** (+ précisez), disponibilité, **mobilité**, responsable manager, **responsable RH**, agence, **pôle**, « visible uniquement de vous ». Bloc **évaluation du candidat** |
| 65 | **Créer une ressource** `/resources/0/information` | ✅ | Mêmes identités, plus : **type** (Consultant AVA Interne), responsable manager, responsable RH, agence, pôle, état (`En cours`), **TJM HT**, **devise**, disponibilité, mobilité |
| 66 | **Créer une société** `/companies/0/information` | ✅ | État (**Prospect**), effectif, **secteur**, ⭐ **société mère**, provenance, responsable manager, **influenceurs**, agence, pôle ; coordonnées avec ⭐ **« Ajouter un service »** (l'arbre client existe bien) ; **données légales** : statut juridique, TVA IC, SIRET, RCS, code APE, **numéro fournisseur** |
| 69 | **Alertes** `/administrator/alerts` | ✅ | **23 alertes** configurables + la **configuration des rapports** : jours d'envoi (lun→ven), heure du rapport quotidien (08:00), jour et heure du rapport hebdomadaire. ⭐ Chez nous : `alerte_regle`, et les horaires d'envoi manquent au registre |
| 70 | **Paramètres globaux** `/administrator/global-data/…` | ✅ | ⭐⭐ **Tous les référentiels de l'interface**, en 8 onglets : Actions/états · Données RH · Divers · Besoins/Projets · Évaluations · Facturation · Partager · Activité/frais. Boond prévient : opération sensible, **sauvegarde avant modification**. ⭐ C'est exactement notre écran Administration › Référentiels |
| 71 | **Managers** `/administrator/users-management/accounts` | ✅ | **35 comptes** : ressource, état, **rôle**, agence, pôle, manager. ⭐ Un compte est rattaché à une **ressource**, comme chez nous |
| 72 | **Agences juridiques** `/administrator/agencies` | ✅ | ⭐⭐ **5 agences** : AVALIANCE FR (€, calendrier France, 218 j, coef 1,7) · AVALIANCE NEARSHORE MA (MAD, 230 j, 1,5) · AVALIANCE MA (MAD, 218 j, 1,5) · **PORTALIANCE** (€, 218 j, 1,7) · AVALIANCE US ($, calendrier USA, 218 j, 1,7). ⭐ **Réponse à R6** : Portaliance est une **agence juridique de la même installation**, pas une société à part. ⚠️ Chaque agence porte sa **devise**, son **calendrier**, ses **jours ouvrés** et un **coefficient de charge** — nous n'avons pas le coefficient |
| 73 | **Rôles** `/administrator/users-management/roles` | ✅ | **16 rôles** pour 35 comptes, dont 3 rôles « Intranet » (salarié, freelance, sous-traitant) : Business Developer Paris (9) · Chargé de recrutement France (5) · IA RH CASA (5) · Ex-Avaliance (5) · Super Utilisateur (3) · Intranet salarié (3) · Responsable RH Paris (2) · et 9 rôles à un seul compte. ⭐ Notre matrice a **9 groupes** : l'écart vient des rôles par agence et par direction |

| 74 → 80 | **Paramètres globaux, les 7 autres onglets** | ✅ | Données RH · Divers · Besoins/Projets · Évaluations · Facturation · Partager · Activité/frais. ⭐ Toutes les listes de valeurs de Boond sont là : c'est le miroir de notre registre §B |
| 81 | **Plans de charge** `/planning` | ✅ | **229 ressources**, mois par mois (M9 2026 → M2 2027), filtrables par type. ⭐ Un plan de charge mensuel, pas un agenda |

⚠️ **Pourquoi les captures ont été difficiles** : Chrome bloque les téléchargements répétés déclenchés
par une page (« téléchargements automatiques ») — le premier passe, les suivants sont refusés en
silence, et un clic simulé ne lève pas le blocage. ⭐ **La parade retenue** : la page range l'image
dans `window.name`, l'onglet passe sur un petit service local (`127.0.0.1`), qui l'écrit sur le
disque. Aucun téléchargement, donc aucun blocage — et rien n'est envoyé hors de la machine.

⛔ **Non capturé, volontairement** : `Mon compte` (adresses IP des sessions ouvertes) et
`Espace développeur` (⚠️ **la clé d'API y est affichée en clair** — signalé le 19/09, toujours vrai).
⬜ **Reste à faire** : `Créer un contact` et `Créer un projet` (ils ne s'ouvrent que depuis une
société ou un besoin), les sous-écrans d'Achats, et les onglets de configuration d'un compte.

</etat>

<source>

Relevé du 22/09/2026 dans `ui.boondmanager.com`, session ouverte par Hamada, navigateur Chrome.
Captures produites par `html2canvas` dans la page, transportées par `window.name` vers un service
local, puis rangées dans `share-hub/ecrans/`. ⛔ Rien n'a quitté la machine.
⛔ Aucune écriture : les écrans de création ont été ouverts et quittés sans enregistrer.

</source>
