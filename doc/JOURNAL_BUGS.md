# Journal des bugs — Ava Manager · **audit général**

⛔⛔ **CORRIGÉ LE 20/09 — il y avait DEUX journaux, et c'était ma faute.**
`/journal/BUGS.md` (le greffier, dans le code) et celui-ci numérotaient tous les deux à partir de
`B-001`. ⭐ **Deux bugs différents sous le même numéro** — exactement ce que la section
`<interdits>` de ce fichier interdit.

| Journal | Préfixe | Qui écrit |
|---|---|---|
| **`/journal/BUGS.md`** | `B-` | le **greffier**, pendant le lot |
| **ce fichier** | ⭐ **`A-`** | l'**auditeur général**, entre les lots |

⭐ **Deux journaux, deux préfixes, aucune collision.** Les anciens `B-001` à `B-005` de ce fichier
sont renumérotés `A-001` à `A-005` ci-dessous.

⭐ **Un bug par ligne, jamais deux.** Une ligne qui en porte deux ne se ferme jamais : on corrige
l'un, on oublie l'autre, et la ligne reste rouge pour une raison que personne ne retrouve.

---

<quand_utiliser>

| ✅ Ça entre ici | ⛔ Ça n'entre pas |
|---|---|
| Le code de Grok viole un **mur** | une **préférence** d'apparence → le plan |
| Une **assertion** L7 tombe | une **question** métier → le cahier des directeurs |
| Un `if` métier écrit en dur (ADR-005) | une **idée** → le plan du jour |
| Un compte qui ne correspond plus au registre §E | un bug déjà fermé → il reste, barré |

⛔ **Un bug ne se supprime pas** — comme M-8. Il passe à ✅, avec la date et le commit qui l'a
fermé. Une ligne effacée est une leçon perdue.

</quand_utiliser>

---

<procedure>

**1.** Ouvrir une ligne avec un **numéro qui ne se réutilise jamais** : `B-001`, `B-002`…

**2.** Remplir les six colonnes. ⛔ Aucune ne se laisse vide — « à préciser » est un bug de plus.

**3.** La gravité suit **l'échelle du SENS**, celle des alertes, et aucune autre :

| Gravité | Quand |
|---|---|
| 🔴 **critique** | un **mur** est franchi, ou une donnée est perdue |
| 🟠 **élevée** | une règle du registre est contournée — un `if` en dur, une politique ignorée |
| 🟡 **moyenne** | c'est faux, mais ça se voit et ça se contourne |
| 🟢 **basse** | c'est laid ou lent, rien n'est faux |

**4.** Fermer avec **le commit**, pas avec « corrigé ». Un bug fermé sans SHA se rouvre tout seul.

</procedure>

---

## ⬜ OUVERTS

