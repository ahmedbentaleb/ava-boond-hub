# SECURITE6 — SQL, refus avant écriture, périmètre par objet, GRANT, pg_hba, secrets, écran

**Sixième audit · branche `lot-2` · commit `a26291c`.** Base `ava_audit6_b` (migrations `001` →
`013` + `db/fixtures/banc.sql`), serveur `AVA_MODE=banc` sur `127.0.0.1:3602`, connexion en
`ava_serveur`. Tout est mesuré par **appels HTTP réels** puis **relu en base**, avec un
**contrôle positif** à chaque fois.

Preuves : `securite6/perimetre_par_objet.json` et `.txt` · `trous_perimetre.txt` ·
`trois_modes.txt` · `hors_banc.txt` · `K2_K3.txt` · `sql_parametre.txt` · `verif_serveur.txt`.

---

## 1 · SQL PARAMÉTRÉ — ✅ aucune injection possible

| Mesure | Résultat |
|---|---|
| Concaténation `"SELECT …" + x` | **0 occurrence** |
| `${…}` dans un littéral SQL | **15 occurrences**, **toutes des identifiants**, relues une par une |
| Requêtes portant `$1` | **224** |

**Les 15 identifiants interpolés, et leur garde :**

| Site | Origine | Garde |
|---|---|---|
| `agence.ts:168, 177` | table `CORRESPONDANCE`, écrite en dur | `ident()` : `/^[a-z_]+$/`, sinon `Refus("GARDE")` |
| `admin.ts:187, 210, 230, 235` — `${referentiel}` | ⚠️ **entrée utilisateur** (`ManageRefs`) | `/^ref_[a-z_]+$/` **puis** existence vérifiée dans `pg_class` par requête paramétrée |
| `admin.ts:88, 115` — `${spec.table}` | table `ARCHIVE[type]` | table fixe ; `if (!spec) throw Refus("GARDE")` |
| `admin.ts:63` — `${col}` | `PORTEURS_ACTION` | liste `as const` de 6 noms |
| `admin.ts:31` — `${fk.tbl}`, `${fk.col}` | `pg_constraint` | vient de la base, pas de l'entrée |
| `besoin.ts:244` — `${clause}` | ternaire sur 2 littéraux | fermé |
| `cycle.ts:125, 145` · `kernel.ts:124, 166` | appelants internes | fermé |

**Quatre vecteurs éprouvés en HTTP, tous repoussés :**

```
ManageRefs referentiel="ref_pays; DROP TABLE ava.societe --"  -> GARDE « référentiel inconnu »
ManageRefs referentiel="pg_class"                             -> GARDE « référentiel inconnu »
CreateCompany nom="X'); DROP TABLE ava.societe; --"           -> ok:true, la valeur est STOCKÉE telle quelle
                                                                 ava.societe existe toujours (3 lignes)
x-ava-groupe: "' OR 1=1 --"                                   -> DROIT « compte inconnu ou inactif » · vue 403
POST /commandes/{constructor,__proto__,toString,valueOf,…}    -> DROIT (pas de fuite de prototype)
```

⭐ **`ManageRefs` est le seul point où un identifiant SQL vient de l'utilisateur, et il est gardé
deux fois** : par une expression régulière, puis par une lecture paramétrée de `pg_class`. C'est
la bonne façon.

---

## 2 · REFUS AVANT ÉCRITURE — ✅ 0 ligne sur 49 refus mesurés

