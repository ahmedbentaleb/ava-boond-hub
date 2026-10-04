**206 cas du registre exécutable rejoués : 203 conformes · 3 écarts · 0 non jouable** — 264 jeux (chaque scénario × chaque valeur servie de sa clé) · 74 sondes des règles §1 et des ⛔ hors lignes : 38 écarts.

> ⚠️ Numérotation : ce document garde les numéros de travail de son brouillon. Les constats rendus sont dans `CONSTATS.md` (V-179 → V-195), table de correspondance à la fin.


Les lignes écrites tiennent presque toutes ; ce qui casse est **ce que les lignes ne jouent pas** : la voie d'administration (SetPolicy), l'ensemble des valeurs réellement admises, les ⛔ en prose, et les scénarios trop pauvres pour voir l'implémentation.

| Mesure | Résultat |
|---|---|
| Lignes du §2 (mon lecteur) | 206 lignes · 56 clés · 96 scénarios · 140 couples (clé, valeur) |
| Verdicts | ✅ 203 · ⛔ 3 (`projet.contact = service_ou_societe`, l. 110/113/115) · ❓ 0 |
| Porte différentielle (§1.3) | 264 jeux · indiscernables hors alias : **aucun** · alias §3 retrouvé (`premiere_prestation_signee = premier_engagement_contractuel`) · `service_ou_societe` non mesurable (SetPolicy refuse) |
| Règle 1 — registre = `politique_valeur_servie` = `COMPORTEMENTS` = générateur | ✅ 287 = 287 = 287 ; 140 = 140 · ⛔ mais `valeurs_possibles` ≠ registre (1 valeur) et l'**admis** ≠ le **servi** (C1, C2) |
| Règle 2 — 10 clés absentes tirées au hasard | ✅ 13/13 SetPolicy → `refus GARDE « valeur non servie »` · ⛔ 25 clés liste sur 33 ne peuvent même pas reprendre leur défaut (C10) |
| Règles 4, 5 — hors domaine / hors bornes | ✅ 4/4 hors domaine, 6/6 hors bornes refusés · ⛔ `[]`, doublons, ordre inverse, tout nombre dans les bornes **admis** (C2) |
| Règle 6 — `taux_change`, `derogation_motif` dans DECLARATION | ✅ présents, écrits |
| Règle 7 — portes du banc qui exigent autre chose que le registre | ⛔ **13 portes** (P-355, P-354, P-125, P-259, P-276, P-133, P-227, P-234, P-245, P-248, P-249, P-264, P-286) |
| Remise au défaut finale | ✅ `valeur <> valeur_defaut` = 0 · `horloge_banc` vide · `git status` du clone vide |

**Date du jour.** Le serveur lit `aujourdhui(agence)` (023), qui prend `horloge_banc` d'abord : j'y ai posé 2026-10-15 (2026-11-01 pour S-RE4, 2026-10-03 pour S-TP4), en SQL, rôle postgres, le temps de chaque jeu ; vidée à la fin. Deux commandes l'ignorent (C6).

**Preuves** : `audits-independants/ava-audit-11/rapport/preuves/registre11/` — `00_monter_base.sh/.txt`, `03_comptes_audit.sql/.txt`, `registre_lu.mjs` (mon lecteur), `lib11.mjs`, `scenarios11.mjs` (les 96 scénarios), `rejoueur11.mjs`, `10_jeux.json` (264 jeux), `11_lignes.json` (206 verdicts), `12_indiscernables.json`, `13_rejoueur_sortie.txt`, `regle1_comparer.mjs` → `02_regle1.txt`, `04_cles_lues.txt`, `05_politique_commandes.txt`, `regpol_c.mjs` → `06_regpol_c.txt`, `07_listes_defaut_non_json.txt`, `sondes11.mjs` → `20_sondes.json`/`21_sondes_sortie.txt`, `sondes11b.mjs` → `22_sondes_b.json`/`23_sondes_b_sortie.txt`, `sonde_siren.mjs` → `24_sonde_siren.txt`, `portes_banc.mjs` → `30_portes_banc.txt`, `90_etat_final.txt`.

---

## CONSTATS CANDIDATS

### C1 ⛔ CRITIQUE — Une valeur servie est inatteignable par l'administrateur, et la porte du banc la déclare tenue

| | |
|---|---|
| **Fait mesuré** | `SetPolicy projet.contact = service_ou_societe` → `refus GARDE « valeur hors valeurs_possibles pour projet.contact »` (l. 110, 113, 115). La valeur est au registre (3 lignes), dans `politique_valeur_servie` et dans `COMPORTEMENTS`, mais `politique.valeurs_possibles` = `["obligatoire","facultatif","obligatoire_avant_engagement"]`. SetPolicy lit `valeurs_possibles` **avant** `politique_admise`. |
| **La porte grave l'écart** | P-355 (`registre_differentiel.test.ts` → `registre_moteur.ts:1023`, `poserPolitique`) pose chaque valeur par **`UPDATE politique` en SQL**, jamais par SetPolicy : le déclencheur `tg_valeur_servie` admet la valeur servie, les 3 lignes passent vertes. Le chemin que l'administrateur emprunte n'est joué par aucune ligne. |
| **Famille** | Deux gardes de valeurs pour une même politique : `valeurs_possibles` (écrite à la main, 003/018) et `politique_admise` (générée du registre). Règle 1 : « une valeur est servie si et seulement si elle a une ligne » — la seconde source la contredit. |
| **Étendue** | Mesurée sur les 56 clés : 1 valeur du registre absente de `valeurs_possibles` ; 0 valeur de `valeurs_possibles` sans ligne. Clés liste et nombre : `valeurs_possibles` NULL, la garde tombe sur la seule `politique_admise` (C2). |
| **Correction de construction** | SetPolicy ne juge **que** par `politique_admise` (une garde, générée) ; `valeurs_possibles` devient une sortie du générateur ou disparaît. La porte pose les politiques **par SetPolicy (ADM, HTTP)** — jamais en SQL. |
| **Porte qui énumère la famille** | Pour **chaque** couple (clé, valeur) de `politique_valeur_servie` : `SetPolicy` ADM → `ok`, puis retour au défaut → `ok`. 287 appels, zéro exception tolérée. |

### C2 ⛔ CRITIQUE — L'ensemble ADMIS déborde l'ensemble SERVI : des valeurs sans ligne retirent une garde

| | |
|---|---|
| **Fait mesuré** | `politique_admise` (023) : si la clé a un domaine, seul le domaine est vérifié ; si elle a des bornes, seules les bornes. Le servi n'est plus consulté. SetPolicy **accepte** : `[]` sur les 4 clés liste ; `["email","email"]`, `["nom","nom"]`… ; `["siren","nom_normalise"]` (ordre inverse) ; `["nom+prenom+societe"]`, `["cv"]`, `["telephone"]` ; `seuil_pct` = 50, 150, 300, `0100` ; `jour_ouvre` = 0.5, 2.0, `1.50`. |
| **Effets observés** | `candidat.complete.champs_requis = []` → `CompleteCandidate` **ok** sur un candidat sans civilité, ville ni e-mail (garde retirée). `doublon.societe.cles = []` + `bloquer` → la société ACME est recréée (garde retirée). `doublon.contact.cles = []` → l'e-mail reste vérifié (le code lit `[]` comme « e-mail ») : `[]` ne dit pas la même chose selon la clé. `["telephone"]` (contact, personne) + `bloquer` → même téléphone **accepté** : élément du domaine que le code n'implémente pas. `["cv"]` → `CompleteCandidate` refusé « champs requis manquants : cv » **alors que le CV est déposé** : garde insatisfiable. `seuil_pct = 150` indiscernable de `200` sur S-SU2, sans alias. |
| **Les portes gravent l'écart** | 8 portes **exigent** une valeur sans ligne (SetPolicy `ok` attendu) : P-133 et P-234 (`capacite.jour_ouvre = 1`, `= 2`), P-227 (`seuil_pct = 50`), P-245 (`["email"]`, `["nom+prenom+societe"]`), P-248 et P-264 (`["nom+prenom+naissance"]`), P-249 (`["localisation"]`, `["nom"]`), P-286 (`["nom+prenom+societe"]`). Liste : `30_portes_banc.txt` (11 occurrences). |
| **Famille** | Règle 1 (servi ⇔ une ligne) contre règles 4-5 (domaine, bornes) : le code a pris le domaine et les bornes comme **définition** du servi, au lieu d'une garde **en plus**. Pas de forme canonique (ordre, doublons, `0100`, `1.50`). |
| **Étendue** | 4 clés liste, 2 clés nombre (mesuré). Domaine : 2 éléments sans code (`telephone` pour contact et personne, `cv` pour la complétude). |
| **Correction de construction** | Décision BRAIN d'abord : (a) servi = lignes seulement, domaine et bornes = garde supplémentaire (intersection) ; ou (b) servi = domaine/bornes, et alors le registre écrit l'issue de **chaque** élément et de `[]`. Puis : forme canonique unique (liste triée sans doublon, nombre normalisé) avant toute garde ; tout élément de domaine a son code, ou sort du domaine. |
| **Porte** | Générer, pour chaque clé liste, `[]`, chaque singleton, chaque permutation et un doublon ; pour chaque clé nombre, min, max, milieu et une écriture non canonique — SetPolicy doit rendre exactement ce que le registre écrit, et chaque élément admis doit changer une issue jouée. |

