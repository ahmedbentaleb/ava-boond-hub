# Décisions techniques Ava Manager v1

Date : 18/09/2026 · Statut : **tranchées par Brain**, Hamada confirme d'un mot.

⭐ **Ava Manager n'est le logiciel de personne en particulier.** Avaliance est la **première installation** ; d'autres sociétés l'installeront avec leurs propres réglages. Rien dans le produit ne porte le nom d'Avaliance — sauf le thème `avaliance`, qui est **un thème parmi sept**.

> **Hamada, 18/09 :** « Je comprends rien aux décisions techniques. Tu me dis, je te réponds. »

⭐ **Donc je tranche tout.** Chaque ligne dit ce que ça veut dire en français, ce que ça coûte, et ce qui arrive si on choisit l'autre. Trois questions seulement demandent une réponse — et ce sont des **faits sur Avaliance**, pas des choix techniques.

<quand_utiliser>

| ✅ On l'ouvre | ⛔ On ne l'ouvre pas |
|---|---|
| Avant de mettre le produit en ligne | Pour le métier — c'est le cahier |
| Pour savoir combien ça coûte par mois | Pour les tables — c'est le livrable 5 |
| Quand un fournisseur doit être remplacé | Pour les droits — c'est la matrice |

</quand_utiliser>

---

# Les dix décisions

| # | La question | **Ce que je décide** | Ce que ça veut dire | Si on prend l'autre |
|---|---|---|---|---|
| **T1** | Avec quoi c'est écrit | **TypeScript + PostgreSQL**, un seul dépôt, pages rendues par le serveur | Un seul langage du haut en bas. Les murs sont déjà dans la base : le code au-dessus reste mince | Deux langages, deux dépôts, deux fois plus de choses à casser pour une équipe d'une personne |
| **T2** | Comment on se connecte | ⭐ **Un réglage** — POL `auth.fournisseur` : `microsoft` (défaut Avaliance) · `google` · `email_mot_de_passe`. **Le produit est vendu à d'autres sociétés : leur fournisseur d'identité n'est pas celui d'Avaliance** (18/09) ⛔ **Une session (D-10, 22/09)** : un jeton **opaque, aléatoire (≥ 32 octets)**, émis après l'authentification, stocké **haché** avec une expiration — **jamais l'identifiant du compte**. Tant que le lot 2c n'est pas livré, le serveur **refuse tout appel hors `AVA_MODE=banc`**. | Personne ne crée de mot de passe. On clique « se connecter », on est déjà identifié. Un départ = on coupe le compte e-mail, l'accès tombe le même jour | Mots de passe à gérer : oublis, réinitialisations, et le jour où l'un fuit, c'est vous qui répondez |
| **T3** | Où ça tourne | ⭐ **Tranché par Hamada le 18/09 — le VPS Alborsa, pour l'instant.** Puis **un VPS dédié** à Ava Manager quand le produit sort de l'essai. ⛔ **Sur tout serveur hors poste de dev (V-022, 22/09)** : `pg_hba` en `scram-sha-256`, aucune règle `trust`, `listen_addresses` limité, `ava_serveur` avec un mot de passe **hors dépôt** — vérifié par la grille (K5) | Zéro euro de plus et zéro compte à ouvrir : la machine tourne déjà. L'essai n'a pas besoin d'une plateforme gérée | ⚠️ Sur un VPS, **l'administrateur système, c'est nous** : mises à jour de sécurité, surveillance, sauvegardes. La plateforme gérée (Scalingo, Clever Cloud) reste l'option du jour où ça devient pénible |
| **T4** | Les sauvegardes | ⬜ **Reporté le 18/09**, se tranche avec le VPS dédié. ⛔ En attendant : **aucune donnée réelle sur l'installation d'essai**. La cible reste : chaque nuit, gardées 30 jours, **plus une copie hebdomadaire ailleurs qu'Alborsa** | Deux copies chez deux hébergeurs différents. Une panne de l'un ne perd rien | Les sauvegardes du seul hébergeur : le jour où c'est **lui** qui tombe, il n'y a rien ailleurs |
| **T5** | ⭐ Le test de restauration | **Une fois par mois**, on restaure vraiment la sauvegarde sur la copie de test | **Une sauvegarde jamais restaurée n'est pas une sauvegarde.** On le découvre le jour où on en a besoin, ou on le découvre chaque mois | On croit être sauvegardé pendant deux ans, et on ne l'est pas |
| **T6** | Les navigateurs | **Chrome, Edge, Firefox, Safari** — les deux dernières versions | Ce que tout le monde a déjà. Rien à installer | Supporter les vieux navigateurs coûte du temps à chaque écran, pour personne |
| **T7** | Le téléphone | **La saisie des temps, oui. Le reste, non** | Une ressource déclare ses jours depuis son téléphone. Les écrans de gestion restent sur ordinateur | Tout rendre utilisable au doigt double le travail des écrans, pour un usage que personne ne demande |
| **T8** | Les environnements | **Deux : la production et une copie de test** | On essaie sur la copie, on livre sur la vraie. La copie sert aussi au test de restauration (T5) | Un seul : on essaie directement sur les vraies données, et un jour ça se voit |
| **T9** | L'adresse | **`ava-manager.ahmedbentaleb.com`** — l'installation d'essai (18/09). Chaque société installée ensuite a **son** adresse | Le produit n'appartient à aucune société : Avaliance est la première installation, pas le propriétaire | Une adresse Avaliance : le produit devient « leur » logiciel, et il ne se donne plus |
| **T10** | Quand ça casse | **Rapport d'erreur automatique** + surveillance qui prévient si le site tombe | On sait qu'il y a un problème avant que quelqu'un appelle | On l'apprend par un utilisateur énervé, sans savoir ce qui s'est passé |

