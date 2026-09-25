# CONFORMITE8 — famille H : les 55 commandes servies contre L4

**11 commandes sur 55 non conformes — dont 9 parce que la liste blanche `CLES_COMMUNES` refuse une entrée du contrat (ou laisse passer `etat`, qui écrit hors contrat) ; les 2 autres : ArchiveObject (hors état terminal) et CreateNeed (politique jamais lue).**
Le OUI tient (69/69 : bon événement, politiques annoncées portées) et le NON tient (70/70 : chaque refus L4 rend son code) ; c'est l'ENTRÉE qui casse.

| Partie | Mesuré par HTTP réel | Résultat |
|---|---|---|
| A · le OUI | entrée de base de chaque commande (objets frais, PAR) | **69 ✅ / 69** — événement L4 émis, politiques L4 dans `liens.politiques` |
| B · le NON | un cas de la colonne « Refuse si » par commande | **70 ✅ / 70** — codes DROIT / ETAT / GARDE / INTROUVABLE conformes, 0 `MUR` visible |
| C · la liste blanche | entrées du contrat, clés admises hors contrat | **2 ✅ / 16** |

Script : `rapport/preuves/conformite8/conformite.mjs` (bibliothèque commune `securite8/monde8.mjs`) · sortie : `conformite8/conformite.md`, `conformite.json` · compléments : `conformite8/politiques_non_lues.txt`.
Acteur : `rh@ava.test` à qui ADM a posé les 55 permissions sur PAR par `ManageGroups` (`securite8/01_permissions_posees.txt`) ; `adm@ava.test` pour les trois commandes d'installation ; `dp@`, `staf@` pour les refus DROIT. Toute politique basculée pour un test a été remise (relu : `grille8/K2_K3_banc.txt` l. 2).

---

## 1 · Les constats

### H-1 · La liste blanche refuse dix entrées que le contrat ou le handler attend — élevée
- **défaut** : `CLES_COMMUNES` est UNE liste pour 54 commandes ; elle ne contient pas des clés que les handlers lisent (`req/opt`) et que L4 nomme. Toute entrée qui les porte tombe en `GARDE « entrée ambiguë »` avant le handler.
- **cible** : `server/src/agence.ts` (`CLES_COMMUNES`, `refuserAmbigu`) ; handlers `identite.ts:120,296,436`, `besoin.ts:121`, `projet.ts:296,352,367,487,589`.
- **famille** : H · **gravité** : élevée.
- **preuve** (`conformite.md` partie C, `politiques_non_lues.txt`) :

| Commande | Entrée | L4 dit | Mesuré |
|---|---|---|---|
| RecordQualification | `mesures: []` | « personne_id, besoin_id, type, **mesures** » | GARDE entrée ambiguë |
| CreatePrestation | `cjm_devise: "USD"` | « TJM, CJM, **devises** » ; M-15 | GARDE — une CJM dans une autre devise est impossible |
| RecordTimesheet | `facturable` / `quantite_facturable` | « quantité **(+ facturable)** » | GARDE ; ⛔ avec `temps.facturable.mode = saisie_separee`, **plus aucun temps ne s'enregistre** : sans la clé → « quantité facturable exigée », avec → « entrée ambiguë » |
| ConvertCandidateToResource | `fournisseur` | « profil_candidat_id, type, agence, **fournisseur** » | GARDE |
| UpdateCandidate · UpdateResource | `disponibilite_code` | « id + champs » (lu par le handler) | GARDE ×2 |
| UpdateNeed | `contexte` | « id + champs » (lu par le handler) | GARDE |
| SignPrestation | `date_signature` | « id, **date de signature** » | GARDE (`date` passe) |
| RecordAbsence | `quantite_par_jour` | « quantité/jour » | GARDE (`quantite` passe) |

- **reproduire** : serveur banc, `node rapport/preuves/conformite8/conformite.mjs`.
- **prétend** : P-327 / P-334 « une clé inconnue → GARDE sur chaque commande servie ».
- **mesure** : la porte ne prouve que le refus d'une clé inconnue de TOUS ; aucune porte ne prouve qu'une entrée du contrat passe.
- **correction** : une liste PAR commande, dérivée des `req/opt` du handler (ou déclarée à côté du handler et relue par une porte) ; porte : « chaque clé lue par un handler est admise par sa commande ».

