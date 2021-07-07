---------------------------------------------------------------------------------------------------------
----------------------------------- Intégration des données de l'étude d'impact Rexma (Limonade)
-----------------------------------     et des données de l'étude Eryhtrine 
---------------------------------------------------------------------------------------------------------
DROP TABLE if exists gn_imports.synthese_EcobiosLimonade;
SELECT setval('gn_meta.t_datasets_id_dataset_seq', (SELECT MAX(id_dataset) FROM gn_meta.t_datasets)+1);
SELECT setval('gn_synthese.t_sources_id_source_seq', (SELECT MAX(id_source) FROM gn_synthese.t_sources)+1);
SELECT setval('utilisateurs.bib_organismes_id_organisme_seq', (SELECT MAX(id_organisme) FROM utilisateurs.bib_organismes)+1);


----------------------------------- création de la structure et de la métadonnée + source_data >> REXMA
-- organismes   ====> ecobios = 12
INSERT INTO utilisateurs.bib_organismes(nom_organisme, adresse_organisme, cp_organisme, ville_organisme) 
									VALUES('EcoBios', '', '97351', 'Matoury');
-- id_dataset ====> 45
INSERT INTO gn_meta.t_datasets(
	id_dataset, id_acquisition_framework, dataset_name, dataset_shortname, dataset_desc, 
	id_nomenclature_data_type, keywords, marine_domain, terrestrial_domain, id_nomenclature_dataset_objectif,id_nomenclature_collecting_method, 
	id_nomenclature_data_origin, id_nomenclature_source_status, id_nomenclature_resource_type, active, validable, id_digitizer)
 VALUES(45, 18, 'Etude d''impact crique Limonade (2007-2008)', 'EI Limonade (2007-2008)', 'Etude d''impact pour le permis minier REXMA de la crique Limonade **Ecobios**', 
	324, 'REXMA, Limonade, batraciens, chiroptères, mammifères, mollusques, oiseaux, poissons, reptiles, flore' , false, true, 422, 395, 
	75, 71, 320, false, false, 1000052);
INSERT INTO gn_meta.cor_dataset_actor(id_dataset, id_organism, id_nomenclature_actor_role) VALUES (45, 12, 363);
	
-- id_source ====> 57
INSERT INTO gn_synthese.t_sources(id_source, name_source, desc_source)	
	VALUES (57, 'EI Limonade (2007-2008)', 'Etude d''impact pour le permis minier REXMA de la crique Limonade **Ecobios**');


----------------------------------- création de la métadonnée + source_data >> Erythrine
-- id_dataset ====> 46
INSERT INTO gn_meta.t_datasets(
	id_dataset, id_acquisition_framework, dataset_name, dataset_shortname, dataset_desc, 
	id_nomenclature_data_type, keywords, marine_domain, terrestrial_domain, id_nomenclature_dataset_objectif,id_nomenclature_collecting_method, 
	id_nomenclature_data_origin, id_nomenclature_source_status, id_nomenclature_resource_type, active, validable, id_digitizer)
 VALUES(46, 18, 'Originalités biogéo de Saül (2009)', 'Erythrine (2009)', 'Biodiversité, espèces nouvelles et originalité biogéographique de la région de Saül : érythrine, rainette et orchidées **Ecobios**', 
	324, 'Saül, Erythrine, rainette, orchidées' , false, true, 414, 406, 
	75, 71, 320, false, false, 1000052);
INSERT INTO gn_meta.cor_dataset_actor(id_dataset, id_organism, id_nomenclature_actor_role)
	VALUES (46, 12, 363), (46, 3, 360);
	
-- id_source ====> 58
INSERT INTO gn_synthese.t_sources(id_source, name_source, desc_source)	
	VALUES (58, 'Originalités biogéo de Saül (2009)', 'Biodiversité, espèces nouvelles et originalité biogéographique de la région de Saül : érythrine, rainette et orchidées **Ecobios**');
	
