# Les fonds d'écran d'Ava Manager

⭐ **Déposez les images ICI**, en `.jpg`, et dites-le moi : j'ajoute une ligne au catalogue
`IMAGES` de `terminal.html` et le fond apparaît dans le panneau de réglages.

| Règle | Pourquoi |
|---|---|
| **1600 px de large maximum** | au-delà, on paie du poids qu'aucun écran ne montre |
| **JPEG, qualité 80** | ~150 Ko chacun. ⛔ Un PNG de nébuleuse pèse 4 Mo pour rien |
| **Sombre, peu contrasté** | ⚠️ un fond qui a du caractère se bat avec les chiffres. Le voile est là pour ça, mais il ne sauve pas une image trop claire |
| Nom en minuscules, sans espace | `avaliance-01.jpg`, `avaliance-02.jpg`… |

⛔ **Le mock est un fichier unique** : une image référencée par `fonds/…` marche sur le hub
GitHub Pages mais **pas dans l'artefact Claude**, qui bloque toute image externe. Pour qu'une
image marche aux deux endroits, elle est **encastrée en base64** dans le fichier — d'où la
limite de poids.

⭐ **`MAILLAGE` ne pèse rien** : il est *dessiné* au chargement, dans la couleur de STRUCTURE
du thème. C'est le seul fond qui suit le thème au lieu de lui résister.
