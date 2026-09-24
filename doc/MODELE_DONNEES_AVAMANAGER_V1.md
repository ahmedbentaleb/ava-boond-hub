# Modèle de données AvaManager v1

Date : 17/09/2026 · Statut : **à valider par Ahmed** (porte du plan, G15) · **Patché le 17/09 au soir** après quatre relectures — D-1→D-9, P-1/P-2/P-4/P-5, O-1→O-3, M-14, M-15 : [RELECTURE_5_MODELE_DONNEES](RELECTURE_5_MODELE_DONNEES_2026-09-17.md) §0
Canon : DEC-01→18 · F1–F36 · ATL-01→18 · G1–G15 · P1–P3 · ADR-000→005 · BM-01→61
Sources de forme : [modèle métier](MODELE_METIER_CANONIQUE_v1.md) · [machines d'état](MACHINES_ETAT_V1.md) · [registre des politiques](REGISTRE_POLITIQUES_v1.md)

**Ce document est la porte.** Une fois validé, l'exécutant écrit le schéma physique, les migrations, les services. Rien avant.

---

## 0. Comment lire ce document

| Convention | Sens |
|---|---|
| `NOT NULL` | obligatoire en base, pas seulement à l'écran |
| **MUR M-n** | contrainte non paramétrable — registre §A. Un mur tombe par ADR, jamais par réglage |
| **POL `cle`** | le comportement dépend d'une politique — registre §C. Le défaut reproduit la décision du 17/09 |
| `→ table` | clé étrangère |
| ⬜ hors V1 | table nommée pour ne pas être oubliée, **non créée** en v1 |

**Conventions générales, valables pour toutes les tables :**

| Règle | Détail |
|---|---|
| Clé primaire | `id UUID PRIMARY KEY DEFAULT gen_random_uuid()` partout. Jamais d'entier séquentiel exposé |
| Pas de `tenant_id` | ADR-000, P1 : une base = une société |
| Horodatage | `cree_le TIMESTAMPTZ NOT NULL DEFAULT now()`, `cree_par_compte_id → compte` sur toute table métier |
| Archivage | `archive_le TIMESTAMPTZ NULL`, `archive_par_compte_id → compte` sur les objets historiques. **MUR M-8** : aucun DELETE |
| Modification | pas de `modifie_le` : l'historique est dans `evenement_metier` (ADR-004) |
| Textes | `TEXT`, jamais `VARCHAR(n)` — une longueur arbitraire est une règle métier cachée |
| Montants | `NUMERIC(14,2)` + `devise_code` à côté : **NOT NULL** si le montant l'est, sinon CHECK « montant présent ⇔ devise présente ». **MUR M-15** |
| Taux | `NUMERIC(5,2)` en pourcentage (60.00 = 60 %) |
| Dates métier | `DATE` pour les jours (début, fin, jour de temps) ; `TIMESTAMPTZ` pour les faits système |
| Fuseau | tout en `TIMESTAMPTZ`. L'affichage convertit au fuseau du lecteur — **jamais** deux horloges |
| ⭐ Contrainte sous politique | **nullable en base, garde dans la commande.** Un NOT NULL, un CHECK ou un index qu'une politique peut relâcher est un `ALTER TABLE` déguisé : changer le réglage deviendrait une migration (ADR-005 ; D-5, D-6) |
| Motifs de transition | dans `evenement_metier.motif`, **jamais en colonne** de l'objet (P-5) |

---

## 1. Carte des tables (compte : registre §E)

Le premier tirage disait « 27 tables + 16 `ref_*` » : une ligne en groupait quatre, `permission` et `perimetre` manquaient, et 8 référentiels techniques n'étaient pas comptés (D-8). Ce qu'on valide doit être ce qu'on compte.

| # | Table | Famille | Rôle |
|---|---|---|---|
| 1 | `personne` | Identité | l'humain, une fois |
| 2 | `profil_candidat` | Identité | le vivier |
| 3 | `profil_ressource` | Identité | qui peut travailler |
| 4 | `document` | Identité | CV, DT, pièce |
| 5 | `societe` | Client | client, prospect, fournisseur, interne |
| 6 | `societe_role` | Client | les rôles cumulables : fournisseur, interne |
| 7 | `unite_organisation` | Client **et interne** | pôle / BU / service, arbre — aussi les pôles et équipes d'Avaliance (D-1) |
| 8 | `contact` | Client | personne chez le client |
| 9 | `besoin` | Staffing | la demande |
| 10 | `besoin_competence` | Staffing | ce qui est demandé |
| 11 | `positionnement` | Staffing | un humain sur un besoin |
| 12 | `positionnement_suivi` | Staffing | CV partagé, entretien… |
| 13 | `qualification` | Staffing | une séance d'évaluation, pour un besoin |
| 14 | `qualification_mesure` | Staffing | compétence × note, par séance |
| 15 | `projet` | Production | le cadre contractuel |
| 16 | `prestation` | Production | qui travaille, à quelles conditions |
| 17 | `prestation_ligne_ca` | Production | CA et invest. additionnels (US5) |
| 18 | `temps` | Production | la production réelle |
| 19 | `absence` | Production | l'indisponibilité |
| 20 | `snapshot_marge` | Production | la marge figée |
| 21 | `agence` | Structure | l'agence interne |
| 22 | `calendrier_jour_non_ouvre` | Structure | la capacité |
| 23 | `compte` | Droits | l'utilisateur |
| 24 | `groupe` | Droits | un ensemble de droits |
| 25 | `compte_groupe` | Droits | qui est dans quel groupe |
| 26 | `permission` | Droits | le catalogue des commandes |
| 27 | `perimetre` | Droits | sur quoi un droit s'applique — agence, pôle, équipe, global |
| 28 | `groupe_permission_perimetre` | Droits | **la paire** droit × périmètre (M-13) |
| 29 | `compte_surcharge` | Droits | la restriction nominative (F28) |
| 30 | `action` | Transverse | le journal CRM |
| 31 | `evenement_metier` | Transverse | l'historique, ajout seul |
| 32 | `politique` | Transverse | les bifurcations (registre §C) |
| + | `modele` | Configuration | ⭐ **S-10.1, 19/09** — actions, recherches, listes de tâches, formulaires |
| + | `alerte_regle` | Configuration | ⭐ **S-10.3, 19/09** — les alertes ne sont plus dans le code |
| + | `periode_emploi` | Identité | ⭐ **M15, 19/09** — partir et revenir. Une personne, plusieurs périodes |
| + | `prestation_version` | Production | ⭐ **B-2, 19/09** — l'avenant daté. Ajout seul. Vide sous le défaut Avaliance |
| + | `reprise_boond` | Migration | la correspondance — se retire après la reprise |
| + | `ref_*` | Référentiels | les listes à catégorie (§6.3) — **compte au registre §E** |

⬜ **Hors V1, nommées** : `achat`, `facture_client`, `facture_fournisseur`, `paiement`, `commentaire`, `mention`, `alerte`, `modele_email`, `processus_recrutement`, `processus_etape`, `objectif`, `compte_portail_candidat`.

---

## 2. Identité

### 2.1 `personne` — l'identité commune (DEC-01)

| Colonne | Type | Contrainte |
|---|---|---|
| `id` | UUID | PK |
| `civilite` | TEXT | `→ ref_civilite.code` |
| `nom`, `prenom` | TEXT | NOT NULL |
| `date_naissance` | DATE | NULL |
| `email` | TEXT | NULL — **pas d'UNIQUE** (POL `doublon.personne.*` : avertir, jamais bloquer, F20) |
| `telephone` | TEXT | NULL — format international, **pas** 10 chiffres (correction BM-58 de US1) |
| `adresse`, `code_postal`, `ville` | TEXT | NULL — `code_postal` **textuel** (zéro initial, alphanumérique) |
| `pays_code` | TEXT | `→ ref_pays.code` |
| `linkedin_url` | TEXT | NULL |
| `archive_le`, `archive_par_compte_id` | | MUR M-8 |

Index : `(nom, prenom)`, `lower(email)`, `(date_naissance)` — servent la **détection** de doublons, pas le blocage.

⚠️ La SPEC US1 déclare « Adresse » de type *Adresse email* et « Code postal » *Numérique*. Deux erreurs de tableau, corrigées ici (BM-58).

### 2.2 `profil_candidat` (DEC-01/02, F19)

| Colonne | Type | Contrainte |
|---|---|---|
| `id` | UUID | PK |
| `personne_id` | UUID | NOT NULL, `→ personne`, **UNIQUE — MUR M-3** |
| `etat_code`, `etat_categorie` | TEXT | NOT NULL, `→ ref_etat_candidat.code` ; catégorie maintenue par trigger (P-1) |
| `titre` | TEXT | NOT NULL |
| `provenance`, `precisez` | TEXT | US3 |
| `disponibilite_code`, `mobilite` | TEXT | `→ ref_disponibilite` |
| `pretentions_montant`, `pretentions_devise_code` | NUMERIC(14,2), TEXT | NULL — CHECK `(pretentions_montant IS NULL) = (pretentions_devise_code IS NULL)` (M-15 : un montant présent a toujours sa devise) |
| `manager_compte_id`, `rh_compte_id` | UUID | `→ compte` |
| `agence_id` | UUID | `→ agence` |
| `commentaire` | TEXT | |
| `visible_uniquement_par_compte_id` | UUID | NULL — cloisonnement vu à l'audit Boond 06 |
| `archive_le`… | | |

Garde de `CompleteCandidate` : **POL `candidat.complete.champs_requis`** (liste de noms de colonnes) — pas un CHECK figé.

### 2.2 bis `periode_emploi` — partir et revenir (M15, 19/09)

⭐ **Une personne qui part et revient reste UNE personne.** Deux contrats, deux coûts, deux périodes — jamais deux fiches. Sans cette table, le second passage écrasait le premier ou créait un doublon ; les deux sont faux.

| Colonne | Type | Contrainte |
|---|---|---|
| `profil_ressource_id` | UUID | **PK (1/2)** `→ profil_ressource` |
| `debut` | DATE | **PK (2/2)**, NOT NULL |
| `fin` | DATE | NULL = en cours. CHECK `fin >= debut` |
| `type_code` | TEXT | `→ ref_type_ressource` — on peut revenir sous un autre statut |
| `agence_id` | UUID | NOT NULL — **M7** : l'agence de cette période, pas celle d'aujourd'hui |
| `societe_fournisseur_id` | UUID | NULL |
| `cout_reference`, `cout_reference_devise_code` | NUMERIC(14,2), TEXT | NULL ensemble ou pleins ensemble (M-15) — **donnée sensible** |
| `motif_fin_code` | TEXT | NULL `→ ref_motif_fin_emploi` |

**Triggers :**
1. ⛔ **Aucun chevauchement** — `EXCLUDE USING gist` sur `(profil_ressource_id, daterange(debut, fin))`. Une personne n'a pas deux emplois le même jour chez le même employeur.
2. ⛔ **Ajout seul sur les périodes closes** : une période dont `fin` est renseignée ne se modifie plus. On en ouvre une autre.

⚠️ **Ce que ça ne change pas** : `profil_ressource` garde ses colonnes d'aujourd'hui — elles décrivent **l'état courant**. La table dit **l'histoire**. ⛔ Et **M-14 tient** : les conditions d'une mission ne lisent jamais cette table, elles sont figées sur la prestation.

`ref_motif_fin_emploi` : `demission` · `fin_contrat` · `rupture` · `fin_mission_externe` · `autre` — **valeurs système**.

---

### 2.3 `profil_ressource` (DEC-01/02/12, US1, F26)

| Colonne | Type | Contrainte |
|---|---|---|
| `id` | UUID | PK |
| `personne_id` | UUID | NOT NULL, `→ personne`, **UNIQUE — MUR M-3** |
| `type_code` | TEXT | NOT NULL, `→ ref_type_ressource.code` (INTERNAL / EXTERNAL) |
| `etat_code`, `etat_categorie` | TEXT | NOT NULL, `→ ref_etat_ressource.code` ; catégorie par trigger (P-1) — POL `ressource.etat.mode` (défaut manuel, F26) |
| `titre` | TEXT | NOT NULL (US1) |
| `agence_id` | UUID | NOT NULL, `→ agence` |
| `societe_fournisseur_id` | UUID | NULL, `→ societe` |
| `cout_reference`, `cout_reference_devise_code` | NUMERIC(14,2), TEXT | NULL — **donnée sensible**, permission séparée |
| `tjm_indicatif`, `tjm_indicatif_devise_code` | NUMERIC(14,2), TEXT | NULL |
| `disponibilite_code`, `mobilite` | TEXT | |
| `manager_compte_id`, `rh_compte_id` | UUID | `→ compte` |
| `archive_le`… | | |

**CHECK — POL `ressource.externe.societe_fournisseur`** (défaut obligatoire, DEC-12) :
`(type_code = 'EXTERNAL') = (societe_fournisseur_id IS NOT NULL)`
⚠️ Ce CHECK est appliqué **par la commande**, pas en base, parce que la politique peut le relâcher. En base : un simple index.

### 2.4 `document`

| Colonne | Type | Contrainte |
|---|---|---|
| `id` | UUID | PK |
| `type_code` | TEXT | `→ ref_type_document` (cv, dt, contrat, autre) |
| `personne_id`, `profil_candidat_id`, `profil_ressource_id`, `projet_id`, `societe_id` | UUID | **cinq FK nullables — CHECK : exactement une non nulle** (patron de `action`, D-7). Plus de `porteur_type / porteur_id` : une référence sans FK peut pointer dans le vide |
| `nom_fichier`, `chemin_stockage`, `mime`, `taille_octets` | | |
| `sha256` | TEXT | intégrité |
| `archive_le`… | | |

Stockage : **fichiers hors base** (disque ou objet), la table porte le chemin et l'empreinte. Une base qui grossit de CV est une base qu'on ne sauvegarde plus.

---

## 3. Client

### 3.1 `societe` + `societe_role` (BM-11, G6)

`societe` : `id`, `nom` NOT NULL, `nom_normalise` (index, détection de doublons), `siren` NULL, `secteur`, coordonnées, `manager_compte_id`, `statut_commercial_code → ref_statut_commercial` (prospect / client), `archive_le`.

`societe_role` : `(societe_id, role_code)` PK, `role_code → ref_role_societe` ∈ {**fournisseur**, **interne**} — cumulables.

⭐ **Rôle ≠ statut (D-3).** Un *rôle* est une capacité durable : fournir des ressources (`fournisseur`), être Avaliance elle-même (`interne`). Le *statut commercial* est la position dans la relation — `prospect` ou `client` — **une colonne, un cycle** (machines §7). `client` et `prospect` **ne sont pas des rôles** : une société cliente **et** fournisseuse = statut `client` + rôle `fournisseur`, sans duplication (BM-11). Le simulateur avait fait les deux à la fois : c'est exactement la divergence que cette ligne interdit. Le rôle `interne` porte Avaliance elle-même (**G6**) et permet le besoin de recrutement sur profil sans casser `besoin.societe_id NOT NULL` (**MUR M-11**).

Passage `prospect → client` : **POL `societe.passage_client.declencheur`** (défaut : première prestation `engage`) et **POL `societe.passage_client.propagation`** (défaut : branche contractante + contacts du service). Retour : **POL `societe.retour_prospect`** (défaut manuel, F23).

**Propagation (D-2)** : `unite_organisation.statut_commercial_code` et `contact.statut_commercial_code`, **nullables — NULL = `prospect`, jamais « hérite »** (troisième passe : hériter ferait passer client les branches sœurs, contraire à BM-15). `ClientStatusDerived` écrit **explicitement** `client` sur la branche contractante, ses ascendants et les contacts que `societe.passage_client.propagation` désigne ; tout le reste reste NULL. Sans ces deux colonnes, la politique n'avait rien à écrire.

### 3.2 `unite_organisation` (BM-12)

`id`, `societe_id` NOT NULL, `parent_id` NULL `→ unite_organisation`, `type_code → ref_type_unite` (pole / bu / service / equipe), `nom`, `description`, `statut_commercial_code` NULL `→ ref_statut_commercial` (D-2), `archive_le`.

⭐ **C'est aussi l'arbre interne (D-1).** Les pôles et équipes d'Avaliance sont des `unite_organisation` de la société de rôle `interne` (G6). Il n'y a **qu'une** hiérarchie d'unités dans la base ; ce qui distingue l'interne du client, c'est le rôle de la société porteuse — pas une seconde table. C'est ce que `perimetre.unite_id` référence (§7).

**Le lien avec `agence` (D-1, second patch)** : colonne `agence_id` NULL `→ agence` sur `unite_organisation`, avec trigger — **NOT NULL si la société est `interne`, NULL sinon**. Une agence est un site (calendrier F30, pays) ; un pôle ou une équipe interne est une organisation **à l'intérieur** d'une agence. `agence` reste une table parce qu'elle porte le calendrier et la capacité (ATL-01) ; elle n'est plus une seconde hiérarchie : chaque unité interne sait de quelle agence elle dépend. Le client, lui, n'a pas d'agence.

**MUR M-12**, trois triggers : le parent appartient à la même société ; **pour une unité interne, le parent appartient à la même agence** (D-1, troisième passe — sinon une équipe de l'agence B pendrait d'un pôle de l'agence A) ; pas de cycle. Un service peut pendre d'une BU, d'un pôle **ou directement de la société** (CdC II.D).
Archivage : **POL `service.archivage.garde`** (défaut : aucun besoin ni projet actif, BM-17).

### 3.3 `contact` (BM-13, F22)

`id`, `societe_id` NOT NULL `→ societe` (**MUR M-12**), `unite_organisation_id` NULL, `civilite`, `nom`, `prenom`, `fonction`, `type_code → ref_type_contact` (décisionnaire, technique, facturation…), `statut_code` (actif / parti), `statut_commercial_code` NULL `→ ref_statut_commercial` (D-2 : **NULL = prospect** ; `client` est écrit explicitement par `ClientStatusDerived`, jamais hérité), email, téléphone, `manager_compte_id`, `archive_le`.

⚠️ **Aucun lien vers `personne`** — F22 : deux objets distincts en V1. Le jour où on les rapproche, ce sera une ADR et une colonne, pas une fusion silencieuse (F20/F21).
Trigger : si `unite_organisation_id` est renseignée, elle appartient à `societe_id`.
Transfert : **POL `contact.transfert.objets_actifs`** (défaut : réaffectation obligatoire, BM-14).

---

## 4. Staffing

### 4.1 `besoin` (DEC-04/05/13, F3, G4, G6)

| Colonne | Type | Contrainte |
|---|---|---|
| `id` | UUID | PK |
| `societe_id` | UUID | **NOT NULL — MUR M-11** |
| `contact_id` | UUID | NULL — **POL `besoin.contact`** (défaut facultatif, DEC-04) |
| `unite_organisation_id` | UUID | NULL |
| `agence_id` | UUID | NOT NULL — l'agence interne qui traite (CdC II.K) |
| `titre` | TEXT | NOT NULL |
| `contexte`, `reference_ao` | TEXT | |
| `type_code` | TEXT | `→ ref_type_mission` (regie / forfait) |
| `etat_code`, `etat_categorie` | TEXT | NOT NULL, `→ ref_etat_besoin.code` ; catégorie par trigger (P-1) |
| `priorite_code` | TEXT | `→ ref_priorite_besoin.code` — **dimension indépendante de l'état** (DEC-13) |
| `nb_postes_vises` | INT | NOT NULL DEFAULT 1, CHECK ≥ 1 — **G4**. ⚠️ Un projet créé **sans** besoin (`projet.besoin_id NULL`) ne compte pour aucun besoin : pour pourvoir un besoin, on crée le projet **depuis** lui (DEC-05). X-7 |
| `unite_couverture_code` | TEXT | NOT NULL DEFAULT `'postes'`, `→ ref_unite_couverture.code` — **B-1, 19/09**. Ce qui satisfait le besoin : des **postes**, une **charge** (FTE), ou les deux |
| `fte_vise` | NUMERIC(6,2) | NULL, CHECK > 0 — **B-1**. Trigger : NOT NULL dès que `unite_couverture_code` vaut `fte` ou `postes_et_fte`, NULL sinon |
| `date_demarrage_souhaitee` | DATE | |
| `budget`, `budget_devise_code` | NUMERIC(14,2), TEXT | NULL — CHECK `(budget IS NULL) = (budget_devise_code IS NULL)` (M-15) |
| `ponderation_pct` | NUMERIC(5,2) | NULL — ATL-11 : CA pondéré = budget × pondération |
| `manager_compte_id` | UUID | `→ compte` |
| `archive_le`… | | |

**La garde de `DeclareNeedFilled`** (**POL `besoin.pourvu.garde_minimale`**, défaut `tous_les_postes_signes`, T-1) **lit l'unité de couverture** — B-1, 19/09. Sur le périmètre `E = prestation WHERE etat_categorie = 'engage' AND projet_id IN (SELECT id FROM projet WHERE besoin_id = besoin.id)` :

| `unite_couverture_code` | Ce que la garde exige |
|---|---|
| **`postes`** ⭐ *(défaut Avaliance, DEC-05 · G4 · T-1)* | `count(E) ≥ nb_postes_vises` — le comportement d'avant, inchangé |
| `fte` | `sum(E.taux_occupation_pct) / 100 ≥ fte_vise` |
| `postes_et_fte` | **les deux à la fois** |

⛔ **Le trou que B-1 bouche** (relecture externe du 19/09, H4) : « deux missions = deux postes » est **faux**. Deux personnes à 50 % font **une** charge pleine et **deux** postes occupés. Sous `postes`, un besoin de 2 postes se déclarait pourvu avec deux mi-temps, et rien ne le signalait. ⭐ Le défaut ne bouge pas — c'est le relecteur qui gagne une option, pas Avaliance qui change de règle.

Triggers **MUR M-12** : `contact_id` et `unite_organisation_id`, s'ils sont présents, appartiennent à `societe_id` (BM-19, P-2).

`besoin_competence` : `(besoin_id, competence_code)`, `niveau_requis`, `obligatoire BOOL`.

### 4.2 `positionnement` (DEC-03, G1, G2, G7, G10)

| Colonne | Type | Contrainte |
|---|---|---|
| `id` | UUID | PK |
| `besoin_id` | UUID | NOT NULL `→ besoin` |
| `profil_candidat_id` | UUID | NULL `→ profil_candidat` |
| `profil_ressource_id` | UUID | NULL `→ profil_ressource` |
| `personne_id` | UUID | NOT NULL `→ personne` — **dénormalisé, écrit par trigger** depuis le profil |
| `etat_code`, `etat_categorie` | TEXT | NOT NULL `→ ref_etat_positionnement.code` ; catégorie par trigger (P-1) |
| `tjm_propose`, `tjm_propose_devise_code` | NUMERIC(14,2), TEXT | NULL (DEC-08) |
| `decision_client_le` | DATE | NULL — la date du retour (G2 : l'état porte la décision) |
| `archive_le`… | | |

**MUR M-2** — CHECK XOR : `(profil_candidat_id IS NULL) <> (profil_ressource_id IS NULL)`

⭐ **`personne_id` dénormalisé** : c'est ce qui rend la garde **G1** lisible en une jointure — « un positionnement de catégorie `terminal_positif` dont la personne a un profil ressource actif » — sans savoir si le positionnement était candidat ou ressource. Trigger `BEFORE INSERT` : le remplit depuis le profil ; `BEFORE UPDATE` : refuse de le changer.

Unicité — **POL `positionnement.unicite`** (défaut `actifs`) : **garde de commande** dans `Position*`, lue à l'exécution (D-6). En base : un index **simple** `(besoin_id, personne_id)`, pour la lecture. ⛔ Pas d'index unique partiel : il figerait l'option `actifs`, et changer la politique deviendrait une migration — contraire à ADR-005. Si l'unicité devait un jour être garantie par la base, ce serait un mur M-16 et les options `aucune` / `historique` sortiraient du registre ; P3 a fixé quinze murs.

**Toutes les tables à état** portent `etat_categorie`, colonne redondante **maintenue par trigger** depuis `ref_etat_<objet>`, parce que gardes, vues et index raisonnent sur la catégorie (ADR-005, P-1).

**Motifs de transition (P-5)** : le motif d'un refus client, d'un retrait, d'une suspension vit dans `evenement_metier.motif` — **jamais en colonne** de l'objet. Une seule place ; les codes admis restent dans `ref_motif_retrait`.

`positionnement_suivi` : `(positionnement_id, etape_code → ref_etape_suivi_positionnement)`, `statut`, `date`, `commentaire`. L'étape `cv_partage` est **système** : retirable d'un dossier, jamais du catalogue (BM-23, CdC IV.G.4).

### 4.3 `qualification` + `qualification_mesure` (BM-09/24)

`qualification` : `id`, `besoin_id` **NULL en base, exigé par la commande** sous **POL `qualification.besoin_obligatoire`** (défaut oui, BM-09 — D-5), `personne_id` NOT NULL, `positionnement_id` NULL, `type_code → ref_type_qualification`, `evaluateur_compte_id` NOT NULL, `date`, `commentaire`, `resultat_global`.

`qualification_mesure` : `(qualification_id, competence_code)`, `niveau_mesure` NULL — **NULL ≠ zéro** : une compétence non mesurée n'est pas une compétence nulle (BM-09). Une `qualification` est **une séance d'évaluation** : une mesure par compétence et par séance, d'où la PK. Ré-évaluer = une **nouvelle** `qualification`, jamais une mise à jour. La fiche affiche la mesure de la séance la plus récente ; les séances précédentes restent lisibles — c'est ainsi que l'historique est conservé (CdC IV.B.5, **MUR M-7**, O-1).

---

## 5. Production

### 5.1 `projet` (DEC-05/06/07, US5, F4, F7, G1, G12)

| Colonne | Type | Contrainte |
|---|---|---|
| `id` | UUID | PK |
| `reference` | TEXT | UNIQUE — générée (PRJ-xxxx) |
| `societe_id` | UUID | NOT NULL |
| `contact_id` | UUID | **NULL en base**, exigé par la commande sous **POL `projet.contact`** (défaut obligatoire, US5/F4 — D-5) |
| `contact_technique_id`, `contact_facturation_id` | UUID | NULL (US5) |
| `besoin_id` | UUID | **NULL** — un projet direct n'a pas de besoin (US5, ADR-003) |
| `agence_id` | UUID | NOT NULL |
| `type_code` | TEXT | NOT NULL `→ ref_type_mission` (regie / forfait) |
| `titre` | TEXT | NOT NULL |
| `etat_code`, `etat_categorie` | TEXT | `→ ref_etat_projet` |
| `date_debut`, `date_fin` | DATE | |
| `lieu_adresse`, `lieu_code_postal`, `lieu_ville`, `lieu_pays_code` | | US5 section 2 |
| `responsable_manager_compte_id` | UUID | |
| `devise_defaut_code` | TEXT | NULL `→ ref_devise` — **valeur proposée** à la création d'une prestation (US5 « Devise ») ; aucun calcul ne la lit (D-9) |
| `description`, `conditions_particulieres` | TEXT | US5 |
| `archive_le`… | | |

⛔ **MUR M-5 — aucune colonne `profil_ressource_id`.** Les ressources d'un projet sont `SELECT DISTINCT profil_ressource_id FROM prestation WHERE projet_id = ?`

⛔ **Aucune colonne `devise_code` économique (D-9)** — seulement `devise_defaut_code` NULL, **valeur proposée** à la création d'une prestation (US5), sans aucun calcul dessus. **Arbitrage de modélisation, Brain, 17/09** — pas une conséquence d'ADR-003 (qui est cohérent avec ce choix sans l'imposer) : la devise est celle de **chaque prestation**, et les agrégats groupent par devise (M-15). Deux devises sur un même projet : **POL `projet.devises_mixtes`** (défaut **autorise** — affichage en deux lignes ; option `refus` : `CreatePrestation` refuse une devise différente de la première prestation du projet). Cas réel Avaliance : un freelance MAD sur un projet facturé en EUR. Cahier des directeurs, question 61.

Triggers **MUR M-12** (O-3) : `contact_id`, `contact_technique_id`, `contact_facturation_id`, s'ils sont présents, appartiennent à `societe_id`.

### 5.2 `prestation` (DEC-07/08/09/10/11, US5, G11)

| Colonne | Type | Contrainte |
|---|---|---|
| `id` | UUID | PK |
| `projet_id` | UUID | NOT NULL `→ projet` |
| `profil_ressource_id` | UUID | **NOT NULL — MUR M-4, immuable** |
| `etat_code`, `etat_categorie` | TEXT | `→ ref_etat_prestation` |
| `intitule` | TEXT | NULL (US5 : facultatif) |
| `date_debut`, `date_fin` | DATE | NOT NULL, CHECK `date_fin >= date_debut` |
| `tjm_vendu` | NUMERIC(14,2) | ATL-05 — **donnée sensible** |
| `cjm_contrat`, `cjm_devise_code` | NUMERIC(14,2), TEXT | ATL-12 — le coût **de cette mission**, pas la fiche ressource (**MUR M-14**). `cjm_devise_code` NOT NULL, **par défaut = `devise_code`** ; si elle diffère (freelance payé en MAD, vendu en EUR — D-9, troisième passe), la marge de cette prestation vaut **« — »** tant que `change.mode = aucune_conversion` (ATL-16, ATL-17, M-15) : on n'invente pas un taux |
| `devise_code` | TEXT | NOT NULL |
| `jours_vendus` | NUMERIC(8,2) | ATL-05 |
| `taux_occupation_pct` | NUMERIC(5,2) | NOT NULL, CHECK > 0 — ATL-02 |
| `frais_journalier`, `frais_mensuel` | NUMERIC(14,2) | ATL-13 |
| `jours_ouvres_annuels` | INT | US5 — pour le prorata des frais mensuels |
| `contrat_reference` | TEXT | US5 |
| `date_signature`, `date_cloture`, `date_annulation` | DATE | NULL |
| `description`, `conditions_particulieres` | TEXT | |
| `archive_le`… | | |

**Triggers :**
1. **MUR M-4** — `BEFORE UPDATE` : si `profil_ressource_id` change → EXCEPTION « La ressource d'une prestation est immuable. Clôturez et créez une nouvelle prestation. »
2. **MUR M-14** (T-2) — `BEFORE UPDATE` : dès la catégorie `engage`, `tjm_vendu`, `cjm_contrat`, `devise_code`, **`cjm_devise_code`**, `jours_vendus`, `frais_journalier`, `frais_mensuel` sont **immuables** → EXCEPTION. Une prévisionnelle se corrige ; une signée s'avenante selon **POL `prestation.avenant.mode`** (B-2, 19/09 — voir §5.3). ⭐ **M-14 tient dans les deux modes** : un avenant **n'écrit jamais dans `prestation`**, il ajoute une ligne à `prestation_version`.
3. `etat_categorie` maintenue depuis `ref_etat_prestation`.
4. Entrée en catégorie `clos` → écrit `snapshot_marge` **dans la même transaction** (DEC-09, ATL-15).
5. **Entrée directe en `engage`** (O-2) : `CreatePrestation` avec état initial `signee` déclenche **les mêmes effets** que `SignPrestation` — `PrestationSigned`, `ClientStatusDerived`, pourvu automatique — **et exige la même permission** `SignPrestation` (troisième passe : sinon Staffing signait sans le droit). Le résultat, et le droit, ne dépendent pas de la commande d'entrée (G8).

### 5.3 `prestation_version` — l'avenant daté (B-2, 19/09)

⚠️ **Table neuve, et elle ne sert que sous l'option.** Sous le défaut Avaliance (`nouvelle_prestation`), elle reste vide : une mission modifiée se clôture et une autre la remplace, comme avant.

| Colonne | Type | Contrainte |
|---|---|---|
| `prestation_id` | UUID | **PK (1/2)** `→ prestation` |
| `version_n` | INT | **PK (2/2)**, CHECK ≥ 1 — la version 1 est celle de la signature |
| `date_effet` | DATE | NOT NULL — CHECK dans `[prestation.date_debut, prestation.date_fin]`. ⛔ UNIQUE `(prestation_id, date_effet)` : deux conditions ne valent pas le même jour |
| `tjm_vendu`, `devise_code` | NUMERIC(14,2), TEXT | NOT NULL ensemble (M-15) |
| `cjm_contrat`, `cjm_devise_code` | NUMERIC(14,2), TEXT | idem |
| `jours_vendus` | NUMERIC(8,2) | |
| `taux_occupation_pct` | NUMERIC(5,2) | NOT NULL, CHECK > 0 |
| `frais_journalier`, `frais_mensuel` | NUMERIC(14,2) | |
| `motif_code` | TEXT | NOT NULL `→ ref_motif_avenant` |
| `cree_le`, `cree_par_compte_id` | TIMESTAMPTZ, UUID | NOT NULL |

**Triggers :**
1. ⛔ **Ajout seul, comme l'historique** — `UPDATE` et `DELETE` lèvent, et le rôle SQL ne les a pas. Une erreur de saisie se corrige par **une version de plus**, jamais en réécrivant celle d'avant. *C'est la même règle que M-7, pour la même raison.*
2. La version **1 s'écrit à la signature**, dans la transaction de `SignPrestation`, en recopiant les conditions de `prestation`. ⭐ **Sans elle, une mission avenantée n'aurait pas de « avant ».**
3. ⛔ **Refus si POL `prestation.avenant.mode` = `nouvelle_prestation`** — sous le défaut Avaliance, la table ne se remplit pas.

⭐ **Ce que lit le snapshot de marge** — la version **en vigueur à chaque date**, pas la dernière : un TJM qui change au 1er juin ne réécrit pas mai. Sous le défaut (table vide), le snapshot lit `prestation` comme avant. **ATL-15 ne change pas de formule, il change de source.**

⚠️ **Ce que ça remplace** : ATL-18 disait « une signée s'avenante par une nouvelle prestation ». C'est toujours vrai **sous le défaut**. Voir [ADR-006](adr/ADR-006-avenant-version-datee.md).

`ref_motif_avenant` : `prolongation` · `changement_tarif` · `changement_charge` · `changement_frais` · `autre` — **valeurs système**.

---

### 5.4 Surcharge

Surcharge : **POL `prestation.surcharge.mode`** (défaut alerte) + **POL `prestation.surcharge.seuil_pct`** (100). Calculée au **jour** (F29) sur le calendrier d'agence (F30). **La garde lit la catégorie `engage` seule** (ATL-02 : « alerte si signées > seuil ») ; `previsionnel` s'affiche distinctement (F31), ne déclenche ni alerte ni refus. *Tranché C-3, 17/09 soir.* ⛔ **Sous le défaut**, jamais un refus automatique (DEC-10, BM-31) ; `refus` n'existe que comme option de la politique, pour une autre société, et l'événement dit sous quelle valeur la prestation a été acceptée ou refusée. *Tranché C-2, 17/09 soir : ce n'est pas un mur (P3 en compte 15, celui-ci n'en est pas), c'est une bifurcation — ADR-005.*

`prestation_ligne_ca` : `(prestation_id, date, titre, ca_ht, invest_ht)` — US5 section 2, entrées d'ATL-06/13.

### 5.3 `temps` (DEC-02, F32/F33/F34, G9)

| Colonne | Type | Contrainte |
|---|---|---|
| `id` | UUID | PK |
| `prestation_id` | UUID | NOT NULL `→ prestation` |
| `profil_ressource_id` | UUID | NOT NULL `→ profil_ressource` |
| `jour` | DATE | NOT NULL |
| `quantite` | NUMERIC(4,2) | NOT NULL, CHECK > 0 (0.6 = 0,6 jour) — **ce qui a été produit** |
| `quantite_facturable` | NUMERIC(4,2) | NULL, CHECK > 0 — **B-4, 19/09**. ⭐ 20 jours produits, 18 facturés : les deux se conservent. Trigger : NULL interdit dès que **POL `temps.facturable.mode`** = `saisie_separee` ; **ignorée** sous le défaut `egal_au_produit`, où le facturable **est** le produit |
| `ajustement` | BOOL | NOT NULL DEFAULT false — F34 : ajustement post-clôture |
| `saisi_par_compte_id` | UUID | NOT NULL — l'auteur ≠ la ressource (DP délégué) |
| `commentaire` | TEXT | |
| `archive_le`, `archive_par_compte_id` | | **D-4** : annuler une saisie erronée = l'archiver, événement `TimesheetCancelled`. Le CA produit et l'occupation lisent `archive_le IS NULL`. Pas de quantité négative : une contre-passation est une ligne qu'on relit mal |

⛔ **MUR M-1** : aucune colonne candidat. Un candidat ne peut **physiquement** pas porter de temps.
⛔ **MUR M-10**, trigger : `temps.profil_ressource_id` = `prestation.profil_ressource_id` (F32).
Période : **POL `temps.periode`** (défaut : `jour BETWEEN prestation.date_debut AND date_fin`, G9).
Après clôture : **POL `temps.correction_apres_cloture`** (défaut : ajustement tracé, `ajustement = true` + événement). ⛔ **Le snapshot ne bouge pas — MUR M-6** (F34, DEC-09).
Validation : **POL `temps.validation`** (défaut aucune, F35) — le CA produit régie utilise les temps **saisis** (ATL-08).
Plafond par jour : **POL `temps.plafond_jour`** (défaut **alerte** ; refus · aucun) — somme des `quantite` d'une personne sur un jour > `capacite.jour_ouvre`. Bifurcation née de la relecture (P-6), posée aux directeurs (cahier, question 60). Pas d'UNIQUE `(prestation_id, jour)` : deux lignes le même jour sont deux faits.

### 5.4 `absence` (F25, DEC-16)

`id`, `profil_ressource_id` NOT NULL, `type_code → ref_type_absence`, `date_debut`, `date_fin`, `quantite_par_jour` NUMERIC(4,2), `statut`, `saisi_par_compte_id`, `archive_le`, `archive_par_compte_id` (D-4 : annuler = archiver, `AbsenceCancelled`).

⭐ **Aucun lien vers `prestation`** — F25 : une absence existe sans mission. Elle entre dans la capacité d'ATL-04.

### 5.5 `snapshot_marge` (DEC-09, ATL-15)

| Colonne | Type |
|---|---|
| `prestation_id` | UUID PK — **un seul par prestation** |
| `calcule_le` | TIMESTAMPTZ NOT NULL |
| `version_atl` | TEXT NOT NULL — « ATL-2026-09-16 » |
| `ca_produit`, `ca_devise_code` | NUMERIC, TEXT NOT NULL | la vente, dans sa devise |
| `cout_produit`, `frais_imputes`, `cout_devise_code` | NUMERIC, TEXT NOT NULL | le coût, dans la sienne (= `prestation.cjm_devise_code`) |
| `marge`, `taux_marge` | NUMERIC | exprimés dans `ca_devise_code` (pas de troisième colonne : la marge n'a de sens que dans la devise de la vente) ; **NULL si `ca_devise_code ≠ cout_devise_code`** et `change.mode = aucune_conversion` — affiché « — », jamais calculé sur deux devises (ATL-16, ATL-17, M-15, D-9) |
| `entrees` | JSONB — les valeurs et politiques utilisées au moment du calcul |

⛔ **MUR M-6** : trigger anti-UPDATE + le rôle SQL applicatif n'a **que** INSERT et SELECT.
⚠️ `taux_marge` est NULL si `ca_produit = 0` — **POL `marge.taux.si_ca_nul`** (défaut : afficher « — », jamais `Inf`, ATL-16).

---

## 6. Structure et capacité

### 6.1 `agence` + `calendrier_jour_non_ouvre` (F30, ATL-01)

`agence` : `id`, `nom`, `code`, `pays_code`. ⛔ Pas de `perimetre_id` (D-1) : c'est `perimetre` qui pointe l'agence, jamais l'inverse — le premier tirage avait les deux, donc un cycle.

`calendrier_jour_non_ouvre` : `(agence_id, jour)` PK, `motif` (week-end / férié / fermeture). **POL `capacite.source`** (défaut : calendrier d'agence).

⭐ Sans cette table, ATL-01, ATL-02, ATL-04 et ATL-09 sont **incalculables**. C'était l'objet manquant n° 2 de l'audit.

### 6.2 `politique` (ADR-005) — seed = registre §C, compte §E

| Colonne | Type |
|---|---|
| `cle` | TEXT PK — `besoin.contact`, `prestation.surcharge.mode`… |
| `valeur` | TEXT NOT NULL |
| `valeur_defaut` | TEXT NOT NULL — la décision du 17/09 |
| `type` | TEXT — enum / int / bool / list / decimal |
| `valeurs_possibles` | JSONB |
| `categorie`, `libelle`, `description`, `source` | TEXT — `source` = « F3 », « G4 », « DEC-06 » |
| `hors_v1` | BOOL DEFAULT false — 11 clés dont la seconde option attend un lot ultérieur |
| `modifie_le`, `modifie_par_compte_id` | |

Lue à l'exécution, changée par `SetPolicy` (Admin) → événement `PolicyChanged`. ⛔ Jamais dans un fichier de config ni une variable d'environnement.

### 6.3 Les `ref_*` — forme commune (compte : registre §E)

```
ref_etat_<objet> (code TEXT PK, libelle TEXT NOT NULL, categorie TEXT NOT NULL,
                  ordre INT, systeme BOOL DEFAULT false, actif BOOL DEFAULT true)
```

| Règle | Détail |
|---|---|
| CHECK | sur la **catégorie** (liste fermée par le code), **jamais** sur le `code` |
| `systeme = true` | valeur non supprimable, non renommable en catégorie ; renommable en libellé (BM-49) |
| L'admin peut | ajouter une valeur **dans une catégorie existante**, renommer un libellé, réordonner, désactiver une valeur non système |
| L'admin ne peut pas | supprimer une valeur utilisée, changer la catégorie d'une valeur utilisée, inventer une catégorie |

Métier (liste au registre §B) : `ref_etat_besoin`, `ref_etat_candidat`, `ref_etat_ressource`, `ref_etat_positionnement`, `ref_etat_prestation`, `ref_etat_projet`, `ref_role_societe` (fournisseur, interne — D-3), `ref_statut_commercial` (prospect, client), `ref_type_ressource`, `ref_priorite_besoin`, `ref_type_action`, `ref_etape_suivi_positionnement`, `ref_type_qualification`, `ref_type_absence`, `ref_devise`, `ref_competence`, `ref_motif_retrait`, `ref_couleur` et `ref_police` (catalogues d'apparence, valeurs système — [THEMES_v1.md](THEMES_v1.md)). Techniques : `ref_civilite`, `ref_pays`, `ref_type_unite` (pole, bu, service, equipe), `ref_type_contact`, `ref_type_mission`, `ref_type_document`, `ref_disponibilite`. ⭐ Le compte n'est écrit qu'au **registre §E** — ce document ne le répète pas.

---

## 7. Droits (DEC-17, F28, BM-41→45)

| Table | Colonnes |
|---|---|
| `compte` | `id`, `email` UNIQUE, `personne_id` NULL `→ personne`, `actif`, `agence_id`, **`theme_json` JSONB NULL** — les neuf réglages d'apparence choisis par la personne ; NULL ou clé absente = la valeur de l'installation. Ignoré si **POL `ui.theme.choix_utilisateur` = non** (18/09). Catalogue : [THEMES_v1.md](THEMES_v1.md) |
| `groupe` | `id`, `nom`, `description` |
| `compte_groupe` | `(compte_id, groupe_id)` |
| `permission` | `code` PK (`CreateCompany`, `CreatePrestation`…), `libelle`, `famille` |
| `perimetre` | `id`, `type_code` (agence / pole / equipe / global), `agence_id` NULL `→ agence`, `unite_id` NULL `→ unite_organisation`. **CHECK (X-6)** : `global` ⇒ les deux NULL · `agence` ⇒ `agence_id` seul · `pole` / `equipe` ⇒ `unite_id` seul. **Trigger (D-1)** : `unite_id` appartient à la société de rôle `interne` (G6) et son `type_code` correspond. Un périmètre pôle / équipe est une unité **d'Avaliance**, jamais du client |
| `groupe_permission_perimetre` | **`(groupe_id, permission_code, perimetre_id)`** — la **paire** |
| `compte_surcharge` | `(compte_id, permission_code, perimetre_id)` — **restriction seule** (F28, P-4) : pas de colonne `sens`, une surcharge ne peut qu'**enlever** |

⛔ **MUR M-13** : une permission n'existe **jamais** sans périmètre — la table de jointure porte les trois colonnes. C'est ce qui empêche BM-42 : lecture sur B + écriture sur A **ne donne pas** écriture sur B.

`compte.personne_id` : c'est le lien qui rend vérifiable le « **S** » (soi-même) de la matrice — Jean saisit **ses** temps. C'était l'objet manquant n° 3 de l'audit.

Résolution : union des `(permission, périmètre)` de tous les groupes, **puis** les surcharges — **POL `droits.surcharge_restrictive`** (défaut : **la restriction gagne**, F28).

⚠️ Cette politique est signalée **en rouge** dans l'écran Administration : la passer à `union_gagne` affaiblit toutes les restrictions nominatives.

---

## 8. Transverse

### 8.1 `action` (DEC-15)

`id`, six FK nullables : `societe_id`, `contact_id`, `profil_candidat_id`, `profil_ressource_id`, `besoin_id`, `projet_id` ; `type_code → ref_type_action`, `date`, `contenu`, `responsable_compte_id`, `archive_le`.

⛔ **MUR M-9** — CHECK : exactement une des six FK est non nulle.
```sql
CHECK ((societe_id IS NOT NULL)::int + (contact_id IS NOT NULL)::int
     + (profil_candidat_id IS NOT NULL)::int + (profil_ressource_id IS NOT NULL)::int
     + (besoin_id IS NOT NULL)::int + (projet_id IS NOT NULL)::int = 1)
```
⚠️ Porteur métier, responsable utilisateur et détenteur d'un droit sont **trois choses différentes** (BM-40).

### 8.2 `evenement_metier` (DEC-18, ADR-004)

`id`, `type` NOT NULL, `objet_type`, `objet_id`, `auteur_compte_id`, `horodatage`, `avant` JSONB, `apres` JSONB, `motif`, `liens` JSONB.

⛔ **MUR M-7** : trigger anti-UPDATE/DELETE + rôle SQL en INSERT/SELECT seulement.
⭐ `liens.politiques` porte **les clés lues et leur valeur au moment de l'exécution** — on saura toujours sous quelle règle un fait s'est produit, même après un changement de réglage. C'est ce qui rend le paramétrage honnête.
Refus : **POL `historique.tentatives_refusees`** (défaut : tracés à part) — jamais mélangés aux réussites (BM-44).

### 8.3 `reprise_boond` (G13)

`(objet_type, objet_id)` PK, `boond_id` TEXT NOT NULL, `boond_etat_source` TEXT, `importe_le`, `lot` TEXT.

⭐ **Hors des tables métier** : aucune colonne `boond_id` ne pollue `personne` ou `projet`. Quand la reprise est finie, la table se retire sans migration.
La correspondance des états Boond (14 étapes candidat, 9 états positionnement) se fait vers des **codes de `ref_*`**, créés au besoin dans la bonne catégorie — sans toucher au code (ADR-005).

---

## 8.4 `modele` — ce qu'on ne réécrit pas deux fois (S-10.1, 19/09)

⭐ **Le plus gros trou trouvé en comparant avec Boond.** Un utilisateur touche ça tous les jours : ses modèles d'actions, ses recherches enregistrées, ses listes de tâches, ses formulaires.

| Colonne | Type | Contrainte |
|---|---|---|
| `id` | UUID | PK |
| `type_code` | TEXT | NOT NULL `→ ref_type_modele` — action · recherche · liste_taches · formulaire · email |
| `nom` | TEXT | NOT NULL |
| `portee_code` | TEXT | NOT NULL `→ ref_portee_modele` — `installation` · `agence` · `personnelle`. **POL `modele.portee.defaut`** |
| `agence_id` | UUID | NULL — NOT NULL si `portee_code = 'agence'` (trigger) |
| `proprietaire_compte_id` | UUID | NULL — NOT NULL si `portee_code = 'personnelle'` (trigger) |
| `contenu_json` | JSONB | NOT NULL — la forme dépend du type |
| `partage` | BOOL | NOT NULL DEFAULT false — **POL `modele.recherche.partage`** |
| `ordre` | INT | NOT NULL DEFAULT 0 |
| `archive_le`, `archive_par_compte_id` | | **M-8** : rien ne se supprime |

⛔ **`contenu_json` est le seul JSONB du modèle, et c'est délibéré** : la forme d'un formulaire n'est pas une donnée métier, c'est une configuration. ⚠️ **Aucune règle métier ne le lit** — sinon on aurait remis du métier hors du registre, et ADR-005 tomberait.

---

## 8.5 `alerte_regle` — les alertes cessent d'être écrites en dur (S-10.3, 19/09)

⛔ **Aujourd'hui les alertes du tableau de bord sont dans le code.** Ça contredit « tout est paramétrable » : une autre société n'a pas les mêmes urgences.

| Colonne | Type | Contrainte |
|---|---|---|
| `code` | TEXT | **PK** — `besoin_non_pourvu`, `cv_sans_reponse`, `mission_sans_temps`… |
| `libelle` | TEXT | NOT NULL |
| `objet_code` | TEXT | NOT NULL `→ ref_type_objet` — sur quoi elle porte |
| `condition_json` | JSONB | NOT NULL — **construite depuis les politiques et les états, jamais du SQL libre** |
| `gravite_code` | TEXT | NOT NULL `→ ref_gravite_alerte` — critique · elevee · moyenne · bonne. ⛔ **L'échelle du SENS**, qu'aucune palette ne touche (THEMES) |
| `actif` | BOOL | NOT NULL DEFAULT true |
| `portee_code` | TEXT | `→ ref_portee_modele` — une agence peut avoir les siennes |
| `agence_id` | UUID | NULL |
| `ordre` | INT | NOT NULL DEFAULT 0 |

⛔ **`condition_json` ne porte pas de SQL.** Elle nomme un objet, un état, une politique et un seuil. Une alerte qui pourrait écrire sa propre requête serait une porte dérobée dans les murs et les droits.

⭐ **Ce que ça remplace** : le bloc « CE QUI VOUS ATTEND » du tableau de bord lisait une liste écrite en dur, par rôle. Il lit maintenant `alerte_regle` filtrée par le périmètre de la personne.

`ref_type_modele` : `action` · `recherche` · `liste_taches` · `formulaire` · `email` — **système**.
`ref_portee_modele` : `installation` · `agence` · `personnelle` — **système**.
`ref_gravite_alerte` : `critique` · `elevee` · `moyenne` · `bonne` — **système**.

---

## 9. Les 15 murs — où ils vivent physiquement

| Mur | Forme |
|---|---|
| M-1 candidat hors production | FK vers `profil_ressource` uniquement, dans `prestation` et `temps` |
| M-2 positionnement XOR | CHECK sur `positionnement` |
| M-3 un profil par type | UNIQUE `personne_id` sur `profil_candidat` et `profil_ressource` |
| M-4 ressource immuable | trigger `BEFORE UPDATE` sur `prestation` |
| M-5 pas de ressource sur projet | absence de colonne |
| M-6 snapshot figé | trigger + rôle SQL sans UPDATE sur `snapshot_marge` |
| M-7 événement en ajout seul | trigger + rôle SQL sans UPDATE/DELETE sur `evenement_metier` |
| M-8 pas de DELETE | rôle SQL sans DELETE sur les tables d'objets historiques listées à l'ADR-004 §3 + `archive_le` |
| M-9 un porteur d'action | CHECK de somme = 1 |
| M-10 temps ↔ ressource | trigger d'égalité |
| M-11 besoin a une société | NOT NULL |
| M-12 cohérence de société | triggers (contact/besoin/unité) + trigger anti-cycle |
| M-13 permission avec périmètre | PK à trois colonnes |
| M-14 économie historisée | colonnes propres à `prestation` **+ trigger `BEFORE UPDATE` : immuables dès `engage`** (T-2) |
| M-15 aucun montant stocké sans devise, aucun agrégat multi-devises stocké ou servi | **Tables** : `devise_code NOT NULL` à côté de **chaque** montant ; `snapshot_marge` porte une devise par montant, marge NULL si elles diffèrent ; aucune colonne de montant converti (patron M-5). **Surface de lecture** (ADR-005, amendement) : les agrégats ne sont exposés que par les vues `v_ca_realise_par_devise`, `v_ca_provisoire_par_devise` (**B-3**), `v_marge_par_devise`, `v_occupation_valorisee_par_devise`, toutes `GROUP BY devise_code` ; le rôle SQL d'agrégation (`ava_lecture_agregats`) a `SELECT` sur ces vues **et pas** sur `prestation`, `temps`, `snapshot_marge` |

**Règle de code R-1 (pas un mur, T-2)** — ce qui reste hors base : un service qui lit des lignes par le rôle transactionnel et les additionne lui-même. Refus en revue, comme un `if` sans clé de politique.

⭐ **Les murs qui sont des triggers ou des droits SQL, pas des CHECK — M-4, M-6, M-7, M-8, M-10, M-12, M-14.** Un CHECK ne peut pas dire « cette colonne ne change jamais ». C'est la différence entre « le mur est dans la DB » et « le mur est dans l'UI ».

---

## 10. Ce que ce livrable ne contient pas

| Absent | Où |
|---|---|
| Le SQL exécutable | étape 7, exécutant |
| Le contenu de la matrice rôle × commande | étape 8 — **configuration**, pas schéma |
| Les écrans | étape 5b, mock |
| Les formules ATL | code, versionné (`snapshot_marge.version_atl`) |
| Commentaires, portail candidat, emailing, processus de recrutement versionné | ⬜ hors V1 (F16–F18), **nommés** au §1 · ⭐ **achats, factures, devis, contrats RH et alertes entrent en V1 le 23/09 : §13** |
| Le partitionnement, la rétention, la stratégie d'index fine | après la première mesure — pas avant |

---

## 11. Vérification — ce livrable répond-il à l'audit du 17/09 ?

| Trou de l'audit | Réponse |
|---|---|
| ⛔ Machines d'état avant le modèle | fait — 6 cycles fermés, états en référentiel à catégorie |
| ⛔ Contradiction F1 ↔ S2 | `positionnement.personne_id` dénormalisé + POL `projet.depuis_besoin.garde_profil` |
| ⛔ 8 objets absents | `agence`, `perimetre`, `calendrier_jour_non_ouvre`, `compte.personne_id`, substitut de Contrat (= prestation `engage`, G8), `besoin.nb_postes_vises`, `qualification` + `ref_competence`, `document` — **les 8 sont là** ; le Périmètre n'y était qu'en nom jusqu'à D-1 : pôles et équipes internes = unités de la société `interne` |
| ⛔ Pas de dépôt ni sauvegarde | fait, étape 0 |
| ⚠️ Zip RBAC non réconcilié | ADR-001, écarté |
| ⚠️ Reprise Boond absente | `reprise_boond`, §8.3 |
| ⚠️ Rien de paramétrable | ADR-005 + `politique` + `ref_*` — comptes au registre §E |

---

## 12. La porte

Ce document + le mock d'écrans (5b) forment le livrable à valider.
**G15** : la validation prend la forme d'une pièce datée `VALIDATION_MODELE_V1_<date>.md`, de la main d'Ahmed, avec ses réserves numérotées.
⛔ Tant qu'elle n'existe pas : **pas de migration, pas d'API, pas d'UI.**

---

## 13. Ajouts V1 du 23-24/09 — tout ce que Boond porte, et les réponses d'Avaliance

⭐ **Décision d'Hamada, 23/09 : « tout en V1, ne rien oublier ».** Chaque objet vient du relevé des
réglages Boond (`cartographie/BOOND_REGLAGES_2026-09-23.md`) ou d'une réponse de la direction
(`REPONSES_AVALIANCE_2026-09-24.md`). ⛔ Les règles du §0 valent ici aussi : `TEXT` jamais `VARCHAR(n)`,
un montant a sa `devise_code`, une date est un `TIMESTAMPTZ` ou une `DATE`, aucune suppression sur
l'historique, les états en référentiel à catégorie.

### 13.1 Colonnes ajoutées aux tables existantes

| Table | Colonnes | Source |
|---|---|---|
| `societe` | `agence_responsable_id` (FK agence, **NOT NULL**) · `secteur_code` (→ `ref_secteur`) · `societe_mere_id` (FK societe) · `statut_juridique`, `tva_intracom`, `siret`, `rcs`, `code_ape`, `numero_fournisseur` (TEXT) | D-25, capture 66 |
| `contact` | `agence_responsable_id` (FK agence, **NOT NULL**) · `type_contact_code` (→ `ref_type_contact`) · `perimetre_technique` (TEXT[]) | D-25, capture 90 |
| `personne` | `drapeau_blackliste` (BOOL) + `blackliste_motif`, `blackliste_le`, `blackliste_par`, `blackliste_portee` (→ `candidat.blackliste.portee`) · `situation_familiale_code` · `nationalite_code` (→ `ref_pays`) · `lieu_naissance` · `numero_securite_sociale` ⛔ **chiffré**, lu sous `LireDonneesRHSensibles` | R7, R8 |
| `profil_candidat` | `agence_id` **NOT NULL** · `disponibilite_code` (→ `ref_disponibilite_candidat`) · `niveau_experience_code` · `niveau_formation_code` · `metier_code` | V-114, relevé |
| `profil_ressource` | `brut_annuel`, `primes_annuelles`, `frais_annuels` (NUMERIC + `devise_code`) — ⭐ le coût journalier d'un salarié **se calcule** : (brut + primes + frais) ÷ `cout.jours_base` ; pour un externe, c'est le prix d'achat | R5 |
| `besoin` | `origine_code` (→ `ref_origine_besoin`) | R10 |
| `projet` | l'interlocuteur : `contact_id` **ou** `unite_organisation_id` **ou** `interlocuteur_societe` (BOOL) — ⛔ **exactement un des trois** si `projet.contact ≠ facultatif` (CHECK) | R10 |
| `agence` | `calendrier_code` (→ `ref_calendrier`) · `jours_ouvres_annuel` (INT) · `coefficient_charge` (NUMERIC) | capture 72 |
| `compte` | `widgets` (JSONB, défaut = `ui.tableau_de_bord.widgets`) | capture 92 |

### 13.2 Tables nouvelles

| Table | Colonnes | Murs et règles |
|---|---|---|
| **`personne_langue`** | `personne_id`, `langue_code`, `niveau_code` | une ligne par langue |
| **`personne_certification`** | `personne_id`, `certification_code`, `obtenue_le`, `expire_le` | l'expiration nourrit l'alerte |
| **`contrat_rh`** | `personne_id`, `agence_id`, `type_code`, `categorie_code`, `classification_code` (Syntec), `temps_travail_code`, `debut`, `fin`, `fin_periode_essai`, `motif_fin_code`, `renouvelle_id` (FK contrat_rh) | ⛔ deux contrats d'une même personne ne se chevauchent pas (EXCLUDE sur la période) — c'est l'alerte « dates qui se chevauchent » de Boond, devenue un mur |
| **`document_suivi`** | `personne_id`, `type_code` (→ `ref_type_document_suivi`), `expire_le`, `document_id` (FK document) | alerte à `rh.document.alerte_jours` |
| **`devis`** | `societe_id`, `projet_id`, `etat_code` (→ `ref_etat_devis`), `montant_ht` + `devise_code`, `emis_le` | ajout seul sur son historique d'états |
| **`facture`** | `societe_id`, `projet_id`, `numero` (séquence, **unique, jamais réutilisé**), `etat_code` (→ `ref_etat_facture`), `emise_le`, `echeance_le`, `tva_code`, `condition_reglement_code`, `mode_reglement_code`, `mode_envoi_code`, `montant_ht` + `devise_code` | ⛔ une facture émise ne se modifie pas : on l'annule par un **avoir** (nouveau mur, M-16 à écrire au modèle métier) |
| **`facture_ligne`** | `facture_id`, `prestation_id`, `quantite`, `prix_unitaire` + `devise_code`, `libelle` | libellé tiré du modèle `[BILL_PERIOD_MONTH]` |
| **`facture_fournisseur`** | `societe_id` (fournisseur), `achat_id`, `etat_code` (→ `ref_etat_facture_fournisseur`), `montant_ht` + `devise_code` | |
| **`achat`** + **`paiement`** | `projet_id`, `fournisseur_id`, `categorie_code` (→ `ref_categorie_achat`), `montant` + `devise_code`, `etat_code` · paiement : `achat_id`, `montant`, `etat_code` (planifié · confirmé · réglé) | 1 seul achat chez Boond aujourd'hui : le module existe pour la reprise |
| **`relance_facture`** | `facture_id`, `rang`, `envoyee_le`, `mode_envoi_code` | rythme : `facturation.relance.jours` |

### 13.3 Les nouveaux murs à écrire au modèle métier

| Mur proposé | Ce qu'il interdit | Pourquoi c'est un mur, pas une politique |
|---|---|---|
| **M-16** | modifier une facture émise | la loi : une facture émise s'annule par un avoir, jamais en place |
| **M-17** | deux contrats RH d'une personne qui se chevauchent | Boond en fait une alerte ; une paie juste n'a qu'un contrat à la fois |
| **M-18** | un numéro de facture réutilisé ou un trou dans la séquence | la loi française exige une numérotation continue |

⚠️ Ces trois murs portent le compte de **15 à 18**. Ils s'écrivent au modèle métier, avec leurs
assertions, **avant** la migration.

### 13.4 Ce qui change dans les comptes (registre §E)

| | Avant le 23/09 | Au 24/09 |
|---|---|---|
| Référentiels | 40 | **71** (registre §E) |
| Politiques | 173 | **201** (registre §E) |
| Tables | 37 | **≈ 63** (§13.2 + §13.5 + §13.6) |
| Murs | 15 | **18** (M-16 → M-18, à écrire) |

### 13.5 La grille de parité du 24/09 — ce que Boond porte encore

⭐ Source : `cartographie/BOOND_PARITE_2026-09-24.md` (10 listes, 8 fiches, le formulaire de contrat RH).

| Objet | Ajout | Note |
|---|---|---|
| `profil_candidat`, `profil_ressource`, `besoin` | `confidentiel` (BOOL) · `responsable_rh_compte_id` · `pole_code` → `ref_pole` | « visible uniquement de vous » ; politique `confidentialite.autorisee` |
| `profil_candidat`, `profil_ressource` | `mobilite` (TEXT[] de codes `ref_mobilite`) | |
| **`dossier_technique`** + **`dossier_technique_ligne`** | personne, titre, description ; lignes : compétence, expérience, formation, diplôme, niveau, langue, domaine, secteur | plusieurs DT par personne |
| **`personne_experience`** · **`personne_diplome`** | poste, employeur, début, fin — diplôme, établissement, année | |
| `profil_ressource` | `matricule` (UNIQUE par agence) · `fonction` | ⚠️ les éléments de coût du §13.1 **quittent** le profil pour `contrat_rh` |
| `contrat_rh` (+ colonnes) | `salaire_annuel_brut`, `salaire_mensuel_brut`, `salaire_horaire_brut` (+ `devise_code`) · `coefficient_charge` · `jours_ouvres_annuel` · `duree_hebdo_heures` · `calendrier_code` · `frais_journaliers`, `frais_mensuels` · **`cjm_contrat` calculé** (vue, jamais saisi) | ⭐ R5 et la capture 93 : le coût d'un salarié dépend de **son contrat en cours** |
| **`avantage_verse`** | personne, `type_code` → `ref_type_avantage`, montant + devise, période | |
| `besoin` | `criteres_requis` (TEXT) · `lieu` · `duree_jours` · `secteur_code` · `budget_envisage` + devise · `ponderation_pct` · `ca_envisage` + devise · `date_reponse` · `date_cloture` | le CA pondéré se **calcule**, jamais stocké |
| `projet` | `adresse`, `code_postal`, `ville`, `pays_code` · `intermediaire_facturation_id` (FK société) | |
| **`jalon`** | projet, libellé, date, montant + devise, état | le forfait |
| `prestation` | `jours_gratuits` · `calendrier_code` · `intermediaire_facturation_id` | |
| **`ca_additionnel`** | prestation ou projet, libellé, montant + devise, date | |
| `positionnement` | `tarif_vente_jour`, `jours_vendus`, `taux_occupation`, `cout_jour_moyen` (+ devise) — **prévisionnels** | Boond chiffre le positionnement avant la mission |
| **`contact_domaine`** · **`contact_outil`** | contact, code | |

⛔ **Écarté, avec motif** : le « taux de change de l'agence juridique » (T-2, M-15 : aucun montant
converti n'est stocké) · les produits (0 utilisé) · « Demander à l'IA » (lot 8).

### 13.6 Les applications Boond reprises en V1 (24/09)

⭐ Source : `cartographie/BOOND_APPLICATIONS_2026-09-24.md` (les 9 applications installées chez Avaliance).

| Table | Colonnes | Note |
|---|---|---|
| **`envoi_email`** | id, `expediteur_compte_id`, `modele_id?`, objet, corps, `pieces` (document_id[]), `nature` (message · push_cv), `envoye_le`, `fournisseur_code` | ⛔ jamais supprimé (M-8) ; le fournisseur est celui de `email.fournisseur` au moment de l'envoi |
| **`envoi_email_destinataire`** | envoi_id, `contact_id?` · `personne_id?` (un des deux), adresse, `etat` (en_attente · envoye · echec), `motif_echec`, `action_id?` | l'action créée par le push de CV y est reliée |
| **`document_genere`** | id, `modele_id` (type document), `famille_code` → `ref_famille_document`, objet + objet_id, format (docx · pdf), `document_id`, `genere_par_compte_id`, `genere_le` | le fichier va dans `document` ; on garde qui l'a produit et depuis quel modèle |
| **`lien_outlook`** | `action_id`, `compte_id`, `outlook_id` (événement ou message), nature (evenement · message), `synchronise_le` | UNIQUE (compte, outlook_id) — un événement ne crée jamais deux actions |
| **`preparation_paie`** | id, `agence_id`, mois, `etat` (brouillon · figee · exportee), `figee_le`, `figee_par_compte_id` | UNIQUE (agence, mois) hors brouillon |
| **`preparation_paie_ligne`** | preparation_id, `contrat_rh_id`, jours de production, internes, absences, salaire, avantages, frais (+ devise), état des temps, état des frais, note | ⭐ une photographie : figée, elle ne bouge plus si un temps change après |

⭐ Aucune table pour HRFlow, PlanProduction, PostProduction, Célébrations ni Viewer : ce sont des
**lectures** de tables existantes (CV → proposition de fiche ; temps et absences par jour ; produit
face à facturé ; dates de naissance, d'entrée et d'ancienneté ; aperçu d'un `document`).
