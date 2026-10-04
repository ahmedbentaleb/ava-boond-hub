# Registre exécutable — le lot 2 · version 2 (D-56, réécrit le 04/10/2026 après le 11e audit)

> **Hamada, 29/09 :** « je ne veux pas de compromis, je veux un truc qui marche dès le départ ».
> **11e audit (V-183, V-190, V-191) :** la version 1 n'était pas jouable sans interprétation — des colonnes qui
> n'existent pas, des règles en phrase, des scénarios à un seul élément. Cette version se joue **à la lettre**.

<quand_utiliser>

| ✅ On ouvre ce fichier | ⛔ On ne l'ouvre pas pour |
|---|---|
| Savoir **exactement** ce que fait une valeur de politique, dans quelle commande, dans quelle situation | la liste des clés et leurs défauts → `REGISTRE_POLITIQUES_v1.md` §C |
| Générer `politique_admise`, `COMPORTEMENTS`, `POLITIQUE_COMMANDES`, les cas de la porte différentielle | le contrat des commandes → `SPEC_COMMANDES_L4.md` |

</quand_utiliser>

<procedure>

## 0 · La grammaire — tout ce qui n'y entre pas est refusé par le lecteur

**Une ligne de cas** : `| clé | valeur | commande | scénario | issue |`, dans les tableaux du §2.
- **commande** : une commande servie, `SetPolicy`, `SetOwnTheme`, `(lecture)` (une vue), ou `*` (lue par **toutes**
  les commandes : le générateur développe la liste).
- **scénario** : un identifiant `S-…` défini sous son tableau. Il nomme ses objets (`B1`, `U1`, `C1`…), donne leur
  **état de départ complet** (aucun état implicite), les politiques **autres que leur défaut**, et l'appel. Agences :
  **PAR** (le demandeur) et **LYO** ; date du jour : `horloge_banc` au **15/10/2026** sauf mention.
- **valeur** : écrite sous sa **forme canonique** — un mot, un nombre sans zéro de tête (`1.5`, `200`), une liste
  JSON triée dans l'ordre du domaine (`["nom_normalise","siren"]`).

**Une issue** est une suite d'assertions séparées par ` · `. Toutes doivent être vraies. Formes **fermées** :

| Forme | Sens |
|---|---|
| `ok` | la commande réussit |
| `refus CODE` | refusée avec `CODE` ∈ GARDE · ETAT · DROIT · INTROUVABLE ; **aucune écriture métier**. ⭐ D-92 (05/10) : **tout** refus, quel que soit son code, écrit **une** ligne `tentative_refusee` sous `historique.tentatives_refusees = tracees_a_part` (le défaut), **aucune** sous `non_tracees` — c'est la seule écriture d'un refus, et la porte la vérifie sur chaque ligne de refus |
| `T[O].c = v` | après l'appel, la colonne `c` de la ligne de `T` désignée par l'objet `O` du scénario vaut `v` |
| `cat(T[O].c) = k` | la **catégorie** du code dans `T[O].c` vaut `k` (D-57 : on ne juge jamais un code ni un ordre) |
| `T[O].c inchangé` | la colonne n'a pas bougé |
| `lignes T = n` | la table compte `n` lignes de plus qu'au départ (`n = 0` : aucune écrite) |
| `alerte CODE` · `sans alerte` | l'alerte est rendue · aucune alerte |
| `événement Nom` | un événement `Nom` est écrit |
| `lu V[O].c = v` · `cat(V[O].c) = k` | une **vue** (D-53) rend `v` |

⛔ **Rien d'autre.** Une phrase sous un tableau ne spécifie rien : toute règle est une ligne (V-183).
⛔ **Une issue au pluriel** (« les contacts de U1 ») a un scénario **à deux éléments au moins** ; **une règle
conditionnelle** a un scénario **de chaque côté** (V-190). Le lecteur le vérifie.
⛔ **Chaque colonne nommée existe** (`information_schema`) ; le lecteur refuse sinon (V-191).

## 1 · Les règles — chacune jouée par une porte

