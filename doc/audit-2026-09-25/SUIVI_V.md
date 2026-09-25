# Huitième audit — suivi des constats sur `48e90c4` (branche `lot-2`)

⛔ **Le mur d'agence est encore percé : deux critiques ouverts, 0 porte ne les voit.**
Au réglage **par défaut**, trois comptes **PAR** seulement (`ia`, `staf`, `dp`) font passer une société **CAS** et son
contact **CAS** de « prospect » à « client » (S15b), alors que `RequalifyCompany` direct leur est refusé (`DROIT`).
Un compte qui cumule `RES` (périmètre `soi`) et un groupe d'agence PAR écrit une absence sur une ressource **CAS** et
un document sur un candidat **CAS** (S19, S19b). **322 portes vertes** pendant ce temps.

⭐ **V-128 au sens strict est fermé** : garde et commande ne jugent plus deux objets différents pour **le même rôle**
(S3, S4 : `GARDE « entrée ambiguë »` ou `DROIT`, 0 écriture ; mutation M4 → P-326 tombe). ⛔ Mais la règle 3 de D-32
(« toute référence écrite passe par la garde ») **n'est pas codée** : **13 commandes** écrivent une référence que la
garde ne lit pas, **11 mesurées `ok:true`** vers un objet CAS. Et la règle 2 (« la commande reçoit ») ne vaut que pour
**5 commandes sur 55**.

Auditeur indépendant. Code lu dans `ava-audit-8-lecture` sur `48e90c4` — `git status` **vide** au début et à la fin.
Base **`ava_audit8_a`** construite depuis rien (`db/migrations/001 → 016`, `rc=0` × 16, puis `db/fixtures/banc.sql`),
serveur port **3801**. Mutations sur une **copie jetable** (`git archive 48e90c4` en scratchpad, `node_modules` en
jonction, jonctions retirées, cibles vérifiées intactes). Base **reconstruite à neuf en fin d'audit** (rien de mes sondes n'y reste).
Sorties longues : `rapport/preuves/suivi8/`. Le script de sondes a été joué **deux fois** sur deux mondes neufs : mêmes verdicts, sauf l’archivage d’action CAS, sondé seulement au 2ᵉ passage (`DROIT`). ⛔ Rien n'est « Fermé » sans une commande exécutée ou un `fichier:ligne` lu.

## Ce qui a tourné, sur base NEUVE (`preuves/suivi8/10_*`, `11_*`)

| Suite | Résultat |
|---|---|
| `comptes-avant-fixture` (avant la fixture) | **1/1** |
| `_ops/JEU_ESSAI.sql` sur base migrée neuve | **rc=0** — 2 581 sociétés · 8 000 contacts · 21 000 personnes · 1 926 besoins · 161 projets · 170 prestations (`03_jeu_essai.txt`) |
| Assertions L7 | **41 OK**, plancher **41**, `cmp` canon/copie **identiques**, `rc=0` (`05_*`) |
| `sante` · `inventaire` · `outils` · `grants` | 1/1 · 1/1 · 2/2 · **1/1** |
| `commandes` · `chemin` · `politiques` · `matrice` | **56/56** · **56/56** · **50/50** · **52/52** |
| `audit3` · `audit4` · `audit6` · `audit7` | **15/15** · **25/25** · **11/11** · **7/7** |
| `correctifs` | **45/46** avec `AVA_URL_MIGRATION` (sans : 44/46, P-136 en plus) — ✖ **P-148** `ENOENT test/test-results/` : clone propre (N7-9, inchangé) |

⭐ **322 portes vertes sur 323 exécutées, 1 rouge d'environnement.** ⛔ Vertes pendant que N8-1 et N8-3 sont vivants.

---

## Les 10 constats du 7ᵉ audit (V-128 → V-137)

