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
