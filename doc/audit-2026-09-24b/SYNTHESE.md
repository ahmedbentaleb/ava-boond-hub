**REFUSÉ** — lot 2, commit `a26291c`, sixième audit du 24/09/2026, clone isolé `ava-audit-6`, base `ava_audit6`, port 3600. Contrôle d'ancêtre (F13) et `_ops/` intact vérifiés avant tout.
Le modèle est tranché et le banc est solide ; il reste **un seul défaut critique**, et sa racine tient en une ligne : `server/src/agence.ts:285`, qui retombe sur l'agence du demandeur quand celle de l'objet n'est pas lue.

| Mesure | 4e | 5e | 6e (`a26291c`) |
|---|---|---|---|
| Banc sur base neuve | ⛔ rouge | vert | ✅ **vert** — 307 portes, 40 assertions |
| Sabotages · chemins aveugles | 57 · 1 | 62 · 1 | **69 · 1** (W1, la ligne de repli) |
| Cliquet dans un clone neuf | 10/12 | 11/12 | **12/13** — case 13 (F13) tourne ; seul le crochet manque, la CI le pose |
| Constats du tour précédent | — | 10 fermés | **3 fermés · 6 partiels · 1 ouvert** |
| Défauts critiques ouverts | 2 | 2 | **1** |

1. **V-117 (critique)** — `ArchiveObject` sait archiver 10 types d'objets, sa ligne d'agence n'en lit que 5 : même compte, même société d'une autre agence, `ArchiveCompany` refuse et `ArchiveObject` **archive**. Mesuré par les deux vérificateurs, chacun de son côté ; le sabotage W1 laisse 307 portes vertes.
2. **V-118 · V-122 (elevee)** — la ligne de repli contredit la décision D-26 écrite juste au-dessus ; et le lot 3 est déjà en base (27 tables écrivables, 95 commandes au contrat pour 55 servies).
3. ⭐ **La correction qui ferme la série** : un objet dont l'agence n'est pas lue est un **refus**, jamais une permission. Quatre tours ont corrigé commande par commande (V-076 → V-097 → V-107 → V-117) ; supprimer cette ligne ferme la famille entière.

⭐ Ce qui tient, mesuré : la politique `societe.perimetre.mode` (3 modes, 3 comportements, gardée par 3 portes) ; F13, `ON_ERROR_STOP`, `verif_serveur.sh` gardés ; 15 sabotages SQL sur 15 ; hors banc 11 routes sur 11 en 401, 49 refus sans une ligne écrite.

❓ Angles morts : CI GitHub non exécutée ; écrans besoin ⏳ lot 3 (7 sabotages sans porte servie) ; X1/X4 visent une branche devenue inatteignable ; T6 sans effet (la fixture réactive les comptes) ; un vérificateur a posé lui-même des délégations dans sa base pour trouver V-117 (déclaré) ; VPS, `.zip`, `.docx` et `Fonds ERP` non ouverts.
