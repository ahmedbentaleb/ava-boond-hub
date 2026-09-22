# SÉCURITÉ I — lot 2, commit 7e3f78c · auditeur B

**Hors `AVA_MODE=banc`, la « session » est l'identifiant du compte en clair : un en-tête
`x-ava-session: 00000000-0000-4000-8000-000000000108` suffit pour agir en administrateur.** Sondé sur un
serveur lancé sans `AVA_MODE` (port 3202, base `ava_audit2_b`) : `SetPolicy` passe en HTTP 200 et la base
enregistre `modifie_par_compte_id = …0108`. Les identifiants sont séquentiels et publiés dans
`db/migrations/005_droits_lot2.sql:192`. Il n'existe ni login, ni secret, ni jeton dans `server/src`.

| # | Question | Verdict | Mesure |
|---|---|---|---|
| I-1 | Requêtes SQL toutes paramétrées ? | ✅ serveur · 🟠 tests | Toutes les **valeurs** passent en `$n`. 11 interpolations d'**identifiants** dans `server/src`, toutes lues : constantes (`cycle.ts:104,124`, `kernel.ts:124,166` appelés avec des noms `ref_*` en dur ; `admin.ts:38` liste blanche `PORTEURS_ACTION` ; `admin.ts:58,63` table `ARCHIVE` ; `besoin.ts:257` deux clauses fixes) ou validées (`admin.ts:116,127,132` : regex `^ref_[a-z_]+$` **et** existence dans `pg_class` du schéma `ava`). Côté tests : `test/contrat/db.ts:32` `compter()` interpole `table` **et** `where`, `monde.ts:38` interpole `table` — appelants littéraux, non exploitable → `preuves/securite/sql_interpolations.txt` |
| I-2 | Rôle sans droit refusé AVANT toute écriture ? | ✅ | `exigeDroit` avant le handler (`executer.ts:351-352`), tout dans une transaction avec `ROLLBACK` sur refus (`executer.ts:342,377`). Mesuré : **54/54** commandes appelées par SUP → DROIT ; **135 refus, 0 événement écrit** ; seule écriture = la trace `tentative_refusee` (voulue, POL `historique.tentatives_refusees`) |
| I-3 | Périmètre (agence) vérifié sur l'objet visé ? | 🔴 | ⛔ **5 commandes mutent un objet d'une autre agence** : WithdrawPositioning, RecordQualification, UploadDocument, CreateAction, ArchiveObject (compte PAR sur objets CAS → ok). Vérifié à juste titre : UpdateNeed, UpdateCandidate, DeclareCVShared, CreateNeed (→ DROIT). Lecture seule : ConvertCandidateToResource ne contrôle pas l'agence **cible** si le candidat en a une (`identite.ts:184`) ; CreatePrestation ne contrôle pas l'agence de la ressource ; UploadDocument sur porteur `projet_id`/`societe_id` sans aucun contrôle → CONFORMITE.md H-1 |
| I-4 | GRANT réels des rôles | ✅ | `ava_serveur` : seul `rolcanlogin`, non super, membre de `ava_app`. `ava_app` : INSERT/SELECT 90, UPDATE 86, **0 DELETE, 0 TRUNCATE**, pas d'UPDATE sur `evenement_metier`, `snapshot_marge`, `prestation_version`, `tentative_refusee`. `ava_lecture_agregats` : exactement 7 relations en SELECT, aucune écriture. Aucune fonction SECURITY DEFINER, aucun CREATE sur `ava`/`public`, pas de RLS (mono-tenant, ADR-000). ⚠️ `ava_serveur` peut INSERT/UPDATE `compte`, `compte_groupe`, `groupe_permission_perimetre`, `politique`, `permission` : attendu (ManageGroups, SetPolicy), mais c'est l'escalade complète si le serveur est compromis → `preuves/securite/grants.txt` |
| I-5 | pg_hba.conf | 🟠 | 6 lignes actives, **toutes `trust`** (local, 127.0.0.1/32, ::1/128, réplication comprise) ; `listen_addresses='*'` mais aucune ligne hors boucle locale → pas d'accès réseau. Conséquence : tout processus local se connecte en `postgres` superutilisateur **sans mot de passe** ; la séparation `ava_serveur` / superutilisateur (V-002) ne protège rien sur ce poste. (Fichier lu, aucun secret : il n'y en a pas) |
| I-6 | Secrets dans le dépôt / l'historique / .env | ✅ | Aucun `.env` suivi ni présent ; aucun motif fort (`sk-…`, `ghp_…`, `AKIA…`, `-----BEGIN … PRIVATE KEY`) dans tout l'historique (`git log --all -p -G`) ; les 14 fichiers qui contiennent « password/token/secret » en parlent (`POSTGRES_PASSWORD` lu dans l'environnement : `docker-compose.yml:8`, `make.sh:57`). ⚠️ Les deux `.zip` de la racine n'ont pas été ouverts au-delà de leur liste de fichiers |
| I-7 | Front : HTML injecté, SVG | ✅ | `web/src` (11 fichiers, 629 lignes) : 0 `dangerouslySetInnerHTML`/`innerHTML`/`insertAdjacentHTML`/`eval` ; 2 SVG **statiques** en JSX (`rendu.tsx:56-63`), aucun SVG venu du serveur ou d'un utilisateur |
| I-8 | Authentification hors banc | 🔴 | `index.ts:149-157` exige seulement la **présence** de `x-ava-session` ; `executer.ts:254-265` `compteDeSession` = `WHERE c.id::text = $1 AND c.actif`. Sonde → `preuves/securite/sonde_auth_hors_banc.txt` : sans en-tête 401 ✅ ; `x-ava-groupe` 401 ✅ ; **`x-ava-session` = id ADM → 200, politique changée** ⛔ ; id inconnu → « session inconnue » en HTTP 200 |

## Constats candidats — famille I

**K-1 · La session est l'identifiant du compte, en clair et devinable.** Cible CODE · I-8 · **critique** (faille
exploitable) · preuve `executer.ts:254-265`, `index.ts:149-157`, `preuves/securite/sonde_auth_hors_banc.txt` ·
reproduire :
```bash
cd /c/Users/Hamada/Desktop/ava-audit-2-lecture/server && AVA_PORT=3202 DATABASE_URL=postgres://ava_serveur@127.0.0.1:5432/ava_audit2_b npx tsx src/index.ts &
sleep 8; curl -s -X POST http://127.0.0.1:3202/commandes/SetPolicy -H "content-type: application/json" -H "x-ava-session: 00000000-0000-4000-8000-000000000108" -d '{"cle":"temps.plafond_jour","valeur":"refus"}'
```
· prétend « session requise » (`index.ts:154`) · mesure : `{"ok":true,"commande":"SetPolicy",…"ancienne":"alerte"}`,
HTTP 200 · correction : jeton opaque aléatoire (≥ 128 bits) émis après authentification, stocké **haché** avec
expiration dans une table `session`, `compteDeSession` cherche le hachage — jamais l'id.

