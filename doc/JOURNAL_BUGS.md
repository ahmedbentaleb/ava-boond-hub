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
| **Q-023 · Q-024** (registre `2835c73`) | 🟡 | La porte différentielle régénérée : **S-DR1** écrit (une ligne `compte_surcharge` du demandeur sur `UpdateNeed` / PAR, sans colonne de sens), **S-NE3** (note 3) ajouté. ⭐ **Témoin** : 206 lignes, 96 scénarios tous écrits ; P-355 **33** lignes fausses (35) — `candidat.note.echelle` et `droits.surcharge_restrictive` tiennent ; P-356 : la paire du registre `1_5 = aucune` disparaît ; 023 inchangée (bloc généré = registre) | 02/10 | `e099cc0` |
| **D-56** (B1, 12e tour) | 🔴 | **Le lecteur du registre exécutable** (`outils/registre_executable.mjs`, sans dépendance) : lignes, scénarios, domaines, bornes, alias ; refuse ce qui sort de la grammaire du §0. Seule source de `politique_valeur_servie` (`--sql`), de la case 20 (`--verifier`) et des cas de porte. ⭐ **Témoin** : 56 clés, 204 lignes, 95 scénarios ; une copie avec « refus GARD » et un scénario S-BC9 non défini → **refusée**, les deux fautes nommées | 01/10 | `e22fafb` |
| **D-56 · V-162 · V-164** (B2) | 🔴 | **La porte différentielle**, générée : chaque scénario en fixture, joué sous chaque valeur de sa clé, jugé contre le registre (P-355) ; règle 3 au registre et à l'observé (P-356) ; domaines et bornes (P-357) ; clé absente → défaut seul (P-358). P-215, P-230, P-233, qui exigeaient l'inverse du registre, réécrites depuis lui. ⭐ **Témoin** lot-2 : P-355 **ROUGE**, 58 lignes sur 204, dont 5 des 6 valeurs de V-162 (le ⑤ tient déjà) — ⚠️ dont 7 dues à MES fixtures (référence de projet hors numérotation, corrigée au B4) : **35** après 023 et la correction ; P-356 **ROUGE** (13 paires, dont **1 au registre** : `1_5` = `aucune`) ; P-357 **ROUGE** 8/8 acceptés ; P-358 **ROUGE** 140/141 ; P-215, P-230, P-233 **ROUGES** | 01/10 | `4764b64` · `838b9c9` |
| **D-57 → D-67 · V-163 · V-167** (B3) | 🔴 | **Migration 023** : `politique_valeur_servie` régénérée du registre (140 couples + 147 défauts), domaines et bornes en base, garde pour tout type ; catégories du statut commercial ; `temps.mois_ouvert.grace_jours` (203) ; `temps.derogation_motif`, `prestation.taux_change`, `snapshot_marge.taux_change`, `motif_sans_marge` ; `doublon.personne.cles` sans `score_pondere` ; `ava.aujourdhui(agence)` au fuseau de l'agence, `horloge_banc` vidée à chaque migrate, vues d'horloge sur elle. **Case 20** : table = registre. **P-359** : réordonner les statuts. ⭐ **Témoins** : `count(*) politique` = **203** ; case 20 sans 023 → **KO** (59 manquants, 204 en trop), une ligne retirée → KO, remise → OK 287 ; P-359 sur lot-2 → **ROUGE** « aucun statut commercial actif d'ordre 1 » ; P-355 58 → 44 lignes fausses après 023 | 01/10 | `bc5bb97` · `8b37116` · `b472dfe` (canon des assertions : catégorie du statut) |
| **V-156 · V-165 · V-170 · V-176 · V-177** (B4) | 🟠 | **V-176** : le crochet refuse `Role: banc` sur `_ops/`, case 21 (exception nommée : `e9476b8`). **V-177** : colonnes de PORTES.md lues par leur en-tête (cases 5, 10). **V-156** : `make test` pose des délégations témoins « humaines » (seed de PAR recopié sur MRS, que nulle porte ne vise) avant la photo ; la case 17 voit enfin un effacement. **V-165** : porte croisée — attendu calculé par ligne (partagee, par_besoins D-58, inter D-49), « PERMIS » n'est plus un verdict, positifs jugés sous toutes les passes, acteur au seul droit sur LYO (D-59), empreinte d'une commande acceptée lue par sa transaction ; `id` de Validate/RejectTimesheet pointé (V-171). **V-170** : P-325 sans fichier exclu, P-360 (noms d'`Object.prototype`), P-361 (routes = LECTURES). ⭐ **Témoins** : case 21 OK → KO sans l'exception, commit Role: banc sur _ops/ refusé ; cases 5 et 10 identiques sur colonnes permutées ; case 17 KO (EVAL SetOwnTheme effacée) → OK 0 / 246 ; P-339 rouge et JUGÉE (1 fuite par_besoins, 13 + 63 positifs refusés DROIT : D-58, D-59 au serveur) ; P-360, P-361 ROUGES (500 sur constructor ; /tuyau, /acquitter hors LECTURES) ; P-325 rouge sur assurerBancRes (compte.personne_id sans droit) | 01/10 | `84c456b` · `e35b226` · `0b6e96e` |
| **D-50 → D-55** (B1, 11e tour) | 🟠 | **Migration 022** : cycle `temps` (`ref_etat_temps`, `temps.etat_code` FK NOT NULL **sans défaut**, lignes existantes → `valide`, `motif_rejet`), `projet.validation_temps`, exception tracée de la ressource (CHECK ensemble ou rien), vues d'horloge `v_ressource_etat` et `v_societe_statut` (D-53, calculées à la lecture), `ValidateTimesheet`/`RejectTimesheet` au DP, `RequalifyCompany` à STAF, 8 valeurs servies. ⭐ **Témoins** : `ref_*` = **75** ; P-353 **verte** avec STAF ; vue d'état : prestation `engage` couvrant aujourd'hui → **en_mission**, sinon **disponible** (sans prestation, finie hier, prévisionnelle) ; exception du jour → en_mission, échue → disponible ; client sans engagement depuis le délai → **prospect**. ⚠️ Rouges attendus jusqu'au code de Grok : P-352 (8 valeurs absentes de `COMPORTEMENTS`), P-325 (6 colonnes accordées que le code n'écrit pas encore), `RecordTimesheet` (n'écrit pas `etat_code`) | 01/10 | `b2153de` |
| **Q-014 · Q-015 · D-48** (B1, 10e tour) | 🟠 | **021** sert les 5 valeurs codées (manuel, taux_saisi, dates_prestation_et_mois_ouvert, par_dp, derive_des_prestations ; 018 non réécrite) et donne au DP `RequalifyCompany` + `DeclareNeedFilled` sur son périmètre. **P-353** : pour chaque cascade de `CASCADES`, tout titulaire de la mère au seed (`<base>_modele`, migrée de zéro) a les filles — la mère qui exige un autre droit pour cascader (`aLeDroit` de son corps) n'oblige que ses titulaires complets : STAF (CreatePrestation sans SignPrestation) exempté, nommé. La fixture n'accorde plus rien : `make test` l'applique sur une copie du seed et compte (**case 19**). ⭐ **Témoin** : sans 021 → P-353 **ROUGE** (4 manques DP), fixture **2 droits hors seed** ; avec → **verte**, **0** | 30/09 | `4fa0a37` · `1cfbd3a` |
| **Q-016 · D-49** (B2) | 🔴 | **Porte croisée** : `RequalifyCompany` a ses cas `contact_id`, `besoin_id` ; sous `staffing.inter_agences=oui`, un profil d'une autre agence (lecteurs `inter`) sur un besoin/projet de l'agence → **PERMIS attendu** (refusé → rouge) ; le même profil + un besoin/projet d'une autre agence → **refus attendu**. ⭐ **Témoin** : make test → P-339 **VERTE**, 0 fuite sur les 5 passes, complète, 4 permis, 4 cas « + besoin/projet » refusés → **✅ au tableau** ; serveur saboté dans un clone (tout staffing passe sous `oui`) → **ROUGE, 7 fuites**, dont les 3 nouveaux cas | 30/09 | `2677999` · `af6e13b` |
| **P-340 en double** (B3) | 🟡 | La porte des valeurs servies du BRAIN CODE portait P-340, déjà pris (audit7, RES/STAF) : renumérotée **P-352** ; passage P-340 ✅ (`2b6299f`) → ⏳ (`419f7b2`) déclaré au tableau D-35, motif « collision de numéro ». ⚠️ Les cases 14 et 16 ne lisaient pas la sortie TAP de `node --test` (14 : un `` devenu octet 0x08 au 9e tour) : corrigées. ⭐ **Témoin** : sortie d'avant → case 16 **KO** « P-340 dans plusieurs titres » ; après → case 9 OK (5 retours D-35), 16 OK (340 titres, après le titre de P-143), 14 OK P-339 | 30/09 | `0fe3954` · `f36d460` · voir log |
| **V-149 · D-44** (B1, 9e tour) | 🔴 | **Porte croisée jouée sous chaque valeur de périmètre** : politiques lues dans `agence.ts` (`pol(ctx, …)`), valeurs dans `politique.valeurs_possibles` — rien d'écrit dans la porte ; sous `societe.perimetre.mode` ≠ défaut, seuls société et contact peuvent être permis (tables lues dans la déclaration), tout autre objet reste jugé, et chaque champ est rejoué avec un compagnon société/contact. ⭐ **Témoin** lot-2 : 5 passes, **ROUGE** — `partagee` 9 fuites, `par_besoins` 9, `staffing.inter_agences=oui` 4 ; 0 aux défauts | 29/09 | `15cb758` |
| **V-153 · V-156 · D-47** (B2) | 🟠 | **Case 14** : copie du canon ET ✅ au tableau ET verte (⏳ → KO). **Case 17** : `make test` photographie `groupe_permission_perimetre` et `compte_groupe` après la fixture et après les portes ; toute ligne d'avant disparue → KO, avec la ligne. ⭐ **Témoin** : lot-2 → 14 **KO** (P-339 ⏳) ; 17 **OK** 0/97 (⚠️ le prompt attendait 6 fichiers sur 8 : `delegations.ts` de Grok est déjà fusionné) ; une porte de sabotage qui retire une délégation DP → 17 **KO**, 87 disparues nommées | 29/09 | `c27cbe4` |
| **V-147 · D-42** (B3) | 🟠 | **`politique_valeur_servie`** (018) : 426 couples semés, une garde refuse toute valeur d'une politique énumérée absente (valeur ET défaut) ; 13 valeurs non servies retirées (audit §3). **P-340** : table = clés de `COMPORTEMENTS` du serveur. ⭐ **Témoin** : `update politique set valeur='par_dp' where cle='temps.validation'` → **refusé** ; P-340 **ROUGE** « COMPORTEMENTS absent de server/src » (⏳ lot 2, à Grok) | 29/09 | `534a4cd` · `419f7b2` |
| **V-150 · D-46** (B4) | 🟡 | **Six permissions de lecture** (019) : LireSocietes, LireContacts, LireCandidats, LireRessources, LireBesoins, LireProjets, semées par le bloc « Lecture » de la MATRICE (✓ périmètre du groupe, S = soi, D = rien, délégable). ⭐ **Témoin** : count = **6** ; SUP : les six en global | 29/09 | `d226ecb` |
| **V-154 · V-157** (B5) | 🔴 | **GRANT par colonne** (020), calculé par `outils/ecritures_serveur.mjs` depuis `server/src` (INSERT, UPDATE, upsert, transitions, archivage, référentiels) : plus d'INSERT sur `politique`, UPDATE (valeur + sa trace). **P-325** compare colonne par colonne pour `ava_app` ET `ava_serveur`, et refuse DELETE/TRUNCATE. **Empreinte** sha256 de chaque migration dans `schema_migrations`, `migrate` refuse un fichier appliqué modifié, **case 18** lue avant le reset. ⭐ **Témoins** : lot-2 → P-325 **ROUGE** (INSERT politique, UPDATE à la table) ; `GRANT UPDATE(valeur_defaut) ON politique` → **ROUGE** ; `GRANT UPDATE(nom) ON agence TO ava_serveur` → **ROUGE** ; une ligne ajoutée à 019 appliquée → case 18 **KO** | 29/09 | `709f047` · `08ede17` |
| **V-159** (B6) | 🟡 | **`make test` rejouable** : le jeu d'essai se charge sur une base `*_modele` vidée et migrée de zéro à chaque tour, plus sur une copie de la base de travail. ⭐ **Témoin** : make test ×3 sans reset → « modèle : 20 migrations », jeu **chargé, 0 erreur** aux trois ; runs 1 et 2 : mêmes rouges (rejouable). ⚠️ Rouge d'avant non reproduit sur le jeu seul (copie vécue : 0 erreur). ⚠️ Au 3ᵉ run, P-303 P-172 P-323 P-330 tombent (GARDE « objets actifs non réaffectés » : le contact de la fixture accumule) — banc. ⚠️ Depuis 018, P-138 P-223 P-230 P-233 P-236 P-251 posent une valeur non servie : SetPolicy rend « erreur interne » au lieu d'un refus typé — serveur (Grok) | 29/09 | `62cb3ef` |
| **D-41** (B5, complément du 8e tour) | 🟡 | ⛔ Trou de la décision du BRAIN : la case 11 ne distinguait pas un doublon retiré (V-141) d'une porte perdue. Elle excuse désormais une porte ✅ absente **seulement** si elle a sa ligne au tableau D-41 **et** que la porte gardée est ✅. ⭐ **Témoin** : avec la déclaration → **OK** (P-333 → P-338 retirées déclarées) ; ligne D-41 de P-335 retirée → **KO P-335** ; P-120 retirée sans déclaration → **KO P-120** ; porte gardée P-326 passée ⏳ → **KO P-333** | 25/09 | `8ac151c` |
| **V-138 · D-36** (B1, 8e tour) | 🔴 | **Porte croisée P-339** : canon `_ops/PORTE_CROISEE.mjs`, repris de l'audit 8, copie exacte dans `test/` (case 14) ; fixture LYO/MRS et un acteur à groupe propre, permissions posées par ManageGroups ; complète par construction (commandes du serveur, identifiants de `agence.ts`, synonymes hérités : 105 identifiants). ⏳ lot 2 tant qu'elle a des fuites (déclarée). ⭐ **Témoin** : lot-2 actuel → **ROUGE, 17 fuites, les 17 de l'audit nom pour nom**, 0 positif KO ; le cas SetOwnTheme retiré → ROUGE « commande servie sans cas » ; copie retouchée → case 14 KO | 25/09 | `2aa8ec6` · `9df4e1a` |
| **V-143 · D-40** (B2) | 🟠 | 001 et 002 **restaurées** à leur version de `main` ; leurs ajouts dans **017** (`ref_decision_client`, codes système) + `staffing.inter_agences` ; **case 15** : chaque migration de `main` est identique ici. ⭐ **Témoin** : base neuve avant/après, `pg_dump --schema-only` : **0 différence** sur 7812 lignes (hors le jeton aléatoire de pg_dump), données des référentiels identiques ; politiques 201 → **202** ; case 15 : état d'avant → KO « 001, 002 », restaurées → OK, une ligne ajoutée à 001 → KO | 25/09 | `ddffd0a` |
| **V-141 · V-142** (B3) | 🟠 | **Case 16** (un numéro = un test, lue sur les titres exécutés) et **case 17** (DELETE/TRUNCATE sur les tables de délégation hors `test/contrat/delegations.ts` → KO, fichier et ligne). ⭐ **Témoin** : lot-2 → 16 KO (P-326…P-331 portent deux numéros, P-143 aussi) et 17 KO (13 retraits à la main nommés) ; clone corrigé → **OK / OK** | 25/09 | `2112399` |
| **V-144** (B4) | 🟡 | `dossier.py` lit les référentiels dans **toutes** les migrations (boucles et `CREATE TABLE`). ⭐ **Témoin** : « ECART : le SQL crée 45, le registre 74 » → aucun écart, **74** référentiels, **202** politiques | 25/09 | `7cfb3c5` |
| **V-131 · D-34** (B1, 7e tour) | 🟠 | Migration **015** : écriture retirée à `ava_app` sur les 19 tables sans commande servie (dont `groupe`, `permission`, `perimetre`, `agence`) + `schema_migrations`, trouvée en mesurant ; plus d'écriture sur les vues ; `compte` : `UPDATE (theme_json)` seul. **Porte calculée P-325** (`Role: banc`) : droits réels contre tables nommées par `server/src`. L'assertion de V-122 dit ce qu'elle mesure. ⭐ **Témoin** : base à 014 → P-325 rouge, 27 tables nommées ; 015 → verte ; `GRANT INSERT ON groupe` remis à la main → rouge, « groupe » | 24/09 | `9cc57f4` · `c0666b2` |
| **V-132** (B2) | 🟠 | Dans 015 : `ref_etat_envoi_email` et `ref_etat_preparation_paie` (72 → **74**), les deux CHECK de 013 en FK. Grille **B5 mesurée en base** (un grep sur les fichiers montre les CHECK déjà retirés) ; registre §D : 4 énumérations techniques de plus justifiées. ⭐ **Témoin** : 9 CHECK de liste vivants, 9 justifiés au §D (4 avant) | 24/09 | `9cc57f4` |
| **V-133 · D-35** (B3) | 🟠 | Case 9 : chaque commit de la branche qui touche `journal/PORTES.md`, plus le tableau de travail — tout ✅ → ⏳ doit être déclaré au tableau D-35 (porte et commit). ⭐ **Témoin** : P-062 → P-065 déclarées → **OK** ; ligne D-35 retirée → **KO** `P-062@b2b7d1e …` ; P-100 passée ⏳ sans commit → **KO** `P-100@travail` | 24/09 | `998f1df` |
| **V-135** (B4) + **016** | 🟠 | Le jeu d'essai porte l'agence responsable ; `make test` le charge sur une base neuve à part et tombe s'il échoue. ⛔ **016, défauts du BRAIN CODE dans 012** trouvés en rechargeant : deux FK disjointes sur `profil_candidat.disponibilite_code` (aucune valeur possible, `UpdateCandidate` levait), `besoin.budget_envisage` en double de `budget` sous un second CHECK M-15, `contact.type_contact_code` en double de `type_code`, deux FK redondantes. ⭐ **Témoin** : base neuve → jeu chargé, 0 erreur ; `agence_responsable_id` retirée du jeu → `make test` rc=1 | 24/09 | `1c5557a` |
| **cliquet et make.sh** (ce tour) | 🟡 | ⛔ Deux défauts de ce tour, vus au cliquet complet : la case 9 écrasait le compteur `ok` (« OK=6 » pour 11 cases vertes) ; l'ajout de P-325 avait écrit un `
` littéral dans la liste de `make.sh` (`make test` KO sans porte tombée). ⭐ **Témoin** : cliquet complet → `make test : OK`, 0 porte tombée, `cases OK=12 KO=1` (case 7 seule) | 24/09 | `509ca1c` |
| **V-124** (B1, 6e tour) | 🟠 | ⛔ **Défaut du BRAIN CODE** : le pas `verif_trailers.sh` annoncé au 5e tour n'était pas dans `ci.yml` — un `git reset --hard` de témoin avait effacé l'édition avant le commit. Branché pour de vrai (`fetch-depth: 0` déjà là) ; le crochet lit désormais les trailers comme git (`interpret-trailers`) : `Role:` hors du bloc de trailers est refusé. Les 3 commits passés ainsi (`18757b7`, `f9ff657`, `3e0a5c2`) sont **nommés** dans `outils/TRAILERS_EXCEPTIONS`, pas réécrits. ⭐ **Témoin** : la commande exacte du pas, branche d'essai + un commit sans trailer → **rc=1** ; commit retiré → **rc=0** ; message à la manière des fautifs → refusé par le crochet | 24/09 | `987dc65` |
| **V-121 · V-122 · V-125** (B2 B3) | 🟠 | Migration **014** : `ref_etat_paiement` (71 → **72**), `paiement.etat_code` en FK, le CHECK retiré ; `LireDonneesRHSensibles` au groupe RH ; **le GRANT vient avec la commande** — INSERT/UPDATE retirés à `ava_app` sur les 27 tables de 012/013 sans commande servie ; compteur de M-18 écrit par le trigger seul (`SECURITY DEFINER`). Assertion L7 : plancher 40 → **41**. ⭐ **Témoin** : 27 tables écrivables → **0** ; INSERT en `ava_serveur` sur `devis` → droit refusé ; état de paiement inconnu → refus FK ; GRANT remis à la main → l'assertion lève | 24/09 | `e76f873` |
| **B4** (compte des commandes) | 🟡 | `outils/compte_commandes.sh` joue la commande de L4 (→ **98**) ; la grille ne recopie plus « 55 » ni « 44 ». ⭐ **Témoin** : 0 compte recopié dans `make.sh`, le cliquet et la grille | 24/09 | `6e00056` |
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
