# Boond — les écrans et les chemins. Ce qui mène à quoi.

⭐ **Relevé cliqué le 19/09/2026**, dans l'instance Avaliance, connecté par Hamada.
⛔ **On ne refait pas ce que le hub a déjà** : les 59 captures d'écran sont au hub. Ici, **les
chemins** — les routes, les sous-menus, ce qui ouvre quoi.

---

<quand_utiliser>

| ✅ On ouvre ce fichier | ⛔ On ne l'ouvre pas pour |
|---|---|
| Savoir **où vit** un objet dans Boond | voir un écran → le hub, 59 captures |
| Faire correspondre un état Boond à un `ref_*` | connaître **notre** modèle → `MODELE_DONNEES` |
| Écrire la reprise (`reprise_boond`) | juger Boond — on relève, on ne commente pas |

</quand_utiliser>

---

## 1 · LES ÉTATS — mesurés, pas devinés

### 1.1 Candidat — **14 étapes** ⭐ le chiffre du modèle est confirmé

| # | Étape Boond | → catégorie `ref_etat_candidat` |
|---|---|---|
| 1 | A traiter | `actif` |
| 2 | En cours | `actif` |
| 3 | A relancer | `actif` |
| 4 | En attente | `actif` |
| 5 | Vivier | `actif` |
| 6 | Vivier++ | `actif` |
| 7 | Validé | `actif` |
| 8 | Non validé | `sorti` |
| 9 | Clos | `sorti` |
| 10 | A supprimer | `sorti` |
| 11 | Collaborateur Avaliance | `sorti` — ⚠️ il est devenu **ressource** |
| 12 | Ex Collaborateur Avaliance | `sorti` |
| 13 | Blacklisté Avaliance | `sorti` |
| 14 | Blacklisté Portaliance | `sorti` |

⚠️ **Deux marques de société dans les états** : `Avaliance` et `Portaliance`. Chez nous, une
blacklist n'est pas un état — c'est une **donnée de la personne**, valable pour toute
l'installation. ⭐ À trancher au moment de la reprise : deux états, ou un drapeau ?

⭐ **`Collaborateur Avaliance` est un piège de reprise** : ce n'est pas un état de candidat,
c'est le fait qu'un `profil_ressource` existe. Chez nous, c'est **M-3** qui le porte, pas un code.

### 1.2 Positionnement — **9 états** ⭐ confirmé

| # | État Boond | → catégorie `ref_etat_positionnement` |
|---|---|---|
| 1 | Proposé | `propose` |
| 2 | GO interne | `propose` |
| 3 | NO GO interne | `terminal_negatif` |
| 4 | CV envoyé | `presente` ⭐ c'est l'étape système `cv_partage` (BM-23) |
| 5 | Présenté Client | `presente` |
| 6 | Validé | `terminal_positif` |
| 7 | Gagné | `terminal_positif` |
| 8 | Rejeté | `terminal_negatif` |
| 9 | Désistement | `retire` |

⚠️ **`Validé` et `Gagné` sont tous deux positifs** — à trancher : lequel déclenche la prestation ?
C'est la garde **G1**. ⭐ À poser à Hamada, pas à deviner.

### 1.3 Ressource — **3 états** ⭐ exactement notre modèle

`En cours` → `en_mission` · `Intercontrat` → `disponible` · `Sortie` → `sorti`

### 1.4 Besoin — **11 entrées**, et c'est là qu'est le problème

`A traiter` · **`P1`** · **`P2`** · **`P3`** · `En cours` · `Vivier` · `Reporté` · `Gagné` ·
`Perdu` · `Abandonné` · `Stand By`

⛔⛔ **BOOND MÉLANGE LA PRIORITÉ ET L'ÉTAT DANS UNE SEULE LISTE.** P1, P2, P3 ne sont pas des
états : ce sont des **urgences**. Un besoin P1 est forcément aussi « en cours » ou « à traiter »,
et Boond force à choisir.

⭐ **C'est la preuve, cliquée, de DEC-13.** Chez nous : `ref_etat_besoin` (5 catégories) et
`ref_priorite_besoin` (P1/P2/P3) sont **deux dimensions indépendantes**. Ce n'était pas une
préférence de modélisation — c'est un défaut mesuré de l'outil qu'on remplace.

⚠️ **Conséquence directe pour la reprise** : un besoin Boond en `P1` a perdu son état. Il faudra
le **redemander**, ou le déduire de ses positionnements. ⛔ Ne pas inventer.

---

## 2 · LES CHEMINS — les routes, telles qu'elles sont

### 2.1 Le menu de gauche — 13 entrées

| Libellé | Route | Notre objet |
|---|---|---|
| Tableau de bord | `/dashboard` | le tableau de bord |
| Actions | `/actions` | `action` |
| Candidats | `/candidates` | `profil_candidat` |
| Ressources | `/resources` | `profil_ressource` |
| Profils types | `/standard-profiles` | ⬜ **rien chez nous** — à décider |
| Produits | `/products` | ⬜ **rien chez nous** — hors V1 |
| CRM ▸ | `/crm` | → Sociétés · Contacts |
| Besoins | `/opportunities` | ⭐ `besoin` |
| Positionnements | `/positionings` | `positionnement` |
| Projets ▸ | `/projectsdeliveries` | → Projets · Prestations |
| Achats ▸ | `/purchasespayments` | ⬜ hors V1 (F16) |
| Planning | `/planning` | vue calendrier |
| Reporting | `/reporting` | les états |

⭐ **Le mot le plus important du relevé : `opportunity` = besoin.** Toute la reprise passe par là,
et c'est le genre de détail qui coûte une journée si on s'en aperçoit tard.

