-- ## On renseigne ici la table t_synonymes permettant de faire une correspondance des valeurs initiales et celles de destinations entre 2 sources de vocabulaire.
drop index IF EXISTS ref_nomenclatures.i_synonymes_type_nomencl_initial_value;


CREATE UNIQUE INDEX CONCURRENTLY i_synonymes_type_initial_value
    ON ref_nomenclatures.t_synonymes (id_type, initial_value);

alter table ref_nomenclatures.t_synonymes
    add constraint c_synonymes_type_initial_value_unique unique using index i_synonymes_type_initial_value;

-- /!\ obse_pcole_choi_id, --> TECHNIQUE_OBS /!\ champ absent d'occurence dans OccTax mais présent dans Synthèse et JDD ###

-- On identifie d'abord les valeurs à faire correspondre dans la nomenclature de Serena
SELECT DISTINCT
    req.obse_pcole_choi_id
  , rnf_choi.choi_nom AS protocole
--   , req.nbre_obs
    FROM
        (SELECT DISTINCT
             o.obse_pcole_choi_id
--            , count(o.obse_id) as nbre_obs
             FROM
                 _import_serena.rnf_obse o
             GROUP BY obse_pcole_choi_id) req
            JOIN _import_serena.rnf_choi ON req.obse_pcole_choi_id = rnf_choi.choi_id
    ORDER BY
--         nbre_obs desc,
protocole;

-- On compare la liste de ces valeurs à la nomenclature SINP à réconcilier (ici: 100 = TECHNIQUE_OBS)
SELECT *
    FROM
        ref_nomenclatures.t_nomenclatures
    WHERE
        id_type = 100;

-- On ajoute des valeurs qui sont absentes de la nomenclature SINP mais que l'on souhaite conserver dans GN2
INSERT INTO
    ref_nomenclatures.t_nomenclatures( id_type
                                     , cd_nomenclature
                                     , mnemonique
                                     , label_default
                                     , definition_default
                                     , label_fr
                                     , definition_fr
                                     , source
                                     , statut
                                     , id_broader
                                     , hierarchy
                                     , meta_create_date
                                     , meta_update_date
                                     , active)
    VALUES
        ( 100
        , '134'
        , 'Observation par prospection ciblée ou systématique'
        , 'Observation par prospection ciblée ou systématique'
        , 'Observation par prospection ciblée ou systématique'
        , 'Observation par prospection ciblée ou systématique'
        , 'Observation par prospection ciblée ou systématique'
        , 'GEONATURE'
        , 'Non-validé'
        , 0
        , '100' || '.' || '134'
        , now()
        , now()
        , true)
      , ( 100
        , '135'
        , 'Comptage ciblé (affût sur place de chant etc.)'
        , 'Comptage ciblé (affût sur place de chant etc.)'
        , 'Comptage ciblé (affût sur place de chant etc.)'
        , 'Comptage ciblé (affût sur place de chant etc.)'
        , 'Comptage ciblé (affût sur place de chant etc.)'
        , 'GEONATURE'
        , 'Non-validé'
        , 0
        , '100' || '.' || '134'
        , now()
        , now()
        , true);

-- On ajoute ces valeurs initiales de Serena dans la table de correspondances de synonymes avec le type correspondant dans la nomenclature GeoNature (ici: 100 = TECHNIQUE_OBS)
INSERT INTO
    ref_nomenclatures.t_synonymes(id_type, initial_value)
SELECT DISTINCT
    100
  , protocole::text
    FROM
        _import_serena.vm_obs_serena_detail_point;

-- On met à jour manuellement les id_nomenclature correspondants aux synonymes dans la nomenclature GeoNature (SINP) quand la valeur n'est pas strictement identique des 2 côtés
UPDATE ref_nomenclatures.t_synonymes s
SET
    id_nomenclature = t.id_nomenclature
    FROM
        ref_nomenclatures.t_nomenclatures t
    WHERE
            initial_value IN ('Observation visuelle directe', 'Observation aléatoire', 'Comptage visuel direct')
      AND   t.cd_nomenclature = '59'
      AND   t.id_type = 100
      AND   s.id_type = 100;
UPDATE ref_nomenclatures.t_synonymes s
SET
    id_nomenclature = t.id_nomenclature
    FROM
        ref_nomenclatures.t_nomenclatures t
    WHERE
          initial_value IN ('Observation par prospection ciblée ou systématique')
      AND t.cd_nomenclature = '134'
      AND t.id_type = 100
      AND s.id_type = 100;
UPDATE ref_nomenclatures.t_synonymes s
SET
    id_nomenclature = t.id_nomenclature
    FROM
        ref_nomenclatures.t_nomenclatures t
    WHERE
          initial_value IN ('Comptage ciblé (affût sur place de chant etc.)')
      AND t.cd_nomenclature = '135'
      AND t.id_type = 100
      AND s.id_type = 100;
UPDATE ref_nomenclatures.t_synonymes s
SET
    id_nomenclature = t.id_nomenclature
    FROM
        ref_nomenclatures.t_nomenclatures t
    WHERE
          initial_value IN ('Utilisation de pièges-photographique')
      AND t.cd_nomenclature = '67'
      AND t.id_type = 100
      AND s.id_type = 100;
UPDATE ref_nomenclatures.t_synonymes s
SET
    id_nomenclature = t.id_nomenclature
    FROM
        ref_nomenclatures.t_nomenclatures t
    WHERE
          initial_value IN ('Détermination par le chant avec repasse')
      AND t.cd_nomenclature = '26'
      AND t.id_type = 100
      AND s.id_type = 100;
UPDATE ref_nomenclatures.t_synonymes s
SET
    id_nomenclature = t.id_nomenclature
    FROM
        ref_nomenclatures.t_nomenclatures t
    WHERE
          initial_value IN ('Détermination par le chant')
      AND t.cd_nomenclature = '24'
      AND t.id_type = 100
      AND s.id_type = 100;