| Constat | Gravité | Verdict | Preuve |
|---|---|---|---|
| **V-128** garde et commande lisent l'entrée chacune de leur côté | critique | ⚠️ **Partiel** | ✅ **Le mécanisme mesuré est fermé** : `{id: pos PAR, positionnement_id: pos CAS}` → `GARDE « entrée ambiguë »` ×2 ; clé seule sur CAS → `DROIT` ×2 ; `id` seul → `GARDE « identifiant manquant »` ; positionnements CAS **relus en base inchangés** (`propose`, `presente` — `30_sondes_d32_sortie_bis.txt:52-53`). `CreateCandidate`/`CreateResource` `{agence: PAR, agence_id: CAS}` → `GARDE` ×2, `agence_id` CAS seul → `DROIT` ×2, **0 profil écrit** (S4). `CreateCompany {manager: compte CAS}` → `DROIT` ; `CreateProject {besoin_id: CAS}` → `DROIT`, 0 projet (S4). Mutation **M4** (paire `agence`/`agence_id` retirée) → **P-326 tombe** ; **M5** → P-329 tombe. ⛔ **Mais D-32 n'est appliqué qu'en partie** : règle 2 — `ctx.cible`/`ctx.resolues` lus par **5 commandes** (`DeclareCVShared`, `RecordClientDecision`, `WithdrawPositioning`, `CreateCompany`, `CreateProject`), les **50 autres relisent l'entrée** ; règle 1 — **une** liste commune de 113 clés (`agence.ts:178-193`, `:202`), pas une par commande, et **3 paires** seulement (`:229-233`) ; règle 3 — **13 commandes** écrivent une référence non lue (table ci-dessous) → **N8-1, N8-2** |
| **V-129** `soi` posé se comporte comme `global` | elevee | ⚠️ **Partiel** | ✅ `ManageGroups soi` sur `UpdateNeed` → `GARDE` par nom **et** par uuid (S18) ; P-329 verte et **gardée** (M5 la fait tomber). ⛔ `droits.ts:33` : `soi` couvre **toute agence** pour les 3 commandes `SOI_MEME`, et `exigeSoiMeme` **renonce** dès que le compte a un autre périmètre (`droits.ts:63`). Mesuré : compte `RES`+`STAF` → `UploadDocument` sur la société CAS et le candidat CAS → **`ok:true` ×2**, 2 documents écrits ; `STAF` seul → `DROIT` (S19). Compte `RES`+`RH` → `RecordAbsence` sur une ressource CAS → **`ok:true`** ; `RH` seul → `DROIT` (`32_*` S19b) → **N8-3** |
| **V-130** `TransferContact` : une seule agence jugée | elevee | ✅ **Fermé** | Mutation **M1 = Y6** (`exigerToutes` sur la seule agence du contact) → **P-330 et P-323 tombent** (`61_M1_Y6_*`). Sondé : PAR→CAS et CAS→PAR → `DROIT` ×2 ; droit CAS posé → transfert `ok`, base : société **CAS**, contact **CAS** ; `UpdateContact` par PAR ensuite → `DROIT` (S2). ⚠️ reste V-119 ci-dessous |
| **V-131** 19 tables écrivables sans commande | elevee | ✅ **Fermé** | `has_table_privilege('ava_app', …)` : `permission`, `perimetre`, `groupe`, `compte_groupe`, `agence`, `compte_surcharge`, `societe_role`, `periode_emploi`, `personne_coordonnee`, `modele`, `reprise_boond`, `compte` → **false/false** ; `compte` : UPDATE sur la **seule** colonne `theme_json` ; tables écrivables hors `ref_*` = **23** = les 24 tables écrites par `server/src` moins `compte` (par colonne). `ava_app` : INSERT 97 · SELECT 151 · UPDATE 93 · **DELETE 0** ; P-325 verte (`70_grants.txt`) |
| **V-132** deux listes d'états en CHECK (013) | elevee | ✅ **Fermé** | Mesuré en base (requête de B5) : **8** CHECK de liste hors `ref_*`, **aucun sur un état** ; chacun est justifié au registre §D (`REGISTRE_POLITIQUES_v1.md:414-415`) ; `ref_etat_envoi_email`, `ref_etat_preparation_paie` présents ; **74** `ref_*` en base (`71_check_listes.txt`) |
| **V-133** P-062→P-065 ✅→⏳ sans trace | elevee | ⚠️ **Partiel** (lu) | Déclarées : `PORTES_EN_ATTENTE.md:169` (commits `6dc1e89`→`b2b7d1e`, motif, D-35) ; `journal/PORTES.md:73-76` en ⏳ lot 3. Case 9 lue (`outils/cliquet.sh:231-294`, variable `c9_ok`) — **non exécutée** : le cliquet m'est interdit (8ᵉ tour, V-077) |
| **V-134** le banc efface les délégations d'autrui (= V-120) | moyenne | ⛔ **Ouvert — élargi** | 6 délégations posées par `ManageGroups` sur **agence PAR**, un fichier à la fois (`40_v120_PAR.txt`) : `matrice` **6→2** · `audit4` **6→2** · `audit3` **6→2** · `politiques` **6→4** · **`audit7` 6→4** · `audit6` 6→5 · `chemin` 6→6 · `commandes` 6→6. Sur **global** (`40_v120_global.txt`) : `chemin` **6→2**, `audit3` 6→2, `politiques` 6→4, `audit7` 6→5, `audit6` 6→5. Cause lue : `v011-lignes.ts:127` `accorder(…PAR)` sans effet sur une ligne présente puis `:132` `retirer(…PAR)` ; `matrice.test.ts` `retirer(…, PERIMETRE_PAR)` ; `chemin.test.ts` `retirer(…, PERIMETRE_GLOBAL)` ; ⛔ **P-331 efface elle-même** `ArchiveObject` et `ArchiveService` PAR (`audit7.test.ts:184-190`). Et le banc **laisse** une ligne `ADM ArchiveObject global` absente du seed (`41_*` vs `43_gpp_seed_neuf.txt`) |
| **V-135** `JEU_ESSAI.sql` ne se charge plus | moyenne | ✅ **Fermé** | `psql -v ON_ERROR_STOP=1 -f _ops/JEU_ESSAI.sql` sur base migrée neuve → **rc=0**, volumes ci-dessus (`03_jeu_essai.txt`) |
| **V-136** grille F « 11 » ; garde de secours non gardée | moyenne | ⚠️ **Partiel** | ✅ Grille : section F « 13 contrôles (F1 → F13) » et **13** lignes F ; **43** lignes de contrôle au total (5+5+5+5+5+5+13). ⛔ « Disparaît avec la règle 2 » est faux : 50 commandes relisent l'entrée. Mutation **M3** (repli rétabli : objet non trouvé → droit dans l'agence du compte) → **0 porte sur 222** (`audit7` 7/7, `audit6` 11/11, `audit4` 25/25, `audit3` 15/15, `matrice` 52/52, `commandes` 56/56, `chemin` 56/56 ; `61_M3_repli_*`) |
| **V-137** bien fait | bonne | ✅ **Tient sur ce qui a été rejoué** | ArchiveObject : société/contact CAS → `GARDE « utiliser ArchiveCompany/ArchiveContact »` ; personne, candidat, ressource, besoin, projet, action CAS → `DROIT` ×6 ; **0 objet CAS archivé** ; id sans objet → `INTROUVABLE` ×6 ; témoin candidat PAR → `ok` (S1, `31_*`). **55** lignes de correspondance = **55** handlers (P-327 les parcourt toutes). Modèle société sous sabotage et 15 sabotages SQL : **non rejoués** |

