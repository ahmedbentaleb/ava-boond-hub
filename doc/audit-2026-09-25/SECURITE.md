# SECURITE8 — famille I : le périmètre par objet, avec toutes les permissions posées

**15 champs d'identifiant, sur 12 des 55 commandes, écrivent dans une autre agence ; et `soi` + une permission d'agence donne l'accès GLOBAL sur les trois commandes « S ».**
La porte systématique existe désormais : `rapport/preuves/securite8/croise_55.mjs` — 55 commandes, 96 champs pointés hors agence, 69 contrôles positifs ; rejouable en 26 s.

---

## 0 · Déclaration — ce qui a été posé avant de mesurer

| Étape | Comment | Preuve |
|---|---|---|
| Seconde agence LYO + son périmètre + un compte LYO **sans groupe** | SQL en `postgres` (aucune commande ne crée d'agence au lot 2) | `securite8/00_seconde_agence.sql` |
| ⭐ **Les 55 permissions** au groupe RH, périmètre **agence PAR** | `ManageGroups` par `adm@ava.test` (ADM global), 55 appels, **55 ok** | `securite8/01_permissions_posees.txt` |
| Acteur | `rh@ava.test` : TOUTES les commandes, sur PAR, rien sur LYO | — |
| Objets | posés en `postgres`, **frais pour chaque cas**, un monde PAR et un monde LYO de même état | `securite8/monde8.mjs` |
| « Rien écrit » | empreinte (count + md5) de **toutes** les tables `ava` sauf `tentative_refusee`, avant/après chaque appel | `monde8.mjs` `empreinte()` |

⚠️ Un groupe porte un périmètre **absolu** (une agence nommée), pas « l'agence du compte » : un compte de LYO mis dans le groupe IA agit sur PAR. C'est le modèle (MATRICE « IA : ses agences ») ; il explique pourquoi le compte LYO n'a aucun groupe.

## 1 · La porte systématique — `croise_55`

| Mesure | Nombre |
|---|---|
| commandes couvertes | **55 / 55** |
| champs d'identifiant pointés vers LYO (un par `req/opt` d'objet du handler ; UploadDocument ×5 porteurs, CreateAction ×6, ArchiveObject ×6 types) | **96** |
| → DROIT ou GARDE, empreinte inchangée | **79** |
| → **ok, écrit** | **17**, dont **15 fuites réelles** et 2 entrées ignorées (écrit dans PAR : CONFORMITE8 H-4, H-5) |
| → autre code | 0 |
| contrôles positifs dans PAR | **69 / 69** ok |
| installation (SetPolicy, ManageRefs, ManageGroups) avec permission sur **agence** | 3 / 3 → DROIT (il faut `global`) |

