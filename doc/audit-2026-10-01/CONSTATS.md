# Constats du dixième audit — commit `16ea24d` (branche `lot-2`)

Constats **neufs**, numérotés à la suite : V-162 →. Chacun porte, comme l'exige `_ops/prompt-audit-9.txt` :
**Famille** (la règle violée, pas le cas) · **Étendue** (mesurée) · **Correction de construction** (ce qui rend la
famille impossible) + la **porte** qui énumère la famille. ⛔ Aucun « corriger la ligne X ».

Suivi des 15 constats du 9e tour et des décisions D-48 → D-55 (`SUIVI_V.md`) : **11 fermés · 1 confirmé · 2 partiels
(V-147 critique, V-151) · 1 ouvert (V-156, 5e tour)** · D-48 → D-55 : **8 codées et gardées**.

Les preuves sont sous `rapport/preuves/` : `suivi10/` (S), `grille10/` (G), `conformite10/` (C), `securite10/` (I),
`banc/` (sabotages et cliquet), `aveugles10/` (sabotages aveugles rejoués à la main).
Les brouillons de travail (`brouillons/`) gardent leurs numéros internes (G-x, H-x, I-x) : la table de
correspondance est à la fin.

**18 constats neufs : 3 critique · 8 elevee · 6 moyenne · 1 bonne.**

---

### V-162 — « Servie » est déclaré, jamais calculé : des valeurs acceptées par `SetPolicy` ne font rien
Cible        CODE + BRAIN · Gravité **critique** — c'est la famille V-147, et elle s'étend au lieu de se fermer
Famille      *Une valeur n'est servie que si une commande servie lit la clé et branche sur CETTE valeur, avec l'effet
             que le registre lui donne.*
Étendue      **Valeurs sans lecteur** : 108 clés de `COMPORTEMENTS` n'ont aucun lecteur (ni `pol()`, ni lecture SQL) ;
             **202 valeurs hors défaut** sont acceptées par `SetPolicy` sans effet, dont **66 sur 45 clés métier**.
             Mesuré : `SetPolicy rh.contrat.obligatoire_avant_prestation = oui` → ok, `commandes_affectees = []`, puis
             une prestation signée pour une ressource sans contrat → ok. 8 de ces clés sont « hors V1 » au registre, et
             leur valeur active est pourtant servie.
             **Valeurs lues mais fausses** (6, mesurées par appel) : ① `temps.periode = dates_prestation_et_mois_ouvert`,
             la valeur la plus stricte, **retire la garde** (des temps au 16/03/2027, au 02/01/2025 et au 01/01/2031 sont
             écrits sur une prestation de sept.–déc. 2026) ; ② `change.mode = taux_saisi` refuse toute prestation en
             devises mixtes, et aucune clé ne permet de saisir le taux ; ③ `besoin.pourvu.mode =
             auto_par_personne_signee` lève la garde §C-2 **aussi** pour l'appel direct de `DeclareNeedFilled` ;
             ④ `temps.plafond_jour = refus_avec_derogation_tracee` se comporte comme `refus` ; ⑤ `projet.cloture.garde =
             cascade_cloture_prestations` : `CloseProject` tombe dès qu'une prestation est déjà terminée (la cascade
             passe la date du jour) ; ⑥ `projet.creation_depuis_besoin = automatique_au_retenu` ne crée aucun projet.
             **Politiques liste** (33 en base, hors D-42) : `doublon.societe.cles = ["telephone"]` accepté → deux sociétés
             identiques créées sous `bloquer` ; `candidat.complete.champs_requis = ["zz_colonne_inexistante"]` accepté →
             `CompleteCandidate` devient impossible. `SetOwnTheme` écrit `ui.palette = zz_non_servie`, que `SetPolicy` refuse.
Preuve       S `04_v147.txt`, `13_non_lues.txt`, `02_comportements_couverture.txt` · C `politiques_lues_et_servies.txt`,
             `valeurs_sans_entree.txt` (H5, H6, H9, H10, H15, H16)