Pour **chacune** des 55 commandes, l'empreinte de **18 tables** est relevée avant et après
l'appel refusé (`societe, contact, unite_organisation, personne, profil_candidat,
profil_ressource, besoin, projet, prestation, positionnement, document, action, temps_saisi,
absence, evenement_metier, seance_qualification, politique, groupe_permission_perimetre`).

| | |
|---|---|
| Refus `DROIT` mesurés | **49** |
| Lignes écrites pendant ces refus | **0** |
| `evenement_metier` pendant ces refus | **inchangé** |

`executer.ts` ouvre `BEGIN`, appelle `exigeAgence(ctx)` **avant** le handler, et `ROLLBACK` sur
tout `Refus`. La trace va dans `tentative_refusee`, hors transaction, selon
`historique.tentatives_refusees`.

---

## 3 · PÉRIMÈTRE PAR OBJET — 🔴 49/49 refusent, mais **deux commandes écrivent quand même**

### Le banc n'avait qu'une agence : j'en ai posé une seconde

`db/fixtures/banc.sql` ne crée **qu'une agence** (`PAR`). Le périmètre inter-agences n'est donc
pas éprouvable en l'état. J'ai créé `LYO` **dans ma base**, construit **deux graphes complets**
(société, unité, contact, personne, candidat, ressource, besoin, projet, prestation,
positionnement) par les **commandes elles-mêmes**, puis basculé le graphe B en `LYO`.

### Le balayage

Chaque commande à objet est appelée **deux fois** : sur l'objet `LYO` (compte `PAR`) et sur
l'objet `PAR` (contrôle positif).

| Résultat | Compte |
|---|---|
| Refus `DROIT` sur l'objet d'une autre agence, **0 ligne écrite** | **49 / 49** |
| Contrôle positif concluant (`OK` / `ETAT` / `GARDE` de l'autre côté) | **49 / 49** |
| Commandes sans objet (`CreateCompany`, `CreatePerson`, `SetPolicy`, `ManageRefs`, `ManageGroups`, `SetOwnTheme`) | 6, hors périmètre par construction |

⭐ **Les 5 commandes sans titulaire ont bien été éprouvées.** Premier balayage : elles rendaient
`DROIT` des **deux** côtés — le refus prouvait l'absence de permission, pas le périmètre. J'ai
donc **posé** les cinq permissions sur le groupe IA avec un périmètre `agence = PAR`, **par la
commande `ManageGroups`**, puis remesuré :

```
ArchiveCompany       hors=DROIT  ecrit=False   positif=GARDE   (garde d'archivage, pas le périmètre)
ArchiveContact       hors=DROIT  ecrit=False   positif=OK
ArchiveService       hors=DROIT  ecrit=False   positif=OK
ArchiveObject        hors=DROIT  ecrit=False   positif=OK
UpdateResourceCost   hors=DROIT  ecrit=False   positif=OK
```

⛔ **Et pourtant K4 tombe** : le balayage suit les **lecteurs** déclarés dans `CORRESPONDANCE`.
Il ne voyait pas que certaines commandes acceptent des **porteurs** ou des **types** qui n'ont
aucun lecteur. **Quatre chemins d'écriture** franchissent le périmètre. Voir **I-01**.

### Les trois modes de `societe.perimetre.mode` — ✅ trois comportements distincts

**Le même appel**, `ia@ava.test` (agence `PAR`) → `UpdateCompany` sur la société **B** (agence
responsable `LYO`) :

| `societe.perimetre.mode` | Verdict | Écrit ? |
|---|---|---|
| `agence_responsable` *(défaut, = `valeur_defaut`)* | **DROIT** | non |
| `partagee` | **OK** | oui |
| `par_besoins` | **DROIT** | non |

**Et `par_besoins` suit vraiment les besoins** — deuxième mesure, même société, on ne bouge que
l'agence d'un besoin :

| État | Verdict |
|---|---|
| un besoin de la société est dans l'agence du compte | **OK** |
| tous les besoins de la société sont en `LYO` | **DROIT** |

`valeurs_possibles = ["agence_responsable","par_besoins","partagee"]`, `valeur = valeur_defaut =
agence_responsable`. **Aucun `if` métier en dur** : le mode est lu par `pol(ctx,
"societe.perimetre.mode")` à chaque appel.

### « Un objet sans agence » — le cas n'existe pas, et deux branches de code sont mortes

La consigne demandait si le mode par défaut refuse un compte d'une autre agence sur **une
société, un contact, un candidat sans agence**. Mesure :

```sql
SELECT table_name, column_name, is_nullable FROM information_schema.columns
WHERE table_schema='ava' AND column_name IN ('agence_id','agence_responsable_id');
```

| Table | Colonne | NULL ? |
|---|---|---|
| `societe` | `agence_responsable_id` | **NON** |
| `contact` | `agence_responsable_id` | **NON** |
| `profil_candidat` · `profil_ressource` · `besoin` · `projet` · `unite_organisation` | `agence_id` | **NON** |

**Les sept colonnes sont `NOT NULL`** (migrations `010` et `011`). Un objet sans agence est donc
**impossible** — c'est la bonne nouvelle, et c'est le mur qui le garantit, pas la garde.

⚠️ **Conséquence** : dans `agence.ts`, la branche `if (trouve && !agenceId)` — et avec elle
`agenceGouvernante()` (l. 182-195) et `exigeGlobal()` (l. 198-209) — **ne peut plus être
atteinte**. C'est du code mort, jamais éprouvé, qui décide pourtant d'un point de sécurité
(« seul un périmètre global passe »). Voir **I-03**.

---

## 4 · GRANT RÉELS — ✅ exacts, mais le lot 3 est déjà ouvert en écriture

| Contrôle | Mesure |
|---|---|
| `ava_app` : `DELETE` / `TRUNCATE` sur toute relation de `ava` | **0 ligne** |
| `ava_serveur` (le rôle qui se connecte) : idem | **0 ligne** |
| `UPDATE` sur `evenement_metier`, `snapshot_marge`, `prestation_version` | **0 ligne** |
| `ava_lecture_agregats` : relations atteintes | **exactement 7** *(les 4 vues par devise + `politique`, `ref_devise`, `ref_pays`)* |
| Rôles superutilisateur parmi `ava*` | **aucun** ; `ava_app`, `ava_lecture_agregats`, `ava_migration` sont **NOLOGIN** |
| Garde au démarrage | `index.ts` l. 325-333 : le serveur **refuse de démarrer** si `current_user` est superutilisateur (V-002) |

⚠️ **Mais** : les **27 tables** créées par `012` et `013` (facturation, achats, contrats RH,
paie, e-mails, Outlook, documents générés…) portent **toutes** `SELECT + INSERT + UPDATE` pour
`ava_serveur` — alors qu'**aucune commande ne les atteint**. Voir **I-02**.

---

## 5 · pg_hba — ⚪ l'outil mesure ; aucun serveur de production n'a été mesuré

`bash outils/verif_serveur.sh` lit `pg_hba_file_rules`, `listen_addresses` et `pg_authid`. Il ne
déclare rien, il mesure. Sur ce poste :

```
6 règles trust (local + 127.0.0.1 + ::1, all et replication)
listen_addresses : *
ava_serveur : login=oui superutilisateur=non mot de passe=(aucun)
verif_serveur : KO
```

C'est le **poste de dev**, assumé par V-022 (`AVA_POSTE_DEV=1` transforme les ⛔ en ⚠️). ⛔ **Mais
« scram-sha-256 sur le VPS » (T3) n'est toujours mesuré nulle part** : l'outil existe depuis le
23/09 et aucune trace d'exécution sur un serveur n'est dans le dépôt. La phrase reste une
phrase.

---

## 6 · SECRETS — ✅ aucun

| Recherche | Résultat |
|---|---|
| `password|secret|api_key|token` suivis d'un littéral, dans `server web db outils .github test` | **0** hors `secrets.*` / `process.env` |
| `postgres://user:motdepasse@` en clair | **0** |
| `.env`, `*.pem`, `*.key` suivis par git | **0** |
| `.github/workflows/ci.yml` | les deux mots de passe viennent de `${{ secrets.CI_* }}` ; le fichier le dit et le motive |

---

## 7 · L'ÉCRAN — ✅ propre

Les **1 130 lignes** de `web/src` lues. Aucun `if` sur un état métier, aucun calcul d'argent,
aucun libellé d'état en dur, aucun import de `server/` ou `db/`, aucun SQL. Le seul
`Record<…>` (`PASTILLE`, `rendu.tsx:3`) associe une **classe CSS** à une pastille, pas un
libellé. Tout le texte affiché vient du serveur (`cellule.libelle`, `action.libelle`,
`etat.libelle`, `action.refus?.message` en `title`).

---

## 8 · HORS `AVA_MODE=banc` — ✅ tout est en 401, rien n'est écrit

Serveur relancé **sans `AVA_MODE`**, même base, même port.

| Route | Code |
|---|---|
| `GET /sante` | **200** `{"ok":true}` |
| `GET /tuyau` · `/vues/besoins` · `/vues/besoins/:id` | **401** |
| `GET /` · `/index.html` · `/besoins` *(les fichiers statiques)* | **401** |
| `POST /acquitter` | **401** |
| `POST /commandes/*` (5 testées) | **401**, corps `{"code":"DROIT","message":"authentification non livrée (lot 2c)","commande":"…"}` |

```
evenement_metier 0 -> 0   |   tentative_refusee 0 -> 0   |   societe 0 -> 0
```

⭐ **Un seul garde, pas une route qui décide** : `app.addHook("preHandler", …)` posé **avant**
l'enregistrement de `@fastify/static`, donc il couvre aussi les fichiers du front. C'est ce que
D-14 demandait après V-075 (« une vue ouverte livrait 81 besoins »), et c'est tenu.

⚠️ **Note** : `refuserAuthentificationNonLivree()` est exportée par `executer.ts` et **n'est
appelée nulle part**. Les refus hors banc ne sont donc pas tracés — ce que K1 demande
(« rien tracé »), mais la fonction reste du code mort.

---

# LES CONSTATS

## I-01 — 🔴 quatre chemins écrivent sur un objet d'une autre agence : `CreateAction`, `UploadDocument`, `ArchiveObject` ×2

| | |
|---|---|
| **défaut** | La garde d'agence lit `CORRESPONDANCE[commande].lecteurs` et juge sur **le premier lecteur qui trouve**. ⛔ Quand **aucun** lecteur ne trouve — parce que le **porteur** ou le **type** utilisé n'a pas de lecteur déclaré — `vu` reste `false`, `agenceId` reste `undefined`, et `exigeAgence` retombe sur `exigeDroit(ctx, commande, ctx.compte.agence_id)` : **le périmètre est jugé sur l'agence du demandeur, pas sur celle de l'objet**, et l'écriture passe. |
| | **Quatre chemins mesurés :** |
| | 1. `CreateAction` — lecteurs : `besoin_id, projet_id, profil_ressource_id, profil_candidat_id`. Handler : `PORTEURS_ACTION` en accepte **six**, dont **`societe_id`** et **`contact_id`**. |
| | 2. `UploadDocument` — lecteurs : `projet_id`, les deux profils, `personne_id`. Handler : accepte aussi **`societe_id`**. |
| | 3. `ArchiveObject type="societe"` — les 5 lecteurs sont `unite_organisation, profil_candidat, profil_ressource, besoin, projet`. **Aucun lecteur `societe`**, alors que le handler délègue à `ArchiveCompany`. |
| | 4. `ArchiveObject type="contact"` — idem, **aucun lecteur `contact`**. |
| **cible** | `server/src/agence.ts` l. 128-146 (`CreateAction`, `UploadDocument`), l. 133-141 (`ArchiveObject`), l. 279-281 (le repli) · `server/src/commandes/admin.ts` l. 6-13 (`PORTEURS_ACTION`) et l. 76-82 (la délégation) · `server/src/commandes/identite.ts` l. 350-356 |
| **famille** | I — sécurité / K4 |
| **gravité** | **élevée** |
| **preuve** | ⭐ **La démonstration la plus nette — même compte, même objet, deux routes :** une société **nue** (aucun besoin, aucun projet, aucune unité), agence responsable **LYO**, compte `ia@ava.test` en **PAR**, qui détient `ArchiveCompany` et `ArchiveObject` avec un périmètre `agence = PAR` : |
| | ```\nArchiveCompany  {id: <societe LYO>}                 -> DROIT « permission absente ou hors périmètre »\n                                                      archivee = false\nArchiveObject   {type:"societe", id: <la MÊME>}     -> ok:true\n                                                      archivee = TRUE          <<<\n``` |
| | Et le reste du balayage (`securite6/trous_perimetre.txt`, `cinq_sans_titulaire.txt`) : |
| | ```\nCreateAction   porteur=besoin_id          objet LYO -> DROIT  action ecrite=False\nCreateAction   porteur=projet_id          objet LYO -> DROIT  action ecrite=False\nCreateAction   porteur=societe_id         objet LYO -> OK     action ecrite=True    <<<\nCreateAction   porteur=contact_id         objet LYO -> OK     action ecrite=True    <<<\nUploadDocument porteur=profil_candidat_id objet LYO -> DROIT  document ecrit=False\nUploadDocument porteur=projet_id          objet LYO -> DROIT  document ecrit=False\nUploadDocument porteur=societe_id         objet LYO -> OK     document ecrit=True   <<<\nArchiveObject  type=besoin                objet LYO -> DROIT  besoin archive=false\nArchiveObject  type=service               objet LYO -> DROIT  unite archive=false\nArchiveObject  type=contact               objet LYO -> OK     contact archive=TRUE  <<<\n``` |
| **reproduire** | 1. `insert into agence (code,nom,pays_code) values ('LYO','Lyon','FR');` 2. `ManageGroups` (compte `adm@ava.test`) pose `ArchiveObject` et `ArchiveCompany` sur le groupe `IA` avec l'`id` du périmètre `agence = PAR`. 3. `CreateCompany` avec `ia@ava.test`, puis `update societe set agence_responsable_id = <LYO>`. 4. `POST /commandes/ArchiveCompany {id, motif}` → `DROIT`. 5. `POST /commandes/ArchiveObject {type:"societe", id, motif}` → `ok:true`, et `select archive_le from societe where id=…` n'est plus nul. Script complet : `angle4.py` et `angle4b.py`, sorties dans `securite6/cinq_sans_titulaire.txt`. |
| **prétend** | Grille **K4** : « la table `commande → table → colonne d'agence` existe et **couvre les 55** ; une commande sans sa ligne est refusée ; par commande : un cas hors agence → `DROIT`, 0 écriture ». `agence.ts` l. 5 : « Les noms viennent de cette table, jamais de l'entrée. » |
| **mesure** | La table couvre bien les **55 commandes** — mais pas tous les **chemins d'entrée**. **5 écritures hors agence** mesurées (1 action `societe_id`, 1 action `contact_id`, 1 document `societe_id`, 1 société archivée, 1 contact archivé). ⛔ **`ArchiveObject` est le cas le plus grave** : il **contourne la garde de `ArchiveCompany`**, qui, elle, fonctionne. |
| **correction** | La règle manquante s'écrit en une ligne et se vérifie mécaniquement : **tout porteur, et tout type, accepté par un handler doit avoir un lecteur d'agence.** Concrètement : ajouter à `CreateAction` les lecteurs `resp("societe", ["societe_id"])` et `resp("contact", ["contact_id"])` ; à `UploadDocument` le lecteur `resp("societe", ["societe_id"])` ; à `ArchiveObject` les lecteurs `resp("societe", ["id"])` et `resp("contact", ["id"])` — `resp()` et `col()` existent déjà. ⚠️ Pour `ArchiveObject`, attention au `break` sur le premier lecteur : les identifiants étant des UUID, aucune collision inter-tables n'est possible, l'ordre est donc sans effet. ⭐ **Et poser la porte qui l'aurait vu** : pour chaque commande, comparer la liste des porteurs/types du handler à la liste des clés de ses lecteurs ; toute clé acceptée et non lue fait échouer le banc. C'est le seul contrôle qui empêche le trou de revenir au prochain porteur ajouté — il vient déjà de revenir quatre fois. |

## I-02 — 🟠 les 27 tables du lot 3 sont ouvertes en écriture à `ava_serveur` avant d'avoir une garde

| | |
|---|---|
| **défaut** | Les migrations `012_schema_v1_complet.sql` (21 tables : `facture`, `facture_ligne`, `devis`, `achat`, `paiement`, `contrat_rh`, `jalon`, `ca_additionnel`, `compteur_facture`…) et `013_applications_boond.sql` (6 tables : `envoi_email`, `preparation_paie`, `document_genere`, `lien_outlook`…) accordent **`SELECT + INSERT + UPDATE`** à `ava_serveur` sur **les 27**. Or **aucune commande ne les touche** : `grep -c "facture\|contrat_rh\|preparation_paie\|envoi_email\|devis\|achat"` dans `server/src` → **0**. Elles n'ont **aucune ligne** dans `CORRESPONDANCE`, donc **aucun périmètre par objet**, et les 40 commandes qui devraient les servir sont contractées mais pas écrites (CONFORMITE6 · H-01). |
| **cible** | `db/migrations/012_schema_v1_complet.sql` · `db/migrations/013_applications_boond.sql` (les blocs `GRANT`) |
| **famille** | I — sécurité / surface |
| **gravité** | **moyenne** *(rien ne les atteint aujourd'hui : c'est une surface posée à l'avance, pas une porte ouverte)* |
| **preuve** | ```sql\nSELECT count(*) FILTER (WHERE has_table_privilege('ava_serveur',c.oid,'INSERT')) AS ins,\n       count(*) FILTER (WHERE has_table_privilege('ava_serveur',c.oid,'UPDATE')) AS upd,\n       count(*) AS total\nFROM pg_class c JOIN pg_namespace n ON n.oid=c.relnamespace\nWHERE n.nspname='ava' AND c.relkind='r' AND c.relname IN (… les 27 …);\n``` → **27 | 27 | 27**. |
| **reproduire** | `grep -oE "^CREATE TABLE (IF NOT EXISTS )?[a-z_]+" db/migrations/01[23]_*.sql` puis la requête ci-dessus. |
| **prétend** | En-tête de `012` : « ⛔ Les règles du §0 du modèle valent ici … rien ne se supprime (M-8) ». Grille **C2** : le rôle applicatif n'a ni `DELETE` ni `TRUNCATE` — respecté. Rien ne dit ce que le lot 2 fait de 27 tables qu'il ne sert pas. |
| **mesure** | **27 tables écrivables, 0 commande, 0 ligne de périmètre.** Trois murs neufs (M-16, M-17, M-18) les gardent en base et leurs assertions passent — c'est ce qui limite le risque. |
| **correction** | Deux options, et il faut en choisir une **par écrit** : (a) n'accorder `INSERT`/`UPDATE` qu'au moment où la commande qui les sert entre — le GRANT suit la commande, pas le schéma ; (b) assumer l'avance dans une ADR, et poser la contrainte de rattrapage (« toute table de `ava` sans ligne dans `CORRESPONDANCE` est en `SELECT` seul »). ⭐ Le contrôle mécanique existe déjà en creux : `CORRESPONDANCE` est la table de vérité du périmètre ; il suffit de la croiser avec `has_table_privilege`. |

## I-03 — 🟡 la branche « objet sans agence » est inatteignable, et décide pourtant d'un point de sécurité

| | |
|---|---|
| **défaut** | `agence.ts` prévoit trois cas (D-21). Le deuxième — objet trouvé mais **sans agence** — appelle `agenceGouvernante()` puis, à défaut, `exigeGlobal()` : « Un objet sans agence n'est pas couvert par un périmètre d'agence. Seul global passe. » ⛔ Depuis les migrations `010` et `011`, **les sept colonnes d'agence sont `NOT NULL`** : ce cas ne peut plus se produire. Trente-cinq lignes de code qui tranchent un point de sécurité ne sont jamais exécutées, donc jamais éprouvées — et le jour où une table neuve porterait une agence nullable, personne ne saurait si elles marchent. |
| **cible** | `server/src/agence.ts` l. 182-195 (`agenceGouvernante`), l. 198-209 (`exigeGlobal`), l. 232-240 (la branche) |
| **famille** | I — sécurité / code mort |
| **gravité** | **faible** |
| **preuve** | Tentative mesurée (`securite6/trois_modes.txt` §3) : `UPDATE societe SET agence_responsable_id = NULL`, `contact`, `profil_candidat`, `besoin` → **les quatre refusées par la base**. `information_schema.columns` : `societe.agence_responsable_id`, `contact.agence_responsable_id`, `profil_candidat.agence_id`, `profil_ressource.agence_id`, `besoin.agence_id`, `projet.agence_id`, `unite_organisation.agence_id` — **`is_nullable = NO` pour les sept**. |
| **reproduire** | `update ava.societe set agence_responsable_id = NULL where id = '<id>';` → `ERREUR : … viole la contrainte NOT NULL`. |
| **prétend** | `agence.ts` l. 197 : « Un objet sans agence n'est pas couvert par un périmètre d'agence. Seul global passe. » |
| **mesure** | Cas **impossible** en base ; la branche n'est jamais atteinte. |
| **correction** | Soit retirer les deux fonctions et la branche (le mur `NOT NULL` suffit, et il est plus fort qu'une garde), soit les garder avec une **porte** qui crée l'objet sans agence en contournant la garde applicative — ce qui n'est possible qu'en SQL, donc dans une assertion, pas dans un test de contrat. ⭐ Ma préférence, et elle se défend : **retirer**. Un garde-fou qu'on croit actif et qui ne l'est pas coûte plus qu'un garde-fou absent — c'est ce que dit déjà la grille à propos du `--no-verify`. |

---

## VERDICT

```
SÉCURITÉ — 1 🔴 · 1 🟠 · 1 🟡 · 1 ⚪
I-01  QUATRE chemins ecrivent hors agence — 5 ecritures mesurees             élevée
      CreateAction(societe_id|contact_id) · UploadDocument(societe_id)
      ArchiveObject(type=societe) · ArchiveObject(type=contact)
      ⛔ ArchiveObject CONTOURNE la garde de ArchiveCompany, qui elle tient
I-02  27 tables du lot 3 en INSERT/UPDATE sans commande ni perimetre         moyenne
I-03  la branche « objet sans agence » est inatteignable (7 colonnes NOT NULL) faible
K5    aucun serveur de production mesure par verif_serveur.sh                ⚪
```

⭐ **Ce qui tient, et qui a été éprouvé, pas supposé.** Le SQL est **entièrement paramétré**, et
le seul identifiant venu de l'utilisateur est gardé deux fois. **49 refus, 0 ligne écrite** :
la garde passe bien avant la mutation. Les **trois modes** de `societe.perimetre.mode` donnent
**trois comportements réellement différents**, et `par_besoins` suit vraiment les besoins. Les
quatre murs en GRANT sont exacts au privilège près, y compris sur le rôle qui se connecte
vraiment. **Hors banc, rien ne répond et rien ne s'écrit** — fichiers du front compris. Aucun
secret. Et l'écran ne décide de rien.

---

# MES ANGLES MORTS

⛔ **Ce que je n'ai pas pu mesurer, et ce qui peut donc m'avoir échappé.**

| # | L'angle mort | Ce qu'il peut cacher |
|---|---|---|
| **1** | **Je n'ai pas lancé `outils/cliquet.sh` ni `outils/make.sh`** (consigne). J'ai **lu** les 13 cases et **rejoué leurs mesures à la main**. | Un écart entre ce que le script fait et ce que j'ai reproduit. En particulier la **case 1** : je n'ai jamais vu la sortie de `make.sh test`, donc je n'ai pas vérifié que les **307 portes ✅ sont réellement exécutées** — je n'ai vérifié que le mécanisme qui le vérifie. |
| **2** | **Je n'ai pas joué les portes** : ni `test/contrat/*.test.ts`, ni Playwright (espèces C et D). | Une porte verte qui ne teste rien. A2 me rassure sur les **assertions** (espèce A) ; je n'ai pas d'équivalent pour les espèces B, C, D. |
| **3** | **Le banc n'a qu'une agence.** J'ai créé `LYO` moi-même et basculé les objets **en SQL**, hors commandes. | Un chemin où l'agence est écrite **par la commande** et où le périmètre se comporte autrement. Et surtout : **le dépôt n'a aucune porte inter-agences** — I-01 aurait dû être trouvé par le banc, pas par moi. |
| **4** | ~~5 commandes sans contrôle positif~~ — **angle mort fermé en cours d'audit.** J'ai posé les cinq permissions par `ManageGroups` et remesuré les deux côtés. C'est ce second passage qui a trouvé les chemins 3 et 4 de **I-01**. | Reste ceci : j'ai éprouvé les **types** d'`ArchiveObject` (`besoin`, `service`, `societe`, `contact`) mais **pas** `projet`, `candidat`, `ressource` — leurs lecteurs existent, je les tiens pour bons **par lecture**, pas par mesure. |
| **5** | **Aucun serveur de production.** `verif_serveur.sh` n'a tourné que sur ce poste. | T3 (`scram-sha-256`, `listen_addresses` borné, mot de passe de `ava_serveur`) reste entièrement non vérifié. |
| **6** | **Le mur d'indépendance** m'a fait ignorer `_ops/PLAN_*`, les prompts, `JOURNAL_BUGS.md`, `REMARQUES`, `ARBITRAGE_*`. | Un constat que je pose et qui est déjà tranché, ou inversement une décision récente que j'ignore. Les verdicts « prétend » ci-dessus ne citent que les fichiers qui font foi. |
| **7** | **Je n'ai pas lancé `_ops/outils/dossier.py`** (A4 — il réécrit `_ops/DOSSIER.html`). | Un écart entre les comptes du registre §E et ce que le générateur mesure. J'ai recompté **politiques (201)** et **référentiels (71)** moi-même, en base : ces deux-là tombent juste. Les autres comptes du §E, non. |
| **8** | **La concurrence.** Tout a été mesuré en série, un appel à la fois. | Une course entre deux commandes (double `IssueInvoice`, double positionnement, `compteur_facture`). M-18 et les `UNIQUE` sont là, je ne les ai pas éprouvés sous charge. |
| **9** | **`liens.politiques` prouve ce qui est lu, pas ce qui devrait l'être.** | Une politique que le code **n'a jamais appris à lire** n'apparaît ni dans mes mesures ni dans mes écarts. Mon H-02 trouve les clés lues et non contractées ; il ne trouve **pas** les clés contractées que personne n'appelle — sauf `besoin.staffing.declencheur`, repérée parce que `politiques.ts` la déclare. |