UPDATE ref_nomenclatures.t_synonymes s
SET
    id_nomenclature = t.id_nomenclature
    FROM
        ref_nomenclatures.t_nomenclatures t
    WHERE
          initial_value IN ('Recherche d''indices de présence')
      AND t.cd_nomenclature = '57'
      AND t.id_type = 100
      AND s.id_type = 100;

UPDATE ref_nomenclatures.t_synonymes s
SET
    id_nomenclature = t.id_nomenclature
    FROM
        ref_nomenclatures.t_nomenclatures t
    WHERE
          initial_value IN ('Recherche d''indices de présence')
      AND t.cd_nomenclature = '57'
      AND t.id_type = 100
      AND s.id_type = 100;

UPDATE ref_nomenclatures.t_synonymes s
SET
    id_nomenclature = t.id_nomenclature
    FROM
        ref_nomenclatures.t_nomenclatures t
    WHERE
          initial_value IS NULL
      AND t.cd_nomenclature = '133'
      AND t.id_type = 100
      AND s.id_type = 100;


-- ### obse_validat_choi_id -> STATUT_VALID ###

-- On identifie d'abord les valeurs à faire correspondre dans la nomenclature de Serena
SELECT DISTINCT
    rnf_choi.choi_list_id
  , req.obse_validat_choi_id
  , rnf_choi.choi_nom AS statut_validation
    FROM
        (SELECT DISTINCT
             o.obse_validat_choi_id
             FROM
                 _import_serena.rnf_obse o) req
            JOIN _import_serena.rnf_choi ON req.obse_validat_choi_id = rnf_choi.choi_id;

-- On compare la liste de ces valeurs à la nomenclature SINP à réconcilier (ici: 101 = STATUT_VALID)
SELECT *
    FROM
        ref_nomenclatures.t_nomenclatures
    WHERE
        id_type = 101;

-- On ajoute ces valeurs initiales de Serena dans la table de correspondances de synonymes avec le type correspondant dans la nomenclature GeoNature (ici: 101 = STATUT_VALID)
INSERT INTO
    ref_nomenclatures.t_synonymes(id_type, initial_value)
SELECT DISTINCT
    101
  , statut_validation::text
    FROM
        _import_serena.vm_obs_serena_detail_point
    WHERE
        statut_validation IS NOT NULL;

-- On met à jour manuellement les id_nomenclature correspondants aux synonymes dans la nomenclature GeoNature (SINP) quand la valeur n'est pas strictement identique des 2 côtés
UPDATE ref_nomenclatures.t_synonymes s
SET
    id_nomenclature = t.id_nomenclature
    FROM
        ref_nomenclatures.t_nomenclatures t
    WHERE
          initial_value like 'Validé par%'
      AND t.cd_nomenclature = '1'
      AND t.id_type = 101
      AND s.id_type = 101;

UPDATE ref_nomenclatures.t_synonymes s
SET
    id_nomenclature = t.id_nomenclature
    FROM
        ref_nomenclatures.t_nomenclatures t
    WHERE
          initial_value like 'En cours de validation%'
      AND t.cd_nomenclature = '0'
      AND t.id_type = 101
      AND s.id_type = 101;

UPDATE ref_nomenclatures.t_synonymes s
SET
    id_nomenclature = t.id_nomenclature
    FROM
        ref_nomenclatures.t_nomenclatures t
    WHERE
          initial_value = 'Non valide'
      AND t.cd_nomenclature = '4'
      AND t.id_type = 101
      AND s.id_type = 101;


--- ### obse_confid_choi_id -> CONFID ### /!\ valeurs absente dans t_nomenclature --> ajoutées manuellement

-- On identifie d'abord les valeurs à faire correspondre dans la nomenclature de Serena
SELECT
    req.obse_confid_choi_id
  , rnf_choi.choi_nom AS confidentialite
    FROM
        (SELECT DISTINCT
             o.obse_confid_choi_id
             FROM
                 _import_serena.rnf_obse o) req
            JOIN _import_serena.rnf_choi ON req.obse_confid_choi_id = rnf_choi.choi_id;

-- On compare la liste de ces valeurs à la nomenclature SINP à réconcilier (ici: 31 = CONFID)
SELECT *
    FROM
        ref_nomenclatures.t_nomenclatures
    WHERE
        id_type = 31;

-- On ajoute ces valeurs initiales de Serena dans la table de correspondances de synonymes avec le type correspondant dans la nomenclature GeoNature (ici: 31 = CONFID)
INSERT INTO
    ref_nomenclatures.t_synonymes(id_type, initial_value)
SELECT DISTINCT
    31
  , confidentialite::text
    FROM
        _import_serena.vm_obs_serena_detail_point
    WHERE
        confidentialite IS NOT NULL;

-- Si les valeurs sont identiques des 2 côtés, on s'arrête là -> la fonction ref_nomenclatures.get_synonymes_nomenclature fera le reste lors de l'insertion dans la synthèse


--- ### obse_sex_choi_id -> SEXE ###

-- On identifie d'abord les valeurs à faire correspondre dans la nomenclature de Serena
SELECT DISTINCT
    req.obse_sex_choi_id
  , rnf_choi.choi_nom AS sexe
    FROM
        (SELECT DISTINCT
             o.obse_sex_choi_id
             FROM
                 _import_serena.rnf_obse o) req
            LEFT JOIN _import_serena.rnf_choi ON req.obse_sex_choi_id = rnf_choi.choi_id;

-- On compare la liste de ces valeurs à la nomenclature SINP à réconcilier (ici: 9 = SEXE)
SELECT *
    FROM
        ref_nomenclatures.t_nomenclatures
    WHERE
        id_type = 9;

