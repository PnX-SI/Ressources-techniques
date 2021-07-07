---------------------------------------------------------------------------------------------------------
----------------------------------- Intégration des données DIADEMA (Limonade),
-----------------------------------     des données des relevés 'arbres' (Habitats),
-----------------------------------     des obs ABC: reco Galbao, inventaires divers... 
---------------------------------------------------------------------------------------------------------



----------------------------------- création de la structure et des métadonnées + source_data
INSERT INTO utilisateurs.bib_organismes(id_organisme, nom_organisme, adresse_organisme, cp_organisme, ville_organisme) 
	VALUES 
		(13, 'ONF de Guyane', 'Colline de Montabo', '97300', 'Cayenne'),---->> ONF = 13
		(14, 'Fondation Biotope', 'Domaine de Montabo','97300', 'Cayenne'),---->> Fnd. Biotope = 14
		(15, 'Labo. Hydreco', '','', ''), 
		(16, 'Université Toulouse III, Laboratoire EDB', 'route de Narbonne', '31062', 'Toulouse'),---->> Labo EDB = 16
		(17, 'UMR EcoFoG','', '', ''), --> EcoFoG = 17
		(18, 'MNHN, UMS PatriNat','', '', 'Paris'), -- MNHN
		(19, 'Grand public', '', '', ''),
		(20, 'Asso. Cérato', '', '', ''),
		(21, 'Asso. GCG (Goupe Chiroptère de Guyane)', '', '', ''),
		(22, 'Exp. Guillaume Léotard', '', '', ''),
		(23, 'Asso. Trésor', '', '', ''),
		(24, 'UMR AMAP','', '', ''), 
		(25, 'Bénévoles','', '', ''),
		(26, 'Exp. Johan Chevalier (WANO)', '', '', ''),
		(27, 'Exp. Maël Dewynter', '', '', '')
		; 
