**REFUSÉ — mais le banc, lui, est réparé** : lot 2, commit `416a7a3`, troisième audit du 23/09/2026, clone isolé `ava-audit-3`, base `ava_audit3`, port 3300.
Sur 50 sabotages, plus une seule porte ne reste verte — et ce sont deux trous d'**accès en lecture**, que la mutation ne pouvait pas voir, qui refusent le lot.

| Mesure | 1er (`3b59ca5`) | 2e (`7e3f78c`) | 3e (`416a7a3`) |
|---|---|---|---|
| Portes aveugles | 48 | 45 | **0** (50 sabotages, 264 portes) |
| Constats des tours précédents | — | 27 neufs | **37 fermés · 6 partiels · 1 ouvert · 8 bonnes tiennent** |
| Critiques ouverts | 12 | 7 | **2, tous les deux neufs** |
| Grille · conformité | 25 ✅ · 5 🔴 | 30 ✅ · 1 🔴 | **42 contrôles : 34 ✅ · 6 🟠 · 1 🟡 · 1 🔴 (K4)** · 55/55 commandes, 0 fantôme |
| Décisions du BRAIN D-10 → D-13 | — | — | **tenues et mesurées** (401 sur 7/7 commandes hors banc, comptes de banc désactivés, périmètre `soi` en donnée, crochet posé par script) |

1. **V-075 (critique)** — hors banc, `GET /vues/besoins` rend **81 besoins** (titre, société, état) sans en-tête ni authentification : D-10 n'a fermé que `POST /commandes/:nom`.
2. **V-076 (critique)** — `crm.ts` est le seul fichier de commandes sans `exigeObjet` : un compte de Paris **crée, renomme et archive** une unité d'une autre agence. Les 5 trous du 2e audit sont fermés, 3 neufs restent.
3. **V-077 (elevee)** — 70 portes ✅ effacées **dans un commit** → cliquet 11/12, case 11 verte : la fenêtre s'arrête à `HEAD~1`. Sans commit, elle tombe bien.

❓ Angles morts : CI GitHub non exécutée (lue seulement : elle lance `installer.sh` puis le cliquet) ; case 12 KO dans un clone neuf, normal ; écrans besoin ⏳ lot 3, donc 7 sabotages d'écran ne visent aucune porte servie ;
VPS, `.zip`, `.docx` et `Fonds ERP` non ouverts ; le cliquet « portes effacées en commit » a été joué sur des commits jetables dans le clone, remis par `git reset --hard`.
