# Mutations — les tests des tests (famille G), septième audit

⭐ Base refaite puis `make.sh test` : **318 portes vertes, 41 assertions, make_rc=0** (`preuves/banc/S0_reference.txt`).
⛔ **1 vrai chemin aveugle** : **Y6** — `TransferContact` ne juge plus qu'une des deux agences, et aucune porte ne tombe (V-130).
Deux autres sabotages ne font rien tomber, mais visent une double garde ou du code devenu inatteignable (Y1, Y2).

Protocole inchangé : `git status` vide → base `ava_audit7` refaite → UN sabotage → `make.sh test` complet →
`git checkout` → `git status` vide. Port 3700. Journal : `preuves/banc/_JOURNAL.txt` (70 passes).

| Sabotage | Tombées | Verdict |
|---|---|---|
| **S1 · S2a · S2b · S3a · S3b** commandes, événements, transaction | 250+ chacune | ✅ (S3b tombé par le 500) |
| **S4a→f** droits ×4, règle « soi-même », porte O-2 | P-027 … · P-057 … · P-042 … · P-127 … · P-208 · P-126 | ✅ |
| **S5a→f · S5bis** politiques en dur · lue puis ignorée | P-134 · P-130 P-240 · P-131 · P-132 · P-133 · P-209 · P-240 | ✅ |
| **S6 ×7 · S7 ×2 · S12→S14 · N8→N10** murs SQL | P-001 ×15 | ✅ |
| **S8 · S9 · S10** écrans besoin (7 passes) | 0 | ⚠️ portes ⏳ lot 3 |
| **N1 · N2 · N6 · N7** thème serveur, trace des refus | P-004 P-005 · P-254 P-257 | ✅ |
| **U1 · U2 · U3 · U4 · U5 · U6 · U7** garde d'entrée, vue, table d'agence, entrée, lecture, `ON_ERROR_STOP`, `verif_serveur.sh` | 3 · 2 · 20 · 1 · **246** · 1 · 1 | ✅ |
| **W2 · W3 · W4 · W5** | P-291 · P-299 · P-300 · P-292 | ✅ |
| **T4 · T5** périmètre `soi` | P-129 P-208 · 61 | ✅ |
| **X2 · X3 · X5** mode société en dur · agence responsable muette · contact libre | 3 · 15 · 7 | ✅ V-108 gardé |
| **Y3** `ArchiveObject` sur une action : contrôle retiré | P-319 | ✅ V-117 gardé |
| **Y4** `ArchiveObject` sur une personne : contrôle retiré | P-318 | ✅ |
| **Y5** `ArchiveObject` accepte un type qui a sa commande dédiée | 4 portes | ✅ |
| **Y1** un objet introuvable devient une permission | 0 | ⚠️ double garde : la commande le refuse ensuite elle-même |
| **Y2** une agence nulle devient une permission | 0 | ⚠️ inatteignable : toutes les colonnes d'agence sont NOT NULL |
| **Y6** `TransferContact` ne juge plus qu'une agence sur deux | **0** | ⛔ **aveugle** (V-130) |
| **T6** comptes de banc réactivés | 0 | ⚠️ sans effet : la fixture les réactive |

## Le cliquet, rejoué en vrai — 13 cases (`preuves/banc/C_*.txt`)

| Témoin | Résultat | Verdict |
|---|---|---|
| rien de saboté | **cases OK=12 KO=1** — seule la case 12 (crochet non posé dans un clone neuf, la CI le pose) ; case 13 (F13) OK | ✅ |
| serveur mort | case 1 KO « exécutées=2 ✅=318 » | ✅ |
| 99 portes effacées, sans commit | case 1 (219 ✅) et case 11 KO | ✅ |
| les mêmes **dans un commit** | case 11 KO | ✅ |

## Le compte

| | 1er | 3e | 5e | 6e | 7e (`ba9a284`) |
|---|---|---|---|---|---|
| Sabotages | 37 | 50 | 62 | 69 | **70** |
| Portes servies | 64 | 264 | 294 | 307 | **318** |
| Chemins aveugles | 48 portes | 0 | 1 | 1 | **1** (Y6) |
| Cliquet, clone neuf | — | 11/12 | 11/12 | 12/13 | **12/13** |
