**REFUSÉ** — lot 2, commit `16ea24d`, dixième audit du 01/10/2026, clone `audits-independants/ava-audit-10`, base `ava_audit10`, port 4000. F13 et `_ops/` intact vérifiés avant tout.
La construction du 9e tour a pris : 0 fuite d'agence sous toutes les valeurs de périmètre, cascades gardées, 5 sabotages de construction sur 5 vus. Ce qui refuse le lot, c'est **le paramétrage** : des valeurs « servies » ne font rien ou font l'inverse, des portes vertes le certifient, et un réglage d'affichage bloque toutes les signatures.

| Mesure | 8e | 9e | 10e (`16ea24d`) |
|---|---|---|---|
| Banc sur base neuve | vert | 331 portes | ✅ **342 portes exécutées, 342 ✅, 41 assertions** · cliquet **18/19** (seul le crochet) |
| Porte croisée | 17 fuites | 0 fuite, ⏳ | ✅ **0 fuite, 691 identifiants, 5 passes**, dans le cliquet — mais 60 lignes non jugées (V-165) |
| Sabotages | — | 8/10 de construction | **55/59 vus** · Q1 → Q5 : **5/5** · les 4 aveugles : **0 fuite** (code mort, V-175) |
| Constats du tour précédent | 4 fermés | 5 fermés | **11 fermés · 2 partiels · 1 ouvert** · D-48 → D-55 : **8/8 codées et gardées** |

| Famille critique | Étendue mesurée | Correction de construction |
|---|---|---|
| **V-162** valeurs servies sans comportement (V-147 s'étend) | 108 politiques sans lecteur, 66 valeurs métier acceptées sans effet ; 6 valeurs lues mais fausses — la plus stricte de `temps.periode` **retire** la garde | `COMPORTEMENTS` dérivé de la carte, une stratégie par valeur ; porte différentielle par clé |
| **V-163** métier en dur hors politiques | `ordre=7` sur « client » (geste permis à ADM) → **toute signature tombe** ; 3 noms de commande dans la garde ; 27 littéraux SQL | catégorie fermée pour `ref_statut_commercial` ; porte qui permute `ordre` et rejoue les 57 positifs |
| **V-164** portes qui gravent le code | P-233, P-230, P-215 exigent l'inverse du registre | l'effet de chaque couple devient une donnée du registre, d'où se génèrent les cas |

⭐ La correction qui fermerait les trois : **le registre des politiques devient exécutable** — pour chaque (clé, valeur), la commande lectrice et l'issue attendue ; `COMPORTEMENTS`, `commandes_affectees` (V-172) et les portes s'en dérivent.

❓ À trancher (BRAIN) : sous `par_besoins`, l'agence responsable perd tout droit sur sa propre société tant qu'aucun besoin n'existe (13 positifs refusés, dont une signature) ; une délégation sur une autre agence seule est inopérante.

Angles morts : CI non exécutée ; écrans ⏳ lot 3 ; VPS (K5) ; concurrence ; deux bancs ne tournent pas en parallèle sur un même PostgreSQL (témoin écarté, rejoué seul) ; les vérificateurs ont posé des données et des délégations dans leurs bases (`ava_audit10_a`, `_b`), déclarées dans SUIVI_V et SECURITE.
