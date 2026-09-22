# Brief exécutant — Ava Manager v1

Date : 17/09/2026 · Pour : **la session de code** (Opus), pas la session de cadrage · Écrit par : Fable, session de cadrage

⛔ **Ce brief ne s'active qu'à l'existence de `_ops/VALIDATION_MODELE_V1_<date>.md`, de la main d'Ahmed.** Tant que ce fichier n'existe pas, il n'y a rien à exécuter : ni migration, ni API, ni écran. Lis-le, prépare ton environnement, et attends.

---

## 1. Ce que tu reçois — et rien d'autre

| # | Pièce | Ce qu'elle est pour toi |
|---|---|---|
| 1 | Ce brief | **Ton mur.** |
| 2 | [`MODELE_DONNEES_AVAMANAGER_V1.md`](MODELE_DONNEES_AVAMANAGER_V1.md) + le fichier de validation d'Ahmed | **Ta source unique de tables.** Tu n'inventes aucune table, aucune colonne. Une colonne qui manque est une question, pas une initiative. |
| 3 | [`MACHINES_ETAT_V1.md`](MACHINES_ETAT_V1.md) | Les cycles, les transitions, qui les déclenche, les événements. Les états sont des **référentiels à catégorie** : tu compares des catégories, jamais des codes. |
| 4 | [`MODELE_METIER_CANONIQUE_v1.md`](MODELE_METIER_CANONIQUE_v1.md) §3 | Les **15 murs**. Chacun devient une contrainte SQL, un trigger ou un droit de rôle — jamais un `if` dans un service. |
| 5 | [`REGISTRE_POLITIQUES_v1.md`](REGISTRE_POLITIQUES_v1.md) | **Toutes les politiques** (compte : registre §E). Chaque bifurcation métier lit sa clé dans la table `politique`. Un `if` métier sans clé au registre est refusé en revue — par toi-même, avant qu'on te le dise. |
| 6 | [`adr/ADR-000`](adr/ADR-000-mono-tenant.md) → [`ADR-005`](adr/ADR-005-politiques-parametrables-vs-invariants.md) | Pourquoi c'est comme ça. Tu les lis pour **ne pas réparer une décision**. |
| 7 | [`ava-simulateur-metier.html`](ava-simulateur-metier.html) | **Ton oracle de comportement.** Son moteur (couche `db`, un **sous-ensemble** des politiques du registre — son en-tête dit lequel) est la référence exécutable de ce que le produit doit refuser et accepter. Quand tu hésites sur un refus, joue-le dans le simulateur. |
| 8 | Le canon en lecture seule : DEC-01→18, F1–F36, G1–G15, P1–P3, T-1, ATL | Tu ne le rouvres **jamais**. |

⛔ Tu ne reçois **pas** : le cadrage réconcilié en entier, le hub, les plans, les relectures, l'historique des hésitations. Te donner l'atelier, c'est t'inviter à le refaire.

## 2. Ce que tu ne fais jamais

| ⛔ | Et pourquoi |
|---|---|
| Rouvrir une DEC, une F, une G, une ADR — même « juste pour clarifier » | Un canon qu'on clarifie en codant n'est plus un canon. Si un texte est ambigu ou muet, tu **écris la question** dans `_ops/QUESTIONS_EXECUTANT.md`, tu prends **l'interprétation la plus restrictive**, tu continues. |
| Un `if` métier sur un code d'état (`'signee'`, `'ouvert'`) | Les états sont administrables. Tu compares `categorie`, lue depuis `ref_etat_*`. |
| Un `if` métier sans clé de politique | Toute bifurcation lit `politique`. Si la clé n'existe pas au registre, ce n'est pas une bifurcation : c'est un mur, ou une question. |
| Un mur dans l'UI ou dans un service seulement | Les 15 murs vivent dans la base : FK, CHECK, trigger, droits du rôle SQL. Le service peut refuser **en plus**, jamais **à la place**. |
| `DELETE` sur une table historique | `archive_le`. Le rôle applicatif n'a pas le droit `DELETE` sur ces tables — c'est toi qui le lui retires. |
| `UPDATE` sur `evenement_metier` ou `snapshot_marge` | Ajout seul. Trigger + droits. |
| Un `tenant_id` | ADR-000, P1 : une base par société. |
| Un montant sans `devise_code` à côté | M-15. |
| Une colonne `boond_id` sur une table métier | La reprise vit dans `reprise_boond`. |
| Un `VARCHAR(n)` | `TEXT`. Une longueur arbitraire est une règle métier cachée. |
| Une date affichée dans un autre fuseau que celui du lecteur | Tout en `TIMESTAMPTZ`, conversion à l'affichage. Une heure montrée est celle de qui la lit. |
| Committer sur `main` | Branche par lot, PR, revue. |
| Contourner un test qui rougit | Tu n'es pas propriétaire du banc. Un test que tu peux assouplir n'est pas un filet. |

