Tu dessines les écrans d'un logiciel appelé **Ava Manager**. Rends des **images** d'interface, une par écran.

# Ce qu'est le produit

Un logiciel de gestion pour une société de services informatiques (ESN) : elle place des gens en mission chez des clients. Il remplace un outil du marché appelé Boond. Il sera installé chez plusieurs sociétés, chacune avec ses propres réglages.

**Le parcours, du premier appel à la facture :**
un client exprime un **besoin** → on propose une personne, c'est un **positionnement** → le client dit oui → on crée le **projet** → on crée la **prestation** (qui travaille, quand, à quel tarif) → la personne saisit son **temps** → on clôture, la marge est figée.

**Sept mots, à ne jamais confondre :**
- **Société** = l'entreprise cliente · **Contact** = quelqu'un chez elle
- **Besoin** = ce que le client demande, il peut viser plusieurs postes
- **Positionnement** = on propose UNE personne sur UN besoin
- **Projet** = le dossier d'exécution · **Prestation** = la mission d'UNE personne sur ce projet
- **Candidat** et **Ressource** = deux profils d'une même personne. Un candidat peut être présenté au client ; il ne peut **pas** travailler ni saisir de temps tant que les RH ne l'ont pas passé en ressource.

# La charte graphique

| | |
|---|---|
| Violet | `#430A4B` — **tout le texte, tous les titres, la structure** |
| Vert | `#AEBF38` — ⛔ **fond uniquement**, jamais d'encre verte, jamais de texte vert |
| Texte courant | `#212529` · Gris `#5D5D5D`, `#E9E9E9`, `#F3F3F3` · Fond blanc |
| Police | **Sora** partout · **IBM Plex Mono** pour les chiffres, les identifiants, les montants |
| États (jamais la couleur de marque) | critique `#A93226` · élevé `#C75B12` · moyen `#D9A21B` · bon `#1E5B3A` |

⛔ **Interdits absolus** : du texte vert · du blanc sur aplat vert · des coins très arrondis ou des « pilules » · des dégradés · des ombres portées · des émojis · des icônes décoratives · un camembert.

⭐ Un titre violet sur un aplat vert est parfaitement lisible : c'est la seule façon de faire vivre le vert.

**Format** : 1440 × 900 pixels, bureau. Une image par écran. Barre du haut, navigation à gauche, contenu au centre.

# Les règles du produit, visibles dans les écrans

1. **Un écran n'affiche que ce qui existe en base.** N'invente aucun champ, aucune colonne, aucun onglet qui ne soit pas dans la liste ci-dessous.
2. **Un bouton visible n'est pas une autorisation.** Montre des boutons que l'utilisateur ne peut pas actionner : le refus vient de la commande, avec son motif.
3. **Un candidat n'a ni onglet Prestations ni onglet Temps.** Jamais.
4. **Le projet n'a pas de champ « ressource ».** Les personnes d'un projet se lisent dans ses prestations.
5. **Aucun montant sans sa devise à côté.** On n'additionne jamais deux devises : une ligne par devise.
6. **Les montants sont fictifs** : écris `[TARIF]`, `[COÛT]`, `[CA]` plutôt que des euros inventés.
7. **Aucun nom de vraie personne.** Utilise : sociétés ALPHA, BETA, GAMMA · personnes « Développeur Java senior », « Architecte cloud », « Analyste métier ».

---

# LES 24 ÉCRANS

## Listes — 7

Chaque liste : une barre de recherche, des filtres en haut, des colonnes triables, un bouton « Créer », et la pagination en bas.

| # | Écran | Colonnes |
|---|---|---|
| 1 | **Sociétés** | Nom · **Statut commercial** (prospect / client) · **Rôles** (fournisseur, interne — cumulables) · Secteur · Ville · Nb besoins · Nb projets |
| 2 | **Contacts** | Nom · Fonction · Société · Unité · Statut · E-mail · Téléphone |
| 3 | **Candidats** | Nom · Titre · État (brouillon / complété) · Disponibilité · Provenance · A déjà un profil ressource ? |
| 4 | **Ressources** | Nom · Titre · Type (interne / externe) · Société fournisseur si externe · État (en mission / disponible / sortie) · Agence · **Charge engagée aujourd'hui en %** |
| 5 | **Besoins** | Titre · Société · Agence · État (à pourvoir / en recherche / pourvu / suspendu / fermé) · **Priorité P1-P2-P3, colonne séparée de l'état** · **n prestations signées / m postes visés** · Date de démarrage |
| 6 | **Projets** | Référence · Titre · Société · Contact · Type (régie / forfait) · État (ouvert / clos) · Nb prestations · Agence |
| 7 | **Prestations** | Ressource · Projet · État (prévisionnelle / signée / clôturée / annulée) · Période · Taux d'occupation % · TJM + devise · Jours saisis |

## Fiches — 7

Chaque fiche : un en-tête avec le nom et l'état, des onglets, et un panneau « Historique » à droite qui liste les événements datés.

