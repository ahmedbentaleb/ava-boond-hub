# Arbitrage du neuvième audit — 29/09/2026

Audit sans compromis (Hamada, 29/09), commit `071b7b2`, verdict **REFUSÉ**. 15 constats neufs (V-147 → V-161 :
3 critiques · 7 élevés · 4 moyens · 1 bon), chacun avec sa **famille**, son **étendue mesurée** et sa
**correction de construction**. ⭐ **La construction a pris** : la porte croisée est au banc (55 commandes,
117 identifiants, 0 fuite, et retirer une déclaration la fait tomber) ; 8 règles de construction sur 10
gardées sous sabotage. Ce qui refuse : trois familles **que la porte croisée ne regarde pas**.

<etat>

## ⬜ CE QUI RESTE À FAIRE

| # | Famille | Décision | Constats | Qui | État |
|---|---|---|---|---|---|
| 1 | ⭐ **Une seule déclaration typée par commande** — tout en dérive | D-45 | V-151 V-152 V-155 V-158 | CODE | ⬜ |
| 2 | **Chaque valeur de politique a un comportement, ou elle est refusée** | D-42 | V-147 | CODE + BRAIN CODE | ⬜ |
| 3 | **Une cascade est une commande** | D-43 | V-148 | CODE | ⬜ |
| 4 | **Le mode société ne juge que la société** ; la porte croisée jouée sous chaque valeur de périmètre | D-44 | V-149 | CODE + BRAIN CODE | ⬜ |
| 5 | **La lecture a ses propres droits** | D-46 | V-150 | BRAIN ✅ canon · CODE | ⬜ |
| 6 | Le banc : P-339 ✅ ; les délégations comparées avant/après ; `make test` rejouable | D-47 | V-153 V-156 V-159 | CODE (`Role: banc`) + BRAIN CODE | ⬜ |
| 7 | GRANT calculé **par colonne**, sur les deux rôles ; empreinte des migrations | — | V-154 V-157 | BRAIN CODE | ⬜ |
| 8 | Grille : K2 au lot 2c ; registre §E | — | V-160 | BRAIN | ✅ |
| 9 | Dixième audit, même exigence | — | — | AUDIT | ⬜ `audits-independants/ava-audit-10`, base `ava_audit10`, port 4000 |

</etat>

⭐ **La règle de ce tour, pour toutes les décisions** : chaque correction arrive avec **sa porte d'énumération**,
**vue rouge avant d'être verte**, et la porte tire ses cas **de la déclaration ou du serveur**, jamais d'une
liste écrite à la main.

## ⭐ D-45 — UNE SEULE DÉCLARATION TYPÉE PAR COMMANDE (V-151, V-152, V-155, V-158)

Aujourd'hui trois listes tenues à la main (clés acceptées, lecteurs d'`agence.ts`, cas de la porte croisée)
divergent : 157 lectures directes de `ctx.entree`, 29 commandes relisent `id`, des clés acceptées puis
ignorées (`ConvertCandidateToResource` : Lyon demandée, ressource créée à Paris).

| Règle | Tranché |
|---|---|
| **La déclaration** | pour chaque commande, **une** entrée : `clé → { rôle : cible · référence · valeur, table si objet, type : uuid · date · décimal · texte · code(ref_x) · liste }` |
| **Ce qui en dérive, par le code, jamais recopié** | la liste des clés acceptées · les lecteurs de la garde d'agence · la validation de type de l'entrée · les cas de la porte croisée · la porte de types (mauvais type sur chaque clé → `GARDE`) |
| **Le handler ne voit plus l'entrée** | ⛔ il reçoit `ctx.resolues` (les objets) et `ctx.valeurs` (les valeurs typées, **sans aucun identifiant**) — `ctx.entree` **n'existe plus** dans le type du contexte des commandes. La règle est tenue par le **compilateur**, pas par une relecture |
| **Une clé déclarée, un effet** | une clé déclarée et jamais lue par le handler fait rougir une porte statique (plus de « Lyon demandée, Paris créée ») |
| **`TransferContact` (4e tour)** | sa société d'arrivée est une **référence** déclarée : la porte croisée la couvre d'office — la famille se ferme sans porte écrite à la main |
| **Hors banc (V-158)** | l'authentification passe **avant** l'analyse du corps ; un corps mal formé, d'un autre type ou trop gros → `400` après `401`, jamais `500` |

## ⭐ D-42 — CHAQUE VALEUR DE POLITIQUE A UN COMPORTEMENT, OU ELLE EST REFUSÉE (V-147)

Mesuré : 11 valeurs sur 7 politiques acceptées sans code — la plus stricte de `temps.periode` **retire** la
garde ; `temps.validation = par_dp` bloque toute saisie ; `change.mode = taux_saisi` fait tomber la clôture
en `MUR`. Et `besoin.unite_couverture` n'est lue par personne (`CreateNeed` code `postes` en dur).

