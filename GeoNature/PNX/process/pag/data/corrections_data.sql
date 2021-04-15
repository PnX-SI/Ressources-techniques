---------------------- Corrections/réaffectation/usage des datasets (on profite de la migration pour mettre des choses au carré...)
UPDATE gn_meta.t_acquisition_frameworks
	SET acquisition_framework_name = 'DIADEMA', 
	    acquisition_framework_desc = 'Programme d''évaluation de la biodiversité tropicale le long d''un gradient géographique et environnemental en Guyane française. (pilotage Labex CEBA)'
	WHERE id_acquisition_framework = 17;
UPDATE gn_meta.t_datasets
	SET dataset_name = 'DIADEMA Limonade', 
	    dataset_shortname = 'DIADEMA Limonade', 
	    dataset_desc = 'DIADEMA Limonade 2013-2014'
	WHERE id_acquisition_framework = 17;

-- Renommage ZNIEFF
UPDATE gn_meta.t_acquisition_frameworks
	SET acquisition_framework_name = 'ZNIEFF 2010-2014', 
	    acquisition_framework_desc = 'Modernisation des ZNIEFF 2010-2014'
	WHERE id_acquisition_framework = 10;
UPDATE gn_meta.t_datasets
	SET dataset_name = 'ZNIEFF Mont Cacao de la Haute Camopi', 
	    dataset_shortname = 'ZNIEFF Mont Cacao de la Haute Camopi', 
	    dataset_desc = 'Modernisation de la ZNIEFF du Mont Cacao de la Haute Camopi'
	WHERE id_dataset = 16;
-- ajout des années d'inventaire des ZNIEFF
UPDATE gn_meta.t_datasets
	SET dataset_name = dataset_name || ' ('||annee_inventaire||')',
		dataset_shortname = dataset_shortname|| ' ('||annee_inventaire||')',
		dataset_desc = dataset_desc || ' ('||annee_inventaire||')'
	FROM (SELECT id_source, id_dataset, string_agg(annee, ', ') as annee_inventaire
			FROM (SELECT id_source, id_dataset, to_char(date_min, 'YYYY') as annee
				FROM gn_synthese.synthese
				WHERE id_source between 10 and 18
				GROUP BY id_source, id_dataset, to_char(date_min, 'YYYY')
				ORDER BY id_source, id_dataset, to_char(date_min, 'YYYY'))as liste_annees
			GROUP BY liste_annees.id_source, liste_annees.id_dataset) as annees_znieff
		  WHERE t_datasets.id_dataset = annees_znieff.id_dataset;

UPDATE gn_synthese.t_sources
	SET name_source = name_source || ' ('||annee_inventaire||')',
		desc_source = desc_source || ' ('||annee_inventaire||')'
	FROM (SELECT id_source, id_dataset, string_agg(annee, ', ') as annee_inventaire
			FROM (SELECT id_source, id_dataset, to_char(date_min, 'YYYY') as annee
				FROM gn_synthese.synthese
				WHERE id_source between 10 and 18
				GROUP BY id_source, id_dataset, to_char(date_min, 'YYYY')
				ORDER BY id_source, id_dataset, to_char(date_min, 'YYYY'))as liste_annees
			GROUP BY liste_annees.id_source, liste_annees.id_dataset) as annees_znieff
		  WHERE t_sources.id_source = annees_znieff.id_source;


--Suivi Itoupé ==> on réaffecte tous les datasets au cadre d'acquisition 9 et on vire le 20
UPDATE gn_meta.t_acquisition_frameworks
	SET acquisition_framework_name = 'Itoupé', 
	    acquisition_framework_desc = 'Inventaires et suivis pluridisciplinaires des monts Itoupé'
	WHERE id_acquisition_framework = 9;
UPDATE gn_meta.t_datasets
	SET dataset_name = 'Itoupé 2010', 
	    dataset_shortname = 'Itoupé 2010', 
	    dataset_desc = 'Inventaire pluridisciplinaire d''Itoupé (2010)'
	WHERE id_dataset = 9;
UPDATE gn_meta.t_datasets
	SET dataset_name = 'Itoupé 2016', 
	    dataset_shortname = 'Itoupé 2016', 
	    dataset_desc = 'Inventaire pluridisciplinaire d''Itoupé (2016)', 
	    id_acquisition_framework = 9
	WHERE id_dataset = 28;
DELETE from gn_meta.t_acquisition_frameworks WHERE id_acquisition_framework = 20;

-- Données ponctuelles ==> On réaffecte tous les datasets au cadre d'acquisition 1 : 
UPDATE gn_meta.t_acquisition_frameworks
	SET acquisition_framework_name = 'Agents PAG-Données ponctuelles', 
	    acquisition_framework_desc = 'Observations opportunistes réalisées hors cadre d''étude.'
	WHERE id_acquisition_framework = 1;
