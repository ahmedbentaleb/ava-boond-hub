# Relecture contradictoire — simulateur métier (5b+) — 17 septembre 2026

**Verdict d'origine : juste sur le métier, faux sur ce qu'il affirme.** → **Corrigé le 17/09 au soir** (Fable, brief Opus exécuté en entier) — voir §7. Les 25 commandes lisent les bons défauts et refusent aux bons endroits ; mais **10 des 15 « Tenter l'interdit » ne tentent rien**, une politique offre une option que G9 a rejetée, et 8 clés sur 22 s'écartent du registre.

Relu par Fable (5c), qui n'a pas écrit le simulateur. Périmètre : `_ops/ava-simulateur-metier.html` (1 121 lignes) contre `MACHINES_ETAT_V1`, `REGISTRE_POLITIQUES_v1`, `MODELE_METIER_CANONIQUE_v1` §3, `FEUILLE_G1-G15`. **Reste à relire pour 5c : le livrable 5 (27 tables) et le canvas 5b.**

Comptes annoncés : 8 rôles ✅ · 25 commandes ✅ · 22 politiques ✅ · **15 murs « à l'essai » ⛔ — 5 réels, 10 en texte canné.**

---

## 1. ⛔ Ce qui est faux — 3 constats

| # | Constat | Preuve | Ce que ça change |
|---|---|---|---|
| S-1 ✅ | **Le banc des murs ment sur 10/15.** M-2, M-3, M-4, M-5, M-6, M-7, M-8, M-9, M-14, M-15 : le bouton renvoie un `KO(...)` rédigé d'avance, sans toucher au monde. L'écran dit « chaque bouton tente vraiment l'opération ». | `MURS[]`, fonctions `f` qui commencent par `return KO(` | Ahmed croit voir la structure refuser ; il voit un message. M-3 pouvait être réel (la conversion le teste déjà). M-10 est testé mais le refus affiché est « DEC-17 · périmètre », pas M-10 — le sim écrit toujours `pr:p.pr`, M-10 est inviolable donc **intestable** ici. |
| S-2 ✅ | **`temps.periode` offre « libre »** — l'option C de G9, rejetée (« le cas rouge de BM-36 »). Le registre dit `dates_prestation · dates_prestation_et_mois_ouvert`. | `POL_DEF`, clé `temps.periode`, `o:["dates_prestation","libre"]` | Une option écartée redevient un réglage. C'est exactement ce que le registre interdit : « une bifurcation sans ligne = codée par accident ». |
| S-3 ✅ | **8 clés sur 22 s'écartent du registre** (options renommées ou manquantes) + une source cite une clé inexistante (`besoin.pourvu.garde` ; registre : `besoin.pourvu.garde_minimale`). | tableau §3 | Le registre est **le schéma de la configuration**. Un mock qui invente ses noms est un mock qu'on ne peut pas vérifier ligne à ligne. |

## 2. ⚠️ Écarts de comportement — 8, chacun une ligne à corriger

| # | Où | Le sim fait | Le canon dit | Gravité |
|---|---|---|---|---|
| E-1 ✅ | `CreatePrestation` avec état « signée » direct | ni `ClientStatusDerived`, ni pourvu auto — ces effets ne vivent que dans `SignPrestation` | G8 : **première prestation `engage`** ⇒ client, quel que soit le chemin | ⚠️ haute — G8 contournable |
| E-2 ✅ | `chargeJour` (surcharge) | additionne `signee` **et** `previsionnelle` | machines §5 : garde « sur l'occupation **`engage`** d'un jour commun » | ⚠️ haute — fausses alertes |
| E-3 ✅ | `RecordClientDecision` en mode `automatique_au_retenu` | crée le projet **sans** contact (`projet.contact` obligatoire ignoré), **sans** garde G1 (candidat non converti passe), sans `besoin.projets_max` | machines §6 : la garde et le contact s'appliquent « depuis besoin » | ⚠️ haute — un projet sans contact sous le défaut |
| E-4 ✅ | `CloseProject` en `cascade` | snapshot écrit avec `tempsSaisis:0` même si des temps existent ; les `previsionnelle` passent `annulee` | registre : cascade clôture les `engage` **avec snapshot** (le vrai) ; rien sur les prévisionnelles | ⚠️ moyenne — snapshot faux, et M-6 dit qu'il ne bougera plus |
| E-5 ✅ | `WithdrawPositioning` | **aucun `droit()`** — Support (0 permission) peut retirer ; retire aussi depuis `refuse_client` / `retire` | machines §4 : depuis `propose`, `presente` seulement ; acteurs IA, RH, Staffing | ⚠️ moyenne |
| E-6 ✅ | `SuspendNeed`, `CloseNeed` | sans garde d'état (on suspend un fermé), sans motif ; `ResumeNeed`, `ReopenNeed`, `TakeNeedInCharge` **absents** — un besoin suspendu est bloqué à vie | machines §1 : motif obligatoire, `ResumeNeed` vers l'état mémorisé, `ReopenNeed` | ⚠️ moyenne |
| E-7 ✅ | `CreateCompany` | lit `doublon.personne.mode` pour un homonyme de **société** | registre : `doublon.societe.mode` existe, clés `[nom_normalise, siren]` | ⚠️ basse — mauvaise clé |
| E-8 ✅ | `SignPrestation` | signe sans `tjm_vendu` ni `jours_vendus` ; le monde initial contient une prestation `signee` à TJM nul | machines §5 : garde « `tjm_vendu`, `jours_vendus`, `taux_occupation` renseignés » | ⚠️ basse — choix assumé « aucun euro », mais la garde disparaît sans le dire |

