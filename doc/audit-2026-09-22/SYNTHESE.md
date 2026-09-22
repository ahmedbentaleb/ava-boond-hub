**REFUSÉ** — lot 2, commit `7e3f78c` (branche `lot-2`), second audit du 22/09/2026, clone isolé `ava-audit-2`, base `ava_audit2`, port 3200.
Les murs en base et les correctifs tiennent, mais l'accès n'est pas gardé : hors banc, n'importe qui écrit en ADM, et aucune porte ne le voit.

| Mesure | 1er audit (`3b59ca5`) | 2nd audit (`7e3f78c`) |
|---|---|---|
| Portes aveugles (mutation) | **48** | **45** (40 sont les mêmes « refuse INTROUVABLE ») · 37 sabotages rejoués + 10 neufs |
| V- du 1er audit | 12 critiques ouverts | 22 fermés · 15 partiels · 2 ouverts (V-003, V-022) · 7 bonnes tiennent ; critiques non fermés : V-003, V-004, V-006, V-011 |
| Constats neufs (V-048 → V-074) | — | 3 critique · 10 elevee · 13 moyenne · 1 bonne |
| Grille · conformité | 25 ✅ · 5 🔴 | 30 ✅ · 5 🟠 · 1 🔴 (F6) · 55/55 commandes servies, 42 conformes |
| Arbitrage du BRAIN | — | 23 éléments : 15 acceptés, 8 contestés (dont D-2, critique) |

1. **V-048** : hors banc, la « session » est l'UUID du compte ; `x-ava-session: …0108` écrit en base comme ADM (HTTP 200). D-2 ne ferme pas V-003, il la déplace.
2. **V-049** : aucune porte sur la session, le compte désactivé ni le périmètre ; 5 commandes écrivent sur une autre agence (V-004 partiel).
3. **V-050** : 4 portes ✅ de `lot-2` effacées de `PORTES.md` → cliquet 10/10. Les deux témoins du BRAIN (serveur mort, portes de `main`) sont vrais.

❓ Angles morts : CI GitHub non exécutée (V-039 : elle ne peut pas passer, établi en lisant) ; N5 non joué (P-136 écrirait dans la base `ava`) ; VPS non vu ; `.zip`, `.docx`, `Fonds ERP` non ouverts ;
rôles globaux au cluster : trois auditeurs ont rejoué 007 (`ALTER ROLE ava_serveur`) en parallèle ; ce rapport a été rédigé par une session qui avait lu l'arbitrage et les prompts d'audit avant de cloner (exigé pour §2.3).
