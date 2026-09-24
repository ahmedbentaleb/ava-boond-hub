# Les réponses d'Avaliance — réunion du 24/09/2026

Les 10 questions posées à la direction, ses réponses, et **ce que chacune change dans le canon**.
⭐ Elles ferment l'étape 1.4 : plus rien n'attend Avaliance pour avancer.

<quand_utiliser>

| ✅ On ouvre ce fichier | ⛔ On ne l'ouvre pas pour |
|---|---|
| Savoir ce que la direction a tranché, et où c'est écrit dans le canon | les questions → `QUESTIONS_BOOND_2026-09-19.md` |
| Préparer la reprise et le lot RH/facturation | le détail des réglages Boond → `cartographie/BOOND_REGLAGES_2026-09-23.md` |

</quand_utiliser>

<etat>

| # | Réponse de la direction | Ce que ça change |
|---|---|---|
| **R1** | ⭐ « **Valider n'est pas gagner.** Valider, c'est que le dossier technique a été posé ; on attend la validation financière. Parfois on gagne directement. **Valider ne crée pas de projet.** » | ⛔ Mon hypothèse était fausse : `valide` n'est **pas** terminal. Machines d'état : `valide` = étape **active** du positionnement, `gagne` = seul état qui autorise le projet et la mission. Reprise : les **80 Validé** de Boond restent ouverts, seuls les **198 Gagné** deviennent des missions |
| **R2** | « Ce n'est pas un bug, c'est un **retard de saisie** chez Avaliance. » | Les 9 missions de Boond ne sont pas la réalité : la reprise **ressaisit** les missions en cours, avec leurs tarifs. Étape 6.2 confirmée |
| **R3** | « L'export pourra se faire : celui qui a les droits fait un **export total** de Boond. » | ✅ L'étape 6.1 n'est plus bloquée. Le format d'import CSV de Boond (capture 85) sert de repère |
| **R4** | « **Tout le monde a une adresse Microsoft.** » | ✅ T2 confirmé : `auth.fournisseur = microsoft`, sans repli. Le lot 2c peut se coder tel quel |
| **R5** | ⭐ « Deux manières de calculer le coût : **l'externe** coûte ce qu'on l'achète (500, facturé 700) ; **le salarié** coûte le brut + primes + frais, divisé par les jours travaillés (≈ 200 j). » | Deux politiques nouvelles : `cout.mode` = `achat_externe` · `salarie_formule` (selon le type de ressource) et `cout.jours_base` (défaut **200**). ⭐ Ça répond à la question des deux CJM de Boond : le **coût de la mission** est calculé, le **coût du contrat** est celui du salarié ou de l'achat |
| **R6** | « PORTALIANCE est une **agence** d'Avaliance — une société peut avoir plusieurs agences. » | ✅ Confirme ADR-000 et la base unique. Les 5 agences de Boond sont nos agences |
| **R7** | ⭐ « Un candidat blacklisté peut revenir : c'est un **drapeau**, pas un bannissement. Un client ou un directeur peut le ramener. » | ✅ Ma recommandation tenait : `personne.drapeau_blackliste` (+ motif, date, auteur), **réversible**, jamais un état de fin. Les deux blacklists de Boond (Avaliance, Portaliance) deviennent un drapeau **par agence** |
| **R8** | « **On importe tout** ce qui est dans Boond. » | ⛔ Renverse ma recommandation du 19/09 (« ne pas reprendre les données RH sensibles »). On reprend n° de sécurité sociale, situation familiale, nationalité, lieu de naissance — ⚠️ avec la conséquence : accès restreint par permission dédiée, et durée de conservation réglable (`rgpd.duree_conservation_candidat`) |
| **R9** | « On importe **le contrat de travail dès le départ**. » | ✅ `contrat_rh` en V1, avec type, catégorie, classification Syntec, temps de travail, dates, renouvellements (étape 5.8) |
| **R10** | ⭐ « Appel d'offres gagné : parfois un interlocuteur, parfois non. On prend un interlocuteur fictif, ou **c'est le service, ou la société entière** qui fait interlocuteur. » | Le projet peut pointer **une unité (service) ou la société** au lieu d'une personne : `projet.contact` gagne la valeur `service_ou_societe`, et `ref_origine_besoin` (régie · appel d'offres · …) est créé. ⛔ Plus besoin d'inventer un contact fictif |

## Ce que j'ajoute au canon, maintenant

| Où | Ajout |
|---|---|
| `REGISTRE §B` | `ref_origine_besoin` (régie, appel d'offres, gré à gré, renouvellement) |
| `REGISTRE §C` | `cout.mode` · `cout.jours_base` (200) · `projet.contact` gagne `service_ou_societe` · `candidat.blackliste.portee` (agence · installation) |
| `MACHINES §3` | `valide` redevient une **étape active** du positionnement ; seul `gagne` ouvre le projet |
| `MODELE_DONNEES` | `personne.drapeau_blackliste` (+ motif, date, auteur, portée) · `besoin.origine_code` · `projet.interlocuteur` (contact **ou** unité **ou** société) |
| `COMPLEMENTS_V1` | les données RH sensibles entrent dans la reprise, sous permission dédiée |

</etat>

<source>

Réunion du 24/09/2026 entre Hamada et la direction d'Avaliance. Réponses recopiées **mot pour mot**
depuis la page « Questions Avaliance » du hub. Les questions venaient du relevé Boond des 19 → 23/09.

</source>
