**REFUSÉ** — lot 2, commit `071b7b2`, neuvième audit du 29/09/2026, clone `audits-independants/ava-audit-9`, base `ava_audit9`, port 3900. F13 et `_ops/` intact vérifiés avant tout.
La construction a pris : la porte croisée est dans le banc (0 fuite sur 117 identifiants) et 8 règles de construction sur 10 sont gardées. Ce qui refuse le lot, ce sont **trois familles que la porte croisée ne regarde pas** : les réglages, les cascades, et les valeurs non par défaut.

| Mesure | 7e | 8e | 9e (`071b7b2`) |
|---|---|---|---|
| Banc sur base neuve | vert | vert | ✅ **331 portes, 41 assertions** · cliquet **16/17** (seul le crochet) |
| Porte croisée | — | 17 fuites (script d'audit) | ✅ **0 fuite**, dans le banc — mais ⏳, elle ne bloque rien |
| Sabotages de construction | — | — | **8 / 10 gardés** |
| Constats du tour précédent | 6 fermés | 4 fermés | **5 fermés · 3 partiels · 1 ouvert** |

| Famille critique (V-147 → V-149) | Étendue mesurée | Correction de construction |
|---|---|---|
| **Valeurs de politique sans comportement** | 11 valeurs / 7 politiques — une retire la garde, une bloque toute saisie | un comportement déclaré par valeur ; `SetPolicy` refuse le reste ; porte politiques × valeurs |
| **Cascades non gardées** | 2 mesurées : STAF clôt une prestation qu'il ne peut pas clôre ; une société de Lyon passe « client » depuis Paris | la cascade appelle la commande fille par `executerCommande` ; porte par cascade déclarée |
| **Garde valable au seul réglage par défaut** | en `partagee` / `par_besoins`, Paris modifie un projet et un besoin de Lyon (`agence.ts:656`) | la politique société ne juge que la société ; porte croisée jouée sous **chaque** valeur |

⭐ La correction qui fermerait aussi V-150 à V-152 : **une seule déclaration typée par commande** (clé → table → rôle), d'où dérivent la liste des clés, les lecteurs et les cas de la porte croisée.

❓ Angles morts : CI non exécutée ; écrans ⏳ lot 3 ; VPS (K5) ; concurrence ; la colonne « vertes » du journal de mutation est faussée par le format TAP (les « tombées » sont exactes) ; les vérificateurs ont posé permissions, agence LYO et comptes cumulés dans leurs bases (déclaré).
