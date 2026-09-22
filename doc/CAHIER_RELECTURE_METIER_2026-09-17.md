# Cahier de relecture métier — Ava Manager

**À l'attention des directeurs d'Avaliance · 17 septembre 2026**

---

## Ce qu'on vous demande

Nous avons écrit comment Ava Manager doit se comporter. **Avant d'écrire la moindre ligne de logiciel**, nous voulons que vous nous disiez où nous nous sommes trompés.

Ce cahier ne demande aucune connaissance technique. Il ne contient ni table, ni code, ni écran. Il contient **ce qui va se passer** quand votre équipe travaillera, et **ce que le logiciel refusera**.

### Comment y répondre

| | |
|---|---|
| **Vous n'avez rien à écrire là où vous êtes d'accord.** | Chaque ligne porte déjà la réponse retenue aujourd'hui. Le silence vaut accord. |
| **Là où c'est faux, écrivez-le.** | Une phrase suffit : « non, chez nous c'est… ». Le numéro de la ligne nous suffit à retrouver. |
| ⭐ **Les lignes marquées ESSENTIEL** | Ce sont celles qui changent votre façon de travailler ou vos chiffres. Si vous ne devez en lire qu'une partie, lisez celles-là : **37 lignes**. |
| ○ Les lignes marquées *technique* | Choix internes, affichage, mécanique. Nous avons tranché ; regardez-les seulement si le cœur vous en dit : **24 lignes**. |
| ⛔ **La partie 4 n'est pas négociable** | Ce sont les quinze choses qu'Ava Manager rendra **impossibles**. Elles ne se règlent pas. Si l'une vous gêne, dites-le : ce serait une décision lourde, pas un réglage. |

**Trois façons de relire, par ordre d'efficacité :**

