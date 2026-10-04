# Constats du onzième audit — commit `34d98a4` (branche `lot-2`)

Constats **neufs**, numérotés à la suite : V-179 →. Chacun porte, comme l'exige `_ops/prompt-audit-9.txt` :
**Famille** (la règle violée, pas le cas) · **Étendue** (mesurée) · **Correction de construction** + la **porte** qui
énumère la famille. ⛔ Aucun « corriger la ligne X ». La spécification des politiques est `_ops/REGISTRE_EXECUTABLE.md` :
chaque issue observée y est comparée.

Suivi des 18 constats du 10e tour et des décisions D-56 → D-67, D-78 (`SUIVI_V.md`) : **1 fermé · 1 confirmé ·
8 partiels · 8 ouverts** (dont V-156, 6e tour) · décisions : **9 codées et gardées · D-59, D-65 codées sans porte qui
tienne · D-66 non codée**.

Preuves sous `rapport/preuves/` : `suivi11/` (S), `registre11/` (R), `grille11/` (G), `conformite11/` (C),
`securite11/` (I), `banc/` (sabotages et cliquet). Les brouillons (`brouillons/`) gardent leurs numéros de travail :
correspondance à la fin.

**17 constats neufs : 6 critique · 6 elevee · 4 moyenne · 1 bonne.**

---

### V-179 — Une cascade saute la garde de sa fille, sur un test de noms de commande
Cible        CODE · Gravité **critique** — droit contourné, objet créé dans une agence où l'acteur n'a pas la commande
Famille      *Une fille de cascade passe par la garde complète, comme un appel direct ; aucune exemption ne se décide sur
             le nom d'une commande (D-43, D-48, D-57).*
Étendue      `executerDans` (`executer.ts:244-252`) remplace `exigeAgence(g)` par une cible fabriquée quand la mère est
             `RecordClientDecision` et la fille `CreateProjectFromNeed`. Mesuré sous `automatique_au_retenu` :
             (a) acteur avec `RecordClientDecision` sur PAR **sans** `CreateProjectFromNeed` : direct → DROIT, par la
             cascade → **1 projet créé** ; (b) acteur de PAR dont le **seul** droit est `RecordClientDecision` sur LYO :
             **1 projet créé dans LYO** ; (c) `ia@` privé de la fille par une surcharge restrictive (droits effectifs 0) :
             direct → DROIT, cascade → `ProjectCreatedFromNeed`. Le `besoin_id` vient de la base, pas de l'entrée.
             1 cascade sur les 10 de `CASCADES` ; la migration 025 donne la fille à IA au seed, ce qui masque le défaut
             au banc. Sabotage Q1 (la fille sans garde) : les portes tombent — mais seulement pour les 9 autres cascades.
Preuve       S `05_v162.txt`, `07_v163b_cascade_rcd.txt` · I `compte_surcharge.txt`
Correction   **Construction** : `executerDans` n'a **aucun** chemin qui contourne `exigeAgence` ; si une politique doit agir
             au nom du système, cela se déclare dans `CASCADES` (`acteur: "systeme"`), se trace, et la garde le lit.
             **Porte** : pour chaque ligne de `CASCADES`, l'acteur qui a la mère et pas la fille (sur la même agence, sur
             une autre par délégation seule, et privé par surcharge) → refus ou issue déclarée, 0 ligne écrite ; AST :
             0 littéral de nom de commande dans `executer.ts` et `agence.ts`.

### V-180 — D-57 n'est pas tenu : le métier passe encore par `ordre`, par le « premier code » d'une catégorie, par des noms de commande et des littéraux
Cible        CODE · Gravité **critique** — un geste d'administration permis casse le passage client ; c'est la famille V-163
Famille      *Le code lit la catégorie, jamais l'identité d'un code ni l'ordre d'affichage ; un défaut est une politique ou
             une catégorie fermée unique ; aucun nom de commande ni littéral de code dans le noyau.*
