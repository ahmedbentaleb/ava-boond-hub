# Les questions nées du relevé Boond — classées

⭐ **15 questions, quatre rangs.** ⭐ **9 attendent encore une réponse.** Le rang dit **ce que la réponse bloque**, pas son importance.

⛔ **Aucune n'est une question de goût.** Chacune, sans réponse, oblige à **inventer** — et ce
qu'on invente à la place d'une réponse coûte une migration.

---

<quand_utiliser>

| ✅ On ouvre ce fichier | ⛔ On ne l'ouvre pas pour |
|---|---|
| Une séance de décisions avec Hamada | relire le relevé → [BOOND_CHEMINS](cartographie/BOOND_CHEMINS_2026-09-19.md) |
| Savoir ce qui bloque quoi | poser une question de goût |

⭐ **On répond dans l'ordre des rangs.** Le rang A débloque du code ; le rang D ne bloque rien.

</quand_utiliser>

---

## RANG A — ⛔ LA RÉPONSE CHANGE L'ARCHITECTURE. 4 questions.

⭐ **A-1 est descendue en B-5 le 19/09 au soir** : mesuré, Portaliance porte 2 candidats et 0 ressource.
Elle ne bloque plus le montage de la base.

| # | La question | Ce qui est bloqué | Ce qu'on fait sans réponse |
|---|---|---|---|
| **A-2** | **`Validé`** et **`Gagné`** sont tous deux des états positifs de positionnement. **Lequel déclenche la prestation ?** | la garde **G1** et la commande `WinPositioning` | ⛔ on devine, et la mauvaise moitié des missions ne se crée pas |
| **A-3** | **Les temps ne sont pas saisis dans Boond** — le module est fermé (403), il n'y a pas d'entrée au menu. **On les introduit en V1 ?** | **DEC-02, F32, ATL-08** et tout le CA **produit** | ⚠️ on code un module que personne n'utilisera, ou on coupe le calcul de marge réel |
| **A-4** | Boond sait refuser **un champ** (« tu modifies la fiche, pas la colonne manager »). **On reprend ce niveau de finesse ?** | **M-13** et la taille de la matrice des droits | ⚠️ on livre moins fin que l'existant — ou on multiplie la matrice par le nombre de colonnes, et elle devient illisible donc fausse |
| **A-5** | **204 ressources actives, 9 prestations en cours, et tous les TJM à `0,00 €`.** Le module Production est-il **abandonné**, ou Avaliance porte-t-elle un **intercontrat massif** ? | l'ordre des lots, et ce que le tableau de bord montre en premier | ⚠️ on construit un outil de production pour une maison qui n'en saisit pas — ou on rate le sujet n° 1 |

⭐ **Il ne reste plus rien qui bloque Grok.** A-1 est tombée à la mesure ; A-2 à A-5 se posent
avant le **lot 2**, pas avant les fondations.

⭐ **Ma recommandation sur A-4, si tu veux un défaut** : ⛔ **non**, pas en V1. Un droit par champ
transforme 396 cases en plusieurs milliers. ⚠️ Mais on note les 2 ou 3 champs qui le méritent
vraiment — le coût, le manager — et on en fait des **permissions séparées**. C'est déjà ce
qu'on fait pour `cout_reference`.

---

## RANG B — ⚠️ LA RÉPONSE CHANGE LA REPRISE. 5 questions.

| # | La question | Ce qui est bloqué |
|---|---|---|
| **B-1** | **Blacklist** : deux états Boond (`Blacklisté Avaliance`, `Blacklisté Portaliance`). Chez nous : un **état**, ou un **drapeau** sur la personne ? | la correspondance `ref_etat_candidat`, et ce qu'on voit d'un coup d'œil |
| **B-2** | **Les besoins en `P1`/`P2`/`P3` ont perdu leur état** — Boond mélange priorité et cycle. À la reprise : on **redemande**, ou on **déduit** des positionnements ? | `reprise_boond`, et la justesse de 22 besoins créés ce mois-ci |
| **B-3** | **Données sensibles RH** vues dans `Administratif` : n° de sécurité sociale, situation familiale, nationalité, lieu de naissance. **On les reprend ?** | la reprise, et ce qu'on a le droit de garder |
| **B-5** | **PORTALIANCE** — ⭐ *anciennement A-1*. Mesuré : absente du CRM, **0 ressource**, **2 candidats blacklistés** contre 168 chez Avaliance. Agence de plus, ou société à part ? | ⭐ **recommandation : une agence.** Et on écrit un ADR « pas maintenant » pour `agence.societe_id`, le jour où une vraie filiale arrive |
| **B-4** | **Le contrat RH** (avec son renouvellement) est en V1, ou hors V1 ? Notre `periode_emploi` en porte l'histoire, mais pas le document | le périmètre de la fiche ressource |