### 2.2 Les sous-menus — trois seulement

| Entrée | Ses pages |
|---|---|
| **CRM** | Sociétés · Contacts |
| **Projets** | Projets · Prestations |
| **Achats** | Achats · Factures fournisseurs · Paiements |

### 2.3 ⭐ CE QUI MÈNE À QUOI — le chemin qui surprend

**Le positionnement n'a pas de fiche à lui.** Dans la liste `/positionings`, chaque ligne porte
**deux** liens, et aucun ne va vers un positionnement :

```
/candidates/<id>/overview        → la personne
/opportunities/<id>/positionings → le besoin, onglet « Positionnements »
```

⭐ **Un positionnement se lit toujours DEPUIS son besoin.** La liste globale n'est qu'un filtre
— pas un objet. ⚠️ C'est cohérent avec notre modèle (`positionnement.besoin_id` NOT NULL), et
ça dit comment l'écran doit se comporter : **le bouton d'un positionnement ouvre le besoin.**

### 2.4 Le menu du compte — 11 entrées

`Mon compte` (`/boondmanager/my-account/settings`) · `Ma fiche` (`/resources/<moi>`) ·
`Mes temps` · `Mes frais` · `Mes absences` · `Configuration` (`/resources/<moi>/settings`) ·
`Mes flags` · `Mon offre` · `Centre de téléchargement` · `Journal d'activité` (`/logs`) ·
`Extensions et applications` · `Administration` (`/administrator`) · `Déconnexion`

⭐ **`Ma fiche` pointe `/resources/35081`** — l'utilisateur connecté **EST une ressource**. C'est
exactement `compte.personne_id` chez nous, et c'est ce qui rend vérifiable le « soi-même » de la
matrice des droits.

⭐ **`Mes temps` vit sous la fiche ressource**, pas dans un écran à part : `/resources/<id>/times-reports`.

### 2.5 Administration — 7 pages, et ce qu'elles ne contiennent pas

`Alertes` · `Business units` · `Pôles` · `Traductions` · `Importer vos données` ·
`Espace développeur` · `Webhooks`

⛔ **Aucune page de référentiels.** Les 14 étapes et les 9 états **ne se règlent pas** : ils sont
figés par Boond. `Traductions` permet de **renommer** un libellé, pas d'ajouter une valeur.

⭐ **C'est exactement le trou qu'ADR-005 comble.** Chez nous, l'admin ajoute une valeur dans une
catégorie existante, sans toucher au code. Chez Boond, il ne peut que la renommer.

---

## 3 · LA STRUCTURE D'AVALIANCE — telle que Boond la porte

| | Ce qui est déclaré |
|---|---|
| **5 agences** | AVALIANCE FR · AVALIANCE MA · AVALIANCE NEARSHORE MA · AVALIANCE US · PORTALIANCE |
| **Pôles** | POLE SALES, + `POLE BM` **ou** `POLE RH` selon l'écran — ⚠️ **à revérifier** |
| Périmètres dynamiques | Mes agences · Mes pôles · Mes managers N-1 · Mes données |

⚠️ **PORTALIANCE est listée comme une agence**, et elle apparaît aussi dans les états de
candidat (`Blacklisté Portaliance`). ❓ **Est-ce une agence d'Avaliance, ou une autre société ?**
⛔ La réponse change ADR-000 : une base par société. À poser à Hamada.

⭐ **« Mes managers N-1 » est un périmètre dynamique** — chez nous, `perimetre` ne connaît que
agence / pôle / équipe / global. ❓ Faut-il un cinquième type ? À trancher.

---

## 4 · LES VOLUMES — mesurés le 19/09

| Objet | Compte |
|---|---|
| Candidats | **20 744** |
| Sociétés | **2 580** |
| Projets | **161** |

⚠️ **20 744 candidats pour 161 projets.** ⭐ C'est le vivier qui porte la valeur, pas la
production — la reprise devra le dire, et le sauvegarder en premier.

---

## 5 · LES ONGLETS DE CHAQUE FICHE — cliqués un par un

| Fiche | Route | Ses onglets |
|---|---|---|
| **Candidat** | `/candidates/<id>` | Synthèse · Informations · Administratif · **DTs** · Actions · Positionnements |
| **Ressource** | `/resources/<id>` | les 6 mêmes **+ Prestations · Projets · Formulaires** |
| **Besoin** | `/opportunities/<id>` | Informations · Positionnements · Actions · Projets — ⛔ **pas de Synthèse** |
| **Projet** | `/projects/<id>` | Informations · Actions · Prestations |
| **Société** | `/companies/<id>` | Synthèse · Informations · Contacts · Actions · Besoins · Projets · Achats · **Facturation** |
| **Contact** | `/contacts/<id>` | Synthèse · Informations · Actions · Besoins · Projets · Achats |

⭐ **La ressource a trois onglets de plus que le candidat** — Prestations, Projets, Formulaires.
C'est **M-1 dessiné dans l'interface** : un candidat n'a pas d'onglet où de la production
pourrait s'écrire. ⚠️ Mais voir le `+` ci-dessous : Boond ne tient pas la règle jusqu'au bout.

⭐ **`Formulaires` sur la ressource** = notre table `modele`, type `formulaire` (S-10.1).

⛔ **Aucun onglet « Services » ou « Unités » sur la société.** Boond n'a pas d'arbre
d'organisation client visible. ⚠️ Notre `unite_organisation` (BM-12) est donc **un ajout**, pas
une reprise — il n'y aura rien à importer.

---

## 6 · CE QUE LE `+` SAIT CRÉER — le vrai menu

| Depuis… | Il crée |
|---|---|
| **Candidat** | Action · Positionnement · **Besoin** · **Projet** · **Contrat** |
| **Besoin** | Action · Positionnement · **Projet** |

