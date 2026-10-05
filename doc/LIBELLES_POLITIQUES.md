# Libellés des politiques — la source unique des libellés affichés (D-114, 05/10/2026)

> Le générateur du juge lit ce fichier. Il REFUSE : une clé servie sans libellé, une valeur codée servie sans libellé, une clé nombre sans unité. Aucun libellé ne s'écrit ailleurs.

## Règles
| Genre | Libellé |
|---|---|
| code | une ligne au §2 |
| booléen | commun : « Oui » / « Non » — aucune ligne par clé |
| nombre | valeur + unité de la clé (§1), ex. « 150 % », « 6 mois ». Une unité écrite « singulier/pluriel » prend le pluriel dès que la valeur vaut 2 ou plus (« 1,5 jour », « 2 jours », « 0 jour ») |
| liste | composé des libellés de ses éléments, lus au §2 bis, ou dans la source nommée en tête du §2 bis |
| texte | la valeur telle quelle (ex. une heure « 08:00 ») ; `ui.theme.defaut` se lit comme la liste de ses réglages `ui.*`, chacun avec son libellé |

## 1 · Les clés
| Clé | Libellé | Unité (nombre seulement) |
|---|---|---|
| absence.chevauchement | Absences qui se chevauchent |  |
| absence.impact_charge | Effet d'une absence sur la charge |  |
| absence.sans_prestation | Absence hors prestation |  |
| absence.validation | Validation des absences |  |
| actions.creation_multiple | Création de plusieurs actions |  |
| alerte.actives | Alertes actives |  |
| alerte.canal | Canal des alertes |  |
| alerte.frequence | Fréquence de calcul des alertes |  |
| alerte.rapport.heure_hebdo | Heure du rapport hebdomadaire |  |
| alerte.rapport.heure_quotidienne | Heure du rapport quotidien |  |
| alerte.rapport.jour_hebdo | Jour du rapport hebdomadaire |  |
| alerte.rapport.jours | Jours du rapport quotidien |  |
| archivage.restauration | Restauration d'un objet archivé |  |
| auth.fournisseur | Mode de connexion |  |
| auth.session.duree_heures | Durée maximale d'une session | heure/heures |
| auth.session.inactivite_minutes | Expiration après inactivité | minute/minutes |
| besoin.contact | Contact sur un besoin |  |
| besoin.pourvu.garde_minimale | Condition pour déclarer pourvu |  |
| besoin.pourvu.mode | Passage d'un besoin à pourvu |  |
| besoin.projets_max | Projets par besoin |  |
| besoin.staffing.declencheur | Début de la recherche |  |
| besoin.unite_couverture | Mesure de la couverture |  |
| ca_produit.base | Base du CA produit |  |
| ca_produit.forfait.mode | CA produit d'un forfait |  |
| ca_produit.provisoire.affichage | Affichage du CA provisoire |  |
| candidat.blackliste.portee | Portée de la liste noire |  |
| candidat.complete.champs_requis | Champs d'un candidat complet |  |
| candidat.conversion.acteur | Qui convertit un candidat |  |
| candidat.note.echelle | Échelle de note des candidats |  |
| capacite.jour_ouvre | Capacité d'un jour ouvré | jour/jours |
| capacite.source | Calendrier de la capacité |  |
| celebrations.types | Célébrations annoncées |  |
| change.mode | Conversion des devises |  |
| confidentialite.autorisee | Fiches confidentielles autorisées |  |
| contact.transfert.objets_actifs | Transfert d'un contact |  |
| conversion.repositionnement_ressource | Repositionnement après conversion |  |
| correction.mode | Correction après facturation |  |
| cout.jours_base | Jours de base du coût salarié | jour/jours |
| cout.mode | Calcul du coût journalier |  |
| cv.lecteur | Lecture automatique des CV |  |
| doublon.contact.cles | Critères de doublon des contacts |  |
| doublon.contact.mode | Doublons de contacts |  |
| doublon.fusion | Fusion des doublons |  |
| doublon.fusion.previsualisation | Aperçu avant fusion |  |
| doublon.personne.cles | Critères de doublon des personnes |  |
| doublon.personne.mode | Doublons de personnes |  |
| doublon.societe.cles | Critères de doublon des sociétés |  |
| doublon.societe.mode | Doublons de sociétés |  |
| droits.support.mutation | Droits du support |  |
| droits.surcharge_restrictive | Conflit entre surcharges de droits |  |
| email.envoi_groupe.max | Plafond d'un envoi groupé | destinataire/destinataires |
| email.fournisseur | Messagerie d'envoi |  |
| email.push_cv.action_auto | Action créée à l'envoi d'un CV |  |
| facturation.condition_reglement_defaut | Échéance de paiement proposée |  |
| facturation.mode_envoi_defaut | Envoi des factures proposé |  |
| facturation.relance.jours | Relances des factures impayées |  |
| facturation.tva_defaut | Taux de TVA proposé |  |
| frais.mode | Frais dans la marge |  |
| historique.tentatives_refusees | Trace des actions refusées |  |
| i18n.langues | Langues disponibles |  |
| marge.taux.si_ca_nul | Taux de marge sans CA |  |
| modele.formulaire.actif | Champs personnalisés sur les fiches |  |
| modele.portee.defaut | Portée d'un nouveau modèle |  |
| modele.recherche.partage | Partage des recherches enregistrées |  |
| occupation.affichage_defaut | Vue d'occupation par défaut |  |
| occupation.grain | Précision de l'occupation |  |
| occupation.inclure_previsionnel | Prévisionnel dans l'occupation |  |
| outlook.synchro | Synchronisation avec Outlook |  |
| paie.export.format | Format de l'export de paie |  |
| personne.coordonnees.multiples | Plusieurs e-mails et téléphones |  |
| positionnement.cv_partage_obligatoire | Présentation du CV obligatoire |  |
| positionnement.qualification_requise_avant_decision | Qualification avant décision client |  |
| positionnement.sur_besoin_inactif | Positionnement sur besoin inactif |  |
| positionnement.unicite | Positionnements en double |  |
| prestation.annulation.garde | Annulation d'une prestation |  |
| prestation.avenant.mode | Avenant à une prestation |  |
| prestation.interruption.mode | Arrêt d'une prestation commencée |  |
| prestation.surcharge.mode | Surcharge d'une ressource |  |
| prestation.surcharge.seuil_pct | Seuil de surcharge | % |
| projet.cloture.garde | Clôture d'un projet |  |
| projet.contact | Interlocuteur d'un projet |  |
| projet.creation_depuis_besoin | Création du projet depuis un besoin |  |
| projet.depuis_besoin.garde | Condition du projet depuis un besoin |  |
| projet.depuis_besoin.garde_profil | Profil retenu pour le projet |  |
| projet.devises_mixtes | Plusieurs devises par projet |  |
| projet.origine_besoin | Besoin d'origine d'un projet |  |
| projet.plafond.mode | Plafond d'un projet |  |
| qualification.besoin_obligatoire | Qualification liée à un besoin |  |
| qualification.mesure_remplace_affichage | Mise à jour d'une qualification |  |
| recrutement.approbation | Approbation d'un recrutement |  |
| referentiels.tri_alphabetique | Listes triées par ordre alphabétique |  |
| ressource.changement_agence.mode | Changement d'agence d'une ressource |  |
| ressource.etat.mode | État d'une ressource |  |
| ressource.externe.societe_fournisseur | Fournisseur d'un externe |  |
| rgpd.duree_conservation_candidat | Conservation des candidats (RGPD) | mois |
| rh.contrat.obligatoire_avant_prestation | Contrat RH avant prestation |  |
| rh.document.alerte_jours | Alerte avant expiration d'un document | jour/jours |
| service.archivage.garde | Archivage d'un service |  |
| societe.archivage.garde | Archivage d'une société |  |
| societe.donnees_legales.requises | Données légales obligatoires |  |
| societe.groupe.propagation_statut | Statut au sein d'un groupe |  |
| societe.passage_client.declencheur | Passage d'une société en client |  |
| societe.passage_client.propagation | Étendue du statut client |  |
| societe.perimetre.mode | Périmètre d'une société |  |
| societe.retour_prospect | Retour d'un client en prospect |  |
| societe.retour_prospect.delai_mois | Délai de retour en prospect | mois |
| staffing.inter_agences | Staffing entre agences |  |
| temps.correction_apres_cloture | Correction des temps clôturés |  |
| temps.facturable.mode | Temps facturable |  |
| temps.mois_ouvert.grace_jours | Délai de saisie du mois précédent | jour/jours |
| temps.periode | Période de saisie des temps |  |
| temps.plafond_jour | Plafond de temps par jour |  |
| temps.reouverture | Réouverture d'une période close |  |
| temps.sans_prestation | Temps hors prestation |  |
| temps.signature.demandee | Signature des feuilles de temps |  |
| temps.validation | Validation des temps |  |
| ui.angle | Forme des angles |  |
| ui.bord.tuiles | Tuiles du tableau de bord |  |
| ui.bouton | Style des boutons |  |
| ui.carte | Trait coloré des cartes |  |
| ui.carte.libelle | Couleur du libellé des tuiles |  |
| ui.coloration | Couleur des tuiles |  |
| ui.couleur.action | Couleur d'action |  |
| ui.couleur.metier | Couleurs des métiers |  |
| ui.couleur.sens | Couleurs des niveaux d'alerte |  |
| ui.couleur.structure | Couleur de structure |  |
| ui.densite | Densité de l'affichage |  |
| ui.ecran.cadre | Couleur sur l'écran ouvert |  |
| ui.encre.t1 | Texte des chiffres et noms |  |
| ui.encre.t2 | Texte courant |  |
| ui.encre.t3 | Texte secondaire |  |
| ui.encre.t4 | Texte des étiquettes |  |
| ui.epaisseur | Épaisseur des traits |  |
| ui.fiche.besoin.onglets | Onglets de la fiche besoin |  |
| ui.fiche.candidat.onglets | Onglets de la fiche candidat |  |
| ui.fiche.contact.onglets | Onglets de la fiche contact |  |
| ui.fiche.prestation.onglets | Onglets de la fiche prestation |  |
| ui.fiche.projet.onglets | Onglets de la fiche projet |  |
| ui.fiche.ressource.onglets | Onglets de la fiche ressource |  |
| ui.fiche.societe.onglets | Onglets de la fiche société |  |
| ui.filet.barre | Filet des barres |  |
| ui.filet.carte | Filet des cartes |  |
| ui.filet.champ | Filet des champs |  |
| ui.filet.colonne | Filet des colonnes |  |
| ui.filet.couleur | Couleur des filets |  |
| ui.fond.barre | Fond des barres |  |
| ui.fond.carte | Fond des cartes |  |
| ui.fond.colonne | Fond des colonnes |  |
| ui.fond.force | Teinte du fond |  |
| ui.fond.image | Image de fond |  |
| ui.fond.image.perso | Image de fond personnelle |  |
| ui.fond.image.voile | Voile sur l'image de fond |  |
| ui.fond.page | Fond de la page |  |
| ui.intensite | Vivacité des couleurs |  |
| ui.liste.actions.colonnes | Colonnes de la liste des actions |  |
| ui.liste.alertes.colonnes | Colonnes de la liste des alertes |  |
| ui.liste.besoins.colonnes | Colonnes de la liste des besoins |  |
| ui.liste.candidats.colonnes | Colonnes de la liste des candidats |  |
| ui.liste.comptes.colonnes | Colonnes de la liste des comptes |  |
| ui.liste.contacts.colonnes | Colonnes de la liste des contacts |  |
| ui.liste.modeles.colonnes | Colonnes de la liste des modèles |  |
| ui.liste.positionnements.colonnes | Colonnes de la liste des positionnements |  |
| ui.liste.prestations.colonnes | Colonnes de la liste des prestations |  |
| ui.liste.projets.colonnes | Colonnes de la liste des projets |  |
| ui.liste.ressources.colonnes | Colonnes de la liste des ressources |  |
| ui.liste.societes.colonnes | Colonnes de la liste des sociétés |  |
| ui.menu.coloration | Éléments colorés du menu |  |
| ui.menu.couleur.une | Couleur unique du menu |  |
| ui.menu.couleurs | Couleur de chaque entrée |  |
| ui.menu.entrees | Entrées du menu |  |
| ui.menu.filet.intensite | Intensité du filet du menu |  |
| ui.menu.icones | Icônes du menu |  |
| ui.menu.icones.perso | Icônes personnelles du menu |  |
| ui.menu.largeur | Largeur du menu |  |
| ui.menu.pastille | Filet coloré du menu |  |
| ui.menu.selection.couleur | Couleur de l'entrée ouverte |  |
| ui.menu.titre | Libellés du menu |  |
| ui.mode | Mode d'affichage |  |
| ui.notes | Aides à l'écran |  |
| ui.ombre | Niveau d'ombre |  |
| ui.ombre.bouton | Ombre des boutons |  |
| ui.ombre.carte | Ombre des cartes |  |
| ui.ombre.tuile | Ombre des tuiles |  |
| ui.palette | Palette de couleurs |  |
| ui.pastille | Style des pastilles |  |
| ui.police | Police de caractères |  |
| ui.rail.outils | Outils de la colonne d'outils |  |
| ui.rail.ouvert | Outil ouvert au démarrage |  |
| ui.rail.position | Position de la colonne d'outils |  |
| ui.role.banc | Rôle du banc d'essai |  |
| ui.selection | Couleur de sélection |  |
| ui.selection.style | Style de sélection |  |
| ui.surface.transparence | Transparence des surfaces |  |
| ui.surface.transparence.barre | Transparence des barres |  |
| ui.surface.transparence.carte | Transparence des cartes |  |
| ui.surface.transparence.colonne | Transparence des colonnes |  |
| ui.survol | Couleur de survol |  |
| ui.tableau_de_bord.widgets | Widgets du tableau de bord |  |
| ui.theme | Thème d'affichage |  |
| ui.theme.choix_utilisateur | Thème choisi par chacun |  |
| ui.theme.defaut | Apparence par défaut |  |
| ui.tuile.clic | Tuiles cliquables |  |
| ui.vues.par_ecran | Vues de chaque écran |  |

