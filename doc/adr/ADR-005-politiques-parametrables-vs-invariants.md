# ADR-005 — Toute bifurcation est une politique ; seuls les invariants sont des murs

Date : 17/09/2026 · Statut : **décidé** (Ahmed, 17/09 au soir ; P1 = une base par société, P2 = (a), P3 = les 15 murs restent)

## Contexte

> « Toutes les règles doivent être paramétrables. Rien ne doit être codé en dur, pour qu'on puisse changer les décisions comme on veut : ces décisions vont différer d'une société à une autre. Toute décision qui est une bifurcation avec plusieurs options doit être paramétrable. C'est ce qui fait la richesse des bons managers. »

Les arbitrages F1–F36 et G1–G15 sont les choix d'**Avaliance aujourd'hui**. La SPEC 2024 voulait un projet **automatique** au besoin gagné (US6) ; DEC-06 l'a rendu explicite. Le CdC 2022 voulait un contact **obligatoire** sur le besoin ; DEC-04 l'a rendu facultatif. Ce sont des bifurcations : deux sociétés — ou Avaliance dans deux ans — choisissent différemment. Boond tire sa richesse de son administration (14 étapes candidat, 9 états positionnement, alertes, rôles). Un miniature qui grave ces choix dans des `if` perd exactement ça.

## Décision

### 1. Trois familles, et le registre dit laquelle pour chaque ligne

| Famille | Définition | Où ça vit | Paramétrable |
|---|---|---|---|
| **Politique** | une bifurcation à options nommées | table `politique` | ✅ en admin, tracé |
| **Référentiel** | une liste de valeurs (états, étapes, types) | tables `ref_*` à **catégorie sémantique** | ✅ vocabulaire, ajout dans une catégorie, ordre ; valeurs système protégées |
| **Mur** | ce qui garde les données **vraies** | contraintes DB (FK, CHECK, trigger, droits SQL) | ⛔ jamais |

Le registre `REGISTRE_POLITIQUES_v1.md` est la liste exhaustive. **Une bifurcation absente du registre est codée en dur par accident** — c'est un défaut, à corriger en ajoutant la ligne, pas en ajoutant un `if`.

### 2. Le mécanisme des politiques

```
politique (cle TEXT PK, valeur TEXT, type {enum,int,bool,list,decimal}, valeurs_possibles JSONB,
           valeur_defaut TEXT, categorie TEXT, libelle TEXT, description TEXT,
           modifie_le TIMESTAMPTZ, modifie_par_compte_id)
```

- **Lue à l'exécution** par un service `Politiques.get(cle)` (cache invalidé au changement). Jamais lue au démarrage seulement, jamais dans un fichier de config, jamais dans une variable d'environnement.
- **Changée par une commande** `SetPolicy` (Admin) → événement `PolicyChanged` avec avant/après (ADR-004). Un changement de politique est un fait métier daté.
- **Défaut = la décision d'aujourd'hui.** Installer Ava Manager sans rien toucher donne exactement le comportement F1–F36 / G1–G15.
- **Un changement ne réécrit pas le passé.** Il s'applique aux commandes futures. Chaque événement métier enregistre dans `liens` les clés de politique qu'il a lues et leur valeur au moment de l'exécution — on sait toujours sous quelle règle un fait s'est produit.
- **Portée V1 : l'installation** (P1 : une base par société). Une colonne `portee` n'existe pas en V1 ; une surcharge par agence serait une évolution, déclarée hors V1 au registre.

### 3. Les référentiels d'états

```
ref_etat_<objet> (code TEXT PK, libelle TEXT, categorie TEXT NOT NULL, ordre INT,
                  systeme BOOL NOT NULL DEFAULT false, actif BOOL NOT NULL DEFAULT true)
```

- Le **code** est stable ; le **libellé** se renomme en admin.
- La **catégorie** est fermée par le code (CHECK) : c'est sur elle que raisonnent les transitions, les gardes et les vues. Exemple : la garde F1/G1 lit « un positionnement dont l'état est de catégorie `terminal_positif` », pas « l'état vaut `retenu` ».
- Un admin **ajoute** une valeur dans une catégorie (« retenu sous réserve » en `terminal_positif`), **renomme**, **désactive** une valeur non système. Il ne supprime pas, ne change pas la catégorie d'une valeur utilisée, ne touche pas aux valeurs `systeme = true`.
- Les **transitions restent en code**, exprimées sur les catégories (P2 = (a)). L'éditeur de transitions en admin est un moteur de workflow : hors V1 (F16 tient).

