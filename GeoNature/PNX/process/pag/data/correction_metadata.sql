
---------------------- Corrections/réaffectation/usage des datasets (on profite de la migration pour mettre des choses au carré...)
	
-------------- Suivi Itoupé 
	-- ==> corrections de libelés et framework. 
	-- ==> Pas de modif des données.
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
--sources associées
UPDATE gn_synthese.t_sources
	SET name_source = 'Itoupé 2010', 
	    desc_source = 'Inventaire pluridisciplinaire d''Itoupé (2010)'
	WHERE t_sources.id_source = 9;-- Itoupé 2010
UPDATE gn_synthese.t_sources
	SET name_source = 'Itoupé 2016', 
	    desc_source = 'Inventaire pluridisciplinaire d''Itoupé (2016)'
	WHERE t_sources.id_source = 38;-- Itoupé 2010	


-------------- Données opportunistes
 	-- ==> corrections de libelés et framework. 
	-- ==>Pas de modif des données.
UPDATE gn_meta.t_acquisition_frameworks
	SET acquisition_framework_name = 'Observations occasionnelles', 
	    acquisition_framework_desc = 'Observations naturalistes opportunistes réalisées hors cadre d''étude.'
	WHERE id_acquisition_framework = 1;
UPDATE gn_meta.t_datasets
	SET dataset_name = 'Obs. faune-flore historiques', 
	    dataset_shortname = 'Obs. historiques', 
	    dataset_desc = 'Observations de faune et flore saisies sur les outils Contact Faune et GéoNature 1.9, entre 2014 et 2020 (pour archive). **PAG**',
	    id_acquisition_framework = 1
	WHERE id_dataset = 1;
UPDATE gn_meta.t_datasets
	SET dataset_name = 'Observations opportunistes', 
	    dataset_shortname = 'Obs. opportunistes', 
	    dataset_desc = 'Observations de faune, flore et fonge hors cadre d''étude. **PAG**',
	    id_acquisition_framework = 1
	WHERE id_dataset = 2; ---- On affecte le dataset 2 à OCCTAX
--sources associées
UPDATE gn_synthese.t_sources
	SET name_source = 'Obs. faune-flore historiques', 
	    desc_source = 'Observations de faune et flore saisies sur les outils Contact Faune et GéoNature 1.9, entre 2014 et 2020 (pour archive). **PAG**',
		entity_source_pk_field = 'pr_occtax.cor_counting_occtax.id_counting_occtax',
		url_source = '#/occtax/info/id_counting'
	WHERE t_sources.id_source = 1;-- Données opportunistes historiques
UPDATE gn_synthese.t_sources
	SET desc_source = 'Observations de faune, flore et fonge hors cadre d''étude (module OccTax). **PAG**'
	WHERE t_sources.name_source = 'Occtax';-- occTax
-- Mise à jour des id_sources quand les données sont des données historiques de Contact faune ou GN1.9 ==> elles ont toutes été transférées dans le occtax
UPDATE gn_synthese.synthese
	SET id_source = 1
	WHERE id_source = (select id_source from gn_synthese.t_sources where t_sources.name_source = 'Occtax');
	
	
-------------- Programme Chasse, Pêche, Terra Maka'Andi... 
	-- ==> corrections de libelés et framework. 
	-- ==> Pas de modif des données.
UPDATE gn_meta.t_acquisition_frameworks
	SET acquisition_framework_name = 'Gestion des ressources naturelles', 
	    acquisition_framework_desc = 'Inventaires/enquêtes dans la cadre de l''appui à la gestion des resosurces naturelles.'
	WHERE id_acquisition_framework = 8;
UPDATE gn_meta.t_datasets
	SET dataset_name = 'Enquêtes Chasse (2020-2012)', 
	    dataset_shortname = 'Chasse (2020-2012)', 
	    dataset_desc = 'Ressources cynégétiques: enquêtes sur les pratiques de chasse (2020-2012). **PAG**',
		id_nomenclature_dataset_objectif = 424 --Évaluation de la ressource / prélèvements
	WHERE id_dataset = 8; --Chasse
UPDATE gn_meta.t_datasets
	SET dataset_name = 'Enquêtes Pêche (2014-2016)', 
	    dataset_shortname = 'Pêche (2014-2016)', 
	    dataset_desc = 'Ressources halieutiques: enquêtes sur les pratiques de pêche (2014-2016). **PAG**', 
		id_nomenclature_dataset_objectif = 424, --Évaluation de la ressource / prélèvements
	    id_acquisition_framework = 8
	WHERE id_dataset = 22; -- Pêche