**K-2 · Neuf comptes de banc, dont ADM, sont créés par une migration de production.** Cible CODE · I-8 ·
**elevee** (critique combiné à K-1) · preuve `005_droits_lot2.sql:184-206` (ids `…0101` à `…0109`,
`adm@ava.test`, `actif=true`) · reproduire :
```bash
grep -nE "@ava.test" /c/Users/Hamada/Desktop/ava-audit-2-lecture/db/migrations/005_droits_lot2.sql
```
· prétend un seed de « banc » · mesure : toute base migrée (`ava` compris) les porte · correction : comptes de banc
dans un fichier de fixtures chargé par `make test` uniquement, jamais dans `db/migrations/`.

**K-3 · Périmètre percé sur 5 commandes** — voir CONFORMITE.md **H-1** (critique).

**K-4 · Aucune porte ne teste le périmètre par objet ni la session hors banc.** Cible BRAIN (banc) · I-3/I-8 ·
**critique** (porte aveugle sur un point bloquant) · preuve : 147 portes B vertes (`preuves/grille/A1_contrat_*.txt`,
122/122 rejouées) alors que K-1 et H-1 passent ; `test/contrat/matrice.test.ts` ne teste que le groupe ; 52 des 55
portes « commande » ne testent **qu'un refus** (`preuves/grille/F_portes.txt`) · reproduire :
```bash
awk -F'|' '/^\| *P-[0-9]+/ && $5 ~ /commandes.test/ {p=$4; if (p ~ /refuse/) r++; else o++} END{print "refus seul:",r," autre:",o}' /c/Users/Hamada/Desktop/ava-audit-2-lecture/journal/PORTES.md
```
· correction : une porte « hors périmètre » par commande qui vise un objet (agence CAS), une porte « session =
id → refus » sur serveur non-banc.

