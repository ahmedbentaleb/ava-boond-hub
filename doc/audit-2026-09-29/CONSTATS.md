# Constats du neuvième audit — commit `071b7b2` (branche `lot-2`)

Constats **neufs**, numérotés à la suite : V-147 →. Chacun porte, comme l'exige `_ops/prompt-audit-9.txt` :
**Famille** (la règle violée, pas le cas) · **Étendue** (mesurée) · **Correction de construction** (ce qui rend la
famille impossible) + la **porte** qui énumère la famille. ⛔ Aucun « corriger la ligne X ».

Suivi des 9 constats du 8e tour (`SUIVI_V.md`) : **5 fermés** (V-139, V-141, V-143, V-144, V-145) · **3 partiels** (V-138, V-140, V-146) · **1 ouvert** (V-142, 4e tour).

**15 constats neufs : 3 critique · 7 elevee · 4 moyenne · 1 bonne.**

---

### V-147 — Des valeurs de politique admises n'ont aucun comportement codé
Cible        CODE (et BRAIN : le registre admet des valeurs que rien n'exécute)
Gravité      **critique** — le principe du projet (« tout est paramétrable ») est faux pour ces valeurs
Famille      *Toute valeur listée dans `valeurs_possibles` d'une politique doit produire un comportement défini.*
Étendue      **11 valeurs sur 7 politiques**, mesurées par appel réel (`SECURITE.md`, `preuves/securite9/`) : la valeur
             la plus stricte de `temps.periode` **retire** la garde ; `temps.validation = par_dp` bloque **toute**
             saisie de temps ; `change.mode = taux_saisi` fait échouer la clôture en `MUR` ; …
Preuve       `SetPolicy` de chaque valeur puis la commande qui la lit — sorties dans `preuves/securite9/`.
Correction   **Construction** : chaque politique déclare, dans une table de dispatch côté serveur, un comportement par
             valeur ; une valeur sans entrée est refusée par `SetPolicy` (et par un CHECK en base).
             **Porte** : toutes les politiques × toutes leurs valeurs × la commande qui les lit — une valeur qui ne
             change rien ou qui lève hors refus contractuel est rouge.

### V-148 — Les écritures en cascade ne repassent ni par le droit ni par la garde d'agence
Cible        CODE · Gravité **critique** (mur percé)
Famille      *Une commande qui en modifie une autre en cascade doit subir le droit et la garde de cette autre.*
Étendue      2 cascades mesurées, 2 murs contournés : **droit** — STAF, qui n'a que `CloseProject`, clôt une prestation
             signée alors que `ClosePrestation` lui est refusé en direct ; **agence** — au réglage par défaut, une
             société de Lyon passe « client » par une commande d'un compte de Paris (référence recopiée, puis cascade).
             L'inventaire complet des cascades n'existe pas : c'est une partie du constat.
Correction   **Construction** : une cascade s'exécute en appelant la commande fille par `executerCommande` (droit,
             garde, événement), jamais en écrivant la table directement ; la liste des cascades est une donnée.
             **Porte** : pour chaque cascade déclarée, un acteur qui a la commande mère mais pas la fille, et un objet
             fils d'une autre agence → refus, rien écrit.

### V-149 — La garde d'agence ne tient qu'au réglage par défaut de la politique société
Cible        CODE + BRAIN (la porte croisée n'est jouée qu'au défaut) · Gravité **critique**
Famille      *Le cloisonnement doit tenir sous toutes les valeurs des politiques de périmètre.*
Étendue      Sous `societe.perimetre.mode = partagee` ou `par_besoins` : un compte de Paris, en ajoutant un
             `contact_id` ou un fournisseur, **modifie un projet et un besoin de Lyon, crée un projet à Lyon et
             convertit un candidat de Lyon** (`preuves/suivi9/`). Cause : `server/src/agence.ts:656` — quand un seul
             objet société ou contact est lu, `modeSociete` tranche et **rend la main** sans juger les autres.
Correction   **Construction** : la politique société ne juge **que** la société ou le contact ; elle ne remplace jamais
             le verdict des autres objets lus. **Porte** : la porte croisée jouée sous **chaque** valeur de chaque
             politique de périmètre, pas seulement au défaut.

---

### V-150 — Les routes de lecture filtrent par le périmètre de n'importe quelle permission
Cible CODE · **elevee** · Famille : *une lecture exige un droit de lecture, jugé sur son propre périmètre.* · Étendue : les 2 routes de lecture ; un compte qui n'a que `SetOwnTheme` (global) lit les 84 besoins des deux agences et la fiche de Lyon · Correction : une permission de lecture par route ; **porte** : routes × groupes × agences.

