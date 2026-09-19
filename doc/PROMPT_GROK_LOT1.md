# L2a — le prompt d'amorçage · LOT 1

⭐ **À coller dans Cursor, tel quel.** Grok lit le dépôt : on ne colle aucun fichier, on donne
des chemins. Le prompt tient en une page **parce que le dépôt porte le reste**.

---

<quand_utiliser>

| ✅ On s'en sert | ⛔ On ne s'en sert pas |
|---|---|
| Ouvrir le **lot 1** — dépôt, migrations, seeds, CI | pour le lot 2 : il aura son prompt |
| Reprendre après un rendu refusé | pour discuter métier — ça, c'est ici |

⚠️ **Un prompt par lot, daté.** Un prompt qu'on rallonge à chaque tour devient illisible, et
personne ne sait plus ce qui a été demandé quand.

</quand_utiliser>

---

## ⬇️ LE TEXTE À COLLER — tout ce qui suit, et rien d'autre

```text
Tu écris le LOT 1 d'Ava Manager, un logiciel de gestion d'agence de
placement. Le cadrage est FINI : 37 tables, 34 référentiels, 167
politiques, 15 murs, 26 écrans. Tout est déjà écrit et fait foi.

═══ CE QUE TU LIS, DANS CET ORDRE ═══
1. _ops/DOSSIER.html              le point d'entrée
2. _ops/SPEC_SQL_LISEZ-MOI.md     une page : par où entrer
3. _ops/SPEC_SQL_AVAMANAGER_V1.sql   le schéma — c'est LUI qui fait foi
4. _ops/SPEC_ASSERTIONS_L7.sql    22 tests : ton critère de fin
5. _ops/REGISTRE_POLITIQUES_v1.md §B et §C : les seeds
6. _ops/adr/                      7 décisions : pourquoi c'est comme ça

⛔ NE LIS PAS le reste de _ops/. Ce sont des relectures, des plans
datés, des captures. C'est le chemin parcouru, pas le canon. Les
lire te ferait suivre une version périmée.

═══ CE QUE TU PRODUIS ═══
/db/migrations/001_schema.sql     SPEC_SQL découpé, à l'identique
/db/migrations/002_seed_ref.sql   les 34 référentiels, registre §B
/db/migrations/003_seed_pol.sql   les 167 politiques, registre §C
/db/test/assertions.sql           SPEC_ASSERTIONS_L7, tel quel
/db/README.md                     monter la base en 3 commandes
/.github/workflows/db.yml         CI : monte, seed, lance les 22
/docker-compose.yml               PostgreSQL 16 local
/Makefile                         make up · make migrate · make test

═══ LA PILE, FIGÉE — tu ne la discutes pas ═══
PostgreSQL 16. Migrations = fichiers .sql numérotés, joués dans
l'ordre, jamais réécrits.
⛔ AUCUN ORM. Un ORM décrit le schéma une seconde fois : deux
vérités qui divergent, et les 15 murs sautent par le côté.
Node 22 + TypeScript UNIQUEMENT pour les outils (charger un seed,
lancer les tests). Aucun code métier au lot 1. Aucune UI.

═══ LES SIX INTERDITS — chacun est un refus en revue ═══
1. ⛔ Aucun `if` métier écrit en dur. Toute bifurcation a une clé
   dans la table `politique` et se lit par la fonction pol().
   C'est l'erreur que fait une IA qui code, parce que 99 % du code
   du monde la fait. C'est la première chose que j'audite.
2. ⛔ Aucune colonne tenant_id. Une base = une société (ADR-000).
3. ⛔ Aucun CHECK sur le CODE d'un référentiel — seulement sur sa
   CATÉGORIE. Boond a 14 états de candidat ; ils doivent pouvoir
   entrer comme codes, sans migration.
4. ⛔ Aucun DELETE accordé au rôle applicatif. Rien ne se supprime,
   tout s'archive (mur M-8).
5. ⛔ Aucune somme de montants hors des 4 vues par devise (M-15).
6. ⛔ Tu ne modifies AUCUN fichier de _ops/. Si tu crois qu'il a
   tort, tu écris ta remarque dans /db/REMARQUES.md avec le
   numéro de ligne. Tu ne corriges pas le canon toi-même.

═══ CE QUE TU DÉCIDES SEUL ═══
Le découpage des migrations, les noms de fichiers, la forme du
Makefile, la version des images Docker, le style du README.

═══ CE QUE TU NE DÉCIDES JAMAIS ═══
Un nom de table, un nom de colonne, un type, une contrainte, un
nom de politique, une catégorie de référentiel. Tout ça est écrit.
Si quelque chose manque, tu l'écris dans /db/REMARQUES.md et tu
t'arrêtes sur ce point — tu ne l'inventes pas.

═══ COMMENT TU SAIS QUE C'EST FINI ═══
Une seule preuve, et elle n'est pas négociable :

  make up && make migrate && make test

affiche 22 lignes OK et sort en 0.

⛔ « 21 sur 22 » n'existe pas : un mur percé est un mur percé.
⚠️ Les assertions doivent TOMBER si tu retires un trigger. Si elles
passent sur une base vide, c'est qu'elles ne testent rien —
signale-le, ne les adapte pas.

═══ CE QUE TU RENDS ═══
Une branche `lot-1`, un commit par fichier produit, et dans le
message de PR :
 - les 22 lignes OK, collées telles quelles
 - le contenu de /db/REMARQUES.md, ou « aucune »
 - ce que tu as décidé seul, en une liste

Ne me demande pas de valider en cours de route. Va au bout, rends,
j'audite.
```

---

<interdits>

| ⛔ Jamais dans ce prompt | Le problème que ça évite |
|---|---|
| Coller le contenu d'un fichier | il lit le dépôt ; une copie collée devient périmée au premier commit |
| Lui laisser choisir la pile | il choisirait un ORM, et les murs sauteraient par le côté |
| Lui dire « fais au mieux » sur un nom | il inventerait `client_id` là où le canon dit `societe_id` |
| Lui demander de valider en cours | on paie trois allers-retours pour un lot mécanique |
| L'autoriser à toucher `_ops/` | le canon se met à suivre le code au lieu de le commander |

</interdits>

---

<etat>

**19/09/2026 — écrit, pas encore lancé.**

La grille qui sert à juger son rendu : [GRILLE_AUDIT.md](GRILLE_AUDIT.md). ⭐ Elle est écrite
**avant** qu'il code — une grille écrite après se plie au code.

⏳ **Lot 2** (les 44 commandes) attend L4. Son prompt s'écrira quand L4 existera.

</etat>

---

<source>

Décidé le 19/09/2026 : le codeur est **Grok dans Cursor**, sur la machine d'Hamada, avec accès
au dépôt. Mon rôle devient celui d'auditeur à demeure.

⭐ **Le choix de pile qui compte : pas d'ORM.** Ce n'est pas un goût. Les 15 murs vivent dans des
triggers, des CHECK et des GRANT ; un ORM redécrit le schéma à sa façon et, au premier
`migrate` généré, il les efface sans que personne le voie. Le SQL est écrit — il n'y a rien à
générer.

</source>
