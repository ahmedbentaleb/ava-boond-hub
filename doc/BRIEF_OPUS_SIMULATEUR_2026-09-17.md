# Brief Opus — corriger le simulateur métier — 17 septembre 2026

**Mot d'Hamada : « corrige tout ».** Ce brief est le périmètre exact. Fichier : `_ops/ava-simulateur-metier.html` (1 121 lignes, tout en mémoire, aucune base). Constats d'origine : [RELECTURE_5b_SIMULATEUR_2026-09-17.md](RELECTURE_5b_SIMULATEUR_2026-09-17.md).

## ⛔ Ce que tu ne fais pas

| | |
|---|---|
| ⛔ | Toucher au canon : `REGISTRE_POLITIQUES_v1`, `MACHINES_ETAT_V1`, `MODELE_DONNEES`, ADR, feuilles F/G. Si le sim et le canon se contredisent, **le canon gagne** ; si le canon est muet, tu notes la question dans la relecture, tu ne tranches pas. |
| ⛔ | Coder le produit. Le simulateur reste un artefact pédagogique en mémoire. |
| ⛔ | **Republier l'artefact** (`claude.ai/artifact/H8yAb1Cbw4wdL9V1Jama1Y`) sans le mot d'Hamada — publier = déployer. Tu corriges le fichier, tu commites, tu demandes. |
| ⛔ | Ajouter une politique, une option ou un mur qui n'est pas au registre. Une option non implémentable **sort de la liste** avec la mention « hors banc », elle ne reste pas décorative. |
| ⛔ | Un `if` métier sans clé de politique. Une comparaison d'état sur le **code** (`"signee"`, `"ouvert"`) au lieu de `categorie()`. |

## Les trois arbitrages du soir — le sim doit les suivre

| # | Tranché (Fable, 17/09 soir) | Effet dans le sim |
|---|---|---|
| C-1 | `positionnement.cv_partage_obligatoire` défaut **oui** | déjà le cas — ne rien changer |
| C-2 | `prestation.surcharge.mode = refus` **reste une option** ; sous le défaut, jamais de refus | déjà le cas — ne rien changer |
| C-3 | la garde de surcharge lit la catégorie **`engage` seule** ; le prévisionnel s'affiche distinctement, ne déclenche rien | → E-2 |

## 1. S-1 — Les 10 murs cannés deviennent réels

Aujourd'hui M-2, 3, 4, 5, 6, 7, 8, 9, 14, 15 renvoient un `KO(...)` rédigé sans toucher au monde. L'écran dit « chaque bouton tente vraiment l'opération ». Il doit devenir vrai.

**Moyen :** une couche « base » minimale dans le sim — `db.insert(table, ligne)`, `db.update(table, id, patch)`, `db.delete(table, id)`, `db.agrege(lignes, champ)` — qui porte les contraintes physiques du livrable 5 §9. **Toutes** les commandes passent par elle (pas seulement le banc). Chaque bouton du banc appelle la couche avec une vraie tentative, et c'est **elle** qui refuse, avec le nom du mur.

| Mur | Tentative réelle | Ce que `db` refuse |
|---|---|---|
| M-2 | `db.insert("pos", {pc: X, pr: Y})` puis `{pc:null, pr:null}` | CHECK XOR : `(pc==null) !== (pr==null)` |
| M-3 | `db.insert("pr", {personne: <déjà ressource>})` | UNIQUE(personne) sur `pc` et `pr` |
| M-4 | `db.update("prestation", id, {pr: <autre>})` | trigger : `pr` immuable |
| M-5 | `db.insert("projet", {…, pr: X})` | colonne inconnue `pr` sur `projet` — la couche connaît les colonnes de chaque table |
| M-6 | `db.update("snap", id, {ca: 0})` | table en INSERT/SELECT seulement |
| M-7 | `db.update("ev", …)` et `db.delete("ev", …)` | idem |
| M-8 | `db.delete("societe", id)` | aucun DELETE sur les objets historiques — « archivez » |
| M-9 | `db.insert("action", {societe: A, projet: P})` puis `{}` | CHECK : exactement une FK non nulle (ajouter la table `action` au monde, vide) |
| M-14 | `db.update("pr", id, {tjm: 999})` **passe**, puis on relit la prestation close : inchangée. Le banc affiche « la fiche a changé, la mission non » — c'est un **OK** qui prouve l'invariant, pas un refus | — |
| M-15 | `db.agrege([{montant:1, devise:"EUR"}, {montant:1, devise:"MAD"}], "montant")` | refus : devises mélangées, pas de taux |
| M-10 | rendre le refus **M-10** : le banc tente `db.insert("temps", {prestation: P, pr: <autre ressource>})` | trigger d'égalité `temps.pr = prestation.pr` |
| M-1, M-11, M-12, M-13 | déjà réels — vérifier qu'ils passent par `db` | — |

