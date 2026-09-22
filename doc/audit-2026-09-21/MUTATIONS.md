# Mutations — les tests des tests (famille G)

⭐ **Sur 37 sabotages, 48 portes aveugles** : 48 des 64 portes servies (✅) sont restées vertes au
moins une fois sous un sabotage qui les concernait. Et le cliquet lui-même est resté vert sous 2
sabotages qui le visaient.

Protocole tenu à chaque ligne : `git status` vide → un sabotage → portes concernées relancées →
`git checkout -- .` (et base refaite par `rapport/preuves/scripts/base.sh` si le sabotage touchait la
base) → `git status` vide. Serveur 3100 sur `ava_audit`. Sorties brutes : `rapport/preuves/banc/<tag>.txt`.

⚠️ P-002 n'a pas été lancée par le banc : elle vise `127.0.0.1:3000` en dur (V-025). Elle est remplacée
par un `curl` sur 3100 en tête de chaque sortie. P-061 est ⏳ (lot 3) : elle échoue partout, elle ne
compte ni comme tombée ni comme aveugle.

Base de référence (S0, rien de saboté) : assertions 23 OK ; contrat 55/55 + inventaire ✔ ; Playwright
7 ✔ + P-061 ✘ (⏳) — `rapport/preuves/banc/S0_base.txt`.

