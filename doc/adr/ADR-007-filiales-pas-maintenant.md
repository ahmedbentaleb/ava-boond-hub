# ADR-007 — Les filiales : par où on passera, le jour où

**19/09/2026 · accepté par Hamada · ⭐ décision de NE PAS faire, et d'écrire le chemin.**

---

<quand_utiliser>

| ✅ On rouvre cet ADR | ⛔ On ne le rouvre pas |
|---|---|
| Une **vraie** filiale arrive et porte des ressources | parce qu'on a « bientôt » un projet à l'étranger |
| Deux entités doivent avoir des **blacklists séparées** | pour séparer deux équipes — ça, c'est `unite_organisation` |
| Une entité a sa **propre comptabilité** dans le même outil | pour séparer deux **pays** — ça, c'est `agence` |

</quand_utiliser>

---

## Contexte

Boond déclare **cinq « agences »** pour Avaliance : `AVALIANCE FR`, `AVALIANCE MA`,
`AVALIANCE NEARSHORE MA`, `AVALIANCE US`, **`PORTALIANCE`**.

⚠️ Quatre sont des **pays**. La cinquième est un **nom**. Et elle porte un état de candidat à
elle : `Blacklisté Portaliance`, distinct de `Blacklisté Avaliance`.

⭐ **Une blacklist séparée veut dire deux viviers qui ne partagent pas leurs refus.** C'est ce
qui a fait poser la question — pas la ressemblance des noms.

### Ce qu'on a mesuré, le 19/09 au soir

| | Portaliance | Avaliance |
|---|---|---|
| Présente dans le CRM | ⛔ **non** | — le CRM ne porte que clients et prospects |
| Ressources actives | **0** | 204 |
| Candidats blacklistés | **2** | **168** |

⭐⭐ **2 candidats sur 20 744, zéro ressource.** Portaliance ne porte presque rien. ⛔ **Ce n'est
pas une filiale qui opère — c'est un reste.**

⚠️ **Ce que la mesure ne dit pas** : si Portaliance existe **juridiquement**. Elle dit seulement
que **dans l'outil, elle ne sert plus**. Les deux questions sont différentes, et seule la seconde
décide aujourd'hui.

---

## Décision

⭐ **PORTALIANCE devient une AGENCE de plus. Le modèle ne gagne rien aujourd'hui.**

| | |
|---|---|
| Les 5 agences Boond deviennent 5 lignes d'`agence` | dont `PORTALIANCE` |
| Les **2** candidats `Blacklisté Portaliance` | se reprennent comme les 168 autres |
| **ADR-000 ne bouge pas** | une base = une **installation** |

⛔ **Et on N'AJOUTE PAS `agence.societe_id` maintenant.** On ne construit pas pour un besoin qui
n'existe pas.

---

## Le motif

⭐ **Le coût de se tromper n'est pas le même dans les deux sens.**

| Si on se trompe… | Ce que ça coûte |
|---|---|
| On traite Portaliance en agence **alors que c'est une filiale** | fusionner **2 blacklists**. Deux lignes |
| On modélise les filiales **alors qu'il n'y en a pas** | une colonne NOT NULL sur `agence`, un cinquième type de périmètre, un trigger, une case de plus dans **chaque** écran d'administration — et personne ne s'en sert |

⛔ **Le second est bien plus cher, et il est invisible** : du code qui ne sert à rien ne se
signale jamais. On le découvre trois ans plus tard, quand quelqu'un demande à quoi il sert et
que personne ne sait.

⚠️ **Mais écrire le chemin est gratuit.** Ce qui coûte, c'est de le **redécouvrir** — donc on
l'écrit ici, une fois.

---

## ⭐ LE CHEMIN, LE JOUR OÙ — trois gestes, pas une refonte

### Le signal qui rouvre cet ADR

⛔ **Un seul déclencheur, et il est mesurable** : une seconde entité porte **des ressources
actives**, ou **ses propres besoins ouverts**. ⚠️ Un nom dans une liste ne suffit pas — on l'a vu.

### Geste 1 — une colonne