## 2 · Les valeurs codées
| Clé | Code | Libellé |
|---|---|---|
| absence.chevauchement | alerte | Avec alerte |
| absence.chevauchement | libre | Autorisé |
| absence.chevauchement | refus | Refusé |
| absence.impact_charge | deduit_du_previsionnel | Déduite du prévisionnel |
| absence.sans_prestation | autorisee | Autorisée |
| absence.sans_prestation | refusee | Refusée |
| absence.validation | aucune | Sans validation |
| alerte.canal | ecran | À l'écran |
| alerte.frequence | temps_reel | En temps réel |
| alerte.rapport.jour_hebdo | lundi | Le lundi |
| archivage.restauration | impossible | Pas de restauration |
| auth.fournisseur | microsoft | Microsoft |
| besoin.contact | facultatif | Contact facultatif |
| besoin.contact | obligatoire | Contact obligatoire |
| besoin.pourvu.garde_minimale | aucune | Sans condition |
| besoin.pourvu.garde_minimale | tous_les_postes_signes | Tous les postes signés |
| besoin.pourvu.garde_minimale | une_prestation_signee | Une prestation signée |
| besoin.pourvu.mode | auto_par_personne_signee | Dès la première prestation signée |
| besoin.pourvu.mode | auto_par_prestation_signee | Dès la couverture atteinte |
| besoin.pourvu.mode | auto_propose_confirme | Proposé, puis confirmé |
| besoin.pourvu.mode | manuel_avec_garde | Manuel, avec contrôle |
| besoin.projets_max | illimite | Sans limite |
| besoin.projets_max | un_seul | Un seul projet |
| besoin.staffing.declencheur | commande_prise_en_charge | Prise en charge du besoin |
| besoin.staffing.declencheur | premier_positionnement | Dès le premier positionnement |
| besoin.staffing.declencheur | retour_client_retenu | Profil retenu par le client |
| besoin.unite_couverture | fte | En charge (ETP) |
| besoin.unite_couverture | postes | En postes |
| besoin.unite_couverture | postes_et_fte | En postes et en charge |
| ca_produit.base | temps_saisis | Les temps saisis |
| ca_produit.base | temps_valides | Les temps validés |
| ca_produit.forfait.mode | prorata_jours_ouvres | Au prorata des jours ouvrés |
| ca_produit.provisoire.affichage | separe_et_nomme | À part, et nommé |
| candidat.blackliste.portee | agence | Par agence |
| candidat.conversion.acteur | groupe_rh | Le groupe RH |
| candidat.conversion.acteur | groupe_rh_ou_rr | RH ou responsable recrutement |
| candidat.conversion.acteur | tout_habilite | Toute personne habilitée |
| candidat.note.echelle | 1_10 | De 1 à 10 |
| candidat.note.echelle | 1_100 | De 1 à 100 |
| candidat.note.echelle | 1_5 | De 1 à 5 |
| candidat.note.echelle | aucune | Sans note |
| capacite.source | calendrier_agence | Calendrier de l'agence |
| change.mode | aucune_conversion | Sans conversion |
| change.mode | taux_saisi | Taux saisi sur la prestation |
| contact.transfert.objets_actifs | conserver_liens | Liens conservés |
| contact.transfert.objets_actifs | reaffectation_obligatoire | Réaffectation obligatoire |
| conversion.repositionnement_ressource | non_requis | Non exigé |
| correction.mode | evenement_compensatoire | Écriture compensatoire |
| cout.mode | selon_type_ressource | Selon le type de ressource |
| cv.lecteur | hrflow | Lecteur HRFlow |
| doublon.contact.mode | avertir | Avertissement |
| doublon.contact.mode | bloquer | Blocage |
| doublon.contact.mode | ignorer | Aucun contrôle |
| doublon.fusion | manuelle_habilitee | Manuelle, par une personne habilitée |
| doublon.fusion.previsualisation | obligatoire | Aperçu obligatoire |
| doublon.personne.mode | avertir | Avertissement |
| doublon.personne.mode | bloquer | Blocage |
| doublon.personne.mode | ignorer | Aucun contrôle |
| doublon.societe.mode | avertir | Avertissement |
| doublon.societe.mode | bloquer | Blocage |
| doublon.societe.mode | ignorer | Aucun contrôle |
| droits.support.mutation | lecture_seule | Consultation seule |
| droits.surcharge_restrictive | restriction_gagne | La restriction l'emporte |
| droits.surcharge_restrictive | union_gagne | L'union l'emporte |
| email.fournisseur | microsoft | Compte Microsoft |
| facturation.condition_reglement_defaut | 30 | 30 jours |
| facturation.mode_envoi_defaut | email | Par e-mail |
| facturation.tva_defaut | 20 | 20 % |
| frais.mode | ignores | Ignorés |
| frais.mode | imputes_en_marge | Déduits de la marge |
| historique.tentatives_refusees | non_tracees | Non tracées |
| historique.tentatives_refusees | tracees_a_part | Tracées à part |
| marge.taux.si_ca_nul | tiret | Un tiret (—) |
| marge.taux.si_ca_nul | zero | 0 % |
| modele.portee.defaut | agence | L'agence du créateur |
| modele.recherche.partage | habilite | Personnes habilitées |
| occupation.affichage_defaut | semaine | Par semaine |
| occupation.grain | jour | À la journée |
| occupation.inclure_previsionnel | oui_distingue | Oui, mis à part |
| paie.export.format | xlsx | Excel (.xlsx) |
| positionnement.sur_besoin_inactif | alerte | Avec alerte |
| positionnement.sur_besoin_inactif | libre | Autorisé |
| positionnement.sur_besoin_inactif | refus | Refusé |
| positionnement.unicite | actifs | Un seul en cours |
| positionnement.unicite | aucune | Sans limite |
| positionnement.unicite | historique | Un seul, historique compris |
| prestation.annulation.garde | aucun_temps_saisi | Sans temps saisi |
| prestation.annulation.garde | libre | Toujours permise |
| prestation.avenant.mode | nouvelle_prestation | Nouvelle prestation |
| prestation.avenant.mode | version_datee | Version datée |
| prestation.interruption.mode | cloture_anticipee | Clôture anticipée |
| prestation.surcharge.mode | alerte | Avec alerte |
| prestation.surcharge.mode | refus | Refusée |
| prestation.surcharge.mode | silencieux | Sans alerte |
| projet.cloture.garde | cascade_cloture_prestations | Clôture des prestations en cascade |
| projet.cloture.garde | prestations_closes | Prestations closes d'abord |
| projet.contact | facultatif | Contact facultatif |
| projet.contact | obligatoire | Contact obligatoire |
| projet.contact | obligatoire_avant_engagement | Contact exigé avant signature |
| projet.contact | service_ou_societe | Contact, service ou société |
| projet.creation_depuis_besoin | automatique_au_retenu | Automatique quand retenu |
| projet.creation_depuis_besoin | explicite | Sur demande |
| projet.depuis_besoin.garde | libre | Sans condition |
| projet.depuis_besoin.garde | retenu_requis | Profil retenu exigé |
| projet.depuis_besoin.garde_profil | personne_avec_ressource | Personne avec fiche ressource |
| projet.depuis_besoin.garde_profil | positionnement_ressource_strict | Ressource positionnée uniquement |
| projet.devises_mixtes | autorise | Autorisées |
| projet.devises_mixtes | refus | Refusées |
| projet.origine_besoin | facultative | Besoin facultatif |
| projet.origine_besoin | obligatoire | Besoin obligatoire |
| projet.plafond.mode | aucun | Sans plafond |
| qualification.mesure_remplace_affichage | oui_historique_conserve | Remplacée, historique conservé |
| recrutement.approbation | aucune | Sans approbation |
| ressource.changement_agence.mode | nouvelle_affectation_datee | Nouvelle affectation datée |
| ressource.etat.mode | derive_avec_exceptions_tracees | Déduit, exceptions tracées |
| ressource.etat.mode | derive_des_prestations | Déduit des prestations |
| ressource.etat.mode | manuel | Saisi à la main |
| ressource.externe.societe_fournisseur | facultatif | Fournisseur facultatif |
| ressource.externe.societe_fournisseur | obligatoire | Fournisseur obligatoire |
| service.archivage.garde | aucun_besoin_ni_projet_actif | Sans besoin ni projet actif |
| service.archivage.garde | libre | Toujours permis |
| societe.archivage.garde | aucun_objet_actif | Sans objet actif |
| societe.archivage.garde | libre | Toujours permis |
| societe.groupe.propagation_statut | aucune | Aucune propagation |
| societe.passage_client.declencheur | creation_projet | Création d'un projet |
| societe.passage_client.declencheur | manuel | À la main |
| societe.passage_client.declencheur | premier_engagement_contractuel | Premier engagement signé |
| societe.passage_client.declencheur | premiere_prestation_signee | Première prestation signée |
| societe.passage_client.propagation | branche_contractante_et_contacts_du_service | Service contractant et ses contacts |
| societe.passage_client.propagation | societe_seule | La société seule |
| societe.passage_client.propagation | toute_la_societe | Toute la société |
| societe.perimetre.mode | agence_responsable | L'agence responsable |
| societe.perimetre.mode | par_besoins | Selon les besoins |
| societe.perimetre.mode | partagee | Partagée |
| societe.retour_prospect | auto_apres_delai | Après un délai |
| societe.retour_prospect | auto_fin_dernier_contrat | Fin du dernier contrat |
| societe.retour_prospect | jamais_ancien_client | Devient ancien client |
| societe.retour_prospect | manuel | À la main |
| temps.correction_apres_cloture | ajustement_trace | Ajustement tracé |
| temps.correction_apres_cloture | refus | Refusée |
| temps.facturable.mode | egal_au_produit | Égal au temps produit |
| temps.facturable.mode | saisie_separee | Saisi à part |
| temps.periode | dates_prestation | Dates de la prestation |
| temps.periode | dates_prestation_et_mois_ouvert | Prestation et mois ouvert |
| temps.plafond_jour | alerte | Avec alerte |
| temps.plafond_jour | aucun | Sans plafond |
| temps.plafond_jour | refus | Refusé |
| temps.plafond_jour | refus_avec_derogation_tracee | Refusé, sauf dérogation tracée |
| temps.reouverture | impossible | Pas de réouverture |
| temps.sans_prestation | refuse | Refusé |
| temps.validation | aucune | Sans validation |
| temps.validation | par_dp | Par le directeur de projet |
| temps.validation | par_projet | Selon le projet |
| ui.angle | ava | Style Ava |
| ui.bouton | plein | Bouton plein |
| ui.carte | aucun | Sans trait |
| ui.carte.libelle | couleur | En couleur |
| ui.coloration | comme_le_menu | Suit le menu |
| ui.couleur.action | palette | Celle de la palette |
| ui.couleur.metier | origine | Couleurs d'origine |
| ui.couleur.sens | origine | Couleurs d'origine |
| ui.couleur.structure | palette | Celle de la palette |
| ui.densite | normal | Normale |
| ui.ecran.cadre | aucun | Sans cadre |
| ui.encre.t1 | du_fond | Selon le fond |
| ui.encre.t2 | du_fond | Selon le fond |
| ui.encre.t3 | du_fond | Selon le fond |
| ui.encre.t4 | du_fond | Selon le fond |
| ui.epaisseur | medium | Moyenne |
| ui.filet.barre | du_theme | Celui du thème |
| ui.filet.carte | du_theme | Celui du thème |
| ui.filet.champ | du_theme | Celui du thème |
| ui.filet.colonne | du_theme | Celui du thème |
| ui.filet.couleur | du_theme | Celui du thème |
| ui.fond.barre | du_theme | Celui du thème |
| ui.fond.carte | du_theme | Celui du thème |
| ui.fond.colonne | du_theme | Celui du thème |
| ui.fond.force | aucune | Sans teinte |
| ui.fond.image | aucune | Sans image |
| ui.fond.image.perso | aucune | Sans image |
| ui.fond.image.voile | normal | Normal (55 %) |
| ui.fond.page | du_theme | Celui du thème |
| ui.intensite | aucune | Neutre |
| ui.menu.coloration | aucune | Rien de coloré |
| ui.menu.couleur.une | action | Couleur d'action |
| ui.menu.couleurs | celle_du_rang | Selon le rang |
| ui.menu.filet.intensite | plein | Intensité pleine |
| ui.menu.icones | celle_du_modele | Celle du modèle |
| ui.menu.icones.perso | aucune | Aucune icône |
| ui.menu.largeur | normale | Normale (214 px) |
| ui.menu.pastille | une_par_entree | Une couleur par entrée |
| ui.menu.selection.couleur | celle_de_lentree | Celle de l'entrée |
| ui.mode | clair | Mode clair |
| ui.notes | infobulle | En infobulle |
| ui.ombre | legere | Légère |
| ui.ombre.bouton | du_theme | Celle du thème |
| ui.ombre.carte | du_theme | Celle du thème |
| ui.ombre.tuile | du_theme | Celle du thème |
| ui.palette | avaliance | Palette Avaliance |
| ui.pastille | carre_plein | Carré plein |
| ui.police | lato | Police Lato |
| ui.rail.ouvert | alertes | Les alertes |
| ui.rail.position | droite | À droite |
| ui.role.banc | staffing | Chargé de staffing |
| ui.selection | action | Couleur d'action |
| ui.selection.style | fond | Fond coloré |
| ui.surface.transparence | nette | Nette (76 %) |
| ui.surface.transparence.barre | du_theme | Celle du thème |
| ui.surface.transparence.carte | du_theme | Celle du thème |
| ui.surface.transparence.colonne | du_theme | Celle du thème |
| ui.survol | du_theme | Celle du thème |
| ui.theme | ava_avaliance | Style Ava (Avaliance) |
| ui.vues.par_ecran | declarees_par_ecran | Déclarées écran par écran |

