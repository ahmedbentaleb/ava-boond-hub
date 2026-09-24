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
| **A-015** | 🔴 **critique** | ⛔⛔ **52 des 55 portes de contrat ne prouvent qu'un REFUS** : 40 « refuse INTROUVABLE », 10 « refuse DROIT », 2 « refuse GARDE » — et **3 seulement** vérifient qu'un objet est rendu. ⭐⭐ **Un serveur qui refuse tout passerait 52 portes sur 55.** 1 897 lignes de commandes, et rien ne prouve qu'elles **écrivent**. ⚠️ C'est le défaut d'A-001 qui revient : *un contrôle qui ne peut pas distinguer le juste du faux est vert pour rien*. Cliquet 10/10 vérifié par moi le 20/09, et il ne voit pas ça | `test/contrat/commandes.test.ts` · `journal/PORTES.md` | — | 20/09 |
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
| **« les 9 applications »** (B5 bis) | 🟠 | Migration **013** : `ref_famille_document` et ses 12 familles (70 → **71**), `document` et `signature` au type de modèle, les 7 politiques du §C.ter (194 → **201**), `celebrations` proposé aux widgets, et six tables — envoi d'e-mail (+ destinataires), document généré, lien Outlook, préparation de paie (+ lignes). ⭐ **Témoin** : jouée deux fois sans rien changer ; `lien_outlook` refuse deux fois le même (compte, outlook_id) ; une préparation figée refuse toute ligne | 24/09 | `8ac9066` |
| **V-111 · D-27** (B2, 5e tour) | 🟠 | `009_unite_agence.sql` devient `010_…` ; `schema_migrations` porte un **rang** unique et sa date ; `make migrate` refuse deux fichiers au même numéro, un nom sans `NNN_`, une migration du registre absente du dépôt, et un fichier hors rang. ⭐ **Témoin** : les quatre refus mesurés, dépôt intact → « migrations à jour » | 24/09 | `9f5281d` |
| **V-112 · V-113 · D-28 · D-29** (B3 B4 B7) | 🟠 | Cliquet **case 13** (`merge-base --is-ancestor lot-2-brain HEAD`, KO motivé si la référence manque) ; `outils/verif_trailers.sh` joué par la CI ; `design` admis par le crochet. ⭐ **Témoin** : branche hors lignée → KO ; référence absente → KO motivé ; commit sans trailer, `Role:` inconnu, `test/` en `Role: serveur` → KO ; `Role: design` accepté. ⚠️ `outils/TRAILERS_DEPUIS` : 26 commits antérieurs comptés, pas bloquants | 24/09 | `a1cb482` |
| **V-108 · V-114 · D-25** (B1) | 🔴 | Migration **011** : `societe.agence_responsable_id`, `contact.agence_responsable_id` et `profil_candidat.agence_id` remplies (manager → créateur → agence par défaut) puis **NOT NULL** ; politique `societe.perimetre.mode`. ⭐ **Témoin** : trois sociétés fabriquées → CAS, CAS, PAR ; rejouée sans rien changer ; une ligne sans agence est refusée | 24/09 | `f3f8915` |
| **« tout en V1 »** (B5) | 🟠 | Migration **012** : 30 référentiels neufs semés aux valeurs de Boond (40 → **70**), 20 politiques neuves (→ **194**, toutes à leur défaut), les colonnes du §13.1/§13.5, les 20 tables neuves, le n° de sécurité sociale **chiffré** sous `LireDonneesRHSensibles`, et deux vues (CJM du contrat, CA pondéré). ⭐ **Témoin** : jouée deux fois sans rien changer ; clés du registre = clés de la base | 24/09 | `3224da5` |
| **M-16 · M-17 · M-18** (B6) | 🟠 | Trois murs neufs et leurs assertions (plancher 32 → **40**) : facture émise immuable, contrats RH sans chevauchement (EXCLUDE), numérotation continue par compteur. ⭐ **Témoin** : chaque mur saboté (trigger désactivé, contrainte retirée) fait lever l'assertion ; base intacte, 40 OK | 24/09 | `7d0d0a9` |
| **V-096 · D-20** (B1, 4e tour) | 🔴 | Le cliquet refait la base (`make.sh reset` puis `test`) et l'annonce ; `AVA_RAPIDE=1` garde le chemin court en le disant. ⭐ Et la case 11 du 23/09 relisait le tableau porte par porte pour chaque commit (280 × 290 `grep`) : le cliquet semblait bloqué (> 300 s) — même mesure en une passe, **42 s**. ⭐ **Témoin** : base neuve → case 1 **KO** (P-207) ; base gardée avec la ligne `categorie='europe'` d'un tour antérieur → **12/12** ; chemin par défaut sur la même base → base refaite, case 1 **KO** | 23/09 | `d3fbde2` |
| **V-104 · D-22** (B2) | 🟠 | Migration **009** : `unite_organisation.agence_id` rempli (manager de la société → compte créateur dans l'historique → agence par défaut) puis `NOT NULL`. ⛔ `unite_arbre()` (001, D-1) **refusait** une agence sur une unité cliente : la fonction est remplacée dans 009. Assertions : plancher 31 → **32** (une unité sans agence est refusée). ⭐ **Témoin** : 14 unités sans agence → **0**, colonne NOT NULL, migration rejouée sans rien changer | 23/09 | `ef4eb4a` |
| **V-101 · D-24** (B3) | 🟡 | `test/contrat/outils.test.ts` : **P-299** (le `\set ON_ERROR_STOP` en tête du canon ET de la copie, copie = canon) et **P-300** (`verif_serveur.sh` refuse la configuration ouverte et nomme le motif ; poste de dev déclaré, il accepte). ⭐ **Témoin** : sabotage U6 → P-287 tombe ; U7 (`verif_serveur.sh` rend 0 quoi qu'il voie) → P-288 tombe ; outils rendus → les deux repassent | 23/09 | `55fa4d1` |
| **V-077 · D-17** (B1, 3e tour) | 🟠 | Cliquet case 11 : la fenêtre va de `git merge-base main HEAD` à HEAD (tous les commits de la branche, plus `main`) ; « porte exécutée absente du tableau » devient un **KO**. ⭐ **Témoin** : 70 portes P-2xx effacées **dans un commit** + un commit de plus, `make test` réel — ancien cliquet **12/12 vert** (⚠️ seulement) → nouveau **KO case 11** ; arbre intact → **12/12** | 23/09 | `3c6cdd6` |
| **V-087 · D-18** (B2) | 🟡 | `\set ON_ERROR_STOP on` en tête de `_ops/SPEC_ASSERTIONS_L7.sql`, copie exacte dans `test/`. ⭐ **Témoin** : `tg_m10` désactivé, fichier joué **sans** le drapeau — avant **rc=0** (18 OK sur 31), après **rc=3** ; base intacte : rc=0, 31 OK | 23/09 | `87ef942` |
| **V-093 · K5** (B3) | 🟡 | `outils/verif_serveur.sh` : `pg_hba_file_rules`, `listen_addresses`, mot de passe et pouvoirs de `ava_serveur`, rôles de droits NOLOGIN. Hors cliquet (poste de dev en `trust` assumé, V-022) ; K5 le cite. ⭐ **Témoin** : sur le poste → **rc=1**, 6 règles `trust`, écoute `*`, `ava_serveur` sans mot de passe ; avec `AVA_POSTE_DEV=1` → rc=0, les trois passent en ⚠️ déclarés | 23/09 | `924c347` |
| **V-050** (B1, 2e tour) | 🔴 | Cliquet case 11 (F12) : le tableau est comparé à HEAD, HEAD~1 et `main` ; une porte ✅ perdue → KO ; une porte exécutée hors tableau est signalée. ⭐ **Témoin** : P-150 → P-153 retirées, `make test` réel : ancien cliquet **10/10** → nouveau **KO** case 11 ; tableau intact → **11/11** | 22/09 | `3f7dfed` |
| **V-060 · D-13** (B2) | 🟠 | `outils/installer.sh` pose `core.hooksPath` ; `commit-msg` exige `Role: banc` sur `test/` (brain/integrateur en fusion, brain pour la seule copie canon) ; case 12 du cliquet. ⭐ **Témoin** : clone neuf → case 12 **KO** → `installer.sh` → **OK** ; `Role: serveur` sur `test/` refusé | 22/09 | `00fae39` |
| **V-053 · V-058 · D-11 · D-12** (B3) | 🟠 | Migration **008** : comptes `@ava.test` désactivés, périmètre `soi`, les 3 cases S de RES en `soi` ; fixture `db/fixtures/banc.sql` chargée par `make test` seulement. ⭐ **Témoin** : 001→007 = **9** comptes de banc actifs, 3 cases S sur l'agence → 008 = **0** actif, 3 en `soi` ; rejouée : identique ; + fixture : 9 actifs, RES lié, portes **vertes** | 22/09 | `b37b874` |
| **V-070** (B4) | 🟡 | Assertions M-12 sur `contact` et sur `projet` (plancher 29 → 31), copie exacte dans `test/`. ⭐ **Témoin** : `DISABLE TRIGGER tg_m12` sur contact puis projet : anciennes **rc=0** → nouvelles **rc=3** | 22/09 | `5fbf7b4` |
| **V-051** (B5) | 🟠 | `make.sh` exporte `DATABASE_URL` = la base choisie, et refuse une URL qui vise une autre base. ⭐ **Témoin** : `AVA_DB=ava_brain`, portes sur `ava` (défaut de `db.ts`) → sur `ava_brain` ; cliquet réel sans `DATABASE_URL` dans l'environnement : P-066 ✔, 246 événements dans `ava_brain` | 22/09 | `7e10553` |
| **V-039** (B6) | 🟡 | CI : service `postgres:16`, mots de passe en secrets GitHub (`CI_POSTGRES_PASSWORD`, `CI_SERVEUR_PASSWORD`), `ava_serveur` avant les migrations, `installer.sh`, puis le cliquet. ⭐ **Témoin** : lecture — 0 → 1 service, 0 → 7 secrets, 0 mot de passe en clair ; ⚠️ exécution au premier push, secrets à poser | 22/09 | `47fd932` |
| **V-012 · V-001** (B1) | 🔴 | Assertions par PRIVILÈGE pour M-6 M-7 M-8 M-15, sur toutes les relations ; `test/` = copie exacte de `_ops/` ; plancher compté dans le fichier (29), plus écrit en dur. ⭐ **Témoin** : ROUGE sur `ava_brain` avant 007 (M-15 FAUX, rc=3) ; sabotages de l'audit (`GRANT UPDATE evenement_metier`, `UPDATE prestation_version`, `TRUNCATE`) : ancienne rc=0 → nouvelle rc=3 | 21/09 | `c9b3067` |
| **V-001 · V-002 · V-027 · V-021** (B2) | 🔴 | Migration **007** : M-15 par `REVOKE ALL` + GRANT de §14 ; rôle LOGIN `ava_serveur` membre d'`ava_app`, sans superutilisateur ni mot de passe ; `tentative_refusee` écrivable ; D-9 : trois CHECK → `ref_*`. ⛔ **A-001 était fermé à tort** (canon corrigé, base jamais) : refermé ici pour de vrai. ⭐ **Témoin** : assertions ROUGE → **VERT 29/29** ; 007 jouée deux fois sans lever ; sabotée au milieu → 0 table, 0 FK, rien de marqué | 21/09 | `aa4da72` |
| **V-008 · V-009** (B3) | 🔴 | Cliquet : case 1 exige `make_rc = 0` **et** chaque ✅ exécutée ; cases 3 et 9 numéro par numéro, colonne État trouvée par son en-tête ; `main` introuvable = KO ; CI en `fetch-depth: 0` + `main` local ; `make.sh` à deux URL (migrations `postgres`, serveur `ava_serveur`). ⭐ **Témoin** (scripts de l'audit) : serveur mort → case 1 OK → **KO** (exécutées 1/64) ; P-002…P-005 retirées → case 3 OK → **KO** | 21/09 | `5f9427b` |
| **V-023 · V-024 · V-029** (B4) | 🟠 | Canon : D-3 → D-8 portés dans L4, MACHINES, MATRICE ; registre dédoublonné, comptage = 172 + 1 = 173 = base ; grille corrigée (A1 A3 B1 B2 B4 C2 C4 F3 F6) ; jeu d'essai ne vide plus les droits ; lot 2c inscrit au plan. ⭐ **Témoin** : après chargement du jeu, `CreateCompany` par IA → `DROIT` (ancien) → **créée** (nouveau, en `ava_serveur`) | 21/09 | `2cf7300` |
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
