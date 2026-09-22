# Arbitrage du second audit — 22/09/2026

Audit : commit `7e3f78c`, verdict **REFUSÉ**, 27 constats neufs (V-048 → V-074 : 3 critiques ·
10 élevés · 13 moyens · 1 bon), 8 contestations de l'arbitrage du 21/09. Rapport :
`Desktop/ava-audit-2/rapport/` (copié au hub, `doc/audit-2026-09-22/`). V-048 revérifié dans le code
avant d'être tranché (`executer.ts:72-83`, `index.ts:149-157`, `005_droits_lot2.sql:185`).

<etat>

## ⬜ CE QUI RESTE À FAIRE

| # | Quoi | Constats | Qui | État |
|---|---|---|---|---|
| 1 | Canon corrigé : MACHINES (3 restes), L4 (`NeedStateChanged`), registre (167), T2 (la session), T3 (`scram`), SPEC_SQL (état du lot 1), grille (famille **K accès**, B5, F9, F12, A4, D5, F7), compte de l'arbitrage du 21 | V-059 V-062 V-063 V-064 V-065 V-067 · contestations 1 6 11 12 15 21 | BRAIN | ✅ fait le 22/09 |
| 2 | Cliquet (F12), crochet posé par script, migration 008, assertions M-12, `make.sh`, CI avec Postgres | V-050 V-053 V-058 V-060 V-070 V-051 V-039 | BRAIN CODE | ⬜ `_ops/prompt-brain-code-2.txt` |
| 3 | Serveur fermé hors banc, périmètre par objet, portes d'accès, élevés et moyens | V-048 V-003 V-004 V-006 V-011 V-049 · élevés · moyens | CODE | ⬜ `_ops/prompt-lot2-correctifs-2.txt` |
| 4 | Troisième audit | — | AUDIT | ⬜ `_ops/prompt-audit-2.txt`, clone `ava-audit-3` |

</etat>

## ⚠️ À TRANCHER PAR AHMED

Rien. Tout se déduit de T2, de la matrice et de la recommandation de l'audit.

## Décisions du BRAIN

