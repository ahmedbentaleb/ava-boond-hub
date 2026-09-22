# CONFORMITÉ H — les 55 commandes contre `_ops/SPEC_COMMANDES_L4.md`

**55 / 55 commandes du contrat servies · 42 conformes · 13 non conformes (dont 3 écarts favorables : le
contrat est faux, pas le code) · 1 commande servie hors contrat (`gardePourvu`).**
Mesuré par **259 appels HTTP** sur mon serveur (`AVA_MODE=banc`, port 3202, base `ava_audit2_b`) : 241 dans
`sondes.mjs` (226 conformes à l'attendu du contrat), 18 sondes complémentaires ; + 4 hors banc (SECURITE.md).

| Mesure transverse | Résultat |
|---|---|
| Refus qui écrivent un `evenement_metier` | **0** sur 135 refus (`dEvt=0` partout) ✅ |
| Refus tracés dans `tentative_refusee` | 134/135 — seule la commande **inconnue** n'est pas tracée |
| Refus `MUR` vus par l'appelant | **1** — `ManageRefs` catégorie inventée (garde manquante) |
| Mutation réussie sans événement | **0** sur 106 appels réussis ✅ |
| Commande par un groupe sans droit (SUP, entrée vide) | **54/54 → DROIT**, 0 écriture ✅ (SetOwnTheme exclu : SUP l'a) |
| HTTP d'un refus | toujours **200** (`ok:false`) ; 500 + code `ERREUR` sur entrée mal typée |

Preuves : `rapport/preuves/conformite/sondes_sortie.txt` (journal ligne à ligne), `sondes.json` (241 appels
avec corps), `sondes2_sortie.txt`, `sondes3_sortie.txt`, `handlers.txt`. Scripts rejouables : `sondes.mjs`
(après `prepare_audcas.sql`), `sondes2.mjs`, `sondes3.mjs`.

Légende : ✅ conforme mesuré · ❌ non conforme · ⚠️ écart sans effet ou non sondé (dit pourquoi) · « tag » = libellé
de la ligne dans `sondes_sortie.txt`.

## I · CRM

| Commande | Existe | Entrée | Sortie | Refus | Événement | Politique lue | Mur | Preuve des « non » |
|---|---|---|---|---|---|---|---|---|
| CreateCompany | ✅ | ✅ | ✅ | ✅ doublon bloquer→GARDE | ✅ CompanyCreated | ✅ doublon.societe.mode+cles | — | |
| UpdateCompany | ✅ | ✅ | ✅ | ✅ INTROUVABLE | ✅ | — | — | ⚠️ id non-UUID → HTTP 500 `ERREUR` (sondes3 #1) — transverse |
| RequalifyCompany | ✅ | ✅ | ✅ | ✅ ETAT prospect→ancien_client | ✅ CompanyStatusChanged | ✅ societe.retour_prospect | — | ⚠️ cycle écrit en dur sur des codes (cycle.ts:86-91) — B1 |
| ArchiveCompany | ✅ | ✅ | ✅ vide | ✅ GARDE objets actifs ; DROIT tant que non délégué | ✅ CompanyArchived + motif | ✅ societe.archivage.garde | ✅ M-8 (UPDATE archive_le, jamais DELETE) | |
| CreateUnit | ✅ | ✅ | ✅ | ✅ parent autre société (GARDE, message distinct) | ✅ | — | ✅ M-12 non atteint | ⚠️ cas « autre agence si interne » non sondé (exige `societe_role` interne) |
| UpdateUnit | ✅ | ✅ | ✅ | ✅ cycle → GARDE « cycle dans l'arbre » | ✅ | — | ✅ | |
| ArchiveService | ✅ | ✅ | ✅ | ⚠️ « besoin actif sur l'unité » **inatteignable** : CreateNeed n'accepte pas `unite_organisation_id` | ✅ UnitArchived | ✅ service.archivage.garde | ✅ | garde morte (crm.ts:237-249 vs besoin.ts:27-80) |
| CreateContact | ✅ | ✅ | ✅ | ✅ unité autre société | ✅ | ✅ doublon.contact.* | ✅ | |
| UpdateContact | ✅ | ✅ | ✅ | ✅ | ✅ | — | ✅ | |
| TransferContact | ✅ | ✅ | ✅ | ✅ GARDE objets actifs | ✅ | ✅ contact.transfert.objets_actifs | ✅ | |
| ArchiveContact | ✅ | ✅ | ✅ | ✅ GARDE objets actifs | ✅ | — | ✅ | |

## II · Identité et recrutement

| Commande | Existe | Entrée | Sortie | Refus | Événement | Politique lue | Mur | Preuve des « non » |
|---|---|---|---|---|---|---|---|---|
| CreatePerson | ✅ | ✅ | ✅ | ✅ doublon bloquer | ✅ | ✅ doublon.personne.* | — | |
| **CreateCandidate** | ✅ | ✅ | ✅ | ❌ **écart favorable** : contrat `MUR` si profil existant, code `GARDE` | ✅ | — | M-3 jamais atteint | tag « refus candidat existant (contrat MUR) » ; identite.ts:49 — le contrat est à corriger (BRAIN) |
| UpdateCandidate | ✅ | ✅ | ✅ | ✅ INTROUVABLE ; GARDE note hors échelle | ✅ | ✅ candidat.note.echelle | — | |
| CompleteCandidate | ✅ | ✅ | ✅ état `complete` | ✅ GARDE champs listés par la politique | ✅ | ✅ champs_requis | — | |
| ExitCandidate | ✅ | ✅ | ✅ état `sorti` | ✅ ETAT depuis brouillon | ✅ + motif | — | ✅ n'écrit pas ref_etat_candidat | |
| ReactivateCandidate | ✅ | ✅ | ✅ | ✅ ETAT depuis actif | ✅ | — | — | |
| **ConvertCandidateToResource** | ✅ | ✅ | ✅ profil ressource sur la **même** personne (1 seule « Durand ») | ❌ doublon → GARDE (contrat MUR, favorable) ; ✅ sans retenu, EXTERNAL sans fournisseur, acteur non désigné (STAF délégué → DROIT) | ✅ | ✅ conversion.acteur + externe.fournisseur | — | identite.ts:191 ; ⚠️ agence **cible** non contrôlée si le candidat a une agence (identite.ts:184, lecture) |
| **CreateResource** | ✅ | ✅ | ✅ | ❌ doublon → GARDE (contrat MUR, favorable) ; ✅ externe sans fournisseur | ✅ | ✅ | — | identite.ts:227 |
| UpdateResource | ✅ | ✅ | ✅ | ✅ refuse le coût (GARDE) | ✅ | — | — | |
| SetResourceState | ✅ | ✅ | ✅ | ✅ ETAT hors cycle | ✅ | ✅ ressource.etat.mode | — | ⚠️ compare à `CAT.candidat.sorti` (identite.ts:281,287) |
| UpdateResourceCost | ✅ | ✅ | ✅ coût visible seulement avec le droit | ✅ DROIT au seed, ok après délégation ADM | ✅ | — | ⚠️ M-15 non sondé | |
| **UploadDocument** | ✅ | ✅ | ✅ | ❌ **périmètre** : RH-PAR dépose sur un candidat de CAS → ok ; ✅ 0/2 porteurs, RES soi-même | ✅ | — | ✅ | tag « PERI UploadDocument » ; identite.ts:322-375 (aucun exigeObjet) |
| **RecordQualification** | ✅ | ✅ | ✅ | ❌ **périmètre** : EVAL-PAR qualifie sur un besoin de CAS → ok ; ✅ besoin absent | ✅ | ✅ | — | tag « PERI RecordQualification » ; identite.ts:377-410 |

## III · Besoin et positionnement

| Commande | Existe | Entrée | Sortie | Refus | Événement | Politique lue | Mur | Preuve des « non » |
|---|---|---|---|---|---|---|---|---|
| CreateNeed | ✅ | ✅ | ✅ + couverture | ✅ contact autre société, FTE manquant, DROIT agence CAS | ✅ | ✅ besoin.contact | ✅ | ⚠️ `nb_postes_vises:"deux"` → 500 (sondes3 #5) |
| UpdateNeed | ✅ | ✅ | ✅ | ✅ ; DROIT sur besoin CAS | ✅ | — | ✅ | |
| SetNeedPriority | ✅ | ✅ | ✅ | ✅ INTROUVABLE | ✅ | — | — | |
| TakeNeedInCharge | ✅ | ✅ | ✅ | ✅ ETAT hors cycle ; ETAT si la politique ne désigne pas la commande | ✅ | ✅ staffing.declencheur | — | |
| DeclareNeedFilled | ✅ | ✅ | ✅ | ✅ GARDE 0/2 postes | ✅ NeedFilled | ✅ garde_minimale | — | ⚠️ variantes `fte`/`postes_et_fte` non sondées |
| SuspendNeed | ✅ | ✅ | ✅ | ✅ | ✅ motif dans l'événement | — | ✅ P-5 | |
| ResumeNeed | ✅ | ✅ | ✅ | ✅ | ✅ | — | — | |
| CloseNeed | ✅ | ✅ | ✅ | ✅ | ✅ motif | — | — | |
| ReopenNeed | ✅ | ✅ | ✅ | ✅ | ✅ | — | — | |
| PositionCandidate | ✅ | ✅ | ✅ | ✅ unicité | ✅ (+ NeedStateChanged au 1er) | ✅ unicite + sur_besoin_inactif | ✅ | |
| PositionResource | ✅ | ✅ | ✅ | ✅ unicité | ✅ | ✅ | ✅ | |
| DeclareCVShared | ✅ | ✅ | ✅ état `presente` | ✅ ETAT ; DROIT sur CAS | ✅ | — | ✅ étape `cv_partage` écrite | |
| **RecordClientDecision** | ✅ | ✅ | ❌ **décision « Retenu » enregistrée `refuse_client`** | ✅ DROIT hors IA, ETAT avant CV, GARDE motif | ✅ + motif | ⚠️ `projet.creation_depuis_besoin` lue **après** l'événement, absente des liens | — | sondes3 #2 ; besoin.ts:336 (liste en dur `["retenu","terminal_positif","oui","accepte"]`), besoin.ts:345-346 |
| **WithdrawPositioning** | ✅ | ✅ | ✅ | ❌ **périmètre** : IA-PAR retire un positionnement de CAS → ok ; ✅ ETAT, motif hors `ref_motif_retrait` → GARDE | ✅ + motif | — | ✅ P-5 | tag « PERI WithdrawPositioning » ; besoin.ts:353-368 (aucun exigeObjet) |

## IV · Projet, prestation, production

| Commande | Existe | Entrée | Sortie | Refus | Événement | Politique lue | Mur | Preuve des « non » |
|---|---|---|---|---|---|---|---|---|
| CreateProject | ✅ | ✅ | ✅ | ✅ contact obligatoire | ✅ | ✅ projet.contact | ✅ | |
| CreateProjectFromNeed | ✅ | ✅ | ✅ `besoin_id` rempli | ✅ GARDE sans retenu, ETAT besoin fermé | ✅ | ✅ garde_profil (+3) | ✅ | |
| UpdateProject | ✅ | ✅ | ✅ | ✅ contact autre société | ✅ | — | ✅ | |
| **CloseProject** | ✅ | ✅ | ✅ | ✅ ETAT clos, GARDE prestations ouvertes ; ❌ sous `cascade_cloture_prestations` → **ETAT « CloseProject hors cycle »** | ✅ | ❌ valeur `cascade_…` lue mais inopérante | — | tag « CloseProject cascade (politique) » ; projet.ts:150-155 appelle ClosePrestation avec `ctx.commande=CloseProject`, cycle.ts:111-118 lit `TRANSITIONS[CloseProject]` |
| CreatePrestation | ✅ | ✅ | ✅ | ✅ état `signee` par STAF → DROIT (G8) | ✅ | ✅ devises_mixtes + surcharge.* | ✅ | ⚠️ agence de la ressource non contrôlée (lecture) |
| **SignPrestation** | ✅ | ✅ | ✅ état `signee` | ✅ DROIT STAF, ETAT déjà signée | ✅ PrestationSigned + ClientStatusDerived | ❌ `prestation.avenant.mode`, `societe.passage_client.*`, `besoin.pourvu.mode` lues **après** PrestationSigned : absentes de ses liens ; si la société est déjà cliente, tracées **nulle part** (évt 75) | ✅ M-14 | sondes2_sortie.txt ; projet.ts:332-333, 164-230 |
| ClosePrestation | ✅ | ✅ | ✅ état `cloturee` | ✅ ETAT depuis prévisionnelle | ✅ | ✅ frais/change/marge | ✅ snapshot même transaction | ⚠️ `version_atl` en dur (projet.ts:376), montants en flottant |
| CancelPrestation | ✅ | ✅ | ✅ | ✅ ETAT clos | ✅ + motif | ✅ annulation.garde | — | |
| RecordTimesheet | ✅ | ✅ | ✅ | ✅ hors dates, RES autrui → DROIT, facturable exigé | ✅ | ✅ les 4 + capacite | ✅ | |
| AdjustTimesheetAfterClose | ✅ | ✅ | ✅ `ajustement=true` | ✅ politique `refus` → GARDE | ✅ + motif | ✅ | ✅ **M-6 : snapshot inchangé** (600/200 avant et après) | |
| RecordAbsence | ✅ | ✅ | ✅ | ✅ chevauchement, RES autrui → DROIT, RES soi-même ok | ✅ | ✅ | — | |

## V · Transverse et administration

| Commande | Existe | Entrée | Sortie | Refus | Événement | Politique lue | Mur | Preuve des « non » |
|---|---|---|---|---|---|---|---|---|
| **CreateAction** | ✅ | ✅ | ✅ | ❌ **périmètre** : IA-PAR pose une action sur un besoin de CAS → ok ; ✅ 0/2 porteurs | ✅ | — | ✅ M-9 | tag « PERI CreateAction » ; admin.ts:27-45 |
| **ArchiveObject** | ✅ | ✅ | ✅ | ❌ **aucune garde par objet** : projet avec prestation signée archivé, besoin actif archivé ; ❌ **périmètre** : besoin de CAS archivé par IA-PAR | ✅ ObjectArchived | — | ✅ M-8 | tags « ArchiveObject projet engagé », « …besoin actif », « PERI ArchiveObject » ; admin.ts:47-68 |
| **SetPolicy** | ✅ | ✅ | ❌ **la liste des commandes affectées est perdue** : la sortie ne garde que l'objet `politique` | ✅ DROIT hors ADM, GARDE hors valeurs_possibles | ✅ PolicyChanged avant/après | — | ✅ | sondes_sortie « SetPolicy sortie complète » ; `sortieDe` executer.ts:219-232 jette `commandes_affectees` (admin.ts:95) — §C-5 |
| **ManageRefs** | ✅ | ✅ | ✅ | ❌ catégorie inventée → **MUR** « erreur interne » ; ❌ valeur **système et utilisée** (`ref_etat_besoin.ouvert`) désactivée → ok ; ❌ valeur **utilisée** (`ref_type_mission.forfait`) désactivée → ok | ✅ | — | CHECK catégorie atteint | 3 tags « refus ManageRefs … » ; admin.ts:99-138 ; `ref_garde` ne protège que DELETE/catégorie/code |
| ManageGroups | ✅ | ✅ | ✅ | ✅ sans périmètre → GARDE, IA → DROIT | ✅ | — | ✅ M-13 | |
| SetOwnTheme | ✅ | ⚠️ tout JSON accepté (clés `<script>`, objets imbriqués) | ✅ | ✅ politique `non` → GARDE | ✅ | ✅ | — | sondes3 #4 |

## Inverses

| Sens | Compte | Détail |
|---|---|---|
| Commandes du contrat non servies | **0** | les 55 noms de L4 sont dans `HANDLERS` (`handlers.txt`) |
| Commandes servies absentes du contrat | **1** | `gardePourvu` — fonction utilitaire exportée par `commandes/besoin.ts:111`, donc routée par `executer.ts:10-16`. Répond DROIT (aucune permission de ce nom) : le seul verrou est l'absence d'une ligne `permission` |

## Constats candidats — famille H

**H-1 · Cinq commandes mutent un objet hors du périmètre de l'appelant.** Cible CODE · H/I · **critique** (S14,
MATRICE §procedure étape 4) · preuve : 5 tags « PERI … » dans `sondes_sortie.txt` · reproduire (serveur banc sur
ta base, `prepare_audcas.sql` joué) :
```bash
node C:/Users/Hamada/Desktop/ava-audit-2/rapport/preuves/conformite/sondes.mjs | grep PERI
```
· prétend « vérifier que le périmètre de la paire contient l'objet visé » · mesure : WithdrawPositioning,
RecordQualification, UploadDocument, CreateAction, ArchiveObject passent sur des objets de CAS avec un compte PAR ·
correction : résoudre l'agence de l'objet visé et appeler `exigeObjet` dans chaque commande — mieux, dans
`executerCommande` avant le handler, d'après une table commande → objet.

**H-2 · RecordClientDecision range toute décision inconnue en refus client.** Cible CODE · H/B1 · **elevee**
(frôle « donnée fausse servie ») · preuve sondes3 #2, besoin.ts:336 · reproduire :
```bash
node C:/Users/Hamada/Desktop/ava-audit-2/rapport/preuves/conformite/sondes3.mjs
```
· prétend « décision » · mesure : `decision:"Retenu"` → état `refuse_client` / `terminal_negatif` · correction :
la décision est un code de `ref_etat_positionnement` (catégorie `terminal_*`) validé, GARDE sinon.

**H-3 · ArchiveObject archive sans garde.** Cible CODE · H · **elevee** · preuve tags « ArchiveObject projet engagé
(contrat GARDE) », « …besoin actif » · prétend « GARDE selon l'objet » · mesure : projet avec prestation signée et
besoin actif archivés · correction : une garde par type (mêmes règles que ArchiveCompany/Contact/Service), lue
dans une politique `*.archivage.garde`.

**H-4 · ManageRefs n'a pas deux de ses trois gardes, et la troisième tombe en MUR.** Cible CODE · H · **elevee** ·
preuve 3 tags « refus ManageRefs … » · prétend « GARDE catégorie inconnue · valeur système · valeur utilisée » ·
mesure : désactiver `ref_etat_besoin.ouvert` (système, utilisé) passe — ensuite `codeCategorie` (cycle.ts:101-108,
`AND actif`) ne trouve plus de code `a_pourvoir` et **CreateNeed refuse pour tout le monde** ; catégorie inventée
→ MUR « erreur interne » · correction : refuser `actif=false` sur une valeur `systeme` ou référencée, vérifier la
catégorie contre les catégories existantes avant l'INSERT.

**H-5 · La politique `projet.cloture.garde = cascade_cloture_prestations` rend CloseProject impossible.** Cible
CODE · H/B · **elevee** · preuve tag « CloseProject cascade (politique) » → ETAT · correction : appeler la
clôture de prestation avec son propre contexte de commande (ou une fonction interne sans `exigeTransition` du
parent).

**H-6 · `liens.politiques` incomplet sur SignPrestation (et RecordClientDecision).** Cible CODE · H règle 4 ·
**elevee** · preuve `sondes2_sortie.txt` (évt 55 et 75 : `["projet.contact"]` seulement) · prétend « porte les
clés lues et leur valeur » · mesure : 4 clés lues après l'émission, jamais tracées quand la société est déjà
cliente · correction : lire toutes les politiques avant `emit`, ou réécrire `liens` de l'événement principal en fin
de transaction (INSERT unique en fin de commande).

**H-7 · SetPolicy ne rend pas la liste des commandes affectées.** Cible CODE · H §C-5 · **moyenne** · preuve
« SetPolicy sortie complète » · correction : `sortieDe` ne doit pas écraser les champs frères de l'objet
enveloppé.

**H-8 · Le contrat dit MUR là où le code dit (mieux) GARDE.** Cible BRAIN · H · **moyenne** · CreateCandidate,
CreateResource, ConvertCandidateToResource sur profil existant · correction : L4 dit GARDE (un MUR vu est un bug,
L4 l.60).

**H-9 · Entrée mal typée → HTTP 500 « ERREUR », hors des cinq familles, non tracée.** Cible CODE · H · **moyenne** ·
preuve sondes3 #1 et #5 · prétend « Refus : chaque cas avec son code, jamais un erreur 500 » (L4 l.45) ·
correction : valider les UUID/nombres en entrée (GARDE) avant la première requête.

**H-10 · `gardePourvu` routé comme une commande.** Cible CODE · **moyenne** · `besoin.ts:111` exporté ·
correction : ne pas l'exporter depuis un module de commandes (ou liste blanche explicite dans `HANDLERS`).

**H-11 · Garde morte d'ArchiveService.** Cible BRAIN+CODE · **moyenne** · aucun chemin de commande ne rattache un
besoin à une unité · correction : décider si CreateNeed prend `unite_organisation_id` (contrat) ou retirer la garde.

**H+ · bien fait (bonne).** 0 écriture sur 135 refus ; 54/54 commandes refusées DROIT pour un groupe sans droit ;
identité non copiée à la conversion ; snapshot figé après ajustement ; G8 tenu (créer signée exige
SignPrestation) ; UpdateResourceCost masque le coût à qui n'a pas le droit ; motifs toujours dans l'événement (P-5).