--sources associées
UPDATE gn_synthese.t_sources
	SET name_source = 'Chasse (2020-2012)', 
	    desc_source = 'Ressources cynégétiques: enquêtes sur les pratiques de chasse (2020-2012). **PAG**'
	WHERE t_sources.id_source = 8;-- Chasse
UPDATE gn_synthese.t_sources
	SET name_source = 'Pêche (2014-2016)', 
	    desc_source = 'Ressources halieutiques: enquêtes sur les pratiques de pêche (2014-2016). **PAG**'
	WHERE t_sources.id_source = 22;-- Pêche	
-- MAJ des bio_status des données des enquêtes chasse et pêche = morts!
UPDATE gn_synthese.synthese
	SET id_nomenclature_bio_condition = 154
	WHERE id_source in (8,22);

	
-------------- ZNIEFF
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
		dataset_desc = dataset_desc || ' ('||annee_inventaire||'). **DEAL Guyane**'
	FROM (SELECT id_source, id_dataset, string_agg(annee, '- ') as annee_inventaire
			FROM (SELECT id_source, id_dataset, to_char(date_min, 'YYYY') as annee
				FROM gn_synthese.synthese
				WHERE id_source between 10 and 18
				GROUP BY id_source, id_dataset, to_char(date_min, 'YYYY')
				ORDER BY id_source, id_dataset, to_char(date_min, 'YYYY'))as liste_annees
			GROUP BY liste_annees.id_source, liste_annees.id_dataset) as annees_znieff
		  WHERE t_datasets.id_dataset = annees_znieff.id_dataset;
--sources associées
UPDATE gn_synthese.t_sources
	SET name_source = replace(replace(name_source, ' (FAUNE)',''),' (FLORE)','') || ' ('||annee_inventaire||')',
		desc_source = 'Données des inventaires faune/flore du programme de modernisation de la '|| replace(replace(name_source, ' (FAUNE)',''),' (FLORE)','')  || ' ('||annee_inventaire||')'
	FROM (SELECT id_source, id_dataset, string_agg(annee, '- ') as annee_inventaire
			FROM (SELECT id_source, id_dataset, to_char(date_min, 'YYYY') as annee
				FROM gn_synthese.synthese
				WHERE id_source between 10 and 18
				GROUP BY id_source, id_dataset, to_char(date_min, 'YYYY')
				ORDER BY id_source, id_dataset, to_char(date_min, 'YYYY'))as liste_annees
			GROUP BY liste_annees.id_source, liste_annees.id_dataset) as annees_znieff
		  WHERE t_sources.id_source = annees_znieff.id_source;
-- mise à jour des références dans la synthese
UPDATE gn_synthese.synthese SET id_source = 10 WHERE id_source = 26; --ZNIEFF Alikéné  (2012)
UPDATE gn_synthese.synthese SET id_source = 11 WHERE id_source = 27; --ZNIEFF Attachi Baka  (2011- 2012)
UPDATE gn_synthese.synthese SET id_source = 12 WHERE id_source = 28; --ZNIEFF Abattis Cotica  (2011- 2012)
UPDATE gn_synthese.synthese SET id_source = 13 WHERE id_source = 29; --ZNIEFF Belvédère  (2012)
UPDATE gn_synthese.synthese SET id_source = 14 WHERE id_source = 30; --ZNIEFF Borne 4  (2012)
UPDATE gn_synthese.synthese SET id_source = 15 WHERE id_source = 31; --ZNIEFF Mémora  (2012)
UPDATE gn_synthese.synthese SET id_source = 16 WHERE id_source = 32; --ZNIEFF Mont Cacao  (2012)
UPDATE gn_synthese.synthese SET id_source = 17 WHERE id_source = 33; --ZNIEFF Pic Coudreau  (2013)
UPDATE gn_synthese.synthese SET id_source = 18 WHERE id_source = 34; --ZNIEFF Waki  (2012)


--------------  Suivis IKA ==> On les annualise
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
--sources associées
UPDATE gn_synthese.t_sources
	SET name_source = 'IKA 2008', 
            desc_source = 'Comptages IKA 2008'
	WHERE id_source = 19;--IKA 2008
INSERT INTO gn_synthese.t_sources(name_source, desc_source)
	SELECT dataset_name, dataset_desc
	FROM gn_meta.t_datasets
	WHERE id_acquisition_framework = 11 and id_dataset <> 19;
