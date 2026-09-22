# Grille d'inventaire — ce qu'Avaliance utilise vraiment dans Boond

Date : 17/09/2026 · À remplir par : **Ahmed, dans Boond, 1 h** · Pourquoi : c'est le point 4 du plan du 15/09, jamais fait — la seule donnée qui dit si la V1 vaut 2 500 € / mois, et **ce qu'il faudra reprendre** (table `reprise_boond`).

⭐ Règle de remplissage : un chiffre, pas un avis. « On s'en sert » ne vaut rien ; « 12 lignes, dernière le 03/09 » vaut tout. Quand Boond ne donne pas le chiffre, écrire `?` — c'est une information.

---

## A. Les objets — combien, et depuis quand

Menu Boond → chaque liste → **réinitialiser les filtres** (⚠️ les listes s'ouvrent filtrées sur un manager : le compteur du hall n'est pas le total) → lire le compteur en haut.

| Objet Boond | Total | Actifs (non archivés) | Créés depuis le 01/01/2026 | Dernier créé le | Table Ava v1 |
|---|---|---|---|---|---|
| Sociétés | | | | | `societe` |
| Contacts | | | | | `contact` |
| Candidats | | | | | `profil_candidat` |
| Ressources | | | | | `profil_ressource` |
| Besoins | | | | | `besoin` |
| Positionnements | | | | | `positionnement` |
| Projets | | | | | `projet` |
| Prestations | | | | | `prestation` |
| Actions | | | | | `action` |
| Temps (feuilles) | | | | | `temps` |
| Absences | | | | | `absence` |
| Achats | | | | | ⬜ hors V1 |
| Factures clients | | | | | ⬜ hors V1 |
| Factures fournisseurs | | | | | ⬜ hors V1 |
| Contrats (candidat / ressource) | | | | | — pas d'objet V1 : à décider |
| Produits | | | | | ⬜ hors V1 |
| Profils types | | | | | ⬜ hors V1 |

## B. Les référentiels — ce qu'il faudra faire correspondre

Administration → Paramètres. Pour chaque liste : **combien de valeurs**, et lesquelles sont **réellement portées** par au moins un objet.

| Référentiel Boond | Nb de valeurs | Valeurs vraiment utilisées (nom : nb d'objets) | Catégorie Ava qui les reçoit |
|---|---|---|---|
| Étapes candidat (14 ?) | | | `ref_etat_candidat` : brouillon · actif · sorti |
| États positionnement (9 ?) | | | `ref_etat_positionnement` : propose · presente · terminal_positif · terminal_negatif · retire |
| États besoin | | | `ref_etat_besoin` : a_pourvoir · en_recherche · pourvu · suspendu · ferme |
| États prestation | | | `ref_etat_prestation` : previsionnel · engage · clos · annule |
| États ressource | | | `ref_etat_ressource` : en_mission · disponible · sorti |
| Types d'action | | | `ref_type_action` |
| Types d'absence | | | `ref_type_absence` |
| Devises | | | `ref_devise` |
| Agences / pôles / BU | | | `unite_organisation` de la société interne |

⚠️ Une valeur Boond qui n'entre dans **aucune** catégorie Ava est une question pour le registre — l'écrire ici, pas la forcer.

## C. Les personnes — qui se connecte, et pour quoi

Administration → Managers.

| Compte | Rôle Boond | Dernière connexion | Ce qu'il fait vraiment (3 mots) | Groupe Ava pressenti |
|---|---|---|---|---|
| | | | | IA · RH · RR · Éval · Staffing/DP · Ressource · Admin · Support |

Nombre de comptes : ___ · dont connectés ces 30 derniers jours : ___ · dont ressources en self-service (temps / absences) : ___

## D. Les apps — ce qui justifie l'abonnement

Apps → pour chacune : installée, **ouverte au moins une fois ce trimestre**, par qui.

| App | Installée | Utilisée (trimestre) | Par | Remplacée par Ava V1 ? |
|---|---|---|---|---|
| PostProduction (facture client) | | | | ⛔ non — hors V1 : **Boond ou autre outil reste nécessaire** |
| ExtractPayroll (paie) | | | | ⛔ non — hors V1 |
| PlanProduction | | | | ✅ plan de charge dérivé |
| Emailing | | | | ⛔ hors V1 (F16) |
| HRFlow | | | | ⛔ hors V1 (LinkedIn différé) |
| DocTemplates | | | | ⛔ hors V1 |
| Microsoft | | | | ? |
| Viewer | | | | ? |
| Célébrations | | | | — |

## E. Le coût — ce que la V1 peut couper, et ce qu'elle ne peut pas

| Ligne | Montant / mois | Couverte par la V1 ? |
|---|---|---|
| Abonnement plateforme | | partiellement — voir A |
| Greffons (apps) | | non pour facture, paie, emailing |
| Utilisateurs | | ✅ |
| **Total** | **2 500 € ?** | |

⭐ **La question que cette grille répond :** pendant la V1, **combien** continue-t-on de payer à Boond, et **pour quoi** ? Si la réponse est « presque tout, pour la facture », la V1 ne coupe rien tant que la facture n'est pas dedans — et c'est une décision de périmètre, pas de modélisation.

## F. Ce qui n'est nulle part

Trois lignes libres : ce que quelqu'un fait dans Boond, ou à côté de Boond (Excel, mail), que ni A ni D ne montrent.

1.
2.
3.
