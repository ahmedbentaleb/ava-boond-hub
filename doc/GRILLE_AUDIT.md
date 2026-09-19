# L2b — la grille d'audit

⭐ **Écrite AVANT qu'il code.** Une grille écrite après le code vérifie ce qu'il a fait, pas ce
qu'on voulait. Celle-ci ne discute pas.

**18 contrôles · 4 familles.** Un seul 🔴 refuse le lot entier.

---

<quand_utiliser>

| ✅ On la passe | ⛔ On ne la passe pas |
|---|---|
| À **chaque** rendu de Grok, sans exception | sur un bout de code montré en passant |
| Avant de dire « c'est bon » | pour juger du **goût** : ce n'est pas son objet |

⚠️ **On la passe en entier, même quand le premier contrôle tombe.** Renvoyer un bug à la fois
coûte dix allers-retours ; renvoyer la liste complète en coûte un.

</quand_utiliser>

---

## A · LA PREUVE — 4 contrôles. ⛔ Si A tombe, on ne lit pas la suite.

| # | Contrôle | Comment | Verdict si faux |
|---|---|---|---|
| **A1** | Les 22 assertions passent | `make up && make migrate && make test`, sortie 0 | 🔴 |
| **A2** | Elles **tombent** quand on casse un mur | retirer `tg_m10`, relancer : l'assertion M-10 doit lever | 🔴 — sinon elles ne testent rien |
| **A3** | La CI fait la même chose que moi | lire `.github/workflows/db.yml` | 🟠 |
| **A4** | Le compte correspond au registre §E | `python _ops/outils/dossier.py` ne crie pas | 🟠 |

⭐ **A2 est le contrôle que personne ne fait.** Une suite de tests verte qui reste verte quand on
casse le code est pire qu'aucune suite : elle donne confiance sans rien prouver.

---

## B · LE PARAMÉTRAGE — 5 contrôles. ⭐ C'est ici qu'une IA qui code se trompe.

| # | Contrôle | Comment | Verdict si faux |
|---|---|---|---|
| **B1** | Aucun `if` métier en dur | `grep -rnE "if .*(etat_code\|type_code\|categorie) *[=!]=" db/` | 🟠 chaque occurrence |
| **B2** | Les 167 politiques sont chargées | `SELECT count(*) FROM politique` = 167 | 🟠 |
| **B3** | `valeur` = `valeur_defaut` au seed | `WHERE valeur <> valeur_defaut` → 0 ligne | 🟠 |
| **B4** | Les 34 référentiels existent | `\dt ava.ref_*` en compte 34 | 🟠 |
| **B5** | Aucun CHECK sur un **code** de référentiel | `grep -n "CHECK (code" db/migrations/` → vide | 🔴 |

⚠️ **B1 attrape aussi les faux positifs** — un `if` sur un état dans un outil de migration n'est
pas du métier. ⭐ **Je lis chaque occurrence, je ne compte pas.** Un grep qui décide tout seul
finit par faire refuser du code juste.

---

## C · LES MURS — 5 contrôles, en plus des assertions.

| # | Contrôle | Comment | Verdict si faux |
|---|---|---|---|
| **C1** | Aucune colonne `tenant_id` | `grep -rn "tenant" db/` → vide | 🔴 ADR-000 |
| **C2** | Le rôle applicatif n'a aucun DELETE | la requête ci-dessous → 0 ligne | 🔴 M-8 |
| **C3** | `evenement_metier` et `snapshot_marge` sans UPDATE | idem | 🔴 M-6, M-7 |
| **C4** | Le rôle d'agrégats ne voit pas `prestation`, `temps`, `snapshot_marge` | idem | 🔴 M-15 |
| **C5** | Les 7 murs-triggers existent | `\dft ava.*` : M-4, M-6, M-7, M-10, M-12, M-14 + `ajout_seul` | 🔴 |

