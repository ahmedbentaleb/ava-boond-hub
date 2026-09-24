**REFUSÉ** — lot 2, commit `ba9a284`, septième audit du 24/09/2026, clone isolé `ava-audit-7`, base `ava_audit7`, port 3700. Contrôle d'ancêtre (F13) et `_ops/` intact vérifiés avant tout.
V-117 est fermé pour de bon — la ligne de repli a disparu ; il reste **un défaut critique d'une famille nouvelle** : la garde d'agence et la commande lisent l'entrée chacune de leur côté.

| Mesure | 5e | 6e | 7e (`ba9a284`) |
|---|---|---|---|
| Banc sur base neuve | vert | vert | ✅ **vert** — 318 portes, 41 assertions |
| Sabotages · chemins aveugles | 62 · 1 | 69 · 1 | **70 · 1** (Y6, `TransferContact`) |
| Cliquet dans un clone neuf | 11/12 | 12/13 | **12/13** (seul le crochet, que la CI pose) |
| Constats du tour précédent | 10 fermés | 3 fermés | **6 fermés · 3 partiels · 1 ouvert** |
| Défauts critiques ouverts | 2 | 1 | **1**, d'une autre famille |

1. **V-128 (critique)** — pour `DeclareCVShared`, la garde lit `id` en premier (`agence.ts:56`) et la commande `positionnement_id` en premier (`besoin.ts:276`) : on envoie les deux, la garde juge Paris, la commande modifie Casablanca. Même mécanique sur 6 autres commandes ; `CreateProject` écrit un `besoin_id` jamais contrôlé. Mesuré par les deux vérificateurs, chacun de son côté.
2. **V-129 · V-130 (elevee)** — un périmètre `soi` posé par `ManageGroups` vaut `global` (`droits.ts:32`) ; `TransferContact` qui ne juge qu'une agence sur deux ne fait tomber aucune porte.
3. ⭐ **La correction qui ferme la famille** : la garde trouve l'objet **une seule fois** et le transmet à la commande, qui ne relit plus l'entrée.

⭐ Ce qui tient, mesuré : les 55 natures de commande sont cohérentes ; `ArchiveObject` refuse les 10 types hors agence ; le modèle société tient sous sabotage (3, 15 et 7 portes tombent) ; 52 sondes hors agence refusées sans une écriture ; 15 sabotages SQL sur 15.

❓ Angles morts : CI GitHub non exécutée ; écrans besoin ⏳ lot 3 ; Y1/Y2 visent une double garde et du code inatteignable ; T6 sans effet ; `_ops/JEU_ESSAI.sql` ne se charge plus (V-135) ; les vérificateurs ont posé des délégations et une agence LYO dans leurs bases pour sonder (déclaré) ; VPS, `.zip`, `.docx` et `Fonds ERP` non ouverts.
