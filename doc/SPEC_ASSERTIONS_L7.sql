-- ═══════════════════════════════════════════════════════════════════════════
--  AVA MANAGER — LIVRABLE L7 : LES 22 ASSERTIONS
--  Un test par mur. PostgreSQL 16+ · 19/09/2026
--  Se lance CONTRE une base montée par `SPEC_SQL_AVAMANAGER_V1.sql`.
-- ═══════════════════════════════════════════════════════════════════════════
--
--  ⭐ POURQUOI CE FICHIER EXISTE AVANT LE CODE
--  Une autre IA va écrire le produit. Un test écrit APRÈS son code se plie à
--  son code : il vérifie ce qu'il a fait, pas ce qu'on voulait. Écrit avant,
--  il ne discute pas.
--
--  ⭐ CE QU'UNE ASSERTION PROUVE
--  Que le mur tient DANS LA BASE. Pas dans une garde applicative, pas dans un
--  écran, pas dans une revue de code : dans la base, contre une console
--  ouverte un vendredi soir.
--
--  ⛔ CE QU'AUCUNE ASSERTION NE FAIT
--  Vérifier une POLITIQUE. Une politique se règle — la tester la figerait, et
--  on aurait recréé un mur par la porte de service. Les 167 clés se vérifient
--  autrement : le seed contre le registre §E.
--
--  ⭐ COMMENT ON LES LIT
--  Une assertion qui PASSE affiche `OK`. Une assertion qui ÉCHOUE lève, et
--  la transaction entière tombe. ⛔ Pas de « 21 sur 22 » : un mur percé est
--  un mur percé.
--
--  LANCER :
--    psql -v ON_ERROR_STOP=1 -f SPEC_SQL_AVAMANAGER_V1.sql
--    psql -v ON_ERROR_STOP=1 -f SPEC_ASSERTIONS_L7.sql
-- ═══════════════════════════════════════════════════════════════════════════

SET search_path = ava, public;

-- ═══════════════════════════════════════════════════════════════════════════
--  §0 — LE HARNAIS : trois gestes, et rien d'autre
--  ⭐ Écrits une fois pour que chaque assertion tienne en une ligne lisible.
--     Un harnais long fait qu'on relit le harnais au lieu du test.
-- ═══════════════════════════════════════════════════════════════════════════

CREATE SCHEMA IF NOT EXISTS t;

-- ⛔ `doit_refuser` — le cœur. On TENTE le geste interdit ; s'il passe, le
--    mur n'existe pas. ⚠️ On ne se contente pas d'« une erreur quelconque » :
--    on exige que le message nomme le mur, sinon une faute de frappe dans un
--    nom de colonne passerait pour une preuve.
CREATE OR REPLACE FUNCTION t.doit_refuser(nom TEXT, mur TEXT, sql TEXT, attendu TEXT DEFAULT NULL)
RETURNS VOID LANGUAGE plpgsql AS $$
DECLARE msg TEXT;
BEGIN
  BEGIN
    EXECUTE sql;
  EXCEPTION WHEN OTHERS THEN
    GET STACKED DIAGNOSTICS msg = MESSAGE_TEXT;
    IF attendu IS NOT NULL AND position(lower(attendu) in lower(msg)) = 0 THEN
      RAISE EXCEPTION E'\n  ⛔ % (%) — refusé, mais PAS pour la bonne raison.\n     attendu : « % »\n     obtenu  : « % »', nom, mur, attendu, msg;
    END IF;
    RAISE NOTICE 'OK   % — %', mur, nom;
    RETURN;
  END;
  RAISE EXCEPTION E'\n  ⛔ % (%) — LE GESTE EST PASSÉ. Le mur n''est pas dans la base.', nom, mur;
END $$;