---

## Les restes des tours précédents

| Constat | Gravité | Verdict | Preuve |
|---|---|---|---|
| **V-118** repli non gardé | elevee | ⛔ **Ouvert** (3ᵉ tour) | M3 : **0/222** (ci-dessus) |
| **V-119** `TransferContact` | elevee | ⚠️ **Partiel** | Code ✅ (S2). ⛔ Mutation **M2** (la recopie `agence_responsable_id = $3` retirée, `crm.ts:395`) → `audit7` 7/7, `audit6` 11/11, `audit4` 25/25 : **aucune porte ne relit l'agence du contact après un transfert permis** (`61_M2_recopie_*`) |
| **V-120 / V-110** délégations effacées | elevee | ⛔ **Ouvert** | = V-134 |
| **V-126** grille 42/43 | moyenne | ✅ **Fermé** | 43 annoncés, 43 écrits, F = 13 |
| **V-107** repli sur l'agence du demandeur | critique | ✅ **Tient** | `ctx.compte.agence_id` : 2 lignes dans `agence.ts` — `:256` (`exigeSoi`) et `:483` (création sans objet trouvé) |
| **V-108** société et contact sans agence | critique | ✅ **Tient** | S1, S2 : société/contact CAS → `GARDE`/`DROIT`. ⛔ Nouvelle écriture **indirecte** d'une société CAS : N8-1 |
| **V-111** deux migrations 009 | elevee | ✅ **Tient** | **16 fichiers, 16 numéros, 0 doublon** |
| **V-113 / V-124** trailers | moyenne | ✅ **Tient** | `verif_trailers.sh` → **rc=0** (215 commits, 29 antérieurs à D-29) ; `ba9a284..48e90c4` : **15 commits, 15 avec `Role:`** (`72_restes_outils.txt`) |
| **V-114** NOT NULL | moyenne | ✅ **Tient** (non ressaboté) | P-322 verte |
| **V-115** permissions sans titulaire | moyenne | **Partiel** (assumé D-30) | **4** : `ArchiveCompany`, `ArchiveContact`, `ArchiveService`, `UpdateResourceCost` |
| **V-019** portes écran | elevee | **Partiel** | Playwright hors périmètre (P-003/004/005) |
| **V-022** `pg_hba` en `trust` | elevee | **Ouvert, assumé et gardé** | `verif_serveur.sh` → **rc=1** ; `AVA_POSTE_DEV=1` → **rc=0** (6 règles trust, `ava_serveur` sans mot de passe) |
| **V-077 / V-112** cliquet sans témoin tiers | elevee | **Partiel** (8ᵉ tour) | interdit d'exécution |
| **N4-2** catégorie auto-référentielle | elevee | ⛔ **Ouvert, inchangé** | `ManageRefs ref_pays categorie:"afrique"` → `GARDE « catégorie inconnue »` ; `ref_pays` n'a que `defaut` (`32_*`) |
| **N4-5** F12 repliée sur HEAD | moyenne | ⛔ **Ouvert** (lu) | `cliquet.sh:333` `f12_liste="HEAD"` |
| **N6-4** registre des migrations | moyenne | ⛔ **Ouvert** | base construite à `psql` : `schema_migrations` → **0 table** |
| **N6-5** 56 permissions, 55 commandes | basse | ⛔ **Ouvert** | `permission` = **56** (dont `LireDonneesRHSensibles`), 55 handlers |
| **N7-8** deux impasses fermées par défaut | basse | ⛔ **Ouvert, inchangé** | personne sans profil → `DROIT` pour IA **et ADM global** (S1e) ; droit `ArchiveService` sur le seul périmètre CAS → `DROIT` sur une unité CAS (S5) |
| **N7-9** P-148 en clone propre | basse | ⛔ **Ouvert** | `ENOENT …\test\test-results\commit-msg.txt` |