```sql
ALTER TABLE agence ADD COLUMN societe_id UUID REFERENCES societe(id);
-- ⭐ Une agence appartient à UNE société interne. Aujourd'hui elle
--    n'appartient à personne, et c'est ce qui manque.
-- ⛔ Nullable d'abord, remplie, puis NOT NULL. Une migration qui pose
--    NOT NULL sur une table pleine échoue le vendredi soir.
```

### Geste 2 — un trigger, calqué sur `perimetre_interne()`

⛔ La société pointée **porte le rôle `interne`**. Sinon on rattacherait une agence à un client.

### Geste 3 — un cinquième type de périmètre

```sql
-- perimetre.type_code ∈ (agence, pole, equipe, global, + societe)
-- ⭐ Pour donner un droit sur TOUTE une filiale, sans énumérer ses agences.
```

⚠️ **Et le CHECK `ck_x6` s'étend** : `societe` ⇒ `societe_id` seul, les deux autres NULL.

### ⭐ Ce qui ne bouge PAS, et c'est l'essentiel

| | |
|---|---|
| **ADR-000** | une base = une installation. Deux filiales qui partagent un vivier restent **une** base |
| `unite_organisation` | l'arbre interne pend déjà d'une société — il suit tout seul |
| Les **15 murs** | aucun ne parle d'agence. Aucun ne bouge |
| `societe_role` | rien n'y interdit **deux** lignes `interne`. C'était déjà vrai |

⭐ **C'est pour ça que la décision est peu coûteuse** : le modèle est déjà à moitié prêt sans
l'avoir cherché, parce qu'`agence` et `societe` ont toujours été deux choses différentes.

---

## Ce qu'on a écarté, et pourquoi

| Option | Écartée parce que |
|---|---|
| **Deux bases séparées** | ⛔ le vivier de **20 744 candidats** serait coupé ou dupliqué. Deux viviers qui divergent valent moins qu'un seul |
| **Ajouter `agence.societe_id` tout de suite** | ⚠️ une colonne NOT NULL que personne ne remplit autrement que par « Avaliance » partout. Du bruit dans chaque écran |
| **Une colonne `groupe_id`** | ⛔ un troisième niveau — société, groupe, agence. On en a refusé un déjà : deux niveaux suffisent |
| **Laisser les deux blacklists** comme deux états | ⚠️ voir **B-1** : une blacklist est un **drapeau**, pas une étape d'un cycle |

---

## Conséquences

| | |
|---|---|
| ✅ Grok monte la base **maintenant**, avec 5 agences | plus rien ne bloque le lot 1 |
| ⬜ **B-1** reste ouverte | la blacklist : drapeau ou état ? Elle ne dépend plus de celle-ci |
| ⚠️ Un jour, quelqu'un relira les 5 agences et trouvera `PORTALIANCE` étrange | ⭐ **c'est pour lui que cet ADR est écrit** |

---

<interdits>

| ⛔ Jamais | Le problème que ça évite |
|---|---|
| Rouvrir cet ADR sur un **nom** | on l'a déjà fait une fois, et la mesure a dit non |
| Ajouter `societe_id` « au cas où » | une colonne que personne ne remplit ment sur ce qu'elle promet |
| Poser un troisième niveau — société, groupe, agence | deux niveaux. C'est la même règle que pour les sessions |
| Séparer deux **bases** pour deux filiales qui partagent un vivier | deux viviers qui divergent valent moins qu'un seul |
| Traiter une **agence** comme une entité juridique | une agence est un **site** : un pays, un calendrier. Rien d'autre |

</interdits>

---

<source>

Mesuré le 19/09/2026 dans l'instance Avaliance de Boond, session ouverte par Hamada.
Relevé complet : [BOOND_CHEMINS_2026-09-19.md](../cartographie/BOOND_CHEMINS_2026-09-19.md) §18.
La question d'origine : [QUESTIONS_BOOND_2026-09-19.md](../QUESTIONS_BOOND_2026-09-19.md), B-5
— *anciennement A-1, descendue de rang à la mesure*.

⭐ **Ce que cet ADR enseigne au-delà de son sujet** : la question était classée **bloquante**, et
trois clics l'ont fait tomber d'un rang. ⛔ **Une question qu'on peut mesurer ne se pose pas** —
on la mesure d'abord, on la pose ensuite si elle tient encore.

</source>