-- ⛔ `doit_etre` — pour les murs qui sont une ABSENCE : une colonne qui
--    n'existe pas, un droit qu'on n'a pas. On ne peut pas « tenter » une
--    absence, on la constate dans le catalogue.
CREATE OR REPLACE FUNCTION t.doit_etre(nom TEXT, mur TEXT, vrai BOOL)
RETURNS VOID LANGUAGE plpgsql AS $$
BEGIN
  IF NOT vrai THEN
    RAISE EXCEPTION E'\n  ⛔ % (%) — FAUX.', nom, mur;
  END IF;
  RAISE NOTICE 'OK   % — %', mur, nom;
END $$;

-- Raccourci : la colonne existe-t-elle ?
CREATE OR REPLACE FUNCTION t.colonne(tbl TEXT, col TEXT) RETURNS BOOL
LANGUAGE sql STABLE AS $$
  SELECT EXISTS (SELECT 1 FROM information_schema.columns
                 WHERE table_schema = 'ava' AND table_name = tbl AND column_name = col)
$$;

-- Raccourci : le rôle a-t-il ce droit sur cette table ?
CREATE OR REPLACE FUNCTION t.droit(role TEXT, tbl TEXT, priv TEXT) RETURNS BOOL
LANGUAGE sql STABLE AS $$
  SELECT has_table_privilege(role, 'ava.' || tbl, priv)
$$;


-- ═══════════════════════════════════════════════════════════════════════════
--  §1 — LE JEU D'ESSAI
--  ⚠️ Le MINIMUM pour que les 22 assertions aient de quoi mordre. Rien de
--     plus : un jeu d'essai qui grossit finit par cacher ce qu'il teste.
--  ⭐ Tout est préfixé `t.` et tout est jeté au §4 : la base repart propre.
-- ═══════════════════════════════════════════════════════════════════════════