---

## Les constats « bonne » — tiennent-ils ?

| Point | Verdict | Mesure de ce tour |
|---|---|---|
| Murs de rôles | ✅ **Tient, et se resserre** | `ava_app` INSERT **97** · SELECT 151 · UPDATE **93** · **DELETE 0** (122/149/118 au 7ᵉ) ; `ava_app`, `ava_lecture_agregats`, `ava_migration` NOLOGIN ; `ava_serveur` login, pas superutilisateur |
| Assertions, plancher compté | ✅ **Tient** | 41 OK, plancher 41, `cmp` identique |
| Paramétrage | ✅ **Tient** | **201** politiques, **74** `ref_*` ; **0** `valeur <> valeur_defaut` après mes sondes (S20) |
| D-14 ferme tout hors banc | ✅ **Tient** | serveur sans `AVA_MODE` : `/tuyau`, `/vues/besoins` (avec et sans en-tête), `/`, `/index.html`, `/contrat.js` → **401** ; **21 POST** `/commandes/*` (sans en-tête, `adm`, `ia`) → **21 × 401** ; `/sante` → 200 ; `evenement_metier` 6 488 → 6 488 (`80_hors_banc.txt`) |
| « 0 porte aveugle » | ⛔ **Rouge, 4ᵉ tour de suite** | M2 et M3 : **0 porte** ; N8-1, N8-3, N8-4 vivants sous 322 portes vertes. ✅ M1 (Y6), M4, M5 : une porte tombe |

---

## Mutations jouées (copie jetable, serveur mutant sur 3801 — `60_mutations.sh`, `61_*`)

| # | Mutation | Attendu | Mesuré |
|---|---|---|---|
| **M1 = Y6** | `TransferContact` ne juge que l'agence du contact | une porte tombe | ✅ **P-330 et P-323 tombent** |
| **M2** | `TransferContact` ne recopie plus `agence_responsable_id` | une porte tombe | ⛔ **0/43** (`audit7`, `audit6`, `audit4`) |
| **M3** | le repli rétabli (`agence.ts:497`) | une porte tombe | ⛔ **0/222** |
| **M4** | la paire `agence`/`agence_id` retirée de `PAIRES` | P-326 tombe | ✅ **P-326 tombe** |
| **M5** | `soi` couvre toute agence pour toute commande | P-329 tombe | ✅ **P-329 tombe** (`matrice` reste 52/52) |

---

## ⭐ LA TABLE DES 55 — ce que lit la commande, ce que lit la garde

Méthode : chaque `req`/`opt(ctx.entree, …)` et chaque `ctx.cible`/`ctx.resolues` de `server/src/commandes/*.ts`,
dans l'ordre, contre les `lecteurs` de la ligne dans `agence.ts:74-176`. Seuls les **identifiants d'objet** figurent.
« — » = pas d'écart. Sonde = `30_sondes_d32_sortie.txt` / `31_*` / `32_*`.