---

# Ce que ça coûte par mois

| Poste | Fourchette |
|---|---|
| Hébergement + base de données | **0 €** tant qu'on est sur le VPS Alborsa · 10 – 25 € pour un VPS dédié ensuite |
| Copie de sauvegarde chez un second fournisseur | 2 – 5 € |
| Nom de domaine | ~1 € |
| Rapport d'erreurs et surveillance | **0 €** — les offres gratuites suffisent à cette taille |
| **Total** | **≈ 5 – 35 € par mois** — le VPS Alborsa est déjà payé |

⚠️ À comparer avec **Boond, payé pendant toute la V1** — c'est ce chiffre-là qui dit si le remplacement vaut le coup, et il n'est toujours pas écrit (étape 11 du plan du 17).

---

<interdits>

| ⛔ Jamais | Le problème que ça évite |
|---|---|
| **Les données hors d'Europe** | des CV, des salaires, des dates de naissance : des données personnelles. L'Europe est le seul endroit qui ne demande aucune justification |
| Un serveur que quelqu'un doit administrer à la main | l'astreinte que personne ne prendra, et la mise à jour de sécurité jamais faite |
| Une seule copie de sauvegarde | **deux copies sur le même disque font une copie** |
| Une sauvegarde jamais restaurée | on découvre qu'elle est vide le jour où on en a besoin |
| Essayer sur les vraies données | il n'y a pas de « annuler » sur une base de production |
| Mettre des mots de passe dans le code ou dans le dépôt | un dépôt public, et c'est fini |
| Coder l'identifiant du fournisseur dans l'application | on ne peut plus en changer sans tout rouvrir |

</interdits>

---

# ⚠️ CE QUE PERSONNE N'A ENCORE REGARDÉ — et qui touche un mur

**Le droit à l'effacement.** Un candidat peut exiger que ses données soient supprimées. Le règlement européen lui en donne le droit, et ça s'applique dès qu'un candidat ou un client est en France.

