# SECURITE10 — famille I et la chasse · auditeur B (base `ava_audit10_b`, port 4002)

> ⚠️ Numérotation : ce document garde les numéros de travail de son brouillon. Les constats rendus sont dans `CONSTATS.md` (V-162 → V-178), table de correspondance à la fin.


**Aucune fuite d'agence, aucune lecture sans permission, aucun accès hors banc : les murs déclarés tiennent, re-mesurés.**
La chasse trouve ce que les portes énumératives ne voient pas : **32 réponses 500 et 8 MUR** sur 121 entrées bien typées, une route de commande qui accepte `constructor`, deux horloges, et des écritures hors commande.

---

## 1 · Les contrôles demandés

| Contrôle | Verdict | Mesure | Preuve |
|---|---|---|---|
| SQL paramétré | ✅ | Tous les identifiants interpolés (`${…}`) viennent d'une constante du code, d'un `ident()` à regex `^[a-z_]+$`, du catalogue, ou de `^ref_[a-z_]+$` + existence dans `ava` (`ManageRefs`) ; toutes les valeurs passent en `$n`. 0 interpolation d'une entrée. | lecture de chaque site `${…}` en SQL de `server/src` (`agence.ts`, `cycle.ts`, `kernel.ts`, `commandes/admin.ts`, `commandes/besoin.ts`) |
| Refus avant écriture | ✅ | P-339 rejouée : 691 identifiants hors agence, 0 écriture ; tout refus fait `ROLLBACK` (`executer.ts`) ; la cascade qui avale un `GARDE` (`effetsSignature` → `DeclareNeedFilled`) ne l'avale qu'avant toute écriture de la fille (garde §C-2 avant `appliquerTransition`). | `preuves/grille10/p339_rejouee.txt` |
| GRANT par colonne (`020`) contre les écritures | ✅ | `ava_app` : INSERT = 22 tables + 75 `ref_*` ; UPDATE = colonnes écrites, à l'égalité stricte (0 accordé non écrit, 0 écrit non accordé) ; `ava_serveur` : **mêmes 408 privilèges**, aucun en propre ; `ava_lecture_agregats` : **0** privilège d'écriture, 7 relations lisibles (C4). | `preuves/securite10/grant_contre_ecritures.txt` |
| Lectures (`lectures.ts`, D-46) | ✅ | Groupes **sans** `LireBesoins` (ADM, RES, CROISE) → 403 sur `/vues/besoins` et `/vues/besoins/:id`, **rien lu** ; les 6 groupes d'agence voient PAR (121 lignes), pas LYO (404 sur la fiche) ; SUP global voit les deux ; sans en-tête → 403. | `preuves/securite10/lectures_banc.txt` |
| Hors `AVA_MODE=banc` | ✅ | 29 sondes : tout 401 sauf `/sante` ; **JSON mal formé, `text/plain`, corps de 1,1 Mo → 401** (le 500 du 9e audit ne revient pas) ; `/tuyau`, `/acquitter`, `/`, statiques, `OPTIONS`, commande inconnue → 401 ; empreinte des 147 tables : **0 modifiée**. | `preuves/securite10/hors_banc.txt` |
| Empreinte des migrations appliquées | ✅ (sur base neuve) | 22/22 : `schema_migrations.sha256` = sha256 du fichier en fins de ligne LF ; les 5 migrations de `origin/main` identiques dans HEAD. ⚠️ Sur une base neuve la comparaison est vraie par construction ; la base qui a **vécu** (`ava`) est hors de mon périmètre. | `preuves/grille10/a1_b3_empreintes.txt` |
| Comptes | ✅ | Serveur en `ava_serveur` (`pg_stat_activity`) ; compte désactivé : DROIT, 0 écriture ; UUID de compte en en-tête : refusé. | `preuves/securite10/k2_k3_c2.txt` |

---

## 2 · La chasse — ce que les portes énumératives ne couvrent pas

Les portes énumèrent ce qui est **déclaré** : `HANDLERS`/`DECLARATION` (P-339), `COMPORTEMENTS` (P-350/P-352), les écritures extraites par `outils/ecritures_serveur.mjs` (P-325), `LECTURES` (P-349). Chaque trou ci-dessous est hors de ces listes.

