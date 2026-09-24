# Constats du sixième audit — commit `a26291c` (branche `lot-2`)

Constats **neufs**, numérotés à la suite : V-117 →. Le suivi des 116 précédents est dans `SUIVI_V.md` ;
des 10 constats du 5e tour : **3 fermés** (V-111, V-112, V-114) · **6 partiels** (V-107 V-108 V-109 V-110 V-115, et V-116 « bonne » à 9/10) · **1 ouvert** (V-113).

**11 constats neufs : 1 critique · 5 elevee · 4 moyenne · 1 bonne.**

⭐ **Le fil des quatre derniers tours** : V-076 → V-097 → V-107/V-108 → V-117. Le même trou change de porte
à chaque tour, parce que la correction se fait **commande par commande**. Sa racine est une seule ligne :
`server/src/agence.ts:285`, `else await exigeDroit(ctx, ctx.commande, ctx.compte.agence_id);` — quand l'agence
de l'objet n'est pas lue, le contrôle se compare au demandeur. Tant qu'elle existe, toute commande dont la
ligne de correspondance oublie un type d'objet est ouverte.

---

### V-117 — `ArchiveObject` archive une société, un contact, une personne ou une action d'une autre agence
Cible        CODE
Famille      I · K4 · Gravité **critique** (mur percé)
Preuve       `server/src/commandes/admin.ts:39-49` : `ArchiveObject` sait archiver **10 types** (dont `societe`,
             `contact`, `personne`, `action`). `server/src/agence.ts:135-143` : sa ligne de correspondance n'en
             **lit que 5** (unité, candidat, ressource, besoin, projet). Pour les autres, rien n'est trouvé, et
             `agence.ts:285` vérifie l'agence **du demandeur**. Mesuré par les deux vérificateurs, chacun de son
             côté : même compte, même société d'une autre agence — `ArchiveCompany` → **DROIT**,
             `ArchiveObject {type:"societe"}` → **ok:true, archivée** (`preuves/securite6/`, `preuves/suivi6/30_archiveobject_porte_derobee.sh`).
             ⛔ Sabotage **W1** (la ligne de repli remplacée par `return`) : **0 porte sur 307 ne tombe**.
Reproduire   `bash rapport/preuves/suivi6/30_archiveobject_porte_derobee.sh` (dans le clone de lecture)
Prétend      V-108 fermé : « le périmètre d'une société se juge par son agence responsable »
Mesure       vrai pour les 6 commandes société/contact ; faux par la porte générique qui archive les mêmes objets
Correction   **Supprimer le repli** : un objet dont l'agence n'est pas lue est un **refus**, jamais une permission ;
             puis donner à `ArchiveObject` un lecteur par type qu'il sait archiver. Une porte par type.

---

### V-118 — La dernière ligne de repli d'agence subsiste, contre la décision D-26, et rien ne la garde
Cible CODE · I · **elevee** · Preuve `server/src/agence.ts:285` ; le commentaire `:278-279` (D-26) dit « une agence demandée ailleurs est un périmètre, pas un repli » et la ligne suivante fait le repli · Sabotage W1 aveugle · Correction : voir V-117.

### V-119 — `TransferContact` laisse le contact dans une agence et sa société dans une autre
Cible CODE · H · **elevee** · Source `SUIVI_V.md` N6-6

### V-120 — Le banc efface des délégations qu'il n'a pas posées
Cible CODE (banc) · G · **elevee** · Preuve : 4 délégations sur 6 posées par l'auditeur effacées par `retirer()` après un passage de la matrice ; V-110 reste partiel (52/52 avec délégations, mais au prix des délégations d'autrui) · Correction : chaque porte ne retire que ce qu'elle a posé.

### V-121 — `paiement.etat_code` fige trois codes sans référentiel
Cible CODE · B5 · **elevee** (règle du projet : toute liste de valeurs est un `ref_*`) · Preuve `db/migrations/012_schema_v1_complet.sql:883` · Les 11 autres états ont leur référentiel · Correction : `ref_etat_paiement`, ou une ligne au registre qui assume le gel.

### V-122 — Le lot 3 est déjà en base : 27 tables écrivables par l'application, 40 commandes contractées sans code
Cible BRAIN · J · **elevee** · Preuve : `012_schema_v1_complet.sql` et `013_applications_boond.sql` donnent `INSERT/UPDATE` à `ava_app` sur 27 tables qu'aucune commande n'écrit ; `SPEC_COMMANDES_L4.md` contracte **95** commandes, la MATRICE **98**, le serveur en sert **55** (`CONFORMITE.md`) · Correction : marquer un lot cible par section de L4, et ne donner le GRANT qu'avec la commande.

---

### V-123 — La branche « agence nulle → périmètre global » est devenue inatteignable
Cible CODE · G · **moyenne** · Preuve : sabotages X1 et X4 (branche vidée, `exigeGlobal` muet) → 0 porte ; toutes les colonnes d'agence lues sont NOT NULL depuis 009-011 · C'est bien, mais c'est du code mort gardé par rien : le jour où une colonne redevient nullable, personne ne le verra.

### V-124 — V-113 ouvert : trois commits sans `Role:` écrits après le constat, et la CI ne vérifie pas
Cible CODE · D5 · **moyenne** · Preuve `git log` ; `grep Role .github/workflows/ci.yml` → 0

### V-125 — `LireDonneesRHSensibles` n'est donnée à personne, alors que la matrice la réserve au groupe RH
Cible BRAIN · H · **moyenne** · Les permissions sans titulaire passent de 5 à 6 (D-30) · Source `CONFORMITE.md`

### V-126 — La grille annonce 42 contrôles et en compte 43 ; le grep B1 n'a pas bougé
Cible BRAIN · A/B1 · **moyenne** · V-109 reste partiel : `RecordClientDecision` lit bien le référentiel, mais le contrôle qui l'aurait vu ne voit toujours pas un `.includes()`.

---

### V-127 — Bien fait, à garder
Cible CODE + BRAIN · **bonne**
- **Le choix de modèle est fait et paramétrable** : `societe.agence_responsable_id` + politique `societe.perimetre.mode` à trois modes, qui donnent trois comportements mesurés ; forcer le mode en dur fait tomber 3 portes (X2).
- Le cliquet a **13 cases**, et la case 13 (F13) **tourne** : « lot-2-brain est un ancêtre de HEAD » (V-112 fermé). Clone neuf : 12/13, seul le crochet manque — la CI le pose.
- Un numéro de migration = un fichier (V-111) ; `profil_candidat.agence_id` obligatoire (V-114).
- 69 sabotages : tous les correctifs des tours précédents font tomber une porte quand on les retire ; 15 sabotages SQL sur 15 font tomber les assertions (40 → 9 quand on retire deux murs).
- 49 refus, 0 ligne écrite ; hors banc, 11 routes sur 11 en 401 ; SQL paramétré, 4 vecteurs d'injection repoussés.
