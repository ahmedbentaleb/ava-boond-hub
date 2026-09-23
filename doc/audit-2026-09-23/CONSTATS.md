# Constats du troisième audit — commit `416a7a3` (branche `lot-2`)

Constats **neufs**, numérotés à la suite : V-075 →. Le suivi des 74 précédents est dans `SUIVI_V.md`
(37 fermés · 6 partiels · 1 ouvert · 8 bonnes qui tiennent). Preuves dans `preuves/`.

**21 constats neufs : 2 critique · 9 elevee · 9 moyenne · 1 bonne.**

---

### V-075 — Les vues de lecture servent la base à un appelant anonyme, y compris hors mode banc
Cible        CODE
Famille      I · K1 · Gravité **critique** (donnée servie sans droit ni périmètre)
Preuve       `server/src/index.ts:164` (`/vues/besoins`) et `:200` (la fiche) ne lisent ni `modeBanc()`, ni
             `x-ava-groupe`, ni le périmètre, et la requête n'a aucun filtre d'agence. Sonde de l'auditeur
             principal, serveur **sans `AVA_MODE`**, base `ava_audit3_a`, aucun en-tête :
             `GET /vues/besoins` → **HTTP 200**, `compte=81`, 81 lignes (titre du besoin, **nom de la société**, état)
             — `preuves/controles_neufs3.txt` C3-N1. Sur la base chargée du jeu d'essai : **1932 besoins**
             (`preuves/securite3/`). Témoin dans la même sonde : `POST /commandes/CreateCompany` → **401**
             « authentification non livrée (lot 2c) ».
Reproduire   `curl -s http://127.0.0.1:<port>/vues/besoins | head -c 400` (serveur lancé sans `AVA_MODE`)
Prétend      D-10 / K1 : « hors `AVA_MODE=banc`, le serveur refuse TOUT appel »
Mesure       D-10 n'a fermé que `POST /commandes/:nom` ; les routes de lecture sont restées ouvertes
Correction   Faire passer les vues par le même garde que les commandes : 401 hors banc, filtre de périmètre en banc.

### V-076 — `crm.ts` n'a aucune garde de périmètre : un compte de Paris crée, renomme et archive une unité d'une autre agence
Cible        CODE
Famille      H · I · K4 · Gravité **critique** (mur percé)
Preuve       `grep -c exigeObjet server/src/commandes/*.ts` → admin 2 · besoin 5 · **crm 0** · identite 9 · projet 6.
             `CreateUnit` accepte `agence_id` **en entrée** (`crm.ts:136`, `:172`) et n'exige le droit que sur l'agence
             du compte. Sondes : `[IA/PAR] CreateUnit` → `ok:true` avec `agence_id = AVFR` ; `UpdateUnit` → unité AVFR
             renommée ; `ArchiveService` → unité AVFR archivée (`preuves/securite3/perimetre_objet.txt`).
Reproduire   `curl -s -X POST .../commandes/UpdateUnit -H 'x-ava-groupe: IA' -d '{"id":"<unité d'une autre agence>","nom":"x"}'`
Prétend      MATRICE §procédure étape 4 et grille K4 : « le périmètre se juge sur l'objet visé » ; H-1 déclaré fermé
Mesure       les 5 trous du 2e audit sont fermés **commande par commande** ; les 3 unités/services n'ont jamais été traités
Correction   Résoudre l'agence de l'objet dans `executerCommande` (table commande → table → colonne) au lieu d'un appel à ne pas oublier dans 55 handlers.

---

### V-077 — Le cliquet ne voit pas une porte ✅ supprimée dans un commit plus ancien que `HEAD~1`
Cible CODE (banc) · F12 · **elevee**
Preuve       `preuves/banc/C_portes_lot2.txt` : 70 portes P-2xx effacées **sans commit** → case 11 **KO** « perdues : P-200 … » ✅.
             `preuves/banc/C_portes_commit.txt` : les **mêmes** effacées dans un commit, puis un commit de plus →
             case 11 **OK**, « ⚠️ exécutées hors tableau : P-200 … », `cases OK=11 KO=1` (le seul KO est la case 12, sans rapport).
Reproduire   `bash rapport/preuves/scripts/cliquet3.sh C_portes_commit portes_commit`
Prétend      `cliquet.sh:237` : « AUCUNE PORTE ✅ NE DISPARAÎT, même propre à la branche »
Mesure       la fenêtre est HEAD, HEAD~1 et `main` ; deux commits suffisent à sortir de la fenêtre, et
             « exécutée hors tableau » n'est qu'un ⚠️, jamais un KO
Correction   Comparer au point de départ de la branche (`git merge-base main HEAD`) et faire de « porte exécutée absente du tableau » un KO.

### V-078 — Hors banc, un POST anonyme écrit une ligne dans `tentative_refusee`, sans plafond
Cible CODE · I/K1 · **elevee** · Preuve : 60 POST anonymes → +60 lignes, `auteur_compte_id IS NULL`, le corps de la requête recopié en jsonb (`index.ts:236`, `executer.ts:129`) · Correction : hors banc, rendre le 401 sans tracer. Source `SECURITE3.md` I-03

