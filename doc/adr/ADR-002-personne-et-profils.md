# ADR-002 — Une Personne, deux profils : Candidat et Ressource

Date : 17/09/2026 · Statut : **décidé** (DEC-01, DEC-02, F19, F22) — cette ADR fixe la **forme physique**, pas la règle

## Contexte

DEC-01 : une Personne porte l'identité commune ; CandidatProfile et RessourceProfile sont deux profils distincts. DEC-02 : un candidat ne porte jamais de prestation ni de temps ; la conversion active un profil Ressource sans copier ni supprimer. F22 : Contact et Personne restent **deux objets distincts** en V1. Boond, lui, a deux tables séparées Candidat / Ressource et « convertit » en créant une nouvelle fiche (SPEC US2 RG3 : « une nouvelle ressource est créée »).

## Décision

Trois tables :

```
personne            (identité : civilité, nom, prénom, naissance, coordonnées, adresse)
profil_candidat     (personne_id UNIQUE, etat Draft/Complété, provenance, dispo, mobilité, prétentions…)
profil_ressource    (personne_id UNIQUE, type INTERNAL/EXTERNAL, etat En cours/Intercontrat/Sortie,
                     agence_id, coût de référence, TJM indicatif, devise, societe_fournisseur_id si EXTERNAL)
```

- `positionnement` référence **un profil** : `profil_candidat_id XOR profil_ressource_id` (DEC-03).
- `prestation`, `temps`, `absence` référencent **`profil_ressource_id` uniquement** — le mur DEC-02 est une clé étrangère, pas une règle d'écran.
- La conversion (BM-06) = `INSERT INTO profil_ressource` sur la même `personne_id`. Rien n'est copié, rien n'est supprimé, `profil_candidat` reste.
- `contact` est une table **à part**, sans lien à `personne` en V1 (F22).

## Motif

Une seule table « personne avec type » aurait deux défauts : les colonnes propres à chaque profil (prétentions vs coût de référence) se mélangent, et surtout **le mur Candidat → Prestation devient un CHECK sur un type** au lieu d'une clé étrangère qui ne peut physiquement pas pointer ailleurs. Deux tables indépendantes (Boond) forcent la copie à la conversion, donc deux identités qui divergent (DEC-01 l'interdit).

## Conséquences

- Une personne peut avoir 0, 1 ou 2 profils. Une Ressource créée directement (US1) n'a pas de profil candidat.
- Le doublon de **Personne** (deux lignes pour le même humain) n'est **pas** résolu par ce schéma : c'est BM-57 / F20 (avertir, jamais fusionner sur l'email seul).
- Les données sensibles RH (salaire, administratif) vont dans `profil_candidat` / `profil_ressource`, pas dans `personne` : les droits par onglet (matrice) suivent la table.

## Écarté

| Option | Pourquoi non |
|---|---|
| Une table `personne` avec colonne `type` | Le mur DEC-02 devient un CHECK contournable ; les colonnes des deux profils se mélangent. |
| Deux tables sans `personne` commune (modèle Boond) | Conversion = copie ; l'historique candidat et l'identité ressource divergent — DEC-01 l'interdit. |
| `contact` = un profil de `personne` | Séduisant, mais F22 dit non pour la V1 ; et ça ouvrirait la fusion contact/candidat que F20 interdit d'automatiser. |
