# Arbitrage du septième audit — 24/09/2026 (nuit)

Audit : commit `ba9a284`, verdict **REFUSÉ** sur **un** défaut critique, d'une famille nouvelle.
10 constats neufs (V-128 → V-137 : 1 critique · 5 élevés · 3 moyens · 1 bon). ⭐ **V-117 fermé et gardé** :
la ligne de repli a disparu, les 55 natures sont cohérentes, `ArchiveObject` refuse les 10 types hors agence.
Banc vert sur base neuve : 318 portes, 41 assertions, 70 sabotages, 1 chemin aveugle (Y6).

<etat>

## ⬜ CE QUI RESTE À FAIRE

| # | Quoi | Constats | Qui | État |
|---|---|---|---|---|
| 1 | ⭐ **D-32 — une seule lecture de l'entrée** : la garde trouve l'objet, la commande le reçoit ; entrée stricte ; toute référence écrite passe par la garde | V-128 V-136 | CODE | ⬜ |
| 2 | **D-33 — `soi` ne vaut jamais `global`** | V-129 | CODE | ⬜ |
| 3 | Le banc : porte des deux agences de `TransferContact` · plus aucune délégation d'autrui effacée | V-130 V-134 | CODE (`Role: banc`) | ⬜ |
| 4 | **D-34 — le GRANT se calcule** : 19 tables fermées, `compte` par colonne, une porte compare les droits au code | V-131 | BRAIN CODE | ⬜ |
| 5 | Migration 015 : deux états en référentiel, les énumérations techniques justifiées au registre ; B5 élargi | V-132 | BRAIN CODE + BRAIN | ⬜ BRAIN ✅ |
| 6 | **D-35 — un ✅ retiré se déclare** ; la case 9 lit toute l'histoire de la branche | V-133 | BRAIN CODE + BRAIN | ⬜ BRAIN ✅ |
| 7 | `JEU_ESSAI.sql` réparé et chargé par `make test` | V-135 | BRAIN CODE | ⬜ |
| 8 | Grille : famille F à 13 | V-136 | BRAIN | ✅ |
| 9 | Huitième audit | — | AUDIT | ⬜ clone `ava-audit-8`, base `ava_audit8`, port 3800 |

</etat>

## ⭐ D-32 — V-128 : LA GARDE ET LA COMMANDE LISENT LA MÊME CHOSE, UNE FOIS

La racine n'est pas `DeclareCVShared` : c'est qu'**un même objet a deux noms dans l'entrée** (`id` et
`positionnement_id`, `agence` et `agence_id`) et que **deux lecteurs** choisissent chacun le sien.
Corriger l'ordre des clés dans sept commandes serait refaire V-076 → V-117 : une porte à la fois.