-- id_dataset ====> Habitats Galbao = 47 (ABC); Sentiers = 48 (ABC); Limonade = 49 (données partenariales)...
INSERT INTO gn_meta.t_datasets(
	id_dataset, id_acquisition_framework, dataset_name, dataset_shortname, dataset_desc, 
	id_nomenclature_data_type, keywords, marine_domain, terrestrial_domain, id_nomenclature_dataset_objectif,id_nomenclature_collecting_method, 
	id_nomenclature_data_origin, id_nomenclature_source_status, id_nomenclature_resource_type, active, validable, id_digitizer)
	VALUES
		(47, 18, 'ABCSaül - Habitats Monts Galbao (2019)', 'Habitats Galbao (2019)', 'Diagnostic des habitats forestiers des monts Galbao (flore des sous-bois dans JDD ''ABC Saül-Flore'') **ONF de Guyane**', 322, 'Habitats forestiers, arbres, monts Galbao, Saül, ABC', false, true, 413, 395, 76, 73, 320, false, false, 1000052), --Habitats Galbao = 47 (ABC)
		(48, 18, 'ABCSaül - Habitats Sentiers de Saül (2019)', 'Habitats Sentiers Saül (2019)', 'Diagnostic des habitats forestiers des sentiers de Saül (flore des sous-bois dans JDD ''ABC Saül-Flore'') **ONF de Guyane**', 322, 'Habitats forestiers, arbres, sentiers, Saül, ABC', false, true, 413, 395, 76, 73, 320, false, false, 1000052), --Habitats Sentiers = 48 (ABC)
		(49, 16, 'Habitats - Flats Limonade (2013)', 'Habitats - Limonade (2013)', 'Diagnostic des habitats forestiers des flats de la crique Limonade **ONF de Guyane**', 322, 'Habitats forestiers, arbres, flats de la Limonade, Saül', false, true, 413, 395, 76, 73, 320, false, false, 1000052), --Limonade = 49 (données partenariales)
		(50, 18, 'ABCSaül - Reconnaissance des monts Galbao (2018)', 'Reco Galbao (2018)', 'ABC de Saül - Mission de reconnaissance des monts Galbao (flore des sous-bois dans JDD ''ABC Saül-Flore'') **PAG, ONF de Guyane, Fond. Biotope**', 322, 'Faune, Flore, Monts Galbao, Saül, ABC', false, true, 417, 395, 76, 73, 320, true, true, 1000052), --RecoGalbao = 50
		(51, 18, 'ABCSaül - Inventaire malacologique (2018)', 'Malaco (2018)', 'ABC de Saül - 1er inventaire malacologique **MNHN**', 322, 'Malacologie, Escargots, Galbao, sentiers, Saül, ABC', false, true, 417, 395, 76, 73, 320, true, true, 1000052),
		(52, 18, 'ABCSaül - Inventaire malacologique (2020)', 'Malaco (2020)', 'ABC de Saül - 2e inventaire malacologique **MNHN**', 322, 'Malacologie, Escargots, Galbao, sentiers, Saül, ABC', false, true, 417, 395, 76, 73, 320, true, true, 1000052),
		(53, 18, 'ABCSaül - Mycologie participative (2020-2021)', 'Myco iNaturalist (2020-2021)', 'ABC de Saül - Inventaire participatif iNaturalist **PAG, Univ Toulouse III et grand public**', 322, 'Mycologie, champignons, grand public, iNaturalist, Saül, ABC', false, true, 417, 395, 76, 73, 320, true, true, 1000052),
		(54, 18, 'ABCSaül - Contributions grand public', 'ABCSaül- grand public', 'ABC de Saül - Communications et contributions personnelles **grand public**',322, 'grand public, Saül, ABC', false, true, 417, 395, 76, 73, 320, true, true, 1000052),
		(55, 18, 'ABCSaül - Fête de la Nature 2018', 'ABCSaül- FdN 2018', 'ABC de Saül - Fête de la Nature 2018 **PAG, EcoFoG, GCG**',  322, 'grand public, Saül, ABC', false, true, 417, 395,  76, 73, 320, true, true, 1000052),
		(56, 18, 'ABCSaül - Fête de la Nature 2019', 'ABCSaül- FdN 2019', 'ABC de Saül - Fête de la Nature 2018 **PAG, Cérato, expert**',  322, 'grand public, Saül, ABC', false, true, 417, 395,  76, 73, 320, true, true, 1000052),
		(57, 9, 'Itoupé 2017', 'Itoupé 2017', 'Inventaire pluridisciplinaire d''Itoupé (2017) **PAG, CNRS, UMR AMAP', 322, '', false, true, 417, 395,  76, 73, 320, true, true, 1000052),
		(58, 9, 'Itoupé 2018', 'Itoupé 2018', 'Inventaire pluridisciplinaire d''Itoupé (2018) **PAG, CNRS, Fond. Biotope', 322, '', false, true, 417, 395,  76, 73, 320, true, true, 1000052),
		(59, 9, 'Itoupé 2021', 'Itoupé 2021', 'Inventaire pluridisciplinaire d''Itoupé (2021) **PAG, CNRS, asso. Trésor, expert', 322, '', false, true, 417, 395,  76, 73, 320, true, true, 1000052),
		(60, 18, 'ABCSaül - Herpétologie monts Galbao (2018)', 'Herpéto Galbao (2018)', 'ABC de Saül - Mission herpétologique des monts Galbao (flore des sous-bois dans JDD ''ABC Saül-Flore'') **PAG, CNRS, Fond. Biotope**',  322, 'Faune, amphibiens, reptiles, Monts Galbao, Saül, ABC', false, true, 417, 395, 76, 73, 320, true, true, 1000052),
		(61, 18, 'ABCSaül - Herpétologie Savane-roche Dachine (2019)', 'Herpéto SR Dachine (2019)', 'ABC de Saül - Mission pluridisciplinaire savane-Roche Dachine (flore des sous-bois dans JDD ''ABC Saül-Flore'') **PAG, CNRS, Fond. Biotope**',  322, 'Faune, amphibiens, reptiles, Monts Galbao, Saül, ABC', false, true, 417, 395, 76, 73, 320, true, true, 1000052),
		(62, 19, 'ABCPPI - IKA Gros Saut (2020)', 'IKA Gros Saut (2020)', 'ABC de PPI - Indice Kilométrique d''Abondance réalisé à Gros Saut **PAG**',  322, 'IKA, grande faune, ABC, Papaïchton, Gros Saut', false, true, 417, 395, 76, 73, 320, true, true, 1000052),
		(63, 19, 'ABCPPI - Gros Saut saison sèche (2020)', 'Gros Saut (2020)', 'ABC de PPI - Mission pluridisciplinaire de saison sèche à Gros Saut (poissons, crustacés, scorpions, amphibiens) **PAG, Hydreco, expert, Fond. Biotope**', 322, 'poissons, amphibiens, crevettes, scorpions, ABC, Papaïchton, Gros Saut', false, true, 417, 395, 76, 73, 320, true, true, 1000052),
		(64, 19, 'ABCPPI - Gros Saut saison des pluies (2021)', 'Gros Saut (2021)', 'ABC de PPI - Mission pluridisciplinaire de saison des pluies à Gros Saut (amphibiens, reptiles, oiseaux, chiroptères, flore) **PAG, CNRS, expert, Fond. Biotope**',  322, 'amphibiens, reptiles, oiseaux, chiroptères, flore, ABC, Papaïchton, Gros Saut', false, true, 417, 395, 76, 73, 320, true, true, 1000052),
		(65, 19, 'ABCPPI - Habitats Gros Saut (2021)', 'Habitats - Gros Saut (2021)', 'Diagnostic des habitats forestiers du secteur de Gros Saut **ONF de Guyane**', 322, 'Habitats forestiers, arbres, flats de la Limonade, Saül', false, true, 413, 395, 76, 73, 320, true, false, 1000052)
		;
		--itoupé 2016: vers de terre, opilions
		