Phrase de l'écran inchangée : elle devient vraie.

## 2. S-2, S-3, E-7 — `POL_DEF` aligné sur le registre §C

Copier-coller du registre : **clés, options, ordre, défaut, source**. Corrections précises :

| Clé | Options exactes (défaut en premier) |
|---|---|
| `besoin.staffing.declencheur` | premier_positionnement · commande_prise_en_charge · retour_client_retenu |
| `besoin.pourvu.mode` | manuel_avec_garde · auto_par_prestation_signee · auto_par_personne_signee |
| `besoin.pourvu.garde_minimale` | **ajouter** : tous_les_postes_signes · une_prestation_signee · aucune — c'est elle que `DeclareNeedFilled` lit (la source « besoin.pourvu.garde » n'existe pas). **Défaut `tous_les_postes_signes`** (T-1, F3) : `count(prestations engage rattachées au besoin) ≥ nb_postes_vises` — **compter les prestations, pas les personnes** (S4). `personnesSignees()` devient `prestationsSignees()` ; la pastille montre *n prestations / m postes* et, en petit, les personnes distinctes. Le monde initial (ALPHA : 2 postes, 1 signée) est donc **refusé** sous le défaut — c'est l'exemple du tableau de bord, il devient juste |
| `positionnement.unicite` | actifs · aucune · historique |
| `projet.cloture.garde` | prestations_closes · cascade_cloture_prestations |
| `ressource.etat.mode` | manuel · derive_des_prestations |
| `temps.periode` | dates_prestation · dates_prestation_et_mois_ouvert — **« libre » disparaît** (G9 l'a rejetée). `mois_ouvert` est hors V1 : mention « hors banc, sans effet » dans le texte de la ligne |
| `societe.retour_prospect` | manuel · auto_fin_dernier_contrat · auto_apres_delai — les deux auto : « hors banc » |
| `candidat.conversion.acteur` | groupe_rh · groupe_rh_ou_rr · tout_habilite |
| `doublon.societe.mode` | **ajouter** : avertir · bloquer · ignorer — `CreateCompany` lit celle-ci, plus `doublon.personne.mode` (E-7) |
| `prestation.surcharge.seuil_pct` | garder la liste 80 · 100 · 120 (acceptable pour un banc) |

Compte final attendu : **24 clés** (22 + `garde_minimale` + `doublon.societe.mode`). Mettre ce chiffre dans le titre du commit.

## 3. E-1 → E-8 — Huit corrections de comportement

| # | Commande | Correction |
|---|---|---|
| E-1 | `CreatePrestation` avec état « signée » | factoriser `effetsSignature(p)` (passage client G8, pourvu auto, événement `PrestationSigned`) — appelé par `SignPrestation` **et** par `CreatePrestation` quand l'état initial est `engage`. Une prestation `engage` produit les mêmes effets quel que soit le chemin |
| E-2 | `chargeJour` | deux sommes : `engage` et `previsionnel`, **distinguées**. La garde de surcharge (alerte / refus) lit **`engage` seule** (C-3). L'écran Plan de charge affiche les deux couleurs comme aujourd'hui. Le message d'alerte dit « n % engagés » |
| E-3 | `RecordClientDecision` en `automatique_au_retenu` | la création automatique passe par **la même garde** que `CreateProjectFromNeed` (G1 sur la personne, `projet.contact`, `besoin.projets_max`). Si la garde refuse : le retenu **est enregistré**, le projet **n'est pas créé**, le message dit pourquoi — « jamais silencieux : l'événement le dit » (registre) |
| E-4 | `CloseProject` en cascade | snapshot des `engage` écrit avec la **vraie somme des temps** (réutiliser `ClosePrestation`) ; les `previsionnel` passent `annule` avec un événement `PrestationCancelled` chacun, et le message le dit |
| E-5 | `WithdrawPositioning` | `droit()` en tête ; autorisé depuis `propose` et `presente` seulement ; motif ∈ {desistement, no_go_interne, autre} (registre `ref_motif_retrait`) — demander le motif par un petit choix dans l'écran |
| E-6 | Besoin | `SuspendNeed` : depuis `a_pourvoir`/`en_recherche`/`pourvu`, **motif obligatoire**, mémorise l'état d'origine dans l'événement ; `ResumeNeed` : vers l'état d'origine ; `CloseNeed` : depuis tout sauf `ferme`, motif ; `ReopenNeed` : depuis `ferme` vers `a_pourvoir`, ou `en_recherche` s'il a des positionnements actifs. Boutons sur l'écran Besoins selon l'état. Ajouter aux perms IA / Staffing selon machines §1 |
| E-7 | `CreateCompany` | lit `doublon.societe.mode` (§2) |
| E-8 | `SignPrestation` | garde : `tjm_vendu`, `jours_vendus`, `taux_occupation` renseignés (**numériques > 0**, comme le livrable §5.2 : `NUMERIC(14,2)` — jamais une chaîne). « Aucun euro certifié » reste vrai autrement : le monde initial porte `tjm: 1` et `jours: 120`, et **l'écran affiche `[TARIF]` partout où le TJM vaut 1** (convention du banc, écrite dans la note de l'écran Prestation). Le CA du snapshot est calculé mais affiché « [CA] ». Le message de refus dit : « saisissez un TJM, même fictif : le banc ne certifie aucun euro ». *Corrigé le 17/09 après la troisième relecture : la première version proposait une chaîne.* |

