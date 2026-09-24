# Arbitrage du cinquième audit — 24/09/2026

Audit : commit `b6ff087`, verdict **REFUSÉ**, 10 constats neufs (V-107 → V-116 : 2 critiques ·
4 élevés · 3 moyens · 1 bon). ⭐ **Le banc part de rien** : base refaite par le cliquet, 294 portes,
32 assertions, `make_rc=0`. **10 constats du 4e tour fermés ET gardés** — y compris les outils de
garde eux-mêmes (`ON_ERROR_STOP` retiré → P-299 ; `verif_serveur.sh` muet → P-300).
62 sabotages, **1 seule porte aveugle** : celle de V-107.

<etat>

## ⬜ CE QUI RESTE À FAIRE

| # | Quoi | Constats | Qui | État |
|---|---|---|---|---|
| 1 | **La société et le contact portent leur agence responsable** (D-25) : canon, puis migration 010, puis périmètre lu dessus | V-108 | BRAIN ✅ canon · BRAIN CODE (010) · CODE | ⬜ |
| 2 | **Plus de repli sur l'agence du demandeur** : agence nulle = périmètre global, partout (D-26) | V-107 | CODE | ⬜ |
| 3 | Décisions client en référentiel · les 2 portes restantes de V-099 · numéros de migration · F13 dans le cliquet | V-109 → V-112 | CODE + BRAIN CODE | ⬜ |
| 4 | Trailers `Role:` vérifiés par la CI · NOT NULL au bon endroit · les 4 écarts reconduits | V-113 → V-115 | BRAIN CODE + CODE | ⬜ |
| 5 | Sixième audit | — | AUDIT | ⬜ clone `ava-audit-6`, base `ava_audit6`, port 3600 |

</etat>

## D-30 · H-1 — les cinq permissions sans titulaire : c'est voulu (24/09 au soir)

| | |
|---|---|
| Constat | `ArchiveCompany`, `ArchiveContact`, `ArchiveService`, `ArchiveObject`, `UpdateResourceCost` n'ont aucun titulaire au seed |
| Tranché | ⭐ **voulu** : la MATRICE les marque `D` (délégable seulement) depuis le 17/09 ; archiver et toucher au coût se délèguent nommément |
| Le vrai défaut | le canon se contredisait : L4 disait « `UpdateResourceCost` est la **seule** ». Corrigé : cinq, nommées |
| Grok | ✅ a eu raison de ne rien inventer — rien à coder ; une porte existe déjà par refus `DROIT` |

## ⚠️ V-108 — TRANCHÉ : ni A, ni B, ni C exactement

⭐ **La réponse était dans Boond, et je ne l'avais pas lue.** L'écran « Créer une société » (capture 66,
relevé du 22/09) porte **Agence** et **Pôle** : chez Boond, une société cliente **a** une agence.

| # | Décision | Motif |
|---|---|---|
| **D-25** | **`societe.agence_responsable_id` et `contact.agence_responsable_id`**, NOT NULL, remplis par l'agence du compte créateur (ou du manager s'il y en a un), modifiables par un droit dédié. Le périmètre se lit **sur cette colonne**, comme partout ailleurs | ⛔ **C'est un trou de mon modèle**, pas un bug de Grok : j'ai écrit 55 commandes sans donner d'agence à deux objets sur lesquels 7 d'entre elles travaillent. L'audit a raison de refuser le colmatage commande par commande |
| **D-25 bis** | Le **comment** devient un réglage : `societe.perimetre.mode` = **`agence_responsable`** (défaut) · `par_besoins` · `partagee`. La colonne est le mur, le mode est la politique | une société suivie par deux agences existe (Portaliance et Avaliance FR partagent des clients). On ne fige pas ce choix : c'est exactement la règle du projet |
| **D-26** | ⛔ **Aucun repli sur l'agence du demandeur.** `sinonCompte` disparaît : agence de l'objet lue → on l'exige ; agence nulle → **périmètre global**, comme déjà fait pour les autres lignes | V-107 : le contrôle se comparait à lui-même, et c'était la seule porte aveugle du tour |
| **D-27** | **Un numéro de migration = un fichier.** La seconde `009` devient `010` ; `schema_migrations` porte un **rang unique** et la date d'exécution | V-111 : deux fichiers sous le même numéro, et plus aucune clé pour les ordonner |
| **D-28** | **F13 entre dans le cliquet** (case 13), et sa commande marche dans un clone neuf : si la référence `lot-2-brain` est absente, la case est **KO** avec son motif | V-112 : une règle écrite dans la grille mais absente du cliquet ne bloque rien — c'est la troisième fois qu'on l'apprend |
| **D-29** | Les **trailers `Role:`** sont vérifiés par la **CI**, pas seulement par un crochet local | V-113 : 20 commits sans trailer, dont 11 sur `test/` |

## Les 10 constats neufs

| V | Verdict | Gravité | Qui | Note |
|---|---|---|---|---|
| 107 | ✅ retenu | critique | CODE | D-26 · la seule porte aveugle du tour |
| 108 | ✅ retenu | critique | **BRAIN** → BRAIN CODE → CODE | D-25 · trou de modèle, tranché par la colonne, le mode reste réglable |
| 109 | ✅ retenu | élevée | CODE + BRAIN | les décisions client passent en `ref_decision_client` ; le grep B1 de la grille apprend à voir `.includes()` |
| 110 | ✅ retenu | élevée | CODE | P-203 et P-207 posent elles-mêmes le droit qu'elles testent |
| 111 | ✅ retenu | élevée | BRAIN CODE | D-27 |
| 112 | ✅ retenu | élevée | BRAIN CODE | D-28 |
| 113 | ✅ retenu | moyenne | BRAIN CODE | D-29 |
| 114 | ✅ retenu | moyenne | BRAIN CODE | `profil_candidat.agence_id` NOT NULL (c'est elle que la reprise remplira) ; l'unité garde le sien |
| 115 | ✅ retenu | moyenne | CODE + BRAIN | les 4 écarts reconduits du 4e tour |
| 116 | ✅ bonne | bonne | — | à garder |

**Compte : 9 retenus · 0 requalifié · 0 rejeté · 1 bonne.**

<source>

## Ce que ce tour apprend

| | |
|---|---|
| ⭐ Le banc | part de rien, et **garde ses propres outils** : retirer un correctif fait tomber une porte, à chaque fois |
| ⛔ Ma faute, la troisième | le même trou déplacé trois tours de suite (V-076 → V-097 → V-107/108) parce que je réparais **le symptôme**. D-25 le ferme à la racine : une colonne d'agence sur les deux objets qui n'en avaient pas |
| ⭐ Ce qu'il fallait faire plus tôt | relire mon propre relevé : la réponse était dans la capture 66 depuis le 22/09 |

</source>
