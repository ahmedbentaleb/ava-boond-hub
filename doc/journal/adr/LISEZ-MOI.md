# Les ADR de RÉALISATION — préfixe `ADR-R-`

⛔ **Deux dossiers d'ADR, deux préfixes, et ce n'est pas une coquetterie.**

| Dossier | Préfixe | Qui décide | Exemple |
|---|---|---|---|
| `_ops/adr/` | `ADR-000` … | la **conception** — le canon | ADR-007 : les filiales, pas maintenant |
| **`journal/adr/`** | ⭐ **`ADR-R-001`** … | la **réalisation** — pendant un lot | ADR-R-001 : le port Postgres de l'hôte |

⚠️ **Pourquoi on l'a séparé** : le 20/09, `ADR-007-filiales-pas-maintenant.md` et
`ADR-007-port-postgres-hote.md` existaient en même temps. ⛔ **Deux décisions différentes sous le
même numéro** — c'est le bug **A-007** du journal de l'auditeur général.

⭐ **Un numéro ne se réutilise jamais**, et deux séries qui se croisent finissent toujours par se
marcher dessus. Le `R` coûte une lettre et règle le problème pour de bon.
