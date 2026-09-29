# Neuvième audit — suivi des constats et trous de la porte croisée, sur `071b7b2` (branche `lot-2`)

⛔ **La porte croisée est verte (55 commandes, 117 identifiants, 0 fuite) et le mur est encore percé à 4 endroits mesurés.**
Elle ne voit que ce que `server/src/agence.ts` DÉCLARE, au SEUL réglage par défaut, sur les seules commandes POST.
Mesuré : un identifiant ajouté sans lecteur écrit une société LYO **sous porte verte** (mutation MB) ; au réglage
`partagee`, un compte PAR modifie un projet LYO, un besoin LYO, crée un projet LYO et convertit un candidat LYO en
ajoutant un `contact_id` ou un fournisseur ; une société LYO passe « client » par un compte PAR **au réglage par défaut** ;
un compte SUP qui n'a que `SetOwnTheme` lit les 84 besoins des deux agences.

Auditeur indépendant. Code lu dans `ava-audit-9-lecture` sur `071b7b2` — `git status` **vide** au début et à la fin.
Base `ava_audit9_a` construite depuis rien (17 migrations `rc=0`, puis `db/fixtures/banc.sql` `rc=0`), serveur port 3901.
Mutations sur une copie jetable (`git archive 071b7b2`, `node_modules` en jonction, jonctions retirées, cible vérifiée
intacte). Base **reconstruite à neuf en fin d'audit** (`preuves/suivi9/99_reconstruction_finale.txt`, 18 × `rc=0`).
Sorties : `rapport/preuves/suivi9/` (NN_*.txt), scripts : `rapport/preuves/suivi9/scripts/`.

## Ce qui a tourné

| Quoi | Résultat | Preuve |
|---|---|---|
| Porte croisée P-339 sur code intact | **1/1 verte** — 55 commandes · 117 identifiants hors agence · 0 fuite · 0 positif KO | `10_porte_croisee.txt` |
| Mesure statique (lectures de `ctx.entree` contre `CLES` et `lecteurs`) | 157 lectures directes, 29 commandes relisent `id`, 17 lignes gardent des synonymes | `20_statique.txt`, `scripts/statique.mjs` |
| Sondes HTTP (V-139, V-140, V-145, T1, T2, T4, T5, restes) | voir tableaux | `30_sondes_*.txt`, `scripts/sondes9.mjs` |
| Survie de 6 délégations, 8 fichiers du banc | 6/8 fichiers effacent | `42_v142_survie_PAR.txt` |
| Mutations MA, MB, M2 | MA : 1 porte tombe · **MB : 0** · **M2 : 0/156** | `51_*`, `54_*`, `57_M2_resume.txt` |
| Hors banc (sans `AVA_MODE`) | **165/165 POST en 401**, 12 GET en 401, `/sante` 200, 0 événement écrit | `61_hors_banc.txt` |

---

## (1) SUIVI_V — les 9 constats du 8ᵉ audit