CREATE OR REPLACE FUNCTION t.monte() RETURNS VOID LANGUAGE plpgsql AS $$
BEGIN
  -- Les référentiels que les FK exigent.
  INSERT INTO ref_pays  VALUES ('FR','France','defaut',1,true,true) ON CONFLICT DO NOTHING;
  INSERT INTO ref_devise VALUES ('EUR','Euro','defaut',1,true,true),
                                ('MAD','Dirham','defaut',2,true,true) ON CONFLICT DO NOTHING;
  INSERT INTO ref_type_ressource VALUES ('INTERNAL','Interne','interne',1,true,true),
                                        ('EXTERNAL','Externe','externe',2,true,true) ON CONFLICT DO NOTHING;
  INSERT INTO ref_etat_candidat     VALUES ('complete','Complet','actif',1,true,true) ON CONFLICT DO NOTHING;
  INSERT INTO ref_etat_ressource    VALUES ('en_cours','En mission','en_mission',1,true,true) ON CONFLICT DO NOTHING;
  INSERT INTO ref_etat_besoin       VALUES ('ouvert','À pourvoir','a_pourvoir',1,true,true) ON CONFLICT DO NOTHING;
  INSERT INTO ref_etat_projet       VALUES ('ouvert','Ouvert','ouvert',1,true,true) ON CONFLICT DO NOTHING;
  INSERT INTO ref_etat_prestation   VALUES ('previsionnelle','Prévisionnelle','previsionnel',1,true,true),
                                           ('signee','Signée','engage',2,true,true) ON CONFLICT DO NOTHING;
  INSERT INTO ref_etat_positionnement VALUES ('propose','Proposé','propose',1,true,true) ON CONFLICT DO NOTHING;
  INSERT INTO ref_statut_commercial VALUES ('prospect','Prospect','defaut',1,true,true) ON CONFLICT DO NOTHING;
  INSERT INTO ref_role_societe      VALUES ('interne','Interne','defaut',1,true,true) ON CONFLICT DO NOTHING;
  INSERT INTO ref_type_mission      VALUES ('regie','Régie','defaut',1,true,true) ON CONFLICT DO NOTHING;
  INSERT INTO ref_type_unite        VALUES ('pole','Pôle','pole',1,true,true),
                                           ('equipe','Équipe','equipe',2,true,true) ON CONFLICT DO NOTHING;
  INSERT INTO ref_type_action       VALUES ('note','Note','defaut',1,true,true) ON CONFLICT DO NOTHING;
  INSERT INTO ref_unite_couverture  VALUES ('postes','Postes','defaut',1,true,true) ON CONFLICT DO NOTHING;

  /* ⭐ Les trois politiques que les triggers du jeu d'essai LISENT. `pol()`
     lève sur une clé absente — c'est voulu : une clé oubliée est un bug, pas
     un défaut silencieux. ⚠️ Il en faut donc trois ici, et exactement trois. */
  INSERT INTO politique (cle, valeur, valeur_defaut, type, valeurs_possibles, categorie, libelle) VALUES
    ('temps.facturable.mode','egal_au_produit','egal_au_produit','enum',
     '["egal_au_produit","saisie_separee"]','metier','Temps facturable'),
    ('prestation.avenant.mode','nouvelle_prestation','nouvelle_prestation','enum',
     '["nouvelle_prestation","version_datee"]','metier','Mode d''avenant'),
    ('droits.surcharge_restrictive','restriction_gagne','restriction_gagne','enum',
     '["restriction_gagne","union_gagne"]','metier','Surcharge restrictive')
  ON CONFLICT DO NOTHING;

  -- Deux agences : la seconde ne sert QU'à prouver M-12 (D-1).
  INSERT INTO agence (id, nom, code, pays_code) VALUES
    ('a0000000-0000-0000-0000-000000000001','Casablanca','CASA','FR'),
    ('a0000000-0000-0000-0000-000000000002','Rabat','RBAT','FR');

  INSERT INTO compte (id, email, agence_id) VALUES
    ('c0000000-0000-0000-0000-000000000001','essai@ava.test','a0000000-0000-0000-0000-000000000001');

  -- Deux sociétés : la seconde ne sert QU'à prouver M-12.
  INSERT INTO societe (id, nom, nom_normalise, statut_commercial_code) VALUES
    ('50000000-0000-0000-0000-000000000001','Client A','client a','prospect'),
    ('50000000-0000-0000-0000-000000000002','Client B','client b','prospect');

  INSERT INTO contact (id, societe_id, nom) VALUES
    ('c1000000-0000-0000-0000-000000000002','50000000-0000-0000-0000-000000000002','Chez B');

  -- Deux personnes : l'une candidate, l'autre ressource.
  INSERT INTO personne (id, nom, prenom) VALUES
    ('90000000-0000-0000-0000-000000000001','Essai','Candidat'),
    ('90000000-0000-0000-0000-000000000002','Essai','Ressource'),
    ('90000000-0000-0000-0000-000000000003','Essai','Autre');

  INSERT INTO profil_candidat (id, personne_id, etat_code, titre) VALUES
    ('b0000000-0000-0000-0000-000000000001','90000000-0000-0000-0000-000000000001','complete','Dév');

  INSERT INTO profil_ressource (id, personne_id, type_code, etat_code, titre, agence_id) VALUES
    ('d0000000-0000-0000-0000-000000000001','90000000-0000-0000-0000-000000000002','INTERNAL','en_cours','Dév','a0000000-0000-0000-0000-000000000001'),
    ('d0000000-0000-0000-0000-000000000002','90000000-0000-0000-0000-000000000003','INTERNAL','en_cours','Dév','a0000000-0000-0000-0000-000000000001');

  INSERT INTO besoin (id, societe_id, agence_id, titre, etat_code) VALUES
    ('be000000-0000-0000-0000-000000000001','50000000-0000-0000-0000-000000000001','a0000000-0000-0000-0000-000000000001','Un besoin','ouvert');

  INSERT INTO projet (id, reference, societe_id, agence_id, type_code, titre, etat_code) VALUES
    ('60000000-0000-0000-0000-000000000001','PRJ-0001','50000000-0000-0000-0000-000000000001','a0000000-0000-0000-0000-000000000001','regie','Un projet','ouvert');

  -- Une prestation PRÉVISIONNELLE (corrigeable) et une SIGNÉE (figée).
  INSERT INTO prestation (id, projet_id, profil_ressource_id, etat_code, date_debut, date_fin,
                          tjm_vendu, devise_code, cjm_contrat, cjm_devise_code, taux_occupation_pct)
  VALUES
    ('70000000-0000-0000-0000-000000000001','60000000-0000-0000-0000-000000000001','d0000000-0000-0000-0000-000000000001','previsionnelle','2026-01-01','2026-12-31',500,'EUR',300,'EUR',100),
    ('70000000-0000-0000-0000-000000000002','60000000-0000-0000-0000-000000000001','d0000000-0000-0000-0000-000000000001','signee','2026-01-01','2026-12-31',500,'EUR',300,'EUR',100);

  INSERT INTO snapshot_marge (prestation_id, version_atl, ca_produit, ca_devise_code,
                              cout_produit, cout_devise_code, marge, entrees)
  VALUES ('70000000-0000-0000-0000-000000000002','ATL-2026-09-16',1000,'EUR',600,'EUR',400,'{}'::jsonb);

  INSERT INTO evenement_metier (type, objet_type, objet_id)
  VALUES ('PrestationSigned','prestation','70000000-0000-0000-0000-000000000002');