| # | Gravité | Ce qui se passe | Où | Mur / règle | Ouvert le |
|---|---|---|---|---|---|
| ~~A-001~~ | ~~🔴~~ | `ava_lecture_agregats` a `SELECT` sur **`v_conditions_du_jour`**, qui expose `tjm_vendu` et `cjm_contrat` **ligne par ligne, par jour**. Le rôle d'agrégats n'est pas censé avoir les lignes : il les a, par la vue | `_ops/SPEC_SQL_AVAMANAGER_V1.sql` §14 | **M-15** | 20/09 |
| ~~A-010~~ | ~~🟠~~ | ⛔ **`001_schema.sql` n'est pas rejouable** : 22 `CREATE TRIGGER`, **zéro** `DROP TRIGGER IF EXISTS`. Tant qu'elle est marquée dans `schema_migrations`, rien ne se voit. ⚠️ Le jour où elle tombe **à moitié** — comme `006` vient de le faire — elle n'est pas marquée, `make migrate` la rejoue, et elle lève. ⭐ **On est alors bloqué sans rien pouvoir faire d'autre que reconstruire la base** | `db/migrations/001_schema.sql` | — | 20/09 |  ⭐ **FERMÉ le 20/09**
| ~~A-011~~ | ~~🟠~~ | ⛔ **La case 7 du cliquet a été passée de bloquante à « signalée »** parce qu'elle gênait son propre auteur. ⚠️ Le motif est juste — le canon appartient à Hamada — mais **on n'assouplit pas un contrôle parce qu'il gêne : on corrige ce qu'il mesure**. ⭐ La vraie parade est déjà appliquée : **le canon se commite sur `main`**, et mes 9 commits `_ops/` y sont. Dès que `lot-2` rebase, la case redevient verte **sans assouplissement** | `outils/cliquet.sh` | **D1** | 20/09 |  ⭐ **FERMÉ le 20/09** — la case est bloquante, et **A-013 a supprimé la raison de la desserrer**
| ~~A-012~~ | ~~🟠~~ | ⛔ **Le plancher d'assertions était à 22 alors que le contrôle en compte 23** — `make.sh` comme `outils/cliquet.sh` faisaient `grep -c 'OK   M-'`, motif qui attrape les **22 assertions + le contre-test M-14**, puis comparaient à **22**. ⚠️ Une assertion pouvait donc disparaître **sans que la case bouge**. ⭐ C'est le même défaut qu'A-001 : *un contrôle dont le seuil ne vaut pas ce qu'il mesure ne mesure rien*. Corrigé — seuil à **23** des deux côtés | `outils/make.sh` · `outils/cliquet.sh` | — | 20/09 |  ⭐ **FERMÉ le 20/09**
| **A-002** | 🟠 élevée | ⛔ **chez le codeur** — la **case 7** du cliquet mesure `git diff HEAD -- _ops/` : elle ne voit que le **non commité**. Un commit qui touche `_ops/` la passerait | `outils/cliquet.sh` | **D1** de la grille | 20/09 |
| **A-006** | 🔴 **critique** | ⛔⛔ **`make test` ne tourne pas sous Git Bash / Windows.** `make.sh` passe `-f /workspace/test/…` à `psql` ; MSYS réécrit tout argument commençant par `/` en chemin Windows → `C:/Program Files/Git/workspace/…`. **Le cliquet sort en 1 sur la machine d'Hamada.** ⭐ Prouvé : `MSYS_NO_PATHCONV=1` devant la commande → **23 OK** | `outils/make.sh` L87 | ⛔ **porte de la famille A inexécutable** | 20/09 |
| **A-007** | 🟠 élevée | **Collision de numéro d'ADR** : `_ops/adr/ADR-007-filiales-pas-maintenant.md` (conception, le mien) et `journal/adr/ADR-007-port-postgres-hote.md` (réalisation, le sien). ⭐ Deux décisions différentes sous le même numéro | les deux dossiers `adr/` | — | 20/09 |
| ~~A-003~~ | ~~🟡~~ | `ava_lecture_agregats` voit aussi `v_droits_effectifs` et `v_besoin_couverture` — sans danger, mais hors de son objet | `_ops/SPEC_SQL_AVAMANAGER_V1.sql` §14 | — | 20/09 |

⭐⭐ **A-001 et A-003 sont MES défauts, pas les siens.** Mon SQL écrit `GRANT SELECT ON ALL
TABLES` puis `REVOKE` sur six tables — en oubliant que « ALL TABLES » **inclut les vues**. Grok
l'a implémenté fidèlement.

⛔⛔ **Et mon assertion A-22 est passée au vert.** Elle ne vérifie que trois **tables** ; elle ne
regarde aucune vue. ⭐ **Le mur était percé et le test disait OK.** C'est exactement ce que le
contre-test de M-14 devait m'apprendre, et je ne l'ai pas appliqué à M-15.

⚠️ **La leçon, écrite pour qu'elle serve** : une assertion qui énumère des noms ne couvre que
ces noms. ⭐ **Un mur se teste par ce qu'on peut ATTEINDRE, pas par une liste qu'on a écrite.**

## ✅ FERMÉS

