-- en cours !!!!!!!!!!!!!!! 

    ALTER TABLE gn_synthese.synthese
      DROP CONSTRAINT IF EXISTS check_synthese_info_geo_type_id_area_attachment;
 
-- synthese
INSERT INTO gn_synthese.synthese (
  unique_id_sinp, -- uuid,
  unique_id_sinp_grp, -- uuid,
  id_source, --integer,
  entity_source_pk_value, --character varying,
  id_dataset, --integer,
  id_nomenclature_geo_object_nature, --integer DEFAULT gn_synthese.get_default_nomenclature_value(3), -- Correspondance nomenclature INPN = nat_obj_geo = 3
  id_nomenclature_grp_typ, --integer DEFAULT gn_synthese.get_default_nomenclature_value(24), -- Correspondance nomenclature INPN = typ_grp = 24
--   id_nomenclature_obs_meth, --integer DEFAULT gn_synthese.get_default_nomenclature_value(14), -- Correspondance nomenclature INPN = methode_obs = 14
  id_nomenclature_obs_technique, --integer DEFAULT gn_synthese.get_default_nomenclature_value(100), -- Correspondance nomenclature CAMPANULE = technique_obs = 100
  id_nomenclature_bio_status, --integer DEFAULT gn_synthese.get_default_nomenclature_value(13), -- Correspondance nomenclature INPN = statut_bio = 13
  id_nomenclature_bio_condition, --integer DEFAULT gn_synthese.get_default_nomenclature_value(7), -- Correspondance nomenclature INPN = etat_bio = 7
  id_nomenclature_naturalness, --integer DEFAULT gn_synthese.get_default_nomenclature_value(8), -- Correspondance nomenclature INPN = naturalite = 8
  id_nomenclature_exist_proof, --integer DEFAULT gn_synthese.get_default_nomenclature_value(15), -- Correspondance nomenclature INPN = preuve_exist = 15
  id_nomenclature_valid_status, --integer DEFAULT gn_synthese.get_default_nomenclature_value(101), -- Correspondance nomenclature GEONATURE = statut_valide = 101
  id_nomenclature_diffusion_level, --integer DEFAULT gn_synthese.get_default_nomenclature_value(5), -- Correspondance nomenclature INPN = niv_precis = 5
  id_nomenclature_life_stage, --integer DEFAULT gn_synthese.get_default_nomenclature_value(10), -- Correspondance nomenclature INPN = stade_vie = 10
  id_nomenclature_sex, --integer DEFAULT gn_synthese.get_default_nomenclature_value(9), -- Correspondance nomenclature INPN = sexe = 9
  id_nomenclature_obj_count, --integer DEFAULT gn_synthese.get_default_nomenclature_value(6), -- Correspondance nomenclature INPN = obj_denbr = 6
  id_nomenclature_type_count, --integer DEFAULT gn_synthese.get_default_nomenclature_value(21), -- Correspondance nomenclature INPN = typ_denbr = 21
  id_nomenclature_sensitivity, --integer DEFAULT gn_synthese.get_default_nomenclature_value(16), -- Correspondance nomenclature INPN = sensibilite = 16
  id_nomenclature_observation_status, --integer DEFAULT gn_synthese.get_default_nomenclature_value(18), -- Correspondance nomenclature INPN = statut_obs = 18
  id_nomenclature_blurring, --integer DEFAULT gn_synthese.get_default_nomenclature_value(4), -- Correspondance nomenclature INPN = dee_flou = 4
  id_nomenclature_source_status, --integer DEFAULT gn_synthese.get_default_nomenclature_value(19), -- Correspondance nomenclature INPN = statut_source = 19
  id_nomenclature_info_geo_type, --integer DEFAULT gn_synthese.get_default_nomenclature_value(23), -- Correspondance nomenclature INPN = typ_inf_geo = 23
  count_min, --integer,
  count_max, --integer,
  cd_nom, --integer,
  nom_cite, -- character varying(255) NOT NULL,
  meta_v_taxref, -- character varying(50) DEFAULT 'SELECT gn_commons.get_default_parameter(''taxref_version'',NULL)'::character varying,
  sample_number_proof, -- text,
  digital_proof, -- text,
  non_digital_proof, -- text,
  altitude_min, --integer,
  altitude_max, --integer,
  the_geom_4326, -- geometry(Geometry,4326),
  the_geom_point, -- geometry(Point,4326),
  the_geom_local, -- geometry(Geometry,2154),
  date_min, -- date NOT NULL,
  date_max, -- date NOT NULL,
  validator, -- character varying(1000),
  validation_comment, -- text,
  observers, -- character varying(1000),
  determiner, -- character varying(1000),
  id_nomenclature_determination_method, -- character varying(20),
  comment_description, -- text,
  comment_context, -- text,
  meta_validation_date, -- timestamp without time zone DEFAULT now(),
  meta_create_date, -- timestamp without time zone DEFAULT now(),
  meta_update_date, -- timestamp without time zone DEFAULT now(),
  last_action -- character(1)
 )
