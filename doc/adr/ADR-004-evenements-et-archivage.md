# ADR-004 — Événements métier en ajout seul, archivage transverse, jamais de DELETE

Date : 17/09/2026 · Statut : **décidé** (DEC-18, DEC-09, F27, F34) — cette ADR fixe la **forme physique**

## Contexte

DEC-18 : les commandes importantes écrivent un **événement métier** distinct des logs techniques ; les objets portant un historique sont **archivés, pas supprimés**. DEC-09 : la marge est figée à la clôture par un snapshot non réécrit. F34 : une correction de temps après clôture est un ajustement distinct. F27 : la restauration est hors V1. CdC IV.A.1 : chaque fiche a un onglet Historique.

## Décision

### 1. Une table d'événements, en ajout seul

```
evenement_metier (id, type, objet_type, objet_id, auteur_compte_id, horodatage,
                  avant JSONB NULL, apres JSONB NULL, motif TEXT NULL, liens JSONB NULL)
```

- **Jamais d'UPDATE ni de DELETE** sur cette table (trigger qui refuse, plus droits SQL du rôle applicatif limités à INSERT/SELECT).
- Un événement par commande **réussie**. Un refus n'écrit pas un événement de réussite ; s'il est tracé, c'est avec un `type` de refus distinct (BM-44).
- Les `type` sont les noms proposés dans le registre BM (`PersonCreated`, `PrestationClosed`, `NeedStateChanged`…) — un catalogue, pas du texte libre.
- Les logs techniques (requêtes, erreurs) vont ailleurs (fichiers, observabilité), **jamais** dans cette table.

### 2. Snapshots figés = lignes, pas colonnes

```
snapshot_marge (prestation_id, calcule_le, version_atl, ca_produit, cout_produit, frais, marge, taux, devise, entrees JSONB)
```

Écrit une fois à `ClosePrestation` (ATL-15). Même règle : jamais d'UPDATE. Un ajustement de temps post-clôture (F34) écrit un `temps` marqué `ajustement = true` et un événement `TimesheetAdjustedAfterClose` ; il entre dans le CA **courant**, jamais dans ce snapshot.

### 3. Archivage transverse

Toute table d'objet historique porte `archive_le TIMESTAMPTZ NULL` et `archive_par_compte_id NULL`. Archiver = renseigner ces colonnes + événement `ObjectArchived`. Les vues « actives » filtrent `archive_le IS NULL`. Les FK restent valides : un contact archivé reste référencé par ses anciennes actions.

**Aucun DELETE physique** sur : personne, profils, société, unité, contact, besoin, positionnement, projet, prestation, temps, absence, action, qualification, document. Le rôle SQL applicatif n'a pas le droit `DELETE` sur ces tables.

## Motif

Un historique qu'on peut modifier n'est pas un historique. Le mettre en colonne de l'objet (`derniere_modif_par`) perd tout sauf le dernier état ; le mettre dans un log technique le mélange avec du bruit et le rend inexploitable pour un onglet Historique. Le trigger anti-UPDATE et l'absence de droit DELETE ne sont pas de la méfiance : c'est que « le mur dans la DB, pas dans l'UI » (plan) n'a de sens que si l'UI ne **peut** pas.

## Conséquences

- Chaque commande de service écrit son événement **dans la même transaction** que la mutation. Pas d'événement = pas de mutation.
- `avant / apres` ne contiennent que les champs pertinents (BM-46), pas la ligne entière.
- Volume : ~1 événement par commande. Partitionner par mois si nécessaire — hors V1.
- Restaurer un objet archivé : commande distincte, hors V1 (F27), qui ne rouvre rien automatiquement.

## Écarté

| Option | Pourquoi non |
|---|---|
| Colonnes `modifie_le / modifie_par` sur chaque table | On garde le dernier état, on perd les 20 précédents. Pas un historique. |
| Une table d'historique **par objet** | 15 tables au lieu d'une ; l'onglet Historique d'une fiche doit alors en interroger plusieurs (une action liée, une qualification…). |
| Soft-delete par booléen `supprime` | « Supprimé » n'est pas « archivé » : DEC-18 veut que l'objet reste **consultable**. Un booléen invite au `WHERE supprime = false` oublié. |
| Event sourcing complet (l'état reconstruit depuis les événements) | Élégant, hors de proportion pour ~25 tables et une équipe de 1. L'état est dans les tables ; l'événement est le journal. |
