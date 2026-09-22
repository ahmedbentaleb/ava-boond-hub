# Arbitrage de l'audit indépendant — 21/09/2026

Audit : commit `3b59ca5`, verdict **REFUSÉ**, 47 constats (V-001 → V-047), rapport dans
`Desktop/ava-audit/rapport/`. Arbitré par le BRAIN. Les 12 critiques ont été revérifiés dans le
code avant d'être tranchés (V-001, V-002, V-003, V-005, V-006, V-007 relus ligne à ligne).

<etat>

## ⬜ CE QUI RESTE À FAIRE

| # | Quoi | Constats | Qui | État |
|---|---|---|---|---|
| 1 | Migration **007** : M-15 par `REVOKE ALL` puis `GRANT` des 4 vues ; rôle **LOGIN** `ava_serveur` membre de `ava_app`, sans superutilisateur ; `GRANT INSERT, SELECT` sur `tentative_refusee` | V-001 V-002 V-027 | BRAIN | ✅ fait — `lot-2-brain`, fusionné |
| 2 | Assertions : une par privilège pour chaque mur « trigger + GRANT » (M-6 M-7 M-8 M-15) ; `test/SPEC_ASSERTIONS_L7.sql` remplacé par la copie `_ops/`, égalité vérifiée par le cliquet | V-001 V-012 | BRAIN | ✅ fait — `lot-2-brain`, fusionné |
| 3 | Cliquet : case 1 exige `make_rc = 0` ; cases 3 et 9 comparent **numéro par numéro** ; CI en `fetch-depth: 0` | V-008 V-009 | BRAIN | ✅ fait — `lot-2-brain`, fusionné |
| 4 | Canon : trancher les 6 contradictions de V-029, corriger la grille, le jeu d'essai | V-023 V-024 V-029 | BRAIN | ✅ fait — `lot-2-brain` |
| 5 | Canon : l'authentification entre dans un lot — **lot 2c** (voir §Décisions) | V-003 | BRAIN | ✅ inscrit — `ETAT_PROJET.md` |
| 6 | Prompt de correction pour Grok | tous les CODE | BRAIN | ✅ `_ops/prompt-lot2-correctifs.txt` |
| 7 | Grok corrige, puis **même audit rejoué** sur le nouveau commit | — | CODE puis AUDIT | ⬜ |

⛔ **Pas de fusion de `lot-2` sur `main`** tant que les points 1 à 3 et le prompt Grok ne sont pas faits
et qu'un second audit ne les a pas vus tomber.

</etat>

## ⚠️ À TRANCHER PAR AHMED

Rien. Tout ce qui suit se déduit du canon (T2, ADR-005, MATRICE, registre).

## Décisions du BRAIN

| # | Décision | Motif |
|---|---|---|
| D-1 | **V-003 est un oubli du BRAIN, pas de Grok.** T2 a tranché le 18/09 (`auth.fournisseur`, défaut `microsoft`), la politique est au registre, mais **aucun lot ne l'a jamais reçue** ; le plan du 20 parlait de « l'authentification du lot 2 » alors que le prompt du lot 2 n'en dit pas un mot | un choix décidé mais jamais confié à personne n'existe pas |
| D-2 | **Lot 2c — authentification**, avant le lot 3 : le compte vient d'une session, le groupe se déduit du compte. En-tête `x-ava-groupe` accepté **seulement** si `AVA_MODE=banc`, refusé sinon. Fournisseur réel Microsoft (OIDC) au lot 2c ; `google` et `email_mot_de_passe` restent des valeurs de la politique, codées plus tard | les écrans du lot 3 ont besoin d'un utilisateur ; T4 interdit les données réelles d'ici là |
| D-3 | **`mur_touche` est indicatif** (SPEC_SQL gagne sur L4) : pas de garde. L4 §C-5 se corrige | SPEC_SQL l'a écrit en connaissance de cause ; 0 politique sur 173 le porte |
| D-4 | Noms d'événements : **L4 gagne**, MACHINES se corrige | le code suit déjà L4 |
| D-5 | Acteurs : **la MATRICE gagne**, MACHINES se corrige | la matrice = le seed, 0 écart mesuré (V-043) |
| D-6 | Doublons : valeurs `avertir · bloquer · ignorer` (registre), L4 « refus » se corrige | le registre fait foi pour les valeurs |
| D-7 | SUP peut régler **son propre** thème : ce n'est pas une mutation métier. La phrase « SUP ne mute rien » se précise | le thème est une préférence de lecteur |
| D-8 | Code `sorti` : **il existe au seed** (005), MACHINES se corrige ; une commande n'écrit **jamais** un référentiel | la base a déjà raison, on ne réécrit pas une migration |
| D-9 | `perimetre.type_code` reste un CHECK : c'est la mécanique des droits, pas une liste métier. Les trois autres (V-021) deviennent des `ref_*` | ADR-005 : le référentiel sert ce que l'admin doit pouvoir changer |

