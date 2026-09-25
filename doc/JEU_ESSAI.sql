-- ═══════════════════════════════════════════════════════════════════════════
--  AVA MANAGER — LE BANC SIMULÉ
--  20/09/2026 · PostgreSQL 16+ · se joue sur une base montée par les migrations
-- ═══════════════════════════════════════════════════════════════════════════
--
--  ⭐ CE QUE C'EST
--  Une base pleine, aux volumes RÉELS d'Avaliance, sans une seule vraie
--  personne. 20 744 candidats, 4 488 positionnements, 2 580 sociétés.
--
--  ⛔ POURQUOI PAS LES VRAIES DONNÉES
--  1. L'API de Boond exige un **User Token** : l'export sort avec le périmètre
--     d'UNE personne, pas celui de l'instance. Mesuré le 20/09 : le compte
--     d'Ahmed reçoit 403 sur les temps et « Droits insuffisants » sur 8
--     alertes. L'export serait partiel, et on ne le verrait qu'après.
--  2. Neuf questions restent ouvertes — les besoins en P1 ont perdu leur
--     état, la blacklist n'est pas tranchée. Importer maintenant, c'est
--     importer faux et recommencer.
--  3. Un dépôt de développement ne porte pas 20 744 personnes réelles avec
--     leurs téléphones et leurs numéros de sécurité sociale.
--
--  ⭐ ET CE N'EST PAS DU TRAVAIL JETÉ : ce banc devient le TEST du script de
--     reprise. Ce qui charge 20 744 lignes fausses chargera les vraies.
--
-- ───────────────────────────────────────────────────────────────────────────
--  ⭐ CE QU'ON GARDE DU VRAI : LA FORME, JAMAIS L'IDENTITÉ
--
--  | Mesuré chez Boond le 19/09 | Ici |
--  |----------------------------|-----|
--  | 20 744 candidats           | 20 744 |
--  | 4 488 positionnements      | 4 488, même entonnoir |
--  | 2 580 sociétés             | 2 580 |
--  | 1 926 besoins              | 1 926 |
--  | 161 projets, 9 prestations en cours | 161, 9 |
--  | 229 ressources, 204 actives | 229, 204 |
--  | 5 agences, 2 pôles         | 5, 2 |
--
--  ⚠️ C'est la FORME qui casse les écrans — la longueur d'un titre, le
--     nombre de lignes, la répartition entre les états. Pas l'identité.
--
-- ───────────────────────────────────────────────────────────────────────────
--  ⛔ IL SE JOUE EN TANT QUE PROPRIÉTAIRE, PAS EN TANT QUE `ava_app`
--     `TRUNCATE` demande des droits que le rôle applicatif n'a pas — et c'est
--     précisément **M-8** qui tient. ⭐ Si ce script passait sous `ava_app`,
--     le mur serait percé.
--
--  LANCER :
--    psql -U postgres -d ava -v ON_ERROR_STOP=1 -f _ops/JEU_ESSAI.sql
--  REJOUER : il se rejoue autant de fois qu'on veut — il vide d'abord.
--
--  ⭐ TOUS LES IDENTIFIANTS DU BANC COMMENCENT PAR « f ».
--     ⛔ Trouvé à l'exécution : le banc prenait les mêmes UUID fixes que
--     `SPEC_ASSERTIONS_L7.sql`, et les 22 assertions tombaient sur une base
--     pleine — « clé dupliquée sur agence_pkey ». ⚠️ Les deux jeux doivent
--     pouvoir coexister : les assertions tournent AUSSI sur une base remplie.
-- ═══════════════════════════════════════════════════════════════════════════

\set ON_ERROR_STOP on
SET search_path = ava, public;

-- ⛔ GARDE-FOU : on refuse de tourner sur une base qui n'est pas la nôtre,
--    et sur une base qui n'a pas ses référentiels.
DO $$
BEGIN
  IF (SELECT count(*) FROM politique) = 0 THEN
    RAISE EXCEPTION 'Base sans politiques : ce n''est pas une base Ava Manager migrée.';
  END IF;
  IF (SELECT count(*) FROM ref_etat_candidat) = 0 THEN
    RAISE EXCEPTION 'Référentiels vides : joue les migrations d''abord.';
  END IF;
END $$;

BEGIN;

