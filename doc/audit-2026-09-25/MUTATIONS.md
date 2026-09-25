# Mutations — les tests des tests (famille G), huitième audit

⭐ Base refaite puis `make.sh test` : **332 portes vertes, 41 assertions, make_rc=0** (`preuves/banc/S0_reference.txt`).
⭐ **0 porte aveugle sur 71 sabotages** : chaque correctif du 7e tour fait tomber au moins une porte quand on le
retire, ou se heurte à une seconde garde qui refuse quand même.
⛔ Mais la mutation ne voit que ce que les portes visent. La porte systématique `croise_55`, construite par l'audit
(`preuves/securite8/croise_55.mjs`), trouve **17 fuites sur 96 champs** — ce que les 332 portes ne cherchent pas.

| Sabotage | Tombées | Verdict |
|---|---|---|
| **S1 → S5bis** commandes, événements, transaction, droits ×6, politiques ×7 | toutes au moins 1 | ✅ |
| **S6 · S7 · S12→S14 · N8→N10** murs SQL | P-001 ×15 | ✅ |
| **S8 · S9 · S10** écrans besoin | 0 | ⚠️ portes ⏳ lot 3 |
| **U1→U7 · W2→W5 · T4 · T5** garde d'entrée, vue, table d'agence, outils de garde, `soi` | 1 à 252 | ✅ |
| **X2 · X3 · X5** modèle société | 3 · 15 · 7 | ✅ |
| **Y3 · Y4 · Y5** `ArchiveObject` action, personne, type dédié | 1 · 1 · 4 | ✅ |
| **Z1** l'entrée ambiguë n'est plus refusée | **P-326 P-327 P-332 P-333 P-334** | ✅ V-128 : le correctif livré est gardé |
| **Z2** la paire `id` / `positionnement_id` retirée | **P-332** | ✅ |
| **Z3** la liste blanche des clés n'est plus appliquée | **P-327 P-334** | ✅ |
| **Z5** `soi` couvre de nouveau toute agence | **P-329 P-336** | ✅ V-129 |
| **Z4** `CreateProject` ne lit plus l'agence du besoin | 0 | ⚠️ P-328 reste vert : une **seconde vérification** rend quand même `DROIT` (non identifiée — angle mort) |
| **Z6** `TransferContact` : le « deux lectures exigées » retiré | 0 | ⚠️ double garde : `exigerToutes` juge déjà les deux agences |
| **T6** comptes de banc réactivés | 0 | ⚠️ sans effet (fixture) |

## La porte systématique `croise_55` — ce que les portes ne cherchent pas

55 commandes · 96 champs d'identifiant pointés vers une autre agence · 69 contrôles positifs dans l'agence :
**79 refus sans écriture · 17 FUITES · 69/69 positifs OK** (`preuves/securite8/croise_55.md`). Exemple qui résume
tout : `CreateCompany` avec `manager` hors agence → **DROIT** ; le même avec `manager_compte_id` → **ÉCRIT**.

## Le cliquet, rejoué en vrai — 13 cases (`preuves/banc/C_*.txt`)

| Témoin | Résultat | Verdict |
|---|---|---|
| rien de saboté | **12/13** — seule la case 12 (crochet, clone neuf) | ✅ |
| serveur mort | case 1 KO « exécutées=2 ✅=332 » | ✅ |
| 99 portes effacées, avec ou sans commit | case 11 KO | ✅ |

## Le compte

| | 1er | 5e | 6e | 7e | 8e (`48e90c4`) |
|---|---|---|---|---|---|
| Sabotages | 37 | 62 | 69 | 70 | **71** |
| Portes servies | 64 | 294 | 307 | 318 | **332** |
| Portes aveugles | 48 | 1 | 1 | 1 | **0** |
| Fuites `croise_55` | — | — | — | — | **17 / 96** |