UPDATE gn_meta.t_datasets
	SET dataset_name = '(GN1.9) Contact Vertébrés', 
	    dataset_shortname = '(GN1.9) Contact Vertébrés', 
	    dataset_desc = 'Observations de faune saisies sur l''outil GéoNature 1.9, entre 2017 et 2020 (pour archive)',
	    id_acquisition_framework = 1
	WHERE id_dataset = 1;
UPDATE gn_meta.t_datasets
	SET dataset_name = '(C.Faune) Faune', 
	    dataset_shortname = '(C.Faune) Faune', 
	    dataset_desc = 'Observations de faune saisies sur l''outil Contact Faune, entre 2014 et 2018 (pour archive)',
	    id_acquisition_framework = 1
	WHERE id_dataset = 6;
UPDATE gn_meta.t_datasets
	SET dataset_name = '(GN1.9) Contact Flore ', 
	    dataset_shortname = '(GN1.9) Contact Flore', 
	    dataset_desc = 'Observations de flore saisies sur l''outil GéoNature 1.9, entre 2017 et 2020 (pour archive)',
	    id_acquisition_framework = 1
	WHERE id_dataset = 7;

-- Données partenariales ==> On réaffecte les datasets Faune-Guyane et Herbier au cadre d'acquisition 16 : 
UPDATE gn_meta.t_acquisition_frameworks
	SET acquisition_framework_name = 'Données partenariales', 
	    acquisition_framework_desc = 'Données naturalistes transmises pour un usage interne dans le cadre de conventions.'
	WHERE id_acquisition_framework = 16;
UPDATE gn_meta.t_datasets
	SET dataset_name = 'Faune-Guyane (xx/xx/2018)', 
	    dataset_shortname = 'Faune-Guyane', 
	    dataset_desc = 'Données de la plateforme collaborative Faune-Guyane',
	    id_acquisition_framework = 16
	WHERE id_dataset = 24;
UPDATE gn_meta.t_datasets
	SET dataset_name = 'Herbier de Guyane (xx/xx/2017)', 
	    dataset_shortname = 'Herbier de Guyane', 
	    dataset_desc = 'Banque de données de l''Herbier de Cayenne, avec échantillonnage.',
	    id_acquisition_framework = 16,
	    id_nomenclature_dataset_objectif = 410
	WHERE id_dataset = 26;

--- Suivis IKA ==> On les annualise
UPDATE gn_meta.t_acquisition_frameworks
	SET acquisition_framework_name = 'Indice Kilométrique d''Abondance (IKA)', 
	    acquisition_framework_desc = 'Comptages protocolés de la grande faune.'
	WHERE id_acquisition_framework = 11;
UPDATE gn_meta.t_datasets
	SET dataset_name = 'IKA 2008', 
	    dataset_shortname = 'IKA 2008', 
	    dataset_desc = 'Comptages IKA 2008',
	    active = false,
	    id_acquisition_framework = 11
	WHERE id_dataset = 19;
-- ajout des IKA 2009 à 2015
INSERT INTO gn_meta.t_datasets(
	id_dataset,
	unique_dataset_id, 
	id_acquisition_framework, 
	dataset_name, 
	dataset_shortname, 
	dataset_desc, 
	id_nomenclature_data_type, keywords, marine_domain, terrestrial_domain, 
	id_nomenclature_dataset_objectif, bbox_west, bbox_east, bbox_south, bbox_north, 
	id_nomenclature_collecting_method, id_nomenclature_data_origin, id_nomenclature_source_status, 
	id_nomenclature_resource_type, active, validable)
  SELECT to_number((to_char(date_min, 'YYYY')),'0000')-1980  as id_dataset, 
	uuid_generate_v4() as unique_dataset_id, 
	id_acquisition_framework, 
	'IKA '|| to_char(date_min, 'YYYY') as dataset_name, 
	'IKA '|| to_char(date_min, 'YYYY') as dataset_shortname, 
	'Comptages IKA '|| to_char(date_min, 'YYYY') as dataset_desc, 
	id_nomenclature_data_type, keywords, marine_domain, terrestrial_domain, 
	id_nomenclature_dataset_objectif, bbox_west, bbox_east, bbox_south, bbox_north, 
	id_nomenclature_collecting_method, id_nomenclature_data_origin, synthese.id_nomenclature_source_status, 
	id_nomenclature_resource_type, false, validable
  FROM gn_synthese.synthese inner join gn_meta.t_datasets
	on synthese.id_dataset = t_datasets.id_dataset
  WHERE synthese.id_source = 19 and to_char(date_min, 'YYYY') <> '2008'
  GROUP BY id_acquisition_framework, 
	dataset_name, dataset_shortname, dataset_desc, 
	id_nomenclature_data_type, keywords, marine_domain, terrestrial_domain, 
	id_nomenclature_dataset_objectif, bbox_west, bbox_east, bbox_south, bbox_north, 
	id_nomenclature_collecting_method, id_nomenclature_data_origin, synthese.id_nomenclature_source_status, 
	id_nomenclature_resource_type, active, validable,
 	to_char(date_min, 'YYYY')
  ORDER BY to_char(date_min, 'YYYY')
