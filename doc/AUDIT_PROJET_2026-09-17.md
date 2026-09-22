# Audit du projet Ava Manager — 17 septembre 2026

**Verdict : le cadrage est cohérent et traçable ; il n'est pas prêt pour le livrable « Modèle de données v1 » sans corriger 4 trous de fond.** Aucun n'est cosmétique : chacun change une table ou une contrainte.

Périmètre audité : `_ops/` (brief, cadrage réconcilié, feuille F1–F36, ATL, plans du 15/16/17, transmission, cartographie Boond, hub), SPEC 2024, CdC 2022, zip `avaliance-crm-vision-360-code`, chantier LinkedIn. Lu en entier, pas survolé. Pas de petite bête : seules les choses qui changent le produit ou le risque sont listées.

---

## 1. Ce qui tient — et pourquoi

| Point | Preuve | Verdict |
|---|---|---|
| Chaîne de décision traçable | DEC-01→18 (brief) → F1–F36 (feuille signée) → ATL (atelier) → BM-01→61 (registre) → matrice → 15 simulations → modèle conceptuel. Chaque BM cite sa source et son statut ACQUISE / PROPOSÉE / DIFFÉRÉ. | ✅ Rare à ce niveau. On sait pourquoi chaque règle existe. |
| Contradictions sourcées, pas noyées | 24 contradictions listées avec les deux sources en désaccord et le traitement (US6 projet auto vs DEC-06 ; US2 « nouvelle ressource » vs DEC-01 ; bouton Boond « projet depuis candidat » vs DEC-14). | ✅ Le CdC 2022 et la SPEC 2024 ne sont pas pris pour argent comptant. |
| Le hub n'est pas pris pour un oracle | Brief §6 liste 9 bugs du simulateur ; le cadrage les traite comme cas rouges de spec, pas comme décisions. | ✅ |
| Discipline « pas de code » | 3 plans successifs, même porte : livrable v1 validé avant migration/API/UI. Zéro code produit dans le dossier. | ✅ Respectée. |
| Périmètre V1 fermé | F15–F18 : ce qui entre, ce qui est différé (éditeur, LinkedIn, emailing, portail, facture, achats, alertes, commentaires). Backlog conservé, pas abandonné. | ✅ |
| Économie sans euro inventé | ATL nomme 18 formules ; aucun tarif Avaliance saisi ; « montant impossible » écrit noir sur blanc dans S7. | ✅ Honnête. |
| Ordre du plan 17/09 | Modèle métier → livrable données → Postgres → rôles → machines d'état → mock → ADR → migrations → services. | ⚠️ Logique, **sauf** que 5 (machines d'état) doit passer **avant** 2 (livrable données) — voir §2.1. |

---

## 2. Ce qu'on a raté — par gravité

### 2.1 ⛔ Les machines d'état sont en étape 5, mais le livrable données (étape 2) ne peut pas s'écrire sans elles

Les statuts sont des colonnes avec CHECK. Aujourd'hui, un seul cycle est fermé (Besoin : ouvert/staffing/pourvu/suspendu/fermé). Les autres sont ouverts ou implicites :

| Objet | Ce que le canon dit | Ce qui manque pour une table |
|---|---|---|
| Positionnement | BM-23 : « état modifiable, types administrables ». Les simulations utilisent « retour client retenu » (BM-24, `ClientDecisionRecorded`). BM-28/F1 exige « positionnement ressource **retenu** ». | « Retenu » est-il un **état** du positionnement ou une **décision client** séparée ? Ça décide si la garde F1 lit `positionnement.etat` ou `decision_client.valeur`. Liste des états V1 jamais fixée (Boond en a 9). |
| Prestation | BM-29 : Signée / Prévisionnelle (commercial) **et** clôture opérationnelle, « deux dimensions à distinguer ». ATL-07 en dépend. | Deux colonnes ou une ? Une prestation Prévisionnelle peut-elle être clôturée ? Non écrit. |
| Projet | US5 : En cours / Archivé. BM-35 : clôture ≠ archivage. | Trois choses (ouvert, clos, archivé) — jamais posées en un cycle. |
| Candidat | F19 : Draft / Complété. | Fermé. ✅ |
| Ressource | F26 : En cours / Intercontrat / Sortie, saisi à la main. | Fermé. ✅ |

