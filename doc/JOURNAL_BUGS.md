# Journal des bugs — Ava Manager

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
| ~~B-001~~ | ~~🔴~~ | `ava_lecture_agregats` a `SELECT` sur **`v_conditions_du_jour`**, qui expose `tjm_vendu` et `cjm_contrat` **ligne par ligne, par jour**. Le rôle d'agrégats n'est pas censé avoir les lignes : il les a, par la vue | `_ops/SPEC_SQL_AVAMANAGER_V1.sql` §14 | **M-15** | 20/09 |
| **B-002** | 🟠 élevée | ⛔ **chez le codeur, pas chez moi** — la **case 7** du cliquet mesure `git diff HEAD -- _ops/` : elle ne voit que le **non commité**. ⛔ Un commit qui touche `_ops/` la passerait | `outils/cliquet.sh` | **D1** de la grille | 20/09 |
| ~~B-003~~ | ~~🟡~~ | `ava_lecture_agregats` voit aussi `v_droits_effectifs` et `v_besoin_couverture` — sans danger, mais hors de son objet | `_ops/SPEC_SQL_AVAMANAGER_V1.sql` §14 | — | 20/09 |

⭐⭐ **B-001 et B-003 sont MES défauts, pas les siens.** Mon SQL écrit `GRANT SELECT ON ALL
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
| **B-001** | 🔴 | M-15 percé : le rôle d'agrégats lisait `v_conditions_du_jour`. ⭐ Corrigé par un `REVOKE ON ALL` suivi d'un `GRANT` des **quatre** vues — on n'énumère plus ce qui est interdit | 20/09 | *ce commit* |
| **B-003** | 🟡 | Deux vues de trop, fermé par la même correction | 20/09 | *ce commit* |
| **B-004** | 🟠 | `positionnement.personne_id NOT NULL` levait **avant** `ck_m2_xor` : le refus venait du mauvais mur. ⭐ **Trouvé par le codeur du lot 1** | 20/09 | *ce commit* |
| **B-005** | 🟡 | L'assertion M-8 évaluait `has_table_privilege` sans barrière de plan et levait sur une table système. ⭐ **Trouvé par le codeur du lot 1** | 20/09 | *ce commit* |

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
