# La parade ⏳ — une porte posée avant d'être servie

**20/09/2026 · complète le cliquet · s'applique dès le lot 2.**

⛔⛔ **Le cliquet se contredisait.** Il exige `make test` **en 0 à chaque tour**, et le rite du
banc exige qu'une porte soit **posée et vue rouge AVANT** que le code la serve. ⭐ En milieu de
lot, le cliquet ne pouvait donc **jamais** sortir en 0.

⚠️ **Constaté le 20/09** : Grok a posé les **55 portes de contrat** d'un coup. Le serveur n'en
sert aucune. `make test` sort en 1 — et c'est **normal**, pas une régression.

---

<quand_utiliser>

| ✅ Une porte est ⏳ | ⛔ Une porte n'est JAMAIS ⏳ |
|---|---|
| Elle est posée, **vue rouge**, journalisée | parce qu'elle est instable et qu'on ne sait pas pourquoi |
| Le code qui la sert **n'existe pas encore** | parce qu'elle gêne et qu'on veut livrer |
| Elle porte **le lot où elle passera ✅** | sans échéance |

⛔⛔ **`⏳` n'est pas un `skip` déguisé.** Un `skip` cache un test ; un `⏳` **déclare** un test qui
attend son code, avec la date où il ne pourra plus attendre.

</quand_utiliser>

---

## La règle, en trois lignes

| | |
|---|---|
| **1** | Une porte naît **⏳**, vue rouge, avec **le lot** où elle passera ✅ |
| **2** | Elle passe **✅** le jour où le code la sert — et **c'est irréversible** |
| **3** | ⛔ **Une porte ✅ ne redevient JAMAIS ⏳.** C'est ça, le cliquet |

---

## Ce que `journal/PORTES.md` porte désormais

```
| Porte | Espèce | Phrase | Test | Vue rouge | État | Lot cible |
|-------|--------|--------|------|-----------|------|-----------|
| P-001 | A BASE | Les 15 murs tiennent. | test/…L7.sql | 2026-09-19 | ✅ | 1 |
| P-012 | B CONTRAT | CreateCompany rend la société créée. | test/contrat/CreateCompany.test.ts | 2026-09-20 | ⏳ | 2 |
```

| Colonne | Ce qu'elle porte |
|---|---|
| **État** | `✅` servie · `⏳` en attente |
| **Lot cible** | ⭐ le lot où elle DOIT être ✅. ⛔ Une `⏳` sans lot cible est refusée |

---

## Ce que le cliquet mesure — trois cases changent, une s'ajoute

| Case | Avant | ⭐ Maintenant |
|---|---|---|
| **1** | `make test` sort en 0 | **toutes les portes ✅ passent** · les ⏳ peuvent échouer |
| **3** | portes(maintenant) ≥ portes(main) | ⭐ **portes ✅(maintenant) ≥ portes ✅(main)** |
| **9** | — | ⛔ **aucune porte n'est passée de ✅ à ⏳** |
| **10** | — | ⚠️ **aucune ⏳ dont le lot cible est dépassé** |

⭐⭐ **Le changement qui compte est la case 3 : le cliquet compte les portes SERVIES.** Une porte
en attente ne protège rien — la compter serait se mentir sur ce qui est verrouillé.

⛔ **La case 9 est le cliquet du cliquet.** Sans elle, il suffirait de repasser une porte en ⏳
pour la faire taire — et on aurait recréé le `skip` avec un joli symbole.

⚠️ **La case 10 empêche le parking.** Une `⏳` qui traîne deux lots est une porte qu'on n'a jamais
eu l'intention de servir.

---

## L'implémentation — à poser dans `outils/cliquet.sh`