END $$;

BEGIN;
SELECT t.monte();


-- ═══════════════════════════════════════════════════════════════════════════
--  §2 — LES 22 ASSERTIONS
-- ═══════════════════════════════════════════════════════════════════════════

-- ── M-1 · un candidat ne produit pas ──────────────────────────────────────
-- ⭐ Ce mur n'est pas une garde : c'est une ABSENCE DE PORTE. On ne peut pas
--    « tenter » de poser un temps sur un candidat — il n'y a pas où l'écrire.
--    C'est le mur le plus fort du modèle, et le seul qui se prouve en
--    regardant ce qui MANQUE.
SELECT t.doit_etre('aucune colonne candidat sur `temps`', 'M-1',
  NOT t.colonne('temps','profil_candidat_id') AND NOT t.colonne('prestation','profil_candidat_id'));

-- ── M-2 · un positionnement est candidat XOR ressource ────────────────────
SELECT t.doit_refuser('les deux profils à la fois', 'M-2', $s$
  INSERT INTO positionnement (besoin_id, profil_candidat_id, profil_ressource_id, etat_code)
  VALUES ('be000000-0000-0000-0000-000000000001',
          'b0000000-0000-0000-0000-000000000001',
          'd0000000-0000-0000-0000-000000000001','propose')
$s$, 'ck_m2_xor');

SELECT t.doit_refuser('aucun des deux profils', 'M-2', $s$
  INSERT INTO positionnement (besoin_id, etat_code)
  VALUES ('be000000-0000-0000-0000-000000000001','propose')
$s$, 'ck_m2_xor');

-- ── M-3 · un seul profil de chaque type par personne ──────────────────────
-- ⚠️ Sans ce mur, une personne a deux viviers et on ne sait plus lequel dit
--    vrai. Le doublon de PERSONNE, lui, est une politique : on avertit.
--    ⛔ Ne pas confondre les deux — c'est l'erreur classique.
SELECT t.doit_refuser('deux profils candidat sur la même personne', 'M-3', $s$
  INSERT INTO profil_candidat (personne_id, etat_code, titre)
  VALUES ('90000000-0000-0000-0000-000000000001','complete','Doublon')
$s$, 'unique');

-- ── M-4 · la ressource d'une prestation est immuable ──────────────────────
-- ⭐ Même sur une PRÉVISIONNELLE. Changer la personne d'une mission, c'est
--    une autre mission — pas une correction.
SELECT t.doit_refuser('changer la ressource d''une prestation', 'M-4', $s$
  UPDATE prestation SET profil_ressource_id = 'd0000000-0000-0000-0000-000000000002'
  WHERE id = '70000000-0000-0000-0000-000000000001'
$s$, 'M-4');