⛔⛔ **Depuis un CANDIDAT, Boond laisse créer un Projet et un Contrat.** C'est exactement ce que
**M-1** interdit chez nous : un candidat ne porte pas de production. ⭐ **C'est le trou que le
mur bouche** — et il est là, cliquable, dans l'outil qu'on remplace.

⭐ **Depuis un besoin : Projet.** Cohérent avec **DEC-05** — pour pourvoir un besoin, on crée le
projet DEPUIS lui. Boond fait pareil.

⚠️ **`Contrat` est un objet Boond.** Chez nous, **G8** dit que le contrat **est** la prestation
en catégorie `engage` — pas une table. À confirmer à la reprise : que porte un contrat Boond que
la prestation ne porte pas ?

---

## 7 · ⛔ CORRIGÉ — le positionnement A une fiche

⚠️⚠️ **Ce que j'avais écrit était FAUX.** J'avais conclu qu'un positionnement n'avait pas de
page parce que les deux liens de la **liste** pointent la personne et le besoin. ⛔ **Un lien
absent d'une liste ne prouve pas qu'une page n'existe pas.**

⭐ **Elle existe** : `Positionnement - POS4634`, fil d'Ariane **Besoins › fiche besoin › fiche
positionnement**, avec une navigation « 5 / 1572 » d'une carte à l'autre. On y arrive par le
**Kanban**, pas par la liste.

### Ce qu'elle porte — et c'est bien plus que chez nous

| Bloc | Champs |
|---|---|
| En-tête | **CA HT · Coût HT · Marge HT · Rentabilité** |
| Informations générales | **État** · Début · Fin · **Tarif de vente journalier** · **Nombre de jours vendus** · *Ajouter des jours gratuits* · **Taux d'occupation** · **Coût journalier moyen** · *Ajouter des CA/investissements additionnels* · Commentaire |
| Informations complémentaires | Candidat · **Besoin** · Type · Client · Responsable du besoin |
| Pied | Référence `POS4634` · créé le, par qui · journal d'activité |

⭐⭐ **LE POSITIONNEMENT PORTE DÉJÀ TOUTE L'ÉCONOMIE** — TJM, jours vendus, taux d'occupation,
CJM, marge. ⛔ **C'est la prestation AVANT la signature.**

⚠️ **Écart réel avec notre modèle** : notre `positionnement` ne porte que `tjm_propose` et sa
devise. Ni jours vendus, ni taux d'occupation, ni CJM. ⭐ **Sans eux, on ne peut pas montrer la
marge prévisionnelle d'une proposition** — et c'est ce que le commercial regarde avant d'envoyer
un prix.

⭐ **« Taux d'occupation » sur le positionnement** confirme **B-1** : la charge se raisonne dès la
proposition, pas seulement à la signature.

⬜ **« Ajouter des jours gratuits »** — un objet qu'on n'a pas. À décider.

---

## 7 bis · LA PRESTATION, elle, n'a pas de page à elle

Dans l'onglet Prestations d'un projet, une ligne pointe vers la **ressource**
(`/resources/<id>`), jamais vers elle-même. ⚠️ Elle porte pourtant sa **référence** — `MRD141`.

⬜ **À vérifier** : une prestation a-t-elle une page, comme le positionnement en avait une ?
⭐ **Je ne conclus plus rien de l'absence d'un lien** — je me suis déjà trompé une fois là-dessus.

**Quatre compteurs de référence relevés** : `PRJ167` (projet) · `MRD141` (prestation) ·
`POS4634` (positionnement) · `CCON18570` (contact) · `AO1953` (besoin) · `CAND35042` (candidat) ·
`COMP35063` (ressource) · `CBSO0015` (société). ⭐ **Huit objets, huit préfixes** — chacun a son
compteur lisible par un humain.

---

## 8 · CE QU'UN ÉCRAN DE PROJET PORTE VRAIMENT

Relevé sur PRJ167 — Forfait, SODEXO, AVALIANCE MA :

| Bloc | Champs |
|---|---|
| Informations générales | Référence · **Type** (Forfait) · Début · Fin · Responsable manager · **Agence** · **Pôle** |
| Lieu de la prestation | Adresse · Code postal · Ville · **Pays** |
| Colonne de droite | **État** · **Client** + manager · *Ajouter un contact technique* · *Ajouter un intermédiaire de facturation* · **Besoin** d'origine · **Devise** · pièces jointes |
| Onglet Prestations | **CA HT · Coût HT · Marge HT · Rentabilité**, ligne « Signé » · *Ajouter des CA/investissements additionnels* · **Créer renouvellement** |

⭐ **Trois confirmations directes du modèle :**

1. **contact technique** et **intermédiaire de facturation** existent — nos `contact_technique_id`
   et `contact_facturation_id` (US5) ne sont pas inventés.
2. **« Ajouter des CA/investissements additionnels »** — notre `prestation_ligne_ca` (US5, ATL-06).
3. **« Créer renouvellement »** — Boond avenante en **créant une nouvelle prestation**, pas en
   versionnant. ⭐ C'est notre défaut `prestation.avenant.mode = nouvelle_prestation` (ADR-006),
   confirmé par l'usage réel.

⚠️ **La devise est portée par le PROJET** (Dirham Marocain ici), pas seulement par la prestation.
⭐ Notre **D-9** dit que `projet.devise_defaut_code` est une **valeur proposée** et qu'aucun
calcul ne la lit. Le relevé ne contredit pas — mais il reste à vérifier que Boond ne calcule rien
dessus.