-- On ajoute ces valeurs initiales de Serena dans la table de correspondances de synonymes avec le type correspondant dans la nomenclature GeoNature (ici: 9 = SEXE)
INSERT INTO
    ref_nomenclatures.t_synonymes(id_type, initial_value)
SELECT DISTINCT
    9
  , sexe::text
    FROM
        _import_serena.vm_obs_serena_detail_point;

-- On met à jour manuellement les id_nomenclature correspondants aux synonymes dans la nomenclature GeoNature (SINP) quand la valeur n'est pas strictement identique des 2 côtés -> la fonction ref_nomenclatures.get_synonymes_nomenclature fera le reste lors de l'insertion dans la synthèse
UPDATE ref_nomenclatures.t_synonymes s
SET
    id_nomenclature = t.id_nomenclature
    FROM
        ref_nomenclatures.t_nomenclatures t
    WHERE
          t.id_type = 9
      AND s.id_type = 9
      AND t.cd_nomenclature = '6'
      AND s.initial_value IS NULL;


--- ### obse_stade_choi_id -> STADE_VIE ###

-- On identifie d'abord les valeurs à faire correspondre dans la nomenclature de Serena
SELECT DISTINCT
    req.obse_stade_choi_id
  , rnf_choi.choi_nom AS stade_vie
    FROM
        (SELECT DISTINCT
             o.obse_stade_choi_id
             FROM
                 _import_serena.rnf_obse o) req
            JOIN _import_serena.rnf_choi ON req.obse_stade_choi_id = rnf_choi.choi_id
    ORDER BY
        stade_vie;

-- On compare la liste de ces valeurs à la nomenclature SINP à réconcilier (ici: 10 = STADE_VIE)
SELECT *
    FROM
        ref_nomenclatures.t_nomenclatures
    WHERE
        id_type = ref_nomenclatures.get_id_nomenclature_type('STADE_VIE');

-- 	/!\ Il manque la valeur 'Fruit' --> bien présente sur http://standards-sinp.mnhn.fr/nomenclature/10-stade-de-vie-stade-de-developpement-du-sujet-occurrencestadedevie-2018-05-ref_nomenclatures.get_id_nomenclature_type('METH_OBS')/ mais absente de t_nomenclatures dans GN2


-- 	/!\ Il manque les valeurs 'En fleur', 'En bouton', 'Etat végétatif' --> Absentes de la nomenclature SINP
-- On les ajoute manuellement pour le moment avec comme source "GEONATURE" et un statut "Non-validé" :
INSERT INTO
    ref_nomenclatures.t_nomenclatures( id_type
                                     , cd_nomenclature
                                     , mnemonique
                                     , label_default
                                     , definition_default
                                     , label_fr
                                     , definition_fr
                                     , source
                                     , statut
                                     , id_broader
                                     , hierarchy
                                     , meta_create_date
                                     , meta_update_date
                                     , active)
    VALUES
    ( ref_nomenclatures.get_id_nomenclature_type('STADE_VIE')
    , '28'
    , 'En bouton'
    , 'En bouton'
    , 'En bouton : L''individu est en bouton.'
    , 'En Bouton'
    , 'En bouton : L''individu est en bouton.'
    , 'GEONATURE'
    , 'Non-validé'
    , 0
    , '010' || '.' || '028'
    , now()
    , now()
    , true);
INSERT INTO
    ref_nomenclatures.t_nomenclatures( id_type
                                     , cd_nomenclature
                                     , mnemonique
                                     , label_default
                                     , definition_default
                                     , label_fr
                                     , definition_fr
                                     , source
                                     , statut
                                     , id_broader
                                     , hierarchy
                                     , meta_create_date
                                     , meta_update_date
                                     , active)
    VALUES
    ( ref_nomenclatures.get_id_nomenclature_type('STADE_VIE')
    , '29'
    , 'En fleur'
    , 'En fleur'
    , 'En fleur : L''individu est en fleur.'
    , 'En fleur'
    , 'En fleur : L''individu est en fleur.'
    , 'GEONATURE'
    , 'Non-validé'
    , 0
    , '010' || '.' || '029'
    , now()
    , now()
    , true);
INSERT INTO
    ref_nomenclatures.t_nomenclatures( id_type
                                     , cd_nomenclature
                                     , mnemonique
                                     , label_default
                                     , definition_default
                                     , label_fr
                                     , definition_fr
                                     , source
                                     , statut
                                     , id_broader
                                     , hierarchy
                                     , meta_create_date
                                     , meta_update_date
                                     , active)
    VALUES
    ( ref_nomenclatures.get_id_nomenclature_type('STADE_VIE')
    , '30'
    , 'Etat végétatif'
    , 'Etat végétatif'
    , 'Etat végétatif : L''individu est dans un stade végétatif.'
    , 'En fleur'
    , 'En fleur : L''individu est dans un stade végétatif.'
    , 'GEONATURE'
    , 'Non-validé'
    , 0
    , '010' || '.' || '030'
    , now()
    , now()
    , true);

-- On ajoute ces valeurs initiales de Serena dans la table de correspondances de synonymes avec le type correspondant dans la nomenclature GeoNature (ici: 10 = STADE_VIE)
INSERT INTO
    ref_nomenclatures.t_synonymes(id_type, initial_value)
SELECT DISTINCT
    10
  , stade_vie::text
    FROM
        _import_serena.vm_obs_serena_detail_point;

-- On met à jour manuellement les id_nomenclature correspondants aux synonymes dans la nomenclature GeoNature (SINP) quand la valeur n'est pas strictement identique des 2 côtés
UPDATE ref_nomenclatures.t_synonymes s
SET
    id_nomenclature = t.id_nomenclature
    FROM
        ref_nomenclatures.t_nomenclatures t
    WHERE
          t.id_type = ref_nomenclatures.get_id_nomenclature_type('STADE_VIE')
      AND s.id_type = ref_nomenclatures.get_id_nomenclature_type('STADE_VIE')
      AND t.cd_nomenclature = '2'
      AND s.initial_value IN ('adulte', 'Adulte', 'Imago, adulte', 'Adulte, individu mature');
