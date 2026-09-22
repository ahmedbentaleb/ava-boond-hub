# Base Ava Manager

PostgreSQL 16, schéma `ava`, driver `pg` brut. Aucun ORM.

Trois commandes, depuis la racine du dépôt :

```
make up
make migrate
make test
```

`make up` démarre Postgres 16 (port hôte **55432**).  
`make migrate` joue `db/migrations/*.sql` dans l'ordre, une fois.  
`make test` exige **22 OK** — pas 21.

Sur Windows sans GNU make : `make.cmd up` (Git Bash / WSL).

Connexion locale (service Windows) :

```
postgres://postgres@127.0.0.1:5432/ava
```

Docker (secours) : mot de passe uniquement via `POSTGRES_PASSWORD`, jamais dans le dépôt.
`DATABASE_URL` l'emporte.
