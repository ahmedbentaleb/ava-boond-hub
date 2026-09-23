**REFUSÉ** — lot 2, commit `cc3ff64`, quatrième audit du 23/09/2026, clone isolé `ava-audit-4`, base `ava_audit4`, port 3400.
Les deux critiques du 3e tour sont fermés **et gardés par des portes qui tombent** ; ce qui refuse le lot, c'est que le banc lui-même est rouge sur une base neuve, et qu'un objet sans agence n'est gardé par personne.

| Mesure | 2e (`7e3f78c`) | 3e (`416a7a3`) | 4e (`cc3ff64`) |
|---|---|---|---|
| Portes aveugles | 45 | 0 | **1** (U4 : agence demandée ≠ agence lue) |
| Sabotages joués | 47 | 50 | **57** · portes servies **280** · assertions **31** |
| Constats du tour précédent | 27 neufs | 21 neufs | **20 fermés · 4 partiels · 1 ouvert assumé** |
| Cliquet réel, base neuve | — | 11/12 | ⛔ **10/12** : case 1 KO (P-207), case 12 KO (clone neuf, normal) |
| Grille · conformité | 1 🔴 | 1 🔴 | **33 ✅ · 7 🟠 · 1 🟡 · 1 🔴** · 55/55 commandes, 0 écart |

1. **V-096 (critique)** — base refaite puis `make test` : `P-207` tombe (`ManageRefs` avec `categorie:"europe"`, alors que `ref_pays` n'a que `defaut` au seed et que la garde de V-084 n'accepte qu'une catégorie existante). Le 12/12 annoncé vient d'une base qui traîne une donnée d'un tour antérieur à la garde.
2. **V-097 (critique)** — `agence.ts:202` : objet lu, agence nulle → **aucun contrôle**. Toute unité de société cliente naît sans agence (`crm.ts:170`) : un compte de LON renomme et archive une unité cliente de PAR ; témoin positif sur une unité interne → refus.
3. **V-100 (elevee)** — la confrontation « agence demandée ≠ agence lue » n'est gardée par aucune porte : le sabotage U4 laisse 280 portes vertes.

⭐ Ce qui tient, mesuré : V-075, V-076, V-077 et V-078 fermés **et** gardés (garde d'entrée saboté → 3 portes tombent ; table d'agence → 14 ; lecture d'agence → 44) ; hors banc 11 routes sur 11 en 401, rien d'écrit ; 15 sabotages SQL sur 15 font tomber les assertions.

❓ Angles morts : CI GitHub non exécutée ; case 12 KO dans un clone neuf (`installer.sh` non lancé — la CI le lance) ; écrans besoin ⏳ lot 3, donc 7 sabotages d'écran ne visent aucune porte servie ; sabotage T6 sans effet (la fixture réactive les comptes) et U8 non joué (vue dépendante) ; VPS, `.zip`, `.docx` et `Fonds ERP` non ouverts.