### C3 ⛔ CRITIQUE — La garde minimale (D-65) se retire en passant un champ d'entrée

| | |
|---|---|
| **Fait mesuré** | S-PM3 (2 postes, 1 prestation engagée), `besoin.pourvu.mode = auto_par_personne_signee`, `DeclareNeedFilled { id, depuis_signature: "oui" }` → **ok, besoin `pourvu` à 1/2**. Sans le champ : refus GARDE (l. 91, conforme). Sous `manuel_avec_garde` : refus. D-65 : « la garde minimale s'applique à `DeclareNeedFilled` direct sous tous les modes ». |
| **Famille** | Un drapeau de cascade (posé par `SignPrestation` dans `effetsSignature`) est une **entrée publique** : `depuis_signature` est déclaré dans `DECLARATION.DeclareNeedFilled`, `besoin.ts` le lit dans `ctx.valeurs`. |
| **Étendue** | 1 drapeau exploitable mesuré (`depuis_signature`). Entrées posées par des cascades et aussi acceptées de HTTP : `RequalifyCompany.contact_id/besoin_id` (choisissent la branche de propagation — non mesuré comme nuisible). |
| **Correction de construction** | Le contexte de cascade vit dans `ctx` (posé par `executerDans`), jamais dans l'entrée ; `DECLARATION` ne déclare aucun champ réservé aux cascades. |
| **Porte** | Pour chaque couple de `CASCADES`, chaque champ que la mère passe à la fille, envoyé par HTTP sur la fille seule, ne change aucune garde (refus identique avec et sans). |

### C4 ⛔ CRITIQUE — Les ⛔ écrits en prose sous un scénario ne sont pas des lignes : rien ne les joue, 2 sur 2 sont faux, et 3 portes exigent le contraire

| | |
|---|---|
| **Fait mesuré** | **S-CA1** « ⛔ `ca_produit.base = temps_valides` sous `temps.validation = aucune` → SetPolicy refus GARDE » : SetPolicy **ok** ; et dans l'ordre inverse (par_dp → temps_valides → aucune), **ok** : le couple interdit est en place. **S-UT1 / D-66** « SetOwnTheme passe par la même garde de valeurs que SetPolicy : un thème non servi → refus GARDE » : `SetOwnTheme {"ui.mode":"clair"}` **ok** (seule `sombre` est servie) ; `{"ui.palette":"zz_a11"}` **ok**. |
| **Les portes gravent l'écart** | **P-354** (`decisions_0110.test.ts:93`) pose `temps.validation = aucune` puis `ca_produit.base = temps_valides` par SetPolicy et **exige ok**. **P-125** (`chemin.test.ts:590`) et **P-259** (`correctifs.test.ts:1119`) exigent `SetOwnTheme {"ui.mode":"clair"}` **ok**. |
| **Famille** | La grammaire du §0 n'a pas de forme pour une contrainte **entre politiques** ni pour une garde **d'une commande d'installation** : le générateur ne la voit pas, la porte différentielle non plus. |
| **Étendue** | ⛔ du §2 qui décrivent une issue de commande hors ligne : S-CA1, S-UT1 (2/2 mesurés faux). Les autres ⛔ (S-CH1, S-PM3, S-PCL1, S-SP4, D-62) sont couverts par une ligne. |
| **Correction de construction** | Le §0 gagne une forme jouable (ligne `SetPolicy` / `SetOwnTheme` avec scénario, ou table « contraintes entre clés » générée vers `politique_admise(clé, valeur, état)`). `SetOwnTheme` appelle `politique_admise` pour chaque clé `ui.*`. |
| **Porte** | Lint du registre : tout ⛔ de puce qui nomme un code de refus a une ligne ; puis la porte différentielle joue ces lignes. |

### C5 ⛔ MAJEURE — Des scénarios à un seul élément ne voient pas l'implémentation de l'issue qu'ils écrivent

| | |
|---|---|
| **Fait mesuré** | **S-PR1** (un contact par unité) : l. 136 conforme. Avec **deux** contacts dans U1 : seul le contact du projet passe `client`, l'autre contact de U1 reste NULL — l'issue écrit « contact.statut (**contacts de U1**) ». Le code (`crm.ts propagerPassageClient`) prend `c.id = contact du projet OR c.unite = unité du besoin`. **R10** (`service_ou_societe`, posée en SQL) : besoin **régie** + unité + sans contact → **ok** ; le registre : « contact obligatoire en régie ». S-PC3 (sans unité) ne peut pas le voir. |
| **Famille** | Une issue au pluriel ou une règle conditionnelle (« en régie ») jugée sur un scénario où le pluriel vaut un, où la condition ne discrimine pas. |
| **Étendue** | 2 mesurées (S-PR1, S-PC3). À énumérer par la porte ci-dessous. |
| **Correction de construction** | Code : la branche lit les contacts de l'unité contractante ; `service_ou_societe` lit `besoin.origine_code`. Registre : tout qualificatif pluriel a une fixture à ≥ 2 éléments ; toute règle conditionnelle a un scénario de chaque côté de la condition. |
| **Porte** | Lint du registre : qualificatif pluriel (« contacts de », « tous », « U1, U2 ») ⇒ scénario à ≥ 2 éléments ; puis rejouer. |

### C6 ⛔ MAJEURE — « Une seule horloge » (§0, V-167) : deux commandes du registre datent à l'horloge système

| | |
|---|---|
| **Fait mesuré** | Horloge de la base au 15/10/2026 : `RecordQualification` (S-QB1) écrit `qualification.date = 2026-10-04` ; `CancelPrestation` (S-RP2) écrit `prestation.date_annulation = 2026-10-04`. |
| **Famille** | Date métier écrite sans `aujourdhui(agence)`. |
| **Étendue** | `server/src` : `identite.ts:445` (`CURRENT_DATE`), `projet.ts:555` (`CURRENT_DATE`), `admin.ts:110` et `crm.ts:534` (`archive_le = now()`) ; `ArchiveCompany`/`ArchiveService` écrivent `aujourdhui()` dans un `timestamptz` (`2026-10-15 00:00:00+00`). |
| **Correction de construction** | Un seul accesseur de date du jour, au fuseau de l'agence de l'objet ; `CURRENT_DATE` et `now()` interdits pour une date métier. |
| **Porte** | grep de `server/src` et des fonctions SQL (zéro `CURRENT_DATE`/`now()` sur une colonne de date métier) + chaque commande qui date, jouée sous une `horloge_banc` ≠ date système. |

### C7 ⛔ CRITIQUE — La clé `[siren]` ne garde rien sur les sociétés créées par l'application

| | |
|---|---|
| **Fait mesuré** | `CreateCompany { nom, siren: "900031050" }` → ok, **`societe.siren` = NULL** ; seconde `CreateCompany` même SIREN, `bloquer`, `cles = [siren]` → **ok** (attendu refus, comme S-DS3). L. 7 n'est conforme que parce que la fixture pose le SIREN de « Durand » en SQL. |
| **Famille** | Une donnée lue par une garde de politique et jamais écrite par la commande qui la reçoit. |
| **Étendue** | `crm.ts CreateCompany` lit `siren` (doublon) mais l'`INSERT` ne l'écrit pas ; `UpdateCompany` ne le déclare pas. Les autres clés de doublon (e-mail, téléphone, naissance) sont écrites. |
| **Correction de construction** | Toute colonne comparée par une garde de doublon est écrite par la commande de création (dérivé de `DECLARATION`). |
| **Porte** | Pour chaque élément de domaine de `doublon.*.cles` : créer deux objets **par commandes** qui partagent cet élément → `bloquer` refuse la seconde. |

### C8 MAJEURE — `POLITIQUE_COMMANDES` réécrit à la main pour 2 clés ; une porte l'exige

`politiques.ts` remplace les commandes du registre (`UpdateNeed`) par **les 57 commandes** pour `droits.surcharge_restrictive` et `historique.tentatives_refusees` (`05_politique_commandes.txt`). Règle 1 : « `POLITIQUE_COMMANDES` se génère de ce fichier ; il ne s'écrit plus à la main ». P-276 (`audit3.test.ts:304`) exige `commandes_affectees` ∋ `CreateCompany`. **Famille** : sortie générée corrigée après coup. **Correction** : le registre écrit ces deux clés comme lues par toute commande (ligne ou déclaration), le générateur produit la liste. **Porte** : `POLITIQUE_COMMANDES` = sortie du générateur, octet pour octet.

### C9 MINEURE (banc) — La carte des politiques lues est commune à tous les bancs de la machine

`kernel.ts` : `CARTE_POLITIQUES = os.tmpdir()/ava-carte-politiques.jsonl`, écrite par **tout** serveur en `AVA_MODE=banc` (26,7 Mo, 418 936 lignes ce matin, mes jeux sur :4103 compris). Une porte qui la lit (D-42) mesure les bancs voisins. **Correction** : chemin dérivé du port ou de la base. **Porte** : deux serveurs de banc simultanés n'écrivent pas le même fichier.