INSERT INTO gn_meta.cor_dataset_actor(id_dataset, id_organism, id_nomenclature_actor_role) 
	VALUES 
		(9, 10, 363), (9, 12, 363), (9, 13, 363), (9, 17, 363), (9,24, 363), (9,25, 363),
		(28, 9 , 363), (28, 25, 363), (28, 14, 363),(28, 3, 363), 
		(47, 13, 363), (47, 3, 360),
		(48, 13, 363), (48, 3, 360),
		(49, 13, 363),
		(50, 13, 363), (50, 14, 363), (50, 3, 363), (50, 3, 360),
		(51, 18, 363), (51, 3, 360),
		(52, 18, 363), (52, 3, 360),
		(53, 19, 363), (53, 16, 362), (53, 3, 360),
		(54, 19, 363),
		(55, 21, 363), (55, 19, 363), (55, 3, 360),
		(56, 20, 363), (56, 19, 363), (56, 3, 363), (56, 3, 360),
		(57, 9 , 363), (57, 24, 363), (57, 3, 360),
		(58, 9 , 363), (58, 14, 363), (58, 3, 360),
		(59, 9 , 363), (59, 23, 363), (59, 22, 363),(59, 3, 363), (59, 3, 360),
		(60, 14, 363), (60, 9 , 363), (60, 3, 363), (60, 3, 360),
		(61, 14, 363), (61, 9 , 363), (61, 3, 363), (61, 3, 360),
		(62, 3, 363), (62, 3, 360),
		(63, 3, 363), (63, 3, 360), (63, 15, 363),(63, 14, 363),(63, 26, 363),
		(64, 3, 363), (64, 3, 360), (64, 14, 363),(64, 9, 363),(64, 27, 363),
		(65, 13, 363), (65, 3, 360)
		;

-- id_source ====> 59 à 61
INSERT INTO gn_synthese.t_sources(id_source, name_source, desc_source)	
	VALUES (59, 'ABCSaül - Habitats Monts Galbao (2019)', 'Diagnostic des habitats forestiers des monts Galbao **ONF de Guyane**'),
		(60, 'ABCSaül - Habitats Sentiers de Saül (2019)', 'Diagnostic des habitats forestiers des sentiers de Saül **ONF de Guyane**'),
		(61, 'Habitats - Flats Limonade (2013)', 'Diagnostic des habitats forestiers des flats de la crique Limonade **ONF de Guyane**'),
		(62, 'ABCSaül - Reconnaissance des monts Galbao (2018)', 'ABC de Saül - Mission de reconnaissance des monts Galbao **PAG, ONF de Guyane, Fond. Biotope**'),
		(63, 'ABCSaül - CardObs malacolo Saül','ABC de Saül - Inventaires malaco 2018 et 2020 **MNHN**'),
		--(64, 'ABCSaül - Inventaire malacologique (2020)','ABC de Saül - 2e inventaire malacologique **MNHN**'),
		(65, 'ABCSaül - Mycologie participative (2020-2021)', 'ABC de Saül - Inventaire participatif iNaturalist **PAG, Univ Toulouse III et grand public**'),
		(66, 'iNaturalist', 'Plateforme participative iNaturalist **grand public**'),
		(67, 'ABCSaül - Fête de la Nature 2018', 'ABC de Saül - Fête de la Nature 2018 **PAG, EcoFoG, GCG**'),
		(68, 'ABCSaül - Fête de la Nature 2019', 'ABC de Saül - Fête de la Nature 2018 **PAG, Cérato, expert**'),
		(69, 'Itoupé 2017', 'Inventaire pluridisciplinaire d''Itoupé (2017) **PAG, CNRS, UMR AMAP'),
		(70, 'Itoupé 2018', 'Inventaire pluridisciplinaire d''Itoupé (2018) **PAG, CNRS, Fond. Biotope'),
		(71, 'Itoupé 2021', 'Inventaire pluridisciplinaire d''Itoupé (2021) **PAG, CNRS, asso. Trésor, expert')
		;
		
