# Registre exécutable — lot 5.8 (RH, facturation, applications) · 05/10/2026

> Même grammaire, mêmes règles que `REGISTRE_EXECUTABLE.md` (lot 2, version 2) : §0 et §1 de ce fichier-là
> **valent ici, mot pour mot**. Ce fichier ne sert **qu'avec le lot 5.8** : tant que ses commandes ne sont pas
> servies, ses clés ne servent que leur défaut (règle 2).

<quand_utiliser>

| ✅ On ouvre ce fichier | ⛔ On ne l'ouvre pas pour |
|---|---|
| Coder ou juger une commande du lot 5.8 qui lit une politique | les clés lues par le lot 2 → `REGISTRE_EXECUTABLE.md` |
| Générer les cas de la porte différentielle du lot 5.8 | le contrat des commandes → `SPEC_COMMANDES_L4.md` §VII, §VIII, §X, §XI |

</quand_utiliser>

<procedure>

## 0 · Ce qui change par rapport au lot 2

| # | Règle |
|---|---|
| 1 | Les scénarios partent du **jeu de démonstration** (`JEU_DEMO.md`) quand il suffit, sinon de leur définition ; tout se crée **par commandes** |
| 2 | ⭐ **D-99 — une seule tâche planifiée dans tout le produit** : `SendAlertReport`, lancée par l'horloge du serveur, **acteur `systeme` déclaré** dans `CASCADES`, idempotente par (agence, jour). Toute autre règle d'horloge se lit à l'affichage (D-53) |
| 3 | Les montants : une devise par montant, jamais un total qui mélange (M-15) |

</procedure>

<etat>

## 1 · Les 22 clés lues par une commande du lot 5.8

### RH — coût, contrats, documents, blacklist, données sensibles

| clé | valeur | commande | scénario | issue |
|---|---|---|---|---|
| `cout.mode` | selon_type_ressource | UpdateEmployeeCost | S-CO1 | ok · profil_ressource[R].cout_reference = 210 · profil_ressource[R].cout_reference_devise_code = EUR |
| `cout.mode` | salarie_formule | UpdateEmployeeCost | S-CO1 | ok · profil_ressource[R].cout_reference = 210 |
| `cout.mode` | achat_externe | UpdateEmployeeCost | S-CO1 | refus GARDE |
| `cout.mode` | selon_type_ressource | UpdateEmployeeCost | S-CO2 | refus GARDE |
| `cout.mode` | achat_externe | UpdateEmployeeCost | S-CO2 | ok · profil_ressource[X].cout_reference = 450 |
| `cout.jours_base` | 200 | UpdateEmployeeCost | S-CO1 | ok · profil_ressource[R].cout_reference = 210 |
| `cout.jours_base` | 218 | UpdateEmployeeCost | S-CO1 | ok · profil_ressource[R].cout_reference = 192.66 |
| `cout.jours_base` | 180 | UpdateEmployeeCost | S-CO1 | ok · profil_ressource[R].cout_reference = 233.33 |
| `cout.jours_base` | 230 | UpdateEmployeeCost | S-CO1 | ok · profil_ressource[R].cout_reference = 182.61 |

- **S-CO1** — ressource **interne** R (PAR) ; le demandeur a `UpdateEmployeeCost` délégué ; entrée : brut annuel 36 000, primes 4 000, frais 2 000, EUR → coût = 42 000 ÷ `cout.jours_base`.
- **S-CO2** — ressource **externe** X (société fournisseur F) ; entrée : prix d'achat journalier 450 EUR. ⭐ `selon_type_ressource` : un salarié par la formule, un externe par son achat ; une entrée de l'autre forme → refus.
- **Plage** de `cout.jours_base` : entier **180 → 230**, défaut 200. Arrondi : 2 décimales, au plus proche.