-- MAJ des sources liées aux IKA
UPDATE gn_synthese.synthese
	SET id_source = refs.id_source,
	    id_dataset = refs.id_dataset
        FROM (SELECT dataset_name, dataset_desc, id_source, id_dataset
	    FROM gn_meta.t_datasets INNER JOIN gn_synthese.t_sources ON t_datasets.dataset_name = t_sources.name_source
	    WHERE id_acquisition_framework = 11) as refs
	WHERE synthese.id_source = 19 and 'IKA '||to_char(date_min, 'YYYY')= dataset_name;

--------------  Suivis STOC-EPS ==> On les annualise
UPDATE gn_meta.t_acquisition_frameworks
	SET acquisition_framework_name = 'Suivi Temporel des Oiseaux Communs (STOC)', 
	    acquisition_framework_desc = 'Suivi temporel des oiseaux communs par échantillonnage ponctuel simple (STOC-EPS). Comptage annuel, coordonné par le GEPOG.'
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
  ORDER BY to_char(date_min, 'YYYY');
--sources associées
UPDATE gn_synthese.t_sources
	SET name_source = 'STOC-EPS 2012', 
            desc_source = 'Comptages STOC-EPS 2012'
	WHERE id_source = 20;--IKA 2008
INSERT INTO gn_synthese.t_sources(name_source, desc_source)
	SELECT dataset_name, dataset_desc
	FROM gn_meta.t_datasets
	WHERE id_acquisition_framework = 12 and id_dataset <> 20;
-- MAJ de la synthèse avec les sources liées aux STOC
UPDATE gn_synthese.synthese
	SET id_source = refs.id_source,
	    id_dataset = refs.id_dataset
        FROM (SELECT dataset_name, dataset_desc, id_source, id_dataset
	    FROM gn_meta.t_datasets INNER JOIN gn_synthese.t_sources ON t_datasets.dataset_name = t_sources.name_source
	    WHERE id_acquisition_framework = 12) as refs
	WHERE synthese.id_source = 20 and 'STOC-EPS '||to_char(date_min, 'YYYY')= dataset_name;
	
	
	
-------------- Données partenariales
	-- ==> corrections de libelés et framework. 
	-- ==>Pas de modif des données.
UPDATE gn_meta.t_acquisition_frameworks
	SET acquisition_framework_name = 'Données partenariales', 
	    acquisition_framework_desc = 'Données naturalistes transmises pour un usage interne.'
	WHERE id_acquisition_framework = 16;
UPDATE gn_meta.t_datasets
	SET dataset_name = 'Faune-Guyane (01/06/2021)', 
	    dataset_shortname = 'Faune-Guyane', 
	    dataset_desc = 'Données de la plateforme collaborative Faune-Guyane. (les données d''inventaires PAG ont été reventillées vers les jeux de données concernés) **GEPOG**',
	    id_acquisition_framework = 16
	WHERE id_dataset = 24;-- Faune-Guyane
UPDATE gn_meta.t_datasets
	SET dataset_name = 'Herbier de Guyane (08/06/2021)', 
	    dataset_shortname = 'Herbier de Guyane', 
	    dataset_desc = 'Banque de données de l''Herbier de Cayenne, avec échantillonnage. **IRD de Cayenne**',
	    id_acquisition_framework = 16,
	    id_nomenclature_dataset_objectif = 410
	WHERE id_dataset = 26;-- Herbier
UPDATE gn_meta.t_datasets
	SET dataset_name = 'DIADEMA Limonade (2013-2014)', 
	    dataset_shortname = 'DIADEMA Limonade', 
	    dataset_desc = 'DIADEMA Limonade (2013-2014). **Labex CEBA**',
		id_acquisition_framework = 16,
		id_nomenclature_dataset_objectif = 421 --Inventaires généralisés & exploration
	WHERE id_dataset = 25;--DIADEMA
UPDATE gn_meta.t_datasets
	SET dataset_name = 'Mammifères et rongeurs', 
	    dataset_shortname = 'Mammifères et rongeurs', 
	    dataset_desc = 'Programme de suivi des populations de mammifères et rongeurs en Guyane. **CNRS-ISEM**',
		id_acquisition_framework = 16
	WHERE id_dataset = 21;-- Micro_mamm
UPDATE gn_meta.t_datasets
	SET dataset_name = 'Cottica/flore (2005)', 
	    dataset_shortname = 'Cottica/flore (2005)', 
	    dataset_desc = 'Inventaire floristique de Cottica (2005). **IRD de Cayenne**',
		id_acquisition_framework = 16
	WHERE id_dataset = 23;-- Cottica