| Constat | Gravité | Verdict | Preuve |
|---|---|---|---|
| **V-138** la garde ne lit pas ce que la commande écrit (17 fuites) | critique | ⚠️ **Partiel** | ✅ Les 17 fuites du 8ᵉ sont fermées au réglage par défaut : porte croisée **0 fuite / 117** (`10_*`). ⛔ La correction de construction demandée n'est pas faite : **29 commandes relisent `id` dans l'entrée**, `CreateAction` relit ses 6 porteurs par `opt(ctx.entree, c)` (`admin.ts:57,60`), `UpdateProject` relit ses 3 contacts (`projet.ts:110`) — 157 lectures directes (`20_statique.txt`) contre la règle affichée `kernel.ts:34,74` ; **17 lignes** gardent des synonymes alors que D-37 dit « il n'y en a plus » ; aucune porte statique (cliquet : 17 cases, aucune sur `ctx.entree`). Et la garde remplace le verdict d'un projet par celui d'une société (**T1** ci-dessous, 4 fuites mesurées hors défaut) |
| **V-139** `soi` + un périmètre d'agence ouvre toutes les agences | critique | ✅ **Fermé** | Compte `RES`+`STAF` (PAR) : document sur société LYO → `DROIT`, sur candidat LYO → `DROIT` ; `RES`+`RH` : absence ressource LYO → `DROIT`, temps prestation LYO → `DROIT` ; témoin absence **sur soi** → `ok` ; `{personne_id: soi, projet_id: LYO}` → `GARDE « exactement un porteur »` (`30_sondes_v139.txt`). ⚠️ `droits.ts:75` sort toujours de `exigeSoiMeme` dès qu'un autre périmètre existe : c'est désormais `exigerToutes` (`agence.ts:661`) qui tient, et `soiSurCettePersonne` décide sur l'entrée brute (`agence.ts:507-528`) |
| **V-140** la liste commune refuse 10 clés du contrat | elevee | ⚠️ **Partiel** | ✅ Liste par commande (`agence.ts:233-289`) ; `saisie_separee` + `facturable` → `ok` ; `contexte` → `ok` ; prestation née `cloturee` → `GARDE` (`30_sondes_v140.txt`). ⛔ `RecordQualification.commentaire` est **lu** par la commande (`identite.ts:441`) et **refusé** par la liste → `GARDE « entrée ambiguë »`. ⛔ `mesures` est admis mais **aucune valeur ne passe** sur base neuve : `ref_competence` est vide et `ManageRefs` ne peut pas y créer la première valeur (`GARDE « catégorie inconnue »`) ; `mesures` en chaîne ou en objet → **HTTP 500** « erreur interne » (`02_serveur.log` : `mesures is not iterable`, `NOT NULL competence_code`) |
| **V-141** six portes inscrites deux fois | elevee | ✅ **Fermé** | `journal/PORTES.md` : 336 lignes `P-`, **0 doublon** ; P-333→P-338 absentes (`40_restes_lus.txt`). Remarque : un titre porte deux numéros, `correctifs.test.ts:725` « P-143 M1 P-002 … » (P-002 y est le sujet) ; la case 16 le compterait (`cliquet.sh:465`) — cliquet non exécuté |
| **V-142** le banc efface des délégations qu'il n'a pas posées | elevee | ⛔ **Ouvert — 4ᵉ tour, pire** | 6 délégations posées par `ManageGroups` sur PAR avant chaque fichier : `matrice` **6→1**, `audit4` **6→1**, `audit3` **6→1**, `politiques` 6→4, `audit7` 6→4, `audit6` 6→5, `chemin` 6→6, `commandes` 6→6 — **toutes les suites vertes** (`42_v142_survie_PAR.txt`). Cause lue : la case 17 vérifie **où** est le `DELETE`, pas **ce qu'il retire** ; l'aide elle-même retire ce qu'elle n'a pas posé : `oter()` (`delegations.ts:115-122`), `suspendre()` (`:49-70`), appelées par `retirer()` (`monde.ts:65-69`) sans condition. Et la porte croisée **laisse 55 délégations** au groupe CROISE (« vide au seed ») |
| **V-143** 001/002 réécrites ; registre 173 vs 201 | moyenne | ✅ **Fermé** | `git diff origin/main HEAD -- 001 002` vide ; 5 migrations de `main` identiques ; ajouts dans 017 (`41_v143.txt`) ; 17 migrations `rc=0`. Registre 202 = base 202 (`dossier.py`, copie jetable). ⚠️ `_ops/ETAT_PROJET.md:54` dit encore « 173 politiques » |
| **V-144** `dossier.py` crie un écart de référentiels | moyenne | ✅ **Fermé** | Exécuté sur copie jetable : `referentiels=74 · ref_sql=74` ; base : 74 tables `ref_*` (`31_referentiels.txt`) |
| **V-145** `pole`/`equipe` ignorés | moyenne | ✅ **Fermé** | Périmètre pôle posé en SQL sur une unité interne → `ManageGroups` → `GARDE « périmètre non servi »` (`30_sondes_v145.txt`) ; `aLeDroit` ne couvre que `global`/`agence` (`droits.ts:30-31`, lu) |
| **V-146** bien fait | bonne | ⚠️ **Tient en partie** | ✅ Hors banc : 165/165 POST en 401, 12 GET en 401, `/sante` 200, 0 écrit, 0 tracé (`61_hors_banc.txt`) ; trailers `rc=0`, 247 commits, `ba9a284..071b7b2` **47/47** avec `Role:` (`43_trailers.txt`). ⛔ « 0 porte aveugle » : **rouge** — M2 0/156, MB porte croisée verte avec fuite |

## Les restes des tours précédents

