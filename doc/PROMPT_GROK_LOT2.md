# Le prompt du LOT 2 — une session, six sous-agents

⭐ **Une seule session Cursor, une seule branche, un seul cliquet.**

**6 sous-agents · branche `lot-2` · une huitième case qui garde la frontière.**

⚠️ **Corrigé le 20/09** : j'avais proposé deux sessions. Hamada a tranché pour des sous-agents,
et il a raison — deux branches faisaient perdre au cliquet exactement ce qu'il protège.

---

<quand_utiliser>

| ✅ On s'en sert | ⛔ On ne s'en sert pas |
|---|---|
| Ouvrir le **lot 2** : les 55 commandes et les écrans | avant que le lot 1 soit **accepté** — il l'est |
| Rouvrir après un lot 2 refusé | pour le lot 3 : il aura son prompt, daté |

⛔ **Le lot 1 doit être fusionné sur `main` AVANT de lancer le lot 2.** Sinon le cliquet compare
contre une branche qui n'a pas les 5 portes, et la case 3 ment.

</quand_utiliser>

---

## ⬇️ LE TEXTE À COLLER

```text
Tu écris le LOT 2 d'Ava Manager. Le lot 1 est accepté : la base
tient, les 15 murs sont dans PostgreSQL, 22 assertions passent et
tombent quand on casse un mur.

Une seule branche : `lot-2`. Six sous-agents. Tu les orchestres.

╔═══════════════════════════════════════════════════════════════╗
║  LA RÈGLE QUI NE BOUGE JAMAIS                                 ║
║                                                               ║
║  ⛔ ON NE PATCHE JAMAIS LE FRONT. JAMAIS.                     ║
║                                                               ║
║  Quand un écran affiche faux, on corrige LE SERVEUR.          ║
║  Un correctif dans l'écran crée une SECONDE vérité. Deux       ║
║  vérités divergent toujours, et c'est celle qu'on a oubliée   ║
║  qui finit par s'afficher au client.                          ║
║                                                               ║
║  L'écran ne calcule jamais une marge, ne décide jamais qu'un  ║
║  bouton est grisé, ne traduit jamais un code d'état, n'écrit  ║
║  jamais `if (etat === '...')`.                                ║
║  Le serveur envoie : le nombre déjà calculé avec sa devise,   ║
║  la liste des actions permises déjà filtrée, le libellé déjà  ║
║  résolu depuis le référentiel.                                ║
╚═══════════════════════════════════════════════════════════════╝

═══ LES SIX SOUS-AGENTS ═══
⛔ Tu n'en fusionnes JAMAIS deux, même « juste pour ce point ».

1. SERVEUR — possède /server et /db.
   ⛔ Ne touche jamais /web, ni /test.
2. ÉCRAN — possède /web.
   ⛔ Ne touche jamais /server, ni /db, ni /test.
3. BANC — possède /test.
   ⛔ NI 1 NI 2 n'y écrivent. Un test qu'on peut assouplir soi-même
   n'est pas un filet, c'est une décoration.
4. AUDIT INTERNE — possède /audit. Passe à chaque fin d'étape.
   ⛔ Ne code pas, ne corrige rien : il renvoie à 1, 2 ou 3.
5. GREFFE — possède /journal.
6. INTÉGRATEUR — ⭐ NOUVEAU, il n'existe que dans ce lot.
   Il ne code pas. Il relit _ops/SPEC_COMMANDES_L4.md et vérifie
   que ce que 1 produit est bien ce que 2 consomme.
   Son livrable : /journal/CONTRAT.md, qui dit pour chaque commande
   « conforme » ou « écart », avec le numéro de ligne de L4.

⚠️ Aucun sous-agent ne tient sa propre contrainte. C'est la seule
règle d'organisation qui compte.

╔═══════════════════════════════════════════════════════════════╗
║  ⛔⛔ LA FRONTIÈRE — et la case qui la garde                   ║
║                                                               ║
║  Les sous-agents 1 et 2 écrivent dans le MÊME dépôt, sur la   ║
║  MÊME branche. Rien ne les sépare physiquement : seule ton    ║
║  orchestration les tient. ⚠️ C'est le point faible de ce mode,║
║  on ne le cache pas — on le MESURE.                           ║
║                                                               ║
║  ⭐ HUITIÈME CASE DU CLIQUET, à ajouter :                     ║
║                                                               ║
║    Aucun commit ne touche /web ET /server à la fois.          ║
║                                                               ║
║    git log --format=%H origin/main..HEAD | while read c; do   ║
║      f="$(git show --name-only --format= "$c")"               ║
║      if grep -q '^web/' <<<"$f" && grep -q '^server/' <<<"$f" ║
║        then echo "FRONTIERE FRANCHIE: $c"; fi                 ║
║    done                                                       ║
║    Vide = OK.                                                 ║
║                                                               ║
║  ⭐ Un commit qui traverse la frontière EST la preuve qu'un    ║
║     sous-agent a fait les deux métiers. Ce n'est pas une      ║
║     question de style : c'est la seule trace qui reste que la ║
║     séparation a tenu.                                        ║
║                                                               ║
║  ⛔ Un commit par sous-agent, son nom dans le message :       ║
║     `[serveur] …`  `[ecran] …`  `[banc] …`  `[greffe] …`      ║
╚═══════════════════════════════════════════════════════════════╝

═══ CE QUE TU LIS, DANS CET ORDRE ═══
1. _ops/DOSSIER.html                le point d'entrée
2. _ops/SPEC_COMMANDES_L4.md        ⭐ LE CONTRAT. 55 commandes.
                                    C'est LUI qui fait foi pour ce lot
3. _ops/MATRICE_DROITS_v1.md        qui a le droit de quoi
4. _ops/MACHINES_ETAT_V1.md         les transitions permises
5. _ops/SPEC_SQL_AVAMANAGER_V1.sql  le schéma, déjà en base
6. _ops/REGISTRE_POLITIQUES_v1.md   §C : les clés à lire
7. _ops/share-hub/terminal.html     ⭐ la cible visuelle de l'écran
8. _ops/THEMES_v1.md                ⭐ 16 couleurs, 9 polices

⛔ NE LIS PAS le reste de _ops/. C'est le chemin parcouru, pas le
canon. Le lire te ferait suivre une version périmée.

═══ CE QUE FAIT LE SOUS-AGENT SERVEUR ═══
Les 55 commandes de L4, dans l'ordre des familles :
  I   CRM                     11 commandes
  II  Identité, recrutement   13
  III Besoin, positionnement  14
  IV  Projet, production      11
  V   Transverse, admin        6
Pour CHACUNE, et sans exception :
 - l'entrée et la sortie exactement comme L4 les décrit
 - les refus, avec leur CODE : DROIT · ETAT · GARDE · MUR ·
   INTROUVABLE
 - l'événement émis, DANS LA MÊME TRANSACTION que la mutation
 - liens.politiques rempli avec les clés lues ET leur valeur
 - ⛔ aucune politique lue autrement que par pol()

⭐ Tu produis aussi /server/contrat/<Commande>.json — le schéma
d'entrée et de sortie. C'est ce que l'écran consomme.

═══ CE QUE FAIT LE SOUS-AGENT ÉCRAN ═══
Les écrans du mock, contre un SERVEUR BOUCHONNÉ qui rend les
sorties figées de /server/contrat/*.json.
⭐ Il n'attend PAS que le serveur soit fini. Si un schéma manque,
il l'écrit dans /web/bouchon/<Commande>.json d'après L4, et le
signale dans QUESTIONS.md.
⛔ Il LIT /server/contrat/*.json. Il n'écrit JAMAIS dans /server —
   pas même « pour corriger un petit truc ».
⚠️ Si tu n'arrives pas à te servir du contrat, LE CONTRAT EST FAUX.
   Dis-le. C'est la meilleure relecture qu'on aura.

Ordre : d'abord la liste et la fiche d'UN objet (le besoin), de bout
en bout, avec ses portes d'écran. Ensuite les autres.
⛔ Pas quinze écrans à moitié. Un écran fini vaut mieux.

═══ LE CLIQUET — une case corrigée, une case en plus ═══
/outils/cliquet.sh tourne en fin de tour ET en pre-push. La CI
relance le même script. Les HUIT cases se MESURENT : aucune ne se
déclare, toutes se calculent.

⭐ UNE CORRECTION ET UN AJOUT, demandés par l'auditeur général :
 - case 7 : ⛔ `git diff HEAD -- _ops/` ne voit que le NON COMMITÉ.
   Un commit qui touche _ops/ la passerait. Mesure plutôt :
     git log --format=%H origin/main..HEAD -- _ops/
   Vide = OK. C'est le bug B-002 du journal.
 - case 8 : la frontière /web contre /server — voir l'encadré.
 - ⭐ le cliquet affiche donc HUIT lignes, et il ne s'arrête
   toujours pas à la première.

═══ LES QUATRE ESPÈCES DE PORTES — il faut les quatre ═══
 A BASE    les assertions : les murs tiennent
 B CONTRAT ⭐ UNE PAR COMMANDE TOUCHÉE. La réponse figée pour un cas
           donné. Un champ qui disparaît fait tomber la porte
 C GESTE   le parcours cliqué, Playwright
 D ÉCRAN   une capture par écran ET PAR THÈME

Le rite, dès qu'une fonctionnalité est approuvée : la NOTER, la
DÉCRIRE en français, POSER la porte, LA VOIR ROUGE, la JOURNALISER.
⛔ Une porte jamais vue rouge ne prouve rien.
⛔ LE NOMBRE DE PORTES NE DIMINUE JAMAIS. En retirer une exige un
   ADR et l'accord d'Hamada.

═══ TU NE T'ARRÊTES PAS ═══
Boucle : prends la première commande (ou le premier écran) non
cochée · fais-la · lance le cliquet jusqu'à 0 · audit interne ·
greffe · coche · reprends.
⛔ Tu ne rends la main qu'à la fin des DEUX moitiés.
Une question : tu l'écris dans QUESTIONS.md avec le choix pris EN
ATTENDANT, et tu continues. Un agent qui attend une réponse est un
agent mort.
Trois échecs sur le même point : tu écris quelle HYPOTHÈSE était
fausse — pas ce que tu as essayé — et tu passes.

═══ LES SEPT INTERDITS ═══
1. ⛔ Aucun `if` métier en dur, ni serveur ni écran. Toute
   bifurcation a une clé, lue par pol().
2. ⛔ Aucun `if` sur un RÔLE. C'est la matrice qui répond, jamais
   `if role === "dp"`.
3. ⛔ Aucune commande qui mute sans émettre son événement.
4. ⛔ Aucun événement émis hors de la transaction.
5. ⛔ Aucune liste renvoyée que l'écran devrait filtrer — le filtre
   finirait dans /web, et ce serait une règle métier.
6. ⛔ Aucun motif en colonne d'objet : les motifs vivent dans
   evenement_metier.motif.
7. ⛔ Tu ne modifies AUCUN fichier de _ops/. Une remarque va dans
   /journal/<ton domaine>/REMARQUES.md, avec le numéro de ligne.

⭐ Le lot 1 a produit six remarques sur le canon, et DEUX étaient
   de vrais bugs qu'on a corrigés. Continue : c'est utile.

═══ COMMENT TU SAIS QUE C'EST FINI ═══
  make up && make migrate && make test   → 0
et, en plus :
 - les 55 commandes ont leur porte de contrat
 - l'objet choisi est fini de bout en bout côté écran, avec ses
   portes de geste et d'écran dans les deux thèmes
 - le cliquet sort en 0 sur ses HUIT cases

⛔ « 54 sur 55 » n'existe pas.

═══ CE QUE TU RENDS ═══
La branche `lot-2`, et dans le message :
 - la sortie complète du cliquet, les HUIT lignes
 - combien de portes, de quelle espèce, laquelle tu as vue rouge
 - /journal/CONTRAT.md — conforme ou écart, par commande
 - REMARQUES.md, QUESTIONS.md, DECISIONS.md, entiers
 - ce que tu as décidé seul

Ne demande pas de valider en cours de route. Va au bout, rends,
l'auditeur général passera.
```

