# Remarques du banc sur le canon — on ne le corrige pas.

| Ligne / fichier | Écart constaté | On n'a pas inventé |
|---|---|---|
| `SPEC_COMMANDES_L4.md` III vs `MACHINES_ETAT_V1.md` §1 | L4 émet `NeedTakenInCharge` / `NeedFilled` / `NeedSuspended`. La machine émet `NeedStateChanged` pour les mêmes transitions. | Portes figées sur **L4** (contrat du lot). |
| `MATRICE_DROITS_v1.md` vs L4 | La matrice avait annoncé 44 ; L4 mesure 55 commandes / 48 lignes. Déjà noté le 20/09. | Inventaire test = 55 noms L4. |
| `MACHINES_ETAT_V1.md` L23 | `TakeNeedInCharge` est une option de `besoin.staffing.declencheur`, pas l'unique chemin vers `en_recherche`. | Geste : bouton « Prendre en charge » sur un besoin « à pourvoir ». |
