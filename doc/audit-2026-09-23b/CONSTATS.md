# Constats du quatrième audit — commit `cc3ff64` (branche `lot-2`)

Constats **neufs**, numérotés à la suite : V-096 →. Le suivi des 95 précédents est dans `SUIVI_V.md`
(20 fermés · 4 partiels · 1 ouvert assumé, sur les 25 restés ouverts au 3e tour).

**11 constats neufs : 2 critique · 3 elevee · 5 moyenne · 1 bonne.**

---

### V-096 — Sur une base neuve, `make test` est rouge : la porte P-207 tombe, et la case 1 du cliquet avec elle
Cible        CODE (banc)
Famille      A1 · F1 · Gravité **critique** (le point bloquant du projet est faux)
Preuve       `bash outils/make.sh reset` puis `bash outils/make.sh test` sur `ava_audit4` :
             `✖ P-207 … ManageRefs ADM {"ok":false,"code":"GARDE","message":"catégorie inconnue"}`,
             `make test : KO contrat=1`, `make_rc=1` (`preuves/banc/S0_reference.txt:476,536`). Deuxième passage
             sans reset : identique (`S0_deuxieme_passe.txt`). Cause : le test envoie `categorie:"europe"`
             (`test/contrat/v011-lignes.ts:994`) et la garde du correctif V-084 n'accepte qu'une catégorie **déjà
             présente en table** (`server/src/commandes/admin.ts:205`) ; au seed, `ref_pays` n'a que `defaut`.
             Démontré dans les deux sens : une ligne `categorie='europe'` insérée → la porte passe ; retirée → elle tombe.
             Cliquet réel, rien de saboté : **cases OK=10 KO=2**, case 1 KO (`preuves/banc/C_temoin.txt`).
Reproduire   `AVA_DB=<base neuve> bash outils/make.sh reset && AVA_DB=<base neuve> bash outils/make.sh test`
Prétend      « cliquet 12/12, make test OK, 280 portes vertes »
Mesure       vrai seulement sur une base qui porte une donnée écrite par un tour **antérieur à la garde** ;
             un banc qui ne repart pas de zéro ne prouve rien, et la CI part toujours de zéro
Correction   Le test crée la catégorie dont il a besoin (ou vise un référentiel contraint) ; et le cliquet devrait
             refaire la base avant `make test`, pour que « vert » veuille dire « vert depuis rien ».

### V-097 — Un objet sans agence échappe à tout contrôle de périmètre : les unités des sociétés clientes sont ouvertes à toutes les agences
Cible        CODE
Famille      I · K4 · Gravité **critique** (mur percé, même famille que V-076)
Preuve       `server/src/agence.ts:202` : `if (!agenceId && vu && !ligne.sinonCompte) return;` — l'objet a été lu,
             son agence est nulle, **aucun `exigeDroit` n'est appelé**. Or `server/src/commandes/crm.ts:170` crée
             toute unité de société **cliente** avec `agence_id = null`. Sonde : un compte de l'agence LON renomme
             puis archive une unité cliente de PAR (`ok:true`), témoin positif : la même commande sur une unité
             **interne** de PAR → `DROIT` (`preuves/securite4/`).
Reproduire   créer une unité sur une société cliente, puis `UpdateUnit` avec un compte d'une autre agence
Prétend      grille K4, « le périmètre se juge sur l'objet visé » ; V-076 déclaré fermé
Mesure       fermé pour les objets **qui portent** une agence ; ouvert pour tous les autres
Correction   Pas de repli silencieux : agence nulle = périmètre du demandeur exigé (ou refus), et `agence_id` posé à la création.

---

### V-098 — `ConvertCandidateToResource` crée la ressource dans n'importe quelle agence
Cible CODE · I/H · **elevee** · Preuve `server/src/commandes/identite.ts:196` (`agence` lue dans l'entrée) ; les 4 autres créations refusent · Source `SECURITE4.md` I-02

### V-099 — Sept portes deviennent rouges dès qu'on pose les permissions absentes du seed : elles testent le seed, pas la garde
Cible CODE (banc) · G · **elevee** · Preuve : les 5 permissions manquantes accordées (délégation normale) → 7 portes ✅ tombent (`GRILLE4.md` G-02) · C-10 du 3e audit, démontré dans les deux sens · Correction : ces portes doivent poser elles-mêmes le droit qu'elles testent.

### V-100 — Aucune porte ne garde la confrontation « agence demandée ≠ agence lue »
Cible CODE (banc) · G · **elevee** (porte aveugle sur le périmètre) · Preuve : sabotage **U4** (`entreeAgence: []`) → 0 porte tombe sur 280 (`preuves/banc/U4_entree_agence_ignoree.txt`) · Correction : une porte qui envoie une agence différente de celle de l'objet et attend `DROIT`.

---

### V-101 — Deux outils de garde ne sont gardés par rien : l'`ON_ERROR_STOP` du fichier d'assertions et `verif_serveur.sh`
Cible BRAIN (banc) · G · **moyenne** · Preuve : sabotages **U6** (le `\set ON_ERROR_STOP` retiré du fichier) et **U7** (`verif_serveur.sh` rend 0 quoi qu'il voie) → 0 porte tombe · Correction : une porte qui grep le `\set` dans le fichier, une autre qui joue `verif_serveur.sh` sur une configuration ouverte connue.

### V-102 — `/sante` reste ouverte hors banc et interroge la base à chaque appel
Cible CODE · I · **moyenne** · Source `SUIVI_V.md` N4-5 · Correction : réponse sans requête, ou route de santé interne.

### V-103 — En banc, une vue sans en-tête prend le périmètre d'IA par défaut, et `x-ava-groupe: ADM` rend une liste vide au lieu d'un refus
Cible CODE · I · **moyenne** · Preuve `server/src/index.ts:180` (`cle = nom ?? "ia@ava.test"`) · Correction : pas d'identité par défaut ; un groupe inconnu est un refus.

### V-104 — `unite_organisation.agence_id` reste NULL pour toute société cliente (colonne morte), et P-285 laisse un compte actif à 23 droits par exécution
Cible CODE · **moyenne** · Source `SUIVI_V.md` N4-6, N4-8 · Lié à V-097.

### V-105 — Le contrat ne dit toujours pas quelles politiques 11 commandes lisent, et C-10 reste ouvert
Cible BRAIN · H · **moyenne** · Source `CONFORMITE4.md` C-08, C-10

---

### V-106 — Bien fait, à garder
Cible CODE + BRAIN · **bonne**
- **V-075 et V-076 fermés et gardés** : sabotage du garde d'entrée → P-066 P-271 P-274 tombent ; vue sans filtre → P-266 P-271 ; commande sortie de la table d'agence → 14 portes ; lecture d'agence muette → 44 portes.
- Hors banc : **11 routes sur 11** en 401, `besoin`, `evenement_metier` et `tentative_refusee` inchangés (V-078 fermé).
- **V-077 fermé** : 86 portes effacées **dans un commit** → case 11 KO ; la fenêtre part du départ de la branche (144 commits).
- Périmètre : 40 sondes hors agence refusées, 25 témoins positifs ; 55 commandes = 55 au contrat = 55 dans la table d'agence, 0 écart.
- Murs : 15 sabotages SQL sur 15 font tomber les assertions ; 173/173 politiques, 40/40 référentiels, 0 secret, SQL toujours paramétré.
