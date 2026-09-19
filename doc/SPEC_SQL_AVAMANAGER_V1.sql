-- ═══════════════════════════════════════════════════════════════════════════
--  AVA MANAGER — LIVRABLE L3 : LE SCHÉMA, EN SQL COMMENTÉ
--  PostgreSQL 16+ · 19/09/2026 · source : _ops/MODELE_DONNEES_AVAMANAGER_V1.md
-- ═══════════════════════════════════════════════════════════════════════════
--
--  ⭐ CE QUE CE FICHIER EST
--  La spécification du schéma, écrite dans la seule langue qui ne se
--  paraphrase pas. Un développeur l'exécute, et il a les 37 tables, les 34
--  référentiels, les 167 politiques et — surtout — LES 15 MURS.
--
--  ⛔ CE QUE CE FICHIER N'EST PAS
--  Le produit. Aucune commande, aucun écran, aucune formule ATL n'est ici.
--  Les formules vivent dans le code et sont versionnées
--  (`snapshot_marge.version_atl`).
--
--  ⛔ ET IL NE S'EXÉCUTE PAS AVANT LA PORTE (§12 du modèle, G15)
--  Tant que `VALIDATION_MODELE_V1_<date>.md` n'existe pas, de la main
--  d'Ahmed : pas de migration.
--
-- ───────────────────────────────────────────────────────────────────────────
--  LES TROIS NATURES — ADR-005. Tout est ici, et rien n'est mélangé.
--
--   | Nature       | Où elle vit            | Qui la change        |
--   |--------------|------------------------|----------------------|
--   | MUR          | CHECK · trigger · GRANT| personne             |
--   | POLITIQUE    | table `politique`      | Admin, `SetPolicy`   |
--   | RÉFÉRENTIEL  | tables `ref_*`         | Admin, dans sa catég.|
--
--  ⛔ Un `if` métier écrit en dur dans le code est un refus en revue.
--  ⛔ Un mur écrit dans l'UI n'est pas un mur.
--
-- ───────────────────────────────────────────────────────────────────────────
--  ⭐ ADR-000 — UNE BASE = UNE SOCIÉTÉ
--  Il n'y a AUCUNE colonne `tenant_id` dans ce fichier, et c'est délibéré.
--  L'isolation se fait par la base, pas par un `WHERE` qu'on oublie une fois.
--  Avaliance a sa base ; la société suivante aura la sienne, avec ses
--  politiques et ses référentiels. Le code est le même, les données ne se
--  touchent jamais.
--  ⚠️ La relecture externe du 19/09 demandait un `tenant_id` : c'est le seul
--  point où on ne la suit pas, et c'est une décision, pas un oubli.
-- ═══════════════════════════════════════════════════════════════════════════


-- ═══════════════════════════════════════════════════════════════════════════
--  §0 — LE SOCLE
-- ═══════════════════════════════════════════════════════════════════════════

CREATE EXTENSION IF NOT EXISTS pgcrypto;    -- gen_random_uuid()
CREATE EXTENSION IF NOT EXISTS btree_gist;  -- l'EXCLUDE de `periode_emploi`

CREATE SCHEMA IF NOT EXISTS ava;
SET search_path = ava, public;

-- ⭐ Les montants : NUMERIC, jamais float. Un centime perdu à l'arrondi est
--    un centime qu'on ne retrouve pas dans la marge.
-- ⛔ Et JAMAIS un montant sans sa devise à côté — c'est le MUR M-15, qui se
--    lit dans chaque table plutôt que dans une règle qu'on se rappelle.


-- ═══════════════════════════════════════════════════════════════════════════
--  §1 — LES TROIS RÔLES SQL
--  ⭐ C'est ici que vivent M-6, M-7, M-8 et la moitié de M-15. Un mur qui
--     repose sur un trigger seul tombe le jour où quelqu'un a les droits ;
--     un mur qui repose sur un GRANT tient même contre une console ouverte.
-- ═══════════════════════════════════════════════════════════════════════════

-- Le rôle de l'application : il écrit le métier.
CREATE ROLE ava_app NOLOGIN;

-- Le rôle des agrégats : il ne voit QUE les vues par devise (§12, M-15).
-- ⛔ Il n'a pas accès à `prestation`, `temps`, `snapshot_marge`. C'est ce qui
--    empêche un service d'additionner deux devises lui-même (règle R-1).
CREATE ROLE ava_lecture_agregats NOLOGIN;

-- Le rôle de migration : il a tout, il ne sert QUE pendant une migration.
-- ⚠️ Aucun service applicatif ne se connecte avec celui-là. Jamais.
CREATE ROLE ava_migration NOLOGIN;

GRANT USAGE ON SCHEMA ava TO ava_app, ava_lecture_agregats;
GRANT ALL   ON SCHEMA ava TO ava_migration;

-- Les GRANT fins sont posés à la toute fin (§13) : ils portent sur des
-- tables qui n'existent pas encore.