1. **Essayez le logiciel** — un simulateur jouable existe. Vous y prenez un rôle, vous faites les gestes de vos équipes, et chaque refus vous explique sa raison. C'est là qu'on voit une erreur en trente secondes. *(L'adresse est en partie 5.)*
2. **Lisez les 15 histoires** de la partie 2. Elles sont concrètes, avec des noms et des chiffres. Une histoire qui vous fait dire « ça ne se passe pas comme ça » vaut dix pages de règles.
3. **Parcourez les réglages** de la partie 3 — **82**, dont 61 de métier.

---

# Partie 1 — Ce que fait Ava Manager, en une page

Alpha, une entreprise cliente, cherche quelqu'un pour une mission. Voici le trajet, du premier appel à la facture de fin.

```
Alpha exprime un besoin
        │
        ▼
Le commercial enregistre LE BESOIN         ← la demande du client
        │
        ▼
L'équipe cherche dans le vivier ou dehors
        │
        ▼
On propose une personne : LE POSITIONNEMENT ← « cette personne pour ce besoin »
        │
        ▼
Alpha répond : retenu, ou refusé
        │  (retenu)
        ▼
On crée LE PROJET                          ← le dossier avec le client
        │
        ▼
On crée LA PRESTATION                      ← qui travaille, quand, à quelles conditions
        │
        ▼
La personne saisit son temps · on suit la charge
        │
        ▼
On clôture la prestation, puis le projet   ← la marge est figée à cet instant
```

## Les sept mots qui comptent

| Mot | Ce que c'est | À ne pas confondre avec |
|---|---|---|
| **Société** | l'entreprise cliente : Alpha | son contact |
| **Contact** | une personne chez Alpha : Alice | un candidat — ce sont deux fichiers séparés |
| **Besoin** | ce qu'Alpha demande. Il peut viser **plusieurs postes** | le projet : un besoin peut n'aboutir à rien |
| **Positionnement** | la proposition d'**une** personne sur **un** besoin | la mission : rien n'est encore signé |
| **Projet** | le dossier d'exécution avec Alpha | la prestation : un projet peut en porter plusieurs |
| **Prestation** | la mission d'**une** personne sur un projet, avec ses dates, sa charge et ses conditions économiques | le projet |
| **Candidat / Ressource** | deux **profils** d'une même personne. Un candidat peut être présenté au client ; il ne peut **pas** travailler ni saisir de temps tant que les RH ne l'ont pas passé en ressource | deux fiches distinctes — c'est la **même personne**, son historique est conservé |

⭐ **Le principe qui commande tout le reste.** Chaque fois qu'une règle pouvait se décider dans un sens ou dans l'autre, nous en avons fait **un réglage**, pas du code. Une autre société qu'Avaliance pourra trancher autrement sans refaire le logiciel. C'est la partie 3 de ce cahier. Ce qui n'est pas réglable est en partie 4, et c'est court : quinze lignes.

---

# Partie 2 — Quinze histoires. Est-ce que ça se passe comme ça chez vous ?

Chaque histoire décrit un cas réel, du début à la fin, avec ce qu'Ava Manager fera. **Lisez la fin de chaque histoire** : c'est là qu'est la règle.

---

### H1 · Placer quelqu'un qui travaille déjà chez nous

Martin, commercial, enregistre un besoin pour Alpha. Karim propose Jean, qui est salarié d'Avaliance. Alpha répond qu'elle retient Jean. Karim crée le projet, puis la mission de Jean : du 1er au 31 janvier, à 60 %. Jean saisit 0,6 jour le 4 janvier.

**Ce que fait Ava :** dès que Karim propose Jean, le besoin passe tout seul de « à pourvoir » à « en recherche » — personne n'a de bouton à penser à cliquer. Le projet, lui, **ne se crée jamais tout seul** : Karim le crée, en confirmant les informations.

✍️ *Vrai chez vous ?*

---

### H2 · Un candidat est retenu, puis embauché

Sophie, aux RH, crée la fiche candidate d'Amina. Martin ouvre un besoin chez Alpha. Sophie propose Amina. Alpha la retient. Sophie transforme alors Amina en ressource. Karim crée le projet et la mission.

**Ce que fait Ava :** la transformation **n'efface rien et ne recopie rien** — Amina reste une seule personne, avec son dossier de candidate et l'historique de sa présentation chez Alpha. Et comme le client a déjà dit oui, **on ne la re-propose pas** : créer la mission suffit.

✍️ *Vrai chez vous ?*

---

### H3 · Un besoin, deux projets

Martin ouvre un besoin chez Alpha pour **deux postes**. Karim propose Sara, Alpha la retient. Karim crée un premier projet depuis ce besoin, puis un second depuis le même besoin.

**Ce que fait Ava :** un besoin peut ouvrir **autant de projets que nécessaire**. Créer un projet ne crée aucune mission automatiquement : un projet peut rester vide un moment, c'est normal avant le chiffrage.

✍️ *Vrai chez vous ? Ou un besoin ne doit-il ouvrir qu'un seul projet ?* → aussi ligne **2** de la partie 3

---

### H4 · Sara à 60 % ici et 40 % là ⭐

Sara travaille à 60 % sur un projet. Karim l'affecte à 40 % sur un second projet, aux mêmes dates.

**Ce que fait Ava :** 60 + 40 = 100 % chaque jour, aucune alerte. Et **Sara compte pour deux postes pourvus**, pas pour une personne : on compte les missions signées, pas les têtes.

⚠️ **Nous avons hésité et corrigé le 17 septembre au soir.** Un besoin de deux postes ne devient « pourvu » que lorsque **toutes** ses missions sont signées — pas à la première. Si vous voulez pouvoir déclarer un besoin pourvu plus tôt, c'est réglable : ligne **5** de la partie 3.

✍️ *Une personne à 60 % + 40 %, c'est deux postes ou une personne ?*

---

### H5 · Quelqu'un est surchargé

Sara est déjà à 100 % en mars. Karim l'affecte à 10 % de plus, du 15 au 19 mars.

**Ce que fait Ava :** il **accepte** et **signale** 110 % sur ces cinq jours seulement. Il ne refuse pas. Le calcul se fait jour par jour, sur le calendrier de l'agence — donc les week-ends et les fériés ne comptent pas.

⚠️ Le refus est possible, mais ce n'est pas notre réglage par défaut : ligne **16**.

✍️ *Alerte, ou refus pur et simple ?*

---

### H6 · Deux missions qui ne se chevauchent pas

Paul travaille à 60 % du 1er au 9 avril, puis à 50 % du 12 au 30 avril.

**Ce que fait Ava :** aucune alerte. 60 % en début de mois et 50 % en fin de mois ne font jamais 110 % — la charge se calcule **au jour**, jamais en additionnant des pourcentages d'un mois.

✍️ *Vrai ?*

---

### H7 · Remplacer quelqu'un en cours de mission ⛔

Jean est sur une mission et a déjà saisi du temps. Il faut le remplacer par Paul au 15 janvier.

**Ce que fait Ava :** il **refuse** de changer la personne sur la mission existante. Karim doit clôturer la mission de Jean au 15, puis en créer une nouvelle pour Paul à partir du 16.

**Pourquoi c'est bloqué :** sinon les jours déjà travaillés par Jean deviendraient ceux de Paul. C'est un des quinze interdits (partie 4).

✍️ *Cette manière de faire vous convient-elle ?*

---

### H8 · Clôturer une mission, puis le projet

Une mission est clôturée, une autre est encore ouverte sur le même projet. Karim essaie de clôturer le projet.

**Ce que fait Ava :** il **refuse** tant qu'une mission est ouverte. À la clôture de chaque mission, **la marge est figée** — et si les RH changent plus tard le coût d'un salarié, **la marge déjà figée ne bouge pas**.

✍️ *Vrai ? Ou faut-il pouvoir clôturer un projet et ses missions d'un seul geste ?* → ligne **14**

---

### H9 · Un candidat sur une mission ⛔

Karim, qui a tous les droits pour créer des missions, essaie de mettre Mehdi — simple candidat — sur un projet.

**Ce que fait Ava :** il **refuse**, et ce n'est pas une question de droits : la structure même du logiciel ne sait pas rattacher un candidat à une mission. Il faut d'abord que les RH le passent en ressource.

✍️ *D'accord ?*

---

### H10 · Un droit qu'on n'a pas

Sophie est aux RH. Elle essaie de créer une fiche société.

**Ce que fait Ava :** il refuse. Martin, commercial, fait la même chose : ça passe.

⚠️ Un bouton visible n'est jamais une autorisation : c'est la commande qui est contrôlée, pas l'écran.

✍️ *La répartition RH / commercial vous convient-elle ? Détail en ligne 43.*

---

### H11 · Un besoin sans interlocuteur

Alpha appelle, on connaît la demande mais pas encore la personne à qui parler.

**Ce que fait Ava :** le besoin s'enregistre **sans contact**. En revanche, au moment de créer le **projet**, il demandera un contact — un dossier client sans interlocuteur, ça ne tient pas.

✍️ *Ou faut-il exiger le contact dès le besoin ?* → lignes **1** et **13**

---

### H12 · Archiver un service du client

Martin veut archiver le Service 1 d'Alpha, qui porte encore un besoin actif.

**Ce que fait Ava :** il refuse tant que le besoin est actif. Une fois le besoin fermé, l'archivage passe — et **tout reste consultable** : les anciens besoins, les projets, les missions, les temps. Rien n'est jamais supprimé dans Ava Manager, tout est archivé.

✍️ *Vrai ?*

---

### H13 · La même commande dans deux agences

Martin travaille sur l'agence A. Il crée un besoin chez un client de A : ça passe. Il essaie chez un client de l'agence B : refus.

**Ce que fait Ava :** chaque droit est attaché à un **périmètre**. « Créer un besoin » n'existe jamais tout seul : c'est toujours « créer un besoin **sur l'agence A** ».

✍️ *Vos périmètres sont-ils les agences, ou autre chose — pôles, équipes, régions ?*

---

### H14 · Deux casquettes qui ne se mélangent pas

On donne à Martin, en plus, un droit de **lecture** sur l'agence B.

**Ce que fait Ava :** il lit B, il continue de créer dans A — et il ne peut **toujours pas** créer dans B. Lire ailleurs ne donne jamais le droit d'écrire ailleurs.

✍️ *Vrai ?*

---

### H15 · Qui embauche ?

Léa évalue un candidat. Elle essaie ensuite de le transformer en ressource.

**Ce que fait Ava :** il refuse — seules les RH transforment un candidat en ressource. Évaluer et embaucher sont deux métiers différents.

✍️ *Qui, chez vous, a le droit de transformer un candidat en ressource ?* → ligne **43**

---

# Partie 3 — Les 82 réglages

Chaque ligne : ce qu'Ava Manager fait **aujourd'hui** (en gras), et les autres possibilités. Tout ceci se change dans l'écran d'administration, **sans développement**.

| | Combien | Ce que c'est |
|---|---|---|
| **Le métier** | **61** | lignes 1 à 61 — comment travaillent vos équipes |
| **L'installation** | **2** | lignes 62 et 63 — ce que chaque société qui installe Ava Manager décide pour elle |
| **L'apparence** | **19** | lignes 64 à 82 — le design est un réglage, pas du code |

⭐ **Le compte fait foi au registre**, pas ici : `_ops/REGISTRE_POLITIQUES_v1.md` §E. ⚠️ Les lignes **36 à 39** ont été trouvées le 18/09 dans ce cahier et **nulle part dans le registre** — c'est le registre qui a été corrigé, pas le cahier.

⭐ = à lire en priorité · ○ = technique · ⬜ = prévu, pas dans le premier lot

## Le besoin et la proposition de candidats

| # | ⭐ | La question | Aujourd'hui | Les autres choix |
|---|---|---|---|---|
| 1 | ⭐ | Faut-il un contact pour enregistrer un besoin ? | **non, facultatif** | obligatoire |
| 2 | ⭐ | Un besoin peut-il ouvrir plusieurs projets ? | **oui, autant que nécessaire** | un seul |
| 3 | ○ | Qu'est-ce qui fait passer un besoin de « à pourvoir » à « en recherche » ? | **la première personne proposée** | une commande explicite du staffing · le retour positif du client |
| 4 | ⭐ | Qui déclare un besoin « pourvu » ? | **le staffing, à la main** | automatiquement à la signature d'une mission · automatiquement à la première personne signée |
| 5 | ⭐ | Qu'exige-t-on pour déclarer « pourvu » ? | **toutes les missions signées** *(corrigé le 17/09)* | au moins une mission signée · rien |
| 6 | ⭐ | Peut-on proposer quelqu'un sur un besoin pourvu, suspendu ou fermé ? | **non, refusé** | alerte seulement · libre |
| 7 | ⭐ | Peut-on proposer deux fois la même personne sur un même besoin ? | **pas tant que la première proposition est en cours** — après un refus, oui | jamais de contrainte · jamais deux fois, même après un refus |
| 8 | ⭐ | Faut-il avoir envoyé un CV avant d'enregistrer la réponse du client ? | **oui** | non |
| 9 | ⭐ | Faut-il une qualification avant d'enregistrer la réponse du client ? | **non** | oui |

## Le projet et la mission

| # | ⭐ | La question | Aujourd'hui | Les autres choix |
|---|---|---|---|---|
| 10 | ⭐ | Un client qui dit « je le prends » crée-t-il le projet tout seul ? | **non, quelqu'un le crée** | oui, automatiquement |
| 11 | ⭐ | Faut-il un candidat retenu pour créer un projet depuis un besoin ? | **oui** | non, libre |
| 12 | ○ | Un candidat retenu **puis embauché** permet-il d'ouvrir le projet ? | **oui — c'est la même personne** | non : il faut une proposition portée par une fiche ressource |
| 13 | ⭐ | Faut-il un contact sur le projet ? | **oui, obligatoire** | facultatif |
| 14 | ⭐ | Peut-on clôturer un projet qui a encore des missions ouvertes ? | **non** | oui, en clôturant tout d'un coup |
| 15 | ○ | Après avoir embauché un candidat, faut-il le re-proposer avant de créer sa mission ? | **non** | oui |
| 16 | ⭐ | Que se passe-t-il quand quelqu'un dépasse sa charge ? | **alerte, la mission est créée** | refus · rien du tout |
| 17 | ⭐ | À partir de quel pourcentage ? | **100 %** | tout entier (80, 120…) |
| 18 | ⭐ | Peut-on annuler une mission sur laquelle du temps a été saisi ? | **non — il faut la clôturer** | oui |
| 19 | ○ | Comment gère-t-on un avenant (changement de tarif, de durée) ? | **une nouvelle mission** | *(seul choix dans ce lot)* |

## Les personnes, le temps, les absences

| # | ⭐ | La question | Aujourd'hui | Les autres choix |
|---|---|---|---|---|
| 20 | ⭐ | « En mission » / « intercontrat » : saisi ou calculé ? | **saisi à la main** | calculé depuis les missions en cours |
| 21 | ○ | Une ressource externe doit-elle avoir une société fournisseur ? | **oui, obligatoire** | facultatif |
| 22 | ⭐ | Sur quelle période peut-on saisir du temps ? | **entre le début et la fin de la mission** | idem + verrou mensuel ⬜ |
| 23 | ⭐ | Peut-on corriger du temps après la clôture d'une mission ? | **oui, tracé comme un ajustement** — la marge figée ne bouge jamais | non, refusé |
| 24 | ○ | Peut-on saisir du temps sans mission (interne, formation) ? | **non** | oui, sur un type interne ⬜ |
| 25 | ⭐ | Les temps saisis doivent-ils être validés par un responsable ? | **non, dans ce lot** | oui, par le directeur de projet ⬜ |
| 26 | ○ | Peut-on enregistrer une absence pour quelqu'un sans mission ? | **oui** | non |
| 27 | ○ | Les absences sont-elles validées ? | **non, dans ce lot** | oui, par le manager ⬜ |
| 28 | ⭐ | Peut-on saisir **plus d'une journée** de travail sur un même jour — deux missions à 0,6 + 0,6 ? | **alerte, la saisie passe** | refus · rien *(question née de la relecture du 17/09 : aucun texte antérieur ne la tranchait — c'est vous qui la tranchez)* |