-- ⛔ On vide le MÉTIER, jamais les référentiels ni les politiques.
--    ⚠️ `CASCADE` suit les FK : l'ordre n'a pas à être tenu à la main, et
--    c'est ce qui rend le script rejouable sans qu'on s'en occupe.
-- ⛔⛔ V-024, 21/09 — NI LES DROITS. Ce TRUNCATE vidait aussi `groupe`,
--    `perimetre`, `groupe_permission_perimetre`, `compte_groupe`, `compte`
--    et `agence` — les droits semés par 005 — et ne les recréait pas :
--    après chargement, AUCUNE commande du lot 2 ne passait (« DROIT groupe
--    inconnu ou sans compte de banc »). ⭐ On ne retire plus que ce que le
--    banc a posé lui-même : ses comptes et ses agences, préfixés « f ».
-- ⚠️ La cascade est TRANSITIVE : `societe` → `unite_organisation` →
--    `perimetre` → `groupe_permission_perimetre`. Vider les sociétés vide
--    les droits. ⭐ On met donc de côté les périmètres qui ne tiennent à
--    aucune unité (global, agence — ceux de 005) et leurs permissions, et on
--    les remet après. Un périmètre d'UNITÉ tombe avec son unité : c'est
--    une donnée métier du banc, pas un droit de l'installation.
CREATE TEMP TABLE garde_perimetre ON COMMIT DROP AS
  SELECT * FROM perimetre WHERE unite_id IS NULL;
CREATE TEMP TABLE garde_gpp ON COMMIT DROP AS
  SELECT g.* FROM groupe_permission_perimetre g
  JOIN garde_perimetre p ON p.id = g.perimetre_id;

TRUNCATE TABLE
  temps, absence, snapshot_marge, prestation_version, prestation_ligne_ca,
  prestation, projet, qualification_mesure, qualification,
  positionnement_suivi, positionnement, besoin_competence, besoin,
  contact, unite_organisation, societe_role, societe,
  document, periode_emploi, profil_candidat, profil_ressource,
  action, evenement_metier, reprise_boond, modele, alerte_regle,
  compte_surcharge, calendrier_jour_non_ouvre, personne_coordonnee
CASCADE;

INSERT INTO perimetre SELECT * FROM garde_perimetre ON CONFLICT DO NOTHING;
INSERT INTO groupe_permission_perimetre SELECT * FROM garde_gpp ON CONFLICT DO NOTHING;

-- ⚠️ `personne` ne passe PAS par le TRUNCATE : `compte → personne` ferait
--    cascader le vidage jusqu'aux comptes de 005, puis à `compte_groupe`.
--    On retire les comptes du banc (« f »), puis les personnes qu'aucun
--    compte ne tient, puis les agences du banc.
DELETE FROM compte WHERE id::text LIKE 'f%';
DELETE FROM personne p
 WHERE NOT EXISTS (SELECT 1 FROM compte c WHERE c.personne_id = p.id);
DELETE FROM agence WHERE id::text LIKE 'f%';

-- ═══════════════════════════════════════════════════════════════════════════
--  §1 — LES MOTS. ⭐ Aucun nom réel : tout se compose.
--     Un prénom = un tirage dans 24, un nom = un tirage dans 32.
--     24 × 32 = 768 combinaisons, réparties sur 21 000 personnes : les
--     homonymes existent, et c'est voulu — ⚠️ la détection de doublons doit
--     avoir de quoi mordre.
-- ═══════════════════════════════════════════════════════════════════════════

CREATE TEMP TABLE mot_prenom(i INT, v TEXT);
INSERT INTO mot_prenom(i, v) VALUES
 (0,'Karim'),(1,'Leïla'),(2,'Youssef'),(3,'Amina'),(4,'Mehdi'),(5,'Sofia'),
 (6,'Rachid'),(7,'Nadia'),(8,'Hicham'),(9,'Salma'),(10,'Omar'),(11,'Yasmine'),
 (12,'Julien'),(13,'Claire'),(14,'Thomas'),(15,'Élise'),(16,'Nicolas'),(17,'Manon'),
 (18,'Antoine'),(19,'Camille'),(20,'Pierre'),(21,'Sarah'),(22,'Lucas'),(23,'Inès');

