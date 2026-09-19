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
| — | — | *aucun. Le code n'a pas encore été écrit.* | — | — | — |

## ✅ FERMÉS

| # | Gravité | Ce qui se passait | Fermé le | Commit |
|---|---|---|---|---|
| — | — | *aucun* | — | — |

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

**19/09/2026 — journal ouvert, zéro ligne.** Il se remplira au premier retour de code de Grok.

Le contrôle qui alimente ce journal : `SPEC_ASSERTIONS_L7.sql` — 22 assertions, une par mur.
⛔ Une assertion qui tombe **ouvre une ligne 🔴**, sans discussion.

</etat>

---

<source>

Format décidé le 19/09/2026, quand le cadre a changé : une autre IA écrit le code, je l'audite.
L'échelle de gravité est celle de `ref_gravite_alerte` — `critique` · `elevee` · `moyenne` ·
`bonne` — pour qu'il n'y ait **qu'une** échelle de sens dans tout le projet.

</source>
