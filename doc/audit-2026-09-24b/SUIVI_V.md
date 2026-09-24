# Sixième audit — suivi des constats sur `a26291c` (branche `lot-2`)

Auditeur indépendant. Code lu dans `ava-audit-6-lecture` sur `a26291c` — `git status` **vide** au
début et à la fin. Base **`ava_audit6_a`** reconstruite **quatre fois depuis rien**
(`db/migrations/001 → 013` + `db/fixtures/banc.sql`, `rc=0` × 14 à chaque fois), serveur port
**3601**. Mutations jouées sur une **copie jetable** (scratchpad, `node_modules` en jonction,
jonctions retirées à la fin) — jamais sur le clone. Sorties longues : `rapport/preuves/suivi6/`.

⛔ **Rien n'est « Fermé » sans une commande exécutée ou un `fichier:ligne` lu.** Les verdicts posés
sur pièce (cliquet, CI, Playwright, `make.sh` — interdits ou hors périmètre) sont **Partiel**.

## Ce qui a tourné, sur base NEUVE

| Suite | Résultat |
|---|---|
| `sante` · `inventaire` | 1/1 · 1/1 |
| `commandes` · `chemin` | **56/56** · **56/56** |
| `politiques` | **50/50** |
| `matrice` | **52/52** |
| `correctifs` | **46/46** |
| `audit3` · `audit4` | **15/15** · **25/25** (P-287 → P-313) |
| `outils` | **2/2** |
| Assertions L7 (`test/SPEC_ASSERTIONS_L7.sql`) | **40 OK**, plancher **40** (`plancher_assertions.sh`), `cmp` canon/copie **identiques**, `rc=0` |
| Les 13 migrations + fixture | `rc=0` × 14 |

⭐ **304 portes vertes, 0 rouge**, sur une base construite depuis rien (291 au 5ᵉ tour).
Les 3 portes ✅ non exécutées ici restent **P-003, P-004, P-005** (Playwright).

---

## Les 10 constats du 5ᵉ audit (V-107 → V-116)