CREATE TEMP TABLE mot_nom(i INT, v TEXT);
INSERT INTO mot_nom(i, v) VALUES
 (0,'BENANI'),(1,'ALAOUI'),(2,'TAZI'),(3,'BERRADA'),(4,'IDRISSI'),(5,'CHAKIR'),
 (6,'LAHLOU'),(7,'SEBTI'),(8,'MANSOURI'),(9,'BENJELLOUN'),(10,'ZOUHRI'),(11,'KADIRI'),
 (12,'MARTIN'),(13,'BERNARD'),(14,'DUBOIS'),(15,'ROBERT'),(16,'PETIT'),(17,'DURAND'),
 (18,'LEROY'),(19,'MOREAU'),(20,'SIMON'),(21,'LAURENT'),(22,'MICHEL'),(23,'GARCIA'),
 (24,'DA SILVA'),(25,'FERREIRA'),(26,'NGUYEN'),(27,'TRAORÉ'),(28,'DIALLO'),(29,'KOUASSI'),
 (30,'OKONKWO'),(31,'MBAYE');

-- ⭐ Les titres viennent des VRAIS métiers relevés chez Boond, sans les
--    personnes : « Business Analyst FO », « Ingénieur DevOps »… Ce sont des
--    titres de poste, pas des données personnelles.
CREATE TEMP TABLE mot_titre(i INT, v TEXT);
INSERT INTO mot_titre(i, v) VALUES
 (0,'Business Analyst Finance de marché'),(1,'Ingénieur DevOps'),
 (2,'Développeur Java / Spring'),(3,'Consultant MOA Banque'),
 (4,'Data Analyst'),(5,'Chef de projet SI'),
 (6,'Architecte Cloud'),(7,'Product Owner'),
 (8,'Ingénieur Réseaux LAN/WAN'),(9,'Analyste Risques de marché'),
 (10,'Consultant SAP FI'),(11,'Développeur Full Stack React/Node'),
 (12,'Expert Cybersécurité'),(13,'Scrum Master'),
 (14,'Ingénieur Test & Validation'),(15,'Consultant Décisionnel BI');

CREATE TEMP TABLE mot_secteur(i INT, v TEXT);
INSERT INTO mot_secteur(i, v) VALUES
 (0,'Banque'),(1,'Assurance'),(2,'Industrie'),(3,'Santé'),
 (4,'Secteur public'),(5,'Conseil'),(6,'Énergie'),(7,'Télécoms');

-- ⭐ Une graine fixe : deux exécutions donnent LE MÊME jeu.
-- ⛔ Sans ça, une porte d'écran comparerait sa capture à une autre base, et
--    tomberait pour une raison qui n'a rien à voir avec le code.
SELECT setseed(0.20260920);

-- ═══════════════════════════════════════════════════════════════════════════
--  §2 — LA STRUCTURE : 5 agences, 2 pôles, 30 comptes
-- ═══════════════════════════════════════════════════════════════════════════

INSERT INTO agence (id, nom, code, pays_code) VALUES
  ('f0000000-0000-0000-0000-000000000001','Avaliance FR','AVFR','FR'),
  ('f0000000-0000-0000-0000-000000000002','Avaliance MA','AVMA','MA'),
  ('f0000000-0000-0000-0000-000000000003','Avaliance Nearshore MA','AVNS','MA'),
  ('f0000000-0000-0000-0000-000000000004','Avaliance US','AVUS','US'),
  ('f0000000-0000-0000-0000-000000000005','Portaliance','PORT','FR');

-- ⭐ ADR-007 : Portaliance est une AGENCE, pas une filiale. Mesuré : 2
--    candidats et 0 ressource chez elle.

-- Le calendrier : les week-ends de 2026, pour les 5 agences.
INSERT INTO calendrier_jour_non_ouvre (agence_id, jour, motif)
SELECT a.id, d::date, 'week_end'
FROM agence a,
     generate_series('2026-01-01'::date, '2026-12-31'::date, '1 day') d
WHERE extract(isodow FROM d) >= 6
  AND a.id::text LIKE 'f%';

INSERT INTO compte (id, email, actif, agence_id)
SELECT ('f1000000-0000-0000-0000-' || lpad(n::text, 12, '0'))::uuid,
       'compte' || n || '@avaliance.test',
       true,
       (SELECT id FROM agence WHERE id::text LIKE 'f%' ORDER BY code LIMIT 1 OFFSET (n % 5))
FROM generate_series(1, 30) n;

-- ═══════════════════════════════════════════════════════════════════════════
--  §3 — LES SOCIÉTÉS : 2 580, dont UNE interne
-- ═══════════════════════════════════════════════════════════════════════════

-- ⭐ V-135 / D-25 : depuis 011, une société porte son AGENCE RESPONSABLE
--    (NOT NULL). Le jeu la prend à son manager — c'est la règle même de 011.
INSERT INTO societe (id, nom, nom_normalise, secteur, pays_code,
                     manager_compte_id, statut_commercial_code, agence_responsable_id)
