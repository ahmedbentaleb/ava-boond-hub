# Registre exécutable — le lot 2 (D-56, 01/10/2026)

> **Hamada, 29/09 :** « je ne veux pas de compromis, je veux un truc qui marche dès le départ ».
> **Arbitrage du 10e audit (D-56) :** la colonne « Effet » du registre est une phrase ; le codeur l'a
> interprétée, ses portes ont gravé son interprétation. Ce fichier la remplace par une donnée.

<quand_utiliser>

| ✅ On ouvre ce fichier | ⛔ On ne l'ouvre pas pour |
|---|---|
| Savoir **exactement** ce que fait une valeur de politique, dans quelle commande, dans quelle situation | la liste et le défaut des politiques → `REGISTRE_POLITIQUES_v1.md` (il reste la source des clés et des défauts) |
| Générer les cas de la porte des politiques, `COMPORTEMENTS`, `politique_valeur_servie` | le contrat des commandes → `SPEC_COMMANDES_L4.md` |

</quand_utiliser>

<procedure>

## 0 · La forme — lisible par un script

Une ligne de cas = `| clé | valeur | commande | scénario | issue |`, dans les tableaux du §2. Un script lit
toutes les lignes dont la première cellule est une clé entre accents graves.

**Le scénario** est un identifiant (`S-…`) défini sous le tableau de sa clé : l'état de départ et l'appel,
assez précis pour être écrit en fixture sans rien inventer. Agences : **PAR** (celle du demandeur) et **LYO**
(une autre). Sauf mention, le demandeur a la permission de la commande sur PAR, et la date du jour est celle de
la base (V-167) au **15/10/2026**.

**L'issue** suit cette grammaire, et rien d'autre :

| Forme | Sens |
|---|---|
| `ok` | la commande réussit |
| `ok · écrit T.c = v` | et la colonne `c` de la table `T` vaut `v` après (plusieurs : séparées par ` ; `) |
| `ok · inchangé T.c` | et cette colonne n'a pas bougé |
| `ok · aucune ligne T` | et aucune ligne n'est écrite dans `T` |
| `ok · alerte CODE` | et l'alerte `CODE` est rendue ; `ok · sans alerte` : aucune alerte |
| `ok · événement Nom` | et l'événement `Nom` est écrit |
| `refus GARDE` · `refus ETAT` · `refus DROIT` · `refus INTROUVABLE` | refusée avec ce code, **rien écrit** |
| `lu T.c = v` | une **lecture** (vue, D-53) rend `v` |

Une **catégorie** se note `cat:prospect` (on ne juge jamais un code, D-57).

## 1 · Les règles qui en dérivent

| # | Règle |
|---|---|
| 1 | ⭐ **Une valeur est servie si et seulement si elle a au moins une ligne ici.** `COMPORTEMENTS`, `politique_valeur_servie` et `POLITIQUE_COMMANDES` se **génèrent** de ce fichier ; ils ne s'écrivent plus à la main |
| 2 | **Une clé absente de ce fichier n'a que son défaut servi** : `SetPolicy` refuse toute autre valeur (`GARDE` « valeur non servie avant son lot »). Elle entre ici avec le lot qui sert sa commande |
| 3 | **La porte différentielle** joue chaque scénario sous chaque valeur servie de sa clé et compare à l'issue écrite. Deux valeurs à l'issue identique **sur tous** les scénarios de la clé → rouge, sauf ligne au §3 « Alias » |
| 4 | **Les politiques liste** déclarent leur **domaine** (§2) ; un élément hors domaine → `SetPolicy` `refus GARDE` |
| 5 | **Les politiques nombre** déclarent leurs bornes ; hors bornes → `refus GARDE` |
| 6 | Une valeur qui exige une **donnée** (un taux, un motif de dérogation) la déclare dans `DECLARATION` (D-45) ; l'issue sans la donnée est écrite ici |
| 7 | ⛔ Une porte qui exige une issue **différente** de ce fichier est fausse, même verte (V-164) |

</procedure>

<etat>

## 2 · Les 56 clés lues par une commande du lot 2

### Société, contact, personne

| clé | valeur | commande | scénario | issue |
|---|---|---|---|---|
| `doublon.societe.mode` | avertir | CreateCompany | S-DS1 | ok · alerte DOUBLON · écrit societe.nom = Acme SA |
| `doublon.societe.mode` | bloquer | CreateCompany | S-DS1 | refus GARDE |
| `doublon.societe.mode` | ignorer | CreateCompany | S-DS1 | ok · sans alerte · écrit societe.nom = Acme SA |
| `doublon.societe.cles` | [nom_normalise, siren] | CreateCompany | S-DS2 | refus GARDE |
| `doublon.societe.cles` | [siren] | CreateCompany | S-DS2 | ok · sans alerte |
| `doublon.societe.cles` | [nom_normalise] | CreateCompany | S-DS3 | ok · sans alerte |
| `doublon.societe.cles` | [nom_normalise, siren] | CreateCompany | S-DS3 | refus GARDE |

- **S-DS1** — une société « ACME » (nom normalisé `acme`, SIREN 111) existe à PAR ; `CreateCompany` nom « Acme SA »… normalisé `acme`, sans SIREN. Clés au défaut.
- **S-DS2** — `doublon.societe.mode = bloquer` ; société « ACME » SIREN 111 existe ; `CreateCompany` nom « Acme », SIREN 222.
- **S-DS3** — `bloquer` ; société « Durand » SIREN 333 existe ; `CreateCompany` nom « Martin », SIREN 333.
- **Domaine** de `doublon.societe.cles` : `nom_normalise`, `siren`. `["telephone"]` → `SetPolicy` refus GARDE.