| # | Commande | La commande lit (ordre) | La garde lit (ordre) | Écart |
|---|---|---|---|---|
| 1 | CreateCompany | `ctx.resolues.manager` | compte ← `manager` | `manager_compte_id` admis par la liste, **ignoré** par les deux : société créée PAR, manager = le demandeur (S4) |
| 2 | UpdateCompany | `id` · `manager`,`manager_compte_id` | societe ← `id` | ⛔ **`manager` non lu** : compte CAS écrit (S11) — alors que `CreateCompany` le refuse |
| 3 | RequalifyCompany | `id` | societe ← `id` | — |
| 4 | ArchiveCompany | `id` | societe ← `id` | — |
| 5 | CreateUnit | `societe_id` · `parent_id` | unite ← `parent_id` ; agence d'entrée `agence_id`,`agence` | ⛔ **`societe_id` non lu** : unité PAR sous la société CAS, `ok` (S7) |
| 6 | UpdateUnit | `id` · `parent_id` | unite ← `id` | `parent_id` non lu par la garde ; la commande exige même société et même agence (`crm.ts:199-207`) |
| 7 | ArchiveService | `id` | unite ← `id` | — |
| 8 | CreateContact | `societe_id` · `unite_organisation_id`,`unite_id` | societe ← `societe_id` | unité contrôlée « même société » ; `unite_id` hors liste → `GARDE` |
| 9 | UpdateContact | `id` · `unite_organisation_id`,`unite_id` | contact ← `id` | idem |
| 10 | TransferContact | `id` · `societe_id`,`nouvelle_societe`,`nouvelle_societe_id` | contact ← `id` ; societe ← mêmes 3, même ordre | 3 noms hors `PAIRES` : deux sociétés différentes **acceptées** (S2, cohérent : les deux prennent `societe_id`) — règle 1 non tenue |
| 11 | ArchiveContact | `id` | contact ← `id` | — |
| 12 | CreatePerson | — | création, aucun lecteur | — |
| 13 | CreateCandidate | `personne_id` · `agence_id` (seul) ?? agence du compte | agence ← `agence`,`agence_id` | **ordre différent**, neutralisé par `PAIRES` (S4 `GARDE`) ; `agence` seul : la garde juge `agence`, la commande écrit l'agence du compte (droit exigé sur elle, `agence.ts:410`) |
| 14 | UpdateCandidate | `id` · `responsable_rh`,`responsable_rh_compte_id` | candidat ← `id` | ⛔ **`responsable_rh` non lu** : compte CAS écrit (S11) |
| 15 | CompleteCandidate | `id` | candidat ← `id` | — |
| 16 | ExitCandidate | `id` | candidat ← `id` | — |
| 17 | ReactivateCandidate | `id` | candidat ← `id` | — |
| 18 | ConvertCandidateToResource | `profil_candidat_id`,`id` · `societe_fournisseur_id` | candidat ← `profil_candidat_id`,`id` | même ordre ; ⛔ **fournisseur non lu** (lu, même code que 19) ; agence écrite = celle du **compte**, pas du candidat lu (`identite.ts:207`, reste N7-3) |
| 19 | CreateResource | `personne_id` · `agence_id`,`agence` · `societe_fournisseur_id` | agence ← `agence`,`agence_id` | **ordre inverse**, neutralisé par `PAIRES` (S4) ; ⛔ **fournisseur non lu** : société CAS écrite (S12) |
| 20 | UpdateResource | `id` · `responsable_rh`,`responsable_rh_compte_id` | ressource ← `id` | ⛔ `responsable_rh` non lu (lu, même code que 14) |
| 21 | SetResourceState | `id` | ressource ← `id` | — |
| 22 | UpdateResourceCost | `id` | ressource ← `id` | — |
| 23 | UploadDocument | un seul de `personne_id`,`profil_candidat_id`,`profil_ressource_id`,`projet_id`,`societe_id` | `projet_id`,`profil_ressource_id`,`profil_candidat_id`,`societe_id`,`personne_id`×2 | ordre différent mais **exactement un porteur** → cohérent ; ⛔ `soi` cumulé : S19 |
| 24 | RecordQualification | `personne_id` · `besoin_id` | besoin ← `besoin_id` **puis** personne (s'arrête au premier trouvé, `agence.ts:474-477`) | ⛔ **personne non jugée quand un besoin est fourni** : qualification d'une personne CAS via un besoin PAR `ok` ; sans besoin → `DROIT` (S13) |
| 25 | CreateNeed | `societe_id` · `agence`,`agence_id` · `contact_id` · `unite_organisation_id`,`unite_id` | agence ← `agence`,`agence_id` | ⛔ **`societe_id` non lu** : besoin PAR sur la société CAS `ok` (S14) → chaîne S15b (N8-1) |
| 26 | UpdateNeed | `id` · `contact_id` | besoin ← `id` | contact « même société » ; accepte des clés d'autres commandes (S16) |
| 27-33 | SetNeedPriority · TakeNeedInCharge · DeclareNeedFilled · SuspendNeed · ResumeNeed · CloseNeed · ReopenNeed | `id` | besoin ← `id` | — |
| 34 | PositionCandidate | `besoin_id` · `profil_candidat_id` | besoin ← `besoin_id` | ⛔ **profil non lu** : candidat CAS positionné (S9) |
| 35 | PositionResource | `besoin_id` · `profil_ressource_id` | besoin ← `besoin_id` | ⛔ **profil non lu** : ressource CAS positionnée (S9) |
| 36 | DeclareCVShared | `ctx.cible` | positionnement→besoin ← `positionnement_id` | — (`PAIRES` id/positionnement_id) |
| 37 | RecordClientDecision | `ctx.cible` | idem | — |
| 38 | WithdrawPositioning | `ctx.cible` | positionnement→besoin ← `id` | — ; même objet nommé `id` ici, `positionnement_id` en 36-37 (`positionnement_id` → `GARDE « identifiant manquant »`) |
| 39 | CreateProject | `societe_id` · `agence`,`agence_id` · `resolues.contact_id` · `resolues.besoin_id` | agence · societe ← `societe_id` · contact · besoin | — (S4, S15 : `DROIT`) ; la cohérence besoin/société n'est pas lue |
| 40 | CreateProjectFromNeed | `besoin_id` · `contact_id` | besoin ← `besoin_id` | ⛔ **`contact_id` non lu** (contrôlé « même société que le besoin ») : contact CAS pris (S15b) |
| 41 | UpdateProject | `id` · `contact_id`,`contact_technique_id`,`contact_facturation_id` · `intermediaire`,`intermediaire_facturation_id` | projet ← `id` | contacts « même société » ; ⛔ **intermédiaire non lu** : société CAS écrite (S10) |
| 42 | CloseProject | `id` | projet ← `id` | — (la cascade appelle `ClosePrestation` sans exiger sa permission, `projet.ts:155-166`, lu) |
| 43 | CreatePrestation | `projet_id` · `ressource`,`profil_ressource_id` | projet ← `projet_id` | ⛔ **ressource non lue** : ressource CAS staffée ×2, signée, occupation **200 %** (S8) |
| 44-46 | SignPrestation · ClosePrestation · CancelPrestation | `id` | prestation→projet ← `id` | — |
| 47 | RecordTimesheet | `prestation_id` | prestation→projet ← `prestation_id` | — ; `soi` cumulé : même code que 49 (lu) |
| 48 | AdjustTimesheetAfterClose | `prestation_id` | idem | — |
| 49 | RecordAbsence | `ressource_id`,`profil_ressource_id` | ressource ← mêmes, même ordre | hors `PAIRES` mais même ordre ; ⛔ `soi` cumulé : S19b |
| 50 | CreateAction | un seul des 6 porteurs | les 6, même liste | — |
| 51 | ArchiveObject | `type` · `id` | 4 lecteurs `id` + personne + action | — (S1) |
| 52-54 | SetPolicy · ManageRefs · ManageGroups | `cle` · `referentiel` · `groupe`,`permission`,`perimetre` | installation (global) | — |
| 55 | SetOwnTheme | clés `ui.*` | soi, `CLES_THEME` | — |

⭐ **Compte** : **5/55** reçoivent l'objet de la garde ; **13** écrivent une référence que la garde ne lit pas (2, 5, 14,
18, 19, 20, 24, 25, 34, 35, 40, 41, 43), **11 mesurées `ok:true`** vers CAS ; **3** passent le mur par `soi` cumulé
(23, 47, 49 — 2 mesurées) ; **2** ordres inverses, tous deux neutralisés par `PAIRES` (13, 19).