## Les clients et les doublons

| # | ⭐ | La question | Aujourd'hui | Les autres choix |
|---|---|---|---|---|
| 29 | ⭐ | Qu'est-ce qui fait d'un prospect un **client** ? | **la première mission signée** | la création du projet · à la main |
| 30 | ⭐ | Jusqu'où le statut « client » se propage-t-il ? | **la branche qui contracte et les contacts de ce service** | la société seule · toute la société |
| 31 | ⭐ | Un client redevient-il prospect ? | **seulement à la main, avec un motif** | à la fin du dernier contrat · après un délai |
| 32 | ○ | Quel délai, si c'est automatique ? | **6 mois** | tout nombre de mois |
| 33 | ⭐ | Quand un contact part, que deviennent ses dossiers en cours ? | **on doit les réaffecter** | on garde les liens tels quels |
| 34 | ○ | Peut-on archiver un service qui porte encore un besoin actif ? | **non** | oui |
| 35 | ⭐ | Que fait-on si on crée une personne qui existe peut-être déjà ? | **on avertit, on n'empêche pas** | on bloque · on ignore |
| 36 | ○ | Sur quoi repère-t-on un doublon de personne ? | **l'e-mail, ou nom + prénom + date de naissance** | toute autre combinaison |
| 37 | ○ | Même question pour un contact | **on avertit** | bloquer · ignorer |
| 38 | ○ | Sur quoi ? | **e-mail, ou nom + prénom + société** | autre |
| 39 | ○ | Même question pour une société | **on avertit** | bloquer · ignorer |
| 40 | ○ | Sur quoi ? | **le nom normalisé, ou le SIREN** | autre |
| 41 | ○ | Fusionne-t-on deux doublons automatiquement ? | **jamais — une personne habilitée le fait** | *(seul choix)* |

