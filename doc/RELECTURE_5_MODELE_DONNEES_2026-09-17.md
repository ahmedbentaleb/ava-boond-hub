# Relecture contradictoire — Modèle de données v1 (livrable 5) — 17 septembre 2026

**Verdict : le livrable tient ses 15 murs et ses arbitrages G, mais il n'est pas signable tel quel — 4 trous qui changent une table, 4 écarts à sa propre règle, et un compte faux sur la couverture.** Rien de cosmétique n'est listé.

Relu par Fable (5c), qui n'a pas écrit les tables. Périmètre : `MODELE_DONNEES_AVAMANAGER_V1.md` contre `MODELE_METIER_CANONIQUE_v1`, `MACHINES_ETAT_V1`, `REGISTRE_POLITIQUES_v1`, `ADR-002/003/004/005`, `FEUILLE_G1-G15`, `AUDIT_PROJET`. Suite de [RELECTURE_5b_SIMULATEUR](RELECTURE_5b_SIMULATEUR_2026-09-17.md). Reste pour 5c : le canvas 5b.

⭐ Chaque constat porte **ma décision** (modélisation = Brain, métier = Ahmed). Ahmed valide à la porte, pas point par point.

---

## 0. État après patch — 17/09, 23h — ce que le relecteur du diff doit vérifier

Quatre relectures (Fable · tiers n°1 · tiers n°2 [RELECTURE_5_TIERS](RELECTURE_5_TIERS_2026-09-17.md) · Fable) ; 15 constats confirmés par un lecteur indépendant, 5 contestés et arbitrés ci-dessous, 3 oublis ajoutés. **Le livrable est patché** ; le diff est `git diff 093d43a -- _ops/`.