| Constat | Gravité | Verdict | Preuve |
|---|---|---|---|
| **V-107** repli sur l'agence du demandeur | critique | ⛔ **Partiel** | `sinonCompte` a bien **disparu du code** : `grep -rn sinonCompte` ne rend plus que **2 lignes de `_ops/`** (des textes d'arbitrage), 0 en `server/`. ⛔ Mais `server/src/agence.ts:285` porte le **même repli sous un autre nom** : `else await exigeDroit(ctx, ctx.commande, ctx.compte.agence_id);`. Il est atteignable dès qu'une ligne a **plusieurs lecteurs** et qu'aucun ne résout l'id : `agence.ts:228` ne lève `INTROUVABLE` que si `ligne.lecteurs.length === 1`. **Mesuré** : `ArchiveObject` archive une société **CAS** et un contact **CAS** depuis un compte **PAR** (`preuves/suivi6/30_*`). **D-26 (« aucun repli sur l'agence du demandeur ») n'est pas tenu.** Voir **N6-1** |
| **V-108** société et contact sans agence | critique | ⛔ **Partiel** | ⭐ **Fermé pour les 6 commandes de la ligne SOCIETE/CONTACT**, sondé dans les deux sens : `011_agence_responsable.sql` pose `societe.agence_responsable_id` et `contact.agence_responsable_id` **NOT NULL** (`information_schema` : `is_nullable = NO` pour les deux). `UpdateCompany`/`UpdateContact`/`RequalifyCompany`/`ArchiveCompany`/`ArchiveContact`/`TransferContact` sur un objet **CAS** par `ia@ava.test` (**PAR**, droit sur périmètre `agence PAR`) → **`DROIT`, rien écrit** ; les **mêmes** sur un objet **PAR** → **`ok:true`** (`preuves/suivi6/10_*`, `11_*`). ⛔ **Ouvert par `ArchiveObject`** — voir **N6-1** |
| **V-109** `RecordClientDecision` hors référentiel | elevee | ⛔ **Partiel** | ⭐ **Code fermé et prouvé en trois sens** (`preuves/suivi6/61_*`) : `besoin.ts:321-329` lit `SELECT categorie FROM ref_decision_client WHERE code = $1 AND actif`. Mesuré — `inventee` (absente) → `GARDE « décision inconnue »` ; `reporte` (catégorie `en_attente`) → `GARDE « décision non terminale »` ; **`abandon`, ajoutée en direct par `ManageRefs` en catégorie `negative`** → **`ok:true`**, `etat_code = refuse_client`, `etat_categorie = terminal_negatif`, `decision_client_le` posé, **relu en base**. ⛔ Le second volet **n'est pas fait** : `git diff b6ff087..HEAD -- _ops/GRILLE_AUDIT.md` est **vide**, le grep B1 (`GRILLE_AUDIT.md:45`) ne voit toujours pas `.includes()` — et il en reste **5** en `server/src` |
| **V-110** V-099, 2 portes sur 7 | elevee | ⛔ **Partiel** | ⭐ **Les deux portes tiennent maintenant** : les **6** permissions sans titulaire posées au groupe IA sur le périmètre `agence PAR` (par `ManageGroups`, pas en SQL), puis `matrice` **52/52**, `commandes` **56/56**, `chemin` **56/56**, `politiques` **50/50** — contre **50/52** au 5ᵉ tour (`preuves/suivi6/50_*`, `51_*`). Cause traitée : `v011-lignes.ts:91-125` photographie les lignes existantes et les remet dans un `finally`. ⛔ **La seconde moitié du constat reste ouverte** : après le passage des portes, **4 délégations sur 6 ont disparu de la base** (`ArchiveCompany`, `ArchiveContact`, `ArchiveObject`, `ArchiveService` ; seules `LireDonneesRHSensibles` et `UpdateResourceCost` survivent). `v011-lignes.ts:131` `retirer(l.groupe, l.commande)` **DELETE tout** ce que le groupe détient sur cette permission. Voir **N6-2** |
| **V-111** deux migrations `009` | elevee | ✅ **Fermé** (réserve nommée) | `ls db/migrations/` : **13 fichiers, 13 numéros distincts** — `009_unite_agence.sql` est devenu `010_unite_agence.sql`. La garde D-27 de `make.sh:169-174` **mesurée isolée dans les deux sens** sur un dossier jetable : dossier sain → `doublons=''` ; un `002_c.sql` ajouté → `doublons='002 '` puis `exit 1`. ⚠️ Réserve : la garde **et** le `rang` du registre vivent **entièrement dans `outils/make.sh`** (`:158`, `:195-197`), interdit d'exécution ici, et **aucune porte de contrat** ne les mesure. Voir **N6-4** |
| **V-112** F13 absente du cliquet | elevee | ⛔ **Partiel** (lu, non exécuté) | `outils/cliquet.sh` porte bien **13 cases** (`line 1` → `line 13`), et la **case 13** (`:322-345`) mesure F13 : elle cherche `lot-2-brain` puis `origin/lot-2-brain`, tente un `git fetch`, et pose **KO avec son motif** si la référence reste absente — plus de vert par défaut. ⛔ `outils/cliquet.sh` reste **interdit d'exécution** : **6ᵉ audit sans témoin exécuté par un tiers**. Vérifié à la main : `git merge-base --is-ancestor origin/lot-2-brain HEAD` → **rc=0** |
| **V-113** commits sans trailer `Role:` | moyenne | ⛔ **Ouvert** | Fenêtre `merge-base(origin/main, HEAD)..HEAD` : **23 commits sans trailer sur 189** (`preuves/suivi6/40_*`). ⛔ **Et 3 d'entre eux ont été écrits APRÈS le constat** (fenêtre `b6ff087..HEAD`, 3 KO / 32) : `18757b7`, `f9ff657`, `3e0a5c2`. ⛔ **D-29 n'est pas tenu** : `grep -n Role .github/workflows/*.yml` → **0 ligne** ; la CI lance `installer.sh` puis `cliquet.sh`, et **aucune des 13 cases** ne relit l'historique — la case 12 vérifie seulement que `core.hooksPath` est posé, ce qui n'a aucun effet rétroactif |
| **V-114** NOT NULL au mauvais endroit | moyenne | ✅ **Fermé** | `information_schema` : `profil_candidat.agence_id` **`is_nullable = NO`** (posé par `011_agence_responsable.sql` §4, après remplissage par le créateur lu dans `evenement_metier`, puis l'agence par défaut). `besoin`, `projet`, `profil_ressource`, `unite_organisation` : NOT NULL également. ⚠️ Effet de bord : `agenceGouvernante()` (`agence.ts:181-193`) ne sert que `unite_organisation`, NOT NULL depuis `010` — **c'est du code mort**, et le seul chemin qui l'appelle (`agence.ts:230-236`) est désormais inatteignable pour toutes les lignes |
| **V-115** écarts du 4ᵉ tour reconduits | moyenne | ⛔ **Partiel** | **H-1** : **assumé, pas corrigé** (D-30) — et elles sont maintenant **6**, pas 5 : `ArchiveCompany`, `ArchiveContact`, `ArchiveObject`, `ArchiveService`, `UpdateResourceCost`, **`LireDonneesRHSensibles`** (neuve). **H-2 fermé** : `crm.ts:133` `emit(ctx, "CompanyArchived", …, motif)`, et **43 lignes** de `evenement_metier` portent un motif non nul. **H-4 fermé** : `couverture.ts:24-33` distingue `fte`, `postes` et `postes_et_fte` — plus de « 0/1 postes » pour un `fte_vise`. **V-103 banc fermé** : `/vues/besoins` rend `session:{nom:"adm@ava.test",groupe:"ADM"}`, `{"ia@ava.test","IA"}`, `{"rh@ava.test","RH"}` — plus de `{nom:"Banc",groupe:"IA"}` (`preuves/suivi6/73_*`) |
| **V-116** bien fait, à garder | bonne | ✅ **Tient, et monte** | voir la section « constats bonne » |

---

## Le nouveau modèle de périmètre — sondé aux trois modes, témoin positif à chaque fois

`societe.perimetre.mode` : valeur **`agence_responsable`**, `valeur_defaut` **`agence_responsable`**,
`valeurs_possibles` `["agence_responsable","par_besoins","partagee"]`, **0 politique modifiée** sur 201.
Demandeur : `ia@ava.test` (agence **PAR**), droit `UpdateCompany`/`UpdateContact` sur le périmètre
`agence PAR`. Objet : `SocCAS` / `ContactCAS`, agence responsable **CAS**. (`preuves/suivi6/12_*`)

| Mode | Sonde hors agence | Témoin positif | Verdict |
|---|---|---|---|
| **`agence_responsable`** (défaut) | société CAS → **`DROIT`** · contact CAS → **`DROIT`** | société PAR → **`ok:true`** · contact PAR → **`ok:true`** | ✅ tient |
| **`partagee`** | société CAS → **`ok:true`** (c'est le sens du mode) | le droit déplacé sur le seul périmètre `agence CAS` → **`DROIT`** sur les deux sociétés : le mode ouvre l'objet, **pas le périmètre** | ✅ tient |
| **`par_besoins`** | société sans aucun besoin → **`DROIT`** · société avec un besoin **CAS** seulement → **`DROIT`** | un besoin d'agence **PAR** ajouté à la même société → **`ok:true`**, contact compris | ✅ tient |

⭐ Et la clé de politique est **tracée dans l'événement** : `liens.politiques` porte
`{"societe.perimetre.mode":"agence_responsable"}` sur chaque écriture société/contact.

⭐ **Mutation M1** — `agence.ts` : `const mode = await pol(…)` remplacé par `const mode = "partagee"`
(la tautologie de V-108 rétablie) → **3 portes tombent** : **✖ P-303, ✖ P-304, ✖ P-305** (22/25).
Les portes neuves du périmètre société **ne sont pas aveugles**.

---

## Les restes des tours précédents

| Constat | Gravité | Verdict | Preuve |
|---|---|---|---|
| **V-019** portes écran | elevee | **Partiel** (inchangé, 6ᵉ tour) | Playwright hors périmètre : **P-003, P-004, P-005** sont les 3 seules portes ✅ du tableau que personne n'a exécutées ici |
| **V-022** `pg_hba` en `trust` | elevee | **Ouvert (assumé, poste de dev) — mesuré et gardé** | `bash outils/verif_serveur.sh` → **rc=1**, 6 règles `trust` nommées avec leur ligne, `listen_addresses: *`, `ava_serveur` sans mot de passe ; `AVA_POSTE_DEV=1` → **rc=0**. Gardé par P-300 |
| **V-077** le cliquet et la porte ✅ supprimée | elevee | **Partiel** (6ᵉ tour) | `outils/cliquet.sh` reste interdit d'exécution. **Six audits, aucun témoin vu rouge par un indépendant** |
| **N4-2** garde de catégorie auto-référentielle | elevee | ⛔ **Ouvert, inchangé** | `admin.ts:207-215` identique. Mesuré (`preuves/suivi6/60_*`) : `ManageRefs ref_pays categorie:"afrique"` → **`GARDE « catégorie inconnue »`** ; `"europe"` → idem ; `"defaut"` → **`ok:true`**. `SELECT DISTINCT categorie FROM ref_pays` → **une seule ligne, `defaut`** : aucune catégorie neuve ne peut naître sur un référentiel sans `ck_cat`, et aucune porte ne le montre |
| **N4-5** fenêtre F12 repliée sur HEAD | moyenne | ⛔ **Ouvert, inchangé** (lu) | `cliquet.sh:281-284` : `else f12_liste="HEAD"` quand `base` est vide ; `:302` ne pose KO que si `f12_n -eq 0` — or la boucle `:286-292` compte HEAD, donc `f12_n=1` et la case 11 reste **OK**. Troisième tour sans changement |
| **V-096 → V-106** fermés au 5ᵉ | — | **Tiennent** | Rejoués ici par `audit3` 15/15, `audit4` 25/25, `outils` 2/2, `correctifs` 46/46, et D-14 hors banc (ci-dessous) |

---

## Les constats « bonne » — tiennent-ils ?

| Point | Verdict | Mesure de ce tour |
|---|---|---|
| Murs de rôles | **Tient, et s'élargit proprement** | `ava_app` : **INSERT 148 · SELECT 148 · UPDATE 144 · 0 DELETE · 0 TRUNCATE** ; `ava_lecture_agregats` : **7 relations, SELECT seul** ; `ava_app`/`ava_lecture_agregats`/`ava_migration` **NOLOGIN**, `ava_serveur` login sans superutilisateur |
| Assertions, plancher compté | **Tient, et monte** | **40 OK** (32 au 5ᵉ, 31 au 4ᵉ), plancher **40** compté par `plancher_assertions.sh`, `cmp` canon/copie identiques, `rc=0`, 0 « LE GESTE EST PASSÉ » |
| 55 = 55 = 55 | ⚠️ **Tient avec une dérive nommée** | **55** clés dans `CORRESPONDANCE` = **55** commandes du banc, mais **56** permissions en base : `LireDonneesRHSensibles` (neuve) n'a pas de ligne. `audit3.test.ts:227` garde le sens commande → correspondance ; **rien ne garde l'autre sens**. Défaut fermé (`GARDE « commande sans correspondance d'agence »`) — voir **N6-5** |
| Paramétrage | **Tient, et grossit** | **201** politiques (173 au 5ᵉ), **71** tables `ref_*` (40 au 5ᵉ), **0** ligne `valeur <> valeur_defaut` |
| D-14 ferme tout hors banc | **Tient** | Serveur relancé **sans `AVA_MODE`** : `/tuyau`, `/vues/besoins`, `/vues/besoins/<id>`, `/`, `/index.html`, `/contrat.js`, `/acquitter` → **401** ; `/commandes/*` avec **et** sans en-tête → **401** ; `/vues/besoins` avec en-tête `adm` → **401**. Seule `/sante` → **200** |
| Pas d'écriture par un anonyme | **Tient** | **60 POST anonymes** hors banc : `evenement_metier` **948 → 948**, `tentative_refusee` **275 → 275**, `societe` **35 → 35**, `contact` **27 → 27** |
| `/sante` n'interroge plus la base | **Tient** | **50 appels** → connexions sur `ava_audit6_a` **1 → 1**, corps `{"ok":true}`. ⚠️ La route reste publique et **aucun contrat ne l'écrit** (inchangé depuis le 5ᵉ) |
| Périmètre prouvé par un témoin positif | **Tient, et s'étend** | `matrice` 52/52, plus mes **14 sondes** sur les trois modes et les 7 commandes société/contact, dans les deux sens |
| Cliquet : 13 cases | **Non vérifié** | interdit d'exécution — angle mort, **6ᵉ tour** |
| **« 0 porte aveugle », N portes vertes** | ⛔ **Repasse au rouge** | **304 vertes / 0 rouge**, et **M1 fait tomber exactement les 3 portes visées**. ⛔ Mais **N6-1 est une porte aveugle** : la faille est vivante sur `a26291c` **pendant que les 304 portes sont vertes**, et le correctif M2 ne fait tomber **aucune** des 133 portes rejouées |

---

## Mutations jouées (copie jetable, portes relancées)

| # | Mutation | Attendu | Mesuré |
|---|---|---|---|
| **T0** | témoin, copie non mutée | vert | `audit4` **25/25** |
| **M1** | `societe.perimetre.mode` forcé à `partagee` (la tautologie de V-108 rétablie) | des portes tombent | **✖ P-303 ✖ P-304 ✖ P-305** (22/25) |
| **M2** | le **correctif** candidat de N6-1 : `resp("societe",["id"])` + `resp("contact",["id"])` ajoutés en tête de `CORRESPONDANCE.ArchiveObject` | ① la faille se ferme ② une porte devrait le voir | ① **oui** : `ArchiveObject type=societe` et `type=contact` sur objet CAS → **`DROIT`**, rien archivé ② ⛔ **non** : `audit4` **25/25**, `matrice` **52/52**, `commandes` **56/56** — **0 porte sur 133 ne distingue le code corrigé du code défectueux** |

---

## Compte

| Verdict | Nombre | Lesquels |
|---|---|---|
| **Fermé** | **2** | V-111 (réserve) · V-114 |
| **Partiel** | **6** | V-107 · V-108 · V-109 · V-110 · V-112 · V-115 |
| **Ouvert** | **1** | V-113 |
| **Bonne — tient** | 9 sur 10 | le point « 0 porte aveugle » **repasse au rouge** (N6-1) |
| Restes des tours précédents | **2 Partiel** (V-019, V-077) · **3 Ouvert** (V-022 assumé, N4-2, N4-5) | |

### Critiques encore ouverts

| # | État | Pourquoi |
|---|---|---|
| **N6-1** (neuf) | ⛔ **Ouvert, critique** | `ArchiveObject` accepte **10 types** (`admin.ts:39-50`) et sa ligne de correspondance n'a que **5 lecteurs** (`agence.ts:135-143`). Pour `societe`, `contact`, `personne` et `action`, aucun lecteur ne résout l'id → repli sur l'agence du **demandeur**. C'est V-107 et V-108 réunis, vivants, derrière une commande qui délègue aux mêmes handlers. **Quatrième tour où le même trou change de porte** (V-076 → V-097 → V-107/108 → N6-1) |
| **V-077** | **Partiel, 6ᵉ tour** | `outils/cliquet.sh` reste interdit à l'auditeur indépendant. Le point bloquant du projet n'a **jamais** eu de témoin exécuté par un tiers |

---

## Constats neufs candidats

| # | Défaut · une phrase | Cible | Gravité | Preuve | Reproduire | Correction |
|---|---|---|---|---|---|---|
| **N6-1** | **`ArchiveObject` est la porte dérobée du périmètre** : il archive une société, un contact, une personne ou une action d'une **autre agence**, là où la commande nommée refuse — et il le fait avec les mêmes handlers | CODE | **critique** | `admin.ts:39-50` : 10 types (`societe`, `unite`, `service`, `contact`, `personne`, `candidat`, `ressource`, `besoin`, `projet`, `action`). `agence.ts:135-143` : `ArchiveObject` n'a que 5 lecteurs (`unite_organisation`, `profil_candidat`, `profil_ressource`, `besoin`, `projet`) — **aucun lecteur `societe`, `contact`, `personne` ni `action`**. `agence.ts:228` ne lève `INTROUVABLE` que si `lecteurs.length === 1`, donc l'id non résolu **passe** ; `agence.ts:285` finit par `exigeDroit(ctx, ctx.commande, ctx.compte.agence_id)` — le contrôle se compare à lui-même. **Mesuré** (`preuves/suivi6/30_archiveobject_sortie.txt`, mode `agence_responsable`, droit posé par `ManageGroups` sur le seul périmètre `agence PAR`) : `ArchiveContact` sur `ContactCAS` → **`DROIT`** ; `ArchiveObject {type:"contact"}` sur **le même objet, le même compte** → **`ok:true`**, `archive_le` posé, relu en base. `ArchiveCompany` sur `SocCAS` → **`DROIT`** ; `ArchiveObject {type:"societe"}` → **`ok:true`**, `archive_le` posé. `ArchiveObject {type:"action"}` sur une action rattachée à un besoin **CAS** → **`ok:true`**, archivée. ⛔ **Porte aveugle** : les **304 portes sont vertes** pendant que la faille est vivante ; `P-303` (« sept commandes société et contact hors agence ») teste les 7 commandes nommées et **jamais** `ArchiveObject` (`audit4.test.ts:396-419`) ; `P-297` n'exerce `ArchiveObject` que sur un type couvert. **Mutation M2** (le correctif posé) → **0 porte sur 133 ne bouge** | `bash rapport/preuves/suivi6/30_archiveobject_porte_derobee.sh` | Deux lecteurs `resp("societe",["id"])` et `resp("contact",["id"])` en tête de `CORRESPONDANCE.ArchiveObject` (mesuré : ferme la faille, ne casse rien) ; **et** `personne`/`action` jugées par leur porteur. ⭐ Surtout : **`exigeAgence` ne doit jamais finir sur `ctx.compte.agence_id`** — `agence.ts:285` est `sinonCompte` sous un autre nom. Un id fourni qu'aucun lecteur ne résout doit être `INTROUVABLE`, quel que soit le nombre de lecteurs. **Et une porte par type d'`ArchiveObject`**, sinon le trou reviendra une cinquième fois |
| **N6-2** | **Le banc détruit des délégations qu'il n'a pas posées** : après un passage des portes, 4 des 6 permissions déléguées ont disparu de la base | CODE (banc) | **elevee** | `v011-lignes.ts:131` : `if (l.delegation) await retirer(l.groupe, l.commande);` et `monde.ts:55-61` : `retirer()` fait un `DELETE … WHERE groupe_id = … AND permission_code = $2` — **toutes** les lignes, y compris celles restaurées trois lignes plus haut par la photo (`v011-lignes.ts:117-124`). **Mesuré** (`preuves/suivi6/50_v110_delegations.txt`) : 6 permissions posées par `ManageGroups` sur `agence PAR` → `matrice` 52/52, `commandes` 56/56 → **il n'en reste que 2** (`LireDonneesRHSensibles`, `UpdateResourceCost`, celles qui n'ont pas de ligne `delegation`). ⚠️ C'est la moitié non fermée de V-110 / N5-2 : les portes ne rougissent plus, mais elles **effacent** | poser les 6 permissions par `ManageGroups` sur le périmètre `agence PAR`, lancer `contrat/matrice.test.ts`, relire `groupe_permission_perimetre` | `retirer()` ne doit supprimer que la ligne exacte qu'`accorder()` a posée (groupe + permission + **périmètre**) ; le `finally` de la délégation doit reposer la photo comme le fait déjà le cas « hors périmètre » |
| **N6-3** | **D-26 est démenti par le code qu'il a produit** : « aucun repli sur l'agence du demandeur » est écrit à l'arbitrage, et la dernière ligne de `exigeAgence` est ce repli | BRAIN + CODE | **elevee** | `_ops/ARBITRAGE_AUDIT_2026-09-24.md` D-26 : « ⛔ **Aucun repli sur l'agence du demandeur.** `sinonCompte` disparaît ». `agence.ts:284-285` : `if (agenceId) await exigeDroit(ctx, ctx.commande, agenceId); else await exigeDroit(ctx, ctx.commande, ctx.compte.agence_id);`. Le nom a disparu, **le geste est resté** — et il est le chemin de N6-1. Le mode `partagee` fait le même geste en clair (`agence.ts:253`), là c'est **voulu** ; le `else` de la fin ne l'est pas | lire `agence.ts:284-285` | Trancher par écrit lequel des deux est la règle, et **une porte par branche** : agence lue → on l'exige ; agence nulle → global (déjà gardé par P-288) ; **objet non résolu → INTROUVABLE**, jamais un périmètre de repli |
| **N6-4** | **La garde « un numéro = un fichier » et le rang du registre vivent dans `outils/make.sh` seul** : ni migration, ni porte de contrat, et l'outil est interdit à l'auditeur | BRAIN CODE | **moyenne** | `make.sh:169-174` (doublons), `:176-183` (nom `NNN_`), `:158` (`ADD COLUMN rang`), `:195-197` (`UPDATE rang` + `CREATE UNIQUE INDEX ux_schema_migrations_rang`). **Aucune** de ces lignes n'est dans `db/migrations/` : une base construite **sans** `make.sh` — comme la mienne, et comme tout déploiement fait à `psql` — n'a **pas de table `ava.schema_migrations` du tout** (`information_schema` : 0 ligne). Et `grep -rn "migration" test/contrat/*.ts` ne rend **aucune** porte sur le sujet. La garde elle-même est saine : mesurée isolée, `doublons=''` / `doublons='002 '` | `psql` les 13 migrations à la main, puis `SELECT * FROM ava.schema_migrations` | Le registre et son rang appartiennent au **schéma** (une migration `014`), pas à l'outil ; et une porte de contrat qui refuse deux fichiers au même numéro — le cliquet de D-27 n'est pas exécutable par un tiers |
| **N6-5** | **56 permissions, 55 lignes de correspondance, et la garde ne va que dans un sens** | CODE | **basse** | `SELECT count(*) FROM ava.permission` → **56** ; clés de `CORRESPONDANCE` (`agence.ts:54-148`) → **55** ; l'écart est `LireDonneesRHSensibles`. `audit3.test.ts:227` vérifie que chaque commande du banc **a** une ligne ; **aucune porte** ne vérifie l'inverse. Le défaut est fermé (`GARDE « commande sans correspondance d'agence »`), donc le risque est un refus, pas une fuite | comparer `permission.code` et les clés de `CORRESPONDANCE` | Soit une porte qui énumère les permissions **routables** et exige leur ligne, soit une colonne `permission.routable` qui dit lesquelles sont des commandes |
| **N6-6** | **`TransferContact` déplace le contact d'agence sans déplacer son agence responsable** : le contact et sa société finissent dans deux agences différentes, et l'agence de départ garde la main sur un contact qui ne lui appartient plus | CODE | **elevee** | `crm.ts:393-395` : `UPDATE contact SET societe_id = $2, unite_organisation_id = NULL` — `agence_responsable_id` **n'est jamais touché**. Et `grep -rn agence_responsable_id server/src/` : la colonne n'est écrite qu'à la **création** (`crm.ts:62` société, `crm.ts:323` contact) — **aucune commande ne la modifie**, alors que D-25 annonce « modifiables par un droit dédié ». **Mesuré** (`preuves/suivi6/90_transfercontact.txt`) : `ContactPAR2` (société **PAR**, contact **PAR**) transféré par `ia@ava.test` vers `SocCAS2` (société **CAS**) → `ok:true`, et la base rend `societe_agence = CAS`, `contact_agence = **PAR**`. Puis `UpdateContact` par le **même compte PAR** → **`ok:true`**, le contact d'un client CAS est renommé. ⛔ `011_agence_responsable.sql` écrit pourtant « le contact suit sa société : c'est le même client, donc la même agence responsable » — l'invariant est cassé par la commande qui déplace, et **aucune porte ne le voit** (`P-303` n'essaie `TransferContact` que pour le refus). ⚠️ Conséquence jumelle : une société ne peut **jamais** changer d'agence responsable, donc un client transféré entre agences est bloqué | `bash` la sonde `preuves/suivi6/90_transfercontact.txt` (droit `TransferContact` + `UpdateContact` au groupe IA sur `agence PAR`, contact PAR transféré vers une société CAS) | `TransferContact` recopie l'agence responsable de la société d'arrivée (comme `CreateContact` le fait déjà à `crm.ts:315-325`) ; une commande dédiée pour changer `societe.agence_responsable_id` ; **et une porte qui relit l'agence du contact après le transfert** |

---

## Angles morts

| Non vérifié | Pourquoi |
|---|---|
| **`outils/cliquet.sh` et `outils/make.sh`** | interdits par le poste de travail, **6ᵉ audit de suite**. V-077, V-112 (case 13), D-20 et D-27 reposent donc sur une **lecture**. Le point bloquant du projet n'a toujours aucun témoin exécuté par un indépendant, et la règle qui l'interdit est plus vieille que le défaut |
| **CI GitHub** | non exécutable depuis un clone. `ci.yml` reconstruit `main` puis lance `installer.sh` et `cliquet.sh` — le repli de N4-5 n'y joue pas. Reste non prouvé : que le cliquet passe. ⛔ Et j'ai pu **lire** que D-29 n'y est pas |
| **Portes écran P-003 / P-004 / P-005** | Playwright non joué (build web + navigateur). V-019 jugé en lisant — **6ᵉ tour** |
| **`web/`** | non audité. Les vues serveur sont mesurées, leur consommation non |
| **Les 13 migrations dans un autre ordre** | non rejoué ce tour : les numéros sont maintenant distincts, mais l'**indépendance** de `011`, `012` et `013` entre elles n'a pas été mesurée |
| **Mutations : 2 jouées** | M1 (le mode forcé) et M2 (le correctif de N6-1). Les 62 sabotages des tours précédents et les 15 sabotages SQL n'ont **pas** été rejoués un par un : le « 0 porte aveugle » n'est pas revérifié en bloc — et N6-1 montre qu'il ne tient déjà plus |
| **S3b (`ROLLBACK` → `COMMIT` sur refus)** | non rejoué, **cinquième** audit de suite |
| **Multi-agences réel** | mes sondes opposent PAR et CAS. Un compte couvrant **deux** agences sur une même permission n'a pas été construit ; le mode `par_besoins` avec une société suivie par **trois** agences non plus |
| **`agence_responsable_id` dans le temps** | mesuré et devenu **N6-6**. Reste non mesuré : ce qui arrive si le **manager** d'une société change d'agence après coup (`011` ne s'exécute qu'une fois) |
| **`agenceGouvernante()`** | code mort mesuré par déduction (les deux colonnes qu'elle servait sont NOT NULL), pas par instrumentation |
| **Rôles globaux au cluster** | `007` fait `ALTER ROLE ava_serveur …` à chaque construction : mes **quatre** reconstructions ont remis les attributs du rôle pour **tout le cluster**, donc pour les autres auditeurs. Aucun `CREATE/ALTER/DROP ROLE` à la main |
| **Artefacts de poste (pas des constats)** | ① `DROP DATABASE … WITH (FORCE)` **tue le serveur** : `pg-pool` lève `Unhandled 'error' event` et le processus meurt. Ordre imposé à toutes mes mesures : base d'abord, serveur ensuite. ② Le port **3602** était déjà pris par un autre auditeur : la mesure hors banc a été faite sur **3601**, serveur de banc arrêté puis relancé. ③ `psql` n'accepte pas d'option après l'URL ; `PGCLIENTENCODING=UTF8` imposé |
