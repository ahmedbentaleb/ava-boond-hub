# Arbitrage du onzième audit — 04/10/2026

Audit sans compromis, `lot-2 @34d98a4`, verdict **REFUSÉ** (6 critiques · 6 élevés · 4 moyens · 1 bon : V-179 → V-195).
⭐ **Tenu** : 348 portes, 41 assertions ; le registre exécutable rejoué par un rejoueur **indépendant** : 203/206 cas
conformes ; porte croisée 0 fuite sur 846 identifiants et 6 passes ; D-58, D-61 → D-64, D-78 tenues.
⛔ **Mais 8 constats du 10e tour n'ont pas été touchés** (V-166, V-167, V-168, V-169, V-171, V-173, V-174, V-175 ;
V-156 au 6e tour) — et la phrase « prêt » a été écrite quand même.

<etat>

## ⬜ CE QUI RESTE À FAIRE

| # | Quoi | Décision | Constats | Qui | État |
|---|---|---|---|---|---|
| 1 | ⭐ **« Prêt » se mesure** : chaque constat de l'arbitrage a sa ligne au journal (porte rouge → verte, commit), sinon le cliquet refuse | D-83 | les 8 du 10e tour | BRAIN CODE (case) · CODE (les 8) | ⬜ |
| 2 | ⭐ **Le registre exécutable v2** : jouable à la lettre, colonnes réelles, contraintes et `SetPolicy` en lignes, scénarios à 2 éléments | D-56 v2 | V-183 V-190 V-191 | **BRAIN** | ✅ 04/10 |
| 3 | **Le registre se joue par le chemin de l'utilisateur** : `SetPolicy` HTTP, chaque clé seule, chaque cascade sans le droit de la fille, listes à 2 éléments | D-84 | V-181 V-183 V-192 | BRAIN CODE | ⬜ |
| 4 | Une cascade n'a **aucun** chemin qui saute la garde de sa fille | D-43, D-88 | V-179 V-182 | CODE | ⬜ |
| 5 | Le métier ne lit ni `ordre`, ni le premier code d'une catégorie, ni un nom de commande, ni un littéral | D-57, D-89 | V-180 V-194 | CODE · BRAIN CODE (porte AST) | ⬜ |
| 6 | Admis = servi : une seule garde de valeurs, générée | D-85, D-86 | V-181 | BRAIN CODE · CODE | ⬜ |
| 7 | Les écarts du code au registre v2 | — | V-184 V-185 V-190 | CODE | ⬜ |
| 8 | Le banc et le cliquet | — | V-186 V-187 V-188 V-189 V-193 | BRAIN CODE · CODE | ⬜ |
| 9 | Douzième audit | — | — | AUDIT | ⬜ `ava-audit-12`, base `ava_audit12`, port 4200 |

</etat>

## ⭐ D-83 — « PRÊT » SE MESURE, IL NE SE DÉCLARE PLUS

Le codeur a écrit « prêt pour le onzième audit » avec 8 constats du tour précédent **jamais ouverts**. Le cliquet
était vert parce qu'aucune case ne savait ce qui était demandé.

| Règle | Tranché |
|---|---|
| **Construction** | une case du cliquet lit la liste des constats de l'**arbitrage en cours** (V-n de son tableau) et exige pour chacun une ligne de `journal/CORRECTIFS.md` : V-n · porte · sortie rouge · sortie verte · commit. Un V-n sans ligne → KO, avec son numéro |
| **Ce qui n'est pas corrigé** | se déclare (V-n · motif · décision du BRAIN qui l'accepte) ; sans décision, KO |
| **La phrase** | « prêt pour le N-ième audit » n'est écrite que **par le cliquet** (sa dernière ligne), plus par le codeur |

## ⭐ D-84 — LE REGISTRE SE JOUE PAR LE CHEMIN DE L'UTILISATEUR

Le rejoueur de l'audit, qui pose les politiques par `SetPolicy` en HTTP, a trouvé ce que la porte du banc (qui
les posait en SQL) ne pouvait pas voir : `service_ou_societe` inatteignable, `[]` admis, 25 défauts de listes
impossibles à remettre.

| Règle | Tranché |
|---|---|
| **Poser** | toute politique d'un scénario se pose par `SetPolicy` (ADM, HTTP) ; ⛔ jamais `UPDATE politique` dans une porte ou une fixture |
| **Isoler** | chaque clé est jouée **seule** sur chaque refus (les autres au défaut) |
| **Cascades** | chaque ligne de `CASCADES` est jouée avec un acteur qui a la mère **sans** la fille (même agence, délégation sur une autre seule, surcharge) |
| **Le banc reprend le rejoueur de l'audit** | `audits-independants/ava-audit-11/rapport/preuves/registre11/rejoueur11.mjs` est la base de la porte ; le BRAIN CODE le reprend, il ne le réinvente pas |
| **Le lecteur vérifie le registre** | `registre_executable.mjs --verifier` au cliquet : grammaire du §0, colonnes existantes, pluriel ⇒ 2 éléments, condition ⇒ deux côtés |