## 2 bis · Les éléments des listes

Les éléments de `ui.rail.outils` se lisent dans le référentiel `ref_outil` (colonne `libelle`), qui fait foi. Les codes d'alerte de `alerte.actives` se lisent dans le référentiel `alerte_regle` (colonne `libelle`), qui fait foi.

Les titres des widgets de `ui.tableau_de_bord.widgets` se lisent ici, et ce fichier fait foi : `WIDGETS` (serveur, lot 3) les y lit au lieu de les écrire. `defaut_avaliance` garde aussi sa ligne : il nomme une sélection, pas un code d'alerte.

| Clé | Élément | Libellé |
|---|---|---|
| alerte.actives | defaut_avaliance | Sélection par défaut d'Avaliance |
| alerte.rapport.jours | jeu | Jeudi |
| alerte.rapport.jours | lun | Lundi |
| alerte.rapport.jours | mar | Mardi |
| alerte.rapport.jours | mer | Mercredi |
| alerte.rapport.jours | ven | Vendredi |
| candidat.complete.champs_requis | civilite | Civilité |
| candidat.complete.champs_requis | email_ou_telephone | E-mail ou téléphone |
| candidat.complete.champs_requis | localisation | Lieu de résidence |
| candidat.complete.champs_requis | nom | Nom de famille |
| candidat.complete.champs_requis | prenom | Prénom |
| celebrations.types | anciennete | Ancienneté |
| celebrations.types | anniversaire | Anniversaire de naissance |
| celebrations.types | arrivee | Arrivée |
| doublon.contact.cles | email | Adresse e-mail |
| doublon.contact.cles | email_ou_telephone | E-mail ou téléphone |
| doublon.contact.cles | nom+prenom+societe | Nom, prénom et société |
| doublon.personne.cles | email | Adresse e-mail |
| doublon.personne.cles | nom+prenom+naissance | Nom, prénom, date de naissance |
| doublon.societe.cles | nom_normalise | Nom normalisé |
| doublon.societe.cles | siren | Numéro SIREN |
| facturation.relance.jours | 15 | À 15 jours |
| facturation.relance.jours | 30 | À 30 jours |
| facturation.relance.jours | 7 | À 7 jours |
| i18n.langues | fr | Français |
| ui.bord.tuiles | les_huit | Les huit tuiles |
| ui.fiche.besoin.onglets | ordre_declare | Tous, dans l'ordre prévu |
| ui.fiche.candidat.onglets | ordre_declare | Tous, dans l'ordre prévu |
| ui.fiche.contact.onglets | ordre_declare | Tous, dans l'ordre prévu |
| ui.fiche.prestation.onglets | ordre_declare | Tous, dans l'ordre prévu |
| ui.fiche.projet.onglets | ordre_declare | Tous, dans l'ordre prévu |
| ui.fiche.ressource.onglets | ordre_declare | Tous, dans l'ordre prévu |
| ui.fiche.societe.onglets | ordre_declare | Tous, dans l'ordre prévu |
| ui.liste.actions.colonnes | ordre_declare | Toutes, dans l'ordre prévu |
| ui.liste.alertes.colonnes | ordre_declare | Toutes, dans l'ordre prévu |
| ui.liste.besoins.colonnes | ordre_declare | Toutes, dans l'ordre prévu |
| ui.liste.candidats.colonnes | ordre_declare | Toutes, dans l'ordre prévu |
| ui.liste.comptes.colonnes | ordre_declare | Toutes, dans l'ordre prévu |
| ui.liste.contacts.colonnes | ordre_declare | Toutes, dans l'ordre prévu |
| ui.liste.modeles.colonnes | ordre_declare | Toutes, dans l'ordre prévu |
| ui.liste.positionnements.colonnes | besoin | Besoin visé |
| ui.liste.positionnements.colonnes | candidat | Candidat positionné |
| ui.liste.positionnements.colonnes | cout_jour_moyen | Coût journalier moyen |
| ui.liste.positionnements.colonnes | etat | État du positionnement |
| ui.liste.positionnements.colonnes | jours_vendus | Nombre de jours vendus |
| ui.liste.positionnements.colonnes | societe | Société cliente |
| ui.liste.positionnements.colonnes | tarif_vente_jour | Tarif journalier de vente |
| ui.liste.prestations.colonnes | ordre_declare | Toutes, dans l'ordre prévu |
| ui.liste.projets.colonnes | ordre_declare | Toutes, dans l'ordre prévu |
| ui.liste.ressources.colonnes | ordre_declare | Toutes, dans l'ordre prévu |
| ui.liste.societes.colonnes | ordre_declare | Toutes, dans l'ordre prévu |
| ui.menu.entrees | template_avaliance | Menu type d'Avaliance |
| ui.tableau_de_bord.widgets | ca_facture_signe | CA facturé signé |
| ui.tableau_de_bord.widgets | ca_marge_signes | CA de production signé et marge |
| ui.tableau_de_bord.widgets | ca_periode_production_signe | CA produit sur la période |
| ui.tableau_de_bord.widgets | mes_alertes | Mes alertes en cours |
| ui.tableau_de_bord.widgets | repartition_besoins | Répartition des besoins |
| ui.tableau_de_bord.widgets | repartition_candidats | Répartition des candidats |
| ui.tableau_de_bord.widgets | synthese | Synthèse |

## 3 · Hors registre

Servies en base, absentes du registre : à retirer de la base (D-98 pour la première ; sans source canon pour la seconde).

- reprise.donnees_rh_sensibles
- ui.theme.personnalise