| clé | valeur | commande | scénario | issue |
|---|---|---|---|---|
| `societe.retour_prospect` | manuel | ClosePrestation | S-RP1 | ok · inchangé societe.statut (cat:client) |
| `societe.retour_prospect` | auto_fin_dernier_contrat | ClosePrestation | S-RP1 | ok · écrit societe.statut = cat:prospect · événement ClientStatusDerived |
| `societe.retour_prospect` | auto_apres_delai | ClosePrestation | S-RP1 | ok · inchangé societe.statut (cat:client) |
| `societe.retour_prospect` | jamais_ancien_client | ClosePrestation | S-RP1 | ok · écrit societe.statut = cat:ancien_client · événement ClientStatusDerived |
| `societe.retour_prospect` | auto_fin_dernier_contrat | CancelPrestation | S-RP2 | ok · écrit societe.statut = cat:prospect |
| `societe.retour_prospect` | manuel | CancelPrestation | S-RP2 | ok · inchangé societe.statut (cat:client) |
| `societe.retour_prospect` | auto_apres_delai | (lecture) | S-RP3 | lu v_societe_statut.statut = cat:prospect |
| `societe.retour_prospect` | manuel | (lecture) | S-RP3 | lu v_societe_statut.statut = cat:client |
| `societe.retour_prospect` | manuel | RequalifyCompany | S-RP4 | ok · écrit societe.statut = cat:prospect |
| `societe.retour_prospect` | jamais_ancien_client | RequalifyCompany | S-RP4 | refus GARDE |

- **S-RP1** — société cliente (cat:client), **une seule** prestation `engage`, à PAR ; `ClosePrestation` de celle-ci.
- **S-RP2** — idem, `CancelPrestation` de la seule prestation `engage`.
- **S-RP3** — société cliente dont la dernière prestation `engage` a fini il y a 7 mois ; `societe.retour_prospect.delai_mois = 6` ; on lit la vue.
- **S-RP4** — société cliente sans prestation ; `RequalifyCompany` vers un statut de catégorie `prospect`.

| clé | valeur | commande | scénario | issue |
|---|---|---|---|---|
| `societe.archivage.garde` | aucun_objet_actif | ArchiveCompany | S-AC1 | refus GARDE |
| `societe.archivage.garde` | libre | ArchiveCompany | S-AC1 | ok · écrit societe.archive_le = aujourd'hui |
| `service.archivage.garde` | aucun_besoin_ni_projet_actif | ArchiveService | S-AS1 | refus GARDE |
| `service.archivage.garde` | libre | ArchiveService | S-AS1 | ok · écrit unite_organisation.archive_le = aujourd'hui |

- **S-AC1** — société à PAR avec un besoin `en_recherche` ; `ArchiveCompany` avec motif.
- **S-AS1** — unité « Achats » d'une société de PAR, porteuse d'un projet ouvert ; `ArchiveService` avec motif.

| clé | valeur | commande | scénario | issue |
|---|---|---|---|---|
| `doublon.contact.mode` | avertir | CreateContact | S-DC1 | ok · alerte DOUBLON |
| `doublon.contact.mode` | bloquer | CreateContact | S-DC1 | refus GARDE |
| `doublon.contact.mode` | ignorer | CreateContact | S-DC1 | ok · sans alerte |
| `doublon.contact.cles` | [email, nom+prenom+societe] | CreateContact | S-DC2 | ok · sans alerte |
| `doublon.contact.cles` | [email_ou_telephone, nom+prenom+societe] | CreateContact | S-DC2 | refus GARDE |
| `contact.transfert.objets_actifs` | reaffectation_obligatoire | TransferContact | S-TC1 | refus GARDE |
| `contact.transfert.objets_actifs` | conserver_liens | TransferContact | S-TC1 | ok · inchangé besoin.contact_id |
| `contact.transfert.objets_actifs` | reaffectation_obligatoire | TransferContact | S-TC2 | ok · écrit besoin.contact_id = contact B |