⭐ **« Afficher l'onglet Lots/Jalons » est un interrupteur** sur la fiche projet. Un onglet
optionnel, réglable par projet : c'est une politique, pas une fonctionnalité figée.

---

## 9 · LES ACTIONS — 8 types, et un modèle

Types mesurés au reporting : `Note` · `Rappel / To do` · `Présentation client` ·
`Suivi de mission` · `Rendez-vous` · `Appel téléphonique` · `Courrier électronique` · `Archives`

⭐ **La création d'une action propose « Utiliser un modèle »** — notre table `modele`, type
`action` (S-10.1). Le trou trouvé en comparant est bien réel : c'est ce que l'utilisateur touche
tous les jours.

⭐ **Une action créée depuis une prestation se DUPLIQUE** sur la fiche Ressource et sur la fiche
Contact — le message le dit à l'écran. ⛔ Elle ne porte pas deux propriétaires : elle est copiée.
⚠️ **Compatible avec M-9** (exactement un porteur), mais à confirmer à la reprise : deux lignes,
pas une.

⭐ **Le journal d'activité se filtre par référence** — `/logs?keywords=PRJ167`. L'historique est
accessible **par objet**, ce qui est exactement ce que `evenement_metier` doit permettre.

---

## 10 · LES VOLUMES QUI DÉCIDENT DU PÉRIMÈTRE

| Objet | Compte | Ce que ça dit |
|---|---|---|
| Candidats | **20 744** | le vivier porte la valeur |
| Sociétés | **2 580** | |
| Projets | **161** | |
| **Prestations en cours** | **9** | ⭐ la production est minuscule |
| **Achats** | **1** | ⛔ le module n'est pas utilisé |
| Contacts, sur SODEXO seul | 28 | |

⛔⛔ **UN SEUL ACHAT DANS TOUTE LA BASE.** ⭐ **F16 est tranché par la mesure, pas par un
arbitrage** : couper Achats, Factures fournisseurs et Paiements en V1 ne coûte rien à Avaliance.

⭐ **9 prestations en cours contre 20 744 candidats.** Le produit qu'on écrit est un outil de
**vivier et de staffing** avant d'être un outil de production. ⚠️ Ça devrait peser sur l'ordre
des lots.

---

## 11 · LES INDICATEURS QUE LES DIRECTEURS REGARDENT

Lus au reporting, période en cours :

| Indicateur | Notre ATL |
|---|---|
| **CA total besoins pondéré** | **ATL-11** — budget × pondération ⭐ confirmé |
| Nb besoins créés, **ventilé par les 11 états** | ⚠️ dont P1/P2/P3 — le mélange se propage jusqu'au reporting |
| Nb positionnements créés | |
| Nb projets et prestations **en cours · démarrées · arrêtées** | |
| **CA signé · Coût signé · Marge signée · Rentabilité signée** | **ATL-05, ATL-12, ATL-15** ⭐ |

⛔ **CORRIGÉ** — j'avais écrit « tout est signé, rien n'est produit ». **C'est faux.** Le
reporting *Synthèse* ne montre que le signé, mais le catalogue de widgets du tableau de bord
porte **« CA Période Facturé, CA Production, CA Signé »**. ⭐ **Boond distingue bien les trois.**

⚠️ **Ce qui reste vrai** : le CA **produit** vaut zéro chez Avaliance, puisque les temps ne sont
pas saisis. ⭐ **La fonction existe, l'usage manque** — et c'est exactement la règle d'Hamada :
on code le chemin, la société décide de s'en servir.

⛔ **Le mélange priorité/état se propage** : le reporting compte « Nb besoins créés - P1 » comme
s'il s'agissait d'un état. Chez nous, ce chiffre deviendra un croisement de deux colonnes.

---

## 12 · CE QUI EST FERMÉ, ET CE QUI N'EST PAS UTILISÉ

⭐ **Un module qu'on ne peut pas ouvrir, ou qui est vide, est un module qu'on ne reprend pas.**
Ces quatre constats valent des heures d'arbitrage.

| Constat | Mesure | Ce que ça tranche |
|---|---|---|
| **Aucune entrée « Temps » au menu** — et `/resources/<id>/times-reports` rend **403** même sur sa propre fiche | erreur 403 | ⭐ **Avaliance ne saisit pas ses temps dans Boond.** DEC-02 et F32 sont un **ajout**, pas une reprise |
| **Achats** | **1 ligne** en base | ⛔ F16 se coupe sans rien coûter |
| **Facturation** d'une société | **0 coordonnée** sur SODEXO | ⛔ pas de facturation en place |
| **Extensions** | l'extension navigateur + l'app mobile, rien d'autre | ⬜ rien à reprendre |

⚠️ **Le 403 est lui-même un relevé** : Boond refuse **à l'écran**, avec une page dédiée
(« Vous ne passerez pas », erreur 403). ⭐ Le refus est une **page**, pas un message d'erreur —
c'est un choix d'interface qu'on peut reprendre.

---

## 13 · LE CONTRAT BOOND — la question 4 se répond toute seule

L'onglet **Administratif** d'une ressource porte :

| Bloc | Contenu |
|---|---|
| **Contrat RH (0)** | « Aucun contrat RH défini ! » · *Ajouter un contrat* · **Créer un renouvellement** |
| Avantage versé (0) | |
| Document à suivre (0) | |
| Informations personnelles | **Référence candidat** · Fonction · Matricule · Date et lieu de naissance · Nationalité · **Situation** · **N° de sécurité sociale** · adresse |

⭐⭐ **Le `Contrat` de Boond est un CONTRAT RH — le contrat de travail de la ressource.** Ce n'est
pas un contrat client. ⭐ **Notre G8** (« le contrat est la prestation en catégorie `engage` »)
parle d'un contrat **commercial** : les deux objets ne se recouvrent pas, et il n'y a pas de
conflit à arbitrer.