------------------------------------------------------------------------------------- Ré-attribution des données FG réalisées dans le cadre des études PAG
-- herpéto galbao 2018
UPDATE gn_synthese.synthese
	SET id_dataset = 60
	WHERE date_min >='15/10/2018' and date_min <='22/10/2018' and id_dataset = 24
	AND ST_Within(the_geom_local, ST_GeometryFromText('Polygon ((236865.21986772728268988 402552.15383158542681485, 242858.19864741052151658 404032.20122251933207735, 248390.17905942580546252 401824.26167210971470922, 251811.27220896157086827 399106.79761006712215021, 249967.27873828980955295 392919.71425452368566766, 242106.04341595229925588 389983.88254463841440156, 235191.06790093317977153 392482.97895883827004582, 234584.49110137010575272 397723.80250706331571564, 236865.21986772728268988 402552.15383158542681485))',2972));
-- herpéto SR Dachine 2018
UPDATE pr_occtax.t_releves_occtax
	SET id_dataset = 61
	WHERE date_min >='4/03/2019' and date_min <='9/03/2019' and id_dataset <> 43 ;
UPDATE gn_synthese.synthese
	SET id_dataset = 61
	WHERE date_min >='4/03/2019' and date_min <='9/03/2019' and id_dataset <> 42 and observers in ('Elodie Courtois','Maël Dewynter', 'Sant Sebastien');
-- FDN 2019
UPDATE pr_occtax.t_releves_occtax
	SET id_dataset = 56
	WHERE id_dataset = 43 
		and extract(year from date_min) = 2019
		and extract(month from date_min) = 5
		and ST_Within(geom_local, ST_GeometryFromText('Polygon ((264389.38653571985196322 409150.79401394905289635, 254088.44633843254996464 409612.03014218580210581, 249091.72161586783477105 403154.72434687137138098, 248861.10355174946016632 395544.3282309650676325, 252089.75644940667552873 388548.91361937444889918, 261237.60632610210450366 387780.18673897988628596, 268617.38437789003364742 392200.36630124866496772, 270462.32889083697227761 400963.85273774684173986, 264389.38653571985196322 409150.79401394905289635))',2972));
UPDATE gn_synthese.synthese
	SET id_dataset = 56
	WHERE id_dataset in (24, 43)
		and extract(year from date_min) = 2019
		and extract(month from date_min) = 5
		and ST_Within(the_geom_local, ST_GeometryFromText('Polygon ((264389.38653571985196322 409150.79401394905289635, 254088.44633843254996464 409612.03014218580210581, 249091.72161586783477105 403154.72434687137138098, 248861.10355174946016632 395544.3282309650676325, 252089.75644940667552873 388548.91361937444889918, 261237.60632610210450366 387780.18673897988628596, 268617.38437789003364742 392200.36630124866496772, 270462.32889083697227761 400963.85273774684173986, 264389.38653571985196322 409150.79401394905289635))',2972));
-- Itoupé 2021
UPDATE pr_occtax.t_releves_occtax
	SET id_dataset = 59
	WHERE date_min >='12/01/2021' and date_min <='21/01/2021'
	AND ST_Within(geom_local, ST_GeometryFromText('Polygon ((258004.42133250087499619 345770.49962448549922556, 258198.52590836104354821 324807.20543158543296158, 282558.6501788143068552 324030.78712814470054582, 282655.70246674440568313 345479.34276069520274177, 258004.42133250087499619 345770.49962448549922556))',2972));
UPDATE gn_synthese.synthese
	SET id_dataset = 59
	WHERE date_min >='12/01/2021' and date_min <='21/01/2021' and id_dataset in (24, 42,43)
	AND ST_Within(the_geom_local, ST_GeometryFromText('Polygon ((258004.42133250087499619 345770.49962448549922556, 258198.52590836104354821 324807.20543158543296158, 282558.6501788143068552 324030.78712814470054582, 282655.70246674440568313 345479.34276069520274177, 258004.42133250087499619 345770.49962448549922556))',2972));
--Itoupé 2018
UPDATE gn_synthese.synthese
	SET id_dataset = 58
	WHERE extract(year from date_min) = 2018 and id_dataset in (1,2,24)
	AND ST_Within(the_geom_local, ST_GeometryFromText('Polygon ((258004.42133250087499619 345770.49962448549922556, 258198.52590836104354821 324807.20543158543296158, 282558.6501788143068552 324030.78712814470054582, 282655.70246674440568313 345479.34276069520274177, 258004.42133250087499619 345770.49962448549922556))',2972));
--Itoupé 2017
UPDATE pr_occtax.t_releves_occtax
	SET id_dataset = 57
	WHERE extract(year from date_min) = 2017 and id_dataset in (1,2,24)
	AND ST_Within(geom_local, ST_GeometryFromText('Polygon ((258004.42133250087499619 345770.49962448549922556, 258198.52590836104354821 324807.20543158543296158, 282558.6501788143068552 324030.78712814470054582, 282655.70246674440568313 345479.34276069520274177, 258004.42133250087499619 345770.49962448549922556))',2972));