---

## Le journal `journal/PORTES.md` — P-326→P-331 en double

✅ **Mesuré** : `journal/PORTES.md:336-348` porte **14 lignes** (P-326 → P-338 hors P-332, plus P-325) pour **8 portes**
exécutées. P-333 → P-338 recopient **mot pour mot** P-326 → P-331 ; `audit7.test.ts` nomme ses tests « P-326 P-333 »,
« P-327 P-334 »… — **6 numéros de trop**, 6 portes comptées deux fois dans « le banc ». → N8-7.

---

## Compte

| Verdict | Nombre | Lesquels |
|---|---|---|
| **Fermé** | **4** | V-130 · V-131 · V-132 · V-135 |
| **Partiel** | **4** | V-128 · V-129 · V-133 (lu) · V-136 |
| **Ouvert** | **1** | V-134 (= V-120, élargi) |
| **Bonne** | V-137 tient sur ce qui a été rejoué | |
| Restes | **Tiennent** V-107 V-108 V-111 V-113/124 V-114 · **Fermé** V-126 · **Partiels** V-019 V-077/112 V-115 V-119 · **Ouverts** V-118 V-120/110 N4-2 N4-5 N6-4 N6-5 N7-8 N7-9 · V-022 assumé | |

### Critiques encore ouverts

| # | État | Pourquoi |
|---|---|---|
| **N8-1** (neuf, famille V-128) | ⛔ **Ouvert, critique** | au réglage par défaut, `ia` + `staf` + `dp` (PAR) requalifient **client** une société CAS et son contact CAS ; événement `ClientStatusDerived` signé `dp@ava.test` (S15b) |
| **N8-3** (neuf, famille V-129) | ⛔ **Ouvert, critique** | `RES` + un groupe PAR = écriture dans CAS par `UploadDocument` et `RecordAbsence` (S19, S19b) |
| **V-128** | ⚠️ Partiel | fermé pour le cas mesuré au 7ᵉ ; règles 2 et 3 de D-32 non codées |
| **V-077** | Partiel, 8ᵉ tour | le cliquet n'a toujours aucun témoin exécuté par un tiers |

---

## Constats neufs candidats

