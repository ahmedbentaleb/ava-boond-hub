# CONFORMITE6 — les commandes servies contre `_ops/SPEC_COMMANDES_L4.md`

**Sixième audit · branche `lot-2` · commit `a26291c`.** Tout ce qui suit est mesuré par **appels
HTTP réels** sur `http://127.0.0.1:3602` (serveur `AVA_MODE=banc`, base `ava_audit6_b` montée par
`db/migrations/001→013` puis `db/fixtures/banc.sql`), puis **relu en base**.

Preuves : `conformite6/le_compte.txt` · `passe2.txt` (la séquence nominale complète) ·
`ecart_politiques.txt` · `H5_agence_ignoree.txt` · `conformite_mesuree.json`.

---

## LE COMPTE — les trois sources demandées coïncident, mais le contrat a doublé

```bash
# recompté, jamais retenu
python - <<'EOF'   # sortie complète : conformite6/le_compte.txt
…  # 1re colonne de L4 nettoyée des 7 non-commandes ; MATRICE §La grille ;
   # export async function ; CORRESPONDANCE ; ava.permission
EOF
```

| Source | Compte mesuré |
|---|---|
| `server/src/commandes/*.ts` — `export async function` | **55** |
| `server/src/agence.ts` — `CORRESPONDANCE` | **55** |
| `ava.permission` | **56** ⚠️ |
| `ava.groupe_permission_perimetre` — codes distincts | **50** |
| **`_ops/SPEC_COMMANDES_L4.md`** — 1ʳᵉ colonne, **11 sections**, nettoyée | ⛔ **95** |
| **`_ops/MATRICE_DROITS_v1.md`** — commandes distinctes / lignes | ⛔ **98 / 70** |

⭐ **Ce que la consigne demandait de vérifier tient** : *commandes servies = lignes de
`CORRESPONDANCE` = handlers* → **55 = 55**, et `comm -3` entre les deux ensembles rend **vide**.
Une commande sans ligne d'agence est refusée avant toute mutation (`executer.ts:150`), une
commande inconnue rend `INTROUVABLE`.

⛔ **Ce qui ne tient plus, c'est le rapport au contrat** : L4 contracte aujourd'hui **95**
commandes. **40 sont contractées et non servies.** Voir **H-01**.

---

## LES 55 AU NOMINAL — 48 menées au vert, 7 refusées avec un motif juste

Séquence complète dans `conformite6/passe2.txt`. Lecture : *évènement mesuré* = le(s) type(s)
réellement écrits dans `evenement_metier` ; *politiques lues* = les clés retrouvées dans
`liens.politiques`.

