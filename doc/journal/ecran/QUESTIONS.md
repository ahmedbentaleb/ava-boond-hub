# Questions écran — lot 2. Choix pris en attendant.

| # | Question | Choix en attendant | Pourquoi |
|---|---|---|---|
| Q-E1 | L4 ne contracte aucune commande de **lecture**. Liste et fiche besoin n'ont pas d'entrée/sortie. | Bouchons `ListerBesoins` et `LireBesoin` : vue déjà calculée (libellés, pastilles, actions filtrées, couverture `1 / 2 postes`). | L'écran ne peut pas filtrer ni traduire un code. Sans vue, il inventerait du métier. |
| Q-E2 | `/server/contrat/*.json` est vide. Quel chemin HTTP live le serveur publiera-t-il ? | GET `/bouchon/<Commande>.json` tant que le contrat n'est pas là. | Le prompt autorise le bouchon et l'écran n'écrit pas dans `/server`. |
| Q-E3 | Le thème clair : fichier unique ou query `?mode=` comme `/sante` ? | Un JSON, deux thèmes dedans (`themes.sombre` / `themes.clair`), l'URL choisit. | Un fichier statique ne lit pas la query ; le serveur, lui, enverra `theme` déjà choisi. |
| Q-E4 | `_ops/share-hub/terminal.html` est absent du dépôt. | Cible visuelle : `_ops/ava-terminal.html` (liste besoins + `fBesoin`). | C'est le mock des 26 écrans que le dossier pointe. |
| Q-E5 | Créer un besoin depuis le `+` : formulaire hors L4. | Le bouton est rendu (action permise) ; le clic n'ouvre pas de formulaire dans ce tour. | Un écran fini = liste + fiche + action d'état, pas quinze demi-écrans. |