### I-1 🟠 (gravité élevée) — Une entrée bien typée, invalide pour la base, sort en 500 ou en MUR
- **Famille** : `typeRefuse` contrôle la **forme** (date = `^\d{4}-\d{2}-\d{2}`, décimal = `^-?\d+(\.\d+)?$`, code = chaîne non vide, liste = tableau) ; la base contrôle le **domaine** (calendrier, précision, clé étrangère, CHECK, trigger). Entre les deux, `pgMur` ne traduit que `22P02`, `23505`, `23514`, `23503` et « MUR M- » : tout le reste (`22008`, `22003`, `23502`, `P0001`) sort en **500**. L4 : « jamais un 500 », « un `MUR` visible est un bug de garde ».
- **Étendue mesurée** — sonde automatique : pour chaque commande et chaque clé `valeur` déclarée, une valeur de la bonne forme mais invalide (date `2026-02-30`, décimal à 30 chiffres, code `zz_inconnu`, liste `[1]`) :
  **121 sondes · 32 × 500 · 8 × MUR** — soit **21 clés de 14 commandes** en 500 (`CreatePerson`, `UpdateResourceCost`, `RecordQualification`, `CreateNeed`, `DeclareCVShared`, `RecordClientDecision`, `CreatePrestation`, `SignPrestation`, `ClosePrestation`, `RecordTimesheet`, `AdjustTimesheetAfterClose`, `RecordAbsence`, `CreateAction`…) et **5 clés de 5 commandes** en MUR (`UpdateCompany.pays`, `UpdateCandidate.disponibilite_code`, `UpdateResource.disponibilite_code`, `CreateProjectFromNeed.type`, `CreatePrestation.cjm_devise`). Sondes manuelles en plus : trigger `besoin_couverture` (`CreateNeed couverture=postes + fte_vise`) → 500 ; `nb_postes_vises = 0` → MUR ; `mesures=[{competence_code:"zz"}]` → MUR.
  Et l'inverse — un code **écrit sans contrôle** : `profil_candidat.provenance` n'a ni clé étrangère vers `ref_provenance` ni `exigeRef` : `provenance = "zz_inconnu"` est **écrit** (2 lignes en base) par `CreateCandidate` et `UpdateCandidate`.
- **Correction de construction** : la déclaration porte le **domaine** de chaque valeur — la table de référence de chaque `code` (`ref: "ref_pays"`), la précision de chaque décimal (lue dans `information_schema.columns` de la colonne cible), une vraie date (aller-retour calendrier), le schéma des éléments d'une `liste` ; `remplirValeurs` refuse `GARDE` avant le handler. `pgMur` traduit **toutes** les classes `22`, `23`, `P0` (jamais 500), et le trigger `besoin_couverture` a sa garde jumelle.
- **Porte** : la sonde ci-dessus (`preuves/securite10/scripts_a10b/t_fuzz.mjs`), sur **toutes** les clés `valeur` de `DECLARATION` : 0 × 500, 0 × MUR, 0 code inconnu écrit. Aujourd'hui : 40 rouges.

### I-2 🟠 — Le routage des commandes est une recherche dans un objet ordinaire
- **Famille** : des tables indexées par une entrée utilisateur (`HANDLERS[nom]`, `CORRESPONDANCE[nom]`, `DECLARATION[cmd]`, `ligne.refusType[type]`, `ARCHIVE[type]`, `COMPORTEMENTS[cle]`) héritent d'`Object.prototype`.
- **Étendue mesurée** : `POST /commandes/constructor`, `toString`, `__proto__`, `hasOwnProperty`, `valueOf`, `__defineGetter__`, `isPrototypeOf` → **7/7 en 500** : chacun passe les deux barrières d'`executerCommande` (« commande inconnue », « sans correspondance d'agence »), ouvre une transaction, résout le compte, puis lève `TypeError: d.champs is not iterable`. 0 écriture (ROLLBACK). `ArchiveObject {type: "constructor"}` est arrêté par hasard (`refusType["constructor"]` est vrai → « utiliser function Object() … »). La porte P-339 énumère `Object.keys(HANDLERS)` : elle ne voit jamais ces noms.
- **Correction** : toute table indexée par une entrée est un `Map` (ou `Object.create(null)`, ou `Object.hasOwn`) ; `executerCommande` refuse `INTROUVABLE` tout nom absent des clés **propres**.
- **Porte** : la liste des membres d'`Object.prototype` envoyée comme nom de commande, comme `type` d'`ArchiveObject` et comme `cle` de `SetPolicy` → `INTROUVABLE`/`GARDE`, jamais 500.