-- ═══════════════════════════════════════════════════════════════════════════
--  §2 — LES 34 RÉFÉRENTIELS
--  ⭐ 27 métier + 7 techniques. Le compte fait foi au registre §E.
--
--  LA FORME COMMUNE — la même pour les 34, sans exception :
--    code      TEXT PK       stable, jamais renommé   (le code est l'ancre)
--    libelle   TEXT NOT NULL renommable par l'admin   (BM-49)
--    categorie TEXT NOT NULL FERMÉE par le code       (gardes et transitions)
--    ordre     INT           l'ordre d'affichage
--    systeme   BOOL          non supprimable, catégorie non modifiable
--    actif     BOOL          désactivable si non système
--
--  ⛔ LE CHECK PORTE SUR LA CATÉGORIE, JAMAIS SUR LE CODE.
--     C'est toute l'idée : Boond a 14 états de candidat, Avaliance en a 2 ;
--     les 14 entrent comme des codes dans `actif` ou `sorti`, et AUCUNE ligne
--     de code ne bouge. Un CHECK sur le code aurait rendu la reprise Boond
--     impossible sans migration.
-- ═══════════════════════════════════════════════════════════════════════════

-- Le gabarit, écrit en clair une fois, pour qu'on sache ce que la boucle fait.
CREATE TABLE ref_etat_besoin (
  code      TEXT PRIMARY KEY,
  libelle   TEXT NOT NULL,
  categorie TEXT NOT NULL,
  ordre     INT  NOT NULL DEFAULT 0,
  systeme   BOOL NOT NULL DEFAULT false,
  actif     BOOL NOT NULL DEFAULT true
);

-- Les 33 autres, à l'identique. ⭐ Une boucle plutôt que 33 copiés-collés :
--    elle DIT qu'il n'y a pas d'exception. Un copier-coller aurait fini par
--    en porter une.
DO $$
DECLARE t TEXT;
BEGIN
  FOREACH t IN ARRAY ARRAY[
    -- ── 26 métier (registre §B) ──────────────────────────────────────────
    'ref_etat_candidat', 'ref_etat_ressource', 'ref_etat_positionnement',
    'ref_etat_prestation', 'ref_etat_projet',
    'ref_role_societe', 'ref_statut_commercial', 'ref_type_ressource',
    'ref_priorite_besoin', 'ref_type_action', 'ref_etape_suivi_positionnement',
    'ref_type_qualification', 'ref_type_absence', 'ref_devise',
    'ref_competence', 'ref_motif_retrait', 'ref_unite_couverture',
    'ref_type_modele', 'ref_portee_modele', 'ref_gravite_alerte',
    'ref_motif_interruption', 'ref_motif_fin_emploi', 'ref_motif_avenant',
    'ref_couleur', 'ref_police', 'ref_outil',
    -- ── 7 techniques ─────────────────────────────────────────────────────
    'ref_civilite', 'ref_pays', 'ref_type_unite', 'ref_type_contact',
    'ref_type_mission', 'ref_type_document', 'ref_disponibilite'
  ] LOOP
    EXECUTE format($f$
      CREATE TABLE %I (
        code      TEXT PRIMARY KEY,
        libelle   TEXT NOT NULL,
        categorie TEXT NOT NULL,
        ordre     INT  NOT NULL DEFAULT 0,
        systeme   BOOL NOT NULL DEFAULT false,
        actif     BOOL NOT NULL DEFAULT true
      )$f$, t);
  END LOOP;
END $$;

-- ⭐ Les catégories fermées — les SEULES sur lesquelles le code raisonne.
--    Six cycles d'état (machines §1–6) + les listes à catégorie.
ALTER TABLE ref_etat_besoin        ADD CONSTRAINT ck_cat CHECK (categorie IN
  ('a_pourvoir','en_recherche','pourvu','suspendu','ferme'));
ALTER TABLE ref_etat_candidat      ADD CONSTRAINT ck_cat CHECK (categorie IN
  ('brouillon','actif','sorti'));
ALTER TABLE ref_etat_ressource     ADD CONSTRAINT ck_cat CHECK (categorie IN
  ('en_mission','disponible','sorti'));
ALTER TABLE ref_etat_positionnement ADD CONSTRAINT ck_cat CHECK (categorie IN
  ('propose','presente','terminal_positif','terminal_negatif','retire'));
ALTER TABLE ref_etat_prestation    ADD CONSTRAINT ck_cat CHECK (categorie IN
  ('previsionnel','engage','clos','annule'));
ALTER TABLE ref_etat_projet        ADD CONSTRAINT ck_cat CHECK (categorie IN
  ('ouvert','clos'));
ALTER TABLE ref_type_ressource     ADD CONSTRAINT ck_cat CHECK (categorie IN
  ('interne','externe'));
ALTER TABLE ref_type_absence       ADD CONSTRAINT ck_cat CHECK (categorie IN
  ('conge','maladie','autre'));
ALTER TABLE ref_type_unite         ADD CONSTRAINT ck_cat CHECK (categorie IN
  ('pole','bu','service','equipe'));
ALTER TABLE ref_gravite_alerte     ADD CONSTRAINT ck_cat CHECK (categorie = 'sens');
ALTER TABLE ref_couleur            ADD CONSTRAINT ck_cat CHECK (categorie IN
  ('marque','vert','chaud','froid','neutre','flashy'));
ALTER TABLE ref_police             ADD CONSTRAINT ck_cat CHECK (categorie IN
  ('chasse_fixe','proportionnelle'));
-- Les autres n'ont pas de catégorie fermée : leur `categorie` vaut 'defaut'.
-- ⚠️ Elle n'est pas facultative pour autant — une colonne sur laquelle aucune
--    garde ne s'appuie aujourd'hui peut en porter une demain, et on ne veut
--    pas d'une migration ce jour-là.

-- ── Les gardes de l'administration (ADR-005) ──────────────────────────────
-- ⛔ Une valeur système ne se supprime pas et ne change pas de catégorie.
-- ⛔ Une valeur utilisée ne se supprime pas — mais elle se DÉSACTIVE.
CREATE FUNCTION ref_garde() RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
  IF TG_OP = 'DELETE' THEN
    IF OLD.systeme THEN
      RAISE EXCEPTION 'Valeur système : elle se désactive, elle ne se supprime pas (%.%)',
        TG_TABLE_NAME, OLD.code;
    END IF;
    RETURN OLD;
  END IF;
  IF OLD.systeme AND NEW.categorie <> OLD.categorie THEN
    RAISE EXCEPTION 'La catégorie d''une valeur système est figée (%.%)',
      TG_TABLE_NAME, OLD.code;
  END IF;
  IF NEW.code <> OLD.code THEN
    RAISE EXCEPTION 'Le code d''un référentiel ne se renomme pas — c''est le libellé qui change';
  END IF;
  RETURN NEW;
END $$;

DO $$
DECLARE t TEXT;
BEGIN
  FOR t IN SELECT tablename FROM pg_tables
           WHERE schemaname = 'ava' AND tablename LIKE 'ref_%' LOOP
    EXECUTE format(
      'CREATE TRIGGER tg_garde BEFORE UPDATE OR DELETE ON %I
         FOR EACH ROW EXECUTE FUNCTION ref_garde()', t);
  END LOOP;
END $$;


-- ═══════════════════════════════════════════════════════════════════════════
--  §3 — `politique` : LES 167 BIFURCATIONS (ADR-005, modèle §6.2)
--  ⭐ 79 métier · 2 installation · 86 apparence. Le compte fait foi au
--     registre §E, et NULLE PART AILLEURS.
--  ⛔ Jamais dans un fichier de config, jamais dans une variable
--     d'environnement : ce qui se règle se règle dans l'écran Administration,
--     et se trace dans `evenement_metier`.
-- ═══════════════════════════════════════════════════════════════════════════

CREATE TABLE politique (
  cle                    TEXT PRIMARY KEY,   -- `besoin.contact`, `ui.encre.t1`…
  valeur                 TEXT NOT NULL,      -- ce qui s'applique aujourd'hui
  valeur_defaut          TEXT NOT NULL,      -- la décision du 17/09
  type                   TEXT NOT NULL
    CHECK (type IN ('enum','int','bool','list','decimal','couleur','texte')),
  valeurs_possibles      JSONB,              -- NULL si type libre
  categorie              TEXT NOT NULL
    CHECK (categorie IN ('metier','installation','apparence')),
  libelle                TEXT NOT NULL,
  description            TEXT,
  source                 TEXT,               -- « F3 », « G4 », « DEC-06 »
  hors_v1                BOOL NOT NULL DEFAULT false,
  mur_touche             TEXT,               -- ⭐ voir juste dessous
  modifie_le             TIMESTAMPTZ,
  modifie_par_compte_id  UUID,
  CHECK (type <> 'enum' OR valeurs_possibles IS NOT NULL)
);

-- ⭐ `mur_touche` — LA COLONNE QUI MANQUAIT (constat du plan, 0-TER).
--    Une politique dit où elle s'arrête : « je peux relâcher ceci, mais pas
--    au-delà de M-13 ». Sans elle, un admin de bonne foi peut régler une
--    politique jusqu'à un état que la base refusera, et il ne le découvrira
--    qu'à l'exécution, sur un refus incompréhensible.
--    ⛔ Elle est INDICATIVE pour l'écran, jamais pour la garde : c'est le mur
--       qui refuse, pas cette colonne.
COMMENT ON COLUMN politique.mur_touche IS
  'M-13, M-15… le mur que cette politique ne peut pas franchir. Sert à l''écran d''administration : il grise les valeurs impossibles au lieu de les laisser choisir puis échouer.';

-- ⛔ Une politique ne se supprime pas et ne change pas de clé : elle se
--    règle. Supprimer une clé, c'est perdre la trace de ce qui était réglé.
CREATE FUNCTION politique_garde() RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
  IF TG_OP = 'DELETE' THEN
    RAISE EXCEPTION 'Une politique ne se supprime pas (%). Elle revient à son défaut.', OLD.cle;
  END IF;
  IF NEW.cle <> OLD.cle THEN
    RAISE EXCEPTION 'La clé d''une politique est son identité : elle ne se renomme pas';
  END IF;
  NEW.modifie_le := now();
  RETURN NEW;
END $$;
CREATE TRIGGER tg_garde BEFORE UPDATE OR DELETE ON politique
  FOR EACH ROW EXECUTE FUNCTION politique_garde();

-- ⭐ LE LECTEUR. Une seule porte, et elle sert à tout le monde.
--    Le développeur n'écrit jamais `SELECT valeur FROM politique WHERE…` à la
--    main : il appelle ceci. C'est ce qui rend possible d'auditer, un jour,
--    quelles clés sont réellement lues.
CREATE FUNCTION pol(p_cle TEXT) RETURNS TEXT LANGUAGE plpgsql STABLE AS $$
DECLARE v TEXT;
BEGIN
  SELECT valeur INTO v FROM politique WHERE cle = p_cle;
  IF NOT FOUND THEN
    -- ⛔ Une clé absente est un BUG, pas un défaut silencieux. Un `COALESCE`
    --    ici aurait laissé passer une faute de frappe pendant des mois.
    RAISE EXCEPTION 'Politique inconnue : %. Toute bifurcation est déclarée au registre §C.', p_cle;
  END IF;
  RETURN v;
END $$;

CREATE FUNCTION pol_bool(p_cle TEXT) RETURNS BOOL LANGUAGE sql STABLE AS
  $$ SELECT pol(p_cle) IN ('oui','true','1') $$;
CREATE FUNCTION pol_num(p_cle TEXT) RETURNS NUMERIC LANGUAGE sql STABLE AS
  $$ SELECT pol(p_cle)::numeric $$;


-- ═══════════════════════════════════════════════════════════════════════════
--  §4 — LES FONCTIONS PARTAGÉES
--  ⭐ Quatre gestes qui reviennent partout. Écrits une fois : une règle
--     recopiée douze fois finit par différer à la douzième.
-- ═══════════════════════════════════════════════════════════════════════════

-- ── P-1 : `etat_categorie` suit le référentiel, toujours ───────────────────
-- ⭐ La colonne est redondante, et c'est voulu : gardes, vues et index
--    raisonnent sur la CATÉGORIE. Sans elle, chaque garde ferait une jointure
--    et on finirait par en oublier une.
-- ⛔ Elle ne se saisit jamais : le trigger l'écrit depuis `ref_etat_<objet>`.
CREATE FUNCTION maj_etat_categorie() RETURNS TRIGGER LANGUAGE plpgsql AS $$
DECLARE c TEXT;
BEGIN
  EXECUTE format('SELECT categorie FROM %I WHERE code = $1', TG_ARGV[0])
    INTO c USING NEW.etat_code;
  IF c IS NULL THEN
    RAISE EXCEPTION 'État inconnu « % » dans %', NEW.etat_code, TG_ARGV[0];
  END IF;
  NEW.etat_categorie := c;
  RETURN NEW;
END $$;

-- ── M-7 / M-6 / prestation_version : l'AJOUT SEUL ──────────────────────────
-- ⛔ Une erreur de saisie se corrige par une ligne de plus, jamais en
--    réécrivant celle d'avant. Le trigger double le GRANT : le GRANT protège
--    du service, le trigger protège de la console ouverte un soir.
CREATE FUNCTION ajout_seul() RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
  RAISE EXCEPTION '% est en ajout seul (%). Ce qui est écrit reste écrit.',
    TG_TABLE_NAME, TG_ARGV[0];
END $$;

-- ── M-12 : la cohérence de société ─────────────────────────────────────────
-- ⭐ Le contact d'un besoin appartient à la société de ce besoin. Sans ce
--    trigger, on propose au client A le contact du client B — et personne ne
--    s'en aperçoit avant l'envoi du mail.
CREATE FUNCTION verifie_meme_societe() RETURNS TRIGGER LANGUAGE plpgsql AS $$
DECLARE
  col TEXT; tbl TEXT; id_ref UUID; soc UUID; i INT;
BEGIN
  FOR i IN 1 .. array_length(TG_ARGV, 1) BY 2 LOOP
    col := TG_ARGV[i - 1]; tbl := TG_ARGV[i];
    EXECUTE format('SELECT ($1).%I', col) INTO id_ref USING NEW;
    CONTINUE WHEN id_ref IS NULL;
    EXECUTE format('SELECT societe_id FROM %I WHERE id = $1', tbl)
      INTO soc USING id_ref;
    IF soc IS DISTINCT FROM NEW.societe_id THEN
      RAISE EXCEPTION 'MUR M-12 : %.% appartient à une autre société que %',
        TG_TABLE_NAME, col, NEW.societe_id;
    END IF;
  END LOOP;
  RETURN NEW;
END $$;

-- ── M-15 : un montant a toujours sa devise ─────────────────────────────────
-- ⭐ Écrite en fonction pour que le CHECK se LISE. « Les deux nuls ou les
--    deux pleins » — jamais un montant orphelin dont on devine la monnaie.
CREATE FUNCTION paire_montant(m NUMERIC, d TEXT) RETURNS BOOL
  LANGUAGE sql IMMUTABLE AS $$ SELECT (m IS NULL) = (d IS NULL) $$;


-- ═══════════════════════════════════════════════════════════════════════════
--  §5 — STRUCTURE ET COMPTES
--  ⚠️ En premier parce que tout le reste les référence.
-- ═══════════════════════════════════════════════════════════════════════════

-- ── `agence` : un site, un calendrier, un pays ─────────────────────────────
-- ⛔ PAS de `perimetre_id` (D-1). C'est `perimetre` qui pointe l'agence,
--    jamais l'inverse : le premier tirage avait les deux, donc un cycle.
CREATE TABLE agence (
  id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  nom        TEXT NOT NULL,
  code       TEXT NOT NULL UNIQUE,
  pays_code  TEXT NOT NULL REFERENCES ref_pays(code)
);

-- ── `calendrier_jour_non_ouvre` : la capacité ──────────────────────────────
-- ⭐ Sans cette table, ATL-01, ATL-02, ATL-04 et ATL-09 sont INCALCULABLES.
--    C'était l'objet manquant n° 2 de l'audit du 17/09.
--    POL `capacite.source` (défaut : le calendrier d'agence).
CREATE TABLE calendrier_jour_non_ouvre (
  agence_id  UUID NOT NULL REFERENCES agence(id),
  jour       DATE NOT NULL,
  motif      TEXT NOT NULL CHECK (motif IN ('week_end','ferie','fermeture')),
  PRIMARY KEY (agence_id, jour)
);

-- ── `compte` : l'utilisateur ───────────────────────────────────────────────
-- ⚠️ `personne_id` n'a pas encore sa FK : `personne` n'existe pas à cette
--    ligne. Elle est posée au §11. C'est la seule référence différée du
--    fichier, et elle est différée parce que les deux tables se pointent.
CREATE TABLE compte (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email       TEXT NOT NULL UNIQUE,
  personne_id UUID,                  -- FK ajoutée au §12
  actif       BOOL NOT NULL DEFAULT true,
  agence_id   UUID NOT NULL REFERENCES agence(id),
  -- ⭐ Les réglages d'apparence de CETTE personne. NULL ou clé absente = la
  --    valeur de l'installation. Ignoré si POL `ui.theme.choix_utilisateur`
  --    vaut `non`. Catalogue : THEMES_v1.md.
  -- ⛔ Aucune règle métier ne lit ce JSONB. Il porte de l'apparence, et rien
  --    d'autre — sinon on aurait remis du métier hors du registre.
  theme_json  JSONB
);

-- ⭐ `compte.personne_id` est ce qui rend VÉRIFIABLE le « S » (soi-même) de
--    la matrice des droits : Jean saisit SES temps. C'était l'objet manquant
--    n° 3 de l'audit.


-- ═══════════════════════════════════════════════════════════════════════════
--  §6 — IDENTITÉ
-- ═══════════════════════════════════════════════════════════════════════════

-- ── `personne` : l'humain, UNE FOIS (DEC-01) ───────────────────────────────
CREATE TABLE personne (
  id             UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  civilite       TEXT REFERENCES ref_civilite(code),
  nom            TEXT NOT NULL,
  prenom         TEXT NOT NULL,
  date_naissance DATE,
  -- ⛔ PAS d'UNIQUE sur l'email. POL `doublon.personne.*` : on AVERTIT,
  --    on ne bloque jamais (F20). Deux vraies personnes partagent une boîte
  --    familiale ; une contrainte les aurait déclarées identiques.
  email          TEXT,
  -- ⚠️ Format international, PAS 10 chiffres. La SPEC US1 disait « Adresse »
  --    de type e-mail et « Code postal » numérique : deux erreurs de tableau,
  --    corrigées ici (BM-58). Un code postal est TEXTUEL — zéro initial,
  --    alphanumérique au Royaume-Uni, au Canada, aux Pays-Bas.
  telephone      TEXT,
  adresse        TEXT,
  code_postal    TEXT,
  ville          TEXT,
  pays_code      TEXT REFERENCES ref_pays(code),
  linkedin_url   TEXT,
  archive_le            TIMESTAMPTZ,          -- MUR M-8
  archive_par_compte_id UUID REFERENCES compte(id)
);

-- Ces trois index servent la DÉTECTION de doublons, pas le blocage.
CREATE INDEX ix_personne_nom   ON personne (nom, prenom);
CREATE INDEX ix_personne_email ON personne (lower(email));
CREATE INDEX ix_personne_naiss ON personne (date_naissance);

-- ── `profil_candidat` : le vivier (DEC-01/02, F19) ─────────────────────────
CREATE TABLE profil_candidat (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  -- ⛔ MUR M-3 : UN SEUL profil candidat par personne.
  personne_id     UUID NOT NULL UNIQUE REFERENCES personne(id),
  etat_code       TEXT NOT NULL REFERENCES ref_etat_candidat(code),
  etat_categorie  TEXT NOT NULL,                       -- écrite par trigger
  titre           TEXT NOT NULL,
  provenance      TEXT,
  precisez        TEXT,
  disponibilite_code TEXT REFERENCES ref_disponibilite(code),
  mobilite        TEXT,
  pretentions_montant     NUMERIC(14,2),
  pretentions_devise_code TEXT REFERENCES ref_devise(code),
  manager_compte_id UUID REFERENCES compte(id),
  rh_compte_id      UUID REFERENCES compte(id),
  agence_id         UUID REFERENCES agence(id),
  commentaire       TEXT,
  -- Cloisonnement vu à l'audit Boond 06 : un profil qu'un seul voit.
  visible_uniquement_par_compte_id UUID REFERENCES compte(id),
  archive_le            TIMESTAMPTZ,
  archive_par_compte_id UUID REFERENCES compte(id),
  CONSTRAINT ck_pretentions_m15
    CHECK (paire_montant(pretentions_montant, pretentions_devise_code))
);
CREATE TRIGGER tg_cat BEFORE INSERT OR UPDATE ON profil_candidat
  FOR EACH ROW EXECUTE FUNCTION maj_etat_categorie('ref_etat_candidat');

-- ⚠️ La garde de `CompleteCandidate` n'est PAS ici. Elle lit
--    POL `candidat.complete.champs_requis` — une liste de noms de colonnes.
--    Un CHECK figé aurait gelé ce que chaque société considère comme
--    « complet », et c'est justement ce qui varie d'une société à l'autre.

-- ── `profil_ressource` : qui peut travailler (DEC-01/02/12, US1, F26) ──────
CREATE TABLE profil_ressource (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  personne_id     UUID NOT NULL UNIQUE REFERENCES personne(id),   -- MUR M-3
  type_code       TEXT NOT NULL REFERENCES ref_type_ressource(code),
  etat_code       TEXT NOT NULL REFERENCES ref_etat_ressource(code),
  etat_categorie  TEXT NOT NULL,
  titre           TEXT NOT NULL,
  agence_id       UUID NOT NULL REFERENCES agence(id),
  societe_fournisseur_id UUID,                          -- FK posée au §12
  -- ⭐ DONNÉE SENSIBLE : permission séparée dans la matrice des droits.
  cout_reference          NUMERIC(14,2),
  cout_reference_devise_code TEXT REFERENCES ref_devise(code),
  tjm_indicatif           NUMERIC(14,2),
  tjm_indicatif_devise_code TEXT REFERENCES ref_devise(code),
  disponibilite_code TEXT REFERENCES ref_disponibilite(code),
  mobilite           TEXT,
  manager_compte_id  UUID REFERENCES compte(id),
  rh_compte_id       UUID REFERENCES compte(id),
  archive_le            TIMESTAMPTZ,
  archive_par_compte_id UUID REFERENCES compte(id),
  CONSTRAINT ck_cout_m15 CHECK (paire_montant(cout_reference, cout_reference_devise_code)),
  CONSTRAINT ck_tjm_m15  CHECK (paire_montant(tjm_indicatif, tjm_indicatif_devise_code))
);
CREATE TRIGGER tg_cat BEFORE INSERT OR UPDATE ON profil_ressource
  FOR EACH ROW EXECUTE FUNCTION maj_etat_categorie('ref_etat_ressource');

-- ⚠️ « Un externe a forcément un fournisseur » N'EST PAS UN CHECK.
--    C'est POL `ressource.externe.societe_fournisseur` (défaut obligatoire,
--    DEC-12), appliquée par la COMMANDE. Un CHECK aurait figé la politique :
--    la relâcher serait devenu une migration — exactement ce qu'ADR-005
--    interdit. En base, un simple index.
CREATE INDEX ix_ressource_fournisseur
  ON profil_ressource (type_code, societe_fournisseur_id);

-- ── `periode_emploi` : PARTIR ET REVENIR (M15, 19/09) ──────────────────────
-- ⭐ Une personne qui part et revient reste UNE personne. Deux contrats, deux
--    coûts, deux périodes — jamais deux fiches. Sans cette table, le second
--    passage écrasait le premier ou créait un doublon ; les deux sont faux.
CREATE TABLE periode_emploi (
  profil_ressource_id UUID NOT NULL REFERENCES profil_ressource(id),
  debut               DATE NOT NULL,
  fin                 DATE,            -- NULL = en cours
  type_code           TEXT NOT NULL REFERENCES ref_type_ressource(code),
  -- ⭐ M7 : l'agence DE CETTE PÉRIODE, pas celle d'aujourd'hui.
  agence_id           UUID NOT NULL REFERENCES agence(id),
  societe_fournisseur_id UUID,          -- FK posée au §12
  cout_reference          NUMERIC(14,2),
  cout_reference_devise_code TEXT REFERENCES ref_devise(code),
  motif_fin_code      TEXT REFERENCES ref_motif_fin_emploi(code),
  PRIMARY KEY (profil_ressource_id, debut),
  CHECK (fin IS NULL OR fin >= debut),
  CONSTRAINT ck_cout_m15 CHECK (paire_montant(cout_reference, cout_reference_devise_code)),
  -- ⛔ AUCUN CHEVAUCHEMENT. Une personne n'a pas deux emplois le même jour
  --    chez le même employeur. `daterange` avec fin NULL = borne infinie.
  EXCLUDE USING gist (
    profil_ressource_id WITH =,
    daterange(debut, fin, '[]') WITH &&
  )
);

-- ⛔ Une période CLOSE ne se modifie plus. On en ouvre une autre.
CREATE FUNCTION periode_close_figee() RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
  IF OLD.fin IS NOT NULL THEN
    RAISE EXCEPTION 'Période close au % : elle ne se modifie plus. Ouvrez-en une nouvelle.', OLD.fin;
  END IF;
  RETURN NEW;
END $$;
CREATE TRIGGER tg_close BEFORE UPDATE ON periode_emploi
  FOR EACH ROW EXECUTE FUNCTION periode_close_figee();

-- ⚠️ CE QUE ÇA NE CHANGE PAS : `profil_ressource` garde ses colonnes — elles
--    décrivent L'ÉTAT COURANT. Cette table dit L'HISTOIRE.
-- ⛔ Et M-14 tient : les conditions d'une mission ne lisent JAMAIS cette
--    table. Elles sont figées sur la prestation.

-- ── `document` : CV, DT, pièce ─────────────────────────────────────────────
CREATE TABLE document (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  type_code     TEXT NOT NULL REFERENCES ref_type_document(code),
  -- ⭐ Cinq FK nullables, EXACTEMENT UNE non nulle — le patron de `action`.
  -- ⛔ Plus de `porteur_type / porteur_id` : une référence sans FK peut
  --    pointer dans le vide, et on ne s'en aperçoit qu'à l'affichage.
  personne_id          UUID REFERENCES personne(id),
  profil_candidat_id   UUID REFERENCES profil_candidat(id),
  profil_ressource_id  UUID REFERENCES profil_ressource(id),
  projet_id            UUID,                  -- FK posée au §12
  societe_id           UUID,                  -- FK posée au §12
  nom_fichier   TEXT NOT NULL,
  -- ⭐ Les FICHIERS vivent hors base (disque ou objet). La table porte le
  --    chemin et l'empreinte. Une base qui grossit de CV est une base qu'on
  --    ne sauvegarde plus — et on ne le découvre qu'au moment de restaurer.
  chemin_stockage TEXT NOT NULL,
  mime          TEXT,
  taille_octets BIGINT,
  sha256        TEXT,
  archive_le            TIMESTAMPTZ,
  archive_par_compte_id UUID REFERENCES compte(id),
  CONSTRAINT ck_un_porteur CHECK (
    (personne_id IS NOT NULL)::int + (profil_candidat_id IS NOT NULL)::int
  + (profil_ressource_id IS NOT NULL)::int + (projet_id IS NOT NULL)::int
  + (societe_id IS NOT NULL)::int = 1)
);


-- ═══════════════════════════════════════════════════════════════════════════
--  §7 — CLIENT
-- ═══════════════════════════════════════════════════════════════════════════

-- ── `societe` (BM-11, G6) ──────────────────────────────────────────────────
-- ⭐ RÔLE ≠ STATUT (D-3). Un rôle est une capacité durable (fournir des
--    ressources, être Avaliance elle-même). Le statut commercial est la
--    position dans la relation : prospect ou client, UNE colonne, UN cycle.
-- ⛔ `client` et `prospect` NE SONT PAS des rôles. Une société cliente ET
--    fournisseuse = statut `client` + rôle `fournisseur`, sans duplication.
--    Le simulateur avait fait les deux à la fois : c'est exactement la
--    divergence que cette ligne interdit.
CREATE TABLE societe (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  nom           TEXT NOT NULL,
  nom_normalise TEXT NOT NULL,        -- détection de doublons, pas blocage
  siren         TEXT,
  secteur       TEXT,
  adresse TEXT, code_postal TEXT, ville TEXT,
  pays_code     TEXT REFERENCES ref_pays(code),
  telephone TEXT, site_web TEXT,
  manager_compte_id UUID REFERENCES compte(id),
  statut_commercial_code TEXT NOT NULL REFERENCES ref_statut_commercial(code),
  archive_le            TIMESTAMPTZ,
  archive_par_compte_id UUID REFERENCES compte(id)
);
CREATE INDEX ix_societe_norm ON societe (nom_normalise);

CREATE TABLE societe_role (
  societe_id UUID NOT NULL REFERENCES societe(id),
  role_code  TEXT NOT NULL REFERENCES ref_role_societe(code),  -- fournisseur|interne
  PRIMARY KEY (societe_id, role_code)
);

-- ⭐ Le rôle `interne` porte Avaliance elle-même (G6). C'est ce qui permet le
--    besoin de recrutement sur profil SANS casser `besoin.societe_id NOT NULL`
--    (MUR M-11) : le besoin interne pointe la société de rôle `interne`.

-- ── `unite_organisation` (BM-12, D-1) ──────────────────────────────────────
-- ⭐ C'EST AUSSI L'ARBRE INTERNE. Les pôles et équipes d'Avaliance sont des
--    unités de la société de rôle `interne`. Il n'y a QU'UNE hiérarchie
--    d'unités dans la base ; ce qui distingue l'interne du client, c'est le
--    rôle de la société porteuse — pas une seconde table.
CREATE TABLE unite_organisation (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  societe_id  UUID NOT NULL REFERENCES societe(id),
  parent_id   UUID REFERENCES unite_organisation(id),
  type_code   TEXT NOT NULL REFERENCES ref_type_unite(code),
  nom         TEXT NOT NULL,
  description TEXT,
  -- D-2 : NULL = `prospect`, JAMAIS « hérite ». Hériter ferait passer client
  -- les branches sœurs, contraire à BM-15.
  statut_commercial_code TEXT REFERENCES ref_statut_commercial(code),
  -- D-1 : une agence est un SITE ; un pôle est une organisation À
  -- L'INTÉRIEUR d'une agence. NOT NULL si la société est interne (trigger).
  agence_id   UUID REFERENCES agence(id),
  archive_le            TIMESTAMPTZ,
  archive_par_compte_id UUID REFERENCES compte(id)
);

-- ── `contact` (BM-13, F22) ─────────────────────────────────────────────────
-- ⚠️ AUCUN lien vers `personne` — F22 : deux objets distincts en V1. Le jour
--    où on les rapproche, ce sera une ADR et une colonne, pas une fusion
--    silencieuse.
CREATE TABLE contact (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  societe_id  UUID NOT NULL REFERENCES societe(id),           -- MUR M-12
  unite_organisation_id UUID REFERENCES unite_organisation(id),
  civilite    TEXT REFERENCES ref_civilite(code),
  nom         TEXT NOT NULL,
  prenom      TEXT,
  fonction    TEXT,
  type_code   TEXT REFERENCES ref_type_contact(code),
  statut_code TEXT NOT NULL DEFAULT 'actif' CHECK (statut_code IN ('actif','parti')),
  statut_commercial_code TEXT REFERENCES ref_statut_commercial(code),  -- D-2
  email TEXT, telephone TEXT,
  manager_compte_id UUID REFERENCES compte(id),
  archive_le            TIMESTAMPTZ,
  archive_par_compte_id UUID REFERENCES compte(id)
);


-- ═══════════════════════════════════════════════════════════════════════════
--  §8 — STAFFING
-- ═══════════════════════════════════════════════════════════════════════════

-- ── `besoin` (DEC-04/05/13, F3, G4, G6) ────────────────────────────────────
CREATE TABLE besoin (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  -- ⛔ MUR M-11 : un besoin a TOUJOURS une société. Le besoin de recrutement
  --    interne pointe la société de rôle `interne` (G6).
  societe_id  UUID NOT NULL REFERENCES societe(id),
  -- POL `besoin.contact` (défaut facultatif, DEC-04) — NULL en base.
  contact_id  UUID REFERENCES contact(id),
  unite_organisation_id UUID REFERENCES unite_organisation(id),
  agence_id   UUID NOT NULL REFERENCES agence(id),   -- l'agence qui traite
  titre       TEXT NOT NULL,
  contexte    TEXT,
  reference_ao TEXT,
  type_code   TEXT REFERENCES ref_type_mission(code),        -- regie | forfait
  etat_code      TEXT NOT NULL REFERENCES ref_etat_besoin(code),
  etat_categorie TEXT NOT NULL,
  -- ⭐ La priorité est une DIMENSION INDÉPENDANTE de l'état (DEC-13). Un
  --    besoin suspendu peut rester P1 ; les mélanger, c'est perdre l'un ou
  --    l'autre à la première transition.
  priorite_code TEXT REFERENCES ref_priorite_besoin(code),
  nb_postes_vises INT NOT NULL DEFAULT 1 CHECK (nb_postes_vises >= 1),
  -- ⭐ B-1, 19/09 — CE QUI SATISFAIT LE BESOIN : des postes, une charge, ou
  --    les deux. Le trou que ça bouche : « deux missions = deux postes » est
  --    FAUX. Deux personnes à 50 % font UNE charge pleine et DEUX postes.
  --    ⚠️ Le défaut Avaliance ne bouge pas : `postes`.
  unite_couverture_code TEXT NOT NULL DEFAULT 'postes'
    REFERENCES ref_unite_couverture(code),
  fte_vise    NUMERIC(6,2) CHECK (fte_vise > 0),
  date_demarrage_souhaitee DATE,
  budget      NUMERIC(14,2),
  budget_devise_code TEXT REFERENCES ref_devise(code),
  ponderation_pct NUMERIC(5,2),      -- ATL-11 : CA pondéré = budget × pond.
  manager_compte_id UUID REFERENCES compte(id),
  archive_le            TIMESTAMPTZ,
  archive_par_compte_id UUID REFERENCES compte(id),
  CONSTRAINT ck_budget_m15 CHECK (paire_montant(budget, budget_devise_code))
);
CREATE TRIGGER tg_cat BEFORE INSERT OR UPDATE ON besoin
  FOR EACH ROW EXECUTE FUNCTION maj_etat_categorie('ref_etat_besoin');

-- `fte_vise` est exigé dès que la couverture parle de charge, interdit sinon.
CREATE FUNCTION besoin_couverture() RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
  IF NEW.unite_couverture_code IN ('fte','postes_et_fte') THEN
    IF NEW.fte_vise IS NULL THEN
      RAISE EXCEPTION 'Couverture « % » : la charge visée (FTE) est requise.',
        NEW.unite_couverture_code;
    END IF;
  ELSIF NEW.fte_vise IS NOT NULL THEN
    RAISE EXCEPTION 'Couverture « postes » : pas de charge visée. Choisissez `fte` ou `postes_et_fte`.';
  END IF;
  RETURN NEW;
END $$;
CREATE TRIGGER tg_couv BEFORE INSERT OR UPDATE ON besoin
  FOR EACH ROW EXECUTE FUNCTION besoin_couverture();

-- ⚠️ LA GARDE DE `DeclareNeedFilled` N'EST PAS EN BASE. Elle lit
--    POL `besoin.pourvu.garde_minimale` ET `unite_couverture_code` :
--      postes         → count(prestations engagées) >= nb_postes_vises
--      fte            → sum(taux_occupation_pct)/100 >= fte_vise
--      postes_et_fte  → les deux à la fois
--    Le périmètre : les prestations de catégorie `engage` des projets de ce
--    besoin. La vue ci-dessous la rend calculable en une ligne.
CREATE TABLE besoin_competence (
  besoin_id       UUID NOT NULL REFERENCES besoin(id),
  competence_code TEXT NOT NULL REFERENCES ref_competence(code),
  niveau_requis   INT,
  obligatoire     BOOL NOT NULL DEFAULT false,
  PRIMARY KEY (besoin_id, competence_code)
);

-- ── `positionnement` (DEC-03, G1, G2, G7, G10) ─────────────────────────────
CREATE TABLE positionnement (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  besoin_id   UUID NOT NULL REFERENCES besoin(id),
  profil_candidat_id  UUID REFERENCES profil_candidat(id),
  profil_ressource_id UUID REFERENCES profil_ressource(id),
  -- ⭐ DÉNORMALISÉ, écrit par trigger. C'est ce qui rend la garde G1 lisible
  --    en UNE jointure — « un positionnement terminal_positif dont la
  --    personne a un profil ressource actif » — sans savoir si le
  --    positionnement était candidat ou ressource.
  -- ⛔ B-004, 20/09 — PAS de NOT NULL, et c'est un piège qu'il faut nommer.
  --    `tg_pers` écrit cette colonne depuis le profil ; quand aucun profil
  --    n'est donné, il écrit NULL — et PostgreSQL lève le NOT NULL AVANT
  --    d'évaluer `ck_m2_xor`. Le refus venait du mauvais mur, avec le mauvais
  --    message. ⭐ Trouvé par le codeur du lot 1, pas par moi.
  personne_id UUID REFERENCES personne(id),
  etat_code      TEXT NOT NULL REFERENCES ref_etat_positionnement(code),
  etat_categorie TEXT NOT NULL,
  tjm_propose    NUMERIC(14,2),
  tjm_propose_devise_code TEXT REFERENCES ref_devise(code),
  decision_client_le DATE,           -- G2 : l'ÉTAT porte la décision
  archive_le            TIMESTAMPTZ,
  archive_par_compte_id UUID REFERENCES compte(id),
  -- ⛔ MUR M-2 : candidat XOR ressource. Jamais les deux, jamais aucun.
  CONSTRAINT ck_m2_xor CHECK (
    (profil_candidat_id IS NULL) <> (profil_ressource_id IS NULL)),
  CONSTRAINT ck_tjm_m15 CHECK (paire_montant(tjm_propose, tjm_propose_devise_code))
);
CREATE TRIGGER tg_cat BEFORE INSERT OR UPDATE ON positionnement
  FOR EACH ROW EXECUTE FUNCTION maj_etat_categorie('ref_etat_positionnement');

CREATE FUNCTION positionnement_personne() RETURNS TRIGGER LANGUAGE plpgsql AS $$
DECLARE p UUID;
BEGIN
  IF TG_OP = 'INSERT' THEN
    IF NEW.profil_candidat_id IS NOT NULL THEN
      SELECT personne_id INTO p FROM profil_candidat WHERE id = NEW.profil_candidat_id;
    ELSE
      SELECT personne_id INTO p FROM profil_ressource WHERE id = NEW.profil_ressource_id;
    END IF;
    NEW.personne_id := p;
  ELSIF NEW.personne_id IS DISTINCT FROM OLD.personne_id THEN
    RAISE EXCEPTION 'La personne d''un positionnement ne change pas. Retirez-le et repositionnez.';
  END IF;
  RETURN NEW;
END $$;
CREATE TRIGGER tg_pers BEFORE INSERT OR UPDATE ON positionnement
  FOR EACH ROW EXECUTE FUNCTION positionnement_personne();

-- ⛔ PAS D'INDEX UNIQUE PARTIEL ICI, et c'est réfléchi.
--    L'unicité est POL `positionnement.unicite` (défaut `actifs`), lue à
--    l'exécution. Un index unique aurait FIGÉ l'option `actifs` : changer la
--    politique serait devenu une migration — contraire à ADR-005. Si
--    l'unicité devait un jour être garantie par la base, ce serait un mur
--    M-16, et les options `aucune`/`historique` sortiraient du registre.
--    P3 a fixé quinze murs.
CREATE INDEX ix_pos_besoin_personne ON positionnement (besoin_id, personne_id);

CREATE TABLE positionnement_suivi (
  positionnement_id UUID NOT NULL REFERENCES positionnement(id),
  etape_code  TEXT NOT NULL REFERENCES ref_etape_suivi_positionnement(code),
  statut      TEXT,
  date        DATE,
  commentaire TEXT,
  PRIMARY KEY (positionnement_id, etape_code)
);
-- ⭐ L'étape `cv_partage` est SYSTÈME : retirable d'un dossier, jamais du
--    catalogue (BM-23). C'est le fait qui déclenche `presente`.

-- ⚠️ LES MOTIFS DE TRANSITION (P-5) — refus client, retrait, suspension —
--    vivent dans `evenement_metier.motif`, JAMAIS en colonne de l'objet.
--    Une seule place ; les codes admis restent dans `ref_motif_retrait`.

-- ── `qualification` (BM-09/24) ─────────────────────────────────────────────
-- ⭐ Une qualification est UNE SÉANCE D'ÉVALUATION. Ré-évaluer = une NOUVELLE
--    séance, jamais une mise à jour. La fiche affiche la plus récente ; les
--    précédentes restent lisibles — c'est ainsi que l'historique se conserve
--    (MUR M-7, O-1).
CREATE TABLE qualification (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  -- ⚠️ NULL EN BASE, exigé par la commande sous POL
  --    `qualification.besoin_obligatoire` (défaut oui, BM-09 — D-5).
  besoin_id   UUID REFERENCES besoin(id),
  personne_id UUID NOT NULL REFERENCES personne(id),
  positionnement_id UUID REFERENCES positionnement(id),
  type_code   TEXT REFERENCES ref_type_qualification(code),
  evaluateur_compte_id UUID NOT NULL REFERENCES compte(id),
  date        DATE NOT NULL,
  commentaire TEXT,
  resultat_global TEXT
);

CREATE TABLE qualification_mesure (
  qualification_id UUID NOT NULL REFERENCES qualification(id),
  competence_code  TEXT NOT NULL REFERENCES ref_competence(code),
  -- ⛔ NULL ≠ ZÉRO. Une compétence non mesurée n'est pas une compétence
  --    nulle (BM-09). Mettre 0 par défaut aurait fait couler des profils.
  niveau_mesure    INT,
  PRIMARY KEY (qualification_id, competence_code)
);


-- ═══════════════════════════════════════════════════════════════════════════
--  §9 — PRODUCTION
-- ═══════════════════════════════════════════════════════════════════════════

-- ── `projet` (DEC-05/06/07, US5, F4, F7, G1, G12) ──────────────────────────
CREATE TABLE projet (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  reference   TEXT NOT NULL UNIQUE,          -- générée : PRJ-xxxx
  societe_id  UUID NOT NULL REFERENCES societe(id),
  -- NULL en base, exigé par la commande sous POL `projet.contact` (D-5).
  contact_id             UUID REFERENCES contact(id),
  contact_technique_id   UUID REFERENCES contact(id),
  contact_facturation_id UUID REFERENCES contact(id),
  -- ⭐ NULL : un projet direct n'a pas de besoin (US5, ADR-003).
  -- ⚠️ Et un projet créé SANS besoin ne compte pour aucun besoin : pour
  --    pourvoir un besoin, on crée le projet DEPUIS lui (DEC-05, X-7).
  besoin_id   UUID REFERENCES besoin(id),
  agence_id   UUID NOT NULL REFERENCES agence(id),
  type_code   TEXT NOT NULL REFERENCES ref_type_mission(code),
  titre       TEXT NOT NULL,
  etat_code      TEXT NOT NULL REFERENCES ref_etat_projet(code),
  etat_categorie TEXT NOT NULL,
  date_debut DATE, date_fin DATE,
  lieu_adresse TEXT, lieu_code_postal TEXT, lieu_ville TEXT,
  lieu_pays_code TEXT REFERENCES ref_pays(code),
  responsable_manager_compte_id UUID REFERENCES compte(id),
  -- ⛔ AUCUNE colonne `devise_code` économique (D-9). Seulement une valeur
  --    PROPOSÉE à la création d'une prestation. AUCUN calcul ne la lit.
  --    La devise est celle de CHAQUE prestation, et les agrégats groupent par
  --    devise (M-15). Cas réel : un freelance MAD sur un projet facturé EUR.
  --    Deux devises sur un même projet : POL `projet.devises_mixtes`
  --    (défaut `autorise` — affichage en deux lignes).
  devise_defaut_code TEXT REFERENCES ref_devise(code),
  description TEXT,
  conditions_particulieres TEXT,
  archive_le            TIMESTAMPTZ,
  archive_par_compte_id UUID REFERENCES compte(id)
);
CREATE TRIGGER tg_cat BEFORE INSERT OR UPDATE ON projet
  FOR EACH ROW EXECUTE FUNCTION maj_etat_categorie('ref_etat_projet');

-- ⛔ MUR M-5 — AUCUNE colonne `profil_ressource_id` sur `projet`.
--    Les ressources d'un projet sont, et restent, une lecture :
--      SELECT DISTINCT profil_ressource_id FROM prestation WHERE projet_id = ?
--    Une colonne ici aurait divergé de `prestation` dès la deuxième mission.

-- ── `prestation` (DEC-07→11, US5, G11) ─────────────────────────────────────
CREATE TABLE prestation (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  projet_id   UUID NOT NULL REFERENCES projet(id),
  -- ⛔ MUR M-4 : NOT NULL et IMMUABLE (trigger ci-dessous).
  profil_ressource_id UUID NOT NULL REFERENCES profil_ressource(id),
  etat_code      TEXT NOT NULL REFERENCES ref_etat_prestation(code),
  etat_categorie TEXT NOT NULL,
  intitule    TEXT,
  date_debut  DATE NOT NULL,
  date_fin    DATE NOT NULL,
  -- ⭐ DONNÉE SENSIBLE (ATL-05) : permission séparée.
  tjm_vendu   NUMERIC(14,2),
  devise_code TEXT NOT NULL REFERENCES ref_devise(code),
  -- ⭐ MUR M-14 : le coût DE CETTE MISSION, pas la fiche ressource. Une fiche
  --    qui change de coût ne réécrit pas une mission signée l'an dernier.
  cjm_contrat NUMERIC(14,2),
  cjm_devise_code TEXT NOT NULL REFERENCES ref_devise(code),
  jours_vendus NUMERIC(8,2),
  taux_occupation_pct NUMERIC(5,2) NOT NULL CHECK (taux_occupation_pct > 0),
  frais_journalier NUMERIC(14,2),
  frais_mensuel    NUMERIC(14,2),
  jours_ouvres_annuels INT,          -- prorata des frais mensuels (US5)
  contrat_reference TEXT,
  date_signature DATE, date_cloture DATE, date_annulation DATE,
  description TEXT,
  conditions_particulieres TEXT,
  archive_le            TIMESTAMPTZ,
  archive_par_compte_id UUID REFERENCES compte(id),
  CHECK (date_fin >= date_debut)
);
CREATE TRIGGER tg_cat BEFORE INSERT OR UPDATE ON prestation
  FOR EACH ROW EXECUTE FUNCTION maj_etat_categorie('ref_etat_prestation');

-- ⛔ MUR M-4 + MUR M-14, dans le même trigger parce que c'est la même idée :
--    ce qui est signé ne se réécrit pas.
CREATE FUNCTION prestation_immuable() RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
  -- M-4 : la ressource, en toutes circonstances.
  IF NEW.profil_ressource_id <> OLD.profil_ressource_id THEN
    RAISE EXCEPTION 'MUR M-4 : la ressource d''une prestation est immuable. Clôturez et créez une nouvelle prestation.';
  END IF;
  -- M-14 : l'économie, dès la catégorie `engage`.
  -- ⭐ Une prévisionnelle se CORRIGE ; une signée s'AVENANTE — et un avenant
  --    n'écrit jamais ici, il ajoute une ligne à `prestation_version`.
  IF OLD.etat_categorie IN ('engage','clos') THEN
    IF (NEW.tjm_vendu, NEW.cjm_contrat, NEW.devise_code, NEW.cjm_devise_code,
        NEW.jours_vendus, NEW.frais_journalier, NEW.frais_mensuel)
       IS DISTINCT FROM
       (OLD.tjm_vendu, OLD.cjm_contrat, OLD.devise_code, OLD.cjm_devise_code,
        OLD.jours_vendus, OLD.frais_journalier, OLD.frais_mensuel) THEN
      RAISE EXCEPTION 'MUR M-14 : les conditions économiques d''une prestation engagée sont figées. Passez par un avenant.';
    END IF;
  END IF;
  RETURN NEW;
END $$;
CREATE TRIGGER tg_m4_m14 BEFORE UPDATE ON prestation
  FOR EACH ROW EXECUTE FUNCTION prestation_immuable();

-- ⚠️ L'ENTRÉE DIRECTE EN `engage` (O-2) : `CreatePrestation` avec état
--    initial `signee` déclenche LES MÊMES effets que `SignPrestation` —
--    `PrestationSigned`, `ClientStatusDerived`, pourvu automatique — ET EXIGE
--    LA MÊME PERMISSION `SignPrestation`. Sinon Staffing signait sans le
--    droit. Le résultat, et le droit, ne dépendent pas de la porte d'entrée.
--    ⛔ Cette règle est dans la COMMANDE, pas ici : la base ne sait pas quelle
--       commande l'appelle. C'est au contrat L4 de la porter.

-- ── `prestation_version` : L'AVENANT DATÉ (B-2, 19/09) ─────────────────────
-- ⚠️ Table neuve, et elle ne sert QUE sous l'option. Sous le défaut Avaliance
--    (POL `prestation.avenant.mode` = `nouvelle_prestation`), elle reste
--    VIDE : une mission modifiée se clôture et une autre la remplace.
CREATE TABLE prestation_version (
  prestation_id UUID NOT NULL REFERENCES prestation(id),
  version_n     INT  NOT NULL CHECK (version_n >= 1),   -- 1 = la signature
  date_effet    DATE NOT NULL,
  tjm_vendu     NUMERIC(14,2) NOT NULL,
  devise_code   TEXT NOT NULL REFERENCES ref_devise(code),
  cjm_contrat   NUMERIC(14,2) NOT NULL,
  cjm_devise_code TEXT NOT NULL REFERENCES ref_devise(code),
  jours_vendus  NUMERIC(8,2),
  taux_occupation_pct NUMERIC(5,2) NOT NULL CHECK (taux_occupation_pct > 0),
  frais_journalier NUMERIC(14,2),
  frais_mensuel    NUMERIC(14,2),
  motif_code    TEXT NOT NULL REFERENCES ref_motif_avenant(code),
  cree_le       TIMESTAMPTZ NOT NULL DEFAULT now(),
  cree_par_compte_id UUID NOT NULL REFERENCES compte(id),
  PRIMARY KEY (prestation_id, version_n),
  -- ⛔ Deux conditions ne valent pas le même jour.
  UNIQUE (prestation_id, date_effet)
);

-- ⛔ AJOUT SEUL, comme l'historique. Une erreur de saisie se corrige par UNE
--    VERSION DE PLUS. C'est la même règle que M-7, pour la même raison.
CREATE TRIGGER tg_ajout_seul BEFORE UPDATE OR DELETE ON prestation_version
  FOR EACH ROW EXECUTE FUNCTION ajout_seul('un avenant se corrige par un avenant');

-- La date d'effet tient dans la mission.
CREATE FUNCTION version_dans_mission() RETURNS TRIGGER LANGUAGE plpgsql AS $$
DECLARE d1 DATE; d2 DATE;
BEGIN
  SELECT date_debut, date_fin INTO d1, d2 FROM prestation WHERE id = NEW.prestation_id;
  IF NEW.date_effet < d1 OR NEW.date_effet > d2 THEN
    RAISE EXCEPTION 'La date d''effet (%) est hors de la mission [% ; %]', NEW.date_effet, d1, d2;
  END IF;
  -- ⛔ Refus sous le défaut Avaliance : la table ne se remplit pas.
  IF pol('prestation.avenant.mode') = 'nouvelle_prestation' THEN
    RAISE EXCEPTION 'POL prestation.avenant.mode = nouvelle_prestation : une mission modifiée se clôture et se remplace.';
  END IF;
  RETURN NEW;
END $$;
CREATE TRIGGER tg_effet BEFORE INSERT ON prestation_version
  FOR EACH ROW EXECUTE FUNCTION version_dans_mission();

-- ⭐ CE QUE LIT LE SNAPSHOT DE MARGE : la version EN VIGUEUR À CHAQUE DATE,
--    pas la dernière. Un TJM qui change au 1er juin ne réécrit pas mai.
--    Sous le défaut (table vide), il lit `prestation` comme avant.
--    ⚠️ ATL-15 ne change pas de formule, il change de SOURCE.
CREATE VIEW v_conditions_du_jour AS
SELECT p.id AS prestation_id, d.jour,
       coalesce(v.tjm_vendu,  p.tjm_vendu)  AS tjm_vendu,
       coalesce(v.devise_code, p.devise_code) AS devise_code,
       coalesce(v.cjm_contrat, p.cjm_contrat) AS cjm_contrat,
       coalesce(v.cjm_devise_code, p.cjm_devise_code) AS cjm_devise_code,
       coalesce(v.frais_journalier, p.frais_journalier) AS frais_journalier,
       coalesce(v.frais_mensuel, p.frais_mensuel) AS frais_mensuel
FROM prestation p
CROSS JOIN LATERAL generate_series(p.date_debut, p.date_fin, '1 day') AS d(jour)
LEFT JOIN LATERAL (
  SELECT * FROM prestation_version pv
  WHERE pv.prestation_id = p.id AND pv.date_effet <= d.jour
  ORDER BY pv.date_effet DESC LIMIT 1
) v ON true;

-- ⭐ Elle est ICI et pas au §8 : elle lit `projet` et `prestation`.
CREATE VIEW v_besoin_couverture AS
SELECT b.id AS besoin_id,
       b.nb_postes_vises,
       b.fte_vise,
       b.unite_couverture_code,
       count(pr.id)                                   AS postes_engages,
       coalesce(sum(pr.taux_occupation_pct), 0) / 100 AS fte_engage
FROM besoin b
LEFT JOIN projet p     ON p.besoin_id = b.id
LEFT JOIN prestation pr ON pr.projet_id = p.id AND pr.etat_categorie = 'engage'
GROUP BY b.id;

CREATE TABLE prestation_ligne_ca (
  prestation_id UUID NOT NULL REFERENCES prestation(id),
  date          DATE NOT NULL,
  titre         TEXT NOT NULL,
  ca_ht         NUMERIC(14,2),
  invest_ht     NUMERIC(14,2),
  PRIMARY KEY (prestation_id, date, titre)
);

-- ── `temps` (DEC-02, F32/F33/F34, G9) ──────────────────────────────────────
CREATE TABLE temps (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  prestation_id UUID NOT NULL REFERENCES prestation(id),
  -- ⛔ MUR M-1 : AUCUNE colonne candidat. Un candidat ne peut PHYSIQUEMENT
  --    pas porter de temps. Ce n'est pas une garde, c'est l'absence de porte.
  profil_ressource_id UUID NOT NULL REFERENCES profil_ressource(id),
  jour      DATE NOT NULL,
  quantite  NUMERIC(4,2) NOT NULL CHECK (quantite > 0),   -- 0.6 = 0,6 jour
  -- ⭐ B-4, 19/09 : 20 jours produits, 18 facturés — les deux se conservent.
  --    NULL sous le défaut `egal_au_produit`, où le facturable EST le produit.
  quantite_facturable NUMERIC(4,2) CHECK (quantite_facturable > 0),
  ajustement BOOL NOT NULL DEFAULT false,      -- F34 : ajustement post-clôture
  saisi_par_compte_id UUID NOT NULL REFERENCES compte(id),  -- l'auteur ≠ la ressource
  commentaire TEXT,
  -- ⭐ D-4 : annuler une saisie erronée = L'ARCHIVER, événement
  --    `TimesheetCancelled`. ⛔ PAS de quantité négative : une
  --    contre-passation est une ligne qu'on relit mal six mois plus tard.
  archive_le            TIMESTAMPTZ,
  archive_par_compte_id UUID REFERENCES compte(id)
);
-- ⛔ PAS d'UNIQUE (prestation_id, jour) : deux lignes le même jour sont deux
--    faits. Le plafond journalier est POL `temps.plafond_jour` (défaut
--    ALERTE), pas une contrainte.
CREATE INDEX ix_temps_presta_jour ON temps (prestation_id, jour) WHERE archive_le IS NULL;
CREATE INDEX ix_temps_ress_jour   ON temps (profil_ressource_id, jour) WHERE archive_le IS NULL;

-- ⛔ MUR M-10 : le temps est porté par la ressource DE LA PRESTATION (F32).
CREATE FUNCTION temps_meme_ressource() RETURNS TRIGGER LANGUAGE plpgsql AS $$
DECLARE r UUID;
BEGIN
  SELECT profil_ressource_id INTO r FROM prestation WHERE id = NEW.prestation_id;
  IF r IS DISTINCT FROM NEW.profil_ressource_id THEN
    RAISE EXCEPTION 'MUR M-10 : ce temps n''est pas porté par la ressource de la prestation.';
  END IF;
  RETURN NEW;
END $$;
CREATE TRIGGER tg_m10 BEFORE INSERT OR UPDATE ON temps
  FOR EACH ROW EXECUTE FUNCTION temps_meme_ressource();

-- Le facturable n'existe que sous l'option (B-4).
CREATE FUNCTION temps_facturable() RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
  IF pol('temps.facturable.mode') = 'saisie_separee' THEN
    IF NEW.quantite_facturable IS NULL THEN
      RAISE EXCEPTION 'POL temps.facturable.mode = saisie_separee : la quantité facturable est requise.';
    END IF;
  ELSE
    NEW.quantite_facturable := NULL;   -- sous le défaut, le facturable EST le produit
  END IF;
  RETURN NEW;
END $$;
CREATE TRIGGER tg_fact BEFORE INSERT OR UPDATE ON temps
  FOR EACH ROW EXECUTE FUNCTION temps_facturable();

-- ⚠️ CE QUI N'EST PAS ICI, et pourquoi :
--    · la période autorisée → POL `temps.periode` (défaut : dans les dates
--      de la prestation, G9)
--    · la correction après clôture → POL `temps.correction_apres_cloture`
--      (défaut : ajustement tracé). ⛔ ET LE SNAPSHOT NE BOUGE PAS — M-6.
--    · la validation → POL `temps.validation` (défaut AUCUNE, F35) : le CA
--      produit régie utilise les temps SAISIS (ATL-08)

-- ── `absence` (F25, DEC-16) ────────────────────────────────────────────────
-- ⭐ AUCUN lien vers `prestation` : une absence existe sans mission. Elle
--    entre dans la capacité d'ATL-04.
CREATE TABLE absence (
  id        UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  profil_ressource_id UUID NOT NULL REFERENCES profil_ressource(id),
  type_code TEXT NOT NULL REFERENCES ref_type_absence(code),
  date_debut DATE NOT NULL,
  date_fin   DATE NOT NULL,
  quantite_par_jour NUMERIC(4,2) NOT NULL DEFAULT 1 CHECK (quantite_par_jour > 0),
  statut    TEXT,
  saisi_par_compte_id UUID NOT NULL REFERENCES compte(id),
  archive_le            TIMESTAMPTZ,       -- D-4 : annuler = archiver
  archive_par_compte_id UUID REFERENCES compte(id),
  CHECK (date_fin >= date_debut)
);

-- ── `snapshot_marge` (DEC-09, ATL-15) ──────────────────────────────────────
-- ⭐ LA MARGE FIGÉE. Un chiffre qu'on a montré à un client ne se recalcule
--    pas six mois plus tard parce qu'un coût a bougé.
CREATE TABLE snapshot_marge (
  prestation_id UUID PRIMARY KEY REFERENCES prestation(id),  -- UN SEUL
  calcule_le    TIMESTAMPTZ NOT NULL DEFAULT now(),
  version_atl   TEXT NOT NULL,             -- « ATL-2026-09-16 »
  ca_produit      NUMERIC(14,2) NOT NULL,
  ca_devise_code  TEXT NOT NULL REFERENCES ref_devise(code),
  cout_produit    NUMERIC(14,2) NOT NULL,
  frais_imputes   NUMERIC(14,2) NOT NULL DEFAULT 0,
  cout_devise_code TEXT NOT NULL REFERENCES ref_devise(code),
  -- ⛔ Exprimées dans `ca_devise_code`. PAS de troisième colonne de devise :
  --    la marge n'a de sens que dans la devise de la vente.
  -- ⛔ NULL si les deux devises diffèrent et que POL `change.mode` vaut
  --    `aucune_conversion` — affiché « — », JAMAIS calculé sur deux devises.
  --    On n'invente pas un taux (ATL-16, ATL-17, M-15, D-9).
  marge       NUMERIC(14,2),
  taux_marge  NUMERIC(6,2),
  -- ⭐ Les valeurs ET LES POLITIQUES lues au moment du calcul. C'est ce qui
  --    permet, un an après, de dire sous quelle règle ce chiffre est né.
  entrees     JSONB NOT NULL,
  CHECK (ca_devise_code = cout_devise_code OR marge IS NULL)
);

-- ⛔ MUR M-6 : le snapshot est FIGÉ. Trigger + GRANT sans UPDATE (§13).
CREATE TRIGGER tg_m6 BEFORE UPDATE OR DELETE ON snapshot_marge
  FOR EACH ROW EXECUTE FUNCTION ajout_seul('MUR M-6 : un snapshot ne se recalcule pas');

-- ⚠️ `taux_marge` est NULL si `ca_produit = 0` — POL `marge.taux.si_ca_nul`
--    (défaut : afficher « — »). ⛔ Jamais `Inf`, jamais une division qui
--    passe et qu'on lit comme un résultat.


-- ═══════════════════════════════════════════════════════════════════════════
--  §10 — DROITS (DEC-17, F28, BM-41→45)
-- ═══════════════════════════════════════════════════════════════════════════

CREATE TABLE groupe (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  nom         TEXT NOT NULL UNIQUE,
  description TEXT
);

CREATE TABLE compte_groupe (
  compte_id UUID NOT NULL REFERENCES compte(id),
  groupe_id UUID NOT NULL REFERENCES groupe(id),
  PRIMARY KEY (compte_id, groupe_id)
);

-- Le catalogue des 44 commandes. ⭐ C'est le contrat L4 qui le remplit.
CREATE TABLE permission (
  code    TEXT PRIMARY KEY,          -- `CreateCompany`, `SignPrestation`…
  libelle TEXT NOT NULL,
  famille TEXT NOT NULL
);

-- ── `perimetre` : SUR QUOI un droit s'applique ─────────────────────────────
CREATE TABLE perimetre (
  id        UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  type_code TEXT NOT NULL CHECK (type_code IN ('agence','pole','equipe','global')),
  agence_id UUID REFERENCES agence(id),
  unite_id  UUID REFERENCES unite_organisation(id),
  -- X-6 : chaque type porte exactement ce qu'il doit porter.
  CONSTRAINT ck_x6 CHECK (
    (type_code = 'global' AND agence_id IS NULL AND unite_id IS NULL)
 OR (type_code = 'agence' AND agence_id IS NOT NULL AND unite_id IS NULL)
 OR (type_code IN ('pole','equipe') AND unite_id IS NOT NULL AND agence_id IS NULL))
);

-- ⛔ MUR M-13 : UNE PERMISSION N'EXISTE JAMAIS SANS PÉRIMÈTRE.
--    La PK porte les trois colonnes. C'est ce qui empêche BM-42 : lecture sur
--    B + écriture sur A NE DONNE PAS écriture sur B. Une table à deux
--    colonnes aurait laissé cette porte ouverte, et personne ne l'aurait vue.
CREATE TABLE groupe_permission_perimetre (
  groupe_id       UUID NOT NULL REFERENCES groupe(id),
  permission_code TEXT NOT NULL REFERENCES permission(code),
  perimetre_id    UUID NOT NULL REFERENCES perimetre(id),
  PRIMARY KEY (groupe_id, permission_code, perimetre_id)
);

-- ── `compte_surcharge` : la restriction nominative (F28, P-4) ──────────────
-- ⛔ PAS de colonne `sens`. Une surcharge ne peut qu'ENLEVER. Une table qui
--    pourrait aussi donner serait une seconde source de droits, et on ne
--    saurait plus lequel des deux chemins a ouvert une porte.
CREATE TABLE compte_surcharge (
  compte_id       UUID NOT NULL REFERENCES compte(id),
  permission_code TEXT NOT NULL REFERENCES permission(code),
  perimetre_id    UUID NOT NULL REFERENCES perimetre(id),
  PRIMARY KEY (compte_id, permission_code, perimetre_id)
);

-- ⭐ LA RÉSOLUTION : union des (permission, périmètre) de tous les groupes,
--    PUIS les surcharges. POL `droits.surcharge_restrictive` (défaut : LA
--    RESTRICTION GAGNE, F28).
-- ⚠️ Cette politique est signalée EN ROUGE dans l'écran Administration :
--    la passer à `union_gagne` affaiblit toutes les restrictions nominatives
--    d'un coup, et rien à l'écran ne le montrerait autrement.
CREATE VIEW v_droits_effectifs AS
SELECT cg.compte_id, gpp.permission_code, gpp.perimetre_id
FROM compte_groupe cg
JOIN groupe_permission_perimetre gpp ON gpp.groupe_id = cg.groupe_id
WHERE pol('droits.surcharge_restrictive') <> 'restriction_gagne'
   OR NOT EXISTS (
     SELECT 1 FROM compte_surcharge cs
     WHERE cs.compte_id = cg.compte_id
       AND cs.permission_code = gpp.permission_code
       AND cs.perimetre_id = gpp.perimetre_id);


-- ═══════════════════════════════════════════════════════════════════════════
--  §11 — TRANSVERSE
-- ═══════════════════════════════════════════════════════════════════════════

-- ── `action` : le journal CRM (DEC-15) ─────────────────────────────────────
-- ⚠️ Porteur métier, responsable utilisateur et détenteur d'un droit sont
--    TROIS CHOSES DIFFÉRENTES (BM-40). Les confondre est la faute la plus
--    fréquente des CRM.
CREATE TABLE action (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  societe_id          UUID REFERENCES societe(id),
  contact_id          UUID REFERENCES contact(id),
  profil_candidat_id  UUID REFERENCES profil_candidat(id),
  profil_ressource_id UUID REFERENCES profil_ressource(id),
  besoin_id           UUID REFERENCES besoin(id),
  projet_id           UUID REFERENCES projet(id),
  type_code TEXT NOT NULL REFERENCES ref_type_action(code),
  date      TIMESTAMPTZ NOT NULL DEFAULT now(),
  contenu   TEXT,
  responsable_compte_id UUID REFERENCES compte(id),
  archive_le            TIMESTAMPTZ,
  archive_par_compte_id UUID REFERENCES compte(id),
  -- ⛔ MUR M-9 : EXACTEMENT UN porteur.
  CONSTRAINT ck_m9 CHECK (
    (societe_id IS NOT NULL)::int + (contact_id IS NOT NULL)::int
  + (profil_candidat_id IS NOT NULL)::int + (profil_ressource_id IS NOT NULL)::int
  + (besoin_id IS NOT NULL)::int + (projet_id IS NOT NULL)::int = 1)
);

-- ── `evenement_metier` : L'HISTORIQUE (DEC-18, ADR-004) ────────────────────
CREATE TABLE evenement_metier (
  id           BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  type         TEXT NOT NULL,           -- `PrestationSigned`, `PolicyChanged`…
  objet_type   TEXT NOT NULL,
  objet_id     UUID,
  auteur_compte_id UUID REFERENCES compte(id),
  horodatage   TIMESTAMPTZ NOT NULL DEFAULT now(),
  avant        JSONB,
  apres        JSONB,
  motif        TEXT,                    -- ⭐ P-5 : le SEUL endroit des motifs
  -- ⭐ `liens.politiques` porte LES CLÉS LUES ET LEUR VALEUR AU MOMENT DE
  --    L'EXÉCUTION. On saura toujours sous quelle règle un fait s'est
  --    produit, même après un changement de réglage.
  --    ⛔ C'est ce qui rend le paramétrage HONNÊTE : sans ça, changer une
  --       politique réécrirait rétroactivement le sens de tout l'historique.
  liens        JSONB
);

-- ⛔ MUR M-7 : AJOUT SEUL. Trigger + GRANT sans UPDATE ni DELETE (§13).
CREATE TRIGGER tg_m7 BEFORE UPDATE OR DELETE ON evenement_metier
  FOR EACH ROW EXECUTE FUNCTION ajout_seul('MUR M-7 : l''historique ne se réécrit pas');

CREATE INDEX ix_evt_objet ON evenement_metier (objet_type, objet_id, horodatage DESC);
CREATE INDEX ix_evt_type  ON evenement_metier (type, horodatage DESC);

-- ⚠️ Les REFUS : POL `historique.tentatives_refusees` (défaut : tracés à
--    part). ⛔ Jamais mélangés aux réussites (BM-44) — un historique où l'on
--    ne distingue pas « fait » de « tenté » ne prouve rien.

-- ── `reprise_boond` (G13) ──────────────────────────────────────────────────
-- ⭐ HORS DES TABLES MÉTIER. Aucune colonne `boond_id` ne pollue `personne`
--    ou `projet`. Quand la reprise est finie, cette table SE RETIRE, sans
--    migration et sans laisser de trace dans le modèle.
CREATE TABLE reprise_boond (
  objet_type        TEXT NOT NULL,
  objet_id          UUID NOT NULL,
  boond_id          TEXT NOT NULL,
  boond_etat_source TEXT,
  importe_le        TIMESTAMPTZ NOT NULL DEFAULT now(),
  lot               TEXT,
  PRIMARY KEY (objet_type, objet_id)
);
-- ⭐ La correspondance des états Boond (14 étapes candidat, 9 états de
--    positionnement) se fait vers des CODES de `ref_*`, créés au besoin dans
--    la BONNE CATÉGORIE — sans toucher au code (ADR-005).
--    ⏸ Le détail des 14 + 9 reste à écrire, depuis Boond (livrable L1).

-- ── `modele` : ce qu'on ne réécrit pas deux fois (S-10.1, 19/09) ───────────
-- ⭐ Le plus gros trou trouvé en comparant avec Boond. Un utilisateur touche
--    ça TOUS LES JOURS : ses modèles d'actions, ses recherches enregistrées,
--    ses listes de tâches, ses formulaires.
CREATE TABLE modele (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  type_code   TEXT NOT NULL REFERENCES ref_type_modele(code),
  nom         TEXT NOT NULL,
  portee_code TEXT NOT NULL REFERENCES ref_portee_modele(code),
  agence_id   UUID REFERENCES agence(id),
  proprietaire_compte_id UUID REFERENCES compte(id),
  -- ⛔ LE SEUL JSONB de configuration du modèle, et c'est délibéré : la forme
  --    d'un formulaire n'est pas une donnée métier.
  -- ⚠️ AUCUNE règle métier ne le lit — sinon on aurait remis du métier hors
  --    du registre, et ADR-005 tomberait.
  contenu_json JSONB NOT NULL,
  partage     BOOL NOT NULL DEFAULT false,
  ordre       INT  NOT NULL DEFAULT 0,
  archive_le            TIMESTAMPTZ,          -- M-8
  archive_par_compte_id UUID REFERENCES compte(id),
  CONSTRAINT ck_portee CHECK (
    (portee_code <> 'agence'      OR agence_id IS NOT NULL) AND
    (portee_code <> 'personnelle' OR proprietaire_compte_id IS NOT NULL))
);

-- ── `alerte_regle` : les alertes cessent d'être en dur (S-10.3, 19/09) ─────
-- ⛔ Aujourd'hui les alertes du tableau de bord sont DANS LE CODE. Ça
--    contredit « tout est paramétrable » : une autre société n'a pas les
--    mêmes urgences.
CREATE TABLE alerte_regle (
  code        TEXT PRIMARY KEY,      -- `besoin_non_pourvu`, `cv_sans_reponse`…
  libelle     TEXT NOT NULL,
  objet_code  TEXT NOT NULL,
  -- ⛔ `condition_json` NE PORTE PAS DE SQL. Elle nomme un objet, un état,
  --    une politique et un seuil. Une alerte qui pourrait écrire sa propre
  --    requête serait une PORTE DÉROBÉE dans les murs et dans les droits.
  condition_json JSONB NOT NULL,
  -- ⛔ L'ÉCHELLE DU SENS, qu'aucune palette ne touche (THEMES_v1.md).
  gravite_code TEXT NOT NULL REFERENCES ref_gravite_alerte(code),
  actif       BOOL NOT NULL DEFAULT true,
  portee_code TEXT REFERENCES ref_portee_modele(code),
  agence_id   UUID REFERENCES agence(id),
  ordre       INT NOT NULL DEFAULT 0
);
-- ⭐ CE QUE ÇA REMPLACE : le bloc « CE QUI VOUS ATTEND » du tableau de bord
--    lisait une liste écrite en dur, par rôle. Il lit maintenant
--    `alerte_regle` filtrée par le périmètre de la personne.


-- ═══════════════════════════════════════════════════════════════════════════
--  §12 — LES RÉFÉRENCES DIFFÉRÉES ET LES TRIGGERS DE COHÉRENCE
--  ⚠️ Ici parce qu'elles pointent des tables créées plus bas que leur origine.
-- ═══════════════════════════════════════════════════════════════════════════

ALTER TABLE compte             ADD CONSTRAINT fk_personne
  FOREIGN KEY (personne_id) REFERENCES personne(id);
ALTER TABLE profil_ressource   ADD CONSTRAINT fk_fournisseur
  FOREIGN KEY (societe_fournisseur_id) REFERENCES societe(id);
ALTER TABLE periode_emploi     ADD CONSTRAINT fk_fournisseur
  FOREIGN KEY (societe_fournisseur_id) REFERENCES societe(id);
ALTER TABLE document           ADD CONSTRAINT fk_projet
  FOREIGN KEY (projet_id) REFERENCES projet(id);
ALTER TABLE document           ADD CONSTRAINT fk_societe
  FOREIGN KEY (societe_id) REFERENCES societe(id);

-- ── MUR M-12 : la cohérence de société, partout où elle se pose ────────────
CREATE TRIGGER tg_m12 BEFORE INSERT OR UPDATE ON contact
  FOR EACH ROW EXECUTE FUNCTION verifie_meme_societe(
    'unite_organisation_id', 'unite_organisation');

CREATE TRIGGER tg_m12 BEFORE INSERT OR UPDATE ON besoin
  FOR EACH ROW EXECUTE FUNCTION verifie_meme_societe(
    'contact_id', 'contact', 'unite_organisation_id', 'unite_organisation');

CREATE TRIGGER tg_m12 BEFORE INSERT OR UPDATE ON projet
  FOR EACH ROW EXECUTE FUNCTION verifie_meme_societe(
    'contact_id', 'contact',
    'contact_technique_id', 'contact',
    'contact_facturation_id', 'contact');

-- ── MUR M-12 (suite) : l'arbre des unités ──────────────────────────────────
-- Trois règles, un seul trigger, parce qu'elles se lisent ensemble.
CREATE FUNCTION unite_arbre() RETURNS TRIGGER LANGUAGE plpgsql AS $$
DECLARE p RECORD; cur UUID; n INT := 0; interne BOOL;
BEGIN
  SELECT EXISTS (SELECT 1 FROM societe_role
                 WHERE societe_id = NEW.societe_id AND role_code = 'interne')
    INTO interne;

  -- D-1 : une unité INTERNE dépend d'une agence ; une unité CLIENT n'en a pas.
  IF interne AND NEW.agence_id IS NULL THEN
    RAISE EXCEPTION 'Une unité interne appartient à une agence (D-1).';
  ELSIF NOT interne AND NEW.agence_id IS NOT NULL THEN
    RAISE EXCEPTION 'Une unité cliente n''a pas d''agence : une agence est un site d''Avaliance.';
  END IF;

  IF NEW.parent_id IS NOT NULL THEN
    SELECT * INTO p FROM unite_organisation WHERE id = NEW.parent_id;
    -- 1. Le parent appartient à la même société.
    IF p.societe_id <> NEW.societe_id THEN
      RAISE EXCEPTION 'MUR M-12 : le parent appartient à une autre société.';
    END IF;
    -- 2. ⭐ Pour une unité interne, le parent est de la MÊME AGENCE — sinon
    --    une équipe de l'agence B pendrait d'un pôle de l'agence A, et le
    --    périmètre de droits ne voudrait plus rien dire.
    IF interne AND p.agence_id <> NEW.agence_id THEN
      RAISE EXCEPTION 'MUR M-12 : le parent interne appartient à une autre agence (D-1).';
    END IF;
    -- 3. Pas de cycle. ⛔ Une hiérarchie qui boucle fait tourner en rond
    --    toute requête récursive — et on ne le découvre qu'en production.
    cur := NEW.parent_id;
    WHILE cur IS NOT NULL LOOP
      IF cur = NEW.id THEN
        RAISE EXCEPTION 'MUR M-12 : cycle dans l''arbre des unités.';
      END IF;
      n := n + 1;
      IF n > 64 THEN RAISE EXCEPTION 'Arbre des unités : profondeur anormale.'; END IF;
      SELECT parent_id INTO cur FROM unite_organisation WHERE id = cur;
    END LOOP;
  END IF;
  RETURN NEW;
END $$;
CREATE TRIGGER tg_m12 BEFORE INSERT OR UPDATE ON unite_organisation
  FOR EACH ROW EXECUTE FUNCTION unite_arbre();

-- ── D-1 : un périmètre pôle/équipe est une unité D'AVALIANCE ───────────────
-- ⛔ Jamais du client. Sans ce trigger, on pouvait donner un droit sur le
--    « pôle » d'une société cliente — et la matrice devenait fausse en
--    silence.
CREATE FUNCTION perimetre_interne() RETURNS TRIGGER LANGUAGE plpgsql AS $$
DECLARE u RECORD;
BEGIN
  IF NEW.unite_id IS NULL THEN RETURN NEW; END IF;
  SELECT uo.*, EXISTS (SELECT 1 FROM societe_role sr
                       WHERE sr.societe_id = uo.societe_id AND sr.role_code = 'interne')
                AS interne
    INTO u FROM unite_organisation uo WHERE uo.id = NEW.unite_id;
  IF NOT u.interne THEN
    RAISE EXCEPTION 'Un périmètre pôle/équipe est une unité interne (G6), jamais du client.';
  END IF;
  IF u.type_code <> NEW.type_code THEN
    RAISE EXCEPTION 'Le type du périmètre (%) ne correspond pas à celui de l''unité (%).',
      NEW.type_code, u.type_code;
  END IF;
  RETURN NEW;
END $$;
CREATE TRIGGER tg_interne BEFORE INSERT OR UPDATE ON perimetre
  FOR EACH ROW EXECUTE FUNCTION perimetre_interne();


-- ═══════════════════════════════════════════════════════════════════════════
--  §13 — MUR M-15 : LES VUES D'AGRÉGATS, ET RIEN D'AUTRE
--  ⭐ La seconde moitié de M-15. La première est dans les tables (une devise
--     à côté de chaque montant) ; celle-ci est dans la SURFACE DE LECTURE.
--  ⛔ Le rôle `ava_lecture_agregats` a SELECT sur ces quatre vues et PAS sur
--     `prestation`, `temps`, `snapshot_marge`. C'est ce qui rend
--     PHYSIQUEMENT impossible qu'un service additionne des euros et des
--     dirhams : il n'a pas les lignes.
-- ═══════════════════════════════════════════════════════════════════════════

CREATE VIEW v_ca_realise_par_devise AS
SELECT s.ca_devise_code AS devise_code,
       p.projet_id, pj.societe_id, pj.agence_id,
       sum(s.ca_produit) AS ca_produit
FROM snapshot_marge s
JOIN prestation p ON p.id = s.prestation_id
JOIN projet pj    ON pj.id = p.projet_id
GROUP BY 1, 2, 3, 4;

-- B-3 : le provisoire — ce qui est engagé mais pas encore clos.
-- ⚠️ Il se LIT à part du réalisé. Les mélanger, c'est annoncer un CA qui
--    n'existe pas encore.
CREATE VIEW v_ca_provisoire_par_devise AS
SELECT p.devise_code, p.projet_id, pj.societe_id, pj.agence_id,
       sum(coalesce(t.quantite_facturable, t.quantite) * p.tjm_vendu) AS ca_provisoire
FROM prestation p
JOIN projet pj ON pj.id = p.projet_id
JOIN temps  t  ON t.prestation_id = p.id AND t.archive_le IS NULL
WHERE p.etat_categorie = 'engage'
GROUP BY 1, 2, 3, 4;

CREATE VIEW v_marge_par_devise AS
SELECT s.ca_devise_code AS devise_code, pj.societe_id, pj.agence_id,
       sum(s.ca_produit) AS ca, sum(s.cout_produit + s.frais_imputes) AS cout,
       sum(s.marge) AS marge
FROM snapshot_marge s
JOIN prestation p ON p.id = s.prestation_id
JOIN projet pj    ON pj.id = p.projet_id
-- ⛔ Les prestations dont les deux devises diffèrent sont EXCLUES, pas
--    converties. Mieux vaut un total honnête et une ligne « — » qu'un total
--    faux que personne ne questionne.
WHERE s.marge IS NOT NULL
GROUP BY 1, 2, 3;

CREATE VIEW v_occupation_valorisee_par_devise AS
SELECT p.devise_code, p.profil_ressource_id, pj.agence_id,
       date_trunc('month', t.jour)::date AS mois,
       sum(t.quantite)                   AS jours_produits,
       sum(t.quantite * p.tjm_vendu)     AS valorisation
FROM temps t
JOIN prestation p ON p.id = t.prestation_id
JOIN projet pj    ON pj.id = p.projet_id
WHERE t.archive_le IS NULL
GROUP BY 1, 2, 3, 4;

-- ⭐ RÈGLE DE CODE R-1 (ce n'est PAS un mur, T-2) — ce qui reste hors base :
--    un service qui lit des lignes par le rôle transactionnel et les
--    additionne lui-même. Refus en revue, comme un `if` sans clé de
--    politique. Aucune contrainte SQL ne peut l'attraper : c'est une règle
--    d'équipe, et elle est écrite ici pour qu'on ne l'oublie pas.


-- ═══════════════════════════════════════════════════════════════════════════
--  §14 — LES GRANT : LÀ OÙ QUATRE MURS DEVIENNENT PHYSIQUES
--  ⭐ M-6, M-7, M-8 et la moitié de M-15 ne sont pas des triggers : ce sont
--     des droits. Un trigger se désactive (`ALTER TABLE … DISABLE TRIGGER`) ;
--     un droit qu'on n'a pas ne se retrouve pas.
-- ═══════════════════════════════════════════════════════════════════════════

GRANT SELECT, INSERT, UPDATE ON ALL TABLES IN SCHEMA ava TO ava_app;

-- ⛔ MUR M-8 — RIEN NE SE SUPPRIME, TOUT S'ARCHIVE.
--    Le rôle applicatif n'a le DELETE sur AUCUNE table. C'est pour ça qu'il
--    n'y a pas une seule icône de corbeille dans les 24 écrans : l'UI ne
--    propose pas un geste que la base refuse.
REVOKE DELETE ON ALL TABLES IN SCHEMA ava FROM ava_app;

-- ⛔ MUR M-7 — l'historique : INSERT et SELECT, un point c'est tout.
REVOKE UPDATE ON evenement_metier   FROM ava_app;

-- ⛔ MUR M-6 — le snapshot : on l'écrit une fois, on le relit toujours.
REVOKE UPDATE ON snapshot_marge     FROM ava_app;

-- ⛔ L'avenant daté : ajout seul (même règle que M-7).
REVOKE UPDATE ON prestation_version FROM ava_app;

-- ⛔ MUR M-15 — le rôle d'agrégation ne voit QUE les vues par devise.
GRANT SELECT ON v_ca_realise_par_devise,
                v_ca_provisoire_par_devise,
                v_marge_par_devise,
                v_occupation_valorisee_par_devise
  TO ava_lecture_agregats;
-- ⚠️ Et surtout : aucun GRANT sur `prestation`, `temps`, `snapshot_marge`
--    pour ce rôle. L'absence est la protection.

-- Les référentiels et les politiques : lecture pour tous, écriture par les
-- commandes d'administration seulement (la matrice s'en charge).
GRANT SELECT ON ALL TABLES IN SCHEMA ava TO ava_lecture_agregats;
REVOKE SELECT ON prestation, temps, snapshot_marge, prestation_ligne_ca,
                 profil_ressource, positionnement
  FROM ava_lecture_agregats;

-- ⛔⛔ B-001, 20/09 — `ALL TABLES` INCLUT LES VUES, et c'est par là que M-15
--    était percé. `v_conditions_du_jour` expose `tjm_vendu` et `cjm_contrat`
--    ligne par ligne : le rôle d'agrégats n'était pas censé avoir les lignes,
--    il les avait par la vue.
-- ⭐ On ne retire donc pas six vues par leur nom — on retire TOUT, puis on
--    redonne les quatre. ⚠️ Une liste de noms ne couvre que ces noms ; la
--    septième vue écrite dans six mois se serait ouverte toute seule.
REVOKE SELECT ON ALL TABLES IN SCHEMA ava FROM ava_lecture_agregats;
GRANT SELECT ON ref_devise, ref_pays, politique TO ava_lecture_agregats;
GRANT SELECT ON v_ca_realise_par_devise,
                v_ca_provisoire_par_devise,
                v_marge_par_devise,
                v_occupation_valorisee_par_devise
  TO ava_lecture_agregats;


-- ═══════════════════════════════════════════════════════════════════════════
--  §15 — VÉRIFICATION : LES 15 MURS, ET OÙ ILS SONT DANS CE FICHIER
--  ⭐ Si une ligne de ce tableau ne correspond à rien dans le fichier, le
--     fichier est faux. C'est la seule façon de relire un schéma.
--
--  | Mur  | Ce qu'il interdit                  | Où, ici                     |
--  |------|------------------------------------|-----------------------------|
--  | M-1  | un candidat qui produit            | `temps` : pas de colonne    |
--  | M-2  | un positionnement des deux côtés   | `ck_m2_xor`                 |
--  | M-3  | deux profils du même type          | UNIQUE `personne_id` ×2     |
--  | M-4  | changer la ressource d'une mission | `prestation_immuable()`     |
--  | M-5  | une ressource posée sur le projet  | `projet` : pas de colonne   |
--  | M-6  | recalculer un snapshot             | trigger + REVOKE UPDATE     |
--  | M-7  | réécrire l'historique              | trigger + REVOKE UPDATE     |
--  | M-8  | supprimer quoi que ce soit         | REVOKE DELETE + `archive_le`|
--  | M-9  | une action à deux porteurs         | `ck_m9` (somme = 1)         |
--  | M-10 | un temps d'une autre ressource     | `temps_meme_ressource()`    |
--  | M-11 | un besoin sans société             | `societe_id` NOT NULL       |
--  | M-12 | un contact d'une autre société     | `verifie_meme_societe()`,   |
--  |      | un arbre qui boucle                | `unite_arbre()`             |
--  | M-13 | un droit sans périmètre            | PK à trois colonnes         |
--  | M-14 | réécrire une mission signée        | `prestation_immuable()`     |
--  | M-15 | un montant sans devise,            | `paire_montant()` partout,  |
--  |      | un agrégat multi-devises           | les 4 vues + les GRANT      |
--
--  ⭐ SEPT murs ne sont PAS des CHECK — M-4, M-6, M-7, M-8, M-10, M-12, M-14.
--     Un CHECK ne peut pas dire « cette colonne ne change jamais ». C'est
--     toute la différence entre « le mur est dans la base » et « le mur est
--     dans l'écran ».
-- ═══════════════════════════════════════════════════════════════════════════


-- ═══════════════════════════════════════════════════════════════════════════
--  §16 — CE QUE CE FICHIER NE CONTIENT PAS, ET OÙ C'EST
--
--  | Absent                         | Livrable                              |
--  |--------------------------------|---------------------------------------|
--  | Les 167 lignes de `politique`  | seed, depuis le registre §C           |
--  | Les codes système des `ref_*`  | seed, depuis le registre §B           |
--  | Le contrat des 44 commandes    | **L4** — entrée, sortie, refus,       |
--  |                                | événement, politique lue, mur touché  |
--  | La matrice rôle × commande     | configuration, étape 8                |
--  | Les formules ATL               | code, versionné (`version_atl`)       |
--  | Les 22 assertions (un test     | **L7** — écrites AVANT le code        |
--  | par mur)                       |                                       |
--  | Les 14 + 9 états Boond         | **L1** — depuis Boond, écran par écran|
--  | Partitionnement, rétention,    | après la PREMIÈRE MESURE. ⛔ Pas avant|
--  | index fins                     | : on n'optimise pas un devinement     |
--
--  ⛔ ACHATS, FACTURES, PAIEMENTS, COMMENTAIRES, MENTIONS, ALERTES ENVOYÉES,
--     MODÈLES D'EMAIL, PROCESSUS DE RECRUTEMENT, OBJECTIFS, PORTAIL CANDIDAT
--     sont HORS V1 — nommés, pas oubliés (F16-F18, modèle §1).
-- ═══════════════════════════════════════════════════════════════════════════