| Constat | Gravité | Verdict | Preuve |
|---|---|---|---|
| **N8-1** société CAS « client » par trois comptes PAR | critique | ⚠️ **Partiel** | Direct au défaut : `CreateNeed` société LYO → `DROIT` (porte). ⛔ Vivant par une référence recopiée : **T4** (société LYO `prospect→client`, contact LYO `→client`, `ClientStatusDerived` signé `croise@ava.test`, réglage **par défaut** au moment de la signature) |
| **N8-8** `CloseProject` en cascade sans `ClosePrestation` | basse | ⛔ **Ouvert, mesuré** | Compte au seul droit `CloseProject` (PAR), `projet.cloture.garde = cascade_cloture_prestations` → `ok`, prestation `signee → cloturee` (`30_sondes_restes.txt`) ; `projet.ts:155-166` inchangé |
| **V-118** repli non gardé | elevee | Non rejoué (mutation) | Lu : plus de repli (`agence.ts:648` → `INTROUVABLE`) ; mesuré : `CreateNeed` société inexistante et `UpdateCompany` id inexistant → `INTROUVABLE` |
| **V-119** recopie d'agence de `TransferContact` non gardée | elevee | ⚠️ **Partiel** | Mutation **M2** (recopie `agence_responsable_id` retirée, `crm.ts:395`) : porte croisée, `audit7`, `audit6`, `audit4`, `matrice`, `chemin` → **0/156** (`57_M2_resume.txt`) |
| **V-120 / V-134** délégations effacées | elevee | ⛔ **Ouvert** | = V-142 |
| **V-107** repli sur l'agence du demandeur | critique | ✅ **Tient** | `ctx.compte.agence_id` : 2 lignes, `agence.ts:363` (`exigeSoi`) et `:634` (création sans objet) |
| **V-108** société et contact sans agence | critique | ✅ **Tient au défaut** | porte croisée ; ⛔ hors défaut : T1 |
| **V-111** doublons de migrations | elevee | ✅ **Tient** | 17 fichiers, 17 numéros, 0 doublon |
| **V-113 / V-124** trailers | moyenne | ✅ **Tient** | `verif_trailers.sh` `rc=0` |
| **V-115** permissions sans titulaire | moyenne | ⚠️ **Partiel, +1** | **5** sur base neuve (hors CROISE) : `ArchiveCompany`, `ArchiveContact`, `ArchiveObject`, `ArchiveService`, `UpdateResourceCost` (4 au 8ᵉ) |
| **V-022** `pg_hba` en `trust` | elevee | Ouvert, assumé et gardé | `verif_serveur.sh` → `rc=1` (13 lignes trust) ; `AVA_POSTE_DEV=1` → `rc=0` (`44_*`) |
| **V-019** portes écran | elevee | Partiel | Playwright hors périmètre |
| **V-077 / V-112 / V-133** cliquet | elevee | Partiel | exécution interdite ; lu seulement |
| **N4-2** catégorie auto-référentielle | elevee | ⛔ **Ouvert, élargi** | `ref_pays` + `afrique` → `GARDE`. ⭐ Famille mesurée : **4 référentiels vides, sans catégorie ni `ck_cat`** (`ref_competence`, `ref_mobilite`, `ref_outil_technique`, `ref_type_avantage`) — `ManageRefs` n'y crée **aucune** première valeur ; ils portent 8 clés étrangères (dont `qualification_mesure`, `besoin_competence`, `candidat_outil`) |
| **N4-5** F12 repliée sur HEAD | moyenne | ⛔ Ouvert (lu) | `cliquet.sh:333` |
| **N6-4** registre des migrations | moyenne | ⛔ Ouvert | `schema_migrations` absente (ava et public) |
| **N6-5** 56 permissions, 55 commandes | basse | ⛔ Ouvert | `permission` = 56 |
| **N7-3** agence écrite = celle du compte | moyenne | ⛔ Ouvert, mesuré | T5 ci-dessous |
| **N7-8** impasses fermées par défaut | basse | ⛔ Ouvert | `ArchiveObject` personne sans profil, acteur à 55 droits PAR → `DROIT` |
| **N7-9** P-148 en clone propre | basse | Non vérifié | clone intouchable |

## Compte

| Verdict | Nombre | Lesquels |
|---|---|---|
| **Fermé** | **5** | V-139 · V-141 · V-143 · V-144 · V-145 |
| **Partiel** | **3** | V-138 · V-140 · V-146 (bonne, tient en partie) |
| **Ouvert** | **1** | V-142 (4ᵉ tour, 6→1) |
| Restes | Tiennent V-107 V-108 V-111 V-113/124 · Partiels N8-1 V-119 V-115 V-019 V-077/112/133 · Ouverts N8-8 V-120/134 N4-2 (élargi) N4-5 N6-4 N6-5 N7-3 N7-8 · V-022 assumé · non rejoués V-118 N7-9 | |

