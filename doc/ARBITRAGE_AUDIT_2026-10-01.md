# Arbitrage du dixième audit — 01/10/2026

Audit sans compromis, `lot-2 @16ea24d`, verdict **REFUSÉ** (3 critiques, 8 élevés, 6 moyens, 1 bon : V-162 → V-178).
⭐ **Tenu** : 342/342 portes ; porte croisée 0 fuite sur 691 identifiants et 5 passes ; 55 sabotages sur 59 vus ;
les 5 règles de construction tiennent ; D-48 → D-55 codées et gardées ; 11 constats du 9e tour fermés.

<etat>

## ⬜ CE QUI RESTE À FAIRE

| # | Quoi | Décision | Constats | Qui | État |
|---|---|---|---|---|---|
| 1 | ⭐ **Le registre exécutable** : pour chaque clé lue par une commande du lot 2, chaque valeur → (commande, scénario, issue attendue) | D-56 | V-162 V-164 | **BRAIN** | ⬜ en premier |
| 2 | Les portes de politique se **génèrent** du registre exécutable ; `COMPORTEMENTS` et `politique_valeur_servie` aussi | D-56 | V-162 V-164 V-172 | BRAIN CODE + CODE | ⬜ après 1 |
| 3 | Une clé sans commande servie : **seul son défaut** est servi | D-56 | V-162 | BRAIN CODE + CODE | ⬜ |
| 4 | Le métier ne passe jamais par `ordre`, un nom de commande ou un littéral | D-57 | V-163 | BRAIN ✅ canon · CODE | ⬜ |
| 5 | `par_besoins` : l'agence responsable garde sa société | D-58 | question 1 | BRAIN ✅ · CODE | ⬜ |
| 6 | Une délégation sur une autre agence opère sur cette agence | D-59 | question 2 | BRAIN ✅ · CODE | ⬜ |
| 7 | Les élevés et moyens | D-60 | V-165 → V-177 | les trois | ⬜ |
| 8 | Onzième audit | — | — | AUDIT | ⬜ seulement après 1 → 7 |

</etat>

## ⭐ D-56 — LE REGISTRE DEVIENT EXÉCUTABLE (V-162, V-164) — et c'est d'abord MA faute

⛔ **La racine est au canon.** La colonne « Effet » du registre est une phrase. Le codeur l'a interprétée ; quand il
ne savait pas, il a marqué la valeur « servie » pour que la porte passe ; et ses portes ont gravé son
interprétation (P-233, P-230, P-215 exigent l'**inverse** du registre). Dix audits ont mesuré des conséquences
d'une spécification qui ne se lit pas par une machine.

| Règle | Tranché |
|---|---|
| **Le format** | `_ops/REGISTRE_EXECUTABLE.md` : une ligne par **(clé, valeur, commande lectrice)** → **scénario** (l'état de départ, en une phrase précise) et **issue attendue** ∈ `ok` · `ok + écrit table.colonne = valeur` · `alerte:CODE` · `GARDE` · `ETAT` · `DROIT`. Lisible par un script |
| **Qui l'écrit** | ⭐ **le BRAIN**, avant toute ligne de code — c'est la spécification qui manquait |
| **Ce qui en dérive** | les cas de la porte des politiques (générés), `COMPORTEMENTS`, `politique_valeur_servie`, `commandes_affectees` — ⛔ plus rien n'est écrit à la main deux fois |
| **La porte différentielle** | chaque scénario joué sous **chaque** valeur servie de la clé ; deux valeurs à l'issue identique partout → rouge, sauf alias écrit au registre ; chaque issue comparée à celle du registre |
| **Une clé sans commande servie** | seul son **défaut** est servi ; `SetPolicy` refuse toute autre valeur (`GARDE` « valeur non servie avant le lot X ») — c'est vrai, pas un compromis : on ne règle pas une commande qui n'existe pas |
| **Une valeur qui exige une donnée** (le taux de `taux_saisi`, la dérogation tracée) | la donnée est déclarée (D-45) et l'issue le dit |
| **Les politiques liste** | elles déclarent le domaine de leurs éléments ; un élément hors domaine → `GARDE` |

## D-57 — LE MÉTIER NE PASSE JAMAIS PAR `ordre` (V-163)

Mesuré : `ManageRefs ref_statut_commercial client ordre=7` (geste permis à l'admin) → **toute signature tombe**.
⛔ `ordre` est l'ordre d'affichage, rien d'autre. `ref_statut_commercial` reçoit des **catégories fermées** —
`prospect` · `client` · `ancien_client` — et le code ne lit que la catégorie. Plus aucun nom de commande dans la
garde générique (la nature, D-31, et la déclaration, D-45, portent tout) ; plus aucun littéral métier.

## D-58 — `par_besoins` : l'agence responsable garde sa société (question 1)

**Non voulu.** Sous `par_besoins`, une société se juge par **l'union** de son agence responsable et des agences de
ses besoins. Sans besoin, elle reste à son agence responsable. L'exemption de `CreateNeed` (`agence.ts:251`)
disparaît : créer un besoin sur une société exige un droit sur une agence de cette union.

## D-59 — Une délégation sur une autre agence opère sur cette agence (question 2)

**Non voulu.** Un droit délégué sur l'agence X ouvre les objets de X, et la création dans X quand l'entrée demande X
(D-26) — que le compte appartienne ou non à X. La porte croisée joue un acteur dont le **seul** droit est sur une
autre agence que la sienne.

## D-60 — Les élevés et moyens

| V | Tranché | Qui |
|---|---|---|
| V-165 | ⛔ « PERMIS » n'est pas un verdict : chaque ligne de la porte croisée a son attendu, calculé de la politique de périmètre ; les 13 positifs `par_besoins` sont jugés | BRAIN CODE |
| V-166 | une transition d'état ne s'écrit **que** dans sa commande : `CreatePrestation` naît `proposee`, jamais `signee` ; pas de besoin en recherche sans `TakeNeedInCharge` (ou sa politique) | CODE |
| V-167 | **une seule horloge** : la date du jour vient de la base (`current_date` au fuseau de l'agence), jamais de Node | CODE + BRAIN CODE |
| V-168 | une garde de commande lit l'**état dérivé** (la vue de D-53), comme l'écran | CODE |
| V-169 | une entrée bien typée ne rend jamais `500` ni `MUR` : chaque contrainte de base a son refus métier déclaré avant l'écriture | CODE |
| V-170 | les portes énumèrent ce que le **serveur** déclare (routes, écrivains), jamais une liste écrite à côté | BRAIN CODE |
| V-171 → V-177 | uuid déclaré `valeur` → `référence` ; `commandes_affectees` calculée ; politiques lues au moment de la commande ; L4 = `DECLARATION` (une porte compare) ; gardes en double retirées ; canon jamais sous `Role: banc` ; cliquet lu par nom de case | répartis dans les prompts |
| V-156 (5e tour) | les délégations : photographie avant/après, déjà au cliquet ; la porte qui efface doit tomber — BRAIN CODE la rend bloquante | BRAIN CODE |

<source>

Rapport : `audits-independants/ava-audit-10/rapport/` (SYNTHESE, CONSTATS V-162 → V-178, SUIVI_V, MUTATIONS,
SECURITE, CONFORMITE, GRILLE), copié dans `audit-2026-10-01/`.

</source>