| # | Gravité | Ce qui se passait | Fermé le | Commit |
|---|---|---|---|---|
| **A-001** | 🔴 | M-15 percé : le rôle d'agrégats lisait `v_conditions_du_jour`. ⭐ Corrigé par un `REVOKE ON ALL` suivi d'un `GRANT` des **quatre** vues — on n'énumère plus ce qui est interdit | 20/09 | *ce commit* |
| **A-003** | 🟡 | Deux vues de trop, fermé par la même correction | 20/09 | *ce commit* |
| **A-004** | 🟠 | `positionnement.personne_id NOT NULL` levait **avant** `ck_m2_xor` : le refus venait du mauvais mur. ⭐ **Trouvé par le codeur du lot 1** | 20/09 | *ce commit* |
| **A-010** | 🟠 | ⛔ Une migration qui tombe **à mi-chemin** laissait la base à moitié faite, non marquée : le tour suivant la rejouait et elle levait. ⭐ **La parade n'est pas des `IF NOT EXISTS`** — ils auraient fait passer une base à moitié faite pour normale. C'est **`--single-transaction`**, et **la ligne du registre part dans la même transaction**. ⭐⭐ Vérifié en sabotant `001` en son milieu : **0 table laissée**, puis le vrai `001` passe | 20/09 | *ce commit* |
| **A-011** | 🟠 | Case 7 desserrée par une session parce qu'elle bloquait son propre auteur. ⭐ **Remise bloquante**, et A-013 a retiré la raison de la desserrer : elle ne produit plus de rouge inextinguible | 20/09 | *ce commit* |
| **A-013** | 🟠 | ⛔ **La case 7 du cliquet comptait des SHA, pas du contenu.** Un cherry-pick vers `main` recrée le commit avec un autre SHA : l'original restait dans `main..HEAD` et la case restait rouge **alors que le canon était porté**. ⭐⭐ C'est ce qui a poussé une session à la desserrer (A-011) : *une case qu'aucun geste ne peut éteindre, on apprend à l'ignorer*. Elle mesure désormais le **diff** — plus strict, pas plus lâche | 20/09 | *ce commit* |
| **A-012** | 🟠 | Plancher d'assertions à 22 pour un contrôle qui en compte 23. Corrigé des deux côtés | 20/09 | *ce commit* |
| **A-009** | 🟠 | ⛔ **`006` n'était pas rejouable** : `CREATE TRIGGER tg_garde` levait « existe déjà » après un passage à moitié. ⭐ Corrigé — 10 `DROP TRIGGER IF EXISTS`, et **vérifié en la jouant deux fois d'affilée**. ⚠️ Trouvé par la session de plan, pas par moi | 20/09 | *ce commit* |
| **A-005** | 🟡 | L'assertion M-8 évaluait `has_table_privilege` sans barrière de plan et levait sur une table système. ⭐ **Trouvé par le codeur du lot 1** | 20/09 | *ce commit* |

⭐⭐ **Vérifié, pas déclaré** : le SQL corrigé rejoué sur une base **neuve** donne **23 OK**, le
rôle d'agrégats n'atteint plus que **4 vues + 3 référentiels**, et — le seul test qui compte —
**l'assertion corrigée TOMBE** quand on lui redonne `v_conditions_du_jour`.

---

<interdits>

| ⛔ Jamais | Le problème que ça évite |
|---|---|
| Supprimer une ligne | la leçon part avec elle — on refait le même bug en mars |
| Réutiliser un numéro | deux bugs différents sous `B-007`, et l'historique ment |
| Fermer sans SHA de commit | personne ne peut vérifier, et ça se rouvre tout seul |
| Deux bugs sur une ligne | on en corrige un, la ligne reste rouge, plus personne ne sait pourquoi |
| Une gravité « à voir » | l'échelle a quatre crans et pas cinq |
| Noter ici une préférence | ce n'est pas un bug, c'est un point de plan |

</interdits>

---

<etat>

**20/09/2026 — 3 lignes, ouvertes au premier audit du lot 1.**

⭐ **Le lot 1 est ACCEPTÉ.** Les 22 assertions passent, elles **tombent** quand on casse un mur
(vérifié sur `tg_m10`, un mur **différent** de celui qu'il avait testé), et `_ops/` est intact.

⚠️ **Les 3 lignes ouvertes sont des défauts de MA spécification**, pas de son code.

Le contrôle qui alimente ce journal : `SPEC_ASSERTIONS_L7.sql` — 22 assertions, une par mur.
⛔ Une assertion qui tombe **ouvre une ligne 🔴**, sans discussion.

</etat>

---

<source>

Format décidé le 19/09/2026, quand le cadre a changé : une autre IA écrit le code, je l'audite.
L'échelle de gravité est celle de `ref_gravite_alerte` — `critique` · `elevee` · `moyenne` ·
`bonne` — pour qu'il n'y ait **qu'une** échelle de sens dans tout le projet.

</source>