### 4. Les murs

Les 15 interdits du modèle métier (I-1 → I-15) sont des contraintes de base de données. Ils ne sont pas des choix : ce sont les conditions pour que les temps saisis, les snapshots de marge, l'historique et les droits **veuillent dire quelque chose**. Un mur se conteste **avec une source**, pas avec une préférence — et s'il tombe, c'est par une ADR, pas par une politique.

## Motif

Un `if` sur un choix métier est une décision **cachée** : personne ne la voit, personne ne la change sans un développeur, et personne ne sait sous quelle règle un fait passé s'est produit. Une table de politiques rend la décision **visible, changeable, datée**. Le prix : chaque commande lit ses politiques et le code a des branches — c'est le même code qu'avec des `if`, sauf que la condition vient d'une table.

Le contre-risque, c'est le **tout-paramétrable** : si l'immuabilité de la ressource est un réglage, un admin pressé la désactive un soir et les temps de Jean se retrouvent sur Paul. Un test qu'on peut assouplir soi-même n'est pas un filet. D'où les murs.

## Conséquences

- Le livrable 5 contient `politique`, un `ref_etat_*` par cycle, et des **CHECK seulement sur les catégories et les murs** — jamais sur une liste de codes métier.
- Le mock 5b montre l'écran **Administration › Politiques** : une ligne par bifurcation, sa valeur, son effet en une phrase.
- Le brief exécutant porte la règle de revue : **aucun `if` métier sans clé au registre**.
- La reprise Boond (G13) mappe les états Boond vers des **codes** de référentiel, éventuellement créés pour l'occasion dans la bonne catégorie — sans toucher au code.
- Les simulations S1–S15 se rejouent sous les défauts ; changer une politique et rejouer est le test de non-régression naturel du mécanisme.

## Écarté

| Option | Pourquoi non |
|---|---|
| Un moteur de règles générique (DSL, expressions évaluées) | On construit une plateforme au lieu d'un produit ; personne ne relit un DSL dans six mois. Une bifurcation = une clé enum suffit. |
| Politiques en fichier de config ou variables d'environnement | Pas d'admin, pas d'événement, pas de « sous quelle règle ce fait s'est produit ». |
| Éditeur complet de transitions en admin (P2-b) | C'est l'éditeur de process que F16 a différé. ×3 sur le livrable et l'exécution. |
| Tout paramétrable, murs compris | Voir motif. Les données cessent d'être vraies. |
| Multi-tenant pour « d'une société à une autre » (rouvrir G5) | P1 : une base par société. Les politiques rendent chaque installation adaptable ; un tenant_id ne rendrait rien de plus adaptable, seulement tout plus lourd. |

## Amendement — 17/09/2026, 23h30 — la forme physique de M-15

Cette ADR exige une forme DB pour chaque mur. Pour **M-15** (ATL-17 : pas d'agrégat multi-devises sans taux), aucune contrainte de table ne peut interdire à une *requête* d'additionner deux devises. La forme DB de M-15 est donc en deux parties, toutes deux dans la base :

1. **Sur les tables** : `devise_code NOT NULL` à côté de chaque montant ; aucune colonne de montant converti ; `snapshot_marge` porte **une devise par montant** (`ca_devise_code`, `cout_devise_code`) et une marge NULL si elles diffèrent ; les montants facultatifs ont un CHECK « montant présent ⇔ devise présente ».
2. **Sur la surface de lecture** : les agrégats (CA, marge, occupation valorisée) ne sont exposés à l'API que par des **vues groupées par devise** ; le rôle applicatif lit ces vues, il n'agrège pas les tables lui-même.

Ce qui reste hors base — une addition EUR + MAD écrite à la main dans un service — est la **règle de code R-1** du registre §A, tenue en revue. M-15 reste le quinzième mur ; P3 n'est pas rouvert : le mur n'est pas affaibli, sa forme est écrite honnêtement.
