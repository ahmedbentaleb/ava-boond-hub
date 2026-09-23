# Mutations — les tests des tests (famille G), troisième audit

⭐ **48 portes aveugles (1er) → 45 (2e) → 0 (3e).** Les 37 sabotages du premier audit sont rejoués à
l'identique, plus 13 neufs — dont 7 qui visent les correctifs D-10 à D-13. **Aucune porte ✅ ne reste verte
sous un sabotage qui la vise.** Ce qui reste : 2 trous de couverture et **1 fenêtre aveugle du cliquet**.

Protocole, à chaque ligne : `git status` vide → base `ava_audit3` refaite (`make.sh reset`) → UN sabotage →
`outils/make.sh test` complet (**264 portes ✅**) → `git checkout` → `git status` vide. Port 3300.
Scripts : `rapport/preuves/scripts/sab.sh` + `sab.py` + `cliquet3.sh`. Sorties : `rapport/preuves/banc/`
(`<clé>.txt`, `<clé>.diff.txt` = le sabotage exact, `_JOURNAL.txt` = le journal complet).

Référence S0 : 31 assertions OK, 263 portes vertes + P-001 = **264/264**, make_rc=0.

| Sabotage | Tombées | Restées vertes (concernées) | 2e audit → 3e |
|---|---|---|---|
| **S1** toute commande rend INTROUVABLE | **244** | 0 — les 40 portes « refuse INTROUVABLE » sont devenues « réussit, base relue » | ⛔ 40 aveugles → ✅ 0 |
| **S2a / S2b** `emit()` n'écrit plus (base fraîche, puis base déjà jouée) | 207 chacune | 0 (P-153 tombe désormais) | ⛔ 1 → ✅ 0 |
| **S3a** `CreateCompany` écrit puis lève | 205 | 0 | ✅ |
| **S3b** idem + `ROLLBACK` → `COMMIT` | 205 | 0 | ⚠️ tombées par le 500, comme aux deux tours précédents |
| **S4a→d** un droit retiré (UpdateResourceCost, SetPolicy, RecordClientDecision, DeclareNeedFilled) | P-027 P-042 P-057 P-127… | 0 | ✅ |
| **S4e** règle « soi-même » de `RecordTimesheet` | **P-208** | 0 | ⛔ aveugle aux 2 tours → ✅ |
| **S4f** `CreatePrestation` signée sans `SignPrestation` | P-126 | 0 | ✅ |
| **S5a** `candidat.note.echelle` en dur dans le trigger | P-134 P-144 | 0 | ✅ |
| **S5b→d** `doublon.societe.mode`, `ui.theme…`, `besoin.contact` en dur | P-006 P-130 / P-060 P-131 / P-132 | 0 | ✅ |
| **S5e** `temps.plafond_jour` en dur | **P-133** | 0 | ⛔ aveugle (la porte de la politique elle-même) → ✅ |
| **S5f** `positionnement.unicite` en dur | **P-209** | 0 | ⛔ aveugle → ✅ |
| **S5bis** politique lue puis ignorée | P-130 P-131 **P-240** | 0 | ⛔ 2 aveugles → ✅ |
| **S6a→g** `DISABLE TRIGGER` tg_m10, tg_m7, tg_m4_m14, tg_m12 (besoin, **contact**, **projet**), tg_m6 | P-001 ×7 | 0 | ✅ — M-12 contact et projet désormais couverts (V-070) |
| **S7a/b** `GRANT DELETE` personne, tentative_refusee | P-001 ×2 | 0 | ✅ |
| **S8a/b · S9a→d · S10** libellés, couleurs et compte calculé dans les écrans besoin | **0** | aucune porte **servie** : P-061→P-065 sont ⏳ lot 3, `besoin.spec.ts` ignoré | ⚠️ trou de couverture, inchangé |
| **S12 · S13 · S14 · N8 · N9 · N10** GRANT UPDATE/SELECT/TRUNCATE/DELETE sur les murs de rôles | P-001 ×6 | 0 | ✅ |
| **N1 · N2** couleur et fond du thème servi par le serveur | P-002 P-004 P-005 | 0 | ✅ |
| **N6** la trace des refus n'écrit plus rien | **P-066 P-254 P-257** | 0 | ⛔ aveugle (P-146) → ✅ |
| **N7** `REVOKE INSERT ON tentative_refusee` | **P-066 P-254 P-257** | 0 | ⛔ aveugle → ✅ |
| **T1** le serveur n'est plus fermé hors banc (D-10 annulé) | **P-066** | 0 | ✅ neuf |
| **T2** l'en-tête `x-ava-groupe` choisit le groupe hors banc | **P-066** | 0 | ✅ neuf |
| **T3 ×3** périmètre par objet retiré de `WithdrawPositioning`, `UploadDocument`, `CreateAction` | P-170 / P-190 P-193 / P-192 P-194 | 0 | ✅ neuf |
| **T4** le périmètre `soi` ne garde plus rien | P-129 P-208 | 0 | ✅ neuf (D-12) |
| **T5** `soi` traité comme `global` | **48** | 0 | ✅ neuf |
| **T6** les comptes de banc réactivés en base (`UPDATE compte SET actif = true`) | **0** | aucune porte ne relit l'état des comptes livrés par 008 | ⛔ trou neuf (V-085) |

## Le cliquet, rejoué en vrai (12 cases, `preuves/banc/C_*.txt`)

| Témoin | Résultat | Verdict |
|---|---|---|
| rien de saboté | cases OK=11 KO=1 — case 12 « crochets posés » KO dans un clone neuf | ✅ attendu : `outils/installer.sh` n'a pas tourné (la CI le lance, `ci.yml:93`) |
| serveur mort (`process.exit` avant `listen`) | case 1 **KO** « exécutées=1 ✅=264 » | ✅ |
| 70 portes ✅ du lot 2 effacées du tableau, **sans commit** | case 11 **KO** « perdues : P-200 … » | ✅ V-050 fermé sur ce cas |
| les mêmes **effacées dans un commit**, puis un commit de plus | case 11 **OK** ⚠️ « exécutées hors tableau : P-200 … », cliquet 11/12 | ⛔ **fenêtre aveugle** (V-077) |

## Le compte

| | 1er (`3b59ca5`) | 2e (`7e3f78c`) | 3e (`416a7a3`) |
|---|---|---|---|
| Sabotages | 37 | 47 | **50** (37 rejoués + 13 neufs) |
| Portes servies | 64 | 151 | **264** |
| **Portes aveugles** | 48 | 45 | **0** |
| Sabotages que rien ne voit | 19 | 6 | **2** : les écrans besoin ⏳ (7 passes) et T6 (comptes de banc) |
| Cliquet | aveugle ×2 | aveugle ×1 | **1 fenêtre** : une suppression commitée il y a plus d'un commit |

## Ce que ça dit

⭐ Le banc a changé de nature : les portes de commande **relisent la base** au lieu de prouver un refus, et
les politiques, les droits, le périmètre et la règle « soi-même » ont chacune une porte qui tombe.
⛔ Ce que la mutation ne peut pas atteindre reste dehors : les **écrans besoin** (⏳ lot 3) et l'**état livré
de la base** (comptes de banc). Et le cliquet ne voit une porte disparue que si elle l'est dans les deux
derniers commits.