Correction   **Construction** : une valeur servie est **une entrée d'une table de stratégies**
             (`COMPORTEMENTS[cle][valeur] = fonction`), appelée par recherche, sans `if`/`else` où une valeur tombe dans le
             `else` d'une autre. `COMPORTEMENTS` n'est plus écrit à la main : il se dérive de la carte calculée ; une clé sans
             lecteur n'a que sa valeur par défaut servie, et `politique_valeur_servie` se régénère. Une valeur qui exige
             une entrée (taux, dérogation) déclare sa clé dans `DECLARATION`. Les politiques liste déclarent le domaine de
             leurs éléments. `SetOwnTheme` passe par la même garde que `SetPolicy`.
             **Porte** : (a) toute clé à plus d'une valeur servie a au moins une commande lectrice dans la carte du banc ;
             (b) **différentiel** : le même scénario joué sous chaque valeur servie d'une clé — deux valeurs à l'issue
             identique partout → rouge, sauf alias déclaré au registre ; (c) chaque issue est comparée à celle du registre
             (V-163).

### V-163 — Le métier est écrit en dur hors des politiques : un réordonnancement d'affichage bloque toutes les signatures
Cible        CODE · Gravité **critique** — un réglage permis à l'administrateur casse le cycle commercial
Famille      *Une décision métier n'est portée ni par un littéral, ni par un nom de commande, ni par une colonne
             administrable détournée (`ordre`) : elle passe par une politique ou une catégorie fermée.*