UPDATE ref_nomenclatures.t_synonymes s
SET
    id_nomenclature = t.id_nomenclature
    FROM
        ref_nomenclatures.t_nomenclatures t
    WHERE
          t.id_type = ref_nomenclatures.get_id_nomenclature_type('STADE_VIE')
      AND s.id_type = ref_nomenclatures.get_id_nomenclature_type('STADE_VIE')
      AND t.cd_nomenclature = '4'
      AND s.initial_value IN ('Individu immature', 'Sub-adulte');
UPDATE ref_nomenclatures.t_synonymes s
SET
    id_nomenclature = t.id_nomenclature
    FROM
        ref_nomenclatures.t_nomenclatures t
    WHERE
          t.id_type = ref_nomenclatures.get_id_nomenclature_type('STADE_VIE')
      AND s.id_type = ref_nomenclatures.get_id_nomenclature_type('STADE_VIE')
      AND t.cd_nomenclature = '3'
      AND s.initial_value IN ('Jeune', 'Jeune non volant', 'Jeune volant, Juvénile');
UPDATE ref_nomenclatures.t_synonymes s
SET
    id_nomenclature = t.id_nomenclature
    FROM
        ref_nomenclatures.t_nomenclatures t
    WHERE
          t.id_type = ref_nomenclatures.get_id_nomenclature_type('STADE_VIE')
      AND s.id_type = ref_nomenclatures.get_id_nomenclature_type('STADE_VIE')
      AND t.cd_nomenclature = '25'
      AND s.initial_value IN ('Poussin');

UPDATE ref_nomenclatures.t_synonymes s
SET
    id_nomenclature = t.id_nomenclature
    FROM
        ref_nomenclatures.t_nomenclatures t
    WHERE
          t.id_type = ref_nomenclatures.get_id_nomenclature_type('STADE_VIE')
      AND s.id_type = ref_nomenclatures.get_id_nomenclature_type('STADE_VIE')
      AND t.cd_nomenclature = '9'
      AND s.initial_value IN ('Oeuf');
UPDATE ref_nomenclatures.t_synonymes s
SET
    id_nomenclature = t.id_nomenclature
    FROM
        ref_nomenclatures.t_nomenclatures t
    WHERE
          t.id_type = ref_nomenclatures.get_id_nomenclature_type('STADE_VIE')
      AND s.id_type = ref_nomenclatures.get_id_nomenclature_type('STADE_VIE')
      AND t.cd_nomenclature = '0'
      AND (s.initial_value IN ('xxx') OR s.initial_value IS NULL);


--- ### obse_precis_choi_id -> TYP_DENBR ###

-- On identifie d'abord les valeurs à faire correspondre dans la nomenclature de Serena
SELECT DISTINCT
    req.obse_precis_choi_id
  , rnf_choi.choi_nom AS type_denombrement
  , req.nbre
    FROM
        (SELECT
             o.obse_precis_choi_id
           , count(o.obse_id) as nbre
             FROM
                 _import_serena.rnf_obse o
             GROUP BY obse_precis_choi_id) req
            LEFT JOIN _import_serena.rnf_choi ON req.obse_precis_choi_id = rnf_choi.choi_id
    GROUP BY
        req.obse_precis_choi_id, rnf_choi.choi_nom, req.nbre;

-- On compare la liste de ces valeurs à la nomenclature SINP à réconcilier (ici: ref_nomenclatures.get_id_nomenclature_type('TYP_DENBR') = TYP_DENBR)
SELECT *
    FROM
        ref_nomenclatures.t_nomenclatures
    WHERE
        id_type = ref_nomenclatures.get_id_nomenclature_type('TYP_DENBR');

-- On ajoute ces valeurs initiales de Serena dans la table de correspondances de synonymes avec le type correspondant dans la nomenclature GeoNature (ici: ref_nomenclatures.get_id_nomenclature_type('TYP_DENBR') = TYP_DENBR)
INSERT INTO
    ref_nomenclatures.t_synonymes(id_type, initial_value)
SELECT DISTINCT
    ref_nomenclatures.get_id_nomenclature_type('TYP_DENBR')
  , statut_validation::text
    FROM
        _import_serena.vm_obs_serena_detail_point;

-- On ajoute ces valeurs initiales de Serena dans la table de correspondances de synonymes avec le type correspondant dans la nomenclature GeoNature (ici: ref_nomenclatures.get_id_nomenclature_type('TYP_DENBR') = TYP_DENBR)
INSERT INTO
    ref_nomenclatures.t_synonymes(id_type, initial_value)
SELECT DISTINCT
    ref_nomenclatures.get_id_nomenclature_type('TYP_DENBR')
  , type_denombrement::text
    FROM
        _import_serena.vm_obs_serena_detail_point;

-- On met à jour manuellement les id_nomenclature correspondants aux synonymes dans la nomenclature GeoNature (SINP) quand la valeur n'est pas strictement identique des 2 côtés
UPDATE ref_nomenclatures.t_synonymes s
SET
    id_nomenclature = t.id_nomenclature
    FROM
        ref_nomenclatures.t_nomenclatures t
    WHERE
          t.id_type = ref_nomenclatures.get_id_nomenclature_type('TYP_DENBR')
      AND s.id_type = ref_nomenclatures.get_id_nomenclature_type('TYP_DENBR')
      AND t.cd_nomenclature = 'Es'
      AND s.initial_value IN ('Ordre de grandeur', 'Sous estimation', 'Estim. par déduction', 'Précision < 10%');