UPDATE gn_meta.t_datasets
	SET dataset_name = 'Alikéné/herpéto (2015)', 
	    dataset_shortname = 'Alikéné/herpéto (2015)', 
	    dataset_desc = 'Inventaire herpéthologique dans le secteur Alikéné (2015) **Comm.pers. Vacher & Cally**',
		id_acquisition_framework = 16
	WHERE id_dataset = 27;-- herpéto Alikéné et Monts Attachi bakka --source = 36!
INSERT INTO gn_meta.t_datasets(
	id_acquisition_framework, dataset_name, dataset_shortname, dataset_desc, 
	id_nomenclature_data_type, keywords, marine_domain, terrestrial_domain, id_nomenclature_dataset_objectif, bbox_west, bbox_east, bbox_south, bbox_north, id_nomenclature_collecting_method, id_nomenclature_data_origin, id_nomenclature_source_status, id_nomenclature_resource_type, active, validable, id_digitizer)
SELECT id_acquisition_framework, 'Atachi Bakka/herpéto (2015)', 'Atachi Bakka/herpéto (2015)', 'Inventaire herpéthologique au Sud des monts Atachi Bakka (2015) **Comm.pers. Vacher & Cally**', 
	id_nomenclature_data_type, keywords, marine_domain, terrestrial_domain, id_nomenclature_dataset_objectif, bbox_west, bbox_east, bbox_south, bbox_north, id_nomenclature_collecting_method, id_nomenclature_data_origin, id_nomenclature_source_status, id_nomenclature_resource_type, active, validable, id_digitizer
	FROM gn_meta.t_datasets WHERE id_dataset = 27 ; -- ajout du jeu Atachi Bakka 2015

	
-- sources associées
UPDATE gn_synthese.t_sources
	SET name_source = 'Faune-Guyane (01/06/2021)', 
	    desc_source = 'Données de la plateforme collaborative Faune-Guyane. **GEPOG**'  
	WHERE t_sources.id_source = 24;-- Faune-Guyane
UPDATE gn_synthese.t_sources
	SET name_source = 'Herbier de Guyane (08/06/2021)', 
	    desc_source = 'Banque de données de l''Herbier de Cayenne, avec échantillonnage. **IRD de Cayenne**'  
	WHERE t_sources.id_source = 35;-- Herbier
UPDATE gn_synthese.t_sources
	SET name_source = 'DIADEMA Limonade', 
	    desc_source = 'DIADEMA Limonade (2013-2014). **LabEx CEBA**'
	WHERE t_sources.id_source = 25;--DIADEMA
UPDATE gn_synthese.t_sources
	SET name_source = 'Mammifères et rongeurs', 
	    desc_source = 'Programme de suivi des populations de mammifères et rongeurs en Guyane. **CNRS-ISEM**'  
	WHERE t_sources.id_source = 21;-- Micro_mamm
UPDATE gn_synthese.t_sources
	SET name_source = 'Cottica/flore (2005)', 
	    desc_source = 'Inventaire floristique de Cottica (2005). **IRD de Cayenne**'  
	WHERE t_sources.id_source = 23; --Cottica
UPDATE gn_synthese.t_sources
	SET name_source = 'Alikéné/herpéto (2015)', 
	    desc_source = 'Inventaire herpéthologique dans le secteur Alikéné (2015) **Comm.pers. Vacher & Cally**'  
	WHERE t_sources.id_source = 36; --Alikéné
INSERT INTO gn_synthese.t_sources (name_source, desc_source)
	VALUES ('Atachi Bakka/herpéto (2015)', 'Inventaire herpéthologique au Sud des monts Atachi Bakka (2015) **Comm.pers. Vacher & Cally**');
	
-- MAJ de la source et du dataset pour Atachi Bakka 2015
UPDATE gn_synthese.synthese
	SET id_source =(select id_source from gn_synthese.t_sources where name_source ='Atachi Bakka/herpéto (2015)' ), 
		id_dataset = (select id_dataset from gn_meta.t_datasets where dataset_name ='Atachi Bakka/herpéto (2015)' )
	FROM  ref_geo.l_areas 
	WHERE ST_CONTAINS(l_areas.geom, the_geom_local)
		AND id_area = 17 AND id_source = 36 AND id_dataset = 27;
-- MAJ des échantillons de données pour l'Herbier
UPDATE gn_synthese.synthese
	SET id_nomenclature_source_status = 70,
	    id_nomenclature_exist_proof = 78,
	    sample_number_proof= 'cf. Herbier Cayenne, ref n°' || comment_description
	WHERE id_source in (35);  -- Herbier de Cay = collection


