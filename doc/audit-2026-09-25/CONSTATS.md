# Constats du huitième audit — commit `48e90c4` (branche `lot-2`)

Constats **neufs**, numérotés à la suite : V-138 →. Suivi des 137 précédents dans `SUIVI_V.md` ; des 10 constats
du 7e tour : **4 fermés** (V-130, V-131, V-132, V-135) · **4 partiels** (V-128, V-129, V-133, V-136) · **1 ouvert** (V-134 / V-120, élargi).

**9 constats neufs : 2 critique · 3 elevee · 3 moyenne · 1 bonne.**

⭐ **Pourquoi le lot ne passe pas, en une phrase** : la recommandation du 7e tour — « la garde trouve l'objet une
seule fois et le transmet à la commande » — n'a été appliquée qu'à **5 commandes sur 55**. Les 50 autres relisent
la requête. Le correctif livré (une liste blanche commune et 3 paires de synonymes) ferme les cas montrés et
laisse les autres : la porte systématique `croise_55` en trouve **17**.

---

### V-138 — 17 champs d'identifiant sur 96 écrivent dans une autre agence : la garde ne lit pas ce que la commande écrit
Cible        CODE (et BRAIN : le banc n'a pas de porte systématique)
Famille      I · K4 · Gravité **critique** (mur percé)
Preuve       `rapport/preuves/securite8/croise_55.mjs` et `croise_55.md` : 55 commandes, 96 champs pointés hors agence,
             **79 refus sans écriture, 17 fuites**, 69/69 contrôles positifs. Mesuré par les deux vérificateurs
             (`preuves/suivi8/` : 11 sondes `ok:true` indépendantes). Cas qui résume tout : `CreateCompany`
             `manager` hors agence → **DROIT** ; `manager_compte_id` hors agence → **ÉCRIT**. Autres : `CreateNeed`
             (société — trois comptes PAR font passer une société CAS et son contact en « client »), `CreateUnit`
             (`societe_id`), `CreatePrestation` (ressource d'une autre agence staffée à 200 %), intermédiaire,
             fournisseur, manager, unité. La garde ne pose l'objet résolu (`ctx.resolues`) que pour 5 commandes.
Reproduire   `node rapport/preuves/securite8/croise_55.mjs` contre un serveur de banc (voir l'en-tête du script)
Prétend      V-128 fermé par `CLES_COMMUNES` + `PAIRES` ; porte P-332 « DeclareCVShared avec id et positionnement_id → GARDE »
Mesure       le cas montré est fermé ; la famille reste ouverte — une paire de synonymes non listée suffit
Correction   **Structurelle** : chaque ligne de `agence.ts` déclare **tous** les identifiants que sa commande lit ;
             la garde résout les objets et les pose dans `ctx.resolues` ; les commandes ne lisent jamais un objet
             dans l'entrée. Et `croise_55` entre dans le banc comme porte : **0 fuite** exigé.

### V-139 — Un compte qui a `soi` et une permission d'agence écrit temps, absences et documents dans toutes les agences
Cible        CODE · I · Gravité **critique**
Preuve       `server/src/droits.ts:28-33` : le commentaire dit « `soi` ne couvre aucune agence (D-33) », le code fait
             couvrir **toutes** les agences à `soi` pour les commandes `SOI_MEME` ; `:63` sort de `exigeSoiMeme` dès que
             le compte a aussi une permission d'agence. Mesuré : un compte `RES` + `STAF` (ou `RH`) de PAR écrit un
             document et une absence sur des objets CAS (`ok:true`) ; le même groupe sans `RES` → `DROIT`.
Correction   `soi` ne couvre que la personne du compte ; la présence d'un autre périmètre ne lève jamais la règle « soi-même ».

---

### V-140 — La liste blanche commune refuse 10 clés du contrat : en `saisie_separee`, plus aucun temps ne s'enregistre
Cible CODE · H · **elevee** · Preuve : `mesures`, `facturable`, `contexte`, la devise du coût… → « entrée ambiguë » ; elle laisse aussi passer `etat` (une prestation créée déjà close, sans calcul de marge) · Source `CONFORMITE.md` · Correction : une liste par commande, tirée de son contrat — conséquence directe de V-138.

### V-141 — `journal/PORTES.md` inscrit six portes deux fois : 332 ✅ pour 326 tests
Cible CODE (banc) · F · **elevee** · Preuve : P-333→P-338 recopient mot pour mot P-326→P-331 ; chaque test porte les deux numéros (`audit7.test.ts:91` « P-328 P-335 ») · Un numéro de porte = un test.

### V-142 — Le banc efface toujours des délégations qu'il n'a pas posées — y compris la porte qui devait l'en empêcher
Cible CODE (banc) · G · **elevee** · Preuve : 6 fichiers sur 8, dont celui de P-331 · V-120 → V-134 → ici, troisième tour ouvert.

---

### V-143 — Les migrations 001 et 002 ont été réécrites, et le registre compte 173 politiques quand la base en a 201
Cible CODE + BRAIN · D3/B2 · **moyenne** · Source `GRILLE.md`

### V-144 — `dossier.py` signale un écart de référentiels qui n'existe pas en base
Cible BRAIN · A4 · **moyenne** · Source `GRILLE.md`

### V-145 — Les périmètres `pole` et `equipe` existent dans le modèle et sont ignorés par le code
Cible CODE · I · **moyenne** · Non sondé (angle mort) · Source `SECURITE.md`

---

### V-146 — Bien fait, à garder
Cible CODE + BRAIN · **bonne**
- **0 porte aveugle sur 71 sabotages** : tous les correctifs du 7e tour tombent quand on les retire (Z1 → 5 portes, Z3 → 2, Z5 → 2).
- `TransferContact` gardé (V-130 fermé) ; tables écrivables = tables des commandes (V-131) ; CHECK justifiés au registre (V-132) ; le jeu d'essai se recharge (V-135).
- Hors banc, **173 appels sur 173 en 401**, rien écrit ni tracé ; `soi` **seul** tient.
- Cliquet 12/13 dans un clone neuf, 4 témoins justes ; 41 assertions, plancher 41.
