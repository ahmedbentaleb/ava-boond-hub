# État du projet Ava Manager — du premier jour à la livraison

⭐ **Une seule source pour « où on en est ».** Le hub (vue « État du projet ») et le dossier
(`dossier.html` §08) lisent ce fichier. ⛔ On ne recopie pas cet état ailleurs : on le met à jour ici,
après chaque rapport de session.

<quand_utiliser>

| ✅ On ouvre ce fichier | ⛔ On ne l'ouvre pas pour |
|---|---|
| Savoir quelle étape est finie, en cours, à venir — et où est son document | le détail d'une étape → le document de sa ligne |
| Mettre à jour l'état après un rapport de session | les tâches du jour → le dernier `PLAN_<date>.md` |

Extraire l'état sans lire le reste :

```bash
sed -n '/^<etat>$/,/^<\/etat>$/p' _ops/ETAT_PROJET.md
```

Légende : ✅ fait · ⏳ en cours · ⬜ à faire · ↪ fusionné ailleurs. Les liens sont relatifs à `doc/` du hub.

</quand_utiliser>

<etat>

Mis à jour le 23/09/2026, au soir. Les anciens numéros de lot sont entre parenthèses.

### 0 · Démarrage

| # | Étape | État | Documents |
|---|---|---|---|
| 0.1 | Lire la commande d'Avaliance : les deux cahiers des charges | ✅ 15/09 | [SPEC 1](AVA_MANAGER-SPEC_1_extract.txt) · [Cockpit 2](COCKPIT2-Cahier_de_charge-v0.1_extract.txt) · [cahier des charges](../cdc.html) |
| 0.2 | Écarter la démo Jenspark (un prototype, pas une base) | ✅ 16/09 | [ADR-001](adr/ADR-001-zip-jenspark-ecarte.md) |
| 0.3 | Dépôt GitHub privé, sauvegarde, règles de travail | ✅ 17/09 | [audit du projet 17/09](AUDIT_PROJET_2026-09-17.md) |

### 1 · Étude de Boond Manager — l'existant

