# À FAIRE — Ava Manager

**Mis à jour le 18/09/2026, après la décision d'Hamada : on avance, on ne bloque plus.**

> « Personne ne va relire le cahier métier. On va rester bloqués pendant des mois. Il faut qu'on avance. »

⭐ **La porte change de nature.** Elle exigeait la relecture de quelqu'un qui n'existe pas. Elle devient : **Hamada joue le banc d'essai 20 minutes**, et on code. Le cahier reste en ligne ; si quelqu'un le lit un jour, ses retours seront des **réglages**, pas une refonte.

⛔ **Motif de ce changement** : une porte que personne ne peut ouvrir n'est pas une porte, c'est un mur. Et l'assurance existe déjà — voir plus bas.

---

# ⬜ CE QUI RESTE

| # | Quoi | Qui | Combien |
|---|---|---|---|
| **1** | ⭐ **Jouer le banc d'essai 20 minutes** — prendre un rôle, faire les gestes, dire ce qui surprend | **Hamada** | 20 min |
| **2** | ✅ **[DÉCISIONS TECHNIQUES](DECISIONS_TECHNIQUES_v1.md)** — les 10 tranchées. ⚠️ Il me manque **3 faits** sur Avaliance (e-mail pro, nombre d'utilisateurs, France ou pas) | moi ✅ · Hamada répond | 2 min |
| **3** | **Écrans** — dessinés par **ChatGPT**. Le prompt est prêt : [PROMPT_CHATGPT_ECRANS.md](PROMPT_CHATGPT_ECRANS.md), autonome, à coller tel quel | Hamada → ChatGPT | — |
| **4** | **Reprise Boond** — correspondance des états | moi + 1 h dans Boond | 1 h |
| **5** | ✅ **Cahier régénéré le 18/09** — **82 réglages**, et `cahier.html` se reconstruit maintenant depuis le `.md` au lieu d'être tenu à la main | moi | fait |
| — | **PUIS : la session de code démarre** (lots 7 → 10) | session exécutante | — |

⭐ **Rien n'attend personne d'extérieur.** Le seul point qui demande Hamada prend 20 minutes.

---

# ⚠️ CE QU'ON PARIE EN CODANT SANS RELECTURE MÉTIER

**Ce qui coûterait cher à changer après — 12 décisions, pas 400 :**

| | Le pari | Sur quoi il repose |
|---|---|---|
| 1 | Un candidat ne porte jamais mission ni temps | DEC-02, S9, et Boond fait pareil |
| 2 | Une personne, deux profils (candidat / ressource) | DEC-01, ADR-002 |
| 3 | La ressource d'une mission ne change jamais | DEC-11, S7 |
| 4 | Le projet ne porte pas de ressource — la prestation, oui | DEC-07, ADR-003 |
| 5 | Une marge figée à la clôture ne se réécrit pas | DEC-09, S8 |
| 6 | Rien ne se supprime, tout s'archive | DEC-18, S12 |
| 7 | Un positionnement = un besoin × **un** humain | DEC-03 |
| 8 | Un événement ne se modifie ni ne s'efface | DEC-18 |
| 9 | Une base par société (pas de multi-société) | G5, ADR-000 — migration mécanique si ça change |
| 10 | Les 6 cycles d'état, dans leurs **catégories** | machines §1–§7 |
| 11 | Un besoin a toujours une société | DEC-04, G6 |
| 12 | Une permission vit toujours dans un périmètre | DEC-17, S13, S14 |

⭐ **Tout le reste — 82 réglages, 27 listes de valeurs, 396 cases de droits, 6 palettes — se change en un clic, sans développeur.** C'est exactement ce que le principe « tout est paramétrable » a acheté : **l'assurance contre l'absence de relecteur**.

⚠️ **Ce qu'un relecteur métier aurait pu trouver et que personne ne trouvera** : un objet qui manque complètement (une notion d'Avaliance absente des 21 objets). C'est le seul vrai risque résiduel, et **20 minutes de banc d'essai le révèlent** — c'est pour ça que le point 1 existe.

---

# ✅ CE QUI EST FAIT

| Quoi | Où |
|---|---|
| **Modèle de données** — 32 tables, 15 murs, 63 politiques, 25 référentiels, clos après **5 passes et 5 relectures** | `MODELE_DONNEES_AVAMANAGER_V1.md` |
| **Matrice des droits** — 44 commandes × 9 groupes = 396 cases | `MATRICE_DROITS_v1.md` |
| **Thèmes paramétrables** — 7 thèmes, 2 politiques | `THEMES_v1.md` |
| **Cahier pour les directeurs** — 15 histoires, les réglages, les 15 interdits | [en ligne](https://ahmedbentaleb.github.io/ava-boond-hub/cahier.html) |
| **Banc d'essai jouable** — 9 rôles, 28 réglages, 15 murs à l'essai | [en ligne](https://ahmedbentaleb.github.io/ava-boond-hub/simulateur.html) |
| **Brief exécutant** — ce que la session de code fait, et ne rouvre jamais | `BRIEF_EXECUTANT_2026-09-17.md` |
| **Canon** — DEC, F1–F36, G1–G15, P1–P3, ADR-000→005, 6 machines d'état | `_ops/` |
| **Sauvegarde vérifiée** + tout poussé sur GitHub | `sauvegardes/canon_2026-09-18/` |

---

# ⛔ CE QU'ON NE FAIT PLUS

| | |
|---|---|
| ⛔ | **Attendre une relecture qui n'arrivera pas** — supprimé le 18/09 |
| ⛔ | Rouvrir les décisions closes — DEC, F, G, P, ADR, les 15 murs |
| ⛔ | Ajouter une politique sans le dire : chaque ajout refait les comptes |

---

# LES TROIS LIENS

```
https://ahmedbentaleb.github.io/ava-boond-hub/simulateur.html
```

```
https://ahmedbentaleb.github.io/ava-boond-hub/cahier.html
```

```
https://ahmedbentaleb.github.io/ava-boond-hub/CAHIER_RELECTURE_METIER.pdf
```