UPDATE ref_nomenclatures.t_synonymes s
SET
    id_nomenclature = t.id_nomenclature
    FROM
        ref_nomenclatures.t_nomenclatures t
    WHERE
          t.id_type = ref_nomenclatures.get_id_nomenclature_type('TYP_DENBR')
      AND s.id_type = ref_nomenclatures.get_id_nomenclature_type('TYP_DENBR')
      AND t.cd_nomenclature = 'NSP'
      AND s.initial_value IS NULL;


-- ### obse_soci_choi_id --> SOCIAB ### /!\ valeurs absente dans t_nomenclature --> ajoutées manuellement

-- On identifie d'abord les valeurs à faire correspondre dans la nomenclature de Serena
SELECT DISTINCT
    req.obse_soci_choi_id
  , rnf_choi.choi_nom AS sociabilite
    FROM
        (SELECT DISTINCT
             o.obse_soci_choi_id
             FROM
                 _import_serena.rnf_obse o) req
            JOIN _import_serena.rnf_choi ON req.obse_soci_choi_id = rnf_choi.choi_id;

-- On compare la liste de ces valeurs à la nomenclature SINP à réconcilier (ici: ref_nomenclatures.get_id_nomenclature_type('SOCIAB') = SOCIAB)
SELECT *
    FROM
        ref_nomenclatures.t_nomenclatures
    WHERE
        id_type = ref_nomenclatures.get_id_nomenclature_type('SOCIAB');

-- On ajoute ces valeurs initiales de Serena dans la table de correspondances de synonymes avec le type correspondant dans la nomenclature GeoNature (ici: ref_nomenclatures.get_id_nomenclature_type('SOCIAB') = SOCIAB)
INSERT INTO
    ref_nomenclatures.t_synonymes(id_type, initial_value)
SELECT DISTINCT
    ref_nomenclatures.get_id_nomenclature_type('SOCIAB')
  , sociabilite::text
    FROM
        _import_serena.vm_obs_serena_detail_point
    WHERE
        sociabilite IS NOT NULL;

-- On met à jour manuellement les id_nomenclature correspondants aux synonymes dans la nomenclature GeoNature (SINP) quand la valeur n'est pas strictement identique des 2 côtés
UPDATE ref_nomenclatures.t_synonymes s
SET
    id_nomenclature = t.id_nomenclature
    FROM
        ref_nomenclatures.t_nomenclatures t
    WHERE
          t.id_type = ref_nomenclatures.get_id_nomenclature_type('SOCIAB')
      AND s.id_type = ref_nomenclatures.get_id_nomenclature_type('SOCIAB')
      AND t.cd_nomenclature = '3'
      AND s.initial_value IN ('2 : groupes restreints');


-- ### obse_contact_choi_id --> METH_OBS ###

-- On identifie d'abord les valeurs à faire correspondre dans la nomenclature de Serena
SELECT
    req.obse_contact_choi_id
  , rnf_choi.choi_nom AS methode_obs
    FROM
        (SELECT DISTINCT
             o.obse_contact_choi_id
             FROM
                 _import_serena.rnf_obse o) req
            JOIN _import_serena.rnf_choi ON req.obse_contact_choi_id = rnf_choi.choi_id;

-- On compare la liste de ces valeurs à la nomenclature SINP à réconcilier (ici: ref_nomenclatures.get_id_nomenclature_type('METH_OBS') = METH_OBS)
SELECT *
    FROM
        ref_nomenclatures.t_nomenclatures
    WHERE
        id_type = ref_nomenclatures.get_id_nomenclature_type('METH_OBS')
    ORDER BY
        cd_nomenclature;

-- On ajoute ces valeurs initiales de Serena dans la table de correspondances de synonymes avec le type correspondant dans la nomenclature GeoNature (ici: ref_nomenclatures.get_id_nomenclature_type('METH_OBS') = METH_OBS)
INSERT INTO
    ref_nomenclatures.t_synonymes(id_type, initial_value)
SELECT DISTINCT
    ref_nomenclatures.get_id_nomenclature_type('METH_OBS')
  , methode_obs::text
    FROM
        _import_serena.vm_obs_serena_detail_point;

-- On met à jour manuellement les id_nomenclature correspondants aux synonymes dans la nomenclature GeoNature (SINP) quand la valeur n'est pas strictement identique des 2 côtés
UPDATE ref_nomenclatures.t_synonymes s
SET
    id_nomenclature = t.id_nomenclature
    FROM
        ref_nomenclatures.t_nomenclatures t
    WHERE
          t.id_type = ref_nomenclatures.get_id_nomenclature_type('METH_OBS')
      AND s.id_type = ref_nomenclatures.get_id_nomenclature_type('METH_OBS')
      AND t.cd_nomenclature = '0'
      AND s.initial_value IN ('Individu vu', 'Individu');
UPDATE ref_nomenclatures.t_synonymes s
SET
    id_nomenclature = t.id_nomenclature
    FROM
        ref_nomenclatures.t_nomenclatures t
    WHERE
          t.id_type = ref_nomenclatures.get_id_nomenclature_type('METH_OBS')
      AND s.id_type = ref_nomenclatures.get_id_nomenclature_type('METH_OBS')
      AND t.cd_nomenclature = '1'
      AND s.initial_value IN ('Individu entendu');
UPDATE ref_nomenclatures.t_synonymes s
SET
    id_nomenclature = t.id_nomenclature
    FROM
        ref_nomenclatures.t_nomenclatures t
    WHERE
          t.id_type = ref_nomenclatures.get_id_nomenclature_type('METH_OBS')
      AND s.id_type = ref_nomenclatures.get_id_nomenclature_type('METH_OBS')
      AND t.cd_nomenclature = '6'
      AND (s.initial_value ILIKE '%déjections%' OR s.initial_value ILIKE '%fientes%' OR
           s.initial_value ILIKE '%crottier%');
