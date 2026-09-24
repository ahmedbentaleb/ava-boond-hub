# Registre des politiques Ava Manager v1

Date : 17/09/2026 · Statut : **décidé** (ADR-005). Exhaustif par construction : toute bifurcation de DEC, F, G, ATL, BM a une ligne. Une bifurcation sans ligne = codée en dur par accident → ajouter la ligne.

Trois sections : **murs** (jamais paramétrables), **référentiels** (listes à catégorie), **politiques** (bifurcations). Défaut en **gras** = la décision d'Avaliance au 17/09/2026.

---

## A. Les murs — 15, contraintes DB, non paramétrables

Un mur se conteste avec une source, et tombe par une ADR, jamais par un réglage.

| # | Mur | Source | Ce qui casserait s'il devenait un réglage |
|---|---|---|---|
| M-1 | Un candidat ne porte jamais prestation ni temps (FK vers `profil_ressource` seulement) | DEC-02, DEC-14 | des temps sur quelqu'un qui n'est pas payé, un CA sur un vivier |
| M-2 | Un positionnement = un besoin × exactement un profil (XOR) | DEC-03 | matching à deux têtes, doublons |
| M-3 | Un profil Candidat et un profil Ressource au plus par Personne | DEC-01, BM-02 | deux fiches ressource, deux coûts de référence |
| M-4 | La ressource d'une prestation est immuable | DEC-11 | les temps de Jean deviennent ceux de Paul |
| M-5 | Aucune colonne ressource sur le projet | DEC-07 | deux vérités pour « qui travaille » |
| M-6 | Un snapshot de marge ne se réécrit pas | DEC-09 | la marge clôturée change quand la fiche ressource change |
| M-7 | Un événement métier ne se modifie ni ne s'efface | DEC-18 | l'historique ment |
| M-8 | Aucun DELETE sur un objet historique — archivage | DEC-18 | des FK orphelines, des actions sans porteur |
| M-9 | Une action a exactement un porteur | DEC-15 | journal éclaté |
| M-10 | Un temps porte la même ressource que sa prestation | F32 | idem M-4 |
| M-11 | Un besoin a une société | DEC-04 | des besoins flottants, aucun périmètre |
| M-12 | Contact et unité appartiennent à la société de leur porteur ; pas de cycle dans l'arbre des unités | BM-12, BM-19 | un besoin Alpha avec un contact Beta |
| M-13 | Une permission est toujours liée à un périmètre | DEC-17, BM-42 | droit sans limite |
| M-14 | Les conditions économiques d'une prestation ne suivent pas la fiche ressource **et ne changent plus dès qu'elle est signée** (trigger, T-2) | DEC-08, ATL-18 | rétroactivité des coûts |
| M-15 | Aucun montant **stocké** sans devise, aucun agrégat multi-devises **stocké** (T-2) | ATL-17 | un chiffre faux stocké comme vrai |

**Règle de code R-1** — *pas un mur* : toute vue ou requête d'agrégat groupe par devise ; une addition EUR + MAD est un refus en revue. La base ne peut pas l'empêcher (T-2, second patch). Elle est ici pour ne pas être oubliée, pas pour être comptée parmi les quinze.


---

## B. Les référentiels — listes à catégorie, administrables

Le **code** est stable, le **libellé** se renomme, une valeur s'**ajoute** dans une catégorie existante, se **désactive** si non système. La **catégorie** est fermée par le code : les transitions et gardes raisonnent dessus.