| # | Défaut · une phrase | Cible | Gravité | Preuve | Reproduire | Correction |
|---|---|---|---|---|---|---|
| **N8-1** | **Une société CAS devient « client » par trois comptes PAR, au réglage par défaut** : `CreateNeed` ne lit pas l'agence de `societe_id`, `CreateProjectFromNeed` ne lit pas celle de `contact_id`, et la signature propage sur la société et le contact | CODE | **critique** (mur percé, réglage par défaut) | `besoin.ts:30` (`societe_id` non lu ; ligne `CreateNeed` = `creation([agence(…)])`, `agence.ts:122`) ; `projet.ts:92` ; `effetsSignature` `projet.ts:184-263`. **Mesuré** : `RequalifyCompany` direct → `DROIT` ; `CreateNeed {societe_id: CAS, agence: PAR}` → `ok` ; `PositionResource` (staf) → `DeclareCVShared` + `RecordClientDecision retenu` (ia) → `CreateProjectFromNeed {contact_id: contact CAS}` (dp) → projet **PAR** sur société **CAS** et contact **CAS** → `SignPrestation` → société CAS `prospect → client`, contact CAS `→ client`, `ClientStatusDerived` par `dp@ava.test`. En mode `par_besoins`, le même besoin donne à IA `UpdateCompany` sur la société CAS → `ok`, secteur réécrit (S14). Incohérence : `CreateProject` sur la même société → `DROIT` (S15). Canon : D-32 règle 3 nomme `societe_id` ; simulation S13/S14 (« CreateNeed sur Zeta, agence B : refus ») | `bash rapport/preuves/suivi8/30_sondes_d32.sh` puis `31_sonde_chaine_societe_cas.sh <T>` | lire l'agence de `societe_id` dans `CreateNeed` (selon `societe.perimetre.mode`) ; lire `contact_id` dans `CreateProjectFromNeed` ; ⭐ appliquer la règle 3 : **toute clé d'identifiant écrite a un lecteur**, sinon `GARDE` ; une porte par commande qui envoie un objet CAS dans chaque référence et exige `DROIT`, 0 écriture |
| **N8-2** | **Onze autres références écrites sans garde** : un compte PAR staffe une ressource CAS, positionne un candidat et une ressource CAS, pose une société CAS en intermédiaire ou en fournisseur, un compte CAS en manager ou responsable RH, une unité sous une société CAS, une qualification sur une personne CAS | CODE | **elevee** | Table des 55, lignes 2, 5, 14, 18, 19, 20, 24, 34, 35, 41, 43. **Mesuré `ok:true`** : S7 (unité PAR sous société CAS), S8 (ressource CAS ×2, signée, occupation **200 %**), S9 (×2), S10, S11 (×2), S12, S13. Canon : D-32 règle 3 ; MATRICE étape 4 (`MATRICE_DROITS_v1.md:43`) ; « aucun de ces comptes n'a de contribution dans l'agence B avant une délégation explicite » (`CADRAGE_METIER_RECONCILIE_2026-09-16.md:243`). ⚠️ Staffer une ressource d'une autre agence peut être voulu : alors il faut l'écrire (délégation ou politique), pas le laisser passer par omission | S7-S13 du même script | un lecteur par référence dans `CORRESPONDANCE` (ressource, profils, société, compte) ; si le staffing inter-agences est voulu : une politique qui le dit, et le droit exigé dans l'agence de la ressource |
| **N8-3** | **`soi` cumulé ouvre toute agence** : pour `UploadDocument`, `RecordTimesheet`, `RecordAbsence`, `soi` couvre toute agence (`droits.ts:33`) et `exigeSoiMeme` ne s'applique plus dès que le compte a un autre périmètre (`droits.ts:63`) | CODE | **critique** (écriture dans CAS ; deux groupes du seed suffisent) | Compte `RES`+`STAF` (PAR) : document sur la société CAS et sur le candidat CAS → `ok` ×2, `STAF` seul → `DROIT` (S19) ; compte `RES`+`RH` (PAR) : absence sur ressource CAS → `ok`, `RH` seul → `DROIT` (S19b). Un salarié qui saisit ses propres temps (`RES`) et a un rôle d'agence est le cas ordinaire | `30_…` S19, `32_sondes_complement.sh` | `soi` ne couvre **aucune** agence dans `aLeDroit` ; la couverture `soi` se juge **seulement** sur l'objet du compte, indépendamment des autres périmètres ; porte : compte `RES`+`RH` sur une ressource CAS → `DROIT` |
| **N8-4** | **La liste blanche commune casse le contrat L4** : des clés que les commandes lisent, et que L4 prévoit, sont refusées « entrée ambiguë » ; `temps.facturable.mode = saisie_separee` rend **toute** saisie de temps impossible | CODE | **elevee** | Clés lues hors `CLES_COMMUNES` (calcul sur les 55) : `mesures` (L4 `:112`), `facturable`/`quantite_facturable` (L4 `:174`), `contexte`, `disponibilite_code`, `cjm_devise`/`cjm_devise_code`, `date_signature`, `chemin_stockage`, `tel`, `unite_id`… **Mesuré** : 6 commandes, 7 appels → `GARDE « entrée ambiguë »` (S17) ; en `saisie_separee`, avec la clé → `GARDE « entrée ambiguë »`, sans → `GARDE « quantité facturable exigée »` : **aucune entrée ne passe**. Aucune porte ne l'a vu (P-327 n'envoie qu'`intrus`) | S17 | une liste **par commande**, dérivée de ses lectures (ou de L4) ; une porte qui envoie chaque clé de L4 à sa commande et n'accepte pas « entrée ambiguë » |
| **N8-5** | **D-32 règles 1 et 2 appliquées à moitié** : une seule liste pour 55 commandes (une commande accepte les clés des autres), 3 paires pour une douzaine d'alias, 50 commandes relisent l'entrée | CODE | **moyenne** | `agence.ts:178-202`, `:229-233` ; `UpdateNeed` accepte `cle`, `groupe`, `permission`, `perimetre` → `ok` (S16) ; `TransferContact` avec deux sociétés différentes → `ok` (S2) ; `CreateCompany {manager_compte_id}` ignoré en silence (S4) ; même objet `id` / `positionnement_id` selon la commande (lignes 36-38) | S2, S4, S16 | la ligne de chaque commande déclare ses clés et ses alias ; la commande ne lit que `ctx.cible` / `ctx.resolues` |
| **N8-6** | **Les gardiens restent aveugles** : la recopie d'agence de `TransferContact` et la suppression du repli ne font tomber aucune porte ; P-331, écrite pour V-134, efface elle-même deux délégations | CODE (banc) | **elevee** | M2 **0/43**, M3 **0/222** ; `40_v120_PAR.txt` : 6 fichiers sur 8 effacent, dont `audit7` (P-331 : `survit` pose sur CAS puis retire sur PAR — jamais le même périmètre, le défaut de P-324 au 7ᵉ) ; le banc laisse `ADM ArchiveObject global` | `60_mutations.sh`, `40_v120.sh <périmètre>` | P-323/P-330 : après un transfert permis, relire `contact.agence_responsable_id` = CAS ; une porte `objet` avec un id que le lecteur ne trouve pas → `INTROUVABLE` ; P-331 : poser **sur PAR**, lancer chaque fichier, recompter ; photographier avant `accorder`, ne retirer que ce qu'on a créé |
| **N8-7** | **Le journal compte 6 portes deux fois** : P-333 → P-338 = P-326 → P-331 | BRAIN (greffe) | **basse** | `journal/PORTES.md:336-348` ; titres « P-326 P-333 »… (`audit7.test.ts:36-180`) | `grep -n "P-3[23][0-9]" journal/PORTES.md` | un numéro = une porte ; retirer les doublons, le cliquet F12 compte des numéros distincts |
| **N8-8** | `CloseProject` en cascade clôt les prestations sans exiger `ClosePrestation` | CODE | **basse** (lu) | `projet.ts:155-166` : `ctx.commande = "ClosePrestation"` puis appel direct du handler, sans `exigeDroit` ; défaut `prestations_closes`, DP a les deux droits au seed | lecture | exiger `ClosePrestation` dans la cascade, ou le dire dans la politique |