## Le recrutement

| # | ⭐ | La question | Aujourd'hui | Les autres choix |
|---|---|---|---|---|
| 42 | ○ | Que faut-il pour qu'un dossier candidat soit « complet » ? | **nom, prénom, civilité, localisation, e-mail ou téléphone** | toute autre liste |
| 43 | ⭐ | **Qui transforme un candidat en ressource ?** | **les RH seules** | RH ou responsable recrutement · toute personne habilitée |
| 44 | ⭐ | Une embauche passe-t-elle par une approbation ? | **non, dans ce lot** | oui, du responsable recrutement ⬜ |
| 45 | ⭐ | Une qualification est-elle toujours rattachée à un besoin ? | **oui** | non, on peut qualifier dans l'absolu |
| 46 | ○ | Une nouvelle évaluation efface-t-elle la précédente ? | **non, l'historique est conservé** | *(seul choix)* |

## La charge et les chiffres

| # | ⭐ | La question | Aujourd'hui | Les autres choix |
|---|---|---|---|---|
| 47 | ⭐ | On raisonne à la journée ou à la demi-journée ? | **à la journée** | à la demi-journée |
| 48 | ○ | Le planning s'affiche par défaut... | **à la semaine** | au mois |
| 49 | ⭐ | Les missions prévisionnelles comptent-elles dans la charge ? | **oui, mais affichées à part** | non |
| 50 | ○ | Combien vaut une journée pleine ? | **1,0** | *(temps partiel hors lot)* |
| 51 | ○ | Quel calendrier fait référence ? | **celui de l'agence** | un calendrier global |
| 52 | ⭐ | Le chiffre d'affaires produit se calcule sur... | **les temps saisis** | les temps validés *(suppose la ligne 25)* |
| 53 | ⭐ | Un forfait se reconnaît... | **au prorata des jours ouvrés** | à des jalons ⬜ |
| 54 | ⭐ | Les frais entrent-ils dans la marge ? | **oui** | non |
| 55 | ⭐ | Que fait-on des devises différentes ? | **aucune conversion : on ne mélange pas** | avec un taux saisi ⬜ |
| 56 | ○ | Un taux de marge sans chiffre d'affaires s'affiche... | **« — »** | zéro |
| 57 | ⭐ | Un même projet peut-il porter des missions en **devises différentes** — un freelance payé en dirhams sur un projet facturé en euros ? | **oui — le projet s'affiche en deux lignes, jamais additionnées** | non, une seule devise par projet *(question née de la relecture du 17/09)* |

