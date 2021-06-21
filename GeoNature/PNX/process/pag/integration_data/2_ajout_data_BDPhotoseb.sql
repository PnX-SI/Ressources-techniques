------------------- Injection BD photo seb

------------------- Injection BD photo seb

UPDATE gn_imports.tmp_localiteslignes_seb SET  localite = 'Saül, sentier Grand Boeuf Mort' WHERE localite = 'Saül, sentier Grand Buf Mort';
UPDATE gn_imports.tmp_localiteslignes_seb SET  localite = 'Saül, sentier Grand Boeuf Mort, crique Roche' WHERE localite = 'Saül, sentier Grand Buf Mort, crique Roche';
UPDATE gn_imports.tmp_localiteslignes_seb SET  localite = 'Saül, crête entre le Belvédère de la Montagne Pelée et le sentier Grand Boeuf Mort' WHERE localite = 'Saül, crête entre le Belvédère de la Montagne Pelée et le sentier Grand Buf Mort';
UPDATE gn_imports.t_releves_basephotoseb SET place_name = 'Saül, crête entre le Belvédère de la Montagne Pelée et le sentier Grand Boeuf Mort' WHERE place_name = 'Saül, crête entre le Belvédère de la Montagne Pelée et le sentier Grand Bœuf Mort';
UPDATE gn_imports.t_releves_basephotoseb SET place_name = 'Saül, sentier Grand Boeuf Mort, crique Roche' WHERE place_name = 'Saül, sentier Grand Bœuf Mort, crique Roche';
UPDATE gn_imports.t_releves_basephotoseb SET date_min=replace(date_min,'‎', '' );
UPDATE gn_imports.t_releves_basephotoseb SET date_max=replace(date_max,'‎', '' );
UPDATE gn_imports.t_medias_basephotoseb SET description_fr =replace(description_fr,'‎', '' );
UPDATE gn_imports.t_medias_basephotoseb SET media_path =replace(media_path,'‎', '' );


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
	comment, geom, ST_TRANSFORM(geom, 4326) AS geom_4326,
	id_nomenclature_geo_object_nature, "precision"
	FROM gn_imports.t_releves_basephotoseb
		INNER JOIN (SELECT localite, saul, entite_geo, geom
			FROM gn_imports.tmp_localiteslignes_seb
			UNION SELECT localite, saul, entite_geo, geom
				FROM gn_imports.tmp_localitespoints_seb
			UNION SELECT localite, saul, entite_geo, geom
				FROM gn_imports.tmp_localitespoly_seb) as obj_geo
			ON t_releves_basephotoseb.place_name ilike obj_geo.localite
		order by id_releve_occtax;
SELECT setval('pr_occtax.t_releves_occtax_id_releve_occtax_seq', (SELECT MAX(id_releve_occtax) FROM pr_occtax.t_releves_occtax)+1);


INSERT INTO pr_occtax.cor_role_releves_occtax(unique_id_cor_role_releve, id_releve_occtax, id_role)
	SELECT uuid_generate_v4() as unique_id_cor_role_releve,id_releve_occtax, 1000016 from gn_imports.t_releves_basephotoseb;


--2- Injection des occurrences
INSERT INTO pr_occtax.t_occurrences_occtax(
	id_occurrence_occtax, unique_id_occurence_occtax, id_releve_occtax, 
	id_nomenclature_obs_technique, id_nomenclature_bio_condition, id_nomenclature_bio_status, 
	id_nomenclature_naturalness, id_nomenclature_exist_proof, id_nomenclature_diffusion_level, 
	id_nomenclature_observation_status, id_nomenclature_blurring, id_nomenclature_source_status, 
	id_nomenclature_behaviour, determiner, id_nomenclature_determination_method, cd_nom, nom_cite, 
	meta_v_taxref, sample_number_proof, digital_proof)
SELECT id_occurrence_occtax, uuid_generate_v4() AS unique_id_occurence_occtax, id_releve_occtax, 
	37, id_nomenclature_bio_condition, id_nomenclature_bio_status, 
	id_nomenclature_naturalness, id_nomenclature_exist_proof, id_nomenclature_diffusion_level, 
	id_nomenclature_observation_status, id_nomenclature_blurring, id_nomenclature_source_status, 
	id_nomenclature_behaviour, determiner, id_nomenclature_determination_method, cd_nom, nom_cite, 
	meta_v_taxref, sample_number_proof, digital_proof
	FROM gn_imports.t_occurrences_basephotoseb;
SELECT setval('pr_occtax.t_occurrences_occtax_id_occurrence_occtax_seq', (SELECT MAX(id_occurrence_occtax) FROM pr_occtax.t_occurrences_occtax)+1);


--3- Injection des décomptes
INSERT INTO pr_occtax.cor_counting_occtax(id_counting_occtax, unique_id_sinp_occtax, id_occurrence_occtax, 
										  id_nomenclature_life_stage, id_nomenclature_sex, 
										  id_nomenclature_obj_count, id_nomenclature_type_count, 
										  count_min, count_max)
	SELECT id_counting_occtax, uuid_generate_v4() AS unique_id_sinp_occtax, id_occurrence_occtax , 
			id_nomenclature_life_stage, id_nomenclature_sex, 
			id_nomenclature_obj_count, id_nomenclature_type_count,
			count_min ,count_max
	from gn_imports.cor_counting_basephotoseb;
SELECT setval('pr_occtax.cor_counting_occtax_id_counting_occtax_seq', (SELECT MAX(id_counting_occtax) FROM pr_occtax.cor_counting_occtax)+1);


--3/ ftp pour envoyer les photos dans les rep:
--geonature/backend/static/medias/4/photoici.jpg

--4/ ajout des medias dans la table gn_commons.t_medias
--avec 
--	id_table_location = 4 (cf.  gn_commons.bib_tables_location)
--	id_nomenclature_media_type = photo (458?)
--	uuid_occurrence/uuid_denombrement
--	adresse de la photos: 'static/medias/4/photoici.JPG'
INSERT INTO gn_commons.t_medias(unique_id_media, id_nomenclature_media_type, id_table_location, uuid_attached_row, 
	title_fr, media_path, author, description_fr, is_public)
SELECT uuid_generate_v4() AS unique_id_media, id_nomenclature_media_type, id_table_location, unique_id_sinp_occtax, 
	title_fr, media_path, 'Sébastien Sant/Parc amazonien de Guyane', description_fr, true
	FROM gn_imports.t_medias_basephotoseb
	INNER JOIN pr_occtax.cor_counting_occtax ON t_medias_basephotoseb.id_counting = cor_counting_occtax.id_counting_occtax;
-- Batch pour Irfanview: $T(%Y%m%d)_$N_$d_SebastienSant.jpg