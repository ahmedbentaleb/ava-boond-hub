# ADR-001 — Le prototype « CRM Vision 360 » (zip Jenspark) est écarté

Date : 17/09/2026 · Statut : **décidé** (Ahmed, 17/09/2026 : « c'est une démo Jenspark, on peut l'ignorer »)

## Contexte

Deux copies identiques de `avaliance-crm-vision-360-code.zip` (15/09/2026) sont à la racine du projet. Contenu : une vue Administration & RBAC en HTML/JS vanilla, un `schema.sql` PostgreSQL (`users, roles, permissions, role_permissions, user_roles, sensitive_fields, sso_config, auth_tokens, user_sessions, audit_log`), une matrice rôles × permissions 33 × 7, un panneau SSO Microsoft 365, la charte Avaliance. Aucun plan ni brief ne le cite.

## Décision

**Ce code n'est pas un socle.** Il n'est ni repris, ni adapté, ni « inspirant ». Le modèle de droits d'Ava Manager est écrit à partir de DEC-17 et F28, pas de ce schéma.

## Motif

Le prototype incarne un modèle **rôles × permissions plats** :

| Ce qu'il fait | Ce que DEC-17 / F28 exigent |
|---|---|
| un utilisateur a des rôles ; un rôle a des permissions | un utilisateur a des **groupes** ; une permission est liée à un **périmètre** |
| pas de périmètre | l'union des habilitations **ne croise jamais** permission et périmètre (BM-42) |
| pas de surcharge restrictive | **la restriction gagne** sur l'union (F28) |
| `sensitive_fields` comme liste plate | données sensibles = permissions séparées par onglet (matrice) |

L'adapter coûterait plus que repartir de la règle — et laisserait des traces du modèle plat dans les noms de tables.

## Conséquences

- Les deux zips restent dans le dépôt comme **pièce d'archive**, pas comme code. Ils peuvent être supprimés sans perte.
- Si quelqu'un propose « on a déjà une base RBAC » : renvoyer à cette ADR.
- Une seule chose est conservée, et elle vient de la charte Avaliance, pas du zip : les couleurs (`#5d1f77`, `#bbc742`) — déjà portées par la skill `design-avaliance`.

## Écarté

| Option | Pourquoi non |
|---|---|
| L'adopter et ajouter périmètre + groupes | On greffe DEC-17 sur un squelette qui le contredit ; chaque table garde un nom qui ment. |
| Le garder « pour les écrans » | Les écrans se dérivent du modèle validé (plan 5b), jamais d'un prototype antérieur au modèle. |
