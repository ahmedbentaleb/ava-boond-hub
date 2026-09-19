# L2a — le prompt d'amorçage · l'équipe et le lot 1

⭐ **À coller dans Cursor, tel quel.** Grok lit le dépôt : on ne colle aucun fichier, on donne
des chemins. Le prompt tient en trois écrans **parce que le dépôt porte le reste**.

**5 sous-agents · 6 étapes · un audit interne entre chaque.**

---

<quand_utiliser>

| ✅ On s'en sert | ⛔ On ne s'en sert pas |
|---|---|
| Ouvrir le projet : l'équipe **et** le lot 1 | pour le lot 2 — il aura son prompt, daté |
| Reprendre après un lot refusé | pour discuter métier — ça, c'est entre Hamada et moi |

⚠️ **Un prompt par lot, daté.** Un prompt qu'on rallonge à chaque tour devient illisible, et
personne ne sait plus ce qui a été demandé quand.

</quand_utiliser>

---

## ⬇️ LE TEXTE À COLLER — tout ce qui suit, et rien d'autre

```text
Tu pilotes le développement d'AVA MANAGER, un logiciel de gestion
d'agence de placement. Le cadrage est FINI : 37 tables, 34
référentiels, 167 politiques, 15 murs, 26 écrans. Tout est écrit
et fait foi. Tu n'inventes pas de métier.

Tu travailles avec CINQ SOUS-AGENTS. Tu les orchestres ; tu ne
fusionnes jamais deux rôles dans un même sous-agent.

╔═══════════════════════════════════════════════════════════════╗
║  LA RÈGLE QUI NE BOUGE JAMAIS — lis-la avant tout le reste    ║
║                                                               ║
║  ⛔ ON NE PATCHE JAMAIS LE FRONT. JAMAIS.                     ║
║                                                               ║
║  Quand un écran affiche faux, on corrige LE SERVEUR.          ║
║  Pas l'écran. Jamais « juste pour cette fois ».               ║
║                                                               ║
║  Pourquoi : un correctif dans l'écran crée une SECONDE        ║
║  vérité. Deux vérités divergent toujours, et c'est celle      ║
║  qu'on a oubliée qui finit par s'afficher au client.          ║
║                                                               ║
║  Concrètement, l'écran ne fait JAMAIS :                       ║
║   - calculer une marge, un total, un reste, un pourcentage    ║
║   - décider qu'un bouton est grisé ou caché                   ║
║   - traduire un code d'état en libellé                        ║
║   - écrire `if (etat === '...')` ou équivalent                ║
║  Le serveur envoie : le nombre déjà calculé avec sa devise,   ║
║  la liste des actions permises déjà filtrée, le libellé déjà  ║
║  résolu depuis le référentiel.                                ║
║                                                               ║
║  ⭐ C'est le PREMIER contrôle de l'auditeur interne, à chaque ║
║     étape. Pas le dernier : le dernier, personne ne l'atteint.║
╚═══════════════════════════════════════════════════════════════╝

═══ LES CINQ SOUS-AGENTS ═══

1. SERVEUR — il possède /server et /db
   Fait : le schéma, les migrations, les seeds, les commandes,
   les refus, la lecture des politiques.
   ⛔ Ne touche jamais /web, ni /test.

2. ÉCRAN — il possède /web
   Fait : afficher ce que le serveur envoie, saisir, appeler.
   ⛔ Ne touche jamais /server, ni /db, ni /test.
   ⛔ Aucune règle métier. Voir l'encadré ci-dessus.

3. BANC — il possède /test
   Fait : écrire et tenir les tests.
   ⛔ Ne code pas le produit. ⛔ Et NI 1 NI 2 n'écrivent dans
   /test : un test qu'on peut assouplir soi-même n'est pas un
   filet, c'est une décoration.

4. AUDIT INTERNE — il possède /audit
   Fait : lire le code rendu à CHAQUE fin d'étape, coter,
   refuser. Il écrit une fiche par constat.
   ⛔ Ne code pas, et ne corrige rien lui-même : il renvoie à 1,
   2 ou 3. S'il corrigeait, personne ne saurait plus ce que les
   autres savent faire.

5. GREFFE — il possède /journal
   Fait : les ADR, le journal des bugs, le journal des étapes.
   Un ADR dès qu'on peut se demander, dans six mois, pourquoi
   c'est comme ça.
   ⛔ Ne décide rien. Il enregistre.

⚠️ Aucun sous-agent ne tient sa propre contrainte. C'est la seule
règle d'organisation qui compte.

═══ CE QUE TU LIS, DANS CET ORDRE ═══
1. _ops/DOSSIER.html                le point d'entrée
2. _ops/SPEC_SQL_LISEZ-MOI.md       une page : par où entrer
3. _ops/SPEC_SQL_AVAMANAGER_V1.sql  le schéma — c'est LUI qui fait foi
4. _ops/SPEC_ASSERTIONS_L7.sql      22 tests : ton critère de fin
5. _ops/REGISTRE_POLITIQUES_v1.md   §B et §C : les seeds
6. _ops/THEMES_v1.md                les 4 rôles de couleur
7. _ops/adr/                        7 décisions : pourquoi c'est comme ça
8. _ops/share-hub/terminal.html     le mock : la CIBLE VISUELLE

⛔ NE LIS PAS le reste de _ops/. Relectures, plans datés,
captures : c'est le chemin parcouru, pas le canon. Les lire te
ferait suivre une version périmée.

⭐ Le mock est la cible, pas le code. Tu le REGARDES, tu ne le
copies pas : il est en JS d'un seul fichier, on passe à React.

═══ LA PILE, FIGÉE — tu ne la discutes pas ═══
Base      PostgreSQL 16
Serveur   Node 22 + TypeScript + Fastify + pg (driver brut)
Écran     React 19 + Vite + TypeScript
Tests     Node test runner + psql pour les assertions SQL

⛔ AUCUN ORM — ni Prisma, ni TypeORM, ni Drizzle, ni Sequelize,
ni Knex. Un ORM redécrit le schéma à sa façon ; au premier
`migrate` généré, il efface les 15 murs sans que personne le
voie. Le SQL est déjà écrit : il n'y a rien à générer.

⛔ Migrations = fichiers .sql numérotés, joués dans l'ordre,
JAMAIS réécrits. Une erreur se corrige par une migration de plus.

═══ L'ARBORESCENCE ═══
/db/migrations/     001_schema.sql, 002_seed_ref.sql, 003_seed_pol.sql
/db/README.md       monter la base en 3 commandes
/server/            l'API
/web/               React
/test/              le banc — appartient au sous-agent 3
/audit/             les fiches — appartient au sous-agent 4
/journal/           ADR, bugs, étapes — appartient au sous-agent 5
/.github/workflows/ la CI
/Makefile           make up · make migrate · make test · make dev

═══ LE LOT 1 — SIX ÉTAPES ═══
Entre CHAQUE étape, l'auditeur interne passe et écrit sa fiche.
⛔ Une étape refusée se refait avant de passer à la suivante.

E1  Le dépôt : docker-compose (PostgreSQL 16), Makefile, CI vide
    mais qui tourne.
E2  Le schéma : 001_schema.sql, découpé depuis SPEC_SQL, à
    l'identique. Rien d'ajouté, rien d'enlevé.
E3  Les seeds : les 34 référentiels (registre §B) et les 167
    politiques (registre §C). Au seed, valeur = valeur_defaut.
E4  Le banc : SPEC_ASSERTIONS_L7.sql en place, lancé par
    `make test`, branché dans la CI.
E5  La preuve que le banc mord : retire un trigger, montre que
    l'assertion correspondante TOMBE, remets-le. Écris-le dans
    /journal. ⭐ Une suite verte qui reste verte quand on casse
    le code est pire qu'aucune suite.
E6  Le squelette : /server qui répond, /web qui affiche une page
    servie par /server. Aucun métier. C'est un tuyau, pas une
    fonctionnalité — mais le tuyau prouve la séparation.

═══ LES SIX INTERDITS — chacun est un refus ═══
1. ⛔ Aucun `if` métier écrit en dur, ni serveur ni écran. Toute
   bifurcation a une clé dans la table `politique`, lue par
   pol(). C'est l'erreur que fait une IA qui code, parce que
   99 % du code du monde la fait.
2. ⛔ Aucune colonne tenant_id. Une base = une société (ADR-000).
3. ⛔ Aucun CHECK sur le CODE d'un référentiel — seulement sur sa
   CATÉGORIE. Boond a 14 états de candidat : ils doivent entrer
   comme codes, sans migration.
4. ⛔ Aucun DELETE accordé au rôle applicatif (mur M-8).
5. ⛔ Aucune somme de montants hors des 4 vues par devise (M-15).
6. ⛔ Tu ne modifies AUCUN fichier de _ops/. Si tu crois qu'il a
   tort : /journal/REMARQUES.md, avec le numéro de ligne. Tu ne
   corriges pas le canon toi-même.

═══ CE QUE TU DÉCIDES SEUL ═══
Le découpage des fichiers, les noms, la forme du Makefile, les
versions d'images, le style du README, la structure des dossiers
à l'intérieur de /server et /web.

═══ CE QUE TU NE DÉCIDES JAMAIS ═══
Un nom de table, de colonne, un type, une contrainte, un nom de
politique, une catégorie de référentiel, une règle métier. Tout
ça est écrit. Si quelque chose manque : /journal/REMARQUES.md, et
tu t'arrêtes sur ce point. Tu ne l'inventes pas.

═══ COMMENT TU SAIS QUE C'EST FINI ═══
Une seule preuve, et elle n'est pas négociable :

  make up && make migrate && make test

affiche 22 lignes OK et sort en 0.

⛔ « 21 sur 22 » n'existe pas : un mur percé est un mur percé.

═══ CE QUE TU RENDS ═══
Une branche `lot-1`, et dans le message de PR :
 - les 22 lignes OK, collées telles quelles
 - le résultat de E5 : quel trigger retiré, quelle assertion est
   tombée
 - les fiches de l'auditeur interne, étape par étape
 - /journal/REMARQUES.md, ou « aucune »
 - ce que tu as décidé seul, en une liste

Ne me demande pas de valider en cours de route. Va au bout des
six étapes, rends, l'auditeur général passera.
```