UPDATE ref_nomenclatures.t_synonymes s
SET
    id_nomenclature = t.id_nomenclature
    FROM
        ref_nomenclatures.t_nomenclatures t
    WHERE
          t.id_type = ref_nomenclatures.get_id_nomenclature_type('METH_OBS')
      AND s.id_type = ref_nomenclatures.get_id_nomenclature_type('METH_OBS')
      AND t.cd_nomenclature = '4'
      AND s.initial_value ILIKE '%empreintes%';
UPDATE ref_nomenclatures.t_synonymes s
SET
    id_nomenclature = t.id_nomenclature
    FROM
        ref_nomenclatures.t_nomenclatures t
    WHERE
          t.id_type = ref_nomenclatures.get_id_nomenclature_type('METH_OBS')
      AND s.id_type = ref_nomenclatures.get_id_nomenclature_type('METH_OBS')
      AND t.cd_nomenclature = '7'
      AND s.initial_value ILIKE '%plumes%';
UPDATE ref_nomenclatures.t_synonymes s
SET
    id_nomenclature = t.id_nomenclature
    FROM
        ref_nomenclatures.t_nomenclatures t
    WHERE
          t.id_type = ref_nomenclatures.get_id_nomenclature_type('METH_OBS')
      AND s.id_type = ref_nomenclatures.get_id_nomenclature_type('METH_OBS')
      AND t.cd_nomenclature = '8'
      AND s.initial_value ILIKE '%nid%';

UPDATE ref_nomenclatures.t_synonymes s
SET
    id_nomenclature = t.id_nomenclature
    FROM
        ref_nomenclatures.t_nomenclatures t
    WHERE
          t.id_type = ref_nomenclatures.get_id_nomenclature_type('METH_OBS')
      AND s.id_type = ref_nomenclatures.get_id_nomenclature_type('METH_OBS')
      AND t.cd_nomenclature = '23'
      AND s.initial_value ILIKE '%Terrier%';
UPDATE ref_nomenclatures.t_synonymes s
SET
    id_nomenclature = t.id_nomenclature
    FROM
        ref_nomenclatures.t_nomenclatures t
    WHERE
          t.id_type = ref_nomenclatures.get_id_nomenclature_type('METH_OBS')
      AND s.id_type = ref_nomenclatures.get_id_nomenclature_type('METH_OBS')
      AND t.cd_nomenclature = '21'
      AND s.initial_value IS NULL;

-- /!\ Il manque les valeurs d'indice de précsence 'Ponte','Igloo','cavité','proie' --> Absentes de la nomenclature SINP
-- On les classes dans 'Autre' -> on conservera la valeur initiale de Serena dans le commentaire de l'occurence
UPDATE ref_nomenclatures.t_synonymes s
SET
    id_nomenclature = t.id_nomenclature
    FROM
        ref_nomenclatures.t_nomenclatures t
    WHERE
          t.id_type = ref_nomenclatures.get_id_nomenclature_type('METH_OBS')
      AND s.id_type = ref_nomenclatures.get_id_nomenclature_type('METH_OBS')
      AND t.cd_nomenclature = '20'
      AND (s.initial_value ILIKE '%ponte%' OR s.initial_value ILIKE '%cavité%' OR s.initial_value ILIKE '%igloo%' OR
           s.initial_value ILIKE '%proie%');


--- ### obse_confid_choi_id --> SENSIBILITE ###
SELECT
    req.obse_confid_choi_id
  , rnf_choi.choi_nom
    FROM
        (SELECT DISTINCT
             o.obse_confid_choi_id
             FROM
                 _import_serena.rnf_obse o) req
            join _import_serena.rnf_choi on req.obse_confid_choi_id = choi_id


INSERT INTO
    ref_nomenclatures.t_synonymes(id_type, initial_value)
SELECT DISTINCT
    ref_nomenclatures.get_id_nomenclature_type('SENSIBILITE')
  , confidentialite::text
    FROM
        _import_serena.vm_obs_serena_detail_point
ON CONFLICT DO NOTHING;

UPDATE ref_nomenclatures.t_synonymes s
SET
    id_nomenclature = t.id_nomenclature
    FROM
        ref_nomenclatures.t_nomenclatures t
    WHERE
          t.id_type = ref_nomenclatures.get_id_nomenclature_type('SENSIBILITE')
      AND s.id_type = ref_nomenclatures.get_id_nomenclature_type('SENSIBILITE')
      AND t.cd_nomenclature = '4'
      AND s.initial_value IN ('Confidentiel');

UPDATE ref_nomenclatures.t_synonymes s
SET
    id_nomenclature = t.id_nomenclature
    FROM
        ref_nomenclatures.t_nomenclatures t
    WHERE
          t.id_type = ref_nomenclatures.get_id_nomenclature_type('SENSIBILITE')
      AND s.id_type = ref_nomenclatures.get_id_nomenclature_type('SENSIBILITE')
      AND t.cd_nomenclature = '0'
      AND s.initial_value IN ('Public');

-- ### obse_contact2_choi_id --> ETA_BIO ###

-- On identifie d'abord les valeurs à faire correspondre dans la nomenclature de Serena
select
    req.obse_contact2_choi_id
  , rnf_choi.choi_nom AS etat_bio
    FROM
        (
            SELECT DISTINCT
                o.obse_contact2_choi_id
                FROM
                    _import_serena.rnf_obse o) req
            JOIN _import_serena.rnf_choi
                 ON req.obse_contact2_choi_id = rnf_choi.choi_id;


-- On compare la liste de ces valeurs à la nomenclature SINP à réconcilier (ici: 7 = ETA_BIO)
SELECT *
    FROM
        ref_nomenclatures.t_nomenclatures
    WHERE
        id_type = ref_nomenclatures.get_id_nomenclature_type('ETA_BIO')
    ORDER BY
        cd_nomenclature;


