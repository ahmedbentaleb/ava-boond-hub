# ADR-R-001 — Port hôte Postgres 55432

Date : 19/09/2026 · Statut : **décidé en attendant** (lot 1)

## Contexte

Le lot 1 monte PostgreSQL 16 en Docker. Le port 5432 est souvent déjà pris sur les machines de développement.

## Décision

L'hôte expose **55432** vers 5432 du conteneur. L'URL vient de `DATABASE_URL` / `POSTGRES_PASSWORD` (hors dépôt).

## Motif

Un bind qui échoue bloque E4 (les 22 assertions jamais jouées). Changer le port hôte ne change aucune table, aucune politique, aucun mur.

## Conséquences

- `DATABASE_URL` par défaut porte 55432.
- En CI, Docker Compose utilise le même fichier.

## Écarté

| Option | Pourquoi non |
|---|---|
| 5432 coûte que coûte | Échec silencieux ou collision avec un autre cluster. |
| Un réseau Docker-only sans port hôte | `psql` et Playwright hors compose deviennent plus lourds. |