## Les 47 constats

| V | Verdict | Gravité retenue | Cible | Note |
|---|---|---|---|---|
| 001 | ✅ retenu | critique | **BRAIN** + CODE | ⛔ mon A-001 a été fermé dans le canon **sans migration** : fermeture fausse, rouvert |
| 002 | ✅ retenu | critique | BRAIN (migration) + CODE (connexion) | revérifié `server/src/index.ts:11` |
| 003 | 🔁 requalifié | critique | **BRAIN** → CODE | D-1, D-2 |
| 004 | ✅ retenu | critique | CODE | |
| 005 | ✅ retenu | critique | CODE | revérifié `projet.ts:397` |
| 006 | 🔁 requalifié | critique | CODE | requête et liste à corriger ; la garde `mur_touche` tombe (D-3) |
| 007 | ✅ retenu | critique | CODE | revérifié `executer.ts:66` |
| 008 | ✅ retenu | critique | BRAIN | cliquet |
| 009 | ✅ retenu | critique | BRAIN | cliquet + CI |
| 010 | ✅ retenu | critique | CODE | = A-015, déjà ordonné le 20/09 ; l'audit le confirme par mutation |
| 011 | ✅ retenu | critique | CODE | |
| 012 | ✅ retenu | critique | BRAIN | assertions |
| 013 | ✅ retenu | elevee | CODE | |
| 014 | ✅ retenu | elevee | CODE | |
| 015 | ✅ retenu | elevee | CODE + BRAIN (grille B1) | |
| 016 | 🔁 requalifié | elevee | CODE | D-8 : la commande ne crée plus rien, refus GARDE |
| 017 | ✅ retenu | elevee | CODE | |
| 018 | ✅ retenu | elevee | CODE | P-062 → P-065 repassent ⏳ lot 3 |
| 019 | ✅ retenu | elevee | CODE | |
| 020 | ✅ retenu | elevee | CODE | |
| 021 | 🔁 partiel | elevee | CODE | D-9 : 3 listes sur 4 |
| 022 | 🔁 requalifié | moyenne | Ahmed (poste) · T3 | poste de dev ; `scram-sha-256` obligatoire sur le VPS |
| 023 | ✅ retenu | elevee | BRAIN | grille |
| 024 | ✅ retenu | moyenne | BRAIN | jeu d'essai |
| 025 | ✅ retenu | moyenne | CODE | |
| 026 | ✅ retenu | moyenne | CODE | |
| 027 | ✅ retenu | moyenne | BRAIN (migration) + CODE (`catch {}`) | |
| 028 | ✅ retenu | moyenne | — | constat historique, rien à réparer ; la règle tient pour la suite |
| 029 | ✅ retenu | moyenne | BRAIN | D-3 → D-8 ; doublon `doublon.contact.mode` au registre |
| 030 | ✅ retenu | moyenne | CODE | |
| 031 | ✅ retenu | moyenne | CODE | mot de passe du conteneur de dev |
| 032 → 039 | ✅ retenus | moyenne | CODE | |
| 040 | 🔁 partiel | moyenne | CODE | un seul humain, un seul compte : un **trailer** `Role:` par commit suffit ; crochet posé par script |
| 041 → 047 | ✅ bonnes | bonne | — | à garder ; V-041 et V-046 n'ont **aucune porte** (V-011) |

**Compte : 42 retenus · 5 requalifiés ou partiels · 0 rejeté.**

<source>

## L'audit face au BRAIN (A-)

| | Constats |
|---|---|
| Vus par les deux | V-010 = A-015 · V-001 = A-001 (que le BRAIN croyait fermé) |
| ⭐ Vus par l'audit seul | V-002 V-003 V-004 V-005 V-006 V-007 V-008 V-009 V-011 V-012 et les 11 élevés |
| Vus par le BRAIN seul | A-006 (`make.sh` sous Git Bash), A-007 (collision de numéro d'ADR) — l'audit n'a pas lancé `make.sh` |

</source>


⭐ **Le mur d'indépendance a payé** : 10 critiques sur 12 étaient invisibles au BRAIN, dont un
mur qu'il croyait avoir fermé.
