**REFUSÉ** — lot 2, commit `3b59ca5` (branche `lot-2`), audité le 21/09/2026 sur un clone isolé, base `ava_audit`, port 3100.
Les portes sont vertes, mais elles ne prouvent presque rien : des murs, des droits et deux commandes sont cassés sans qu'aucune ne tombe.

| Constats | 12 critique · 11 elevee · 17 moyenne · 7 bonne (47, V-001 → V-047) · grille : 25 ✅ · 6 🟠 · 5 🔴 (C2 C3 C4 F3 F6) |
|---|---|
| Mutation | ⭐ **sur 37 sabotages, 48 portes aveugles** (48 des 64 portes servies restées vertes sous un sabotage qui les visait) ; le cliquet reste 10/10 quand aucune porte n'a tourné |
| Conformité | 55/55 commandes servies ; 34 conformes hors écarts communs ; périmètre jamais vérifié sur l'objet (les 55) |

1. **V-001** M-15 percé : `ava_lecture_agregats` lit les TJM/CJM (34 170 lignes) et 21 000 personnes ; la copie `test/` de l'assertion, périmée, reste verte — la version `_ops/` lève.
2. **V-002 · V-003 · V-004** le serveur tourne en superutilisateur `postgres` (les murs GRANT ne s'appliquent pas), le groupe vient d'un en-tête sans authentification, et IA de Paris écrit dans une autre agence.
3. **V-005 · V-006 · V-007** `RecordTimesheet` refuse toute saisie, `SetPolicy` ne réussit jamais (HTTP 500), et un `emit()` supprimé laisse 55/55 portes vertes — leurs portes ne testent qu'un refus.

❓ Angles morts : exécutions de la CI GitHub non vues ; `make.sh`/`cliquet.sh` non lancés (base `ava`), rejoués à la main ; P-002 non lancée (vise 3000 en dur) ;
fiches `audit/`, `REMARQUES`, journaux de bugs non lus (mur d'indépendance) ; configuration git du dépôt original non lue (F7) ; `.docx`, `.zip` et `Fonds ERP` non inspectés.