Étendue      **`ordre` porte du sens** : `cycle.ts` (`codeStatutCommercial(ctx, 1|2|3)`, `REQUALIF_ORDRE`),
             `crm.ts:100` (`actuelOrdre === 2 && viseOrdre === 1`), la vue `v_societe_statut` (migration 022). Mesuré :
             `ManageRefs ref_statut_commercial client ordre=7`, geste permis à ADM, → **toute signature d'un prospect
             tombe** (`GARDE aucun statut commercial actif d'ordre 2`). Les 3 codes ont tous la catégorie `defaut`.
             **Noms de commande dans la garde générique** : 3 (`agence.ts:251` `CreateNeed`, exempté sous `par_besoins` — on
             crée alors un besoin sur une société de n'importe quelle agence, règle écrite nulle part ; `:326`
             `ArchiveObject` ; `:420` `TransferContact`). **Défauts métier en dur** : 4 (`"principal"`, `"regie"`,
             `"postes"`, l'état `'ouvert'` inséré tel quel). **Littéraux SQL** de codes et catégories métier : 27, que le
             grep B1 de la grille ne voit pas. Échelle de note : borne basse 0 pour toutes les échelles (`note = 0`
             acceptée sous `1_5`).
Preuve       C `ordre_semantique.txt`, H7 · G `b1_et_hors_grille.txt`
Correction   **Construction** : `ref_statut_commercial` reçoit une catégorie fermée (`prospect`, `client`,
             `ancien_client`) et le serveur lit **par catégorie**, comme les autres machines ; `ordre` ne sert plus qu'au tri.
             Les exemptions de garde se déclarent dans `DECLARATION`, la garde lit la déclaration. Les défauts deviennent
             des politiques.
             **Porte** : (a) pour chaque `ref_*` lue par le serveur, une passe qui **permute `ordre`** puis rejoue les 57
             positifs → résultats identiques ; (b) AST : aucune comparaison `ctx.commande === "…"` hors `executer.ts` ;
             (c) AST : tout littéral comparé dans une requête ou un `if` est une catégorie fermée déclarée, sinon rouge.

### V-164 — Les portes de politique tirent leur attendu du code, pas du registre
Cible        BRAIN CODE + CODE · Gravité **critique** — des portes vertes certifient le défaut V-162 ①
Famille      *L'attendu d'un couple (clé, valeur) vient du registre (colonne « Effet »), jamais du comportement observé.*
Étendue      **3 portes vertes affirment l'inverse du registre** : **P-233** exige qu'un temps hors prestation **passe**
             sous `mois_ouvert` (c'est la garde retirée) ; **P-230** exige que `taux_saisi` refuse, alors que le registre
             dit « conversion au taux saisi » ; **P-215** exige une alerte pour `automatique_au_retenu`, alors que le
             registre dit « crée le projet ». **P-221** ne joue qu'une prestation qui finit en novembre et ne voit jamais
             l'échec ⑤. **P-350** (« chaque valeur a une branche ») se satisfait d'une variable utilisée ailleurs :
             `temps.periode` passe sans branche sur `mois_ouvert`. La porte de D-42 (« comme le registre le dit ») n'existe
             que pour les 8 clés de P-354. Sabotage Q5 (une valeur lue puis ignorée) : P-133 et P-350 tombent — la
             porte voit l'oubli d'une branche, pas une branche fausse.
Preuve       `test/contrat/v011-politiques.ts` (P-215 l. 167-189, P-230 l. 726-751, P-233 l. 796-810) · S `09_portes.txt`
Correction   **Construction** : l'effet attendu de chaque couple devient au registre une **donnée lisible par la
             machine** : (commande, scénario, issue ∈ {ok, alerte:CODE, GARDE, ETAT, écrit:table.colonne}). Les cas de porte
             s'en génèrent ; un couple sans effet écrit ne peut pas être servi.
             **Porte** : le produit politique × valeur servie × commande lectrice (carte) joué contre l'issue du registre.

---

### V-165 — La porte croisée a des lignes qu'elle ne juge pas
Cible        BRAIN CODE · Gravité **elevee** — c'est la porte de la famille critique V-149
Famille      *Chaque ligne d'une porte a un attendu et un verdict ; « PERMIS » ou « noté » n'en est pas un.*
Étendue      Sous `societe.perimetre.mode ≠ défaut`, un identifiant qui vise une société ou un contact est classé
             `PERMIS:<table>` **quel que soit** le résultat, écriture comprise : **60 lignes non jugées** (30 sous
             `par_besoins`, 30 sous `partagee`). Plus **13 positifs notés KO** sous `par_besoins`, jamais jugés, dont
             `SignPrestation` d'un projet de PAR sur une société de PAR (la cascade `RequalifyCompany` exige un besoin).
             Un serveur qui traiterait `par_besoins` comme `partagee` resterait vert. L'empreinte étant globale, un autre
             processus qui écrit produit de fausses fuites (2 mesurées).
Preuve       S `03_porte_croisee_detail.json` · G `p339_detail.json`, `p339_passe1_PARASITEE_*`
Correction   **Construction** : l'attendu de chaque passe se **calcule** depuis la sémantique de la valeur (`partagee` :
             ok si l'acteur a la commande sur une agence ; `par_besoins` : ok ssi il l'a sur l'agence d'un besoin de la
             société) ; aucun verdict sans comparaison ; l'empreinte se prend par transaction (`txid`), pas par diff global.
             **Porte** : dans la porte croisée elle-même, 0 ligne sans attendu ; un PERMIS refusé ou un REFUS accepté → rouge.

### V-166 — Une transition d'état s'écrit hors de sa commande, et par deux entrées aux gardes différentes
Cible        CODE + BRAIN CODE · Gravité **elevee** — droit contourné, mesuré
Famille      *Une transition d'un objet appartient à UNE commande ; toute autre commande ne l'écrit que par
             `executerDans`, et la liste des cascades se calcule.*
Étendue      3 commandes écrivent `UPDATE besoin SET etat_code` (la transition de `TakeNeedInCharge`) via
             `maybeStaffing` : `PositionCandidate`, `PositionResource`, `RecordClientDecision`. Mesuré : IA, refusé DROIT
             sur `TakeNeedInCharge` en direct, fait passer 2 besoins en recherche. `CASCADES` est écrite à la main et
             P-347 ne cherche que ce qui y figure. `CreatePrestation {etat: "signee"}` crée une prestation **engagée sans
             TJM ni jours vendus**, que `SignPrestation` aurait refusée ; M-14 fige ensuite ces `null`. Aucune cascade
             n'ouvre de `SAVEPOINT`, et `effetsSignature` avale les GARDE de la fille.
Preuve       S `05_v148_v149.txt` · C H4a, H4b, H5
Correction   **Construction** : chaque (table, colonne d'état) a une commande propriétaire déclarée dans `DECLARATION` ;
             l'effet est **une** fonction qui porte sa garde, appelée par toutes ses entrées ; `CASCADES` se dérive des
             appels `executerDans`.
             **Porte** : chaque `UPDATE`/`INSERT` d'un handler porte sur sa cible déclarée, sinon il passe par
             `executerDans` ; pour chaque effet atteignable par plusieurs entrées, le même jeu de refus joué par chacune.

### V-167 — Deux horloges pour « aujourd'hui »
Cible        CODE · Gravité **elevee** — D-53 dit que l'horloge se calcule à la lecture ; elle se calcule à deux endroits
Famille      *La date du jour a UNE source par transaction.*
Étendue      4 sites lisent l'horloge de Node en UTC (`ClosePrestation` par défaut, cascade de `CloseProject`,
             `DeclareCVShared`, `RecordClientDecision`) ; 3 lisent celle de la base (`CancelPrestation`,
             `RecordQualification`, les vues D-53). **Prouvé**, base réglée sur UTC+14 pendant la sonde, au même instant :
             `date_cloture = 2026-10-01`, `date_annulation = 2026-10-02` ; une prestation du 02/10 met la ressource « en
             mission » dans la vue alors que le jour JS est le 01/10. À Casablanca (UTC+0), les deux coïncident par hasard.
Preuve       I `deux_horloges.txt`
Correction   **Construction** : une seule horloge, la base ; `executerCommande` lit `current_date` une fois
             (`ctx.aujourdhui`) ; le fuseau de session est posé par le pool depuis un réglage d'installation.
             **Porte** : (a) AST : aucun `new Date(` dans `server/src/commandes` ; (b) une passe de banc avec la base à
             UTC+14 compare toutes les dates écrites à `current_date`.

### V-168 — Règles d'horloge : l'écran lit l'état dérivé, la commande juge l'état écrit
Cible        CODE · Gravité **elevee**
Famille      *Une transition se juge sur l'état que l'utilisateur voit.*
Étendue      Sous `auto_apres_delai`, une société cliente sans prestation depuis plus de 6 mois **se montre** `prospect`,
             mais `RequalifyCompany → client` refuse « client → client hors cycle ». 4 consommateurs de l'état écrit :
             `RequalifyCompany`, `effetsSignature`, `retourSiDernierContrat`, `SetResourceState`.
Preuve       C H12
Correction   **Construction** : les commandes lisent la **même** vue que l'écran pour juger une transition.
             **Porte** : pour chaque vue D-53, un scénario où lu ≠ écrit : les actions offertes par la vue et le verdict de
             chaque commande concernée concordent.

### V-169 — Une entrée bien typée mais hors domaine sort en 500 ou en MUR
Cible        CODE · Gravité **elevee** — L4 : « jamais un 500 », « un MUR visible est un bug de garde »
Famille      *La déclaration porte le domaine de chaque valeur, pas seulement sa forme.*
Étendue      Sonde automatique sur chaque clé `valeur` déclarée (date `2026-02-30`, décimal à 30 chiffres, code
             `zz_inconnu`, liste `[1]`) : **121 sondes · 32 × 500 · 8 × MUR**, soit 21 clés de 14 commandes en 500 et 5 clés
             en MUR. À l'inverse, `profil_candidat.provenance = "zz_inconnu"` est **écrit** (ni clé étrangère, ni contrôle).
Preuve       I `scripts_a10b/t_fuzz.mjs` et sa sortie
Correction   **Construction** : chaque `code` déclare sa table de référence, chaque décimal sa précision (lue dans le
             catalogue), chaque date un aller-retour calendrier ; `remplirValeurs` refuse GARDE avant le handler ;
             `pgMur` traduit toutes les classes `22`, `23`, `P0`.
             **Porte** : cette sonde sur toutes les clés `valeur` de `DECLARATION` : 0 × 500, 0 × MUR, 0 code inconnu écrit.

### V-170 — Les portes énumèrent une liste écrite à côté du serveur, pas le serveur
Cible        CODE · Gravité **elevee**
Famille      *Ce qu'une porte énumère (routes, écrivains, commandes) se lit dans le serveur lui-même.*
Étendue      **Commandes** : `POST /commandes/constructor` (et `toString`, `__proto__`… 7/7) → **500** après ouverture
             d'une transaction : les tables de routage héritent d'`Object.prototype`, P-339 énumère `Object.keys`.
             **Routes** : `GET /tuyau` et `POST /acquitter` hors `LECTURES`, 200 sans identité en banc.
             **Écrivains** : `assurerBancRes` (exclu de l'extraction ; son `UPDATE compte` n'est même pas accordé),
             `tracerRefus` (écrit le corps entier d'une requête **sans compte**, jusqu'à 1 Mo), 3 migrations de données
             (16 écritures, dont 2 dont la recherche d'auteur ne peut rien trouver), la carte D-42 dans `os.tmpdir()`
             partagée par tous les serveurs de banc du poste.
Preuve       I I-2, I-3, I-4 · `migrations_ecritures_donnees.txt`
Correction   **Construction** : toute table indexée par une entrée est un `Map` ; les routes s'enregistrent **depuis**
             `LECTURES` ; un registre unique des écrivains extrait de `server/src` entier, des fonctions SQL et des
             migrations ; la fixture remplace `assurerBancRes` ; la carte est nommée par processus.
             **Porte** : `app.printRoutes()` = `LECTURES` ∪ {`/sante`, `/commandes/:nom`} ; les membres
             d'`Object.prototype` comme nom de commande → INTROUVABLE ; P-325 sans exclusion de fichier.

---

### V-171 — Des identifiants d'objet sont déclarés `valeur` : un oracle d'existence entre agences
Cible CODE · **moyenne** (aucune fuite d'écriture : la défense tient à une ligne du handler) · Famille : *`type: "uuid"`
interdit le rôle `valeur`.* · Étendue : 4 champs qui portent une agence (`CreateUnit.agence`/`agence_id`,
`ValidateTimesheet.id`, `RejectTimesheet.id`), 4 d'installation. `ValidateTimesheet` avec l'`id` d'un temps de LYO →
« temps d'une autre prestation », un UUID inexistant → INTROUVABLE : l'existence se lit à travers les agences ·
Correction : `Champ` en union discriminée (`uuid` ⇒ `cible|reference` + table), refusée à la compilation ; **porte** :
0 champ `uuid` en `valeur`, et la porte croisée génère ses cas depuis tous les `uuid` · Preuve S `01_declaration_roles.txt`.

### V-172 — `commandes_affectees` de `SetPolicy` reste écrite à la main, et fausse (D-42 non codée)
Cible CODE · **moyenne** · Famille : *ce que `SetPolicy` annonce se lit dans la carte calculée.* · Étendue : 3 clés lues
→ `[]` (`societe.perimetre.mode` et `staffing.inter_agences`, les deux politiques de périmètre, et
`besoin.unite_couverture`) ; 2 clés listées pour toutes les commandes alors qu'aucune ne les lit ; attributions fausses
(`ArchiveObject`, `TakeNeedInCharge`) ; `CloseProject` omis · Correction : `commandesDe(clé)` lit la carte du banc,
cascades comprises, versionnée ; **porte** : carte versionnée = carte de ce `make test`, et 0 clé lue à `[]` ·
Preuve S `14_carte_politiques.txt`.

### V-173 — L'histoire photographie les politiques à l'émission, pas au commit
Cible CODE · **moyenne** · Famille : *chaque événement porte toutes les politiques lues par sa transaction.* · Étendue :
100 % des `ProjectCreated`, `ProjectCreatedFromNeed`, `CandidatePositioned`, `ResourcePositioned`,
`ClientDecisionRecorded` mesurés n'ont pas la politique lue après l'émission ; 5 clés lues en SQL ne sont jamais tracées ·
Correction : événements insérés au COMMIT avec la photographie finale, lectures SQL notées dans une table de transaction ;
**porte** : clés de la carte ⊆ `liens.politiques` de chaque événement · Preuve C H-5.

### V-174 — Le contrat L4 et `DECLARATION` divergent
Cible CODE + BRAIN · **moyenne** · Famille : *les clés d'une commande vivent dans un seul texte, l'autre se génère.* ·
Étendue : **4 entrées du contrat refusées** (`ArchiveService`, `ArchiveContact` exigent `motif` ; `ValidateTimesheet`,
`RejectTimesheet {temps_ids}` → « entrée ambiguë ») ; **16 commandes** déclarent des clés hors contrat ; 1 clé lue jamais
déclarée (`RecordQualification.commentaire`, jamais écrite) ; 2 codes de refus différents du contrat · Correction : la
colonne Entrée de L4 se génère depuis `DECLARATION` ; **porte** : L4 = `DECLARATION` = clés lues, dans les 3 sens ·
Preuve C `tableau_H.md`, H1a → H1g.

### V-175 — Des gardes en double sont du code mort, et un refus contractuel n'a aucune porte
Cible CODE (banc) · **moyenne** (0 fuite mesurée) · Famille : *une règle est tenue à UN endroit, et chaque code de refus
du contrat a une porte qui l'exige.* · Étendue : **4 sabotages sur 56 ne font tomber aucune porte**, rejoués à la main
sur le serveur saboté contre le code intact : `exigeSoiMeme` désactivé (T4) ou retiré de `RecordTimesheet`
(S4_RecordTimesheet_S) → **mutant équivalent**, 15 refus identiques, 0 écriture : la garde d'agence refuse avant
(`agence.ts:428`), `exigeSoiMeme` n'est **jamais** la ligne qui refuse ; la boucle de synonymes de `noter` (R8) → code
mort, `replier` recopie l'alias avant (23 groupes, 81 lectures, 0 alias lu seul) ; `TransferContact` vers une société
**inexistante** (R7) → le refus passe d'INTROUVABLE à GARDE sans qu'aucune porte ne le voie (V-155, 5e tour sur ce
geste). ⚠️ Le raccourci `soiSurCettePersonne` (`agence.ts:427`) saute `exigerToutes` dès que l'entrée vise soi : il
n'est fermé que par une ligne du handler (`identite.ts:384`) · Correction : la règle `soi` vit dans la garde seule
(`exigeSoiMeme` disparaît, le raccourci juge **tous** les objets lus) ; `noter` et `replier` fusionnent ; **porte** :
pour chaque code de refus de la colonne « Refuse si » de L4, un cas qui l'exige — un sabotage qui change le code rendu
fait rougir · Preuve `preuves/aveugles10/RESULTAT.md`, `preuves/banc/_JOURNAL.txt`.

### V-176 — Un canon du BRAIN modifié sous `Role: banc`
Cible BRAIN (gouvernance) · **moyenne** · Famille : *`_ops/PORTE_CROISEE.mjs`, `_ops/JEU_ESSAI.sql`,
`_ops/SPEC_ASSERTIONS_L7.sql` ne s'écrivent que sous `Role: brain`.* · Étendue : 1 commit (`e9476b8`) depuis `071b7b2`,
qui ajoute `ValidateTimesheet`/`RejectTimesheet` **sans** le champ `id` (V-171) — contraire à D-49 · Correction : le hook
de commit refuse ; **porte** : case du cliquet qui exige `Role: brain` sur chaque commit d'un canon.

### V-177 — Le cliquet lit deux colonnes par position
Cible CODE (banc) · **moyenne** · Famille : *une colonne de `PORTES.md` se lit par son en-tête (V-009).* · Étendue :
cases 5 et 10 sur 19 (`$6`, `$7`, `$8`) ; justes aujourd'hui, fausses en silence au premier `|` dans une phrase ·
Correction : une seule fonction `colonne "<En-tête>"` ; **porte** : le cliquet joué sur un `PORTES.md` aux colonnes
permutées rend les mêmes verdicts.

---

### V-178 — Bien fait, à garder
Cible CODE + BRAIN · **bonne**
- **La construction du 9e tour a pris** : la garde juge chaque objet résolu sous chaque valeur de périmètre (5 passes,
  691 identifiants, **0 fuite**) ; les cascades passent par `executerDans` ; `ctx.entree` est sorti du type des
  commandes (0 lecture) ; GRANT par colonne exact ; hors banc, tout est 401 avant l'analyse du corps.
- **Les 5 sabotages de construction de ce tour sont tous vus** : cascade sans garde (Q1, 250+ portes), lecture sous
  n'importe quelle permission (Q2, P-349), une seule agence jugée (Q3, P-290 P-339), référence muette (Q4), valeur lue
  puis ignorée (Q5, P-133 P-350).
- D-48 → D-55 codées et gardées ; 11 des 13 valeurs du 9e tour font ce que dit le registre ; l'horloge D-53 est en vues,
  sans tâche planifiée.

---

## Correspondance avec les brouillons

| Constat | Brouillons |
|---|---|
| V-162 | SUIVI V-147 ①→⑥ et V-162 · CONFORMITE H-2 |
| V-163 | CONFORMITE H-3 · GRILLE G-1 |
| V-164 | SUIVI V-163 |
| V-165 | SUIVI V-164 · GRILLE G-3 |
| V-166 | SUIVI V-165 · CONFORMITE H-4 · SECURITE I-5 |
| V-167 | SECURITE I-6 |
| V-168 | CONFORMITE H-7 |
| V-169 | SECURITE I-1 |
| V-170 | SECURITE I-2, I-3, I-4 |
| V-171 | SUIVI V-166 |
| V-172 | SUIVI V-167 · CONFORMITE H-6 |
| V-173 | CONFORMITE H-5 |
| V-174 | SUIVI V-151 (partiel) · CONFORMITE H-1, H-8 |
| V-175 | MUTATIONS (sabotages S4_RecordTimesheet_S, T4, R7, R8) |
| V-176 | SUIVI V-168 |
| V-177 | GRILLE G-2 |
| V-178 | SUIVI V-169 |
