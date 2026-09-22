# Décisions écran — lot 2. Seul, en attendant.

| # | Décision | Motif |
|---|---|---|
| D-E1 | Le tuyau lot 1 reste sur `/`. Liste `/besoins`, fiche `/besoins/BESOIN-0001`. | Ne pas casser P-003 / P-004 / P-005. |
| D-E2 | Toute vue bouchonnée porte `actions[]` déjà filtrées, `libelle` déjà résolu, `pastille` déjà choisie, couverture déjà écrite (`1 / 2 postes`). | Interdit n° 5 et règle « on ne patche jamais le front ». |
| D-E3 | `DeclareNeedFilled` arrive `permise: false` + `refus.GARDE`. L'écran grise et pose le `title` du serveur. | L4 L54–56 : l'écran affiche le message du serveur, il ne calcule pas la garde. |
| D-E4 | Clic `Suspendre` recharge `SuspendNeed.json` (même forme de fiche, actions `Reprendre` / `Fermer`). | Bout en bout contre le bouchon, sans Fastify métier. |
| D-E5 | Goldens D : 4 captures (liste × 2 thèmes, fiche × 2 thèmes), `maxDiffPixelRatio = 0,01`, win32 et linux. | Espèce D du prompt : une capture par écran et par thème. |
| D-E6 | Vite copie `/web/bouchon` vers `dist/bouchon` au build. Fastify statique les sert. | L'écran n'écrit pas dans `/server`. |
