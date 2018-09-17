SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;


INSERT INTO gn_imports.matching_tables (id_matching_table, source_schema, source_table, target_schema, target_table, matching_comments) VALUES (1, 'gn_imports', 'testimport', 'gn_synthese', 'synthese', NULL);

INSERT INTO gn_imports.matching_fields (id_matching_field, source_field, source_default_value, target_field, target_field_type, field_comments, id_matching_table) VALUES (207, NULL, 'uuid_generate_v4()', 'unique_id_sinp', 'uuid', NULL, 1);
INSERT INTO gn_imports.matching_fields (id_matching_field, source_field, source_default_value, target_field, target_field_type, field_comments, id_matching_table) VALUES (208, NULL, 'uuid_generate_v4()', 'unique_id_sinp_grp', 'uuid', NULL, 1);
INSERT INTO gn_imports.matching_fields (id_matching_field, source_field, source_default_value, target_field, target_field_type, field_comments, id_matching_table) VALUES (219, NULL, 'gn_synthese.get_default_nomenclature_value(''PREUVE_EXIST''::character varying)', 'id_nomenclature_exist_proof', 'integer', NULL, 1);
INSERT INTO gn_imports.matching_fields (id_matching_field, source_field, source_default_value, target_field, target_field_type, field_comments, id_matching_table) VALUES (210, 'id_data', NULL, 'entity_source_pk_value', 'character varying', NULL, 1);
INSERT INTO gn_imports.matching_fields (id_matching_field, source_field, source_default_value, target_field, target_field_type, field_comments, id_matching_table) VALUES (211, 'id_lot', NULL, 'id_dataset', 'integer', NULL, 1);
INSERT INTO gn_imports.matching_fields (id_matching_field, source_field, source_default_value, target_field, target_field_type, field_comments, id_matching_table) VALUES (209, 'id_source', NULL, 'id_source', 'integer', NULL, 1);
INSERT INTO gn_imports.matching_fields (id_matching_field, source_field, source_default_value, target_field, target_field_type, field_comments, id_matching_table) VALUES (213, NULL, 'gn_synthese.get_default_nomenclature_value(''TYP_GRP''::character varying)', 'id_nomenclature_grp_typ', 'integer', NULL, 1);
INSERT INTO gn_imports.matching_fields (id_matching_field, source_field, source_default_value, target_field, target_field_type, field_comments, id_matching_table) VALUES (212, NULL, 'gn_synthese.get_default_nomenclature_value(''NAT_OBJ_GEO''::character varying)', 'id_nomenclature_geo_object_nature', 'integer', NULL, 1);
INSERT INTO gn_imports.matching_fields (id_matching_field, source_field, source_default_value, target_field, target_field_type, field_comments, id_matching_table) VALUES (214, NULL, 'gn_synthese.get_default_nomenclature_value(''METH_OBS''::character varying)', 'id_nomenclature_obs_meth', 'integer', NULL, 1);
INSERT INTO gn_imports.matching_fields (id_matching_field, source_field, source_default_value, target_field, target_field_type, field_comments, id_matching_table) VALUES (215, NULL, 'gn_synthese.get_default_nomenclature_value(''TECHNIQUE_OBS''::character varying)', 'id_nomenclature_obs_technique', 'integer', NULL, 1);
INSERT INTO gn_imports.matching_fields (id_matching_field, source_field, source_default_value, target_field, target_field_type, field_comments, id_matching_table) VALUES (217, NULL, 'gn_synthese.get_default_nomenclature_value(''ETA_BIO''::character varying)', 'id_nomenclature_bio_condition', 'integer', NULL, 1);
INSERT INTO gn_imports.matching_fields (id_matching_field, source_field, source_default_value, target_field, target_field_type, field_comments, id_matching_table) VALUES (216, NULL, 'gn_synthese.get_default_nomenclature_value(''STATUT_BIO''::character varying)', 'id_nomenclature_bio_status', 'integer', NULL, 1);
INSERT INTO gn_imports.matching_fields (id_matching_field, source_field, source_default_value, target_field, target_field_type, field_comments, id_matching_table) VALUES (218, NULL, 'gn_synthese.get_default_nomenclature_value(''NATURALITE''::character varying)', 'id_nomenclature_naturalness', 'integer', NULL, 1);
INSERT INTO gn_imports.matching_fields (id_matching_field, source_field, source_default_value, target_field, target_field_type, field_comments, id_matching_table) VALUES (220, NULL, 'gn_synthese.get_default_nomenclature_value(''STATUT_VALID''::character varying)', 'id_nomenclature_valid_status', 'integer', NULL, 1);
INSERT INTO gn_imports.matching_fields (id_matching_field, source_field, source_default_value, target_field, target_field_type, field_comments, id_matching_table) VALUES (221, NULL, 'gn_synthese.get_default_nomenclature_value(''NIV_PRECIS''::character varying)', 'id_nomenclature_diffusion_level', 'integer', NULL, 1);
INSERT INTO gn_imports.matching_fields (id_matching_field, source_field, source_default_value, target_field, target_field_type, field_comments, id_matching_table) VALUES (223, NULL, 'gn_synthese.get_default_nomenclature_value(''SEXE''::character varying)', 'id_nomenclature_sex', 'integer', NULL, 1);
INSERT INTO gn_imports.matching_fields (id_matching_field, source_field, source_default_value, target_field, target_field_type, field_comments, id_matching_table) VALUES (222, NULL, 'gn_synthese.get_default_nomenclature_value(''STADE_VIE''::character varying)', 'id_nomenclature_life_stage', 'integer', NULL, 1);
INSERT INTO gn_imports.matching_fields (id_matching_field, source_field, source_default_value, target_field, target_field_type, field_comments, id_matching_table) VALUES (224, NULL, 'gn_synthese.get_default_nomenclature_value(''OBJ_DENBR''::character varying)', 'id_nomenclature_obj_count', 'integer', NULL, 1);
INSERT INTO gn_imports.matching_fields (id_matching_field, source_field, source_default_value, target_field, target_field_type, field_comments, id_matching_table) VALUES (226, NULL, 'gn_synthese.get_default_nomenclature_value(''SENSIBILITE''::character varying)', 'id_nomenclature_sensitivity', 'integer', NULL, 1);
INSERT INTO gn_imports.matching_fields (id_matching_field, source_field, source_default_value, target_field, target_field_type, field_comments, id_matching_table) VALUES (225, NULL, 'gn_synthese.get_default_nomenclature_value(''TYP_DENBR''::character varying)', 'id_nomenclature_type_count', 'integer', NULL, 1);
INSERT INTO gn_imports.matching_fields (id_matching_field, source_field, source_default_value, target_field, target_field_type, field_comments, id_matching_table) VALUES (227, NULL, 'gn_synthese.get_default_nomenclature_value(''STATUT_OBS''::character varying)', 'id_nomenclature_observation_status', 'integer', NULL, 1);
INSERT INTO gn_imports.matching_fields (id_matching_field, source_field, source_default_value, target_field, target_field_type, field_comments, id_matching_table) VALUES (228, NULL, 'gn_synthese.get_default_nomenclature_value(''DEE_FLOU''::character varying)', 'id_nomenclature_blurring', 'integer', NULL, 1);
INSERT INTO gn_imports.matching_fields (id_matching_field, source_field, source_default_value, target_field, target_field_type, field_comments, id_matching_table) VALUES (230, NULL, 'gn_synthese.get_default_nomenclature_value(''TYP_INF_GEO''::character varying)', 'id_nomenclature_info_geo_type', 'integer', NULL, 1);
INSERT INTO gn_imports.matching_fields (id_matching_field, source_field, source_default_value, target_field, target_field_type, field_comments, id_matching_table) VALUES (229, NULL, 'gn_synthese.get_default_nomenclature_value(''STATUT_SOURCE''::character varying)', 'id_nomenclature_source_status', 'integer', NULL, 1);
INSERT INTO gn_imports.matching_fields (id_matching_field, source_field, source_default_value, target_field, target_field_type, field_comments, id_matching_table) VALUES (233, 'cd_nom', NULL, 'cd_nom', 'integer', NULL, 1);
INSERT INTO gn_imports.matching_fields (id_matching_field, source_field, source_default_value, target_field, target_field_type, field_comments, id_matching_table) VALUES (237, NULL, 'NULL', 'digital_proof', 'text', NULL, 1);
INSERT INTO gn_imports.matching_fields (id_matching_field, source_field, source_default_value, target_field, target_field_type, field_comments, id_matching_table) VALUES (238, NULL, 'NULL', 'non_digital_proof', 'text', NULL, 1);
INSERT INTO gn_imports.matching_fields (id_matching_field, source_field, source_default_value, target_field, target_field_type, field_comments, id_matching_table) VALUES (239, 'altitude_retenue', NULL, 'altitude_min', 'integer', NULL, 1);
INSERT INTO gn_imports.matching_fields (id_matching_field, source_field, source_default_value, target_field, target_field_type, field_comments, id_matching_table) VALUES (240, 'altitude_retenue', NULL, 'altitude_max', 'integer', NULL, 1);
INSERT INTO gn_imports.matching_fields (id_matching_field, source_field, source_default_value, target_field, target_field_type, field_comments, id_matching_table) VALUES (244, 'dateobs', NULL, 'date_min', 'timestamp without time zone', NULL, 1);
INSERT INTO gn_imports.matching_fields (id_matching_field, source_field, source_default_value, target_field, target_field_type, field_comments, id_matching_table) VALUES (245, 'dateobs', NULL, 'date_max', 'timestamp without time zone', NULL, 1);
INSERT INTO gn_imports.matching_fields (id_matching_field, source_field, source_default_value, target_field, target_field_type, field_comments, id_matching_table) VALUES (246, NULL, 'NULL', 'validator', 'character varying', NULL, 1);
INSERT INTO gn_imports.matching_fields (id_matching_field, source_field, source_default_value, target_field, target_field_type, field_comments, id_matching_table) VALUES (248, NULL, 'NULL', 'observers', 'character varying', NULL, 1);
INSERT INTO gn_imports.matching_fields (id_matching_field, source_field, source_default_value, target_field, target_field_type, field_comments, id_matching_table) VALUES (247, NULL, 'NULL', 'validation_comment', 'text', NULL, 1);
INSERT INTO gn_imports.matching_fields (id_matching_field, source_field, source_default_value, target_field, target_field_type, field_comments, id_matching_table) VALUES (250, NULL, 'gn_synthese.get_default_nomenclature_value(''METH_DETERMIN''::character varying)', 'id_nomenclature_determination_method', 'integer', NULL, 1);
INSERT INTO gn_imports.matching_fields (id_matching_field, source_field, source_default_value, target_field, target_field_type, field_comments, id_matching_table) VALUES (252, NULL, 'now()', 'meta_validation_date', 'timestamp without time zone', NULL, 1);
INSERT INTO gn_imports.matching_fields (id_matching_field, source_field, source_default_value, target_field, target_field_type, field_comments, id_matching_table) VALUES (253, NULL, 'now()', 'meta_create_date', 'timestamp without time zone', NULL, 1);
INSERT INTO gn_imports.matching_fields (id_matching_field, source_field, source_default_value, target_field, target_field_type, field_comments, id_matching_table) VALUES (254, NULL, 'now()', 'meta_update_date', 'timestamp without time zone', NULL, 1);
INSERT INTO gn_imports.matching_fields (id_matching_field, source_field, source_default_value, target_field, target_field_type, field_comments, id_matching_table) VALUES (255, NULL, '''c''', 'last_action', 'character', NULL, 1);
INSERT INTO gn_imports.matching_fields (id_matching_field, source_field, source_default_value, target_field, target_field_type, field_comments, id_matching_table) VALUES (235, NULL, 'gn_commons.get_default_parameter(''taxref_version'',NULL)::character varying', 'meta_v_taxref', 'character varying', NULL, 1);
INSERT INTO gn_imports.matching_fields (id_matching_field, source_field, source_default_value, target_field, target_field_type, field_comments, id_matching_table) VALUES (251, 'remarques', NULL, 'comments', 'text', NULL, 1);
INSERT INTO gn_imports.matching_fields (id_matching_field, source_field, source_default_value, target_field, target_field_type, field_comments, id_matching_table) VALUES (231, 'effectif_total', NULL, 'count_min', 'integer', NULL, 1);
INSERT INTO gn_imports.matching_fields (id_matching_field, source_field, source_default_value, target_field, target_field_type, field_comments, id_matching_table) VALUES (232, 'effectif_total', NULL, 'count_max', 'integer', NULL, 1);
INSERT INTO gn_imports.matching_fields (id_matching_field, source_field, source_default_value, target_field, target_field_type, field_comments, id_matching_table) VALUES (249, NULL, 'u.nom_role || '' '' || u.prenom_role', 'determiner', 'character varying', NULL, 1);
INSERT INTO gn_imports.matching_fields (id_matching_field, source_field, source_default_value, target_field, target_field_type, field_comments, id_matching_table) VALUES (234, 'taxon_saisi', NULL, 'nom_cite', 'character varying', NULL, 1);