Étendue      Le cas du 10e tour est fermé (`client ordre=7` puis signature → ok). La famille reste ouverte, **20 sites** :
             **comparaison au premier code de la catégorie** (`projet.ts:29, :53, :304`, `crm.ts:120`) — mesuré :
             `ManageRefs ref_statut_commercial zz_prospect_chaud categorie=prospect ordre=0` (geste ADM) → **une signature
             ne fait plus passer la société cliente**, aucun `CompanyStatusChanged`, et `CreateCompany` écrit ce code ;
             **défaut choisi par `ordre`** (5 sites serveur + 2 vues) — passe qui inverse `ordre` dans les 75 `ref_*` :
             `CreateProjectFromNeed` écrit `forfait` au lieu de `regie` ; `ref_type_contact autre ordre=0` change le type
             par défaut ; un état `zz_sourcing` devient l'état écrit par `TakeNeedInCharge` ; **noms de commande** dans le
             noyau : 4 (`agence.ts:335`, `:433`, `executer.ts:244`, `SOI_MEME` qui double la nature `soi`) ; **littéraux
             de code** : 7 (`'ouvert'`, `'cv_partage'`, `'fait'`, `'autre'`, `'interne'`, `"postes"`, `fte_vise = "1"`) ;
             4 `ref_*` lus sans catégorie fermée. P-359 ne permute qu'**entre** catégories, et elle est ⏳ (V-188). Le
             contrôle B1 de la grille reste un grep qui ne voit aucun de ces 20 sites.