---

## Angles morts

| Non vérifié | Pourquoi |
|---|---|
| **`outils/cliquet.sh`, `outils/make.sh`** | interdits — V-077, V-112, V-133 (case 9), N4-5 reposent sur une lecture |
| **CI GitHub, Playwright (P-003/004/005), `web/`** | non exécutables ici ; `web/src` n'appelle aucune commande (grep) : N8-4 ne casse pas d'écran aujourd'hui |
| **`RecordTimesheet` en `soi` cumulé, `UpdateResource` `responsable_rh`, `ConvertCandidateToResource` fournisseur** | lus (même code que les cas mesurés), non sondés |
| **Mode `partagee` de `societe.perimetre.mode`** | non sondé ; `par_besoins` sondé une fois (S14) puis rétabli |
| **Modèle société sous sabotage, 15 sabotages SQL, 69-70 sabotages du banc** | non rejoués ; 5 mutations jouées (M1-M5) |
| **P-148** | exige `test/test-results/`, que je n'ai pas créé dans le clone (clone intouchable) |
| **Données et droits posés par moi dans `ava_audit8_a`** | ⚠️ déclarés : agence CAS et périmètre CAS (ids de `db.ts`) ; 2 comptes CAS `cas-a8…`/`cas-b8…@ava.test` et 2 groupes `CAS-…` avec 12 puis 6 droits sur le périmètre CAS, **en SQL** (lignes de données) ; 2 comptes cumulés `cumul-…` (`RES`+`STAF`) et `cumulrh-…` (`RES`+`RH`), agence PAR, désactivés après usage ; par `ManageGroups` : IA × `ArchiveObject` (PAR, retiré), `TransferContact` et `ArchiveService` (CAS, retirés), puis les 6 délégations de V-120 sur PAR et sur global (posées, mesurées, retirées) ; `SetPolicy` `societe.perimetre.mode` et `temps.facturable.mode` posés puis **rétablis** (0 écart). ⭐ **La base a été reconstruite à neuf en fin d'audit** : rien de tout cela n'y reste. Aucun `CREATE/ALTER/DROP ROLE` à la main |
| **Rôles globaux au cluster** | `007` fait `ALTER ROLE ava_serveur …` à chaque construction ; une construction a échoué 16 fois de suite pendant qu'un autre poste rejouait les migrations — rejouée avec reprise (`02_reconstruire.sh`), 16 × `rc=0` |
| **Artefacts de poste** | ① `psql` sous Git Bash : un libellé accentué dans une requête casse l'encodage (une ligne S3 perdue, l'état est relu par S3 lui-même) ; ② `sed -i` sur la copie jetable convertit les fins de ligne (le diff montre tout le fichier, la ligne mutée est vérifiée à part) ; ③ les serveurs arrêtés finissent « exit 127 » : c'est l'arrêt |