## 3. Les 22 politiques contre le registre

| Clé | Options du sim | Registre | Écart | L'option change-t-elle le comportement ? |
|---|---|---|---|---|
| `besoin.contact` | facultatif · obligatoire | idem | — | oui |
| `besoin.staffing.declencheur` | premier_positionnement · **commande_explicite** | premier_positionnement · commande_prise_en_charge · retour_client_retenu | renommée, 1 manquante | ⛔ non — aucune commande : le besoin reste « ouvert » à vie |
| `besoin.pourvu.mode` | manuel_avec_garde · **auto_premiere_signature** | manuel_avec_garde · auto_par_prestation_signee · auto_par_personne_signee | renommée, 1 manquante ; `garde_minimale` absente | oui |
| `positionnement.sur_besoin_inactif` | refus · alerte · libre | idem | — | ⚠️ « alerte » = « libre », aucune alerte émise |
| `positionnement.unicite` | actifs · aucune | actifs · aucune · historique | 1 manquante | oui |
| `positionnement.cv_partage_obligatoire` | oui · non | oui · non | — (voir C-1) | oui |
| `projet.creation_depuis_besoin` | explicite · automatique_au_retenu | idem | — | oui (mais E-3) |
| `projet.depuis_besoin.garde` | retenu_requis · libre | idem | — | oui |
| `projet.depuis_besoin.garde_profil` | personne_avec_ressource · positionnement_ressource_strict | idem | — | oui (ne vérifie pas « actif ») |
| `projet.contact` | obligatoire · facultatif | idem | — | oui |
| `projet.cloture.garde` | prestations_closes · **cascade** | prestations_closes · cascade_cloture_prestations | renommée | oui (mais E-4) |
| `prestation.surcharge.mode` | alerte · refus · silencieux | idem | — (voir C-2) | oui |
| `prestation.surcharge.seuil_pct` | 80 · 100 · 120 | entier, 100 | liste au lieu d'un entier — acceptable pour un banc | oui |
| `prestation.annulation.garde` | aucun_temps_saisi · libre | idem | — | oui |
| `ressource.etat.mode` | manuel · **derive_des_missions** | manuel · derive_des_prestations | renommée | ⛔ non — aucun effet |
| `temps.periode` | dates_prestation · **libre** | dates_prestation · dates_prestation_et_mois_ouvert | **option inventée, rejetée par G9** (S-2) | oui |
| `temps.correction_apres_cloture` | ajustement_trace · refus | idem | — | oui |
| `societe.passage_client.declencheur` | premiere_prestation_signee · creation_projet · manuel | idem | — | ⚠️ « creation_projet » sans effet |
| `societe.retour_prospect` | manuel · **auto_fin_contrat** | manuel · auto_fin_dernier_contrat · auto_apres_delai | renommée, 1 manquante | ⛔ non — aucun effet |
| `doublon.personne.mode` | avertir · bloquer · ignorer | idem | — (mais E-7) | oui |
| `candidat.conversion.acteur` | groupe_rh · tout_habilite | groupe_rh · groupe_rh_ou_rr · tout_habilite | 1 manquante | ⛔ non — `droit()` exige encore la permission que seul RH porte ; « tout_habilite » ne change rien |
| `droits.surcharge_restrictive` | restriction_gagne · union_gagne | idem | — | ⛔ non — pas de groupes dans le sim (annoncé en rouge, acceptable) |

