# Relecture métier externe — le tri

Date : 19/09/2026 · Source : `REPONSE_COMPLETE_RELECTURE_METIER_AVA_MANAGER.docx` (669 lignes, 27 Ko) · Statut : ✅ **appliquée en entier le 19/09**

⭐ **C'est la relecture qu'on avait renoncé à attendre le 18/09.** Elle est arrivée. Elle est sérieuse : elle répond aux 15 histoires, aux 82 réglages, aux 15 invariants, et ajoute **18 cas métier** que le cahier ne couvrait pas.

<quand_utiliser>

Ce fichier dit **ce qu'on fait de la relecture**. Le texte intégral est dans le `.docx` sur le Bureau. Les décisions qui en sortent vont au [registre](REGISTRE_POLITIQUES_v1.md) §C et au [plan](PLAN_2026-09-19.md).

</quand_utiliser>

---

## ⭐ LA RÈGLE DE TRI — Hamada, 19/09

> « On va rester là 10 ans si on doit attendre des directeurs. Le but, c'est de faire tout paramétrable, faire un paramètre Avaliance par défaut, mais **le maximum doit être paramétrable**. C'est le but. »

⛔ **Donc on ne discute aucun choix.** Pour chaque point où le relecteur recommande autre chose :

| | Ce qu'on fait |
|---|---|
| Le comportement actuel | reste le **défaut Avaliance** — il est déjà tracé à sa source |
| La recommandation du relecteur | devient la **seconde option** de la même clé |
| Si la clé n'existe pas | ⭐ **on la crée.** C'est là qu'est le travail |

⭐ **Personne n'a à trancher.** Les deux camps ont raison, chacun dans son installation. C'est exactement ce que le principe achetait.

---

## ⬜ CE QUI RESTE À FAIRE

| # | Nature | Compte | État |
|---|---|---|---|
| **1** | **Options ajoutées à des clés existantes** — ⛔ aucun défaut n'a bougé | **11** | ✅ |
| **2** | **Clés nouvelles** au registre | **11** | ✅ |
| **3** | **Changements de schéma** — B-1, B-2, B-3, B-4 **et** M15 | **5** | ✅ |
| **4** | **Murs** — 13 validés tels quels, 2 nuancés et déjà couverts | 0 | ✅ |

⭐ **Ce que ça coûte, mesuré** — annoncé en ligne 1 comme le gel du 17/09 l'exige :

| | Avant le 19/09 | Après |
|---|---|---|
| Politiques | 82 | **93** |
| Référentiels | 27 | **31** |
| Tables | 32 | **34** |

⛔ **Zéro défaut Avaliance modifié.** Les 11 recommandations du relecteur qui divergeaient sont toutes devenues des **secondes options**.

---

## ⛔ LES 4 QUI TOUCHENT VRAIMENT LE SCHÉMA

⚠️ Ceux-là ne se règlent pas par une option : la table n'a pas la colonne.

| | Le point | Ce que ça demande | Ce que ça coûte de l'ignorer |
|---|---|---|---|
| **B-1** | ✅ **FAIT 19/09** — **L'unité du besoin** (H4, ligne 5) — « deux missions = deux postes » est faux. Deux personnes à 50 % ne font pas deux postes | `besoin.unite_couverture` (`postes` · `fte` · `les_deux`) + `besoin.fte_vise NUMERIC`. La garde `besoin.pourvu.garde_minimale` lit alors l'unité | ⭐ **le vrai trou.** Un besoin de 2 postes se déclare pourvu avec 2 mi-temps, et personne ne le voit |
| **B-2** | ✅ **FAIT 19/09** ([ADR-006](adr/ADR-006-avenant-version-datee.md)) — **L'avenant** (ligne 19) — aujourd'hui « une nouvelle mission » ; le relecteur veut une **version datée de la même mission** | `prestation_version` : `prestation_id`, `date_effet`, les conditions économiques, `version_n`. La prestation garde sa version courante | l'historique d'un TJM qui change est illisible : deux missions qui n'en sont qu'une |
| **B-3** | ✅ **FAIT** — **CA produit : provisoire ≠ validé** (lignes 52-53) | deux vues distinctes, `v_ca_provisoire_par_devise` (temps saisis) et `v_ca_realise_par_devise` (temps validés) ; + `jalon` pour le forfait, hors V1 | on montre un CA qui n'en est pas un, et quelqu'un le met dans un tableau de bord |
| **B-4** | ✅ **FAIT** — **Temps produit ≠ temps facturé** (M11) — 20 jours produits, 18 facturés | `temps.quantite_facturable` à côté de `temps.quantite` | on perd une des deux mesures, et la marge est fausse |

