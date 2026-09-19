# ADR-006 — L'avenant est une version datée, pas une mission de plus

Date : 19/09/2026 · Statut : **accepté** · Amende : ATL-18, [ADR-003](ADR-003-projet-prestation-ressource.md) · Source : relecture métier externe du 19/09, lignes 19 et M1–M2

---

## Le contexte

ATL-18 disait : une mission signée ne se modifie pas, **on en crée une autre**. C'est ce qui rendait **M-14** tenable — dès `engage`, les conditions économiques sont immuables, et le trigger les protège.

La relecture externe classe ce point **BLOQUANT AVANT CODE** et demande l'inverse : *« avenant/version rattaché à la même mission, avec date d'effet »*.

⚠️ **Les deux ont raison, et pas sur la même question.**

| | Ce que ça protège | Ce que ça casse |
|---|---|---|
| **Nouvelle mission** (ATL-18) | l'immuabilité, sans exception. Le passé ne bouge pas | ⛔ une prolongation de trois mois devient **deux missions** qui n'en sont qu'une. Le plan de charge en montre deux, la fiche ressource en montre deux, et personne ne voit que c'est la même |
| **Version datée** (relecture) | l'histoire réelle d'un contrat : un TJM au 1er janvier, un autre au 1er juin | ⛔ si la version écrit dans `prestation`, **M-14 tombe** |

---

## La décision

⭐ **Les deux, et c'est une politique** — POL `prestation.avenant.mode`.

| Valeur | Ce qui se passe | Pour qui |
|---|---|---|
| **`nouvelle_prestation`** | le comportement d'ATL-18, inchangé. `prestation_version` reste **vide** | ⭐ **défaut Avaliance** |
| `version_datee` | une ligne de plus dans `prestation_version`, avec sa `date_effet` et son motif | une société qui gère de longs contrats à conditions mouvantes |

⛔ **Et la clé de tout : un avenant n'écrit JAMAIS dans `prestation`.** Il ajoute une ligne à `prestation_version`. **M-14 n'est pas affaibli, il n'est même pas touché** — les colonnes de `prestation` restent immuables dès `engage`, dans les deux modes.

⭐ **`prestation_version` est en ajout seul**, comme `evenement_metier` (M-7) : `UPDATE` et `DELETE` lèvent, et le rôle SQL ne les a pas. Une erreur de saisie se corrige par **une version de plus**. C'est la même règle, pour la même raison : un historique qu'on peut réécrire n'est pas un historique.

**La version 1 s'écrit à la signature**, dans la transaction de `SignPrestation`, en recopiant les conditions de `prestation`. ⚠️ Sans elle, une mission avenantée n'aurait pas de « avant ».

---

## Ce que ça change pour la marge

⭐ **ATL-15 ne change pas de formule, il change de source.** Le snapshot lit la version **en vigueur à chaque date**, pas la dernière : un TJM qui change au 1er juin ne réécrit pas mai.

Sous le défaut, la table est vide et le snapshot lit `prestation`, exactement comme avant.

---

## Ce qu'on rejette

| ⛔ Rejeté | Pourquoi |
|---|---|
| Rendre `prestation` modifiable après `engage` | M-14 tombe, et avec lui la promesse n° 14 du cahier |
| Une colonne `prestation_parente_id` qui chaîne les missions | on garde deux missions dans tous les écrans — le problème qu'on vient de nommer |
| Écrire l'avenant dans `evenement_metier` seul | un événement se lit, il ne se calcule pas. La marge a besoin d'une table qu'on interroge par date |
| Trancher pour l'un des deux camps | ⛔ **ADR-005.** Une bifurcation métier est une politique, pas une opinion |

---

## Le coût

| | |
|---|---|
| Une table | `prestation_version`, 12 colonnes, PK à deux colonnes |
| Un référentiel | `ref_motif_avenant`, 5 valeurs système |
| Une seconde option | sur une clé qui existait déjà |
| **Des politiques** | 82 → **83** ; **référentiels** 27 → 29 ; **tables** 32 → 33 |

⚠️ **Annoncé en ligne 1**, comme le gel du 17/09 l'exige.
