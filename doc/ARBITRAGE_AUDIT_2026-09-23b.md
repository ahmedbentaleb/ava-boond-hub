# Arbitrage du quatrième audit — 23/09/2026 (soir)

Audit : commit `cc3ff64`, verdict **REFUSÉ**, 11 constats neufs (V-096 → V-106 : 2 critiques ·
3 élevés · 5 moyens · 1 bon). ⭐ **Les deux critiques du 3e tour sont fermés ET gardés** : re-cassés,
des portes tombent (garde d'entrée → 3 portes · table d'agence → 14 · lecture d'agence → 44).
57 sabotages, 280 portes, 31 assertions, **1 seule porte aveugle**.
V-097 revérifié : `agence.ts:202` `if (!agenceId && vu && !ligne.sinonCompte) return;` — sortie sans
aucun contrôle ; `crm.ts:170` crée toute unité de société cliente avec `agence_id` **NULL**.

<etat>

## ⬜ CE QUI RESTE À FAIRE

| # | Quoi | Constats | Qui | État |
|---|---|---|---|---|
| 1 | **Le banc repart de zéro** : le cliquet refait la base avant `make test` | V-096 | BRAIN CODE | ⬜ `_ops/prompt-brain-code-4.txt` |
| 2 | **Aucun repli silencieux** : agence nulle = périmètre du demandeur exigé ; l'unité porte toujours son agence | V-097 V-104 | CODE + BRAIN CODE (migration 009) | ⬜ |
| 3 | `P-207` et les 7 portes qui testent le seed ; la porte du « agence demandée ≠ agence lue » ; `ConvertCandidateToResource` ; `/sante` ; identité par défaut | V-096 V-098 → V-100, V-102 V-103 | CODE | ⬜ `_ops/prompt-lot2-correctifs-4.txt` |
| 4 | Les outils de garde gardés à leur tour (assertions, `verif_serveur.sh`) | V-101 | BRAIN CODE | ⬜ |
| 5 | Canon : les 11 lectures de politiques inscrites **ligne par ligne** au contrat | V-105 | BRAIN | ✅ fait |
| 6 | Cinquième audit | — | AUDIT | ⬜ clone `ava-audit-5`, base `ava_audit5`, port 3500 |

</etat>

## Décisions du BRAIN

| # | Décision | Motif |
|---|---|---|
| **D-20** | ⛔ **Le cliquet refait la base avant `make test`** (`make.sh reset` puis `test`). Un banc qui ne repart pas de zéro ne prouve rien — et la CI, elle, part toujours de zéro | V-096 : le 12/12 annoncé hier venait d'une base qui traînait une donnée écrite **avant** la garde. Sur une base neuve, `P-207` tombe |
| **D-21** | ⛔ **Aucun repli silencieux dans la résolution d'agence.** Trois cas, trois règles : agence de l'objet → on l'exige ; **agence nulle → on exige le périmètre du demandeur** ; objet introuvable → `INTROUVABLE`. Le `return` sans contrôle disparaît | V-097 : un compte de Londres renommait et archivait une unité cliente de Paris |
| **D-22** | **`unite_organisation.agence_id` n'est jamais NULL** : l'agence est celle du compte qui crée, société cliente comprise. Migration **009** : remplissage puis `NOT NULL` | V-104 : une colonne toujours nulle est une colonne morte, et c'est elle qui portait la garde |
| **D-23** | **Une porte pose elle-même le droit qu'elle teste.** Une porte qui rougit quand on ajoute une permission légitime teste le seed, pas la garde | V-099 : 7 portes tombaient dès qu'on accordait une délégation normale |
| **D-24** | **Les outils de garde sont gardés** : une porte vérifie le `\set ON_ERROR_STOP` dans le fichier d'assertions, une autre joue `verif_serveur.sh` sur une configuration fabriquée et attend un refus | V-101 : les deux outils du BRAIN pouvaient être neutralisés sans qu'une porte bouge |

## Les 11 constats neufs

| V | Verdict | Gravité retenue | Qui | Note |
|---|---|---|---|---|
| 096 | ✅ retenu | critique | CODE (P-207) + BRAIN CODE (D-20) | ⛔ le banc rouge sur base neuve annule le 12/12 d'hier |
| 097 | ✅ retenu | critique | CODE | D-21 |
| 098 | ✅ retenu | élevée | CODE | `ConvertCandidateToResource` crée dans l'agence demandée |
| 099 | ✅ retenu | élevée | CODE (banc) | D-23 |
| 100 | ✅ retenu | élevée | CODE (banc) | la seule porte aveugle restante |
| 101 | ✅ retenu | moyenne | BRAIN CODE | D-24 |
| 102 | ✅ retenu | moyenne | CODE | `/sante` répond sans toucher la base |
| 103 | ✅ retenu | moyenne | CODE | pas d'identité par défaut ; groupe inconnu = refus |
| 104 | ✅ retenu | moyenne | BRAIN CODE (009) + CODE | D-22 |
| 105 | ✅ retenu | moyenne | BRAIN | ✅ les 11 lectures sont au contrat, **ligne par ligne** |
| 106 | ✅ bonne | bonne | — | à garder |

**Compte : 10 retenus · 0 requalifié · 0 rejeté · 1 bonne.**

<source>

## Ce que ce tour apprend

| | |
|---|---|
| ⭐ La réparation tient | les deux critiques du 3e tour sont fermés **et** gardés : re-cassés, 3, 14 et 44 portes tombent. C'est la première fois qu'une correction est prouvée durable |
| ⛔ Le piège du jour | un banc vert sur une base **déjà jouée**. Le 12/12 d'hier était vrai sur ma machine et faux sur une base neuve (D-20) |
| ⭐ La leçon, la même qu'hier | ce qui n'est pas gardé finit par céder : les outils de contrôle eux-mêmes ont besoin d'une porte (D-24) |

</source>