**7 clés sur 22 ont au moins une option sans effet.** L'écran Politiques promet : « changez-en une, puis refaites la même manipulation : le produit se comporte autrement ». Pour un tiers des clés, c'est faux.

## 4. ✅ Ce que la relecture révèle sur le CANON lui-même — 3 contradictions, **tranchées le 17/09 au soir par Fable sur délégation d'Ahmed**

| # | Tranché | Où c'est écrit |
|---|---|---|
| C-1 | défaut **oui** — le registre faisait foi | `MACHINES_ETAT_V1.md` §4 |
| C-2 | `refus` **reste une option** ; « jamais de refus » vaut **sous le défaut** — bifurcation, pas mur (ADR-005, P3) | `MODELE_DONNEES_AVAMANAGER_V1.md` §prestation |
| C-3 | la garde lit **`engage` seul** (ATL-02) ; le prévisionnel s'affiche, ne déclenche pas | idem |

Le tableau d'origine, pour le motif :

Ce n'est pas le simulateur qui a tort ici : deux documents décidés se contredisent, et il a dû choisir.

| # | Sujet | Document A | Document B | Le sim a pris | À trancher |
|---|---|---|---|---|---|
| C-1 | Défaut de `positionnement.cv_partage_obligatoire` | REGISTRE §C : **oui** | MACHINES_ETAT §4 : **non** « (défaut, BM-23 : on déclare le partage puis la décision) » | oui | Une ligne dans l'un des deux. Le motif de BM-23 (« on déclare le partage puis la décision ») plaide pour **oui**. |
| C-2 | Option `refus` de `prestation.surcharge.mode` | REGISTRE §C : alerte · **refus** · silencieux | MODELE_DONNEES l.296 : « ⛔ **Jamais un refus automatique** (DEC-10) » | refus implémenté | Soit le mur du livrable 5 tombe (c'est une politique, ADR-005), soit l'option sort du registre. |
| C-3 | Base de la garde de surcharge | MACHINES_ETAT §5 : « occupation **`engage`** d'un jour commun » | MODELE_DONNEES l.296 : « catégories `previsionnel` et `engage` **distinguées** » (sans dire laquelle déclenche) | les deux additionnées | Écrire dans le livrable 5 : la garde lit `engage` ; le prévisionnel s'affiche, ne déclenche pas. |

## 5. ✅ Ce qui tient — pour ne pas le casser en corrigeant

| Point | Preuve |
|---|---|
| Les 22 défauts sont ceux du 17/09 | `POL_DEF[].d` = colonne « défaut » du registre, sans exception |
| Aucun `if` métier sans clé (hors E-7) | chaque `KO` de bifurcation cite sa clé ; chaque `OK` liste les réglages lus |
| Les transitions raisonnent sur la **catégorie** | `categorie()` puis comparaison sur `a_pourvoir`, `engage`, `terminal_positif`… — jamais sur le code, sauf `b.etat==="ouvert"` dans `positionner` et `p.etat==="signee"` dans `chargeJour`/`personnesSignees` (3 endroits à passer par `categorie()`) |
| G1 lu sur la **Personne** | `CreateProjectFromNeed` : `S.pr.some(r=>r.personne===p.personne)` |
| G3 : premier positionnement ⇒ staffing | `positionner()`, événement `NeedStateChanged` |
| G4 : pourvu manuel, refusé sans signature, compteur *n / m postes* | `DeclareNeedFilled` + `personnesSignees` + pastille |
| G7 : unicité parmi `propose`/`presente` seulement | `positionner()` |
| G8 : première signature ⇒ client, retour manuel | `SignPrestation`, `RequalifyCompany` |
| G11 : un seul cycle prestation, snapshot à la clôture, annulation refusée si temps saisi | `ClosePrestation`, `CancelPrestation` |
| F34 : ajustement après clôture tracé, snapshot intact | `RecordTimesheet`, `ajust:true`, `TimesheetAdjustedAfterClose` |
| M-1 réellement testé | `CreatePrestation({pc})` refuse |
| DEC-17 : bouton visible ≠ commande autorisée | `droit()` en tête de 23 commandes sur 25 (manquent `WithdrawPositioning`, `DeclareCVShared` partiel) |
| Monde initial cohérent | ALPHA cliente **et** une `signee` ; besoin 2 postes / 1 signé ; X1 retenu porté par une ressource ; charges d'avril sans recouvrement |

## 6. Ce que je recommande

| Ordre | Geste | Coût |
|---|---|---|
| 1 | Trancher C-1, C-2, C-3 dans le canon (une ligne chacune) — **avant** de corriger le sim, sinon il sera corrigé vers une cible mobile | 10 min, Fable |
| 2 | S-1 : soit rendre réels les 10 murs (M-3, M-4, M-6, M-7, M-9 se testent en 5 lignes chacun sur le monde en mémoire), soit **changer la phrase** de l'écran : « 5 murs à l'essai, 10 décrits » | 1 h, Opus |
| 3 | S-2, S-3, E-7 : aligner `POL_DEF` sur le registre — noms, options, clés. C'est du copier-coller du §C | 20 min, Opus |
| 4 | E-1 → E-6 : six corrections locales, une commande chacune | 1 h, Opus |
| 5 | Les 4 options sans effet (`staffing.declencheur`, `ressource.etat.mode`, `retour_prospect`, `conversion.acteur`) : implémenter ou **retirer de la liste** — un réglage qui ne règle rien contredit la promesse de l'écran | 30 min, Opus |

⛔ Aucun de ces gestes ne touche le livrable 5 ni le canon, **sauf** l'étape 1. Le simulateur reste un artefact pédagogique : le corriger n'est pas coder le produit.


---

## 7. ✅ Corrections appliquées — 17/09 au soir, fichier `ava-simulateur-metier.html` (1 286 lignes)

Vérifié en exécutant le §6 du brief hors navigateur (moteur seul, sans DOM) : **14 refus venant de `db`, M-14 = OK prouvant l'invariant**, S2 passe sous le défaut et refuse sous `positionnement_ressource_strict`, BETA devient cliente sur une prestation créée « signée », 60 % signé + 50 % prévisionnel = aucune alerte et 60 + 50 signés = alerte, suspendre → reprendre revient à l'état d'origine, `charger()` ramène toute valeur hors registre au défaut.

| Constat | État | Ce qui le corrige |
|---|---|---|
| S-1 — 10 murs cannés | ✅ | couche `db` (`insert` / `update` / `del` / `agrege`) portant `SCHEMA` : colonnes connues (M-5), XOR (M-2), UNIQUE (M-3), un porteur (M-9), FK vers `pr` seule (M-1), trigger `temps.pr = prestation.pr` (M-10), `immuable:["pr"]` (M-4), `appendOnly` sur `snap` (M-6) et `ev` (M-7), pas de DELETE sur `historique` (M-8), `agrege` par devise (M-15). **Toutes** les commandes passent par `db` ; `MURS[].f` appelle `db` dans `tente()`. M-6 a une prestation close en seed pour être tentable dès le chargement |
| S-2 — `temps.periode = libre` | ✅ | `POL_DEF` : `dates_prestation · dates_prestation_et_mois_ouvert`, la seconde marquée hors banc ; `charger()` remet au défaut une valeur hors registre |
| S-3 — 8 clés hors registre | ✅ | `POL_DEF` recopié du registre §C : clés, options, ordre, défaut, source. **25 clés** (les 24 du brief + `besoin.projets_max`, que E-3 exige et que le registre porte) |
| E-1 — signée directe sans effets | ✅ | `effetsSignature(p)` appelé par `SignPrestation` **et** `CreatePrestation` quand l'état initial est `signee` ; la garde de signature s'applique aux deux chemins |
| E-2 — surcharge sur prévisionnel | ✅ | `chargeJour()` rend `{engage, previsionnel}` ; la garde lit `engage` seule (C-3) ; le message dit « n % engagés » ; le plan de charge empile les deux couleurs |
| E-3 — auto au retenu sans garde | ✅ | `creerProjetDepuisBesoin(b, contact, titre, auto)` : une seule garde (G1 sur la personne, `projet.contact`, `besoin.projets_max`) pour le manuel et l'automatique ; refus → retenu enregistré, événement `ProjectAutoCreationRefused`, message explicite |
| E-4 — cascade avec snapshot faux | ✅ | `CloseProject` en cascade réutilise `cloturerPrestation()` (vraie somme des temps) ; les prévisionnelles passent `annulee` avec un `PrestationCancelled` chacune ; le message compte les deux |
| E-5 — retrait sans droit ni motif | ✅ | `droit("WithdrawPositioning")` en tête ; depuis `propose` / `presente` seulement ; motif ∈ {desistement, no_go_interne, autre} choisi dans un `<select>` par ligne |
| E-6 — besoin bloqué à vie | ✅ | `SuspendNeed` (motif obligatoire, `precedent` mémorisé), `ResumeNeed` (vers `precedent`), `CloseNeed` (motif), `ReopenNeed` (`a_pourvoir`, ou `en_recherche` s'il a des positionnements actifs) ; boutons selon la catégorie ; perms IA / Staffing selon machines §1 |
| E-7 — mauvaise clé de doublon | ✅ | `CreateCompany` lit `doublon.societe.mode` |
| E-8 — signature sans TJM | ✅ | `gardeSignature()` : TJM, jours, taux numériques > 0 ; seed `tjm: 1`, `jours: 120` ; `tjmAff()` affiche `[TARIF]` pour 1 ; CA du snapshot calculé, affiché `[CA]` ; refus : « saisissez un TJM, même fictif » |
| `besoin.staffing.declencheur = commande_prise_en_charge` | ✅ | `TakeNeedInCharge` (Staffing), bouton visible sous cette valeur seulement ; `positionner()` ne déplace plus le besoin sous ce réglage |
| `… = retour_client_retenu` | ✅ | `RecordClientDecision(retenu)` passe `a_pourvoir → en_recherche` |
| `ressource.etat.mode = derive_des_prestations` | ✅ | `etatRessource(r)` : `en_cours` si une `engage` couvre `S.aujourdhui`, sinon `intercontrat` ; `sorti` manuel ; `SetResourceState` refuse les deux premiers, options grisées |
| `societe.passage_client.declencheur = creation_projet` | ✅ | `effetsPassageClient(societe, declencheur)` appelé par `CreateProject`, `creerProjetDepuisBesoin` et `effetsSignature` |
| `positionnement.sur_besoin_inactif = alerte` | ✅ | le positionnement passe ; message et événement portent l'alerte |
| `candidat.conversion.acteur` | ✅ | `groupe_rh` → rh ; `groupe_rh_ou_rr` → rh, rr ; `tout_habilite` → quiconque porte la permission (donnée à rr et staffing, pas à eval) |
| `societe.retour_prospect` auto ×2 · `temps.periode` mois ouvert · `droits.surcharge_restrictive` | ✅ hors banc | options portées, libellées « — hors banc », ligne grisée, `SetPolicy` le dit dans son message |
| §5 — 3 comparaisons sur le code | ✅ | `positionner`, `chargeJour`, `prestationsSignees` (ex-`personnesSignees`) passent par `categorie()` — plus aucun `=== "signee"` ni `=== "ouvert"` métier dans le fichier |
| T-1 (troisième relecture) | ✅ | `besoin.pourvu.garde_minimale` défaut `tous_les_postes_signes` : `count(prestations engage) ≥ postes` ; la pastille montre *n / m postes* et le nombre de personnes à part ; ALPHA (2 postes, 1 signée) est **refusé** sous le défaut |

**Non fait, et pourquoi :** rien du brief. Un écart au brief : **25 clés au lieu de 24**, parce que E-3 demande la garde `besoin.projets_max` et qu'un `if` sans clé est interdit — la clé vient du registre, elle n'est pas inventée.

**Et en plus, hors brief (demande d'Hamada du même soir) :** trois apparences sur le même moteur — **Nuit** (graphite, argent, traits vifs par chemin, Bricolage Grotesque + Manrope + JetBrains Mono), **Clair** (même famille, fond clair), **Avaliance** (charte du site : violet porteur, vert dessous, Sora + IBM Plex Mono). Sélecteur en haut, préférence mémorisée. Aucune règle métier ne dépend de l'apparence.

⛔ **L'artefact n'a pas été republié** : `https://claude.ai/artifact/H8yAb1Cbw4wdL9V1Jama1Y` montre encore la version du 17/09 après-midi. Le fichier corrigé est `_ops/ava-simulateur-metier.html`.