| Règle | Tranché |
|---|---|
| **Table de comportements** | côté serveur, `COMPORTEMENTS[clé][valeur]` : une entrée par valeur **servie** ; `pol()` ne rend qu'une valeur qui y figure |
| **Une valeur non servie est refusée** | `SetPolicy` → `GARDE` « valeur non servie » ; en base, une table des valeurs servies et un contrôle qui refuse les autres (BRAIN CODE) ; une porte compare la table et `COMPORTEMENTS` |
| **La carte se calcule** | `pol()` enregistre `(commande, clé)` à chaque lecture pendant le banc ; une clé lue par une commande **servie** doit avoir **toutes** ses valeurs servies |
| **Les 11 valeurs** | elles sont lues par des commandes du lot 2 : elles se **codent** dans ce tour, selon la colonne « Effet » du registre. ⛔ Si l'effet ne suffit pas pour coder → `journal/QUESTIONS.md`, le BRAIN tranche — jamais une valeur codée au jugé |
| **`besoin.unite_couverture`** | lue par `CreateNeed` ; plus de `postes` en dur |
| **La porte** | toutes les politiques lues × toutes leurs valeurs × chaque commande qui les lit : la valeur change le comportement **comme le registre le dit**, et ne lève jamais hors d'un refus contractuel |

## ⭐ D-43 — UNE CASCADE EST UNE COMMANDE (V-148)