-- ── M-5 · pas de ressource posée sur le projet ────────────────────────────
-- ⭐ Une colonne ici aurait divergé de `prestation` dès la deuxième mission.
SELECT t.doit_etre('aucune colonne ressource sur `projet`', 'M-5',
  NOT t.colonne('projet','profil_ressource_id'));

-- ── M-6 · le snapshot de marge est figé ───────────────────────────────────
SELECT t.doit_refuser('recalculer un snapshot', 'M-6', $s$
  UPDATE snapshot_marge SET marge = 999 WHERE prestation_id = '70000000-0000-0000-0000-000000000002'
$s$, 'M-6');

-- ⭐ Et le droit, pas seulement le trigger : un trigger se désactive.
SELECT t.doit_etre('`ava_app` n''a pas UPDATE sur `snapshot_marge`', 'M-6',
  NOT t.droit('ava_app','snapshot_marge','UPDATE'));

-- ── M-7 · l'historique est en ajout seul ──────────────────────────────────
SELECT t.doit_refuser('réécrire un événement', 'M-7', $s$
  UPDATE evenement_metier SET motif = 'réécrit' WHERE type = 'PrestationSigned'
$s$, 'M-7');

SELECT t.doit_refuser('effacer un événement', 'M-7', $s$
  DELETE FROM evenement_metier WHERE type = 'PrestationSigned'
$s$, 'M-7');

-- ── M-8 · rien ne se supprime, tout s'archive ─────────────────────────────
-- ⭐ C'est CE mur qui explique pourquoi il n'y a aucune icône de corbeille
--    dans les 24 écrans : l'UI ne propose pas un geste que la base refuse.
-- ⚠️ On vérifie sur TOUTES les tables, pas sur un échantillon : un DELETE
--    oublié sur une seule table suffit à perdre une donnée.
SELECT t.doit_etre('`ava_app` n''a DELETE sur aucune table', 'M-8',
  -- ⚠️ `OFFSET 0` est une BARRIÈRE DE PLAN, pas une coquetterie : sans elle,
  --    PostgreSQL peut évaluer `has_table_privilege` avant le filtre sur le
  --    schéma, et lever sur une table système. ⭐ Trouvé par le codeur du
  --    lot 1 — son `004` et sa copie de `/test` avaient raison.
  NOT EXISTS (
    SELECT 1 FROM (
      SELECT tablename FROM pg_tables WHERE schemaname = 'ava' OFFSET 0
    ) AS n
    WHERE has_table_privilege('ava_app', 'ava.' || quote_ident(tablename), 'DELETE')));

-- ── M-9 · une action a exactement un porteur ──────────────────────────────
SELECT t.doit_refuser('une action sans porteur', 'M-9', $s$
  INSERT INTO action (type_code, contenu) VALUES ('note','orpheline')
$s$, 'ck_m9');

SELECT t.doit_refuser('une action à deux porteurs', 'M-9', $s$
  INSERT INTO action (type_code, contenu, societe_id, besoin_id)
  VALUES ('note','deux porteurs','50000000-0000-0000-0000-000000000001',
          'be000000-0000-0000-0000-000000000001')
$s$, 'ck_m9');

-- ── M-10 · un temps appartient à la ressource de la prestation ────────────
SELECT t.doit_refuser('un temps saisi pour une autre ressource', 'M-10', $s$
  INSERT INTO temps (prestation_id, profil_ressource_id, jour, quantite, saisi_par_compte_id)
  VALUES ('70000000-0000-0000-0000-000000000001',
          'd0000000-0000-0000-0000-000000000002','2026-03-02',1,
          'c0000000-0000-0000-0000-000000000001')
$s$, 'M-10');

-- ── M-11 · un besoin a toujours une société ───────────────────────────────
-- ⭐ Y compris le besoin de recrutement INTERNE : il pointe la société de
--    rôle `interne` (G6). C'est ce qui évite une colonne nullable et les
--    quatre requêtes cassées qui suivent toujours.
SELECT t.doit_refuser('un besoin sans société', 'M-11', $s$
  INSERT INTO besoin (agence_id, titre, etat_code)
  VALUES ('a0000000-0000-0000-0000-000000000001','Sans société','ouvert')
$s$, 'societe_id');

