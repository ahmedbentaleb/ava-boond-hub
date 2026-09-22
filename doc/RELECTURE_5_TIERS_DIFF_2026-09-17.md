Non signable. 14 « patché conforme », 8 « patché de travers ». D-1, D-9 et T-2 sont les trois de travers qui changent encore une table ou un mur. Canon intact.

Lu : RELECTURE_5_MODELE_DONNEES §0, puis `git diff 093d43a` sur les quatre fichiers. Aucune ligne du tableau §0 sautée. Pas de patch. Pas de commit.

## Avis

Le livrable 5 a vraiment bougé : cycle `agence`/`perimetre` cassé, NOT NULL sous politique relâché, index unique retiré, `document` à FK, `archive_le` sur temps/absence, M-14 devenu un trigger. Ce n'est pas cosmétique.

Trois trous restent bloquants. **D-1** : une table d'unités pour le client et l'interne est tenable (M-12 sépare les arbres) ; garder **en plus** la table `agence` sans lien vers `unite_organisation` laisse deux hiérarchies internes — le tranché D-1 disait « une seule, pas deux ». **D-9** : la colonne part, le motif cite encore ADR-003 alors que §0 avoue que ce n'en est pas une conséquence. **T-2** : M-14 est un mur ; M-15 est écrit à la fois comme mur et « pas un mur ».

Le fichier `MODELE_METIER_CANONIQUE_v1.md` est dans le diff et n'a reçu que M-14/M-15 et « 59 → 60 ». Il contredit encore D-3, D-5, D-6.

## Tableau §0