⭐ **Le contrat RH avec son « Créer un renouvellement » est exactement notre `periode_emploi`**
(M15, 19/09) : partir, revenir, deux contrats, deux périodes, une seule personne.

⭐ **Une ressource garde sa `Référence candidat`** (`CAND35042` sur la ressource `COMP35063`).
⚠️ Boond conserve donc la trace du passage candidat → ressource. C'est **M-3 + `personne`** chez
nous : deux profils, une identité. Confirmé par l'usage.

⚠️ **Données sensibles dans Administratif** : n° de sécurité sociale, situation familiale,
nationalité, date et lieu de naissance. ⛔ **À isoler à la reprise** — ce ne sont pas des données
de staffing, et elles ne doivent pas se promener dans les mêmes écrans.

---

## 14 · LES DROITS DE BOOND — beaucoup plus fins que notre matrice

Lu dans le journal d'activité, sur une modification de rôle : le modèle de droits est un **JSON
par module**, et il porte trois choses que notre matrice n'a pas.

| Ce que Boond sait faire | Chez nous |
|---|---|
| Droits **par champ** — `fields[].writeAccess`, `assignments` sur `mainManager` | ⛔ **absent** — notre `permission` porte une commande, pas un champ |
| `creation` / `deletion` séparés **par entité** | ✅ nos commandes |
| Périmètre sur **4 axes** : agences · business units · pôles · **managers** | ⚠️ nous : agence · pôle · équipe · global — pas « managers » |
| `myAgencies`, `allAgencies`, `managersInMyAgencies`, `myManagers`… | ⭐ nos **périmètres dynamiques** |

⛔⛔ **L'écart qui compte : le droit au niveau du CHAMP.** Boond sait dire « tu peux modifier
cette fiche mais pas la colonne *manager principal* ». **M-13 ne couvre pas ça.**

⚠️ **Ce n'est pas un oubli à corriger tout de suite** : c'est une décision à prendre. Ajouter le
droit par champ multiplie la matrice par le nombre de colonnes, et c'est exactement le genre de
finesse qui rend une matrice illisible — donc fausse. ⭐ **À poser comme une question, pas comme
un manque.**

⭐ **Rôles vus** : `Super Utilisateur`, `Ex-Avaliance`. **Apps activées** : `ExtractPayroll`,
`PostProduction`, `HRFlow`, `Microsoft` (calendrier et messagerie).

---

## 15 · L'HISTORIQUE DE BOOND — 338 362 entrées

⭐ **Il trace l'AVANT et l'APRÈS**, champ par champ :

```
Rôle :
  - Ex-Avaliance
  + Super Utilisateur
Apps :
  + ExtractPayroll
  + PostProduction
```

⭐ **C'est exactement `evenement_metier.avant` / `.apres`** (JSONB), et ça confirme que le patron
tient à l'échelle : 338 362 lignes, filtrables par référence d'objet (`/logs?keywords=PRJ167`).

⛔ **Ce qu'il ne trace pas, et qu'on ajoute** : `liens.politiques` — sous quelle règle le fait
s'est produit. Boond n'a pas de politiques, donc la question ne se pose pas chez lui. ⭐ **Chez
nous, sans cette colonne, changer un réglage réécrirait le sens de tout l'historique.**

---

## 16 · LES VOLUMES, COMPLETS

| Objet | Compte |
|---|---|
| Journal d'activité | **338 362** |
| Candidats | **20 744** |
| Sociétés | **2 580** |
| **Ressources au plan de charge** | **229** |
| Projets | **161** |
| Prestations en cours | **9** |
| Achats | **1** |
| Coordonnées de facturation (SODEXO) | **0** |
| Contrats RH (ressource relevée) | **0** |

⭐ **229 ressources, 9 prestations en cours.** ⚠️ L'écart est tel qu'il faut le poser : soit les
prestations ne sont pas tenues à jour, soit 220 ressources ne sont pas en mission. **Les deux
réponses changent le produit** — et ce n'est pas à moi de trancher.

---

## 17 · LE PLANNING — un plan de charge, pas un calendrier

`/planning` → **« Plans de charge » (229 ressources)**, une ligne par ressource, une colonne par
**mois**, filtrée par type de ressource.

⭐ **Ce n'est pas un agenda.** C'est la capacité vue par mois — exactement **ATL-04**. ⚠️ Donc
`calendrier_jour_non_ouvre` (F30, ATL-01) n'a **pas d'équivalent visible** : Boond ne montre pas
le calendrier d'agence ici. ⬜ À chercher ailleurs, ou à porter comme un ajout.

---

## 18 · LA STRUCTURE, MESURÉE — le rang D est levé

| Objet d'administration | Compte | Ce que ça dit |
|---|---|---|
| **Agences** | **5** | AVALIANCE FR · MA · NEARSHORE MA · US · PORTALIANCE |
| **Pôles** | **2** | POLE RH · POLE SALES — avec un état **Visible / Archivé** ⭐ M-8 chez Boond aussi |
| **Business units** | **0** | ⛔ jamais créées |

⭐ **D-1 est levé** : il n'y a que `POLE RH` et `POLE SALES`. Le « POLE BM » que j'avais cru lire
était une **erreur de ma part** sur une capture réduite. ⚠️ Un chiffre lu sur une image floue
n'est pas un chiffre.

⭐ **0 business unit.** Avaliance n'utilise que **agences + pôles**, deux niveaux plats. ⚠️ Notre
`unite_organisation` avec son arbre et son trigger anti-boucle est donc un **ajout complet** — il
n'y aura rien à importer.

---