⛔ **Le mur M-8 dit « rien ne se supprime, tout s'archive ».** Archiver n'est **pas** effacer : les données sont toujours là.

| La sortie | Ce que ça donne |
|---|---|
| **Ma recommandation** | Une commande **`AnonymisePersonne`** : le nom, l'e-mail, le téléphone, l'adresse et les documents sont **écrasés** ; l'identifiant, les missions et les temps restent. L'histoire de l'entreprise est conservée, la personne disparaît |
| Ce que ça préserve | M-8 tient — rien n'est supprimé, une ligne reste. M-6 et M-7 tiennent — les marges et le journal ne bougent pas |
| Ce qu'il faut ajouter | 1 commande, 1 événement `PersonneAnonymisee`, 1 politique `rgpd.duree_conservation_candidat` (défaut : **2 ans** après le dernier contact) |

⛔ **Décidé le 18/09 : `AnonymisePersonne` entre en V1.** Candidats en France, au Maroc, à Dubaï et ailleurs — la règle la plus stricte s'applique partout, et le produit sera vendu à des sociétés qui auront le même problème. Ce n'était pas bloquant pour coder ; ça l'est pour vendre. Un candidat qui écrit « effacez-moi » et à qui on répond « on ne peut pas » est un problème qui ne se répare pas après coup.

---

<etat>

**Au 18/09/2026**

| | |
|---|---|
| Décisions prises | **10**, toutes par Brain |
| En attente d'un fait | **0** — les trois sont répondus le 18/09 |
| Ajouté au canon le 18/09 | `AnonymisePersonne`, événement `PersonneAnonymisee`, 2 politiques (`auth.fournisseur`, `rgpd.duree_conservation_candidat`) → **65 politiques** |
| Coût estimé | 30 – 60 € / mois |

**Les trois faits — répondus par Hamada le 18/09 :**

| # | Réponse | Ce que j'en fais |
|---|---|---|
| **F1** | Microsoft (Outlook, Teams) | défaut de `auth.fournisseur` = `microsoft` ; les deux autres options existent pour les sociétés suivantes |
| **F2** | **beaucoup** — le produit est vendu à d'autres sociétés | une installation par société (ADR-000 tient) ; l'hébergement se dimensionne par installation |
| **F3** | candidats en **France, Maroc, Dubaï** et ailleurs | `AnonymisePersonne` **en V1**, et `rgpd.duree_conservation_candidat` réglable par pays |

**Questions d'origine :**

| # | Question | Pourquoi j'en ai besoin |
|---|---|---|
| **F1** | Quelle adresse e-mail professionnelle utilise Avaliance ? `@avaliance.com` sur **Microsoft**, sur **Google**, ou autre chose ? | Décide T2. Si c'est Microsoft ou Google : zéro mot de passe. Sinon je bascule sur e-mail + mot de passe |
| **F2** | Combien de personnes utiliseront Ava Manager ? Une dizaine, une trentaine, plus ? | Décide la taille de l'hébergement, donc le prix |
| **F3** | Y a-t-il des candidats, des salariés ou des clients **en France** ? | Décide si le droit à l'effacement s'applique, donc si on ajoute `AnonymisePersonne` maintenant ou plus tard |

</etat>

<source>

Tranchées par Brain le 18/09/2026, sur la parole d'Hamada : « je comprends rien aux décisions techniques, tu me dis, je te réponds ».

Contraintes qui ont guidé : une équipe d'une personne (donc le moins de pièces possible), des données personnelles (donc l'Europe), la règle d'Hamada sur les sauvegardes — « deux copies sur le même disque font une copie », « vérifier avant de supprimer, jamais après » — et le fait qu'aucune astreinte technique n'existe chez Avaliance.

Le point sur le droit à l'effacement n'est demandé par aucun document du canon : il vient de la lecture du mur M-8 contre le règlement européen.

</source>