SELECT ('f2000000-0000-0000-0000-' || lpad(n::text, 12, '0'))::uuid,
       'Société ' || n,
       'societe ' || n,
       (SELECT v FROM mot_secteur WHERE i = n % 8),
       CASE WHEN n % 3 = 0 THEN 'MA' ELSE 'FR' END,
       ('f1000000-0000-0000-0000-' || lpad(((n % 30) + 1)::text, 12, '0'))::uuid,
       -- ⭐ La proportion vient du relevé : une minorité de clients.
       CASE WHEN n % 10 = 0 THEN 'client' ELSE 'prospect' END,
       (SELECT c.agence_id FROM compte c
         WHERE c.id = ('f1000000-0000-0000-0000-' || lpad(((n % 30) + 1)::text, 12, '0'))::uuid)
FROM generate_series(1, 2580) n;

-- La société interne — celle qui porte Avaliance elle-même (G6).
INSERT INTO societe (id, nom, nom_normalise, pays_code, statut_commercial_code, agence_responsable_id)
VALUES ('f2000000-0000-0000-0000-000000009999','Avaliance','avaliance','FR','client',
        'f0000000-0000-0000-0000-000000000001');
INSERT INTO societe_role VALUES
  ('f2000000-0000-0000-0000-000000009999','interne');

-- Les deux pôles internes. ⛔ `agence_id` NOT NULL parce que la société est
--    interne — c'est le trigger `unite_arbre` qui l'exige (D-1).
INSERT INTO unite_organisation (id, societe_id, type_code, nom, agence_id) VALUES
  ('fb000000-0000-0000-0000-000000000001','f2000000-0000-0000-0000-000000009999',
   'pole','Pôle RH','f0000000-0000-0000-0000-000000000001'),
  ('fb000000-0000-0000-0000-000000000002','f2000000-0000-0000-0000-000000009999',
   'pole','Pôle Sales','f0000000-0000-0000-0000-000000000001');

-- 8 000 contacts, répartis sur les sociétés. ⭐ Inégalement : quelques grosses
-- sociétés en portent 28, comme SODEXO chez Boond.
-- ⭐ Le contact suit sa société (011) : même agence responsable.
INSERT INTO contact (id, societe_id, civilite, nom, prenom, fonction,
                     type_code, statut_code, manager_compte_id, agence_responsable_id)
SELECT ('f3000000-0000-0000-0000-' || lpad(n::text, 12, '0'))::uuid,
       ('f2000000-0000-0000-0000-' || lpad((1 + (n * 7) % 2580)::text, 12, '0'))::uuid,
       CASE WHEN n % 2 = 0 THEN 'm' ELSE 'mme' END,
       (SELECT v FROM mot_nom WHERE i = (n * 13) % 32),
       (SELECT v FROM mot_prenom WHERE i = (n * 5) % 24),
       CASE WHEN n % 4 = 0 THEN 'Directeur des achats'
            WHEN n % 4 = 1 THEN 'Responsable IT'
            WHEN n % 4 = 2 THEN 'DSI'
            ELSE 'Chef de projet' END,
       CASE WHEN n % 3 = 0 THEN 'principal' ELSE 'autre' END,
       'actif',
       ('f1000000-0000-0000-0000-' || lpad(((n % 30) + 1)::text, 12, '0'))::uuid,
       (SELECT s.agence_responsable_id FROM societe s
         WHERE s.id = ('f2000000-0000-0000-0000-' || lpad((1 + (n * 7) % 2580)::text, 12, '0'))::uuid)
FROM generate_series(1, 8000) n;

-- ═══════════════════════════════════════════════════════════════════════════
--  §4 — LES PERSONNES : 21 000, et LEURS PROFILS
--  ⭐ Une personne, un ou deux profils. ⛔ Jamais deux du même type — M-3.
-- ═══════════════════════════════════════════════════════════════════════════

INSERT INTO personne (id, civilite, nom, prenom, date_naissance, email,
                      telephone, ville, pays_code)