```sql
-- Ce que le rôle applicatif a le droit de faire. ⛔ Aucune ligne DELETE.
SELECT table_name, privilege_type
FROM information_schema.role_table_grants
WHERE grantee = 'ava_app' AND privilege_type = 'DELETE';
```

---

## D · LE DÉPÔT — 4 contrôles.

| # | Contrôle | Comment | Verdict si faux |
|---|---|---|---|
| **D1** | `_ops/` n'a pas bougé | `git diff --stat main -- _ops/` → vide | 🔴 le canon commande, il ne suit pas |
| **D2** | Aucun ORM | `grep -rniE "prisma\|typeorm\|sequelize\|drizzle\|knex" .` | 🔴 |
| **D3** | Les migrations sont numérotées et jamais réécrites | `git log --diff-filter=M -- db/migrations/` → vide | 🟠 |
| **D4** | `REMARQUES.md` existe, même vide | il doit dire « aucune » plutôt que manquer | 🟡 |

⭐ **D1 est le contrôle le plus important de la grille.** Le jour où le canon commence à suivre le
code, plus rien ne commande — et on ne s'en aperçoit que trois mois après.

---

<procedure>

**1.** Lancer la preuve (A1 → A4). ⛔ Si A1 ou A2 tombe : refus, on s'arrête là.

**2.** Passer B, C, D **en entier**, même si quelque chose est déjà tombé.

**3.** Écrire chaque 🔴 et 🟠 dans [JOURNAL_BUGS.md](JOURNAL_BUGS.md), **une ligne par bug**, avec
le numéro du contrôle.

**4.** Rendre le verdict en trois lignes, pas plus :

```
LOT 1 — REFUSÉ · 2 🔴 · 4 🟠
B5  un CHECK sur ref_etat_candidat.code — Boond ne pourra plus entrer
C2  ava_app a DELETE sur 6 tables
→ la liste complète : JOURNAL_BUGS.md, B-001 à B-006
```

**5.** Corriger **le prompt**, pas seulement le code. ⭐ Un bug qui revient deux fois est un bug
du prompt.

</procedure>

---

<interdits>

| ⛔ Jamais | Le problème que ça évite |
|---|---|
| Adapter une assertion pour qu'elle passe | c'est le code qui se plie au test, pas l'inverse |
| Accepter « 21 sur 22 » | un mur percé est un mur percé |
| Refuser sur le style, la mise en forme, les noms de fichiers | ce sont ses décisions ; les lui reprendre le rend inutile |
| Corriger son code moi-même | on ne saurait plus ce qu'il sait faire, et le prompt ne s'améliorerait jamais |
| Laisser un 🟠 sans ligne de journal | il revient au lot suivant, et personne ne se souvient |
| Compter un `grep` sans le lire | un grep qui décide tout seul fait refuser du code juste |

</interdits>

---

<etat>

**19/09/2026 — grille écrite, aucun lot encore audité.**

Le prompt qu'elle juge : [PROMPT_GROK_LOT1.md](PROMPT_GROK_LOT1.md).
Le journal qu'elle alimente : [JOURNAL_BUGS.md](JOURNAL_BUGS.md) — 0 ligne.

⏳ **Elle grandira.** Le lot 2 (les 44 commandes) ajoutera une famille **E — les contrats** :
un contrôle par commande, tirés de L4.

</etat>

---

<source>

Bâtie le 19/09/2026 sur trois sources : les **15 murs** (registre §A), **ADR-005** (tout ce qui
bifurque est une politique), et la méthode du skill `/audit-code` — un constat, une preuve
localisée, un verdict.

⭐ **Ce qu'elle cherche en premier, et pourquoi** : le `if` métier écrit en dur. Ce n'est pas de
la méfiance envers Grok — c'est que 99 % du code du monde fait comme ça, et qu'un modèle écrit
ce qu'il a lu. ⚠️ **ADR-005 est la chose la plus facile à perdre et la plus chère à retrouver.**

</source>
