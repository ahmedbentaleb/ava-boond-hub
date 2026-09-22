# Décisions techniques tranchées seul

| # | Décision | Motif |
|---|---|---|
| D-001 | Postgres exposé sur le port hôte **55432** (55432→5432). | Éviter le conflit avec un Postgres local déjà sur 5432. |
| D-002 | Recettes dans `outils/make.sh` ; `Makefile` et `make.cmd` délèguent. | Windows n'a pas GNU make ; la CI Linux si. |
| D-003 | `tsx` pour lancer le serveur TypeScript, pas un `tsc` de prod. | Tuyau E6, zéro métier, un process. |
| D-004 | Page unique servie par Fastify depuis `web/dist` (pas Vite en dev pour `make test`). | « /web affiche une page servie par /server ». |
| D-005 | Hook Cursor `stop` + `pre-push` appellent le même `outils/cliquet.sh`. | E7. |
| D-006 | Migration 004 : `positionnement.personne_id` nullable. | L7 exige `ck_m2_xor` ; 001 ne se réécrit pas. |
| D-007 | `schema_migrations` dans le schéma `ava`, pas `public`. | L7 M-8 + `has_table_privilege` sur `ava.\|\|tablename` lève si le nom n'existe pas dans `ava`. |
| D-008 | `make.sh` attend le serveur avec `node.exe` Windows, pas `curl` WSL. | WSL `127.0.0.1` n'est pas l'hôte Docker/Node. |
| D-009 | Cliquet case 7 : contenu `_ops/` vs `HEAD` (`autocrlf=true`), pas `origin/main`. | Q-001 : origin/main en retard, commits Boond sur `lot-1`, faux diff CRLF sous Git Bash. |
| D-010 | Greffe écrit sur `lot-2` (ouverte depuis `aa04aa6`). | Q-005 : FAIT. |
| D-011 | Noms d'événements = L4, pas MACHINES, tant que Q-008 n'est pas tranché. | Prompt lot 2 : L4 fait foi. |
| D-012 | `/journal/CONTRAT.md` : 55 **écarts**, 0 conforme. | Aucun `/server/contrat/*.json`, aucun handler des 55. |
| D-013 | Cases 7–8 : ne pas les juger verts tant que le banc n'a pas posé la mesure **depuis le fork lot 2**. | `origin/main..HEAD` est déjà rouge (28 SHA `_ops/`, 2 commits mixtes lot 1). |
| D-014 | Objet écran « le besoin » (prompt écran) — greffe ne le change pas. | Hors périmètre. |
| D-015 | Ne pas amender `2df9bd6` (mélange `_ops`/audit/journal/make.sh). | Q-009. Amend = force. |
| D-016 | `ListerBesoins` / `LireBesoin` = lectures d'écran, pas des commandes L4. | Q-011 · matrice BM-45. |
| D-017 | Rebase `lot-2` sur `main` (`d684c1a`) : WIP unique rejoué, commits Hamada déjà sur `main` non rejoués. | Case 7 : `_ops/` identique à `main`. |
| D-018 | Parade ⏳ avant toute commande : `PORTES.md` colonnes État/Lot cible ; cliquet 10 cases. | `_ops/PORTES_EN_ATTENTE.md`. |
| D-019 | C2 (`ava_serveur`) reporté : fusion `lot-2-brain` sur le mot d'Ahmed. Pas de migration 007 écrite ici. | Prompt correctifs §5. |
| D-020 | P-061–P-065 repassent ⏳ lot 3 (E6) : le bouchon n'est plus servi ; les captures besoin ne touchaient pas le serveur. | Prompt E6 gagne sur « une ✅ ne redevient jamais ⏳ » jusqu'au cliquet BRAIN. |
| D-021 | C2 livré : connexion `ava_serveur`, démarrage refusé si `current_user` est superutilisateur. Migration 007 vient de `lot-2-brain`, non réécrite. | P-136 · `7f09c29`. |