| Bloc | Menées au vert | Refus mesurés, et leur motif |
|---|---|---|
| I · CRM (11) | 10 | `TransferContact` → `GARDE « objets actifs non réaffectés — réaffectation obligatoire »` ✅ conforme à `contact.transfert.objets_actifs` |
| II · Identité (13) | 12 | `UpdateResourceCost` → `DROIT` ✅ (personne ne l'a, D-30) |
| III · Besoin (14) | 12 | `DeclareNeedFilled` → `GARDE « couverture insuffisante (postes) : 0/1 postes »` ✅ · `WithdrawPositioning` → `ETAT « hors cycle »` ✅ (positionnement déjà terminal) |
| IV · Projet (11) | 11 | — |
| V · Transverse (6) | 3 | `ArchiveObject` → `DROIT` ✅ · `SetOwnTheme` → `GARDE « clé de thème inconnue »` ✅ |

⭐ **Événement : conforme sur les 48.** Chaque commande menée au vert émet exactement le type
que L4 lui assigne. Deux émissions en cascade, toutes deux **contractées** :
`PositionCandidate` → `CandidatePositioned` **+** `NeedStateChanged` (V-064) et
`SignPrestation` → `PrestationSigned` **+** `ClientStatusDerived`.

⚠️ **Les 7 refus ne sont pas des écarts.** Ce sont les gardes qui travaillent. Le piège que le
5ᵉ audit avait nommé — *« un `pol=` vide sur un refus ne prouve rien »* — a été évité ici en
rejouant chaque commande avec ses vraies préconditions (passe 2).

---

## LES POLITIQUES — V-089 s'est rouvert : 8 clés sont lues et ne sont nulle part dans L4

L4 pose la règle : « **Porte dans `liens.politiques` les clés lues et leur valeur au moment de
l'exécution** », et le bloc V-089 (23/09) a porté au contrat les clés que le code lisait sans le
dire — *« le code avait raison, le contrat était en retard »*. **Il l'est de nouveau.**

| Commande | Clé lue, mesurée dans `liens.politiques` | Dans sa ligne L4 ? | Ailleurs dans L4 ? |
|---|---|---|---|
| `CreateContact` · `UpdateCompany` · `UpdateContact` | `societe.perimetre.mode` | ❌ | ❌ **nulle part** |
| `CancelPrestation` | `prestation.annulation.garde` | ❌ (L4 dit « — ») | ❌ **nulle part** |
| `CloseProject` | `projet.cloture.garde` | ❌ (L4 dit « — ») | ❌ **nulle part** |
| `CreateProject` | `projet.origine_besoin` | ❌ | ❌ **nulle part** |
| `CreateProjectFromNeed` | `besoin.projets_max` · `projet.depuis_besoin.garde` | ❌ | ❌ **nulle part** |
| `SignPrestation` | `besoin.pourvu.mode` | ❌ | ❌ **nulle part** |
| `RecordAbsence` | `absence.sans_prestation` | ❌ (L4 dit `absence.chevauchement`) | ❌ **nulle part** |
| `CreateProjectFromNeed` · `SignPrestation` | `projet.contact` | ❌ | ✅ (ligne `CreateProject`) |
| `PositionResource` | `positionnement.sur_besoin_inactif` · `positionnement.unicite` | ❌ (la ligne dit « idem ») | ✅ (ligne `PositionCandidate`) |

**8 clés absentes de TOUT le fichier L4**, toutes présentes au registre §C et en base. Voir **H-02**.

### L'inverse — une seule

| Commande | Contractée | Mesurée |
|---|---|---|
| `PositionCandidate` | `besoin.staffing.declencheur` | ❌ **jamais portée** dans `liens.politiques` |

C'est le **H-3 du 5ᵉ audit, toujours ouvert** — voir le suivi ci-dessous.

---

## SUIVI DES CONSTATS DU 5ᵉ AUDIT (`ava-audit-5/rapport/CONFORMITE.md`)

| # | Constat du 5ᵉ audit | État | Mesure du 6ᵉ |
|---|---|---|---|
| **H-1** | 4 commandes de L4 sans titulaire au seed | ⚠️ **assumé, mais le compte est faux** | Toujours 5 commandes sans titulaire — et D-30 en fait désormais une **décision écrite** dans L4 (« le seed ne leur invente pas de titulaire »). ⛔ **Mais la base en porte SIX** — voir **H-03**. |
| **H-2** | `ArchiveService` / `ArchiveContact` jettent le motif | 🟢 **fermé** | `crm.ts` : `await emit(ctx, "UnitArchived", "unite", id, avant, null, motif)` et `await emit(ctx, "ContactArchived", "contact", id, avant, null, motif)` — le motif est passé dans les deux. |
| **H-3** | `SetPolicy` annonce `TakeNeedInCharge` comme lectrice d'une politique qu'elle ne lit plus | 🔴 **toujours ouvert** | `server/src/politiques.ts:23` : `"besoin.staffing.declencheur": ["TakeNeedInCharge", "PositionCandidate", "PositionResource"]`. Mesuré : `TakeNeedInCharge` menée au vert porte `liens.politiques = {}`. |
| **H-4** | Le refus de `DeclareNeedFilled` cite la mauvaise unité et le mauvais seuil | 🟢 **fermé** | `couverture.ts` lit `unite_couverture_code` et `v_besoin_couverture` ; mesuré : `GARDE « couverture insuffisante (postes) : 0/1 postes »` — l'unité **est** celle du besoin, le seuil **est** `nb_postes_vises`. |
| **H-5** | `ConvertCandidateToResource` reçoit une `agence_id` au contrat, ne l'honore pas et ne la refuse pas | 🔴 **toujours ouvert** | Mesuré de bout en bout — voir **H-04**. |
| **H-7** | Les décisions client admises sont un tableau littéral en TypeScript | 🟢 **fermé** | `besoin.ts:321` : `SELECT categorie FROM ref_decision_client WHERE code = $1 AND actif`, puis comparaison sur la **catégorie** (`positive` / `negative`). Un code ajouté par `ManageRefs` dans une catégorie existante passe. |

**3 fermés · 1 assumé (compte faux) · 2 toujours ouverts.**

---

# LES CONSTATS

## H-01 — L4 contracte 95 commandes, le serveur en sert 55 ; l'en-tête de L4 en annonce encore 55

| | |
|---|---|
| **défaut** | Cinq sections ont été ajoutées à `SPEC_COMMANDES_L4.md` le 24/09 — **VII** RH (8), **VIII** Facturation et achats (13), **IX** Réglages du compte (1), **X** La grille de parité (9), **XI** Les applications (10). Le contrat porte désormais **95** commandes ; le serveur en sert **55**. ⛔ **40 commandes sont contractées et non servies**, et l'en-tête du fichier dit toujours « **20/09/2026 · 55 commandes** ». |
| **cible** | `_ops/SPEC_COMMANDES_L4.md` l. 3 (en-tête) et l. 204-283 (sections VII → XI) |
| **famille** | H — conformité au contrat |
| **gravité** | **moyenne** *(le contrat est en avance sur le code, pas l'inverse — mais un contrat dont le compte est faux ne sert plus à cadrer un lot)* |
| **preuve** | `conformite6/le_compte.txt`. Les 40 : `AddAdditionalRevenue, AddTrackedDocument, BulkArchive, BulkUpdate, ChangeQuoteState, ClearBlacklistFlag, CreateHrContract, CreateInvoiceDraft, CreateMilestone, CreatePurchase, CreateQuote, CreateTechnicalFile, EndHrContract, ExportSelection, GenerateDocument, IssueCreditNote, IssueInvoice, ParseCV, PreparePayroll, PushCVToContacts, RecordBenefit, RecordDiploma, RecordExperience, RecordInvoicePayment, RecordInvoiceReminder, RecordOutlookMail, RecordPayment, RecordSupplierInvoice, RenewHrContract, SendEmail, SendInvoice, SetBlacklistFlag, SetConfidential, SetOwnDashboardWidgets, SyncOutlookEvent, UpdateEmployeeCost, UpdateInvoiceDraft, UpdateSensitiveHrData, UpdateTechnicalFile, ValidatePurchase`. Aucune commande servie n'est hors contrat (`h - L4 = ∅`). |
| **reproduire** | `grep -nE '^# [IVX]+ ·' _ops/SPEC_COMMANDES_L4.md` → 11 sections ; le script de `le_compte.txt`. |
| **prétend** | L4 l. 3 : « **20/09/2026 · 55 commandes.** » ; L4 l. 7 : « elle porte **48 lignes de permission** et **55 commandes distinctes** ». La MATRICE, elle, en porte **98 / 70**. |
| **mesure** | L4 : **95** · MATRICE : **98 / 70** · serveur : **55**. Les trois chiffres écrits dans L4 sont périmés, et le bloc `python` que L4 donne pour se recompter rend aujourd'hui **98 · 70** — il contredit la ligne qu'il est censé prouver. |
| **correction** | L4 se recompte déjà par un script : il suffit de **le relancer et de réécrire la ligne 3 et la ligne 7** — ou, mieux, d'ajouter à chaque section un marqueur de lot (comme les portes ont leur « Lot cible »), pour que « contracté » et « servi » cessent d'être le même mot. |

## H-02 — huit politiques sont lues par le serveur et ne figurent nulle part dans L4 (V-089 rouvert)

| | |
|---|---|
| **défaut** | Huit clés sont lues à l'exécution et portées dans `liens.politiques`, et **aucune n'apparaît dans `SPEC_COMMANDES_L4.md`** — ni dans la ligne de la commande, ni dans le bloc V-089, ni ailleurs. Elles existent toutes au registre §C et dans `ava.politique`. |
| **cible** | `_ops/SPEC_COMMANDES_L4.md` colonnes *Politique* des sections I à V, et le bloc V-089 (l. 148-152) |
| **famille** | H — conformité au contrat |
| **gravité** | **moyenne** |
| **preuve** | `conformite6/ecart_politiques.txt`. Les huit : `absence.sans_prestation`, `besoin.pourvu.mode`, `besoin.projets_max`, `prestation.annulation.garde`, `projet.cloture.garde`, `projet.depuis_besoin.garde`, `projet.origine_besoin`, `societe.perimetre.mode`. Exemple mesuré : `CancelPrestation` → `evenement.liens.politiques = {"prestation.annulation.garde": …}` alors que sa ligne L4 porte « — ». |
| **reproduire** | Séquence de `conformite6/passe2.py` ; puis `grep -c "prestation.annulation.garde" _ops/SPEC_COMMANDES_L4.md` → **0**, `… _ops/REGISTRE_POLITIQUES_v1.md` → **1**, `select count(*) from politique where cle='prestation.annulation.garde'` → **1**. |
| **prétend** | L4, « Ce que TOUTE commande fait » §4 : « Porte dans `liens.politiques` **les clés lues et leur valeur au moment de l'exécution** ». Et le bloc V-089 : « ⭐ Le code avait raison, le contrat était en retard. » |
| **mesure** | **10 commandes** lisent au moins une clé que leur ligne ne contracte pas ; **8 clés** manquent à tout le fichier. |
| **correction** | Le même geste que le 23/09 : relever les clés **mesurées** et les porter au contrat. ⭐ Et puisque c'est la deuxième fois, en faire une **porte** : une commande dont `liens.politiques` contient une clé absente de sa ligne L4 échoue au banc. Cela ne se re-discute plus. |

## H-03 — `LireDonneesRHSensibles` : une permission de plus, sans titulaire, que D-30 ne compte pas

| | |
|---|---|
| **défaut** | La migration `012` crée la permission `LireDonneesRHSensibles` (famille `rh`). Elle n'est donnée à **aucun groupe**. `ava.permission` porte donc **56** lignes pour 55 commandes, et **six** permissions sans titulaire — pas cinq. ⚠️ Et la MATRICE affirme, elle, qu'elle **est** donnée. |
| **cible** | `db/migrations/012_schema_v1_complet.sql` l. 965 · `_ops/MATRICE_DROITS_v1.md` l. 151 · `_ops/SPEC_COMMANDES_L4.md` l. 100-103 (bloc D-30) |
| **famille** | H — conformité au contrat |
| **gravité** | **faible** *(aucune commande ne la consulte aujourd'hui — les trois commandes de paie sont dans les 40 non servies)* |
| **preuve** | ```sql\nSELECT p.code, p.famille FROM permission p\nWHERE NOT EXISTS (SELECT 1 FROM groupe_permission_perimetre g WHERE g.permission_code = p.code);\n``` → `ArchiveCompany·crm`, `ArchiveContact·crm`, `ArchiveObject·admin`, `ArchiveService·crm`, **`LireDonneesRHSensibles·rh`**, `UpdateResourceCost·identite` — **6 lignes**. |
| **reproduire** | `select count(*) from permission` → **56** ; `select distinct permission_code from groupe_permission_perimetre` → **50**. |
| **prétend** | L4, D-30 (24/09) : « ⛔⛔ **Cinq commandes, et cinq seulement, que PERSONNE n'a au départ** ». MATRICE l. 151 : « `LireDonneesRHSensibles`, **donnée au seul groupe RH** ». |
| **mesure** | **Six** permissions sans titulaire. Et celle que la MATRICE dit donnée au groupe RH n'est donnée à personne. |
| **correction** | Trancher, et écrire lequel : soit le seed la pose sur RH (ce que dit la MATRICE), soit D-30 l'absorbe et dit « **six** permissions ». ⚠️ Le bloc D-30 parle de « commandes », la base compte des « permissions » — les deux comptes sont justes et ne portent pas sur la même chose ; c'est exactement ce qui fait diverger un chiffre écrit deux fois. |

## H-04 — `ConvertCandidateToResource` accepte une `agence_id` au contrat, l'ignore, et ne la refuse pas *(H-5 du 5ᵉ audit, toujours ouvert)*

| | |
|---|---|
| **défaut** | L4 contracte l'entrée `profil_candidat_id, type, **agence**, fournisseur`. Le handler écrit `const agenceId = ctx.compte.agence_id` et insère **l'agence du demandeur**, quelle que soit l'agence envoyée. Aucun refus. ⛔ L'appelant croit avoir choisi l'agence de la ressource ; il ne l'a pas choisie, et rien ne le lui dit. |
| **cible** | `server/src/commandes/identite.ts` l. ~250 (`const agenceId = ctx.compte.agence_id`) · `server/src/agence.ts` l. 76-78 |
| **famille** | H — conformité au contrat |
| **gravité** | **moyenne** |
| **preuve** | Mesuré de bout en bout (`conformite6/H5_agence_ignoree.txt`) : compte `rh@ava.test` (agence **PAR**), `agence_id` envoyée = **LYO** → réponse `{"ok": true}` → `select a.code from profil_ressource r join agence a on a.id=r.agence_id` → **`PAR`**. Contre-épreuve sans `agence_id` : même résultat, `PAR`. |
| **reproduire** | `python h5.py` (joint) : créer société + contact + besoin + personne + candidat, positionner, `DeclareCVShared`, `RecordClientDecision retenu`, puis `ConvertCandidateToResource` avec l'UUID d'une seconde agence. |
| **prétend** | L4 §II : « **`ConvertCandidateToResource`** — profil_candidat_id, type, **agence**, fournisseur ». Et `CORRESPONDANCE` porte bien un lecteur `agence(["agence_id","agence"])` — mais il est **second**, et `exigeAgence` sort sur le **premier** lecteur qui trouve (`break`), c'est-à-dire toujours `profil_candidat`. |
| **mesure** | Le champ est **accepté, ignoré, et non refusé**. |
| **correction** | Une des deux, et une seule : soit la commande **honore** l'agence reçue (et `entreeAgence` la fait alors juger par le périmètre, comme pour `CreateUnit`), soit elle la **refuse** (`GARDE`, champ non retenu). ⭐ `CreateUnit` montre déjà le motif propre : `entreeAgence: ["agence_id","agence"]` fait lever `DROIT` si l'entrée diffère de l'objet. |

---

## VERDICT

```
CONFORMITÉ — 55 servies / 95 contractées · 4 constats · 2 constats du 5e audit toujours ouverts
H-01  L4 contracte 95 commandes, le serveur en sert 55 ; l'en-tete dit 55       moyenne
H-02  8 politiques lues et absentes de tout L4 (V-089 rouvert)                  moyenne
H-04  ConvertCandidateToResource ignore l'agence recue sans la refuser (= H-5)  moyenne
H-03  LireDonneesRHSensibles : 6e permission sans titulaire, D-30 en compte 5   faible
→ fermes depuis le 5e audit : H-2 (motif d'archivage) · H-4 (message de couverture)
                              H-7 (decisions client au referentiel)
→ toujours ouverts : H-3 (politiques.ts annonce TakeNeedInCharge) · H-5 (= H-04)
```

⭐ **Ce qui tient.** Les trois sources demandées **coïncident exactement** : 55 handlers,
55 lignes de `CORRESPONDANCE`, 55 commandes servies, aucun écart dans les deux sens. **48 sur 55
menées au vert** dans une séquence nominale complète, et les 7 refus restants sont des **gardes
qui travaillent**, pas des manques. **Tous les événements sont conformes**, cascades comprises.
Et trois des sept constats du 5ᵉ audit sont fermés, mesurés fermés — pas déclarés.