-- tri des datasets non utilisés (ça sert à rien!) et des des gn_commons.cor_module_dataset (saisie occtax)
delete from gn_synthese.t_sources where id_source in (2,3,4,5,6,7,26,27,28,29,30,31,32,33,34,37);
DELETE FROM gn_meta.cor_acquisition_framework_actor;
delete from gn_meta.cor_dataset_actor;
delete from gn_meta.t_datasets where id_dataset in (3,4,5,6,7);
delete from gn_meta.t_acquisition_frameworks where id_acquisition_framework in (2,3,4,5,6,7,13,14,15,17,18,19,20);



-- les contacts principaux pour chaque framework
INSERT INTO gn_meta.cor_acquisition_framework_actor(
	id_acquisition_framework, id_organism, id_nomenclature_actor_role)
	VALUES (1, 3, ref_nomenclatures.get_id_nomenclature('ROLE_ACTEUR', '1')), 
		(10, 7, ref_nomenclatures.get_id_nomenclature('ROLE_ACTEUR', '1')), 
		(11, 10, ref_nomenclatures.get_id_nomenclature('ROLE_ACTEUR', '1')), 
		(12, 6, ref_nomenclatures.get_id_nomenclature('ROLE_ACTEUR', '1')), 
		(16, 0, ref_nomenclatures.get_id_nomenclature('ROLE_ACTEUR', '1')), 
		(8, 3, ref_nomenclatures.get_id_nomenclature('ROLE_ACTEUR', '1')), 
		(9, 3, ref_nomenclatures.get_id_nomenclature('ROLE_ACTEUR', '1'));
-- les fournisseurs des jeux de données
INSERT INTO gn_meta.cor_dataset_actor(
	id_dataset, id_organism, id_nomenclature_actor_role)
	VALUES (1, 3, ref_nomenclatures.get_id_nomenclature('ROLE_ACTEUR', '5')), 
		(2, 3, ref_nomenclatures.get_id_nomenclature('ROLE_ACTEUR', '5')), 
		(8, 3, ref_nomenclatures.get_id_nomenclature('ROLE_ACTEUR', '5')), 
		(22, 3, ref_nomenclatures.get_id_nomenclature('ROLE_ACTEUR', '5')), 
		(9, 3, ref_nomenclatures.get_id_nomenclature('ROLE_ACTEUR', '5')), 
		(28, 3, ref_nomenclatures.get_id_nomenclature('ROLE_ACTEUR', '5')), 
		(10, 3, ref_nomenclatures.get_id_nomenclature('ROLE_ACTEUR', '5')), 
		(11, 3, ref_nomenclatures.get_id_nomenclature('ROLE_ACTEUR', '5')), 
		(12, 3, ref_nomenclatures.get_id_nomenclature('ROLE_ACTEUR', '5')), 
		(13, 3, ref_nomenclatures.get_id_nomenclature('ROLE_ACTEUR', '5')), 
		(14, 3, ref_nomenclatures.get_id_nomenclature('ROLE_ACTEUR', '5')), 
		(15, 3, ref_nomenclatures.get_id_nomenclature('ROLE_ACTEUR', '5')), 
		(16, 3, ref_nomenclatures.get_id_nomenclature('ROLE_ACTEUR', '5')), 
		(17, 3, ref_nomenclatures.get_id_nomenclature('ROLE_ACTEUR', '5')), 
		(18, 3, ref_nomenclatures.get_id_nomenclature('ROLE_ACTEUR', '5')), 
		(19, 3, ref_nomenclatures.get_id_nomenclature('ROLE_ACTEUR', '5')), 
		(29, 3, ref_nomenclatures.get_id_nomenclature('ROLE_ACTEUR', '5')), 
		(30, 3, ref_nomenclatures.get_id_nomenclature('ROLE_ACTEUR', '5')), 
		(31, 3, ref_nomenclatures.get_id_nomenclature('ROLE_ACTEUR', '5')), 
		(32, 3, ref_nomenclatures.get_id_nomenclature('ROLE_ACTEUR', '5')), 
		(33, 3, ref_nomenclatures.get_id_nomenclature('ROLE_ACTEUR', '5')), 
		(34, 3, ref_nomenclatures.get_id_nomenclature('ROLE_ACTEUR', '5')), 
		(35, 3, ref_nomenclatures.get_id_nomenclature('ROLE_ACTEUR', '5')), 
		(20, 3, ref_nomenclatures.get_id_nomenclature('ROLE_ACTEUR', '5')), 
		(37, 3, ref_nomenclatures.get_id_nomenclature('ROLE_ACTEUR', '5')), 
		(38, 3, ref_nomenclatures.get_id_nomenclature('ROLE_ACTEUR', '5')), 
		(39, 3, ref_nomenclatures.get_id_nomenclature('ROLE_ACTEUR', '5')), 
		(40, 3, ref_nomenclatures.get_id_nomenclature('ROLE_ACTEUR', '5')), 
		(21, 9, ref_nomenclatures.get_id_nomenclature('ROLE_ACTEUR', '5')), 
		(23, 4, ref_nomenclatures.get_id_nomenclature('ROLE_ACTEUR', '5')), 
		(24, 6, ref_nomenclatures.get_id_nomenclature('ROLE_ACTEUR', '5')), 
		(25, 8, ref_nomenclatures.get_id_nomenclature('ROLE_ACTEUR', '5')), 
		(26, 4, ref_nomenclatures.get_id_nomenclature('ROLE_ACTEUR', '5')), 
		(27, -1, ref_nomenclatures.get_id_nomenclature('ROLE_ACTEUR', '5')), 
		(41, -1, ref_nomenclatures.get_id_nomenclature('ROLE_ACTEUR', '5'));