## 19 · LES DEUX OBJETS QU'ON N'A PAS MODÉLISÉS — C-3 se répond seul

| Objet Boond | Compte | Verdict |
|---|---|---|
| **Profils types** | **0** | ⛔ écarté — jamais utilisé |
| **Produits** | **1** | ⛔ écarté — et c'est `AVAMANAGER`, 30 €/mois |

⭐ **Le seul produit en base est notre propre logiciel.** Quelqu'un l'a saisi comme produit à
vendre. ⚠️ Ce n'est pas un usage du module : c'est un essai.

⭐ **Un profil type porte** : Titre · Tarif de vente journalier · Coût journalier · Marge ·
Rentabilité · Agence. C'est un **gabarit de prix**, pas un objet métier. ⬜ Si le besoin revient,
ce sera une politique, pas une table.

---

## 20 · LA LISTE DES BESOINS — et M-15 confirmé à l'écran

**1 926 besoins.** Références **AO1953** — AO comme appel d'offres.

| Colonne | Notre équivalent |
|---|---|
| Date · Titre · Client + contact | |
| **État** | ⚠️ affiche `P1`, `P2` — le mélange se voit dans la liste |
| **Pos. Actif** | ⭐ le nombre de positionnements **actifs** — POL `positionnement.unicite` = `actifs`, visible |
| Date de démarrage | `date_demarrage_souhaitee` |
| **CA Pond. HT** | ⭐ **ATL-11** affiché en **colonne de liste**, pas seulement au reporting |
| Manager | `manager_compte_id` |

⭐⭐ **M-15 EST CONFIRMÉ À L'ÉCRAN.** La même liste affiche `0,00 €` et `0,00 د.م` — des euros et
des dirhams, **côte à côte, sans conversion et sans total**. ⭐ C'est exactement notre règle : on
n'invente pas un taux, on groupe par devise. **Boond fait déjà comme ça.**

---

## 21 · LES RESSOURCES — l'écart est réel

**204 ressources** sous le filtre par défaut (2 états, les actives), **229** au plan de charge,
**9 prestations en cours**.

⛔⛔ **204 ressources actives pour 9 prestations en cours.** ⚠️ Deux lectures, et elles ne mènent
pas au même produit :

| Si… | Alors |
|---|---|
| les prestations **ne sont pas tenues à jour** | le module Production est abandonné, comme les Temps et les Achats |
| **195 ressources sont réellement hors mission** | Avaliance porte un intercontrat massif, et l'outil doit le montrer en premier |

⭐ **Un indice qui penche pour la première lecture** : la colonne **Tarif HT affiche `0,00 €` sur
toutes les lignes**. Les TJM ne sont pas saisis. ⚠️ Un outil de production sans tarifs n'est pas
un outil de production.

⛔ **Je ne tranche pas.** C'est D-3, et il devient une **vraie question** : mesuré, l'écart ne
s'explique pas tout seul.

---

## 22 · CE QUE LA LISTE DES ACTIONS OUVRE PAR DÉFAUT

`/actions` s'ouvre **filtrée sur soi** — « BENTALEB Ahmed » + « 5 Types ».

⭐ **Un écran qui s'ouvre sur *mes* actions, pas sur toutes.** C'est un défaut d'affichage qui
vaut une politique chez nous : `ui.liste.<ecran>.filtre_defaut`. ⚠️ **Elle n'existe pas au
registre.** ⬜ À ajouter, ou à décider qu'on ne la reprend pas.

---

## 23 · LES 23 ALERTES — `alerte_regle` n'était pas une invention

⭐⭐ **Boond a 23 alertes CONFIGURABLES**, avec pour chacune : son **périmètre**, son **type**,
son **état**, son **seuil**, et **dans quels rapports** elle entre.

| Exemples relevés, avec leur seuil |
|---|
| Actions à traiter dans moins de **0** jour |
| Candidats non mis à jour depuis plus de **30** jours |
| Ressources sans Entretien RH annuel depuis plus de **330** jours |
| Périodes d'essai se terminant dans moins de **30** jours |
| **Ressources sans contrat RH** · **sans contrat en cours** · **sans date de fin** |
| **Contrats RH dont les dates se chevauchent** |
| **Prestations non intégralement couvertes par un contrat RH** |
| Documents arrivant à expiration dans moins de **60** jours |
| Projets se terminant dans moins de **30** jours ou déjà terminés |

⭐ **C'est exactement `alerte_regle` (S-10.3)** : un code, un objet, une condition, un seuil, une
gravité. ⛔ **Ce n'était pas une invention de notre part** — c'est un besoin que l'outil existant
porte déjà, et que nous avions trouvé en comparant.

⭐⭐ **« Contrats RH dont les dates se chevauchent » est notre `EXCLUDE USING gist`** sur
`periode_emploi` (M15). ⚠️ **Boond le signale ; nous l'INTERDISONS.** ⭐ C'est toute la
différence entre une alerte et un mur — et c'est la bonne différence : deux contrats qui se
chevauchent sont une erreur de saisie, pas un fait à commenter.

⭐ **Les rapports d'alerte sont réglés** : jours d'envoi (lun→ven), heure quotidienne (08:00),
jour et heure du rapport hebdomadaire. ⭐ Quatre politiques de plus, qu'on n'a pas.

⚠️ Huit alertes affichent **« Droits insuffisants »** — Ahmed ne peut pas les voir. ⭐ Le droit
se voit **jusque dans la liste des alertes**.

---

## 24 · LA CONFIGURATION D'UN COMPTE — nos `ui.*` existent déjà chez Boond

`/resources/<id>/settings` — **9 onglets** : Intranet · **Tableau de bord** · Partage ·
**Modèles d'action** · **Objectifs** · Reporting · Notifications · Suggestions de profils ·
Configuration générale.