-- ── M-12 · la cohérence de société, et l'arbre ────────────────────────────
-- ⚠️ Sans ce mur, on propose au client A le contact du client B. Personne ne
--    s'en aperçoit avant l'envoi du mail.
SELECT t.doit_refuser('un contact d''une autre société sur un besoin', 'M-12', $s$
  UPDATE besoin SET contact_id = 'c1000000-0000-0000-0000-000000000002'
  WHERE id = 'be000000-0000-0000-0000-000000000001'
$s$, 'M-12');

SELECT t.doit_refuser('une unité qui est son propre parent', 'M-12', $s$
  INSERT INTO unite_organisation (id, societe_id, type_code, nom)
  VALUES ('c1e00000-0000-0000-0000-000000000009',
          '50000000-0000-0000-0000-000000000001','pole','Boucle');
  UPDATE unite_organisation SET parent_id = id
  WHERE id = 'c1e00000-0000-0000-0000-000000000009'
$s$, 'cycle');

-- ⭐ D-1 : une équipe de l'agence B ne pend pas d'un pôle de l'agence A —
--    sinon le périmètre de droits ne veut plus rien dire.
SELECT t.doit_refuser('une unité interne dont le parent est d''une autre agence', 'M-12', $s$
  INSERT INTO societe_role VALUES ('50000000-0000-0000-0000-000000000001','interne');
  INSERT INTO unite_organisation (id, societe_id, type_code, nom, agence_id)
  VALUES ('c1e00000-0000-0000-0000-000000000001','50000000-0000-0000-0000-000000000001',
          'pole','Pôle Casa','a0000000-0000-0000-0000-000000000001');
  INSERT INTO unite_organisation (societe_id, parent_id, type_code, nom, agence_id)
  VALUES ('50000000-0000-0000-0000-000000000001','c1e00000-0000-0000-0000-000000000001',
          'equipe','Équipe Rabat','a0000000-0000-0000-0000-000000000002')
$s$, 'agence');

-- ── M-13 · une permission n'existe jamais sans périmètre ──────────────────
-- ⭐ C'est ce qui empêche BM-42 : lecture sur B + écriture sur A NE DONNE PAS
--    écriture sur B. Une table à deux colonnes aurait laissé cette porte
--    ouverte, et personne ne l'aurait vue.
SELECT t.doit_etre('la paire droit × périmètre porte trois colonnes', 'M-13',
  (SELECT count(*) FROM information_schema.key_column_usage k
    JOIN information_schema.table_constraints c USING (constraint_name, table_schema)
   WHERE k.table_schema = 'ava' AND k.table_name = 'groupe_permission_perimetre'
     AND c.constraint_type = 'PRIMARY KEY') = 3
  AND (SELECT is_nullable FROM information_schema.columns
       WHERE table_schema = 'ava' AND table_name = 'groupe_permission_perimetre'
         AND column_name = 'perimetre_id') = 'NO');

-- ── M-14 · l'économie d'une mission engagée est figée ─────────────────────
-- ⭐ Une prévisionnelle se CORRIGE, une signée s'AVENANTE. Les deux gestes
--    existent ; ce sont deux gestes différents, et c'est tout l'enjeu.
SELECT t.doit_refuser('changer le TJM d''une prestation signée', 'M-14', $s$
  UPDATE prestation SET tjm_vendu = 999 WHERE id = '70000000-0000-0000-0000-000000000002'
$s$, 'M-14');

-- ⚠️ Le contre-test : sur une PRÉVISIONNELLE, le même geste doit PASSER.
--    ⛔ Sans lui, un mur trop large passerait pour un mur juste — et on aurait
--       figé ce qu'on voulait garder souple.
DO $$
BEGIN
  UPDATE prestation SET tjm_vendu = 550 WHERE id = '70000000-0000-0000-0000-000000000001';
  RAISE NOTICE 'OK   M-14 — corriger une prévisionnelle reste possible (contre-test)';