INSERT INTO gn_imports.matching_geoms (id_matching_geom, source_x_field, source_y_field, source_geom_field, source_geom_format, source_srid, target_geom_field, target_geom_srid, geom_comments, id_matching_table) VALUES (1, 'x', 'y', NULL, 'xy', 2154, 'the_geom_local', 2154, NULL, 1);
INSERT INTO gn_imports.matching_geoms (id_matching_geom, source_x_field, source_y_field, source_geom_field, source_geom_format, source_srid, target_geom_field, target_geom_srid, geom_comments, id_matching_table) VALUES (2, NULL, NULL, 'POINT(6.064544 44.28787)', 'wkt', 4326, 'the_geom_4326', 4326, NULL, 1);


SELECT pg_catalog.setval('gn_imports.matching_fields_id_matching_field_seq', 255, true);
SELECT pg_catalog.setval('gn_imports.matching_geoms_id_matching_geom_seq', 2, true);
SELECT pg_catalog.setval('gn_imports.matching_tables_id_matching_table_seq', 7, true);

---------------
--IMPORT DATA--
---------------
--autogenerated query
INSERT INTO gn_synthese.synthese(
unique_id_sinp
,unique_id_sinp_grp
,id_nomenclature_exist_proof
,entity_source_pk_value
,id_dataset
,id_source
,id_nomenclature_grp_typ
,id_nomenclature_geo_object_nature
,id_nomenclature_obs_meth
,id_nomenclature_obs_technique
,id_nomenclature_bio_condition
,id_nomenclature_bio_status
,id_nomenclature_naturalness
,id_nomenclature_valid_status
,id_nomenclature_diffusion_level
,id_nomenclature_sex
,id_nomenclature_life_stage
,id_nomenclature_obj_count
,id_nomenclature_sensitivity
,id_nomenclature_type_count
,id_nomenclature_observation_status
,id_nomenclature_blurring
,id_nomenclature_info_geo_type
,id_nomenclature_source_status
,cd_nom
,digital_proof
,non_digital_proof
,altitude_min
,altitude_max
,date_min
,date_max
,validator
,observers
,validation_comment
,id_nomenclature_determination_method
,meta_validation_date
,meta_create_date
,meta_update_date
,last_action
,meta_v_taxref
,comments
,count_min
,count_max
,determiner
,nom_cite
,the_tgeom_local
,the_geom_4326
)
 SELECT 