| # | Écran | Onglets et contenu |
|---|---|---|
| 8 | **Fiche société** | *Synthèse* (identité, statut, rôles) · *Organisation* — **un arbre** pôle → BU → service, avec le statut de chaque niveau (une branche cliente, une branche sœur restée prospect) · *Contacts* · *Besoins* · *Projets* · *Actions* · *Historique* |
| 9 | **Fiche contact** | *Synthèse* · *Besoins* · *Projets* · *Actions* · *Historique* |
| 10 | **Fiche candidat** | *Synthèse* · *Informations* (civilité, naissance, localisation, prétentions + devise, mobilité) · *Documents* (CV, pièces) · *Positionnements* · *Qualifications* · *Actions* · *Historique*. ⛔ **Ni Prestations ni Temps.** Un bouton « Convertir en ressource » |
| 11 | **Fiche ressource** | *Synthèse* · *Informations* · *Coût de référence* — **onglet grisé, cadenassé** : « permission spécifique requise » · *Prestations* · *Temps* · *Absences* · *Documents* · *Historique* |
| 12 | **Fiche besoin** | *Synthèse* (société, contact, agence, postes visés, priorité, démarrage, budget + devise) · *Compétences demandées* · *Positionnements* — un tableau : personne, candidat ou ressource, état, CV présenté, et les boutons « CV présenté », « Client : retenu », « Client : refusé », « Retirer » avec un choix de motif · *Projets issus de ce besoin* · *Historique*. En bas : « Créer le projet », « Déclarer pourvu », « Suspendre », « Fermer » |
| 13 | **Fiche projet** | *Synthèse* (société, contact, contact technique, contact facturation, type, lieu, dates) · *Prestations* — le tableau, avec « Signer », « Clôturer », « Annuler » selon l'état, et **« marge — » avec son motif** sur une mission close · *Lignes de CA additionnel* · *Documents* · *Historique*. ⛔ **Aucun champ « ressource » sur cette fiche** |
| 14 | **Fiche prestation** | *Synthèse* (ressource — **verrouillée, avec un cadenas**, projet, dates, taux %) · *Conditions économiques* (TJM vendu + devise, CJM contrat + **sa propre devise**, jours vendus, frais) — **grisées et cadenassées dès que la mission est signée** · *Temps saisis* · *Snapshot de marge* si clôturée · *Historique* |

## Transverse — 5

| # | Écran | Contenu |
|---|---|---|
| 15 | **Tableau de bord** | Des tuiles de chiffres (sociétés, candidats, ressources, besoins, positionnements, projets, prestations, jours saisis) · **un tableau « CA signé et marge — une ligne par devise, jamais un total »** · une liste « Ce qui attend » |
| 16 | **Plan de charge** | Un mois en colonnes, une personne par ligne, **une barre par jour** : vert plein = signé, vert clair empilé au-dessus = prévisionnel, orange = au-dessus du seuil, gris = absence, gris pâle = jour non ouvré. Une moyenne à droite. Une légende |
| 17 | **Mes temps** | Mes missions, un champ date et un champ quantité par ligne, un bouton « Saisir ». En dessous, mes lignes saisies avec « ajustement après clôture » signalé. ⭐ **Fais aussi une version téléphone 375 × 812 de cet écran uniquement** |
| 18 | **Mes absences** | Mes absences, type, période, et un formulaire d'ajout |
| 19 | **Actions** | Le journal : type (note, appel, entretien, relance), date, contenu, **le dossier auquel elle est rattachée — un seul, jamais deux**, le responsable |

## Administration — 5

| # | Écran | Contenu |
|---|---|---|
| 20 | **Politiques** | ⭐ **L'écran le plus important.** Un tableau par famille (Besoin, Positionnement, Projet, Prestation, Temps, Société, Doublons, Recrutement, Droits, Apparence, Installation). Par ligne : la clé en chasse fixe, un menu déroulant de valeurs avec « (défaut) », une phrase « ce que ça change », et la source. Une ligne en rouge pâle pour un réglage dangereux, des lignes grisées « hors lot » |
| 21 | **Référentiels** | Les listes de valeurs (états, types, motifs, thèmes). Par valeur : code, libellé modifiable, **catégorie non modifiable**, ordre, et un cadenas « valeur système » sur celles qu'on ne peut pas supprimer |
| 22 | **Groupes et droits** | La matrice : les commandes en lignes, les groupes en colonnes, et dans chaque case **✓ attribué · D délégation · S soi-même · — refusé**. Un panneau de droite pour le périmètre d'une case |
| 23 | **Comptes** | Nom, e-mail, personne liée, groupes, agence, **thème choisi**, actif ou non |
| 24 | **Agences et calendrier** | Les agences, et pour chacune un calendrier annuel des jours non ouvrés (week-ends, fériés, fermetures) |

---

# Les sept thèmes

Le logiciel change d'apparence complètement selon un réglage. **Dessine tous les écrans dans le thème « Avaliance »** (la charte ci-dessus), **puis rends le seul écran « Tableau de bord » dans chacun des six autres** :

| Thème | À quoi il ressemble |
|---|---|
| **Nuit** | lignes argentées sur graphite, fond `#141414` |
| **Clair** | traits sombres sur blanc, très neutre |
| **Terminal** | ⭐ genre Bloomberg : chasse fixe partout, densité maximale, aucune décoration, trois fois plus de lignes à l'écran |
| **Flashy** | couleurs saturées, contrastes francs, gros indicateurs — pour un écran mural |
| **Sobre** | gris, une seule couleur d'accent, aucun aplat |
| **Accessible** | contraste renforcé, texte à 15 px, cibles de 44 px, contour de focus épais |

⛔ **Un thème ne déplace jamais un élément et ne change jamais un mot.** Ce sont les mêmes écrans, aux mêmes endroits.

---

# Ce que je veux recevoir

1. Les **24 écrans** en thème Avaliance, 1440 × 900.
2. L'écran **Mes temps** en version téléphone, 375 × 812.
3. Le **Tableau de bord** dans les **6 autres thèmes**.

Commence par les cinq qui portent le métier — **Besoins, Fiche besoin, Fiche projet, Plan de charge, Politiques** — et montre-les-moi avant de faire les autres.