-- On ajoute ces valeurs initiales de Serena dans la table de correspondances de synonymes avec le type correspondant dans la nomenclature GeoNature (ici: 7 = ETA_BIO)
INSERT INTO
    ref_nomenclatures.t_synonymes(id_type, initial_value)
SELECT DISTINCT
    ref_nomenclatures.get_id_nomenclature_type('ETA_BIO')
  , etat_bio::text
    FROM
        _import_serena.vm_obs_serena_detail_point;

-- On met à jour manuellement les id_nomenclature correspondants aux synonymes dans la nomenclature GeoNature (SINP) quand la valeur n'est pas strictement identique des 2 côtés
UPDATE ref_nomenclatures.t_synonymes s
SET
    id_nomenclature = t.id_nomenclature
    FROM
        ref_nomenclatures.t_nomenclatures t
    WHERE
          t.id_type = ref_nomenclatures.get_id_nomenclature_type('ETA_BIO')
      AND s.id_type = ref_nomenclatures.get_id_nomenclature_type('ETA_BIO')
      AND t.cd_nomenclature = '2'
      AND s.initial_value IN ('Vu vivant');
UPDATE ref_nomenclatures.t_synonymes s
SET
    id_nomenclature = t.id_nomenclature
    FROM
        ref_nomenclatures.t_nomenclatures t
    WHERE
          t.id_type = ref_nomenclatures.get_id_nomenclature_type('ETA_BIO')
      AND s.id_type = ref_nomenclatures.get_id_nomenclature_type('ETA_BIO')
      AND t.cd_nomenclature = '1'
      AND s.initial_value IS NULL;


-- ### obse_activ_choi_id --> STATUT_BIO ###
-- ### obse_caract_choi_id --> STATUT_BIO ###/!\ Distinction de stade de reproduction absente de la nomenclature SINP (confirmée, probable, possible)

-- On identifie d'abord les valeurs à faire correspondre dans la nomenclature de Serena
(SELECT
     req.obse_activ_choi_id
   , rnf_choi.choi_nom AS statut_bio
     FROM
         (SELECT DISTINCT
              o.obse_activ_choi_id
              FROM
                  _import_serena.rnf_obse o) req
             JOIN _import_serena.rnf_choi ON req.obse_activ_choi_id = rnf_choi.choi_id)
UNION
(SELECT
     req.obse_caract_choi_id
   , rnf_choi.choi_nom AS statut_bio
     FROM
         (SELECT DISTINCT
              o.obse_caract_choi_id
              FROM
                  _import_serena.rnf_obse o) req
             JOIN _import_serena.rnf_choi ON req.obse_caract_choi_id = rnf_choi.choi_id);

-- On compare la liste de ces valeurs à la nomenclature SINP à réconcilier (ici: 13 = STATUT_BIO)
SELECT *
    FROM
        ref_nomenclatures.t_nomenclatures
    WHERE
        id_type = ref_nomenclatures.get_id_nomenclature_type('STATUT_BIO');

-- 	/!\ Il manque les valeurs 'Présence irrégulière', 'Reproduction confirmée', 'Reproduction possible', 'Reproduction probable', 'Stationnement long' --> Absentes de la nomenclature SINP
-- On les ajoute manuellement pour le moment avec comme source "GEONATURE" et un statut "Non-validé" :
INSERT INTO
    ref_nomenclatures.t_nomenclatures( id_type
                                     , cd_nomenclature
                                     , mnemonique
                                     , label_default
                                     , definition_default
                                     , label_fr
                                     , definition_fr
                                     , source
                                     , statut
                                     , id_broader
                                     , hierarchy
                                     , meta_create_date
                                     , meta_update_date
                                     , active)
    VALUES
    ( ref_nomenclatures.get_id_nomenclature_type('ETA_BIO')
    , '15'
    , 'Reproduction confirmée'
    , 'Reproduction confirmée'
    , 'Reproduction confirmée : Le stade de reproduction est confirmé chez le(s) individu(s) observé(s).'
    , 'Reproduction confirmée'
    , 'Reproduction confirmée : Le stade de reproduction est confirmé chez le(s) individu(s) observé(s).'
    , 'GEONATURE'
    , 'Non-validé'
    , 0
    , '013' || '.' || '015'
    , now()
    , now()
    , true);
INSERT INTO
    ref_nomenclatures.t_nomenclatures( id_type
                                     , cd_nomenclature
                                     , mnemonique
                                     , label_default
                                     , definition_default
                                     , label_fr
                                     , definition_fr
                                     , source
                                     , statut
                                     , id_broader
                                     , hierarchy
                                     , meta_create_date
                                     , meta_update_date
                                     , active)
    VALUES
    ( ref_nomenclatures.get_id_nomenclature_type('ETA_BIO')
    , '16'
    , 'Reproduction probable'
    , 'Reproduction probable'
    , 'Reproduction confirmée : Le stade de reproduction est probable chez le(s) individu(s) observé(s).'
    , 'Reproduction probable'
    , 'Reproduction probable : Le stade de reproduction est probable chez le(s) individu(s) observé(s).'
    , 'GEONATURE'
    , 'Non-validé'
    , 0
    , '013' || '.' || '016'
    , now()
    , now()
    , true);
INSERT INTO
    ref_nomenclatures.t_nomenclatures( id_type
                                     , cd_nomenclature
                                     , mnemonique
                                     , label_default
                                     , definition_default
                                     , label_fr
                                     , definition_fr
                                     , source
                                     , statut
                                     , id_broader
                                     , hierarchy
                                     , meta_create_date
                                     , meta_update_date
                                     , active)
    VALUES
    ( ref_nomenclatures.get_id_nomenclature_type('ETA_BIO')
    , '17'
    , 'Reproduction possible'
    , 'Reproduction possible'
    , 'Reproduction possible : Le stade de reproduction est possible chez le(s) individu(s) observé(s).'
    , 'Reproduction possible'
    , 'Reproduction possible : Le stade de reproduction est possible chez le(s) individu(s) observé(s).'
    , 'GEONATURE'
    , 'Non-validé'
    , 0
    , '013' || '.' || '017'
    , now()
    , now()
    , true);