UPDATE gn_synthese.synthese
	SET id_dataset = 57
	WHERE extract(year from date_min) = 2017 and id_dataset in (1,2,24)
	AND ST_Within(the_geom_local, ST_GeometryFromText('Polygon ((258004.42133250087499619 345770.49962448549922556, 258198.52590836104354821 324807.20543158543296158, 282558.6501788143068552 324030.78712814470054582, 282655.70246674440568313 345479.34276069520274177, 258004.42133250087499619 345770.49962448549922556))',2972));
--Itoupé 2016
UPDATE pr_occtax.t_releves_occtax
	SET id_dataset = 28
	WHERE extract(year from date_min) = 2016 and id_dataset in (1,2,24)
	AND ST_Within(geom_local, ST_GeometryFromText('Polygon ((258004.42133250087499619 345770.49962448549922556, 258198.52590836104354821 324807.20543158543296158, 282558.6501788143068552 324030.78712814470054582, 282655.70246674440568313 345479.34276069520274177, 258004.42133250087499619 345770.49962448549922556))',2972));
UPDATE gn_synthese.synthese
	SET id_dataset = 28
	WHERE extract(year from date_min) = 2016 and id_dataset in (1,2,24)
	AND ST_Within(the_geom_local, ST_GeometryFromText('Polygon ((258004.42133250087499619 345770.49962448549922556, 258198.52590836104354821 324807.20543158543296158, 282558.6501788143068552 324030.78712814470054582, 282655.70246674440568313 345479.34276069520274177, 258004.42133250087499619 345770.49962448549922556))',2972));
--Itoupé 2010
UPDATE gn_synthese.synthese
	SET id_dataset = 9
	WHERE extract(year from date_min) = 2010 and id_dataset in (1,2,24)
	AND ST_Within(the_geom_local, ST_GeometryFromText('Polygon ((258004.42133250087499619 345770.49962448549922556, 258198.52590836104354821 324807.20543158543296158, 282558.6501788143068552 324030.78712814470054582, 282655.70246674440568313 345479.34276069520274177, 258004.42133250087499619 345770.49962448549922556))',2972));
-- Gros Saut 2020
UPDATE gn_synthese.synthese
	SET id_dataset = 63
	WHERE extract(year from date_min) in (2020) and ST_Within(the_geom_local, ST_GeometryFromText('Polygon ((176131.82773109237314202 465416.22899159678490832, 169470.85084033606108278 467886.02941176481544971, 159441.96428571420256048 462721.90126050432445481, 161537.55252100832876749 454489.23319327743956819, 167674.63235294111655094 448501.8382352942135185, 177179.62184873942169361 453067.22689075639937073, 176131.82773109237314202 465416.22899159678490832))',2972));
-- Gros Saut 2021
UPDATE pr_occtax.t_releves_occtax
	SET id_dataset = 64
	WHERE extract(year from date_min) in (2021) and ST_Within(geom_local, ST_GeometryFromText('Polygon ((176131.82773109237314202 465416.22899159678490832, 169470.85084033606108278 467886.02941176481544971, 159441.96428571420256048 462721.90126050432445481, 161537.55252100832876749 454489.23319327743956819, 167674.63235294111655094 448501.8382352942135185, 177179.62184873942169361 453067.22689075639937073, 176131.82773109237314202 465416.22899159678490832))',2972));
UPDATE gn_synthese.synthese
	SET id_dataset = 64
	WHERE extract(year from date_min) in (2021) and ST_Within(the_geom_local, ST_GeometryFromText('Polygon ((176131.82773109237314202 465416.22899159678490832, 169470.85084033606108278 467886.02941176481544971, 159441.96428571420256048 462721.90126050432445481, 161537.55252100832876749 454489.23319327743956819, 167674.63235294111655094 448501.8382352942135185, 177179.62184873942169361 453067.22689075639937073, 176131.82773109237314202 465416.22899159678490832))',2972));
	
	
	
	
----------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------- Cardobs_Malaco ----------------------------------------------
----------------------------------------------------------------------------------------------------------------------------
DROP TABLE if exists gn_imports.synthese_malaco ;

--------------------------------------- 1/ Import des données Malaco
CREATE TABLE gn_imports.synthese_malaco 
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
	
