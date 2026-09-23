# Correctifs lot 2 — audit V- · 21/09/2026

Une ligne par point. SHA après commit. ROUGE = vu sur le défaut réel (audit 3b59ca5 et/ou remis une fois).

| V- | Point | Porte | ROUGE avant | VERTE après | Commit |
|---|---|---|---|---|---|
| V-003 | C1 session ; x-ava-groupe hors banc → 401 | P-066 | `not ok` — HTTP 200, commande exécutée | `ok` — 401, rien d'écrit | `1a544e0` |
| V-002 | C2 ava_serveur | P-136 | `not ok` — attendu exit 1, obtenu `sante` (`ava-server :3011`) | `ok` — exit 1, /sante muet ; `ava_serveur` rolsuper=f sert /sante | `8021f3e` `7f09c29` |
| V-004 | C3 périmètre objet | P-067 | `not ok` — `ok:true`, besoin écrit agence CAS | `ok` — DROIT, rien d'écrit | `1a544e0` |
| V-007 | C4 emit RETURNING id | P-068 | `not ok` — rendu `NeedCreated`, attendu `CompanyCreated` | `ok` — id RETURNING, objet = société | `1a544e0` |
| V-005 | C5 RecordTimesheet dates | P-069 | `not ok` — GARDE « jour hors des dates » pour le 2026-10-15 | `ok` — ligne écrite | `6777f92` |
| V-006 | C6 SetPolicy colonne `code` | P-070 | `not ok` — `ERREUR` « erreur interne » (`permission_code`) | `ok` — valeur relue, `PolicyChanged` | `1a544e0` |
| V-010 | C7 chemin nominal 55 | P-071–P-125 | `not ok` P-071 — société absente après commande | `ok` P-071 ; suite chemin 56/56 | `67b5e8b` `1a544e0` |
| V-011 | C7 matrice / politiques / O-2 / S | P-126–P-134 | une ligne, un seul cas | `ok` P-126–P-134 (make test, fail 0) | `67b5e8b` |
| V-013 | E1 pourvu auto = même garde | P-137 | `not ok` — `pourvu` au lieu de `en_recherche` (1/2) | `ok` — garde puis `une_prestation_signee` → pourvu | `c968918` |
| V-014 | E2 clé lue = branche | P-138 | `not ok` — `droits.surcharge_restrictive` = `restriction_gagne` dans liens | `ok` — clé non lue ; cles, propagation, validation gouvernent | `fa32680` |
| V-015 | E3 table de transitions | P-139 | `not ok` — `besoin.ts "en_recherche"` | `ok` — littéraux seulement dans `cycle.ts`, vues lisent TRANSITIONS | `2af4270` |
| V-016 | E4 ExitCandidate n'écrit pas ref | P-135 | `not ok` — `ok:true`, `etat_code` `sorti_sab` | `ok` — GARDE, ref inchangé | `1a544e0` |
| V-017 | E5 exigeRef avant écriture | P-140 | `not ok` — `MUR` « erreur interne » (FK type_code) | `ok` — GARDE, type inchangé ; MUR trace la cause | `f42d0e3` |
| V-018 | E6 bouchon plus servi | P-141 | `not ok` — `bouchon copié dans dist` | `ok` — HTTP sans le JSON, dist/bouchon absent. P-061–P-065 restent ⏳ lot 3 | `03796ea` |
| V-019 | E7 jetons getComputedStyle | P-004 P-005 | `x` P-004 — reçu `#111111`, attendu `#000000` | `ok` P-004 et P-005 — getComputedStyle clair et sombre | `9c69bce` |
| V-020 | E8 UploadDocument sous S | P-129 | `not ok` — upload projet par RES `true !== false` | `ok` — soi permis, autrui et projet DROIT | `adebb39` |
| V-021 | E9 ref contact/coordonnée | P-142 | `not ok` — `fk_contact_statut` absent | `ok` — 3 FK, `perimetre_type_code_check` garde `global`. Migration non réécrite (007) | `df69c96` |
| V-025 | M1 AVA_BASE_URL | P-143 | `not ok` — `sante.test.ts` contient le port en dur | `ok` — AVA_BASE_URL requis, P-002 vert | `f655f02` |
| V-026 | M2 note candidat | P-144 | `not ok` — note relue `0` au lieu de `4` | `ok` — 4 sur 1_5, 9 sur 1_10 | `e17df4e` |
| V-027 | M3 catch trace journalise | P-145 | `not ok` — `catch {} silencieux` | `ok` — `console.error` sur le rollback de refus | `bbf0e3a` |
| V-030 | M4 500 → ERREUR générique | P-146 | `not ok` — GARDE en HTTP 500 | `ok` — statut ≠ 500, message sans fkey, détail au journal | `d583872` |
| V-031 | M5 mot de passe hors dépôt | P-147 | `not ok` — `outils/make.sh` contenait le secret | `ok` — git grep vide hors journal | `032ceed` |
| V-032 | M6 sortie unique + evenements | P-149 | `not ok` — `evenements` `[]` | `ok` — id société + `CompanyCreated` relu | `dc2c330` |
| V-033 | M7 UpdateUnit remonte l'arbre | P-152 | `not ok` — cycle rendu `MUR` | `ok` — GARDE, parent inchangé | `5de34a1` |
| V-034 | M8 ClosePrestation date ≤ fin | P-150 | `not ok` — clôture `ok:true` au 2026-11-15 | `ok` — GARDE, prestation reste `engage` | `d74dbc8` |
| V-035 | M9 ref projet advisory lock | P-151 | `not ok` — `count(*)+1` dans nextRef | `ok` — `pg_advisory_xact_lock`, plus de count+1 | `82a3595` |
| V-036 | M10 ManageRefs ordre/actif ; ManageGroups emit si change | P-153 | `not ok` — 42 événements au lieu de 41 | `ok` — ordre 9, actif false, second accord silencieux | `421ffdf` |
| V-037 | M11 ArchiveObject délègue | P-154 | `not ok` — `ok:true` ObjectArchived malgré un besoin ouvert | `ok` — GARDE, société non archivée | `baa4054` |
| V-038 | M12 compte RES + personne | P-155 | `not ok` — `personne_id null` | `ok` — personne et profil ressource au démarrage banc | `0e61751` |
| V-039 | M13 snaps Linux | P-156 | `not ok` — `tuyau-sombre-chromium-1-55-0-linux.png` absent | `ok` — sombre et clair Linux versionnés | `1231bc8` |
| V-040 | M14 trailer Role: | P-148 | `not ok` — `Role: brain` refusé | `ok` — sans Role refusé, brain et serveur admis | `fce4647` |