### V-151 — Une clé admise dans l'entrée peut ne correspondre à aucun lecteur
Cible CODE · **elevee** · Famille : *la liste des clés, les lecteurs et la porte croisée doivent venir d'UNE seule déclaration typée par commande.* · Étendue : clés acceptées puis ignorées (3 commandes, dont `ConvertCandidateToResource` : agence Lyon demandée, ressource créée à Paris) ; un fournisseur de Lyon attaché à une ressource de Paris, porte croisée verte (mutation MB) · Correction : une déclaration par commande — clé → table → rôle — dont dérivent la liste blanche, les lecteurs et les cas de la porte croisée.

### V-152 — La règle « la commande ne relit pas l'entrée » n'est tenue par rien
Cible CODE + BRAIN · **elevee** · Famille : *un objet ne se lit que dans `ctx.resolues`.* · Étendue : **157** lectures directes de `ctx.entree`, **29** commandes relisent `id`, 17 lignes gardent des synonymes ; la porte statique promise (D-37) n'existe pas · Correction : remettre au handler une entrée **gelée sans identifiants** ; **porte** statique qui refuse tout accès d'objet à `ctx.entree`.

### V-153 — La porte croisée P-339 est ⏳ : rouge, elle ne bloque pas le cliquet
Cible BRAIN · F · **elevee** · Preuve `journal/PORTES.md` (P-339 ⏳) ; cliquet réel : « exécutées=331 ✅=330 » · La case 14 vérifie la copie, pas le verdict.

### V-154 — Le GRANT calculé est trop large, et sa porte ne voit ni les colonnes ni le rôle de connexion
Cible CODE · I · **elevee** · Étendue : UPDATE jamais utilisé sur **6** tables (dont `groupe_permission_perimetre`) ; toutes les colonnes ouvertes sur **19** tables ; P-325 ignore les droits par colonne et `ava_serveur` · Correction : GRANT calculé **par colonne** depuis les écritures des commandes ; porte sur les deux rôles.

### V-155 — `TransferContact` : le jugement de la seconde agence n'est gardé par aucune porte
Cible CODE (banc) · G · **elevee** · Preuve : sabotages R7 et M2 → 0 porte · 4e tour (V-119 → V-130 → V-142 → ici).

### V-156 — Le banc efface les délégations d'autrui, 4e tour
Cible CODE (banc) · G · **elevee** · Étendue : 6 fichiers sur 8 (`matrice`, `audit4`, `audit3` : 6 → 1) ; la case 17 regarde où est le `DELETE`, pas ce qu'il retire · Correction : chaque porte ne retire que les lignes qu'elle a créées (clé de lot), et une case qui compare les délégations avant/après.

---

### V-157 — Rien en base ne garde l'empreinte d'une migration appliquée
Cible CODE · D3 · **moyenne** · Étendue : 7 réécritures en 5 commits (dont 2 sur `main`), un renommage 009 → 010 · Correction : empreinte sha256 dans `schema_migrations`, case du cliquet qui la compare.

### V-158 — Hors banc, trois requêtes répondent 500 avant la garde
Cible CODE · I · **moyenne** · JSON mal formé, type XML, corps > 1 Mo · Correction : la garde avant l'analyse du corps.

### V-159 — `make test` n'est pas rejouable sans refaire la base
Cible CODE (banc) · **moyenne** · Preuve : la base du jeu d'essai est une copie (`TEMPLATE`) de la base courante (`outils/make.sh:390`) ; une base déjà jouée la fait échouer (`preuves/banc/S2b.txt`) · Le sabotage S2b ne peut plus être mesuré.

### V-160 — La grille exige une session (K2) que le lot 2 ne peut pas livrer
Cible BRAIN · K2 · **moyenne** · En banc, l'e-mail dans l'en-tête suffit (décision D-10, authentification au lot 2c) : la grille compte 🔴 un défaut assumé · Correction : K2 marquée « lot 2c » dans la grille.

---

### V-161 — Bien fait, à garder
Cible CODE + BRAIN · **bonne**
- La porte croisée est **entrée dans le banc** : 55 commandes, 117 identifiants, 0 fuite ; retirer une déclaration la fait tomber (R1).
- **8 règles de construction sur 10 gardées** : synonyme ajouté (8 portes), `soi` global (P-329, P-340), GRANT hors commande (P-325), liste de clés ignorée (P-327), unité hors table (22 portes).
- Les commandes lisent leurs objets dans `ctx.resolues` ; aucune commande `creation`, `installation` ou `soi` n'écrit un objet existant ; aucun trigger ne traverse les agences.
- Registre des politiques exact (202 = 202) ; la saisie de temps en `saisie_separee` fonctionne ; hors banc, 22 routes sur 25 en 401.
