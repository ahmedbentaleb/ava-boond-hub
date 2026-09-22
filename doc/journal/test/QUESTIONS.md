# Questions du banc — lot 2. Choix pris, on continue.

| # | Question | Choix en attendant | Pourquoi |
|---|---|---|---|
| Q-T-001 | Case 7 exige `git log origin/main..HEAD -- _ops/` vide. `lot-1` porte tout le cadrage ; origin/main est en retard. La case est KO tant que le cadrage n'est pas sur `main`. | Mesurer exactement la commande du prompt (pas le contournement Q-001). | L'auditeur a rejeté `git diff HEAD`. Cacher l'historique re-créerait B-002. |
| Q-T-002 | L4 ne dit pas le chemin HTTP des 55 commandes. | `POST /commandes/:Nom` + `X-Ava-Groupe`. | Si le serveur pose un autre contrat, l'inventaire reste ; les 55 portes restent rouges jusqu'à l'accord intégrateur. |
| Q-T-003 | Groupe « ÉVAL » : code `EVAL` ou `ÉVAL` ? | `EVAL` (ASCII) dans `X-Ava-Groupe`. | En-tête HTTP ; la matrice écrit ÉVAL. |
