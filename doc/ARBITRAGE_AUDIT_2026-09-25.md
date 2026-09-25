# Arbitrage du huitième audit — 25/09/2026

Audit : commit `48e90c4`, verdict **REFUSÉ**. 9 constats neufs (V-138 → V-146 : 2 critiques · 3 élevés ·
3 moyens · 1 bon). ⭐ **Pour la première fois, 0 porte aveugle sur 71 sabotages.** Banc vert sur base neuve
(332 portes, 41 assertions), 173 appels hors banc sur 173 en 401.
⛔ Mais D-32 n'a été appliquée qu'à **5 commandes sur 55** : la porte croisée de l'audit trouve **17 fuites
sur 96 champs**.

<etat>

## ⬜ CE QUI RESTE À FAIRE

| # | Quoi | Constats | Qui | État |
|---|---|---|---|---|
| 1 | ⭐ **D-36 — la porte croisée entre au banc** : 55 commandes, chaque identifiant pointé hors agence, **0 fuite exigée** ; copie = canon, le codeur n'y touche pas | V-138 | BRAIN CODE (`Role: banc`) | ⬜ |
| 2 | ⭐ **D-37 — D-32 sur les 55 commandes** : chaque ligne déclare tous ses identifiants, la garde les résout dans `ctx.resolues`, la commande ne lit plus un objet dans l'entrée ; liste de clés **par commande**, tirée du contrat | V-138 V-140 | CODE | ⬜ |
| 3 | **D-38 — chaque référence écrite a sa règle**, et deux d'entre elles sont des politiques | V-138 | BRAIN ✅ canon · CODE | ⬜ |
| 4 | **D-39 — `soi` ne lève jamais une autre règle** | V-139 | CODE | ⬜ |
| 5 | Un numéro = un test · le banc ne touche plus les délégations d'autrui (3e tour) | V-141 V-142 | CODE (`Role: banc`) + BRAIN CODE (cliquet) | ⬜ |
| 6 | **D-40 — une migration publiée ne se réécrit pas** : 001 et 002 restaurées, leur ajout dans 017, et une case qui le garde | V-143 | BRAIN CODE | ⬜ |
| 7 | Comptes : registre (201) et `dossier.py` (toutes les migrations) | V-143 V-144 | BRAIN ✅ texte · BRAIN CODE (`dossier.py`) | ⬜ |
| 8 | Périmètres `pole` et `equipe` : fermés tant qu'ils ne sont pas servis | V-145 | CODE | ⬜ |
| 9 | ⭐ **Grok tourne jusqu'à 0 fuite, sans audit entre-temps** ; l'audit n'est rappelé qu'à ce moment | — | CODE | ⬜ |
| 10 | Neuvième audit | — | AUDIT | ⬜ clone `ava-audit-9`, base `ava_audit9`, port 3900 |

</etat>

## ⭐ D-36 — LA PORTE CROISÉE ENTRE AU BANC (V-138)

L'audit a construit ce qui manquait : `ava-audit-8/rapport/preuves/securite8/croise_55.mjs`.

| Règle | Tranché |
|---|---|
| Qui l'écrit | **BRAIN CODE**, pas le codeur : celui qui corrige ne tient pas le test qui le juge |
| Où | la source dans `_ops/PORTE_CROISEE.mjs` (canon), la copie **exacte** dans `test/` ; le cliquet compare les deux, comme pour les assertions |
| Le monde | une **seconde et une troisième agence** posées par la fixture ; l'acteur reçoit les 55 permissions **par `ManageGroups`**, sur son agence seulement |
| Ce qu'elle joue | pour chaque commande servie, **chaque** identifiant de son entrée pointé vers un objet d'une autre agence → `DROIT` ou `GARDE`, **empreinte de toutes les tables inchangée** ; puis un positif dans l'agence → `ok` |
| ⭐ Complète par construction | la liste des commandes vient du serveur (les 55 servies) et la liste des champs de la **déclaration** de chaque ligne (D-37) : une commande ou un identifiant sans cas → la porte **rougit**. Une commande nouvelle entre dans la porte sans qu'on y pense |
| Seuil | **0 fuite**. Pas « moins qu'avant » |

## ⭐ D-37 — D-32 JUSQU'AU BOUT (V-138, V-140)

Le correctif du 7e tour a posé une liste blanche commune (`CLES_COMMUNES`) et trois paires de synonymes :
il ferme les cas montrés et laisse la famille. ⛔ **On retire les deux.**

| Règle | Tranché |
|---|---|
| **Déclaration** | chaque ligne de `agence.ts` déclare **toutes** les clés de l'entrée de sa commande, tirées de son contrat L4 : les identifiants d'objet (avec leur table) et les valeurs simples |
| **Résolution** | la garde résout **chaque** identifiant déclaré, une fois, et le pose dans `ctx.resolues` (table, id, agence) |
| **Lecture** | ⛔ une commande ne lit **jamais** un objet dans `ctx.entree` : seulement dans `ctx.resolues`. Une porte le vérifie dans le code (aucun `req(ctx.entree, "…_id")` ni `opt(…, "…_id")` dans `server/src/commandes`) |
| **Clé inconnue** | une clé absente de la déclaration **de cette commande** → `GARDE` « entrée ambiguë ». Les 10 clés du contrat refusées à tort (`mesures`, `facturable`, `contexte`…) reviennent par la déclaration ; `etat` à la création sort (une prestation ne naît pas close) |
| **Synonymes** | ⛔ il n'y en a plus : un objet = un nom. `manager` **ou** `manager_compte_id` — le contrat en garde un seul |

## ⭐ D-38 — CHAQUE RÉFÉRENCE ÉCRITE A SA RÈGLE (les 17 fuites)