⭐ **B-1 et B-2 sont à faire avant le schéma** (étape 2 du plan). B-3 et B-4 sont des colonnes et des vues : ils entrent avec le schéma sans le retarder.

---

## LES 18 CAS MANQUANTS — où ils tombent

| | Le cas | Ce que ça devient |
|---|---|---|
| M1 | Prolongation simple | **B-2** (version datée) |
| M2 | TJM change en cours de mission | **B-2** |
| M3 | Mission annulée avant démarrage | ✅ déjà : état `annulee` + POL `prestation.annulation.garde` |
| M4 | Mission interrompue après démarrage | clé neuve : `prestation.interruption.mode` |
| M5 | Candidat refusé puis repositionné | ✅ déjà : le refus vit dans le positionnement (POL `positionnement.unicite`) |
| M6 | Besoin en personnes et/ou FTE | **B-1** |
| M7 | Ressource multi-agences | clé neuve : `ressource.changement_agence.mode` |
| M8 | Client groupe et filiales | ✅ déjà : l'arbre `unite` + POL `societe.passage_client.propagation` |
| M9 | Forfait non corrélé aux jours | **B-3** |
| M10 | Plafond contractuel / bon de commande | clé neuve : `projet.plafond.mode` (`aucun` · `alerte` · `refus`) |
| M11 | Temps produit ≠ facturé | **B-4** |
| M12 | Sous-traitant / freelance | ✅ déjà : ressource externe + société fournisseur + devise propre |
| M13 | Absence pendant une mission | clé neuve : `absence.impact_charge` |
| M14 | Correction après facturation | clé neuve : `correction.mode` (`evenement_compensatoire` · `avoir`) |
| M15 | Départ puis retour d'une ressource | ✅ **table `periode_emploi`** — une personne, plusieurs périodes, sans chevauchement |
| M16 | Fusion de doublons après activité | clé neuve : `doublon.fusion.previsualisation` |
| M17 | Réouverture d'une période verrouillée | clé neuve : `temps.reouverture` (dépend de `temps.periode`) |
| M18 | Projet sans besoin d'origine | clé neuve : `projet.origine_besoin` (`facultative` · `obligatoire`) |

⭐ **6 des 18 étaient déjà couverts.** 4 tombent dans les changements de schéma. **8 sont des clés neuves.**

---

## ✅ LES 15 MURS SORTENT INTACTS

13 validés tels quels. Les deux nuances demandées sont **déjà dans le modèle** :

| Mur | La nuance demandée | Où elle est déjà |
|---|---|---|
| **M-6** marge figée | « autoriser une correction traçable, sans écraser la valeur » | `evenement_metier` en ajout seul porte la correction ; le snapshot ne bouge pas. ⚠️ Reste à **exposer la valeur corrigée à côté**, pas à la place — c'est une vue, pas un mur |
| **M-8** rien ne se supprime | « prévoir l'anonymisation réglementaire » | commande `AnonymisePersonne` + POL `rgpd.duree_conservation_candidat`, entrées le 18/09 |

⭐ **Un relecteur extérieur n'a cassé aucun des 15 murs.** C'est le meilleur résultat que ce document pouvait rendre.

---

## ⚠️ À TRANCHER

| | La question | Ma recommandation |
|---|---|---|
| **A** | Les 4 réglages d'apparence que le relecteur veut changer (police système par défaut, angles légers, pastilles remplies, hiérarchie de boutons) — on change le défaut Avaliance ? | ⭐ **Non.** Ce sont ses goûts, pas un fait métier. Les 4 options existent déjà toutes : il lui suffit de les choisir |
| **B** | ~~M15 : une clé ou une table ?~~ | ✅ **tranché : une table `periode_emploi`**, écrite le 19/09 |

<source>

`REPONSE_COMPLETE_RELECTURE_METIER_AVA_MANAGER.docx`, sur le Bureau, daté de la version 1 du cahier (17/09). Comptes mesurés : 7 `BLOQUANT AVANT CODE`, 26 `MODIFIER`, 27 `VALIDER + PRÉCISER`, 56 `VALIDER`.

</source>
