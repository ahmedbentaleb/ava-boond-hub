AVA MANAGER — SUITE DU LOT 2, PUIS LOT 3
========================================
Mise à jour du 20/09/2026, après vérification de ta livraison par
l'auditeur général. Lis ce prompt en entier avant d'écrire une ligne.


0. LA MACHINE — POSTGRESQL EST DÉJÀ INSTALLÉ, PLUS BESOIN DE DOCKER
───────────────────────────────────────────────────────────────────
PostgreSQL 16.15 tourne en SERVICE WINDOWS sur 127.0.0.1:5432.
Vérifié le 20/09 : « pg_isready » répond « acceptation des connexions ».

  binaires   C:\Program Files\PostgreSQL\16\bin
  base       ava
  URL        postgres://postgres@127.0.0.1:5432/ava

⛔ NE LANCE PAS DOCKER. Il est tombé deux fois en une heure le 20/09 et
   t'a bloqué. « outils/make.sh » détecte le service local tout seul et
   l'annonce en première ligne : « moteur : local (...) ».
   Docker ne reste qu'en secours, forcé par AVA_MOTEUR=docker.
⛔ JAMAIS LES DEUX À LA FOIS : deux bases, c'est deux vérités, et on
   teste dans l'une en codant contre l'autre. C'est déjà arrivé.

  bash outils/make.sh migrate    joue les migrations non encore jouées
  bash outils/make.sh test       migrate + assertions + contrat + geste
  bash outils/make.sh reset      refait la base à neuf, puis migrate
  bash outils/cliquet.sh         les 10 cases du cliquet

Si « make test » te dit « moteur : docker », c'est que le service est
arrêté : relance-le dans les services Windows, ne contourne pas.


1. CE QUI EST ACQUIS — MESURÉ PAR MOI, PAS DÉCLARÉ PAR TOI
──────────────────────────────────────────────────────────
  cliquet        10 cases sur 10          ✅ relancé, confirmé
  assertions     23 OK sur 23             ✅
  portes ✅      64                       ✅
  contrat        0 échec sur 55           ✅
  seul rouge     P-061 (geste), ⏳ lot 3  ✅ légitime

La parade ⏳ est posée et elle tient. Les cases 9 et 10 existent.
Le lot 2 est ACCEPTÉ sur la forme.


2. ⛔ CE QUI NE VA PAS — À CORRIGER AVANT TOUT AUTRE TRAVAIL
────────────────────────────────────────────────────────────
Sur tes 55 portes de contrat, voici ce qu'elles vérifient réellement :

  40  « refuse INTROUVABLE »
  10  « refuse DROIT »
   2  « refuse GARDE »
   3  « rend l'objet créé »       ← les seules qui prouvent quelque chose

⭐⭐ AUTREMENT DIT : UN SERVEUR QUI REFUSE TOUT PASSERAIT 52 DE TES 55
    PORTES. Tu as écrit 1 897 lignes de commandes, et rien ne prouve
    qu'elles ÉCRIVENT quoi que ce soit.

⛔ Une porte qui ne peut pas distinguer un serveur juste d'un serveur
   qui refuse tout ne mesure rien. C'est le même défaut que l'assertion
   A-001 du lot 1 : elle était verte pendant qu'un mur était percé.

TA TÂCHE 1, BLOQUANTE — LE CHEMIN QUI PASSE
Pour CHACUNE des 55 commandes, ajoute une porte « chemin nominal » :

  - elle crée ce dont elle a besoin (société, personne, besoin...)
  - elle appelle la commande avec des entrées VALIDES
  - elle vérifie la ressource rendue, champ par champ
  - elle vérifie que l'ÉVÉNEMENT a bien été écrit dans
    « evenement_metier » : un type, un acteur, une date
  - elle vérifie que l'écriture a bien eu lieu, en relisant

Numérote-les à la suite (P-066 et suivantes), espèce B CONTRAT, lot
cible 2. Rite habituel : posée, VUE ROUGE, journalisée, puis servie.

⛔ Tu ne touches à rien d'autre tant que ces 55 portes ne sont pas ✅.


3. TA TÂCHE 2 — LES REFUS DOIVENT ÊTRE LES BONS
───────────────────────────────────────────────
Tes portes vérifient qu'il y a un refus. Elles ne vérifient pas que
c'est LE BON refus, ni qu'il arrive au BON MOMENT.

Pour chaque commande, une porte de plus qui vérifie que :
  - un utilisateur sans le droit reçoit DROIT, et RIEN n'a été écrit
  - un objet dans le mauvais état reçoit ETAT, et RIEN n'a été écrit
  - la transaction a bien été annulée : relis, la base est intacte

⛔⛔ ET LE POINT QUI COMPTE LE PLUS : UN REFUS « MUR » VU PAR UN
    UTILISATEUR EST TOUJOURS UN BUG DE LA COMMANDE. Le mur est le
    dernier filet, pas le contrôle. Écris une porte qui vérifie
    qu'AUCUNE des 55 commandes ne rend jamais le code MUR sur une
    entrée simplement invalide. Si elle est rouge, corrige la commande,
    pas la porte.


