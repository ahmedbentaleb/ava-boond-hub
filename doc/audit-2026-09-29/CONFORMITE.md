# CONFORMITE9 — les 55 commandes servies contre `SPEC_COMMANDES_L4.md`, par appels HTTP réels

**Verdict : 55/55 servies = 55 contractées (L4 §I–V), 128 cas sur 133 conformes ; 50/50 commandes à agence refusent hors agence sans rien écrire. ⛔ 18 commandes portent au moins un écart (16 mesurés par appel, 2 lus dans le code), en 6 familles + 2 écarts de sortie.**
Le cas du 8ᵉ audit est **réparé** : en `saisie_separee`, `RecordTimesheet` accepte `quantite_facturable` et `facturable`, les stocke, et refuse sans elles (GARDE).

> Mesure : `rapport/preuves/conformite9/` (`scenario.jsonl` = chaque appel et sa réponse, `tableau.json`, `tableau55.md`, `cles_statique.json`, `politiques_carte_vs_code.txt`) et `securite9/` (`hors_agence.json`, `supp.json`, `types.json`).
> Serveur `AVA_MODE=banc` sur `:3902`, base `ava_audit9_b`. Comptes du banc (`ia`, `rh`, `staf`, `dp`, `eval`, `res`, `adm`, `sup`, `rr`) sur l'agence PAR ; objets « hors agence » tirés du jeu d'essai (agence AVFR).

## 1. Les écarts, par famille

