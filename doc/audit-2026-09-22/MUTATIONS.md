# Mutations — les tests des tests (famille G), second audit

⭐ **Premier audit 48 portes aveugles → second 45.** Les 37 sabotages du premier audit sont rejoués à
l'identique, plus 10 neufs (47 passes ; N4 incomplet remplacé par N4b, N5 non joué). Mais **40 des 45** sont les mêmes portes « refuse INTROUVABLE » qu'au
premier tour : elles restent aveugles, simplement doublées par les portes de succès P-071 → P-125.
Et le cliquet reste **10/10** quand on retire 4 portes ✅ propres à `lot-2` (V-050).

Protocole, à chaque ligne : `git status` vide → base `ava_audit2` refaite (`make.sh reset`) → UN sabotage →
`outils/make.sh test` complet (les **151 portes ✅** : assertions, 7 fichiers de contrat, Playwright) →
`git checkout` → `git status` vide. Port 3200. Script : `rapport/preuves/scripts/sab.sh` + `sab.py` (ancres
du premier audit ; les deux adaptations au code bougé sont commentées dans `sab.py`). Sorties :
`rapport/preuves/banc/<clé>.txt` (+ `.diff.txt` = le sabotage exact). Journal : `banc/_JOURNAL.txt`.

⚠️ `make.sh` est lancé ici, contrairement au premier audit : il prend désormais `AVA_DB`/`AVA_PORT`
(`outils/make.sh:20`). Il a fallu **exporter `DATABASE_URL` à la main**, sinon les portes relisent la
base `ava` du CODE (V-051). ⚠️ Quand les assertions tombent, `make.sh` s'arrête : les autres portes ne
tournent pas — seul P-001 est jugé sur ces lignes.

Référence S0 (rien de saboté) : 29 assertions OK, 150 portes vertes + P-001 = **151/151**, make_rc=0.

| # | Sabotage | Portes lancées | Tombées | RESTÉES VERTES (concernées) | Verdict |
|---|---|---|---|---|---|
| 1 | **S1** toute commande rend INTROUVABLE avant tout droit | 151 | 94 | **40** : P-007 008 010 011 013 014 015 018→026 029→041 043→048 050→054 | ⛔ 40 aveugles — **inchangé** (1er : 40) |
| 2 | **S2a** `emit()` n'écrit plus (base fraîche) | 151 | 70 | **1** : P-153 (« n'émet que si une ligne change » : 0 = 0) | ⛔ 1 aveugle |
| 3 | **S2b** même sabotage, base où le banc a déjà tourné | 151 | 70 | P-153 | ✅ réparé (1er : 3 aveugles) · ⛔ P-153 idem |
| 4 | **S3a** `CreateCompany` écrit puis lève | 151 | 72 | 0 | ✅ rollback réel |
| 5 | **S3b** idem + `ROLLBACK` → `COMMIT` | 151 | 72 | 0 | ⚠️ tombées par le 500, pas par l'écriture persistée — comme au 1er audit |
| 6 | **S4a** droit retiré : `UpdateResourceCost` | 151 | P-027 P-127 | 0 | ✅ |
| 7 | **S4b** droit retiré : `SetPolicy` | 151 | 11 (P-057 …) | 0 | ✅ |
| 8 | **S4c** droit retiré : `RecordClientDecision` | 151 | P-042 P-127 | 0 | ✅ |
| 9 | **S4d** droit retiré : `DeclareNeedFilled` | 151 | P-127 | P-034 | ✅ vu (1er : aveugle) — P-034 reste aveugle (déjà dans S1) |
| 10 | **S4e** règle S retirée : `RecordTimesheet` | 151 | **0** | P-052 | ⛔ aveugle — **inchangé** |
| 11 | **S4f** porte de derrière O-2 : `CreatePrestation` signée sans `SignPrestation` | 151 | P-126 | P-048 | ✅ vu (1er : aveugle) |
| 12 | **S5a** `candidat.note.echelle` en dur (5) dans le trigger | 151 | P-134 P-144 | 0 | ✅ vu (1er : trou) |
| 13 | **S5b** `doublon.societe.mode` → `avertir` en dur | 151 | P-006 P-130 | 0 | ✅ |
| 14 | **S5c** `ui.theme.choix_utilisateur` → `oui` en dur | 151 | P-060 P-131 | 0 | ✅ |
| 15 | **S5d** `besoin.contact` → `facultatif` en dur | 151 | P-132 | P-030 | ✅ vu (1er : aveugle) |
| 16 | **S5e** `temps.plafond_jour` → `alerte` en dur | 151 | **0** | **P-133** (la porte de CETTE politique) + P-052 | ⛔ aveugle — P-133 ne joue jamais `RecordTimesheet` (V-052) |
| 17 | **S5f** `positionnement.unicite` → `actifs` en dur | 151 | **0** | P-039 | ⛔ aveugle — **inchangé** |
| 18 | **S5bis** politique lue puis ignorée (`doublon.societe.mode`, `ui.theme…`) | 151 | P-130 P-131 | **P-006 P-060** | ✅ vu · ⛔ P-006 P-060 restent aveugles |
| 19-23 | **S6a→e** `DISABLE TRIGGER` tg_m10, tg_m7, tg_m4_m14, tg_m12 (besoin), tg_m6 | P-001 | P-001 ×5 | 0 | ✅ |
| 24-25 | **S7a/b** `GRANT DELETE` personne, tentative_refusee | P-001 | P-001 ×2 | 0 | ✅ |
| 26-27 | **S8a/b** libellé `/web` (liste besoins, bouchon) | 151 | 0 | aucune porte **servie** ne les vise : P-061→P-065 sont ⏳ lot 3 et `besoin.spec.ts` est ignoré (`test/playwright.config.ts:6`) | ⚠️ trou de couverture, pas une porte aveugle |
| 28-31 | **S9a→d** couleurs du bouchon et du CSS des écrans besoin | 151 | 0 | idem (⏳) | ⚠️ trou de couverture |
| 32 | **S10** le front calcule le compte des besoins | 151 | 0 | idem (⏳) | ⚠️ trou de couverture |
| 33 | **S11** 4 portes servies sur `main` retirées de `PORTES.md` (P-002→005), cliquet réel | cliquet | case 3 KO « disparues » | — | ✅ témoin du BRAIN confirmé (`banc/C_portes_main.txt`) |
| 34 | **S11b** serveur mort (`process.exit` au démarrage), cliquet réel | cliquet | case 1 KO « exécutées=1, non_jouées » | — | ✅ témoin du BRAIN confirmé (`banc/C_serveur_mort.txt`) |
| 35 | **S12** `GRANT UPDATE ON evenement_metier` | P-001 | P-001 | 0 | ✅ (1er : aveugle) |
| 36 | **S13** `GRANT SELECT` prestation_version, v_conditions_du_jour aux agrégats | P-001 | P-001 | 0 | ✅ (1er : aveugle, et état réel) |
| 37 | **S14** `GRANT UPDATE ON prestation_version` | P-001 | P-001 | 0 | ✅ (1er : aveugle) |
| N1 | couleur `structure` du thème serveur, clair ET sombre | 151 | P-002 P-004 P-005 | 0 | ✅ |
| N2 | fond du thème serveur, clair ET sombre | 151 | P-002 P-004 P-005 | 0 | ✅ |
| N3 | la session accepte un compte **désactivé** (`AND c.actif` retiré) | 151 | **0** | aucune porte ne vise la session | ⛔ trou (V-049) |
| N4b | `x-ava-groupe` accepté hors banc | 151 | P-066 | 0 | ✅ |
| N6 | la trace des refus n'écrit plus rien | 151 | **0** | **P-146** (« le détail reste au journal » : ne relit que le source) | ⛔ aveugle |
| N7 | `REVOKE INSERT ON tentative_refusee` (régression V-027) | 151 | **0** | P-146 | ⛔ aveugle |
| N8 | `GRANT SELECT ON personne TO ava_lecture_agregats` (M-15) | P-001 | P-001 | 0 | ✅ |
| N9 | `GRANT TRUNCATE ON evenement_metier` (M-7) | P-001 | P-001 | 0 | ✅ |
| N10 | `GRANT DELETE ON snapshot_marge` (M-6) | P-001 | P-001 | 0 | ✅ |
| N11 | 4 portes ✅ **propres à lot-2** retirées de `PORTES.md` (P-150→153), cliquet réel | cliquet | **0** — `cases OK=10`, `exécutées=151 ✅=147` | — | ⛔ **cliquet aveugle** (V-050, `banc/C_portes_lot2.txt`) |

