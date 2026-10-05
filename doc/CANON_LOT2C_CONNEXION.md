# Canon du lot 2c — la connexion (05/10/2026)

> **Hamada, 18/09 :** « personne ne crée de mot de passe ; on clique « se connecter », on est déjà identifié ».
> **T2 / D-10 :** un réglage `auth.fournisseur` (microsoft · google · email_mot_de_passe), une session opaque hachée,
> et tant que le lot 2c n'est pas livré, le serveur refuse tout hors `AVA_MODE=banc`.

<etat>

## ⬜ CE QUI RESTE À FAIRE

| # | Quoi | Qui | État |
|---|---|---|---|
| 1 | Ce canon | BRAIN | ✅ 05/10 |
| 2 | Le code, branche `lot-2c` (depuis `lot-3`), poste `postes/ava-lot2c`, base `ava_lot2c`, port 3600 | session « Code Lot 3 » | ⬜ |
| 3 | Les portes du §4, branche `lot-2c-brain` | Brain Code (juge) | ⬜ |
| 4 | L'application déclarée chez Microsoft Entra (identifiant client, secret, adresse de retour) | ⛔ **Hamada seul** — aucun agent ne crée de compte ni ne saisit de secret | ⬜ |
| 5 | Essai réel avec un compte `@avaliance.com` | Hamada | ⬜ après 2, 3, 4 |

</etat>

## 1 · Ce qui est tranché

| # | Règle |
|---|---|
| **C-1** | ⭐ **Un seul module d'identité** côté page (D-97) et **un seul** côté serveur : tout le reste lit le compte qu'il rend. Le lot 2c remplace le `?compte=` du banc par la session, **sans toucher** aux écrans |
| **C-2** | Le fournisseur se lit dans `auth.fournisseur` (registre). Les trois valeurs sont servies par **une même interface** (`debut` → redirection, `retour` → identité vérifiée) ; `microsoft` et `google` en OpenID Connect (code + PKCE + `state` + `nonce`), `email_mot_de_passe` en lien magique à usage unique — **jamais de mot de passe stocké** |
| **C-3** | L'identité retenue est l'**adresse e-mail vérifiée** rendue par le fournisseur (revendication `email` vérifiée, ou `preferred_username` pour Entra), comparée **sans casse** à `compte.email`. Aucun compte n'est **créé** à la connexion : un e-mail inconnu → refus « compte inconnu », tracé (D-92) |
| **C-4** | Un compte **inactif** → refus, tracé. Désactiver un compte **coupe ses sessions** dans la même transaction |
| **C-5** | La session (D-10) : jeton **opaque, aléatoire ≥ 32 octets**, stocké **haché** (SHA-256), avec expiration ; cookie `HttpOnly`, `Secure`, `SameSite=Lax`, chemin `/` ; jamais l'identifiant du compte dans le cookie ni dans l'URL |
| **C-6** | Durées : politiques nouvelles `auth.session.duree_heures` (plage 1 → 24, défaut 10) et `auth.session.inactivite_minutes` (plage 15 → 240, défaut 60) — inscrites au registre exécutable avec leur seuil (D-108) |
| **C-7** | Se déconnecter supprime la session côté serveur (pas seulement le cookie) |
| **C-8** | Toute écriture (POST) exige, en plus de la session, un en-tête anti-CSRF lié à la session |
| **C-9** | Les secrets (identifiant client, secret, adresse de retour) viennent de l'**environnement** du serveur, jamais du dépôt ; un serveur sans eux démarre en refusant toute connexion par ce fournisseur, et le dit |
| **C-10** | `AVA_MODE=banc` garde `?compte=` **pour le banc seul** ; hors banc, `?compte=` est refusé (400), et un serveur hors banc sans session rend 401 sur toute route |
| **C-11** | Au banc, le fournisseur est un **faux fournisseur OIDC** du juge (D-102), qui signe ses jetons ; jamais un appel réel à Microsoft |
| **C-12** | ⭐ (05/10) Un **sixième code de refus, `AUTH`** : « tu n'es pas identifié » (sans session, session échue, compte inconnu ou inactif à la connexion), distinct de `DROIT` (« identifié, mais sans le droit »). Réponse 401. Tracé dans `tentative_refusee` quand un compte est connu (session échue, compte inactif) ou quand un e-mail a été présenté (compte inconnu, auteur nul) ; un anonyme sans rien présenter n'est pas tracé |