SELECT ('f4000000-0000-0000-0000-' || lpad(n::text, 12, '0'))::uuid,
       CASE WHEN n % 2 = 0 THEN 'm' ELSE 'mme' END,
       (SELECT v FROM mot_nom WHERE i = n % 32),
       (SELECT v FROM mot_prenom WHERE i = (n / 32) % 24),
       ('1970-01-01'::date + ((n * 37) % 10000)),
       -- ⚠️ `.test` est réservé par la norme : aucune de ces adresses ne peut
       --    exister ni recevoir quoi que ce soit.
       'p' || n || '@exemple.test',
       '+2126' || lpad((n % 10000000)::text, 7, '0'),
       CASE WHEN n % 3 = 0 THEN 'Casablanca' WHEN n % 3 = 1 THEN 'Paris' ELSE 'Rabat' END,
       CASE WHEN n % 3 = 0 THEN 'MA' WHEN n % 3 = 1 THEN 'FR' ELSE 'MA' END
FROM generate_series(1, 21000) n;

-- ── 20 744 candidats ──────────────────────────────────────────────────────
-- ⭐ La répartition des états vient du relevé : l'écrasante majorité est
--    dans le vivier, une poignée est « à supprimer ».
INSERT INTO profil_candidat (id, personne_id, etat_code, titre,
                             disponibilite_code, manager_compte_id, agence_id,
                             pretentions_montant, pretentions_devise_code)
SELECT ('f5000000-0000-0000-0000-' || lpad(n::text, 12, '0'))::uuid,
       ('f4000000-0000-0000-0000-' || lpad(n::text, 12, '0'))::uuid,
       CASE WHEN n % 20 = 0 THEN 'draft' ELSE 'complete' END,
       (SELECT v FROM mot_titre WHERE i = n % 16),
       CASE WHEN n % 3 = 0 THEN 'asap' WHEN n % 3 = 1 THEN '1_3_mois' ELSE '6_mois_plus' END,
       ('f1000000-0000-0000-0000-' || lpad(((n % 30) + 1)::text, 12, '0'))::uuid,
       (SELECT id FROM agence WHERE id::text LIKE 'f%' ORDER BY code LIMIT 1 OFFSET (n % 5)),
       -- ⛔ M-15 : le montant et la devise vont ensemble, ou pas du tout.
       CASE WHEN n % 4 = 0 THEN NULL ELSE 400 + (n % 500) END,
       CASE WHEN n % 4 = 0 THEN NULL WHEN n % 3 = 0 THEN 'MAD' ELSE 'EUR' END
FROM generate_series(1, 20744) n;

-- ── 229 ressources ───────────────────────────────────────────────────────
-- ⭐ 204 actives, 25 sorties — exactement le relevé.
-- ⚠️ Elles prennent les personnes 20 745 à 20 973 : ⛔ une personne ne porte
--    pas les deux profils ici, sinon la conversion candidat→ressource n'aurait
--    plus rien à tester.
INSERT INTO profil_ressource (id, personne_id, type_code, etat_code, titre,
                              agence_id, manager_compte_id,
                              cout_reference, cout_reference_devise_code,
                              tjm_indicatif, tjm_indicatif_devise_code,
                              disponibilite_code)
SELECT ('f6000000-0000-0000-0000-' || lpad(n::text, 12, '0'))::uuid,
       ('f4000000-0000-0000-0000-' || lpad((20744 + n)::text, 12, '0'))::uuid,
       CASE WHEN n % 4 = 0 THEN 'EXTERNAL' ELSE 'INTERNAL' END,
       CASE WHEN n > 204 THEN 'sortie'
            WHEN n % 5 = 0 THEN 'intercontrat'
            ELSE 'en_cours' END,
       (SELECT v FROM mot_titre WHERE i = n % 16),
       (SELECT id FROM agence WHERE id::text LIKE 'f%' ORDER BY code LIMIT 1 OFFSET (n % 4)),
       ('f1000000-0000-0000-0000-' || lpad(((n % 30) + 1)::text, 12, '0'))::uuid,
       280 + (n % 200),
       CASE WHEN n % 3 = 0 THEN 'MAD' ELSE 'EUR' END,
       450 + (n % 350),
       CASE WHEN n % 3 = 0 THEN 'MAD' ELSE 'EUR' END,
       'immediate'
FROM generate_series(1, 229) n;

-- ⛔ Les externes doivent avoir un fournisseur (POL, défaut obligatoire).
UPDATE profil_ressource
   SET societe_fournisseur_id =
       ('f2000000-0000-0000-0000-' || lpad((1 + (('x' || substr(id::text, 3, 6))::bit(24)::int % 2580))::text, 12, '0'))::uuid
 WHERE type_code = 'EXTERNAL';