| Réglage vu | Chez nous |
|---|---|
| ⭐⭐ **Barre de menu** — les 12 entrées, **cochables une par une** | **`ui.menu.entrees`** — confirmé, ce n'était pas une lubie |
| **Page d'accueil** | ⬜ `ui.accueil` — **pas au registre** |
| **Mémoriser ma dernière recherche** | ⬜ **pas au registre** |
| **Opérateur entre les catégories du filtre Périmètre** : ET / OU | ⬜ **pas au registre** — et c'est fin |
| Autoriser l'appel aux API Rest **par compte** | ⬜ hors V1 |
| **Modèles d'action** comme onglet du compte | ⭐ `modele.portee_code = 'personnelle'` — confirmé |
| **Objectifs** comme onglet du compte | ⬜ hors V1, nommé |

⭐⭐ **Le tableau de bord est un CATALOGUE DE WIDGETS**, chacun `affiché` ou `Non affiché` :
Mes temps · Répartition des besoins · **CA Période Facturé, CA Production, CA Signé** · Mes frais
· CA Facturé, CA Signé · CA Signé, Marge Signée · Mes absences · Synthèse · Répartition des
candidats.

⭐ **C'est exactement notre catalogue + sélection ordonnée** (`ui.tuiles`). ⛔ Le motif qu'on a
inventé six fois dans le mock existe déjà dans l'outil qu'on remplace.

⚠️ **Trois réglages d'UI manquent à notre registre** : page d'accueil, mémoriser la dernière
recherche, opérateur ET/OU du filtre de périmètre. ⬜ **À ajouter, ou à écarter — mais à décider.**

---

## 25 · LE KANBAN — et le vrai volume du staffing

**4 488 positionnements.** Le Kanban les range en colonnes, **une par état**, avec le compte :

| État | Compte |
|---|---|
| **Proposé** | **1 572** |
| **NO GO interne** | **719** |
| **GO interne** | **188** |
| CV envoyé, Présenté Client, Validé, Rejeté, Gagné, Désistement | *reste à lire* |

⭐⭐ **L'entonnoir est lisible d'un coup d'œil** : 1 572 proposés → 719 refusés en interne →
188 GO. ⚠️ **Plus d'un positionnement sur trois meurt AVANT d'atteindre le client.**

⭐ **Le Kanban est la vraie interface du staffing** — pas la liste. On y glisse une carte d'une
colonne à l'autre, et c'est la transition d'état.

⚠️ **Notre mock a-t-il un Kanban ?** ⬜ À vérifier. S'il n'en a pas, il manque l'écran que les
gens utilisent le plus.

---

## 26 · WEBHOOKS ET API

| | |
|---|---|
| **Webhooks** | **0** — jamais créés |
| **API REST** | ✅ existe · token et clef affichés **en clair** dans `Espace développeur` |
| **Apps développeur** | **0** |
| **Traductions** | ⛔ la page rend une **erreur interne** — pas relevée |

⚠️⚠️ **La clé d'API est affichée sans masquage.** Je ne l'ai pas utilisée et je ne la recopie
nulle part. ⛔ Mais elle donne accès à **toute** la base, **sans passer par les droits d'écran** —
et quiconque ouvre cette page la voit. ⭐ **À vérifier : qui a accès à cet écran ?**

---

## 27 · LE KANBAN COMPLET — les 9 colonnes, et le vrai taux de succès

| Colonne | Compte | Part |
|---|---|---|
| **Proposé** | **1 572** | 35 % |
| NO GO interne | **719** | 16 % |
| GO interne | **188** | 4 % |
| CV envoyé | **661** | 15 % |
| Présenté Client | **123** | 3 % |
| **Rejeté** | **507** | 11 % |
| **Désistement** | **440** | 10 % |
| Validé | **80** | 2 % |
| **Gagné** | **198** | **4,4 %** |

⭐ **La somme fait exactement 4 488.** Le compte tient.

⛔⛔ **198 gagnés sur 4 488 : 4,4 %.** ⭐ Un positionnement sur vingt-trois aboutit. ⚠️ **C'est le
chiffre qui devrait être en haut du tableau de bord** — pas le nombre de candidats.

⚠️ **Deux anomalies qui se voient d'un coup d'œil, et qui n'en sont peut-être pas :**

| Ce qu'on lit | Ce que ça suggère |
|---|---|
| **GO interne 188**, mais **CV envoyé 661** | ⭐ le CV part **sans passer par le GO interne** dans la majorité des cas. L'étape existe, elle n'est pas tenue |
| **Gagné 198** > **Validé 80** | ⭐ « Validé » n'est pas une étape **avant** « Gagné » : ce sont deux issues positives **parallèles** |

⭐⭐ **Ça répond en partie à A-2** — `Validé` et `Gagné` ne se suivent pas, ils coexistent. ⛔ Mais
ça ne dit toujours pas **lequel déclenche la prestation**. La question tient.

---

## 28 · LA PRESTATION A UNE PAGE — et elle porte plus que la nôtre

⭐ **`MIS239`** — préfixe `MIS`, pas `MRD` comme je l'avais lu dans une colonne. Fil d'Ariane :
**Projets › fiche projet › fiche prestation**. Route : `/deliveries/<id>`.

⚠️ **Je ne conclus plus d'un lien absent** : la liste d'un projet pointe la ressource, mais la
prestation a bien sa page — comme le positionnement. ⭐ **Deux fois la même erreur évitée.**

### Ce qu'elle porte, et les TROIS écarts avec notre modèle