COPY gn_imports.synthese_Malaco (id_synthese, id_source, id_module, entity_source_pk_value, id_dataset, id_nomenclature_geo_object_nature,
    id_nomenclature_grp_typ, grp_method, id_nomenclature_obs_technique, id_nomenclature_bio_status,
    id_nomenclature_bio_condition, id_nomenclature_naturalness, id_nomenclature_exist_proof, id_nomenclature_valid_status,
    id_nomenclature_diffusion_level, id_nomenclature_life_stage, id_nomenclature_sex, id_nomenclature_obj_count,
	id_nomenclature_type_count, count_min, count_max, cd_nom, cd_hab, nom_cite, meta_v_taxref, sample_number_proof ,
    digital_proof, non_digital_proof, altitude_min, altitude_max, place_name, latitude, longitude,
    id_area_attachment, date_min, date_max, validator, validation_comment, observers, determiner, id_digitiser, id_nomenclature_determination_method, comment_context, comment_description)
	FROM '/home/geonatureadmin/Ressources-techniques/GeoNature/PNX/process/pag/integration_data/20210701_synthese_malaco.csv' WITH csv HEADER DELIMITER ';';
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
	digital_proof, non_digital_proof, altitude_min, altitude_max, 
	place_name, the_geom_4326, the_geom_point, the_geom_local, 
	id_area_attachment, date_min, date_max, validator, validation_comment, 
	observers, determiner, id_digitiser, id_nomenclature_determination_method, 
	comment_context, comment_description)
	SELECT uuid_generate_v4() AS unique_id_sinp_grp, id_source, id_module, entity_source_pk_value, id_dataset, 
		170, id_nomenclature_grp_typ, grp_method, id_nomenclature_obs_technique, 
		id_nomenclature_bio_status, id_nomenclature_bio_condition, id_nomenclature_naturalness, 
		id_nomenclature_exist_proof, id_nomenclature_valid_status,id_nomenclature_diffusion_level, 
		id_nomenclature_life_stage, id_nomenclature_sex, id_nomenclature_obj_count,
		id_nomenclature_type_count, 84,
		171,70,123, 543, 175,
		count_min, count_max, cd_nom, cd_hab, nom_cite, meta_v_taxref, sample_number_proof,
		digital_proof, non_digital_proof, altitude_min, altitude_max, 
		place_name, 
		ST_Transform(ST_SetSRID(ST_MakePoint(to_number(latitude, '999999'),to_number(longitude, '999999')), 2972), 4326) AS geom_4326, ST_Transform(ST_SetSRID(ST_MakePoint(to_number(latitude, '999999'),to_number(longitude, '999999')), 2972), 4326) AS the_geom_point, ST_SetSRID(ST_MakePoint(to_number(latitude, '999999'),to_number(longitude, '999999')), 2972)  as geom, 
		id_area_attachment, date_min, date_max, validator, validation_comment, 
		observers, determiner, 1000052, id_nomenclature_determination_method, 
		comment_context, comment_description
		FROM gn_imports.synthese_Malaco;
		
----------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------- iNaturalist -----------------------------------------------
----------------------------------------------------------------------------------------------------------------------------
DROP TABLE if exists gn_imports.synthese_inaturalist ;

--------------------------------------- 1/ Import des données iNaturalist
CREATE TABLE gn_imports.synthese_inaturalist 
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
COPY gn_imports.synthese_inaturalist (id_synthese, id_source, id_module, entity_source_pk_value, id_dataset, id_nomenclature_geo_object_nature,
    id_nomenclature_grp_typ, grp_method, id_nomenclature_obs_technique, id_nomenclature_bio_status,
    id_nomenclature_bio_condition, id_nomenclature_naturalness, id_nomenclature_exist_proof, id_nomenclature_valid_status,
    id_nomenclature_diffusion_level, id_nomenclature_life_stage, id_nomenclature_sex, id_nomenclature_obj_count,
	id_nomenclature_type_count, count_min, count_max, cd_nom, cd_hab, nom_cite, meta_v_taxref, sample_number_proof ,
    digital_proof, non_digital_proof, altitude_min, altitude_max, depth_min, depth_max, place_name, latitude, longitude,
    id_area_attachment, date_min, date_max, validator, validation_comment, observers, determiner, id_digitiser, id_nomenclature_determination_method, comment_context, comment_description)
	FROM '/home/geonatureadmin/Ressources-techniques/GeoNature/PNX/process/pag/integration_data/20210705_synthese_inaturalist.csv' WITH csv HEADER DELIMITER ';';
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
	digital_proof, non_digital_proof, altitude_min, altitude_max, 
	place_name, the_geom_4326, the_geom_point, the_geom_local, 
	id_area_attachment, date_min, date_max, validator, validation_comment, 
	observers, determiner, id_digitiser, id_nomenclature_determination_method, 
	comment_context, comment_description)
	SELECT uuid_generate_v4() AS unique_id_sinp_grp, id_source, id_module, entity_source_pk_value, id_dataset, 
		170, id_nomenclature_grp_typ, grp_method, id_nomenclature_obs_technique, 
		id_nomenclature_bio_status, id_nomenclature_bio_condition, id_nomenclature_naturalness, 
		id_nomenclature_exist_proof, id_nomenclature_valid_status,id_nomenclature_diffusion_level, 
		id_nomenclature_life_stage, id_nomenclature_sex, id_nomenclature_obj_count,
		id_nomenclature_type_count, 84,
		171,73,122, 543, 175,
		count_min, count_max, cd_nom, cd_hab, nom_cite, meta_v_taxref, sample_number_proof,
		digital_proof, non_digital_proof, altitude_min, altitude_max, 
		place_name, 
		ST_SetSRID(ST_MakePoint(to_number(longitude, 'SG99.99999999999'),to_number(latitude, '9.99999999999')), 4326) AS the_geom_4326, 
		ST_SetSRID(ST_MakePoint(to_number(longitude, 'SG99.99999999999'),to_number(latitude, '9.99999999999')), 4326) AS the_geom_point, 
		ST_Transform(ST_SetSRID(ST_MakePoint(to_number(longitude, 'SG99.99999999999'),to_number(latitude, '9.99999999999')), 4326), 2972) as geom, 
		id_area_attachment, date_min, date_max, validator, validation_comment, 
		observers, determiner, 1000052, id_nomenclature_determination_method, 
		comment_context, comment_description
		FROM gn_imports.synthese_inaturalist;	
		
		