SELECT setval('gn_meta.t_datasets_id_dataset_seq', (SELECT MAX(id_dataset) FROM gn_meta.t_datasets));
SELECT setval('gn_synthese.t_sources_id_source_seq', (SELECT MAX(id_source) FROM gn_synthese.t_sources));
	
--------------------------------------- 1/ Import des données Ecobios
CREATE TABLE gn_imports.synthese_EcobiosLimonade 
	(id_synthese integer,
    id_source integer,
    id_module integer,
    entity_source_pk_value character varying COLLATE pg_catalog."default",
    id_dataset integer,
    id_nomenclature_geo_object_nature integer DEFAULT gn_synthese.get_default_nomenclature_value('NAT_OBJ_GEO'::character varying),
    id_nomenclature_grp_typ integer DEFAULT gn_synthese.get_default_nomenclature_value('TYP_GRP'::character varying),
    grp_method character varying(255) COLLATE pg_catalog."default",
    id_nomenclature_obs_technique integer DEFAULT gn_synthese.get_default_nomenclature_value('METH_OBS'::character varying),
    id_nomenclature_bio_status integer DEFAULT gn_synthese.get_default_nomenclature_value('STATUT_BIO'::character varying),
    id_nomenclature_bio_condition integer DEFAULT gn_synthese.get_default_nomenclature_value('ETA_BIO'::character varying),
    id_nomenclature_naturalness integer DEFAULT gn_synthese.get_default_nomenclature_value('NATURALITE'::character varying),
    id_nomenclature_exist_proof integer DEFAULT gn_synthese.get_default_nomenclature_value('PREUVE_EXIST'::character varying),
    id_nomenclature_valid_status integer DEFAULT gn_synthese.get_default_nomenclature_value('STATUT_VALID'::character varying),
    id_nomenclature_diffusion_level integer,
    id_nomenclature_life_stage integer DEFAULT gn_synthese.get_default_nomenclature_value('STADE_VIE'::character varying),
    id_nomenclature_sex integer DEFAULT gn_synthese.get_default_nomenclature_value('SEXE'::character varying),
    id_nomenclature_obj_count integer DEFAULT gn_synthese.get_default_nomenclature_value('OBJ_DENBR'::character varying),
    id_nomenclature_type_count integer DEFAULT gn_synthese.get_default_nomenclature_value('TYP_DENBR'::character varying),
    count_min integer,
    count_max integer,
    cd_nom integer,
    cd_hab integer,
    nom_cite character varying(1000) COLLATE pg_catalog."default" NOT NULL,
	nom_cite_raccourci character varying(1000),
    meta_v_taxref character varying(50) COLLATE pg_catalog."default" DEFAULT gn_commons.get_default_parameter('taxref_version'::text, NULL::integer),
    sample_number_proof text COLLATE pg_catalog."default",
    digital_proof text COLLATE pg_catalog."default",
    non_digital_proof text COLLATE pg_catalog."default",
    altitude_min integer,
    altitude_max integer,
    depth_min integer,
    depth_max integer,
    place_name character varying(500) COLLATE pg_catalog."default",
	latitude character varying(250),
	longitude character varying(250),
    id_area_attachment integer,
    date_min timestamp without time zone NOT NULL,
    date_max timestamp without time zone NOT NULL,
    validator character varying(1000) COLLATE pg_catalog."default",
    validation_comment text COLLATE pg_catalog."default",
    observers character varying(1000) COLLATE pg_catalog."default",
    determiner character varying(1000) COLLATE pg_catalog."default",
    id_digitiser integer,
    id_nomenclature_determination_method integer DEFAULT gn_synthese.get_default_nomenclature_value('METH_DETERMIN'::character varying),
    comment_context text COLLATE pg_catalog."default",
    comment_description text COLLATE pg_catalog."default");
	