-- les dates min et max des frameworks
UPDATE gn_meta.t_acquisition_frameworks
	SET acquisition_framework_start_date = dt_minmax.datemin	
	FROM (SELECT id_acquisition_framework, min(date_min) as datemin, max(date_max) as datemax
		FROM gn_synthese.synthese INNER JOIN gn_meta.t_datasets ON synthese.id_dataset = t_datasets.id_dataset
		GROUP BY id_acquisition_framework) as dt_minmax
		WHERE t_acquisition_frameworks.id_acquisition_framework = dt_minmax.id_acquisition_framework;
UPDATE gn_meta.t_acquisition_frameworks
	SET acquisition_framework_end_date = dt_minmax.datemax	
	FROM (SELECT id_acquisition_framework, min(date_min) as datemin, max(date_max) as datemax
		FROM gn_synthese.synthese INNER JOIN gn_meta.t_datasets ON synthese.id_dataset = t_datasets.id_dataset
		GROUP BY id_acquisition_framework) as dt_minmax
		WHERE t_acquisition_frameworks.id_acquisition_framework = dt_minmax.id_acquisition_framework
			AND t_acquisition_frameworks.id_acquisition_framework in (10);

---------------------------------------------------------------------------------------- gn_commons
	-- ==>renommage modules et permissions
UPDATE gn_commons.t_modules SET module_label='Administration', module_desc='Backoffice de GeoNature' WHERE module_code='ADMIN';
UPDATE gn_commons.t_modules SET module_label='Métadonnées', module_desc='Administration des métadonnées' WHERE module_code='METADATA';
UPDATE gn_commons.t_modules SET module_label='Synthèse', module_desc='Consultation des données'	WHERE module_code='SYNTHESE';
UPDATE gn_commons.t_modules SET module_label='Saisie - Taxons', module_desc='Module OccTax: saisie des observations naturalistes.' WHERE module_code='OCCTAX';
UPDATE gn_commons.t_modules SET module_label='Saisie - Habitats', module_desc='Module OccHab: cartographie des habitats' WHERE module_code='OCCHAB';
UPDATE gn_commons.t_modules SET module_label='Validation', module_desc='Module de validation des données: une à une, par lots...' WHERE module_code='VALIDATION';
-- ajout des gn_commons.cor_module_dataset (saisie occtax)
INSERT INTO gn_commons.cor_module_dataset (id_module, id_dataset) 
	SELECT 3, id_dataset from gn_meta.t_datasets; -- tous les datasets dans la synthese
INSERT INTO gn_commons.cor_module_dataset (id_module, id_dataset)
	SELECT 4, id_dataset from gn_meta.t_datasets where id_acquisition_framework = 1; -- saisie dans occtax pour les obs' des agents
INSERT INTO gn_commons.cor_module_dataset (id_module, id_dataset)
	SELECT 6, id_dataset from gn_meta.t_datasets where id_acquisition_framework in (1,11,12); -- validation pour les saisies de agents, les ika et les stoc
	
	
SELECT setval('gn_meta.t_acquisition_frameworks_id_acquisition_framework_seq', (SELECT MAX(id_acquisition_framework) FROM gn_meta.t_acquisition_frameworks)+1);