4. TA TÂCHE 3 — LES POLITIQUES SONT-ELLES VRAIMENT LUES ?
─────────────────────────────────────────────────────────
Le principe qui commande tout le projet :

  ⭐ TOUT DOIT ÊTRE PARAMÉTRABLE.

173 politiques en base. Une commande qui ne lit pas sa politique et
décide en dur est un REFUS D'AUDIT — pas une remarque, un refus.

Écris une porte par politique que tes commandes sont censées lire
(colonne « politique lue » de « _ops/SPEC_COMMANDES_L4.md ») :

  1. lis le comportement avec la valeur par défaut
  2. change la politique avec SetPolicy
  3. relance la même commande
  4. VÉRIFIE QUE LE COMPORTEMENT A CHANGÉ
  5. remets la valeur par défaut

⛔ Si le comportement ne change pas, la politique n'est pas lue : la
   valeur est en dur quelque part. Ouvre une ligne dans journal/BUGS.md
   et corrige LA COMMANDE.


5. ENSUITE SEULEMENT — LE LOT 3 : LES ÉCRANS
────────────────────────────────────────────
P-061 est ⏳ lot cible 3. Le lot 3, c'est les 26 écrans, servis par le
serveur du lot 2.

⛔⛔ JAMAIS PATCHER LE FRONT. JAMAIS. Si un écran affiche faux, la
    correction est DANS LE SERVEUR. Tout vient du serveur : les
    libellés, les états, les actions offertes, le thème.
⛔ AUCUNE ICÔNE CORBEILLE NULLE PART. M-8 : rien ne se supprime, tout
   s'archive, et « ava_app » n'a pas le droit DELETE.
⛔ Chaque écran a DEUX portes D : thème sombre ET thème clair.


6. LES INVARIANTS — INCHANGÉS DEPUIS LE PREMIER JOUR
────────────────────────────────────────────────────
  ⛔ Aucun « if » métier en dur : politique · mur · référentiel.
  ⛔ Pas d'ORM. Du SQL, avec « pg », à la main.
  ⛔ Aucun commit ne touche /web ET /server à la fois (case 8).
     Préfixe : [serveur]  [ecran]  [banc]  [greffe]
  ⛔ Tu n'écris JAMAIS dans « _ops/ » — c'est le canon (case 7).
  ⛔ Tu ne touches pas à « db/migrations/ ». Si une migration te gêne,
     tu ouvres une ligne dans journal/BUGS.md et tu t'arrêtes.
  ⛔ N'assouplis jamais une case du cliquet parce qu'elle te gêne. On
     corrige ce qu'elle mesure. C'est arrivé le 20/09 sur la case 7.
  ⛔ Ne pousse jamais avec --no-verify.
  ⛔ Une porte ✅ ne redevient JAMAIS ⏳ (case 9).
  ⛔ Une ⏳ sans lot cible est refusée (case 10).

Les cinq codes de refus, et il n'y en a pas d'autres :
  DROIT · ETAT · GARDE · MUR · INTROUVABLE


7. LES SIX SOUS-AGENTS — DANS TA SESSION, PAS SIX SESSIONS
──────────────────────────────────────────────────────────
  SERVEUR        écrit /server. Ne touche jamais /web.
  ÉCRAN          écrit /web. Ne touche jamais /server.
  BANC           écrit /test. Pose les portes, les voit rouges,
                 les journalise. C'est lui qui tient le cliquet.
  AUDIT INTERNE  passe entre chaque étape. Ne code pas.
  GREFFE         tient journal/ : PORTES, ETAPES, BUGS, DECISIONS, ADR.
  INTÉGRATEUR    ne code pas. Vérifie la conformité à L4, commande
                 par commande, avant de rendre la main.


8. CE QUE TU ÉCRIS EN AVANÇANT
──────────────────────────────
  journal/PORTES.md      une ligne par porte, avec sa date de vue rouge
  journal/ETAPES.md      une ligne par étape finie
  journal/BUGS.md        tes bugs, numérotés B-001, B-002, ...
                         (les miens sont A-, ne les mélange pas)
  journal/DECISIONS.md   toute décision technique, avec son motif
  journal/QUESTIONS.md   ce que tu ne peux pas trancher seul
  journal/adr/           une ADR par décision structurante


9. TU NE T'ARRÊTES PAS
──────────────────────
Ordre de passage, et pas un autre :
  1. les 55 portes « chemin nominal »          ← bloquant
  2. les portes de refus juste et d'annulation
  3. les portes de politique
  4. le lot 3, les écrans

⛔ TU NE RENDS PAS LA MAIN TANT QUE LE CLIQUET N'EST PAS AU VERT.
⛔ Si tu es bloqué trois tours de suite sur la même erreur : tu
   t'arrêtes, tu nommes l'hypothèse qui était fausse, et tu poses UNE
   question dans journal/QUESTIONS.md.

Les fichiers qui font foi, dans l'ordre où tu les lis :
  _ops/SPEC_COMMANDES_L4.md         le contrat des 55 commandes
  _ops/PORTES_EN_ATTENTE.md         la parade ⏳
  _ops/SPEC_SQL_AVAMANAGER_V1.sql   le schéma commenté, avec les motifs
  _ops/REGISTRE_POLITIQUES_v1.md    les 173 politiques
  _ops/GRILLE_AUDIT.md              les 36 contrôles sur lesquels je t'audite