Témoin : le cliquet non saboté rend 10/10, exécutées=151 ✅=151 (`banc/C_temoin.txt`).

⚠️ Non joué : **N5** (retirer le refus du superutilisateur). P-136 démarre alors un serveur sur la base
`ava` du CODE, en dur (`test/contrat/correctifs.test.ts:137`) : `assurerBancRes` y **écrirait**. Refus
superutilisateur vérifié à la main (`preuves/controles_neufs.txt`, C-N1).

## Le compte

| | 1er audit (`3b59ca5`) | 2nd audit (`7e3f78c`) |
|---|---|---|
| Sabotages | 37 | 37 rejoués + 10 neufs = 47 |
| Portes servies | 64 | **151** |
| **Portes aveugles** (restées vertes sous un sabotage qui les vise) | **48** | **45** : les 40 de S1 · P-153 (S2) · P-133 (S5e) · P-006 P-060 (S5bis) · P-146 (N6, N7) |
| Sabotages que **rien** ne voit | 19 (dont S9 ×4, S10, S11, S11b) | **6** : S4e (règle S), S5e (plafond), S5f (unicité), N3 (compte désactivé), N6/N7 (trace des refus) — et le cliquet sur N11 |
| Cliquet | aveugle sur S11 et S11b | ✅ S11 et S11b · ⛔ N11 |

## Ce que ça dit

⭐ Les murs en base sont tenus : **13 sabotages SQL sur 13 font tomber P-001**, contre 7 sur 10 au premier tour.
⭐ Neuf sabotages aveugles au 1er tour sont désormais vus : S2b, S4d, S4f, S5a, S5d, S5bis, S12, S13, S14 ; et le cliquet voit S11 et S11b.
⛔ Ce qui reste aveugle, c'est **l'accès** (session, compte désactivé, périmètre), la **règle S**, deux
politiques et la **trace des refus**. Les 40 portes « refuse INTROUVABLE » ne prouvent toujours que
« l'UUID nul n'existe pas ».
