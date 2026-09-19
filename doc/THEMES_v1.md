# Thèmes Ava Manager v1 — le design est un réglage

Date : 18/09/2026 · Statut : **décidé** — principe d'Hamada du 18/09, étendu d'ADR-005. **Réécrit deux fois le 18/09** : un thème n'est plus un nom dans une liste, c'est **quatre rôles de couleur, trois fonds, et seize réglages**.

> **Hamada, 18/09 :** « Tout logiciel doit être paramétrable, ça doit être indiqué. **Même le design.** […] Le style de bouton doit être aussi paramétrable. […] Est-ce qu'on ne peut pas colorer par métier ? Moi, je veux que ça soit **entièrement** paramétrable. »

Le banc d'essai le prouve : [ava-manager.ahmedbentaleb.com](https://claude.ai/artifact/VfZzn889VFVpahf2GnUcY7) — un seul squelette, **663 552 combinaisons**.

<quand_utiliser>

| ✅ On l'ouvre | ⛔ On ne l'ouvre pas |
|---|---|
| Écrire la feuille de styles, ou en ajouter une valeur | Pour les couleurs de la marque Avaliance — c'est le skill `design-avaliance`, et c'est lui qui fait foi |
| Savoir ce qu'une personne voit, et pourquoi | Pour les libellés, colonnes, langue — ce sont des préférences (BM-49) |
| Ajouter une police ou une couleur au catalogue | Pour un thème aux couleurs d'un **client** — hors V1 |

</quand_utiliser>

---

# ⭐ CE QUI NE BOUGE JAMAIS

| | |
|---|---|
| La **grille** | barre latérale, barre du haut, cadre centré à 1 420 px, deux colonnes qui s'empilent sous 1 080 px |
| La **densité** | corps 12 px, interlignage 1,4, hauteurs de ligne de tableau |
| La **place des choses** | aucun réglage ne déplace un bouton, n'en cache un, ni ne change un mot |
| Les **droits** | un thème n'ouvre ni ne ferme aucune commande |

⛔ **Deux personnes aux réglages opposés voient le même produit, aux mêmes endroits, avec les mêmes refus.** C'est ce qui permet à l'une d'aider l'autre au téléphone.

---

# QUATRE ROLES, PAS QUATRE COULEURS

C'est la correction du 18/09 au soir. « Couleur 1 / couleur 2 » etait arbitraire : on choisissait le vert, **tout** devenait vert. Une palette ne donne pas des couleurs, elle **remplit des roles**.

| Role | Ce qu'il colore | Part de l'ecran |
|---|---|---|
| **ACTION** | boutons, entree active de la barre, focus | ~5 % — la seule teinte vive |
| **STRUCTURE** | titres de panneau, en-tetes de colonne, cles de politique, devises | ~15 % — presente mais sourde |
| **DONNEES** | les chiffres eux-memes | jamais colores — c'est ce qui les rend lisibles |
| **SENS** | bon · attention · critique | echelle **separee** : aucune palette ne la touche, un danger reste rouge partout |

## Les six palettes livrees

| Palette | ACTION | STRUCTURE |
|---|---|---|
| **AVALIANCE** *(defaut)* | vert Avaliance | violet Avaliance |
| **TERMINAL** | orange | bleu |
| **AMBRE** | ambre | cyan |
| **GLACE** | bleu | cyan |
| **ENCRE** | argent | argent — aucun accent |
| **PHOSPHORE** | vert vif | ambre |

Le **mode expert** ouvre les deux roles separement : 12 couleurs x 12 couleurs. Choisir une palette efface les retouches.

# LES TREIZE REGLAGES D'APPARENCE

| # | Cle | Options | Defaut |
|---|---|---|---|
| 1 | `ui.palette` | 6 palettes nommees | **avaliance** |
| 2 | `ui.mode` | `sombre` · `intermediaire` · `clair` | **sombre** |
| 3 | `ui.intensite` | `discret` **20 %** · `normal` **50 %** · `fort` **100 %** — la **vivacite**, rien d'autre | **normal** |
| 4 | `ui.epaisseur` | `fin` · `medium` · `large` — la **largeur des traits**, rien d'autre | **medium** |
| 5 | `ui.police` | 9 valeurs de `ref_police` | **jetbrains_mono** |
| 6 | `ui.densite` | `compact` · `normal` · `confort` | **normal** |
| 7 | `ui.couleur.action` | 12 de `ref_couleur` — expert, sinon la palette decide | *(palette)* |
| 8 | `ui.couleur.structure` | les memes 12 — expert | *(palette)* |
| 9 | `ui.angle` | `carre` · `leger` · `arrondi` | **carre** |
| 10 | `ui.pastille` | `contour` (2 px) · `plein` | **contour** |
| 11 | `ui.bouton` | `contour` · `plein` · `fantome` · `souligne` | **contour** |
| 12 | `ui.carte` | `bande` · `contour` · `plein` | **bande** |
| 13 | `ui.coloration` | `une_couleur` · `par_metier` | **une_couleur** |