-- ═══════════════════════════════════════════════════════════════════════════
--  §5 — LE STAFFING : 1 926 besoins, 4 488 positionnements
-- ═══════════════════════════════════════════════════════════════════════════

INSERT INTO besoin (id, societe_id, contact_id, agence_id, titre, type_code,
                    etat_code, priorite_code, nb_postes_vises,
                    unite_couverture_code, fte_vise, date_demarrage_souhaitee,
                    budget, budget_devise_code, ponderation_pct,
                    manager_compte_id)
SELECT ('f7000000-0000-0000-0000-' || lpad(n::text, 12, '0'))::uuid,
       s.id,
       -- ⛔ MUR M-12 : le contact appartient à la société du besoin.
       (SELECT c.id FROM contact c WHERE c.societe_id = s.id LIMIT 1),
       (SELECT id FROM agence WHERE id::text LIKE 'f%' ORDER BY code LIMIT 1 OFFSET (n % 4)),
       (SELECT v FROM mot_titre WHERE i = n % 16),
       CASE WHEN n % 6 = 0 THEN 'forfait' ELSE 'regie' END,
       -- ⭐ La répartition suit l'entonnoir relevé.
       CASE WHEN n % 11 = 0 THEN 'pourvu'
            WHEN n % 11 = 1 THEN 'suspendu'
            WHEN n % 11 IN (2,3) THEN 'ferme'
            WHEN n % 11 IN (4,5,6) THEN 'staffing'
            ELSE 'ouvert' END,
       -- ⭐⭐ DEC-13 : la priorité est une dimension À PART. Chez Boond elle
       --    était mélangée à l'état ; ici, les deux colonnes coexistent.
       CASE WHEN n % 3 = 0 THEN 'P1' WHEN n % 3 = 1 THEN 'P2' ELSE 'P3' END,
       1 + (n % 3),
       CASE WHEN n % 17 = 0 THEN 'fte' ELSE 'postes' END,
       -- ⛔ `fte_vise` se pose À L'INSERT, pas après : le trigger `tg_couv`
       --    refuse la ligne avant qu'un UPDATE puisse la corriger.
       CASE WHEN n % 17 = 0 THEN 1.0 + (n % 3) ELSE NULL END,
       '2026-01-01'::date + (n % 300),
       50000 + (n % 200) * 1000,
       CASE WHEN n % 3 = 0 THEN 'MAD' ELSE 'EUR' END,
       10 + (n % 90),
       ('f1000000-0000-0000-0000-' || lpad(((n % 30) + 1)::text, 12, '0'))::uuid
FROM generate_series(1, 1926) n
JOIN LATERAL (
  SELECT id FROM societe
   WHERE id <> 'f2000000-0000-0000-0000-000000009999'
   ORDER BY id LIMIT 1 OFFSET ((n * 11) % 2580)
) s ON true;

-- ── 4 488 positionnements ────────────────────────────────────────────────
-- ⭐ L'entonnoir relevé chez Boond, ramené à nos 5 catégories :
--    1 760 proposés · 1 500 refusés client · 700 présentés · 400 retenus ·
--    128 retirés. ⚠️ Plus d'un sur trois meurt avant d'atteindre le client.
INSERT INTO positionnement (id, besoin_id, profil_candidat_id, etat_code,
                            tjm_propose, tjm_propose_devise_code,
                            decision_client_le)
SELECT ('fa000000-0000-0000-0000-' || lpad(n::text, 12, '0'))::uuid,
       ('f7000000-0000-0000-0000-' || lpad((1 + (n * 7) % 1926)::text, 12, '0'))::uuid,
       ('f5000000-0000-0000-0000-' || lpad((1 + (n * 13) % 20744)::text, 12, '0'))::uuid,
       CASE WHEN n <= 1760 THEN 'propose'
            WHEN n <= 3260 THEN 'refuse_client'
            WHEN n <= 3960 THEN 'presente'
            WHEN n <= 4360 THEN 'retenu'
            ELSE 'retire' END,
       450 + (n % 400),
       CASE WHEN n % 3 = 0 THEN 'MAD' ELSE 'EUR' END,
       CASE WHEN n > 1760 AND n <= 4360 THEN '2026-03-01'::date + (n % 180) ELSE NULL END
FROM generate_series(1, 4488) n;

-- ═══════════════════════════════════════════════════════════════════════════
--  §6 — LA PRODUCTION : 161 projets, 170 prestations, 9 en cours
-- ═══════════════════════════════════════════════════════════════════════════