**Déclencheur ouvert→staffing du Besoin** : BM-60/F6 dit « prise en charge par Staffing » ; S1 étape 3 fait passer N1 en staffing **sur le retour client retenu**. Deux déclencheurs différents pour la même transition. À trancher avant de coder la machine.

⭐ **Correction du plan** : mettre les machines d'état en étape 1b, avant le livrable données. Le livrable les *contient*, il ne les précède pas.

### 2.2 ⛔ Contradiction F1 ↔ S2 : la garde de création de projet refuse le parcours candidat

- **F1 / BM-28** : `CreateProjectFromNeed` exige un « positionnement **ressource** retenu ».
- **S2** : Amina est positionnée **candidate** (X2), retenue par le client, convertie (BM-06), puis « Karim crée P2 » depuis N2.
- **DEC-03** : X2 porte un profil Candidat, pas Ressource. Après conversion, X2 reste un positionnement candidat (S2 le dit : « X2 candidat reste lisible »).

→ Pris à la lettre, **F1 refuse P2**. F2 (« CreatePrestation suffit ») règle la prestation, pas la garde du projet.

Ce n'est pas une nuance : ça décide si `positionnement` référence un **profil** (candidat_id XOR ressource_id, lecture actuelle) ou une **personne + type**, et ce que la garde F1 vérifie exactement. Recommandation : garde F1 = « positionnement retenu dont la **Personne** possède désormais un profil Ressource actif ». À faire signer par Ahmed, une ligne, avant le livrable.

### 2.3 ⛔ Objets absents du modèle conceptuel alors que les règles en dépendent

Le modèle conceptuel liste 13 objets. Les règles en utilisent au moins 8 de plus :

| Objet manquant | Qui en dépend | Gravité |
|---|---|---|
| **Agence** (interne) + **Pôle / Équipe** (= le *périmètre* de DEC-17) | Toute la matrice, S13/S14, BM-12 (« agences internes ≠ hiérarchie client »), US1/US5 lookup Agence | ⛔ Sans objet Périmètre, DEC-17 n'a pas de colonne sur laquelle s'appliquer. |
| **Calendrier d'agence** (jours fériés, ouvrés) | F30, ATL-01/02/04/09, S5/S6 | ⛔ Toute occupation et tout CA forfait en dépendent. |
| **Compte utilisateur ↔ Personne** | Self-service « S » de la matrice (Jean saisit *ses* temps) ; Boond lie Manager ↔ Ressource | ⛔ Sans ce lien, « soi-même » n'est pas vérifiable. |
| **Contrat** (ou son substitut) | BM-15 : « statut Client dérivé d'un **contrat signé** ». Il n'y a **aucun objet Contrat** en V1. | ⛔ La règle n'a pas de déclencheur. À remplacer par « première prestation Signée sur un projet de cette société » ou par une commande manuelle — à trancher. |
| **Postes visés** sur le Besoin | F3/BM-60 : « pourvu quand tous les postes visés ont une prestation signée ». BM-18 n'a pas ce champ dans ses entrées. | ⚠️ Et S4 compte Sara (60 % + 40 %) pour **deux** postes : un poste = une prestation ou une personne ? Non défini. |
| **Qualification** + **Compétence** (référentiel) | BM-09, BM-24, Léa dans S2/S15 | ⚠️ Dans V1 par les simulations, absent de la liste d'objets. |
| **Document** (CV, DT) | BM-04, BM-52, US3 | ⚠️ Stockage fichier non posé. |
| **Devise** (référentiel) + **Absence type** | ATL-17, BM-37 | mineur |

