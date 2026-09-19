# ADR-000 — Mono-tenant : une base, une société

Date : 17/09/2026 · Statut : **décidé** (G5 = A, 17/09/2026, sur délégation) · Porte : le livrable Modèle de données v1

## Contexte

Ava Manager remplace Boond pour **Avaliance**. Aucun document (SPEC 2024, CdC 2022, DEC, F, ATL, plans) n'évoque une revente, un hébergement pour d'autres sociétés, ni une séparation de données entre entités juridiques. Les « agences » du CdC sont des périmètres de droits **à l'intérieur** d'Avaliance, pas des clients de la plateforme.

## Décision

**Une base = Avaliance.** Aucune colonne `tenant_id`. Aucune Row-Level Security par tenant. Les agences, pôles et équipes sont modélisés comme **périmètres** (voir modèle métier), pas comme tenants.

## Motif

`tenant_id` touche chaque table (~25), chaque clé unique, chaque index, chaque requête, chaque test. On paierait ce coût sur tout le projet pour une hypothèse que personne n'a formulée. L'inverse — ajouter plus tard une colonne à valeur constante et la faire entrer dans les clés — est une migration **mécanique**, pas une refonte.

## Conséquences

- Les clés uniques sont simples (`societe.nom`, `personne.email`…), sans préfixe tenant.
- Le périmètre de droits (DEC-17) s'appuie sur `agence_id` / `perimetre_id`, jamais sur un tenant.
- Si un jour Avaliance héberge une autre entité : nouvelle ADR, migration d'ajout de colonne, **pas** de réécriture du métier.

## Écarté

| Option | Pourquoi non |
|---|---|
| Multi-tenant dès la v1 | Coût sur 25 tables pour zéro besoin exprimé. Le CdC parle d'agences, pas de clients de la plateforme. |
| « Mono-tenant mais on met la colonne quand même, au cas où » | Une colonne toujours égale à 1 est une colonne qu'on oublie dans une clé unique un jour — et ce jour-là elle ment. |