## V-017 · P-140 · sorties

ROUGE (21/09/2026) : `UpdateContact` avec `type=code_absent` passait la clé étrangère et rendait MUR.

```
not ok 1 - P-140 E5 un code hors ref actif est GARDE, pas un MUR
'MUR' !== 'GARDE'
{"ok":false,"commande":"UpdateContact","code":"MUR","message":"erreur interne"}
```

La ligne `tentative_refusee` gardait la cause (`contact_type_code_fkey`).

VERTE (`exigeRef` avant l'UPDATE) :

```
ok 1 - P-140 E5 un code hors ref actif est GARDE, pas un MUR
# fail 0
```

## V-015 · P-139 · sorties

ROUGE (littéral remis dans `maybeStaffingPremierPositionnement`, 21/09/2026) :

```
not ok 1 - P-139 E3 aucun code d'état ni de groupe en littéral hors de la table
besoin.ts "en_recherche"
```

VERTE (catégories dans `CAT` / `TRANSITIONS` ; `vues.ts` ne duplique plus `cats`) :

```
ok 1 - P-139 E3 aucun code d'état ni de groupe en littéral hors de la table
# fail 0
```

## V-014 · P-138 · sorties

ROUGE (21/09/2026) : `aLeDroit` lisait `droits.surcharge_restrictive` sans branche. La clé sortait dans `liens.politiques`.

```
not ok 1 - P-138 E2 une clé lue gouverne ; une clé non implémentée n'est pas lue
clé non implémentée non lue
+ 'restriction_gagne'
- undefined
```

VERTE (`pol()` retiré ; `doublon.societe.cles`, `societe.passage_client.propagation` et `temps.validation` changent le résultat) :

```
ok 1 - P-138 E2 une clé lue gouverne ; une clé non implémentée n'est pas lue
# fail 0
```

## V-013 · P-137 · sorties

ROUGE (gardePourvu retiré de effetsSignature, 21/09/2026) : mode `auto_par_prestation_signee`, garde `tous_les_postes_signes`, 1 prestation sur 2 postes. Le besoin est passé `pourvu`.

```
not ok 1 - P-137 E1 pourvu auto à la signature appelle besoin.pourvu.garde_minimale
1/2 postes : la garde refuse le pourvu
+ 'pourvu'
- 'en_recherche'
```

VERTE (gardePourvu rappelé avant l'UPDATE ; `une_prestation_signee` pourvoit) :

```
ok 1 - P-137 E1 pourvu auto à la signature appelle besoin.pourvu.garde_minimale
# fail 0
```

## V-016 · P-135 · sorties

ROUGE (21/09/2026) : ExitCandidate insérait un code `sorti` actif puis sortait le candidat.

```
not ok 1 - P-135 E4 ExitCandidate sans code sorti actif → GARDE, ref_etat_candidat inchangé
{"ok":true,"commande":"ExitCandidate",...,"etat_code":"sorti_sab",...}
true !== false
```

VERTE (aucun INSERT dans `ref_etat_candidat` ; pas de code actif → GARDE) :

```
ok 1 - P-135 E4 ExitCandidate sans code sorti actif → GARDE, ref_etat_candidat inchangé
# fail 0
```

## V-003 · P-066 · sorties

ROUGE (21/09/2026) : hors `AVA_MODE=banc`, `x-ava-groupe` était transmis à la commande.

```
not ok 1 - P-066 C1 hors banc x-ava-groupe ADM → 401, rien d'écrit
HTTP 200 body={"ok":false,"commande":"ManageRefs","code":"GARDE",...}
200 !== 401
```

VERTE (401 avant toute écriture) :

```
ok 1 - P-066 C1 hors banc x-ava-groupe ADM → 401, rien d'écrit
# fail 0
```

## V-010 · P-071 · sorties

ROUGE (21/09/2026) : CreateCompany pour un nom `c71*` rendait un id et un événement sans INSERT. La porte relit la base.

```
not ok 1 - P-071 CreateCompany chemin nominal, base relue
societe 00000000-0000-4000-8000-00000000c071 absent après commande
```

VERTE (INSERT rétabli). Le même tour, `make test` : chemin 56/56, matrice 3/3, politiques 5/5, fail 0 — P-071 à P-134.

```
ok 1 - P-071 CreateCompany chemin nominal, base relue
# fail 0
```

## V-006 · P-070 · sorties

ROUGE (21/09/2026) : `SELECT permission_code` sur `politique` — colonne absente, rien n'est réglé.

```
not ok 1 - P-070 C6 une politique réglée, relue en base, événement PolicyChanged de la transaction
SetPolicy ADM: {"ok":false,"commande":"SetPolicy","code":"ERREUR","message":"erreur interne"}
false !== true
```

VERTE (`SELECT cle, valeur, valeurs_possibles, mur_touche` ; `commandes_affectees` = `commandesDe`) :

```
ok 1 - P-070 C6 une politique réglée, relue en base, événement PolicyChanged de la transaction
# fail 0
```

## V-005 · P-069 · sorties

ROUGE (21/09/2026) : comparaison `String(jour)` à `String(Date)` — le 2026-10-15, dans [2026-10-01, 2026-10-31], refusé.

```
not ok 1 - P-069 C5 un temps saisi DANS les dates est écrit
RecordTimesheet DP: {"ok":false,"code":"GARDE","message":"jour hors des dates de la prestation"}
false !== true
```

VERTE (`jourIso` des deux côtés) :

```
ok 1 - P-069 C5 un temps saisi DANS les dates est écrit
# fail 0
```

## V-007 · P-068 · sorties

ROUGE (21/09/2026) : `emit()` ignorait `RETURNING id` et rendait le dernier événement du compte.

```
not ok 1 - P-068 C4 l'événement rendu est celui de la transaction (RETURNING id)
+ 'NeedCreated'
- 'CompanyCreated'
```

VERTE (`RETURNING id` poussé dans `evenementIds`) :

```
ok 1 - P-068 C4 l'événement rendu est celui de la transaction (RETURNING id)
# fail 0
```

## V-004 · P-067 · sorties

ROUGE (garde d'agence retirée, 21/09/2026) : `aLeDroit` rendait vrai dès qu'une ligne de droit existait. CreateNeed par IA a écrit un besoin `agence_id` CAS.

```
not ok 1 - P-067 C3 IA de PAR sur un besoin de CAS → DROIT, rien d'écrit
{"ok":true,"commande":"CreateNeed",...,"agence_id":"00000000-0000-4000-8000-000000000002",...}
true !== false
```

VERTE (comparaison `type_code = global` ou `agence_id` de l'objet, avant l'INSERT) :

```
ok 1 - P-067 C3 IA de PAR sur un besoin de CAS → DROIT, rien d'écrit
# fail 0
```

## V-002 · P-136 · sorties

ROUGE (défaut en place, puis remis une fois) :

```
not ok 1 - P-136 C2 démarrage en postgres superutilisateur → le serveur s'arrête
démarrage postgres : attendu exit 1, obtenu sante. logs=ava-server :3011
'sante' !== 1
```

VERTE (garde remise) :

```
ok 1 - P-136 C2 démarrage en postgres superutilisateur → le serveur s'arrête
# fail 0
```

Contrôle positif : `postgres://ava_serveur@127.0.0.1:5432/ava` sert `/sante` ; `current_user=ava_serveur`, `rolsuper=f`.

# Correctifs lot 2 — second audit · 22/09/2026

Le second audit a refusé `7e3f78c`. Une ligne par V- repris. ROUGE = porte vue sur le défaut, y compris remis une fois.

| V- | Point | Porte | ROUGE avant | VERTE après | Commit |
|---|---|---|---|---|---|
| V-048 | C1 D-10 serveur fermé hors banc | P-066 | `not ok` — ManageRefs HTTP 200, `RefChanged`, `ref_pays` ZZ | `ok` — 401 « authentification non livrée (lot 2c) », ZZ et politique inchangés, refus tracé ×2 | `4b13752` |
| V-003 | C1 même porte (la session n'est plus l'UUID) | P-066 | idem V-048 | idem V-048 | `4b13752` |
| V-004 | C2 périmètre sur l'objet | P-157–P-197 | `not ok` — WithdrawPositioning, UploadDocument, RecordQualification, CreateAction, ArchiveObject `ok:true` sur un objet CAS | `ok` — DROIT, événement inchangé | `4e818fb` |
| V-049 | C3 portes d'accès : K3 compte inactif, 40 réussites | P-007–P-054, P-198 | `not ok` — serveur INTROUVABLE : CreateCompany `sabotage` ; compte inactif `ok:true` CompanyCreated | `ok` — 40 réussites relues ; compte inactif DROIT | `e140b07` |
| V-006 | C5 SetPolicy rend les commandes affectées | P-199 | `not ok` — sortie sans `commandes_affectees` | `ok` — liste contient CreateCompany, valeur relue | `93dbb98` |
| V-054 | E3 décision inconnue → GARDE | P-200 | `not ok` — `Retenu` écrit `refuse_client` | `ok` — GARDE, etat_code inchangé | `6c83213` |
| V-055 | E4 ManageRefs gardes | P-201 | `not ok` — désactiver `ouvert` `ok:true` actif false | `ok` — GARDE, catégorie inventée non écrite, renommage garde actif | `5b1e1a4` |
| V-056 | E5 cascade clôture | P-202 | `not ok` — `ETAT` « CloseProject hors cycle » | `ok` — prestation et projet `clos`, les deux événements | `ec41489` |
| V-011 | C4 chaque ligne : passe, hors périmètre, sans groupe ; chaque politique lue : deux valeurs | P-203–P-254 | `not ok` — CreateCompany hors périmètre `ok:true` CompanyCreated | `ok` — DROIT rien d'écrit ; politiques deux résultats (chemin+matrice+politiques 158/158) | `4f36b74` |
| V-052 | E2 plafond jour joue RecordTimesheet | P-133 | `not ok` — alerte absente `[]` quand le plafond est ignoré | `ok` — 1,5 j alerte écrite, refus GARDE rien d'écrit | `b46bd61` |
| V-057 | E6 liens.politiques des clés lues | P-256 | `not ok` — SignPrestation sans `prestation.avenant.mode`, seulement `projet.contact` | `ok` — les quatre clés et `projet.creation_depuis_besoin` | `5bd0196` |
| V-061 | M1 refus sans compte tracé | P-257 | `not ok` — 0 ligne, uuid vide | `ok` — ligne, auteur nul | `f1ea103` |
| V-068 | M2 SetPolicy selon le type | P-258 | `not ok` — `ok:true`, valeur `pas du json` | `ok` — GARDE, valeur inchangée | `a9cdc09` |
| V-071 | M4 SetOwnTheme clés ui | P-259 | `not ok` — `ok:true`, clé `<script>` enregistrée | `ok` — GARDE, thème inchangé, `ui.mode` écrit | `0afd788` |
| V-030 | M6 entrée mal typée → GARDE | P-260 | `not ok` — HTTP 500 `ERREUR` | `ok` — statut ≠ 500, code GARDE | `061cb07` |
| V-032 | M6 sortie ArchiveObject | P-261 | `not ok` — sortie `{}` | `ok` — `sortie.id` = l'objet | `a9f86e3` |
| V-037 | M6 ArchiveObject projet engagé | P-262 | `not ok` — `ok:true` ObjectArchived malgré une prestation ouverte | `ok` — GARDE, projet non archivé | `30a2582` |
| V-051 | E1 DATABASE_URL, plus de base ava ni de ports fixes | P-263 | `not ok` — `db.ts retombe sur la base ava` | `ok` — lève si DATABASE_URL manque ; ports et URL lus de l'environnement | `6f3df6b` |
| V-014 | E8 clé nom+prenom+naissance | P-264 | `not ok` — second CreatePerson `ok:true`, `date_naissance` null | `ok` — GARDE, l'autre jour est écrit | `46b816c` |
| V-015 | E8 statuts commerciaux lus dans le référentiel | P-265 | `not ok` — `crm.ts:54 prospect` et 13 littéraux | `ok` — plus de code en dur, CreateCompany relit l'ordre 1 | `b87917a` |
| V-018 | E8 le bouchon n'est plus lu | P-266 | `not ok` — `contrat.ts` contient `/bouchon/` | `ok` — liste et fiche relisent le besoin créé | `2d7699a` `b044550` `4238e76` |
| V-017 | E8 ManageRefs | P-201 | couvert par V-055 | `ok` — catégorie inventée non écrite, renommage garde actif | `5b1e1a4` |
| V-019 | E8 couleur calculée du titre | P-004 P-005 | `not ok` — reçu `rgb(255, 0, 0)`, attendu `rgb(217, 174, 232)` | `ok` — P-004 et P-005, le h1 est la structure | `b46d31f` |
| V-069 | M3 profil ressource recréé | P-267 | `not ok` — `0 !== 1` après redémarrage | `ok` — profil ressource = 1 | `0e2d9e3` |
| V-072 | M5 valeurs de test en $n | P-268 | `not ok` — Missing expected rejection | `ok` — littéral refusé, piège compté 0 | `ccb05f4` |
| V-036 | M6 renommage | P-201 | couvert par V-055 | `ok` — renommage garde actif | `5b1e1a4` |
| V-073 | M6 gardePourvu et garde du service | P-269 | `not ok` — `DROIT` puis `UnitArchived` | `ok` — INTROUVABLE, puis GARDE. Besoin fermé et ressource en mission déjà gardés dans ArchiveObject, sans porte séparée | `2b087bb` |
| V-058 | E7 règle S lue sur le périmètre soi | P-270 | `not ok` — `identite.ts:395`, `droits.ts:59` `GROUPE.RES` | `ok` — plus de rôle en dur, UploadDocument de RES est `soi` | `0f45c06` |

## V-011 · P-203 · sorties

ROUGE (périmètre CreateCompany déplacé sur Casablanca, avant la garde sur l'agence du compte) :

```
not ok 1 - P-203 matrice CRM : passe, hors périmètre, sans le groupe
CreateCompany hors périmètre : {"ok":true,"commande":"CreateCompany",...}
true !== false
```

VERTE (`aLeDroit` : un périmètre d'agence ne couvre que cette agence) : P-203 à P-254, et chemin+matrice+politiques `pass 158`.