### 2.4 ⛔ Le canon n'est ni versionné ni sauvegardé

- `C:\Users\Hamada\Desktop\Ava Manager\` : **pas de dépôt git** à la racine. Seul `_ops/share-hub/.git` existe (le hub publié).
- Aucun dossier `sauvegardes/`. Aucune copie hors disque connue.
- Le canon, c'est **3 jours de décisions d'Ahmed** dans un dossier sur un Bureau. Un disque, une fausse manip, et la feuille F1–F36 n'existe plus nulle part.

Ce n'est pas un point de forme : c'est le seul risque de ce projet qui peut tout effacer en une seconde.

### 2.5 ⚠️ Un code RBAC existe déjà et personne ne l'a réconcilié avec DEC-17

`avaliance-crm-vision-360-code.zip` (15/09, deux copies identiques à la racine) contient un **prototype Administration & RBAC** : `schema.sql` PostgreSQL avec `users, roles, permissions, role_permissions, user_roles, sensitive_fields, sso_config, auth_tokens, user_sessions, audit_log`, matrice 33 × 7 cliquable, SSO Microsoft 365, charte Avaliance.

Aucun plan, aucun brief ne le cite. Or il incarne un modèle **rôles × permissions plats** — sans **groupes**, sans **périmètre**, sans « restriction gagne sur l'union » (F28). C'est exactement ce que DEC-17 refuse. Deux issues, une seule à choisir dans l'ADR : l'adopter comme socle et lui ajouter périmètre + groupes, ou le déclarer maquette et repartir de DEC-17. Le laisser traîner, c'est le voir réapparaître comme « on a déjà la base ».

### 2.6 ⚠️ La V1 ne permet pas d'arrêter Boond — et personne ne l'a écrit

Le motif d'origine (plan du 15/09) : Boond coûte > 2 500 €/mois et n'est utilisé qu'en partie. Or :

| Ce que Boond fait aujourd'hui pour Avaliance | En V1 Ava ? |
|---|---|
| CRM, candidats, ressources, besoins, positionnements, projets, prestations, temps | ✅ |
| Facture client (PostProduction) | ⛔ hors V1 (F16) |
| Achats / factures fournisseurs | ⛔ hors V1 |
| Paie (ExtractPayroll), absences validées | ⛔ hors V1 |
| **Reprise des données existantes** (sociétés, contacts, candidats avec 14 étapes admin, positionnements avec 9 états, projets, prestations, temps historiques) | ⛔ **jamais mentionné** dans aucun document |

Deux conséquences à écrire dans le cadrage : (1) pendant V1, Boond **reste** payé — dire combien de temps ; (2) le modèle de données doit prévoir dès v1 les colonnes de reprise (`boond_id`, table de correspondance des états Boond → états Ava), sinon la migration se fera à coups de scripts sur une base qui n'était pas faite pour.

Le point 4 du plan du 15/09 (« trancher le hors-scope ») et l'**inventaire de ce qu'Avaliance utilise vraiment dans Boond** n'ont jamais été faits ni reportés dans les plans suivants. C'est la seule donnée qui dit si V1 vaut 2 500 €/mois.

### 2.7 ⚠️ Points plus petits, mais qui touchent une table

| # | Constat | Effet |
|---|---|---|
| a | Besoin **interne** de recrutement sur profil (CdC II.K, BM-09/18) : « lié à l'agence même et non à un client ». DEC-04 impose une Société. | `besoin.societe_id NOT NULL` casse le besoin interne — ou Avaliance est une Société dans sa propre base. À trancher. |
| b | Positionnement : « unicité historique du couple non spécifiée, pas de blocage inventé » (BM-21). | Pas de UNIQUE (besoin, profil) → la même personne peut être positionnée deux fois sur le même besoin. Voulu ? |
| c | BM-36 « période autorisée » de saisie de temps : jamais définie. | Colonne ou règle absente. |
| d | Deux copies du hub (`share-hub/index.html` ≠ `cartographie/ava-manager.html`, divergentes ligne 7). | Laquelle fait foi ? Une seule source, l'autre supprimée ou générée. |
| e | « Validé par Ahmed » (porte du code) n'a pas de forme définie. | Recommandation : même mécanisme que la feuille F1–F36 — une pièce datée signée « Modèle v1 : validé », pas un « ok » dans un chat. |
| f | Tenant : ADR prévue en étape 7, **après** le schéma. | Mono-tenant ou multi change **chaque** table (`tenant_id`). À décider en étape 0, une ligne. |

---

## 3. Ce qui n'est PAS un problème (pour ne pas y revenir)

| Sujet | Pourquoi c'est réglé |
|---|---|
| Matrice rôles × commandes pas encore signée | DEC-17 = groupes + permissions + périmètre. La matrice est de la **donnée de configuration**, pas du schéma. Le modèle de données peut être livré avant qu'elle soit signée. |
| Aucun euro dans les simulations | Voulu (ATL). Le schéma porte des formules, pas des tarifs. |
| LinkedIn US3/US4 non faits | Chantier séparé, différé F16, tests locaux verts. N'influence pas le noyau. |
| Simulateur HTML bugué (brief §6) | Traité comme cas rouges de spec. Le hub est pédagogique, pas un mock. |
| Audit écrans Boond « non clos » (33/59) | Suffisant : les 5 chemins et les invariants sont établis. Finir les captures n'apporterait rien au modèle. |
| Achats / facture hors V1 | Cohérent avec ATL-12 (coût externe = CJM contrat sur prestation). Rien ne bloque. |

---

## 4. Ce qu'il faut faire — dans l'ordre

| # | Action | Bloque quoi | Effort |
|---|---|---|---|
| 0 | **`git init` à la racine + `sauvegardes/canon_2026-09-17/` avec manifeste SHA-256 + une copie hors disque** | Tout | 20 min |
| 1 | Décision d'Ahmed en 4 lignes : (a) garde F1 = personne avec profil Ressource actif ; (b) « retenu » = état ou décision ; (c) déclencheur ouvert→staffing ; (d) un poste = une prestation signée. | Livrable v1 | 1 échange |
| 2 | Ajouter au modèle conceptuel : Agence, Périmètre, Calendrier, Compte↔Personne, Qualification/Compétence, Document, postes visés, substitut de Contrat. | Livrable v1 | ½ journée |
| 3 | Fermer les 3 machines d'état ouvertes (Positionnement, Prestation, Projet) — **avant** le livrable, pas en étape 5. | Livrable v1 | ½ journée |
| 4 | ADR-0 : mono/multi-tenant ; ADR-1 : sort du prototype RBAC du zip. | Schéma | 2 lignes chacune |
| 5 | Section « Reprise Boond » dans le livrable : `boond_id`, correspondance des états, ce qui reste sur Boond et jusqu'à quand. | Le « pourquoi » du projet | ½ journée |
| 6 | Inventaire d'usage réel Boond (quelles fonctions, combien d'objets, quelles apps) — le point 4 du 15/09 jamais fait. | Décision de dé-commissionner | 1 h dans Boond |
| 7 | Puis seulement : le livrable **Modèle de données v1**. | Le code | — |

Étape 0 est **aujourd'hui**. Les étapes 1–4 se font en une journée. Le livrable v1 ne perd donc qu'un jour — et gagne quatre trous en moins.

---

## 5. En une phrase pour quelqu'un qui n'a pas le temps

Le travail de cadrage est solide et honnête ; ce qu'il manque, ce n'est pas de la réflexion, ce sont **quatre objets, trois cycles d'état, une contradiction F1/S2, et une sauvegarde** — tous corrigeables en un jour, tous bloquants si on les découvre en écrivant les tables.
