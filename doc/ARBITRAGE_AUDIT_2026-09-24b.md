# Arbitrage du sixième audit — 24/09/2026 (soir)

Audit : commit `a26291c`, verdict **REFUSÉ** sur **un seul** défaut critique. 11 constats neufs
(V-117 → V-127 : 1 critique · 5 élevés · 4 moyens · 1 bon). ⭐ Banc vert sur base neuve : 307 portes,
40 assertions, 69 sabotages, **1 seul chemin aveugle** — la ligne `agence.ts:285`.

<etat>

## ⬜ CE QUI RESTE À FAIRE

| # | Quoi | Constats | Qui | État |
|---|---|---|---|---|
| 1 | ⭐ **D-31 — la ligne 285 disparaît** : une agence non lue est un refus ; chaque ligne de la table déclare sa nature | V-117 V-118 V-123 | CODE | ⬜ |
| 2 | `ArchiveObject` ne prend plus que les objets sans commande dédiée, un lecteur par type | V-117 | CODE | ⬜ |
| 3 | `TransferContact` : droit aux deux agences, le contact suit sa nouvelle société | V-119 | CODE | ⬜ |
| 4 | Le banc ne retire que ce qu'il a posé | V-120 | CODE (`Role: banc`) | ⬜ |
| 5 | Migration 014 : `ref_etat_paiement` · GRANT retiré aux tables du lot 5.8 · `LireDonneesRHSensibles` au groupe RH | V-121 V-122 V-125 | BRAIN CODE | ⬜ |
| 6 | Le pas `verif_trailers.sh` **branché** dans `ci.yml` (il n'y a jamais été) | V-124 | BRAIN CODE | ⬜ |
| 7 | Canon : lot cible par section de L4, compte des commandes mesuré (98), grille à 43, B1 voit `.includes()` | V-122 V-126 | BRAIN | ✅ 24/09 |
| 8 | Septième audit | — | AUDIT | ⬜ clone `ava-audit-7`, base `ava_audit7`, port 3700 |

</etat>

## ⭐ D-31 — LA LIGNE 285 : TRANCHÉE

```
else await exigeDroit(ctx, ctx.commande, ctx.compte.agence_id);   ← supprimée
```

**La règle : l'agence du demandeur n'est JAMAIS l'agence d'un objet.** Elle ne sert que dans un seul
cas, déclaré : l'objet **n'existe pas encore** et c'est dans cette agence qu'il sera écrit.

Chaque ligne de `CORRESPONDANCE` porte désormais sa **nature**, et le contrôle part d'elle :

| Nature | Pour qui | Contrôle | Si l'agence n'est pas lue |
|---|---|---|---|
| `objet` | toute commande qui touche un objet existant | droit **dans l'agence lue** sur l'objet | ⛔ **refus** — `INTROUVABLE` si l'identifiant ne mène à rien, `GARDE` si aucun identifiant n'est donné |
| `creation` | l'objet naît | droit dans l'agence **où il sera écrit** : celle demandée, sinon celle du compte (D-26) | — (c'est la seule place de l'agence du compte) |
| `installation` | réglages, listes, groupes | droit au périmètre **global** | — |
| `soi` | ce qui ne regarde que le compte (thème, widgets, Outlook) | le compte agit sur lui-même | — |

| Question | Tranché |
|---|---|
| Un objet trouvé avec une agence **nulle** (V-123) | ⛔ **refus**, plus « périmètre global ». D-21 l'ouvrait quand des colonnes étaient nullables ; elles sont toutes NOT NULL depuis 009-011. On ferme, et une porte vérifie que chaque colonne lue par la table **reste** NOT NULL : le jour où une colonne redevient nullable, le banc rougit |
| `agenceGouvernante` (l'agence du manager de la société pour une unité) | ⛔ supprimée avec le repli — l'unité a son agence NOT NULL depuis 010 |
| Une commande **absente** de la table | déjà `GARDE` ; ⭐ une porte parcourt les **55 commandes servies** et exige une ligne avec sa nature — plus jamais un oubli silencieux |
| `ArchiveObject` sur société, contact, unité, service | ⛔ **refus `GARDE`** qui nomme la commande dédiée (`ArchiveCompany`, `ArchiveContact`, `ArchiveService`) : sinon il contourne leur garde métier (`societe.archivage.garde`) en plus du périmètre |
| `ArchiveObject` sur candidat, ressource, besoin, projet | le lecteur de la commande dédiée à l'objet |
| `ArchiveObject` sur une personne | lue par **tous** ses profils ; s'ils sont dans deux agences, le droit est exigé dans **les deux** |
| `ArchiveObject` sur une action | lue par l'objet qui la porte (M-9 : une action a un seul porteur) |
| Un type que `ARCHIVE` connaît sans lecteur | ⛔ `GARDE`, et une porte parcourt `ARCHIVE` : un type sans lecteur fait rougir le banc |
| `CreateAction`, `UploadDocument` | leurs lecteurs couvrent **tous** les porteurs possibles (société et contact compris) ; aucun porteur → `GARDE` (L4 l'exige déjà : « zéro ou deux porteurs ») |

⭐ **Pourquoi ça ferme la série** : V-076, V-097, V-107, V-108 et V-117 sont un seul défaut qui changeait
de porte. Chacun venait d'une commande dont la table oubliait un cas ; le repli le rendait **silencieux**.
Sans repli, un oubli devient un refus — une gêne visible, jamais une brèche.

## Les autres constats

| V | Tranché | Qui |
|---|---|---|
| V-119 | `TransferContact` exige le droit dans l'agence **du contact** ET dans celle de la **société d'arrivée** ; le contact prend l'`agence_responsable_id` de sa nouvelle société. Porte : transfert vers une société hors périmètre → `DROIT`, rien d'écrit | CODE |
| V-120 | Chaque porte **photographie** les délégations existantes avant d'en poser, et ne retire **que les siennes**. Porte : une délégation posée à la main avant le banc survit au banc | CODE (`Role: banc`) |
| V-121 | `ref_etat_paiement` (catégories `planifie` · `confirme` · `regle`) ; `paiement.etat_code` → FK. Migration **014**, jamais une réécriture de 012 | BRAIN CODE |
| V-122 | ⭐ **Le GRANT vient avec la commande.** 014 retire `INSERT, UPDATE` à `ava_app` sur les tables des lots 5.7 et 5.8 (`SELECT` reste) ; la migration qui livrera leurs commandes le rendra. Assertion L7 : aucune de ces tables n'est écrivable. Canon : chaque section de L4 porte son lot cible ; **98 commandes** partout (L4 = MATRICE, mesuré ; le « 95 » de l'audit et mon « 96 » étaient faux) | BRAIN CODE + BRAIN |
| V-123 | fermé par D-31 (refus, et porte sur les NOT NULL) | CODE |
| V-124 | ⭐ **Constat juste, et c'est un défaut du BRAIN CODE** : `verif_trailers.sh` existe, `ci.yml` ne l'appelle pas — B4 était annoncé fait. Le pas se branche ; témoin : un commit sans trailer fait échouer la commande **exacte** du pas. Les 2 commits de la branche sans `Role:` (`18757b7`, `f9ff657`) sont comptés et nommés, pas réécrits | BRAIN CODE |
| V-125 | La MATRICE donne `LireDonneesRHSensibles` au groupe RH : le seed la lui donne (014). Elle n'est pas une des cinq de D-30 | BRAIN CODE |
| V-126 | La grille passe à **43** ; B1 cherche aussi `.includes(` et `.startsWith(` sur un libellé | BRAIN |
| V-127 | ⭐ gardé : le choix de modèle tient, la case 13 tourne, un numéro = un fichier | — |

## Ce que ce tour apprend

⭐ **Un contrôle d'accès se ferme par défaut, jamais par la liste de ce qu'on a pensé.** Quatre tours à
boucher des portes, une seule ligne à retirer.
⚠️ **« Fait » n'est pas « branché »** : un script de CI qui n'est appelé nulle part a été annoncé fermé
(V-124). Le témoin doit être la commande **exacte** de la CI, jouée à la main.

<source>

Rapport : `Desktop/ava-audit-6/rapport/` (SYNTHESE, CONSTATS, SUIVI_V, MUTATIONS, SECURITE, CONFORMITE,
GRILLE), copié dans `audit-2026-09-24b/`. Mesures du BRAIN, 24/09 : `agence.ts:100-300` lu ;
`grep verif_trailers .github/` → 0 ; commits sans trailer depuis `9f5281d` : `18757b7`, `f9ff657` ;
commandes : L4 = MATRICE = 98, serveur = 55.

</source>
