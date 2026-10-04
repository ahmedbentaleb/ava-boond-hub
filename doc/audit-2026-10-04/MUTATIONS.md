# Mutations — les tests des tests (famille G), onzième audit

⭐ Base neuve puis `make.sh test` : **348 portes vertes, 41 assertions, make_rc=0** (`preuves/banc/S0_reference.txt`).
⭐ **67 sabotages joués, 62 font tomber au moins une porte.** Les 5 autres : l'horloge de Node (P5, trou neuf) et les
4 mutants équivalents du 10e tour, toujours là (V-193).
⭐ **Les 7 sabotages des corrections de ce tour (P1 → P7) : 6 vus.** Le 7e est P5 (horloge unique).

Méthode : arbre propre, base refaite, UN sabotage, `make.sh test` complet, `git checkout`, arbre propre. Deux files en
parallèle : **A** (`ava-audit-11`, `ava_audit11`, port 4100) et **B** (`ava-audit-11b`, `ava_audit11x`, port 4110).
Journaux : `preuves/banc/_JOURNAL.txt` (A) et `../ava-audit-11b/rapport/preuves/banc/_JOURNAL.txt` (B).

⚠️ Comptage : la colonne « vertes » du journal est faussée par le format TAP ; la colonne « tombées » est exacte.
⚠️ Deux bancs sur un même PostgreSQL se gênent (rôles communs : « tuple concurrently updated ») : `sab.sh` rejoue
désormais un résultat touché ; une seule collision, au `reset` de U2 (B), rejoué seul ensuite. Premier banc écarté :
le clone neuf n'avait pas ses `node_modules` (`_nuls/S0_sans_node_modules.txt`).
⚠️ Ancres adaptées au code du tour (commentées dans `sab.py`) : Q1 (une branche `RecordClientDecision` ajoutée dans
`executerDans`), N6 (`tracerRefus` rend un booléen).

| Sabotage | Tombées | Verdict |
|---|---|---|
| **P1** `politique_admise` rend toujours vrai (SQL) | P-357 P-358 | ✅ |
| **P2** `SetPolicy` n'exige plus une valeur servie | P-357 P-358 | ✅ |
| **P3** `par_besoins` sans l'agence responsable (D-58) | P-339 P-355 | ✅ |
| **P4** le statut commercial choisi par `ordre` (D-57) | P-265 P-359 | ✅ — mais P-359 est ⏳ (V-188) |
| **P5** `ClosePrestation` reprend l'horloge de Node (V-167) | **0** | ⛔ **trou** : la date écrite change, aucune porte ne la regarde (V-193) |
| **P6** l'entrée exige de nouveau le droit dans l'agence du compte (D-59) | P-339 | ✅ |
| **P7** la table des commandes hérite d'`Object.prototype` (V-170) | P-360 | ✅ — mais P-360 est ⏳ (V-188) |
| **P8** `GRANT INSERT ON horloge_banc` (SQL) | P-325 | ✅ |
| **Q1 → Q5** construction du 10e tour | 1 à 250+ chacun | ✅ |
| **R3 · R6 · R9** `soi` global, liste de clés, GRANT hors commande | 1 à 2 chacun | ✅ |
| **R7 · R8 · T4 · S4_RecordTimesheet_S** | **0** | ⚠️ mutants équivalents du 10e tour, code inchangé (V-175 ouvert, V-193) |
| **S1 · S2a · S3a** serveur, événements | 250+ | ✅ |
| **S4** droits retirés ×5 | 1 à 250+ | ✅ |
| **S5a · S5 ×5 · S5bis** politiques en dur | 2 à 6 chacun | ✅ |
| **S6 ×7 · S7 ×2 · S12 → S14 · N8 → N10 · R10** murs SQL | assertions KO (le geste passe) | ✅ |
| **N7 · N1 · N2 · N6** | 2 à 5 chacun | ✅ |
| **U1 · U2 · U5 · U6 · U7 · W3 · W4 · W5 · X2 · Y5 · Z1** correctifs des tours 3 à 8 | 1 à 250+ | ✅ (U2 : voir le journal B) |

## Le cliquet, rejoué en vrai (`preuves/banc/C_*.txt`)

| Témoin | Résultat | Verdict |
|---|---|---|
| rien de saboté | **20/22** — exécutées=349, ✅=346 (+3 ⏳ vertes, V-188), P-339 verte ; KO : case 12 (crochet, clone neuf, attendu) et **case 22 « la branche lot-2-brain est introuvable »** | ⛔ V-189 : la case D-78 ne rend pas de verdict hors du poste du codeur |
| serveur mort | case 1 KO « exécutées=2 », case 14 KO | ✅ |
| 100 portes P-2xx effacées, sans commit | case 11 KO « perdues : P-200 … » | ✅ |
| la même perte, commitée deux commits plus tôt | case 11 KO | ✅ |
| rien de saboté, `C22_JUGE=origin/lot-2-brain` | case 22 OK « 10 fichiers du juge, 0 commit hors de la ligne » | ✅ D-78 tenue |
| un fichier du juge (`outils/registre_executable.mjs`) touché par un commit direct sur la branche | case 22 **KO** « hors origin/lot-2-brain : 0513bf9 » | ✅ — ⚠️ le message ajoute « entrés par fusion », faux pour un commit direct |

Clone propre après chaque témoin (`git status` vide, HEAD remis à `34d98a4`). Le dernier lot a été coupé une fois par la
limite de temps de l'outil : les deux témoins D-78 ont été rejoués seuls.
