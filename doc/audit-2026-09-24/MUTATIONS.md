# Mutations — les tests des tests (famille G), cinquième audit

⭐ **Le banc part enfin de rien** : base refaite puis `make.sh test` → **294 portes vertes, 32 assertions,
make_rc=0** (`preuves/banc/S0_reference.txt`). V-096 fermé.
⛔ **1 porte aveugle** : le sabotage **W1** (le repli silencieux sur une agence nulle revient) ne fait tomber
aucune des 294 portes — c'est le demi-correctif de V-097 (V-107).

Protocole inchangé : `git status` vide → base `ava_audit5` refaite → UN sabotage → `make.sh test` complet →
`git checkout` → `git status` vide. Port 3500. Journal : `preuves/banc/_JOURNAL.txt`.

| Sabotage | Tombées | Verdict |
|---|---|---|
| **S1** toute commande rend INTROUVABLE | 267 | ✅ |
| **S2a / S2b** `emit()` n'écrit plus (base fraîche, puis déjà jouée) | 222 | ✅ |
| **S3a / S3b** écrit puis lève · `ROLLBACK` → `COMMIT` | 225 | ✅ / ⚠️ tombée par le 500 |
| **S4a→f** un droit retiré ×4, règle « soi-même », porte de derrière O-2 | P-027 P-127 · 17 · P-042 · P-127 · P-208 · P-126 | ✅ |
| **S5a→f · S5bis** une politique en dur (6 clés) · lue puis ignorée | P-134 P-144 · P-130 · P-131 · P-132 · P-133 · P-209 · P-240 | ✅ |
| **S6 ×7 · S7 ×2 · S12 · S13 · S14 · N8 · N9 · N10** murs SQL (triggers et GRANT) | P-001 ×15 | ✅ |
| **S8 · S9 · S10** écrans besoin (7 passes) | 0 | ⚠️ portes ⏳ lot 3 |
| **N1 · N2** thème servi par le serveur | P-002 P-004 P-005 | ✅ |
| **N6 · N7** trace des refus muette · `REVOKE INSERT` | P-254 P-257 | ✅ |
| **U1** garde d'entrée (D-14) ouvert hors banc | P-066 P-271 P-274 | ✅ |
| **U2** vue sans filtre d'agence | P-266 P-271 | ✅ |
| **U3** une commande sort de la table de correspondance | 16 portes | ✅ |
| **U5** la lecture de l'agence de l'objet rend « rien » | **210 portes** | ✅ |
| **T4 · T5** périmètre `soi` ignoré · `soi` = `global` | P-129 P-208 · 51 portes | ✅ |
| **W1** le repli silencieux sur agence nulle revient | **0** | ⛔ **aveugle** (V-107) |
| **W2 / U4** la confrontation « agence demandée ≠ agence lue » retirée | **P-291** | ✅ (V-100 fermé et gardé) |
| **W3 / U6** le fichier d'assertions perd son `ON_ERROR_STOP` | **P-299** | ✅ (V-101 fermé et gardé) |
| **W4 / U7** `verif_serveur.sh` rend 0 quoi qu'il voie | **P-300** | ✅ |
| **W5** l'identité par défaut revient dans les vues | **P-292** | ✅ (V-103 fermé et gardé) |
| **T6** comptes de banc réactivés en base | 0 | ⚠️ sabotage sans effet : la fixture les réactive de toute façon |

## Le cliquet, rejoué en vrai (`preuves/banc/C_*.txt`)

| Témoin | Résultat | Verdict |
|---|---|---|
| rien de saboté | **cases OK=11 KO=1** — seule la case 12 (crochet non posé dans un clone neuf, la CI le pose) | ✅ **case 1 verte sur base neuve** : V-096 fermé |
| serveur mort | case 1 KO, « exécutées=2 ✅=294 » | ✅ |
| 99 portes effacées du tableau, sans commit | case 1 (195 ✅) et case 11 KO | ✅ |
| les mêmes effacées **dans un commit** | case 11 KO | ✅ V-077 tient |

## Le compte

| | 1er | 2e | 3e | 4e | 5e (`b6ff087`) |
|---|---|---|---|---|---|
| Sabotages | 37 | 47 | 50 | 57 | **62** |
| Portes servies | 64 | 151 | 264 | 280 | **294** |
| **Portes aveugles** | 48 | 45 | 0 | 1 | **1** (W1) |
| Banc de référence | vert | vert | vert | ⛔ rouge | ✅ **vert depuis rien** |