Sortie : `securite8/croise_55.md` (une ligne par cas, code, message, tables écrites) · `croise_55.json` · passe 1 conservée (`croise_55_passe1.md` : deux positifs faux à cause d'une fixture, voir I-10).

**Les 15 fuites** (écrit alors que l'acteur n'a rien sur LYO) :

| # | Commande | Champ pointé vers LYO | Tables écrites | Constat |
|---|---|---|---|---|
| 1 | CreateNeed | `societe_id` | besoin | I-2 |
| 2 | CreateUnit | `societe_id` | unite_organisation | I-2 |
| 3 | PositionCandidate | `profil_candidat_id` | positionnement, besoin | I-3 |
| 4 | PositionResource | `profil_ressource_id` | positionnement, besoin | I-3 |
| 5 | CreatePrestation | `profil_ressource_id` | prestation | I-3 |
| 6 | RecordQualification | `personne_id` (avec un `besoin_id` de PAR) | qualification | I-4 |
| 7 | CreateCandidate | `personne_id` (personne à profil LYO) | profil_candidat | I-5 |
| 8 | CreateResource | `personne_id` (personne à profil LYO) | profil_ressource | I-5 |
| 9-10 | UpdateCompany | `manager` / `manager_compte_id` (compte LYO) | societe | I-6 |
| 11 | UpdateCandidate | `responsable_rh_compte_id` | profil_candidat | I-6 |
| 12 | UpdateResource | `responsable_rh_compte_id` | profil_ressource | I-6 |
| 13 | ConvertCandidateToResource | `societe_fournisseur_id` | profil_ressource | I-7 |
| 14 | CreateResource | `societe_fournisseur_id` | profil_ressource | I-7 |
| 15 | UpdateProject | `intermediaire_facturation_id` | projet | I-7 |

---

## 2 · Les constats

### I-1 · `soi` + une permission d'agence = GLOBAL sur UploadDocument, RecordTimesheet, RecordAbsence — critique
- **défaut** : `aLeDroit` fait couvrir **toute agence** par une ligne `soi` dès que la commande est dans `SOI_MEME` ; `exigeSoiMeme` se retire dès que le compte a UNE autre ligne que `soi` pour la commande. Les deux ensemble : plus aucune borne.
- **cible** : `server/src/droits.ts:28-35` (`(r.type_code === "soi" && SOI_MEME.has(commande))`) et `:63` (`droits.some((d) => d.type_code !== "soi")) return;`).
- **famille** : I · **gravité** : critique.
- **preuve** : `securite8/soi_v129.out`.

| Cas | Attendu | Mesuré |
|---|---|---|
| RES (soi seul) : sa prestation PAR / sa prestation LYO | ok / ok | ok / ok ✅ |
| RES (soi seul) : prestation, absence, document d'un AUTRE, PAR ou LYO | DROIT | DROIT ✅ (×4) |
| ADM ajoute à RES ces 3 commandes sur **agence PAR** (`ManageGroups`, ok) | — | — |
| RES : `RecordTimesheet` d'un autre, **dans LYO** | DROIT | ⛔ **ok** (temps écrit) |
| RES : `RecordAbsence` d'un autre, **dans LYO** | DROIT | ⛔ **ok** |
| RES : `UploadDocument` sur le profil d'un autre, **dans LYO** | DROIT | ⛔ **ok** |
| Union réaliste : `dp@` (DP, UploadDocument sur PAR) devient aussi RES (il est lui-même ressource) — avant / après | DROIT / DROIT | DROIT / ⛔ **ok** sur un profil LYO |

- **reproduire** : `bash rapport/preuves/securite8/soi_v129.sh` (serveur banc :3802, seconde agence posée).
- **prétend** : V-129 « le périmètre soi ne vaut plus global » ; `droits.ts` « `soi` ne couvre aucune agence (D-33) » ; MATRICE procédure §4 « Lire sur B et écrire sur A ne donne jamais écrire sur B ».
- **mesure** : `soi` seul tient ; `soi` **en union** avec n'importe quelle agence vaut global. Un manager qui est aussi ressource (cas nommé par la MATRICE : les rôles se cumulent) écrit les documents et les temps de toutes les agences.
- **correction** : `soi` ne couvre jamais une agence dans `aLeDroit` ; la décision « soi » se prend ligne par ligne : une ligne `soi` n'autorise que l'objet du compte, une ligne `agence` n'autorise que son agence — et le refus seulement si AUCUNE ligne n'autorise. Porte : soi + agence A, objet d'un autre dans B → DROIT.

### I-2 · CreateNeed et CreateUnit ne jugent pas la société — critique (élevée sous la politique par défaut)
- **défaut** : la ligne de `CORRESPONDANCE` de CreateNeed ne lit que l'agence ; celle de CreateUnit que le parent et l'agence. `societe_id` n'est jamais jugé — alors que CreateProject, CreateContact, TransferContact le jugent.
- **cible** : `server/src/agence.ts` (`CreateNeed: creation([agence(...)])`, `CreateUnit: creation([col("unite_organisation", ["parent_id"])], …)`).
- **famille** : I · **gravité** : critique.
- **preuve** : `croise_55.md` lignes CreateNeed/`societe_id`, CreateUnit/`societe_id` → ok. **Chaîne** (`securite8/chaine_par_besoins.txt`, passe 2) sous `societe.perimetre.mode = par_besoins` (valeur du registre) :

| Pas | ia@ (PAR) sur une société de LYO | Mesuré |
|---|---|---|
| a | `UpdateCompany` | DROIT |
| b | `CreateNeed` (besoin dans PAR, société LYO) | ok — non gardé |
| c | `UpdateCompany` | ⛔ **ok** — nom de la société LYO réécrit |
| e | même appel sous `agence_responsable` (défaut) | DROIT |

- **reproduire** : `croise_55.mjs` ; la chaîne : commandes de `chaine_par_besoins.txt`.
- **prétend** : registre `societe.perimetre.mode` — défaut `agence_responsable` : « comment on juge le périmètre d'une société » ; P-328 « CreateProject vers un besoin d'une autre agence → DROIT ».
- **mesure** : sous le défaut, un besoin et une unité de PAR s'accrochent à une société de LYO ; sous `par_besoins`, ce besoin **donne** à PAR les droits sur la société de LYO.
- **correction** : `resp("societe", ["societe_id"])` dans les deux lignes, jugé par `modeSociete` comme pour CreateContact.

### I-3 · Le staffing traverse les agences : positionner et affecter un profil de LYO — élevée
- **défaut** : PositionCandidate, PositionResource, CreatePrestation ne lisent que le besoin / le projet ; le profil n'est jamais jugé.
- **cible** : `server/src/agence.ts` (`PositionCandidate`, `PositionResource`, `CreatePrestation`) · **gravité** : élevée.
- **preuve** : `croise_55.md` → ok, `positionnement` / `prestation` écrits avec un profil de LYO (et `besoin` passé en recherche par effet).
- **prétend** : MATRICE §4 (S14) ; aucune politique « inter-agence » au registre.
- **mesure** : PAR engage une ressource de LYO sur un projet de PAR, avec son CJM, sans aucun droit sur LYO ; le positionnement ouvre ensuite ConvertCandidateToResource.
- **correction** : juger le profil (lecteur `col("profil_candidat" | "profil_ressource", …)`) ; si le staffing inter-agence est voulu, une politique (ex. `positionnement.inter_agence` : refus · même_pays · libre), défaut refus.

### I-4 · La garde s'arrête au premier objet trouvé — RecordQualification — élevée
- **défaut** : pour la nature `objet`, la boucle `for (const l of ligne.lecteurs)` fait `break` au premier lecteur résolu ; les suivants ne sont jamais jugés. RecordQualification déclare pourtant le lecteur `personne_id` (`tousProfils`).
- **cible** : `server/src/agence.ts`, `exigeAgence`, `if (ligne.nature === "objet" && ctx.commande !== "TransferContact") { … break; }` · **gravité** : élevée.
- **preuve** : `besoin_id` de PAR + `personne_id` d'une personne à profil LYO → ok, `qualification` écrite (`croise_55.md`).
- **prétend** : la ligne de correspondance (le lecteur existe) ; P-321.
- **mesure** : le lecteur écrit est du code mort dès qu'un `besoin_id` est fourni. Seul TransferContact échappe au `break`, par son nom.
- **correction** : juger TOUS les lecteurs fournis (`exigerToutes`) pour toute nature ; le `if … "TransferContact"` disparaît.

### I-5 · Une personne se juge par ses profils… sauf à la création d'un profil — moyenne
- **défaut** : UploadDocument, ArchiveObject et RecordQualification jugent une personne par les agences de ses profils ; CreateCandidate et CreateResource ne jugent pas `personne_id`.
- **cible** : `server/src/agence.ts` (`CreateCandidate`, `CreateResource`) · **gravité** : moyenne.
- **preuve** : personne à profil ressource LYO → CreateCandidate dans PAR : ok ; personne à profil candidat LYO → CreateResource dans PAR : ok.
- **mesure** : PAR s'approprie une personne que LYO suit ; et, en retour, LYO perd UploadDocument et ArchiveObject sur SA personne (`exigerToutes` exige désormais PAR aussi) — un profil créé ailleurs bloque le propriétaire.
- **correction** : trancher (ADR) : la personne est partagée (et alors UploadDocument/ArchiveObject ne doivent pas l'exiger) ou elle se juge par ses profils partout.

### I-6 · Des comptes d'une autre agence posés comme manager ou responsable RH — moyenne
- **défaut** : UpdateCompany (`manager`, `manager_compte_id`), UpdateCandidate et UpdateResource (`responsable_rh_compte_id`) acceptent n'importe quel compte actif ; CreateCompany, lui, juge `manager`.
- **cible** : `server/src/commandes/crm.ts:71`, `identite.ts:90,279` ; `agence.ts` · **gravité** : moyenne.
- **preuve** : `croise_55.md` (4 lignes ok) ; `societe.manager_compte_id` = un compte de LYO.
- **correction** : lecteur `col("compte", [...], "id")` sur ces clés, comme CreateCompany.

### I-7 · Des sociétés d'une autre agence comme fournisseur ou intermédiaire — moyenne
- **défaut** : `societe_fournisseur_id` (ConvertCandidateToResource, CreateResource), `intermediaire_facturation_id` (UpdateProject) ne sont pas jugés (CreateResource ne vérifie même pas l'existence : c'est la FK qui le fait).
- **cible** : `identite.ts:208,247`, `projet.ts:116` · **gravité** : moyenne.
- **preuve** : `croise_55.md` (3 lignes ok).
- **correction** : `resp("societe", [...])` jugé par `modeSociete`, ou une décision écrite que fournisseurs et intermédiaires sont partagés.

### I-8 · La vue des besoins s'ouvre par n'importe quelle permission — moyenne
- **défaut** : `filtreAgence` prend l'union des périmètres de TOUTES les permissions du compte ; une permission sans rapport (SetOwnTheme) ouvre la lecture de l'agence.
- **cible** : `server/src/index.ts` (`filtreAgence`, `/vues/besoins`, `/vues/besoins/:id`) · **gravité** : moyenne (le banc seul l'expose aujourd'hui : K1 ferme tout hors banc).
- **preuve** : `grille8/K2_K3_banc.txt` : `res@` (RES, « soi-même ») voit **176** besoins de PAR, comme `rh@` ; `eval@` 176 ; `ia.lyo@` (aucun groupe) 0 ; rh sur un besoin LYO par id → 404 ✅.
- **prétend** : MATRICE « RES : déclarer son activité · soi-même ».
- **correction** : une permission de lecture par vue (ou la liste des commandes qui ouvrent la vue), jugée comme une commande.

### I-9 · ManageGroups ne sait pas redonner le `S` de la matrice — moyenne
- **défaut** : `ManageGroups` refuse `soi` sauf pour la nature `soi` (SetOwnTheme) ; UploadDocument, RecordTimesheet, RecordAbsence sont de nature `objet`. Le seed pose leurs lignes `soi` en SQL.
- **cible** : `server/src/commandes/admin.ts:263-269` · **gravité** : moyenne.
- **preuve** : `soi_v129.out` l. « soi sur UploadDocument » → GARDE « soi ne couvre pas cette commande ».
- **prétend** : MATRICE, symbole **S** ; la délégation passe par ManageGroups.
- **mesure** : une ligne S retirée ne se remet que par migration. Et le seul chemin restant — une ligne d'agence — ouvre I-1.
- **correction** : `soi` admis pour les commandes de `SOI_MEME` ; la nature suit la matrice.

### I-10 · Constats de robustesse vus en mesurant — faible
- Les noms `constructor`, `__proto__`, `toString`, `hasOwnProperty` passent `HANDLERS[nom]` et ouvrent une transaction avant de tomber en `GARDE « nature d'agence inconnue »` (`noms_prototype.txt`) — attendu : `INTROUVABLE « commande inconnue »` sans transaction (`Object.hasOwn`).
- `nextRef` : une référence de projet hors format bloque toute création de projet (CONFORMITE8 H-10) — c'est ce qui a faussé 2 positifs de la passe 1.
- Le démarrage refuse un superutilisateur (✅), mais accepte tout rôle non-superutilisateur plus puissant qu'`ava_serveur` (propriétaire des tables, par exemple) : il faudrait exiger `current_user = 'ava_serveur'` ou « membre d'`ava_app` et de lui seul ».

---

## 3 · Ce qui tient — mesuré

| Point | Mesure | Preuve |
|---|---|---|
| 79 champs sur 96 jugés, rien écrit | DROIT ou GARDE, empreinte inchangée | `croise_55.md` |
| V-129, `soi` seul | RES : soi-même ok partout, autrui DROIT partout (6 cas) ; `soi` posé en base sur CreateAction → DROIT | `soi_v129.out` §1, §3 n |
| V-131 | écrivables par `ava_app` = écrites par une commande, **par table** (23 + 74 `ref_*`) ; ⚠️ 7 privilèges en trop (GRILLE8 G-8) | `grille8/V131_ecrivables_ava_app.txt` |
| V-132 / B5 | 9 CHECK de liste, tous justifiés au registre §D ; ⚠️ 2 CHECK sur un code seul hors requête (GRILLE8 G-7) | `grille8/B2_B5.txt` |
| K1 hors banc | 173 appels → 173 × 401, 0 écriture, 0 trace (tentative_refusee comprise), `/sante` 200 | `grille8/K1_hors_banc.txt` |
| V-135 | `_ops/JEU_ESSAI.sql` se charge sur une base neuve 001→016 : rc 0 (2 581 sociétés, 21 000 personnes, 1 926 besoins, 161 projets) | `grille8/V135_jeu_essai.log` |
| K2 / K3 | UUID comme session → DROIT ; compte inactif → DROIT (commande et vue) | `grille8/K2_K3_banc.txt` |
| Superutilisateur | le serveur refuse de démarrer en `postgres` | `grille8/C2_superutilisateur_refuse.txt` |

## 4 · Recommandation de porte (pas une correction du code)

`croise_55` est la porte que l'audit 7 demandait : elle se relit comme une table (commande × champ), elle **découvre** les champs au lieu de les recopier si on la dérive des `req/opt` des handlers, et elle a son contrôle positif. Pour qu'elle serve de cliquet : (1) la générer depuis les handlers (un champ ajouté sans lecteur doit la faire rougir), (2) ajouter le cas « soi + agence », (3) la passer au banc sous les trois valeurs de `societe.perimetre.mode`.

---

## 5 · ANGLES MORTS

- Un seul acteur complet (RH à 55 permissions) ; les combinaisons de groupes réels (IA+STAF, DP+RES…) n'ont été mesurées que pour I-1.
- Périmètres `pole` et `equipe` : dans le schéma, jamais honorés par `aLeDroit` (qui ne connaît que global, agence, soi) — non testés ; un groupe « STAF : son équipe / pôle » n'a pas de traduction.
- `societe.perimetre.mode = partagee` et `par_besoins` : mesurés sur la seule chaîne I-2, pas sur les 96 champs.
- Surcharges nominatives (`compte_surcharge`) et `droits.surcharge_restrictive = union_gagne` : non testées.
- Lectures : seules `/vues/besoins` et `/vues/besoins/:id` existent ; aucune autre fuite en lecture n'était mesurable.
- Concurrence (deux transactions sur le même objet), injection au-delà des noms de commande : non testées ; `ManageRefs` interpole `referentiel` dans le SQL après une regex `^ref_[a-z_]+$` et un contrôle `pg_class` — lu, jugé fermé, non attaqué.
- Les objets sont posés en SQL : un chemin qui n'existe que via une suite de commandes (ex. un profil déplacé d'agence) n'est pas couvert.
- Base laissée : `ava_audit8_b` (neuve + fixture + LYO + tests de politiques, politiques remises) ; serveur :3802 arrêté.