---

<interdits>

| ⛔ Jamais dans ce lot | Le problème que ça évite |
|---|---|
| **Deux branches** pour deux moitiés | ⭐ le cliquet ne sait pas comparer trois branches — et il se perdrait là où on le croit le plus solide |
| Fusionner le sous-agent **Écran** avec le sous-agent **Serveur** | le `if` métier passe d'un côté à l'autre sans qu'on le voie |
| Laisser 1 ou 2 écrire dans `/test` | un test qu'on peut assouplir soi-même n'est pas un filet |
| Un commit qui touche `/web` **et** `/server` | ⭐ **c'est la seule trace mesurable que la séparation a tenu** |
| Laisser l'écran **attendre** le serveur | il code contre le contrat, avec un bouchon |
| Lancer le lot 2 **avant** de fusionner le lot 1 | la case 3 compare contre une branche sans portes, et ment |

</interdits>

---

<etat>

**20/09/2026 — écrit, pas lancé.**

| Avant de lancer | |
|---|---|
| **1** | ⛔ **fusionner `lot-1` sur `main`** — sinon la case 3 ment |
| **2** | créer `lot-2` depuis `main` |
| **3** | coller `prompt-lot2.txt`, en entier |

⭐ **Ce que l'auditeur général fait, et que personne d'autre ne fait** : relire `/web` **à
l'œil**. La case 8 prouve qu'aucun commit n'a traversé la frontière ; elle ne prouve pas qu'un
libellé d'état ne s'est pas glissé dans un objet `const LABELS = {…}`. ⚠️ **Aucun grep ne
remplace ça.**

