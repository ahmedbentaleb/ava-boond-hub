# Mutations — les tests des tests (famille G), neuvième audit

⭐ Base refaite puis `make.sh test` : **331 portes jouées (330 ✅ + P-339 ⏳), 41 assertions, make_rc=0**.
⭐ **Sur 10 sabotages des règles de construction, 8 font tomber une porte.** Les 2 autres : `TransferContact`
(R7, aveugle — V-155) et « noter sous le premier nom seulement » (R8, sans fuite : le synonyme est ignoré).

⚠️ Comptage : dans `_JOURNAL.txt`, la colonne « vertes » ne compte plus que 3 portes, le rapporteur TAP ayant changé
de format ; la colonne « tombées », elle, est exacte (lignes `not ok`). S2b ne se mesure plus (V-159).

| Sabotage | Tombées | Verdict |
|---|---|---|
| **S1 · S2a · S3a · S3b** | 250+ | ✅ (S3b tombé par le 500) |
| **S4 · S5 · S5bis** droits, politiques | au moins 1 chacun | ✅ |
| **S6 · S7 · S12→S14 · N8→N10 · R10** murs SQL | assertions KO | ✅ |
| **S8 · S9 · S10** écrans besoin | 0 | ⚠️ portes ⏳ lot 3 |
| **U · W · X · Y · Z1 · Z4 · T4** correctifs des tours 3 à 8 | au moins 1 chacun | ✅ |
| **R1** un champ lu par la commande sans être déclaré | **P-339** | ✅ la porte croisée le voit |
| **R2** un synonyme ajouté à la garde | **8 portes** | ✅ |
| **R3** `soi` vaut « toutes agences » | **P-329 P-340** | ✅ |
| **R4** l'agence demandée d'une unité n'est plus confrontée | **P-291 P-339** | ✅ |
| **R5** `CreateUnit` sort de la table | **22 portes** | ✅ |
| **R6** la liste de clés par commande n'est plus appliquée | **P-327** | ✅ |
| **R9** `GRANT INSERT ON agence TO ava_app` | **P-325** | ✅ GRANT calculé gardé |
| **R7** `TransferContact` ne juge qu'une agence | **0** | ⛔ **aveugle**, 4e tour (V-155) |
| **R8** la garde note l'objet sous son premier nom seulement | 0 | ⚠️ sans fuite : le second nom est ignoré par la commande |
| **T6** comptes de banc réactivés | 0 | ⚠️ sans effet (fixture) |

## Le cliquet, rejoué en vrai — 17 cases (`preuves/banc/C_*.txt`)

| Témoin | Résultat | Verdict |
|---|---|---|
| rien de saboté | **16/17** — seule la case 12 (crochet, clone neuf) ; case 14 « porte croisée : copie = canon » OK | ✅ |
| serveur mort | case 1 KO « exécutées=2 » | ✅ |
| 100 portes effacées, avec ou sans commit | case 11 KO | ✅ |
| ⚠️ | « exécutées=331 ✅=330 » : P-339 est ⏳, rouge elle ne bloquerait pas (V-153) | |