**K-5 · `if` sur un rôle dans un service.** Cible CODE · B1/I · **elevee** (L4 interdits : « un if sur un rôle dans un
service ») · preuve `identite.ts:346-349` (`groupes.includes(GROUPE.RES)`), `droits.ts:55-58` (`S` = « groupe
RES » en dur) · correction : porter le `S` de la matrice en donnée (type de périmètre `soi` dans
`groupe_permission_perimetre`) et le lire.

**K-6 · pg_hba.conf en `trust` partout.** Cible CODE (poste/infra) · I-5 · **elevee** sur le poste, critique si le
VPS est réglé pareil (non vérifié) · correction : `scram-sha-256` pour `host` et `local`, mot de passe de
`ava_serveur` hors dépôt.

**K-7 · SetOwnTheme enregistre n'importe quel JSON.** Cible CODE · I · **moyenne** · preuve sondes3 #4 (clé
`<script>` et objets imbriqués acceptés, renvoyés tels quels) · correction : liste blanche des clés `ui.*` et
valeurs dans `valeurs_possibles`.

**K-8 · Helpers de test qui interpolent du SQL.** Cible CODE (tests) · I-1 · **moyenne** · `test/contrat/db.ts:32`,
`monde.ts:38` · correction : liste blanche de tables, `where` construit par paramètres.

**K+ · bien fait (bonne).** Valeurs SQL 100 % paramétrées ; refus avant écriture, prouvé sur 135 refus ; murs de
rôles mesurés sur toutes les relations ; serveur qui refuse le superutilisateur et n'écoute que 127.0.0.1 ; aucun
secret dans l'historique ; front sans HTML injecté.

---

# Tous les constats candidats — index par gravité