| clé | valeur | commande | scénario | issue |
|---|---|---|---|---|
| `rh.contrat.obligatoire_avant_prestation` | non | SignPrestation | S-RC1 | ok · prestation[X1].etat_categorie = engage |
| `rh.contrat.obligatoire_avant_prestation` | oui | SignPrestation | S-RC1 | refus GARDE |
| `rh.contrat.obligatoire_avant_prestation` | oui | SignPrestation | S-RC2 | ok · prestation[X1].etat_categorie = engage |
| `rh.document.alerte_jours` | 60 | (lecture) | S-DS1 | lu v_documents_a_renouveler[D1].alerte = true |
| `rh.document.alerte_jours` | 30 | (lecture) | S-DS1 | lu v_documents_a_renouveler[D1].alerte = false |
| `rh.document.alerte_jours` | 7 | (lecture) | S-DS1 | lu v_documents_a_renouveler[D1].alerte = false |
| `rh.document.alerte_jours` | 120 | (lecture) | S-DS1 | lu v_documents_a_renouveler[D1].alerte = true |

- **S-RC1** — ressource **interne** R (PAR), **sans** contrat RH couvrant les dates de la prestation X1 (`proposee`) ; `SignPrestation X1`.
- **S-RC2** — idem, avec un contrat RH `actif` couvrant toute la période. ⭐ Une ressource **externe** n'a pas de contrat RH : la garde ne la regarde pas (une ligne par côté à la génération).
- **S-DS1** — un titre de séjour D1 de R expire dans **45 jours**.
- **Plage** de `rh.document.alerte_jours` : entier **7 → 120**, défaut 60. ⭐ La vue `v_documents_a_renouveler` (D-53) est à écrire par le BRAIN CODE.

| clé | valeur | commande | scénario | issue |
|---|---|---|---|---|
| `candidat.blackliste.portee` | agence | SetBlacklistFlag | S-BL1 | ok · personne[P].drapeau_blackliste = true · personne[P].blackliste_agence_id = PAR |
| `candidat.blackliste.portee` | installation | SetBlacklistFlag | S-BL1 | ok · personne[P].drapeau_blackliste = true · personne[P].blackliste_agence_id = NULL |
| `candidat.blackliste.portee` | agence | PushCVToContacts | S-BL2 | ok · lignes envoi_email = 1 |
| `candidat.blackliste.portee` | installation | PushCVToContacts | S-BL2 | refus GARDE |
| `candidat.blackliste.portee` | agence | PushCVToContacts | S-BL3 | refus GARDE |

- **S-BL1** — personne P (candidate à PAR) ; `SetBlacklistFlag P`, motif « comportement », par un compte de PAR.
- **S-BL2** — P blacklistée **à LYO** seulement ; `PushCVToContacts` de P par un compte de **PAR** à un contact de PAR.
- **S-BL3** — P blacklistée **à PAR** ; même envoi par PAR.

⛔ **D-98** : `reprise.donnees_rh_sensibles` est **retirée** du registre — il n'y a plus de reprise (D-94). Les
données sensibles se saisissent par `UpdateSensitiveHrData`, sous la permission `ModifierDonneesRHSensibles`.

### Facturation