### I-3 🟡 — Des routes servies qui ne sont pas dans `LECTURES`
- **Famille** : `LECTURES` est une liste écrite à côté des `app.get` ; la porte P-349 énumère la liste, pas le serveur.
- **Étendue mesurée** (`grep app.get/app.post server/src/index.ts`) : 6 routes ; 2 hors `LECTURES` et hors `/sante`/`/commandes/:nom` : `GET /tuyau` (et `HEAD`), `POST /acquitter` — **200 sans aucune identité** en banc ; plus le gestionnaire statique et le `NotFound` → `index.html`. Contenu : un thème et un titre, aucune donnée. Hors banc : 401.
- **Correction** : les routes de lecture s'**enregistrent depuis** `LECTURES` (une boucle), chacune avec sa permission ; les routes de démonstration du lot 1 sortent du serveur.
- **Porte** : `app.printRoutes()` = `LECTURES` ∪ {`/sante`, `/commandes/:nom`}, égalité stricte.

### I-4 🟠 — Des écritures qui ne passent par aucune commande
- **Famille** : P-325 et la règle « une commande qui mute émet un événement » ne voient que les écritures extraites de `server/src` hors `index.ts`.
- **Étendue mesurée** :

| Écrivain | Ce qu'il écrit | Événement | Mesure |
|---|---|---|---|
| `assurerBancRes` (`index.ts`, exclu d'`ecritures_serveur.mjs`) | `INSERT personne`, `INSERT profil_ressource`, `UPDATE compte SET personne_id` | aucun | ⚠️ `UPDATE compte (personne_id)` **n'est pas accordé** à `ava_app` : le jour où il s'exécute, il échoue en silence (`console.error`). Gardé par la seule variable `AVA_MODE`. |
| `tracerRefus` (banc) | `tentative_refusee` avec le **corps entier** de la requête | — | une requête **sans en-tête** (sans compte) écrit une ligne ; jusqu'à 1 Mo par appel. 981 lignes après mes sondes. |
| Migrations de données | `010` (unités), `011` (sociétés, contacts, candidats : `agence_*`), `022` (`temps.etat_code`) — 16 écritures métier | aucun | `010`/`011` cherchent l'auteur dans `evenement_metier` avec `objet_type = 'unite_organisation'` / `'profil_candidat'`, alors que les commandes émettent `'unite'` / `'candidat'` : cette passe ne peut **jamais** trouver une ligne, tout tombe sur `agence_defaut`. `preuves/securite10/migrations_ecritures_donnees.txt` |
| `noterLecture` (`kernel.ts`, banc) | `os.tmpdir()/ava-carte-politiques.jsonl` | — | fichier **partagé par tous les serveurs de banc du poste** : 3,9 Mo, 61 063 lignes au moment de la mesure ; P-351 le relit et peut verdir sur la ligne d'un autre serveur. |
| Triggers `BEFORE` | `etat_categorie`, `positionnement.personne_id`, `politique.modifie_le` | — | colonnes dérivées, hors GRANT par construction — conforme. |

- **Correction** : un **registre unique des écrivains** — extraction de `server/src` **entier**, des fonctions et triggers (`pg_proc.prosrc`), des migrations ; la fixture remplace `assurerBancRes` (D-11 le dit déjà) ; une migration de données émet un `evenement_metier` de type `DataMigrated` ; `tracerRefus` ne trace qu'un refus d'un compte résolu et tronque l'entrée ; la carte D-42 est nommée par processus.
- **Porte** : P-325 sur le registre élargi (aucune exclusion de fichier) ; une porte « toute écriture de table métier a un événement dans la même transaction » jouée par trigger de banc (`AFTER INSERT/UPDATE` qui exige un `evenement_metier` du même `txid`).

### I-5 🟠 — Les cascades : la fille re-juge, mais l'entrée est construite par la mère depuis la base
- **Famille** : `executerDans` fait passer la fille par sa garde (D-43) — **aucune fuite** mesurée — mais ses identifiants (`projet.societe_id`, `projet.contact_id`, `projet.besoin_id`, prestations du projet) ne sont **pas** ceux que la garde de la mère a jugés ; la fille les juge sous les droits de l'appelant, et son refus fait tomber la mère. `propagerPassageClient` écrit en plus `contact.statut_commercial_code` sur des contacts qu'**aucune** garde ne juge (choisis par société).
- **Étendue mesurée** : sous `par_besoins`, `SignPrestation` d'une prestation **de l'agence de l'acteur** est refusée `DROIT` parce que la cascade `RequalifyCompany` vise une société sans besoin (P-339, positif « noté », non jugé) ; 13 positifs dans ce cas (GRILLE10 G-3). Contacts propagés : invariant « contact dans l'agence de sa société » tenu **par le code seul** (0 écart sur le jeu d'essai chargé : [volume réel retiré] contacts), aucune contrainte en base.
- **Correction** : la mère **déclare** ses filles et les identifiants qu'elle leur passe (`CASCADES: { mere, fille, entree: ["projet.societe_id", …] }`) ; la garde de la mère juge ces identifiants **avant** toute écriture ; l'invariant d'agence du contact devient une contrainte (trigger M-12 étendu).
- **Porte** : P-339 étendue aux identifiants **déclarés par les cascades** (monde mixte : projet de PAR, société de LYO) et jugée sous toutes les passes.

### I-6 🟠 — Deux horloges pour « aujourd'hui »
- **Famille** : la date du jour vient tantôt de Node (`new Date().toISOString().slice(0, 10)`, **UTC**), tantôt de la base (`CURRENT_DATE`/`now()`, fuseau de session) ; les règles d'horloge D-53 lisent la base.
- **Étendue mesurée** : 4 sites JS (`ClosePrestation` date par défaut, cascade de `CloseProject`, `DeclareCVShared`, `RecordClientDecision`) · 3 sites base (`CancelPrestation.date_annulation`, `RecordQualification.date`, les vues `v_ressource_etat`/`v_societe_statut`). **Prouvé** : base réglée à `Pacific/Kiritimati` le temps de la sonde (`ALTER DATABASE ava_audit10_b SET timezone`, remis ensuite), **même instant** : `date_cloture = 2026-10-01`, `date_annulation = 2026-10-02`, `suivi.date = 2026-10-01`, `qualification.date = 2026-10-02` ; une prestation du 02/10 rend la ressource « en mission » côté vue alors que le jour JS est le 01/10 (`preuves/securite10/deux_horloges.txt`). Aujourd'hui le poste est à Casablanca (UTC+0) : les deux coïncident par hasard.
- **Correction** : une seule horloge — la base. `executerCommande` lit `current_date` une fois par transaction (`ctx.aujourdhui`) ; le fuseau de la session est **posé** par le pool (`-c TimeZone=…`), depuis un réglage d'installation, jamais hérité du serveur.
- **Porte** : (a) AST : aucun `new Date(` dans `server/src/commandes` ; (b) le banc tourne une passe avec la base à UTC+14 et compare toutes les dates écrites par les positifs à `current_date`.

---

## 3 · ANGLES MORTS (ce que cet audit n'a pas mesuré)

| Angle mort | Pourquoi | Ce qu'il faudrait |
|---|---|---|
| `make test` complet et le cliquet | interdits au poste ; Playwright (geste, écran) non joué | les jouer sur une base dédiée et relire les 19 cases |
| La base qui a **vécu** (`ava`, `ava_audit10`) | hors périmètre : l'empreinte n'est prouvée que sur une base neuve, où elle est vraie par construction | `make.sh empreintes` sur la base de travail, avant reset |
| K5, authentification réelle | `verif_serveur.sh` est un contrôle de VPS ; l'authentification arrive au lot 2c | audit du VPS ; refaire K1-K3 au lot 2c |
| Charge et concurrence | aucune mesure de deux transactions simultanées (référence `PRJ-` sous verrou consultatif, doublons, unicité de positionnement sans contrainte) | deux clients parallèles sur les gardes d'unicité |
| Lectures à travers les **sorties** de commandes | une commande permise rend des lignes entières (`SELECT *`) : non mesuré sous `partagee`, où une société d'une autre agence est permise | énumérer les colonnes rendues par sortie, contre `Lire*` |
| `compte_surcharge` | P-349 calcule les droits depuis `groupe_permission_perimetre`, le serveur depuis `v_droits_effectifs` : une surcharge restrictive n'est jamais jouée | une passe P-349 avec surcharges |
| Politiques des lots suivants | 202 clés en base, 55 lues : les 147 autres ne sont jugées par rien | au lot qui les sert |
| Mes propres sondes | elles ont muté la base (politiques remises, 57 délégations à CROISE, 2 `provenance` inconnues, un trigger `tg_m4_m14` désactivé quelques secondes pour poser une devise mixte, `ref_statut_commercial.ordre` remis) et ont **parasité** la première passe de P-339 (2 fausses fuites, conservées) | — tout est déclaré ici ; la base a été reconstruite deux fois |