⭐ **Ma recommandation sur B-1, si tu veux un défaut** : un **drapeau**. Une blacklist n'est pas
une étape d'un cycle — un candidat blacklisté n'« avance » pas vers autre chose. ⚠️ Et en faire
un état oblige à le retirer pour le réactiver, donc à perdre la trace.

⭐ **Sur B-3** : ⛔ **on ne reprend pas** par défaut. Ces champs ne servent ni au staffing ni à la
marge. Les reprendre, c'est porter un risque sans contrepartie.

---

## RANG C — ⬜ CONFIRMER UNE COUPE. 3 questions.

| # | La question | La mesure qui la porte |
|---|---|---|
| **C-1** | **Achats / Factures fournisseurs / Paiements** — on coupe en V1 ? | ⭐ **1 seule ligne** dans toute la base |
| **C-2** | **Facturation client** — on coupe ? | ⭐ **0 coordonnée de facturation** sur SODEXO, le plus gros client |
| **C-3** | **Profils types** et **Produits** — on les écarte ? | ✅ **mesuré** : 0 profil type, 1 produit — et c'est `AVAMANAGER` à 30 €/mois, un essai |

⭐ **C-1 et C-2 ne sont pas vraiment des questions** : la mesure a déjà répondu. Il suffit de le
**dire une fois**, pour que personne ne rouvre le sujet dans trois mois.

---

## RANG D — ❓ À VÉRIFIER PAR MOI, pas par Hamada. 3 points.

| # | À vérifier | Pourquoi je ne demande pas |
|---|---|---|
| **D-1** | Les **pôles** | ✅ **levé** — 2 pôles : `POLE RH` et `POLE SALES`. Le « POLE BM » était **mon erreur de lecture** sur une capture réduite |
| **D-2** | Le périmètre **« Mes managers N-1 »** | ✅ **levé** — c'est un périmètre **dynamique** parmi d'autres (`myManagers`, `managersInMyAgencies`…), pas un type. ⭐ Chez nous, une **vue**, pas une ligne de `perimetre` |
| **D-3** | **204 ressources actives, 9 prestations en cours** | ⛔ **mesuré, et l'écart ne s'explique pas.** Il **remonte en rang A** — voir A-5 |

⭐ **Deux des trois se sont levés tout seuls**, et le troisième est devenu une vraie question.
⚠️ **D-1 était une erreur de ma part** : j'avais lu un nom sur une capture réduite. Un chiffre lu
sur une image floue n'est pas un chiffre.

---

<interdits>

| ⛔ Jamais | Le problème que ça évite |
|---|---|
| Inventer une réponse et continuer | ce qu'on invente à la place d'une réponse coûte une migration |
| Poser une question qu'un clic tranche | Hamada répond à ce que lui seul sait |
| Mélanger les rangs dans une même séance | on répond aux faciles et on repart sans les bloquantes |
| Poser une question sans dire **ce qu'elle bloque** | elle reste sans réponse, et personne ne sait ce qu'on attend |
| Poser plus de deux questions à la fois | au-delà, il décroche et tout est perdu |

</interdits>

---

<etat>

**19/09/2026 — relevé CLOS, 0 réponse d'Hamada.**

⭐ Le rang D est vide, le rang C est mesuré. Il reste **9 vraies questions** — **5 en A, 4 en B**.

| Rang | Combien | État |
|---|---|---|
| **A** — change l'architecture | **4** | ✅ **plus rien ne bloque Grok** |
| **B** — change la reprise | **5** | ⏳ avant la reprise, pas avant le code |
| **C** — confirme une coupe | 3 | ✅ **la mesure a répondu aux trois** |
| **D** — à vérifier par moi | 3 | ✅ **levés** — deux d'eux-mêmes, le troisième remonte en A-5 |

⭐ **Sur 4 des 9 questions des rangs A et B, j'ai écrit une recommandation.** Hamada tranche, mais
il tranche entre deux options nommées, pas devant une page blanche.

</etat>

---

<source>

Nées du relevé cliqué le 19/09/2026 — [BOOND_CHEMINS_2026-09-19.md](cartographie/BOOND_CHEMINS_2026-09-19.md).

⭐ **Le classement obéit à une seule règle** : le rang dit **ce que la réponse débloque**, jamais
l'importance ressentie. Une question passionnante qui ne bloque rien reste en D.

⚠️ **Ce que ce fichier ne contient pas** : les questions métier déjà posées au
[cahier des directeurs](CAHIER_RELECTURE_METIER_2026-09-17.md). Celles-ci sont **nouvelles**, et
elles viennent toutes d'un écran.

</source>