uuid_generate_v4()::uuid AS unique_id_sinp
,uuid_generate_v4()::uuid AS unique_id_sinp_grp
,gn_synthese.get_default_nomenclature_value('PREUVE_EXIST'::character varying)::integer AS id_nomenclature_exist_proof
,a.id_data::character varying AS entity_source_pk_value
,a.id_lot::integer AS id_dataset
,a.id_source::integer AS id_source
,gn_synthese.get_default_nomenclature_value('TYP_GRP'::character varying)::integer AS id_nomenclature_grp_typ
,gn_synthese.get_default_nomenclature_value('NAT_OBJ_GEO'::character varying)::integer AS id_nomenclature_geo_object_nature
,gn_synthese.get_default_nomenclature_value('METH_OBS'::character varying)::integer AS id_nomenclature_obs_meth
,gn_synthese.get_default_nomenclature_value('TECHNIQUE_OBS'::character varying)::integer AS id_nomenclature_obs_technique
,gn_synthese.get_default_nomenclature_value('ETA_BIO'::character varying)::integer AS id_nomenclature_bio_condition
,gn_synthese.get_default_nomenclature_value('STATUT_BIO'::character varying)::integer AS id_nomenclature_bio_status
,gn_synthese.get_default_nomenclature_value('NATURALITE'::character varying)::integer AS id_nomenclature_naturalness
,gn_synthese.get_default_nomenclature_value('STATUT_VALID'::character varying)::integer AS id_nomenclature_valid_status
,gn_synthese.get_default_nomenclature_value('NIV_PRECIS'::character varying)::integer AS id_nomenclature_diffusion_level
,gn_synthese.get_default_nomenclature_value('SEXE'::character varying)::integer AS id_nomenclature_sex
,gn_synthese.get_default_nomenclature_value('STADE_VIE'::character varying)::integer AS id_nomenclature_life_stage
,gn_synthese.get_default_nomenclature_value('OBJ_DENBR'::character varying)::integer AS id_nomenclature_obj_count
,gn_synthese.get_default_nomenclature_value('SENSIBILITE'::character varying)::integer AS id_nomenclature_sensitivity
,gn_synthese.get_default_nomenclature_value('TYP_DENBR'::character varying)::integer AS id_nomenclature_type_count
,gn_synthese.get_default_nomenclature_value('STATUT_OBS'::character varying)::integer AS id_nomenclature_observation_status
,gn_synthese.get_default_nomenclature_value('DEE_FLOU'::character varying)::integer AS id_nomenclature_blurring
,gn_synthese.get_default_nomenclature_value('TYP_INF_GEO'::character varying)::integer AS id_nomenclature_info_geo_type
,gn_synthese.get_default_nomenclature_value('STATUT_SOURCE'::character varying)::integer AS id_nomenclature_source_status
,a.cd_nom::integer AS cd_nom
,NULL::text AS digital_proof
,NULL::text AS non_digital_proof
,a.altitude_retenue::integer AS altitude_min
,a.altitude_retenue::integer AS altitude_max
,a.dateobs::timestamp without time zone AS date_min
,a.dateobs::timestamp without time zone AS date_max
,NULL::character varying AS validator
,NULL::character varying AS observers
,NULL::text AS validation_comment
,gn_synthese.get_default_nomenclature_value('METH_DETERMIN'::character varying)::integer AS id_nomenclature_determination_method
,now()::timestamp without time zone AS meta_validation_date
,now()::timestamp without time zone AS meta_create_date
,now()::timestamp without time zone AS meta_update_date
,'c'::character AS last_action
,gn_commons.get_default_parameter('taxref_version',NULL)::character varying::character varying AS meta_v_taxref
,a.remarques::text AS comments
,a.effectif_total::integer AS count_min
,a.effectif_total::integer AS count_max
,u.nom_role || ' ' || u.prenom_role::character varying AS determiner
,a.taxon_saisi::character varying AS nom_cite
,ST_Transform(ST_GeomFromText('POINT('|| x || ' ' || y ||')', 2154), 2154)
,ST_Transform(ST_GeomFromText('POINT(6.064544 44.28787)', 4326), 4326)
FROM gn_imports.testimport a
--self addition
LEFT JOIN utilisateurs.t_roles u ON u.id_role = a.observateurs::integer

--autogenerated query
INSERT INTO gn_synthese.cor_observer_synthese(
id_role
,id_synthese
)
 SELECT 
a.observateurs::integer AS id_role
,s.id_synthese::integer AS id_synthese
FROM gn_imports.testimport a
--self addition
JOIN gn_synthese.synthese s ON s.entity_source_pk_value::integer = a.id_data
WHERE s.id_source = 13;
;