| clé | valeur | commande | scénario | issue |
|---|---|---|---|---|
| `facturation.tva_defaut` | 20 | CreateInvoiceDraft | S-FA1 | ok · facture[N].tva_code = 20 |
| `facturation.tva_defaut` | 10 | CreateInvoiceDraft | S-FA1 | ok · facture[N].tva_code = 10 |
| `facturation.tva_defaut` | 0 | CreateInvoiceDraft | S-FA1 | ok · facture[N].tva_code = 0 |
| `facturation.tva_defaut` | 20 | CreateInvoiceDraft | S-FA2 | ok · facture[N].tva_code = 10 |
| `facturation.condition_reglement_defaut` | 30 | CreateInvoiceDraft | S-FA1 | ok · facture[N].condition_reglement_code = 30 |
| `facturation.condition_reglement_defaut` | 10 | CreateInvoiceDraft | S-FA1 | ok · facture[N].condition_reglement_code = 10 |
| `facturation.condition_reglement_defaut` | 40 | CreateInvoiceDraft | S-FA1 | ok · facture[N].condition_reglement_code = 40 |
| `facturation.condition_reglement_defaut` | 45 | CreateInvoiceDraft | S-FA1 | ok · facture[N].condition_reglement_code = 45 |
| `facturation.condition_reglement_defaut` | 60 | CreateInvoiceDraft | S-FA1 | ok · facture[N].condition_reglement_code = 60 |
| `facturation.mode_envoi_defaut` | email | CreateInvoiceDraft | S-FA1 | ok · facture[N].mode_envoi_code = email |
| `facturation.mode_envoi_defaut` | courrier | CreateInvoiceDraft | S-FA1 | ok · facture[N].mode_envoi_code = courrier |
| `facturation.mode_envoi_defaut` | email_courrier | CreateInvoiceDraft | S-FA1 | ok · facture[N].mode_envoi_code = email_courrier |
| `facturation.mode_envoi_defaut` | portail_chorus | CreateInvoiceDraft | S-FA1 | ok · facture[N].mode_envoi_code = portail_chorus |
| `facturation.relance.jours` | [7,15,30] | (lecture) | S-FR1 | lu v_factures_a_relancer[F].rang_du = 2 |
| `facturation.relance.jours` | [15,45] | (lecture) | S-FR1 | lu v_factures_a_relancer[F].rang_du = 1 |
| `facturation.relance.jours` | [7,15,30] | RecordInvoiceReminder | S-FR1 | ok · relance_facture[N].rang = 2 |
| `facturation.relance.jours` | [7,15,30] | RecordInvoiceReminder | S-FR2 | refus GARDE |

- **S-FA1** — projet P1 (PAR), 10 jours de temps de catégorie `valide` sur sa prestation ; `CreateInvoiceDraft P1` pour octobre, **sans** TVA, condition ni mode d'envoi dans l'entrée.
- **S-FA2** — idem, **avec** `tva_code = 10` dans l'entrée : l'entrée l'emporte sur le défaut.
- **S-FR1** — facture F `emise`, échue depuis **20 jours**, une relance de rang 1 déjà faite.
- **S-FR2** — facture F `emise`, échue depuis **3 jours**, aucune relance : la première n'est due qu'à 7 jours.
- **Domaines** : `facturation.relance.jours` — listes d'entiers croissants de 1 à 120, sans doublon ; servies : celles écrites ici.

### Temps signés, actions multiples, confidentialité

| clé | valeur | commande | scénario | issue |
|---|---|---|---|---|
| `temps.signature.demandee` | non | ValidateTimesheet | S-TS1 | ok · cat(temps[T].etat_code) = valide |
| `temps.signature.demandee` | oui | ValidateTimesheet | S-TS1 | refus GARDE |
| `temps.signature.demandee` | oui | ValidateTimesheet | S-TS2 | ok · cat(temps[T].etat_code) = valide |
| `actions.creation_multiple` | oui | CreateAction | S-AM1 | ok · lignes action = 3 |
| `actions.creation_multiple` | non | CreateAction | S-AM1 | refus GARDE |
| `actions.creation_multiple` | oui | CreateAction | S-AM2 | refus GARDE |
| `confidentialite.autorisee` | oui | SetConfidential | S-CF1 | ok · profil_candidat[K].confidentiel = true |
| `confidentialite.autorisee` | non | SetConfidential | S-CF1 | refus GARDE |

- **S-TS1** — `temps.validation = par_dp` ; 5 lignes `a_valider` de la ressource R pour la semaine ; `ValidateTimesheet` par le DP, **sans** document de signature.
- **S-TS2** — idem, avec `signature_document_id` (la feuille signée, déposée par `UploadDocument`). ⭐ **D-100** : la signature d'une feuille de temps est un document joint à la validation ; pas de commande de plus.
- **S-AM1** — `CreateAction` de type de catégorie **`presentation_client`**, avec **trois** porteurs (trois contacts) : une action par porteur, chacune à un seul porteur (M-9 tient).
- **S-AM2** — même appel avec un type de catégorie `defaut` : la création multiple ne vaut que pour `presentation_client` et `suivi_mission`. ⭐ **D-101** : `ref_type_action` reçoit ces deux catégories et leurs codes.
- **S-CF1** — candidat K (PAR) ; `SetConfidential K = oui`.