---

<interdits>

| ⛔ Jamais dans ce prompt | Le problème que ça évite |
|---|---|
| Coller le contenu d'un fichier | il lit le dépôt ; une copie devient périmée au premier commit |
| Fusionner deux sous-agents | celui qui code le test le desserrera à 2 h du matin |
| Laisser l'auditeur interne corriger | on ne saurait plus ce que les autres savent faire, et le prompt ne s'améliorerait jamais |
| Lui laisser choisir la pile | il prendrait un ORM, et les murs sauteraient par le côté |
| Lui demander de valider en cours | on paie trois allers-retours pour un lot mécanique |
| L'autoriser à toucher `_ops/` | le canon se met à suivre le code au lieu de le commander |

</interdits>

---

<etat>

**19/09/2026 — écrit, pas encore lancé.**

| Qui | Quoi | Quand |
|---|---|---|
| **Auditeur interne** (sous-agent 4) | une fiche **entre chaque étape** | 5 fois dans le lot 1 |
| **Auditeur général** (moi) | [GRILLE_AUDIT.md](GRILLE_AUDIT.md), 18 contrôles | **sur le lot rendu** |

⭐ Deux mailles, pas deux chefs : l'une fine et continue, l'autre large et finale.

⏳ **Lot 2** (les 44 commandes) attend [L4](PLAN_2026-09-19.md). Son prompt s'écrira après.

</etat>

---

<source>

Décidé le 19/09/2026 : le codeur est **Grok dans Cursor**, sur la machine d'Hamada, avec accès
au dépôt et **cinq sous-agents** — pas cinq sessions.

⭐ **Trois choix de fond, et leur motif :**

| Choix | Motif |
|---|---|
| **Pas d'ORM** | les 15 murs vivent dans des triggers, des CHECK et des GRANT ; un ORM les efface au premier `migrate` généré, sans que personne le voie |
| **React** | 26 écrans partagent les mêmes listes, fiches et onglets. En JS d'un seul fichier, on recopie 26 fois et la 27e diverge |
| **Le banc appartient au sous-agent 3** | `equipe-saine`, geste 3 : aucun camp ne tient sa propre contrainte. Vu sur Kurso — la session qui possédait le test l'a affaibli pour passer au vert |

⚠️ **Ce que React coûte, dit une fois** : les 86 réglages d'apparence du mock sont à refaire. Le
mock reste la **cible visuelle**, il ne devient pas le code.

</source>