Toutes les fuites ne sont pas le même cas. Défaut **strict** partout ; deux bifurcations métier deviennent
des **politiques**, parce qu'une société de conseil peut vouloir les ouvrir.

| Référence écrite | Règle | Fuites fermées |
|---|---|---|
| un objet d'agence (besoin, projet, unité, prestation…) | droit **pour cette commande** dans l'agence de l'objet | `CreateUnit.societe_id` via la société |
| une **société** (client, fournisseur, intermédiaire) | suit `societe.perimetre.mode` (D-25 bis) : `agence_responsable` → droit dans son agence ; `par_besoins` → une de ses agences de besoin ; `partagee` → libre | `CreateNeed`, `CreateUnit`, `UpdateProject` (intermédiaire), `ConvertCandidateToResource` et `CreateResource` (fournisseur) |
| un **compte** (manager, responsable RH) | son agence doit être couverte par le périmètre du demandeur pour cette commande | `CreateCompany`, `UpdateCompany`, `UpdateCandidate`, `UpdateResource` |
| une **personne** existante | chacune des agences de ses profils doit être couverte ; une personne sans profil est libre | `CreateCandidate`, `CreateResource`, `RecordQualification` |
| une **agence** demandée | droit dans cette agence (D-26) | `ConvertCandidateToResource.agence_id` |
| ⭐ un **candidat ou une ressource d'une autre agence** sur un besoin ou une prestation | **politique `staffing.inter_agences`** : **non** · oui. `non` → refus ; `oui` → permis si le demandeur a le droit dans l'agence du besoin ou du projet ; le profil garde son agence | `PositionCandidate`, `PositionResource`, `CreatePrestation` |

⚠️ `staffing.inter_agences` est une **question pour Avaliance** (le nearshore Casablanca → Paris est leur
métier) : ajoutée aux questions de réunion. Le défaut `non` est celui que l'audit exige ; la porte croisée
joue le défaut, et une porte par valeur joue `oui`.

## Les autres constats

| V | Tranché | Qui |
|---|---|---|
| V-139 · **D-39** | `soi` ne couvre **que la personne du compte** ; un autre périmètre ne lève **jamais** la règle « soi-même » : chaque droit est jugé sur son propre périmètre, puis on prend l'union. `droits.ts:28-33` et `:63`. Porte : `RES` + `STAF` de PAR sur un document ou une absence de CAS → `DROIT` | CODE |
| V-140 | fermé par D-37 (liste par commande) | CODE |
| V-141 | P-333 → P-338 retirées (doublons de P-326 → P-331) ; un test porte **un** numéro. Case du cliquet : chaque numéro apparaît une fois dans `PORTES.md` et dans un seul titre de test | CODE (`Role: banc`) + BRAIN CODE (case) |
| V-142 | ⛔ **troisième tour ouvert.** On arrête de corriger fichier par fichier : **une seule aide** pose et retire les délégations, elle ne retire que ce qu'elle a enregistré ; un `DELETE` direct sur les tables de délégation dans `test/` hors de cette aide fait rougir le cliquet | CODE (`Role: banc`) + BRAIN CODE (case) |
| V-143 · **D-40** | Mesuré : `001_schema.sql` et `002_seed_ref.sql` réécrites par le codeur (`4b74720` le 23/09, `d1776e3` le 24/09). ⛔ **Une migration publiée ne se réécrit pas, et le codeur n'écrit pas de migration.** 001 et 002 reviennent à leur version de `main` ; leurs ajouts passent dans une migration **017** ; une case du cliquet exige que chaque migration présente sur `main` soit **identique** dans HEAD | BRAIN CODE |
| V-143 (compte) | le registre compte **201** (200 en tableau + 1 en prose) ; c'est le **commentaire** de la commande du §E qui disait encore 173 — corrigé | BRAIN ✅ |
| V-144 | `dossier.py` lit les référentiels dans **toutes** les migrations, pas seulement les premières | BRAIN CODE |
| V-145 | `pole` et `equipe` : **fermés** tant qu'ils ne sont pas servis — un droit sur ces périmètres ne couvre rien, et `ManageGroups` refuse de les poser (`GARDE` « périmètre non servi »). Lot cible : 5.7 | CODE |
| V-146 | ⭐ gardé : **0 porte aveugle sur 71 sabotages** ; `TransferContact` ; tables écrivables = tables des commandes ; CHECK justifiés ; jeu d'essai rechargé | — |

## ⭐ La boucle, jusqu'à 0 fuite (demande de l'audit, acceptée)

1. BRAIN CODE livre la porte croisée (D-36) **en premier** ; Grok fusionne `lot-2-brain`.
2. Grok corrige (D-37 → D-39) et **rejoue la porte croisée** après chaque passe, sans audit entre-temps.
3. Il ne rend la main qu'à **0 fuite** et cliquet vert — puis « prêt pour le neuvième audit ».

## Ce que ce tour apprend

⭐ **Un test qui énumère les cas qu'on a pensés ferme ces cas-là ; un test qui énumère ce que le code
reçoit ferme la famille.** La porte croisée tire ses cas du serveur, pas d'une liste.

<source>

Rapport : `Desktop/ava-audit-8/rapport/` (SYNTHESE, CONSTATS, SUIVI_V, MUTATIONS, SECURITE, CONFORMITE,
GRILLE, `preuves/securite8/croise_55.*`), copié dans `audit-2026-09-25/`. Mesures du BRAIN, 25/09 : les 17
fuites de `croise_55.md` classées une par une ; `git log main..lot-2 -- db/migrations/00[12]*` →
`4b74720`, `d1776e3` ; registre §C, commande du §E → 200 + 1.

</source>