## La colonne d'outils — trois reglages de plus

| Cle | Options | Defaut |
|---|---|---|
| `ui.rail.position` | `droite` · `gauche` · `masquee` | **droite** |
| `ui.rail.outils` | liste ordonnee de `ref_outil` | **les six** |
| `ui.rail.ouvert` | l'outil ouvert au chargement | **alertes** |

**Les six outils — `ref_outil`** : bloc-notes · alertes · assistant · a faire · indicateurs · calendrier.
C'est un **catalogue**, pas une liste ecrite en dur : un septieme outil, c'est une ligne de plus.

**Et deux clés de portée**, déjà au registre : `ui.theme.defaut` (le jeu de seize que porte l'installation) · `ui.theme.choix_utilisateur` (oui / non).

⭐ **Le choix individuel** vit dans `compte.theme_json` — les seize valeurs, ou NULL pour suivre l'installation.

## ⭐ LA BARRE DE COULEURS — 19/09

> **Hamada, 19/09 :** « La barre de couleurs, on va l'appeler comme ça, on sait de quoi on parle. Ces couleurs, je veux les reporter dans les cartes : société, candidat, ressources. **Avoir les mêmes couleurs pour qu'on sache de quoi on parle.** »

⭐ **Une couleur = un objet métier, partout.** Le filet de 3 px au bord d'une entrée de menu et le cadre de la tuile qui la compte portent **le même hex**.

| | |
|---|---|
| La **barre de couleurs** | le filet de 3 px au bord de chaque entrée — `ui.menu.pastille` |
| La **tuile** qui compte cet objet | le même hex — `ui.coloration` = `comme_le_menu` |
| Les **icônes** | monochromes ou colorées, c'est un autre réglage |

⛔ **Une couleur par entrée, pas par métier.** Treize entrées qui se partagent cinq couleurs ne disent rien : c'est ce qui rendait la colonne repliée illisible.

## ⭐ INTENSITE ET EPAISSEUR — deux reglages, deux choses

> **Hamada, 18/09 :** « L'intensite, c'est pas la largeur. L'intensite regle la **vivacite de la couleur** ; fin, medium, large, c'est **la largeur des traits**. »

| `ui.intensite` | L'aplat de STRUCTURE | L'encre dedans |
|---|---|---|
| `discret` | la couleur melangee au fond a **20 %** | recalculee sur le melange |
| `normal` | **50 %** | recalculee |
| `fort` | **100 %** — le hex de la charte, `#430A4B` tel quel | **blanc**, calcule |

⭐ **L'encre se calcule sur le MELANGE, pas sur la couleur pure.** C'est la seule facon d'ecrire en blanc a 100 % et en noir a 20 % sans qu'aucune ligne de code ne dise quelle encre va ou. Seuil : **luminance 0,179**, le point exact ou le noir et le blanc contrastent pareil.

⛔ **Un aplat n'est pas du texte.** `teinte()` eclaircit une couleur sur fond sombre pour que le TEXTE reste lisible ; `aplat()` rend le hex de la charte, sans le toucher.

⛔ **Un filet qu'on ne voit pas se corrige par sa TEINTE, jamais par sa largeur.** `--bord` suit le fond : `#2e2e3a` sur sombre, `#6b6b83` sur intermediaire, `#a79fb6` sur clair. L'epaisseur reste libre.

## ⛔ UN SEUL VERT A L'ECRAN — 18/09

> **Hamada, 18/09 :** « C'est le vert Avaliance, celui qui est à gauche. Tout doit suivre la même couleur. Là, tu as deux verts différents. »

Le bouton `OUVRIR` portait `#6E7A1E` (la variante sombre, pour rester lisible en encre sur blanc) pendant que l'entrée active du menu portait `#AEBF38`. Deux verts.

| | Ce que ça porte | Fond sombre | Fond intermédiaire | Fond clair |
|---|---|---|---|---|
| `--action` | **bordures, aplats, accents** | `#AEBF38` | `#AEBF38` | `#AEBF38` |
| `--action-encre` | **le texte seulement** | `#AEBF38` | `#AEBF38` | ⭐ **`--t1`, l'encre courante** |

⭐ **La charte le disait déjà** : « vert = fond uniquement, jamais d'encre verte ». Sur fond clair le vert ne fait que **remplir et border** ; l'étiquette prend l'encre du texte. Un seul vert, et aucun texte vert.

⚠️ Vaut pour les six palettes, pas seulement Avaliance : sur fond clair, aucune couleur d'ACTION ne sert d'encre.

## La barre de défilement

Argent à 40 %, rail transparent, 9 px. ⛔ Elle se voyait plus que le contenu.

## Les trois fonds — et la regle qui va avec

| Mode | Fond | Texte courant |
|---|---|---|
| **sombre** | `#000` vers `#101017` | argente `#CFCFDB` |
| **intermediaire** | `#22222A` vers `#31313D` | clair `#DCDCE6` |
| **clair** | `#FFF` vers `#E7E5EA` | encre `#453F4F` |

**Sur un fond fonce, on n'ecrit pas en gris moyen.** Un `#9d9da8` sur du noir se lit mal et fatigue ; le texte courant passe a **l'argent**, et les couleurs a leur version **vive**. C'est ce qui distingue un terminal lisible d'un ecran qu'on abandonne au bout d'une heure.

Le mode `clair` est le **seul** a prendre les versions foncees. `sombre` et `intermediaire` prennent les vives.

## Les 12 couleurs — `ref_couleur`

| Code | Vive (sombre, intermediaire) | Foncee (clair) | |
|---|---|---|---|
| `vert_avaliance` | `#AEBF38` | `#6E7A1E` | la marque |
| `violet_avaliance` | `#D9AEE8` | `#430A4B` | la marque |
| `vert_vif` | `#00E676` | `#00893E` | |
| `vert_normal` | `#22C55E` | `#15803D` | |
| `vert_clair` | `#CDD749` | `#7E8A22` | |
| `rouge` | `#F04438` | `#B42318` | |
| `orange` | `#FF8C00` | `#B85C00` | terminal financier |
| `ambre` | `#FFB000` | `#8A5D00` | terminal ancien |
| `bleu` | `#4EA8FF` | `#0B63C4` | |
| `cyan` | `#00D4AA` | `#00786A` | |
| `magenta` | `#E879F9` | `#A21CAF` | |
| `argent` | `#DCDCE6` | `#5A5364` | sans accent |

**Chaque couleur porte ses deux versions**, et c'est le mode qui choisit. Le vert `#AEBF38` donne 1,8 : 1 sur blanc — illisible — et **10,2 : 1 sur noir**. L'interdit de la charte (« jamais d'encre verte ») a ete mesure sur **fond clair** ; sur fond fonce, la relation s'inverse. Le violet de charte `#430A4B` est trop sombre pour un fond noir : sa version vive est `#D9AEE8`.

⛔ **L'encre d'un aplat ne se choisit pas, elle se calcule** : luminance > 0,36 → texte noir, sinon blanc. Aucun thème ne peut produire du texte illisible sur son propre fond.

## Les 9 polices — `ref_police`

`jetbrains_mono` (défaut) · `ibm_plex_mono` · `space_mono` · `roboto_mono` · `source_code_pro` · `fira_code` · `sora` · `inter`

⚠️ **Six sont à chasse fixe** — c'est ce qui fait le terminal : les chiffres s'alignent en colonne sans effort.

## ⭐ La coloration par métier

Quand `ui.coloration = par_metier`, chaque bloc prend la couleur de **son chemin**, ceux du cadrage :

| | Chemin | Sombre | Clair |
|---|---|---|---|
| **C1** | CRM — sociétés, contacts | `#4EA8FF` | `#0B63C4` |
| **C2** | Recrutement — candidats | `#C9A0DC` | `#430A4B` |
| **C3** | Staffing — ressources, besoins, positionnements | `#AEBF38` | `#6E7A1E` |
| **C4** | Production — projets, prestations, temps | `#FF8C00` | `#B85C00` |
| **C5** | Externe — fournisseurs, achats | `#00D4AA` | `#00786A` |

Ce n'est pas de la décoration : **c'est le graphe du métier, coloré**. Un écran dit à quel chemin il appartient avant qu'on l'ait lu.

---

<procedure>

**Quel thème une personne voit — dans cet ordre :**

**1.** Si POL `ui.theme.choix_utilisateur` = `non` → les seize valeurs de POL `ui.theme.defaut`. **On s'arrête là.**

**2.** Sinon, pour **chacun** des seize réglages : la valeur de `compte.theme_json` si elle existe et reste valide dans son référentiel.

**3.** Sinon, la valeur de l'installation.

**4.** Une valeur devenue invalide (désactivée en admin) retombe sur celle de l'installation, et écrit `ThemeFallback`.

**5.** L'encre de chaque aplat est **calculée** à l'affichage, jamais stockée.

</procedure>

---

<interdits>

| ⛔ Jamais | Le problème que ça évite |
|---|---|
| Une couleur en dur dans un écran | l'écran resté blanc quand tout passe en sombre |
| Un réglage qui déplace, cache ou renomme | deux personnes qui ne voient pas le même produit et ne peuvent plus s'entraider |
| Un réglage qui touche un droit | l'apparence devenue du métier |
| Choisir l'encre d'un aplat à la main | un thème illisible que personne ne teste |
| Du **texte vert sur fond clair** | `design-avaliance` : 1,8 : 1. En mode clair, `vert_avaliance` vaut `#6E7A1E` |
| Du **gris moyen sur fond fonce** | illisible et fatigant. Sur sombre, le texte courant est **argente** et les couleurs **vives** |
| Colorer un **chiffre** | les donnees restent neutres. La couleur dit l'etat ou l'action, jamais la valeur |
| Une palette qui touche **le sens** | un danger doit rester rouge sous les six palettes |
| Supprimer une valeur système | les comptes qui la portent pointeraient dans le vide ; on **désactive** |
| Un thème client sur mesure en V1 | c'est un éditeur de thèmes — le piège que F16 a écarté pour les process |

</interdits>

---

<etat>

**Au 18/09/2026, soir**

| | |
|---|---|
| Reglages | **12** d'apparence + **3** de colonne d'outils + 2 de portee |
| Fonds | **3** — sombre, intermediaire, clair |
| Palettes livrees | **6**, plus le mode expert |
| Outils | **6** au catalogue |
| Referentiels ajoutes | `ref_couleur` (12) · `ref_police` (9) · `ref_outil` (6) — **valeurs systeme** |
| Colonne | `compte.theme_json` remplace `compte.theme_code` |
| Commande | `SetOwnTheme` — la seule que les 9 groupes portent |
| Implemente | le tableau de bord du banc d'essai, **les seize reglages en direct**, colonne d'outils comprise |
| ⬜ Reste | appliquer le squelette aux 23 autres écrans |
| ⬜ Hors V1 | `ui.theme.personnalise` — un thème aux couleurs d'un client |

</etat>

<source>

Principe d'Hamada, 18/09/2026, en cinq passes : « meme le design doit etre parametrable » puis « le style de bouton aussi » puis « est-ce qu'on ne peut pas colorer par metier ? » puis « il faut travailler avec trois ou quatre couleurs, reflechis comment rendre ce projet plus joli » puis « une barre laterale a droite avec un bloc-notes, les alertes, l'assistant, une to-do, un calendrier — **on ne code rien tant que tout n'est pas parametrable** ».

**Sa phrase de methode, le 18/09** : « On ne va pas arriver a un super design maintenant, mais si on fait tout parametrable, on ameliore le parametrage et **on fait de beaux templates** ». Les seize reglages ne sont pas le but : ils sont **le materiau** des templates a venir.

Le dernier correctif vient de lui aussi : « sur le mode sombre, ecrire en gris, on ne voit rien — il faut ecrire en argente, des couleurs vives ». Les valeurs de texte ont ete relevees en consequence, et le mode **intermediaire** ajoute.

Le squelette terminal vient de `Spread Monitor IA` (`static/style.css`) : noir `#000`, surfaces `#0a0a0f` / `#0f1014`, rayon 2 px, chasse fixe partout, bordures à 12 % de l'accent. Hamada : « je veux ce genre de truc, sauf qu'on remplace l'orange par le violet et le vert Avaliance ».

Les cinq couleurs de métier sont les chemins **C1 à C5** du `CADRAGE_METIER_RECONCILIE`, pas une invention.

Les contrastes cités sont mesurés, pas estimés : `#AEBF38` sur `#000` = 10,2 : 1 ; sur `#fff` = 1,8 : 1.

</source>
