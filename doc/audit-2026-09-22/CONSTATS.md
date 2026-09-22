# Constats du second audit — commit `7e3f78c` (branche `lot-2`)

Constats **neufs**, numérotés à la suite du premier audit (V-048 →). Les 47 premiers sont suivis dans
`SUIVI_V.md` (22 fermés · 15 partiels · 2 ouverts · 7 bonnes qui tiennent · 1 historique).
Le détail long de chaque constat est dans le brouillon cité en « Source » ; les preuves dans `preuves/`.

**27 constats neufs : 3 critique · 10 elevee · 13 moyenne · 1 bonne.** Du plus grave au moins grave.

---

### V-048 — Hors banc, la « session » est l'identifiant du compte en clair : n'importe qui agit en ADM
Cible        CODE
Famille      I (sécurité) · J (contestation de D-2)
Gravité      **critique** — faille exploitable
Preuve       `server/src/executer.ts:72-83` (`compteDeSession` : `WHERE c.id::text = $1`) ; `server/src/index.ts:149-157`
             (hors banc, seule la **présence** de `x-ava-session` est exigée) ; identifiants fixes et consécutifs
             `db/migrations/005_droits_lot2.sql:185-193` (…0101 → …0109). Sonde, serveur **sans** `AVA_MODE`, base
             `ava_audit2_n` : `ManageRefs` avec `x-ava-session: 00000000-0000-4000-8000-000000000108` → HTTP 200
             `ok:true RefChanged`, ligne `ref_pays ZZ` écrite, auteur = compte ADM (`preuves/controles_neufs.txt` C-N3).
             Même résultat sur `SetPolicy` par deux auditeurs (`preuves/securite/sonde_auth_hors_banc.txt`,
             `preuves/canon/J_session_uuid.txt` : ADM trouvé au 9e essai ; « session inconnue » sert d'oracle).
Reproduire   `cd server && AVA_PORT=3204 DATABASE_URL=postgres://ava_serveur@127.0.0.1:5432/<base> npx tsx src/index.ts &`
             puis `curl -X POST http://127.0.0.1:3204/commandes/ManageRefs -H "x-ava-session: 00000000-0000-4000-8000-000000000108" -H "content-type: application/json" -d '{"referentiel":"ref_pays","code":"ZZ","libelle":"x","categorie":"europe"}'`
Prétend      D-2 / P-066 : « x-ava-groupe refusé hors banc », « session requise »
Mesure       l'en-tête `x-ava-groupe` est fermé (401, rien d'écrit — C-N2), mais la porte qui le remplace n'a pas de serrure
Correction   Une session est un jeton opaque aléatoire émis après authentification, stocké haché avec une expiration — jamais l'id du compte.
Source       `SECURITE.md` K-1 · `CANON.md` J-2 · `SUIVI_V.md` N-1 · V-003 reste **Ouvert**

### V-049 — Aucune porte ne teste l'accès : session, compte désactivé, périmètre par objet ; 45 portes aveugles
Cible        les deux (CODE écrit les portes, BRAIN écrit la grille)
Famille      G (mutation) · I · grille (aucune famille « accès »)
Gravité      **critique** — portes aveugles sur un point bloquant
Preuve       `MUTATIONS.md` : **45 portes aveugles** (40 « refuse INTROUVABLE », P-153, P-133, P-006, P-060, P-146) ;
             N3 (session sur compte **désactivé**) → 151/151 vertes ; V-048 passe avec 151/151 vertes ;
             périmètre : 5 commandes écrivent sur une autre agence — `WithdrawPositioning`, `RecordQualification`,
             `UploadDocument`, `CreateAction`, `ArchiveObject` (`CONFORMITE.md` H-1, `SUIVI_V.md` V-004) — sans qu'aucune porte ne tombe.
             `test/contrat/matrice.test.ts` ne teste que le groupe ; P-066 ne teste que `x-ava-groupe`.
Reproduire   `bash rapport/preuves/scripts/sab.sh N3_session_sans_actif` → `tombées: aucune`
Prétend      « le cliquet vert = le lot tient » ; GRILLE §C « les murs »
Mesure       l'accès n'a ni porte ni contrôle de grille : il peut casser sans qu'un seul feu passe au rouge
Correction   Une porte « hors périmètre » par commande qui vise un objet, une porte « session = id → refus » et « compte inactif → refus » sur serveur non-banc, et une famille « accès » dans la grille.
Source       `SECURITE.md` K-4 · `GRILLE.md` G-1 · `MUTATIONS.md`

