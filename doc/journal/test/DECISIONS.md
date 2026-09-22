# Décisions du banc — lot 2. Choix pris en attendant.

| # | Décision | Motif |
|---|---|---|
| D-T-001 | `POST /commandes/:Nom` + en-tête `X-Ava-Groupe`. Corps = entrée L4 en snake_case SQL. | L4 ne fixe pas l'HTTP. Une URL, 55 noms. |
| D-T-002 | Succès : `{ ok, commande, sortie, evenement: { type, liens.politiques }, actions }`. Refus : `{ ok:false, commande, code, message }`. | Un champ qui disparaît fait tomber la porte. `actions` déjà filtrées — l'écran ne filtre pas. |
| D-T-003 | Libellés déjà résolus (`statut.code` + `statut.libelle`). | Interdit d'écran : `if (etat === …)`. |
| D-T-004 | Routes écran besoin : `/besoins` et clic vers la fiche. Thèmes `?mode=clair` / défaut sombre. | Même convention que le tuyau lot 1. Cible mock : liste « Besoins », fiche « Deux développeurs Java seniors ». |
| D-T-005 | Geste figé : Architecte cloud (à pourvoir) → bouton « Prendre en charge » → « en recherche ». | Machine besoin + `TakeNeedInCharge`. Libellés du mock terminal. |
| D-T-006 | `make.sh` tue le PID qui ÉCOUTE `:AVA_PORT` (`taskkill /T /F` Windows, `kill` sinon) avant d'écouter. Log dans `test/test-results/`. Playwright et contrat tournent même si l'autre espèce est rouge. | Hang Fastify / `npx` orphelin sur 3000. Voir toutes les portes rouges, pas la première. |
| D-T-007 | Cliquet case 7 = diff `_ops/` vs `main` (A-013). Case 8 = aucun commit `web/`+`server/`. | Prompt lot 2. `origin/main..HEAD` comptait des SHA. |
| D-T-008 | Parade ⏳ : cases 1/3/9/10. Tests nommés `P-XXX …`. 55 portes B = P-006–P-060 lot 2. P-061–P-065 écran/geste besoin = lot 3. | `_ops/PORTES_EN_ATTENTE.md`. ⏳ n'est pas un skip. |
| D-T-009 | ArchiveCompany/Service/Contact/Object : cas figé `DROIT` (IA). | Matrice = D, 005 ne sème pas les D. INTROUVABLE aurait exigé un droit absent. |
