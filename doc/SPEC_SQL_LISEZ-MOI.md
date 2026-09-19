# L3 — le schéma en SQL commenté

**`SPEC_SQL_AVAMANAGER_V1.sql` — 1 599 lignes · 75 Ko · PostgreSQL 16+.**
Source : `MODELE_DONNEES_AVAMANAGER_V1.md`. Comptes : registre §E, jamais réécrits ici.

| Mesuré dans le fichier | Compte |
|---|---|
| Tables métier (+ `reprise_boond`) | **37** |
| Référentiels `ref_*` | **34** — 27 métier + 7 techniques |
| Fonctions · triggers · vues | 18 · 22 · 7 |
| Murs portés physiquement | **15 / 15** — table de vérification au §15 |

---

<quand_utiliser>

| ✅ On ouvre ce fichier | ⛔ On ne l'ouvre pas pour |
|---|---|
| Écrire une commande : quelle table, quelle colonne | savoir **ce que fait** une commande → **L4** |
| Savoir si une règle est un mur ou une politique | connaître la **valeur** d'une politique → registre §C |
| Vérifier qu'un mur est bien dans la base | voir un **écran** → le mock `terminal.html` |
| Poser la migration, **après la porte** | les formules ATL → code, versionné |

</quand_utiliser>

---

<procedure>

**1.** Lire l'en-tête : les trois natures (mur · politique · référentiel) et **ADR-000** — une base = une société, **aucun `tenant_id`**.

**2.** Aller au **§15** : la table des 15 murs et l'objet SQL qui porte chacun. Si une ligne ne correspond à rien dans le fichier, **le fichier est faux**.

**3.** Chercher sa table. Chaque colonne non évidente porte **le motif** en commentaire — pas la description, le motif.

**4.** Avant d'écrire un `if` métier : chercher la clé au registre §C. ⛔ Un `if` sans clé de politique est un **refus en revue**.

**5.** Pour exécuter : ⛔ **pas avant** `VALIDATION_MODELE_V1_<date>.md`, de la main d'Ahmed (G15, modèle §12).

</procedure>

---

<interdits>

| ⛔ Jamais | Le problème que ça évite |
|---|---|
| Ajouter une colonne `tenant_id` | ADR-000 : l'isolation est la **base**, pas un `WHERE` qu'on oublie une fois |
| Mettre un `if` métier dans le code | une société suivante le rouvre — ADR-005 |
| Un CHECK sur le **code** d'un `ref_*` | Boond a 14 états candidat : ils entrent comme codes dans une catégorie, **sans migration** |
| Un index unique sur `(besoin_id, personne_id)` | il figerait POL `positionnement.unicite` |
| Un CHECK « externe ⇒ fournisseur » | il figerait POL `ressource.externe.societe_fournisseur` |
| Additionner des montants hors des 4 vues | M-15 · règle R-1 — le rôle `ava_lecture_agregats` n'a pas les lignes |
| Une icône de corbeille dans un écran | **M-8** : `REVOKE DELETE` — l'UI ne propose pas un geste que la base refuse |
| Un montant sans sa devise à côté | M-15, `paire_montant()` |

</interdits>

---

<etat>

**19/09/2026 — écrit, non exécuté.**

| Livrable | État |
|---|---|
| L1 le besoin, depuis Boond | ⏸ **Hamada se connecte lui-même** — je regarde, j'écris |
| L2 le dossier de spécification | ⬜ bloqué : **qui code, sur quelle pile ?** |
| **L3 le schéma SQL** | ✅ **ce fichier** |
| L4 le contrat des 44 commandes | ⬜ |
| L5 le moteur de politiques | ⚠️ la **table**, le **lecteur** `pol()` et `mur_touche` sont ici ; l'**écran** reste |
| L6 les 24 écrans | ✅ `terminal.html` |
| L7 les 22 assertions | ✅ `SPEC_ASSERTIONS_L7.sql` — 22 + 1 contre-test. ⚠️ **écrites, jamais exécutées** : pas de PostgreSQL sur cette machine |

**Deux seeds à écrire**, tous deux mécaniques : les 167 lignes de `politique` (registre §C) et les codes système des 34 `ref_*` (registre §B).

</etat>

---

<source>

`MODELE_DONNEES_AVAMANAGER_V1.md` (637 lignes, 19/09) · `REGISTRE_POLITIQUES_v1.md` §A/§B/§C/§E ·
`MATRICE_DROITS_v1.md` · `MACHINES_ETAT_V1.md` · ADR-000, ADR-003, ADR-004, ADR-005, ADR-006.

**Un ajout qui n'est pas dans le modèle** : la colonne `politique.mur_touche`, née du constat 0-TER
du plan — *aucune politique ne déclare le mur qu'elle ne peut pas franchir*. Elle est **indicative**,
pour griser les valeurs impossibles dans l'écran d'administration ; c'est le mur qui refuse, pas elle.

</source>