----------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------- cumul JDD: Habitats, Diadema, ABC... ----------------------
----------------------------------------------------------------------------------------------------------------------------		
DROP TABLE if exists gn_imports.synthese_cumul_data ;
--------------------------------------- 1/ Import des données cumulées
CREATE TABLE gn_imports.synthese_cumul_data
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
	nom_tmp_corresp character varying(1000),
    meta_v_taxref character varying(50) COLLATE pg_catalog."default" DEFAULT gn_commons.get_default_parameter('taxref_version'::text, NULL::integer),
    sample_number_proof text COLLATE pg_catalog."default",
    digital_proof text COLLATE pg_catalog."default",
    non_digital_proof text COLLATE pg_catalog."default",
    altitude_min integer,
    altitude_max integer,
    place_name character varying(500) COLLATE pg_catalog."default",
	y_longitude character varying(20),
	x_latitude character varying(20),
	x_rgfg95 double precision,
	y_rgfg95 double precision,
	poly character varying(5000),
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

COPY gn_imports.synthese_cumul_data (id_synthese, id_source, id_module, entity_source_pk_value, id_dataset, id_nomenclature_geo_object_nature,
    id_nomenclature_grp_typ, grp_method, id_nomenclature_obs_technique, id_nomenclature_bio_status,
    id_nomenclature_bio_condition, id_nomenclature_naturalness, id_nomenclature_exist_proof, id_nomenclature_valid_status,
    id_nomenclature_diffusion_level, id_nomenclature_life_stage, id_nomenclature_sex, id_nomenclature_obj_count,
	id_nomenclature_type_count, count_min, count_max, cd_nom, cd_hab, nom_cite, nom_tmp_corresp, meta_v_taxref, sample_number_proof ,
    digital_proof, non_digital_proof, altitude_min, altitude_max, place_name, y_longitude, x_latitude, x_rgfg95, y_rgfg95, poly,
    id_area_attachment, date_min, date_max, validator, validation_comment, observers, determiner, id_digitiser, id_nomenclature_determination_method, comment_context, comment_description)
	FROM '/home/geonatureadmin/Ressources-techniques/GeoNature/PNX/process/pag/integration_data/20210707_CumulDiademaEtc.csv' WITH csv HEADER DELIMITER ';';

--------------------------------------- 2/ Injection dans la synthese ==> polygones
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
	digital_proof, non_digital_proof, altitude_min, altitude_max, 
	place_name, the_geom_4326, the_geom_point, the_geom_local, 
	id_area_attachment, date_min, date_max, validator, validation_comment, 
	observers, determiner, id_digitiser, id_nomenclature_determination_method, 
	comment_context, comment_description)
	SELECT uuid_generate_v4() AS unique_id_sinp_grp, id_source, id_module, entity_source_pk_value, id_dataset, 
		id_nomenclature_geo_object_nature, id_nomenclature_grp_typ, grp_method, id_nomenclature_obs_technique, 
		id_nomenclature_bio_status, id_nomenclature_bio_condition, id_nomenclature_naturalness, 
		id_nomenclature_exist_proof, id_nomenclature_valid_status,id_nomenclature_diffusion_level, 
		id_nomenclature_life_stage, id_nomenclature_sex, id_nomenclature_obj_count,
		id_nomenclature_type_count, 84,
		171,73,123, 543, 175, -- 123: rattachement. sinon 122: coord.source
		count_min, count_max, cd_nom, cd_hab, nom_cite, meta_v_taxref, sample_number_proof,
		digital_proof, non_digital_proof, altitude_min, altitude_max, 
		place_name, 
		ST_Transform(ST_SetSRID(ST_Multi(ST_GeomFromText(poly)), 2972), 4326) AS the_geom_4326, 
		null AS the_geom_point, 
		ST_SetSRID(ST_Multi(ST_GeomFromText(poly)), 2972) as geom, 
		id_area_attachment, date_min, date_max, validator, validation_comment, 
		observers, determiner, 1000052, id_nomenclature_determination_method, 
		comment_context, comment_description
		FROM gn_imports.synthese_cumul_data
		where poly is not null;