COPY gn_imports.synthese_EcobiosLimonade (id_synthese, id_source, id_module, entity_source_pk_value, id_dataset, id_nomenclature_geo_object_nature,
    id_nomenclature_grp_typ, grp_method, id_nomenclature_obs_technique, id_nomenclature_bio_status,
    id_nomenclature_bio_condition, id_nomenclature_naturalness, id_nomenclature_exist_proof, id_nomenclature_valid_status,
    id_nomenclature_diffusion_level, id_nomenclature_life_stage, id_nomenclature_sex, id_nomenclature_obj_count,
	id_nomenclature_type_count, count_min, count_max, cd_nom, cd_hab, nom_cite, nom_cite_raccourci, meta_v_taxref, sample_number_proof ,
    digital_proof, non_digital_proof, altitude_min, altitude_max, depth_min, depth_max, place_name, latitude, longitude,
    id_area_attachment, date_min, date_max, validator, validation_comment, observers, determiner, id_digitiser, id_nomenclature_determination_method, comment_context, comment_description)
	FROM '/home/geonatureadmin/Ressources-techniques/GeoNature/PNX/process/pag/integration_data/20210629_Ecobios_Limonade.csv' WITH csv HEADER DELIMITER ';';
UPDATE gn_imports.synthese_ecobioslimonade SET date_max = '2007/12/15' WHERE place_name = 'Rexma Chiro 2';
	
--------------------------------------- 2/ Injection dans la synthese

INSERT INTO gn_synthese.synthese(
	unique_id_sinp, id_source, id_module, entity_source_pk_value, id_dataset, 
	id_nomenclature_geo_object_nature, id_nomenclature_grp_typ, grp_method, id_nomenclature_obs_technique, 
	id_nomenclature_bio_status, id_nomenclature_bio_condition, id_nomenclature_naturalness, 
	id_nomenclature_exist_proof, id_nomenclature_valid_status, id_nomenclature_diffusion_level, 
	id_nomenclature_life_stage, id_nomenclature_sex, id_nomenclature_obj_count, 
	id_nomenclature_type_count, id_nomenclature_observation_status, 
	id_nomenclature_blurring, id_nomenclature_source_status, id_nomenclature_info_geo_type, 
	id_nomenclature_behaviour, id_nomenclature_biogeo_status, 
	count_min, count_max, cd_nom, cd_hab, nom_cite, meta_v_taxref, sample_number_proof, 
	digital_proof, non_digital_proof, altitude_min, altitude_max, depth_min, depth_max, 
	place_name, the_geom_4326, the_geom_local, 
	id_area_attachment, date_min, date_max, validator, validation_comment, 
	observers, determiner, id_digitiser, id_nomenclature_determination_method, 
	comment_context, comment_description)
SELECT uuid_generate_v4() AS unique_id_sinp_grp, id_source, id_module, entity_source_pk_value, id_dataset, 
	id_nomenclature_geo_object_nature, id_nomenclature_grp_typ, grp_method, id_nomenclature_obs_technique, 
	id_nomenclature_bio_status, id_nomenclature_bio_condition, id_nomenclature_naturalness, 
	id_nomenclature_exist_proof, id_nomenclature_valid_status, id_nomenclature_diffusion_level, 
	id_nomenclature_life_stage, id_nomenclature_sex, id_nomenclature_obj_count, 
	id_nomenclature_type_count, 84, 
	171,71,123, 543, 176,
	count_min, count_max, cd_nom, cd_hab, nom_cite, meta_v_taxref, sample_number_proof, 
	digital_proof, non_digital_proof, altitude_min, altitude_max, depth_min, depth_max, 
	place_name, 
	ST_Transform(tmp_localitespoly_ecobios.geom, 4326) as the_geom_4326, tmp_localitespoly_ecobios.geom as the_geom_local, 
	id_area_attachment, date_min, date_max, validator, validation_comment, 
	observers, determiner, id_digitiser, id_nomenclature_determination_method, 
	comment_context, comment_description	
		FROM gn_imports.synthese_EcobiosLimonade INNER JOIN gn_imports.tmp_localitespoly_ecobios 
			ON synthese_EcobiosLimonade.place_name = tmp_localitespoly_ecobios.lieu_name;