| # | Verdict | Ligne |
|---|---|---|
| **D-1** | **patché de travers** | Cycle ôté : MODELE_DONNEES L363. Trigger `perimetre.unite_id` → société `interne` : L410. `equipe` ajouté : L177. **Reste :** `agence` est toujours une 2e hiérarchie interne, sans FK vers `unite_organisation` — contraire à RELECTURE §1 D-1 « une seule hiérarchie interne, pas deux » (L48). Pas de XOR `perimetre.agence_id` / `unite_id` (L410 : les deux NULL = `global`, les deux remplis = ?). `ref_type_unite` n'existe pas au registre §B ; `equipe` n'y est pas. MODELE_METIER L16 : UnitéOrganisation = « pôle, BU, service », pas équipe, pas interne. **Tenable :** une table, deux arbres (client vs interne) oui — BM-12 L56. Deux structures internes (`agence` + unités Avaliance) non, tant que le lien n'est pas écrit. |
| D-2 | **patché conforme** | MODELE_DONNEES L129–130, L177, L185 : `statut_commercial_code` NULL sur unité et contact, NULL = hérite. |
| D-3 | **patché de travers** | REGISTRE L45–46 et MODELE_DONNEES L164–166 : rôle ≠ statut, écrit. **Cassé :** MACHINES §7 L110 « Rôles (`client`, `fournisseur`, `interne`) » — fichier du diff, non touché. MODELE_METIER L14 : « rôles client / prospect / fournisseur / interne ». |
| D-4 | **patché conforme** | MODELE_DONNEES L328, L337 : `archive_le` + `TimesheetCancelled` / `AbsenceCancelled`. |
| D-5 | **patché de travers** | MODELE_DONNEES L35, L249, L261 : NULL en base. **Cassé dans le diff :** MODELE_METIER L59 « Projet → Contact \| 1 \| NOT NULL » ; L55 « Besoin → Qualification \| NOT NULL — jamais flottante ». |
| D-6 | **patché de travers** | MODELE_DONNEES L238 ; REGISTRE L73 : garde de commande, index simple. **Cassé dans le diff :** MODELE_METIER L54 « index partiel sur les catégories `propose`, `presente` ». |
| D-7 | **patché conforme** | MODELE_DONNEES L152 : cinq FK + CHECK somme = 1. |
| D-8 | **patché de travers** | Carte L40–86 : 32 + `reprise_boond` = vrai. PLAN L37 : 32 / 24. **§6.3 L398 :** « Les 16 métier » en liste **17** noms (`ref_statut_commercial` ajouté) **et** le reprend dans les techniques → doublon. Le footer registre L167 dit 17+7 = 24, le livrable dit encore 16+8. PLAN L40, colonne motif : « 27 tables ». |
| **D-9** | **patché de travers** | Colonne ôtée : MODELE_DONNEES L277–279. **Le motif est faux :** « Le projet ne porte pas d'économie (ADR-003) » — alors que §0 L25 assume un arbitrage de modélisation et accorde que ce n'était **pas** une conséquence d'ADR-003. Un projet à deux devises est maintenant **légal** (L279 : « pas interdit »). Cas Avaliance rare (EUR) ; cas réel possible (MAD + EUR). Ce n'est plus un oubli, c'est un choix non nommé dans le registre. |
| P-1 | **patché conforme** | MODELE_DONNEES L109, L129, L205, L227, L240. |
| P-2 | **patché conforme** | MODELE_DONNEES L214. |
| P-4 | **patché conforme** | MODELE_DONNEES L412 : plus de `sens`. |
| P-5 | **patché conforme** | MODELE_DONNEES L36, L243 : `motif_retrait_code` ôté ; motifs dans `evenement_metier.motif`. |
| P-6 → politique | **patché conforme** | REGISTRE L100 ; MODELE_DONNEES L331 ; CAHIER L290 Q60. Le simulateur (25 clés) ne la porte pas — déjà dit au §0. |
| P-7 | **patché conforme** | Rien à faire : ADR-005 `valeur TEXT`. |
| T-1 | **patché de travers** | FEUILLE_G L188 alignée (prestations, tous les postes). **L55 option C** dit encore « refusée s'il n'y a aucune prestation signée » et « *n personnes signées* ». Hors des quatre fichiers ; §0 le citait. |
| **T-2** | **patché de travers** | **M-14 conforme :** MODELE_DONNEES L307, REGISTRE L28, MODELE_METIER L93 — trigger dès `engage`, même forme que M-4. **M-15 de travers :** REGISTRE L29 et MODELE_DONNEES L473 listent M-15 comme **mur** (P3 = 15) **et** écrivent « ce n'est pas un mur, c'est une règle de code » pour l'addition EUR+MAD. Un exécutant lâche les vues groupées. Ce que la base garantit (NOT NULL + pas de colonne convertie) **est** un mur, patron M-5. L'addition ad hoc n'en est pas un. Les coller dans la même cellule défait P3. |
| T-3 | **patché conforme** | PLAN L39 : plus « 15 murs à l'essai ». Hors des quatre fichiers ; vérifié. |
| T-4, T-5 | **patché conforme** | Déjà corrigés avant ce diff (brief E-8, D-8 arithmétique). Rien dans les quatre fichiers. |
| O-1 | **patché conforme** | MODELE_DONNEES L201 : une séance, ré-évaluer = nouvelle ligne. |
| O-2 | **patché conforme** | MACHINES L13 ; MODELE_DONNEES L309. |
| O-3 | **patché conforme** | MODELE_DONNEES L281 : M-12 sur les trois contacts du projet. |

## Ce que le patch a cassé ailleurs

| # | Quoi | Ligne |
|---|---|---|
| X-1 | Machines §7 non alignées sur D-3 | MACHINES L110 |
| X-2 | Modèle métier, fichier du diff, contredit D-3 / D-5 / D-6 / D-1 | MODELE_METIER L14, L16, L54, L55, L59 |
| X-3 | Compte des `ref_*` à deux vitesses | MODELE_DONNEES L398 vs REGISTRE L167 |
| X-4 | Plan : 32 tables en L37, « 27 tables » en L40 ; étape 5d « 59 réglages » | PLAN L37, L40, L43 |
| X-5 | Feuille G : récapitulatif T-1 vs option C | FEUILLE_G L55 vs L188 |
| X-6 | `perimetre` : `type_code` ne contraint pas quelle FK est remplie | MODELE_DONNEES L410 |
| X-7 | Chemin `DeclareNeedFilled` toujours absent (`prestation` sans `besoin_id`, `projet.besoin_id` NULL) — T-1 non porté par le livrable 5 | MACHINES L24 ; MODELE_DONNEES §5.1–5.2 |

⛔ Porte Ahmed : après un second patch sur D-1 (lien `agence` ↔ unités internes, XOR périmètre), D-8 (§6.3), T-2 (M-15 = uniquement ce que la base garantit), et le modèle métier (X-2).