## 3. Ce que tu fais, dans cet ordre

Un lot = une branche, un commit par point, un test rouge vu avant d'être vert.

| Lot | Contenu | La commande qui prouve |
|---|---|---|
| **7 — Schéma** | Les tables du livrable §1 + les `ref_*` + `politique` + `reprise_boond` (comptes : registre §E) en SQL PostgreSQL, **exactement** le livrable 5. Les 15 murs en contraintes, triggers et droits (livrable §9). Rôle SQL applicatif sans `DELETE` sur les tables historiques, sans `UPDATE` sur `evenement_metier` et `snapshot_marge`. | un script qui tente les 15 interdits contre la base et attend **15 refus SQL** — le pendant du « banc des murs » du simulateur |
| **9a — Seeds** | Les référentiels du registre §B et §E, avec leurs codes système et catégories (registre §B) ; **toutes les politiques du registre §C** à leur défaut (colonne en gras ; compte §E) ; une agence, son calendrier, la société `AVALIANCE` en rôle `interne`. | `SELECT count(*) FROM politique` = **le compte du registre §E** (lis-le, ne le recopie pas) ; chaque valeur = son défaut |
| **8 — Droits** | `groupe`, `permission`, `perimetre`, `groupe_permission_perimetre`, `compte_surcharge` peuplés depuis la matrice retenue (cadrage §matrice, F8–F14). Résolution : union des paires, puis surcharges, restriction gagne (F28). | un test par ligne de la matrice : commande autorisée dans le périmètre, refusée hors périmètre, refusée sans le groupe |
| **10a — Services** | Une fonction par commande des machines d'état (§1–§7). Chaque commande : `droit()` → gardes (catégories + politiques) → mutation → **événement dans la même transaction**, avec les clés de politique lues dans `liens`. | rejouer **S1 → S15** du cadrage comme tests d'intégration, un monde cumulatif ; rejouer les 7 scénarios du §6 du brief simulateur |
| **10b — API** | Une route par commande, une par lecture. Les lectures filtrent par périmètre (BM-45). Un refus rend le motif métier et sa source (`M-4`, `F1`, `politique …`). | les mêmes tests, par HTTP |
| **10c — UI** | Les écrans du mock, dans cet ordre : Sociétés · Candidats · Ressources · Besoins · Projets · Prestations · Mes temps · Plan de charge · Administration › Politiques. Un bouton visible n'est pas une autorisation : la commande refuse, l'écran montre le motif. | un écran = ses tables de la bande du bas, rien de plus |
| **9b — Reprise Boond** | Import dans `reprise_boond` + correspondance des états Boond vers des codes `ref_*` (créés dans la bonne catégorie, sans code). | chaque objet importé a sa ligne de correspondance ; zéro objet sans état valide |

⭐ **Le plus risqué en premier** : le lot 7 avec ses 15 refus SQL. Si un mur ne tient pas en base, rien d'autre n'a de sens.

## 4. Comment tu rends compte

| Quand | Quoi |
|---|---|
| Chaque lot fini | une ligne dans `_ops/JOURNAL_EXECUTANT.md` : lot · commit · la commande de preuve et sa sortie |
| Une question | `_ops/QUESTIONS_EXECUTANT.md` : le texte muet, ton interprétation restrictive, ce que tu as fait. **Tu ne t'arrêtes pas.** |
| Un mur qui ne tient pas en base | tu **t'arrêtes sur ce point**, tu l'écris en tête de ton fichier d'état : `BLOQUÉ: M-n — <raison>`, tu passes au point suivant du lot |
| Deux échecs sur le même point | le point remonte à la session de cadrage (Fable). Ce n'est pas toi qui as tort : c'est le plan qui n'avait pas prévu quelque chose |

## 5. Ce qui est hors de ton lot

Achats, factures, commentaires, mentions, alertes, emailing, portail candidat, processus de recrutement versionné, objectifs stockés, multi-tenant, restauration d'archive. Les tables sont **nommées** au livrable 5 §1 pour ne pas être oubliées ; tu ne les crées pas.

## 6. En une phrase

**Tu ne décides rien : tout est décidé. Tu rends les murs physiques, les politiques lisibles, les états administrables — et quand un texte se tait, tu prends le plus strict, tu l'écris, et tu continues.**
