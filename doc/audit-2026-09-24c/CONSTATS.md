# Constats du septième audit — commit `ba9a284` (branche `lot-2`)

Constats **neufs**, numérotés à la suite : V-128 →. Suivi des 127 précédents dans `SUIVI_V.md` ; des 11 constats
du 6e tour : **6 fermés** (V-117, V-121 à V-125) · **3 partiels** (V-118, V-119, V-126) · **1 ouvert** (V-120).

**10 constats neufs : 1 critique · 5 elevee · 3 moyenne · 1 bonne.**

⭐ **V-117 est fermé pour de bon** : la ligne de repli a disparu, chaque commande porte une « nature », et les
55 natures sont cohérentes. Le trou qui reste est d'une **autre famille** : la garde et la commande lisent
l'entrée chacune de leur côté.

---

### V-128 — La garde d'agence et la commande ne lisent pas le même champ : 7 commandes écrivent dans une autre agence
Cible        CODE
Famille      I · K4 · Gravité **critique** (mur percé) — mesuré par les deux vérificateurs, chacun de son côté
Preuve       Confirmé par lecture, deux cas :
             · `DeclareCVShared` — la garde lit `["id", "positionnement_id"]` (`server/src/agence.ts:56`, `id` d'abord) ;
               la commande lit `req(ctx.entree, "positionnement_id", "id")` (`server/src/commandes/besoin.ts:276`,
               `positionnement_id` d'abord). Envoyer les deux : la garde juge un positionnement de PAR, la commande
               modifie celui de CAS. Mesuré en base : positionnement CAS passé à « présenté » puis « refusé par le
               client » (`RecordClientDecision`, même ligne `POSITION`).
             · `CreateProject` — la garde lit `agence` (`agence.ts:134`) ; la commande écrit aussi un `besoin_id`
               (`projet.ts:58`) sans jamais lire son agence. Mesuré : signer la prestation fait passer un besoin
               d'une autre agence à « pourvu ».
             Et `CreateCandidate`, `CreateResource` (garde sur `agence`, écriture par `agence_id`), `CreateCompany`
             (l'agence du `manager` passé en entrée). Sondes : `preuves/suivi7/30_sondes_d31.sh`, `preuves/securite7/`.
Reproduire   `DeclareCVShared` avec `{"id": "<positionnement PAR>", "positionnement_id": "<positionnement CAS>"}` sous un compte PAR
Prétend      « le périmètre se juge sur l'objet visé » (K4)
Mesure       il se juge sur **un** objet de l'entrée — pas forcément celui que la commande écrit
Correction   La garde trouve l'objet **une seule fois** et le transmet à la commande, qui ne relit plus l'entrée ;
             et tout identifiant qu'une commande écrit (un `besoin_id` dans `CreateProject`) passe par la garde.

---

### V-129 — Un périmètre `soi` posé par `ManageGroups` se comporte comme `global`
Cible CODE · I · **elevee** · Preuve `server/src/droits.ts:32` : `r.type_code === "global" || r.type_code === "soi"` couvre toute agence ; `exigeSoiMeme` ne restreint ensuite que les 3 commandes de `SOI_MEME` · Correction : `soi` ne couvre que l'agence du compte, et seulement pour les commandes « soi ».

### V-130 — `TransferContact` : juger une seule des deux agences ne fait tomber aucune porte
Cible CODE (banc) · G · **elevee** · Preuve : sabotage **Y6** → 0 porte sur 318 (`preuves/banc/Y6_transfert_une_agence.txt`) ; V-119 reste partiel, P-323 ne garde rien · Correction : une porte qui transfère vers une société d'une autre agence et attend `DROIT`.

### V-131 — `ava_app` peut encore écrire 19 tables qu'aucune commande n'écrit, dont `groupe`, `permission`, `perimetre` et `agence`
Cible BRAIN · I · **elevee** · Les 27 tables du lot 3 sont fermées (V-122 fermé), mais pas celles-là · Source `SECURITE.md`

### V-132 — Deux listes d'états figées en CHECK dans la migration 013, invisibles au grep B5
Cible CODE + BRAIN · B5 · **elevee** · Source `GRILLE.md`

### V-133 — P-062 à P-065 sont repassées de ✅ à ⏳ sur la branche, sans qu'aucune case du cliquet le voie
Cible BRAIN (banc) · F10 · **elevee** · Source `GRILLE.md`

---

### V-134 — V-120 reste ouvert : trois fichiers de portes effacent 4 délégations sur 6 qu'ils n'ont pas posées
Cible CODE (banc) · G · **moyenne** · Preuve : `matrice`, `audit4`, `chemin` · Source `SUIVI_V.md`

### V-135 — `_ops/JEU_ESSAI.sql` ne se charge plus : `societe.agence_responsable_id` est obligatoire depuis 011
Cible BRAIN · J · **moyenne** · Le seul jeu de données autorisé pour l'audit est cassé.

### V-136 — La grille dit « 11 contrôles » pour la famille F, qui en compte 13 ; la garde de secours d'un objet introuvable n'est gardée par aucune porte
Cible BRAIN + CODE · **moyenne** · Sabotage Y1 : 0 porte, la commande refusant elle-même ensuite (double garde, pas de trou) · V-118 et V-126 restent partiels.

---

### V-137 — Bien fait, à garder
Cible CODE + BRAIN · **bonne**
- **V-117 fermé et gardé** : la ligne de repli a disparu ; `ArchiveObject` refuse les 10 types hors agence ou renvoie vers leur commande dédiée ; retirer ce contrôle sur une action ou une personne fait tomber P-318 / P-319.
- **Les 55 natures de commande sont cohérentes** : aucune commande `creation` ou `soi` ne modifie un objet existant ; un objet introuvable → `INTROUVABLE`, une agence nulle → `DROIT`.
- Le modèle société tient sous sabotage : mode forcé, agence responsable muette, contact libre → 3, 15 et 7 portes tombent.
- `paiement.etat_code` a son référentiel ; les 27 tables du lot 3 sont fermées ; chaque section de L4 porte son lot cible.
- 52 sondes directes hors agence refusées, rien d'écrit ; hors banc toutes les routes en 401 ; 15 sabotages SQL sur 15.