## Les droits et l'administration

| # | ⭐ | La question | Aujourd'hui | Les autres choix |
|---|---|---|---|---|
| 58 | ⭐ | Un groupe autorise, un autre restreint : qui gagne ? | **la restriction** | l'autorisation ⚠️ affaiblit toutes les restrictions nominatives |
| 59 | ⭐ | Le support peut-il agir sur vos données ? | **non, lecture seule** | oui, sur délégation ⬜ |
| 60 | ○ | Peut-on désarchiver un objet ? | **non, dans ce lot** | oui, par une commande dédiée ⬜ |
| 61 | ○ | Trace-t-on les tentatives refusées ? | **oui, à part** | non |

## L'installation — ce que chaque société décide pour elle

⭐ Ava Manager n'appartient à aucune société. Avaliance en est la **première installation** ; une autre société l'installera avec ses propres réponses aux deux lignes ci-dessous.

| # | ⭐ | La question | Aujourd'hui | Les autres choix |
|---|---|---|---|---|
| 62 | ⭐ | Comment se connecte-t-on ? | **par le compte Microsoft de la société** | par Google · par e-mail et mot de passe |
| 63 | ⭐ | Combien de temps garde-t-on un dossier candidat après le dernier contact ? | **24 mois** — au-delà, l'anonymisation est proposée | tout nombre de mois *(obligation RGPD : ce n'est pas un confort)* |