| Bloc | Champs | Chez nous |
|---|---|---|
| En-tête | **CA HT · Coût HT · Marge HT · Rentabilité**, ligne « Signé » | ✅ `snapshot_marge` |
| ⭐ | **CJM Prestation** *(541 €)* **ET CJM Contrat** | ⛔ **un seul** : `cjm_contrat` |
| Général | État · intitulé · début · fin · **64 jours ouvrés** calculés | ✅ |
| | Tarif de vente · jours vendus · *Ajouter des jours gratuits* · taux d'occupation | ⬜ **jours gratuits** absent |
| ⭐ | **Contrat** : « Aucun · Modifier » | ⭐ le lien vers le **contrat RH** — notre `periode_emploi` |
| ⭐ | **« Modifier le calendrier de la prestation »** | ⛔ **notre calendrier est par AGENCE** |
| Frais | journaliers · mensuels · **jours ouvrés annuels** · *Activer le détail des frais* | ✅ sauf le détail |
| Complémentaires | Ressource · Projet · Type · Responsable · **Besoin** · Client · ⭐ **Agence** | ⛔ **l'agence est sur le projet**, pas sur la prestation |

### ⛔⛔ L'écart qui compte : DEUX coûts journaliers

Boond distingue **CJM Contrat** — ce qu'on paie la personne, qui vient du contrat RH — et
**CJM Prestation** — le coût imputé à **cette mission**.

⭐ **Notre M-14 fige `cjm_contrat` dès la signature**, et c'est juste. ⚠️ **Mais s'il y a deux
coûts, lequel est figé, et lequel entre dans la marge ?**

| Lecture possible | Conséquence |
|---|---|
| Le **CJM Prestation** est le coût chargé — salaire + frais + structure | ⭐ c'est **lui** que la marge doit lire, pas le contrat |
| C'est une simple recopie modifiable | ⬜ alors un seul suffit, et on ne change rien |

⛔ **Je ne tranche pas.** ⭐ **Nouvelle question, rang A** — elle touche **ATL-12** et **M-14**.

---

## 29 · LA PAGE TRADUCTIONS EST CASSÉE

`/administrator/translations` rend **« ERREUR INTERNE — Boond ne peut pas traiter votre
requête »**. ⚠️ **Reproduit deux fois, dans deux sessions différentes.** Ce n'est pas un hasard.

⭐ **Ce que ça veut dire pour nous** : la seule page qui permettait de **renommer** un libellé de
référentiel **ne fonctionne pas** chez Avaliance. ⛔ Donc aujourd'hui, personne chez Avaliance ne
peut renommer quoi que ce soit — ni ajouter, ni renommer.

⭐⭐ **Le trou qu'ADR-005 comble est encore plus large qu'on ne le croyait.**

---

<etat>

**19/09/2026 — première passe. Ce qui reste à cliquer :**

| | Quoi | Pourquoi ça compte |
|---|---|---|
| ✅ | Le sous-menu **Achats** | Achats · Factures fournisseurs · Paiements — **1 seule ligne en base** |
| ✅ | Les **onglets** des 6 fiches, et ce que le `+` crée | §5 et §6 |
| ✅ | **Reporting** — les indicateurs | §11 |
| ✅ | **Planning** | §17 — un plan de charge par mois, pas un agenda |
| ✅ | **Extensions et applications** | §12 — rien à reprendre |
| ✅ | Le **journal d'activité** | §15 — 338 362 entrées, avant et après |
| ✅ | Les **temps** | §12 — **403, module fermé** |
| ✅ | L'onglet **Facturation** d'une société | §12 — 0 coordonnée |
| ✅ | Un **contrat** Boond | §13 — c'est un contrat **RH** |
| ✅ | **Pôles, business units, profils types, produits** | §18 et §19 |
| ✅ | La liste des **besoins** | §20 — et M-15 confirmé à l'écran |

| ✅ | **Alertes** | §23 — 23 alertes configurables |
| ✅ | **Configuration du compte** | §24 — nos `ui.*` existent déjà |
| ✅ | **Kanban** | §25 — 4 488 positionnements |
| ✅ | **Webhooks, API, apps** | §26 |
| ✅ | **Traductions** | §29 — ⛔ la page est **cassée**, reproduit deux fois |
| ✅ | Le **Kanban** complet | §27 — les 9 colonnes · **4,4 % de gagnés** |
| ✅ | La **fiche prestation** | §28 — elle existe, et elle porte **deux CJM** |

⭐⭐ **LE RELEVÉ EST CLOS.** 29 sections. ⛔ **Et il a produit DEUX corrections de ma part** —
voir §7 et §11. Un relevé qui ne se corrige jamais est un relevé qu'on n'a pas relu.

❓ **Cinq questions pour Hamada**, nées du relevé :
1. **PORTALIANCE** : agence d'Avaliance, ou autre société ? *(change ADR-000)*
2. **`Validé` ou `Gagné`** : lequel déclenche la prestation ? *(c'est la garde G1)*
3. **Blacklist** : un état, ou un drapeau sur la personne ?
4. **Le `Contrat` Boond** : que porte-t-il que la prestation `engage` ne porte pas ? *(G8)*
5. **Achats : 1 ligne en base.** ⭐ On confirme la coupe en V1 ?

</etat>

---

<source>

Cliqué le 19/09/2026 dans `ui.boondmanager.com`, instance Avaliance, session ouverte par Hamada
lui-même. ⛔ Aucune écriture, aucun réglage touché : lecture seule.

⭐ **Ce que ce relevé vaut, et ne vaut pas** : les états et les routes sont **lus à l'écran**,
donc sûrs. Les correspondances vers nos `ref_*` (colonne de droite des tableaux) sont **ma
proposition**, pas une mesure — elles restent à valider.

</source>