| # | Étape | État | Documents |
|---|---|---|---|
| 1.1 | Les captures d'écran de Boond — 89 | ✅ 15/09, complétées le 22/09 (administration, référentiels, plans de charge) | hub › Boond › Audit complet · [audit des écrans](cartographie/AUDIT_ECRANS.md) |
| 1.2 | Comprendre comment Boond fonctionne | ✅ 15/09 | [fonctionnement](cartographie/FONCTIONNEMENT_BOOND.md) · [diagnostic métier](cartographie/DIAGNOSTIC_METIER.md) |
| 1.3 | Le relevé de Boond : chemins, écrans, et **tous les réglages valeur par valeur** | ✅ 19 → 23/09 | [relevé Boond](cartographie/BOOND_CHEMINS_2026-09-19.md) · [écrans du 22/09](cartographie/BOOND_ECRANS_2026-09-22.md) · [réglages du 23/09](cartographie/BOOND_REGLAGES_2026-09-23.md) · [grille d'inventaire](GRILLE_INVENTAIRE_BOOND_2026-09-17.md) |
| 1.4 | Les questions que seul Avaliance peut trancher | ⏳ réunion du 23/09 | hub › [Questions Avaliance](../#reunion) · [questions Boond](QUESTIONS_BOOND_2026-09-19.md) |

### 2 · Cadrage métier — ce que le logiciel doit faire

| # | Étape | État | Documents |
|---|---|---|---|
| 2.1 | Le cadrage réconcilié : les 15 parcours du métier | ✅ 16/09 | [cadrage](CADRAGE_METIER_RECONCILIE_2026-09-16.md) · [parcours simples](PARCOURS_METIER_SIMPLE_AVA_MANAGER.md) · [passation](TRANSMISSION_SESSION_CADRAGE_2026-09-16.md) |
| 2.2 | Les 18 décisions et la feuille F1–F36 | ✅ 16/09 | hub › Décisions · [feuille F1–F36](FEUILLE_F1-F36_AHMED_2026-09-16.md) |
| 2.3 | La feuille G1–G15, tranchée | ✅ 17/09 | [feuille G](FEUILLE_G1-G15_2026-09-17.md) |
| 2.4 | Le modèle métier et les 15 murs | ✅ 17/09 | [modèle métier](MODELE_METIER_CANONIQUE_v1.md) |
| 2.5 | Les cycles de vie (machines d'état) | ✅ 17/09 | [machines d'état](MACHINES_ETAT_V1.md) |
| 2.6 | Tout est réglable : le registre des 173 politiques | ✅ 17/09 | [registre](REGISTRE_POLITIQUES_v1.md) · [ADR-005](adr/ADR-005-politiques-parametrables-vs-invariants.md) |
| 2.7 | Qui a le droit de quoi | ✅ 18/09 | [matrice des droits](MATRICE_DROITS_v1.md) · [motifs](annexes/MATRICE_DROITS_MOTIFS_2026-09-18.md) |
| 2.8 | Relectures externes (Grok, GPT) | ✅ 19/09 | [relecture métier](RELECTURE_METIER_EXTERNE_2026-09-19.md) · [relecture du modèle](RELECTURE_5_MODELE_DONNEES_2026-09-17.md) · [tiers](RELECTURE_5_TIERS_2026-09-17.md) |
| 2.9 | Le cahier de relecture métier, pour Avaliance | ✅ 17/09 | [cahier](CAHIER_RELECTURE_METIER_2026-09-17.md) · [version lisible](../cahier.html) |

### 3 · Conception technique — comment il sera construit

| # | Étape | État | Documents |
|---|---|---|---|
| 3.1 | Les décisions d'architecture (ADR) | ✅ 16 → 19/09 | [ADR-000](adr/ADR-000-mono-tenant.md) · [002](adr/ADR-002-personne-et-profils.md) · [003](adr/ADR-003-projet-prestation-ressource.md) · [004](adr/ADR-004-evenements-et-archivage.md) · [006](adr/ADR-006-avenant-version-datee.md) · [007](adr/ADR-007-filiales-pas-maintenant.md) |
| 3.2 | Les 10 décisions techniques (pile, connexion, hébergement) | ✅ 18/09 — T4 sauvegardes reporté | [décisions techniques](DECISIONS_TECHNIQUES_v1.md) |
| 3.3 | Le modèle de données | ✅ 17/09 | [modèle de données](MODELE_DONNEES_AVAMANAGER_V1.md) |
| 3.4 | Le schéma de la base et ses murs | ✅ 19/09 | [lisez-moi](SPEC_SQL_LISEZ-MOI.md) · [schéma SQL](SPEC_SQL_AVAMANAGER_V1.sql) · [assertions des murs](SPEC_ASSERTIONS_L7.sql) |
| 3.5 | Le contrat des 55 commandes | ✅ 19/09 | [contrat des commandes](SPEC_COMMANDES_L4.md) |
| 3.6 | Les thèmes et les couleurs | ✅ 19/09 | [thèmes](THEMES_v1.md) · [audit des thèmes](annexes/AUDIT_THEMES_2026-09-19.md) |
| 3.7 | La maquette : les 26 écrans et le banc d'essai | ✅ 18/09 | [les 26 écrans](../terminal.html) · [banc d'essai](../simulateur.html) · [relecture du banc](RELECTURE_5b_SIMULATEUR_2026-09-17.md) |

### 4 · Organisation et contrôle — qui fait quoi, qui vérifie

| # | Étape | État | Documents |
|---|---|---|---|
| 4.1 | Trois agents séparés : BRAIN, CODE (Grok), AUDIT | ✅ 21/09 | [brief exécutant](BRIEF_EXECUTANT_2026-09-17.md) |
| 4.2 | La grille d'audit : 36 contrôles | ✅ 19/09 | [grille d'audit](GRILLE_AUDIT.md) |
| 4.3 | Le cliquet et les portes (les tests qui bloquent) | ✅ 20/09 | [portes du code](journal/PORTES.md) · [portes en attente](PORTES_EN_ATTENTE.md) |
| 4.4 | Les journaux de bugs | ⏳ tenus en continu | [bugs du BRAIN](JOURNAL_BUGS.md) · [bugs du code](journal/BUGS.md) · [correctifs](journal/CORRECTIFS.md) |