### Réponses aux questions du codeur (05/10)

| Q | Tranché |
|---|---|
| Q1 · environnement | `AVA_AUTH_ISSUER` (découverte `/.well-known/openid-configuration`, JWKS compris), `AVA_AUTH_CLIENT_ID`, `AVA_AUTH_CLIENT_SECRET`, `AVA_AUTH_REDIRECT_URI` ; Entra : `https://login.microsoftonline.com/<tenant>/v2.0` ; signature vérifiée par `node:crypto`, sans dépendance nouvelle. Le faux fournisseur du juge sert la même découverte |
| Q2 · tables (migration du juge) | `auth_session` (jeton_hash PK, compte_id, csrf_hash, cree_le, expire_le, dernier_acces_le) · `auth_tentative` (state_hash PK, nonce, code_verifier, fournisseur, expire_le ; usage unique, supprimée au retour) · le rôle serveur a SELECT, INSERT, UPDATE, DELETE sur elles seules |
| Q3 · lien magique | ⛔ **`email_mot_de_passe` n'est pas servi au lot 2c** : le produit n'envoie pas encore de courriel (l'envoi vient au lot 5.8). La valeur reste au registre, `SetPolicy` la refuse (règle 2), et C-2 ne sert que `microsoft` et `google`. Pas de table de lien magique |
| Q4 · coupure | un **déclencheur du juge** : `compte.actif` passe à faux → les `auth_session` du compte sont supprimées dans la même transaction, quelle que soit la commande |
| Q5 · territoire | le codeur du lot 2c touche `server/src/index.ts` **au minimum** : un appel au module d'identité dans le crochet et dans la route des commandes ; `executer.ts` intact. Le message « auth non livrée » disparaît : hors banc sans session → 401 « session requise » |

## 2 · Les écrans

| Écran | Contenu |
|---|---|
| Connexion | le logo, **un** bouton « Se connecter avec <fournisseur> » (libellé tiré du registre), rien d'autre ; le refus (compte inconnu, inactif) en une phrase sous le bouton |
| Bandeau | « Se déconnecter » dans le menu « moi » (sous le nom), à côté de l'administration |

## 3 · Hors du lot 2c

Créer des comptes (c'est `ManageGroups`, déjà servi) · l'authentification à deux facteurs (portée par le fournisseur) ·
la synchronisation des annuaires.

## 4 · Les portes (juge, branche `lot-2c-brain`, plage P-413 → P-430)

| Porte | Ce qu'elle exige |
|---|---|
| Parcours | faux fournisseur : connexion → session → `/vues/besoins` 200 ; déconnexion → 401 |
| Identité | e-mail inconnu → refus tracé, aucun compte créé ; compte inactif → refus ; casse différente → même compte |
| Jeton | session stockée hachée (jamais le jeton en clair en base) ; longueur ≥ 32 octets ; cookie avec ses trois attributs |
| Expiration | durée et inactivité aux deux valeurs adjacentes de leur seuil (D-108) |
| Coupure | désactiver un compte → sa session suivante rend 401 |
| CSRF | POST sans l'en-tête → refus |
| `state` / `nonce` | rejoués ou faux → refus |
| Hors banc | `?compte=` → 400 ; sans session → 401 sur toutes les routes de LECTURES et toutes les commandes |
| Secrets | aucun secret dans le dépôt (recherche sur l'arbre) |

<source>

T2 et D-10 : `DECISIONS_TECHNIQUES_v1.md` · `auth.fournisseur` : `REGISTRE_POLITIQUES_v1.md` §C · D-97 :
`CANON_LOT3_ECRANS.md` §6 bis · D-92 (refus tracés), D-102 (faux au banc), D-108 (seuils).

</source>