| # | Décision | Motif |
|---|---|---|
| **D-10** | ⛔ **Hors `AVA_MODE=banc`, le serveur refuse TOUT appel** jusqu'au lot 2c : `401 « authentification non livrée (lot 2c) »`, 0 écriture. L'en-tête `x-ava-session` est **retiré**. Aucune session factice. Au lot 2c, une session = un jeton **opaque, aléatoire, haché, expirant**, émis après l'authentification Microsoft — jamais l'id du compte | ⛔ **Ma faute** : D-2 disait « le compte vient d'une session » sans dire ce qu'est une session. Grok a pris le plus simple, l'id du compte. La recommandation de l'audit est la bonne : on ne livre pas une serrure à moitié |
| **D-11** | Les comptes de banc ne vivent plus dans une migration de production : la migration **008** les **désactive** ; une fixture `db/fixtures/banc.sql`, chargée par `make test` seulement, les réactive | on ne réécrit pas 005 ; un compte désactivé ne fait rien (K3) |
| **D-12** | La règle « S » (soi-même) devient une **donnée** : périmètre `soi` (migration 008 l'ajoute au CHECK de `perimetre.type_code`), lue par `droits.ts` ; plus aucun `includes(GROUPE.RES)` | V-058 : un rôle écrit en dur est un `if` métier |
| **D-13** | D5 se mesure par le **trailer** : un commit qui touche `test/` porte `Role: banc`, le crochet refuse sinon ; `outils/installer.sh` pose `core.hooksPath`, le cliquet le vérifie | un seul compte git : le nom d'auteur ne dit rien, le trailer si |

## Les 8 contestations — toutes acceptées

| # | Contestation | Réponse du BRAIN |
|---|---|---|
| 1 | Compte « 42 · 5 » faux | ✅ acceptée — corrigé en **41 · 6** dans l'arbitrage du 21 |
| 6 | V-022 : la condition « scram sur le VPS » n'est écrite que dans l'arbitrage | ✅ acceptée — écrite dans **T3** et vérifiée par **K5**. Poste de dev : reste `trust`, déclaré |
| 7 | V-040 : 8 commits sans `Role:`, crochet posé par rien | ✅ acceptée — D-13. Les 8 commits anciens restent : on ne réécrit pas l'historique |
| 9 | ⛔ **D-2 ne ferme pas V-003, il le déplace** | ✅ **acceptée, et c'est la plus importante** — D-10 remplace D-2 pour l'avant-2c |
| 11 | D-4 : `NeedStateChanged` absent de L4 | ✅ acceptée — L4 le porte comme événement d'effet |
| 12 | D-5 : `CancelPrestation` reste « DP » | ✅ acceptée — MACHINES dit DP, Staffing |
| 15 | D-8 : `sorti` dit « système » | ✅ acceptée — MACHINES dit « semé, non système » |
| 21 | Les 6 contradictions pas toutes tranchées dans le texte | ✅ acceptée — les restes 1, 5 et 6 sont corrigés (lignes 11, 12, J-1) |

## Les 27 constats neufs

| V | Verdict | Gravité retenue | Qui | Note |
|---|---|---|---|---|
| 048 | ✅ retenu | critique | CODE | D-10 : tout refuser hors banc |
| 049 | ✅ retenu | critique | CODE + BRAIN (grille K) | portes K1 → K4 |
| 050 | ✅ retenu | critique | BRAIN CODE | F12 |
| 051 | ✅ retenu | élevée | BRAIN CODE (`make.sh`) + CODE (`db.ts`, `correctifs.test.ts`) | |
| 052 | ✅ retenu | élevée | CODE | |
| 053 | ✅ retenu | élevée | BRAIN CODE | D-11 |
| 054 | ✅ retenu | élevée | CODE | une décision inconnue est un `GARDE`, jamais un refus client |
| 055 | ✅ retenu | élevée | CODE | |
| 056 | ✅ retenu | élevée | CODE | |
| 057 | ✅ retenu | élevée | CODE | |
| 058 | ✅ retenu | élevée | BRAIN CODE (008) + CODE (`droits.ts`) | D-12 |
| 059 | ✅ retenu | élevée | BRAIN | ✅ famille K ajoutée |
| 060 | 🔁 requalifié | moyenne | BRAIN CODE | D-13 : se mesure par trailer, pas par auteur |
| 061 → 062 | ✅ retenus | moyenne | CODE · BRAIN | 062 ✅ corrigé |
| 063 | 🔁 requalifié | moyenne | BRAIN | ✅ la spec se déclare « état du lot 1 » ; on ne la réécrit pas à chaque migration |
| 064 → 067 | ✅ retenus | moyenne | BRAIN | ✅ corrigés ; 066 : `ETAT_PROJET` mis à jour à chaque rapport, désormais |
| 068 → 069 | ✅ retenus | moyenne | CODE | |
| 070 | ✅ retenu | moyenne | BRAIN CODE | assertions M-12 sur `contact` et `projet` |
| 071 | ✅ retenu | moyenne | CODE | `SetOwnTheme` : clés et valeurs contrôlées contre `ui.*` |
| 072 | 🔁 requalifié | basse | CODE | aides de test, noms de tables constants — à corriger au passage |
| 073 | ✅ retenu | moyenne | CODE | |
| 074 | ✅ bonne | bonne | — | à garder |

**Compte : 23 retenus · 3 requalifiés · 0 rejeté · 1 bonne.** Les 15 partiels et 2 ouverts du premier
audit (`SUIVI_V.md`) sont repris dans le prompt de Grok et celui de Brain Code.

<source>

## L'audit face au BRAIN

| | |
|---|---|
| ⛔ Défauts du BRAIN trouvés | D-2 incomplet (la session non définie) · 6 restes de canon · un compte faux · `ETAT_PROJET` en retard le jour même |
| ⭐ Ce que l'audit a validé | 007, M-15, `ava_serveur`, assertions (13/13 sabotages SQL tombent), témoins du cliquet vrais |
| Mesure | portes aveugles **48 → 45** : la moitié du travail est faite sur le serveur, presque rien sur les portes |

</source>
