# Mutations — les tests des tests (famille G), quatrième audit

⛔ **Le banc de référence est ROUGE** : sur une base neuve, `make.sh test` rend 1 et la porte **P-207** tombe
(V-096). Toutes les lignes qui suivent portent donc P-207 en plus de ce qu'elles font tomber ; il est retiré
des comptes.

⭐ **48 portes aveugles (1er) → 45 (2e) → 0 (3e) → 1 (4e)** : le sabotage **U4** (l'agence donnée en entrée
n'est plus confrontée à celle lue en base) ne fait tomber aucune porte.

Protocole inchangé : `git status` vide → base `ava_audit4` refaite → UN sabotage → `outils/make.sh test`
complet (280 portes ✅) → `git checkout` → `git status` vide. Port 3400. Journal : `preuves/banc/_JOURNAL.txt`,
diff de chaque sabotage : `preuves/banc/<clé>.diff.txt`.

| Sabotage | Tombées (hors P-207) | Verdict |
|---|---|---|
| **S1** toute commande rend INTROUVABLE | 253 | ✅ |
| **S2a / S2b** `emit()` n'écrit plus (base fraîche, puis déjà jouée) | 208 chacune | ✅ |
| **S3a / S3b** écrit puis lève · `ROLLBACK` → `COMMIT` | 211 | ✅ / ⚠️ tombée par le 500 |
| **S4a→d** droit retiré (UpdateResourceCost, SetPolicy, RecordClientDecision, DeclareNeedFilled) | P-027 P-127 P-202 · 17 · P-042 P-127 P-169 P-205 · P-127 P-161 P-205 | ✅ (ancre adaptée : le droit passe par `exigeAgence`) |
| **S4e** règle « soi-même » de `RecordTimesheet` | P-208 | ✅ |
| **S4f** `CreatePrestation` signée sans `SignPrestation` | P-126 | ✅ |
| **S5a→f** une politique écrite en dur (6 clés) | P-134 P-144 · P-006 P-130 P-240 · P-060 P-131 · P-132 · P-133 · P-209 | ✅ |
| **S5bis** politique lue puis ignorée | P-130 P-131 P-240 | ✅ |
| **S6a→g** `DISABLE TRIGGER` ×7 (dont M-12 sur contact et projet) | P-001 ×7 | ✅ |
| **S7a/b · S12 · S13 · S14 · N8 · N9 · N10** GRANT interdits ×8 | P-001 ×8 | ✅ |
| **S8 · S9 · S10** libellés, couleurs, compte calculé dans les écrans besoin (7 passes) | 0 | ⚠️ aucune porte **servie** ne les vise (P-061→P-065 ⏳ lot 3) |
| **N1 · N2** thème servi par le serveur | P-002 P-004 P-005 | ✅ |
| **N6 · N7** la trace des refus muette · `REVOKE INSERT` | P-254 P-257 | ✅ |
| **U1** le garde d'entrée (D-14) ne refuse plus rien hors banc | **P-066 P-271 P-274** | ✅ V-075 gardé |
| **U2** la vue rend tous les besoins, sans filtre d'agence | **P-266 P-271** | ✅ |
| **U3** `CreateUnit` sort de la table de correspondance d'agence | **14 portes** (P-010 P-011 P-075…) | ✅ V-076 gardé |
| **U4** l'agence donnée en entrée n'est plus confrontée à celle lue | **0** | ⛔ **aveugle** (V-100) |
| **U5** la lecture de l'agence de l'objet rend toujours « rien » | **44 portes** | ✅ |
| **U6** le fichier d'assertions perd son propre `ON_ERROR_STOP` | **0** | ⛔ trou (V-101) |
| **U7** `verif_serveur.sh` rend 0 quoi qu'il voie | **0** | ⛔ trou (V-101) |
| **T4 · T5** le périmètre `soi` ignoré · `soi` traité comme `global` | P-129 P-208 · 48 portes | ✅ |
| **T6** comptes de banc réactivés en base | 0 | ⚠️ sabotage **sans effet** : `make test` recharge `db/fixtures/banc.sql`, qui les réactive de toute façon |
| **U8** `v_besoin_couverture` rendue fausse | (SQL refusé : la vue a des dépendances) | ⚠️ non joué |

## Le cliquet, rejoué en vrai (`preuves/banc/C_*.txt`)

| Témoin | Résultat | Verdict |
|---|---|---|
| rien de saboté | **cases OK=10 KO=2** : case 1 KO (`P-207` rouge), case 12 KO (crochet non posé dans un clone neuf) | ⛔ le 12/12 annoncé n'est pas reproductible (V-096) |
| serveur mort | case 1 KO, « exécutées=2 ✅=280 » | ✅ |
| 86 portes effacées du tableau, sans commit | case 1 KO (194 ✅ au lieu de 280), case 11 KO | ✅ |
| les mêmes effacées **dans un commit**, puis un commit de plus | **case 11 KO** « perdues : P-200 … » | ✅ **V-077 fermé** — la fenêtre part bien du départ de la branche (144 commits) |

## Le compte

| | 1er | 2e | 3e | 4e (`cc3ff64`) |
|---|---|---|---|---|
| Sabotages | 37 | 47 | 50 | **57** |
| Portes servies | 64 | 151 | 264 | **280** |
| **Portes aveugles** | 48 | 45 | 0 | **1** (U4) |
| Sabotages que rien ne voit | 19 | 6 | 2 | **3** : les écrans ⏳, `ON_ERROR_STOP`, `verif_serveur.sh` |
| Banc de référence | vert | vert | vert | ⛔ **rouge** (P-207) |