### V-050 — Le cliquet reste 10/10 quand on retire des portes ✅ propres à `lot-2`
Cible        CODE (banc)
Famille      F (cliquet) · F6
Gravité      **critique** — le cliquet est le point bloquant du projet
Preuve       `preuves/banc/C_portes_lot2.txt` : lignes P-150 → P-153 retirées de `journal/PORTES.md`, `outils/cliquet.sh` réel
             → `cases OK=10 KO=0`, case 1 « exécutées=151 ✅=147 ». Cases 3 et 9 ne comparent qu'à `main` (5 portes servies) ;
             case 1 n'exige que les portes **encore écrites** dans le tableau. Témoins : P-002→005 retirées → case 3 KO ;
             serveur mort → case 1 KO (les deux témoins du BRAIN sont vrais).
Reproduire   `bash rapport/preuves/scripts/cliquet2.sh C_portes_lot2 portes_lot2`
Prétend      « une porte ✅ ne redevient jamais ⏳ » (`journal/PORTES.md:1`)
Mesure       146 des 151 portes ✅ peuvent être effacées du tableau sans qu'aucune case ne bouge
Correction   Comparer aussi au `PORTES.md` du dernier commit de la branche (ou de la base de la PR), et signaler toute porte exécutée absente du tableau.
Source       `SUIVI_V.md` N-4

---

### V-051 — Les portes lisent et écrivent la base « ava » du CODE dès que `DATABASE_URL` manque
Cible        CODE (banc) · Famille I/A · Gravité **elevee**
Preuve       `test/contrat/db.ts:7` (défaut `…/ava`) ; `outils/make.sh` n'exporte jamais `DATABASE_URL` ; `test/contrat/correctifs.test.ts:137`
             lance un serveur sur `ava` **en dur** ; ports 3010/3011 fixes. Avec `AVA_DB=ava_audit2`, le serveur écrit dans une base
             et P-066 compte les événements dans une autre. Si le refus superutilisateur tombait, P-136 ferait écrire `assurerBancRes` dans `ava`.
Reproduire   `grep -n "5432/ava" test/contrat/*.ts ; grep -n DATABASE_URL outils/make.sh`
Correction   `make.sh` exporte `DATABASE_URL` (base choisie), `db.ts` lève si elle manque, `correctifs.test.ts` lit l'URL de l'environnement.
Source       `SUIVI_V.md` N-2 · `MUTATIONS.md` (N5 non joué pour cette raison)

### V-052 — P-133 « temps.plafond_jour : alerte vs refus » ne joue jamais `RecordTimesheet`
Cible        CODE (banc) · Famille G · Gravité **elevee**
Preuve       `test/contrat/politiques.test.ts:74-87` règle la politique et la relit ; S5e (`plafond = "alerte"` en dur) → 0 porte tombe
             (`preuves/banc/S5_temps.plafond_jour.txt`).