### Mail, CV, Outlook, paie, célébrations

| clé | valeur | commande | scénario | issue |
|---|---|---|---|---|
| `email.fournisseur` | microsoft | SendEmail | S-EM1 | ok · envoi_email[N].fournisseur_code = microsoft · lignes envoi_email_destinataire = 2 |
| `email.fournisseur` | google | SendEmail | S-EM1 | ok · envoi_email[N].fournisseur_code = google |
| `email.fournisseur` | smtp | SendEmail | S-EM1 | ok · envoi_email[N].fournisseur_code = smtp |
| `email.fournisseur` | aucun | SendEmail | S-EM1 | refus GARDE |
| `email.envoi_groupe.max` | 200 | SendEmail | S-EM2 | refus GARDE |
| `email.envoi_groupe.max` | 500 | SendEmail | S-EM2 | ok · lignes envoi_email_destinataire = 201 |
| `email.envoi_groupe.max` | 10 | SendEmail | S-EM1 | ok · lignes envoi_email_destinataire = 2 |
| `email.envoi_groupe.max` | 1000 | SendEmail | S-EM2 | ok · lignes envoi_email_destinataire = 201 |
| `email.push_cv.action_auto` | oui | PushCVToContacts | S-PV1 | ok · lignes action = 4 |
| `email.push_cv.action_auto` | non | PushCVToContacts | S-PV1 | ok · lignes action = 0 · lignes envoi_email = 1 |
| `cv.lecteur` | hrflow | ParseCV | S-CV1 | ok · lignes profil_candidat = 0 |
| `cv.lecteur` | aucun | ParseCV | S-CV1 | refus GARDE |
| `cv.lecteur` | autre | ParseCV | S-CV1 | ok · lignes profil_candidat = 0 |
| `outlook.synchro` | oui | SyncOutlookEvent | S-OU1 | ok · lignes lien_outlook = 1 |
| `outlook.synchro` | non | SyncOutlookEvent | S-OU1 | refus GARDE |
| `outlook.synchro` | oui | RecordOutlookMail | S-OU2 | ok · lignes action = 1 · lignes lien_outlook = 1 |
| `outlook.synchro` | non | RecordOutlookMail | S-OU2 | refus GARDE |
| `paie.export.format` | xlsx | ExportPayroll | S-PA1 | ok · preparation_paie[N].etat = exportee · événement PayrollExported |
| `paie.export.format` | csv | ExportPayroll | S-PA1 | ok · preparation_paie[N].etat = exportee · événement PayrollExported |
| `celebrations.types` | ["anniversaire","anciennete","arrivee"] | (lecture) | S-CE1 | lu v_celebrations[*].lignes = 3 |
| `celebrations.types` | ["anciennete","arrivee"] | (lecture) | S-CE1 | lu v_celebrations[*].lignes = 2 |

- **S-EM1** — `SendEmail` à **deux** contacts de PAR, objet et corps donnés, par un compte de PAR. ⚠️ Au banc, le fournisseur est un **faux** (aucun mail ne part) ; le fournisseur réel est branché au lot 2c.
- **S-EM2** — `SendEmail` à **201** contacts.
- **Plage** de `email.envoi_groupe.max` : entier **10 → 1000**, défaut 200.
- **S-PV1** — `PushCVToContacts` d'**un** candidat à **quatre** contacts de PAR : une action par couple (candidat, contact).
- **S-CV1** — un document CV (PDF) d'un candidat ; `ParseCV` : ⭐ une **proposition** rendue à la page, **jamais** écrite seule (`lignes profil_candidat = 0`). Au banc, le lecteur est un faux qui rend une proposition fixe.
- **S-OU1** — action A du compte D ; `SyncOutlookEvent A`. **S-OU2** — un mail Outlook du compte D ; `RecordOutlookMail` vers un contact. Au banc, Outlook est un faux.
- **S-PA1** — préparation de paie de PAR pour septembre, `figee` ; `ExportPayroll`. ⚠️ Le format du **fichier** se juge par un témoin de fichier (extension, en-tête), à écrire par le BRAIN CODE ; la grammaire ne juge que la base.
- **S-CE1** — dans la semaine : un anniversaire, une ancienneté (3 ans), une arrivée ; lecture du widget. ⚠️ L'anniversaire exige la date de naissance, lue sous `LireDonneesRHSensibles` : sans elle, la ligne ne sort pas.

