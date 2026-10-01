# Mutations — les tests des tests (famille G), dixième audit

⭐ Base refaite puis `make.sh test` : **référence verte, 41 assertions, make_rc=0** (`preuves/banc/S0_reference.txt`).
⭐ **59 sabotages joués, 55 font tomber au moins une porte.** Les 4 autres ont été rejoués à la main sur le serveur
saboté, contre le code intact : **0 fuite**, 3 mutants équivalents (code mort) et 1 code de refus non gardé (V-175).
⭐ **Les 5 sabotages des règles de construction de ce tour (Q1 → Q5) sont tous vus.**

Méthode : arbre propre, base refaite, UN sabotage, `make.sh test` complet, `git checkout`, arbre propre. Pour tenir le
temps, deux files en parallèle sur deux clones et deux bases : **A** (`ava-audit-10`, `ava_audit10`, port 4000) et
**B** (`ava-audit-10b`, `ava_audit10x`, port 4010). Journaux : `preuves/banc/_JOURNAL.txt` (A) et
`../ava-audit-10b/rapport/preuves/banc/_JOURNAL.txt` (B).

⚠️ Comptage : la colonne « vertes » du journal est faussée par le format TAP ; la colonne « tombées » est exacte.
⚠️ Résultats nuls écartés (`preuves/banc/_nuls/`) : le `sab.sh` copié dans B visait encore `-d ava_audit10` en dur ; deux
sabotages SQL de B ont frappé la base de A. Corrigé (`-d "$AVA_DB"`), les deux files relancées de zéro.

| Sabotage | Tombées | Verdict |
|---|---|---|
| **S1 · S2a · S2b · S3a** serveur, saisie, banc | 250+ chacun | ✅ |
| **S4** droits retirés : `UpdateResourceCost`, `SetPolicy`, `RecordClientDecision`, `DeclareNeedFilled`, `CreatePrestation` (signature) | 1 à 250+ chacun | ✅ |
| **S4** la règle « soi » retirée de `RecordTimesheet` | **0** | ⚠️ mutant équivalent : la garde d'agence refuse avant (V-175) |
| **S5a · S5 ×5 · S5bis** politiques en dur | 1 à 4 chacun | ✅ |
| **S6 ×7 · S7 ×2 · S12 → S14 · N8 → N10 · R10** murs SQL | assertions KO (le geste passe) | ✅ |
| **N7** REVOKE sur `tentative_refusee` | P-254 P-257 P-325 | ✅ |
| **N1 · N2 · N6** thème, fond, trace des refus | 2 chacun | ✅ |
| **U1 · U2 · U5 · U6 · U7 · W3 · W4 · W5 · X2 · Y5 · Z1** correctifs des tours 3 à 8 | 1 à 250+ chacun | ✅ |
| **T4** `soi` ne garde plus rien (`exigeSoiMeme` neutralisé) | **0** | ⚠️ mutant équivalent : 15 refus identiques, 0 écriture (`aveugles10/T4_*`) |
| **R3** `soi` vaut « toutes agences » | P-329 P-340 | ✅ |
| **R6** liste de clés ignorée | P-327 | ✅ |
| **R7** `TransferContact` vers une société inexistante | **0** | ⛔ le refus passe d'INTROUVABLE à GARDE, aucune porte ne l'exige (V-155 → V-175) |
| **R8** la garde note l'objet sous sa première clé seulement | **0** | ⚠️ mutant équivalent : `replier` recopie l'alias avant ; la boucle est du code mort |
| **R9** `GRANT INSERT ON agence` | P-325 | ✅ |
| **Q1** la cascade ne passe plus par la garde (V-148) | 250+ | ✅ |
| **Q2** une lecture admise sous n'importe quelle permission (V-150) | P-349 | ✅ |
| **Q3** une seule agence jugée sur plusieurs | P-290 P-339 | ✅ |
| **Q4** `CreateNeed.societe_id` passe de référence à valeur | 15+ | ✅ |
| **Q5** `temps.plafond_jour` lue puis ignorée | P-133 P-350 | ✅ — mais une branche **fausse** reste invisible (V-164) |

Abandonnés parce que leur cible n'existe plus dans le code (la construction l'a retirée) : T1, T2, T3, Z2, Z3, Z6, X1,
X4, W1, R1, R2, R4, R5.

## Le cliquet, rejoué en vrai — 19 cases (`preuves/banc/C_*.txt`)

| Témoin | Résultat | Verdict |
|---|---|---|
| rien de saboté | **18/19** — exécutées=342, ✅=342, 41/41 assertions, P-339 verte (case 14), 341 titres à un numéro ; seule la case 12 (crochet, clone neuf) | ✅ |
| serveur mort | case 1 KO « exécutées=2 », case 14 KO | ✅ |
| 100 portes P-2xx effacées, sans commit | case 11 KO « perdues : P-200 … » | ✅ |
| la même perte, commitée deux commits plus tôt | case 11 KO | ✅ |
| ⚠️ case 17 « aucune délégation d'avant disparue » | OK (sur 136) — mais sur une base neuve, où aucune délégation humaine n'existe : elle ne peut pas voir V-156 | ⚠️ |

⚠️ Un premier témoin, lancé en même temps qu'un autre banc sur le même PostgreSQL, est tombé sur « tuple concurrently
updated » au jeu d'essai (les rôles sont communs à tout le serveur) : écarté (`_nuls/C_temoin_course_parallele.txt`),
rejoué seul. Deux bancs ne peuvent pas tourner en parallèle sur un même PostgreSQL ; les 59 sabotages n'en ont pas
souffert (aucune autre sortie ne porte cette erreur).