INSERT INTO
    ref_nomenclatures.t_nomenclatures( id_type
                                     , cd_nomenclature
                                     , mnemonique
                                     , label_default
                                     , definition_default
                                     , label_fr
                                     , definition_fr
                                     , source
                                     , statut
                                     , id_broader
                                     , hierarchy
                                     , meta_create_date
                                     , meta_update_date
                                     , active)
    VALUES
    ( ref_nomenclatures.get_id_nomenclature_type('ETA_BIO')
    , '18'
    , 'Présence irrégulière'
    , 'Présence irrégulière'
    , 'Présence irrégulière : La présence de l''individu observé est pas ou peu habituelle sur le lieu d''observation.'
    , 'Présence irrégulière'
    , 'Présence irrégulière : La présence de l''individu observé est pas ou peu habituelle sur le lieu d''observation.'
    , 'GEONATURE'
    , 'Non-validé'
    , 0
    , '013' || '.' || '018'
    , now()
    , now()
    , true);
INSERT INTO
    ref_nomenclatures.t_nomenclatures( id_type
                                     , cd_nomenclature
                                     , mnemonique
                                     , label_default
                                     , definition_default
                                     , label_fr
                                     , definition_fr
                                     , source
                                     , statut
                                     , id_broader
                                     , hierarchy
                                     , meta_create_date
                                     , meta_update_date
                                     , active)
    VALUES
    ( ref_nomenclatures.get_id_nomenclature_type('ETA_BIO')
    , '19'
    , 'Stationnement long'
    , 'Stationnement long'
    , 'Stationnement long : l''individu observé est en situation de stationnement prolongé sur son lieu d''observation.'
    , 'Stationnement long'
    , 'Stationnement long : l''individu observé est en situation de stationnement prolongé sur son lieu d''observation.'
    , 'GEONATURE'
    , 'Non-validé'
    , 0
    , '013' || '.' || '019'
    , now()
    , now()
    , true);

-- On ajoute ces valeurs initiales de Serena dans la table de correspondances de synonymes avec le type correspondant dans la nomenclature GeoNature (ici: 13 = STATUT_BIO)
INSERT INTO
    ref_nomenclatures.t_synonymes(id_type, initial_value)
SELECT DISTINCT
    ref_nomenclatures.get_id_nomenclature_type('ETA_BIO')
  , statut_bio::text
    FROM
        _import_serena.vm_obs_serena_detail_point;

-- On met à jour manuellement les id_nomenclature correspondants aux synonymes dans la nomenclature GeoNature (SINP) quand la valeur n'est pas strictement identique des 2 côtés
UPDATE ref_nomenclatures.t_synonymes s
SET
    id_nomenclature = t.id_nomenclature
    FROM
        ref_nomenclatures.t_nomenclatures t
    WHERE
          t.id_type = ref_nomenclatures.get_id_nomenclature_type('ETA_BIO')
      AND s.id_type = ref_nomenclatures.get_id_nomenclature_type('ETA_BIO')
      AND t.cd_nomenclature = '12'
      AND s.initial_value ILIKE '%sédentaire%';
UPDATE ref_nomenclatures.t_synonymes s
SET
    id_nomenclature = t.id_nomenclature
    FROM
        ref_nomenclatures.t_nomenclatures t
    WHERE
          t.id_type = ref_nomenclatures.get_id_nomenclature_type('ETA_BIO')
      AND s.id_type = ref_nomenclatures.get_id_nomenclature_type('ETA_BIO')
      AND t.cd_nomenclature = '5'
      AND s.initial_value IN ('Estivage');
UPDATE ref_nomenclatures.t_synonymes s
SET
    id_nomenclature = t.id_nomenclature
    FROM
        ref_nomenclatures.t_nomenclatures t
    WHERE
          t.id_type = ref_nomenclatures.get_id_nomenclature_type('ETA_BIO')
      AND s.id_type = ref_nomenclatures.get_id_nomenclature_type('ETA_BIO')
      AND t.cd_nomenclature = '6'
      AND s.initial_value IN ('Hivernage');
UPDATE ref_nomenclatures.t_synonymes s
SET
    id_nomenclature = t.id_nomenclature
    FROM
        ref_nomenclatures.t_nomenclatures t
    WHERE
          t.id_type = ref_nomenclatures.get_id_nomenclature_type('ETA_BIO')
      AND s.id_type = ref_nomenclatures.get_id_nomenclature_type('ETA_BIO')
      AND t.cd_nomenclature = '1'
      AND s.initial_value IS NULL;


--- Recherche des correspondances natives
UPDATE ref_nomenclatures.t_synonymes s
SET
    id_nomenclature = t.id_nomenclature
    FROM
        ref_nomenclatures.t_nomenclatures t
    WHERE
          s.id_type = t.id_type
      AND s.initial_value = t.mnemonique;
--- NETTOYAGE

ALTER TABLE ref_nomenclatures.t_synonymes
    ADD id serial PRIMARY KEY;

DELETE
    FROM
        ref_nomenclatures.t_synonymes l,
 USING ref_nomenclatures.t_synonymes r
    WHERE
        l.id
      < r.id
    AND l.id_nomenclature = r.id_nomenclature
    AND l.initial_value = r.initial_value;

--DELETE SELECT * FROM ref_nomenclatures.t_synonymes  WHERE initial_value IS NULL;


UPDATE ref_nomenclatures.t_synonymes s
SET
    cd_nomenclature = t.cd_nomenclature
  , mnemonique      = t.mnemonique
  , label_default   = t.label_default
    FROM
        ref_nomenclatures.t_nomenclatures t
    WHERE
        s.id_nomenclature = t.id_nomenclature;