| # | Famille | Étendue mesurée | Sévérité |
|---|---|---|---|
| **H-1** | Une entrée du contrat, ou lue par le code, est refusée « entrée ambiguë » ou exigée en plus | **5 commandes** : `UpdateCompany` (siren, ville, téléphone… — colonnes de `societe` que `CreateCompany` admet), `CreateContact` (`telephone`, colonne de `contact`), `RecordQualification` (`commentaire`, **lu** par `identite.ts:441`, refusé par la liste), `ArchiveContact` et `ArchiveService` (L4 : entrée = `id` ; le code **exige** `motif` → GARDE) | 🟠 |
| **H-2** | Une clé admise puis ignorée : la commande dit oui et fait autre chose | **3 commandes** : `ConvertCandidateToResource` — `agence: LYO` contrôlée par la garde (droit LYO exigé) puis **ignorée**, la ressource naît en **PAR** (`identite.ts:207`, mesuré) ; `CreateCompany` — `ville`, `telephone` admis et jetés, `siren` admis, lu pour le doublon, **jamais stocké** (`siren = null` en base) ; `CreateUnit` — l'agence de l'unité est celle du parent ou du compte, l'entrée `agence` ne sert qu'à refuser | 🟠 |
| **H-3** | Une valeur de politique acceptée par `SetPolicy` sans comportement codé | **11 valeurs sur 7 clés** (liste §3). Mesurées : `temps.periode = dates_prestation_et_mois_ouvert` **retire** la garde de période (un jour de 2027 passe) ; `temps.validation = par_dp` ou `par_projet` **bloque toute saisie de temps** ; `change.mode = taux_saisi` → `ClosePrestation` tombe en **MUR** sur une prestation EUR/USD | 🔴 (la valeur la plus stricte affaiblit la garde) |
| **H-4** | Un refus hors des cinq codes : HTTP 500 ou `MUR` visible | **5 × HTTP 500** (`RecordTimesheet` quantité 1e12, `CreatePrestation` date 2026-13-45, `RecordAbsence` « hier », `CreateAction` « jamais », `RecordQualification` mesures non liste) + **3 × MUR** (`RecordQualification` compétence inconnue — `ref_competence` est **vide**, aucune mesure n'est donc possible ; `UpdateCandidate` `disponibilite_code` inconnu ; `ClosePrestation` en `taux_saisi`) + **3 × 500 hors banc** (voir SECURITE9) | 🟠 |
| **H-5** | Un droit contourné par l'effet d'une autre commande | `CloseProject` en `cascade_cloture_prestations` : STAF (délégué `CloseProject` seul) clôt une prestation **signée** et écrit son `snapshot_marge`, alors que `ClosePrestation` direct lui est refusé (DROIT) — `projet.ts:155-167` change `ctx.commande` sans rejouer la garde | 🔴 |
| **H-6** | La liste « ce qui change » de `SetPolicy` est écrite à la main | `politiques.ts` : **2 clés lues absentes** (`societe.perimetre.mode` — lue par la garde de ~20 commandes société/contact —, `staffing.inter_agences`) → `commandes_affectees = []` ; **4 attributions fausses** (`societe.archivage.garde` et `service.archivage.garde` → `ArchiveObject` qui ne les lit pas ; `besoin.staffing.declencheur` → `TakeNeedInCharge` qui ne la lit pas ; `frais.mode`, `change.mode`, `marge.taux.si_ca_nul` omettent `CloseProject` qui les lit en cascade) | 🟠 (L4 §C-5 : « la sortie liste ce qui change ») |

Et deux écarts de sortie, hors familles de refus :
- **H-7 🟡 Dates décalées** : un DATE rendu comme instant ISO — `date_debut: "2026-10-01"` revient `"2026-09-30T23:00:00.000Z"` (Node lit `Africa/Casablanca` = UTC+1 dans sa table ICU, Windows dit UTC+0). Toute vue (`vuePrestation`, `vueTemps`, `vueAbsence`…) sort les DATE ainsi. Correction de construction : un type `jour` sérialisé `YYYY-MM-DD` au pilote (`pg.types.setTypeParser(1082, s => s)`), une seule fois.
- **H-8 🟡 `TransferContact` sans société d'arrivée** → `INTROUVABLE` au lieu de `GARDE` « champ requis ».

## 2. Correction de construction et porte, par famille

| # | Ce qui rend la famille impossible | La porte qui l'énumère |
|---|---|---|
| H-1 / H-2 | **Une seule déclaration par commande** : le schéma d'entrée (clé → colonne, alias, requis) écrit une fois, d'où dérivent la liste des clés admises, la lecture du handler (`entree.x` typé) et le contrat L4 ; une clé qui n'a pas de colonne cible ne peut pas être admise | P-H1 : pour chaque commande, chaque clé du schéma envoyée seule (avec les requis) → la colonne cible relue en base **porte la valeur** ; chaque entrée L4 → jamais « entrée ambiguë » |
| H-3 | `valeurs_possibles` n'est plus une liste libre : chaque valeur est une ligne `politique_valeur(cle, valeur, implementee_par)` ; `SetPolicy` refuse une valeur sans implémentation | P-H3 : pour chaque clé lue × chaque valeur possible, un cas qui montre un comportement **différent** du défaut |
| H-4 | Un validateur de types à l'entrée (date, décimal, uuid, liste) dérivé du même schéma ; toute référence `*_code` passe par `exigeRef` avant écriture ; `pgMur` ne rend jamais `MUR` à l'utilisateur sans ouvrir un bug | P-H4 : fuzz par commande (mauvais type sur chaque clé) → jamais 500, jamais MUR |
| H-5 | Une commande n'en appelle jamais une autre : l'effet en cascade passe par `executer` qui rejoue `exigeAgence` + droit pour chaque sous-commande | P-H5 : pour chaque politique « cascade », un compte qui a la commande mère sans la fille → DROIT, 0 écrit |
| H-6 | La carte se **calcule** : `pol()` enregistre `(commande, clé)` à chaque lecture pendant le banc ; `SetPolicy` lit cette table | P-H6 : chaque clé lue pendant le banc apparaît dans `commandes_affectees` de ses commandes, et seulement là |

## 3. H-3 en détail — les valeurs sans comportement (lu dans le code, 3 mesurées)

| Clé | Valeur acceptée sans code | Effet |
|---|---|---|
| `temps.periode` | `dates_prestation_et_mois_ouvert` | ⛔ **mesuré** : aucune garde de période |
| `temps.validation` | `par_dp`, `par_projet` | ⛔ **mesuré** : `RecordTimesheet` refuse tout |
| `change.mode` | `taux_saisi` | ⛔ **mesuré** : EUR − USD soustraits, puis MUR `snapshot_marge_check` |
| `besoin.pourvu.mode` | `auto_par_personne_signee`, `auto_propose_confirme` | traitées comme `auto_par_prestation_signee` |
| `besoin.staffing.declencheur` | `retour_client_retenu` | rien ne change l'état du besoin au retenu |
| `ressource.etat.mode` | `derive_des_prestations`, `derive_avec_exceptions_tracees` | bloquent le manuel, ne dérivent rien |
| `societe.retour_prospect` | `auto_fin_dernier_contrat`, `auto_apres_delai` | aucun automatisme |
| `societe.passage_client.declencheur` | `creation_projet`, `manuel` | `CreateProject` ne lit pas la clé |

Et l'inverse : **`besoin.unite_couverture` existe en base et n'est lue par aucune commande** ; `CreateNeed` code son défaut `"postes"` en dur (`besoin.ts:43`).

## 4. Le rejeu du 8ᵉ audit — `saisie_separee`

| Cas | Attendu | Obtenu |
|---|---|---|
| `SetPolicy temps.facturable.mode = saisie_separee` | ok | ✅ ok |
| `RecordTimesheet` + `quantite_facturable: 0.5` | ok, stocké | ✅ ok, `quantite_facturable = 0.50` relu en base |
| `RecordTimesheet` + `facturable: 1` (nom L4) | ok | ✅ ok |
| sans facturable | GARDE | ✅ GARDE « quantité facturable exigée » |
| clé hors liste `quantite_non_facturable` | GARDE | ✅ GARDE « entrée ambiguë » |

⭐ La liste commune a disparu : chaque commande a sa liste (`agence.ts:233-289`), et les alias d'un même lecteur sont repliés **avant** la liste (`replier`, `agence.ts:327`) — c'est pourquoi `fournisseur`, `ressource`, `agence` passent sans y figurer. ⛔ Mais la liste reste **une deuxième écriture** du handler : 5 commandes divergent encore (H-1), 3 admettent pour rien (H-2).

## 5. Les 55 commandes (généré depuis `tableau.json`, `hors_agence.json`)

Données posées pour le scénario (déclarées) : sociétés, contacts, unités, personnes, candidats, ressources, besoins, projets, prestations et temps **en agence PAR** dans `ava_audit9_b` ; délégations par `ManageGroups` : **IA** ← `ArchiveObject`, `ArchiveCompany`, `ArchiveContact`, `ArchiveService`, `UpdateResourceCost` sur PAR ; **STAF** ← `CloseProject` sur PAR ; **RH** ← `ConvertCandidateToResource` sur **LYO** ; politiques modifiées puis **remises à leur défaut** (vérifié : `valeur <> valeur_defaut` → 0).

| # | Commande | Entrée L4 | Clés admises (`agence.ts`) | Oui | Non (code obtenu) | Hors agence | Verdict |
|---|---|---|---|---|---|---|---|
| 1 | `CreateCompany` | nom, secteur, pays, manager | nom, secteur, pays, pays_code, siren, ville, telephone, manager, manager_compte_id | nom, secteur, pays (+siren, ville, telephone admis) → ok | RR n'a pas la permission → DROIT ; clé hors contrat (tva) → GARDE | DROIT, 0 écrit | ✅ |
| 2 | `UpdateCompany` | id + champs | id, nom, secteur, pays, pays_code, manager, manager_compte_id | id + champs → ok ; ⛔ id + siren (champ de la société, admis à la création) → GARDE (« entrée ambiguë ») |  | DROIT, 0 écrit | ⛔ |
| 3 | `RequalifyCompany` | id, statut visé | id, statut, statut_vise, statut_commercial_code | prospect → client → ok | prospect → ancien_client (hors cycle) → ETAT | DROIT, 0 écrit | ✅ |
| 4 | `CreateUnit` | societe_id, parent_id, type, nom | societe_id, parent_id, type, type_code, nom, agence, agence_id | societe_id, type, nom → ok ; avec parent_id → ok | parent d'une autre société → GARDE ; agence LYO hors périmètre → DROIT | DROIT, 0 écrit | ✅ |
| 5 | `UpdateUnit` | id + champs | id, nom, parent_id, type, type_code | id + nom → ok | cycle U1 → U2 → U1 → GARDE | DROIT, 0 écrit | ✅ |
| 6 | `CreateContact` | societe_id, nom, fonction, type | societe_id, nom, fonction, type, type_code, prenom, email, unite_organisation_id, unite_id | societe_id, nom, fonction, type (+ unité) → ok ; ⛔ clé telephone (coordonnée d'un contact) → GARDE (« entrée ambiguë ») | unité d'une autre société → GARDE | DROIT, 0 écrit | ⛔ |
| 7 | `UpdateContact` | id + champs | id, nom, prenom, fonction, email, type, type_code, unite_organisation_id, unite_id | id + champs → ok | unité d'une autre société → GARDE | DROIT, 0 écrit | ✅ |
| 8 | `TransferContact` | id, nouvelle société | id, societe_id, nouvelle_societe, nouvelle_societe_id | id, nouvelle société → ok | sans société d'arrivée → INTROUVABLE | DROIT, 0 écrit | ✅ |
| 9 | `CreatePerson` | nom, prénom, coordonnées | nom, prenom, email, telephone, tel, civilite, pays, pays_code, date_naissance, naissance, ville | nom, prénom, coordonnées → ok | civilité inconnue → GARDE ; coordonnée « adresse » → GARDE | — (sans agence visée) | ✅ |
| 10 | `CreateCandidate` | personne_id, titre, provenance | personne_id, titre, provenance, agence, agence_id | personne_id, titre, provenance → ok | profil candidat déjà présent → GARDE ; agence LYO hors périmètre → DROIT | DROIT, 0 écrit | ✅ |
| 11 | `UpdateCandidate` | id + champs | id, titre, provenance, commentaire, pole, pole_code, responsable_rh, responsable_rh_compte_id, note, note_globale, disponibilite_code | id + champs (note dans l'échelle) → ok | note hors échelle 1_5 → GARDE | DROIT, 0 écrit | ✅ |
| 12 | `CompleteCandidate` | id | id | id (tous champs présents) → ok | champs requis manquants → GARDE | DROIT, 0 écrit | ✅ |
| 13 | `ExitCandidate` | id, motif | id, motif | id, motif → ok | brouillon → sorti (hors cycle) → ETAT | DROIT, 0 écrit | ✅ |
| 14 | `ReactivateCandidate` | id | id | id → ok | actif → actif (hors cycle) → ETAT | DROIT, 0 écrit | ✅ |
| 15 | `CreateResource` | personne_id, type, titre, agence | personne_id, type, type_code, titre, agence, agence_id, societe_fournisseur_id | personne_id, type, titre, agence → ok ; externe avec « fournisseur » (nom L4) → ok | externe sans fournisseur → GARDE | DROIT, 0 écrit | ✅ |
| 16 | `UpdateResource` | id + champs | id, titre, pole, pole_code, responsable_rh, responsable_rh_compte_id, disponibilite_code, mobilite, matricule, cout, cout_reference | id + champs → ok | tente le coût → GARDE | DROIT, 0 écrit | ✅ |
| 17 | `SetResourceState` | id, état visé | id, etat, etat_vise, etat_code | intercontrat → en_cours → ok | état inconnu → GARDE | DROIT, 0 écrit | ✅ |
| 18 | `UpdateResourceCost` | id, coût, devise | id, cout, cout_reference, devise, cout_reference_devise_code | id, coût, devise (délégué) → ok | personne ne l'a au seed → DROIT ; devise inconnue → GARDE | DROIT, 0 écrit | ✅ |
| 19 | `UploadDocument` | un seul porteur, type, fichier | type, type_code, fichier, nom_fichier, personne_id, profil_candidat_id, profil_ressource_id, projet_id, societe_id, chemin_stockage | un porteur, type, fichier → ok | deux porteurs → GARDE | DROIT, 0 écrit | ✅ |
| 20 | `CreateNeed` | societe_id, agence, titre, type, couverture | societe_id, agence, agence_id, titre, type, type_code, couverture, unite_couverture_code, priorite, priorite_code, contact_id, unite_organisation_id, unite_id, fte_vise, nb_postes_vises | societe_id, agence, titre, type, couverture → ok | couverture fte sans FTE → GARDE ; contact d'une autre société → GARDE ; agence LYO hors périmètre → DROIT | DROIT, 0 écrit | ✅ |
| 21 | `UpdateNeed` | id + champs | id, titre, contact_id, type, type_code, pole, pole_code, contexte, lieu, criteres, criteres_requis | id + champs → ok | contact d'une autre société → GARDE | DROIT, 0 écrit | ✅ |
| 22 | `SetNeedPriority` | id, priorité | id, priorite, priorite_code | id, priorité → ok | besoin inexistant → INTROUVABLE | DROIT, 0 écrit | ✅ |
| 23 | `TakeNeedInCharge` | id | id | a_pourvoir → en_recherche → ok | en_recherche → (hors cycle) → ETAT | DROIT, 0 écrit | ✅ |
| 24 | `PositionCandidate` | besoin_id, profil_candidat_id | besoin_id, profil_candidat_id | besoin_id, profil_candidat_id → ok | unicité (actifs) → GARDE | DROIT, 0 écrit | ✅ |
| 25 | `PositionResource` | besoin_id, profil_ressource_id | besoin_id, profil_ressource_id | besoin_id, profil_ressource_id → ok | unicité (actifs) → GARDE | DROIT, 0 écrit | ✅ |
| 26 | `DeclareCVShared` | positionnement_id, date | positionnement_id, id, date | positionnement_id, date → ok | presente → (hors cycle) → ETAT | DROIT, 0 écrit | ✅ |
| 27 | `RecordQualification` | personne_id, besoin_id, type, mesures | personne_id, besoin_id, type, type_code, mesures | personne_id, besoin_id, type, mesures → ok ; ⛔ clé « commentaire » lue par le code → GARDE (« entrée ambiguë ») | sans besoin (politique oui) → GARDE | DROIT, 0 écrit | ⛔ |
| 28 | `RecordClientDecision` | positionnement_id, décision, date, motif si négatif | positionnement_id, id, decision, date, motif | positionnement_id, décision, date → ok | CV non présenté (cv_partage_obligatoire = oui) → ETAT ; négatif sans motif → GARDE ; STAF (IA seul) → DROIT | DROIT, 0 écrit | ✅ |
| 29 | `WithdrawPositioning` | id, motif (`ref_motif_retrait`) | id, motif | id, motif → ok | retire → (hors cycle) → ETAT | DROIT, 0 écrit | ✅ |
| 30 | `ConvertCandidateToResource` | profil_candidat_id, type, agence, fournisseur | profil_candidat_id, id, type, type_code, agence, agence_id, societe_fournisseur_id, fournisseur | profil_candidat_id, type, agence → ok | sans positionnement terminal_positif → GARDE | DROIT, 0 écrit | ✅ |
| 31 | `CreateProjectFromNeed` | besoin_id + champs | besoin_id, contact_id, titre, type, type_code | besoin_id (retenu avec profil ressource) → ok | aucun retenu → GARDE | DROIT, 0 écrit | ✅ |
| 32 | `CreateProject` | societe_id, agence, type, titre | societe_id, agence, agence_id, type, type_code, titre, contact_id, besoin_id | societe_id, agence, type, titre → ok | contact requis (projet.contact = obligatoire) → GARDE | DROIT, 0 écrit | ✅ |
| 33 | `UpdateProject` | id + champs | id, titre, contact_id, contact_technique_id, contact_facturation_id, intermediaire, intermediaire_facturation_id | id + champs → ok | contact d'une autre société → GARDE | DROIT, 0 écrit | ✅ |
| 34 | `CreatePrestation` | projet_id, ressource, dates, TJM, CJM, devises, taux | projet_id, ressource, profil_ressource_id, date_debut, debut, date_fin, fin, tjm, tjm_vendu, cjm, cjm_contrat, devise, devise_code, cjm_devise, cjm_devise_code, taux, taux_occupation_pct, jours_vendus, etat, etat_code, date_signature | projet_id, ressource, dates, TJM, CJM, devises, taux → ok | STAF crée en « signee » sans SignPrestation → DROIT ; début > fin → GARDE | DROIT, 0 écrit | ✅ |
| 35 | `SignPrestation` | id, date de signature | id, date, date_signature | id, date de signature → ok | engage → (hors cycle) → ETAT | DROIT, 0 écrit | ✅ |
| 36 | `DeclareNeedFilled` | id | id | besoin déjà pourvu par la signature ? sinon en_recherche → pourvu → ok | en_recherche, 0 poste signé → GARDE | DROIT, 0 écrit | ✅ |
| 37 | `RecordTimesheet` | prestation_id, jour, quantité (+ facturable) | prestation_id, jour, quantite, facturable, quantite_facturable | prestation_id, jour, quantité → ok ; + facturable (egal_au_produit) → ok | jour hors des dates → GARDE | DROIT, 0 écrit | ✅ |
| 38 | `RecordAbsence` | ressource_id, type, dates, quantité/jour | ressource_id, profil_ressource_id, type, type_code, date_debut, debut, date_fin, fin, quantite, quantite_par_jour | ressource_id, type, dates, quantité/jour → ok | chevauchement (refus) → GARDE | DROIT, 0 écrit | ✅ |
| 39 | `ClosePrestation` | id, date | id, date, date_cloture | id, date → ok | previsionnel → (hors cycle) → ETAT ; date de clôture après la fin → GARDE | DROIT, 0 écrit | ✅ |
| 40 | `AdjustTimesheetAfterClose` | prestation_id, jour, quantité, motif | prestation_id, jour, quantite, motif | prestation_id, jour, quantité, motif → ok | prestation non close → ETAT | DROIT, 0 écrit | ✅ |
| 41 | `CancelPrestation` | id, motif | id, motif | id, motif → ok | clos → (hors cycle) → ETAT | DROIT, 0 écrit | ✅ |
| 42 | `CloseProject` | id | id | id (prestations closes) → ok | clos → (hors cycle) → ETAT | DROIT, 0 écrit | ✅ |
| 43 | `SuspendNeed` | id, motif | id, motif | id, motif → ok | suspendu → (hors cycle) → ETAT | DROIT, 0 écrit | ✅ |
| 44 | `ResumeNeed` | id | id | id → ok | non suspendu (hors cycle) → ETAT | DROIT, 0 écrit | ✅ |
| 45 | `CloseNeed` | id, motif | id, motif | id, motif → ok | ferme → (hors cycle) → ETAT | DROIT, 0 écrit | ✅ |
| 46 | `ReopenNeed` | id | id | id → ok | ouvert → (hors cycle) → ETAT | DROIT, 0 écrit | ✅ |
| 47 | `CreateAction` | un seul porteur, type, date, contenu | type, type_code, date, contenu, societe_id, contact_id, profil_candidat_id, profil_ressource_id, besoin_id, projet_id | un porteur, type, date, contenu → ok | deux porteurs → GARDE | DROIT, 0 écrit | ✅ |
| 48 | `SetPolicy` | clé, valeur | cle, valeur | clé, valeur → ok | valeur hors valeurs_possibles → GARDE ; IA (ADM seul) → DROIT | — (sans agence visée) | ✅ |
| 49 | `ManageRefs` | référentiel, code, libellé, catégorie | referentiel, code, libelle, categorie, ordre, actif | référentiel, code, libellé, catégorie → ok | catégorie inconnue → GARDE ; désactiver une valeur système → GARDE | — (sans agence visée) | ✅ |
| 50 | `ManageGroups` | groupe, permission, périmètre | groupe, permission, perimetre | — | soi pour une commande non-soi → GARDE ; permission sans périmètre → GARDE | — (sans agence visée) | ✅ |
| 51 | `SetOwnTheme` | les réglages d'apparence | ui.* | réglages d'apparence (RES) → ok | clé hors thème → GARDE | — (sans agence visée) | ✅ |
| 52 | `ArchiveObject` | type, id, motif | type, id, motif | type, id, motif → ok | personne ne l'a au seed → DROIT ; type société → commande dédiée → GARDE ; besoin non fermé → GARDE | DROIT, 0 écrit · DROIT, 0 écrit · DROIT, 0 écrit | ✅ |
| 53 | `ArchiveCompany` | id, motif | id, motif | id, motif → ok | personne ne l'a au seed → DROIT ; objets actifs → GARDE | DROIT, 0 écrit | ✅ |
| 54 | `ArchiveContact` | id | id, motif | ⛔ id (entrée du contrat seule) → GARDE (« Champ requis manquant : motif ») | personne ne l'a au seed → DROIT ; objets actifs (besoin B1 porte C1) → GARDE | DROIT, 0 écrit | ⛔ |
| 55 | `ArchiveService` | id | id, motif | ⛔ id (entrée du contrat seule) → GARDE (« Champ requis manquant : motif ») | personne ne l'a au seed → DROIT ; besoin actif sur l'unité → GARDE | DROIT, 0 écrit | ⛔ |

⚠️ Le tableau ne montre que ce que le scénario de base a vu. Les écarts de §1 trouvés par les cas ciblés s'ajoutent : `ConvertCandidateToResource` (H-2), `CloseProject` (H-5), `RecordTimesheet` et `ClosePrestation` (H-3), `CreatePrestation`, `RecordAbsence`, `CreateAction`, `UpdateCandidate` (H-4), `SetPolicy` (H-6), `CreateCompany` (H-2), `TransferContact` (H-8). `ManageGroups` n'a pas de ligne « oui » dans le tableau : ses 8 délégations réussies sont dans `scenario.jsonl` et `supp.jsonl`.

## 6. Angles morts de cette partie
- Les **sorties** ne sont comparées au contrat que par leur code et leurs événements, pas champ par champ (L4 ne porte pas de schéma JSON : « à écrire avec le lot 2 »).
- `besoin.pourvu.mode`, `retour_prospect`, `passage_client.declencheur` : lus, pas rejoués.
- Un seul cas « oui » par commande ; les alias rares (`debut`, `fin`, `tel`, `naissance`…) ne sont pas tous envoyés.
- Les commandes des lots 5.7 / 5.8 (43 contractées, non servies) : hors périmètre.