## D-89 — un code par défaut se déclare, il ne se devine pas par `ordre` (V-180)

Mesuré : inverser `ordre` fait écrire `forfait` au lieu de `regie` ; un second code `prospect` d'ordre 0 casse le
passage client. ⭐ Chaque `ref_*` dont le code lit un **défaut** reçoit une colonne `par_defaut` (vrai pour **un
seul** code, index unique partiel), administrable ; le code lit la **catégorie** pour décider et `par_defaut` pour
écrire. `ORDER BY ordre` n'existe que dans les vues d'affichage.

## Les questions de l'audit

| Question | Tranché |
|---|---|
| (1) Listes : toute partie du domaine, ou seulement les listes écrites ? | **D-85 : seulement les listes écrites**, sous forme canonique. Le domaine valide le registre, il n'élargit rien. `[]` refusé partout où il n'a pas de ligne |
| (2) `PositionCandidate` passe un besoin en recherche sans `TakeNeedInCharge` : la politique vaut-elle droit ? | **D-87 : oui** — la politique désigne la commande qui écrit la transition ; elle en fait partie, son droit suffit. Ce n'est pas une cascade. `MACHINES_ETAT_V1` §7 ter liste qui écrit chaque transition, et une porte compare |

## Les constats, un par un

| V | Tranché | Qui |
|---|---|---|
| V-179 | `executerDans` sans **aucun** contournement de la garde ; une cascade qui doit agir « au nom du système » le déclare dans `CASCADES` (`acteur: systeme`) et la garde le lit ; porte générée de `CASCADES` (registre S-CB2, S-PCL2) ; 0 nom de commande dans `executer.ts` et `agence.ts` | CODE · BRAIN CODE (porte) |
| V-180 | D-57 sur les **20 sites** : lecture par catégorie, défaut par `par_defaut` (D-89), 0 littéral ; porte AST + passe « ordre inversé et second code de catégorie » sur les 57 positifs (S-PCD4) | CODE · BRAIN CODE (porte) |
| V-181 | une seule garde, `politique_admise`, **générée** du registre : couple servi + forme canonique + contraintes ; `valeurs_possibles` en sort ; les 33 défauts de listes en JSON ; `SetOwnTheme` passe par elle | BRAIN CODE (générateur, migration) · CODE (`SetPolicy`, `SetOwnTheme`) |
| V-182 | **D-88** : `depuis_signature` sort de l'entrée publique ; ce que la cascade transmet passe par le contexte serveur (S-PM4) | CODE |
| V-183 | les règles en phrase sont des lignes (registre v2 : S-K1 → S-K3, S-UT2, S-PM3, S-PCL1) | BRAIN ✅ · CODE |
| V-184 | `CreateCompany` et `UpdateCompany` écrivent le SIREN ; une colonne comparée par une garde de doublon est écrite par la commande (S-DS4) | CODE |
| V-185 | M-15 : un coût garde **sa** devise ; seul le taux s'écrit (S-CH2) | CODE |
| V-186 | aucun GRANT de banc dans une migration de production | BRAIN CODE |
| V-187 | la porte croisée joue D-59 (une délégation sur une autre agence seule opère, S-SP5) et juge les permis de `par_besoins` | BRAIN CODE · CODE |
| V-188 | une porte verte et ⏳ → KO au cliquet ; P-359 → P-361 passent ✅ | BRAIN CODE |
| V-189 | la case 22 récupère `lot-2-brain` dans un clone neuf (`git fetch origin lot-2-brain`), et la CI aussi | BRAIN CODE |
| V-190 | propagation : **tous** les contacts de l'unité contractante (S-PR1) ; R10 : contact exigé en régie même avec une unité (S-PC5) | CODE |
| V-191 | le registre v2 | BRAIN ✅ |
| V-192 | `v011-politiques.ts` : ses portes qui contredisent le registre sont retirées (déclarées D-41) ; la porte des politiques est **générée**, jamais écrite à la main | BRAIN CODE |
| V-193 | une seule horloge, gardée par une porte (le sabotage « Node au lieu de la base » doit tomber) ; les gardes en double retirées | CODE · BRAIN CODE |
| V-194 | les contrôles B1 et D3 de la grille renvoient à la porte AST, plus à un grep | BRAIN ✅ |
| V-166 → V-175 (10e tour) | **chacun** fermé avec sa porte, ou déclaré avec décision (D-83) | CODE |

<source>

Rapport : `audits-independants/ava-audit-11/rapport/` (SYNTHESE, CONSTATS, SUIVI_V, REGISTRE, MUTATIONS, SECURITE,
CONFORMITE, GRILLE), copié dans `audit-2026-10-04/`.

</source>