Preuve       C `d57_ordre_et_categorie.txt`, `d57_litteraux.txt` · S `06_v163.txt`
Correction   **Construction** : toute lecture d'état par catégorie (`categorie(code) = 'prospect'`), jamais `code === …` ;
             un code par défaut est une politique ou une catégorie `defaut` unique (unicité partielle en base) ;
             `ORDER BY ordre` réservé aux vues d'affichage ; les exceptions de commande se déclarent dans `DECLARATION`.
             **Porte** : (a) AST sur `server/src` : tout `ORDER BY ordre … LIMIT 1` hors affichage, toute égalité sur un
             `*_code`, tout `ctx.commande ===`, tout littéral de code dans un `INSERT`/`WHERE` → rouge (20 aujourd'hui) ;
             (b) pour chaque `ref_*` lu : inverser `ordre`, puis ajouter un deuxième code actif d'ordre 0 dans chaque
             catégorie, et rejouer les 57 positifs → issues et colonnes identiques (2 rouges aujourd'hui).

### V-181 — L'ensemble ADMIS n'est pas l'ensemble SERVI : des réglages sans ligne au registre retirent une garde, et une valeur servie est inatteignable
Cible        CODE + BRAIN · Gravité **critique** — viole la règle 1 du registre (« servie ssi une ligne »)
Famille      *Une seule garde de valeurs, générée du registre : le domaine et les bornes s'ajoutent à la règle 1, ils ne la
             remplacent pas ; la porte pose les politiques par le chemin de l'administrateur.*
Étendue      **Débordement** : `politique_admise` (migration 023) ne regarde que le domaine (listes) ou les bornes (nombres).
             `SetPolicy` accepte `[]` sur les 4 clés liste, les doublons, l'ordre inversé, `["telephone"]` (que le code
             n'implémente pas), `["cv"]` (insatisfiable : refuse un candidat dont le CV est déposé), tout nombre dans les
             bornes, et des écritures non canoniques (`0100`, `1.50`). Effets mesurés : `doublon.societe.cles = []` sous
             `bloquer` → **deux sociétés identiques** ; `candidat.complete.champs_requis = []` → `CompleteCandidate` ok sur
             un candidat vide ; `seuil_pct = 150` indiscernable de `200`. **8 portes exigent** une valeur sans ligne
             (P-133, P-227, P-234, P-245, P-248, P-249, P-264, P-286). **Inatteignable** : `projet.contact =
             service_ou_societe` est au registre (3 lignes), dans `politique_valeur_servie` et `COMPORTEMENTS`, mais
             `SetPolicy` la refuse (`valeurs_possibles`, seconde garde écrite à la main) ; P-355 pose les politiques par
             `UPDATE` SQL et passe ces 3 lignes au vert. **25 politiques liste sur 33** ne peuvent même pas reprendre leur
             défaut par `SetPolicy` (défaut non JSON).
Preuve       R `02_regle1.txt`, `20_sondes.json`, `22_sondes_b.json`, `07_listes_defaut_non_json.txt`, `30_portes_banc.txt` ·
             S `14_listes.txt`, `02_setpolicy_regles_2_4_5.txt`
Correction   **Construction** : `SetPolicy` ne juge que par `politique_admise`, qui exige le couple servi **et** le domaine
             (ou le registre déclare « toute partie non vide du domaine » avec l'issue de `[]`) ; forme canonique unique
             avant toute garde ; `valeurs_possibles` devient une sortie du générateur ; chaque élément de domaine a son code.
             **Porte** : pour chaque couple servi, `SetPolicy` par HTTP (ADM) → ok puis retour au défaut → ok (287 appels) ;
             pour chaque clé liste, `[]`, chaque singleton, une permutation, un doublon ; pour chaque nombre, min, max, une
             écriture non canonique → exactement ce que le registre écrit ; la porte différentielle pose ses politiques
             par `SetPolicy`, jamais en SQL.

### V-182 — Un drapeau interne de cascade est une clé publique, et il lève la garde que le registre déclare
Cible        CODE + BRAIN CODE · Gravité **critique** — S-PM3 et D-65 exigent un refus « sous tous les modes »
Famille      *Ce qu'une cascade transmet à sa fille pour la distinguer d'un appel direct ne passe jamais par l'entrée
             publique ; une clé déclarée `valeur` ne peut lever aucune garde.*
Étendue      `DeclareNeedFilled` déclare `depuis_signature` ; `besoin.ts:160` saute `gardePourvu` si elle est présente sous
             `auto_par_personne_signee`. Mesuré : `{id, depuis_signature: "oui"}` → **besoin pourvu à 0/2, 0/1 et 1/2**
             (trois vérificateurs) ; sans la clé : GARDE. P-355 reste verte : le scénario S-PM3 ne passe pas la clé.
             1 drapeau exploitable mesuré ; `RequalifyCompany.contact_id/besoin_id` sont aussi des entrées de cascade
             ouvertes à HTTP (non nuisibles mesurées).
Preuve       S `05_v162.txt` · R `11_lignes.json` (S-PM3 + sondes) · C H-PM3
Correction   **Construction** : le contexte de cascade vit dans `ctx.mere` (posé par `executerDans`, absent d'un appel HTTP) ;
             `DECLARATION` refuse toute clé que seul un `executerDans` alimente.
             **Porte** : pour chaque commande et chaque clé déclarée, l'appel direct avec cette clé seule ajoutée ne change
             jamais un refus du registre en succès.

### V-183 — Des règles du registre écrites en phrase ne sont jouées par rien : 2 sur 2 sont fausses, et 3 portes exigent le contraire
Cible        BRAIN + BRAIN CODE + CODE · Gravité **critique** — des portes vertes affirment l'inverse du registre (famille V-164)
Famille      *Toute règle du registre exécutable est une ligne de cas ; une phrase « ⛔ … » sous un tableau n'est pas une
             spécification.*
Étendue      **S-CA1** « ⛔ `ca_produit.base = temps_valides` sous `temps.validation = aucune` → refus GARDE » : `SetPolicy`
             **ok**, dans les deux ordres ; **P-354** exige ok. **S-UT1 / D-66** « un thème non servi → refus GARDE » :
             `SetOwnTheme {"ui.mode":"clair"}`, `{"ui.palette":"zz_non_servie"}`, 5 000 caractères → **ok, écrits** ;
             **P-125** et **P-259** exigent ok ; D-66 n'est pas codée. Deux autres phrases hors grammaire laissent passer
             V-182 (S-PM3) et V-162 ⑤ (S-PCL1 sans prestation finie). La grammaire n'a de forme ni pour une contrainte
             entre politiques, ni pour une commande d'installation.
Preuve       R `20_sondes.json` (C4) · S `03_d66_setowntheme.txt`
Correction   **Construction** : le §0 du registre gagne une forme jouable (lignes `SetPolicy`/`SetOwnTheme` avec scénario,
             et une table de contraintes entre clés générée vers `politique_admise(clé, valeur, état)`) ; le lecteur
             `registre_executable.mjs` refuse un « ⛔ » ou un code de refus dans une puce sans ligne correspondante ;
             `SetOwnTheme` appelle `politique_admise` pour chaque clé `ui.*`.
             **Porte** : ce lint, puis la porte différentielle joue ces lignes.

### V-184 — `CreateCompany` n'écrit pas le SIREN : la clé de doublon `[siren]` ne protège aucune société créée par l'application
Cible        CODE · Gravité **critique** — une valeur servie sans comportement (famille V-162), masquée par la fixture
Famille      *Toute colonne comparée par une garde de politique est écrite par la commande qui la reçoit.*
Étendue      `CreateCompany {nom, siren: "900031050"}` → ok, **`societe.siren = NULL`** ; une seconde société même SIREN, sous
             `bloquer` et `cles = [siren]` → **ok**. La ligne S-DS3 n'est conforme que parce que la fixture pose le SIREN en
             SQL. `UpdateCompany` ne déclare pas `siren`. Les autres clés de doublon (e-mail, téléphone, naissance) sont
             écrites.
Preuve       R `24_sonde_siren.txt`
Correction   **Construction** : les colonnes de doublon se dérivent de `DECLARATION` (champ comparé ⇒ champ écrit).
             **Porte** : pour chaque élément de domaine de `doublon.*.cles`, deux objets créés **par commandes** qui
             partagent cet élément → `bloquer` refuse le second.

---

### V-185 — Le snapshot de marge écrit un coût converti sous la devise d'origine (M-15)
Cible CODE · **elevee** — un chiffre faux, figé par M-14 · Famille : *un montant porte la devise dans laquelle il est
exprimé ; seul le taux s'écrit.* · Étendue : vente USD, CJM 200 EUR × 4 j, taux 0,9 → `cout_produit = 720.00`,
`cout_devise_code = EUR` (vrai : 800 EUR) ; `marge = 280` sans devise ; la ligne S-CH2 ne regarde que `marge` et
`taux_change` · Correction : `cout_produit` reste dans sa devise, la marge convertie a sa colonne de devise, contrainte
en base ; **porte** : assertion L7 « montant = Σ des entrées dans SA devise » et S-CH2 vérifie `cout_produit = 800` ·
Preuve S `05b_v162_change.txt`.

### V-186 — Un GRANT de production est ouvert pour un écrivain de banc
Cible CODE · **elevee** · Famille : *un droit SQL de `ava_app` correspond à une écriture de commande ; ce que seul le banc
écrit vit dans la fixture.* · Étendue : `assurerBancRes` reste dans `index.ts` (V-170) et la migration 025 accorde
`UPDATE (personne_id) ON compte TO ava_app` pour que P-325 passe ; la migration joue en production ; aucune commande
n'écrit cette colonne, qui fonde la règle « soi » (D-33). Aussi : `tracerRefus` écrit le corps entier (1 Mo) d'une
requête sans compte ; 2 migrations de données écrivent sans événement, `tg_garde` désactivé · Correction : la fixture
remplace `assurerBancRes`, 025 révoque ; **porte** : P-325 inversée — tout privilège accordé est écrit par un handler de
`HANDLERS` · Preuve I `grant_contre_ecritures.txt`, S `10_divers.txt`.

### V-187 — La porte croisée tire ses attendus de la structure du code : elle grave le défaut D-59 et ne joue jamais le permis de `par_besoins`
Cible BRAIN CODE + CODE · **elevee** (famille V-164, sur la porte de périmètre) · Famille : *l'attendu d'une porte vient
de la décision écrite, jamais d'une propriété du code jugé.* · Étendue : `porte_croisee.test.mjs:459` attend REFUS pour
une création « chez soi » sans `entreeAgence` ; or `CreateNeed`, `CreateCandidate`, `CreateResource` avec
`agence_id = LYO`, par un acteur dont le seul droit est sur LYO → **DROIT**, contraire à D-59 (`agence.ts:424`) ; la porte
l'exige. 8 lignes `OK-METIER` comptées sans être exigées ; sous `par_besoins`, **0 permis joué** (D-58 tient, mesuré à
la main, mais rien ne le garde) · Correction : l'agence demandée d'une création est **une** notion déclarée, lue par la
garde et par la porte ; **porte** : par passe, au moins un permis attendu joué par valeur qui en ouvre un ; les créations
D-59 jouées avec le champ d'agence = LYO, attendu ok · Preuve S `12_porte_croisee_detail.json`, `10b_divers.txt`,
G `analyse_p339.txt`.

### V-188 — Des portes vertes laissées ⏳ ne protègent rien : les corrections de V-163 et V-170 ne sont pas verrouillées
Cible BRAIN CODE · **elevee** · Famille : *l'état d'une porte se calcule ; une ⏳ exécutée et verte fait rougir le
cliquet.* · Étendue : P-359 (D-57), P-360 (`Object.prototype`), P-361 (routes = `LECTURES`) sont vertes et ⏳, lot cible 2,
au moment où le lot 2 part en audit ; la case 1 ignore l'échec d'une ⏳ · Correction : le cliquet croise exécutées ∩
vertes avec les ⏳ ; **porte** : cette case (3 rouges aujourd'hui) · Preuve G `porte_attente_*.txt`.

### V-189 — La case 22 du cliquet ne passe que sur le poste qui l'a écrite : la CI est rouge par construction
Cible BRAIN CODE · **elevee** · Famille : *une case qui lit une branche la résout en local, puis `origin/`, puis par
`fetch` — une seule fonction pour toutes (V-112).* · Étendue : la case 22 (D-78) cherche `lot-2-brain` en local ; `ci.yml`
ne pose que `main` ; dans un clone neuf elle rend « branche introuvable » (mesuré par le vérificateur et par le cliquet de
l'auditeur, `MUTATIONS.md`) : le verdict D-78 n'est jamais rendu par la CI · Correction : `ref_branche NOM` partagée par
les cases 3, 9, 11, 13, 15, 22 ; `ci.yml` pose les branches du juge ; **porte** : le cliquet joué dans un clone neuf rend
un verdict mesuré à chaque case · Preuve G `cliquet_sans_make.txt` (case 22 KO « introuvable »), `cliquet_case22_origin.txt` (OK avec `C22_JUGE=origin/lot-2-brain`).

### V-190 — Des scénarios à un seul élément ne voient pas l'issue qu'ils écrivent : la propagation « branche » et R10 sont faux
Cible CODE + BRAIN · **elevee** · Famille : *une issue au pluriel a une fixture à ≥ 2 éléments ; une règle conditionnelle
a un scénario de chaque côté.* · Étendue : `branche_contractante_et_contacts_du_service` avec **deux** contacts dans U1 :
seul le contact du projet passe client (l'issue écrit « contacts de U1 ») ; `service_ou_societe` (R10, « contact
obligatoire en régie ») : besoin régie + unité + sans contact → **ok** ; S-PR1 et S-PC3 ne peuvent pas le voir ·
Correction : le code lit les contacts de l'unité contractante et `besoin.origine_code` ; **porte** : lint du registre —
qualificatif pluriel ⇒ scénario à ≥ 2 éléments, condition ⇒ un scénario de chaque côté · Preuve R `20_sondes.json` (C5).

---

### V-191 — Le registre exécutable n'est pas exécutable sans interprétation
Cible **BRAIN** · **moyenne** · Famille : *une issue nomme une colonne qui existe, dans la grammaire du §0, sur un
scénario constructible.* · Étendue : 8 colonnes inexistantes (`societe.statut`, `*.etat`, `snapshot_marge.ca`…), 5 formes
hors grammaire (`refus DROIT · écrit …`, `inchangé snapshot_marge` sans colonne…), S-PG3 impossible (le déclencheur
`besoin_couverture` refuse « postes + fte visé »), 3 scénarios ambigus, une 57ᵉ clé lue (`temps.mois_ouvert.grace_jours`),
3 contradictions avec L4 et des valeurs absentes de `REGISTRE_POLITIQUES_v1.md` §C · Correction : le lecteur valide
chaque issue contre le catalogue (`information_schema`) et la grammaire ; **porte** : `registre_executable.mjs --verifier`
au cliquet · Preuve R C11.

### V-192 — La liste des fichiers du juge est écrite à la main, et une seconde porte de politiques en reste dehors
Cible BRAIN CODE · **moyenne** (famille V-176 / D-78) · Famille : *ce qui porte un attendu est un fichier du juge ; la liste
se calcule.* · Étendue : `outils/FICHIERS_DU_JUGE` nomme 10 fichiers ; `test/contrat/v011-politiques.ts` (portes de
politique écrites à la main, qui doublent le registre), `outils/ecrire_comportements.mjs` (qui lit la base `ava` en dur),
le bloc généré de la migration 023 et `outils/make.sh` n'y sont pas ; le codeur a changé deux attendus de
`v011-politiques.ts` sous `Role: banc` (`eb546ed`) · Correction : les portes de politique n'existent qu'en génération du
registre ; la liste se dérive ; **porte** : la case 22 calcule la liste et la compare · Preuve S §3.

### V-193 — « Une seule horloge » n'est gardée par aucune porte, et les gardes en double sont toujours du code mort
Cible CODE (banc) + BRAIN CODE · **moyenne** (0 fuite mesurée) · Famille : *une règle de construction a une porte qui
tombe quand on la viole ; une règle est tenue à UN endroit.* · Étendue : **5 sabotages sur 67 ne font tomber aucune
porte**. **P5** : `ClosePrestation` reprend l'horloge de Node (`new Date()`) au lieu de `aujourdhui(agence)` → 0 porte,
alors que la date écrite change (horloge du banc au 15/10, Node au 04/10) : V-167 n'a pas de porte, et deux commandes
datent déjà à `CURRENT_DATE` sans que rien ne rougisse. **T4 · S4_RecordTimesheet_S · R7 · R8** : les quatre mutants
équivalents du 10e tour, inchangés — `exigeSoiMeme` (3 sites), la boucle de `noter` (`agence.ts:121`) et le test
`TransferContact` (`agence.ts:433`, aussi un nom de commande, V-180) sont toujours là, et le refus INTROUVABLE de
`TransferContact` vers une société inexistante n'est exigé par aucune porte · Correction : la règle `soi` vit dans la
garde seule, `noter` et `replier` fusionnent, une seule source de date (V-167) ; **porte** : chaque commande qui date,
jouée sous `horloge_banc` ≠ date système, compare chaque colonne de date écrite à `aujourdhui(agence)` ; chaque code de
la colonne « Refuse si » de L4 a un cas qui l'exige · Preuve `banc/_JOURNAL.txt` (A et B), `aveugles` du 10e tour.

### V-194 — Deux contrôles de la grille restent des greps, et deux cases lisent encore par position
Cible BRAIN · **moyenne** · Famille : *un contrôle de la grille est une porte structurelle, pas une commande figée.* ·
Étendue : B1 ne voit aucun des 20 sites de V-180 ; D3 rend 6 réécritures de migration, dont `023` réécrite 49 minutes
après sa création, tolérées par la case 15 ; les cases 9 et 12 lisent `$4` de `PORTES_EN_ATTENTE.md` par position
(V-177) · Correction : B1 = la porte AST de V-180 ; D3 = « une migration ne change plus après son premier commit sur une
branche partagée » ; lecture par en-tête partout ; **porte** : case du cliquet sur `git log --diff-filter=M` de
`db/migrations/` sur `lot-2` et `lot-2-brain` · Preuve G G-4, S V-177.

---

### V-195 — Bien fait, à garder
Cible CODE + BRAIN · **bonne**
- **Le registre exécutable existe et il est tenu ligne à ligne** : 206 cas rejoués par un rejoueur indépendant, **203
  conformes** ; registre = `politique_valeur_servie` = `COMPORTEMENTS` = générateur (287 couples) ; 210 valeurs de clés
  absentes du registre refusées ; porte différentielle générée, 264 jeux, aucune valeur indiscernable hors alias.
- **Le cloisonnement tient** : porte croisée 846 identifiants, 6 passes, **0 fuite**, 0 ligne sans attendu ; D-58 tient.
- V-162 ①②④⑥ fermés (mois ouvert, taux saisi, dérogation tracée, projet automatique) ; `Object.prototype` fermé ;
  D-78 tenue (0 commit hors fusion sur les fichiers du juge) ; GRANT par colonne à l'égalité stricte.

---

## Correspondance avec les brouillons

| Constat | Brouillons |
|---|---|
| V-179 | SUIVI N-1 · SECURITE I-3 · CONFORMITE C-1 (nom de commande) |
| V-180 | CONFORMITE C-1 · SUIVI V-163 (partiel) |
| V-181 | REGISTRE C1, C2, C10 · SUIVI N-6 |
| V-182 | SUIVI N-2 · REGISTRE C3 · CONFORMITE C-2 |
| V-183 | REGISTRE C4 · SUIVI N-7, D-66 |
| V-184 | REGISTRE C7 |
| V-185 | SUIVI N-3 |
| V-186 | SUIVI N-4 · SECURITE I-4 |
| V-187 | SUIVI N-5, D-59 · GRILLE G-3 |
| V-188 | GRILLE G-1 |
| V-189 | GRILLE G-2 |
| V-190 | REGISTRE C5 |
| V-191 | REGISTRE C11 |
| V-192 | SUIVI N-8 |
| V-193 | MUTATIONS |
| V-194 | GRILLE G-4 · SUIVI V-177 |
| V-195 | SUIVI V-178 |

Restent **ouverts au suivi**, sans numéro neuf : V-166 (`CreatePrestation {etat: signee}` sans TJM — CONFORMITE C-3),
V-167 (deux horloges — REGISTRE C6, SECURITE I-5), V-168 (état écrit contre état lu — CONFORMITE C-4), V-169 (32 × 500,
8 × MUR — SECURITE I-1), V-171, V-173, V-174 (CONFORMITE C-5), V-156 (6e tour).
