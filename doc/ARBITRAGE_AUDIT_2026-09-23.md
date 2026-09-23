# Arbitrage du troisième audit — 23/09/2026

Audit : commit `416a7a3`, verdict **REFUSÉ**, 21 constats neufs (V-075 → V-095 : 2 critiques ·
9 élevés · 9 moyens · 1 bon). ⭐ **Le banc est réparé** : 0 porte aveugle sur 50 sabotages
(48 → 45 → 0), 264 portes, 31 assertions, et D-10 → D-13 tenues et mesurées.
V-075 et V-076 revérifiés dans le code avant d'être tranchés (`index.ts:164` et `:200` sans garde ;
`grep -c exigeObjet` : admin 3 · besoin 6 · **crm 0** · identite 14 · projet 6).

<etat>

## ⬜ CE QUI RESTE À FAIRE

| # | Quoi | Constats | Qui | État |
|---|---|---|---|---|
| 1 | **Un seul garde en entrée** (commandes ET vues) et l'agence de l'objet résolue **en donnée** dans `executerCommande` | V-075 V-076 V-078 | CODE | ⬜ `_ops/prompt-lot2-correctifs-3.txt` |
| 2 | Les 9 élevés et 9 moyens du code | V-079 → V-084, V-086, V-088 → V-092, V-094 | CODE | ⬜ même prompt |
| 3 | Cliquet : fenêtre au point de départ de la branche, porte hors tableau = KO ; assertions avec leur propre `ON_ERROR_STOP` ; contrôle `pg_hba` outillé | V-077 V-087 V-093 | BRAIN CODE | ⬜ `_ops/prompt-brain-code-3.txt` |
| 4 | Canon : L4 (GARDE vs MUR, politiques lues), grille K1 étendue aux vues, K5 mesurable | V-085 V-089 V-093 | BRAIN | ✅ fait le 23/09 |
| 5 | Quatrième audit | — | AUDIT | ⬜ clone `ava-audit-4`, base `ava_audit4`, port 3400 |

</etat>

## ⚠️ À TRANCHER PAR AHMED

Rien.

## Décisions du BRAIN

| # | Décision | Motif |
|---|---|---|
| **D-14** | ⛔ **Le garde d'entrée est unique et couvre TOUTE route** : hors `AVA_MODE=banc`, seule `/sante` répond ; tout le reste rend 401, **y compris les vues de lecture**. En banc, une vue filtre par le périmètre du compte comme une commande | ⭐ **Ma faute** : D-10 disait « refuse tout appel », je ne l'ai écrit que pour `POST /commandes/:nom`. Une porte de lecture ouverte livre la base entière (81 besoins, 1 932 avec le jeu d'essai) |
| **D-15** | **L'agence de l'objet se résout en DONNÉE**, dans `executerCommande` : une table `commande → table → colonne d'agence`, lue avant le handler. `exigeObjet` disparaît des handlers. Une commande nouvelle sans ligne dans cette table est **refusée**, pas laissée passer | V-076 : `crm.ts` n'a jamais eu la garde. Une règle qu'on doit se rappeler d'appeler dans 55 fichiers sera oubliée une 56e fois — c'était déjà la correction proposée en H-1 |
| **D-16** | Hors banc, **un refus anonyme ne se trace pas** : 401 sec, rien en base | V-078 : 60 appels anonymes = 60 lignes avec le corps recopié. Une trace ouverte à l'anonyme est un journal qu'on remplit de l'extérieur |
| **D-17** | Cliquet : la fenêtre des portes est **`git merge-base main HEAD` → HEAD**, et « porte exécutée absente du tableau » devient un **KO**, plus un ⚠️ | V-077 : deux commits suffisaient à sortir 70 portes de la fenêtre |
| **D-18** | Le fichier d'assertions porte **`\set ON_ERROR_STOP on` en tête** : il ne dépend plus de qui le lance | V-087 : lancé à la main, il rendait `rc=0` avec 13 assertions en échec |
| **D-19** | En banc, l'en-tête désigne **le compte** (son e-mail), pas le groupe : le groupe se déduit du compte, et l'événement porte le bon auteur | V-092 : l'auteur enregistré est « le premier compte du groupe », donc faux |

## Les 21 constats neufs

| V | Verdict | Gravité retenue | Qui | Note |
|---|---|---|---|---|
| 075 | ✅ retenu | critique | **BRAIN** (D-10 incomplet) → CODE | D-14 |
| 076 | ✅ retenu | critique | CODE | D-15 — la correction est structurelle, pas commande par commande |
| 077 | ✅ retenu | élevée | BRAIN CODE | D-17 |
| 078 | ✅ retenu | élevée | CODE | D-16 |
| 079 → 084 | ✅ retenus | élevée | CODE | prestation sur projet clos, `SetPolicy`, `ArchiveObject`, `v_besoin_couverture`, `TakeNeedInCharge`, `ManageRefs` |
| 085 | ✅ retenu | élevée | BRAIN | ✅ L4 corrigé : le code refuse **mieux** que le contrat, c'est le contrat qui suit |
| 086 | ✅ retenu | moyenne | CODE | une porte qui relit `actif` après migration, avant la fixture |
| 087 | ✅ retenu | moyenne | BRAIN CODE | D-18 |
| 088 | ✅ retenu | moyenne | CODE | `NeedStateChanged` porte `{de, vers}`, lus en catégorie |
| 089 | 🔁 requalifié | moyenne | BRAIN | ✅ les 11 lectures sont légitimes : **c'est L4 qui les annonce désormais**, le code ne change pas |
| 090 → 091 | ✅ retenus | moyenne | CODE | 4 commandes sans porte de succès · `ManageGroups` |
| 092 | ✅ retenu | moyenne | CODE | D-19 |
| 093 | 🔁 requalifié | moyenne | BRAIN CODE | ✅ K5 devient mesurable (`outils/verif_serveur.sh`) ; **V-022 reste ouvert** jusqu'au VPS (étape 7.2) |
| 094 | ✅ retenu | moyenne | CODE | V-014, V-019, V-032 encore partiels |
| 095 | ✅ bonne | bonne | — | à garder |

**Compte : 19 retenus · 2 requalifiés · 0 rejeté · 1 bonne.**

<source>

## Ce que ce tour apprend

| | |
|---|---|
| ⭐ Le banc | **0 porte aveugle** : les 40 portes « refuse INTROUVABLE » relisent désormais la base. Le filet tient |
| ⛔ Ma faute, deux fois de suite | D-2 puis D-10 : j'ai écrit une règle **pour la porte d'entrée que j'avais en tête**, pas pour toutes. D-14 la pose une fois pour toutes |
| ⭐ La leçon retenue | une garde qui se **rappelle** (un appel dans chaque handler) se perd ; une garde qui se **lit** (une table, un point de passage) tient. D-15 |

</source>