```bash
# ── Les portes, lues dans le journal ──────────────────────────────────────
#    Colonnes : | numéro | espèce | phrase | test | vue rouge | état | lot |
portes_servies() {   # $1 = le fichier PORTES.md
  grep -cE '^\| *P-[0-9]+ *\|.*\| *✅ *\|' "$1" 2>/dev/null || echo 0
}
portes_attente() {
  grep -cE '^\| *P-[0-9]+ *\|.*\| *⏳ *\|' "$1" 2>/dev/null || echo 0
}

# ⭐ CASE 3 — le cliquet compte les SERVIES, pas le total.
now_ok="$(portes_servies journal/PORTES.md)"
main_file="$(mktemp)"
git show "$base:journal/PORTES.md" > "$main_file" 2>/dev/null || : > "$main_file"
base_ok="$(portes_servies "$main_file")"
if [[ "$now_ok" -ge "$base_ok" ]]; then
  line 3 "portes servies >= servies(main)" OK "$now_ok >= $base_ok"
else
  line 3 "portes servies >= servies(main)" KO "$now_ok < $base_ok"
fi

# ⛔ CASE 9 — le cliquet du cliquet : aucune ✅ n'est redevenue ⏳.
#    On compare NUMÉRO par NUMÉRO, pas par compte : un total qui ne baisse
#    pas peut cacher une porte rétrogradée et une autre ajoutée.
retro=""
while read -r p; do
  [[ -z "$p" ]] && continue
  if grep -qE "^\| *$p *\|.*\| *⏳ *\|" journal/PORTES.md; then
    retro="$retro $p"
  fi
done < <(grep -oE '^\| *P-[0-9]+' "$main_file" | tr -d '| ' )
if [[ -z "$retro" ]]; then
  line 9 "aucune porte rétrogradée ✅ → ⏳" OK ""
else
  line 9 "aucune porte rétrogradée ✅ → ⏳" KO "$retro"
fi

# ⚠️ CASE 10 — aucune ⏳ dont le lot cible est dépassé. LOT_COURANT vient de
#    l'environnement, ou vaut 2 par défaut.
depasse="$(awk -F'|' -v lot="${LOT_COURANT:-2}" '
  /^\| *P-[0-9]+ *\|/ && $7 ~ /⏳/ {
    gsub(/[^0-9]/, "", $8);
    if ($8 != "" && $8+0 < lot) { gsub(/ /, "", $2); print $2 }
  }' journal/PORTES.md)"
if [[ -z "$depasse" ]]; then
  line 10 "aucune ⏳ au-delà de son lot cible" OK ""
else
  line 10 "aucune ⏳ au-delà de son lot cible" KO "$depasse"
fi
```

⚠️ **Et la case 1 change de sens** : `make test` ne peut plus se contenter de son code de sortie.
⭐ Le banc doit **nommer ses tests d'après le numéro de porte** — `P-012 CreateCompany …` — pour
qu'un échec se rattache à une ligne du journal. ⛔ Sans ça, on ne peut pas savoir si celui qui
tombe était ✅ ou ⏳, et la case redevient du tout-ou-rien.

---

<interdits>

| ⛔ Jamais | Le problème que ça évite |
|---|---|
| Une `⏳` **sans lot cible** | elle reste en attente pour toujours, et personne ne s'en aperçoit |
| Repasser une `✅` en `⏳` | ⭐ **c'est le `skip` avec un joli symbole** — case 9 |
| Compter les `⏳` dans le cliquet | une porte en attente ne protège rien ; la compter, c'est se mentir |
| Une `⏳` **jamais vue rouge** | elle ne prouve rien, même le jour où elle passera |
| Laisser une `⏳` au rendu du lot cible | ⛔ **refus** : c'est une porte qu'on n'avait pas l'intention de servir |
| Nommer un test sans son numéro de porte | on ne sait plus lequel avait le droit d'échouer |

</interdits>

---

<etat>

**20/09/2026 — écrit, pas encore implémenté dans `outils/cliquet.sh`.**

| | |
|---|---|
| Qui l'implémente | ⭐ le **sous-agent BANC** — c'est son fichier |
| Quand | ⛔ **avant de reprendre le lot 2** : sans ça il ne peut pas cocher une étape |
| Ce que ça débloque | les **55 portes de contrat** déjà posées passent en ⏳, lot cible **2** |

⚠️ **Les 5 portes du lot 1 passent ✅ sans discussion** — elles sont servies et vertes.

## ⏳ P-355 → P-358 — la porte différentielle du registre exécutable (D-56, 01/10)