--------------------------------------- 2/ Injection dans la synthese ==> points latitude/longitude
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
	digital_proof, non_digital_proof, altitude_min, altitude_max, 
	place_name, the_geom_4326, the_geom_point, the_geom_local, 
	id_area_attachment, date_min, date_max, validator, validation_comment, 
	observers, determiner, id_digitiser, id_nomenclature_determination_method, 
	comment_context, comment_description)
	SELECT uuid_generate_v4() AS unique_id_sinp_grp, id_source, id_module, entity_source_pk_value, id_dataset, 
		id_nomenclature_geo_object_nature, id_nomenclature_grp_typ, grp_method, id_nomenclature_obs_technique, 
		id_nomenclature_bio_status, id_nomenclature_bio_condition, id_nomenclature_naturalness, 
		id_nomenclature_exist_proof, id_nomenclature_valid_status,id_nomenclature_diffusion_level, 
		id_nomenclature_life_stage, id_nomenclature_sex, id_nomenclature_obj_count,
		id_nomenclature_type_count, 84,
		171,73,122, 543, 175, -- 123: rattachement. sinon 122: coord.source
		count_min, count_max, cd_nom, cd_hab, nom_cite, meta_v_taxref, sample_number_proof,
		digital_proof, non_digital_proof, altitude_min, altitude_max, 
		place_name, 
		ST_SetSRID(ST_MakePoint(to_number(replace(x_latitude,',', '.'),'SG99.99999999999'),to_number(replace(y_longitude,',', '.'),'9.99999999999')), 4326) AS the_geom_4326, 
		ST_SetSRID(ST_MakePoint(to_number(replace(x_latitude,',', '.'),'SG99.99999999999'),to_number(replace(y_longitude,',', '.'),'9.99999999999')), 4326) AS the_geom_point, 
		ST_Transform(ST_SetSRID(ST_MakePoint(to_number(replace(x_latitude,',', '.'),'SG99.99999999999'),to_number(replace(y_longitude,',', '.'),'9.99999999999')), 4326), 2972) as geom, 
		id_area_attachment, case when date_min > date_max then date_max else date_min end, case when date_min>date_max then date_min else date_max end, validator, validation_comment, 
		observers, determiner, 1000052, id_nomenclature_determination_method, 
		comment_context, comment_description
		FROM gn_imports.synthese_cumul_data
		where x_latitude is not null;
		
--------------------------------------- 2/ Injection dans la synthese ==> points RGFG95
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
	digital_proof, non_digital_proof, altitude_min, altitude_max, 
	place_name, the_geom_4326, the_geom_point, the_geom_local, 
	id_area_attachment, date_min, date_max, validator, validation_comment, 
	observers, determiner, id_digitiser, id_nomenclature_determination_method, 
	comment_context, comment_description)
	SELECT uuid_generate_v4() AS unique_id_sinp_grp, id_source, id_module, entity_source_pk_value, id_dataset, 
		id_nomenclature_geo_object_nature, id_nomenclature_grp_typ, grp_method, id_nomenclature_obs_technique, 
		id_nomenclature_bio_status, id_nomenclature_bio_condition, id_nomenclature_naturalness, 
		id_nomenclature_exist_proof, id_nomenclature_valid_status,id_nomenclature_diffusion_level, 
		id_nomenclature_life_stage, id_nomenclature_sex, id_nomenclature_obj_count,
		id_nomenclature_type_count, 84,
		171,73,122, 543, 175, -- 123: rattachement. sinon 122: coord.source
		count_min, count_max, cd_nom, cd_hab, nom_cite, meta_v_taxref, sample_number_proof,
		digital_proof, non_digital_proof, altitude_min, altitude_max, 
		place_name, 
		ST_Transform(ST_SetSRID(ST_MakePoint(x_rgfg95,y_rgfg95), 2972), 4326) AS the_geom_4326, 
		ST_Transform(ST_SetSRID(ST_MakePoint(x_rgfg95,y_rgfg95), 2972), 4326) AS the_geom_point, 
		ST_SetSRID(ST_MakePoint(x_rgfg95,y_rgfg95), 2972) as geom, 
		id_area_attachment, case when date_min > date_max then date_max else date_min end, case when date_min>date_max then date_min else date_max end, validator, validation_comment, 
		observers, determiner, 1000052, id_nomenclature_determination_method, 
		comment_context, comment_description
		FROM gn_imports.synthese_cumul_data
		where x_rgfg95 is not null;	