### H-2 · La liste commune laisse passer des clés d'autres commandes, en silence — moyenne
- **défaut** : une clé admise pour une commande l'est pour toutes ; le handler l'ignore sans le dire.
- **cible** : `server/src/agence.ts` (`for … ligne.cles = … CLES_COMMUNES`) · **famille** : H · **gravité** : moyenne.
- **preuve** : `UpdateNeed { id, cle: "besoin.contact", valeur: "obligatoire" }` → **ok** ; `UpdateCandidate { disponibilite: "asap" }` → ok, **`disponibilite_code` reste NULL** (clé admise, jamais lue) — `conformite.md` partie C.
- **prétend** : « Toute autre clé → GARDE entrée ambiguë » (commentaire du type `Ligne.cles`).
- **mesure** : l'écran reçoit `ok:true` pour une saisie qui n'a rien écrit.
- **correction** : la même que H-1 ; une clé admise et non lue est un refus.

### H-3 · `etat` admis : CreatePrestation crée une prestation déjà close ou annulée — élevée
- **défaut** : `CreatePrestation` accepte tout code de `ref_etat_prestation` ; seul `engage` est gardé (SignPrestation).
- **cible** : `server/src/commandes/projet.ts:298-307` · **famille** : H (+ machine) · **gravité** : élevée.
- **preuve** : `etat: "cloturee"` → ok, prestation en `clos`, **`snapshot_marge` : 0 ligne** ; `etat: "annulee"` → ok, en `annule` (`conformite.md` C).
- **reproduire** : `POST /commandes/CreatePrestation` avec l'entrée de base + `"etat":"cloturee"`.
- **prétend** : L4 §C-3 (la seule autre porte d'entrée est `signee`) ; `cycle.ts` `CreatePrestation → previsionnel` ; L4 `ClosePrestation` « écrit snapshot_marge dans la MÊME transaction ».
- **mesure** : une marge close sans snapshot ; une annulation sans la garde `prestation.annulation.garde`.
- **correction** : n'admettre que les catégories `previsionnel` et `engage` en création (la seconde avec les effets de signature) ; porte : chaque catégorie de `ref_etat_prestation` en création → ETAT sauf ces deux.

### H-4 · ConvertCandidateToResource ignore l'agence du contrat — moyenne
- **défaut** : le handler écrit `ctx.compte.agence_id`, jamais l'`agence_id` d'entrée (L4 §C-1 : « ENTRÉE profil_candidat_id · type_code · agence_id ») ni celle du candidat.
- **cible** : `server/src/commandes/identite.ts:207` · **famille** : H · **gravité** : moyenne.
- **preuve** : entrée `agence_id = LYO` → ok, ressource écrite dans **PAR**, sans refus (`conformite.md` C ; `securite8/croise_55.md`).
- **prétend** : §C-1 · **mesure** : entrée acceptée puis ignorée ; un compte global convertit un candidat de LYO en ressource de SA propre agence.
- **correction** : lire `agence_id` (défaut : l'agence du candidat), et la juger comme `CreateResource`.

### H-5 · CreateCompany ignore `manager_compte_id` — faible
- **défaut** : la garde ne lit que `manager` ; le handler prend `ctx.resolues.manager` ; `manager_compte_id` (lu par UpdateCompany) est admis et jeté.
- **cible** : `server/src/agence.ts` (`CreateCompany: creation([col("compte", ["manager"], "id")])`), `crm.ts:24` · **gravité** : faible.
- **preuve** : manager demandé = un compte ; manager écrit = `rh@ava.test` (`conformite.md` C).
- **correction** : même clé des deux côtés, ou refus.

### H-6 · ArchiveObject archive hors état terminal, par des règles en dur — élevée
- **défaut** : les gardes d'archivage par type sont des `if (type === …)` écrits dans la commande, sans politique ; et elles ne vérifient pas l'état terminal que la machine exige.
- **cible** : `server/src/commandes/admin.ts:87-108` · **famille** : H + B (paramétrage) · **gravité** : élevée.
- **preuve** : contrôles positifs `croise_55.md` : ArchiveObject accepte un **candidat `draft`**, une **ressource `intercontrat`**, un **projet `ouvert`** (ok, `ObjectArchived`).
- **prétend** : MACHINES_ETAT §0 [G12] « possible seulement depuis un état **terminal** du cycle de l'objet » ; principe : toute bifurcation est une politique.
- **mesure** : 3 types archivés depuis un état non terminal ; seul `besoin` exige `ferme`.
- **correction** : garde unique « catégorie terminale » lue dans la machine ; si une souplesse est voulue, une politique `<objet>.archivage.garde` comme pour société et service.

### H-7 · Des politiques existent, se règlent, et ne changent rien — élevée
- **défaut** : `besoin.unite_couverture` et `conversion.repositionnement_ressource` nomment une commande servie mais aucun handler ne les lit.
- **cible** : `server/src/commandes/besoin.ts:43` (`?? "postes"` en dur) ; `identite.ts` / `projet.ts` (conversion) · **gravité** : élevée.
- **preuve** : `SetPolicy besoin.unite_couverture = fte` → ok, `commandes_affectees: []` ; puis `CreateNeed` sans couverture → besoin écrit en **`postes`** (`politiques_non_lues.txt`).
- **prétend** : registre §C (la clé règle « ce qui satisfait un besoin ») · **mesure** : réglage accepté, effet nul — l'administrateur croit avoir changé la règle.
- **correction** : lire la politique ; ou la marquer « hors V1 » et la refuser dans SetPolicy tant qu'aucune commande ne la lit.

### H-8 · 22 politiques qu'aucun administrateur ne peut régler — moyenne
- **défaut** : 21 politiques de type `list` sont semées avec une valeur qui n'est pas un tableau JSON (SetPolicy refuse même leur valeur actuelle) ; `societe.donnees_legales.requises` exige à la fois « un élément de `valeurs_possibles` » et « un tableau » — aucune valeur ne satisfait les deux.
- **cible** : `db/migrations/003_seed_pol.sql` (les 21 valeurs `list`), `006_releve_boond.sql:314` (`donnees_legales`) ; `server/src/commandes/admin.ts:144-152` (`possibles.includes(valeur)` sur une liste) · **gravité** : moyenne.
- **preuve** : `politiques_non_lues.txt` (liste des 21 ; `SetPolicy alerte.actives = defaut_avaliance` → GARDE « valeur incompatible avec le type list » ; `["siret"]` → « hors valeurs_possibles »).
- **correction** : pour `list`, vérifier chaque élément contre `valeurs_possibles` ; semer des valeurs conformes à leur type ; porte : chaque valeur semée repasse `SetPolicy`.

### H-9 · Codes écrits en dur à la création — moyenne
- **défaut** : `CreateProject` et `CreateProjectFromNeed` écrivent `etat_code = 'ouvert'` (code) au lieu de `codeCategorie(…, CAT.projet.ouvert)` ; défauts `'regie'` (type de mission), `'principal'` (type de contact).
- **cible** : `projet.ts:58,95,99`, `crm.ts:271` · **gravité** : moyenne.
- **mesure** : un administrateur qui ajoute un code de catégorie `ouvert` et désactive `ouvert` casse la création de projet (FK) ; les autres commandes, elles, suivent le référentiel.
- **correction** : `codeCategorie` partout ; défauts lus dans une politique ou dans le référentiel.

### H-10 · Une référence de projet hors format bloque toute création de projet — moyenne
- **défaut** : `nextRef` lit `substring(reference from 5)::int` sur TOUS les projets ; une référence qui n'a pas « 4 caractères + un entier » lève 22P02.
- **cible** : `server/src/commandes/projet.ts:7-12` · **gravité** : moyenne.
- **preuve** : `securite8/05_nextref_reference.txt` — 41 projets de référence `A8-…` en base → `CreateProject` valide → `GARDE « entrée mal typée »` (trace : « syntaxe en entrée invalide pour le type integer »). `_ops/JEU_ESSAI.sql` (`SIM-0001`) passe par chance : préfixe de 4 caractères.
- **prétend** : L4 : `GARDE` = « une politique refuse » ; ici c'est une donnée reprise (Boond) qui casse une commande.
- **correction** : séquence dédiée ; ou `max` restreint à `reference ~ '^PRJ-[0-9]+$'`.

### H-11 · Une erreur 400 devient « 500 erreur interne » — faible
- **défaut** : `setErrorHandler` rend 500 pour toute erreur, y compris le JSON mal formé ou un Content-Length faux.
- **cible** : `server/src/index.ts` (`app.setErrorHandler`) · **gravité** : faible.
- **preuve** : `POST /commandes/CreatePerson` corps `{mal forme` → **500** (`securite8/chaine_par_besoins.txt` f).
- **prétend** : L4 « Refus : chaque cas, avec son code — ⛔ jamais un « erreur 500 » » · **correction** : garder le `statusCode` de Fastify (4xx) et un code `GARDE`.

### H-12 · `liens.politiques` ne porte jamais la politique des droits — faible
- **défaut** : `droits.surcharge_restrictive` est lue pour CHAQUE commande (vue `v_droits_effectifs`) mais n'apparaît dans aucun événement.
- **cible** : `server/src/droits.ts` / vue `v_droits_effectifs` · **gravité** : faible.
- **preuve** : partie A, colonne « politiques portées » : absente des 69 événements.
- **prétend** : L4 « ce que TOUTE commande fait » §4 : les clés lues et leur valeur.
- **correction** : lire la clé par `pol()` dans la résolution des droits.

---

## 2 · Le tableau des 55 commandes

Colonnes : l'événement L4 attendu contre l'émis · les politiques annoncées par L4 présentes dans `liens.politiques` · la preuve par « non » (cas L4 → code obtenu) · l'entrée L4 · le verdict.

| # | commande | événement L4 = émis | politiques L4 portées | le NON (cas → code) | entrée L4 | verdict |
|---|---|---|---|---|---|---|
| 1 | CreateCompany | ✅ CompanyCreated | ✅ | doublon, politique défaut avertir → alerte → ok ; doublon, politique = bloquer → GARDE | ⚠️ manager_compte_id ignoré | ✅ |
| 2 | UpdateCompany | ✅ CompanyUpdated | ✅ | société archivée → INTROUVABLE | ✅ | ✅ |
| 3 | RequalifyCompany | ✅ CompanyStatusChanged | ✅ | prospect → ancien_client (hors cycle) → ETAT | ✅ | ✅ |
| 4 | ArchiveCompany | ✅ CompanyArchived | ✅ | objets actifs (un contact) → GARDE | ✅ | ✅ |
| 5 | CreateUnit | ✅ UnitCreated | ✅ | parent d'une autre société → GARDE | ✅ | ✅ |
| 6 | UpdateUnit | ✅ UnitUpdated | ✅ | cycle (parent = soi) → GARDE | ✅ | ✅ |
| 7 | ArchiveService | ✅ UnitArchived | ✅ | besoin actif sur l'unité → GARDE | ✅ | ✅ |
| 8 | CreateContact | ✅ ContactCreated | ✅ | unité d'une autre société → GARDE | ✅ | ✅ |
| 9 | UpdateContact | ✅ ContactUpdated | ✅ | unité d'une autre société → GARDE | ✅ | ✅ |
| 10 | TransferContact | ✅ ContactTransferred | ✅ | objets actifs non réaffectés → GARDE | ✅ | ✅ |
| 11 | ArchiveContact | ✅ ContactArchived | ✅ | objets actifs → GARDE | ✅ | ✅ |
| 12 | CreatePerson | ✅ PersonCreated | ✅ | doublon email, défaut avertir → alerte → ok | ✅ | ✅ |
| 13 | CreateCandidate | ✅ CandidateCreated | ✅ | profil candidat déjà présent → GARDE | ✅ | ✅ |
| 14 | UpdateCandidate | ✅ CandidateUpdated | ✅ | note hors échelle → GARDE | ⛔ disponibilite_code | ⛔ |
| 15 | CompleteCandidate | ✅ CandidateCompleted | ✅ | champ requis manquant (civilité, localisation, email/tel) → GARDE | ✅ | ✅ |
| 16 | ExitCandidate | ✅ CandidateExited | ✅ | depuis brouillon (hors cycle) → ETAT | ✅ | ✅ |
| 17 | ReactivateCandidate | ✅ CandidateReactivated | ✅ | depuis actif (hors cycle) → ETAT | ✅ | ✅ |
| 18 | ConvertCandidateToResource | ✅ CandidateConverted | ✅ | aucun positionnement terminal_positif → GARDE ; EXTERNAL sans fournisseur (politique obligatoire) → GARDE | ⛔ fournisseur · ⛔ agence_id ignorée | ⛔ |
| 19 | CreateResource | ✅ ResourceCreated | ✅ | profil ressource déjà présent → GARDE ; EXTERNAL sans fournisseur → GARDE | ✅ | ✅ |
| 20 | UpdateResource | ✅ ResourceUpdated | ✅ | le coût (jamais par UpdateResource) → GARDE | ⛔ disponibilite_code (mesuré : GARDE « entrée ambiguë ») | ⛔ |
| 21 | SetResourceState | ✅ ResourceStateChanged | ✅ | disponible → disponible (hors cycle) → ETAT | ✅ | ✅ |
| 22 | UpdateResourceCost | ✅ ResourceCostChanged | ✅ | DP sans la permission (personne ne l'a au seed) → DROIT | ✅ | ✅ |
| 23 | UploadDocument | ✅ DocumentUploaded | ✅ | zéro porteur → GARDE ; deux porteurs → GARDE | ✅ | ✅ |
| 24 | RecordQualification | ✅ QualificationRecorded | ✅ | sans besoin (politique oui) → GARDE | ⛔ mesures | ⛔ |
| 25 | CreateNeed | ✅ NeedCreated | ✅ | contact d'une autre société → GARDE ; FTE manquant (couverture fte) → GARDE | ⚠️ `besoin.unite_couverture` jamais lue (« postes » en dur) | ⛔ |
| 26 | UpdateNeed | ✅ NeedUpdated | ✅ | contact d'une autre société → GARDE | ⛔ contexte · ⚠️ cle/valeur admises, ignorées | ⛔ |
| 27 | SetNeedPriority | ✅ NeedPriorityChanged | ✅ | besoin inconnu → INTROUVABLE | ✅ | ✅ |
| 28 | TakeNeedInCharge | ✅ NeedTakenInCharge | ✅ | depuis fermé → ETAT | ✅ | ✅ |
| 29 | DeclareNeedFilled | ✅ NeedFilled | ✅ | en recherche, aucun poste signé → GARDE | ✅ | ✅ |
| 30 | SuspendNeed | ✅ NeedSuspended | ✅ | depuis fermé → ETAT | ✅ | ✅ |
| 31 | ResumeNeed | ✅ NeedResumed | ✅ | depuis ouvert → ETAT | ✅ | ✅ |
| 32 | CloseNeed | ✅ NeedClosed | ✅ | depuis fermé → ETAT | ✅ | ✅ |
| 33 | ReopenNeed | ✅ NeedReopened | ✅ | depuis ouvert → ETAT | ✅ | ✅ |
| 34 | PositionCandidate | ✅ CandidatePositioned+NeedStateChanged | ✅ | unicité (actifs) → GARDE | ✅ | ✅ |
| 35 | PositionResource | ✅ ResourcePositioned+NeedStateChanged | ✅ | unicité (actifs) → GARDE | ✅ | ✅ |
| 36 | DeclareCVShared | ✅ CVShared | ✅ | depuis présenté → ETAT | ✅ | ✅ |
| 37 | RecordClientDecision | ✅ ClientDecisionRecorded | ✅ | CV non présenté (politique oui) → ETAT ; DP n'est pas IA → DROIT ; décision négative sans motif → GARDE | ✅ | ✅ |
| 38 | WithdrawPositioning | ✅ PositioningWithdrawn | ✅ | depuis retenu → ETAT | ✅ | ✅ |
| 39 | CreateProject | ✅ ProjectCreated | ✅ | sans contact (politique obligatoire) → GARDE | ⚠️ état écrit `'ouvert'` en dur | ✅ |
| 40 | CreateProjectFromNeed | ✅ ProjectCreatedFromNeed | ✅ | besoin fermé → ETAT ; aucun retenu → GARDE | ✅ | ✅ |
| 41 | UpdateProject | ✅ ProjectUpdated | ✅ | contact d'une autre société → GARDE | ✅ | ✅ |
| 42 | CloseProject | ✅ ProjectClosed | ✅ | prestation non close → GARDE ; projet déjà clos (hors cycle) → ETAT | ✅ | ✅ |
| 43 | CreatePrestation | ✅ PrestationCreated | ✅ | état signee sans SignPrestation (STAF) → DROIT | ⛔ cjm_devise · ⛔ etat=cloturee/annulee admis | ⛔ |
| 44 | SignPrestation | ✅ PrestationSigned+ClientStatusDerived | ✅ | STAF (—) signe → DROIT ; jours vendus absents → GARDE | ⛔ date_signature | ⛔ |
| 45 | ClosePrestation | ✅ PrestationClosed | ✅ | date de clôture après la fin → GARDE ; depuis prévisionnelle → ETAT | ✅ | ✅ |
| 46 | CancelPrestation | ✅ PrestationCancelled | ✅ | temps déjà saisis → GARDE | ✅ | ✅ |
| 47 | RecordTimesheet | ✅ TimesheetRecorded | ✅ | jour hors des dates → GARDE | ⛔ facturable / quantite_facturable | ⛔ |
| 48 | AdjustTimesheetAfterClose | ✅ TimesheetAdjusted | ✅ | politique = refus → GARDE | ✅ | ✅ |
| 49 | RecordAbsence | ✅ AbsenceRecorded | ✅ | chevauchement (politique refus) → GARDE | ⛔ quantite_par_jour | ⛔ |
| 50 | CreateAction | ✅ ActionCreated | ✅ | deux porteurs → GARDE | ✅ | ✅ |
| 51 | ArchiveObject | ✅ ObjectArchived | ✅ | type societe → commande dédiée → GARDE ; besoin non fermé → GARDE | ⛔ archive un candidat brouillon, une ressource disponible, un projet ouvert (G12) | ⛔ |
| 52 | SetPolicy | ✅ PolicyChanged | ✅ | RH n'est pas ADM → DROIT ; valeur hors valeurs_possibles → GARDE | ✅ | ✅ |
| 53 | ManageRefs | ✅ RefChanged | ✅ | catégorie inconnue → GARDE ; valeur système désactivée → GARDE ; valeur utilisée désactivée → GARDE | ✅ | ✅ |
| 54 | ManageGroups | ✅ GroupPermissionChanged (paire neuve ; en A la paire existait : « inchange », 0 événement) | ✅ | permission sans périmètre → GARDE | ✅ | ✅ |
| 55 | SetOwnTheme | ✅ ThemeChanged | ✅ | politique = non → GARDE | ✅ | ✅ |

**Verdict : 44 ✅ · 11 ⛔** (UpdateCandidate, ConvertCandidateToResource, UpdateResource, RecordQualification, CreateNeed, UpdateNeed, CreatePrestation, SignPrestation, RecordTimesheet, RecordAbsence, ArchiveObject).

---

## 3 · ANGLES MORTS

- Un seul cas « non » par ligne de refus L4, pas tous : les refus `MUR` annoncés (M-2, M-3, M-11, M-12, M-14, M-15) n'ont été vus que par les assertions L7 (GRILLE8 A1), pas provoqués par la commande.
- Les sorties sont jugées sur l'événement et le code, pas champ par champ contre un schéma : L4 n'a pas de schéma JSON (« à écrire avec le lot 2 ») — rien à quoi comparer.
- Les objets d'entrée sont posés en `postgres` (fixture) : un état qu'aucune commande ne sait produire pourrait avoir été rendu possible par la fixture ; les 69 positifs montrent seulement que les commandes l'acceptent.
- Les 43 commandes non servies (L4 = 98) ne sont pas jugées ; elles répondent `INTROUVABLE « commande inconnue »`.
- Politiques : seules trois politiques non lues ont été basculées ; les 58 autres non lues (hors `ui.*`) sont déclarées « hors V1 » ou visent des commandes non servies — non vérifié une à une.