| Porte | Posée | Vue rouge | Pourquoi ⏳ | Passe ✅ quand |
|---|---|---|---|---|
| P-355 | 01/10, `lot-2-brain` | 01/10 : **58 lignes sur 204** non tenues, sur 26 clés — dont 5 des 6 valeurs fausses de V-162 (le ⑤ `cascade_cloture_prestations` tient déjà) | le serveur ne code pas encore le registre (CODE), le schéma de D-57 → D-67 est en 023 (BRAIN CODE), et 4 scénarios ne s'écrivent pas à la lettre (S-DR1, S-CH2 avant 023 ; S-UC1, S-CV* : à trancher au registre) | 204 / 204 |
| P-356 | 01/10, `lot-2-brain` | 01/10 : 13 paires indiscernables, dont **1 au registre** (`candidat.note.echelle` : `1_5` = `aucune`, aucun scénario ne les distingue) ; 02/10 : S-NE3 (Q-024) les distingue — 6 paires, toutes observées au serveur, 0 au registre | idem, et le registre lui-même (BRAIN) | 0 paire |
| P-357 | 01/10, `lot-2-brain` | 01/10 : 8 / 8 acceptés (4 domaines, 2 bornes × 2) | `SetPolicy` ne lit pas domaines ni bornes (CODE ; base : 023) | 8 refus GARDE |
| P-358 | 01/10, `lot-2-brain` | 01/10 : **140 / 141** clés hors registre réglables au-delà du défaut ; après 023 : 0 acceptée, mais 141 refusées en `ERREUR` (la base refuse, le serveur ne traduit pas — V-169) | règle 2 au serveur (CODE) | 0 acceptée, 0 hors GARDE |
| P-359 | 01/10, `lot-2-brain` | 01/10 : SignPrestation → GARDE « aucun statut commercial actif d'ordre 1 » après réordonnancement (V-163) | le serveur lit `ordre` (CODE) ; la base a ses catégories depuis 023 | signature ok, société de catégorie client |

### Portes réécrites depuis le registre — « contredisait le registre » (V-164){nl}{nl}| Porte | Exigeait | Réécrite au commit | Maintenant | Décision |
|---|---|---|---|---|
| P-215 | une alerte `PROJET_AUTO` sous `automatique_au_retenu` — le registre : le projet est créé | B2, 10e audit | les lignes de `projet.creation_depuis_besoin`, jouées par le moteur de P-355 ; ✅ gardé, rouge tant que le serveur ne crée pas le projet | D-56 |
| P-230 | un refus de `taux_saisi` en devises mixtes — le registre : la conversion au taux saisi | B2, 10e audit | les lignes de `change.mode` ; rouge tant que D-63 n'est pas codé | D-56, D-63 |
| P-233 | qu'un temps hors prestation passe sous le mois ouvert — le registre : la valeur stricte AJOUTE une garde | B2, 10e audit | les lignes de `temps.periode` ; rouge tant que D-62 n'est pas codé | D-56, D-62 |

⚠️ Réécrites, pas retirées : le numéro garde sa place et son ✅ — elles n'étaient pas des doublons (D-41 ne s'applique pas) ; leur rouge est la vérité du serveur.

## ✅ P-352 — les valeurs servies (D-42, 29/09 ; renumérotée le 30/09, collision avec P-340 d'audit7)

⚠️ ✅ au tableau depuis `9137fbe` (greffe). Depuis 021 (30/09) elle est rouge « dans l'autre sens » : cinq valeurs servies en base que `COMPORTEMENTS` n'a pas encore — attendu jusqu'à ce que Grok les code (Q-014). Elle ne repasse pas ⏳ : elle n'était pas fausse.

| Porte | Posée | Vue rouge | Pourquoi ⏳ | Passe ✅ quand |
|---|---|---|---|---|
| P-352 | 29/09, `lot-2-brain` | 29/09 : « COMPORTEMENTS absent de server/src » | le serveur n'exporte pas encore sa table de dispatch (D-42, côté CODE) | `COMPORTEMENTS` = `politique_valeur_servie`, paire pour paire |


## ✅ P-339 — la porte croisée (D-36, 25/09) — LEVÉE le 30/09