### V-079 — `CreatePrestation` réussit sur un projet clos
Cible CODE · H · **elevee** · Source `CONFORMITE3.md` C-02

### V-080 — `SetPolicy` rend une liste de commandes affectées **vide** pour `droits.surcharge_restrictive` et `historique.tentatives_refusees`
Cible CODE · H §C-5 · **elevee** (H-7 reste partiel) · Source `CONFORMITE3.md` C-03

### V-081 — `ArchiveObject` n'émet pas son événement pour 3 types sur 10, et perd le motif
Cible CODE · H · **elevee** · Source `CONFORMITE3.md` C-04

### V-082 — `v_besoin_couverture` compte les prestations archivées
Cible CODE · H/B · **elevee** (donnée fausse servie) · Source `CONFORMITE3.md` C-06

### V-083 — `TakeNeedInCharge` refuse toujours sous le seed livré, et avec le mauvais code
Cible CODE · H · **elevee** · Source `CONFORMITE3.md` C-07

### V-084 — La garde « catégorie inconnue » de `ManageRefs` n'existe que sur les tables qui portent `ck_cat`
Cible CODE · H · **elevee** · Preuve : sur `ref_pays`, une catégorie inventée s'écrit ; P-201 ne teste que le référentiel contraint · Source `SUIVI_V.md` N3-2

### V-085 — Le contrat dit `MUR` là où le code dit (mieux) `GARDE` — H-8 reste ouvert
Cible BRAIN · H · **elevee** (le canon décrit un comportement que le code ne tient pas) · Preuve `_ops/SPEC_COMMANDES_L4.md` inchangé · Source `CONFORMITE3.md` C-09

---

### V-086 — Les comptes de banc réactivés en base ne font tomber aucune porte
Cible CODE (banc) · G · **moyenne** · Preuve : `UPDATE ava.compte SET actif = true WHERE email LIKE '%@ava.test'` → 264/264 vertes (`preuves/banc/T6_comptes_banc_actifs.txt`) · Correction : une porte qui relit `actif` des 9 comptes après migration, avant la fixture.

### V-087 — Joué sans `ON_ERROR_STOP`, le fichier d'assertions rend `rc=0` alors que 13 assertions ne passent pas
Cible BRAIN · A/C · **moyenne** · Preuve `preuves/controles_neufs3.txt` C3-N2 : trigger `tg_m10` désactivé → sans le drapeau `rc=0` et 18 « OK M- » sur 31 ; avec le drapeau `rc=3`. Le banc met le drapeau (`make.sh`), une main humaine ne le met pas · Correction : `\set ON_ERROR_STOP on` en tête du fichier lui-même.

### V-088 — `NeedStateChanged` porte un code d'état écrit en dur, et pas `{de, vers}`
Cible CODE · H · **moyenne** · Source `CONFORMITE3.md` C-05

### V-089 — Onze commandes lisent des politiques que leur ligne de contrat n'annonce pas
Cible BRAIN + CODE · H · **moyenne** · Source `CONFORMITE3.md` C-08

### V-090 — Quatre commandes contractées ne sont jouées par aucune porte autrement que par leur absence de droit
Cible CODE (banc) · G · **moyenne** · Source `CONFORMITE3.md` C-10

### V-091 — `ManageGroups` déguise une erreur de type en garde
Cible CODE · H · **moyenne** · Source `CONFORMITE3.md` C-11

### V-092 — En banc, la « session » reste un nom de groupe dans un en-tête, et l'auteur enregistré n'est pas l'acteur
Cible CODE · I · **moyenne** (assumé jusqu'au lot 2c, mais l'événement porte un auteur faux) · Source `SECURITE3.md` I-04

### V-093 — Rien dans le dépôt ne mesure le `pg_hba` d'un serveur ; V-022 reste ouvert
Cible BRAIN · I/K5 · **moyenne** · Source `SECURITE3.md` I-05

### V-094 — Trois constats anciens restent partiels
Cible CODE · **moyenne** · V-014 (`doublon.contact.cles` à une seule branche ; `societe.passage_client.propagation` ne modifie aucune donnée) · V-019 (le fond de page n'est pas vérifié en couleur calculée) · V-032 (3 types délégués rendent une sortie sans id) · Source `SUIVI_V.md`

---

### V-095 — Bien fait, à garder
Cible CODE + BRAIN · **bonne**
- **0 porte aveugle sur 50 sabotages** (48 → 45 → 0) ; les 40 portes « refuse INTROUVABLE » sont devenues des portes qui **relisent la base**.
- D-10 tenu sur les commandes : 7 commandes sur 7 refusées hors banc, 0 écriture métier ; D-11, D-12, D-13 tenus et mesurés.
- Les 5 trous de périmètre du 2e audit sont fermés **et prouvés fermés** par un contrôle positif (la même commande réussit dans le périmètre).
- Murs de rôles : 0 DELETE, 0 TRUNCATE, 0 UPDATE interdit ; le rôle d'agrégats voit exactement 7 relations ; 31 assertions, plancher compté.
- Cliquet : 12 cases, serveur mort et portes effacées sans commit détectés ; `installer.sh` posé par la CI.
- 55 commandes servies = 55 contractées, 0 fantôme des deux côtés ; `liens.politiques` porte clé **et** valeur.
