# ADR-003 — Le Projet ne porte pas de ressource : la Prestation est l'affectation

Date : 17/09/2026 · Statut : **décidé** (DEC-05, DEC-06, DEC-07, DEC-11, F1, F2, F7) — cette ADR fixe la **forme physique**

## Contexte

SPEC US5 met une `Ressource` obligatoire dans le formulaire de création de projet ; un commentaire Word de la même US demande de « l'ajouter au niveau des prestations ». DEC-07 : le Projet ne porte pas de `resource_id` ; ses ressources se dérivent des Prestations. DEC-11 : la ressource d'une prestation est **immuable**. DEC-05 : un besoin peut ouvrir N projets ; US5 permet aussi un projet **sans** besoin.

## Décision

```
besoin      (societe_id NOT NULL, contact_id NULL, agence_id, nb_postes_vises ≥ 1, priorite P1–P3, etat)
projet      (societe_id NOT NULL, contact_id NOT NULL, besoin_id NULL, agence_id, type Régie/Forfait, etat)
prestation  (projet_id NOT NULL, profil_ressource_id NOT NULL — jamais modifié après INSERT,
             etat, debut, fin, tjm_vendu, cjm_contrat, devise, jours_vendus, taux_occupation…)
```

- **Aucune colonne ressource sur `projet`.** La liste des ressources d'un projet est une vue : `SELECT DISTINCT profil_ressource_id FROM prestation WHERE projet_id = …`.
- `prestation.profil_ressource_id` est protégé par un trigger `BEFORE UPDATE` qui refuse tout changement (DEC-11). Remplacer = clôturer + créer (BM-33, ATL-18).
- `projet.besoin_id` est **nullable** : un projet direct (US5) existe sans besoin. Un besoin a 0..N projets.
- `projet.contact_id NOT NULL` (US5) alors que `besoin.contact_id` est nullable (DEC-04) : `CreateProjectFromNeed` **demande** le contact à la commande si le besoin n'en a pas (F4).
- Les conditions économiques vivent sur la prestation (DEC-08) : `tjm_vendu`, `cjm_contrat` ne sont jamais recalculés depuis la fiche ressource.

## Motif

Un `resource_id` sur le projet ne survit pas au premier projet à deux personnes ni au premier remplacement : soit on le laisse pourrir, soit on le duplique avec la prestation et les deux divergent. La prestation **est** le fait « cette personne travaille sur ce projet à ces conditions » ; le projet est le cadre contractuel avec le client.

## Conséquences

- Un projet peut exister sans prestation (S3 : P3B). C'est voulu — « un projet sans prestation est un titre », mais un titre légitime avant chiffrage (audit Boond 14).
- Clôturer un projet exige toutes ses prestations `cloturee` ou `annulee` (F7) — trigger ou garde de commande, les deux.
- Le CA, la marge, l'occupation sont des **vues** sur les prestations et les temps (ATL), jamais des colonnes de `projet`.

## Écarté

| Option | Pourquoi non |
|---|---|
| `projet.resource_id` obligatoire (US5 littéral) | Faux dès le deuxième intervenant ; le commentaire Word de l'US le corrige lui-même. |
| `prestation.profil_ressource_id` modifiable « par un admin » | DEC-11 ; et ça réécrit les temps déjà saisis par l'ancienne personne. |
| `projet.besoin_id NOT NULL` | Supprime silencieusement US5 (projet direct) et CdC II.I. |
| Une table de jointure `projet_ressource` en plus de `prestation` | Deux vérités pour le même fait. |