;
SELECT setval('gn_meta.t_datasets_id_dataset_seq', (SELECT MAX(id_dataset) FROM gn_meta.t_datasets)+1);

--- Suivis STOC-EPS ==> On les annualise
UPDATE gn_meta.t_acquisition_frameworks
	SET acquisition_framework_name = 'Suivi Temporel des Oiseaux Communs (STOC)', 
	    acquisition_framework_desc = 'Suivi temporel des oiseaux communs par échantillonnage ponctuel simple (STOC-EPS). Comptage annuel, coordonné par la GEPOG.'
	WHERE id_acquisition_framework = 12;
UPDATE gn_meta.t_datasets
	SET dataset_name = 'STOC-EPS 2012', 
	    dataset_shortname = 'STOC-EPS 2012', 
	    dataset_desc = 'Comptages STOC-EPS 2012',
	    active = false,
	    id_acquisition_framework = 12
	WHERE id_dataset = 20;
-- ajout des STOC 2013 à 2016
INSERT INTO gn_meta.t_datasets(
	--id_dataset,
	unique_dataset_id, 
	id_acquisition_framework, 
	dataset_name, 
	dataset_shortname, 
	dataset_desc, 
	id_nomenclature_data_type, keywords, marine_domain, terrestrial_domain, 
	id_nomenclature_dataset_objectif, bbox_west, bbox_east, bbox_south, bbox_north, 
	id_nomenclature_collecting_method, id_nomenclature_data_origin, id_nomenclature_source_status, 
	id_nomenclature_resource_type, active, validable)
  SELECT --to_number((to_char(date_min, 'YYYY')),'0000')-1980  as id_dataset, 
	uuid_generate_v4() as unique_dataset_id, 
	id_acquisition_framework, 
	'STOC-EPS '|| to_char(date_min, 'YYYY') as dataset_name, 
	'STOC-EPS '|| to_char(date_min, 'YYYY') as dataset_shortname, 
	'Comptages STOC-EPS '|| to_char(date_min, 'YYYY') as dataset_desc, 
	id_nomenclature_data_type, keywords, marine_domain, terrestrial_domain, 
	id_nomenclature_dataset_objectif, bbox_west, bbox_east, bbox_south, bbox_north, 
	id_nomenclature_collecting_method, id_nomenclature_data_origin, synthese.id_nomenclature_source_status, 
	id_nomenclature_resource_type, false, validable
  FROM gn_synthese.synthese inner join gn_meta.t_datasets
	on synthese.id_dataset = t_datasets.id_dataset
  WHERE synthese.id_source = 20 and to_char(date_min, 'YYYY') <> '2012'
  GROUP BY id_acquisition_framework, 
	dataset_name, dataset_shortname, dataset_desc, 
	id_nomenclature_data_type, keywords, marine_domain, terrestrial_domain, 
	id_nomenclature_dataset_objectif, bbox_west, bbox_east, bbox_south, bbox_north, 
	id_nomenclature_collecting_method, id_nomenclature_data_origin, synthese.id_nomenclature_source_status, 
	id_nomenclature_resource_type, active, validable,
 	to_char(date_min, 'YYYY')
  ORDER BY to_char(date_min, 'YYYY')
;



--- Objectifs des datasets
UPDATE gn_meta.t_datasets
	SET id_nomenclature_dataset_objectif = 424 --Enquetes chasse et peche: Évaluation de la ressource / prélèvements
	WHERE id_dataset in (8,22);
UPDATE gn_meta.t_datasets
	SET id_nomenclature_dataset_objectif = 421 -- CEBA Limonade: Inventaires généralisés & exploration
	WHERE id_dataset in (25);

-- tri des datasets non utilisés (ça sert à rien!)
delete from gn_meta.cor_dataset_actor where id_dataset in (2,3,4,5);
delete from gn_meta.t_datasets where id_dataset in (2,3,4,5);
delete from gn_meta.t_acquisition_frameworks where id_acquisition_framework in (2,3,4,5,6,7,18);
delete from gn_synthese.t_sources where id_source in (2,3,4,5);