Correction   Saisir 1,5 j sous `alerte` (écrit + alerte), puis sous `refus` (GARDE, rien d'écrit).

### V-053 — Neuf comptes de banc, dont ADM, sont semés par une migration de production
Cible        CODE · Famille I · Gravité **elevee** (critique combiné à V-048)
Preuve       `db/migrations/005_droits_lot2.sql:184-206` (`adm@ava.test` … actifs) : toute base migrée les porte.
Correction   Les comptes de banc vont dans une fixture chargée par `make test` seulement, jamais dans `db/migrations/`.
Source       `SECURITE.md` K-2

### V-054 — `RecordClientDecision` range toute décision inconnue en refus client
Cible CODE · H/B1 · **elevee** · Source `CONFORMITE.md` H-2

### V-055 — `ManageRefs` : deux gardes du contrat absentes, la troisième tombe en MUR ; un renommage réactive une valeur désactivée
Cible CODE · H · **elevee** · Preuve `admin.ts:107-133` ; `categorie_inventee` → MUR ; `7 false → 7 true` · Source `CONFORMITE.md` H-4, `SUIVI_V.md` N-8, V-036

### V-056 — La politique `projet.cloture.garde = cascade_cloture_prestations` rend `CloseProject` impossible
Cible CODE · H/B · **elevee** · Source `CONFORMITE.md` H-5

### V-057 — `liens.politiques` incomplet : des politiques lues ne sont pas tracées (SignPrestation, RecordClientDecision)
Cible CODE · H règle 4 · **elevee** · Source `CONFORMITE.md` H-6

### V-058 — `if` sur le rôle RES dans un service ; la règle « S » est écrite en dur
Cible CODE · B1/I · **elevee** · Preuve `identite.ts:346-349` (`groupes.includes(GROUPE.RES)`), `droits.ts:55-58` · Source `SECURITE.md` K-5
Correction   Porter le `S` de la matrice en donnée (périmètre `soi`) et le lire.

### V-059 — La grille d'audit n'a aucun contrôle d'authentification ni de périmètre par objet
Cible BRAIN · grille · **elevee** · Preuve : grille passée à la lettre = 0 🔴 alors que V-048 et V-004 passent · Source `GRILLE.md` G-1

### V-060 — D5 et F7 ne se mesurent pas : le codeur serveur écrit ses portes, le crochet n'est posé par rien
Cible BRAIN · D5/F7 · **elevee** · Preuve : `test/` écrit par `banc` (18 commits), `greffe` (5), `ecran` (1), 1 sans rôle ; 8 commits sur 52 sans `Role:` dont 007 ; `core.hooksPath` vide dans un clone neuf · Source `GRILLE.md` G-4, `CANON.md` J-8, `CONTESTATION.md` l.7

---

### V-061 — Les refus « session inconnue » ne sont jamais tracés
Cible CODE · I · **moyenne** · Preuve : `tracerRefus` insère `''` dans une colonne uuid (22P02) ; 0 ligne après énumération · Source `CANON.md` J-2b

### V-062 — Les chiffres du canon se contredisent : 167 / 169 / 173 politiques, 37 / 43 tables, 44 / 55 commandes, 22 / 29 assertions
Cible BRAIN · J · **moyenne** · Preuve `REGISTRE_POLITIQUES_v1.md:329-332` (79 + 2 + 86 = 167 contre 173) ; base : 173, 43 tables · Source `CANON.md` J-1, J-10

### V-063 — La spec décrit un schéma qui n'est pas la base (ignore 005 et 007, garde un CHECK retiré)
Cible BRAIN · J · **moyenne** · Preuve `SPEC_SQL:658` · Source `CANON.md` J-3

### V-064 — Trois restes dans MACHINES_ETAT après D-4, D-5, D-8
Cible BRAIN · J · **moyenne** · Preuve `MACHINES:23` (`NeedStateChanged` absent de L4), `:91` (`CancelPrestation` : DP, base DP+STAF), `:32` (`sorti` « système », base `systeme=false`) · Source `CANON.md` J-4 → J-6

### V-065 — La grille est périmée : B5 donne un faux 🔴, F9 « 7 lignes », A4 écrit dans `_ops/`, famille F « contrats » inexistante
Cible BRAIN · grille · **moyenne** · Source `CANON.md` J-7, J-14 · `GRILLE.md` G-5

### V-066 — `ETAT_PROJET.md`, « source unique », était en retard le jour de son écriture
Cible BRAIN · J · **moyenne** · Preuve : lot 2c ⬜ alors que le code sert déjà une session ; « élevés et moyens en cours » alors que 37 V- avaient leur commit · Source `CANON.md` J-9

### V-067 — L'arbitrage compte 5 requalifications (le tableau en montre 6) et la condition de V-022 n'est écrite nulle part où on la vérifie
Cible BRAIN · J · **moyenne** · Source `CONTESTATION.md` l.1 et l.6 · `CANON.md` J-11, J-13

### V-068 — `SetPolicy` accepte n'importe quelle valeur libre (une liste JSON réglée à « pas du json »)
Cible CODE · B · **moyenne** · Preuve `admin.ts:80-87` · Source `SUIVI_V.md` N-9

### V-069 — Après le jeu d'essai, le compte RES perd son profil ressource et `assurerBancRes` ne le recrée pas
Cible CODE · banc · **moyenne** · Preuve `index.ts:78` · Source `SUIVI_V.md` N-6

### V-070 — Les assertions ne couvrent pas M-12 sur `contact` ni sur `projet`
Cible BRAIN · C · **moyenne** · Preuve : `DISABLE TRIGGER tg_m12` sur ces deux tables → assertions rc=0 · Source `SUIVI_V.md` N-7

### V-071 — `SetOwnTheme` enregistre n'importe quel JSON (clé `<script>` acceptée et rendue)
Cible CODE · I · **moyenne** · Source `SECURITE.md` K-7

### V-072 — Les aides de test interpolent du SQL (`compter(table, where)`)
Cible CODE · I · **moyenne** · Preuve `test/contrat/db.ts:32`, `monde.ts:38` · Source `SECURITE.md` K-8

### V-073 — Écarts de contrat mineurs : MUR écrit là où le code dit (mieux) GARDE, `gardePourvu` routé comme commande, garde morte d'`ArchiveService`, entrée mal typée → HTTP 500 non tracé
Cible BRAIN + CODE · H · **moyenne** · Source `CONFORMITE.md` H-8 → H-11, H-9

---

### V-074 — Bien fait, à garder
Cible CODE + BRAIN · **bonne**
- 13 sabotages SQL sur 13 font tomber les assertions (7 sur 10 au premier tour) ; 29 assertions = plancher compté ; `test/` = `_ops/` (même empreinte).
- Le serveur refuse de démarrer en superutilisateur, sans rien écrire (C-N1) ; `x-ava-groupe` hors banc → 401, rien d'écrit (C-N2).
- 135 refus, 0 écriture ; 54/54 commandes appelées par SUP → DROIT ; GRANT réels conformes (0 DELETE, 0 TRUNCATE).
- Le cliquet voit un serveur mort et 4 portes de `main` retirées (témoins du BRAIN vrais).
- Un événement non écrit fait tomber 70 portes, même sur une base déjà jouée (S2b réparé).