| # | Sabotage | Portes lancées | Tombées | RESTÉES VERTES (concernées) | Verdict |
|---|---|---|---|---|---|
| 1 | **S1** toute commande rend INTROUVABLE avant tout droit, sans rien écrire (`s1.py`) | 55 contrat | 15 : P-006 009 012 016 017 027 028 042 049 055 056 057 058 059 060 | **40** : toutes les portes « refuse INTROUVABLE » (P-007 008 010 011 013 014 015 018→026 029→041 043→048 050→054) | ⛔ 40 aveugles (V-010) |
| 2 | **S2a** `emit()` n'écrit plus — base fraîche (`s2.py`) | 55 contrat | 3 : P-006 017 060 | 0 | ✅ |
| 3 | **S2b** même sabotage — base où le banc a déjà tourné une fois (cas réel : `make.sh test` ne remet pas la base à zéro) | 55 contrat | **0** | **3** : P-006 017 060 (55/55 vertes, 2 sociétés sans événement) | ⛔ 3 aveugles (V-007) |
| 4 | **S3a** `CreateCompany` écrit société + événement, puis lève (`s3.py`) | 55 contrat | 1 : P-006 (HTTP 500) | 0 | ✅ rollback réel : 0 société, 0 événement (V-041) |
| 5 | **S3b** idem + `ROLLBACK` remplacé par `COMMIT` (`s3.py commit`) | 55 contrat | 1 : P-006 (à cause du 500, pas de l'écriture) | 0 | ⚠️ tombée par accident : 1 société persistée, aucune porte ne relit la base |
| 6 | **S4a** droit retiré : `UpdateResourceCost` (`s4.py`) | 55 contrat | 1 : P-027 | 0 | ✅ |
| 7 | **S4b** droit retiré : `SetPolicy` | 55 contrat | 1 : P-057 | 0 | ✅ |
| 8 | **S4c** droit retiré : `RecordClientDecision` (IA seul) | 55 contrat | 1 : P-042 | 0 | ✅ |
| 9 | **S4d** droit retiré : `DeclareNeedFilled` | 55 contrat | 0 | **1** : P-034 | ⛔ aveugle (V-011) |
| 10 | **S4e** règle S retirée : `RecordTimesheet` (`exigeSoiMeme`) | 55 contrat | 0 | **1** : P-052 | ⛔ aveugle |
| 11 | **S4f** porte de derrière O-2 : `CreatePrestation` en signée sans `SignPrestation` | 55 contrat | 0 | **1** : P-048 | ⛔ aveugle |
| 12 | **S5a** `candidat.note.echelle` écrite en dur (5) dans le trigger `note_dans_echelle` | P-001 + 55 contrat | 0 | aucune porte ne la couvre (23 OK, 55/55) | ⛔ trou de couverture (V-026) |
| 13 | **S5b** `doublon.societe.mode` → `"avertir"` en dur (`s5.py`) | 55 contrat | 1 : P-006 | 0 | ✅ (la clé disparaît de `liens`) |
| 14 | **S5c** `ui.theme.choix_utilisateur` → `"oui"` en dur | 55 contrat | 1 : P-060 | 0 | ✅ |
| 15 | **S5d** `besoin.contact` → `"facultatif"` en dur | 55 contrat | 0 | **1** : P-030 | ⛔ aveugle |
| 16 | **S5e** `temps.plafond_jour` → `"alerte"` en dur | 55 contrat | 0 | **1** : P-052 | ⛔ aveugle |
| 17 | **S5f** `positionnement.unicite` → `"actifs"` en dur | 55 contrat | 0 | **1** : P-039 | ⛔ aveugle |
| 18 | **S5bis** politique lue puis ignorée : `doublon.societe.mode`, `ui.theme.choix_utilisateur` | 55 contrat | 0 | **2** : P-006 060 | ⛔ aveugles — c'est déjà l'état du code pour 6 clés (V-014) |
| 19 | **S6a** `DISABLE TRIGGER tg_m10` (M-10) | P-001 | P-001 (« le geste est passé ») | 0 | ✅ |
| 20 | **S6b** `DISABLE TRIGGER tg_m7` (M-7) | P-001 | P-001 | 0 | ✅ |
| 21 | **S6c** `DISABLE TRIGGER tg_m4_m14` (M-4/M-14) | P-001 | P-001 | 0 | ✅ |
| 22 | **S6d** `DISABLE TRIGGER tg_m12` sur `besoin` (M-12) | P-001 | P-001 | 0 | ✅ |
| 23 | **S6e** `DISABLE TRIGGER tg_m6` (M-6) | P-001 | P-001 | 0 | ✅ |
| 24 | **S7a** `GRANT DELETE ON personne TO ava_app` (M-8) | P-001 | P-001 | 0 | ✅ |
| 25 | **S7b** `GRANT DELETE ON tentative_refusee TO ava_app` (table de 005) | P-001 | P-001 | 0 | ✅ |
| 26 | **S8a** libellé `/web/src` : « OUVRIR » → « VOIR » (`sw.py`) | 8 Playwright | P-062 063 | 0 | ✅ |
| 27 | **S8b** libellé du bouchon `/web` : « Déclarer pourvu » → « Déclarer comblé » | 8 Playwright | P-064 065 | 0 | ✅ |
| 28 | **S9a** couleur `ok` → `#ff0000`, thèmes clair ET sombre | 8 Playwright | 0 | **4** : P-062 063 064 065 | ⛔ aveugles (V-019) |
| 29 | **S9b** couleur `structure` → `#FF00FF`, clair ET sombre | 8 Playwright | 0 | **4** | ⛔ aveugles |
| 30 | **S9c** titres en rouge dans `web/src/index.css` | 8 Playwright | 0 | **4** | ⛔ aveugles |
| 31 | **S9d** fond de page `#000000→#330000`, `#FFFFFF→#FFDDDD` (témoin : effet visible, `preuves/S9d_besoins_sombre.png`) | 8 Playwright | 0 | **4** | ⛔ aveugles |
| 32 | **S10** le front calcule le compte des besoins (`lignes.length`) au lieu de lire `compte` | 8 Playwright | 0 | **2** : P-062 063 | ⛔ aveugles — même valeur, rien ne peut le voir |
| 33 | **S11** 4 portes ✅ supprimées de `journal/PORTES.md` (P-002→P-005), cases du cliquet rejouées sans `make` | cliquet 3, 9 | 0 | **cases 3 et 9** (« 60 >= 0 ») | ⛔ cliquet aveugle (V-009) |
| 34 | **S11b** le serveur ne démarre pas : aucune porte contrat/geste/écran n'est exécutée | cliquet 1→10 | 0 | **10/10 OK** | ⛔ cliquet aveugle (V-008) |
| 35 | **S12** `GRANT UPDATE ON evenement_metier TO ava_app` (moitié GRANT de M-7) | P-001 | 0 | **1** : P-001 (23 OK) | ⛔ aveugle (V-012) |
| 36 | **S13** `GRANT SELECT ON prestation_version, v_conditions_du_jour TO ava_lecture_agregats` (M-15) | P-001 | 0 | **1** : P-001 — et c'est **l'état actuel** de la base (V-001) | ⛔ aveugle |
| 37 | **S14** `GRANT UPDATE ON prestation_version TO ava_app` (ajout seul) | P-001 | 0 | **1** : P-001 | ⛔ aveugle |

## Le compte

| | |
|---|---|
| Sabotages appliqués | **37** (les 10 exigés, déclinés : S4 ×6, S5 ×7, S6 ×5, S7 ×2, S8 ×2, S9 ×4 ; plus S11, S11b, S12, S13, S14) |
| Portes servies | 64 (P-001 → P-065 sans P-061 ⏳) |
| Portes restées vertes au moins une fois sous un sabotage qui les concerne | **48** : les 40 de S1, P-006 P-017 P-060 (S2b, S5bis), P-062 → P-065 (S9, S10), P-001 (S12 → S14) |
| Paires (porte × sabotage) aveugles | 72 |
| Les 16 autres | 12 ont tenu partout où elles étaient visées : P-009 012 016 027 028 042 049 055 056 057 058 059 (refus DROIT ou GARDE) ; P-002 non lancée (V-025) ; P-003 P-004 P-005 (tuyau du lot 1) non visées — leur thème vient du serveur, pas de `/web` |

## Ce que ça dit

⭐ Les portes contrat prouvent un **code de refus**, jamais un **effet** : aucune ne relit la base, et 40
sur 55 ne prouvent que « l'UUID nul n'existe pas ». ⭐ P-001 tient sur les **triggers** et tombe sur
les **GRANT** — sauf M-8 et M-6, les deux seuls privilèges qu'elle interroge. ⭐ Les portes écran
voient un **mot**, pas une **couleur** : la tolérance (1 % des pixels + seuil par pixel par défaut)
absorbe un fond de page changé.
