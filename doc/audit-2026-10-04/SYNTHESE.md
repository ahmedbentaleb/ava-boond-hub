**REFUSÉ** — lot 2, commit `34d98a4`, onzième audit du 04/10/2026, clone `audits-independants/ava-audit-11`, base `ava_audit11`, port 4100. F13, `_ops/` intact et D-78 (fichiers du juge) vérifiés avant tout.
Le registre exécutable a pris : 203 cas sur 206 conformes, rejoués par un rejoueur indépendant, et 0 fuite d'agence. Ce qui refuse le lot, c'est **ce que les lignes ne jouent pas** : une cascade qui saute la garde, des réglages admis sans ligne qui retirent une garde, une clé publique qui en lève une autre, et D-57 tenu sur un seul cas.

| Mesure | 9e | 10e | 11e (`34d98a4`) |
|---|---|---|---|
| Banc sur base neuve | 331 portes | 342 | ✅ **348 vertes, 41 assertions** · cliquet **20/22** (crochet, et la case 22 introuvable en clone neuf, V-189) |
| Porte croisée | 0 fuite, ⏳ | 0 fuite, 691 id. | ✅ **0 fuite, 846 identifiants, 6 passes, 0 ligne sans attendu** |
| Registre exécutable | — | — | ✅ **203/206** cas conformes · 287 = 287 couples générés · porte différentielle 264 jeux |
| Sabotages | 8/10 de construction | 55/59 | **62/67** · corrections du tour : **7/8** (l'horloge unique n'a pas de porte) |
| Constats du tour précédent | 5 fermés | 11 fermés | **1 fermé · 8 partiels · 8 ouverts** · décisions : 9/12 gardées, D-66 non codée |

| Famille critique | Étendue mesurée | Correction de construction |
|---|---|---|
| **V-179** une cascade saute la garde de sa fille, sur un nom de commande | droit seul sur LYO → 1 projet créé dans LYO ; droit retiré → projet créé quand même | `executerDans` sans aucun contournement ; porte par ligne de `CASCADES` |
| **V-180** D-57 tenu sur un cas, pas sur la famille | un 2e code « prospect » (geste ADM) → la signature ne passe plus client ; `ordre` inversé → `forfait` au lieu de `regie` ; 20 sites | lecture par catégorie, défauts en politique ; porte AST + permutation de chaque `ref_*` |
| **V-181** admis ≠ servi | `[]` accepté → deux sociétés identiques sous `bloquer` ; 8 portes exigent des valeurs sans ligne ; `service_ou_societe` inatteignable mais verte (posée en SQL) | une seule garde générée ; la porte pose par `SetPolicy` |
| **V-182** clé publique qui lève une garde | `depuis_signature: "oui"` → besoin pourvu à 0/2 | le contexte de cascade dans `ctx`, jamais dans l'entrée |
| **V-183** règles du registre en prose | 2/2 fausses (`temps_valides` sous `aucune`, thème non servi) ; 3 portes exigent le contraire | toute règle est une ligne ; lint du registre |
| **V-184** le SIREN n'est jamais écrit | la clé de doublon `[siren]` ne protège aucune société créée par l'application | champ comparé ⇒ champ écrit, dérivé de `DECLARATION` |

⭐ La correction qui fermerait la moitié : **jouer le registre par le chemin de l'utilisateur** — politiques posées par `SetPolicy`, chaque clé déclarée essayée seule sur chaque refus, chaque cascade jouée sans le droit de la fille, chaque issue au pluriel sur deux éléments.

❓ À trancher (BRAIN) : (1) listes — servir « toute partie du domaine » ou seulement les listes écrites (V-181) ; (2) `PositionCandidate` fait passer un besoin en recherche sans `TakeNeedInCharge` : la politique vaut-elle droit ?

Angles morts : CI non observée (V-189 déduit de `ci.yml` et mesuré en clone neuf) ; écrans ⏳ lot 3 ; VPS (K5) ; concurrence ; deux bancs ne tournent pas sans collision sur un même PostgreSQL (1 collision, rejouée) ; les vérificateurs ont posé données, groupes et délégations dans leurs bases (`ava_audit11_a`, `_b`, `_c`), déclarés dans SUIVI_V, REGISTRE et SECURITE.