| # | Patché où | Ce qui a changé |
|---|---|---|
| D-1 | livrable §3.2, §6.1, §7 · carte | pôles / équipes internes = `unite_organisation` de la société `interne` ; `perimetre.unite_id` + trigger ; `agence.perimetre_id` **retiré** ; `type_code` gagne `equipe` |
| D-2 | livrable §3.1, §3.2, §3.3 | `statut_commercial_code` nullable sur `unite_organisation` et `contact` (NULL = hérite) |
| D-3 | livrable §3.1 · registre §B | `ref_role_societe` = fournisseur · interne ; `ref_statut_commercial` = prospect · client, référentiel séparé ; **la règle rôle ≠ statut est écrite** (réponse à la contestation du tiers : on n'a pas supprimé sans expliquer) |
| D-4 | livrable §5.3, §5.4 | `archive_le` sur `temps` et `absence` ; `TimesheetCancelled`, `AbsenceCancelled` |
| D-5 | livrable §0 (règle), §4.3, §5.1 | `projet.contact_id` et `qualification.besoin_id` **NULL en base**, garde en commande |
| D-6 | livrable §4.2 · registre §C | index unique partiel **retiré** ; garde de commande ; index simple |
| D-7 | livrable §2.4 | `document` : 5 FK nullables + CHECK somme = 1 |
| D-8 | livrable §1, §6.2, §6.3, §11 · plan l.5 | carte refaite : **32 tables** (dont `politique`) + `reprise_boond` + **24 ref** |
| **D-9** (ex P-3) | livrable §5.1 | `projet.devise_code` **retiré** — arbitrage de modélisation assumé comme tel (le tiers avait raison : ce n'était pas une « conséquence d'ADR-003 ») |
| P-1 | livrable §2.2, §2.3, §4.1, §4.2 | `etat_categorie` sur les 4 tables qui l'omettaient |
| P-2 | livrable §4.1 | trigger M-12 sur `besoin.unite_organisation_id` |
| P-4 | livrable §7 | `compte_surcharge` sans colonne `sens` — restriction seule (F28) |
| P-5 | livrable §0, §4.2 | `motif_retrait_code` **retiré** ; les motifs vivent dans `evenement_metier.motif` |
| **P-6 → politique** | registre §C · livrable §5.3 · cahier Q60 | le tiers avait raison : c'était une garde inventée. Elle devient la **60e bifurcation** `temps.plafond_jour` (alerte · refus · aucun), posée aux directeurs. ⚠️ Le simulateur (25 clés) ne la porte pas encore |
| P-7 | — | **retiré** : ADR-005 décide `TEXT`, le tiers a raison |
| T-1 | feuille G l.188 | récapitulatif G4 aligné (le tiers l'avait vu) |
| **T-2** | livrable §5.2, §9 · registre §A · modèle métier §3 | **M-14 devient un trigger** (colonnes économiques immuables dès `engage`). **M-15 reformulé** en ce que la base garantit vraiment : *aucun montant faux stocké* — l'addition ad hoc EUR + MAD est une règle de code, dite comme telle |
| T-3 | plan l.5b+ | Opus l'a réécrite en corrigeant le simulateur |
| T-4, T-5 | brief · cette relecture | déjà corrigés avant le patch |
| **O-1** | livrable §4.3 | reformulé : une `qualification` = une séance ; ré-évaluer = nouvelle ligne. Pas de restructuration (le constat était faible, la phrase était ambiguë) |
| **O-2** | livrable §5.2 · machines §5 | `CreatePrestation` en `engage` = les effets de `SignPrestation` — c'était E-1 du simulateur, jamais remonté dans la machine |
| **O-3** | livrable §5.1 | trigger M-12 sur les trois contacts du projet |

**Second patch — 17/09, 23h30 — après [RELECTURE_5_TIERS_DIFF](RELECTURE_5_TIERS_DIFF_2026-09-17.md)** : 14 conformes, 8 de travers, 7 cassures ailleurs. Tout est repris :

| # | Ce qui manquait | Repris où |
|---|---|---|
| D-1 | `agence` restait une seconde hiérarchie ; pas de XOR sur `perimetre` | `unite_organisation.agence_id` (NOT NULL si société interne, trigger) ; CHECK de `perimetre` par `type_code` (X-6) ; `ref_type_unite` au registre avec `equipe` ; modèle métier §1. ⭐ Réponse à la question du tiers : **un pôle interne pend d'une agence** — l'agence est le site, le pôle l'organisation dedans |
| D-3 | machines §7 et modèle métier disaient encore « rôle client » | les deux alignés (X-1, X-2) |
| D-5, D-6 | modèle métier §2 disait encore NOT NULL et index partiel | aligné (X-2) |
| D-8 | §6.3 comptait `ref_statut_commercial` deux fois ; plan « 27 tables » et « 59 réglages » | 17 + 7 = 24 partout (X-3, X-4) |
| D-9 | motif citait ADR-003 ; deux devises « légales » sans le dire | motif réécrit comme **arbitrage** ; c'est une bifurcation → **POL `projet.devises_mixtes`** (autorise · refus), cahier Q61. ⭐ Réponse à la question du tiers : **une politique**, défaut `autorise` — le freelance MAD sur projet EUR est un cas réel d'Avaliance |
| T-1 | feuille G, option C, disait encore « aucune prestation signée » | corrigé (X-5) |
| T-2 | M-15 écrit comme mur **et** « pas un mur » dans la même cellule | **scindé** : M-15 = ce que la base garantit (NOT NULL + aucune colonne convertie, patron M-5), **règle de code R-1** à part, hors des quinze — dans le livrable §9, le registre §A, le modèle métier §3 |
| X-7 | la garde T-1 n'était écrite nulle part dans le livrable | formule dans §4.1, avec la conséquence : un projet créé sans besoin ne pourvoit aucun besoin (DEC-05) |

Comptes après second patch : voir **registre §E** (seule source depuis la troisième passe). ⚠️ Le simulateur porte 25 clés : `temps.plafond_jour` et `projet.devises_mixtes` manquent — pour Opus.

**Troisième passe — 17/09, 23h45 — après [RELECTURE_5_TIERS_DIFF2](RELECTURE_5_TIERS_DIFF2_2026-09-17.md).** ⚠️ Le fichier du tiers et son message à Hamada ne disaient pas la même chose (6 de travers dans le fichier, 2 dans le message) ; **le fichier fait foi**. Neuf lignes reprises, et un changement de méthode : **les comptes ne s'écrivent plus qu'au registre §E**, partout ailleurs un renvoi.

| # | Repris |
|---|---|
| D-8 / X-3 / compte | `ref_type_unite` **technique** partout (17 + 7) ; registre §E créé, seule source ; livrable §1, §6.2, §6.3, §11, plan 5c, modèle métier §4 → renvois |
| D-1 résidu | trigger : le parent d'une unité interne est de la **même agence** |
| Résidu D-2 | NULL = **prospect**, jamais « hérite » ; `ClientStatusDerived` écrit `client` explicitement sur la branche désignée |
| Résidu O-2 | `CreatePrestation` en `signee` exige la permission `SignPrestation` — livrable §5.2 et machines §5 |
| « neuf murs » | **sept**, nommés |
| D-9 résidu | `cjm_devise_code` (défaut = devise de vente ; si différente, marge « — » sous `aucune_conversion`) ; `projet.devise_defaut_code` NULL, valeur proposée sans calcul (US5) |
| T-2 résidu | **amendement ADR-005** : la forme DB de M-15 = tables (NOT NULL, pas de colonne convertie) **+ surface de lecture** (agrégats exposés par des vues groupées par devise). P3 n'est pas rouvert |
| X-4 | plan 5c : renvoi |

**Quatrième passe — 18/09, 00h15 — après [RELECTURE_5_TIERS_DIFF3](RELECTURE_5_TIERS_DIFF3_2026-09-17.md) (GPT) et le tableau de Grok.** D-2 : la ligne `contact` disait encore « hérite » → NULL = prospect. D-9 : `devise_defaut_code` **dans la table** projet ; `cjm_devise_code` **dans le trigger M-14** (Grok et GPT l'ont vu tous les deux) ; `snapshot_marge` porte une devise par montant, marge NULL si elles diffèrent. T-2 : le livrable §9 **nomme les vues** et le rôle SQL d'agrégation sans SELECT sur les tables — la forme DB de l'amendement est dans le livrable, R-1 se réduit au code qui contourne. Comptes : « 32 » retiré du titre de la carte, « sept » retiré, brief exécutant sans « 59 ». ⚠️ **Portée de la règle §E écrite** : « 15 murs » est une décision, pas un compte — GPT l'appliquait aux quinze, ce qui n'a pas de sens.

**Cinquième passe — 18/09, 00h45 — après [RELECTURE_5_TIERS_DIFF4](RELECTURE_5_TIERS_DIFF4_2026-09-17.md) (GPT) et Grok.** T-2 : CHECK « montant présent ⇔ devise présente » sur `pretentions_*` et `budget_*` ; marge exprimée dans `ca_devise_code` ; ADR-005 aligné (une devise par montant, plus « unique »). Comptes : le test `count(*) = 59` du brief exécutant (il était à la fin de la ligne 49, mon grep l'avait manqué) et le « 32 » de la ligne 5c du plan → renvois §E. **Rien d'autre ne reste.**

---

## 1. ⛔ Ce qui change une table — 4 constats

| # | Constat | Preuve | Source contredite | ⭐ Tranché |
|---|---|---|---|---|
| D-1 | **Le périmètre interne n'a pas de table.** `perimetre.type_code ∈ {agence, pole, equipe, global}` pointe `unite_id → unite_organisation`, qui est l'arbre **du client** (§3.2). Il n'existe aucun objet « pôle / équipe interne ». Et `agence.perimetre_id` ↔ `perimetre.agence_id` est circulaire. §11 dit « les 8 sont là » : le n° 1 (Périmètre) n'y est qu'en nom. | §6.1, §7, §11 | DEC-17, BM-12 « agences internes ≠ hiérarchie client », audit §2.3 | **G6 donne la réponse** : Avaliance est une `societe` de rôle `interne` — ses pôles et équipes sont **ses** `unite_organisation`. `perimetre.unite_id` doit référencer une unité de la société interne (trigger : `societe.role interne`). `agence` devient une `unite_organisation` de type `agence` de cette société — ou garde sa table et `perimetre.agence_id` suffit ; on **retire** `agence.perimetre_id`. Une seule hiérarchie interne, pas deux. |
| D-2 | **La propagation du statut client est incalculable.** POL `societe.passage_client.propagation` (défaut : « branche contractante **+ contacts du service** ») — mais `statut_commercial_code` n'existe que sur `societe`. Ni `unite_organisation` ni `contact` ne portent de statut. | §3.1 vs §3.2, §3.3 | BM-15, CdC II.F, registre §C | Ajouter `statut_commercial_code` sur `unite_organisation` **et** `contact` (nullable ; NULL = hérite du parent). `ClientStatusDerived` écrit la branche et les contacts que la politique désigne. Sans ça, la clé sort du registre — et le CdC II.F tombe. |
| D-3 | **Deux vérités pour « client »**. `societe_role` accepte `client` et `prospect` (registre §B : `ref_role_societe` = prospect, client, fournisseur, interne) **et** `societe.statut_commercial_code` porte prospect / client. Le simulateur a fait les deux (`roles.push("client")` + `statut="client"`), preuve qu'un exécutant divergera. | §3.1 vs registre §B | BM-11, BM-15, machines §7 « rôles : un ensemble, pas un état » | `ref_role_societe` = **fournisseur · interne** seulement. Prospect / client = `statut_commercial_code`, une colonne, un cycle (machines §7). Patch registre §B + livrable §3.1. |
| D-4 | **Une ligne de temps fausse est immortelle.** `temps` : pas de DELETE (M-8, ADR-004 la nomme), **pas d'`archive_le`** (absent du tableau §5.3), `quantite CHECK > 0` (pas de contre-passation), `ajustement` réservé à l'après-clôture. Une saisie erronée avant clôture ne peut être ni effacée, ni annulée, ni compensée. Idem `absence`. | §5.3, §5.4 | M-8 (« archivage, pas suppression »), F34 | `archive_le` + `archive_par_compte_id` sur `temps` et `absence` — l'annulation d'une saisie est un archivage tracé (`TimesheetCancelled`). Le CA produit lit `archive_le IS NULL`. Pas de quantité négative : une contre-passation est une ligne qu'on relit mal. |

## 2. ⚠️ Écarts à sa propre règle — 4 constats

| # | Constat | Preuve | ⭐ Tranché |
|---|---|---|---|
| D-5 | **NOT NULL sous politique.** §2.3 pose la règle : un CHECK qu'une politique peut relâcher est « appliqué par la commande, pas en base ». Puis `projet.contact_id NOT NULL` (POL `projet.contact` : facultatif possible) et `qualification.besoin_id NOT NULL` (POL `qualification.besoin_obligatoire` : non possible) la violent. Changer ces politiques exigerait un `ALTER TABLE`. | §5.1, §4.3 vs §2.3, ADR-005 | Les deux colonnes passent **NULL en base**, la garde vit dans la commande. Règle écrite au §0 : *toute contrainte gouvernée par une politique est nullable en base*. |
| D-6 | **Un index qui dépend d'une politique.** `positionnement_actif_unique` implémente `positionnement.unicite = actifs`. Passer à `aucune` ou `historique` = DROP INDEX / autre index = migration. Le registre le sait (« appliqué par la commande, et par l'index si actifs ») — donc une politique **à deux vitesses**, contraire à ADR-005 « lue à l'exécution, sans code ». | §4.2, registre §C | L'unicité est **une garde de commande** qui lit la politique. L'index unique partiel **disparaît** ; on garde un index simple `(besoin_id, personne_id)`. Si Ahmed veut la garantie DB, alors c'est un mur M-16 et `aucune`/`historique` sortent du registre — c'est l'un ou l'autre. Je choisis la commande : P3 a fixé 15 murs. |
| D-7 | **Deux patrons pour « un porteur »**. `action` : six FK nullables + CHECK somme = 1 (M-9, vraies FK). `document` : `porteur_type` + `porteur_id` **sans FK** — un document peut pointer vers un id qui n'existe pas, exactement l'orphelin que M-8 veut empêcher. | §2.4 vs §8.1 | `document` prend le patron de `action` : cinq FK nullables (`personne_id`, `profil_candidat_id`, `profil_ressource_id`, `projet_id`, `societe_id`) + CHECK somme = 1. `evenement_metier` reste polymorphe (ADR-004 l'assume : c'est un journal, pas une relation). |
| D-8 | **Le compte que signe Ahmed est faux.** « 27 tables » : la ligne 24 en groupe 4, `permission` et `perimetre` (§7) n'apparaissent pas dans la carte → **32 tables, `politique` comprise** (27 lignes − 1 groupée + 4 + `permission` + `perimetre`), **+ `reprise_boond` = 33**. « 16 `ref_*` » : §6.3 en liste 16 **+ 8 techniques = 24**. Le plan, le commit et le titre répètent 27 / 16. | §1 vs §7, §6.3 | Carte corrigée : une ligne par table, compte vrai (**32 + reprise_boond + 24 ref**). Ce qu'on valide doit être ce qu'on compte. *Corrigé après la troisième relecture : ma première version comptait `politique` deux fois.* |

## 3. ⚠️ Petits trous — à corriger en passant, sans décision

| # | Où | Trou |
|---|---|---|
| P-1 | §4.1, §2.2, §2.3, §4.2 | `etat_categorie` (colonne redondante maintenue par trigger, §4.2) n'est listée que sur `projet` et `prestation` ; le texte dit « toutes les tables à état ». Ajouter à `besoin`, `profil_candidat`, `profil_ressource`, `positionnement`. |
| P-2 | §4.1 | Trigger M-12 cité pour `besoin.contact_id`, pas pour `besoin.unite_organisation_id` — même règle, même société. |
| P-3 | §5.2 | `prestation.devise_code` et `projet.devise_code` sans contrainte de cohérence : un projet EUR avec une prestation MAD ne viole rien. Un CHECK d'égalité (trigger) ou une décision écrite « la devise est celle de la prestation, le projet n'en a pas ». Je prends la seconde : le projet ne porte pas d'économie (ADR-003), donc pas de devise. |
| P-4 | §7 | `compte_surcharge.sens ∈ {autorise, restreint}` — F28 et le modèle métier ne parlent que de **surcharge restrictive**. `autorise` est une extension non sourcée : la retirer, ou l'ajouter au registre comme option de `droits.surcharge_restrictive`. Je retire. |
| P-5 | §4.2 | `motif_retrait_code` existe pour `retire` ; rien pour `refuse_client` alors que machines §4 exige un motif. Le motif vit dans `evenement_metier.motif` pour les deux — écrire la règle : **les motifs de transition sont dans l'événement, jamais en colonne**, et retirer `motif_retrait_code`. Une seule place. |
| P-6 | §5.3 | Pas d'UNIQUE `(prestation_id, jour)` ni de plafond par jour : deux lignes de 0,6 le même jour = 1,2 jour sans refus. Plafond = politique (`capacite.jour_ouvre`), garde de commande, pas CHECK. À écrire. |
| P-7 | §6.2 | `politique.valeur TEXT` porte aussi des listes (`doublon.personne.cles`). `JSONB` évite un parseur maison. |

## 3b. Troisième relecture (modèle tiers, 17/09 soir) — ce qu'elle a trouvé et ce qu'elle n'a pas fait

Le tiers a lu les 9 fichiers, contesté 5 affirmations, écrit **aucun** fichier et **n'a pas** passé D-1 → D-8 / P-1 → P-7 un par un comme demandé. Donc D-1, D-2, D-4, D-6, D-7 et les P restent **vérifiés par une seule relecture**.

| # | Sa contestation | Vérifié par Brain | ⭐ Tranché |
|---|---|---|---|
| T-1 | **F3 ≠ G4.** F3 = 3B, précision d'Ahmed : « il reste en staffing jusqu'à ce que **tous** les postes visés soient pourvus ». G4-C : `pourvu` se déclare dès **une** prestation signée. G4 écrit « F3 reste vrai » — c'est faux : G4 **assouplit** F3. | ✅ confirmé — `FEUILLE_F1-F36` 3B vs `FEUILLE_G` G4 | C'est une bifurcation : `besoin.pourvu.garde_minimale` gagne une option **`tous_les_postes_signes`** (compte des personnes signées ≥ `nb_postes_vises`). Le motif de G4-C (S4 : Sara 60 %+40 % = 1 personne pour 2 postes → jamais pourvu sous « tous ») reste écrit. **Tranché par Brain** (Hamada, 17/09 soir : « c'est toi qui tranches ») : défaut = **`tous_les_postes_signes`**, parce que F3 est signé et qu'une délégation ne réécrit pas une signature ; un poste = une **prestation** `engage` (S4 est canon : Sara = 2 postes). Écrit dans registre §C, machines §1, feuille G4, modèle métier §3, brief Opus. |
| T-2 | **M-14 et M-15 ne sont pas des contraintes DB.** M-14 « colonnes propres, jamais recalculées » et M-15 « vues groupées » n'empêchent aucune commande de réécrire un `tjm_vendu` ni d'additionner deux devises. | ✅ confirmé pour **M-14** ; ⚠️ partiel pour **M-15** | **M-14** : trigger `BEFORE UPDATE` sur `prestation` — `tjm_vendu`, `cjm_contrat`, `devise_code`, `jours_vendus`, `frais_*` **immuables dès la catégorie `engage`** (avant signature, une prévisionnelle se corrige). Devient une vraie contrainte, même forme que M-4. **M-15** : sa forme physique est **l'absence de colonne « montant converti »** — même patron que M-5, que le livrable accepte déjà comme mur. Le §9 le dit explicitement ; « vues groupées » n'était que la conséquence. |
| T-3 | **Le plan lui-même annonce « les 15 murs à l'essai »** (ligne 5b+), pas seulement l'écran. | ✅ confirmé | Ligne 5b+ corrigée par Opus avec le simulateur (brief §7). |
| T-4 | **Le brief Opus proposait `tjm: "[TARIF]"`** — une chaîne dans un `NUMERIC(14,2)`, et `t*p.tjm` casse. | ✅ confirmé — **erreur de Brain** | Brief §3 E-8 réécrit : valeur numérique 1, affichage `[TARIF]` par convention d'écran. |
| T-5 | **D-8 compte `politique` deux fois.** | ✅ confirmé — erreur de Brain | D-8 réécrit : 32 tables `politique` comprise + `reprise_boond` + 24 ref. |
| — | « Le modèle n'est pas signable » ; `client` en rôle et en statut ; `contact_id NOT NULL` sous politique | confirmation de D-3 et D-5, rien de neuf | — |

## 4. ✅ Ce qui tient — pour ne pas le casser en corrigeant

| Point | Preuve |
|---|---|
| Les 15 murs ont chacun une forme physique, et 8 sont des triggers ou droits SQL — pas des CHECK | §9 |
| M-1 est structurel : `prestation`, `temps`, `absence` n'ont aucune colonne candidat | §5.2–5.4, ADR-002 |
| G1 par `positionnement.personne_id` dénormalisé, immuable par trigger | §4.2 |
| G4 `nb_postes_vises ≥ 1`, G6 rôle `interne`, G8 sans objet Contrat, G9 période en trigger, G11 une colonne d'état, G12 `archive_le` transverse, G13 `reprise_boond` hors métier | §4.1, §3.1, §5.3, §5.2, §0, §8.3 |
| P1 mono-tenant : aucun `tenant_id` | §0 |
| Les états en `ref_*` à catégorie fermée, CHECK sur la catégorie, `systeme` protégé | §6.3, ADR-005 |
| `politique` en table, lue à l'exécution, `valeur_defaut` = 17/09, `hors_v1` | §6.2 |
| `evenement_metier.liens.politiques` : chaque fait porte la règle sous laquelle il s'est produit | §8.2 |
| Conventions §0 justes : UUID, `TIMESTAMPTZ` partout, `TEXT` sans longueur, montant + devise, `code_postal` textuel | §0, §2.1 |
| Les corrections BM-58 de la SPEC (adresse, code postal, téléphone) sont reprises | §2.1 |
| `absence` sans lien à `prestation` (F25) ; `contact` sans lien à `personne` (F22) | §5.4, §3.3 |
| `document` hors base, chemin + sha256 | §2.4 |
| Les 12 hors-V1 sont nommés, pas modélisés | §1 |

## 5. Ce que je recommande

| Ordre | Geste | Qui |
|---|---|---|
| 1 | Patcher le livrable 5 sur D-1 → D-8 et P-1 → P-7 selon les colonnes « tranché » ci-dessus ; patcher registre §B (D-3) | Brain · Fable (les décisions sont prises, le patch est court) |
| 2 | Corriger « 27 tables / 16 référentiels » dans le plan, le titre, la ligne 5 | idem |
| 3 | Relire le canvas 5b contre le livrable patché — dernier morceau de 5c | Fable |
| 4 | Puis la porte : `VALIDATION_MODELE_V1_<date>.md` d'Ahmed | Ahmed |

⛔ D-1, D-2, D-3 sont du **métier autant que de la modélisation** (qui est « client », jusqu'où, et ce qu'est un pôle interne). Je les ai tranchés parce qu'Ahmed a délégué G1–G15 ; il les revoit à la porte, comme le reste.
