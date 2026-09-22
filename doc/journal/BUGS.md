# Bugs — un bug par ligne, numéro jamais réutilisé. Fermé avec un SHA, jamais avec « corrigé ».

| # | Ouvert | Fermé (SHA) | Gravité | Fait |
|---|---|---|---|---|
| B-001 | 2026-09-19 | `3cd95e8` | cliquet | CRLF sur `.sh` : `pipefail` cassé. `.gitattributes` force LF. |
| B-002 | 2026-09-19 | `3cd95e8` | M-2 | `personne_id NOT NULL` lève avant `ck_m2_xor`. Migration 004. |
| B-003 | 2026-09-19 | `3cd95e8` | M-8 | `has_table_privilege('ava.'\|\|tablename)` évalué hors filtre. OFFSET 0 dans `/test`. |
| B-004 | 2026-09-19 | `3cd95e8` | banc | stdout du serveur tenait le `tee` du cliquet. Log redirigé vers `/tmp/ava-server.log`. |
| B-005 | 2026-09-20 | `d028582` | cliquet | Prompt lot 2 : 8 cases ; `outils/cliquet.sh` en a 7. Case 7/8 vs `origin/main` déjà KO. Q-006. Parade ⏳ : 10 cases. |
| B-006 | 2026-09-20 | `d684c1a` rebase | cliquet | Premier commit `lot-2` `2df9bd6` touche `_ops/`. Rebase sur `main` : case 7 verte. |