## L'apparence — le design est un réglage

⭐ **Deux personnes aux réglages opposés voient le même produit, aux mêmes endroits, avec les mêmes refus.** ⛔ Aucun réglage d'apparence ne déplace un bouton, n'en cache un, ni ne change un mot — c'est ce qui permet à l'une d'aider l'autre au téléphone.

| # | ⭐ | La question | Aujourd'hui | Les autres choix |
|---|---|---|---|---|
| 64 | ⭐ | Quelle apparence voit quelqu'un qui n'a rien choisi ? | **le jeu complet ci-dessous, tel que la société l'installe** | tout autre jeu |
| 65 | ⭐ | Chacun peut-il changer son apparence ? | **oui** | non — tout le monde voit celle de l'installation, les réglages disparaissent |
| 66 | ⭐ | La palette | **Avaliance** — vert et violet de la charte | Terminal · Ambre · Glace · Encre · Phosphore |
| 67 | ⭐ | Le fond | **sombre** | intermédiaire · clair |
| 68 | ○ | L'intensité de la couleur | **normale** — l'aplat est mélangé au fond à 50 % | discrète (20 %) · forte (100 %, la couleur de la charte telle quelle) |
| 69 | ○ | L'épaisseur des traits | **medium** | fin · large ⚠️ ne touche à aucune couleur |
| 70 | ○ | La densité | **normale** | compacte · confortable |
| 71 | ○ | La colonne d'outils, à droite | **à droite** | à gauche · masquée |
| 72 | ○ | Quels outils y figurent | **les six** — bloc-notes, alertes, assistant, à faire, indicateurs, calendrier | toute sélection, dans tout ordre |
| 73 | ○ | Lequel s'ouvre au chargement | **les alertes** | n'importe lequel des six |
| 74 | ⭐ | La couleur **ACTION** — ce sur quoi on clique | **celle de la palette** | 12 couleurs au référentiel |
| 75 | ⭐ | La couleur **STRUCTURE** — titres et filets | **celle de la palette** | les mêmes 12 ⛔ les **données** ne sont jamais colorées, le **sens** a son échelle à part |
| 76 | ○ | La police | **JetBrains Mono** | 8 autres, dont celle du système |
| 77 | ○ | Les angles | **carrés** | légers · arrondis |
| 78 | ○ | Les pastilles d'état | **en contour** | pleines |
| 79 | ○ | Les boutons d'action | **en contour** | pleins · fantômes · soulignés |
| 80 | ○ | Les blocs de chiffres | **à bande** | en contour · pleins |
| 81 | ⭐ | La coloration | **une seule couleur** | par métier — chaque bloc prend la couleur de son chemin : CRM, recrutement, staffing, production, externe |
| 82 | ⬜ | Un thème sur mesure aux couleurs d'un client | *(pas dans le premier lot)* | un éditeur de thèmes ⬜ |