### 5 · Construction — le code

| # | Étape | État | Documents |
|---|---|---|---|
| 5.1 | Fondations : dépôt, base, 15 murs, données de départ (lot 1) | ✅ 20/09 — 69 min | [prompt lot 1](PROMPT_GROK_LOT1.md) · [étapes du code](journal/ETAPES.md) · [base](db/README.md) |
| 5.2 | Le serveur : les 55 commandes (lot 2) | ⏳ **quatrième tour de correctifs** · banc vert au 23/09 : **280 portes jouées, 31 assertions, cliquet 12/12** (fusion `cc3ff64`) | [prompt lot 2](PROMPT_GROK_LOT2.md) · [prompt correctifs](prompt-lot2-correctifs.txt) · [décisions du code](journal/DECISIONS.md) |
| 5.3 | Premier audit indépendant | ✅ 21/09 — refusé, 47 constats | [synthèse](audit-2026-09-21/SYNTHESE.md) · [constats](audit-2026-09-21/CONSTATS.md) · [mutations](audit-2026-09-21/MUTATIONS.md) · [arbitrage](ARBITRAGE_AUDIT_2026-09-21.md) |
| 5.4 | Corrections du BRAIN : base, tests des murs, cliquet | ✅ 21/09 — validées par le second audit | [prompt brain code](prompt-brain-code.txt) |
| 5.5 | Second audit | ✅ 22/09 — refusé, 27 constats neufs, accès non gardé | [synthèse](audit-2026-09-22/SYNTHESE.md) · [constats](audit-2026-09-22/CONSTATS.md) · [contestation](audit-2026-09-22/CONTESTATION.md) · [arbitrage](ARBITRAGE_AUDIT_2026-09-22.md) |
| 5.5b | Corrections du second tour : BRAIN CODE puis Grok | ✅ 22-23/09 | [prompt brain code 2](prompt-brain-code-2.txt) · [prompt correctifs 2](prompt-lot2-correctifs-2.txt) |
| 5.5c | Troisième audit | ✅ 23/09 — refusé, 21 constats neufs ; ⭐ **banc réparé : 0 porte aveugle sur 50 sabotages** | [synthèse](audit-2026-09-23/SYNTHESE.md) · [constats](audit-2026-09-23/CONSTATS.md) · [arbitrage](ARBITRAGE_AUDIT_2026-09-23.md) |
| 5.5d | Corrections du troisième tour | ⏳ — BRAIN CODE ✅ fusionné (cliquet 12/12) · Grok en cours (D-14 le garde unique, D-15 l'agence de l'objet) | [prompt brain code 3](prompt-brain-code-3.txt) · [prompt correctifs 3](prompt-lot2-correctifs-3.txt) |
| 5.5e | Quatrième audit | ✅ 23/09 — refusé, 11 constats ; ⭐ **les corrections du 3e tour tiennent et sont gardées** | [synthèse](audit-2026-09-23b/SYNTHESE.md) · [constats](audit-2026-09-23b/CONSTATS.md) · [arbitrage](ARBITRAGE_AUDIT_2026-09-23b.md) |
| 5.5f | Corrections du quatrième tour | ⏳ | [prompt brain code 4](prompt-brain-code-4.txt) · [prompt correctifs 4](prompt-lot2-correctifs-4.txt) |
| 5.5g | Cinquième audit | ⬜ quand Grok écrit « prêt pour le cinquième audit » | [prompt d'audit](prompt-audit-2.txt) |
| 5.6 | Connexion par compte Microsoft (lot 2c) | ⬜ attend R4 de la réunion | [décisions techniques T2](DECISIONS_TECHNIQUES_v1.md) · [arbitrage D-2](ARBITRAGE_AUDIT_2026-09-21.md) |
| 5.8 | ⭐ **RH et facturation** — contrats, documents à suivre, devis, factures (décision du 23/09 : tout en V1) | ⬜ après les écrans | [ce que la V1 doit porter en plus](COMPLEMENTS_V1_2026-09-23.md) · [réglages Boond](cartographie/BOOND_REGLAGES_2026-09-23.md) |
| 5.7 | Les 26 écrans (lot 3) | ⬜ après le 5.5 accepté | [les 26 écrans](../terminal.html) · [prompt écrans](PROMPT_CHATGPT_ECRANS.md) |
| — | CRM, staffing, production (anciens lots 4, 5, 6) | ↪ fusionnés dans 5.2 et 5.7 | — |

#### Les tours d'audit du serveur — mesurés

| | 1er (21/09) | 2e (22/09) | 3e (23/09) | 4e (en cours) |
|---|---|---|---|---|
| Tests aveugles | 48 | 45 | **0** | **1** |
| Défauts critiques ouverts | 12 | 7 | 2 | 2 |
| Tests joués | 64 | 151 | 264 | **280** · 57 sabotages |
| Constats du tour précédent fermés | — | 22/47 | 37/47 | **20/25**, et les 4 critiques **gardés** |

⭐ **Le filet tient depuis le 3e tour** : plus aucun test ne reste vert quand on casse le code exprès (50 sabotages).

### 6 · Reprise et recette — avec les vraies données

| # | Étape | État | Documents |
|---|---|---|---|
| 6.1 | Obtenir l'export des données de Boond | ⬜ attend R3 | [relevé Boond](cartographie/BOOND_CHEMINS_2026-09-19.md) |
| 6.2 | Ressaisir les missions en cours et leurs tarifs | ⬜ attend R2 | hub › [Questions Avaliance](../#reunion) |
| 6.3 | Import des données Boond (lot 7) | ⬜ | [modèle de données](MODELE_DONNEES_AVAMANAGER_V1.md) |
| 6.4 | Essai de deux semaines, trois utilisateurs réels | ⬜ | — |
| 6.5 | Un mois en parallèle de Boond, chiffres comparés | ⬜ | — |

### 7 · Mise en production et livraison à Avaliance

| # | Étape | État | Documents |
|---|---|---|---|
| 7.1 | Serveur dédié, sauvegardes chaque nuit, test de restauration mensuel | ⬜ | [décisions techniques T3–T5](DECISIONS_TECHNIQUES_v1.md) |
| 7.2 | Sécurité : mots de passe de base, accès réseau | ⬜ | [audit, constat V-022](audit-2026-09-21/CONSTATS.md) |
| 7.3 | Documentation utilisateur, par rôle | ⬜ | — |
| 7.4 | Bascule : Ava Manager remplace Boond | ⬜ | — |
| 7.5 | ⭐ Livraison finale à Avaliance | ⬜ | — |

### 8 · Après la livraison

| # | Étape | État | Documents |
|---|---|---|---|
| 8.1 | Connecteur pour Claude, lecture seule d'abord (lot 8) | ⬜ | détail au canon : `PLAN_2026-09-20.md` |

</etat>

<source>

Étapes 0 → 4 : les plans datés du 15 au 22/09 et les documents cités. Étape 5 : rapports de Grok,
audit indépendant du 21/09 (`Desktop/ava-audit/rapport/`, copié dans `doc/audit-2026-09-21/`).
⚠️ Renumérotation du 22/09 : lot 1 → 5.1, lot 2 → 5.2, lot 2c → 5.6, lot 3 → 5.7, lot 7 → 6.3,
lot 8 → 8.1. Les anciens numéros restent entre parenthèses pour relire les prompts déjà écrits.

</source>