WITH
s AS (SELECT * FROM v1_compat.syntheseff WHERE supprime = false)
SELECT
      uuid_generate_v4() as unique_id_sinp
    , uuid_generate_v4() as unique_id_sinp_grp
    , s.id_source as id_source
    , s.id_fiche_source as entity_source_pk_value
    , s.id_lot as id_dataset
    , COALESCE(
       v1_compat.get_synonyme_id_nomenclature('NAT_GEO', 'id_precision', s.id_precision), --n3
       ref_nomenclatures.get_id_nomenclature('NAT_OBJ_GEO','NSP')
    ) AS id_nomenclature_geo_object_nature
    , COALESCE(
        v1_compat.get_synonyme_id_nomenclature('TYP_GRP', 'id_lot', s.id_lot), -- n24
        ref_nomenclatures.get_id_nomenclature('TYP_GRP','NSP')
    ) AS id_nomenclature_grp_typ
    , COALESCE(
        v1_compat.get_synonyme_id_nomenclature('METH_OBS', 'id_critere_synthese', s.id_critere_synthese), -- n14
        ref_nomenclatures.get_id_nomenclature('METH_OBS','21')
    ) AS id_nomenclature_obs_technique --id_nomenclature_obs_meth 
    -- , COALESCE(
    --     v1_compat.get_synonyme_id_nomenclature('TECHNIQUE_OBS', 'id_critere_synthese', s.id_critere_synthese), --n100
    --     ref_nomenclatures.get_id_nomenclature('TECHNIQUE_OBS','000000') --- ??????
    -- ) AS id_nomenclature_obs_technique
    , COALESCE(
        v1_compat.get_synonyme_id_nomenclature('STATUT_BIO', 'id_critere_synthese', s.id_critere_synthese), --n13
        ref_nomenclatures.get_id_nomenclature('STATUT_BIO','0')
    ) AS id_nomenclature_bio_status
    , COALESCE(
        v1_compat.get_synonyme_id_nomenclature('ETA_BIO', 'id_critere_synthese', s.id_critere_synthese), -- n7
        ref_nomenclatures.get_id_nomenclature('ETA_BIO','1')
    ) AS id_nomenclature_bio_condition
    , COALESCE(
        v1_compat.get_synonyme_id_nomenclature('NATURALITE', 'id_lot', id_lot), -- n8
        ref_nomenclatures.get_id_nomenclature('NATURALITE','1')
    ) AS id_nomenclature_naturalness
    , COALESCE(
        v1_compat.get_synonyme_id_nomenclature('PREUVE_EXIST', 'id_lot', id_lot), -- n15
        ref_nomenclatures.get_id_nomenclature('PREUVE_EXIST','0')
    ) AS id_nomenclature_exist_proof
    , COALESCE(
        v1_compat.get_synonyme_id_nomenclature('STATUT_VALID', 'id_source', id_source),--n101
        ref_nomenclatures.get_id_nomenclature('STATUT_VALID','6')
    ) AS id_nomenclature_valid_status
    , COALESCE(
        v1_compat.get_synonyme_id_nomenclature('NIV_PRECIS', 'id_source', id_source),--n5
        ref_nomenclatures.get_id_nomenclature('NIV_PRECIS','4')
        ) AS id_nomenclature_diffusion_level
    , COALESCE(
        v1_compat.get_synonyme_id_nomenclature('STADE_VIE', 'id_source', id_source),--n10
        ref_nomenclatures.get_id_nomenclature('STADE_VIE','0')
    ) AS id_nomenclature_life_stage
    , COALESCE(
        v1_compat.get_synonyme_id_nomenclature('SEXE', 'id_source', id_source),--n9,
        ref_nomenclatures.get_id_nomenclature('SEXE','6')
    ) AS id_nomenclature_sex
    , COALESCE(
        v1_compat.get_synonyme_id_nomenclature('OBJ_DENBR', 'id_source', id_source), --n6,
        ref_nomenclatures.get_id_nomenclature('OBJ_DENBR','NSP')
    ) AS id_nomenclature_obj_count
    , COALESCE(
        v1_compat.get_synonyme_id_nomenclature('TYP_DENBR', 'id_source', id_source), --n21,
        ref_nomenclatures.get_id_nomenclature('TYP_DENBR','NSP')
        ) AS id_nomenclature_type_count
    , NULL AS id_nomenclature_sensitivity
    , ref_nomenclatures.get_id_nomenclature('STATUT_OBS','Pr') AS id_nomenclature_observation_status
    , ref_nomenclatures.get_id_nomenclature('DEE_FLOU','NON') AS id_nomenclature_blurring
    , COALESCE(
        v1_compat.get_synonyme_id_nomenclature('STATUT_SOURCE', 'id_source', id_source), --n19,
        ref_nomenclatures.get_id_nomenclature('STATUT_SOURCE','NSP')
    ) AS id_nomenclature_source_status
    , COALESCE(
        v1_compat.get_synonyme_id_nomenclature('TYP_INF_GEO', 'id_precision', id_precision), --n23,
        ref_nomenclatures.get_id_nomenclature('TYP_INF_GEO','1')
    ) AS id_nomenclature_info_geo_type
    , COALESCE(s.effectif_total, -1) AS count_min
    , COALESCE(s.effectif_total, -1) AS count_max
    , s.cd_nom
    , 'aucun' AS nom_cite -- voir avec la source
    , 'Taxref V11' AS meta_v_taxref
    , NULL AS sample_number_proof
    , NULL AS digital_proof
    , NULL AS non_digital_proof
    , s.altitude_retenue AS altitude_min
    , s.altitude_retenue AS altitude_max --voir si besoin de faire des calculs pour les polygones et les lignes
    , st_transform(s.the_geom_3857, 4326) AS the_geom_4326
    , st_transform(s.the_geom_point, 4326) AS the_geom_point
    , st_transform(s.the_geom_local, :srid_local) AS the_geon_local
    , s.dateobs AS date_min
    , s.dateobs AS date_max
    , NULL AS validator
    , NULL AS validation_comment
    , observateurs AS observers
    , determinateur AS determiner
    , NULL AS id_nomenclature_determination_method --TODO
    , s.remarques AS comments
    , concat('old_id_synthese : ',s.id_synthese)
    , NULL AS meta_validation_date
    , date_insert AS meta_create_date
    , date_update AS meta_update_date
    , derniere_action AS last_action