| Gravité | Constat | Cible | Fichier |
|---|---|---|---|
| **critique** | K-1 session = id du compte, hors banc | CODE | SECURITE |
| **critique** | H-1 / K-3 périmètre percé sur 5 commandes | CODE | CONFORMITE |
| **critique** | K-4 aucune porte sur le périmètre ni sur la session | BRAIN | SECURITE |
| elevee | K-2 comptes de banc (dont ADM) dans la migration 005 | CODE | SECURITE |
| elevee | H-2 décision client inconnue enregistrée en refus | CODE | CONFORMITE |
| elevee | H-3 ArchiveObject sans garde | CODE | CONFORMITE |
| elevee | H-4 ManageRefs : 2 gardes absentes, 1 en MUR | CODE | CONFORMITE |
| elevee | H-5 politique `cascade_cloture_prestations` inopérante | CODE | CONFORMITE |
| elevee | H-6 `liens.politiques` incomplet (SignPrestation, RecordClientDecision) | CODE | CONFORMITE |
| elevee | K-5 `if` sur le rôle RES dans UploadDocument / le `S` en dur | CODE | SECURITE |
| elevee | B1 `if` métier sur des **codes** (statut commercial, couverture, 'ouvert', 'regie', 'autre', 'interne') | CODE | GRILLE |
| elevee | K-6 pg_hba `trust` partout | CODE (poste) | SECURITE |
| elevee | G-1 grille sans famille « accès » | BRAIN | GRILLE |
| elevee | G-2 001_schema.sql réécrite 2 fois | CODE | GRILLE |
| elevee | G-3 CI qui ne peut pas passer | CODE | GRILLE |
| elevee | G-4 le codeur écrit ses portes (`[greffe]` dans test/) | BRAIN | GRILLE |
| moyenne | H-7 SetPolicy perd `commandes_affectees` | CODE | CONFORMITE |
| moyenne | H-8 contrat MUR vs code GARDE (3 commandes) | BRAIN | CONFORMITE |
| moyenne | H-9 entrée mal typée → 500 « ERREUR » non tracée | CODE | CONFORMITE |
| moyenne | H-10 `gardePourvu` routé comme commande | CODE | CONFORMITE |
| moyenne | H-11 garde morte d'ArchiveService | BRAIN+CODE | CONFORMITE |
| moyenne | G-5 grille/outils périmés (F9 « 7 lignes », A4 écrit dans `_ops`, 28 vs 29, colonnes par position) | BRAIN | GRILLE |
| moyenne | K-7 SetOwnTheme sans liste blanche | CODE | SECURITE |
| moyenne | K-8 helpers de test qui interpolent du SQL | CODE | SECURITE |
| moyenne | refus en HTTP 200 ; commande inconnue non tracée ; `SetResourceState` compare à `CAT.candidat.sorti` ; `version_atl` en dur et montants en flottant (`projet.ts:360-376`) ; `assurerBancRes` mute sans événement (banc) ; migrations sensibles à l'encodage client (échec `0x90 WIN1252` quand la sortie n'est pas un fichier — aucun `SET client_encoding`) | CODE | — |

---

# ANGLES MORTS

| Non couvert | Pourquoi | Ce que ça peut cacher |
|---|---|---|
| `make.sh` / `cliquet.sh` non lancés, `contrat/correctifs.test.ts` et Playwright non joués | consigne | une porte ✅ rouge sur ces deux espèces ; F2/F6 jugés à la lecture |
| Serveur **non-banc** sondé sur `SetPolicy` seulement | temps | les autres commandes empruntent le même chemin `compteDeSession` : même faille attendue, non rejouée une à une |
| Variantes de politiques non sondées : `fte`/`postes_et_fte`, `besoin.pourvu.mode=auto_*`, `version_datee`, `change.mode=taux_saisi`, `droits.surcharge_restrictive=union_gagne` avec `compte_surcharge` réel, `societe.passage_client.declencheur=creation_projet`/`manuel` (non implémentées ?) | une sonde par valeur × 173 clés dépasse la passe | des valeurs `valeurs_possibles` lues mais sans branche dans le code (ex. `besoin.staffing.declencheur=retour_client_retenu` n'a aucune branche dans `besoin.ts`) |
| Refus « autre agence si interne » de CreateUnit/UpdateUnit | exige un `societe_role` interne, non créé | message fusionné ou garde absente |
| Murs M-11, M-13, M-15 par commande | les gardes passent avant ; seules les assertions L7 les touchent | un mur que la garde ne voit jamais venir |
| Concurrence (deux signatures simultanées, `nextRef` sous verrou consultatif) | sondes séquentielles | doublon de référence, double pourvu |
| Lectures (vues `vueSociete`/`vuePrestation` en `SELECT *`) | le lot n'expose pas encore de route de lecture | `cjm_contrat` renvoyé à tout groupe qui voit une prestation (le coût de référence, lui, est masqué) |
| Contenu de `tentative_refusee.entree` | non évalué au regard de la donnée personnelle | l'entrée complète (coûts, coordonnées) est gardée pour chaque refus |
| VPS / production | hors poste | pg_hba, mot de passe `ava_serveur`, TLS, exposition du port 3000 |
| Les deux `.zip` à la racine | non ouverts | code tiers non audité dans le dépôt |
| Écran | 629 lignes lues une fois ; le front ne parle qu'au bouchon (`contrat.ts:160`) | le branchement réel front ↔ serveur n'existe pas encore : les actions `actions[]` du serveur ne sont testées par aucun écran |