---

## (2) Ce que la porte croisée ne couvre pas

⭐ **La porte est complète sur UNE projection : commandes POST × identifiants DÉCLARÉS × réglage par défaut × acteur
mono-agence.** Chaque trou ci-dessous est hors de cette projection. Sonde : acteur `croise@ava.test` (55 droits sur PAR,
posés par la porte), objets de l'autre agence = LYO.

### T0 — La porte ne voit pas un identifiant qui n'est pas déclaré ⛔ elevee (gardien aveugle par construction)

| | |
|---|---|
| Mesure | **Mutation MB** : `UpdateResource` admet `societe_fournisseur_id` (une clé dans `CLES`) et l'écrit par `opt(ctx.entree, …)`, sans lecteur. Porte croisée : **verte, 117 identifiants, 0 fuite** (`54_MB_porte_croisee.txt`) ; appel direct : ressource **PAR** avec fournisseur **LYO**, `ok` (`55_MB_sonde.txt`). Mutation MA (lecteur `intermédiaire` retiré) : la porte tombe **seulement** parce que le cas est écrit à la main depuis l'audit 8, et son alias `intermediaire` **disparaît** de la couverture (117 → 116 identifiants, `51_*`) |
| Famille | **Trois listes pour un même objet, aucune ne dérive des autres** : ce que la commande admet (`CLES`, `agence.ts:233`), ce que la garde juge (`lecteurs`), ce que la commande lit (`req`/`opt`/`ctx.entree.x`). La porte tire ses cas de la 2ᵉ ; la fuite naît dans l'écart entre la 1ʳᵉ et la 3ᵉ |
| Étendue | 55 lignes × 3 listes ; **157** lectures directes de `ctx.entree` dans `server/src/commandes` ; **29** commandes relisent `id` ; 3 lectures dynamiques (`admin.ts:57,60`, `projet.ts:110`) ; côté garde, 2 lectures hors lecteurs (`personneVisee`, `agence.ts:507-528` ; `ArchiveObject` `type`/`id`, `:560-561`) ; **0** porte statique (la « porte dans le code » de D-37 n'existe pas) |
| Correction de construction | ⭐ **Une seule déclaration par commande, typée** : chaque clé d'entrée est soit un *identifiant* (table + lecteur), soit un *scalaire* (type). `CLES` est **calculé** depuis cette déclaration, jamais écrit à côté. La commande reçoit un objet `entree` **gelé et typé** construit par la garde (identifiants résolus, scalaires validés) ; `ctx.entree` n'est plus exposé aux handlers (type `Ctx` sans `entree`) — la relecture devient une erreur de compilation. Synonymes : un seul nom, l'alias refusé |
| Porte | (1) statique : `grep -c "ctx\.entree" server/src/commandes` = **0** (et `tsc` échoue si un handler y touche) ; (2) la porte croisée tire ses identifiants de la déclaration **et** des clés que le type d'entrée admet se terminant par `_id` ou typées identifiant : un identifiant admis sans lecteur → rouge ; (3) sabotage : MB rejouée → la porte doit tomber |

**Réponse à la question « un synonyme ajouté à `lecteurs` »** (lu, `agence.ts:327-341`) : `replier` recopie l'alias sur
le **premier** nom. Avec `["societe_id","id"]`, une entrée `{id}` devient `{societe_id}`, `id` est supprimé, et les 29
commandes qui font `req(ctx.entree,"id")` répondent `GARDE « Champ requis manquant »` : **fermé par accident, commande
cassée**. Avec `["id","societe_id"]`, `{societe_id}` est recopié sur `id` : cohérent. Le danger n'est pas là : il est
dans une clé admise par `CLES` sans lecteur (T0), que ni `replier` ni la porte ne voient.

### T1 — Au réglage `partagee` ou `par_besoins`, la garde remplace le verdict d'un projet par celui d'une société ⛔ critique (mur percé à un réglage du registre)

| | |
|---|---|
| Mesure | `societe.perimetre.mode = partagee` (`30_sondes_t1_bis.txt`) : `UpdateProject {id: projet LYO}` → `DROIT` ; **+ `contact_id` du projet → `ok`, titre LYO réécrit** · `UpdateNeed` besoin LYO → `DROIT` ; **+ `contact_id` → `ok`** · `CreateProjectFromNeed` besoin LYO → `DROIT` ; **+ `contact_id` → `ok`, 1 projet LYO créé** · `ConvertCandidateToResource` candidat LYO → `DROIT` ; **+ `societe_fournisseur_id` (société PAR) → `ok`, ressource créée**. `par_besoins` : l'acteur crée un besoin PAR sur la société du projet LYO (permis par le réglage), puis `UpdateProject` LYO + `contact_id` → **`ok`** (`A9 PB APRES` en base) ; sans contact → `DROIT` |
| Cause | `agence.ts:656-658` : si **un seul** objet d'agence a été lu et que le **dernier** objet trouvé est une société ou un contact, la garde appelle `modeSociete` avec l'agence du projet… qui, en `partagee`, ne la lit pas (`exigePartage`, `:476-478`) et, en `par_besoins`, lit les agences de besoin **de la société** (`:480-502`) |
| Famille | **Un verdict par commande au lieu d'un verdict par objet** : la garde agrège les objets lus dans des variables d'état (`lus`, `couvert`, `tableTrouve`, `agenceId`) puis prend UNE décision ; l'ordre des lecteurs et le type du dernier trouvé changent la règle appliquée aux autres |
| Étendue | **5 lignes** où un lecteur société/contact suit un lecteur d'objet d'agence (`20_statique.txt`) : `UpdateProject`, `UpdateNeed`, `CreateProjectFromNeed`, `ConvertCandidateToResource` (**4 mesurées `ok` hors agence**), `UploadDocument` (arrêtée par la commande : `GARDE « exactement un porteur »`). 2 réglages sur 3 de `societe.perimetre.mode` |
| Correction de construction | chaque objet résolu est jugé **seul**, par la règle de sa table (objet d'agence → droit dans son agence ; société/contact → `modeSociete` sur **cet** objet), et le verdict est la **conjonction** : une boucle `for (const o of resolus) await juger(o)` sans état partagé. Supprimer `:652-659` |
| Porte | la porte croisée joue **chaque valeur** des politiques lues par la garde (`societe.perimetre.mode` × 3, `staffing.inter_agences` × 2) — la liste vient des `pol(…)` appelés dans `agence.ts`, pas d'une liste écrite ; et chaque cas « hors agence » est rejoué **avec un compagnon dans l'agence** (contact, fournisseur, besoin PAR) pour chaque autre lecteur de la ligne |

### T2 — Les routes de lecture filtrent par « n'importe quel droit » ⛔ elevee (lecture hors agence)

| | |
|---|---|
| Mesure | `GET /vues/besoins` : `sup@ava.test` (seul droit : `SetOwnTheme` global) → **84 lignes, LYO:26 PAR:58**, fiche d'un besoin LYO → **200** avec titre et nom de la société ; `adm@ava.test` (4 droits d'installation) → idem ; `res@`, `eval@`, `croise@` (droits PAR) → 58 PAR, fiche LYO → 404 (`30_sondes_t2.txt`) |
| Cause | `index.ts:212-225` : `filtreAgence` prend **toutes** les permissions du compte, quel que soit leur code ; un seul droit `global` (même le thème) ouvre toutes les agences |
| Famille | **Une route hors commande décide seule de son filtre** : elle n'a pas de ligne de correspondance, pas de permission de lecture (la base en a une, `LireDonneesRHSensibles`, que rien ne lit), et aucune porte |
| Étendue | 2 routes de données sur 6 routes servies (`/vues/besoins`, `/vues/besoins/:id`) ; 0 porte sur un GET ; 55 commandes rendent aussi des vues (`vues.ts`), après succès seulement |
| Correction de construction | les routes de lecture passent par la **même** table que les commandes : une ligne `LireBesoins` (nature `lecture`, lecteur `besoin`) et une permission de lecture par type d'objet ; le filtre SQL est **généré** depuis `v_droits_effectifs` restreint à **cette** permission |
| Porte | la porte croisée énumère les routes enregistrées par Fastify (`app.printRoutes()` ou la liste des `app.get`) : pour chaque route de données, un acteur à droit PAR seul et un acteur au seul droit `SetOwnTheme` global ne voient **aucune** ligne LYO et reçoivent 404 sur une fiche LYO |

### T3 — Une référence recopiée depuis un objet stocké n'est jamais jugée ⛔ elevee (écriture en cascade hors agence)

| | |
|---|---|
| Mesure | Chaîne 100 % par commandes, acteur PAR (`30_sondes_t4_bis.txt`) : `par_besoins` le temps d'un `CreateNeed {société LYO, contact LYO, agence PAR}` → `ok` ; **retour au défaut** `agence_responsable` ; témoins `RequalifyCompany` et `UpdateCompany` société LYO → `DROIT` ; puis `PositionResource` → `DeclareCVShared` → `RecordClientDecision retenu` → `CreateProjectFromNeed` **sans** `contact_id` → `ok` (projet PAR · société LYO · contact LYO) → `CreatePrestation etat=signee` → **société LYO `prospect → client`, contact LYO `null → client`, `ClientStatusDerived` signé `croise@ava.test`** |
| Cause | `CreateProjectFromNeed` recopie `besoin.societe_id` et `besoin.contact_id` (`projet.ts:92,100`) sans les juger ; `effetsSignature` écrit `projet.societe_id`, tous ses contacts et `projet.besoin_id` (`projet.ts:184-280`) ; la garde de `SignPrestation`/`CreatePrestation` ne juge que le projet |
| Famille | **Une écriture en cascade suit une clé stockée, pas un objet résolu par la garde** ; ce qui était permis au réglage d'hier (ou par une reprise Boond) est recopié aujourd'hui sans verdict |
| Étendue | 3 cibles écrites par cascade (`societe`, `contact` ×N, `besoin`) depuis 2 commandes (`SignPrestation`, `CreatePrestation` en `signee`) ; 1 cascade `CloseProject → ClosePrestation` (même projet, droit non exigé : N8-8) ; 3 références recopiées par `CreateProjectFromNeed` ; **0 trigger** n'écrit une autre table (22 triggers `BEFORE`, tous sur la ligne elle-même — lu dans `db/migrations`) |
| Correction de construction | une commande déclare aussi ses **objets touchés par cascade** (`cascade: [{table, via}]` dans sa ligne) ; la garde les résout et les juge comme les autres, **avant** d'exécuter — ou la cascade n'écrit que dans l'agence du projet (politique explicite). Et `CreateProjectFromNeed` résout `besoin.societe_id`/`contact_id` par un lecteur `via` |
| Porte | pour chaque commande à cascade déclarée, un monde où l'objet atteint par la clé stockée est dans l'autre agence : empreinte de **sa** table inchangée. Liste des cascades = `UPDATE` des handlers dont la clé ne vient pas de `ctx.resolues` (mesure statique, rouge si non déclarée) |

### T4 — L'agence écrite n'est pas l'agence jugée ⚠️ moyenne

| | |
|---|---|
| Mesure | CROISE reçoit `ConvertCandidateToResource` et `CreateUnit` sur LYO (posés puis retirés) : conversion d'un candidat LYO avec `agence_id: LYO` → `ok`, **ressource écrite dans PAR** ; `CreateUnit` société LYO, `agence_id: LYO` → `ok`, **unité écrite dans PAR** (`30_sondes_t5.txt`) |
| Famille | la garde calcule l'agence d'écriture (`agence.ts:633-642`) et la commande la **recalcule** autrement (`identite.ts:207` : compte ; `crm.ts:173` : parent ou compte) ; une clé admise (`agence_id`) est jugée puis **ignorée** |
| Étendue | 2 commandes sur 9 qui insèrent un objet porteur d'agence (`ConvertCandidateToResource`, `CreateUnit`) ; les 7 autres écrivent l'agence résolue |
| Correction de construction | la garde pose `ctx.agenceEcrite` et c'est la **seule** source de l'agence insérée (le handler n'a plus accès à `ctx.compte.agence_id`) |
| Porte | pour chaque commande de création, relire en base l'agence de l'objet créé et exiger `= agence jugée` (positif avec un acteur dont l'agence d'attache diffère du périmètre délégué) |

### T5 — Valeurs imbriquées et référentiels vides ⚠️ moyenne (pas de fuite d'agence ; erreurs 500)

| | |
|---|---|
| Mesure | Aucune valeur imbriquée ne porte d'identifiant d'agence aujourd'hui (2 entrées non scalaires : `RecordQualification.mesures`, `SetOwnTheme ui.rail.outils`). Mais `mesures: "abc"` et `mesures: {}` → **HTTP 500** ; `mesures` valide impossible (référentiel vide) ; tout champ texte accepte un objet (`str()` → `"[object Object]"`, `kernel.ts:53-56`, lu) |
| Famille | l'entrée n'a pas de type : la liste de clés contrôle les **noms**, pas les **formes** ; un identifiant logé dans un objet ou un tableau passerait sous la garde, la liste et la porte |
| Étendue | 2 clés non scalaires ; 4 référentiels vides inutilisables (N4-2) |
| Correction de construction | la déclaration de T0 porte le **type** de chaque clé (scalaire, liste de `{competence_code: ref}`…) ; un identifiant imbriqué est déclaré avec son lecteur, résolu élément par élément |
| Porte | pour chaque clé non scalaire déclarée : une forme fausse → `GARDE` (jamais 500) ; pour chaque identifiant imbriqué, un élément pointé hors agence → `DROIT`, empreinte inchangée |

### Ce qui a été cherché et n'est PAS un trou

| Cherché | Mesure |
|---|---|
| (e) Une commande `creation`, `installation` ou `soi` écrit un objet existant | Non : les 7 `creation` font un `INSERT` (et lisent la personne existante, jugée par `tousProfils`) ; les 3 `installation` exigent `global` (`agence.ts:550-553`) ; `SetOwnTheme` n'écrit que le compte courant |
| (d) Trigger ou vue qui écrit une autre table | Non : 22 triggers, tous `BEFORE … ON <table>` sur `NEW` (contrôle ou recalcul de la ligne) |
| Confusion de type dans `ArchiveObject` (la garde ignore `type` pour 4 tables) | Non exploitable : identifiants `gen_random_uuid()` distincts d'une table à l'autre (lu) |
| `soi` décidé sur l'entrée brute | Latent seulement : toute entrée à deux porteurs est refusée par la commande (`GARDE « exactement un porteur »`, mesuré) |

---

## Angles morts

| Non vérifié ou posé par moi | Pourquoi / détail |
|---|---|
| `outils/cliquet.sh`, `outils/make.sh` | interdits ; cases 9, 11, 16, 17 lues seulement |
| Mutation M3 (repli, V-118), 71 sabotages du banc | non rejoués ; 3 mutations jouées (MA, MB, M2) |
| `staffing.inter_agences = oui` | non sondé (décision métier en attente) ; seuls `partagee` et `par_besoins` sondés |
| `/tuyau`, `/acquitter`, fichiers statiques | aucune donnée d'objet (lu) ; `web/dist` absent du clone |
| Reprise Boond comme source de besoins PAR sur société LYO | supposée, non mesurée ; T3 est reproduit par un réglage, pas par une reprise |
| Données posées dans `ava_audit9_a` (⚠️ déclarées) | objets « A9 » en SQL dans PAR et LYO ; 2 comptes cumulés `cumul-staf-…@a9.test` (`RES`+`STAF`) et `cumul-rh-…@a9.test` (`RES`+`RH`), désactivés ; 1 groupe `A9CLOSE…` (droit `CloseProject` PAR) et son compte `close-…@a9.test`, désactivé ; CROISE × {`ConvertCandidateToResource`, `CreateUnit`} sur LYO, posés puis retirés en SQL ; 5 délégations IA/DP sur PAR posées par `ManageGroups` puis retirées (la 6ᵉ, IA × `TransferContact`, est du seed et n'a pas été touchée) ; une unité interne et un périmètre `pole` ; politiques `societe.perimetre.mode`, `candidat.conversion.acteur`, `temps.facturable.mode`, `projet.cloture.garde` posées puis **rétablies** ; `mobilite = idf` écrit sur le profil « Banc RES » par une sonde. ⭐ **Base reconstruite à neuf en fin d'audit** : rien de tout cela n'y reste. Aucun `CREATE/ALTER/DROP ROLE` |
| Artefact de poste | mes premiers projets de sonde portaient une référence > 2³¹ : `nextRef` (`projet.ts:9`, `substring(reference from 5)::int`) a levé 500 sur `CreateProjectFromNeed` (`30_sondes_t1.txt`, `30_sondes_t4.txt`) ; renumérotés, rejoués (`*_bis.txt`). ⚠️ Fragilité réelle : une seule référence hors `int4` ou non numérique bloque **toute** création de projet |
| Serveurs arrêtés | finissent « exit 127 » : c'est l'arrêt forcé du processus |