-- ajout des gn_commons.cor_module_dataset (saisie occtax)
INSERT INTO gn_commons.cor_module_dataset (id_module, id_dataset) 
	VALUES (4,1),(4,6),(4,7),(4,27);


----------------------------------- Mise à jour des élements de synthese
-------------------- Les sources
UPDATE gn_synthese.t_sources
	SET name_source = 'DIADEMA Limonade', 
	    desc_source = 'DIADEMA Limonade 2013-2014'
	WHERE t_sources.id_source = 25;
UPDATE gn_synthese.t_sources
	SET name_source = 'Faune-Guyane (xx/xx/2018)', 
	    desc_source = 'Données de la plateforme collaborative Faune-Guyane'  
	WHERE t_sources.id_source = 24;-- Faune-Guyane
UPDATE gn_synthese.t_sources
	SET name_source = 'Herbier de Guyane (xx/xx/2017)', 
	    desc_source = 'Banque de données de l''Herbier de Cayenne, avec échantillonnage.'  
	WHERE t_sources.id_source = 35;-- Herbier
UPDATE gn_synthese.t_sources
	SET name_source = '(GN1.9) Contact Vertébrés', 
	    desc_source = 'Observations de faune saisies sur l''outil GéoNature 1.9, entre 2017 et 2020 (pour archive)'
	WHERE id_source = 1;-- Contact vertébrés GN1.9
UPDATE gn_synthese.t_sources
	SET name_source = '(GN1.9) Contact Flore ', 
            desc_source = 'Observations de flore saisies sur l''outil GéoNature 1.9, entre 2017 et 2020 (pour archive)'
	WHERE id_source = 7;--Contact Flore GN1.9
UPDATE gn_synthese.t_sources
	SET name_source = '(C.Faune) Faune', 
            desc_source = 'Observations de faune saisies sur l''outil Contact Faune, entre 2014 et 2018 (pour archive)'
	WHERE id_source = 6;--Contact Faune GN1.9
UPDATE gn_synthese.t_sources
	SET name_source = 'IKA 2008', 
            desc_source = 'Comptages IKA 2008'
	WHERE id_source = 19;--IKA 2008
INSERT INTO gn_synthese.t_sources(name_source, desc_source)
	SELECT dataset_name, dataset_desc
	FROM gn_meta.t_datasets
	WHERE id_acquisition_framework = 11 and id_dataset <> 19;
INSERT INTO gn_synthese.t_sources(name_source, desc_source)
	SELECT dataset_name, dataset_desc
	FROM gn_meta.t_datasets
	WHERE id_acquisition_framework = 12 and id_dataset <> 20;
-- Autres corrections
UPDATE gn_synthese.t_sources
	SET entity_source_pk_field = null
	WHERE id_source = 6;
UPDATE gn_synthese.t_sources
	SET url_source = '#/occtax/info/id_counting'
	WHERE id_source in (1,6,7);

------- Corrections dans la synthese
-- MAJ des bio_status des données des enquêtes chasse et pêche
UPDATE gn_synthese.synthese
	SET id_nomenclature_bio_condition = 154
	WHERE id_source in (8,22);
-- MAJ des échantillons de données pour l'Herbier
UPDATE gn_synthese.synthese
	SET id_nomenclature_source_status = 70,
	    id_nomenclature_exist_proof = 78,
	    sample_number_proof= 'cf. Herbier Cayenne, ref n°' || comment_description
	WHERE id_source in (35);  -- Herbier de Cay = collection
-- MAJ des sources liées aux IKA
UPDATE gn_synthese.synthese
	SET id_source = refs.id_source,
	    id_dataset = refs.id_dataset
        FROM (SELECT dataset_name, dataset_desc, id_source, id_dataset
	    FROM gn_meta.t_datasets INNER JOIN gn_synthese.t_sources ON t_datasets.dataset_name = t_sources.name_source
	    WHERE id_acquisition_framework = 11) as refs
	WHERE synthese.id_source = 19 and 'IKA '||to_char(date_min, 'YYYY')= dataset_name;
-- MAJ des sources liées aux STOC
UPDATE gn_synthese.synthese
	SET id_source = refs.id_source,
	    id_dataset = refs.id_dataset
        FROM (SELECT dataset_name, dataset_desc, id_source, id_dataset
	    FROM gn_meta.t_datasets INNER JOIN gn_synthese.t_sources ON t_datasets.dataset_name = t_sources.name_source
	    WHERE id_acquisition_framework = 12) as refs
	WHERE synthese.id_source = 20 and 'STOC-EPS '||to_char(date_min, 'YYYY')= dataset_name;