FROM s
-- LEFT JOIN n3 ON s.id_precision = n3.pk_source
-- LEFT JOIN n24 ON s.id_lot = n24.pk_source
-- LEFT JOIN n14 ON s.id_critere_synthese = n14.pk_source
--LEFT JOIN n100 ON s.id_critere_synthese = n100.pk_source
-- LEFT JOIN n13 ON s.id_critere_synthese = n13.pk_source
-- LEFT JOIN n7 ON s.id_critere_synthese = n7.pk_source
-- LEFT JOIN n8 ON s.id_lot = n8.pk_source
-- LEFT JOIN n15 ON s.id_lot = n15.pk_source
-- LEFT JOIN n101 ON s.id_source = n101.pk_source
-- LEFT JOIN n5 ON s.id_source = n5.pk_source
-- LEFT JOIN n10 ON s.id_source = n10.pk_source
-- LEFT JOIN n9 ON s.id_source = n9.pk_source
-- LEFT JOIN n6 ON s.id_source = n6.pk_source
-- LEFT JOIN n21 ON s.id_source = n21.pk_source
-- LEFT JOIN n19 ON s.id_source = n19.pk_source
-- LEFT JOIN n23 ON s.id_precision = n23.pk_source
-- LEFT JOIN taxonomie.taxref t ON t.cd_nom = s.cd_nom;


-- TODO user