### Le rapport d'alertes (D-99)

| clé | valeur | commande | scénario | issue |
|---|---|---|---|---|
| `alerte.rapport.jours` | ["lun","mar","mer","jeu","ven"] | SendAlertReport | S-AR1 | ok · lignes envoi_email = 1 |
| `alerte.rapport.jours` | ["lun","mar","mer","jeu","ven"] | SendAlertReport | S-AR2 | ok · lignes envoi_email = 0 |
| `alerte.rapport.jours` | ["lun","mer","ven"] | SendAlertReport | S-AR3 | ok · lignes envoi_email = 0 |
| `alerte.rapport.heure_quotidienne` | 08:00 | SendAlertReport | S-AR1 | ok · lignes envoi_email = 1 |
| `alerte.rapport.heure_quotidienne` | 09:00 | SendAlertReport | S-AR1 | ok · lignes envoi_email = 0 |
| `alerte.rapport.jour_hebdo` | lundi | SendAlertReport | S-AR4 | ok · lignes envoi_email = 1 |
| `alerte.rapport.jour_hebdo` | vendredi | SendAlertReport | S-AR4 | ok · lignes envoi_email = 0 |
| `alerte.rapport.heure_hebdo` | 08:00 | SendAlertReport | S-AR4 | ok · lignes envoi_email = 1 |
| `alerte.rapport.heure_hebdo` | 10:00 | SendAlertReport | S-AR4 | ok · lignes envoi_email = 0 |

- **S-AR1** — mardi 08:00 à l'heure de PAR ; une alerte ouverte ; `SendAlertReport` pour PAR (quotidien). Un **second** appel le même jour → `lignes envoi_email = 0` (idempotent).
- **S-AR2** — samedi 08:00. **S-AR3** — mardi 08:00 sous `["lun","mer","ven"]`.
- **S-AR4** — lundi 08:00 ; rapport hebdomadaire.
- **Domaines** : jours `lun` → `dim` ; heures `00:00` → `23:30` par demi-heure ; servies : celles écrites ici.

## 2 · Les clés qui ne sont pas au lot 5.8

| clé | où |
|---|---|
| `referentiels.tri_alphabetique` · `ui.tableau_de_bord.widgets` · `ui.liste.<liste>.colonnes` · les clés `ui.*` | registre exécutable du **lot 3** (écrans) |
| `reprise.donnees_rh_sensibles` | ⛔ retirée (D-98) |

## 3 · Décisions

| # | Décision |
|---|---|
| **D-98** | `reprise.donnees_rh_sensibles` retirée : plus de reprise Boond (D-94) |
| **D-99** | une **seule** tâche planifiée, `SendAlertReport`, acteur `systeme` déclaré, idempotente |
| **D-100** | la signature d'une feuille de temps est un document joint à `ValidateTimesheet` |
| **D-101** | `ref_type_action` reçoit les catégories `presentation_client` et `suivi_mission` |
| **D-102** | au banc, mail, Outlook et lecteur de CV sont des **faux** déclarés ; les vrais se branchent au lot 2c |

</etat>

<source>

BRAIN, 05/10/2026. Clés : `REGISTRE_POLITIQUES_v1.md` §C.bis et §C.ter ; commandes : `SPEC_COMMANDES_L4.md` §VII,
§VIII, §X, §XI ; colonnes relevées dans `ava_brain` le 05/10 (`contrat_rh`, `facture`, `relance_facture`,
`envoi_email*`, `lien_outlook`, `preparation_paie`, `personne`, `profil_ressource`, `action`).

</source>
