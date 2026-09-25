**REFUSÉ** — lot 2, commit `48e90c4`, huitième audit du 25/09/2026, clone isolé `ava-audit-8`, base `ava_audit8`, port 3800. F13 et `_ops/` intact vérifiés avant tout.
Pour la première fois, **aucune porte n'est aveugle** — mais une porte systématique, construite par l'audit, trouve **17 fuites entre agences sur 96 champs** que les 332 portes ne cherchent pas.

| Mesure | 6e | 7e | 8e (`48e90c4`) |
|---|---|---|---|
| Banc sur base neuve | vert | vert | ✅ **332 portes, 41 assertions** |
| Portes aveugles / sabotages | 1 / 69 | 1 / 70 | **0 / 71** |
| Porte systématique `croise_55` | — | — | ⛔ **17 fuites / 96 champs** · 69/69 positifs |
| Cliquet dans un clone neuf | 12/13 | 12/13 | **12/13** (seul le crochet, que la CI pose) |
| Constats du tour précédent | 3 fermés | 6 fermés | **4 fermés · 4 partiels · 1 ouvert** |

1. **V-138 (critique)** — la recommandation du 7e tour (« la garde transmet l'objet à la commande ») n'est appliquée qu'à **5 commandes sur 55**. Exemple : `CreateCompany` refuse un `manager` d'une autre agence, et accepte le même sous le nom `manager_compte_id`. Trois comptes de Paris font passer une société de Casablanca en « client ».
2. **V-139 (critique)** — `droits.ts:28-33` : le commentaire dit « `soi` ne couvre aucune agence », le code la fait couvrir toutes. Un compte `RES` + `STAF` de Paris écrit absences et documents à Casablanca.
3. ⭐ **Ce qu'il faut faire** : faire entrer `croise_55` dans le banc (0 fuite exigé), puis la correction structurelle — chaque commande déclare ses identifiants, la garde les résout, la commande ne relit jamais la requête. Grok tourne jusqu'à 0 fuite **sans audit entre-temps**.

⭐ Ce qui tient : 0 porte aveugle ; hors banc 173 appels sur 173 en 401 ; `TransferContact`, les tables écrivables, les CHECK et le jeu d'essai fermés.

❓ Angles morts : CI non exécutée ; écrans ⏳ lot 3 ; Z4 et Z6 heurtent une seconde garde non identifiée ; périmètres `pole` et `equipe` non sondés ; les vérificateurs ont posé les 55 permissions, une agence LYO et des comptes cumulés dans leurs bases (déclaré) ; VPS, `.zip`, `.docx`, `Fonds ERP` non ouverts.