INSERT INTO projet (id, reference, societe_id, contact_id, agence_id,
                    type_code, titre, etat_code, date_debut, date_fin,
                    devise_defaut_code, responsable_manager_compte_id)
SELECT ('f8000000-0000-0000-0000-' || lpad(n::text, 12, '0'))::uuid,
       -- ⛔ `SIM-`, pas `PRJ-` : la référence est UNIQUE, et les assertions
       --    créent `PRJ-0001`. Deuxième collision trouvée à l'exécution, sur
       --    un autre axe que les UUID. ⭐ Et ça se lit : une référence `SIM-`
       --    dit tout de suite qu'on est sur le banc.
       'SIM-' || lpad(n::text, 4, '0'),
       s.id,
       (SELECT c.id FROM contact c WHERE c.societe_id = s.id LIMIT 1),
       (SELECT id FROM agence WHERE id::text LIKE 'f%' ORDER BY code LIMIT 1 OFFSET (n % 4)),
       CASE WHEN n % 5 = 0 THEN 'forfait' ELSE 'regie' END,
       (SELECT v FROM mot_titre WHERE i = n % 16) || ' — mission',
       CASE WHEN n <= 20 THEN 'ouvert' ELSE 'clos' END,
       '2025-06-01'::date + (n % 400),
       '2025-06-01'::date + (n % 400) + 180,
       CASE WHEN n % 3 = 0 THEN 'MAD' ELSE 'EUR' END,
       ('f1000000-0000-0000-0000-' || lpad(((n % 30) + 1)::text, 12, '0'))::uuid
FROM generate_series(1, 161) n
JOIN LATERAL (
  SELECT id FROM societe
   WHERE statut_commercial_code = 'client'
   ORDER BY id LIMIT 1 OFFSET ((n * 3) % 250)
) s ON true;

-- ⭐ 9 prestations en cours (`signee`), le reste clos ou prévisionnel —
--    exactement le relevé du 19/09.
-- ⚠️ La devise du coût peut DIFFÉRER de celle de la vente : un freelance
--    payé en MAD, vendu en EUR. ⛔ La marge vaudra alors « — » (ATL-16).
INSERT INTO prestation (id, projet_id, profil_ressource_id, etat_code,
                        date_debut, date_fin, tjm_vendu, devise_code,
                        cjm_contrat, cjm_devise_code, jours_vendus,
                        taux_occupation_pct)
SELECT ('f9000000-0000-0000-0000-' || lpad(n::text, 12, '0'))::uuid,
       ('f8000000-0000-0000-0000-' || lpad((1 + (n % 161))::text, 12, '0'))::uuid,
       ('f6000000-0000-0000-0000-' || lpad((1 + (n % 204))::text, 12, '0'))::uuid,
       CASE WHEN n <= 9 THEN 'signee'
            WHEN n <= 150 THEN 'cloturee'
            WHEN n <= 160 THEN 'annulee'
            ELSE 'previsionnelle' END,
       '2025-09-01'::date + (n % 300),
       '2025-09-01'::date + (n % 300) + 200,
       500 + (n % 350),
       CASE WHEN n % 3 = 0 THEN 'MAD' ELSE 'EUR' END,
       300 + (n % 180),
       -- ⭐ Une sur sept est payée dans une autre devise que celle de la vente.
       CASE WHEN n % 7 = 0 THEN 'MAD'
            WHEN n % 3 = 0 THEN 'MAD' ELSE 'EUR' END,
       100 + (n % 120),
       CASE WHEN n % 9 = 0 THEN 50 ELSE 100 END
FROM generate_series(1, 170) n;

-- ── Les temps ────────────────────────────────────────────────────────────
-- ⚠️ Avaliance N'EN SAISIT PAS dans Boond : le module est fermé (403).
-- ⭐ On en met quand même, et c'est exactement la règle d'Hamada : « on fait
--    le chemin ; ils veulent saisir, ils saisissent ». Sans temps, on ne peut
--    ni tester le CA produit, ni la surcharge, ni le plafond journalier.
INSERT INTO temps (prestation_id, profil_ressource_id, jour, quantite,
                   saisi_par_compte_id)
SELECT p.id, p.profil_ressource_id, d::date,
       CASE WHEN (extract(day FROM d)::int % 7) = 0 THEN 0.5 ELSE 1.0 END,
       'f1000000-0000-0000-0000-000000000001'::uuid