| Référentiel | Catégories (fermées) | Codes système par défaut | Source |
|---|---|---|---|
| `ref_etat_besoin` | `a_pourvoir` · `en_recherche` · `pourvu` · `suspendu` · `ferme` | ouvert, staffing, pourvu, suspendu, ferme | DEC-13, F6 |
| `ref_etat_candidat` | `brouillon` · `actif` · `sorti` | draft, complete | F19 ; Boond en a 14 → ajout dans `actif` ou `sorti` |
| `ref_etat_ressource` | `en_mission` · `disponible` · `sorti` | en_cours, intercontrat, sortie | US1, F26 |
| `ref_etat_positionnement` | `propose` · `presente` · `terminal_positif` · `terminal_negatif` · `retire` | propose, presente, retenu, refuse_client, retire | G10 ; Boond en a 9 — ⭐ **R1, 24/09** : `valide` (Boond) se range en `presente`, **jamais** en `terminal_positif` |
| `ref_origine_besoin` | — | regie, appel_offres, gre_a_gre, renouvellement, autre | ⭐ **R10, 24/09** : c'est elle qui dit si le projet peut se passer d'une personne comme interlocuteur |
| `ref_etat_prestation` | `previsionnel` · `engage` · `clos` · `annule` | previsionnelle, signee, cloturee, annulee | G11, US5 |
| `ref_etat_projet` | `ouvert` · `clos` | ouvert, clos | G12 |
| `ref_role_societe` | (ensemble, pas un cycle) | fournisseur, interne — **D-3** : `client` / `prospect` sont un **statut**, pas un rôle | BM-11, G6 |
| `ref_statut_commercial` | cycle court (machines §7) | prospect, client · **`ancien_client`** lu seulement sous POL `societe.retour_prospect` = `jamais_ancien_client` (relecture externe 19/09) | BM-15, F23 |
| `ref_type_ressource` | `interne` · `externe` | INTERNAL, EXTERNAL | DEC-12 |
| `ref_priorite_besoin` | — | P1, P2, P3 | DEC-13 |
| `ref_type_action` | — | note, todo, rdv, entretien_tel, entretien_physique, entretien_visio, qualification, mail, autre | audit Boond 19–21 |
| `ref_etape_suivi_positionnement` | — | cv_partage (**système**, non retirable), entretien, qualification | BM-23, CdC IV.G.4 |
| `ref_type_qualification` | — | telephonique, technique, humaine, fonctionnelle | CdC II.K |
| `ref_type_absence` | `conge` · `maladie` · `autre` | à fixer au livrable 5 | F25 |
| `ref_devise` | — | EUR, USD, MAD | US1 |
| `ref_competence` | domaines à fixer | — | CdC IV.B.5 |
| `ref_motif_retrait` | — | desistement, no_go_interne, autre | G10 |
| `ref_unite_couverture` | — | postes, fte, postes_et_fte — **système** | B-1, relecture externe 19/09 |
| `ref_type_modele` | — | action, recherche, liste_taches, formulaire, email — **système** | S-10.1, 19/09 |
| `ref_portee_modele` | — | installation, agence, personnelle — **système** | S-10.1, 19/09 |
| `ref_gravite_alerte` | `sens` | critique, elevee, moyenne, bonne — **système**. ⛔ L'échelle du SENS : aucune palette ne la touche | S-10.3, 19/09 |
| `ref_motif_interruption` | — | client, ressource, commercial, autre — **système** | M4, relecture externe 19/09 |
| `ref_motif_fin_emploi` | — | demission, fin_contrat, rupture, fin_mission_externe, autre — **système** | M15, relecture externe 19/09 |
| `ref_motif_avenant` | — | prolongation, changement_tarif, changement_charge, changement_frais, autre — **système** | B-2, relecture externe 19/09 |
| `ref_couleur` | `marque` · `vert` · `chaud` · `froid` · `neutre` · `flashy` | **16 valeurs**, chacune avec sa version sombre et sa version claire — **système**. `jaune_fluo`, `rose` et `lavande` ajoutées le 19/09. ⭐ **Mesurées le 20/09 dans le mock** : `vert_avaliance` · `violet_avaliance` · `vert_vif` · `vert_normal` · `vert_clair` · `rouge` · `orange` · `ambre` · `bleu` · **`bleu_roi`** · `cyan` · `magenta` · `gris` · `jaune_fluo` · `rose` · `lavande`. ⚠️ La « 16e sans nom » du lot 1 est **`bleu_roi`** | Hamada 18/09. [THEMES_v1.md](THEMES_v1.md) |
| `ref_police` | `chasse_fixe` · `proportionnelle` | 9 valeurs, dont 6 à chasse fixe — **système**. ⭐ **Mesurées le 20/09** : `jetbrains` · `plex` · `space` · `roboto` · `source` · `fira` · `sora` · `inter` · **`systeme`** (la pile du système, aucune police web). ⚠️ La 9e que le lot 1 ne trouvait pas est **`systeme`** | idem |
| `ref_outil` | — | notes, alertes, assistant, todo, indicateurs, calendrier — **système**. ⚠️ C'est la colonne d'outils de **l'INTERFACE** | Hamada 18/09 |
| `ref_provenance` | — | candidature, cooptation, jobboard, linkedin, reseau, appel_entrant, autre | ⭐ relevé Boond 20/09 |
| `ref_outil_technique` | — | ⬜ **vide au seed** — comme `ref_competence`. ⛔ Ne pas confondre avec `ref_outil` | ⭐ relevé Boond 20/09 |
| `ref_domaine` | — | banque, assurance, industrie, sante, secteur_public, telecoms, energie, autre. ⚠️ Distinct du **secteur** d'une société | ⭐ relevé Boond 20/09 |
| `ref_statut_contact` | `actif` · `parti` | actif, parti — **système** | ⭐ **D-9, 21/09** (V-021) : était un CHECK sur `contact.statut_code` ; migration 007 |
| `ref_type_coordonnee` | `email` · `telephone` · `reseau_social` | email, telephone, reseau_social — **système** (la contrainte « un réseau social porte son réseau » raisonne sur `reseau_social`) | ⭐ **D-9, 21/09** (V-021) : était un CHECK sur `personne_coordonnee.type_code` ; migration 007 |
| `ref_usage_coordonnee` | — | personnel, professionnel, mobile, fixe, autre (**système** : valeur par défaut) | ⭐ **D-9, 21/09** (V-021) : était un CHECK sur `personne_coordonnee.usage_code` ; migration 007. ⛔ `perimetre.type_code` **reste** un CHECK : mécanique des droits, pas une liste métier |
| `ref_secteur` | — | 30 valeurs relevées chez Boond (aéronautique, assurance, banque, défense, énergie, pharmacie, secteur public…) ⚠️ **secteur d'une société**, distinct de `ref_domaine` | ⭐ **23/09, relevé des réglages Boond** |
| `ref_metier` | — | product owner, chef de projet, MOA, ingénierie financière, architecture, ingénieur études et dev, support, ingénieur IT, administrateur, SDM/SM, autre (13) | ⭐ 23/09 |
| `ref_certification` | — | ITIL, AZURE, SAFe, AWS — ⬜ vide au seed, l'admin ajoute | ⭐ 23/09 |
| `ref_niveau_experience` | — | debutant, junior_0_2, confirme_3_5, senior_5_10, expert_10p | ⭐ 23/09 |
| `ref_niveau_formation` | — | bac, bac2, bac3, bac4, bac5 | ⭐ 23/09 |
| `ref_langue` | — | anglais, espagnol, allemand… (l'admin ajoute) | ⭐ 23/09 |
| `ref_niveau_langue` | — | scolaire, intermediaire, courant, maternel | ⭐ 23/09 |
| `ref_disponibilite_candidat` | — | asap, 1_2_semaines, 1_3_mois, 3_6_mois, 6_mois_plus | ⭐ 23/09 — ⛔ ne pas confondre avec `ref_disponibilite` (ressource) |
| `ref_situation_familiale` | — | celibataire, marie, concubinage, divorce, veuf, pacs | ⭐ 23/09 |
| `ref_type_contrat` | `actif` · `termine` | salarie_cdi, salarie_cdd, independant, stagiaire, portage, autre | ⭐ 23/09 — la fiche ressource porte le contrat |
| `ref_categorie_contrat` | — | ingenieur_cadre, etam | ⭐ 23/09 |
| `ref_classification_contrat` | — | ⭐ **21 positions Syntec** : position 1.1 coef 95 → position 3.3 coef 500 | ⭐ 23/09 — ⛔ ne se code pas en dur : une convention collective change |
| `ref_temps_travail` | — | temps_plein, temps_partiel, mi_temps | ⭐ 23/09 |
| `ref_type_document_suivi` | — | titre_sejour, certification (l'admin ajoute) | ⭐ 23/09 — document qui expire, lié à l'alerte « document arrivant à expiration » |
| `ref_categorie_achat` | — | divers, prestation_externe | ⭐ 23/09 — achats hors V1, le référentiel existe pour la reprise |
| `ref_calendrier` | — | france_sans_pentecote, royaume_uni, usa | ⭐ 23/09 — ⚠️ chaque **agence** porte son calendrier et ses jours ouvrés |
| `ref_taux_tva` | — | 20, 10, 0 (%) | ⭐ 23/09 — **facturation** |
| `ref_condition_reglement` | — | 10, 30, 40, 45, 60 jours | ⭐ 23/09 — **facturation** |
| `ref_mode_reglement` | — | virement, prelevement, cheque, cb | ⭐ 23/09 — **facturation** |
| `ref_mode_envoi_facture` | — | email, courrier, email_courrier, portail_chorus | ⭐ 23/09 — **facturation**, ⚠️ Chorus est une obligation du secteur public |
| `ref_etat_facture` | `brouillon` · `emise` · `payee` · `litige` | proforma, creation, transmis_client, relance_1, relance_2, email_client, impayee, payee | ⭐ 23/09 — **facturation** |
| `ref_etat_facture_fournisseur` | `brouillon` · `valide` · `paye` · `rejete` | brouillon, a_valider, validee, rejetee, payee | ⭐ 23/09 — **achats** |
| `ref_etat_devis` | `en_cours` · `accepte` · `refuse` · `archive` | creation, transmis_client, attente, refuse, accord_client, archive | ⭐ 23/09 — **facturation** |
| `ref_decision_client` | `positive` · `negative` · `en_attente` | retenu, refuse, sans_suite, reporte — ⭐ **V-109, 24/09** : les décisions étaient écrites en dur dans le code |
| `ref_type_message` | — | 19 modèles relevés : saisie des temps, des frais, attente de validation, validée, rejet, refus, suppression, demande/relance/confirmation de signature | ⭐ 23/09 — le **texte** du message est un modèle (`modele`), le type est ici |

---

## C. Les politiques — bifurcations, table `politique`

⭐ **Ajouts du 24/09 — réponses de la direction d'Avaliance** (`REPONSES_AVALIANCE_2026-09-24.md`) :
`cout.mode` = **selon_type_ressource** · achat_externe · salarie_formule (R5 : l'externe coûte son
achat, le salarié coûte brut + primes + frais divisés par les jours) · `cout.jours_base` = **200** (R5) ·
`projet.contact` gagne la valeur **`service_ou_societe`** (R10 : le service ou la société fait
interlocuteur, plus de contact fictif) · `candidat.blackliste.portee` = **agence** · installation (R7 :
un drapeau réversible, pas un état) · `reprise.donnees_rh_sensibles` = **oui** (R8 : on importe tout,
sous la permission dédiée `LireDonneesRHSensibles`).

⭐ **Ajout du 24/09 (D-25 bis, V-108)** — `societe.perimetre.mode` : **`agence_responsable`** (défaut) ·
`par_besoins` · `partagee`. Elle dit **comment** on juge le périmètre d'une société et d'un contact ;
la colonne `agence_responsable_id` est le mur, ce réglage est la bifurcation.

Clé · options (**défaut**) · source de la bifurcation · effet quand on change. Portée V1 = installation.

### Besoin et positionnement

| Clé | Options | Source | Effet du changement |
|---|---|---|---|
| `besoin.contact` | **facultatif** · obligatoire | DEC-04 vs CdC IV.D.1 | `CreateNeed` refuse sans contact |
| `besoin.projets_max` | **illimite** · un_seul | DEC-05 vs CdC 1–1 | `CreateProjectFromNeed` refuse au-delà |
| `besoin.staffing.declencheur` | **premier_positionnement** · commande_prise_en_charge · retour_client_retenu | G3 | qui écrit la transition `a_pourvoir → en_recherche` |
| `besoin.pourvu.mode` | **manuel_avec_garde** · auto_par_prestation_signee · auto_par_personne_signee · `auto_propose_confirme` (relecture externe 19/09) | F3, G4 | `DeclareNeedFilled` manuel vs transition automatique à `SignPrestation` |
| `besoin.unite_couverture` | **postes** · fte · postes_et_fte | B-1, relecture externe 19/09 | ⭐ ce qui **satisfait** un besoin : des postes, une charge (FTE), ou les deux. ⛔ « Deux missions = deux postes » est faux : deux mi-temps font une charge pleine et deux postes. Défaut Avaliance inchangé |
| `besoin.pourvu.garde_minimale` | **tous_les_postes_signes** · une_prestation_signee · aucune | F3 (3B, signé par Ahmed), G4, S4 — *T-1 tranché 17/09 soir* | ce que refuse `DeclareNeedFilled`. **Un poste = une prestation `engage`** rattachée au besoin (S4 : Sara 60 % + 40 % = 2 postes) ; défaut : `count(prestations engage) ≥ nb_postes_vises`. L'écran montre *n prestations signées / m postes* et, à part, le nombre de personnes distinctes |
| `positionnement.sur_besoin_inactif` | **refus** · alerte · libre | F5 | positionner sur pourvu / suspendu / fermé |
| `positionnement.unicite` | **actifs** · aucune · historique | G7, BM-21 | garde de commande, lue à l'exécution ; **aucun index unique** (D-6) |
| `positionnement.cv_partage_obligatoire` | **oui** · non | BM-23, G10 | `non` autorise `propose → terminal_positif` sans passer par `presente` |
| `positionnement.qualification_requise_avant_decision` | **non** · oui | CdC IV.E | `RecordClientDecision` refuse sans qualification |

### Projet et prestation

| Clé | Options | Source | Effet du changement |
|---|---|---|---|
| `projet.creation_depuis_besoin` | **explicite** · automatique_au_retenu | DEC-06 vs SPEC US6 RG1 | `automatique` : `RecordClientDecision(retenu)` crée le projet avec les paramètres du besoin et un événement — jamais silencieux : l'événement le dit |
| `projet.depuis_besoin.garde` | **retenu_requis** · libre | F1 | garde de `CreateProjectFromNeed` |
| `projet.depuis_besoin.garde_profil` | **personne_avec_ressource** · positionnement_ressource_strict | G1 | ce que « retenu » doit porter |
| `projet.contact` | **obligatoire** · facultatif · `obligatoire_avant_engagement` (relecture externe 19/09 : libre à la création, exigé avant la première signature) · ⭐ `service_ou_societe` (R10, 24/09 : l'interlocuteur peut être une unité ou la société entière, selon `besoin.origine_code`) | US5, F4, R10 | `CreateProject*` demande ou non un contact, ou accepte une unité ou la société |
| `projet.cloture.garde` | **prestations_closes** · cascade_cloture_prestations | F7 | `cascade` clôture les prestations `engage` restantes avec snapshot, dans la même transaction |
| `projet.devises_mixtes` | **autorise** · refus | D-9 → cahier des directeurs, question 61 | `refus` : `CreatePrestation` refuse une devise différente de la première prestation du projet ; `autorise` : le projet s'affiche en deux lignes, M-15 tient |
| `conversion.repositionnement_ressource` | **non_requis** · requis | F2 | après `ConvertCandidateToResource`, faut-il un positionnement Ressource avant `CreatePrestation` |
| `prestation.surcharge.mode` | **alerte** · refus · silencieux | DEC-10 | comportement quand l'occupation `engage` dépasse le seuil |
| `prestation.surcharge.seuil_pct` | **100** (entier) | DEC-10 | seuil d'alerte / refus |
| `prestation.annulation.garde` | **aucun_temps_saisi** · libre | G11 | `CancelPrestation` |
| `prestation.avenant.mode` | **nouvelle_prestation** ⭐ *(défaut Avaliance)* · `version_datee` (B-2, 19/09 — `prestation_version`, ajout seul, table vide sous le défaut) | ATL-18 · relecture externe 19/09 | comment se porte un changement de tarif ou de durée sur une mission signée. ⛔ M-14 tient dans les deux modes : un avenant n'écrit jamais dans `prestation`. Ancien libellé : `modification_datee` déclarée hors V1) | ATL-18, DEC-11 | mur M-4 : l'autre option n'existe pas tant que M-4 tient |
| `prestation.interruption.mode` | **cloture_anticipee** · `interruption_tracee` | M4, relecture externe 19/09 | une mission arrêtée **après** démarrage. Le temps déjà produit reste. ⛔ Ne se confond pas avec `annulee`, qui suppose zéro temps saisi |
| `projet.plafond.mode` | **aucun** · alerte · refus | M10, relecture externe 19/09 | un bon de commande plafonne le projet. `alerte` quand la consommation approche, `refus` bloque au-delà |
| `projet.origine_besoin` | **facultative** · obligatoire | M18, relecture externe 19/09 | un projet interne, une régie directe ou une maintenance peut-il naître **sans** besoin ? ⭐ Sous le défaut, oui — et il ne pourvoit alors aucun besoin (DEC-05) |

### Ressource, temps, absence

| Clé | Options | Source | Effet du changement |
|---|---|---|---|
| `ressource.etat.mode` | **manuel** · derive_des_prestations · `derive_avec_exceptions_tracees` (relecture externe 19/09) | F26 | `derive` : `en_mission` si une prestation `engage` couvre aujourd'hui, sinon `disponible` ; `sorti` reste manuel |
| `ressource.externe.societe_fournisseur` | **obligatoire** · facultatif | DEC-12 | CHECK appliqué par la commande |
| `temps.periode` | **dates_prestation** · dates_prestation_et_mois_ouvert | G9 | `mois_ouvert` introduit une clôture mensuelle — hors V1, clé déclarée |
| `temps.correction_apres_cloture` | **ajustement_trace** · refus | F34 | `AdjustTimesheetAfterClose` autorisé ou non ; le snapshot ne bouge jamais (M-6) |
| `temps.plafond_jour` | **alerte** · refus · aucun · `refus_avec_derogation_tracee` (relecture externe 19/09) | P-6 → cahier des directeurs, question 60 | somme des temps d'une personne sur un jour > `capacite.jour_ouvre` ; jamais silencieux sous le défaut |
| `temps.sans_prestation` | **refuse** · autorise_type_interne | F33 | hors V1, clé déclarée |
| `temps.validation` | **aucune** · par_dp · `par_projet` (relecture externe 19/09 : exigée sur les temps facturables, réglée projet par projet) | F35, ATL-08 | `par_dp` ajoute une commande `ValidateTimesheet` — hors V1, clé déclarée |
| `absence.sans_prestation` | **autorisee** · refusee | F25 | `RecordAbsence` |
| `absence.validation` | **aucune** · par_manager | BM-37 | hors V1, clé déclarée |
| `absence.impact_charge` | **deduit_du_previsionnel** · `sans_impact` · `deduit_et_signale` | M13, relecture externe 19/09 | ce qu'une absence fait à la charge engagée d'une mission en cours |
| `temps.reouverture` | **impossible** · `commande_dediee_tracee` | M17, relecture externe 19/09 | rouvrir une période verrouillée. ⚠️ Lue seulement si `temps.periode` = `dates_prestation_et_mois_ouvert` |
| `temps.facturable.mode` | **egal_au_produit** · `saisie_separee` | B-4, M11, relecture externe 19/09 | ⭐ 20 jours produits, 18 facturés. Sous `saisie_separee`, `temps.quantite_facturable` s'ouvre à côté de `temps.quantite` — **les deux mesures sont conservées**, jamais l'une à la place de l'autre |
| `ressource.changement_agence.mode` | **nouvelle_affectation_datee** · `mutation_simple` | M7, relecture externe 19/09 | une ressource change d'agence ou d'entité : calendrier, manager, coût et droits suivent. ⛔ L'historique ne se réécrit pas |

### Société, contact, doublons

| Clé | Options | Source | Effet du changement |
|---|---|---|---|
| `societe.passage_client.declencheur` | **premiere_prestation_signee** · creation_projet · manuel · `premier_engagement_contractuel` (relecture externe 19/09) | G8, BM-15 | qui écrit `ClientStatusDerived` |
| `societe.passage_client.propagation` | **branche_contractante_et_contacts_du_service** · societe_seule · toute_la_societe | BM-15, CdC II.F | jusqu'où remonte / descend le statut |
| `societe.retour_prospect` | **manuel** · auto_fin_dernier_contrat · auto_apres_delai · `jamais_ancien_client` (relecture externe 19/09 : un client ne redevient pas prospect, il devient **ancien client** — ajoute la valeur `ancien_client` à `ref_statut_commercial`) | F23, CdC « 6 mois ? » | déclencheur du retour |
| `societe.retour_prospect.delai_mois` | **6** (entier, lu seulement si `auto_apres_delai`) | CdC | — |
| `contact.transfert.objets_actifs` | **reaffectation_obligatoire** · conserver_liens | BM-14 | `TransferContact` |
| `societe.archivage.garde` | **aucun_objet_actif** · libre | ⭐ L4, 20/09 | `ArchiveCompany` refuse s'il reste des objets actifs |
| `absence.chevauchement` | **refus** · alerte · libre | ⭐ L4, 20/09 | `RecordAbsence` : deux absences qui se chevauchent |
| `personne.coordonnees.multiples` | **oui** · une_par_type · non | ⭐ relevé Boond, 20/09 | plusieurs e-mails et téléphones par personne |
| `societe.groupe.propagation_statut` | **aucune** · vers_les_filles · vers_la_mere · les_deux | ⭐ relevé Boond, 20/09 · D-2 | ⛔ défaut **aucune** : une filiale cliente ne rend pas le groupe client |
| `societe.donnees_legales.requises` | **[]** · liste parmi statut_juridique, tva_intracom, siret, rcs, code_ape, numero_fournisseur | ⭐ relevé Boond, 20/09 | ⚠️ un SIRET n'existe pas au Maroc : le format se vérifie **dans la commande**, selon le pays |
| `candidat.note.echelle` | **1_5** · 1_10 · 1_100 · aucune | ⭐ relevé Boond, 20/09 | ⛔ pas un CHECK figé : un trigger lit la politique |
| `service.archivage.garde` | **aucun_besoin_ni_projet_actif** · libre | BM-17 | `ArchiveService` |
| `doublon.personne.mode` | **avertir** · bloquer · ignorer | F20 | à `CreatePerson` |
| `doublon.personne.cles` | **[email, nom+prenom+naissance]** (liste) · `score_pondere` (relecture externe 19/09 : e-mail + téléphone normalisé + nom/prénom + naissance, avec un seuil) | F20 | champs comparés |
| `doublon.contact.mode` | **avertir** · bloquer · ignorer | CdC · cahier ligne 36 | ⚠️ **Ajoutée le 18/09** : le cahier des directeurs la promettait depuis le 17/09, le registre ne l'avait pas. Trouvée en réconciliant les deux |
| `doublon.contact.cles` | **[email, nom+prenom+societe]** (liste) · `[email_ou_telephone, nom+prenom+societe]` (relecture externe 19/09) | cahier ligne 37 | sur quoi on repère un contact déjà connu |
| `doublon.societe.mode` | **avertir** · bloquer · ignorer | cahier ligne 38 | idem pour une société |
| `doublon.societe.cles` | **[nom_normalise, siren]** (liste) | cahier ligne 39 | le nom normalisé, ou l'identifiant légal |
| `doublon.fusion` | **manuelle_habilitee** (seule option V1) | F21 | jamais automatique ; l'autre option n'existe pas |
| `doublon.fusion.previsualisation` | **obligatoire** · `directe` | M16, relecture externe 19/09 | ⛔ Sous le défaut, la fusion **montre d'abord** ce qu'elle va déplacer — besoins, positionnements, missions, temps, historique — et demande confirmation |

### Recrutement

| Clé | Options | Source | Effet du changement |
|---|---|---|---|
| `candidat.complete.champs_requis` | **[nom, prenom, civilite, localisation, email_ou_telephone]** (liste) · `[nom, prenom, localisation, email_ou_telephone]` (relecture externe 19/09 : la civilité n'est pas une donnée de complétude) | BM-04, F19 | garde de `CompleteCandidate` |
| `candidat.conversion.acteur` | **groupe_rh** · groupe_rh_ou_rr · tout_habilite | F9 | qui peut `ConvertCandidateToResource` (double avec la matrice : la matrice donne le droit, la politique dit le rôle attendu par défaut) |
| `recrutement.approbation` | **aucune** · approbation_rr | F10 | `approbation_rr` ajoute une commande `ApproveRecruitment` avant la conversion — hors V1, clé déclarée |
| `qualification.besoin_obligatoire` | **oui** · non | BM-09 | `non` autorise une qualification hors besoin (le CdC dit non) |
| `qualification.mesure_remplace_affichage` | **oui_historique_conserve** (seule option) | CdC IV.B.5 + M-7 | — |

### Occupation, capacité, chiffres (ATL)

| Clé | Options | Source | Effet du changement |
|---|---|---|---|
| `occupation.grain` | **jour** · demi_jour | F29 | grain de calcul ; l'affichage est une préférence utilisateur |
| `occupation.affichage_defaut` | **semaine** · mois | F29 | vue par défaut |
| `occupation.inclure_previsionnel` | **oui_distingue** · non | F31 | ATL-02 |
| `capacite.jour_ouvre` | **1.0** (décimal) | F30, ATL | capacité d'un jour ouvré temps plein ; temps partiel hors V1 |
| `capacite.source` | **calendrier_agence** · calendrier_global · `calendrier_ressource_employeur` (relecture externe 19/09, avec règle de priorité explicite) | F30 | quel calendrier |
| `ca_produit.base` | **temps_saisis** · temps_valides | F35, ATL-08 | `temps_valides` exige `temps.validation ≠ aucune` |
| `ca_produit.forfait.mode` | **prorata_jours_ouvres** · jalons | ATL-09 | `jalons` hors V1, clé déclarée |
| `frais.mode` | **imputes_en_marge** · ignores | ATL-13 | ATL-14 |
| `change.mode` | **aucune_conversion** · taux_saisi | ATL-17 | `taux_saisi` hors V1 ; M-15 tient dans les deux cas |
| `marge.taux.si_ca_nul` | **tiret** · zero | ATL-16 | affichage |
| `ca_produit.provisoire.affichage` | **separe_et_nomme** · `masque` | B-3, relecture externe 19/09 | ⭐ Deux chiffres, jamais un seul : le **provisoire** (temps saisis) et le **réalisé** (temps validés), chacun dans sa vue, chacun nommé. ⛔ Ne jamais servir l'un pour l'autre |
| `correction.mode` | **evenement_compensatoire** · `avoir` | M14, relecture externe 19/09 | corriger après facturation. ⛔ Dans les deux cas **rien ne se réécrit** : on ajoute. M-6 et M-7 tiennent |

### Droits et administration

| Clé | Options | Source | Effet du changement |
|---|---|---|---|
| `droits.surcharge_restrictive` | **restriction_gagne** · union_gagne | F28 | ⚠️ `union_gagne` affaiblit les surcharges ; conservé comme bifurcation parce que c'en est une, signalé en rouge dans l'écran |
| `droits.support.mutation` | **lecture_seule** · assistance_active_deleguee | F13, CdC III.G | `assistance_active` hors V1, clé déclarée |
| `archivage.restauration` | **impossible** · commande_dediee | F27 | hors V1, clé déclarée |
| `historique.tentatives_refusees` | **tracees_a_part** · non_tracees | BM-44 | trace ou non des refus (jamais dans les réussites — M-7) |

### Installation — ajouté le 18/09

| Clé | Options | Source | Effet du changement |
|---|---|---|---|
| `auth.fournisseur` | **microsoft** · google · email_mot_de_passe | Hamada 18/09 : le produit est vendu à d'autres sociétés | comment on se connecte. Chaque installation a le sien |
| `rgpd.duree_conservation_candidat` | **24** mois après le dernier contact (entier) | RGPD · candidats France / Maroc / Dubaï | au-delà, `AnonymisePersonne` est proposée. La durée diffère d'un pays et d'une société à l'autre |

### Modèles, alertes et langue — ajouté le 19/09

| Clé | Options | Source | Effet du changement |
|---|---|---|---|
| `modele.portee.defaut` | **agence** · installation · personnelle | S-10.1 | où naît un modèle qu'on vient de créer |
| `modele.recherche.partage` | **habilite** · tous · personnel | S-10.1 | qui voit une recherche enregistrée par quelqu'un d'autre |
| `modele.formulaire.actif` | **non** · oui | S-10.1 | ⬜ hors V1 : des champs libres sur les fiches. ⚠️ La clé est déclarée pour que la table n'ait pas à changer |
| `alerte.actives` | **les 9 du défaut Avaliance** · toute liste de codes d'`alerte_regle` | S-10.3 | ⭐ le même patron que `ui.rail.outils` : un **catalogue**, et une sélection ordonnée |
| `alerte.canal` | **ecran** · ecran_et_email | S-10.3 | ⬜ `ecran_et_email` hors V1 |
| `alerte.frequence` | **temps_reel** · quotidien | S-10.3 | quand l'alerte se recalcule |
| `i18n.langues` | **[fr]** · toute liste de `ref_pays`/locales | S-10.2 | ⬜ hors V1, clé déclarée. ⚠️ Ses candidats sont en France, au Maroc, aux US et à Dubaï (F1) : ça reviendra |

⭐ **Ce que ça referme** : sans ces sept clés, « tout est paramétrable » était faux — les alertes et les modèles étaient dans le code.

### Apparence — ajouté le 18/09

| Clé | Options | Source | Effet du changement |
|---|---|---|---|
| `ui.theme.defaut` | les **seize** valeurs ci-dessous, en un jeu | Hamada 18/09 | ce que voit une personne qui n'a rien choisi. Une autre société installe le sien |
| `ui.theme.choix_utilisateur` | **oui** · non | Hamada 18/09 (D2) | `non` : `compte.theme_json` est ignoré, tout le monde voit le défaut. Les réglages disparaissent |
| `ui.theme` | **avaliance** · 27 autres de `ref_theme` | Hamada 19/09 | ⭐ **un thème regroupe tout** : les deux couleurs, la police, les angles, les pastilles, les boutons, les cartes, le marqueur, l'épaisseur et la densité. ⛔ Il ne porte **pas le fond** — chacun tient en sombre, intermédiaire et clair. Le poser écrit **neuf** réglages d'un coup ; chacun se retouche ensuite |
| `ui.palette` | **avaliance** · terminal · ambre · glace · encre · phosphore | Hamada 18/09 | remplit les deux rôles colorés d'un coup |
| `ui.mode` | **sombre** · intermediaire · clair | Hamada 18/09 | le fond et l'échelle de gris. Sur fond foncé : texte argenté, couleurs vives |
| `ui.fond.page` | **du thème** · une couleur de `ref_couleur` | Hamada 19/09 | le fond **hors carte** |
| `ui.fond.carte` | **du thème** · une couleur | Hamada 19/09 | le fond des cartes et des panneaux, et ses deux nuances internes |
| `ui.fond.barre` | **du thème** · une couleur | Hamada 19/09 | le bandeau et la barre d'écran |
| `ui.fond.colonne` | **du thème** · une couleur | Hamada 19/09 | le menu de gauche et la colonne d'outils |
| `ui.survol` | **du thème** · une couleur | Hamada 19/09 | la ligne, l'entrée de menu ou l'option que la souris traverse |
| `ui.selection` | **(celle d'ACTION)** · une couleur | Hamada 19/09 | ce qui est coché |
| `ui.selection.style` | **fond** · barre_a_gauche · contour | Hamada 19/09 | comment se montre une ligne sélectionnée |
| `ui.fond.force` | **aucune** · legere (7 %) · nette (14 %) · forte (24 %) | Hamada 19/09 | combien la teinte mord sur le gris. ⛔ Au-delà de 24 %, le fond devient un aplat et les données se battent avec lui |
| `ui.fond.image` | **aucune** · maillage · une image du catalogue | Hamada 19/09 | ⭐ une image **derrière le logiciel**, en `fixed` : elle ne défile pas. ⛔ `maillage` est **dessiné** dans la couleur de STRUCTURE du thème — zéro octet, et il suit le thème au lieu de lui résister |
| `ui.fond.image.voile` | leger (35 %) · **normal** (55 %) · fort (72 %) · tres_fort (86 %) | Hamada 19/09 | combien la couleur du fond recouvre l'image. ⛔ Sans voile, une donnée posée sur une nébuleuse n'est plus une donnée |
| `ui.surface.transparence` | opaque · legere (90 %) · **nette** (76 %) · forte (58 %) | Hamada 19/09 | ce que les cartes, les colonnes et les barres laissent passer **quand une image est posée**. ⛔ Sans transparence l'image est là et ne se voit nulle part. ⭐ `opaque` = exactement comme avant l'image |
| `ui.ombre` | aucune · **légère** · mediane · prononcee | Hamada 19/09 | ⭐ le cran que le **thème** pose pour les trois surfaces. ⛔ L'opacité suit le fond — **0,55 sur sombre, 0,42 sur intermédiaire, 0,16 sur clair** : une ombre noire sur du noir ne se voit pas |
| `ui.ombre.tuile` | **du thème** · aucune · legere · mediane · prononcee | Hamada 19/09 | les tuiles du tableau de bord — « qu'on ait l'impression qu'elles sortent du truc » |
| `ui.ombre.carte` | **du thème** · aucune · legere · mediane · prononcee | Hamada 19/09 | les panneaux et les cartes de contenu |
| `ui.ombre.bouton` | **du thème** · aucune · legere · mediane · prononcee | Hamada 19/09 | les boutons d'ACTION et les boutons ronds |
| `ui.surface.transparence.carte` | **du thème** · opaque · legere · nette · forte | Hamada 19/09 | les cartes et les panneaux |
| `ui.surface.transparence.colonne` | **du thème** · opaque · legere · nette · forte | Hamada 19/09 | ⭐ **le menu de gauche ET la colonne d'outils** — « il faut la régler toute seule ». ⛔ Les deux ensemble : c'est une seule surface vue de deux côtés |
| `ui.surface.transparence.barre` | **du thème** · opaque · legere · nette · forte | Hamada 19/09 | le bandeau et la barre d'écran |
| `ui.intensite` | **normal** · discret · fort | Hamada 18/09 | ⭐ la **vivacité** de la couleur, et rien d'autre : l'aplat est mélangé au fond à **20 % · 50 % · 100 %**, l'encre dedans se recalcule sur le mélange |
| `ui.epaisseur` | **medium** · fin · large | Hamada 18/09 | la **largeur des traits** — bordures, filets, bandes, contours. ⛔ Ne touche à aucune couleur : un filet invisible se corrige par sa **teinte**, pas par sa largeur |
| `ui.densite` | **normal** · compact · confort | Hamada 18/09 | resserre ou aère toute la grille |
| `ui.filet.couleur` | **du thème** · une couleur | Hamada 19/09 | ⭐ la couleur des **filets** — bordures de cartes, séparateurs, contours de champs. Sans choix, elle prend une pointe de la couleur de STRUCTURE du thème : **les bords suivent le thème** au lieu de rester gris sous les 28 |
| `ui.filet.carte` | **du thème** · aucun (0) · fin (1 px) · moyen (2) · gros (3) | Hamada 19/09 | l'épaisseur du filet des **cartes** et des panneaux. ⭐ **Même découpe que `ui.fond.*`** : ce qui a sa couleur a son épaisseur |
| `ui.filet.barre` | **du thème** · aucun (0) · fin (1 px) · moyen (2) · gros (3) | Hamada 19/09 | le bandeau, la barre d'écran, les onglets, le pied de table |
| `ui.filet.colonne` | **du thème** · aucun (0) · fin (1 px) · moyen (2) · gros (3) | Hamada 19/09 | le menu de gauche et la colonne d'outils |
| `ui.filet.champ` | **du thème** · aucun (0) · fin (1 px) · moyen (2) · gros (3) | Hamada 19/09 | les champs, les boutons de filtre, la recherche — ⛔ un filet de champ trop gros mange la saisie |
| `ui.menu.largeur` | **normale** (214 px) · etroite (178) · large (252) | Hamada 19/09 | la largeur de la colonne de gauche. ⭐ **Chaque thème la pose** — un thème compact n'a pas la même colonne qu'un thème confort |
| `ui.rail.position` | **droite** · gauche · masquee | Hamada 18/09 | la colonne d'outils |
| `ui.rail.outils` | liste de `ref_outil` — **les six** | Hamada 18/09 | bloc-notes, alertes, assistant, à faire, indicateurs, calendrier |
| `ui.rail.ouvert` | **alertes** · un code de `ref_outil` | Hamada 18/09 | l'outil ouvert au chargement |
| `ui.couleur.action` | **(palette)** · 12 de `ref_couleur` | Hamada 18/09 | ⭐ rôle **ACTION** — boutons, entrée active, focus. ~5 % de l'écran |
| `ui.couleur.structure` | **(palette)** · 12 de `ref_couleur` | Hamada 18/09 | ⭐ rôle **STRUCTURE** — titres, en-têtes, clés. Les **données** ne sont jamais colorées, le **sens** a son échelle |
| `ui.police` | **jetbrains_mono** · 8 autres (`ref_police`) | Hamada 18/09 | la famille, du haut en bas |
| `ui.angle` | **carre** · leger · arrondi | Hamada 18/09 | rayon 0 / 2 / 7 px sur tout ce qui a un bord |
| `ui.pastille` | **contour** (2 px) · plein | Hamada 18/09 | les étiquettes d'état |
| `ui.bouton` | **contour** · plein · fantome · souligne | Hamada 18/09 | les boutons d'action, **indépendants des pastilles** |
| `ui.carte` | **cadre** · gauche · droite · haut · bas · plein · aucun | Hamada 18/09, élargi le 19/09 | où se pose le trait coloré d'une carte. ⛔ Pourquoi seulement à gauche ? |
| `ui.carte.libelle` | **couleur** · neutre | Hamada 19/09 | le libellé d'une tuile prend la couleur de sa bande, ou reste du texte. ⛔ ARDOISE FUN = `neutre` : « juste les barres à gauche, c'est tout » |
| `ui.menu.entrees` | **les 13 entrées du template Avaliance** · toute liste ordonnée | Hamada 19/09 | ⭐ **chaque société compose son menu** — même patron que `ui.rail.outils`. ⛔ Un menu n'est pas une permission : masquer une entrée range, ça ne protège rien |
| `ui.notes` | **infobulle** · sous_le_titre · aucune | Hamada 19/09 | ⭐ Une explication ne s'écrit pas sous un titre : un « ? » discret, et le texte **au survol**. `sous_le_titre` la remet en paragraphe — pour une formation ou une reprise |
| `ui.menu.coloration` | **aucune** · icone · titre · les_deux | Hamada 19/09 | ⭐ **ce qui prend la couleur de l'entrée** — l'icône, le titre, les deux, ou rien. ⛔ L'icône reste toujours là : sans elle, une colonne repliée ne dit rien |
| `ui.menu.titre` | **oui** · non | Hamada 19/09 | le libellé, replié comme déplié |
| `ui.menu.pastille` | **une_par_entree** · une_seule · par_metier · non | Hamada 19/09 | ⭐ un **filet de 3 px** au bord de l'entrée. ⛔ Une couleur **par entrée** : treize entrées qui se partagent cinq couleurs ne disent rien. ⭐ `une_seule` le 19/09 au soir : « une couleur pour tout, ou une couleur pour chaque »|
| `ui.menu.couleur.une` | **(celle d'ACTION)** · une couleur | Hamada 19/09 | la couleur unique, quand `ui.menu.pastille` vaut `une_seule` |
| `ui.menu.couleurs` | **celle du rang** · une couleur par entrée | Hamada 19/09 | ⭐ **chaque entrée se retouche** — Tableau de bord une couleur, Actions une autre. Un menu déroulant par entrée, le même qu'ailleurs |
| `ui.menu.icones` | **celle du modèle** · une des 78 | Hamada 19/09 | ⭐ **chaque entrée choisit son icône** dans la bibliothèque. ⛔ Toutes au même tracé — 16×16, trait de 1,3, bouts ronds : une icône hors grille se voit tout de suite au milieu des autres |
| `ui.menu.icones.perso` | **aucune** · des `.svg` téléversés | Hamada 19/09 | ⭐ **sa propre bibliothèque**, importée en `.svg`. ⛔ Un SVG téléversé est du **CODE** : il est nettoyé par **liste blanche** — 12 balises, 18 attributs, rien d'autre. Script, `on…`, `foreignObject`, image liée : refusés. Remis à l'échelle 16×16 pour tenir la grille |
| `ui.menu.filet.intensite` | **plein** · demi (62 %) · neutre (34 %) · faible (18 %) | Hamada 19/09 | ce que le filet donne à voir. ⛔ `neutre` n'est pas `aucune` : le filet reste, il s'efface — c'est un rythme, pas une couleur |
| `ui.menu.selection.couleur` | **celle de l'entrée** · celle d'ACTION | Hamada 19/09 | ⭐ ce que porte la **plaque de l'entrée ouverte**. « Je veux qu'elle porte les mêmes couleurs du produit sélectionné » — la plaque se construit sur SA couleur, et l'encre se recalcule dessus |
| `ui.fond.image.perso` | **aucune** · un fichier téléversé | Hamada 19/09 | ⭐ **sa propre photo** en arrière-plan, pas seulement celles du modèle. ⛔ Elle ne part pas dans l'adresse : un `#t=` de 3 Mo ne se partage pas — elle vit dans le stockage du navigateur |
| `ui.vues.par_ecran` | **déclarées par écran** — liste · kanban · graphe · vignettes | S-7, 19/09 | ⛔ Toutes les listes ne portent pas toutes les vues : une liste de personnes n'a pas de graphe utile. Rien n'est écrit en dur |
| `ui.couleur.metier` | **(les cinq d'origine)** · une couleur de `ref_couleur` **par chemin** — C1 CRM, C2 recrutement, C3 staffing, C4 production, C5 externe | Hamada 19/09 | ⛔ On n'impose pas les couleurs de métier : chacune se choisit. `null` = celle d'origine |
| `ui.couleur.sens` | **(l'échelle d'origine)** · une couleur **par niveau** — bon, à surveiller, critique | Hamada 19/09 | ⭐ L'échelle du SENS devient choisie, et **c'est différent d'être repeinte** : ⛔ aucune palette ne la touche toujours. C'est l'installation qui la fixe, une fois |
| `ui.encre.t1` | **du fond** · une couleur | Hamada 19/09 | les **chiffres et les noms** — l'encre la plus forte |
| `ui.encre.t2` | **du fond** · une couleur | Hamada 19/09 | le **texte courant** |
| `ui.encre.t3` | **du fond** · une couleur | Hamada 19/09 | le **secondaire** — sous-titres, détails |
| `ui.encre.t4` | **du fond** · une couleur | Hamada 19/09 | les **étiquettes** — ⛔ 3:1 lui suffit : au-delà on ne la distinguerait plus de `t3` |
| `ui.role.banc` | **staffing** · dp · ia · rh · ressource | Hamada 19/09 | ⛔ Le banc d'essai quitte le bandeau : il descend sous le nom, là où vit déjà l'administration. Un bandeau de produit n'est pas un tableau de bord de démonstration |
| `ui.coloration` | **comme_le_menu** · par_metier · une_couleur | Hamada 18/09, élargi le 19/09 | ⭐ « Ce qui s'affiche en haut suit les couleurs de gauche » : une tuile prend la couleur de **l'entrée de menu à laquelle elle répond** |
| `ui.bord.tuiles` | **les huit** · toute sélection ordonnée | Hamada 19/09 | ⭐ ce qui s'affiche en tuiles sur le tableau de bord. **Troisième fois le même patron** : un catalogue, une sélection — comme `ui.menu.entrees` et `ui.rail.outils` |
| `ui.liste.societes.colonnes` | **les 7, dans l'ordre déclaré** · toute sélection ordonnée | Hamada 19/09 | les colonnes de « Sociétés » — ⛔ la dernière ne se masque pas |
| `ui.liste.contacts.colonnes` | **les 6, dans l'ordre déclaré** · toute sélection ordonnée | Hamada 19/09 | les colonnes de « Contacts » — ⛔ la dernière ne se masque pas |
| `ui.liste.candidats.colonnes` | **les 6, dans l'ordre déclaré** · toute sélection ordonnée | Hamada 19/09 | les colonnes de « Candidats » — ⛔ la dernière ne se masque pas |
| `ui.liste.ressources.colonnes` | **les 7, dans l'ordre déclaré** · toute sélection ordonnée | Hamada 19/09 | les colonnes de « Ressources » — ⛔ la dernière ne se masque pas |
| `ui.liste.besoins.colonnes` | **les 6, dans l'ordre déclaré** · toute sélection ordonnée | Hamada 19/09 | les colonnes de « Besoins » — ⛔ la dernière ne se masque pas |
| `ui.liste.projets.colonnes` | **les 7, dans l'ordre déclaré** · toute sélection ordonnée | Hamada 19/09 | les colonnes de « Projets » — ⛔ la dernière ne se masque pas |
| `ui.liste.prestations.colonnes` | **les 8, dans l'ordre déclaré** · toute sélection ordonnée | Hamada 19/09 | les colonnes de « Prestations » — ⛔ la dernière ne se masque pas |
| `ui.liste.actions.colonnes` | **les 5, dans l'ordre déclaré** · toute sélection ordonnée | Hamada 19/09 | les colonnes de « Actions » — ⛔ la dernière ne se masque pas |
| `ui.liste.modeles.colonnes` | **les 6, dans l'ordre déclaré** · toute sélection ordonnée | Hamada 19/09 | les colonnes de « Modèles » — ⛔ la dernière ne se masque pas |
| `ui.liste.alertes.colonnes` | **les 6, dans l'ordre déclaré** · toute sélection ordonnée | Hamada 19/09 | les colonnes de « Alertes » — ⛔ la dernière ne se masque pas |
| `ui.liste.comptes.colonnes` | **les 6, dans l'ordre déclaré** · toute sélection ordonnée | Hamada 19/09 | les colonnes de « Comptes » — ⛔ la dernière ne se masque pas |
| `ui.fiche.societe.onglets` | **les 7, dans l'ordre déclaré** · toute sélection ordonnée | Hamada 19/09 | les onglets de « Fiche société » — ⛔ le dernier ne se masque pas |
| `ui.fiche.contact.onglets` | **les 5, dans l'ordre déclaré** · toute sélection ordonnée | Hamada 19/09 | les onglets de « Fiche contact » — ⛔ le dernier ne se masque pas |
| `ui.fiche.candidat.onglets` | **les 7, dans l'ordre déclaré** · toute sélection ordonnée | Hamada 19/09 | les onglets de « Fiche candidat » — ⛔ le dernier ne se masque pas |
| `ui.fiche.ressource.onglets` | **les 8, dans l'ordre déclaré** · toute sélection ordonnée | Hamada 19/09 | les onglets de « Fiche ressource » — ⛔ le dernier ne se masque pas |
| `ui.fiche.besoin.onglets` | **les 5, dans l'ordre déclaré** · toute sélection ordonnée | Hamada 19/09 | les onglets de « Fiche besoin » — ⛔ le dernier ne se masque pas |
| `ui.fiche.projet.onglets` | **les 5, dans l'ordre déclaré** · toute sélection ordonnée | Hamada 19/09 | les onglets de « Fiche projet » — ⛔ le dernier ne se masque pas |
| `ui.fiche.prestation.onglets` | **les 5, dans l'ordre déclaré** · toute sélection ordonnée | Hamada 19/09 | les onglets de « Fiche prestation » — ⛔ le dernier ne se masque pas |
| `ui.tuile.clic` | **oui** · non | Hamada 19/09 | ⭐ une tuile **ouvre l'écran de son entrée de menu**. La tuile SOCIÉTÉS mène aux sociétés — ⛔ jamais vers autre chose que ce qu'elle compte |
| `ui.ecran.cadre` | **aucun** · titre · souligne · gauche · droite · haut · bas · cadre | Hamada 19/09 | ⭐ où se pose **la couleur de l'entrée** sur l'écran ouvert. `titre` ne touche **aucun panneau** — un filet devant le titre, rien d'autre ; les cinq suivants bordent les panneaux comme une carte. ⛔ Avaliance = `titre` : les cadres y restent neutres |

⚠️ **Ce que ces deux clés ne rouvrent pas** : BM-49 tient — libellés d'écran, colonnes par défaut et langue restent des **préférences**, pas des politiques. Ici, c'est le **catalogue** et le **défaut** qui sont une décision d'installation ; le choix individuel reste une préférence (`compte.theme_code`).

⬜ **Hors V1, clé déclarée** : `ui.theme.personnalise` — un thème sur mesure aux couleurs d'un client. C'est un éditeur de thèmes, même piège que l'éditeur de process différé par F16.

### C.bis — Ajouts du 23-24/09 : le relevé complet des réglages Boond et les réponses d'Avaliance

⭐ **Décision d'Hamada, 23/09 : « tout en V1, ne rien oublier ».** Chaque ligne vient soit d'un réglage
**vu à l'écran chez Boond** (`cartographie/BOOND_REGLAGES_2026-09-23.md`), soit d'une **réponse de la
direction** (`REPONSES_AVALIANCE_2026-09-24.md`). Défaut en gras = ce que fait Avaliance aujourd'hui.

| Clé | Valeurs (défaut en **gras**) | Source | Effet |
|---|---|---|---|
| `cout.mode` | **selon_type_ressource** · achat_externe · salarie_formule | R5, 24/09 | l'externe coûte son achat ; le salarié coûte brut + primes + frais ÷ `cout.jours_base` |
| `cout.jours_base` | **200** | R5 | le diviseur du coût journalier d'un salarié |
| `societe.perimetre.mode` | **agence_responsable** · par_besoins · partagee | D-25 bis, 24/09 | comment on juge le périmètre d'une société et de ses contacts |
| `candidat.blackliste.portee` | **agence** · installation | R7, 24/09 | un drapeau réversible, posé pour une agence ou pour toutes |
| `reprise.donnees_rh_sensibles` | **oui** · non | R8, 24/09 | la reprise importe n° de sécurité sociale, nationalité, lieu de naissance, situation familiale — lus sous `LireDonneesRHSensibles` |
| `actions.creation_multiple` | **oui** · non | Boond, actions/états | forcer plusieurs actions d'un coup pour « Présentation client » et « Suivi de mission » |
| `referentiels.tri_alphabetique` | **non** · oui | Boond, actions/états | l'ordre des listes : celui de l'administrateur, ou alphabétique |
| `facturation.tva_defaut` | **20** · 10 · 0 | Boond, facturation | le taux proposé à la création d'une facture |
| `facturation.condition_reglement_defaut` | **30** · 10 · 40 · 45 · 60 | Boond, facturation | l'échéance proposée, en jours |
| `facturation.mode_envoi_defaut` | **email** · courrier · email_courrier · portail_chorus | Boond, facturation | le canal d'envoi proposé ; Chorus pour le secteur public |
| `facturation.relance.jours` | **[7, 15, 30]** | Boond (Relance 1, Relance 2) | quand relancer une facture impayée |
| `rh.contrat.obligatoire_avant_prestation` | **non** · oui | Boond, alerte « prestation non couverte par un contrat RH » | exiger un contrat RH avant de signer une mission |
| `rh.document.alerte_jours` | **60** | Boond, alertes | le seuil de l'alerte « document arrivant à expiration » |
| `temps.signature.demandee` | **non** · oui | Boond, activité/frais | demander la signature d'une feuille de temps |
| `alerte.rapport.jours` | **[lun, mar, mer, jeu, ven]** | Boond, alertes | les jours d'envoi du rapport quotidien |
| `alerte.rapport.heure_quotidienne` | **08:00** | Boond, alertes | l'heure du rapport quotidien — ⚠️ à l'heure de l'agence du lecteur |
| `alerte.rapport.jour_hebdo` | **lundi** | Boond, alertes | le jour du rapport hebdomadaire |
| `alerte.rapport.heure_hebdo` | **08:00** | Boond, alertes | l'heure du rapport hebdomadaire |
| `ui.tableau_de_bord.widgets` | **[repartition_besoins, repartition_candidats, synthese, ca_facture_signe, ca_periode_production_signe, ca_marge_signes, mes_alertes]** · + mes_temps · mes_frais · mes_absences | Boond, configuration d'un compte | les widgets affichés, **réglables compte par compte** ; le défaut est ce qu'Avaliance affiche |

---

## D. Ce qui n'est ni mur, ni référentiel, ni politique

| Sujet | Où c'est |
|---|---|
| La matrice rôle × commande × périmètre | tables `groupe`, `permission`, `perimetre` — **configuration**, étape 8 |
| Le périmètre V1 (F15–F18) | décision de lot, pas un réglage |
| Les formules ATL elles-mêmes | code, versionné (`version_atl` dans le snapshot) ; seules leurs **variantes** sont des politiques |
| Les libellés d'écran, colonnes par défaut, langue | préférences (BM-49), pas des politiques métier |

## E. Compte — ⭐ la seule source

Les autres documents **ne réécrivent pas ces chiffres** : ils renvoient ici (« voir registre §E »). Un compte écrit à deux endroits diverge à la passe suivante — c'est ce qui a coûté trois relectures le 17/09.

| Quoi | Compte | Détail |
|---|---|---|
| Murs | **15** | M-1 → M-15, §A ; **+ 1 règle de code** R-1, hors des quinze |
| Référentiels | ⭐ **64 au 23/09** (57 métier en §B + 7 techniques) ⚠️ **+24 le 23/09** : relevé complet des réglages Boond, tout est repris en V1 (secteur, métier, certification, expérience, formation, langue, niveau, disponibilité candidat, situation familiale, contrat ×4, temps de travail, document suivi, catégorie d'achat, calendrier, TVA, conditions et modes de règlement, envoi de facture, états facture / facture fournisseur / devis, type de message). ⛔ La migration qui les crée reste à écrire. Avant : **40 au 21/09** | ⭐ **+3 le 21/09 (D-9, migration 007)** : `ref_statut_contact`, `ref_type_coordonnee`, `ref_usage_coordonnee` — trois listes figées en CHECK (V-021). ⭐ **33 lignes en §B** (métier) **+ 7 techniques** ; mesuré en base : `select count(*) from pg_tables where schemaname='ava' and tablename like 'ref\_%'` = 40. Avant : **37 au 20/09**, ⭐ **27 métier** (§B, un par ligne — ⛔ *`ref_theme` était cité ici par erreur : il n'y a pas de table `ref_theme`, un thème est un **code texte** porté par `ui.theme`. Retiré le 20/09, signalé par le lot 1* ; `ref_unite_couverture`, `ref_motif_avenant`, `ref_motif_interruption`, `ref_motif_fin_emploi`, `ref_type_modele`, `ref_portee_modele` et `ref_gravite_alerte` le 19/09) **+ 7 techniques** : `ref_civilite`, `ref_pays`, `ref_type_unite`, `ref_type_contact`, `ref_type_mission`, `ref_type_document`, `ref_disponibilite` |
| Politiques | ⭐ **192 au 24/09** (191 en tableau + 1 en prose) ⚠️ **+19 le 23-24/09** (§C.bis) : relevé complet des réglages Boond et réponses d'Avaliance — coût salarié, périmètre de société, blacklist, données RH, facturation ×4, contrat RH, documents, signature des temps, rapports d'alerte ×4, widgets du tableau de bord, actions multiples, tri des listes. ⛔ La migration qui les sème reste à écrire. Avant : **173 au 20/09** | §C — **172 en tableau + 1 déclarée en prose** (mesuré le 21/09, V-029 — le « 168 » précédent était un compte retenu). ⭐ **+2 le 20/09, annoncés comme l'exige le gel** :
`societe.archivage.garde` et `absence.chevauchement`, toutes deux **citées dans L4** et
**absentes du registre** — trou de ma spécification, comblé par le codeur du lot 2, qui a écrit
leur source dans la table (`L4 L82`, `L4 L163`). ⭐ **C'est exactement ce qu'on attend de lui** (`ui.theme.personnalise`). ⚠️ *La répartition « 79 métier · 2 installation · 86 apparence » (= 167) date d'avant le 20/09 et ne tient plus (V-062, 22/09) : **seul le total 173 est mesuré**, en base et par la commande ci-dessous.* ⭐ **+5 le 19/09** : les **quatre encres**, avec le garde-fou — une encre choisie qui ne passe pas 4,5:1 sur sa surface est **relevée**, jamais posée telle quelle — et le rôle du banc d'essai |
| Tables du livrable 5 | **36** + `reprise_boond` | `prestation_version` (B-2) et `periode_emploi` (M15) ajoutées le 19/09 —  carte au livrable §1 |

⭐ **Portée de « seule source »** : les comptes **qui bougent** — tables, référentiels, politiques. « **15 murs** » et « 6 cycles » sont des **décisions** (P3, machines), pas des comptes : ils s'écrivent partout où on en a besoin.

⛔ **Gel (17/09, 23h30)** : plus aucune politique ni référentiel ajouté sans l'annoncer en ligne 1 — chaque ajout relance tous les comptes.

⭐ **Ce que le 18/09 a appris** — le compte a bougé trois fois dans la journée : 79 annoncé, 77 mesuré, 78 avec `ui.epaisseur`, **82** après réconciliation avec le cahier des directeurs. Les quatre dernières (`doublon.contact.*`, `doublon.societe.*`) **existaient depuis le 17/09 dans le cahier** et nulle part ici. ⚠️ **Un compte ne se retient pas, il se mesure** — et il se mesure **contre l'autre document**, pas contre le souvenir qu'on en a :

```bash
# ⛔ V-029, 21/09 — l'ancienne commande (`grep -cE '^\| `…` \|'`) comptait
#    aussi les 33 référentiels du §B et ratait les lignes à deux clés : elle
#    rendait 202, pas 173. Celle-ci ne lit que la PREMIÈRE colonne du §C.
awk -F'|' '/^## C\./{c=1} /^## D\./{c=0} c && /^\| `/ {print $2}' _ops/REGISTRE_POLITIQUES_v1.md \
  | tr -d '\r' | grep -oE '`[a-z0-9_.]+`' | sort -u | wc -l     # 172 en tableau, + 1 en prose (ui.theme.personnalise) = 173
# ⭐ Et contre la base — la seule mesure qui départage :
psql -h 127.0.0.1 -U postgres -d ava -Atc "select count(*) from ava.politique"   # 173
```
