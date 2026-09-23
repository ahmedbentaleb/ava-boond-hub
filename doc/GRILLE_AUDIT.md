# L2b — la grille d'audit

⭐ **Écrite AVANT qu'il code.** Une grille écrite après le code vérifie ce qu'il a fait, pas ce
qu'on voulait. Celle-ci ne discute pas.

**42 contrôles · 7 familles** (A → F, et K l'accès depuis le 22/09). Un seul 🔴 refuse le lot entier.

⭐ **Je suis l'auditeur GÉNÉRAL** : je passe sur le lot rendu. L'auditeur **interne** (sous-agent 4) passe **entre chaque étape**. Deux mailles, pas deux chefs.

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

## A · LA PREUVE — 5 contrôles. ⛔ Si A tombe, on ne lit pas la suite.

| # | Contrôle | Comment | Verdict si faux |
|---|---|---|---|
| **A1** | Toutes les assertions passent | `make up && make migrate && make test`, sortie 0 ; autant de lignes `OK   M-` que `bash outils/plancher_assertions.sh _ops/SPEC_ASSERTIONS_L7.sql` en compte, et `test/` = `_ops/` (`cmp`) *(V-012, 21/09 : le nombre ne s'écrit plus, il se compte)* | 🔴 |
| **A2** | Elles **tombent** quand on casse un mur | retirer `tg_m10`, relancer : l'assertion M-10 doit lever | 🔴 — sinon elles ne testent rien |
| **A3** | La CI fait la même chose que moi | lire `.github/workflows/ci.yml` : `fetch-depth: 0`, `main` en local, puis `bash outils/cliquet.sh` *(V-023 : `db.yml` n'existe pas)* | 🟠 |
| **A4** | Le compte correspond au registre §E | `python _ops/outils/dossier.py` ne crie pas — ⚠️ **dans le clone de l'audit seulement** : il réécrit `_ops/DOSSIER.html` *(V-065)* | 🟠 |
| **A5** | Les fiches de l'auditeur interne existent | une par étape, 5 pour le lot 1, dans `/audit/` | 🟠 |

⭐ **A2 est le contrôle que personne ne fait.** Une suite de tests verte qui reste verte quand on
casse le code est pire qu'aucune suite : elle donne confiance sans rien prouver.

---

## B · LE PARAMÉTRAGE — 5 contrôles. ⭐ C'est ici qu'une IA qui code se trompe.

| # | Contrôle | Comment | Verdict si faux |
|---|---|---|---|
| **B1** | Aucun `if` métier en dur | `grep -rnE "(etat_code\|type_code\|statut_code\|categorie\|_code) *(===?\|!==?) *['\"\`]" server/src web/src` puis `grep -rnE "if .*(etat_code\|type_code\|categorie) *[=!]=" db/` *(V-023 : les `if` sont dans `server/` et `web/`, pas dans `db/`)* | 🟠 chaque occurrence |
| **B2** | Toutes les politiques sont chargées | `SELECT count(*) FROM politique` = le compte du **registre §E** — ⛔ ne pas recopier le chiffre ici | 🟠 |
| **B3** | `valeur` = `valeur_defaut` au seed | `WHERE valeur <> valeur_defaut` → 0 ligne | 🟠 |
| **B4** | Tous les référentiels existent | `\dt ava.ref_*` = le compte du **registre §E** — ⛔ ne pas recopier le chiffre ici | 🟠 |
| **B5** | Aucun CHECK qui fige une **liste de codes** métier | `grep -niE "CHECK *\(.*_code *(IN\|=)" db/migrations/*.sql` — chaque ligne doit être justifiée au registre (ex. `perimetre.type_code`, D-9) *(V-065 : l'ancien grep donnait un faux 🔴)* | 🔴 non justifiée |

⚠️ **B1 attrape aussi les faux positifs** — un `if` sur un état dans un outil de migration n'est
pas du métier. ⭐ **Je lis chaque occurrence, je ne compte pas.** Un grep qui décide tout seul
finit par faire refuser du code juste.

---

## C · LES MURS — 5 contrôles, en plus des assertions.

| # | Contrôle | Comment | Verdict si faux |
|---|---|---|---|
| **C1** | Aucune colonne `tenant_id` | `grep -rn "tenant" db/` → vide | 🔴 ADR-000 |
| **C2** | Le rôle applicatif n'a ni DELETE ni TRUNCATE, et le serveur se connecte en `ava_serveur` (pas en superutilisateur) | la requête ci-dessous → 0 ligne ; `pg_stat_activity` du serveur = `ava_serveur` | 🔴 M-8, V-002 |
| **C3** | `evenement_metier` et `snapshot_marge` sans UPDATE | idem | 🔴 M-6, M-7 |
| **C4** | Le rôle d'agrégats n'atteint QUE les 4 vues par devise + `ref_devise`, `ref_pays`, `politique` | mesuré sur **toutes les relations** du schéma (requête ci-dessous) — ⛔ jamais une liste de noms interdits *(V-001 : le mur fuyait par `v_conditions_du_jour`)* | 🔴 M-15 |
| **C5** | Les 7 murs-triggers existent | `\dft ava.*` : M-4, M-6, M-7, M-10, M-12, M-14 + `ajout_seul` | 🔴 |

```sql
-- ⭐ Par ce qu'on ATTEINT (has_table_privilege), pas par ce qu'on a écrit :
--    information_schema ne voit ni l'héritage, ni PUBLIC, ni les colonnes.
-- C2 / C3 — ⛔ aucune ligne.
SELECT c.relname, p.priv
FROM pg_class c JOIN pg_namespace n ON n.oid = c.relnamespace,
     unnest(ARRAY['DELETE','TRUNCATE']) AS p(priv)
WHERE n.nspname = 'ava' AND c.relkind IN ('r','v','m','p','f')
  AND has_table_privilege('ava_app', c.oid, p.priv)
UNION ALL
SELECT c.relname, 'UPDATE' FROM pg_class c JOIN pg_namespace n ON n.oid = c.relnamespace
WHERE n.nspname = 'ava' AND c.relname IN ('evenement_metier','snapshot_marge','prestation_version')
  AND has_table_privilege('ava_app', c.oid, 'UPDATE');

-- C4 — ⛔ exactement 7 lignes : politique, ref_devise, ref_pays et les 4 vues v_*_par_devise.
SELECT c.relname FROM pg_class c JOIN pg_namespace n ON n.oid = c.relnamespace
WHERE n.nspname = 'ava' AND c.relkind IN ('r','v','m','p','f')
  AND has_any_column_privilege('ava_lecture_agregats', c.oid, 'SELECT')
ORDER BY 1;
```

---

## K · L'ACCÈS — 5 contrôles. ⛔ Ajoutée le 22/09 (V-059) : l'accès peut casser sans qu'aucune autre famille ne rougisse.

| # | Contrôle | Comment | Si ça échoue |
|---|---|---|---|
| **K1** | Hors `AVA_MODE=banc`, **aucune route ne répond** sauf `/sante` — ⛔ **les vues de lecture comprises** | serveur sans `AVA_MODE` : `POST /commandes/*` **et** `GET /vues/*` → 401, 0 ligne écrite, 0 ligne rendue, rien tracé *(V-075, D-14, 23/09 : une vue ouverte livrait 81 besoins)* | 🔴 |
| **K2** | Une session n'est jamais l'identifiant d'un compte | envoyer l'UUID d'un compte comme session → refus ; le jeton est aléatoire, haché, expirant (D-10) | 🔴 |
| **K3** | Un compte désactivé ne fait rien | sa session → refus, 0 écriture | 🔴 |
| **K4** | Le périmètre se juge **sur l'objet visé**, et se **lit** au lieu de s'appeler | la table `commande → table → colonne d'agence` existe et couvre les 55 ; une commande sans sa ligne est refusée ; par commande : un cas hors agence → `DROIT`, 0 écriture *(V-076, D-15 : `crm.ts` n'avait aucune garde)* | 🔴 |
| **K5** | La base n'accepte personne sans mot de passe hors poste de dev | `bash outils/verif_serveur.sh` sur le serveur : 0 `trust`, `listen_addresses` borné, `ava_serveur` avec mot de passe — ⚠️ pas dans le cliquet : le poste de dev est en `trust` assumé *(V-093)* | 🔴 V-022 (T3) |

## D · LE DÉPÔT — 5 contrôles.

| # | Contrôle | Comment | Verdict si faux |
|---|---|---|---|
| **D1** | `_ops/` n'a pas bougé | `git diff --stat main -- _ops/` → vide | 🔴 le canon commande, il ne suit pas |
| **D2** | Aucun ORM | `grep -rniE "prisma\|typeorm\|sequelize\|drizzle\|knex" package.json */package.json` | 🔴 |
| **D3** | Les migrations sont numérotées et jamais réécrites | `git log --diff-filter=M -- db/migrations/` → vide | 🟠 |
| **D4** | `REMARQUES.md` existe, même vide | il doit dire « aucune » plutôt que manquer | 🟡 |
| **D5** | Chaque dossier n'a qu'un seul auteur | chaque commit porte un trailer `Role:` ; un commit qui touche `test/` porte `Role: banc`, et le crochet le refuse sinon *(V-060, 22/09 : un seul compte git, c'est le trailer qui mesure)* | 🟠 |

⭐ **D1 est le contrôle le plus important de la grille.** Le jour où le canon commence à suivre le
code, plus rien ne commande — et on ne s'en aperçoit que trois mois après.

---

## E · L'ÉCRAN — 5 contrôles. ⛔⛔ La règle qui ne bouge jamais.

> **Hamada :** « Jamais patcher le front. Jamais, jamais, jamais, jamais. »

| # | Contrôle | Comment | Verdict si faux |
|---|---|---|---|
| **E1** | Aucun `if` sur un état métier dans `/web` | `grep -rnE "(etat\|statut\|categorie)[a-zA-Z_]* *[=!]==" web/src/` | 🔴 chaque occurrence |
| **E2** | Aucun calcul d'argent dans `/web` | `grep -rnE "marge\|tjm *\*\|cjm\|\* *jours\|/ *100" web/src/` | 🔴 |
| **E3** | Aucun libellé d'état écrit en dur | `grep -rn "Signée\|Prévisionnelle\|À pourvoir" web/src/` → vide | 🟠 le serveur envoie le libellé |
| **E4** | `/web` n'importe rien de `/server` ni de `/db` | `grep -rn "from .*\.\./server\|/db/" web/src/` → vide | 🔴 |
| **E5** | Aucun ORM ni SQL dans `/web` | `grep -rniE "SELECT \|INSERT \|pg" web/src/` → vide | 🔴 |

⭐ **E1 et E2 attrapent la même faute par deux bouts.** Un agent Écran bloqué écrira
`if (etat === 'signee')` pour débloquer l'affichage — c'est le `if` métier en dur, déplacé de
l'autre côté du fil. ⛔ **Et la correction n'est jamais dans l'écran** : on renvoie au serveur.

⚠️ **Ce que E3 n'attrape pas** : un libellé traduit dans un objet `const LABELS = {...}`. ⭐ Je
lis `/web/src` une fois, à l'œil, à chaque lot — c'est ce qu'aucun grep ne remplace.

---

## F · LE CLIQUET — 11 contrôles (F1 → F11). ⛔⛔ Plus important que l'audit lui-même.

> **Hamada :** « On ne doit plus faire marche arrière. On avance et on ne recule pas. »

| # | Contrôle | Comment | Verdict si faux |
|---|---|---|---|
| **F1** | `/journal/PORTES.md` existe et est à jour | une ligne par porte : numéro, description, espèce, vue rouge quand | 🔴 |
| **F2** | Les **quatre espèces** tournent | base · contrat · geste · **écran** | 🔴 — l'écran est celle qu'on oublie |
| **F3** | ⭐ **Les portes SERVIES n'ont pas baissé** | **numéro par numéro** : chaque porte servie sur `main` existe dans HEAD — l'état se lit dans la colonne « État » trouvée par son en-tête ; sans cette colonne, toute porte de `main` est servie *(V-009 : un compte de `main` sans colonne valait 0)* | 🔴 **le contrôle du cliquet** |
| **F10** | ⛔ **Aucune porte n'est passée de ✅ à ⏳** | numéro par numéro, pas par compte | 🔴 — c'est le `skip` avec un joli symbole |
| **F11** | Aucune **⏳** au-delà de son **lot cible** | chaque `⏳` porte le lot où elle doit passer ✅ | 🟠 une ⏳ sans échéance est un parking |
| **F4** | Aucune porte désactivée, commentée, ou en `skip` | `grep -rniE "skip\|todo\|xit\|\.only\|disabled" test/` | 🔴 |
| **F5** | Chaque porte a été **vue rouge** | la colonne du journal est remplie, avec la date | 🟠 |
| **F6** | `/outils/cliquet.sh` existe et **mesure** | le lire : aucune case ne se déclare, toutes se calculent ; ⭐ la case 1 exige `make_rc = 0` **et** que chaque porte ✅ ait été **exécutée** (un serveur mort ne produit aucune ligne d'échec — V-008) | 🔴 |
| **F7** | Il est branché en **pre-push** | `git config core.hooksPath` vaut `.githooks` — posé par `bash outils/installer.sh`, et la case du cliquet le vérifie *(V-060)* | 🟠 |
| **F8** | La CI relance **le même** script | `.github/workflows/` appelle `cliquet.sh`, pas une copie | 🔴 — deux copies divergent |
| **F9** | Le script ne s'arrête pas à la première case | il imprime **toutes** ses cases même après un échec *(V-065)* | 🟠 |
| **F13** | ⛔ **La branche auditée descend de `lot-2-brain`** | `git merge-base --is-ancestor lot-2-brain HEAD` → vrai. Sinon les correctifs du BRAIN ne sont pas dans ce qu'on audite, et l'audit les déclare ouverts *(posé le 23/09 au soir : deux tours de suite ont commencé par ce faux départ)* | 🔴 on n'audite pas |
| **F12** | ⭐ Une porte ✅ **de la branche** ne disparaît pas | le `PORTES.md` de HEAD contient toutes les ✅ du commit précédent **et** de `main` ; une porte exécutée absente du tableau est signalée *(V-050)* | 🔴 |

⭐⭐ **F3 compte les portes SERVIES, pas le total** — voir [PORTES_EN_ATTENTE.md](PORTES_EN_ATTENTE.md).
⚠️ Une porte **⏳** est posée et vue rouge, mais le code ne la sert pas encore : **elle ne
protège rien**, et la compter serait se mentir sur ce qui est verrouillé.

⭐ **F3 est le seul contrôle qui mesure le cliquet.** Tout le reste dit si le code d'aujourd'hui
est juste ; F3 dit si celui d'hier tient encore. ⛔ Une porte de moins qu'au lot précédent, sans
ADR : refus, sans discussion.

⭐ **F6 est le contrôle qui décide si le hook sert à quelque chose.** Une case qu'un agent coche
en tapant « oui » ne vaut rien — un agent fatigué coche tout. ⛔ **Le hook lance les commandes et
lit les résultats ; il ne pose aucune question.**

⚠️ **Et je ne le prends jamais pour un mur** : `git push --no-verify` le contourne. Le hook donne
la réponse en 30 secondes, **la CI est le vrai mur** — d'où F8. Un garde-fou qu'on croit plus
solide qu'il n'est vaut moins qu'un garde-fou absent : on cesse de faire attention.

⚠️ **F4 attrape la désactivation polie.** Personne n'écrit « je retire cette porte » — on écrit
`test.skip`, « le temps de livrer ». C'est ainsi que les cliquets se perdent, partout.

---

<procedure>

**1.** Lancer la preuve (A1 → A5). ⛔ Si A1 ou A2 tombe : refus, on s'arrête là.

**2.** Passer **F en premier** — le cliquet prime. Puis B, C, D, E **en entier**, même si
quelque chose est déjà tombé.

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

⏳ **Elle grandira.** Le lot 2 (les 44 commandes) ajoutera une famille **F — les contrats** :
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