⏳ **Le jeu synthétique** viendra après : il sert aux portes d'écran quand il faudra des listes
longues, pas au premier écran.

</etat>

---

<source>

Écrit le 20/09/2026, après l'acceptation du lot 1 et l'écriture de L4.

⭐ **Deux nouveautés par rapport au lot 1**, et les deux viennent de ce que l'audit a trouvé :

| Nouveauté | Pourquoi |
|---|---|
| **L'intégrateur** — un sixième sous-agent qui ne code pas | ce que le serveur produit et ce que l'écran consomme divergent en silence ; il compare les deux à L4, ligne par ligne |
| **La huitième case** — la frontière `/web` ⟂ `/server` | ⭐ avec des sous-agents, la séparation n'est plus physique. Ce qui n'est plus garanti par la structure doit être **mesuré**, sinon il n'est plus garanti du tout |

⚠️ **Ce qu'on perd en passant de deux sessions à des sous-agents, dit franchement** : la
séparation devient une discipline au lieu d'être un fait. ⭐ **Ce qu'on gagne est plus grand** :
une seule branche, un seul cliquet, aucune fusion à auditer — et la fusion était précisément le
moment où le cliquet pouvait se perdre.

⚠️ **Et la case 7 est corrigée** : `git diff HEAD` ne voyait que le non commité. C'est le bug
**B-002**, trouvé en auditant le cliquet lui-même. ⭐ **Le contrôleur avait besoin d'un contrôle.**

</source>