### C10 MINEURE — 25 politiques liste sur 33 ne peuvent pas reprendre leur défaut par SetPolicy

Défauts non JSON (`[lun, mar, mer, jeu, ven]`, `ordre_declare`…) : SetPolicy → `refus GARDE « valeur incompatible avec le type list »` (`07_listes_defaut_non_json.txt`, `22_sondes_b.json`). Règle 2 : le défaut est la seule valeur servie — il doit au moins s'atteindre. **Correction** : défauts canoniques (JSON) ou type exact. **Porte** : pour chacune des 203 politiques, `SetPolicy` de son défaut → ok.

### C11 MAJEURE (cible BRAIN) — Le registre n'est pas exécutable sans interprétation

| Point | Mesure |
|---|---|
| Colonnes inexistantes | `societe.statut`, `contact.statut`, `unite_organisation.statut`, `*.etat`, `profil_candidat.etape`, `profil_candidat.note`, `snapshot_marge.ca`, `prestation_version.version` : aucune n'existe ; correspondance posée par moi (`lib11.mjs`, `CORRESPONDANCE`) — le banc a la sienne |
| Formes hors grammaire §0 | `écrit tentative_refusee (1 ligne)` ; `refus DROIT · écrit …` (le §0 dit « refus = rien écrit ») ; `inchangé snapshot_marge` (sans colonne) ; parenthèse à double sens : `(U1)` choisit une ligne, `(cat:client)` affirme une valeur ; `(la prestation ouverte, à la date de clôture du projet)` porte une seconde assertion (la date) |
| Scénario impossible | **S-PG3** : « unité postes, fte visé 1,0 » refusé par le déclencheur `besoin_couverture` — le banc (`registre_moteur.ts:698`) et moi avons dû retirer le fte |
| Scénario ambigu | **S-PJ3** « 1,3 j le même jour » : une saisie de 1,3 ou 0,8 + 0,5 ? ; **S-RE1** : état écrit de départ non dit (je l'ai pris `en_cours`) ; **S-PC3/PC4** « origine régie / appel d'offres » = `besoin.origine_code`, non nommé |
| « 56 clés lues » | `temps.mois_ouvert.grace_jours` est lue par `RecordTimesheet` (57ᵉ) ; `societe.retour_prospect.delai_mois` fait l'issue de S-RP3 ; D-62 lui donne des bornes 0..15 que rien ne sert (règle 2 : défaut seul) |
| Contre `SPEC_COMMANDES_L4.md` | l. 131 `TakeNeedInCharge` : « ETAT hors cycle · NeedTakenInCharge » — sous `premier_positionnement` la commande rend **ok sans rien écrire ni tracer** (l. 74) ; l. 195 `SetOwnTheme` : GARDE seulement si `non` (D-66 absent) ; §C-3 : pourvu automatique « selon garde_minimale » — le registre le fait dépendre de `besoin.pourvu.mode` |
| Contre `REGISTRE_POLITIQUES_v1.md` §C | Le registre dit tenir ses valeurs de §C, mais `[siren]`, `[nom_normalise]`, `[email]`, `200`, `1.5` n'y figurent pas (`06_regpol_c.txt`) ; §C `ui.theme.choix_utilisateur = non` : « theme_json ignoré » — le registre : refus GARDE ; sous D-66 strict, `oui` ne permet que le thème par défaut (seules les valeurs par défaut des `ui.*` sont servies) |
| Issues non écrites, observées | `societe.retour_prospect = auto_apres_delai` : `RequalifyCompany` client → prospect **refus ETAT** (S-RP4) ; `change.mode = aucune_conversion` écrit `snapshot_marge.taux_change = 0.9` sans s'en servir (S-CH2) ; `temps.plafond_jour = aucun`/`alerte` écrit `derogation_motif` (S-PJ2) |

---

## Angles morts — tout ce que j'ai posé en base `ava_audit11_c`

| Posé | Comment | Pourquoi |
|---|---|---|
| Base | 25 migrations dans l'ordre, registre `schema_migrations` (rang, sha256 LF), une transaction par fichier, comptes `@ava.test` éteints, `horloge_banc` vidée, puis `db/fixtures/banc.sql` (`00_monter_base.sh`) | reproduire `make.sh migrate` sans le lancer |
| Comptes | groupe **AUD11** (61 permissions, toutes sauf installation, périmètre agence PAR) et `aud11@ava.test` ; `aud11.rr` (RR), `aud11.ia` et `aud11.dr` (IA) ; `ConvertCandidateToResource` accordée à RR et IA sur PAR ; 1 ligne `compte_surcharge` (aud11.dr, UpdateNeed, PAR) — SQL (`03_comptes_audit.sql`) | « le demandeur a la permission sur PAR » ; S-CV1, S-CV2, S-DR1 |
| Demandeurs particuliers | S-RF2 par `rh@ava.test` (acteur au défaut groupe_rh) ; S-HT1 par `dp@ava.test` | texte du scénario |
| Fixtures | **tous** les états de départ insérés en SQL (rôle postgres) : sociétés, unités, contacts, personnes, profils, besoins, positionnements, projets (`PRJ-n` au max + 1), prestations, temps, absences ; S-RE3/S-RE4 : l'exception posée en SQL (« après S-RE2 ») ; S-TV3/S-TC3 : un `snapshot_marge` inséré ; S-CH2 : `prestation.taux_change = 0.9` en SQL ; S-UT1 : `theme_json` remis à NULL | aucun état de départ n'est atteignable par commande sans dépendre d'autres politiques ; un état posé en SQL contourne les gardes de création |
| États implicites déclarés | S-CC1 brouillon ; S-PG*/S-PM* besoin `en_recherche` ; S-RE1/RE2 ressource `en_cours` ; S-PC3/PC4/PX1/GP1/PCD3 un positionnement `retenu` (garde au défaut) ; S-PO1/S-PCD2/S-CB1/S-PX1/S-DG1/S-GP1 un contact (projet.contact au défaut) ; S-PG3 sans fte ; S-PJ3 = 0,8 + 0,5 ; S-FR1 frais = `frais_mensuel` 200 ; S-PR1 contractante = contact du projet | le texte ne les dit pas ; sans eux la commande tombe sur une autre garde |
| Isolement des doublons | avant S-DS*, archivage (`archive_le = now()`) des sociétés `acme/durand/martin` ou SIREN 111/222/333 ; avant S-DP*, des personnes `sara@mail.fr`, `s.ali@autre.fr`, « Sara Ali » | les doublons sont globaux à la base |
| Politiques | réglées **par SetPolicy (ADM, HTTP)** ; remises au défaut **en SQL** entre deux jeux ; `projet.contact = service_ou_societe` posée **en SQL** pour 4 sondes (C1, C5) ; état final 0 hors défaut | la valeur est refusée par SetPolicy |
| Horloge | `horloge_banc` (2026-10-15 ; 11-01 ; 10-03), SQL ; vidée à la fin | date du registre |
| Fichier hors base | mes jeux ont écrit dans `%TEMP%/ava-carte-politiques.jsonl`, fichier commun aux bancs (C9) | `AVA_MODE=banc` |
| Non couvert | performances, concurrence, écrans ; les 147 clés absentes du registre au-delà de 10 tirées ; les jeux du banc non relancés (mur : pas de `make`/`cliquet`) | hors mission |

---

## TABLEAU COMPLET — une ligne par cas du registre

| # | clé = valeur | commande · scénario | issue attendue | issue observée | verdict |
|---|---|---|---|---|---|
| 1 | `doublon.societe.mode` = avertir | CreateCompany · S-DS1 | ok · alerte DOUBLON · écrit societe.nom = Acme SA | ok · alertes DOUBLON · évts CompanyCreated | ✅ CONFORME |
| 2 | `doublon.societe.mode` = bloquer | CreateCompany · S-DS1 | refus GARDE | refus GARDE « société déjà connue (doublon.societe.mode = bloquer) » | ✅ CONFORME |
| 3 | `doublon.societe.mode` = ignorer | CreateCompany · S-DS1 | ok · sans alerte · écrit societe.nom = Acme SA | ok · sans alerte · évts CompanyCreated | ✅ CONFORME |
| 4 | `doublon.societe.cles` = [nom_normalise, siren] | CreateCompany · S-DS2 | refus GARDE | refus GARDE « société déjà connue (doublon.societe.mode = bloquer) » | ✅ CONFORME |
| 5 | `doublon.societe.cles` = [siren] | CreateCompany · S-DS2 | ok · sans alerte | ok · sans alerte · évts CompanyCreated | ✅ CONFORME |
| 6 | `doublon.societe.cles` = [nom_normalise] | CreateCompany · S-DS3 | ok · sans alerte | ok · sans alerte · évts CompanyCreated | ✅ CONFORME |
| 7 | `doublon.societe.cles` = [nom_normalise, siren] | CreateCompany · S-DS3 | refus GARDE | refus GARDE « société déjà connue (doublon.societe.mode = bloquer) » | ✅ CONFORME — SIREN de « Durand » posé en SQL ; CreateCompany ne l’écrit jamais (voir C9) |
| 8 | `societe.retour_prospect` = manuel | ClosePrestation · S-RP1 | ok · inchangé societe.statut (cat:client) | ok · sans alerte · évts PrestationClosed | ✅ CONFORME |
| 9 | `societe.retour_prospect` = auto_fin_dernier_contrat | ClosePrestation · S-RP1 | ok · écrit societe.statut = cat:prospect · événement ClientStatusDerived | ok · sans alerte · évts PrestationClosed+CompanyStatusChanged+ClientStatusDerived | ✅ CONFORME |
| 10 | `societe.retour_prospect` = auto_apres_delai | ClosePrestation · S-RP1 | ok · inchangé societe.statut (cat:client) | ok · sans alerte · évts PrestationClosed | ✅ CONFORME |
| 11 | `societe.retour_prospect` = jamais_ancien_client | ClosePrestation · S-RP1 | ok · écrit societe.statut = cat:ancien_client · événement ClientStatusDerived | ok · sans alerte · évts PrestationClosed+CompanyStatusChanged+ClientStatusDerived | ✅ CONFORME |
| 12 | `societe.retour_prospect` = auto_fin_dernier_contrat | CancelPrestation · S-RP2 | ok · écrit societe.statut = cat:prospect | ok · sans alerte · évts PrestationCancelled+CompanyStatusChanged+ClientStatusDerived | ✅ CONFORME — date_annulation hors horloge (voir C6) |
| 13 | `societe.retour_prospect` = manuel | CancelPrestation · S-RP2 | ok · inchangé societe.statut (cat:client) | ok · sans alerte · évts PrestationCancelled | ✅ CONFORME — date_annulation hors horloge (voir C6) |
| 14 | `societe.retour_prospect` = auto_apres_delai | (lecture) · S-RP3 | lu v_societe_statut.statut = cat:prospect | lu v_societe_statut.statut = prospect | ✅ CONFORME |
| 15 | `societe.retour_prospect` = manuel | (lecture) · S-RP3 | lu v_societe_statut.statut = cat:client | lu v_societe_statut.statut = client | ✅ CONFORME |
| 16 | `societe.retour_prospect` = manuel | RequalifyCompany · S-RP4 | ok · écrit societe.statut = cat:prospect | ok · sans alerte · évts CompanyStatusChanged | ✅ CONFORME |
| 17 | `societe.retour_prospect` = jamais_ancien_client | RequalifyCompany · S-RP4 | refus GARDE | refus GARDE « requalification client → prospect interdite (jamais_ancien_client) » | ✅ CONFORME |
| 18 | `societe.archivage.garde` = aucun_objet_actif | ArchiveCompany · S-AC1 | refus GARDE | refus GARDE « des objets actifs empêchent l'archivage de la société » | ✅ CONFORME |
| 19 | `societe.archivage.garde` = libre | ArchiveCompany · S-AC1 | ok · écrit societe.archive_le = aujourd'hui | ok · sans alerte · évts CompanyArchived | ✅ CONFORME |
| 20 | `service.archivage.garde` = aucun_besoin_ni_projet_actif | ArchiveService · S-AS1 | refus GARDE | refus GARDE « besoin ou projet actif sur cette unité » | ✅ CONFORME |
| 21 | `service.archivage.garde` = libre | ArchiveService · S-AS1 | ok · écrit unite_organisation.archive_le = aujourd'hui | ok · sans alerte · évts UnitArchived | ✅ CONFORME |
| 22 | `doublon.contact.mode` = avertir | CreateContact · S-DC1 | ok · alerte DOUBLON | ok · alertes DOUBLON · évts ContactCreated | ✅ CONFORME |
| 23 | `doublon.contact.mode` = bloquer | CreateContact · S-DC1 | refus GARDE | refus GARDE « contact déjà connu (doublon.contact.mode = bloquer) » | ✅ CONFORME |
| 24 | `doublon.contact.mode` = ignorer | CreateContact · S-DC1 | ok · sans alerte | ok · sans alerte · évts ContactCreated | ✅ CONFORME |
| 25 | `doublon.contact.cles` = [email, nom+prenom+societe] | CreateContact · S-DC2 | ok · sans alerte | ok · sans alerte · évts ContactCreated | ✅ CONFORME |
| 26 | `doublon.contact.cles` = [email_ou_telephone, nom+prenom+societe] | CreateContact · S-DC2 | refus GARDE | refus GARDE « contact déjà connu (doublon.contact.cles = email_ou_telephone) » | ✅ CONFORME |
| 27 | `contact.transfert.objets_actifs` = reaffectation_obligatoire | TransferContact · S-TC1 | refus GARDE | refus GARDE « objets actifs non réaffectés — réaffectation obligatoire » | ✅ CONFORME |
| 28 | `contact.transfert.objets_actifs` = conserver_liens | TransferContact · S-TC1 | ok · inchangé besoin.contact_id | ok · sans alerte · évts ContactTransferred | ✅ CONFORME |
| 29 | `contact.transfert.objets_actifs` = reaffectation_obligatoire | TransferContact · S-TC2 | ok · écrit besoin.contact_id = contact B | ok · sans alerte · évts ContactTransferred | ✅ CONFORME |
| 30 | `doublon.personne.mode` = avertir | CreatePerson · S-DP1 | ok · alerte DOUBLON | ok · alertes DOUBLON · évts PersonCreated | ✅ CONFORME |
| 31 | `doublon.personne.mode` = bloquer | CreatePerson · S-DP1 | refus GARDE | refus GARDE « personne déjà connue (doublon.personne.mode = bloquer) » | ✅ CONFORME |
| 32 | `doublon.personne.mode` = ignorer | CreatePerson · S-DP1 | ok · sans alerte | ok · sans alerte · évts PersonCreated | ✅ CONFORME |
| 33 | `doublon.personne.cles` = [email, nom+prenom+naissance] | CreatePerson · S-DP2 | refus GARDE | refus GARDE « personne déjà connue (doublon.personne.cles = nom+prenom+naissance) » | ✅ CONFORME |
| 34 | `doublon.personne.cles` = [email] | CreatePerson · S-DP2 | ok · sans alerte | ok · sans alerte · évts PersonCreated | ✅ CONFORME |
| 35 | `candidat.complete.champs_requis` = [nom, prenom, civilite, localisation, email_ou_telephone] | CompleteCandidate · S-CC1 | refus GARDE | refus GARDE « champs requis manquants : civilite » | ✅ CONFORME |
| 36 | `candidat.complete.champs_requis` = [nom, prenom, localisation, email_ou_telephone] | CompleteCandidate · S-CC1 | ok · écrit profil_candidat.etape = cat:complet | ok · sans alerte · évts CandidateCompleted | ✅ CONFORME |
| 37 | `candidat.conversion.acteur` = groupe_rh | ConvertCandidateToResource · S-CV1 | refus DROIT | refus DROIT « groupe non désigné par candidat.conversion.acteur » | ✅ CONFORME |
| 38 | `candidat.conversion.acteur` = groupe_rh_ou_rr | ConvertCandidateToResource · S-CV1 | ok · écrit profil_ressource.personne_id = la personne | ok · sans alerte · évts CandidateConverted | ✅ CONFORME |
| 39 | `candidat.conversion.acteur` = tout_habilite | ConvertCandidateToResource · S-CV1 | ok | ok · sans alerte · évts CandidateConverted | ✅ CONFORME |
| 40 | `candidat.conversion.acteur` = groupe_rh_ou_rr | ConvertCandidateToResource · S-CV2 | refus DROIT | refus DROIT « groupe non désigné par candidat.conversion.acteur » | ✅ CONFORME |
| 41 | `candidat.conversion.acteur` = tout_habilite | ConvertCandidateToResource · S-CV2 | ok | ok · sans alerte · évts CandidateConverted | ✅ CONFORME |
| 42 | `candidat.note.echelle` = 1_5 | UpdateCandidate · S-NE1 | refus GARDE | refus GARDE « note hors échelle 0..5 » | ✅ CONFORME |
| 43 | `candidat.note.echelle` = 1_10 | UpdateCandidate · S-NE1 | ok · écrit profil_candidat.note = 7 | ok · sans alerte · évts CandidateUpdated | ✅ CONFORME |
| 44 | `candidat.note.echelle` = 1_100 | UpdateCandidate · S-NE1 | ok · écrit profil_candidat.note = 7 | ok · sans alerte · évts CandidateUpdated | ✅ CONFORME |
| 45 | `candidat.note.echelle` = aucune | UpdateCandidate · S-NE1 | refus GARDE | refus GARDE « candidat.note.echelle = aucune » | ✅ CONFORME |
| 46 | `candidat.note.echelle` = 1_10 | UpdateCandidate · S-NE2 | refus GARDE | refus GARDE « note hors échelle 0..10 » | ✅ CONFORME |
| 47 | `candidat.note.echelle` = 1_100 | UpdateCandidate · S-NE2 | ok · écrit profil_candidat.note = 50 | ok · sans alerte · évts CandidateUpdated | ✅ CONFORME |
| 48 | `candidat.note.echelle` = 1_5 | UpdateCandidate · S-NE3 | ok · écrit profil_candidat.note = 3 | ok · sans alerte · évts CandidateUpdated | ✅ CONFORME |
| 49 | `candidat.note.echelle` = aucune | UpdateCandidate · S-NE3 | refus GARDE | refus GARDE « candidat.note.echelle = aucune » | ✅ CONFORME |
| 50 | `ressource.externe.societe_fournisseur` = obligatoire | CreateResource · S-RF1 | refus GARDE | refus GARDE « fournisseur obligatoire pour une ressource externe » | ✅ CONFORME |
| 51 | `ressource.externe.societe_fournisseur` = facultatif | CreateResource · S-RF1 | ok | ok · sans alerte · évts ResourceCreated | ✅ CONFORME |
| 52 | `ressource.externe.societe_fournisseur` = obligatoire | ConvertCandidateToResource · S-RF2 | refus GARDE | refus GARDE « fournisseur obligatoire pour une ressource externe » | ✅ CONFORME |
| 53 | `ressource.externe.societe_fournisseur` = facultatif | ConvertCandidateToResource · S-RF2 | ok | ok · sans alerte · évts CandidateConverted | ✅ CONFORME |
| 54 | `ressource.etat.mode` = manuel | SetResourceState · S-RE1 | ok · écrit profil_ressource.etat = cat:disponible | ok · sans alerte · évts ResourceStateChanged | ✅ CONFORME |
| 55 | `ressource.etat.mode` = derive_des_prestations | SetResourceState · S-RE1 | refus GARDE | refus GARDE « ressource.etat.mode n'autorise pas un changement manuel vers cet état » | ✅ CONFORME |
| 56 | `ressource.etat.mode` = derive_avec_exceptions_tracees | SetResourceState · S-RE1 | refus GARDE | refus GARDE « exception : motif et date de fin » | ✅ CONFORME |
| 57 | `ressource.etat.mode` = derive_avec_exceptions_tracees | SetResourceState · S-RE2 | ok · écrit profil_ressource.etat_exception_code = cat:disponible ; profil_ressource.etat_exception_jusquau = 31/10/2026 | ok · sans alerte · évts ResourceStateChanged | ✅ CONFORME |
| 58 | `ressource.etat.mode` = derive_avec_exceptions_tracees | (lecture) · S-RE3 | lu v_ressource_etat.etat = cat:disponible | lu v_ressource_etat.etat = disponible | ✅ CONFORME |
| 59 | `ressource.etat.mode` = derive_avec_exceptions_tracees | (lecture) · S-RE4 | lu v_ressource_etat.etat = cat:en_mission | lu v_ressource_etat.etat = en_mission | ✅ CONFORME |
| 60 | `ressource.etat.mode` = derive_des_prestations | (lecture) · S-RE5 | lu v_ressource_etat.etat = cat:en_mission | lu v_ressource_etat.etat = en_mission | ✅ CONFORME |
| 61 | `ressource.etat.mode` = manuel | (lecture) · S-RE5 | lu v_ressource_etat.etat = cat:disponible | lu v_ressource_etat.etat = disponible | ✅ CONFORME |
| 62 | `ressource.etat.mode` = derive_des_prestations | SetResourceState · S-RE6 | ok · écrit profil_ressource.etat = cat:sorti | ok · sans alerte · évts ResourceStateChanged | ✅ CONFORME |
| 63 | `qualification.besoin_obligatoire` = oui | RecordQualification · S-QB1 | refus GARDE | refus GARDE « besoin obligatoire pour une qualification » | ✅ CONFORME |
| 64 | `qualification.besoin_obligatoire` = non | RecordQualification · S-QB1 | ok · écrit qualification.besoin_id = NULL | ok · sans alerte · évts QualificationRecorded | ✅ CONFORME — date de la séance hors horloge (voir C6) |
| 65 | `besoin.unite_couverture` = postes | CreateNeed · S-UC1 | ok · écrit besoin.unite_couverture_code = postes | ok · sans alerte · évts NeedCreated | ✅ CONFORME |
| 66 | `besoin.unite_couverture` = fte | CreateNeed · S-UC1 | ok · écrit besoin.unite_couverture_code = fte | ok · sans alerte · évts NeedCreated | ✅ CONFORME |
| 67 | `besoin.unite_couverture` = postes_et_fte | CreateNeed · S-UC1 | ok · écrit besoin.unite_couverture_code = postes_et_fte | ok · sans alerte · évts NeedCreated | ✅ CONFORME |
| 68 | `besoin.contact` = facultatif | CreateNeed · S-BC1 | ok | ok · sans alerte · évts NeedCreated | ✅ CONFORME |
| 69 | `besoin.contact` = obligatoire | CreateNeed · S-BC1 | refus GARDE | refus GARDE « contact obligatoire » | ✅ CONFORME |
| 70 | `besoin.staffing.declencheur` = premier_positionnement | PositionCandidate · S-SD1 | ok · écrit besoin.etat = cat:en_recherche | ok · sans alerte · évts CandidatePositioned+NeedStateChanged | ✅ CONFORME |
| 71 | `besoin.staffing.declencheur` = commande_prise_en_charge | PositionCandidate · S-SD1 | ok · inchangé besoin.etat (cat:a_pourvoir) | ok · sans alerte · évts CandidatePositioned | ✅ CONFORME |
| 72 | `besoin.staffing.declencheur` = retour_client_retenu | PositionCandidate · S-SD1 | ok · inchangé besoin.etat (cat:a_pourvoir) | ok · sans alerte · évts CandidatePositioned | ✅ CONFORME |
| 73 | `besoin.staffing.declencheur` = commande_prise_en_charge | TakeNeedInCharge · S-SD2 | ok · écrit besoin.etat = cat:en_recherche | ok · sans alerte · évts NeedTakenInCharge | ✅ CONFORME |
| 74 | `besoin.staffing.declencheur` = premier_positionnement | TakeNeedInCharge · S-SD2 | ok · inchangé besoin.etat (cat:a_pourvoir) | ok · sans alerte | ✅ CONFORME |
| 75 | `besoin.staffing.declencheur` = retour_client_retenu | RecordClientDecision · S-SD3 | ok · écrit besoin.etat = cat:en_recherche | ok · sans alerte · évts ClientDecisionRecorded+NeedStateChanged | ✅ CONFORME |
| 76 | `besoin.staffing.declencheur` = commande_prise_en_charge | RecordClientDecision · S-SD3 | ok · inchangé besoin.etat (cat:a_pourvoir) | ok · sans alerte · évts ClientDecisionRecorded | ✅ CONFORME |
| 77 | `besoin.pourvu.garde_minimale` = tous_les_postes_signes | DeclareNeedFilled · S-PG1 | refus GARDE | refus GARDE « couverture insuffisante (postes) : 1/2 postes » | ✅ CONFORME |
| 78 | `besoin.pourvu.garde_minimale` = une_prestation_signee | DeclareNeedFilled · S-PG1 | ok · écrit besoin.etat = cat:pourvu | ok · sans alerte · évts NeedFilled | ✅ CONFORME |
| 79 | `besoin.pourvu.garde_minimale` = aucune | DeclareNeedFilled · S-PG1 | ok · écrit besoin.etat = cat:pourvu | ok · sans alerte · évts NeedFilled | ✅ CONFORME |
| 80 | `besoin.pourvu.garde_minimale` = une_prestation_signee | DeclareNeedFilled · S-PG2 | refus GARDE | refus GARDE « couverture insuffisante (une_prestation_signee) » | ✅ CONFORME |
| 81 | `besoin.pourvu.garde_minimale` = aucune | DeclareNeedFilled · S-PG2 | ok · écrit besoin.etat = cat:pourvu | ok · sans alerte · évts NeedFilled | ✅ CONFORME |
| 82 | `besoin.pourvu.garde_minimale` = tous_les_postes_signes | DeclareNeedFilled · S-PG3 | ok · écrit besoin.etat = cat:pourvu | ok · sans alerte · évts NeedFilled | ✅ CONFORME — ⚠️ état adapté : fte visé 1,0 impossible sous l’unité postes (déclencheur besoin_couverture) |
| 83 | `besoin.pourvu.garde_minimale` = tous_les_postes_signes | DeclareNeedFilled · S-PG4 | refus GARDE | refus GARDE « couverture insuffisante (fte) : 0.5/1 fte » | ✅ CONFORME |
| 84 | `besoin.pourvu.mode` = manuel_avec_garde | SignPrestation · S-PM1 | ok · inchangé besoin.etat (cat:en_recherche) | ok · sans alerte · évts PrestationSigned | ✅ CONFORME |
| 85 | `besoin.pourvu.mode` = auto_par_prestation_signee | SignPrestation · S-PM1 | ok · inchangé besoin.etat (cat:en_recherche) | ok · sans alerte · évts PrestationSigned | ✅ CONFORME |
| 86 | `besoin.pourvu.mode` = auto_par_personne_signee | SignPrestation · S-PM1 | ok · écrit besoin.etat = cat:pourvu · événement NeedFilled | ok · sans alerte · évts PrestationSigned+NeedFilled | ✅ CONFORME |
| 87 | `besoin.pourvu.mode` = auto_propose_confirme | SignPrestation · S-PM1 | ok · inchangé besoin.etat · sans alerte | ok · sans alerte · évts PrestationSigned | ✅ CONFORME |
| 88 | `besoin.pourvu.mode` = auto_par_prestation_signee | SignPrestation · S-PM2 | ok · écrit besoin.etat = cat:pourvu · événement NeedFilled | ok · sans alerte · évts PrestationSigned+NeedFilled | ✅ CONFORME |
| 89 | `besoin.pourvu.mode` = auto_propose_confirme | SignPrestation · S-PM2 | ok · inchangé besoin.etat · alerte BESOIN_A_DECLARER_POURVU | ok · alertes BESOIN_A_DECLARER_POURVU · évts PrestationSigned | ✅ CONFORME |
| 90 | `besoin.pourvu.mode` = manuel_avec_garde | SignPrestation · S-PM2 | ok · inchangé besoin.etat (cat:en_recherche) | ok · sans alerte · évts PrestationSigned | ✅ CONFORME |
| 91 | `besoin.pourvu.mode` = auto_par_personne_signee | DeclareNeedFilled · S-PM3 | refus GARDE | refus GARDE « couverture insuffisante (postes) : 1/2 postes » | ✅ CONFORME — sans depuis_signature ; avec, la garde tombe (voir C3) |
| 92 | `besoin.pourvu.mode` = auto_propose_confirme | DeclareNeedFilled · S-PM3 | refus GARDE | refus GARDE « couverture insuffisante (postes) : 1/2 postes » | ✅ CONFORME |
| 93 | `positionnement.sur_besoin_inactif` = refus | PositionCandidate · S-BI1 | refus GARDE | refus GARDE « positionnement sur besoin inactif refusé » | ✅ CONFORME |
| 94 | `positionnement.sur_besoin_inactif` = alerte | PositionCandidate · S-BI1 | ok · alerte BESOIN_INACTIF | ok · alertes BESOIN_INACTIF · évts CandidatePositioned | ✅ CONFORME |
| 95 | `positionnement.sur_besoin_inactif` = libre | PositionCandidate · S-BI1 | ok · sans alerte | ok · sans alerte · évts CandidatePositioned | ✅ CONFORME |
| 96 | `positionnement.unicite` = actifs | PositionCandidate · S-PU1 | refus GARDE | refus GARDE « unicité de positionnement violée » | ✅ CONFORME |
| 97 | `positionnement.unicite` = aucune | PositionCandidate · S-PU1 | ok | ok · sans alerte · évts CandidatePositioned+NeedStateChanged | ✅ CONFORME |
| 98 | `positionnement.unicite` = historique | PositionCandidate · S-PU1 | refus GARDE | refus GARDE « unicité de positionnement violée » | ✅ CONFORME |
| 99 | `positionnement.unicite` = actifs | PositionCandidate · S-PU2 | ok | ok · sans alerte · évts CandidatePositioned+NeedStateChanged | ✅ CONFORME |
| 100 | `positionnement.unicite` = historique | PositionCandidate · S-PU2 | refus GARDE | refus GARDE « unicité de positionnement violée » | ✅ CONFORME |
| 101 | `positionnement.cv_partage_obligatoire` = oui | RecordClientDecision · S-CP1 | refus ETAT | refus ETAT « décision client hors cycle (CV non présenté) » | ✅ CONFORME |
| 102 | `positionnement.cv_partage_obligatoire` = non | RecordClientDecision · S-CP1 | ok · écrit positionnement.etat = cat:terminal_positif | ok · sans alerte · évts ClientDecisionRecorded | ✅ CONFORME |
| 103 | `positionnement.qualification_requise_avant_decision` = non | RecordClientDecision · S-QR1 | ok | ok · sans alerte · évts ClientDecisionRecorded | ✅ CONFORME |
| 104 | `positionnement.qualification_requise_avant_decision` = oui | RecordClientDecision · S-QR1 | refus GARDE | refus GARDE « qualification requise avant décision » | ✅ CONFORME |
| 105 | `projet.creation_depuis_besoin` = explicite | RecordClientDecision · S-CB1 | ok · aucune ligne projet | ok · sans alerte · évts ClientDecisionRecorded | ✅ CONFORME |
| 106 | `projet.creation_depuis_besoin` = automatique_au_retenu | RecordClientDecision · S-CB1 | ok · écrit projet.besoin_id = le besoin · événement ProjectCreatedFromNeed | ok · sans alerte · évts ClientDecisionRecorded+ProjectCreatedFromNeed | ✅ CONFORME |
| 107 | `projet.contact` = obligatoire | CreateProject · S-PC1 | refus GARDE | refus GARDE « contact obligatoire » | ✅ CONFORME |
| 108 | `projet.contact` = facultatif | CreateProject · S-PC1 | ok · écrit projet.contact_id = NULL | ok · sans alerte · évts ProjectCreated | ✅ CONFORME |
| 109 | `projet.contact` = obligatoire_avant_engagement | CreateProject · S-PC1 | ok · écrit projet.contact_id = NULL | ok · sans alerte · évts ProjectCreated | ✅ CONFORME |
| 110 | `projet.contact` = service_ou_societe | CreateProject · S-PC1 | ok · écrit projet.contact_id = NULL | SetPolicy refus GARDE « valeur hors valeurs_possibles pour projet.contact » ⇒ SetPolicy projet.contact=service_ou_societe refusé : refus GARDE « valeur hors valeurs_possibles pour projet.contact » — valeur servie par le registre (règle 1) mais inatteignable | ⛔ ÉCART — service_ou_societe absente de valeurs_possibles |
| 111 | `projet.contact` = facultatif | SignPrestation · S-PC2 | ok | ok · sans alerte · évts PrestationSigned+CompanyStatusChanged+ClientStatusDerived | ✅ CONFORME |
| 112 | `projet.contact` = obligatoire_avant_engagement | SignPrestation · S-PC2 | refus GARDE | refus GARDE « contact obligatoire avant engagement » | ✅ CONFORME |
| 113 | `projet.contact` = service_ou_societe | CreateProjectFromNeed · S-PC3 | refus GARDE | SetPolicy refus GARDE « valeur hors valeurs_possibles pour projet.contact » ⇒ SetPolicy projet.contact=service_ou_societe refusé : refus GARDE « valeur hors valeurs_possibles pour projet.contact » — valeur servie par le registre (règle 1) mais inatteignable | ⛔ ÉCART — service_ou_societe absente de valeurs_possibles |
| 114 | `projet.contact` = facultatif | CreateProjectFromNeed · S-PC3 | ok | ok · sans alerte · évts ProjectCreatedFromNeed | ✅ CONFORME |
| 115 | `projet.contact` = service_ou_societe | CreateProjectFromNeed · S-PC4 | ok · écrit projet.unite_organisation_id = l'unité donnée | SetPolicy refus GARDE « valeur hors valeurs_possibles pour projet.contact » ⇒ SetPolicy projet.contact=service_ou_societe refusé : refus GARDE « valeur hors valeurs_possibles pour projet.contact » — valeur servie par le registre (règle 1) mais inatteignable | ⛔ ÉCART — service_ou_societe absente de valeurs_possibles |
| 116 | `projet.contact` = obligatoire | CreateProjectFromNeed · S-PC4 | refus GARDE | refus GARDE « contact obligatoire » | ✅ CONFORME |
| 117 | `projet.origine_besoin` = facultative | CreateProject · S-PO1 | ok · écrit projet.besoin_id = NULL | ok · sans alerte · évts ProjectCreated | ✅ CONFORME |
| 118 | `projet.origine_besoin` = obligatoire | CreateProject · S-PO1 | refus GARDE | refus GARDE « origine besoin obligatoire » | ✅ CONFORME |
| 119 | `besoin.projets_max` = illimite | CreateProjectFromNeed · S-PX1 | ok | ok · sans alerte · évts ProjectCreatedFromNeed | ✅ CONFORME |
| 120 | `besoin.projets_max` = un_seul | CreateProjectFromNeed · S-PX1 | refus GARDE | refus GARDE « besoin.projets_max = un_seul » | ✅ CONFORME |
| 121 | `projet.depuis_besoin.garde` = retenu_requis | CreateProjectFromNeed · S-DG1 | refus GARDE | refus GARDE « retenu avec profil ressource requis » | ✅ CONFORME |
| 122 | `projet.depuis_besoin.garde` = libre | CreateProjectFromNeed · S-DG1 | ok | ok · sans alerte · évts ProjectCreatedFromNeed | ✅ CONFORME |
| 123 | `projet.depuis_besoin.garde_profil` = personne_avec_ressource | CreateProjectFromNeed · S-GP1 | ok | ok · sans alerte · évts ProjectCreatedFromNeed | ✅ CONFORME |
| 124 | `projet.depuis_besoin.garde_profil` = positionnement_ressource_strict | CreateProjectFromNeed · S-GP1 | refus GARDE | refus GARDE « retenu avec profil ressource requis » | ✅ CONFORME |
| 125 | `projet.cloture.garde` = prestations_closes | CloseProject · S-PCL1 | refus GARDE | refus GARDE « des prestations ne sont pas closes » | ✅ CONFORME |
| 126 | `projet.cloture.garde` = cascade_cloture_prestations | CloseProject · S-PCL1 | ok · écrit prestation.etat = cat:clos (la prestation ouverte, à la date de clôture du projet) ; inchangé prestation.etat (la prestation déjà close) | ok · sans alerte · évts PrestationClosed+ProjectClosed | ✅ CONFORME |
| 127 | `prestation.avenant.mode` = nouvelle_prestation | SignPrestation · S-AV1 | ok · aucune ligne prestation_version | ok · sans alerte · évts PrestationSigned+CompanyStatusChanged+ClientStatusDerived | ✅ CONFORME |
| 128 | `prestation.avenant.mode` = version_datee | SignPrestation · S-AV1 | ok · écrit prestation_version.version = 1 | ok · sans alerte · évts PrestationSigned+CompanyStatusChanged+ClientStatusDerived | ✅ CONFORME |
| 129 | `societe.passage_client.declencheur` = premiere_prestation_signee | SignPrestation · S-PCD1 | ok · écrit societe.statut = cat:client · événement ClientStatusDerived | ok · sans alerte · évts PrestationSigned+CompanyStatusChanged+ClientStatusDerived | ✅ CONFORME |
| 130 | `societe.passage_client.declencheur` = premier_engagement_contractuel | SignPrestation · S-PCD1 | ok · écrit societe.statut = cat:client · événement ClientStatusDerived | ok · sans alerte · évts PrestationSigned+CompanyStatusChanged+ClientStatusDerived | ✅ CONFORME |
| 131 | `societe.passage_client.declencheur` = manuel | SignPrestation · S-PCD1 | ok · inchangé societe.statut (cat:prospect) | ok · sans alerte · évts PrestationSigned | ✅ CONFORME |
| 132 | `societe.passage_client.declencheur` = creation_projet | SignPrestation · S-PCD1 | ok · inchangé societe.statut (cat:prospect) | ok · sans alerte · évts PrestationSigned | ✅ CONFORME |
| 133 | `societe.passage_client.declencheur` = creation_projet | CreateProject · S-PCD2 | ok · écrit societe.statut = cat:client · événement ClientStatusDerived | ok · sans alerte · évts ProjectCreated+CompanyStatusChanged+ClientStatusDerived | ✅ CONFORME |
| 134 | `societe.passage_client.declencheur` = premiere_prestation_signee | CreateProject · S-PCD2 | ok · inchangé societe.statut (cat:prospect) | ok · sans alerte · évts ProjectCreated | ✅ CONFORME |
| 135 | `societe.passage_client.declencheur` = creation_projet | CreateProjectFromNeed · S-PCD3 | ok · écrit societe.statut = cat:client | ok · sans alerte · évts ProjectCreatedFromNeed+CompanyStatusChanged+ClientStatusDerived | ✅ CONFORME |
| 136 | `societe.passage_client.propagation` = branche_contractante_et_contacts_du_service | SignPrestation · S-PR1 | ok · écrit unite_organisation.statut (U1) = cat:client ; contact.statut (contacts de U1) = cat:client ; inchangé unite_organisation.statut (U2) | ok · sans alerte · évts PrestationSigned+CompanyStatusChanged+ClientStatusDerived | ✅ CONFORME — ⚠️ un seul contact par unité : le scénario ne distingue pas « contacts de U1 » de « le contact du projet » (voir C5) |
| 137 | `societe.passage_client.propagation` = societe_seule | SignPrestation · S-PR1 | ok · écrit societe.statut = cat:client ; inchangé unite_organisation.statut (U1) | ok · sans alerte · évts PrestationSigned+CompanyStatusChanged+ClientStatusDerived | ✅ CONFORME |
| 138 | `societe.passage_client.propagation` = toute_la_societe | SignPrestation · S-PR1 | ok · écrit unite_organisation.statut (U1, U2) = cat:client ; contact.statut (tous) = cat:client | ok · sans alerte · évts PrestationSigned+CompanyStatusChanged+ClientStatusDerived | ✅ CONFORME |
| 139 | `projet.devises_mixtes` = autorise | CreatePrestation · S-DM1 | ok · écrit prestation.devise_code = USD | ok · sans alerte · évts PrestationCreated | ✅ CONFORME |
| 140 | `projet.devises_mixtes` = refus | CreatePrestation · S-DM1 | refus GARDE | refus GARDE « devises mixtes refusées sur ce projet » | ✅ CONFORME |
| 141 | `prestation.surcharge.mode` = alerte | CreatePrestation · S-SU1 | ok · alerte SURCHARGE | ok · alertes SURCHARGE · évts PrestationCreated | ✅ CONFORME |
| 142 | `prestation.surcharge.mode` = refus | CreatePrestation · S-SU1 | refus GARDE | refus GARDE « surcharge occupation 150 > 100 » | ✅ CONFORME |
| 143 | `prestation.surcharge.mode` = silencieux | CreatePrestation · S-SU1 | ok · sans alerte | ok · sans alerte · évts PrestationCreated | ✅ CONFORME |
| 144 | `prestation.surcharge.seuil_pct` = 100 | CreatePrestation · S-SU2 | ok · alerte SURCHARGE | ok · alertes SURCHARGE · évts PrestationCreated | ✅ CONFORME |
| 145 | `prestation.surcharge.seuil_pct` = 200 | CreatePrestation · S-SU2 | ok · sans alerte | ok · sans alerte · évts PrestationCreated | ✅ CONFORME |
| 146 | `prestation.annulation.garde` = aucun_temps_saisi | CancelPrestation · S-PA1 | refus GARDE | refus GARDE « des temps sont déjà saisis » | ✅ CONFORME |
| 147 | `prestation.annulation.garde` = libre | CancelPrestation · S-PA1 | ok · écrit prestation.etat = cat:annule | ok · sans alerte · évts PrestationCancelled | ✅ CONFORME |
| 148 | `temps.periode` = dates_prestation | RecordTimesheet · S-TP1 | ok | ok · sans alerte · évts TimesheetRecorded | ✅ CONFORME |
| 149 | `temps.periode` = dates_prestation_et_mois_ouvert | RecordTimesheet · S-TP1 | ok | ok · sans alerte · évts TimesheetRecorded | ✅ CONFORME |
| 150 | `temps.periode` = dates_prestation | RecordTimesheet · S-TP2 | refus GARDE | refus GARDE « jour hors des dates de la prestation » | ✅ CONFORME |
| 151 | `temps.periode` = dates_prestation_et_mois_ouvert | RecordTimesheet · S-TP2 | refus GARDE | refus GARDE « jour hors des dates de la prestation » | ✅ CONFORME |
| 152 | `temps.periode` = dates_prestation | RecordTimesheet · S-TP3 | ok | ok · sans alerte · évts TimesheetRecorded | ✅ CONFORME |
| 153 | `temps.periode` = dates_prestation_et_mois_ouvert | RecordTimesheet · S-TP3 | refus GARDE | refus GARDE « jour hors du mois ouvert » | ✅ CONFORME |
| 154 | `temps.periode` = dates_prestation_et_mois_ouvert | RecordTimesheet · S-TP4 | ok | ok · sans alerte · évts TimesheetRecorded | ✅ CONFORME |
| 155 | `temps.plafond_jour` = alerte | RecordTimesheet · S-PJ1 | ok · alerte PLAFOND_JOUR | ok · alertes PLAFOND_JOUR · évts TimesheetRecorded | ✅ CONFORME |
| 156 | `temps.plafond_jour` = refus | RecordTimesheet · S-PJ1 | refus GARDE | refus GARDE « plafond journalier dépassé (1.3 > 1) » | ✅ CONFORME |
| 157 | `temps.plafond_jour` = aucun | RecordTimesheet · S-PJ1 | ok · sans alerte | ok · sans alerte · évts TimesheetRecorded | ✅ CONFORME |
| 158 | `temps.plafond_jour` = refus_avec_derogation_tracee | RecordTimesheet · S-PJ1 | refus GARDE | refus GARDE « plafond journalier dépassé (1.3 > 1) » | ✅ CONFORME |
| 159 | `temps.plafond_jour` = refus_avec_derogation_tracee | RecordTimesheet · S-PJ2 | ok · alerte PLAFOND_JOUR · écrit temps.derogation_motif = astreinte | ok · alertes PLAFOND_JOUR · évts TimesheetRecorded | ✅ CONFORME |
| 160 | `capacite.jour_ouvre` = 1.0 | RecordTimesheet · S-PJ3 | refus GARDE | refus GARDE « plafond journalier dépassé (1.3 > 1) » | ✅ CONFORME — « 1,3 j » lu 0,8 + 0,5 |
| 161 | `capacite.jour_ouvre` = 1.5 | RecordTimesheet · S-PJ3 | ok | ok · sans alerte · évts TimesheetRecorded | ✅ CONFORME |
| 162 | `temps.facturable.mode` = egal_au_produit | RecordTimesheet · S-TF1 | ok · écrit temps.quantite_facturable = 1.0 | ok · sans alerte · évts TimesheetRecorded | ✅ CONFORME |
| 163 | `temps.facturable.mode` = saisie_separee | RecordTimesheet · S-TF1 | refus GARDE | refus GARDE « quantité facturable exigée » | ✅ CONFORME |
| 164 | `temps.facturable.mode` = saisie_separee | RecordTimesheet · S-TF2 | ok · écrit temps.quantite = 1.0 ; temps.quantite_facturable = 0.5 | ok · sans alerte · évts TimesheetRecorded | ✅ CONFORME |
| 165 | `temps.facturable.mode` = egal_au_produit | RecordTimesheet · S-TF2 | refus GARDE | refus GARDE « la quantité facturable est égale au produit » | ✅ CONFORME |
| 166 | `temps.validation` = aucune | RecordTimesheet · S-TV1 | ok · écrit temps.etat = cat:valide | ok · sans alerte · évts TimesheetRecorded | ✅ CONFORME |
| 167 | `temps.validation` = par_dp | RecordTimesheet · S-TV1 | ok · écrit temps.etat = cat:a_valider | ok · sans alerte · évts TimesheetRecorded | ✅ CONFORME |
| 168 | `temps.validation` = par_projet | RecordTimesheet · S-TV1 | ok · écrit temps.etat = cat:a_valider | ok · sans alerte · évts TimesheetRecorded | ✅ CONFORME |
| 169 | `temps.validation` = par_projet | RecordTimesheet · S-TV2 | ok · écrit temps.etat = cat:valide | ok · sans alerte · évts TimesheetRecorded | ✅ CONFORME |
| 170 | `temps.validation` = par_dp | AdjustTimesheetAfterClose · S-TV3 | ok · écrit temps.etat = cat:a_valider ; temps.ajustement = true | ok · sans alerte · évts TimesheetAdjusted | ✅ CONFORME |
| 171 | `temps.validation` = aucune | AdjustTimesheetAfterClose · S-TV3 | ok · écrit temps.etat = cat:valide ; temps.ajustement = true | ok · sans alerte · évts TimesheetAdjusted | ✅ CONFORME |
| 172 | `temps.correction_apres_cloture` = ajustement_trace | AdjustTimesheetAfterClose · S-TC3 | ok · écrit temps.ajustement = true ; inchangé snapshot_marge | ok · sans alerte · évts TimesheetAdjusted | ✅ CONFORME |
| 173 | `temps.correction_apres_cloture` = refus | AdjustTimesheetAfterClose · S-TC3 | refus GARDE | refus GARDE « correction après clôture refusée » | ✅ CONFORME |
| 174 | `ca_produit.base` = temps_saisis | ClosePrestation · S-CA1 | ok · écrit snapshot_marge.ca = 5000 | ok · sans alerte · évts PrestationClosed | ✅ CONFORME |
| 175 | `ca_produit.base` = temps_valides | ClosePrestation · S-CA1 | ok · écrit snapshot_marge.ca = 3000 | ok · sans alerte · évts PrestationClosed | ✅ CONFORME |
| 176 | `frais.mode` = imputes_en_marge | ClosePrestation · S-FR1 | ok · écrit snapshot_marge.marge = 1800 | ok · sans alerte · évts PrestationClosed | ✅ CONFORME |
| 177 | `frais.mode` = ignores | ClosePrestation · S-FR1 | ok · écrit snapshot_marge.marge = 2000 | ok · sans alerte · évts PrestationClosed | ✅ CONFORME |
| 178 | `change.mode` = aucune_conversion | ClosePrestation · S-CH1 | ok · écrit snapshot_marge.marge = NULL ; snapshot_marge.motif_sans_marge = devises_mixtes | ok · sans alerte · évts PrestationClosed | ✅ CONFORME |
| 179 | `change.mode` = taux_saisi | ClosePrestation · S-CH1 | refus GARDE | refus GARDE « taux de change non saisi pour des devises mixtes » | ✅ CONFORME |
| 180 | `change.mode` = taux_saisi | ClosePrestation · S-CH2 | ok · écrit snapshot_marge.marge = 1400 ; snapshot_marge.taux_change = 0.9 | ok · sans alerte · évts PrestationClosed | ✅ CONFORME |
| 181 | `marge.taux.si_ca_nul` = tiret | ClosePrestation · S-MT1 | ok · écrit snapshot_marge.taux_marge = NULL | ok · sans alerte · évts PrestationClosed | ✅ CONFORME |
| 182 | `marge.taux.si_ca_nul` = zero | ClosePrestation · S-MT1 | ok · écrit snapshot_marge.taux_marge = 0 | ok · sans alerte · évts PrestationClosed | ✅ CONFORME |
| 183 | `absence.chevauchement` = refus | RecordAbsence · S-AB1 | refus GARDE | refus GARDE « chevauchement d'absence » | ✅ CONFORME |
| 184 | `absence.chevauchement` = alerte | RecordAbsence · S-AB1 | ok · alerte CHEVAUCHEMENT | ok · alertes CHEVAUCHEMENT · évts AbsenceRecorded | ✅ CONFORME |
| 185 | `absence.chevauchement` = libre | RecordAbsence · S-AB1 | ok · sans alerte | ok · sans alerte · évts AbsenceRecorded | ✅ CONFORME |
| 186 | `absence.sans_prestation` = autorisee | RecordAbsence · S-AB2 | ok | ok · sans alerte · évts AbsenceRecorded | ✅ CONFORME |
| 187 | `absence.sans_prestation` = refusee | RecordAbsence · S-AB2 | refus GARDE | refus GARDE « absence sans prestation refusée » | ✅ CONFORME |
| 188 | `ui.theme.choix_utilisateur` = oui | SetOwnTheme · S-UT1 | ok · écrit compte.theme_json = le thème donné | ok · sans alerte · évts ThemeChanged | ✅ CONFORME — seule valeur servie de ui.mode : sombre (D-66 non jouée : voir C4) |
| 189 | `ui.theme.choix_utilisateur` = non | SetOwnTheme · S-UT1 | refus GARDE | refus GARDE « ui.theme.choix_utilisateur = non » | ✅ CONFORME |
| 190 | `droits.surcharge_restrictive` = restriction_gagne | UpdateNeed · S-DR1 | refus DROIT | refus DROIT « permission absente ou hors périmètre » | ✅ CONFORME |
| 191 | `droits.surcharge_restrictive` = union_gagne | UpdateNeed · S-DR1 | ok | ok · sans alerte · évts NeedUpdated | ✅ CONFORME |
| 192 | `historique.tentatives_refusees` = tracees_a_part | UpdateNeed · S-HT1 | refus DROIT · écrit tentative_refusee (1 ligne) | refus DROIT « permission absente ou hors périmètre » | ✅ CONFORME |
| 193 | `historique.tentatives_refusees` = non_tracees | UpdateNeed · S-HT1 | refus DROIT · aucune ligne tentative_refusee | refus DROIT « permission absente ou hors périmètre » | ✅ CONFORME |
| 194 | `societe.perimetre.mode` = agence_responsable | UpdateCompany · S-SP1 | refus DROIT | refus DROIT « permission absente ou hors périmètre » | ✅ CONFORME |
| 195 | `societe.perimetre.mode` = par_besoins | UpdateCompany · S-SP1 | ok | ok · sans alerte · évts CompanyUpdated | ✅ CONFORME |
| 196 | `societe.perimetre.mode` = partagee | UpdateCompany · S-SP1 | ok | ok · sans alerte · évts CompanyUpdated | ✅ CONFORME |
| 197 | `societe.perimetre.mode` = par_besoins | UpdateCompany · S-SP2 | refus DROIT | refus DROIT « permission absente ou hors périmètre » | ✅ CONFORME |
| 198 | `societe.perimetre.mode` = partagee | UpdateCompany · S-SP2 | ok | ok · sans alerte · évts CompanyUpdated | ✅ CONFORME |
| 199 | `societe.perimetre.mode` = par_besoins | UpdateCompany · S-SP3 | ok | ok · sans alerte · évts CompanyUpdated | ✅ CONFORME |
| 200 | `societe.perimetre.mode` = agence_responsable | UpdateCompany · S-SP3 | ok | ok · sans alerte · évts CompanyUpdated | ✅ CONFORME |
| 201 | `societe.perimetre.mode` = partagee | UpdateProject · S-SP4 | refus DROIT | refus DROIT « permission absente ou hors périmètre » | ✅ CONFORME |
| 202 | `staffing.inter_agences` = non | PositionCandidate · S-SI1 | refus DROIT | refus DROIT « staffing inter-agences refusé » | ✅ CONFORME |
| 203 | `staffing.inter_agences` = oui | PositionCandidate · S-SI1 | ok · inchangé profil_candidat.agence_id (LYO) | ok · sans alerte · évts CandidatePositioned+NeedStateChanged | ✅ CONFORME |
| 204 | `staffing.inter_agences` = oui | PositionCandidate · S-SI2 | refus DROIT | refus DROIT « permission absente ou hors périmètre » | ✅ CONFORME |
| 205 | `staffing.inter_agences` = non | CreatePrestation · S-SI3 | refus DROIT | refus DROIT « staffing inter-agences refusé » | ✅ CONFORME |
| 206 | `staffing.inter_agences` = oui | CreatePrestation · S-SI3 | ok · inchangé profil_ressource.agence_id (LYO) | ok · sans alerte · évts PrestationCreated | ✅ CONFORME |
