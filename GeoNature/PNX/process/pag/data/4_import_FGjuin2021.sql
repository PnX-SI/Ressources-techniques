
----------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------- Faune-Guyane ----------------------------------------------
----------------------------------------------------------------------------------------------------------------------------
DROP TABLE if exists gn_imports.synthese_FGJuin2021 ;

--------------------------------------- 1/ Import des données FG
CREATE TABLE gn_imports.synthese_FGJuin2021 
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
	
COPY gn_imports.synthese_FGJuin2021 (id_synthese, id_source, id_module, entity_source_pk_value, id_dataset, id_nomenclature_geo_object_nature,
    id_nomenclature_grp_typ, grp_method, id_nomenclature_obs_technique, id_nomenclature_bio_status,
    id_nomenclature_bio_condition, id_nomenclature_naturalness, id_nomenclature_exist_proof, id_nomenclature_valid_status,
    id_nomenclature_diffusion_level, id_nomenclature_life_stage, id_nomenclature_sex, id_nomenclature_obj_count,
	id_nomenclature_type_count, count_min, count_max, cd_nom, cd_hab, nom_cite, meta_v_taxref, sample_number_proof ,
    digital_proof, non_digital_proof, altitude_min, altitude_max, depth_min, depth_max, place_name, latitude, longitude,
    id_area_attachment, date_min, date_max, validator, validation_comment, observers, determiner, id_digitiser, id_nomenclature_determination_method, comment_context, comment_description)
	FROM '/tmp/20210616_FG_juin2021.csv' WITH csv HEADER DELIMITER ';';
    
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
	place_name, the_geom_4326, the_geom_point, the_geom_local, 
	id_area_attachment, date_min, date_max, validator, validation_comment, 
	observers, determiner, id_digitiser, id_nomenclature_determination_method, 
	comment_context, comment_description)
 WITH exclusion_PAG as (SELECT st_union(st_difference(l_areas.geom, geom_pag.geometrie)) as geometrie
						FROM ref_geo.l_areas, 
							(Select st_buffer(l_areas.geom,1000) as geometrie
							 from ref_geo.l_areas 
							 WHERE l_areas.id_type in (23)
							 group by geometrie)  as geom_pag
						WHERE id_type = 25  and area_code not in ('97352', '97353', '97356', '97362'))
	SELECT uuid_generate_v4() AS unique_id_sinp_grp, id_source, id_module, entity_source_pk_value, id_dataset, 
		get_nom_corr(id_nomenclature_geo_object_nature), get_nom_corr(id_nomenclature_grp_typ), grp_method, get_nom_corr(id_nomenclature_obs_technique), 
		get_nom_corr(id_nomenclature_bio_status), get_nom_corr(id_nomenclature_bio_condition), get_nom_corr(id_nomenclature_naturalness), 
		get_nom_corr(id_nomenclature_exist_proof), get_nom_corr(id_nomenclature_valid_status),get_nom_corr(id_nomenclature_diffusion_level), 
		get_nom_corr(id_nomenclature_life_stage), get_nom_corr(id_nomenclature_sex), get_nom_corr(id_nomenclature_obj_count),
		get_nom_corr(id_nomenclature_type_count), case when count_min = 0 then 83 else 84 end ,
		get_nom_corr(171), get_nom_corr(73), get_nom_corr(122), get_nom_corr(543), get_nom_corr(175),
		count_min, count_max, cd_nom, cd_hab, nom_cite, meta_v_taxref, sample_number_proof,
		digital_proof, non_digital_proof, altitude_min, altitude_max, depth_min, depth_max, 
		place_name, ST_SetSRID(ST_MakePoint(to_number(longitude, '99D999999999999999'),to_number(latitude, '99D999999999999999')), 4326) AS geom_4326, ST_SetSRID(ST_MakePoint(to_number(longitude, '99D999999999999999'),to_number(latitude, '99D999999999999999')), 4326) AS the_geom_point, ST_Transform(ST_SetSRID(ST_MakePoint(to_number(longitude, '99D999999999999999'),to_number(latitude, '99D999999999999999')), 4326),2972)  as geom, 
		id_area_attachment, date_min, date_max, validator, validation_comment, 
		observers, determiner, 1000052, get_nom_corr(id_nomenclature_determination_method), 
		comment_context, comment_description
		FROM gn_imports.synthese_FGJuin2021 inner join exclusion_pag
		on not st_intersects(ST_Transform(ST_SetSRID(ST_MakePoint(to_number(longitude, '99D999999999999999'),to_number(latitude, '99D999999999999999')), 4326),2972), geometrie);
