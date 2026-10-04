# Le jeu de démonstration — une Avaliance fictive (D-94, 05/10/2026)

> **Hamada, 05/10 :** « on n'aura pas l'export de Boond. Il faut qu'on teste avec des données à nous. »

<quand_utiliser>

| ✅ On ouvre ce fichier | ⛔ On ne l'ouvre pas pour |
|---|---|
| Savoir ce que contient la base de démonstration, et comment elle se crée | les cas précis d'une politique → `REGISTRE_EXECUTABLE.md` (ses scénarios ont leurs propres données) |
| Écrire ou relire le script qui la crée | les volumes réels de Boond → `cartographie/BOOND_CHEMINS_2026-09-19.md` |

</quand_utiliser>

<procedure>

## 0 · Ce que c'est, en une phrase

**Une société de conseil inventée, remplie comme une vraie** : des clients, des contacts, des candidats, des
consultants, des besoins, des missions, des temps saisis — pour que les écrans montrent quelque chose de vrai,
que les essais tournent sur des volumes réels, et qu'on puisse **faire une démonstration** à Avaliance et à un
futur client sans jamais montrer une donnée réelle.

## 1 · Les règles

| # | Règle | Pourquoi |
|---|---|---|
| 1 | ⭐ **Tout se crée par les commandes**, comme un utilisateur (HTTP, avec les comptes de chaque groupe) — ⛔ jamais un `INSERT` | la démonstration passe par toutes les gardes déjà auditées : si une commande refuse, le jeu le montre |
| 2 | **Aucun nom réel** : sociétés ALPHA, BETA… ; personnes tirées d'une liste de prénoms et noms fictifs ; e-mails en `@demo.ava.test` | rien de réel ne sort jamais |
| 3 | **Reproductible** : une graine fixe donne toujours la même base ; `make.sh demo` la recrée de zéro | deux personnes voient la même démonstration |
| 4 | **Les dates suivent l'horloge** : le jeu est écrit en jours relatifs à la date du jour | il ne vieillit pas |
| 5 | **Chaque état existe au moins une fois** : chaque catégorie de chaque cycle (besoin, positionnement, prestation, candidat, ressource, société, temps) | chaque écran a de quoi se montrer ; une porte le vérifie |
| 6 | **Les réglages restent à leur défaut** (ceux d'Avaliance) | on démontre Avaliance ; un autre client changera ses réglages ensuite |

## 2 · Deux tailles

| Taille | Pour | Sociétés | Contacts | Candidats | Ressources | Besoins | Projets | Prestations |
|---|---|---|---|---|---|---|---|---|
| **démo** | les écrans, les captures, une démonstration | 40 | 120 | 300 | 30 | 25 | 15 | 30 |
| **pleine** | les essais de charge, aux volumes de Boond | 2 580 | 6 000 | 20 744 | 229 | 400 | 161 | 300 |

## 3 · Ce que la démo contient

| Objet | Contenu |
|---|---|
| **Agences** | Paris (PAR) et Casablanca (CAS), chacune son fuseau et son calendrier |
| **Comptes** | un par groupe (IA, RH, RR, ÉVAL, STAF, DP, RES, ADM, SUP), à Paris ; IA, RH et STAF aussi à Casablanca |
| **Sociétés** | clients, prospects, anciens clients ; quelques fournisseurs (sous-traitance) ; deux sociétés avec un arbre d'unités (pôle → BU → service) |
| **Contacts** | 2 à 5 par société, dans leurs unités |
| **Candidats** | à tous les états ; certains positionnés, certains déjà ressources |
| **Ressources** | internes et externes (avec leur société fournisseur) ; en mission, disponibles, une sortie |
| **Besoins** | à tous les états et priorités ; en régie et en appel d'offres (R10) ; des besoins à plusieurs postes, partiellement pourvus |
| **Positionnements** | à tous les états : proposé, présenté, retenu, refusé, retiré |
| **Projets et prestations** | en régie et au forfait ; en EUR, et un en USD (devises mixtes) ; prévisionnelles, signées, closes, une annulée ; une prestation à 50 % |
| **Temps et absences** | trois mois de temps saisis sur les prestations signées ; quelques absences ; un dépassement de plafond avec alerte |
| **Actions** | appels, entretiens, relances, rattachés à un seul dossier chacun |

## 4 · Six histoires qu'on doit pouvoir raconter en démonstration

| # | Histoire | Ce qu'elle montre |
|---|---|---|
| 1 | ALPHA demande deux développeurs Java ; trois candidats positionnés ; un retenu, signé ; le besoin est à 1 / 2 | le cycle complet du staffing, la couverture |
| 2 | BETA gagne un appel d'offres sans interlocuteur : le projet est rattaché au service Achats | R10 |
| 3 | Une consultante passe de candidate à ressource, puis part en mission | conversion, état dérivé |
| 4 | Une mission en USD vendue à un client dont le coût est en EUR | une ligne par devise, jamais un total mélangé |
| 5 | Un consultant saisit 1,3 jour un même jour : alerte de plafond | les politiques au défaut |
| 6 | Un compte de Casablanca ne voit pas les besoins de Paris | le cloisonnement par agence |

</procedure>

<etat>

## 5 · Qui fait quoi

| # | Quoi | Qui | État |
|---|---|---|---|
| 1 | Ce fichier | BRAIN | ✅ 05/10 |
| 2 | Le script `outils/demo/` (HTTP, comptes par groupe, graine fixe), `make.sh demo` et `make.sh demo --pleine` | BRAIN CODE — [prompt 14](prompt-brain-code-14.txt) | ⬜ |
| 3 | La porte « chaque catégorie de chaque cycle existe dans la démo » | BRAIN CODE | ⬜ |
| 4 | Les commandes que le jeu appelle et qui n'existent pas encore (lot 5.8 : contrats, factures) : **pas dans la démo** tant qu'elles ne sont pas servies | — | règle |

</etat>

<source>

BRAIN, 05/10/2026. Volumes « pleine » : `cartographie/BOOND_CHEMINS_2026-09-19.md` §16. Remplace l'import Boond
(ancienne étape 6.3), retiré le 05/10.

</source>