---
# Partie 4 — Les quinze choses qu'Ava Manager rendra impossibles ⛔

Celles-ci **ne sont pas des réglages**. Elles sont inscrites dans la structure même des données. Aucun utilisateur, aucun administrateur, aucun développeur pressé ne pourra les contourner par un écran.

Si l'une d'elles vous gêne, dites-le : ce n'est pas un refus, c'est une décision lourde qu'il faudra reprendre — et qui a un coût.

| # | Ce qui sera impossible | Ce qui arriverait sans ce garde-fou |
|---|---|---|
| 1 | Un **candidat** ne portera jamais de mission ni de temps | du temps facturé sur quelqu'un qui n'est pas payé |
| 2 | Une proposition relie un besoin à **exactement une** personne | des propositions à deux têtes, des doublons |
| 3 | Une personne a **au plus un** dossier candidat et **un** dossier ressource | deux coûts différents pour le même salarié |
| 4 | On ne **change pas la personne** d'une mission | les jours travaillés par Jean deviennent ceux de Paul |
| 5 | Le projet ne porte **pas** de personne — ce sont ses missions qui le font | deux réponses à « qui travaille sur ce projet ? » |
| 6 | Une **marge figée à la clôture ne se réécrit jamais** | la marge d'un dossier clos change quand un salaire change |
| 7 | Un **événement d'historique** ne se modifie ni ne s'efface | l'historique ment |
| 8 | **Rien ne se supprime** — tout s'archive | des dossiers vidés de leur passé |
| 9 | Une action a **exactement un** dossier de rattachement | un journal éclaté, introuvable |
| 10 | Le temps saisi porte **la même personne** que sa mission | même conséquence que le n° 4 |
| 11 | Un besoin a **toujours** une société *(y compris vos recrutements internes : Avaliance est une société dans sa propre base)* | des besoins flottants, hors de tout périmètre |
| 12 | Un contact et un service appartiennent **à la société de leur dossier** | un besoin Alpha avec un interlocuteur Beta |
| 13 | Un droit est **toujours** attaché à un périmètre | un droit sans limite |
| 14 | Les conditions économiques d'une mission **ne suivent pas** la fiche de la personne | un changement de salaire qui réécrit le passé |
| 15 | On **n'additionne jamais** deux devises sans taux | un chiffre faux affiché comme vrai |

---

# Partie 5 — Essayez-le

Un **simulateur** reproduit toute cette logique, jouable dans un navigateur, à cette adresse :

```
https://ahmedbentaleb.github.io/ava-boond-hub/simulateur.html
```

Il Vous choisissez un rôle — commercial, RH, staffing, ressource, administrateur — et vous faites les gestes de vos équipes. Chaque refus vous dit **pourquoi** il refuse et d'où vient la règle. Un écran « Politiques » vous laisse changer les réglages de la partie 3 **en direct** et refaire le même geste pour voir la différence.

Rien n'y est enregistré : c'est un banc d'essai, pas le logiciel.

> ✍️ **Ce qui m'a surpris en l'essayant :**
>
> —
>
> —

---

# Ce que nous attendons de vous

| | |
|---|---|
| 1 | Les numéros de ce cahier où **nous nous sommes trompés**, avec une phrase |
| 2 | Ce qui **manque** : un cas de votre quotidien qu'aucune des quinze histoires ne couvre |
| 3 | Votre accord — ou vos réserves numérotées — **par écrit et daté** |

⛔ Tant que cet accord n'existe pas, aucune ligne du logiciel n'est écrite. C'est délibéré : corriger un cahier coûte une soirée, corriger un logiciel livré coûte un trimestre.

---

*Ce cahier est dérivé du cadrage métier du 16 septembre, des décisions DEC-01→18, de la feuille F1–F36 signée le 16 septembre au soir, des arbitrages G1–G15 et du registre des politiques. Il ne contient aucune règle qui ne soit tracée à sa source.*