----------------------- ------------0/ Métadonnées pour les ABC Saül et Papaïchton
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
			ref_nomenclatures.get_id_nomenclature('NIVEAU_TERRITORIAL', '7'), 
			'Centrage des inventaires sur quelques zones clés de Saül', 
			'ABC, Saül, amphibiens, escargots, champignons, flore, habitats, orchidées', 
			ref_nomenclatures.get_id_nomenclature('TYPE_FINANCEMENT', '1'),
			'Identifier les enjeux sur les groupes taxonomiques suivants: amphibiens, escargots, champignons, flore, habitats, orchidées', 'ecologic', 
			null, false, true, null, 
			'2018-01-01', '2021-12-31'),
		(uuid_generate_v4(), 
			'Atlas de la Biodiversité Communale de Papaïchton', 
			'Etat des lieux de la biodiversité de Papaïchton. **PAG + Mairie**', 
			ref_nomenclatures.get_id_nomenclature('NIVEAU_TERRITORIAL', '7'), 
			'Centrage des inventaires sur quelques zones clés de Papaïchton', 
			'ABC, Papaïchton, amphibiens, oiseaux, poissons, flore, habitats', 
			ref_nomenclatures.get_id_nomenclature('TYPE_FINANCEMENT', '1'),
			'Identifier les enjeux sur les groupes taxonomiques suivants: amphibiens, oiseaux, poissons, flore, habitats', 'ecologic', 
			null, false, true, null, 
			'2020-06-01', '2023-12-31');
INSERT INTO gn_meta.cor_acquisition_framework_actor(id_acquisition_framework, id_organism, id_nomenclature_actor_role)
	SELECT id_acquisition_framework, 3, 360  -- MO
		FROM gn_meta.t_acquisition_frameworks
		WHERE acquisition_framework_name like 'Atlas de la Biodiversité Communale de%'
	UNION 	SELECT id_acquisition_framework, 3, ref_nomenclatures.get_id_nomenclature('ROLE_ACTEUR', '1') -- Contact pricipal
		FROM gn_meta.t_acquisition_frameworks
		WHERE acquisition_framework_name like 'Atlas de la Biodiversité Communale de%';
		
-- Création des JDD "Faune", "Flore" et "Fonge" de Saül
INSERT INTO gn_meta.t_datasets(	id_dataset, unique_dataset_id, id_acquisition_framework, 
		dataset_name, dataset_shortname, dataset_desc, 
		id_nomenclature_data_type, marine_domain, terrestrial_domain, 
		id_nomenclature_dataset_objectif,  id_nomenclature_collecting_method, id_nomenclature_data_origin, id_nomenclature_source_status, id_nomenclature_resource_type, 
		active, validable, id_digitizer)
	SELECT 42, uuid_generate_v4() as unique_dataset_id, id_acquisition_framework, 
		'ABCSaül - Flore', 'ABCSaül - Flore', 'Acquisition de données floristiques dans le cadre de l''ABC de Saül', 
		ref_nomenclatures.get_id_nomenclature('DATA_TYP', '1'), false, true, 
		ref_nomenclatures.get_id_nomenclature('METHO_RECUEIL', '1'), ref_nomenclatures.get_id_nomenclature('METHO_RECUEIL', '1'), ref_nomenclatures.get_id_nomenclature('DS_PUBLIQUE', 'Pu'), ref_nomenclatures.get_id_nomenclature('STATUT_SOURCE', 'Te'), ref_nomenclatures.get_id_nomenclature('RESOURCE_TYP', '1'),
		true, true, 1000052	
	FROM gn_meta.t_acquisition_frameworks
		WHERE acquisition_framework_name = 'Atlas de la Biodiversité Communale de Saül';
		
INSERT INTO gn_meta.t_datasets(	id_dataset, unique_dataset_id, id_acquisition_framework, 
		dataset_name, dataset_shortname, dataset_desc, 
		id_nomenclature_data_type, marine_domain, terrestrial_domain, 
		id_nomenclature_dataset_objectif,  id_nomenclature_collecting_method, id_nomenclature_data_origin, id_nomenclature_source_status, id_nomenclature_resource_type, 
		active, validable, id_digitizer)
	SELECT 43, uuid_generate_v4() as unique_dataset_id, id_acquisition_framework, 
		'ABCSaül - Faune', 'ABCSaül - Faune', 'Acquisition de données faunistiques opportunistes dans le cadre de l''ABC de Saül', 
		ref_nomenclatures.get_id_nomenclature('DATA_TYP', '1'), false, true, 
		ref_nomenclatures.get_id_nomenclature('METHO_RECUEIL', '1'), ref_nomenclatures.get_id_nomenclature('METHO_RECUEIL', '1'), ref_nomenclatures.get_id_nomenclature('DS_PUBLIQUE', 'Pu'), ref_nomenclatures.get_id_nomenclature('STATUT_SOURCE', 'Te'), ref_nomenclatures.get_id_nomenclature('RESOURCE_TYP', '1'),
		true, true, 1000052	
	FROM gn_meta.t_acquisition_frameworks
		WHERE acquisition_framework_name = 'Atlas de la Biodiversité Communale de Saül';

