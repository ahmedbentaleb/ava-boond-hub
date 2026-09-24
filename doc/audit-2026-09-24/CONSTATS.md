# Constats du cinquième audit — commit `b6ff087` (branche `lot-2`)

Constats **neufs**, numérotés à la suite : V-107 →. Le suivi des 106 précédents est dans `SUIVI_V.md`
(10 fermés · 3 partiels · 3 ouverts, sur les 17 restés ouverts au 4e tour).

**10 constats neufs : 2 critique · 4 elevee · 3 moyenne · 1 bonne.**

⭐ **Le fil des trois derniers tours, en une phrase : le périmètre ne protège que les objets qui portent une
agence.** V-076 l'a fermé pour les objets qui en ont une, V-097 pour ceux dont la colonne est obligatoire,
V-107 et V-108 sont ce qu'il reste — et cette fois la question est un choix de modèle, pas un oubli de code.

---

### V-107 — Un objet dont l'agence est nulle retombe sur l'agence du demandeur : le contrôle se compare à lui-même
Cible        CODE
Famille      I · K4 · Gravité **critique** (mur percé) — et **porte aveugle** : rien ne le garde
Preuve       `server/src/agence.ts:244` : `if (!agenceId && ligne.sinonCompte) agenceId = ctx.compte.agence_id;`
             puis `:249` `exigeDroit(ctx, ctx.commande, agenceId)`. Les lignes `sinonCompte: true` concernées :
             `UploadDocument` (`agence.ts:81`), `CreateAction` (`:127`), `ArchiveObject` (`:136`). Mesuré : un compte
             de l'agence LON **archive** un candidat de PAR (`preuves/securite5/`). ⛔ Mutation **W1** (le repli
             silencieux rétabli) : **0 porte sur 294 ne tombe** (`preuves/banc/W1_agence_nulle_libre.txt`).
             `profil_candidat.agence_id` est resté **nullable** alors que la migration 009 a posé le NOT NULL
             sur `unite_organisation` — la colonne qui n'en avait plus besoin.
Reproduire   `bash rapport/preuves/scripts/sab.sh W1_agence_nulle_libre` → `tombées: aucune`
Prétend      D-21 « agence nulle → périmètre du demandeur exigé » ; V-097 déclaré fermé
Mesure       fermé pour les lignes `sinonCompte: false` (elles exigent le périmètre **global**), ouvert pour les autres
Correction   Même règle pour les deux familles de lignes : agence nulle = périmètre global exigé, et une porte qui tombe quand on l'enlève.

### V-108 — Une société et un contact n'ont aucune agence : pour 7 commandes, le périmètre est une tautologie
Cible        **BRAIN** (choix de modèle) puis CODE
Famille      I · J · Gravité **critique**
Preuve       `db/migrations/001_schema.sql:597` (`societe`) et `:649` (`contact`) : aucune colonne `agence_id`.
             Les 7 commandes correspondantes sont en ligne `COMPTE` (`server/src/agence.ts:35,52-64`), dont
             `sinonCompte: true` sans aucun lecteur : l'agence vérifiée est **celle du demandeur**. Mesuré :
             `ia@ava.test` (PAR) **archive** une société de CAS (`ok:true`, `archive_le` posé), en **renomme** une
             autre, et **renomme** un contact de CAS (`preuves/securite5/`).
Reproduire   `UpdateCompany` / `ArchiveCompany` / `UpdateContact` avec un compte d'une autre agence que le manager
Prétend      grille K4, « le périmètre se juge sur l'objet visé »
Mesure       l'objet n'a pas d'agence à juger : aucune garde n'est possible en l'état du modèle
Correction   ⚠️ **À trancher** : soit une société porte une agence (ou se juge par son manager, ou par ses besoins),
             soit le canon écrit noir sur blanc que les sociétés et les contacts sont **partagés entre agences** —
             et alors la grille K4 doit dire lesquelles des 55 commandes sont hors périmètre par nature.

---

### V-109 — `RecordClientDecision` porte ses décisions en dur, hors référentiel
Cible CODE · B1 · **elevee** · Preuve `server/src/commandes/besoin.ts:313-314` (deux tableaux littéraux) ; une décision ajoutée par `ManageRefs` en `terminal_negatif` → `GARDE « décision inconnue »` · Le grep B1 de la grille ne voit pas un `.includes()` · Correction : lire la catégorie du référentiel, et élargir le grep B1.