| Règle | Tranché |
|---|---|
| **Construction** | une écriture en cascade appelle la commande fille par `executerCommande` (droit, garde d'agence, événement) ; ⛔ jamais une table écrite directement par une autre commande |
| **La liste des cascades est une donnée** | `CASCADES` : mère → fille(s), déclarée à côté des déclarations de commandes ; une écriture hors de sa commande fait rougir une porte statique |
| **Atomique** | si la fille est refusée, **la mère est refusée entière**, rien n'est écrit : STAF sans `ClosePrestation` ne clôt pas un projet qui a une prestation signée |
| **Les états dérivés** (la société qui passe « client ») | une cascade comme les autres, avec la garde de l'agence de la société |
| **La porte** | pour chaque cascade déclarée : un acteur qui a la mère sans la fille → `DROIT` ; une fille d'une autre agence → `DROIT` ; rien écrit |

## ⭐ D-44 — LE MODE SOCIÉTÉ NE JUGE QUE LA SOCIÉTÉ (V-149)

`agence.ts:656` : quand un objet société ou contact est lu, `modeSociete` tranche et **rend la main** sans juger
les autres objets. Sous `partagee` ou `par_besoins`, Paris modifie un projet de Lyon en glissant un `contact_id`.

| Règle | Tranché |
|---|---|
| **Construction** | la garde juge **chaque** objet résolu, puis prend le verdict le plus strict ; `societe.perimetre.mode` ne s'applique **qu'**aux objets société et contact. Aucune branche ne rend la main avant d'avoir jugé tous les objets |
| **La porte** | la porte croisée jouée sous **chaque valeur de chaque politique de périmètre** : `societe.perimetre.mode` × 3, `staffing.inter_agences` × 2 — les valeurs sont lues au registre, pas écrites dans la porte |

## ⭐ D-46 — LA LECTURE A SES PROPRES DROITS (V-150)

⛔ **Trou du canon, le mien** : la MATRICE disait « qui voit quoi se règle par le périmètre, objet par objet »
sans dire **le périmètre de quelle permission**. Le code a pris celui de n'importe laquelle : un compte qui
n'a que `SetOwnTheme` (global) lit les 84 besoins des deux agences.

Tranché : **six permissions de lecture**, écrites dans la MATRICE (bloc « Lecture ») ; une route de lecture
exige **sa** permission, jugée sur **son** périmètre ; rien d'autre n'ouvre une lecture. Porte : routes ×
groupes × agences.

## D-47 — LE BANC

| V | Tranché | Qui |
|---|---|---|
| V-153 | P-339 (la porte croisée) passe ✅. ⛔ La porte croisée ne peut **jamais** être ⏳ : la case 14 vérifie la copie **et** qu'elle est ✅ et verte | CODE (`Role: banc`) + BRAIN CODE |
| V-156 (4e tour) | on arrête de regarder où est le `DELETE` : la case 17 **photographie les délégations avant `make test` et les compare après** — toute ligne disparue qui n'a pas été posée par le banc → KO ; l'aide commune supprime **par identifiant** ce qu'elle a inséré | BRAIN CODE (case) + CODE (aide) |
| V-159 | le jeu d'essai part d'une base **migrée à neuf**, jamais d'une copie de la base courante : `make test` se rejoue deux fois de suite | BRAIN CODE |

## Les autres constats

| V | Tranché | Qui |
|---|---|---|
| V-154 | GRANT calculé **par colonne**, depuis les colonnes que les commandes écrivent ; plus d'`INSERT` sur `politique` (seule `valeur` est écrite) ; la porte P-325 regarde les colonnes et **les deux rôles** (`ava_app`, `ava_serveur`) | BRAIN CODE |
| V-157 | empreinte sha256 de chaque migration dans `schema_migrations` ; une case du cliquet compare fichier et base | BRAIN CODE |
| V-160 | K2 (la session) marquée **lot 2c** dans la grille : le banc s'identifie par en-tête, c'est D-10, assumé | BRAIN ✅ |
| V-161 | ⭐ gardé : la porte croisée au banc, 8 règles de construction sur 10 sous sabotage, registre exact (202 = 202) | — |

## Décisions du 30/09 — les questions de Grok (Q-014 → Q-016)

⚠️ Le prompt « Brain Code, dixième tour » reçu le 30/09 a été écrit **par le codeur**. Ses points mécaniques
sont justes ; deux points sont des décisions de juge, tranchées ici, et un point manquait.

| Question | Tranché |
|---|---|
| Q-014 — 5 valeurs codées, retirées par 018 | **servies** par une migration 021 ; Grok les ajoute à `COMPORTEMENTS` après la fusion. ⚠️ Les **6 autres** des 11 valeurs ne sont ni codées ni déclarées : Grok rend leur liste ; chacune est **codée** (registre, colonne « Effet ») ou fait l'objet d'une question — jamais laissée muette |
| Q-015 — **D-48** | la MATRICE contredisait D-43 : le DP signe, mais les filles (`RequalifyCompany`, `DeclareNeedFilled`) n'étaient qu'à IA et STAF ; le banc les accordait en douce dans sa fixture. ⭐ **Qui a la mère a les filles** : le DP les reçoit au seed ; une porte vérifie, pour chaque cascade déclarée, que tout groupe titulaire de la mère a les filles. La fixture du banc n'accorde plus rien que le seed n'accorde |
| Q-016 — **D-49** | `staffing.inter_agences = oui` : les 4 écritures sont un **permis**, pas une fuite (D-38) — **à la condition mesurée** que le demandeur ait le droit dans l'agence du besoin ou du projet ; un besoin ou un projet d'une autre agence reste un **refus** même sous `oui`. `RequalifyCompany` reçoit ses cas `contact_id` et `besoin_id`. La porte est modifiée par le **BRAIN CODE**, jamais par le codeur |
| P-340 en double | collision de numéro créée par le BRAIN CODE : sa porte des valeurs servies prend le prochain numéro libre ; le passage ✅ → ⏳ est déclaré au tableau D-35 avec le motif « collision » |
| Le report sur `main` | c'est le **BRAIN**, pas le BRAIN CODE |

## Décisions du 01/10 — les six valeurs muettes (Q-017 → Q-022) et `par_dp`

⛔ Grok a déclaré « prêt pour le dixième audit » avec **6 valeurs de politique non servies** et `temps.validation =
par_dp` « codé » en **refusant toute saisie** (`projet.ts:480`, « exige une commande hors V1 ») — c'est le défaut
V-147 lui-même, déclaré servi. ⭐ **Le dixième audit ne part pas** avant ces décisions codées. Les effets sont
écrits au registre, colonne « Effet », pour qu'aucune valeur ne se code au jugé.

| Décision | Question | Tranché |
|---|---|---|
| **D-50** | Q-017 et `par_dp` | ⭐ **la validation des temps est en V1** (Hamada : « tout en V1 » ; l'emailing de Boond porte déjà le modèle « Relance de validation des temps »). `ValidateTimesheet` et `RejectTimesheet` entrent au lot 2 (100 commandes, 57 servies), au DP ; cycle `temps` (`a_valider` · `valide` · `rejete`) ; `par_projet` lit `projet.validation_temps` (défaut vrai, réglé par `UpdateProject`) |
| **D-51** | Q-018 | les trois modes automatiques de `besoin.pourvu.mode` distingués : couverture atteinte · première signature · alerte à confirmer |
| **D-52** | Q-019 | `retour_client_retenu` : la transition s'écrit à `RecordClientDecision` d'une décision `positive` — la valeur est servie |
| **D-53** | Q-020 | ⭐ **une règle qui dépend de l'horloge se calcule à la lecture** (vue), jamais par une tâche planifiée ; l'exception tracée a un motif et une date de fin |
| **D-54** | Q-021 | `auto_fin_dernier_contrat` : cascade à la dernière clôture ; `auto_apres_delai` : vue (D-53) |
| **D-55** | Q-022 | `creation_projet` : cascade `RequalifyCompany` à la création du projet ; STAF reçoit la fille au seed (D-48) |

## Ce que ce tour apprend

⭐ **Une règle tenue par une relecture finit toujours par être contournée ; une règle tenue par le type du
code ne peut pas l'être.** `ctx.entree` retiré du contexte des commandes vaut mieux que 157 corrections.

<source>

Rapport : `audits-independants/ava-audit-9/rapport/` (CONSTATS, SECURITE, CONFORMITE §3, GRILLE, SUIVI_V,
MUTATIONS, `preuves/securite9/07_valeurs_sans_code.txt`), copié dans `audit-2026-09-29/`. Mesures du BRAIN :
`MATRICE_DROITS_v1.md` l. 16-18 (la lecture renvoyée au périmètre, sans permission) ; routes de lecture
`server/src/index.ts:227`, `:268`.

</source>