FROM prestation p
CROSS JOIN LATERAL generate_series(
  p.date_debut, LEAST(p.date_fin, p.date_debut + 90), '1 day') d
WHERE p.etat_categorie IN ('engage','clos')
  AND extract(isodow FROM d) < 6;

-- ── Les absences ─────────────────────────────────────────────────────────
INSERT INTO absence (profil_ressource_id, type_code, date_debut, date_fin,
                     quantite_par_jour, saisi_par_compte_id)
SELECT r.id, 'conge',
       -- ⚠️ `row_number()` rend un BIGINT, et `date + bigint` n'existe pas.
       --    Il faut le ramener en INT : PostgreSQL ne le fait pas tout seul.
       '2026-07-01'::date + ((row_number() OVER ()) % 30)::int,
       '2026-07-01'::date + ((row_number() OVER ()) % 30)::int + 10,
       1.0,
       'f1000000-0000-0000-0000-000000000001'::uuid
FROM profil_ressource r
WHERE r.etat_categorie <> 'sorti';

-- ═══════════════════════════════════════════════════════════════════════════
--  §7 — LES ACTIONS : 20 000, un seul porteur chacune (M-9)
-- ═══════════════════════════════════════════════════════════════════════════

INSERT INTO action (societe_id, contact_id, profil_candidat_id, besoin_id,
                    type_code, date, contenu, responsable_compte_id)
SELECT
  CASE WHEN n % 4 = 0 THEN ('f2000000-0000-0000-0000-' || lpad((1 + n % 2580)::text, 12, '0'))::uuid END,
  CASE WHEN n % 4 = 1 THEN ('f3000000-0000-0000-0000-' || lpad((1 + n % 8000)::text, 12, '0'))::uuid END,
  CASE WHEN n % 4 = 2 THEN ('f5000000-0000-0000-0000-' || lpad((1 + n % 20744)::text, 12, '0'))::uuid END,
  CASE WHEN n % 4 = 3 THEN ('f7000000-0000-0000-0000-' || lpad((1 + n % 1926)::text, 12, '0'))::uuid END,
  (SELECT code FROM ref_type_action ORDER BY ordre LIMIT 1 OFFSET (n % 9)),
  '2026-01-01'::timestamptz + (n % 260) * interval '1 day',
  'Échange du ' || to_char('2026-01-01'::date + (n % 260), 'DD/MM/YYYY'),
  ('f1000000-0000-0000-0000-' || lpad(((n % 30) + 1)::text, 12, '0'))::uuid
FROM generate_series(1, 20000) n;

COMMIT;

-- ═══════════════════════════════════════════════════════════════════════════
--  §8 — LE COMPTE RENDU. ⭐ On MESURE ce qu'on a posé, on ne l'annonce pas.
-- ═══════════════════════════════════════════════════════════════════════════

\echo ''
\echo '  ══ BANC SIMULÉ — ce qui est en base ══'
SELECT 'personne'        AS objet, count(*) AS n, 21000 AS attendu FROM personne
UNION ALL SELECT 'profil_candidat',   count(*), 20744 FROM profil_candidat
UNION ALL SELECT 'profil_ressource',  count(*),   229 FROM profil_ressource
UNION ALL SELECT 'societe',           count(*),  2581 FROM societe
UNION ALL SELECT 'contact',           count(*),  8000 FROM contact
UNION ALL SELECT 'besoin',            count(*),  1926 FROM besoin
UNION ALL SELECT 'positionnement',    count(*),  4488 FROM positionnement
UNION ALL SELECT 'projet',            count(*),   161 FROM projet
UNION ALL SELECT 'prestation',        count(*),   170 FROM prestation
UNION ALL SELECT 'action',            count(*), 20000 FROM action
UNION ALL SELECT 'temps',             count(*),     0 FROM temps
UNION ALL SELECT 'absence',           count(*),     0 FROM absence;

\echo ''
\echo '  ══ L''ENTONNOIR DU STAFFING — la forme, pas les gens ══'
SELECT etat_categorie, count(*) AS n
FROM positionnement GROUP BY 1 ORDER BY 2 DESC;

\echo ''
\echo '  ══ LES PRESTATIONS PAR ÉTAT ══'
SELECT etat_categorie, count(*) AS n FROM prestation GROUP BY 1 ORDER BY 2 DESC;

\echo ''
\echo '  ⭐ Zéro personne réelle. Les adresses sont en .test — réservé par la'
\echo '     norme, elles ne peuvent ni exister ni recevoir quoi que ce soit.'
\echo ''