### V-110 — V-099 n'est fermé qu'à 5 portes sur 7 : deux rougissent dès qu'on délègue une permission
Cible CODE (banc) · G · **elevee** · Preuve : `ArchiveCompany` délégué sur PAR → P-203 et P-207 tombent (52/52 → 51/52 → 50/52 avec les 5 permissions) ; `triptyque` n'écarte pas les délégations existantes et `retirer()` détruit celles qu'il n'a pas posées · Correction : chaque porte pose et retire **ses** délégations, et ignore les autres.

### V-111 — Deux migrations portent le numéro 009, et le registre n'a aucun rang
Cible BRAIN + CODE · D3 · **elevee** · Preuve `db/migrations/009_couverture_sans_archive.sql` et `009_unite_agence.sql` ; `ava.schema_migrations` a `filename` en clé primaire, **aucune colonne d'ordre** ; l'ordre réel vient du glob. Rejouées en ordre inverse, la base est identique (rc=0), donc rien ne casse **aujourd'hui** — mais un `009_a….sql` passerait avant les deux. `001_schema.sql` a été réécrit 3 fois · Correction : un numéro = un fichier, contrôlé par le cliquet ; ou un rang explicite dans le registre.

### V-112 — La règle F13 est écrite dans la grille mais absente du cliquet : elle ne bloque rien
Cible BRAIN · F · **elevee** · Preuve : `_ops/GRILLE_AUDIT.md` porte F13 (« on n'audite jamais une branche dont `lot-2-brain` n'est pas l'ancêtre ») ; `outils/cliquet.sh` compte **12 cases**, aucune ne la mesure, et sa commande échoue dans un clone neuf (pas de `lot-2-brain` local) · ⚠️ C'est la règle née de deux faux départs d'audit · Correction : une case 13 qui la mesure, avec la référence distante.

---

### V-113 — Vingt commits sans trailer `Role:`, dont onze touchent `test/`
Cible CODE · D5 · **moyenne** · Preuve `git log` sur la branche · Correction : le crochet posé par `installer.sh` ne sert à rien tant que la case 12 est le seul garde-fou, et elle n'est verte que chez qui l'a lancé.

### V-114 — La migration 009 a posé le NOT NULL sur la colonne qui n'en avait plus besoin
Cible CODE · **moyenne** · Preuve : `unite_organisation.agence_id` NOT NULL (ce qui rend `agenceGouvernante()` inatteignable pour les unités) ; `profil_candidat.agence_id` reste nullable, alors que c'est celle que la reprise Boond remplira · Lié à V-107.

### V-115 — Écarts du 4e audit reconduits sans correction
Cible CODE + BRAIN · H · **moyenne** · H-1 (5 permissions sans titulaire au seed) · H-2 (le motif d'archivage jeté) · H-4 (message « 0/1 postes » pour un `fte_vise = 2.0`) · V-103 côté banc (`session: {nom:"Banc", groupe:"IA"}` identique pour tous).

---

### V-116 — Bien fait, à garder
Cible CODE + BRAIN · **bonne**
- **Le banc part de rien** : base refaite par le cliquet (D-20), 294 portes vertes, 32 assertions, `make_rc=0` — V-096 fermé, case 1 verte.
- Les correctifs sont **gardés par des portes qui tombent** : garde d'entrée → 3 portes, vue sans filtre → 2, table d'agence → 16, lecture d'agence → 210, `soi` → 51, identité par défaut → P-292.
- **Les outils de garde sont eux-mêmes gardés** : `ON_ERROR_STOP` retiré → P-299 ; `verif_serveur.sh` muet → P-300 (V-101 fermé).
- V-097 fermé **plus strictement que demandé** pour les objets à agence obligatoire : agence nulle → périmètre **global**.
- Périmètre : 46 sondes hors agence refusées avec témoins positifs ; 15 sabotages SQL sur 15 font tomber les assertions ; hors banc, toutes les routes en 401 et 4 compteurs immobiles.