EXCEPTION WHEN OTHERS THEN
  RAISE EXCEPTION E'\n  ⛔ M-14 est TROP LARGE : une prévisionnelle ne se corrige plus.';
END $$;

-- ── M-15 · aucun montant sans devise, aucun agrégat multi-devises servi ───
SELECT t.doit_refuser('un montant sans sa devise', 'M-15', $s$
  UPDATE profil_candidat SET pretentions_montant = 450, pretentions_devise_code = NULL
  WHERE id = 'b0000000-0000-0000-0000-000000000001'
$s$, 'm15');

-- ⭐ La seconde moitié de M-15 : la SURFACE DE LECTURE. Le rôle d'agrégation
--    n'a pas les lignes — il ne PEUT pas additionner des euros et des
--    dirhams, même en essayant.
-- ⛔⛔ CORRIGÉ LE 20/09 — cette assertion ÉNUMÉRAIT trois tables. Elle passait
--    au vert pendant que le rôle lisait `v_conditions_du_jour`, qui expose
--    `tjm_vendu` et `cjm_contrat` ligne par ligne. **Le mur était percé et le
--    test disait OK.**
-- ⭐ LA LEÇON, et elle vaut pour toutes les autres : **un mur se teste par ce
--    qu'on peut ATTEINDRE, pas par une liste qu'on a écrite.** On n'énumère
--    plus ce qui est interdit — on exige que le permis soit EXACTEMENT les
--    quatre vues par devise, plus ce dont elles ont besoin pour se lire.
SELECT t.doit_etre('`ava_lecture_agregats` n''atteint QUE les 4 vues par devise', 'M-15',
  (SELECT count(*) FROM information_schema.role_table_grants
    WHERE grantee = 'ava_lecture_agregats'
      AND table_name NOT IN ('ref_devise','ref_pays','politique')) = 4
  AND t.droit('ava_lecture_agregats','v_marge_par_devise','SELECT')
  AND NOT t.droit('ava_lecture_agregats','v_conditions_du_jour','SELECT'));


-- ═══════════════════════════════════════════════════════════════════════════
--  §3 — LE COMPTE
--  ⛔ 22, et 22 exactement. Si ce nombre bouge, c'est qu'un mur a été ajouté
--     ou retiré — et ça ne se fait pas en silence : P3 a fixé quinze murs.
-- ═══════════════════════════════════════════════════════════════════════════

DO $$
BEGIN
  RAISE NOTICE E'\n  ⭐ 22 assertions passées, plus 1 contre-test sur M-14. Les 15 murs tiennent DANS LA BASE.\n';
END $$;

ROLLBACK;


-- ═══════════════════════════════════════════════════════════════════════════
--  §4 — CE QUE CES 22 ASSERTIONS NE COUVRENT PAS, ET OÙ ÇA SE VÉRIFIE
--
--  | Non couvert                    | Où ça se vérifie                      |
--  |--------------------------------|---------------------------------------|
--  | Les 167 politiques             | seed comparé au registre §C/§E        |
--  | Les 34 référentiels            | idem, et leurs catégories fermées     |
--  | Les 44 commandes               | **L4** — chaque contrat a ses cas     |
--  | La matrice des droits          | jeu de rôles, étape 8                 |
--  | Les formules ATL               | tests de calcul, versionnés           |
--  | L'apparence, les 86 clés `ui.*`| le mock fait foi                      |
--
--  ⚠️ CE QUI RESTE HORS DE PORTÉE D'UN TEST — la règle R-1 : un service qui
--     lit des lignes par le rôle transactionnel et les additionne lui-même.
--     ⛔ Aucune contrainte SQL ne l'attrape. C'est une règle de REVUE, et
--        c'est pour ça qu'elle est écrite ici : pour qu'on la cherche à l'œil
--        puisque la machine ne peut pas.
-- ═══════════════════════════════════════════════════════════════════════════