- **S-DC1** — un contact « Lea Morel » `lea@acme.fr` existe chez Acme ; `CreateContact` même e-mail, autre nom, même société.
- **S-DC2** — `doublon.contact.mode = bloquer` ; contact `lea@acme.fr`, tél. 0611 existe chez Acme ; `CreateContact` « Paul Roy », `paul@acme.fr`, tél. 0611, chez Acme.
- **S-TC1** — contact A, porteur d'un besoin `en_recherche`, transféré vers une autre société de PAR, **sans** `reaffecter_a`.
- **S-TC2** — idem, avec `reaffecter_a` = contact B (même société d'origine).
- **Domaine** de `doublon.contact.cles` : `email`, `telephone`, `email_ou_telephone`, `nom+prenom+societe`.

| clé | valeur | commande | scénario | issue |
|---|---|---|---|---|
| `doublon.personne.mode` | avertir | CreatePerson | S-DP1 | ok · alerte DOUBLON |
| `doublon.personne.mode` | bloquer | CreatePerson | S-DP1 | refus GARDE |
| `doublon.personne.mode` | ignorer | CreatePerson | S-DP1 | ok · sans alerte |
| `doublon.personne.cles` | [email, nom+prenom+naissance] | CreatePerson | S-DP2 | refus GARDE |
| `doublon.personne.cles` | [email] | CreatePerson | S-DP2 | ok · sans alerte |

- **S-DP1** — une personne `sara@mail.fr` existe ; `CreatePerson` même e-mail, autre nom.
- **S-DP2** — `bloquer` ; personne « Sara Ali », née le 02/03/1990, `sara@mail.fr` ; `CreatePerson` « Sara Ali », 02/03/1990, `s.ali@autre.fr`.
- **Domaine** de `doublon.personne.cles` : `email`, `telephone`, `nom+prenom+naissance`. ⛔ `score_pondere` **retiré** (D-61) : il exigeait des poids et un seuil que rien ne règle — du métier en dur ; une liste de clés couvre le besoin.

### Candidat, ressource, qualification

| clé | valeur | commande | scénario | issue |
|---|---|---|---|---|
| `candidat.complete.champs_requis` | [nom, prenom, civilite, localisation, email_ou_telephone] | CompleteCandidate | S-CC1 | refus GARDE |
| `candidat.complete.champs_requis` | [nom, prenom, localisation, email_ou_telephone] | CompleteCandidate | S-CC1 | ok · écrit profil_candidat.etape = cat:complet |
| `candidat.conversion.acteur` | groupe_rh | ConvertCandidateToResource | S-CV1 | refus DROIT |
| `candidat.conversion.acteur` | groupe_rh_ou_rr | ConvertCandidateToResource | S-CV1 | ok · écrit profil_ressource.personne_id = la personne |
| `candidat.conversion.acteur` | tout_habilite | ConvertCandidateToResource | S-CV1 | ok |
| `candidat.conversion.acteur` | groupe_rh_ou_rr | ConvertCandidateToResource | S-CV2 | refus DROIT |
| `candidat.conversion.acteur` | tout_habilite | ConvertCandidateToResource | S-CV2 | ok |
| `candidat.note.echelle` | 1_5 | UpdateCandidate | S-NE1 | refus GARDE |
| `candidat.note.echelle` | 1_10 | UpdateCandidate | S-NE1 | ok · écrit profil_candidat.note = 7 |
| `candidat.note.echelle` | 1_100 | UpdateCandidate | S-NE1 | ok · écrit profil_candidat.note = 7 |
| `candidat.note.echelle` | aucune | UpdateCandidate | S-NE1 | refus GARDE |
| `candidat.note.echelle` | 1_10 | UpdateCandidate | S-NE2 | refus GARDE |
| `candidat.note.echelle` | 1_100 | UpdateCandidate | S-NE2 | ok · écrit profil_candidat.note = 50 |
| `candidat.note.echelle` | 1_5 | UpdateCandidate | S-NE3 | ok · écrit profil_candidat.note = 3 |
| `candidat.note.echelle` | aucune | UpdateCandidate | S-NE3 | refus GARDE |
| `ressource.externe.societe_fournisseur` | obligatoire | CreateResource | S-RF1 | refus GARDE |
| `ressource.externe.societe_fournisseur` | facultatif | CreateResource | S-RF1 | ok |
| `ressource.externe.societe_fournisseur` | obligatoire | ConvertCandidateToResource | S-RF2 | refus GARDE |
| `ressource.externe.societe_fournisseur` | facultatif | ConvertCandidateToResource | S-RF2 | ok |

- **S-CC1** — candidat de PAR : nom, prénom, localisation, e-mail remplis ; **civilité vide**.
- **S-CV1** — le demandeur est du groupe **RR**, la permission lui est déléguée sur PAR ; candidat de PAR.
- **S-CV2** — le demandeur est du groupe **IA**, la permission lui est déléguée sur PAR.
- **S-NE1** — `UpdateCandidate` note = 7 ; **S-NE2** — note = 50 ; **S-NE3** — note = 3 (sépare `1_5` de `aucune`, Q-024).
- **S-RF1** — `CreateResource` type externe, sans société fournisseur ; **S-RF2** — conversion vers une ressource externe, sans société fournisseur.
- **Domaine** de `candidat.complete.champs_requis` : `nom`, `prenom`, `civilite`, `localisation`, `email`, `telephone`, `email_ou_telephone`, `date_naissance`, `cv`.

| clé | valeur | commande | scénario | issue |
|---|---|---|---|---|
| `ressource.etat.mode` | manuel | SetResourceState | S-RE1 | ok · écrit profil_ressource.etat = cat:disponible |
| `ressource.etat.mode` | derive_des_prestations | SetResourceState | S-RE1 | refus GARDE |
| `ressource.etat.mode` | derive_avec_exceptions_tracees | SetResourceState | S-RE1 | refus GARDE |
| `ressource.etat.mode` | derive_avec_exceptions_tracees | SetResourceState | S-RE2 | ok · écrit profil_ressource.etat_exception_code = cat:disponible ; profil_ressource.etat_exception_jusquau = 31/10/2026 |
| `ressource.etat.mode` | derive_avec_exceptions_tracees | (lecture) | S-RE3 | lu v_ressource_etat.etat = cat:disponible |
| `ressource.etat.mode` | derive_avec_exceptions_tracees | (lecture) | S-RE4 | lu v_ressource_etat.etat = cat:en_mission |
| `ressource.etat.mode` | derive_des_prestations | (lecture) | S-RE5 | lu v_ressource_etat.etat = cat:en_mission |
| `ressource.etat.mode` | manuel | (lecture) | S-RE5 | lu v_ressource_etat.etat = cat:disponible |
| `ressource.etat.mode` | derive_des_prestations | SetResourceState | S-RE6 | ok · écrit profil_ressource.etat = cat:sorti |

- **S-RE1** — ressource de PAR, une prestation `engage` couvre le 15/10/2026 ; `SetResourceState` → disponible, **sans** motif.
- **S-RE2** — idem, avec motif « congé sabbatique » et date de fin 31/10/2026.
- **S-RE3** — après S-RE2, lecture le 15/10 ; **S-RE4** — après S-RE2, lecture le 01/11 (l'exception est échue).
- **S-RE5** — ressource dont l'état écrit est `disponible`, une prestation `engage` couvre aujourd'hui ; lecture.
- **S-RE6** — `SetResourceState` → sorti (permis sous tous les modes).

| clé | valeur | commande | scénario | issue |
|---|---|---|---|---|
| `qualification.besoin_obligatoire` | oui | RecordQualification | S-QB1 | refus GARDE |
| `qualification.besoin_obligatoire` | non | RecordQualification | S-QB1 | ok · écrit qualification.besoin_id = NULL |

- **S-QB1** — `RecordQualification` d'un candidat de PAR, sans `besoin_id`.

### Besoin et positionnement

| clé | valeur | commande | scénario | issue |
|---|---|---|---|---|
| `besoin.unite_couverture` | postes | CreateNeed | S-UC1 | ok · écrit besoin.unite_couverture_code = postes |
| `besoin.unite_couverture` | fte | CreateNeed | S-UC1 | ok · écrit besoin.unite_couverture_code = fte |
| `besoin.unite_couverture` | postes_et_fte | CreateNeed | S-UC1 | ok · écrit besoin.unite_couverture_code = postes_et_fte |
| `besoin.contact` | facultatif | CreateNeed | S-BC1 | ok |
| `besoin.contact` | obligatoire | CreateNeed | S-BC1 | refus GARDE |

- **S-UC1** — `CreateNeed` sans unité de couverture dans l'entrée. ⭐ La politique donne le **défaut du besoin** ; chaque besoin garde la sienne (colonne), lue par la couverture (S-PG3).
- **S-BC1** — `CreateNeed` sur une société de PAR, sans contact.

| clé | valeur | commande | scénario | issue |
|---|---|---|---|---|
| `besoin.staffing.declencheur` | premier_positionnement | PositionCandidate | S-SD1 | ok · écrit besoin.etat = cat:en_recherche |
| `besoin.staffing.declencheur` | commande_prise_en_charge | PositionCandidate | S-SD1 | ok · inchangé besoin.etat (cat:a_pourvoir) |
| `besoin.staffing.declencheur` | retour_client_retenu | PositionCandidate | S-SD1 | ok · inchangé besoin.etat (cat:a_pourvoir) |
| `besoin.staffing.declencheur` | commande_prise_en_charge | TakeNeedInCharge | S-SD2 | ok · écrit besoin.etat = cat:en_recherche |
| `besoin.staffing.declencheur` | premier_positionnement | TakeNeedInCharge | S-SD2 | ok · inchangé besoin.etat (cat:a_pourvoir) |
| `besoin.staffing.declencheur` | retour_client_retenu | RecordClientDecision | S-SD3 | ok · écrit besoin.etat = cat:en_recherche |
| `besoin.staffing.declencheur` | commande_prise_en_charge | RecordClientDecision | S-SD3 | ok · inchangé besoin.etat (cat:a_pourvoir) |

- **S-SD1** — besoin de PAR `a_pourvoir`, sans positionnement ; `PositionCandidate` d'un candidat de PAR.
- **S-SD2** — besoin de PAR `a_pourvoir` ; `TakeNeedInCharge` par le demandeur.
- **S-SD3** — besoin de PAR `a_pourvoir` avec un positionnement `presente` ; `RecordClientDecision` d'une décision de catégorie `positive`.

| clé | valeur | commande | scénario | issue |
|---|---|---|---|---|
| `besoin.pourvu.garde_minimale` | tous_les_postes_signes | DeclareNeedFilled | S-PG1 | refus GARDE |
| `besoin.pourvu.garde_minimale` | une_prestation_signee | DeclareNeedFilled | S-PG1 | ok · écrit besoin.etat = cat:pourvu |
| `besoin.pourvu.garde_minimale` | aucune | DeclareNeedFilled | S-PG1 | ok · écrit besoin.etat = cat:pourvu |
| `besoin.pourvu.garde_minimale` | une_prestation_signee | DeclareNeedFilled | S-PG2 | refus GARDE |
| `besoin.pourvu.garde_minimale` | aucune | DeclareNeedFilled | S-PG2 | ok · écrit besoin.etat = cat:pourvu |
| `besoin.pourvu.garde_minimale` | tous_les_postes_signes | DeclareNeedFilled | S-PG3 | ok · écrit besoin.etat = cat:pourvu |
| `besoin.pourvu.garde_minimale` | tous_les_postes_signes | DeclareNeedFilled | S-PG4 | refus GARDE |

- **S-PG1** — besoin de PAR, 2 postes (unité `postes`), **1** prestation `engage` rattachée.
- **S-PG2** — besoin de PAR, 2 postes, **aucune** prestation `engage`.
- **S-PG3** — besoin, unité `postes`, 1 poste, fte visé 1,0 ; une prestation `engage` à 50 % : couverture **atteinte** (1 poste / 1).
- **S-PG4** — idem, unité **`fte`** : couverture **non atteinte** (0,5 / 1,0).
- ⭐ « tous les postes signés » = **couverture atteinte selon l'unité du besoin** (postes, fte, ou les deux).

| clé | valeur | commande | scénario | issue |
|---|---|---|---|---|
| `besoin.pourvu.mode` | manuel_avec_garde | SignPrestation | S-PM1 | ok · inchangé besoin.etat (cat:en_recherche) |
| `besoin.pourvu.mode` | auto_par_prestation_signee | SignPrestation | S-PM1 | ok · inchangé besoin.etat (cat:en_recherche) |
| `besoin.pourvu.mode` | auto_par_personne_signee | SignPrestation | S-PM1 | ok · écrit besoin.etat = cat:pourvu · événement NeedFilled |
| `besoin.pourvu.mode` | auto_propose_confirme | SignPrestation | S-PM1 | ok · inchangé besoin.etat · sans alerte |
| `besoin.pourvu.mode` | auto_par_prestation_signee | SignPrestation | S-PM2 | ok · écrit besoin.etat = cat:pourvu · événement NeedFilled |
| `besoin.pourvu.mode` | auto_propose_confirme | SignPrestation | S-PM2 | ok · inchangé besoin.etat · alerte BESOIN_A_DECLARER_POURVU |
| `besoin.pourvu.mode` | manuel_avec_garde | SignPrestation | S-PM2 | ok · inchangé besoin.etat (cat:en_recherche) |
| `besoin.pourvu.mode` | auto_par_personne_signee | DeclareNeedFilled | S-PM3 | refus GARDE |
| `besoin.pourvu.mode` | auto_propose_confirme | DeclareNeedFilled | S-PM3 | refus GARDE |

- **S-PM1** — besoin de PAR `en_recherche`, 2 postes ; une prestation `proposee` rattachée, aucune `engage` ; `SignPrestation` de celle-ci (1 / 2).
- **S-PM2** — idem, une prestation déjà `engage` ; on signe la seconde (2 / 2).
- **S-PM3** — besoin, 2 postes, 1 prestation `engage` ; `DeclareNeedFilled` **appelé directement** : ⛔ la garde minimale (au défaut) s'applique sous **tous** les modes (V-162 ③).

| clé | valeur | commande | scénario | issue |
|---|---|---|---|---|
| `positionnement.sur_besoin_inactif` | refus | PositionCandidate | S-BI1 | refus GARDE |
| `positionnement.sur_besoin_inactif` | alerte | PositionCandidate | S-BI1 | ok · alerte BESOIN_INACTIF |
| `positionnement.sur_besoin_inactif` | libre | PositionCandidate | S-BI1 | ok · sans alerte |
| `positionnement.unicite` | actifs | PositionCandidate | S-PU1 | refus GARDE |
| `positionnement.unicite` | aucune | PositionCandidate | S-PU1 | ok |
| `positionnement.unicite` | historique | PositionCandidate | S-PU1 | refus GARDE |
| `positionnement.unicite` | actifs | PositionCandidate | S-PU2 | ok |
| `positionnement.unicite` | historique | PositionCandidate | S-PU2 | refus GARDE |
| `positionnement.cv_partage_obligatoire` | oui | RecordClientDecision | S-CP1 | refus ETAT |
| `positionnement.cv_partage_obligatoire` | non | RecordClientDecision | S-CP1 | ok · écrit positionnement.etat = cat:terminal_positif |
| `positionnement.qualification_requise_avant_decision` | non | RecordClientDecision | S-QR1 | ok |
| `positionnement.qualification_requise_avant_decision` | oui | RecordClientDecision | S-QR1 | refus GARDE |

- **S-BI1** — besoin de PAR `suspendu` ; `PositionCandidate` d'un candidat de PAR.
- **S-PU1** — le candidat a déjà un positionnement **actif** sur ce besoin ; on le repositionne.
- **S-PU2** — le candidat a un positionnement **terminé** (retiré) sur ce besoin ; on le repositionne.
- **S-CP1** — positionnement `propose` (CV jamais partagé) ; décision de catégorie `positive`.
- **S-QR1** — positionnement `presente`, sans aucune qualification du candidat ; décision `positive`.

### Projet

| clé | valeur | commande | scénario | issue |
|---|---|---|---|---|
| `projet.creation_depuis_besoin` | explicite | RecordClientDecision | S-CB1 | ok · aucune ligne projet |
| `projet.creation_depuis_besoin` | automatique_au_retenu | RecordClientDecision | S-CB1 | ok · écrit projet.besoin_id = le besoin · événement ProjectCreatedFromNeed |
| `projet.contact` | obligatoire | CreateProject | S-PC1 | refus GARDE |
| `projet.contact` | facultatif | CreateProject | S-PC1 | ok · écrit projet.contact_id = NULL |
| `projet.contact` | obligatoire_avant_engagement | CreateProject | S-PC1 | ok · écrit projet.contact_id = NULL |
| `projet.contact` | service_ou_societe | CreateProject | S-PC1 | ok · écrit projet.contact_id = NULL |
| `projet.contact` | facultatif | SignPrestation | S-PC2 | ok |
| `projet.contact` | obligatoire_avant_engagement | SignPrestation | S-PC2 | refus GARDE |
| `projet.contact` | service_ou_societe | CreateProjectFromNeed | S-PC3 | refus GARDE |
| `projet.contact` | facultatif | CreateProjectFromNeed | S-PC3 | ok |
| `projet.contact` | service_ou_societe | CreateProjectFromNeed | S-PC4 | ok · écrit projet.unite_organisation_id = l'unité donnée |
| `projet.contact` | obligatoire | CreateProjectFromNeed | S-PC4 | refus GARDE |
| `projet.origine_besoin` | facultative | CreateProject | S-PO1 | ok · écrit projet.besoin_id = NULL |
| `projet.origine_besoin` | obligatoire | CreateProject | S-PO1 | refus GARDE |
| `besoin.projets_max` | illimite | CreateProjectFromNeed | S-PX1 | ok |
| `besoin.projets_max` | un_seul | CreateProjectFromNeed | S-PX1 | refus GARDE |
| `projet.depuis_besoin.garde` | retenu_requis | CreateProjectFromNeed | S-DG1 | refus GARDE |
| `projet.depuis_besoin.garde` | libre | CreateProjectFromNeed | S-DG1 | ok |
| `projet.depuis_besoin.garde_profil` | personne_avec_ressource | CreateProjectFromNeed | S-GP1 | ok |
| `projet.depuis_besoin.garde_profil` | positionnement_ressource_strict | CreateProjectFromNeed | S-GP1 | refus GARDE |
| `projet.cloture.garde` | prestations_closes | CloseProject | S-PCL1 | refus GARDE |
| `projet.cloture.garde` | cascade_cloture_prestations | CloseProject | S-PCL1 | ok · écrit prestation.etat = cat:clos (la prestation ouverte, à la date de clôture du projet) ; inchangé prestation.etat (la prestation déjà close) |

- **S-CB1** — positionnement `presente` d'un besoin de PAR ; décision de catégorie `positive`.
- **S-PC1** — `CreateProject` sur une société de PAR, sans contact ni unité.
- **S-PC2** — projet sans contact ; `SignPrestation` de sa première prestation.
- **S-PC3** — `CreateProjectFromNeed` d'un besoin d'origine **régie**, sans contact.
- **S-PC4** — `CreateProjectFromNeed` d'un besoin d'origine **appel d'offres**, sans contact, avec une unité donnée.
- ⭐ `service_ou_societe` (R10) : contact **obligatoire en régie**, **facultatif en appel d'offres**, où l'interlocuteur est l'unité donnée ou, à défaut, la société entière.
- **S-PO1** — `CreateProject` sans besoin d'origine.
- **S-PX1** — le besoin a déjà un projet ; `CreateProjectFromNeed` d'un second.
- **S-DG1** — besoin sans positionnement `terminal_positif` ; `CreateProjectFromNeed`.
- **S-GP1** — le positionnement retenu est celui d'un **candidat**, dont la personne a aussi un profil ressource à PAR.
- **S-PCL1** — projet de PAR avec une prestation `engage` qui finit le 31/12/2026 et une prestation déjà `clos` ; `CloseProject` au 15/10/2026. ⛔ La prestation déjà close ne fait pas tomber la cascade (V-162 ⑤).

### Prestation et société cliente

| clé | valeur | commande | scénario | issue |
|---|---|---|---|---|
| `prestation.avenant.mode` | nouvelle_prestation | SignPrestation | S-AV1 | ok · aucune ligne prestation_version |
| `prestation.avenant.mode` | version_datee | SignPrestation | S-AV1 | ok · écrit prestation_version.version = 1 |
| `societe.passage_client.declencheur` | premiere_prestation_signee | SignPrestation | S-PCD1 | ok · écrit societe.statut = cat:client · événement ClientStatusDerived |
| `societe.passage_client.declencheur` | premier_engagement_contractuel | SignPrestation | S-PCD1 | ok · écrit societe.statut = cat:client · événement ClientStatusDerived |
| `societe.passage_client.declencheur` | manuel | SignPrestation | S-PCD1 | ok · inchangé societe.statut (cat:prospect) |
| `societe.passage_client.declencheur` | creation_projet | SignPrestation | S-PCD1 | ok · inchangé societe.statut (cat:prospect) |
| `societe.passage_client.declencheur` | creation_projet | CreateProject | S-PCD2 | ok · écrit societe.statut = cat:client · événement ClientStatusDerived |
| `societe.passage_client.declencheur` | premiere_prestation_signee | CreateProject | S-PCD2 | ok · inchangé societe.statut (cat:prospect) |
| `societe.passage_client.declencheur` | creation_projet | CreateProjectFromNeed | S-PCD3 | ok · écrit societe.statut = cat:client |
| `societe.passage_client.propagation` | branche_contractante_et_contacts_du_service | SignPrestation | S-PR1 | ok · écrit unite_organisation.statut (U1) = cat:client ; contact.statut (contacts de U1) = cat:client ; inchangé unite_organisation.statut (U2) |
| `societe.passage_client.propagation` | societe_seule | SignPrestation | S-PR1 | ok · écrit societe.statut = cat:client ; inchangé unite_organisation.statut (U1) |
| `societe.passage_client.propagation` | toute_la_societe | SignPrestation | S-PR1 | ok · écrit unite_organisation.statut (U1, U2) = cat:client ; contact.statut (tous) = cat:client |

- **S-AV1** — prestation `proposee` d'un projet de PAR ; `SignPrestation`.
- **S-PCD1** — société **prospect** de PAR, projet ouvert, première prestation `proposee` ; `SignPrestation`.
- **S-PCD2** — société prospect ; `CreateProject` ; **S-PCD3** — idem par `CreateProjectFromNeed`.
- **S-PR1** — société prospect avec deux unités U1 (contractante du projet) et U2, un contact dans chacune ; première signature.

| clé | valeur | commande | scénario | issue |
|---|---|---|---|---|
| `projet.devises_mixtes` | autorise | CreatePrestation | S-DM1 | ok · écrit prestation.devise_code = USD |
| `projet.devises_mixtes` | refus | CreatePrestation | S-DM1 | refus GARDE |
| `prestation.surcharge.mode` | alerte | CreatePrestation | S-SU1 | ok · alerte SURCHARGE |
| `prestation.surcharge.mode` | refus | CreatePrestation | S-SU1 | refus GARDE |
| `prestation.surcharge.mode` | silencieux | CreatePrestation | S-SU1 | ok · sans alerte |
| `prestation.surcharge.seuil_pct` | 100 | CreatePrestation | S-SU2 | ok · alerte SURCHARGE |
| `prestation.surcharge.seuil_pct` | 200 | CreatePrestation | S-SU2 | ok · sans alerte |
| `prestation.annulation.garde` | aucun_temps_saisi | CancelPrestation | S-PA1 | refus GARDE |
| `prestation.annulation.garde` | libre | CancelPrestation | S-PA1 | ok · écrit prestation.etat = cat:annule |

- **S-DM1** — projet de PAR dont la première prestation est en EUR ; `CreatePrestation` en USD.
- **S-SU1** — ressource de PAR déjà `engage` à 100 % du 01/11 au 30/11 ; `CreatePrestation` à 50 % sur la même période ; seuil au défaut (100).
- **S-SU2** — idem, `prestation.surcharge.mode = alerte` ; occupation résultante 150 %.
- **Bornes** de `prestation.surcharge.seuil_pct` : entier de 50 à 300.
- **S-PA1** — prestation `engage` avec 3 jours de temps saisis ; `CancelPrestation` avec motif.

### Temps, clôture, marge

| clé | valeur | commande | scénario | issue |
|---|---|---|---|---|
| `temps.periode` | dates_prestation | RecordTimesheet | S-TP1 | ok |
| `temps.periode` | dates_prestation_et_mois_ouvert | RecordTimesheet | S-TP1 | ok |
| `temps.periode` | dates_prestation | RecordTimesheet | S-TP2 | refus GARDE |
| `temps.periode` | dates_prestation_et_mois_ouvert | RecordTimesheet | S-TP2 | refus GARDE |
| `temps.periode` | dates_prestation | RecordTimesheet | S-TP3 | ok |
| `temps.periode` | dates_prestation_et_mois_ouvert | RecordTimesheet | S-TP3 | refus GARDE |
| `temps.periode` | dates_prestation_et_mois_ouvert | RecordTimesheet | S-TP4 | ok |

- Prestation `engage` du 01/09/2026 au 31/12/2026, ressource de PAR.
- **S-TP1** — saisie au 14/10/2026 (aujourd'hui 15/10). **S-TP2** — saisie au 15/01/2027 (hors prestation). **S-TP3** — saisie au 10/09/2026 (mois clos). **S-TP4** — aujourd'hui **03/10/2026**, saisie au 30/09/2026.
- ⭐ **D-62 — le mois ouvert** : le mois courant, et le mois précédent jusqu'au jour `temps.mois_ouvert.grace_jours` (défaut **5**, entier 0 à 15 — politique nouvelle) du mois courant. ⛔ La valeur la plus stricte **ajoute** une garde, elle n'en retire jamais (V-162 ①). Au fuseau de l'agence de la prestation.

| clé | valeur | commande | scénario | issue |
|---|---|---|---|---|
| `temps.plafond_jour` | alerte | RecordTimesheet | S-PJ1 | ok · alerte PLAFOND_JOUR |
| `temps.plafond_jour` | refus | RecordTimesheet | S-PJ1 | refus GARDE |
| `temps.plafond_jour` | aucun | RecordTimesheet | S-PJ1 | ok · sans alerte |
| `temps.plafond_jour` | refus_avec_derogation_tracee | RecordTimesheet | S-PJ1 | refus GARDE |
| `temps.plafond_jour` | refus_avec_derogation_tracee | RecordTimesheet | S-PJ2 | ok · alerte PLAFOND_JOUR · écrit temps.derogation_motif = astreinte |
| `capacite.jour_ouvre` | 1.0 | RecordTimesheet | S-PJ3 | refus GARDE |
| `capacite.jour_ouvre` | 1.5 | RecordTimesheet | S-PJ3 | ok |
| `temps.facturable.mode` | egal_au_produit | RecordTimesheet | S-TF1 | ok · écrit temps.quantite_facturable = 1.0 |
| `temps.facturable.mode` | saisie_separee | RecordTimesheet | S-TF1 | refus GARDE |
| `temps.facturable.mode` | saisie_separee | RecordTimesheet | S-TF2 | ok · écrit temps.quantite = 1.0 ; temps.quantite_facturable = 0.5 |
| `temps.facturable.mode` | egal_au_produit | RecordTimesheet | S-TF2 | refus GARDE |
| `temps.validation` | aucune | RecordTimesheet | S-TV1 | ok · écrit temps.etat = cat:valide |
| `temps.validation` | par_dp | RecordTimesheet | S-TV1 | ok · écrit temps.etat = cat:a_valider |
| `temps.validation` | par_projet | RecordTimesheet | S-TV1 | ok · écrit temps.etat = cat:a_valider |
| `temps.validation` | par_projet | RecordTimesheet | S-TV2 | ok · écrit temps.etat = cat:valide |
| `temps.validation` | par_dp | AdjustTimesheetAfterClose | S-TV3 | ok · écrit temps.etat = cat:a_valider ; temps.ajustement = true |
| `temps.validation` | aucune | AdjustTimesheetAfterClose | S-TV3 | ok · écrit temps.etat = cat:valide ; temps.ajustement = true |
| `temps.correction_apres_cloture` | ajustement_trace | AdjustTimesheetAfterClose | S-TC3 | ok · écrit temps.ajustement = true ; inchangé snapshot_marge |
| `temps.correction_apres_cloture` | refus | AdjustTimesheetAfterClose | S-TC3 | refus GARDE |

- **S-PJ1** — la ressource a déjà 0,8 j saisi le 14/10 ; on saisit 0,5 j le même jour (1,3 > 1,0), sans motif de dérogation.
- **S-PJ2** — idem, avec `derogation_motif = astreinte` (clé déclarée, D-45).
- **S-PJ3** — `temps.plafond_jour = refus` ; 1,3 j le même jour.
- **Bornes** de `capacite.jour_ouvre` : décimal de 0,5 à 2,0.
- **S-TF1** — saisie de 1,0 j **sans** quantité facturable ; **S-TF2** — saisie de 1,0 j avec quantité facturable 0,5.
- **S-TV1** — saisie sur un projet dont `validation_temps = true` ; **S-TV2** — projet dont `validation_temps = false`.
- **S-TV3** / **S-TC3** — prestation `clos` ; `AdjustTimesheetAfterClose` d'un jour, avec motif.

| clé | valeur | commande | scénario | issue |
|---|---|---|---|---|
| `ca_produit.base` | temps_saisis | ClosePrestation | S-CA1 | ok · écrit snapshot_marge.ca = 5000 |
| `ca_produit.base` | temps_valides | ClosePrestation | S-CA1 | ok · écrit snapshot_marge.ca = 3000 |
| `frais.mode` | imputes_en_marge | ClosePrestation | S-FR1 | ok · écrit snapshot_marge.marge = 1800 |
| `frais.mode` | ignores | ClosePrestation | S-FR1 | ok · écrit snapshot_marge.marge = 2000 |
| `change.mode` | aucune_conversion | ClosePrestation | S-CH1 | ok · écrit snapshot_marge.marge = NULL ; snapshot_marge.motif_sans_marge = devises_mixtes |
| `change.mode` | taux_saisi | ClosePrestation | S-CH1 | refus GARDE |
| `change.mode` | taux_saisi | ClosePrestation | S-CH2 | ok · écrit snapshot_marge.marge = 1400 ; snapshot_marge.taux_change = 0.9 |
| `marge.taux.si_ca_nul` | tiret | ClosePrestation | S-MT1 | ok · écrit snapshot_marge.taux_marge = NULL |
| `marge.taux.si_ca_nul` | zero | ClosePrestation | S-MT1 | ok · écrit snapshot_marge.taux_marge = 0 |

- **S-CA1** — `temps.validation = par_dp` ; TJM 500 € ; 10 j saisis dont 6 `valide`. ⛔ `ca_produit.base = temps_valides` sous `temps.validation = aucune` → `SetPolicy` refus GARDE.
- **S-FR1** — CA 5 000 €, coût 3 000 €, frais rattachés 200 € (tout en EUR).
- **S-CH1** — vente en USD (CA 5 000 USD), coût en EUR (4 000 EUR), **sans** taux saisi. ⛔ Jamais `MUR` (V-169) : sous `aucune_conversion`, la marge n'est pas calculée et le dit.
- **S-CH2** — idem, `taux_change = 0.9` saisi sur la prestation (clé déclarée à `CreatePrestation`, D-45) : 1 EUR de coût = 0,9 USD ; marge = 5 000 − 4 000 × 0,9 = 1 400 USD. M-15 tient : le **taux** est écrit, jamais un montant converti.
- **S-MT1** — prestation close avec CA nul.

### Absence, thème, droits, traces

| clé | valeur | commande | scénario | issue |
|---|---|---|---|---|
| `absence.chevauchement` | refus | RecordAbsence | S-AB1 | refus GARDE |
| `absence.chevauchement` | alerte | RecordAbsence | S-AB1 | ok · alerte CHEVAUCHEMENT |
| `absence.chevauchement` | libre | RecordAbsence | S-AB1 | ok · sans alerte |
| `absence.sans_prestation` | autorisee | RecordAbsence | S-AB2 | ok |
| `absence.sans_prestation` | refusee | RecordAbsence | S-AB2 | refus GARDE |
| `ui.theme.choix_utilisateur` | oui | SetOwnTheme | S-UT1 | ok · écrit compte.theme_json = le thème donné |
| `ui.theme.choix_utilisateur` | non | SetOwnTheme | S-UT1 | refus GARDE |
| `droits.surcharge_restrictive` | restriction_gagne | UpdateNeed | S-DR1 | refus DROIT |
| `droits.surcharge_restrictive` | union_gagne | UpdateNeed | S-DR1 | ok |
| `historique.tentatives_refusees` | tracees_a_part | UpdateNeed | S-HT1 | refus DROIT · écrit tentative_refusee (1 ligne) |
| `historique.tentatives_refusees` | non_tracees | UpdateNeed | S-HT1 | refus DROIT · aucune ligne tentative_refusee |

- **S-AB1** — absence du 10 au 12/11 déjà saisie ; nouvelle du 12 au 14/11. **S-AB2** — absence d'une ressource sans prestation `engage` sur la période.
- **S-UT1** — `SetOwnTheme` d'un thème **servi**. ⛔ `SetOwnTheme` passe par la même garde de valeurs que `SetPolicy` : un thème non servi → refus GARDE sous les deux valeurs.
- **S-DR1** — le groupe du demandeur a `UpdateNeed` sur le périmètre agence PAR ; **une ligne `compte_surcharge`** (compte du demandeur, `UpdateNeed`, ce même périmètre) ; `UpdateNeed` d'un besoin de PAR. ⭐ Q-023 : `compte_surcharge` n'a **pas** de colonne de sens (`001_schema.sql`, F28) — **toute** ligne retire ; on n'en ajoute pas.
- **S-HT1** — compte sans `UpdateNeed` ; `UpdateNeed` d'un besoin de PAR.

### Périmètre

| clé | valeur | commande | scénario | issue |
|---|---|---|---|---|
| `societe.perimetre.mode` | agence_responsable | UpdateCompany | S-SP1 | refus DROIT |
| `societe.perimetre.mode` | par_besoins | UpdateCompany | S-SP1 | ok |
| `societe.perimetre.mode` | partagee | UpdateCompany | S-SP1 | ok |
| `societe.perimetre.mode` | par_besoins | UpdateCompany | S-SP2 | refus DROIT |
| `societe.perimetre.mode` | partagee | UpdateCompany | S-SP2 | ok |
| `societe.perimetre.mode` | par_besoins | UpdateCompany | S-SP3 | ok |
| `societe.perimetre.mode` | agence_responsable | UpdateCompany | S-SP3 | ok |
| `societe.perimetre.mode` | partagee | UpdateProject | S-SP4 | refus DROIT |
| `staffing.inter_agences` | non | PositionCandidate | S-SI1 | refus DROIT |
| `staffing.inter_agences` | oui | PositionCandidate | S-SI1 | ok · inchangé profil_candidat.agence_id (LYO) |
| `staffing.inter_agences` | oui | PositionCandidate | S-SI2 | refus DROIT |
| `staffing.inter_agences` | non | CreatePrestation | S-SI3 | refus DROIT |
| `staffing.inter_agences` | oui | CreatePrestation | S-SI3 | ok · inchangé profil_ressource.agence_id (LYO) |

- **S-SP1** — société de responsable **LYO**, avec un besoin de **PAR** ; le demandeur (PAR) la modifie.
- **S-SP2** — société de responsable LYO, **sans** besoin.
- **S-SP3** — société de responsable **PAR**, sans besoin (D-58 : l'agence responsable garde sa société sous `par_besoins`).
- **S-SP4** — projet de **LYO** ; `UpdateProject` avec un `contact_id` d'une société partagée : ⛔ la politique société ne juge que la société (D-44), le projet de LYO reste refusé.
- **S-SI1** — besoin de PAR, candidat de **LYO** ; `PositionCandidate` par PAR.
- **S-SI2** — besoin de **LYO**, candidat de PAR ; refusé sous les deux valeurs.
- **S-SI3** — projet de PAR, ressource de LYO ; `CreatePrestation`.

## 3 · Alias déclarés — deux valeurs qui font la même chose, et pourquoi

| clé | valeurs | sur quels scénarios | motif | jusqu'à |
|---|---|---|---|---|
| `societe.passage_client.declencheur` | premiere_prestation_signee = premier_engagement_contractuel | tous ceux du lot 2 | l'engagement contractuel d'avant la prestation (devis accepté) n'existe qu'au lot 5.8 | lot 5.8 : `AcceptQuote` passe client sous `premier_engagement_contractuel` seulement |

## 4 · Les décisions prises en écrivant ce fichier

| # | Décision |
|---|---|
| **D-61** | `doublon.personne.cles = score_pondere` est **retiré** du registre : des poids et un seuil non réglables seraient du métier en dur ; une liste de clés suffit |
| **D-62** | le **mois ouvert** de `temps.periode` : mois courant + mois précédent jusqu'au jour `temps.mois_ouvert.grace_jours` (**politique nouvelle**, défaut 5) ; ⛔ la valeur stricte ajoute une garde |
| **D-63** | `change.mode = taux_saisi` est **en V1** : un taux saisi sur la prestation (clé déclarée), la marge calculée avec ce taux, le taux écrit au snapshot ; `aucune_conversion` ne calcule pas la marge en devises mixtes et l'écrit — jamais `MUR` |
| **D-64** | `temps.plafond_jour = refus_avec_derogation_tracee` : un motif de dérogation (clé déclarée) lève le refus et s'écrit sur la ligne de temps (`temps.derogation_motif`) |
| **D-65** | « tous les postes signés » = couverture atteinte **selon l'unité du besoin** ; la garde minimale s'applique à `DeclareNeedFilled` direct sous tous les modes |
| **D-66** | `SetOwnTheme` passe par la garde de valeurs servies, comme `SetPolicy` |
| **D-67** | les **politiques liste** ont un domaine et les **politiques nombre** des bornes, écrits ici |

</etat>

<source>

Écrit par le BRAIN le 01/10/2026, après le 10e audit (`audits-independants/ava-audit-10/rapport/`, V-162, V-164).
Les 56 clés sont celles que lisent les commandes servies (`server/src/politiques.ts`, plus
`besoin.unite_couverture`, `societe.perimetre.mode`, `staffing.inter_agences`) ; les valeurs et les défauts
viennent de `REGISTRE_POLITIQUES_v1.md` §C, les issues de la colonne « Effet », rendues précises ici.

</source>