⭐ 30/09 (10e tour, D-49) : **0 fuite** sur les 5 passes, 0 positif KO, 0 identifiant déclaré sans cas, 4 permis inter-agences sous `oui` → ✅ au tableau.

| Porte | Posée | Vue rouge | Pourquoi ⏳ | Passe ✅ quand |
|---|---|---|---|---|
| P-339 | 25/09, `lot-2-brain` | 25/09 : **17 fuites**, les 17 de l'audit 8 (V-138) | le serveur écrit des identifiants qu'il ne résout pas (D-37, côté CODE) | **0 fuite** sur les 55 commandes servies, 0 positif KO, 0 identifiant déclaré sans cas |

⛔ Une ⏳ qui tombe fait tomber `make test`, donc la case 1 du cliquet : c'est voulu (D-36). La porte
ne se retouche pas pour passer — `test/` en est la copie exacte du canon (case 14).

## ⛔ D-35 (24/09) — un ✅ retiré se DÉCLARE ici

Un ✅ ne redevient ⏳ que s'il était **faux**, et la ligne ci-dessous le dit. La case 9 lit **toute
l'histoire** de `journal/PORTES.md` sur la branche : un passage ✅ → ⏳ absent de ce tableau → KO.

| Porte | ✅ posé | ⏳ remis | Motif | Décision |
|---|---|---|---|---|
| P-062 · P-063 · P-064 · P-065 | `6dc1e89` (20/09) | `b2b7d1e` (21/09) | captures des écrans besoin : ✅ posé en masse avec les 55 portes de contrat, alors que ces écrans sont du **lot 3** et n'existent pas | D-35 — le ⏳ est la vérité, lot cible **3** |
| P-340 | `2b6299f` (25/09) | `419f7b2` (29/09) | collision de numéro, porte des valeurs servies renumérotée P-352 : le BRAIN CODE avait inscrit sa porte sous P-340, déjà pris par la porte d'audit7 (RES/STAF) ; la ligne ⏳ portait le même numéro. P-340 d'audit7 ne bouge pas et reste ✅ | décisions du 30/09 (arbitrage 9e audit), case 16 |

## ⛔ D-41 (25/09) — une porte ✅ RETIRÉE du tableau se déclare ici

Une porte ✅ ne sort du tableau que si elle était un **doublon** (même test, deux numéros) ; le test,
lui, reste sous l'autre numéro. La case 11 retire de ses « perdues » les seules portes de ce tableau,
et vérifie que le numéro gardé est bien ✅ dans HEAD. Une porte retirée sans ligne ici → KO.

| Porte retirée | Retirée au commit | Doublon de (gardée ✅) | Motif | Décision |
|---|---|---|---|---|
| P-333 | `5aefe26` (25/09) | P-326 | recopiée mot pour mot, un test portait les deux numéros | V-141, D-41 |
| P-334 | `5aefe26` (25/09) | P-327 | idem | V-141, D-41 |
| P-335 | `5aefe26` (25/09) | P-328 | idem | V-141, D-41 |
| P-336 | `5aefe26` (25/09) | P-329 | idem | V-141, D-41 |
| P-337 | `5aefe26` (25/09) | P-330 | idem | V-141, D-41 |
| P-338 | `5aefe26` (25/09) | P-331 | idem | V-141, D-41 |

</etat>

---

<source>

Née d'une contradiction constatée le 20/09 en lançant le cliquet moi-même : 6 cases OK, 2 KO,
et les deux KO étaient **attendus**. ⭐ Un contrôle qui tombe pour une raison prévue n'est plus
un contrôle — on apprend à ignorer sa couleur, et le jour où il tombe pour de vrai, personne ne
regarde.

⛔ **La contradiction était dans MA règle**, pas dans son code : j'ai écrit « le cliquet doit
sortir en 0 à chaque tour » et « la porte est posée avant d'être servie » sans voir qu'elles
s'excluent.

⭐ **Ce que ça enseigne** : deux règles justes séparément peuvent être fausses ensemble. Le seul
moyen de le voir, c'est de **lancer le contrôle soi-même** — pas de le relire.

</source>
