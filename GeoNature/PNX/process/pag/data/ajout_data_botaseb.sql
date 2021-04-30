------------------- Injection BD photo seb

------------0/ Métadonnées
--Création du cadre ABC Saül (et celui de PPI au passage)
INSERT INTO gn_meta.t_acquisition_frameworks(unique_acquisition_framework_id, 
	acquisition_framework_name, 
	acquisition_framework_desc, 
	id_nomenclature_territorial_level, 
	territory_desc, 
	keywords, 
	id_nomenclature_financing_type, 
	target_description, ecologic_or_geologic_target,
	acquisition_framework_parent_id, is_parent, opened, id_digitizer, 
	acquisition_framework_start_date, acquisition_framework_end_date)
	VALUES (uuid_generate_v4(), 
			'Atlas de la Biodiversité Communale de Saül', 
			'Etat des lieux de la biodiversité de Saül. **PAG + Mairie**', 
			357, 
			'Centrage des inventaires sur quelques zones clés de Saül', 
			'ABC, Saül, amphibiens, escargots, champignons, flore, habitats, orchidées', 
			382,
			'Identifier les enjeux sur les groupes taxonomiques suivants: amphibiens, escargots, champignons, flore, habitats, orchidées', 'ecologic', 
			null, false, true, null, 
			'2018-01-01', '2021-12-31'),
		(uuid_generate_v4(), 
			'Atlas de la Biodiversité Communale de Papaïchton', 
			'Etat des lieux de la biodiversité de Papaïchton. **PAG + Mairie**', 
			357, 
			'Centrage des inventaires sur quelques zones clés de Papaïchton', 
			'ABC, Papaïchton, amphibiens, oiseaux, poissons, flore, habitats', 
			382,
			'Identifier les enjeux sur les groupes taxonomiques suivants: amphibiens, oiseaux, poissons, flore, habitats', 'ecologic', 
			null, false, true, null, 
			'2020-06-01', '2023-12-31');
INSERT INTO gn_meta.cor_acquisition_framework_actor(id_acquisition_framework, id_organism, id_nomenclature_actor_role)
	SELECT id_acquisition_framework, 3, 360  -- MO
		FROM gn_meta.t_acquisition_frameworks
		WHERE acquisition_framework_name like 'Atlas de la Biodiversité Communale de%'
	UNION 	SELECT id_acquisition_framework, 3, 358 -- Contact pricipal
		FROM gn_meta.t_acquisition_frameworks
		WHERE acquisition_framework_name like 'Atlas de la Biodiversité Communale de%';
-- Création du JDD "Flore de Saül"
INSERT INTO gn_meta.t_datasets(	unique_dataset_id, id_acquisition_framework, 
		dataset_name, dataset_shortname, dataset_desc, 
		id_nomenclature_data_type, marine_domain, terrestrial_domain, 
		id_nomenclature_dataset_objectif,  id_nomenclature_collecting_method, id_nomenclature_data_origin, id_nomenclature_source_status, id_nomenclature_resource_type, 
		active, validable)
	SELECT uuid_generate_v4() as unique_dataset_id, id_acquisition_framework, 
		'ABCSaül - Flore', 'ABCSaül - Flore', 'Acquisition de données floristiques dans le cadre de l''ABC de Saül', 
		322, false, true, 
		417, 395, 76, 73, 320,
		true, true	
	FROM gn_meta.t_acquisition_frameworks
		WHERE acquisition_framework_name = 'Atlas de la Biodiversité Communale de Saül';
INSERT INTO gn_meta.cor_dataset_actor(
	id_dataset, id_organism, id_nomenclature_actor_role)
	SELECT id_dataset, 3, 363
	FROM gn_meta.t_datasets
		WHERE dataset_shortname ='ABCSaül - Flore';
-- ajout des gn_commons.cor_module_dataset (saisie occtax)
INSERT INTO gn_commons.cor_module_dataset (id_module, id_dataset) 
	SELECT 3, id_dataset
		FROM gn_meta.t_datasets
		WHERE dataset_shortname ='ABCSaül - Flore'
	UNION SELECT 4, id_dataset
		FROM gn_meta.t_datasets
		WHERE dataset_shortname ='ABCSaül - Flore'
	UNION SELECT 6, id_dataset
		FROM gn_meta.t_datasets
		WHERE dataset_shortname ='ABCSaül - Flore';
		
		
--1/ création des releves/occurrences/counting
--2/ ftp pour envoyer les photos dans les rep:
geonature/backend/static/medias/4/photoici.jpg
--3/ ajout des medias dans la table gn_commons.t_medias
avec 
	id_table_location = 4 (cf.  gn_commons.bib_tables_location)
	id_nomenclature_media_type = photo (458?)
	uuid_occurrence/uuid_denombrement
	adresse de la photos: 'static/medias/4/photoici.JPG'