| Règle | Tranché |
|---|---|
| **1. Un identifiant = un nom** | chaque commande déclare les clés de son entrée ; ⛔ plus d'alias. Une clé inconnue, ou deux clés qui désignent le même objet → `GARDE` « entrée ambiguë », rien d'écrit |
| **2. La garde lit, la commande reçoit** | la garde résout l'objet **une fois** et le passe dans le contexte (`ctx.cible` : table, id, agence) ; la commande **ne relit plus** l'identifiant dans l'entrée |
| **3. Toute référence écrite passe par la garde** | chaque identifiant qu'une commande **écrit** vers un autre objet (`besoin_id` dans `CreateProject`, le `manager` de `CreateCompany`, une `societe_id`…) est déclaré dans la ligne de correspondance ; la garde lit son agence et exige le droit dessus. Une référence non déclarée → `GARDE` |
| **4. Une porte générique, pas sept** | pour chacune des 55 commandes servies : une clé inconnue → `GARDE` ; les deux noms d'un même objet → `GARDE` ; une référence écrite d'une autre agence → `DROIT` — 0 écriture relue en base |
| V-136 (la garde de secours d'un objet introuvable) | disparaît avec la règle 2 : la commande reçoit un objet déjà trouvé, il n'y a plus de seconde recherche à garder |

⭐ Le principe : **ce qui est contrôlé et ce qui est écrit doivent être la même donnée, pas deux lectures
de la même entrée.**

## Les autres constats

| V | Tranché | Qui |
|---|---|---|
| V-129 · **D-33** | `soi` ne couvre **aucune agence** : il ne vaut que pour une commande de nature `soi`, et seulement sur le compte lui-même. `ManageGroups` refuse (`GARDE`) de poser `soi` sur une commande d'une autre nature. Porte : un groupe `soi` sur `UpdateNeed` → `DROIT` hors du compte | CODE |
| V-130 | Porte : transfert vers une société d'une autre agence → `DROIT` ; le sabotage Y6 (ne juger qu'une agence) doit la faire tomber | CODE (`Role: banc`) |
| V-131 · **D-34** | ⭐ **Le GRANT se calcule, il ne se liste pas** : une porte compare `has_table_privilege('ava_app', …)` aux tables nommées dans un `INSERT`/`UPDATE` de `server/src` (plus les `ref_*` et `politique` via leurs commandes d'administration) ; toute table écrivable sans commande fait rougir. Migration 015 : `REVOKE` sur les 19 ; `compte` par colonne (`theme_json` seul) ; plus de GRANT sur les vues | BRAIN CODE |
| V-132 | Les **états** deviennent des référentiels : `ref_etat_envoi_email`, `ref_etat_preparation_paie` (catégories fixes, codes administrables) — registre **74**. Les **énumérations techniques** (`envoi_email.nature`, `lien_outlook.nature`, `document_genere.format`) restent en CHECK, **justifiées au registre §D** : le code s'y branche, un administrateur n'a rien à y ajouter. B5 cherche désormais tout `CHECK (… IN (…))`, pas seulement les colonnes `_code` | BRAIN CODE + BRAIN |
| V-133 · **D-35** | Mesuré : P-062 → P-065 sont passées ✅ le 20/09 (`6dc1e89`) sur des écrans du **lot 3 jamais construits**, puis ⏳ le 21/09 (`b2b7d1e`). ⭐ Le ✅ était faux, le ⏳ est la vérité — mais le retour ne s'est vu nulle part. Règle : **un ✅ retiré se déclare** dans `PORTES_EN_ATTENTE.md` (commit, motif, décision) ; la case 9 lit **toute l'histoire** de `PORTES.md` sur la branche, pas seulement son début et sa fin. Les quatre sont déclarées | BRAIN CODE + BRAIN |
| V-134 | = V-120, toujours ouvert dans `matrice`, `audit4`, `chemin` : chaque fichier photographie les délégations et ne retire que les siennes. Porte : une délégation posée avant le banc lui survit, **fichier par fichier** | CODE (`Role: banc`) |
| V-135 | `JEU_ESSAI.sql` reçoit `agence_responsable_id` ; `make test` le charge sur base neuve — un jeu d'essai qui ne se charge pas ne se découvre plus à l'audit | BRAIN CODE |
| V-136 | Grille : famille F à **13** | BRAIN ✅ |
| V-137 | ⭐ gardé : natures cohérentes, `ArchiveObject`, modèle société sous sabotage, 15 sabotages SQL sur 15 | — |

## Ce que ce tour apprend

⭐ **Deux lecteurs de la même entrée finissent par en lire deux différentes.** Le contrôle et l'écriture
doivent porter sur la même donnée, transmise, pas relue.
⭐ **Une liste de droits recopiée ment le jour où le code change ; une liste calculée, jamais.**

<source>

Rapport : `Desktop/ava-audit-7/rapport/` (SYNTHESE, CONSTATS, SUIVI_V, MUTATIONS, SECURITE, CONFORMITE,
GRILLE), copié dans `audit-2026-09-24c/`. Mesures du BRAIN, 24/09 : `droits.ts:31-32` lu ; `013:111-188`
(5 CHECK de liste) ; histoire de P-062 dans `journal/PORTES.md` (`fc35217` ⏳ → `6dc1e89` ✅ → `b2b7d1e` ⏳).

</source>