## 4. Les 7 options sans effet — implémenter ou sortir

| Clé · option | Décision |
|---|---|
| `besoin.staffing.declencheur = commande_prise_en_charge` | **implémenter** : commande `TakeNeedInCharge` (Staffing), bouton visible seulement sous cette valeur |
| `besoin.staffing.declencheur = retour_client_retenu` | **implémenter** : `RecordClientDecision(retenu)` passe le besoin `a_pourvoir → en_recherche` |
| `ressource.etat.mode = derive_des_prestations` | **implémenter** : l'état affiché est `en_mission` si une prestation `engage` couvre la date du jour du monde, sinon `disponible` ; `sorti` reste manuel ; le bouton `SetResourceState` se grise pour les deux premiers |
| `societe.passage_client.declencheur = creation_projet` | **implémenter** dans `CreateProject` et `CreateProjectFromNeed` via `effetsPassageClient(societe)` factorisé |
| `positionnement.sur_besoin_inactif = alerte` | **implémenter** : le positionnement passe, le message porte l'alerte, l'événement aussi |
| `candidat.conversion.acteur` | **implémenter** : `groupe_rh` → rôle `rh` seul ; `groupe_rh_ou_rr` → `rh` ou `rr` ; `tout_habilite` → quiconque porte la permission. Donner la permission `ConvertCandidateToResource` à `rr` et `staffing` dans `ROLES` pour que la différence se voie |
| `societe.retour_prospect` auto ×2 · `temps.periode = …mois_ouvert` · `droits.surcharge_restrictive` | **hors banc** : garder la ligne (le registre la porte) avec le texte « hors banc — aucun effet ici », grisée |

## 5. Trois comparaisons sur le code → `categorie()`

`positionner` : `b.etat==="ouvert"` → `categorie(b.etat)==="a_pourvoir"` · `chargeJour` : `p.etat==="signee"` → catégorie · `personnesSignees` : `signee`/`cloturee` → `engage`/`clos`.

## 6. Comment tu vérifies

| Scénario | Résultat attendu |
|---|---|
| Banc des murs, les 15 boutons | 14 refus **venant de `db`**, nommant le mur ; M-14 = un OK qui montre la mission inchangée |
| Besoin ALPHA, 2 postes, 1 signée → « Déclarer pourvu » | refusé sous le défaut (« 1 prestation signée sur 2 postes visés ») ; passe sous `une_prestation_signee` avec l'avertissement ; passe à 2/2 après une seconde signature sur ce besoin |
| Politiques, chaque clé, chaque option | une manipulation qui change de résultat — ou la mention « hors banc » |
| S2 du cadrage : candidat positionné → retenu → converti → projet depuis besoin | passe sous le défaut ; refuse sous `positionnement_ressource_strict` |
| Prestation créée directement « signée » chez BETA (prospect) | BETA devient cliente (E-1) |
| Plan de charge : 60 % signé + 50 % prévisionnel le même jour | affiché 110 % distingués, **aucune** alerte (C-3) ; 60 % + 50 % signés → alerte |
| Suspendre → reprendre un besoin | revient à l'état d'origine (E-6) |
| `localStorage` d'une version précédente | `charger()` complète les clés manquantes et **retire** `temps.periode = libre` (remettre au défaut) |

## 7. Ce que tu rends

1. Le fichier corrigé, **sans** republier l'artefact.
2. `RELECTURE_5b_SIMULATEUR_2026-09-17.md` : chaque ligne S/E/option passée à ✅ avec la fonction qui la corrige — ou ⚠️ avec le motif si tu n'as pas pu.
3. Plan 17/09, ligne 5b+ : « corrigé le <date>, 24 politiques, 15 murs réels ».
4. Un commit :

```
Simulateur : 15 murs reels via couche db, 24 politiques alignees sur le registre, E-1..E-8 corriges
```

5. Ta réponse à Hamada : ligne 1 = ce qui a été vérifié (§6), puis ce que tu n'as pas pu faire, puis **une** question : republier ?
