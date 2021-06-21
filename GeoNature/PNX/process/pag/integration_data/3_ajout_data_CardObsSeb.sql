------------------- Injection données CardObs Seb


--1- Injection des relevés
INSERT INTO pr_occtax.t_releves_occtax(
	id_releve_occtax, unique_id_sinp_grp, id_dataset, id_digitiser, observers_txt, 
	id_nomenclature_tech_collect_campanule, id_nomenclature_grp_typ, grp_method, 
	date_min, date_max, place_name, meta_device_entry, 
	comment, geom_local, geom_4326, 
	id_nomenclature_geo_object_nature, "precision")
SELECT id_releve_occtax, uuid_generate_v4() AS unique_id_sinp_grp, id_dataset, id_digitiser, observers_txt, 
	id_nomenclature_tech_collect_campanule, id_nomenclature_grp_typ, grp_method, 
	TO_DATE(date_min, 'DD/MM/YYYY'), TO_DATE(date_max, 'DD/MM/YYYY'),  place_name, meta_device_entry, 
	comment, ST_Transform(ST_SetSRID(ST_MakePoint(to_number(longitude, '99D999999999999999'),to_number(latitude, '99D999999999999999')), 4326),2972)  as geom, ST_SetSRID(ST_MakePoint(to_number(longitude, '99D999999999999999'),to_number(latitude, '99D999999999999999')), 4326) AS geom_4326,
	id_nomenclature_geo_object_nature, "precision"
	FROM gn_imports.t_releves_cardobsseb
		order by id_releve_occtax;
SELECT setval('pr_occtax.t_releves_occtax_id_releve_occtax_seq', (SELECT MAX(id_releve_occtax) FROM pr_occtax.t_releves_occtax)+1);


INSERT INTO pr_occtax.cor_role_releves_occtax(unique_id_cor_role_releve, id_releve_occtax, id_role)
	SELECT uuid_generate_v4() as unique_id_cor_role_releve,id_releve_occtax, 1000016 from gn_imports.t_releves_cardobsseb;


--2- Injection des occurrences
INSERT INTO pr_occtax.t_occurrences_occtax(
	id_occurrence_occtax, unique_id_occurence_occtax, id_releve_occtax, 
	id_nomenclature_obs_technique, id_nomenclature_bio_condition, id_nomenclature_bio_status, 
	id_nomenclature_naturalness, id_nomenclature_exist_proof, id_nomenclature_diffusion_level, 
	id_nomenclature_observation_status, id_nomenclature_blurring, id_nomenclature_source_status, 
	id_nomenclature_behaviour, determiner, id_nomenclature_determination_method, cd_nom, nom_cite, 
	meta_v_taxref, sample_number_proof, digital_proof, comment)
SELECT id_occurrence_occtax, uuid_generate_v4() AS unique_id_occurence_occtax, id_releve_occtax, 
	37, id_nomenclature_bio_condition, id_nomenclature_bio_status, 
	id_nomenclature_naturalness, id_nomenclature_exist_proof, id_nomenclature_diffusion_level, 
	id_nomenclature_observation_status, id_nomenclature_blurring, id_nomenclature_source_status, 
	id_nomenclature_behaviour, determiner, id_nomenclature_determination_method, cd_nom, nom_cite, 
	meta_v_taxref, sample_number_proof, digital_proof, comment
	FROM gn_imports.t_occurrences_cardobsseb;
SELECT setval('pr_occtax.t_occurrences_occtax_id_occurrence_occtax_seq', (SELECT MAX(id_occurrence_occtax) FROM pr_occtax.t_occurrences_occtax)+1);


--3- Injection des décomptes
INSERT INTO pr_occtax.cor_counting_occtax(id_counting_occtax, unique_id_sinp_occtax, id_occurrence_occtax, 
										  id_nomenclature_life_stage, id_nomenclature_sex, 
										  id_nomenclature_obj_count, id_nomenclature_type_count, 
										  count_min, count_max)
	SELECT num + 4407 as id_counting_occtax, uuid_generate_v4() AS unique_id_sinp_occtax, id_occurrence_occtax , 
			id_nomenclature_life_stage, id_nomenclature_sex, 
			id_nomenclature_obj_count, id_nomenclature_type_count,
			count_min ,count_max
	from gn_imports.cor_counting_cardobsseb;
SELECT setval('pr_occtax.cor_counting_occtax_id_counting_occtax_seq', (SELECT MAX(id_counting_occtax) FROM pr_occtax.cor_counting_occtax)+1);


-------------------------------------- Corrections
-- Tout ce qui est hors Saül parmis ce qui est pointé vers 
UPDATE gn_synthese.synthese
	SET id_source = 39, id_dataset = 2 	where not ST_Intersects((select l_areas.geom from ref_geo.l_areas where id_area= 14), the_geom_local) and id_dataset in (42,43,44);
UPDATE gn_synthese.synthese
	SET id_source = 53 	where ST_Intersects((select l_areas.geom from ref_geo.l_areas where id_area= 14), the_geom_local) and id_dataset = 42;
UPDATE gn_synthese.synthese
	SET id_source = 54 	where ST_Intersects((select l_areas.geom from ref_geo.l_areas where id_area= 14), the_geom_local) and id_dataset = 43;
UPDATE gn_synthese.synthese
	SET id_source = 55 	where ST_Intersects((select l_areas.geom from ref_geo.l_areas where id_area= 14), the_geom_local) and id_dataset = 44;