| # | Règle |
|---|---|
| 1 | ⭐ **Une valeur est servie si et seulement si elle a au moins une ligne ici.** `politique_admise`, `COMPORTEMENTS`, `POLITIQUE_COMMANDES`, `valeurs_possibles` sont des **sorties** du générateur, jamais écrites à la main |
| 2 | Une clé **absente** d'ici : seul son **défaut** est servi. `SetPolicy` → `refus GARDE` sur toute autre valeur |
| 3 | **Différentiel** : chaque scénario d'une clé est joué sous **chaque** valeur servie ; deux valeurs à l'issue identique sur **tous** → rouge, sauf alias au §3 |
| 4 | ⭐ **D-85 — une politique liste ne sert que les listes écrites** (forme canonique) ; `[]`, un doublon, une autre combinaison → `refus GARDE`. Le domaine sert au lecteur à valider ce qui est écrit, il n'élargit rien |
| 5 | ⭐ **D-86 — une politique nombre sert une plage** `[min, max]` écrite au §2, avec une ligne au **min**, au **max** et au **défaut** ; une écriture non canonique (`0100`) → `refus GARDE` |
| 6 | **Les politiques se posent par `SetPolicy`** (chemin de l'administrateur, HTTP) — jamais en SQL, ni dans la porte ni dans les fixtures (V-181) |
| 7 | **Les contraintes entre clés** sont des lignes `SetPolicy` (§2, « Contraintes ») ; le générateur en tire `politique_admise(clé, valeur, état des autres clés)` |
| 8 | ⛔ Une porte qui exige une issue différente d'ici est **fausse**, même verte (V-164) |

</procedure>

<etat>

## 2 · Les 58 clés lues par une commande du lot 2

### Société, contact, personne

| clé | valeur | commande | scénario | issue |
|---|---|---|---|---|
| `doublon.societe.mode` | avertir | CreateCompany | S-DS1 | ok · alerte DOUBLON · lignes societe = 1 |
| `doublon.societe.mode` | bloquer | CreateCompany | S-DS1 | refus GARDE |
| `doublon.societe.mode` | ignorer | CreateCompany | S-DS1 | ok · sans alerte · lignes societe = 1 |
| `doublon.societe.cles` | ["nom_normalise","siren"] | CreateCompany | S-DS2 | refus GARDE |
| `doublon.societe.cles` | ["siren"] | CreateCompany | S-DS2 | ok · lignes societe = 1 |
| `doublon.societe.cles` | ["nom_normalise"] | CreateCompany | S-DS3 | ok · lignes societe = 1 |
| `doublon.societe.cles` | ["nom_normalise","siren"] | CreateCompany | S-DS3 | refus GARDE |
| `doublon.societe.cles` | ["siren"] | CreateCompany | S-DS3 | refus GARDE |
| `doublon.societe.cles` | ["nom_normalise","siren"] | CreateCompany | S-DS4 | ok · societe[N].siren = 444555666 |
| `doublon.societe.cles` | ["nom_normalise","siren"] | SetPolicy | S-DS5 | refus GARDE |

- **S-DS1** — société A « ACME », SIREN 111111111, créée **par `CreateCompany`** à PAR ; `CreateCompany` N nom « Acme SA » (normalisé `acme`), sans SIREN.
- **S-DS2** — `doublon.societe.mode = bloquer` ; A « ACME » SIREN 111111111 (par commande) ; `CreateCompany` N « Acme », SIREN 222222222.
- **S-DS3** — `bloquer` ; A « Durand » SIREN 333333333 (par commande) ; `CreateCompany` N « Martin », SIREN 333333333.
- **S-DS4** — aucune société ; `CreateCompany` N « Neuve », SIREN 444555666 : ⛔ **le SIREN reçu est écrit** (V-184).
- **S-DS5** — `SetPolicy doublon.societe.cles = []`.
- **Domaine** : `nom_normalise`, `siren`.

| clé | valeur | commande | scénario | issue |
|---|---|---|---|---|
| `societe.retour_prospect` | manuel | ClosePrestation | S-RP1 | ok · cat(societe[A].statut_commercial_code) = client |
| `societe.retour_prospect` | auto_fin_dernier_contrat | ClosePrestation | S-RP1 | ok · cat(societe[A].statut_commercial_code) = prospect · événement ClientStatusDerived |
| `societe.retour_prospect` | auto_apres_delai | ClosePrestation | S-RP1 | ok · cat(societe[A].statut_commercial_code) = client |
| `societe.retour_prospect` | jamais_ancien_client | ClosePrestation | S-RP1 | ok · cat(societe[A].statut_commercial_code) = ancien_client · événement ClientStatusDerived |
| `societe.retour_prospect` | auto_fin_dernier_contrat | ClosePrestation | S-RP5 | ok · cat(societe[A].statut_commercial_code) = client |
| `societe.retour_prospect` | auto_fin_dernier_contrat | CancelPrestation | S-RP2 | ok · cat(societe[A].statut_commercial_code) = prospect |
| `societe.retour_prospect` | manuel | CancelPrestation | S-RP2 | ok · cat(societe[A].statut_commercial_code) = client |
| `societe.retour_prospect` | auto_apres_delai | (lecture) | S-RP3 | cat(v_societe_statut[A].statut_lu_code) = prospect |
| `societe.retour_prospect` | manuel | (lecture) | S-RP3 | cat(v_societe_statut[A].statut_lu_code) = client |
| `societe.retour_prospect` | auto_apres_delai | (lecture) | S-RP6 | cat(v_societe_statut[A].statut_lu_code) = client |
| `societe.retour_prospect` | manuel | RequalifyCompany | S-RP4 | ok · cat(societe[A].statut_commercial_code) = prospect |
| `societe.retour_prospect` | auto_fin_dernier_contrat | RequalifyCompany | S-RP4 | ok · cat(societe[A].statut_commercial_code) = prospect |
| `societe.retour_prospect` | auto_apres_delai | RequalifyCompany | S-RP4 | ok · cat(societe[A].statut_commercial_code) = prospect |
| `societe.retour_prospect` | jamais_ancien_client | RequalifyCompany | S-RP4 | refus GARDE |
| `societe.retour_prospect.delai_mois` | 6 | (lecture) | S-RP3 | cat(v_societe_statut[A].statut_lu_code) = prospect |
| `societe.retour_prospect.delai_mois` | 12 | (lecture) | S-RP3 | cat(v_societe_statut[A].statut_lu_code) = client |
| `societe.retour_prospect.delai_mois` | 1 | (lecture) | S-RP6 | cat(v_societe_statut[A].statut_lu_code) = prospect |
| `societe.retour_prospect.delai_mois` | 24 | (lecture) | S-RP3 | cat(v_societe_statut[A].statut_lu_code) = client |

- **S-RP1** — société A (PAR) de catégorie `client` ; projet P1 ; prestation X1 `engage` (01/09 → 31/12/2026), **la seule** `engage` de A ; `ClosePrestation X1` au 15/10.
- **S-RP5** — idem, avec une **seconde** prestation X2 `engage` sur A : X1 close, X2 reste → A reste cliente.
- **S-RP2** — comme S-RP1, `CancelPrestation X1` avec motif.
- **S-RP3** — A `client`, sa dernière prestation `engage` a fini le 15/03/2026 (7 mois) ; `societe.retour_prospect = auto_apres_delai` sauf la ligne `manuel` ; on lit la vue.
- **S-RP6** — A `client`, dernière fin le 15/09/2026 (1 mois) ; `delai_mois = 6` sauf mention.
- **S-RP4** — A `client`, sans prestation ; `RequalifyCompany A` vers un code de catégorie `prospect`.
- **Plage** de `societe.retour_prospect.delai_mois` : entier **1 → 24**, défaut 6.

| clé | valeur | commande | scénario | issue |
|---|---|---|---|---|
| `societe.archivage.garde` | aucun_objet_actif | ArchiveCompany | S-AC1 | refus GARDE |
| `societe.archivage.garde` | libre | ArchiveCompany | S-AC1 | ok · societe[A].archive_le = 2026-10-15 |
| `service.archivage.garde` | aucun_besoin_ni_projet_actif | ArchiveService | S-AS1 | refus GARDE |
| `service.archivage.garde` | libre | ArchiveService | S-AS1 | ok · unite_organisation[U1].archive_le = 2026-10-15 |

- **S-AC1** — société A (PAR) avec un besoin B1 de catégorie `en_recherche` ; `ArchiveCompany A`, motif « fermeture ».
- **S-AS1** — société A, unité U1 porteuse d'un projet P1 de catégorie `ouvert` ; `ArchiveService U1`, motif « réorganisation ».

| clé | valeur | commande | scénario | issue |
|---|---|---|---|---|
| `doublon.contact.mode` | avertir | CreateContact | S-DC1 | ok · alerte DOUBLON · lignes contact = 1 |
| `doublon.contact.mode` | bloquer | CreateContact | S-DC1 | refus GARDE |
| `doublon.contact.mode` | ignorer | CreateContact | S-DC1 | ok · sans alerte · lignes contact = 1 |
| `doublon.contact.cles` | ["email","nom+prenom+societe"] | CreateContact | S-DC2 | ok · lignes contact = 1 |
| `doublon.contact.cles` | ["email_ou_telephone","nom+prenom+societe"] | CreateContact | S-DC2 | refus GARDE |
| `contact.transfert.objets_actifs` | reaffectation_obligatoire | TransferContact | S-TC1 | refus GARDE |
| `contact.transfert.objets_actifs` | conserver_liens | TransferContact | S-TC1 | ok · besoin[B1].contact_id inchangé |
| `contact.transfert.objets_actifs` | reaffectation_obligatoire | TransferContact | S-TC2 | ok · besoin[B1].contact_id = C2 |
| `contact.transfert.objets_actifs` | conserver_liens | TransferContact | S-TC2 | refus GARDE |

- **S-DC1** — société A (PAR), contact C1 « Lea Morel » `lea@acme.fr` (par commande) ; `CreateContact` « Lou Morin » `lea@acme.fr` chez A.
- **S-DC2** — `doublon.contact.mode = bloquer` ; C1 `lea@acme.fr`, tél. 0611223344 chez A ; `CreateContact` « Paul Roy » `paul@acme.fr`, tél. 0611223344, chez A.
- **S-TC1** — contacts C1, C2 chez A ; besoin B1 `en_recherche` dont le contact est C1 ; `TransferContact C1` vers la société A2 (PAR), **sans** `reaffecter_a`.
- **S-TC2** — idem, avec `reaffecter_a = C2`. ⛔ Sous `conserver_liens`, `reaffecter_a` n'a pas d'effet : il est refusé (une clé reçue a un effet, V-152).
- **Domaine** : `email`, `telephone`, `email_ou_telephone`, `nom+prenom+societe`.

| clé | valeur | commande | scénario | issue |
|---|---|---|---|---|
| `doublon.personne.mode` | avertir | CreatePerson | S-DP1 | ok · alerte DOUBLON · lignes personne = 1 |
| `doublon.personne.mode` | bloquer | CreatePerson | S-DP1 | refus GARDE |
| `doublon.personne.mode` | ignorer | CreatePerson | S-DP1 | ok · sans alerte · lignes personne = 1 |
| `doublon.personne.cles` | ["email","nom+prenom+naissance"] | CreatePerson | S-DP2 | refus GARDE |
| `doublon.personne.cles` | ["email"] | CreatePerson | S-DP2 | ok · lignes personne = 1 |

- **S-DP1** — personne P1 `sara@mail.fr` (par commande) ; `CreatePerson` « Nora Ben » `sara@mail.fr`.
- **S-DP2** — `bloquer` ; P1 « Sara Ali », née 1990-03-02, `sara@mail.fr` ; `CreatePerson` « Sara Ali », 1990-03-02, `s.ali@autre.fr`.
- **Domaine** : `email`, `telephone`, `nom+prenom+naissance` (D-61 : `score_pondere` retiré).

### Candidat, ressource, qualification

| clé | valeur | commande | scénario | issue |
|---|---|---|---|---|
| `candidat.complete.champs_requis` | ["nom","prenom","civilite","localisation","email_ou_telephone"] | CompleteCandidate | S-CC1 | refus GARDE |
| `candidat.complete.champs_requis` | ["nom","prenom","localisation","email_ou_telephone"] | CompleteCandidate | S-CC1 | ok · cat(profil_candidat[K].etat_code) = complet |
| `candidat.complete.champs_requis` | ["nom","prenom","localisation","email_ou_telephone"] | CompleteCandidate | S-CC2 | refus GARDE |
| `candidat.complete.champs_requis` | [] | SetPolicy | S-CC3 | refus GARDE |
| `candidat.conversion.acteur` | groupe_rh | ConvertCandidateToResource | S-CV1 | refus DROIT |
| `candidat.conversion.acteur` | groupe_rh_ou_rr | ConvertCandidateToResource | S-CV1 | ok · lignes profil_ressource = 1 |
| `candidat.conversion.acteur` | tout_habilite | ConvertCandidateToResource | S-CV1 | ok · lignes profil_ressource = 1 |
| `candidat.conversion.acteur` | groupe_rh_ou_rr | ConvertCandidateToResource | S-CV2 | refus DROIT |
| `candidat.conversion.acteur` | tout_habilite | ConvertCandidateToResource | S-CV2 | ok · lignes profil_ressource = 1 |
| `candidat.note.echelle` | 1_5 | UpdateCandidate | S-NE1 | refus GARDE |
| `candidat.note.echelle` | 1_10 | UpdateCandidate | S-NE1 | ok · profil_candidat[K].note_globale = 7 |
| `candidat.note.echelle` | 1_100 | UpdateCandidate | S-NE1 | ok · profil_candidat[K].note_globale = 7 |
| `candidat.note.echelle` | aucune | UpdateCandidate | S-NE1 | refus GARDE |
| `candidat.note.echelle` | 1_10 | UpdateCandidate | S-NE2 | refus GARDE |
| `candidat.note.echelle` | 1_100 | UpdateCandidate | S-NE2 | ok · profil_candidat[K].note_globale = 50 |
| `candidat.note.echelle` | 1_5 | UpdateCandidate | S-NE3 | ok · profil_candidat[K].note_globale = 3 |
| `candidat.note.echelle` | aucune | UpdateCandidate | S-NE3 | refus GARDE |
| `ressource.externe.societe_fournisseur` | obligatoire | CreateResource | S-RF1 | refus GARDE |
| `ressource.externe.societe_fournisseur` | facultatif | CreateResource | S-RF1 | ok · lignes profil_ressource = 1 |
| `ressource.externe.societe_fournisseur` | obligatoire | ConvertCandidateToResource | S-RF2 | refus GARDE |
| `ressource.externe.societe_fournisseur` | facultatif | ConvertCandidateToResource | S-RF2 | ok · lignes profil_ressource = 1 |

- **S-CC1** — candidat K (PAR), catégorie `brouillon` : nom, prénom, localisation, e-mail remplis ; **civilité vide**.
- **S-CC2** — K `brouillon` : nom, prénom remplis ; localisation, e-mail et téléphone **vides**.
- **S-CC3** — `SetPolicy candidat.complete.champs_requis = []`.
- **S-CV1** — demandeur du groupe **RR**, `ConvertCandidateToResource` **délégué** sur PAR ; candidat K (PAR) `complet`, type visé interne.
- **S-CV2** — demandeur du groupe **IA**, même délégation ; même K.
- **S-NE1** — `UpdateCandidate K` note = 7 ; **S-NE2** — note = 50 ; **S-NE3** — note = 3.
- **S-RF1** — `CreateResource` pour une personne P1 sans profil, type `externe`, sans société fournisseur.
- **S-RF2** — conversion de K vers une ressource `externe`, sans société fournisseur (demandeur du groupe RH).
- **Domaine** de `candidat.complete.champs_requis` : `nom`, `prenom`, `civilite`, `localisation`, `email`, `telephone`, `email_ou_telephone`, `date_naissance`.

| clé | valeur | commande | scénario | issue |
|---|---|---|---|---|
| `ressource.etat.mode` | manuel | SetResourceState | S-RE1 | ok · cat(profil_ressource[R].etat_code) = disponible |
| `ressource.etat.mode` | derive_des_prestations | SetResourceState | S-RE1 | refus GARDE |
| `ressource.etat.mode` | derive_avec_exceptions_tracees | SetResourceState | S-RE1 | refus GARDE |
| `ressource.etat.mode` | derive_avec_exceptions_tracees | SetResourceState | S-RE2 | ok · profil_ressource[R].etat_exception_jusquau = 2026-10-31 · cat(profil_ressource[R].etat_exception_code) = disponible |
| `ressource.etat.mode` | derive_des_prestations | SetResourceState | S-RE2 | refus GARDE |
| `ressource.etat.mode` | derive_avec_exceptions_tracees | (lecture) | S-RE3 | lu v_ressource_etat[R].etat_lu_categorie = disponible |
| `ressource.etat.mode` | derive_avec_exceptions_tracees | (lecture) | S-RE4 | lu v_ressource_etat[R].etat_lu_categorie = en_mission |
| `ressource.etat.mode` | derive_des_prestations | (lecture) | S-RE5 | lu v_ressource_etat[R].etat_lu_categorie = en_mission |
| `ressource.etat.mode` | manuel | (lecture) | S-RE5 | lu v_ressource_etat[R].etat_lu_categorie = disponible |
| `ressource.etat.mode` | derive_des_prestations | SetResourceState | S-RE6 | ok · cat(profil_ressource[R].etat_code) = sorti |

- **S-RE1** — ressource R (PAR), état écrit de catégorie `en_mission` ; une prestation X `engage` (01/09 → 31/12/2026) ; `SetResourceState R` → un code de catégorie `disponible`, **sans** motif ni date de fin.
- **S-RE2** — idem, avec motif « congé sabbatique » et fin 2026-10-31.
- **S-RE3** — état après S-RE2 ; lecture le 15/10. **S-RE4** — état après S-RE2 ; lecture le **01/11/2026**.
- **S-RE5** — R, état écrit de catégorie `disponible`, X `engage` couvre le 15/10 ; lecture.
- **S-RE6** — R `en_mission` ; `SetResourceState R` → un code de catégorie `sorti`, motif « départ ».

| clé | valeur | commande | scénario | issue |
|---|---|---|---|---|
| `qualification.besoin_obligatoire` | oui | RecordQualification | S-QB1 | refus GARDE |
| `qualification.besoin_obligatoire` | non | RecordQualification | S-QB1 | ok · lignes qualification = 1 |

- **S-QB1** — candidat K (PAR) ; `RecordQualification` de K, type « entretien », **sans** `besoin_id`.

### Besoin et positionnement

| clé | valeur | commande | scénario | issue |
|---|---|---|---|---|
| `besoin.unite_couverture` | postes | CreateNeed | S-UC1 | ok · besoin[N].unite_couverture_code = postes |
| `besoin.unite_couverture` | fte | CreateNeed | S-UC1 | ok · besoin[N].unite_couverture_code = fte |
| `besoin.unite_couverture` | postes_et_fte | CreateNeed | S-UC1 | ok · besoin[N].unite_couverture_code = postes_et_fte |
| `besoin.contact` | facultatif | CreateNeed | S-BC1 | ok · besoin[N].contact_id = NULL |
| `besoin.contact` | obligatoire | CreateNeed | S-BC1 | refus GARDE |
| `besoin.contact` | obligatoire | CreateNeed | S-BC2 | ok · besoin[N].contact_id = C1 |

- **S-UC1** — société A (PAR) ; `CreateNeed` N avec contact C1, 1 poste, fte visé 1.0, **sans** unité de couverture.
- **S-BC1** — `CreateNeed` N sur A, sans contact. **S-BC2** — `CreateNeed` N sur A, contact C1.

| clé | valeur | commande | scénario | issue |
|---|---|---|---|---|
| `besoin.staffing.declencheur` | premier_positionnement | PositionCandidate | S-SD1 | ok · besoin[B1].etat_categorie = en_recherche |
| `besoin.staffing.declencheur` | commande_prise_en_charge | PositionCandidate | S-SD1 | ok · besoin[B1].etat_categorie = a_pourvoir |
| `besoin.staffing.declencheur` | retour_client_retenu | PositionCandidate | S-SD1 | ok · besoin[B1].etat_categorie = a_pourvoir |
| `besoin.staffing.declencheur` | commande_prise_en_charge | TakeNeedInCharge | S-SD2 | ok · besoin[B1].etat_categorie = en_recherche · besoin[B1].manager_compte_id = demandeur · événement NeedTakenInCharge |
| `besoin.staffing.declencheur` | premier_positionnement | TakeNeedInCharge | S-SD2 | ok · besoin[B1].etat_categorie = a_pourvoir · besoin[B1].manager_compte_id = demandeur · événement NeedTakenInCharge |
| `besoin.staffing.declencheur` | retour_client_retenu | RecordClientDecision | S-SD3 | ok · besoin[B1].etat_categorie = en_recherche |
| `besoin.staffing.declencheur` | commande_prise_en_charge | RecordClientDecision | S-SD3 | ok · besoin[B1].etat_categorie = a_pourvoir |

- **S-SD1** — besoin B1 (PAR) `a_pourvoir`, sans positionnement ; candidat K (PAR) ; `PositionCandidate K` sur B1. Le demandeur a `PositionCandidate`, **pas** `TakeNeedInCharge` (D-87).
- **S-SD2** — B1 `a_pourvoir` ; `TakeNeedInCharge B1`.
- **S-SD3** — B1 `a_pourvoir` avec un positionnement Q1 `presente` ; `RecordClientDecision Q1` d'une décision de catégorie `positive`.

| clé | valeur | commande | scénario | issue |
|---|---|---|---|---|
| `besoin.pourvu.garde_minimale` | tous_les_postes_signes | DeclareNeedFilled | S-PG1 | refus GARDE |
| `besoin.pourvu.garde_minimale` | une_prestation_signee | DeclareNeedFilled | S-PG1 | ok · besoin[B1].etat_categorie = pourvu |
| `besoin.pourvu.garde_minimale` | aucune | DeclareNeedFilled | S-PG1 | ok · besoin[B1].etat_categorie = pourvu |
| `besoin.pourvu.garde_minimale` | une_prestation_signee | DeclareNeedFilled | S-PG2 | refus GARDE |
| `besoin.pourvu.garde_minimale` | aucune | DeclareNeedFilled | S-PG2 | ok · besoin[B1].etat_categorie = pourvu |
| `besoin.pourvu.garde_minimale` | tous_les_postes_signes | DeclareNeedFilled | S-PG3 | ok · besoin[B1].etat_categorie = pourvu |
| `besoin.pourvu.garde_minimale` | tous_les_postes_signes | DeclareNeedFilled | S-PG4 | refus GARDE |

- **S-PG1** — besoin B1 (PAR) `en_recherche`, unité `postes`, **2** postes visés, **sans** fte ; **1** prestation `engage` rattachée.
- **S-PG2** — B1 comme S-PG1, **aucune** prestation `engage`.
- **S-PG3** — B1 unité `postes`, 1 poste visé, **sans** fte ; 1 prestation `engage` à 50 % : couverture atteinte (1/1 poste).
- **S-PG4** — B1 unité **`fte`**, fte visé 1.0, sans nombre de postes ; 1 prestation `engage` à 50 % : non atteinte (0,5/1,0).

| clé | valeur | commande | scénario | issue |
|---|---|---|---|---|
| `besoin.pourvu.mode` | manuel_avec_garde | SignPrestation | S-PM1 | ok · besoin[B1].etat_categorie = en_recherche |
| `besoin.pourvu.mode` | auto_par_prestation_signee | SignPrestation | S-PM1 | ok · besoin[B1].etat_categorie = en_recherche |
| `besoin.pourvu.mode` | auto_par_personne_signee | SignPrestation | S-PM1 | ok · besoin[B1].etat_categorie = pourvu · événement NeedFilled |
| `besoin.pourvu.mode` | auto_propose_confirme | SignPrestation | S-PM1 | ok · besoin[B1].etat_categorie = en_recherche · sans alerte |
| `besoin.pourvu.mode` | auto_par_prestation_signee | SignPrestation | S-PM2 | ok · besoin[B1].etat_categorie = pourvu · événement NeedFilled |
| `besoin.pourvu.mode` | auto_propose_confirme | SignPrestation | S-PM2 | ok · besoin[B1].etat_categorie = en_recherche · alerte BESOIN_A_DECLARER_POURVU |
| `besoin.pourvu.mode` | manuel_avec_garde | SignPrestation | S-PM2 | ok · besoin[B1].etat_categorie = en_recherche |
| `besoin.pourvu.mode` | manuel_avec_garde | DeclareNeedFilled | S-PM3 | refus GARDE |
| `besoin.pourvu.mode` | auto_par_prestation_signee | DeclareNeedFilled | S-PM3 | refus GARDE |
| `besoin.pourvu.mode` | auto_par_personne_signee | DeclareNeedFilled | S-PM3 | refus GARDE |
| `besoin.pourvu.mode` | auto_propose_confirme | DeclareNeedFilled | S-PM3 | refus GARDE |
| `besoin.pourvu.mode` | auto_par_personne_signee | DeclareNeedFilled | S-PM4 | refus GARDE |

- **S-PM1** — B1 (PAR) `en_recherche`, unité `postes`, 2 postes ; X1 `proposee` rattachée, aucune `engage` ; `SignPrestation X1` (1/2).
- **S-PM2** — idem, X0 déjà `engage` ; `SignPrestation X1` (2/2).
- **S-PM3** — B1, 2 postes, 1 prestation `engage` ; `DeclareNeedFilled B1` **appelé directement** (garde minimale au défaut).
- **S-PM4** — comme S-PM3, l'entrée contient en plus `depuis_signature = true`. ⛔ **D-88** : ce que la cascade transmet à sa fille ne passe jamais par l'entrée publique ; une telle clé est inconnue → refus (V-182).

| clé | valeur | commande | scénario | issue |
|---|---|---|---|---|
| `positionnement.sur_besoin_inactif` | refus | PositionCandidate | S-BI1 | refus GARDE |
| `positionnement.sur_besoin_inactif` | alerte | PositionCandidate | S-BI1 | ok · alerte BESOIN_INACTIF · lignes positionnement = 1 |
| `positionnement.sur_besoin_inactif` | libre | PositionCandidate | S-BI1 | ok · sans alerte · lignes positionnement = 1 |
| `positionnement.unicite` | actifs | PositionCandidate | S-PU1 | refus GARDE |
| `positionnement.unicite` | aucune | PositionCandidate | S-PU1 | ok · lignes positionnement = 1 |
| `positionnement.unicite` | historique | PositionCandidate | S-PU1 | refus GARDE |
| `positionnement.unicite` | actifs | PositionCandidate | S-PU2 | ok · lignes positionnement = 1 |
| `positionnement.unicite` | historique | PositionCandidate | S-PU2 | refus GARDE |
| `positionnement.cv_partage_obligatoire` | oui | RecordClientDecision | S-CP1 | refus ETAT |
| `positionnement.cv_partage_obligatoire` | non | RecordClientDecision | S-CP1 | ok · positionnement[Q1].etat_categorie = terminal_positif |
| `positionnement.qualification_requise_avant_decision` | non | RecordClientDecision | S-QR1 | ok · positionnement[Q1].etat_categorie = terminal_positif |
| `positionnement.qualification_requise_avant_decision` | oui | RecordClientDecision | S-QR1 | refus GARDE |

- **S-BI1** — besoin B1 (PAR) `suspendu` ; `PositionCandidate K` (PAR) sur B1.
- **S-PU1** — K a déjà un positionnement **actif** Q0 sur B1 ; `PositionCandidate K` sur B1.
- **S-PU2** — K a un positionnement Q0 **retiré** sur B1 ; `PositionCandidate K` sur B1.
- **S-CP1** — positionnement Q1 `propose` (CV jamais partagé) sur B1 ; décision de catégorie `positive`.
- **S-QR1** — Q1 `presente`, aucune qualification de K ; décision `positive`.

### Projet

| clé | valeur | commande | scénario | issue |
|---|---|---|---|---|
| `projet.creation_depuis_besoin` | explicite | RecordClientDecision | S-CB1 | ok · lignes projet = 0 |
| `projet.creation_depuis_besoin` | automatique_au_retenu | RecordClientDecision | S-CB1 | ok · lignes projet = 1 · événement ProjectCreatedFromNeed |
| `projet.creation_depuis_besoin` | automatique_au_retenu | RecordClientDecision | S-CB2 | refus DROIT |
| `projet.contact` | obligatoire | CreateProject | S-PC1 | refus GARDE |
| `projet.contact` | facultatif | CreateProject | S-PC1 | ok · projet[N].contact_id = NULL |
| `projet.contact` | obligatoire_avant_engagement | CreateProject | S-PC1 | ok · projet[N].contact_id = NULL |
| `projet.contact` | service_ou_societe | CreateProject | S-PC1 | ok · projet[N].contact_id = NULL · projet[N].unite_organisation_id = NULL |
| `projet.contact` | facultatif | SignPrestation | S-PC2 | ok · prestation[X1].etat_categorie = engage |
| `projet.contact` | obligatoire_avant_engagement | SignPrestation | S-PC2 | refus GARDE |
| `projet.contact` | service_ou_societe | CreateProjectFromNeed | S-PC3 | refus GARDE |
| `projet.contact` | facultatif | CreateProjectFromNeed | S-PC3 | ok · lignes projet = 1 |
| `projet.contact` | service_ou_societe | CreateProjectFromNeed | S-PC4 | ok · projet[N].unite_organisation_id = U1 · projet[N].contact_id = NULL |
| `projet.contact` | obligatoire | CreateProjectFromNeed | S-PC4 | refus GARDE |
| `projet.contact` | service_ou_societe | CreateProjectFromNeed | S-PC5 | refus GARDE |
| `projet.contact` | service_ou_societe | SetPolicy | S-PC6 | ok |
| `projet.origine_besoin` | facultative | CreateProject | S-PO1 | ok · projet[N].besoin_id = NULL |
| `projet.origine_besoin` | obligatoire | CreateProject | S-PO1 | refus GARDE |
| `besoin.projets_max` | illimite | CreateProjectFromNeed | S-PX1 | ok · lignes projet = 1 |
| `besoin.projets_max` | un_seul | CreateProjectFromNeed | S-PX1 | refus GARDE |
| `projet.depuis_besoin.garde` | retenu_requis | CreateProjectFromNeed | S-DG1 | refus GARDE |
| `projet.depuis_besoin.garde` | libre | CreateProjectFromNeed | S-DG1 | ok · lignes projet = 1 |
| `projet.depuis_besoin.garde_profil` | personne_avec_ressource | CreateProjectFromNeed | S-GP1 | ok · lignes projet = 1 |
| `projet.depuis_besoin.garde_profil` | positionnement_ressource_strict | CreateProjectFromNeed | S-GP1 | refus GARDE |
| `projet.cloture.garde` | prestations_closes | CloseProject | S-PCL1 | refus GARDE |
| `projet.cloture.garde` | cascade_cloture_prestations | CloseProject | S-PCL1 | ok · prestation[X1].etat_categorie = clos · prestation[X1].date_cloture = 2026-10-15 · prestation[X2].date_cloture inchangé |
| `projet.cloture.garde` | cascade_cloture_prestations | CloseProject | S-PCL2 | refus DROIT |

- **S-CB1** — positionnement Q1 `presente` d'un besoin B1 (PAR) ; le demandeur a `RecordClientDecision` **et** `CreateProjectFromNeed` sur PAR ; décision `positive`.
- **S-CB2** — idem, le demandeur a `RecordClientDecision` sur PAR **sans** `CreateProjectFromNeed` (D-43, V-179 : la fille passe par sa garde complète ; aucune exemption par nom de commande).
- **S-PC1** — `CreateProject` N sur A (PAR), type `regie`, sans contact, sans unité.
- **S-PC2** — projet P1 sans contact ; prestation X1 `proposee` ; `SignPrestation X1`.
- **S-PC3** — besoin B1 (PAR) avec `origine_code = regie`, un positionnement retenu ; `CreateProjectFromNeed` sans contact, sans unité.
- **S-PC4** — B1 avec `origine_code = appel_offres`, un positionnement retenu ; `CreateProjectFromNeed` sans contact, **avec** l'unité U1.
- **S-PC5** — B1 `origine_code = regie` ; `CreateProjectFromNeed` sans contact, **avec** l'unité U1 : ⛔ en régie le contact est exigé même si une unité est donnée (R10, V-190).
- **S-PC6** — `SetPolicy projet.contact = service_ou_societe` : ⛔ une valeur servie s'atteint par `SetPolicy` (V-181).
- **S-PO1** — `CreateProject` N sur A avec un contact C1, sans besoin d'origine.
- **S-PX1** — B1 a déjà un projet P0 ; un positionnement retenu ; `CreateProjectFromNeed` d'un second, contact C1.
- **S-DG1** — B1 sans positionnement de catégorie `terminal_positif` ; `CreateProjectFromNeed`, contact C1.
- **S-GP1** — le positionnement retenu Q1 est celui d'un **candidat** K dont la personne a aussi un profil ressource R à PAR ; contact C1.
- **S-PCL1** — projet P1 (PAR) avec X1 `engage` (fin 31/12/2026) et X2 déjà `clos` (date de clôture 30/09/2026) ; `CloseProject P1` au 15/10.
- **S-PCL2** — comme S-PCL1, le demandeur a `CloseProject` **sans** `ClosePrestation` (D-43 : fille refusée → mère refusée).

### Prestation et société cliente

| clé | valeur | commande | scénario | issue |
|---|---|---|---|---|
| `prestation.avenant.mode` | nouvelle_prestation | SignPrestation | S-AV1 | ok · lignes prestation_version = 0 |
| `prestation.avenant.mode` | version_datee | SignPrestation | S-AV1 | ok · lignes prestation_version = 1 |
| `societe.passage_client.declencheur` | premiere_prestation_signee | SignPrestation | S-PCD1 | ok · cat(societe[A].statut_commercial_code) = client · événement ClientStatusDerived |
| `societe.passage_client.declencheur` | premier_engagement_contractuel | SignPrestation | S-PCD1 | ok · cat(societe[A].statut_commercial_code) = client · événement ClientStatusDerived |
| `societe.passage_client.declencheur` | manuel | SignPrestation | S-PCD1 | ok · cat(societe[A].statut_commercial_code) = prospect |
| `societe.passage_client.declencheur` | creation_projet | SignPrestation | S-PCD1 | ok · cat(societe[A].statut_commercial_code) = prospect |
| `societe.passage_client.declencheur` | creation_projet | CreateProject | S-PCD2 | ok · cat(societe[A].statut_commercial_code) = client · événement ClientStatusDerived |
| `societe.passage_client.declencheur` | premiere_prestation_signee | CreateProject | S-PCD2 | ok · cat(societe[A].statut_commercial_code) = prospect |
| `societe.passage_client.declencheur` | creation_projet | CreateProjectFromNeed | S-PCD3 | ok · cat(societe[A].statut_commercial_code) = client |
| `societe.passage_client.declencheur` | premiere_prestation_signee | SignPrestation | S-PCD4 | ok · cat(societe[A].statut_commercial_code) = client |
| `societe.passage_client.propagation` | branche_contractante_et_contacts_du_service | SignPrestation | S-PR1 | ok · cat(unite_organisation[U1].statut_commercial_code) = client · cat(contact[C1].statut_commercial_code) = client · cat(contact[C2].statut_commercial_code) = client · cat(unite_organisation[U2].statut_commercial_code) = prospect · cat(contact[C3].statut_commercial_code) = prospect |
| `societe.passage_client.propagation` | societe_seule | SignPrestation | S-PR1 | ok · cat(societe[A].statut_commercial_code) = client · cat(unite_organisation[U1].statut_commercial_code) = prospect · cat(contact[C1].statut_commercial_code) = prospect |
| `societe.passage_client.propagation` | toute_la_societe | SignPrestation | S-PR1 | ok · cat(unite_organisation[U1].statut_commercial_code) = client · cat(unite_organisation[U2].statut_commercial_code) = client · cat(contact[C3].statut_commercial_code) = client |

- **S-AV1** — prestation X1 `proposee` d'un projet P1 (PAR) avec contact ; `SignPrestation X1`.
- **S-PCD1** — société A (PAR), catégorie `prospect` ; projet P1 avec contact ; première prestation X1 `proposee` ; `SignPrestation X1`.
- **S-PCD2** — A `prospect` ; `CreateProject` N sur A, contact C1. **S-PCD3** — idem par `CreateProjectFromNeed`, un positionnement retenu.
- **S-PCD4** — comme S-PCD1, **et** l'administrateur a ajouté au référentiel un **second** code de catégorie `prospect`, d'ordre 0, avant l'appel : ⛔ le passage client ne dépend ni d'un code ni d'un ordre (D-57, V-180).
- **S-PR1** — A `prospect` avec deux unités U1 (contractante du projet P1) et U2 ; **deux** contacts dans U1 (C1, contact du projet ; C2) et un contact C3 dans U2 ; `SignPrestation` de la première prestation de P1.

| clé | valeur | commande | scénario | issue |
|---|---|---|---|---|
| `projet.devises_mixtes` | autorise | CreatePrestation | S-DM1 | ok · prestation[N].devise_code = USD |
| `projet.devises_mixtes` | refus | CreatePrestation | S-DM1 | refus GARDE |
| `prestation.surcharge.mode` | alerte | CreatePrestation | S-SU1 | ok · alerte SURCHARGE · lignes prestation = 1 |
| `prestation.surcharge.mode` | refus | CreatePrestation | S-SU1 | refus GARDE |
| `prestation.surcharge.mode` | silencieux | CreatePrestation | S-SU1 | ok · sans alerte · lignes prestation = 1 |
| `prestation.surcharge.seuil_pct` | 100 | CreatePrestation | S-SU2 | ok · alerte SURCHARGE |
| `prestation.surcharge.seuil_pct` | 50 | CreatePrestation | S-SU2 | ok · alerte SURCHARGE |
| `prestation.surcharge.seuil_pct` | 300 | CreatePrestation | S-SU2 | ok · sans alerte |
| `prestation.surcharge.seuil_pct` | 200 | CreatePrestation | S-SU2 | ok · sans alerte |
| `prestation.surcharge.seuil_pct` | 0100 | SetPolicy | S-SU3 | refus GARDE |
| `prestation.annulation.garde` | aucun_temps_saisi | CancelPrestation | S-PA1 | refus GARDE |
| `prestation.annulation.garde` | libre | CancelPrestation | S-PA1 | ok · prestation[X1].etat_categorie = annule |

- **S-DM1** — projet P1 (PAR) dont la première prestation est en EUR ; `CreatePrestation` N en USD.
- **S-SU1** — ressource R (PAR) déjà `engage` à 100 % du 01/11 au 30/11/2026 ; `CreatePrestation` à 50 % sur la même période ; seuil au défaut.
- **S-SU2** — comme S-SU1, `prestation.surcharge.mode = alerte` ; occupation résultante 150 %.
- **S-SU3** — `SetPolicy prestation.surcharge.seuil_pct = 0100` (forme non canonique).
- **Plage** de `prestation.surcharge.seuil_pct` : entier **50 → 300**, défaut 100.
- **S-PA1** — X1 `engage` avec 3 lignes de temps ; `CancelPrestation X1` avec motif.

### Temps, clôture, marge

| clé | valeur | commande | scénario | issue |
|---|---|---|---|---|
| `temps.periode` | dates_prestation | RecordTimesheet | S-TP1 | ok · lignes temps = 1 |
| `temps.periode` | dates_prestation_et_mois_ouvert | RecordTimesheet | S-TP1 | ok · lignes temps = 1 |
| `temps.periode` | dates_prestation | RecordTimesheet | S-TP2 | refus GARDE |
| `temps.periode` | dates_prestation_et_mois_ouvert | RecordTimesheet | S-TP2 | refus GARDE |
| `temps.periode` | dates_prestation | RecordTimesheet | S-TP3 | ok · lignes temps = 1 |
| `temps.periode` | dates_prestation_et_mois_ouvert | RecordTimesheet | S-TP3 | refus GARDE |
| `temps.periode` | dates_prestation_et_mois_ouvert | RecordTimesheet | S-TP4 | ok · lignes temps = 1 |
| `temps.mois_ouvert.grace_jours` | 5 | RecordTimesheet | S-TP4 | ok · lignes temps = 1 |
| `temps.mois_ouvert.grace_jours` | 0 | RecordTimesheet | S-TP4 | refus GARDE |
| `temps.mois_ouvert.grace_jours` | 15 | RecordTimesheet | S-TP4 | ok · lignes temps = 1 |
| `temps.mois_ouvert.grace_jours` | 2 | RecordTimesheet | S-TP4 | refus GARDE |

- Prestation X `engage` du 01/09/2026 au 31/12/2026, ressource R de PAR, saisie de 1.0 j.
- **S-TP1** — saisie au 14/10/2026. **S-TP2** — saisie au 15/01/2027. **S-TP3** — saisie au 10/09/2026.
- **S-TP4** — date du jour **03/10/2026**, saisie au 30/09/2026 ; `temps.periode = dates_prestation_et_mois_ouvert` sous les lignes de `grace_jours`.
- **Plage** de `temps.mois_ouvert.grace_jours` : entier **0 → 15**, défaut 5.

| clé | valeur | commande | scénario | issue |
|---|---|---|---|---|
| `temps.plafond_jour` | alerte | RecordTimesheet | S-PJ1 | ok · alerte PLAFOND_JOUR · lignes temps = 1 |
| `temps.plafond_jour` | refus | RecordTimesheet | S-PJ1 | refus GARDE |
| `temps.plafond_jour` | aucun | RecordTimesheet | S-PJ1 | ok · sans alerte · lignes temps = 1 |
| `temps.plafond_jour` | refus_avec_derogation_tracee | RecordTimesheet | S-PJ1 | refus GARDE |
| `temps.plafond_jour` | refus_avec_derogation_tracee | RecordTimesheet | S-PJ2 | ok · alerte PLAFOND_JOUR · temps[N].derogation_motif = astreinte |
| `temps.plafond_jour` | alerte | RecordTimesheet | S-PJ2 | refus GARDE |
| `temps.plafond_jour` | aucun | RecordTimesheet | S-PJ2 | refus GARDE |
| `temps.plafond_jour` | refus | RecordTimesheet | S-PJ2 | refus GARDE |
| `capacite.jour_ouvre` | 1.0 | RecordTimesheet | S-PJ3 | refus GARDE |
| `capacite.jour_ouvre` | 1.5 | RecordTimesheet | S-PJ3 | ok · lignes temps = 1 |
| `capacite.jour_ouvre` | 0.5 | RecordTimesheet | S-PJ3 | refus GARDE |
| `capacite.jour_ouvre` | 2.0 | RecordTimesheet | S-PJ3 | ok · lignes temps = 1 |

- **S-PJ1** — R a **une** ligne de 0.8 j le 14/10 ; on saisit **une seconde** ligne de 0.5 j le même jour (total 1.3), sans motif de dérogation.
- **S-PJ2** — idem, avec `derogation_motif = astreinte`. ⛔ Sous une autre valeur, la clé n'a pas d'effet : refusée (V-152).
- **S-PJ3** — `temps.plafond_jour = refus` ; même saisie (0.8 + 0.5 = 1.3).
- **Plage** de `capacite.jour_ouvre` : décimal **0.5 → 2.0**, défaut 1.0.

| clé | valeur | commande | scénario | issue |
|---|---|---|---|---|
| `temps.facturable.mode` | egal_au_produit | RecordTimesheet | S-TF1 | ok · temps[N].quantite_facturable = 1.0 |
| `temps.facturable.mode` | saisie_separee | RecordTimesheet | S-TF1 | refus GARDE |
| `temps.facturable.mode` | saisie_separee | RecordTimesheet | S-TF2 | ok · temps[N].quantite = 1.0 · temps[N].quantite_facturable = 0.5 |
| `temps.facturable.mode` | egal_au_produit | RecordTimesheet | S-TF2 | refus GARDE |
| `temps.validation` | aucune | RecordTimesheet | S-TV1 | ok · cat(temps[N].etat_code) = valide |
| `temps.validation` | par_dp | RecordTimesheet | S-TV1 | ok · cat(temps[N].etat_code) = a_valider |
| `temps.validation` | par_projet | RecordTimesheet | S-TV1 | ok · cat(temps[N].etat_code) = a_valider |
| `temps.validation` | par_projet | RecordTimesheet | S-TV2 | ok · cat(temps[N].etat_code) = valide |
| `temps.validation` | par_dp | AdjustTimesheetAfterClose | S-TV3 | ok · cat(temps[N].etat_code) = a_valider · temps[N].ajustement = true |
| `temps.validation` | aucune | AdjustTimesheetAfterClose | S-TV3 | ok · cat(temps[N].etat_code) = valide · temps[N].ajustement = true |
| `temps.correction_apres_cloture` | ajustement_trace | AdjustTimesheetAfterClose | S-TV3 | ok · temps[N].ajustement = true · snapshot_marge[X].ca_produit inchangé |
| `temps.correction_apres_cloture` | refus | AdjustTimesheetAfterClose | S-TV3 | refus GARDE |

- **S-TF1** — saisie de 1.0 j **sans** quantité facturable ; **S-TF2** — 1.0 j avec quantité facturable 0.5.
- **S-TV1** — projet dont `validation_temps = true` ; saisie de 1.0 j. **S-TV2** — projet dont `validation_temps = false`.
- **S-TV3** — prestation X `clos` avec son `snapshot_marge` ; `AdjustTimesheetAfterClose` d'un jour, motif « oubli ».

| clé | valeur | commande | scénario | issue |
|---|---|---|---|---|
| `ca_produit.base` | temps_saisis | ClosePrestation | S-CA1 | ok · snapshot_marge[X].ca_produit = 5000 |
| `ca_produit.base` | temps_valides | ClosePrestation | S-CA1 | ok · snapshot_marge[X].ca_produit = 3000 |
| `frais.mode` | imputes_en_marge | ClosePrestation | S-FR1 | ok · snapshot_marge[X].marge = 1800 · snapshot_marge[X].frais_imputes = 200 |
| `frais.mode` | ignores | ClosePrestation | S-FR1 | ok · snapshot_marge[X].marge = 2000 · snapshot_marge[X].frais_imputes = 0 |
| `change.mode` | aucune_conversion | ClosePrestation | S-CH1 | ok · snapshot_marge[X].marge = NULL · snapshot_marge[X].motif_sans_marge = devises_mixtes |
| `change.mode` | taux_saisi | ClosePrestation | S-CH1 | refus GARDE |
| `change.mode` | taux_saisi | ClosePrestation | S-CH2 | ok · snapshot_marge[X].marge = 1400 · snapshot_marge[X].taux_change = 0.9 · snapshot_marge[X].cout_devise_code = EUR |
| `change.mode` | taux_saisi | CreatePrestation | S-CH3 | ok · prestation[N].taux_change = 0.9 |
| `change.mode` | aucune_conversion | CreatePrestation | S-CH3 | refus GARDE |
| `marge.taux.si_ca_nul` | tiret | ClosePrestation | S-MT1 | ok · snapshot_marge[X].taux_marge = NULL |
| `marge.taux.si_ca_nul` | zero | ClosePrestation | S-MT1 | ok · snapshot_marge[X].taux_marge = 0 |

- **S-CA1** — `temps.validation = par_dp` ; X `engage`, TJM 500 EUR ; 10 lignes de 1.0 j, dont **6** de catégorie `valide` ; `ClosePrestation X`.
- **S-FR1** — X : 10 j × 500 EUR, coût 3000 EUR, `frais_mensuel` 200 EUR sur un mois ; tout en EUR.
- **S-CH1** — X vendue en USD (10 j × 500 USD = 5000), coût 4000 **EUR** (`cjm_devise_code = EUR`), **sans** taux.
- **S-CH2** — idem, `prestation.taux_change = 0.9` (1 EUR de coût = 0,9 USD) : marge = 5000 − 4000 × 0,9 = 1400 USD. ⛔ M-15 : le coût garde sa devise EUR, seul le **taux** est écrit (V-185).
- **S-CH3** — `CreatePrestation` N vendue en USD, coût en EUR, avec `taux_change = 0.9`.
- **S-MT1** — X close avec CA nul (aucun temps).

### Absence, thème, droits, traces

| clé | valeur | commande | scénario | issue |
|---|---|---|---|---|
| `absence.chevauchement` | refus | RecordAbsence | S-AB1 | refus GARDE |
| `absence.chevauchement` | alerte | RecordAbsence | S-AB1 | ok · alerte CHEVAUCHEMENT · lignes absence = 1 |
| `absence.chevauchement` | libre | RecordAbsence | S-AB1 | ok · sans alerte · lignes absence = 1 |
| `absence.sans_prestation` | autorisee | RecordAbsence | S-AB2 | ok · lignes absence = 1 |
| `absence.sans_prestation` | refusee | RecordAbsence | S-AB2 | refus GARDE |
| `ui.theme.choix_utilisateur` | oui | SetOwnTheme | S-UT1 | ok · compte[D].theme_json = le thème donné |
| `ui.theme.choix_utilisateur` | non | SetOwnTheme | S-UT1 | refus GARDE |
| `ui.theme.choix_utilisateur` | oui | SetOwnTheme | S-UT2 | refus GARDE |
| `droits.surcharge_restrictive` | restriction_gagne | UpdateNeed | S-DR1 | refus DROIT |
| `droits.surcharge_restrictive` | union_gagne | UpdateNeed | S-DR1 | ok |
| `droits.surcharge_restrictive` | restriction_gagne | * | S-DR1 | refus DROIT |
| `historique.tentatives_refusees` | tracees_a_part | UpdateNeed | S-HT1 | refus DROIT · lignes tentative_refusee = 1 |
| `historique.tentatives_refusees` | non_tracees | UpdateNeed | S-HT1 | refus DROIT · lignes tentative_refusee = 0 |
| `historique.tentatives_refusees` | tracees_a_part | CompleteCandidate | S-HT2 | refus GARDE · lignes tentative_refusee = 1 |
| `historique.tentatives_refusees` | non_tracees | CompleteCandidate | S-HT2 | refus GARDE · lignes tentative_refusee = 0 |
| `historique.tentatives_refusees` | tracees_a_part | * | S-HT1 | refus DROIT · lignes tentative_refusee = 1 |

- **S-AB1** — absence de R du 10 au 12/11/2026 ; nouvelle du 12 au 14/11. **S-AB2** — absence de R (PAR) sans prestation `engage` sur la période.
- **S-UT1** — le demandeur D ; `SetOwnTheme` du thème **par défaut** (`ui.theme.defaut`).
- **S-UT2** — `SetOwnTheme {"ui.palette":"zz_non_servie"}` : ⛔ **D-66** — chaque clé `ui.*` du thème passe par la garde des valeurs servies, comme `SetPolicy` ; aujourd'hui seuls les défauts des clés `ui.*` sont servis (règle 2), leurs autres valeurs entrent avec le registre du lot 3.
- **S-DR1** — le groupe du demandeur a `UpdateNeed` sur le périmètre PAR ; **une ligne `compte_surcharge`** (compte du demandeur, `UpdateNeed`, ce périmètre) — toute ligne retire, la table n'a pas de sens (F28) ; `UpdateNeed` d'un besoin de PAR. La ligne `*` : même surcharge sur la commande jouée.
- **S-HT1** — compte sans `UpdateNeed` ; `UpdateNeed` d'un besoin de PAR. La ligne `*` : compte sans la commande jouée.
- **S-HT2** — candidat K `brouillon` sans localisation ni e-mail ; `CompleteCandidate K` (refus GARDE au défaut des champs requis).

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
| `societe.perimetre.mode` | agence_responsable | CreateNeed | S-SP5 | ok · besoin[N].agence_id = LYO |
| `staffing.inter_agences` | non | PositionCandidate | S-SI1 | refus DROIT |
| `staffing.inter_agences` | oui | PositionCandidate | S-SI1 | ok · profil_candidat[K].agence_id = LYO |
| `staffing.inter_agences` | oui | PositionCandidate | S-SI2 | refus DROIT |
| `staffing.inter_agences` | non | CreatePrestation | S-SI3 | refus DROIT |
| `staffing.inter_agences` | oui | CreatePrestation | S-SI3 | ok · profil_ressource[R].agence_id = LYO |

- **S-SP1** — société A, agence responsable **LYO**, avec un besoin de **PAR** ; le demandeur (PAR) la modifie.
- **S-SP2** — A responsable LYO, **sans** besoin.
- **S-SP3** — A responsable **PAR**, sans besoin (D-58).
- **S-SP4** — projet P1 de **LYO** ; `UpdateProject P1` avec un `contact_id` d'une société A partagée (D-44 : la politique société ne juge que la société).
- **S-SP5** — le demandeur est de PAR, son **seul** droit `CreateNeed` est **délégué sur LYO** ; société A responsable LYO ; `CreateNeed` avec `agence_id = LYO` (D-59 : une délégation sur une autre agence opère sur cette agence, en création quand l'entrée la demande).
- **S-SI1** — besoin B1 de PAR, candidat K de **LYO** ; `PositionCandidate K` sur B1 par PAR. **S-SI2** — B1 de **LYO**, K de PAR.
- **S-SI3** — projet P1 de PAR, ressource R de LYO ; `CreatePrestation`.

### Contraintes entre clés (règle 7)

| clé | valeur | commande | scénario | issue |
|---|---|---|---|---|
| `ca_produit.base` | temps_valides | SetPolicy | S-K1 | refus GARDE |
| `ca_produit.base` | temps_valides | SetPolicy | S-K2 | ok |
| `temps.validation` | aucune | SetPolicy | S-K3 | refus GARDE |

- **S-K1** — `temps.validation = aucune` ; `SetPolicy ca_produit.base = temps_valides` (V-183 : CA sur temps validés sans validation).
- **S-K2** — `temps.validation = par_dp` ; `SetPolicy ca_produit.base = temps_valides`.
- **S-K3** — `ca_produit.base = temps_valides`, `temps.validation = par_dp` ; `SetPolicy temps.validation = aucune`.

## 3 · Alias déclarés

| clé | valeurs | sur quels scénarios | motif | jusqu'à |
|---|---|---|---|---|
| `societe.passage_client.declencheur` | premiere_prestation_signee = premier_engagement_contractuel | tous ceux du lot 2 | l'engagement d'avant la prestation (devis accepté) n'existe qu'au lot 5.8 | lot 5.8 : `AcceptQuote` sous `premier_engagement_contractuel` seulement |

## 4 · Décisions

| # | Décision |
|---|---|
| D-61 → D-67 | du 01/10, inchangées (score retiré, mois ouvert, taux saisi, dérogation, couverture par unité, thème gardé, domaines) |
| **D-85** | une politique liste ne sert **que les listes écrites** (question 1 du 11e audit) |
| **D-86** | une politique nombre sert une **plage écrite**, jouée au min, au max et au défaut |
| **D-87** | quand une politique désigne la commande qui écrit une transition (`premier_positionnement` → `PositionCandidate`), **la transition fait partie de cette commande** : son droit suffit, ce n'est pas une cascade vers `TakeNeedInCharge` (question 2 du 11e audit). `MACHINES_ETAT_V1` dit, pour chaque transition, les commandes qui l'écrivent et sous quelle valeur |
| **D-88** | ce qu'une cascade transmet à sa fille passe par le **contexte serveur**, jamais par une clé d'entrée (V-182) |

</etat>

<source>

BRAIN, 04/10/2026, après le 11e audit (`audits-independants/ava-audit-11/rapport/`, CONSTATS V-179 → V-195,
REGISTRE C1 → C11). Colonnes relevées dans `information_schema` de la base `ava_brain` le 04/10. Version 1 :
01/10, commit `b48af33`.

</source>