INSERT INTO gn_meta.t_datasets(	id_dataset, unique_dataset_id, id_acquisition_framework, 
		dataset_name, dataset_shortname, dataset_desc, 
		id_nomenclature_data_type, marine_domain, terrestrial_domain, 
		id_nomenclature_dataset_objectif,  id_nomenclature_collecting_method, id_nomenclature_data_origin, id_nomenclature_source_status, id_nomenclature_resource_type, 
		active, validable, id_digitizer)
	SELECT 44, uuid_generate_v4() as unique_dataset_id, id_acquisition_framework, 
		'ABCSaül - Fonge', 'ABCSaül - Fonge', 'Acquisition de données fonge opportunistes dans le cadre de l''ABC de Saül', 
		ref_nomenclatures.get_id_nomenclature('DATA_TYP', '1'), false, true, 
		ref_nomenclatures.get_id_nomenclature('METHO_RECUEIL', '1'), ref_nomenclatures.get_id_nomenclature('METHO_RECUEIL', '1'), ref_nomenclatures.get_id_nomenclature('DS_PUBLIQUE', 'Pu'), ref_nomenclatures.get_id_nomenclature('STATUT_SOURCE', 'Te'), ref_nomenclatures.get_id_nomenclature('RESOURCE_TYP', '1'),
		true, true, 1000052	
	FROM gn_meta.t_acquisition_frameworks
		WHERE acquisition_framework_name = 'Atlas de la Biodiversité Communale de Saül';
		
INSERT INTO gn_meta.cor_dataset_actor(
	id_dataset, id_organism, id_nomenclature_actor_role)
	SELECT id_dataset, 3, ref_nomenclatures.get_id_nomenclature('ROLE_ACTEUR', '6'))
	FROM gn_meta.t_datasets
		WHERE dataset_shortname in ('ABCSaül - Flore', 'ABCSaül - Faune', 'ABCSaül - Fonge');
		

INSERT INTO gn_commons.cor_module_dataset (id_module, id_dataset) 
	SELECT 3, id_dataset
		FROM gn_meta.t_datasets
		WHERE dataset_shortname in ('ABCSaül - Flore', 'ABCSaül - Faune', 'ABCSaül - Fonge')
	UNION SELECT 4, id_dataset
		FROM gn_meta.t_datasets
		WHERE dataset_shortname in ('ABCSaül - Flore', 'ABCSaül - Faune', 'ABCSaül - Fonge')
	UNION SELECT 6, id_dataset
		FROM gn_meta.t_datasets
		WHERE dataset_shortname in ('ABCSaül - Flore', 'ABCSaül - Faune', 'ABCSaül - Fonge');
		
-- Création des sources "Faune", "Flore" et "Fonge" de Saül
INSERT INTO gn_synthese.t_sources(
	id_source, name_source, desc_source, entity_source_pk_field, url_source)
	VALUES 
	(53, 'ABCSaül - Flore', 'Acquisition de données floristiques dans le cadre de l''ABC de Saül. **PAG**', 'pr_occtax.cor_counting_occtax.id_counting_occtax', '#/occtax/info/id_counting'),
	(54, 'ABCSaül - Faune', 'Acquisition de données faunistiques dans le cadre de l''ABC de Saül. **PAG**', 'pr_occtax.cor_counting_occtax.id_counting_occtax', '#/occtax/info/id_counting'),
	(55, 'ABCSaül - Fonge', 'Acquisition de données fongistiques dans le cadre de l''ABC de Saül. **PAG**', 'pr_occtax.cor_counting_occtax.id_counting_occtax', '#/occtax/info/id_counting')
	;
SELECT setval('gn_meta.t_datasets_id_dataset_seq', (SELECT MAX(id_dataset) FROM gn_meta.t_datasets)+1);
SELECT setval('gn_synthese.t_sources_id_source_seq', (SELECT MAX(id_source) FROM gn_synthese.t_sources)+1);