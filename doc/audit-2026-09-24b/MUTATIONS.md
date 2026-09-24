# Mutations — les tests des tests (famille G), sixième audit

⭐ Base refaite puis `make.sh test` : **307 portes vertes, 40 assertions, make_rc=0** (`preuves/banc/S0_reference.txt`).
⛔ **3 sabotages que rien ne voit, tous sur le même chemin : le repli d'agence.** Le seul qui touche du code
vivant est **W1** (la dernière ligne de repli) — c'est le chemin par lequel `ArchiveObject` archive une société
d'une autre agence (V-117). X1 et X4 visent une branche devenue inatteignable (V-123).

Protocole inchangé : `git status` vide → base `ava_audit6` refaite → UN sabotage → `make.sh test` complet →
`git checkout` → `git status` vide. Port 3600. Journal : `preuves/banc/_JOURNAL.txt` (69 lignes).

| Sabotage | Tombées | Verdict |
|---|---|---|
| **S1** toute commande rend INTROUVABLE | 280 | ✅ |
| **S2a / S2b** `emit()` n'écrit plus | 235 | ✅ |
| **S3a / S3b** écrit puis lève · `ROLLBACK` → `COMMIT` | 238 | ✅ / ⚠️ tombée par le 500 |
| **S4a→f** droit retiré ×4 · règle « soi-même » · porte O-2 | P-027 P-127 P-189 P-204 · 23 · P-042 … · P-127 … · P-208 · P-126 | ✅ |
| **S5a→f · S5bis** une politique en dur ×6 · lue puis ignorée | P-134 P-144 · P-006 P-130 P-240 · P-131 · P-132 · P-133 · P-209 · P-240 | ✅ |
| **S6 ×7 · S7 ×2 · S12 · S13 · S14 · N8 · N9 · N10** murs SQL | P-001 ×15 | ✅ |
| **S8 · S9 · S10** écrans besoin (7 passes) | 0 | ⚠️ portes ⏳ lot 3 |
| **N1 · N2** thème servi par le serveur | P-004 P-005 | ✅ |
| **N6 · N7** trace des refus muette · `REVOKE INSERT` | P-254 P-257 | ✅ |
| **U1** garde d'entrée ouvert hors banc | P-066 P-271 P-274 | ✅ |
| **U2** vue sans filtre d'agence | P-266 P-271 | ✅ |
| **U3** une commande sort de la table d'agence | 19 portes | ✅ |
| **U4 / W2** agence demandée ≠ agence lue, confrontation retirée | P-291 | ✅ |
| **U5** la lecture de l'agence de l'objet rend « rien » | **236 portes** | ✅ |
| **U6 / W3** `ON_ERROR_STOP` retiré du fichier d'assertions | P-299 | ✅ |
| **U7 / W4** `verif_serveur.sh` muet | P-300 | ✅ |
| **W5** identité par défaut dans les vues | P-292 | ✅ |
| **T4 · T5** périmètre `soi` ignoré · `soi` = `global` | P-129 P-208 · 54 portes | ✅ |
| **X2** `societe.perimetre.mode` écrit en dur (`partagee`) | **P-303 P-304 P-305** | ✅ V-108 : la politique est gardée |
| **X3** l'agence responsable d'une société n'est plus lue | **P-303 P-304 P-305** | ✅ |
| **X5** le contact n'est plus jugé | **P-303** | ✅ |
| **W1** la dernière ligne de repli (`else exigeDroit(…, ctx.compte.agence_id)`) remplacée par `return` | **0** | ⛔ **rien ne la voit** (V-117, V-118) |
| **X1** la branche « agence nulle → périmètre global » rend sans rien vérifier | 0 | ⚠️ branche **inatteignable** : toutes les colonnes d'agence sont NOT NULL (V-123) |
| **X4** `exigeGlobal` accepte tout le monde | 0 | ⚠️ idem |
| **T6** comptes de banc réactivés en base | 0 | ⚠️ sans effet : la fixture les réactive |

## Le cliquet, rejoué en vrai — 13 cases (`preuves/banc/C_*.txt`)

| Témoin | Résultat | Verdict |
|---|---|---|
| rien de saboté | **cases OK=12 KO=1** : seule la case 12 (crochet non posé dans un clone neuf — la CI le pose) ; **case 13 (F13) OK** « origin/lot-2-brain » ; case 7 OK | ✅ V-112 fermé |
| serveur mort | case 1 KO, « exécutées=2 ✅=307 » | ✅ |
| 99 portes effacées, sans commit | case 1 (208 ✅) et case 11 KO | ✅ |
| les mêmes effacées **dans un commit** | case 11 KO | ✅ |

## Le compte

| | 1er | 2e | 3e | 4e | 5e | 6e (`a26291c`) |
|---|---|---|---|---|---|---|
| Sabotages | 37 | 47 | 50 | 57 | 62 | **69** |
| Portes servies | 64 | 151 | 264 | 280 | 294 | **307** |
| Portes aveugles | 48 | 45 | 0 | 1 | 1 | **1 chemin** (W1) |
| Banc sur base neuve | vert | vert | vert | ⛔ rouge | vert | **vert** |
| Cliquet dans un clone neuf | — | — | 11/12 | 10/12 | 11/12 | **12/13** |
