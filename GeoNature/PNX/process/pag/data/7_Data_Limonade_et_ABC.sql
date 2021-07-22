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
SELECT setval('utilisateurs.bib_organismes_id_organisme_seq', (SELECT MAX(id_organisme) FROM utilisateurs.bib_organismes)+1);

-- id_dataset ====> Habitats Galbao = 47 (ABC); Sentiers = 48 (ABC); Limonade = 49 (données partenariales)...
INSERT INTO gn_meta.t_datasets(
	id_dataset, id_acquisition_framework, dataset_name, dataset_shortname, dataset_desc, 
	id_nomenclature_data_type, keywords, marine_domain, terrestrial_domain, id_nomenclature_dataset_objectif,id_nomenclature_collecting_method, 
	id_nomenclature_data_origin, id_nomenclature_source_status, id_nomenclature_resource_type, active, validable, id_digitizer)
	VALUES
		(47, 18, 'ABCSaül - Habitats Monts Galbao (2019)', 'Habitats Galbao (2019)', 'Diagnostic des habitats forestiers des monts Galbao (flore des sous-bois dans JDD ''ABC Saül-Flore'') **ONF de Guyane**', get_nom_corr(322), 'Habitats forestiers, arbres, monts Galbao, Saül, ABC', false, true, get_nom_corr(413), get_nom_corr(395), get_nom_corr(76), get_nom_corr(73), get_nom_corr(320), false, false, 1000052), --Habitats Galbao = 47 (ABC)
		(48, 18, 'ABCSaül - Habitats Sentiers de Saül (2019)', 'Habitats Sentiers Saül (2019)', 'Diagnostic des habitats forestiers des sentiers de Saül (flore des sous-bois dans JDD ''ABC Saül-Flore'') **ONF de Guyane**', get_nom_corr(322), 'Habitats forestiers, arbres, sentiers, Saül, ABC', false, true, get_nom_corr(413), get_nom_corr(395), get_nom_corr(76), get_nom_corr(73), get_nom_corr(320), false, false, 1000052), --Habitats Sentiers = 48 (ABC)
		(49, 16, 'Habitats - Flats Limonade (2013)', 'Habitats - Limonade (2013)', 'Diagnostic des habitats forestiers des flats de la crique Limonade **ONF de Guyane**', get_nom_corr(322), 'Habitats forestiers, arbres, flats de la Limonade, Saül', false, true, get_nom_corr(413), get_nom_corr(395), get_nom_corr(76), get_nom_corr(73), get_nom_corr(320), false, false, 1000052), --Limonade = 49 (données partenariales)
		(50, 18, 'ABCSaül - Reconnaissance des monts Galbao (2018)', 'Reco Galbao (2018)', 'ABC de Saül - Mission de reconnaissance des monts Galbao (flore des sous-bois dans JDD ''ABC Saül-Flore'') **PAG, ONF de Guyane, Fond. Biotope**', get_nom_corr(322), 'Faune, Flore, Monts Galbao, Saül, ABC', false, true, get_nom_corr(417), get_nom_corr(395), get_nom_corr(76), get_nom_corr(73), get_nom_corr(320), true, true, 1000052), --RecoGalbao = 50
		(51, 18, 'ABCSaül - Inventaire malacologique (2018)', 'Malaco (2018)', 'ABC de Saül - 1er inventaire malacologique **MNHN**', get_nom_corr(322), 'Malacologie, Escargots, Galbao, sentiers, Saül, ABC', false, true, get_nom_corr(417), get_nom_corr(395), get_nom_corr(76), get_nom_corr(73), get_nom_corr(320), true, true, 1000052),
		(52, 18, 'ABCSaül - Inventaire malacologique (2020)', 'Malaco (2020)', 'ABC de Saül - 2e inventaire malacologique **MNHN**', get_nom_corr(322), 'Malacologie, Escargots, Galbao, sentiers, Saül, ABC', false, true, get_nom_corr(417), get_nom_corr(395), get_nom_corr(76), get_nom_corr(73), get_nom_corr(320), true, true, 1000052),
		(53, 18, 'ABCSaül - Mycologie participative (2020-2021)', 'Myco iNaturalist (2020-2021)', 'ABC de Saül - Inventaire participatif iNaturalist **PAG, Univ Toulouse III et grand public**', get_nom_corr(322), 'Mycologie, champignons, grand public, iNaturalist, Saül, ABC', false, true, get_nom_corr(417), get_nom_corr(395), get_nom_corr(76), get_nom_corr(73), get_nom_corr(320), true, true, 1000052),
		(54, 18, 'ABCSaül - Contributions grand public', 'ABCSaül- grand public', 'ABC de Saül - Communications et contributions personnelles **grand public**',get_nom_corr(322), 'grand public, Saül, ABC', false, true, get_nom_corr(417), get_nom_corr(395), get_nom_corr(76), get_nom_corr(73), get_nom_corr(320), true, true, 1000052),
		(55, 18, 'ABCSaül - Fête de la Nature 2018', 'ABCSaül- FdN 2018', 'ABC de Saül - Fête de la Nature 2018 **PAG, EcoFoG, GCG**',  get_nom_corr(322), 'grand public, Saül, ABC', false, true, get_nom_corr(417), get_nom_corr(395),  get_nom_corr(76), get_nom_corr(73), get_nom_corr(320), true, true, 1000052),
		(56, 18, 'ABCSaül - Fête de la Nature 2019', 'ABCSaül- FdN 2019', 'ABC de Saül - Fête de la Nature 2018 **PAG, Cérato, expert**',  get_nom_corr(322), 'grand public, Saül, ABC', false, true, get_nom_corr(417), get_nom_corr(395),  get_nom_corr(76), get_nom_corr(73), get_nom_corr(320), true, true, 1000052),
		(57, 9, 'Itoupé 2017', 'Itoupé 2017', 'Inventaire pluridisciplinaire d''Itoupé (2017) **PAG, CNRS, UMR AMAP', get_nom_corr(322), '', false, true, get_nom_corr(417), get_nom_corr(395),  get_nom_corr(76), get_nom_corr(73), get_nom_corr(320), true, true, 1000052),
		(58, 9, 'Itoupé 2018', 'Itoupé 2018', 'Inventaire pluridisciplinaire d''Itoupé (2018) **PAG, CNRS, Fond. Biotope', get_nom_corr(322), '', false, true, get_nom_corr(417), get_nom_corr(395),  get_nom_corr(76), get_nom_corr(73), get_nom_corr(320), true, true, 1000052),
		(59, 9, 'Itoupé 2021', 'Itoupé 2021', 'Inventaire pluridisciplinaire d''Itoupé (2021) **PAG, CNRS, asso. Trésor, expert', get_nom_corr(322), '', false, true, get_nom_corr(417), get_nom_corr(395),  get_nom_corr(76), get_nom_corr(73), get_nom_corr(320), true, true, 1000052),
		(60, 18, 'ABCSaül - Herpétologie monts Galbao (2018)', 'Herpéto Galbao (2018)', 'ABC de Saül - Mission herpétologique des monts Galbao (flore des sous-bois dans JDD ''ABC Saül-Flore'') **PAG, CNRS, Fond. Biotope**',  get_nom_corr(322), 'Faune, amphibiens, reptiles, Monts Galbao, Saül, ABC', false, true, get_nom_corr(417), get_nom_corr(395), get_nom_corr(76), get_nom_corr(73), get_nom_corr(320), true, true, 1000052),
		(61, 18, 'ABCSaül - Herpétologie Savane-roche Dachine (2019)', 'Herpéto SR Dachine (2019)', 'ABC de Saül - Mission pluridisciplinaire savane-Roche Dachine (flore des sous-bois dans JDD ''ABC Saül-Flore'') **PAG, CNRS, Fond. Biotope**',  get_nom_corr(322), 'Faune, amphibiens, reptiles, Monts Galbao, Saül, ABC', false, true, get_nom_corr(417), get_nom_corr(395), get_nom_corr(76), get_nom_corr(73), get_nom_corr(320), true, true, 1000052),
		(62, 19, 'ABCPPI - IKA Gros Saut (2020)', 'IKA Gros Saut (2020)', 'ABC de PPI - Indice Kilométrique d''Abondance réalisé à Gros Saut **PAG**',  get_nom_corr(322), 'IKA, grande faune, ABC, Papaïchton, Gros Saut', false, true, get_nom_corr(417), get_nom_corr(395), get_nom_corr(76), get_nom_corr(73), get_nom_corr(320), true, true, 1000052),
		(63, 19, 'ABCPPI - Gros Saut saison sèche (2020)', 'Gros Saut (2020)', 'ABC de PPI - Mission pluridisciplinaire de saison sèche à Gros Saut (poissons, crustacés, scorpions, amphibiens) **PAG, Hydreco, expert, Fond. Biotope**', get_nom_corr(322), 'poissons, amphibiens, crevettes, scorpions, ABC, Papaïchton, Gros Saut', false, true, get_nom_corr(417), get_nom_corr(395), get_nom_corr(76), get_nom_corr(73), get_nom_corr(320), true, true, 1000052),
		(64, 19, 'ABCPPI - Gros Saut saison des pluies (2021)', 'Gros Saut (2021)', 'ABC de PPI - Mission pluridisciplinaire de saison des pluies à Gros Saut (amphibiens, reptiles, oiseaux, chiroptères, flore) **PAG, CNRS, expert, Fond. Biotope**',  get_nom_corr(322), 'amphibiens, reptiles, oiseaux, chiroptères, flore, ABC, Papaïchton, Gros Saut', false, true, get_nom_corr(417), get_nom_corr(395), get_nom_corr(76), get_nom_corr(73), get_nom_corr(320), true, true, 1000052),
		(65, 19, 'ABCPPI - Habitats Gros Saut (2021)', 'Habitats - Gros Saut (2021)', 'Diagnostic des habitats forestiers du secteur de Gros Saut **ONF de Guyane**', get_nom_corr(322), 'Habitats forestiers, arbres, flats de la Limonade, Saül', false, true, get_nom_corr(413), get_nom_corr(395), get_nom_corr(76), get_nom_corr(73), get_nom_corr(320), true, false, 1000052)
		;
		--itoupé 2016: vers de terre, opilions
SELECT setval('gn_meta.t_datasets_id_dataset_seq', (SELECT MAX(id_dataset) FROM gn_meta.t_datasets)+1);
		
INSERT INTO gn_meta.cor_dataset_actor(id_dataset, id_organism, id_nomenclature_actor_role) 
	VALUES 
		(9, 10, get_nom_corr(363)), (9, 12, get_nom_corr(363)), (9, 13, get_nom_corr(363)), (9, 17, get_nom_corr(363)), (9,24, get_nom_corr(363)), (9,25, get_nom_corr(363)),
		(28, 9 , get_nom_corr(363)), (28, 25, get_nom_corr(363)), (28, 14, get_nom_corr(363)),(28, 3, get_nom_corr(363)), 
		(47, 13, get_nom_corr(363)), (47, 3, get_nom_corr(360)),
		(48, 13, get_nom_corr(363)), (48, 3, get_nom_corr(360)),
		(49, 13, get_nom_corr(363)),
		(50, 13, get_nom_corr(363)), (50, 14, get_nom_corr(363)), (50, 3, get_nom_corr(363)), (50, 3, get_nom_corr(360)),
		(51, 18, get_nom_corr(363)), (51, 3, get_nom_corr(360)),
		(52, 18, get_nom_corr(363)), (52, 3, get_nom_corr(360)),
		(53, 19, get_nom_corr(363)), (53, 16, 362), (53, 3, get_nom_corr(360)),
		(54, 19, get_nom_corr(363)),
		(55, 21, get_nom_corr(363)), (55, 19, get_nom_corr(363)), (55, 3, get_nom_corr(360)),
		(56, 20, get_nom_corr(363)), (56, 19, get_nom_corr(363)), (56, 3, get_nom_corr(363)), (56, 3, get_nom_corr(360)),
		(57, 9 , get_nom_corr(363)), (57, 24, get_nom_corr(363)), (57, 3, get_nom_corr(360)),
		(58, 9 , get_nom_corr(363)), (58, 14, get_nom_corr(363)), (58, 3, get_nom_corr(360)),
		(59, 9 , get_nom_corr(363)), (59, 23, get_nom_corr(363)), (59, 22, get_nom_corr(363)),(59, 3, get_nom_corr(363)), (59, 3, get_nom_corr(360)),
		(60, 14, get_nom_corr(363)), (60, 9 , get_nom_corr(363)), (60, 3, get_nom_corr(363)), (60, 3, get_nom_corr(360)),
		(61, 14, get_nom_corr(363)), (61, 9 , get_nom_corr(363)), (61, 3, get_nom_corr(363)), (61, 3, get_nom_corr(360)),
		(62, 3, get_nom_corr(363)), (62, 3, get_nom_corr(360)),
		(63, 3, get_nom_corr(363)), (63, 3, get_nom_corr(360)), (63, 15, get_nom_corr(363)),(63, 14, get_nom_corr(363)),(63, 26, get_nom_corr(363)),
		(64, 3, get_nom_corr(363)), (64, 3, get_nom_corr(360)), (64, 14, get_nom_corr(363)),(64, 9, get_nom_corr(363)),(64, 27, get_nom_corr(363)),
		(65, 13, get_nom_corr(363)), (65, 3, get_nom_corr(360))
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
SELECT setval('gn_synthese.t_sources_id_source_seq', (SELECT MAX(id_source) FROM gn_synthese.t_sources)+1);
		
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
	FROM '/tmp/20210701_synthese_malaco.csv' WITH csv HEADER DELIMITER ';';
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
		get_nom_corr(170), get_nom_corr(id_nomenclature_grp_typ), grp_method, get_nom_corr(id_nomenclature_obs_technique), 
		get_nom_corr(id_nomenclature_bio_status), get_nom_corr(id_nomenclature_bio_condition), get_nom_corr(id_nomenclature_naturalness), 
		get_nom_corr(id_nomenclature_exist_proof), get_nom_corr(id_nomenclature_valid_status),get_nom_corr(id_nomenclature_diffusion_level), 
		get_nom_corr(id_nomenclature_life_stage), get_nom_corr(id_nomenclature_sex), get_nom_corr(id_nomenclature_obj_count),
		get_nom_corr(id_nomenclature_type_count), get_nom_corr(84),
		get_nom_corr(171),get_nom_corr(70),get_nom_corr(get_nom_corr(123)), get_nom_corr(543), get_nom_corr(175),
		count_min, count_max, cd_nom, cd_hab, nom_cite, meta_v_taxref, sample_number_proof,
		digital_proof, non_digital_proof, altitude_min, altitude_max, 
		place_name, 
		ST_Transform(ST_SetSRID(ST_MakePoint(to_number(latitude, '999999'),to_number(longitude, '999999')), 2972), 4326) AS geom_4326, ST_Transform(ST_SetSRID(ST_MakePoint(to_number(latitude, '999999'),to_number(longitude, '999999')), 2972), 4326) AS the_geom_point, ST_SetSRID(ST_MakePoint(to_number(latitude, '999999'),to_number(longitude, '999999')), 2972)  as geom, 
		id_area_attachment, date_min, date_max, validator, validation_comment, 
		observers, determiner, 1000052, get_nom_corr(id_nomenclature_determination_method), 
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
	FROM '/tmp/20210705_synthese_inaturalist.csv' WITH csv HEADER DELIMITER ';';
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
		get_nom_corr(170), get_nom_corr(id_nomenclature_grp_typ), grp_method, get_nom_corr(id_nomenclature_obs_technique), 
		get_nom_corr(id_nomenclature_bio_status), get_nom_corr(id_nomenclature_bio_condition), get_nom_corr(id_nomenclature_naturalness), 
		get_nom_corr(id_nomenclature_exist_proof), get_nom_corr(id_nomenclature_valid_status),get_nom_corr(id_nomenclature_diffusion_level), 
		get_nom_corr(id_nomenclature_life_stage), get_nom_corr(id_nomenclature_sex), get_nom_corr(id_nomenclature_obj_count),
		get_nom_corr(id_nomenclature_type_count), get_nom_corr(84),
		get_nom_corr(171),get_nom_corr(73),get_nom_corr(122), get_nom_corr(543), get_nom_corr(175),
		count_min, count_max, cd_nom, cd_hab, nom_cite, meta_v_taxref, sample_number_proof,
		digital_proof, non_digital_proof, altitude_min, altitude_max, 
		place_name, 
		ST_SetSRID(ST_MakePoint(to_number(longitude, 'SG99.99999999999'),to_number(latitude, '9.99999999999')), 4326) AS the_geom_4326, 
		ST_SetSRID(ST_MakePoint(to_number(longitude, 'SG99.99999999999'),to_number(latitude, '9.99999999999')), 4326) AS the_geom_point, 
		ST_Transform(ST_SetSRID(ST_MakePoint(to_number(longitude, 'SG99.99999999999'),to_number(latitude, '9.99999999999')), 4326), 2972) as geom, 
		id_area_attachment, date_min, date_max, validator, validation_comment, 
		observers, determiner, 1000052, get_nom_corr(id_nomenclature_determination_method), 
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
	FROM '/tmp/20210707_CumulDiademaEtc.csv' WITH csv HEADER DELIMITER ';';

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
		get_nom_corr(id_nomenclature_geo_object_nature), get_nom_corr(id_nomenclature_grp_typ), grp_method, get_nom_corr(id_nomenclature_obs_technique), 
		get_nom_corr(id_nomenclature_bio_status), get_nom_corr(id_nomenclature_bio_condition), get_nom_corr(id_nomenclature_naturalness), 
		get_nom_corr(id_nomenclature_exist_proof), get_nom_corr(id_nomenclature_valid_status),get_nom_corr(id_nomenclature_diffusion_level), 
		get_nom_corr(id_nomenclature_life_stage), get_nom_corr(id_nomenclature_sex), get_nom_corr(id_nomenclature_obj_count),
		get_nom_corr(id_nomenclature_type_count), get_nom_corr(84),
		get_nom_corr(171),get_nom_corr(73),get_nom_corr(123), get_nom_corr(543), get_nom_corr(175), -- get_nom_corr(123): rattachement. sinon get_nom_corr(122): coord.source
		count_min, count_max, cd_nom, cd_hab, nom_cite, meta_v_taxref, sample_number_proof,
		digital_proof, non_digital_proof, altitude_min, altitude_max, 
		place_name, 
		ST_Transform(ST_SetSRID(ST_Multi(ST_GeomFromText(poly)), 2972), 4326) AS the_geom_4326, 
		null AS the_geom_point, 
		ST_SetSRID(ST_Multi(ST_GeomFromText(poly)), 2972) as geom, 
		id_area_attachment, date_min, date_max, validator, validation_comment, 
		observers, determiner, 1000052, get_nom_corr(id_nomenclature_determination_method), 
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
		get_nom_corr(id_nomenclature_geo_object_nature), get_nom_corr(id_nomenclature_grp_typ), grp_method, get_nom_corr(id_nomenclature_obs_technique), 
		get_nom_corr(id_nomenclature_bio_status), get_nom_corr(id_nomenclature_bio_condition), get_nom_corr(id_nomenclature_naturalness), 
		get_nom_corr(id_nomenclature_exist_proof), get_nom_corr(id_nomenclature_valid_status),get_nom_corr(id_nomenclature_diffusion_level), 
		get_nom_corr(id_nomenclature_life_stage), get_nom_corr(id_nomenclature_sex), get_nom_corr(id_nomenclature_obj_count),
		get_nom_corr(id_nomenclature_type_count), get_nom_corr(84),
		get_nom_corr(171),get_nom_corr(73),get_nom_corr(122), get_nom_corr(543), get_nom_corr(175), -- get_nom_corr(123): rattachement. sinon get_nom_corr(122): coord.source
		count_min, count_max, cd_nom, cd_hab, nom_cite, meta_v_taxref, sample_number_proof,
		digital_proof, non_digital_proof, altitude_min, altitude_max, 
		place_name, 
		ST_SetSRID(ST_MakePoint(to_number(replace(x_latitude,',', '.'),'SG99.99999999999'),to_number(replace(y_longitude,',', '.'),'9.99999999999')), 4326) AS the_geom_4326, 
		ST_SetSRID(ST_MakePoint(to_number(replace(x_latitude,',', '.'),'SG99.99999999999'),to_number(replace(y_longitude,',', '.'),'9.99999999999')), 4326) AS the_geom_point, 
		ST_Transform(ST_SetSRID(ST_MakePoint(to_number(replace(x_latitude,',', '.'),'SG99.99999999999'),to_number(replace(y_longitude,',', '.'),'9.99999999999')), 4326), 2972) as geom, 
		id_area_attachment, case when date_min > date_max then date_max else date_min end, case when date_min>date_max then date_min else date_max end, validator, validation_comment, 
		observers, determiner, 1000052, get_nom_corr(id_nomenclature_determination_method), 
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
		get_nom_corr(id_nomenclature_geo_object_nature), get_nom_corr(id_nomenclature_grp_typ), grp_method, get_nom_corr(id_nomenclature_obs_technique), 
		get_nom_corr(id_nomenclature_bio_status), get_nom_corr(id_nomenclature_bio_condition), get_nom_corr(id_nomenclature_naturalness), 
		get_nom_corr(id_nomenclature_exist_proof), get_nom_corr(id_nomenclature_valid_status),get_nom_corr(id_nomenclature_diffusion_level), 
		get_nom_corr(id_nomenclature_life_stage), get_nom_corr(id_nomenclature_sex), get_nom_corr(id_nomenclature_obj_count),
		get_nom_corr(id_nomenclature_type_count), get_nom_corr(84),
		get_nom_corr(171),get_nom_corr(73),get_nom_corr(122), get_nom_corr(543), get_nom_corr(175), -- get_nom_corr(123): rattachement. sinon get_nom_corr(122): coord.source
		count_min, count_max, cd_nom, cd_hab, nom_cite, meta_v_taxref, sample_number_proof,
		digital_proof, non_digital_proof, altitude_min, altitude_max, 
		place_name, 
		ST_Transform(ST_SetSRID(ST_MakePoint(x_rgfg95,y_rgfg95), 2972), 4326) AS the_geom_4326, 
		ST_Transform(ST_SetSRID(ST_MakePoint(x_rgfg95,y_rgfg95), 2972), 4326) AS the_geom_point, 
		ST_SetSRID(ST_MakePoint(x_rgfg95,y_rgfg95), 2972) as geom, 
		id_area_attachment, case when date_min > date_max then date_max else date_min end, case when date_min>date_max then date_min else date_max end, validator, validation_comment, 
		observers, determiner, 1000052, get_nom_corr(id_nomenclature_determination_method), 
		comment_context, comment_description
		FROM gn_imports.synthese_cumul_data
		where x_rgfg95 is not null;	


----------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------- cumul JDD: Habitats, Diadema, ABC... ----------------------
----------------------------------------------------------------------------------------------------------------------------
UPDATE taxonomie.taxref SET id_statut = 'J' where cd_nom in (656489, 447341, 630169, 971931, 895547, 732404, 446505);	
---------------------------------------------- 1/ les releves espèces exotiques		
INSERT INTO pr_occtax.t_releves_occtax(
	id_releve_occtax, unique_id_sinp_grp, id_dataset, id_digitiser, observers_txt, 
	id_nomenclature_tech_collect_campanule, id_nomenclature_grp_typ, grp_method, 
	date_min, date_max, place_name, comment, 
	geom_local, geom_4326, id_nomenclature_geo_object_nature)
	select 3371,uuid_generate_v4() AS unique_id_sinp_grp, 42, 1000052, null,
			get_nom_corr(239), get_nom_corr(131), null, 
			'09/09/2019', '27/09/2019', 'Saül, zones habitées', 'Inventaire des espèces exotiques des espaces habités',
			geom, ST_transform(geom, 4326),
			get_nom_corr(168) from gn_imports.tmp_localitespoly_seb where localite= 'Saül, zones habitées';
INSERT INTO pr_occtax.cor_role_releves_occtax(unique_id_cor_role_releve, id_releve_occtax, id_role) values(uuid_generate_v4(),3371, 1000016 );
SELECT setval('pr_occtax.t_releves_occtax_id_releve_occtax_seq', (SELECT MAX(id_releve_occtax) FROM pr_occtax.t_releves_occtax)+1);
-----------------------------------------------2/ les occurrences des espèces exotiques
INSERT INTO pr_occtax.t_occurrences_occtax( id_occurrence_occtax, id_releve_occtax, id_nomenclature_obs_technique, id_nomenclature_bio_condition, id_nomenclature_bio_status, id_nomenclature_naturalness, id_nomenclature_exist_proof, id_nomenclature_diffusion_level, id_nomenclature_observation_status, id_nomenclature_blurring, id_nomenclature_source_status, id_nomenclature_behaviour, determiner, id_nomenclature_determination_method, cd_nom, nom_cite, non_digital_proof, meta_v_taxref, sample_number_proof, digital_proof,  comment)
	VALUES (9104,3371,get_nom_corr(37),get_nom_corr(153),get_nom_corr(get_nom_corr(30)),get_nom_corr(160), null,get_nom_corr(140),get_nom_corr(84),get_nom_corr(171),get_nom_corr(73), null,'Sant S.',get_nom_corr(446),656489,'Asystasia gangetica ssp. micrantha','Asystasia gangetica subsp. micrantha','TaxRef v14', null, null,'Invasive'),
		(9105,3371,get_nom_corr(37),get_nom_corr(153),get_nom_corr(30),get_nom_corr(160), null,get_nom_corr(140),get_nom_corr(84),get_nom_corr(171),get_nom_corr(73), null,'Sant S.',get_nom_corr(446),636296,'Ruellia blechum','Ruellia blechum','TaxRef v14', null, null, null),
		(9106,3371,get_nom_corr(37),get_nom_corr(153),get_nom_corr(30),get_nom_corr(157), null,get_nom_corr(140),get_nom_corr(84),get_nom_corr(171),get_nom_corr(73), null,'Sant S.',get_nom_corr(446),670722,'Sanchezia parvibracteata','Sanchezia parvibracteata','TaxRef v14', null, null, null),
		(9107,3371,get_nom_corr(37),get_nom_corr(153),get_nom_corr(30),get_nom_corr(157), null,get_nom_corr(140),get_nom_corr(84),get_nom_corr(171),get_nom_corr(73), null,'Sant S.',get_nom_corr(446),446879,'Thunbergia erecta ''alba''','Thunbergia erecta','TaxRef v14', null, null, null),
		(9108,3371,get_nom_corr(37),get_nom_corr(153),get_nom_corr(30),get_nom_corr(160), null,get_nom_corr(140),get_nom_corr(84),get_nom_corr(171),get_nom_corr(73), null,'Sant S.',get_nom_corr(446),446881,'Thunbergia grandiflora','Thunbergia grandiflora','TaxRef v14', null, null, null),
		(9109,3371,get_nom_corr(37),get_nom_corr(153),get_nom_corr(30),get_nom_corr(160), null,get_nom_corr(140),get_nom_corr(84),get_nom_corr(171),get_nom_corr(73), null,'Sant S.',get_nom_corr(446),446890,'Cyathula prostrata','Cyathula prostrata','TaxRef v14', null, null, null),
		(9110,3371,get_nom_corr(37),get_nom_corr(153),get_nom_corr(30),get_nom_corr(158), null,get_nom_corr(140),get_nom_corr(84),get_nom_corr(171),get_nom_corr(73), null,'Sant S.',get_nom_corr(446),446826,'Crinum amabile','Crinum amabile','TaxRef v14', null, null, null),
		(9111,3371,get_nom_corr(37),get_nom_corr(153),get_nom_corr(30),get_nom_corr(157), null,get_nom_corr(140),get_nom_corr(84),get_nom_corr(171),get_nom_corr(73), null,'Sant S.',get_nom_corr(446),446893,'Anacardium occidentale','Anacardium occidentale','TaxRef v14', null, null,'Anacardier, cajou'),
		(9112,3371,get_nom_corr(37),get_nom_corr(153),get_nom_corr(30),get_nom_corr(157), null,get_nom_corr(140),get_nom_corr(84),get_nom_corr(171),get_nom_corr(73), null,'Sant S.',get_nom_corr(446),446894,'Mangifera indica','Mangifera indica','TaxRef v14', null, null,'Manguier'),
		(9113,3371,get_nom_corr(37),get_nom_corr(153),get_nom_corr(30),get_nom_corr(157), null,get_nom_corr(140),get_nom_corr(84),get_nom_corr(171),get_nom_corr(73), null,'Sant S.',get_nom_corr(446),639227,'Spondias dulcis','Spondias dulcis','TaxRef v14', null, null,'Prune de Cythère'),
		(9114,3371,get_nom_corr(37),get_nom_corr(153),get_nom_corr(30),get_nom_corr(157), null,get_nom_corr(140),get_nom_corr(84),get_nom_corr(171),get_nom_corr(73), null,'Sant S.',get_nom_corr(446),455727,'Annona mucosa','Annona mucosa','TaxRef v14', null, null, null),
		(9115,3371,get_nom_corr(37),get_nom_corr(153),get_nom_corr(30),get_nom_corr(157), null,get_nom_corr(140),get_nom_corr(84),get_nom_corr(171),get_nom_corr(73), null,'Sant S.',get_nom_corr(446),446899,'Annona muricata','Annona muricata','TaxRef v14', null, null,'Corossol'),
		(9116,3371,get_nom_corr(37),get_nom_corr(153),get_nom_corr(30),get_nom_corr(157), null,get_nom_corr(140),get_nom_corr(84),get_nom_corr(171),get_nom_corr(73), null,'Sant S.',get_nom_corr(446),446902,'Cananga odorata','Cananga odorata','TaxRef v14', null, null,'Ylang-ylang'),
		(9117,3371,get_nom_corr(37),get_nom_corr(153),get_nom_corr(30),get_nom_corr(160), null,get_nom_corr(140),get_nom_corr(84),get_nom_corr(171),get_nom_corr(73), null,'Sant S.',get_nom_corr(446),446824,'Eryngium foetifum','Eryngium foetidum','TaxRef v14', null, null,'radié la fièvre'),
		(9118,3371,get_nom_corr(37),get_nom_corr(153),get_nom_corr(30),get_nom_corr(157), null,get_nom_corr(140),get_nom_corr(84),get_nom_corr(171),get_nom_corr(73), null,'Sant S.',get_nom_corr(446),446907,'Allamanda blanchetii','Allamanda blanchetii','TaxRef v14', null, null, null),
		(9119,3371,get_nom_corr(37),get_nom_corr(153),get_nom_corr(30),get_nom_corr(160), null,get_nom_corr(140),get_nom_corr(84),get_nom_corr(171),get_nom_corr(73), null,'Sant S.',get_nom_corr(446),446951,'Asclepias curassavica','Asclepias curassavica','TaxRef v14', null, null, null),
		(9120,3371,get_nom_corr(37),get_nom_corr(153),get_nom_corr(30),get_nom_corr(157), null,get_nom_corr(140),get_nom_corr(84),get_nom_corr(171),get_nom_corr(73), null,'Sant S.',get_nom_corr(446),445415,'Plumeria sp.','Plumeria','TaxRef v14', null, null,'Frangipanier'),
		(9121,3371,get_nom_corr(37),get_nom_corr(153),get_nom_corr(30),get_nom_corr(157), null,get_nom_corr(140),get_nom_corr(84),get_nom_corr(171),get_nom_corr(73), null,'Sant S.',get_nom_corr(446),447722,'Colocasia esculenta','Colocasia esculenta','TaxRef v14', null, null,'Dachine'),
		(9122,3371,get_nom_corr(37),get_nom_corr(153),get_nom_corr(30),get_nom_corr(157), null,get_nom_corr(140),get_nom_corr(84),get_nom_corr(171),get_nom_corr(73), null,'Sant S.',get_nom_corr(446),631319,'Adonidia merrillii','Adonidia merrillii','TaxRef v14', null, null,'Palmier royal nain'),
		(9123,3371,get_nom_corr(37),get_nom_corr(153),get_nom_corr(30),get_nom_corr(157), null,get_nom_corr(140),get_nom_corr(84),get_nom_corr(171),get_nom_corr(73), null,'Sant S.',get_nom_corr(446),710432,'Bactris gasipaes','Bactris gasipaes var. gasipaes','TaxRef v14', null, null,'Parepou'),
		(9124,3371,get_nom_corr(37),get_nom_corr(153),get_nom_corr(30),get_nom_corr(157), null,get_nom_corr(140),get_nom_corr(84),get_nom_corr(171),get_nom_corr(73), null,'Sant S.',get_nom_corr(446),705943,'Bismarckia nobilis','Bismarckia nobilis','TaxRef v14', null, null,'Palmier cireux'),
		(9125,3371,get_nom_corr(37),get_nom_corr(153),get_nom_corr(30),get_nom_corr(157), null,get_nom_corr(140),get_nom_corr(84),get_nom_corr(171),get_nom_corr(73), null,'Sant S.',get_nom_corr(446),629273,'Caryota mitis','Caryota mitis','TaxRef v14', null, null,'palmeir queue de poisson'),
		(9126,3371,get_nom_corr(37),get_nom_corr(153),get_nom_corr(30),get_nom_corr(157), null,get_nom_corr(140),get_nom_corr(84),get_nom_corr(171),get_nom_corr(73), null,'Sant S.',get_nom_corr(446),447749,'Cocos nucifera','Cocos nucifera','TaxRef v14', null, null,'Cocotier'),
		(9127,3371,get_nom_corr(37),get_nom_corr(153),get_nom_corr(30),get_nom_corr(157), null,get_nom_corr(140),get_nom_corr(84),get_nom_corr(171),get_nom_corr(73), null,'Sant S.',get_nom_corr(446),447751,'Cyrtostachys renda','Cyrtostachys renda','TaxRef v14', null, null,'multipliant rouge'),
		(9128,3371,get_nom_corr(37),get_nom_corr(153),get_nom_corr(30),get_nom_corr(157), null,get_nom_corr(140),get_nom_corr(84),get_nom_corr(171),get_nom_corr(73), null,'Sant S.',get_nom_corr(446),630983,'Dypsis lutescens','Dypsis lutescens','TaxRef v14', null, null,'Palmier multipliant'),
		(9129,3371,get_nom_corr(37),get_nom_corr(153),get_nom_corr(30),get_nom_corr(157), null,get_nom_corr(140),get_nom_corr(84),get_nom_corr(171),get_nom_corr(73), null,'Sant S.',get_nom_corr(446),629112,'Aristolochia trilobata','Aristolochia trilobata','TaxRef v14', null, null,'Aristoloche'),
		(9130,3371,get_nom_corr(37),get_nom_corr(153),get_nom_corr(30),get_nom_corr(157), null,get_nom_corr(140),get_nom_corr(84),get_nom_corr(171),get_nom_corr(73), null,'Sant S.',get_nom_corr(446),706307,'Furcraea selloa','Furcraea selloa','TaxRef v14', null, null,'"agave"'),
		(9131,3371,get_nom_corr(37),get_nom_corr(153),get_nom_corr(30),get_nom_corr(160), null,get_nom_corr(140),get_nom_corr(84),get_nom_corr(171),get_nom_corr(73), null,'Sant S.',get_nom_corr(446),446961,'Emilia fosbergii','Emilia fosbergii','TaxRef v14', null, null, null),
		(9132,3371,get_nom_corr(37),get_nom_corr(153),get_nom_corr(30),get_nom_corr(160), null,get_nom_corr(140),get_nom_corr(84),get_nom_corr(171),get_nom_corr(73), null,'Sant S.',get_nom_corr(446),446962,'Emilia sonchifolia','Emilia sonchifolia','TaxRef v14', null, null, null),
		(9133,3371,get_nom_corr(37),get_nom_corr(153),get_nom_corr(30),get_nom_corr(157), null,get_nom_corr(140),get_nom_corr(84),get_nom_corr(171),get_nom_corr(73), null,'Sant S.',get_nom_corr(446),448228,'Spathodea campanulata','Spathodea campanulata','TaxRef v14', null, null,'Tulipier du Gabon'),
		(9134,3371,get_nom_corr(37),get_nom_corr(153),get_nom_corr(30),get_nom_corr(157), null,get_nom_corr(140),get_nom_corr(84),get_nom_corr(171),get_nom_corr(73), null,'Sant S.',get_nom_corr(446),447005,'Bixa orellana','Bixa orellana','TaxRef v14', null, null,'Roucou'),
		(9135,3371,get_nom_corr(37),get_nom_corr(153),get_nom_corr(30),get_nom_corr(157), null,get_nom_corr(140),get_nom_corr(84),get_nom_corr(171),get_nom_corr(73), null,'Sant S.',get_nom_corr(446),190038,'Brassica spp.','Brassica','TaxRef v14', null, null,'Choux'),
		(9136,3371,get_nom_corr(37),get_nom_corr(153),get_nom_corr(30),get_nom_corr(157), null,get_nom_corr(140),get_nom_corr(84),get_nom_corr(171),get_nom_corr(73), null,'Sant S.',get_nom_corr(446),99902529,'Aechmea blanchetiana','Aechmea blanchetiana', null, null, null, null),
		(9137,3371,get_nom_corr(37),get_nom_corr(153),get_nom_corr(30),get_nom_corr(157), null,get_nom_corr(140),get_nom_corr(84),get_nom_corr(171),get_nom_corr(73), null,'Sant S.',get_nom_corr(446),886312,'Selenicereus undatus','Selenicereus undatus','TaxRef v14', null, null,'Pitaya'),
		(9138,3371,get_nom_corr(37),get_nom_corr(153),get_nom_corr(30),get_nom_corr(160), null,get_nom_corr(140),get_nom_corr(84),get_nom_corr(171),get_nom_corr(73), null,'Sant S.',get_nom_corr(446),447059,'Hippobroma longiflora','Hippobroma longiflora','TaxRef v14', null, null, null),
		(9139,3371,get_nom_corr(37),get_nom_corr(153),get_nom_corr(30),get_nom_corr(157), null,get_nom_corr(140),get_nom_corr(84),get_nom_corr(171),get_nom_corr(73), null,'Sant S.',get_nom_corr(446),841934,'Combretum indicum','Combretum indicum','TaxRef v14', null, null, null),
		(9140,3371,get_nom_corr(37),get_nom_corr(153),get_nom_corr(30),get_nom_corr(157), null,get_nom_corr(140),get_nom_corr(84),get_nom_corr(171),get_nom_corr(73), null,'Sant S.',get_nom_corr(446),447089,'Terminalia catappa','Terminalia catappa','TaxRef v14', null, null,'Amandier pays'),
		(9141,3371,get_nom_corr(37),get_nom_corr(153),get_nom_corr(30),get_nom_corr(160), null,get_nom_corr(140),get_nom_corr(84),get_nom_corr(171),get_nom_corr(73), null,'Sant S.',get_nom_corr(446),445573,'Ipomoea batatas','Ipomoea batatas','TaxRef v14', null, null,'Patate douce'),
		(9142,3371,get_nom_corr(37),get_nom_corr(153),get_nom_corr(30),get_nom_corr(160), null,get_nom_corr(140),get_nom_corr(84),get_nom_corr(171),get_nom_corr(73), null,'Sant S.',get_nom_corr(446),445583,'Ipomoea setifera','Ipomoea setifera','TaxRef v14', null, null, null),
		(9143,3371,get_nom_corr(37),get_nom_corr(153),get_nom_corr(30),get_nom_corr(157), null,get_nom_corr(140),get_nom_corr(84),get_nom_corr(171),get_nom_corr(73), null,'Sant S.',get_nom_corr(446),838887,'Hellenia speciosa','Hellenia speciosa','TaxRef v14', null, null, null),
		(9144,3371,get_nom_corr(37),get_nom_corr(153),get_nom_corr(30),get_nom_corr(157), null,get_nom_corr(140),get_nom_corr(84),get_nom_corr(171),get_nom_corr(73), null,'Sant S.',get_nom_corr(446),193698,'Kalanchoe','Kalanchoe','TaxRef v14', null, null, null),
		(9145,3371,get_nom_corr(37),get_nom_corr(153),get_nom_corr(30),get_nom_corr(157), null,get_nom_corr(140),get_nom_corr(84),get_nom_corr(171),get_nom_corr(73), null,'Sant S.',get_nom_corr(446),446992,'Crescentia cujete','Crescentia cujete','TaxRef v14', null, null,'Calebassier'),
		(9146,3371,get_nom_corr(37),get_nom_corr(153),get_nom_corr(30),get_nom_corr(157), null,get_nom_corr(140),get_nom_corr(84),get_nom_corr(171),get_nom_corr(73), null,'Sant S.',get_nom_corr(446),611694,'Cucurbita moscata','Cucurbita moschata','TaxRef v14', null, null,'Giraumon'),
		(9147,3371,get_nom_corr(37),get_nom_corr(153),get_nom_corr(30),get_nom_corr(160), null,get_nom_corr(140),get_nom_corr(84),get_nom_corr(171),get_nom_corr(73), null,'Sant S.',get_nom_corr(446),447106,'Momordica charantia','Momordica charantia','TaxRef v14', null, null, null),
		(9148,3371,get_nom_corr(37),get_nom_corr(153),get_nom_corr(30),get_nom_corr(157), null,get_nom_corr(140),get_nom_corr(84),get_nom_corr(171),get_nom_corr(73), null,'Sant S.',get_nom_corr(446),198441,'Thuja sp.','Thuja','TaxRef v14', null, null, null),
		(9149,3371,get_nom_corr(37),get_nom_corr(153),get_nom_corr(30),get_nom_corr(157), null,get_nom_corr(140),get_nom_corr(84),get_nom_corr(171),get_nom_corr(73), null,'Sant S.',get_nom_corr(446),447941,'Cycas circinnalis','Cycas circinalis','TaxRef v14', null, null,'Cycas'),
		(9150,3371,get_nom_corr(37),get_nom_corr(153),get_nom_corr(30),get_nom_corr(157), null,get_nom_corr(140),get_nom_corr(84),get_nom_corr(171),get_nom_corr(73), null,'Sant S.',get_nom_corr(446),447810,'Dioscorea bulbifera','Dioscorea bulbifera','TaxRef v14', null, null,'Patates volantes'),
		(9151,3371,get_nom_corr(37),get_nom_corr(153),get_nom_corr(30),get_nom_corr(157), null,get_nom_corr(140),get_nom_corr(84),get_nom_corr(171),get_nom_corr(73), null,'Sant S.',get_nom_corr(446),447694,'Dracaena fragrans','Dracaena fragrans','TaxRef v14', null, null, null),
		(9152,3371,get_nom_corr(37),get_nom_corr(153),get_nom_corr(30),get_nom_corr(160), null,get_nom_corr(140),get_nom_corr(84),get_nom_corr(171),get_nom_corr(73), null,'Sant S.',get_nom_corr(446),630964,'Acalypha aristata','Acalypha aristata','TaxRef v14', null, null, null),
		(9153,3371,get_nom_corr(37),get_nom_corr(153),get_nom_corr(30),get_nom_corr(157), null,get_nom_corr(140),get_nom_corr(84),get_nom_corr(171),get_nom_corr(73), null,'Sant S.',get_nom_corr(446),445614,'Acalypha hispida','Acalypha hispida','TaxRef v14', null, null, null),
		(9154,3371,get_nom_corr(37),get_nom_corr(153),get_nom_corr(30),get_nom_corr(157), null,get_nom_corr(140),get_nom_corr(84),get_nom_corr(171),get_nom_corr(73), null,'Sant S.',get_nom_corr(446),447128,'Codiaeum variegatum','Codiaeum variegatum','TaxRef v14', null, null,'Croton'),
		(9155,3371,get_nom_corr(37),get_nom_corr(153),get_nom_corr(30),get_nom_corr(157), null,get_nom_corr(140),get_nom_corr(84),get_nom_corr(171),get_nom_corr(73), null,'Sant S.',get_nom_corr(446),445631,'Euphorbia groupe milii','Euphorbia milii','TaxRef v14', null, null,'épine du christ'),
		(9156,3371,get_nom_corr(37),get_nom_corr(153),get_nom_corr(30),get_nom_corr(160), null,get_nom_corr(140),get_nom_corr(84),get_nom_corr(171),get_nom_corr(73), null,'Sant S.',get_nom_corr(446),97540,'Euphorbia heterophylla','Euphorbia heterophylla','TaxRef v14', null, null, null),
		(9157,3371,get_nom_corr(37),get_nom_corr(153),get_nom_corr(30),get_nom_corr(160), null,get_nom_corr(140),get_nom_corr(84),get_nom_corr(171),get_nom_corr(73), null,'Sant S.',get_nom_corr(446),452876,'Euphorbia hirta','Euphorbia hirta','TaxRef v14', null, null, null),
		(9158,3371,get_nom_corr(37),get_nom_corr(153),get_nom_corr(30),get_nom_corr(157), null,get_nom_corr(140),get_nom_corr(84),get_nom_corr(171),get_nom_corr(73), null,'Sant S.',get_nom_corr(446),446846,'Euphorbia neriifolia','Euphorbia neriifolia','TaxRef v14', null, null,'Euphorbe'),
		(9159,3371,get_nom_corr(37),get_nom_corr(153),get_nom_corr(30),get_nom_corr(157), null,get_nom_corr(140),get_nom_corr(84),get_nom_corr(171),get_nom_corr(73), null,'Sant S.',get_nom_corr(446),447146,'Jatropha gossypifolia','Jatropha gossypiifolia','TaxRef v14', null, null,'Médicinier'),
		(9160,3371,get_nom_corr(37),get_nom_corr(153),get_nom_corr(30),get_nom_corr(160), null,get_nom_corr(140),get_nom_corr(84),get_nom_corr(171),get_nom_corr(73), null,'Sant S.',get_nom_corr(446),447341,'Acacia mangium','Acacia mangium','TaxRef v14', null, null,'Invasive'),
		(9161,3371,get_nom_corr(37),get_nom_corr(153),get_nom_corr(30),get_nom_corr(157), null,get_nom_corr(140),get_nom_corr(84),get_nom_corr(171),get_nom_corr(73), null,'Sant S.',get_nom_corr(446),705872,'Arachis pintoi','Arachis pintoi','TaxRef v14', null, null, null),
		(9162,3371,get_nom_corr(37),get_nom_corr(153),get_nom_corr(30),get_nom_corr(157), null,get_nom_corr(140),get_nom_corr(84),get_nom_corr(171),get_nom_corr(73), null,'Sant S.',get_nom_corr(446),445530,'Bauhinia sp.','Bauhinia','TaxRef v14', null, null, null),
		(9163,3371,get_nom_corr(37),get_nom_corr(153),get_nom_corr(30),get_nom_corr(157), null,get_nom_corr(140),get_nom_corr(84),get_nom_corr(171),get_nom_corr(73), null,'Sant S.',get_nom_corr(446),447032,'Caesalpinia pulcherrima','Caesalpinia pulcherrima','TaxRef v14', null, null, null),
		(9164,3371,get_nom_corr(37),get_nom_corr(153),get_nom_corr(30),get_nom_corr(157), null,get_nom_corr(140),get_nom_corr(84),get_nom_corr(171),get_nom_corr(73), null,'Sant S.',get_nom_corr(446),447159,'Calopogonium mucunoides','Calopogonium mucunoides','TaxRef v14', null, null, null),
		(9165,3371,get_nom_corr(37),get_nom_corr(153),get_nom_corr(30),get_nom_corr(157), null,get_nom_corr(140),get_nom_corr(84),get_nom_corr(171),get_nom_corr(73), null,'Sant S.',get_nom_corr(446),445670,'Erythrina sp.','Erythrina','TaxRef v14', null, null, null),
		(9166,3371,get_nom_corr(37),get_nom_corr(153),get_nom_corr(30),get_nom_corr(160), null,get_nom_corr(140),get_nom_corr(84),get_nom_corr(171),get_nom_corr(73), null,'Sant S.',get_nom_corr(446),630169,'Mimosa camporum','Mimosa camporum','TaxRef v14', null, null,'Invasive'),
		(9167,3371,get_nom_corr(37),get_nom_corr(153),get_nom_corr(30),get_nom_corr(157), null,get_nom_corr(140),get_nom_corr(84),get_nom_corr(171),get_nom_corr(73), null,'Sant S.',get_nom_corr(446),447823,'Heliconia rostrata','Heliconia rostrata','TaxRef v14', null, null, null),
		(9168,3371,get_nom_corr(37),get_nom_corr(153),get_nom_corr(30),get_nom_corr(160), null,get_nom_corr(140),get_nom_corr(84),get_nom_corr(171),get_nom_corr(73), null,'Sant S.',get_nom_corr(446),630837,'Trimezia steyermarckii','Trimezia martinicensis','TaxRef v14', null, null, null),
		(9169,3371,get_nom_corr(37),get_nom_corr(153),get_nom_corr(30),get_nom_corr(157), null,get_nom_corr(140),get_nom_corr(84),get_nom_corr(171),get_nom_corr(73), null,'Sant S.',get_nom_corr(446),851877,'Plectranthus neochilus','Plectranthus neochilus','TaxRef v14', null, null,'Doliprane'),
		(9170,3371,get_nom_corr(37),get_nom_corr(153),get_nom_corr(30),get_nom_corr(157), null,get_nom_corr(140),get_nom_corr(84),get_nom_corr(171),get_nom_corr(73), null,'Sant S.',get_nom_corr(446),448262,'Plectranthus amboinicus','Plectranthus amboinicus','TaxRef v14', null, null,'Gros thym'),
		(9171,3371,get_nom_corr(37),get_nom_corr(153),get_nom_corr(30),get_nom_corr(160), null,get_nom_corr(140),get_nom_corr(84),get_nom_corr(171),get_nom_corr(73), null,'Sant S.',get_nom_corr(446),971931,'Coleus monostachyus','Carex casteriana','TaxRef v14', null, null,'Invasive'),
		(9172,3371,get_nom_corr(37),get_nom_corr(153),get_nom_corr(30),get_nom_corr(157), null,get_nom_corr(140),get_nom_corr(84),get_nom_corr(171),get_nom_corr(73), null,'Sant S.',get_nom_corr(446),629399,'Congea tomentosa','Congea tomentosa','TaxRef v14', null, null, null),
		(9173,3371,get_nom_corr(37),get_nom_corr(153),get_nom_corr(30),get_nom_corr(157), null,get_nom_corr(140),get_nom_corr(84),get_nom_corr(171),get_nom_corr(73), null,'Sant S.',get_nom_corr(446),629775,'Gmelina philippensis','Gmelina philippensis','TaxRef v14', null, null,'Sousou'),
		(9174,3371,get_nom_corr(37),get_nom_corr(153),get_nom_corr(30),get_nom_corr(157), null,get_nom_corr(140),get_nom_corr(84),get_nom_corr(171),get_nom_corr(73), null,'Sant S.',get_nom_corr(446),447272,'Cinnamomum verum','Cinnamomum verum','TaxRef v14', null, null,'cannelier'),
		(9175,3371,get_nom_corr(37),get_nom_corr(153),get_nom_corr(30),get_nom_corr(157), null,get_nom_corr(140),get_nom_corr(84),get_nom_corr(171),get_nom_corr(73), null,'Sant S.',get_nom_corr(446),447273,'Persea americana','Persea americana','TaxRef v14', null, null,'Avocatier'),
		(9176,3371,get_nom_corr(37),get_nom_corr(153),get_nom_corr(30),get_nom_corr(157), null,get_nom_corr(140),get_nom_corr(84),get_nom_corr(171),get_nom_corr(73), null,'Sant S.',get_nom_corr(446),629215,'Bunchosia glandulifera','Bunchosia glandulifera','TaxRef v14', null, null, null),
		(9177,3371,get_nom_corr(37),get_nom_corr(153),get_nom_corr(30),get_nom_corr(157), null,get_nom_corr(140),get_nom_corr(84),get_nom_corr(171),get_nom_corr(73), null,'Sant S.',get_nom_corr(446),630081,'Malpighia emarginata','Malpighia emarginata','TaxRef v14', null, null,'Cerise pays, Acérola'),
		(9178,3371,get_nom_corr(37),get_nom_corr(153),get_nom_corr(30),get_nom_corr(157), null,get_nom_corr(140),get_nom_corr(84),get_nom_corr(171),get_nom_corr(73), null,'Sant S.',get_nom_corr(446),447298,'Abelmoschus esculentus','Abelmoschus esculentus','TaxRef v14', null, null,'Gombo'),
		(9179,3371,get_nom_corr(37),get_nom_corr(153),get_nom_corr(30),get_nom_corr(157), null,get_nom_corr(140),get_nom_corr(84),get_nom_corr(171),get_nom_corr(73), null,'Sant S.',get_nom_corr(446),447302,'Gossypium barbadense','Gossypium barbadense','TaxRef v14', null, null,'coton'),
		(9180,3371,get_nom_corr(37),get_nom_corr(153),get_nom_corr(30),get_nom_corr(157), null,get_nom_corr(140),get_nom_corr(84),get_nom_corr(171),get_nom_corr(73), null,'Sant S.',get_nom_corr(446),445757,'Hibiscus schizocephalus','Hibiscus schizopetalus','TaxRef v14', null, null,'Hibiscus'),
		(9181,3371,get_nom_corr(37),get_nom_corr(153),get_nom_corr(30),get_nom_corr(157), null,get_nom_corr(140),get_nom_corr(84),get_nom_corr(171),get_nom_corr(73), null,'Sant S.',get_nom_corr(446),193274,'Hibiscus sp.','Hibiscus','TaxRef v14', null, null,'Hibiscus'),
		(9182,3371,get_nom_corr(37),get_nom_corr(153),get_nom_corr(30),get_nom_corr(157), null,get_nom_corr(140),get_nom_corr(84),get_nom_corr(171),get_nom_corr(73), null,'Sant S.',get_nom_corr(446),447309,'Malvaviscus penduliflorus','Malvaviscus penduliflorus','TaxRef v14', null, null,'Hibiscus'),
		(9183,3371,get_nom_corr(37),get_nom_corr(153),get_nom_corr(30),get_nom_corr(157), null,get_nom_corr(140),get_nom_corr(84),get_nom_corr(171),get_nom_corr(73), null,'Sant S.',get_nom_corr(446),779754,'Theobroma grandiflorum','Theobroma grandiflorum','TaxRef v14', null, null,'Cupuaçu'),
		(9184,3371,get_nom_corr(37),get_nom_corr(153),get_nom_corr(30),get_nom_corr(157), null,get_nom_corr(140),get_nom_corr(84),get_nom_corr(171),get_nom_corr(73), null,'Sant S.',get_nom_corr(446),892981,'Pleroma heteromallum','Pleroma heteromallum','TaxRef v14', null, null, null),
		(9185,3371,get_nom_corr(37),get_nom_corr(153),get_nom_corr(30),get_nom_corr(160), null,get_nom_corr(140),get_nom_corr(84),get_nom_corr(171),get_nom_corr(73), null,'Sant S.',get_nom_corr(446),630163,'Microtea debilis','Microtea debilis','TaxRef v14', null, null, null),
		(9186,3371,get_nom_corr(37),get_nom_corr(153),get_nom_corr(30),get_nom_corr(157), null,get_nom_corr(140),get_nom_corr(84),get_nom_corr(171),get_nom_corr(73), null,'Sant S.',get_nom_corr(446),447363,'Artocarpus altilis','Artocarpus altilis','TaxRef v14', null, null,'Arbre à pain'),
		(9187,3371,get_nom_corr(37),get_nom_corr(153),get_nom_corr(30),get_nom_corr(157), null,get_nom_corr(140),get_nom_corr(84),get_nom_corr(171),get_nom_corr(73), null,'Sant S.',get_nom_corr(446),445805,'Ficus benjamina','Ficus benjamina','TaxRef v14', null, null,'Ficus, figuier pleureur'),
		(9188,3371,get_nom_corr(37),get_nom_corr(153),get_nom_corr(30),get_nom_corr(157), null,get_nom_corr(140),get_nom_corr(84),get_nom_corr(171),get_nom_corr(73), null,'Sant S.',get_nom_corr(446),446234,'Musa spp.','Musa','TaxRef v14', null, null,'Bananier'),
		(9189,3371,get_nom_corr(37),get_nom_corr(153),get_nom_corr(30),get_nom_corr(157), null,get_nom_corr(140),get_nom_corr(84),get_nom_corr(171),get_nom_corr(73), null,'Sant S.',get_nom_corr(446),447403,'Pimenta racemosa','Pimenta racemosa','TaxRef v14', null, null,'Bois d''Inde'),
		(9190,3371,get_nom_corr(37),get_nom_corr(153),get_nom_corr(30),get_nom_corr(157), null,get_nom_corr(140),get_nom_corr(84),get_nom_corr(171),get_nom_corr(73), null,'Sant S.',get_nom_corr(446),447412,'Syzygium malaccence','Syzygium malaccense','TaxRef v14', null, null,'Pomme-rosa'),
		(9191,3371,get_nom_corr(37),get_nom_corr(153),get_nom_corr(30),get_nom_corr(157), null,get_nom_corr(140),get_nom_corr(84),get_nom_corr(171),get_nom_corr(73), null,'Sant S.',get_nom_corr(446),86216,'Bougainvillea spectabilis','Bougainvillea spectabilis','TaxRef v14', null, null,'Bougainvillée'),
		(9192,3371,get_nom_corr(37),get_nom_corr(153),get_nom_corr(30),get_nom_corr(157), null,get_nom_corr(140),get_nom_corr(84),get_nom_corr(171),get_nom_corr(73), null,'Sant S.',get_nom_corr(446),445864,'Jasminum multiflorum','Jasminum multiflorum','TaxRef v14', null, null, null),
		(9193,3371,get_nom_corr(37),get_nom_corr(153),get_nom_corr(30),get_nom_corr(157), null,get_nom_corr(140),get_nom_corr(84),get_nom_corr(171),get_nom_corr(73), null,'Sant S.',get_nom_corr(446),629119,'Arundina graminifolia','Arundina graminifolia','TaxRef v14', null, null,'orchidée bambou'),
		(9194,3371,get_nom_corr(37),get_nom_corr(153),get_nom_corr(30),get_nom_corr(157), null,get_nom_corr(140),get_nom_corr(84),get_nom_corr(171),get_nom_corr(73), null,'Sant S.',get_nom_corr(446),628107,'Coelogyne x bufordiense','Coelogyne','TaxRef v14', null, null, null),
		(9195,3371,get_nom_corr(37),get_nom_corr(153),get_nom_corr(30),get_nom_corr(157), null,get_nom_corr(140),get_nom_corr(84),get_nom_corr(171),get_nom_corr(73), null,'Sant S.',get_nom_corr(446),99902528,'Phalaenopsis spp.','Phalaenopsis', null, null, null, null),
		(9196,3371,get_nom_corr(37),get_nom_corr(153),get_nom_corr(30),get_nom_corr(157), null,get_nom_corr(140),get_nom_corr(84),get_nom_corr(171),get_nom_corr(73), null,'Sant S.',get_nom_corr(446),448405,'Spathoglottis spicata','Spathoglottis plicata','TaxRef v14', null, null, null),
		(9197,3371,get_nom_corr(37),get_nom_corr(153),get_nom_corr(30),get_nom_corr(157), null,get_nom_corr(140),get_nom_corr(84),get_nom_corr(171),get_nom_corr(73), null,'Sant S.',get_nom_corr(446),445877,'Passiflora edulis','Passiflora edulis','TaxRef v14', null, null,'Maracuja'),
		(9198,3371,get_nom_corr(37),get_nom_corr(153),get_nom_corr(30),get_nom_corr(160), null,get_nom_corr(140),get_nom_corr(84),get_nom_corr(171),get_nom_corr(73), null,'Sant S.',get_nom_corr(446),630368,'Petiveria alliacea','Petiveria alliacea','TaxRef v14', null, null, null),
		(9199,3371,get_nom_corr(37),get_nom_corr(153),get_nom_corr(30),get_nom_corr(160), null,get_nom_corr(140),get_nom_corr(84),get_nom_corr(171),get_nom_corr(73), null,'Sant S.',get_nom_corr(446),445642,'Phyllanthus amarus','Phyllanthus amarus','TaxRef v14', null, null,'graine en bas feuille'),
		(9200,3371,get_nom_corr(37),get_nom_corr(153),get_nom_corr(30),get_nom_corr(160), null,get_nom_corr(140),get_nom_corr(84),get_nom_corr(171),get_nom_corr(73), null,'Sant S.',get_nom_corr(446),445649,'Phyllanthus urinaria','Phyllanthus urinaria','TaxRef v14', null, null,'graine en bas feuille'),
		(9201,3371,get_nom_corr(37),get_nom_corr(153),get_nom_corr(30),get_nom_corr(157), null,get_nom_corr(140),get_nom_corr(84),get_nom_corr(171),get_nom_corr(73), null,'Sant S.',get_nom_corr(446),446369,'Pinus caribaea','Pinus caribaea','TaxRef v14', null, null,'Pin Caraïbe'),
		(9202,3371,get_nom_corr(37),get_nom_corr(153),get_nom_corr(30),get_nom_corr(157), null,get_nom_corr(140),get_nom_corr(84),get_nom_corr(171),get_nom_corr(73), null,'Sant S.',get_nom_corr(446),447453,'Piper nigrum','Piper nigrum','TaxRef v14', null, null,'Poivre'),
		(9203,3371,get_nom_corr(37),get_nom_corr(153),get_nom_corr(30),get_nom_corr(160), null,get_nom_corr(140),get_nom_corr(84),get_nom_corr(171),get_nom_corr(73), null,'Sant S.',get_nom_corr(446),851780,'Angelonia minor','Angelonia minor','TaxRef v14', null, null, null),
		(9204,3371,get_nom_corr(37),get_nom_corr(153),get_nom_corr(30),get_nom_corr(160), null,get_nom_corr(140),get_nom_corr(84),get_nom_corr(171),get_nom_corr(73), null,'Sant S.',get_nom_corr(446),895547,'Limnophila rugosa','Limnophila rugosa','TaxRef v14', null, null,'Invasive'),
		(9205,3371,get_nom_corr(37),get_nom_corr(153),get_nom_corr(30),get_nom_corr(160), null,get_nom_corr(140),get_nom_corr(84),get_nom_corr(171),get_nom_corr(73), null,'Sant S.',get_nom_corr(446),630128,'Mecardonia procumbens','Mecardonia procumbens','TaxRef v14', null, null, null),
		(9206,3371,get_nom_corr(37),get_nom_corr(153),get_nom_corr(30),get_nom_corr(160), null,get_nom_corr(140),get_nom_corr(84),get_nom_corr(171),get_nom_corr(73), null,'Sant S.',get_nom_corr(446),447898,'Bambusa vulgaris','Bambusa vulgaris','TaxRef v14', null, null,'Bambou'),
		(9207,3371,get_nom_corr(37),get_nom_corr(153),get_nom_corr(30),get_nom_corr(157), null,get_nom_corr(140),get_nom_corr(84),get_nom_corr(171),get_nom_corr(73), null,'Sant S.',get_nom_corr(446),447899,'Cymbopogon citratus','Cymbopogon citratus','TaxRef v14', null, null,'Citronelle'),
		(9208,3371,get_nom_corr(37),get_nom_corr(153),get_nom_corr(30),get_nom_corr(157), null,get_nom_corr(140),get_nom_corr(84),get_nom_corr(171),get_nom_corr(73), null,'Sant S.',get_nom_corr(446),446334,'Saccharum officinarum','Saccharum officinarum','TaxRef v14', null, null,'Canne à sucre'),
		(9209,3371,get_nom_corr(37),get_nom_corr(153),get_nom_corr(30),get_nom_corr(160), null,get_nom_corr(140),get_nom_corr(84),get_nom_corr(171),get_nom_corr(73), null,'Sant S.',get_nom_corr(446),732404,'Tripsacum andersonii','Tripsacum andersonii','TaxRef v14', null, null,'Invasive - zerb à zébu'),
		(9210,3371,get_nom_corr(37),get_nom_corr(153),get_nom_corr(30),get_nom_corr(157), null,get_nom_corr(140),get_nom_corr(84),get_nom_corr(171),get_nom_corr(73), null,'Sant S.',get_nom_corr(446),671394,'Platycerium bifurcatum','Platycerium bifurcatum','TaxRef v14', null, null,'Corne de cerf'),
		(9211,3371,get_nom_corr(37),get_nom_corr(153),get_nom_corr(30),get_nom_corr(160), null,get_nom_corr(140),get_nom_corr(84),get_nom_corr(171),get_nom_corr(73), null,'Sant S.',get_nom_corr(446),446397,'Pteris tripartita','Pteris tripartita','TaxRef v14', null, null, null),
		(9212,3371,get_nom_corr(37),get_nom_corr(153),get_nom_corr(30),get_nom_corr(157), null,get_nom_corr(140),get_nom_corr(84),get_nom_corr(171),get_nom_corr(73), null,'Sant S.',get_nom_corr(446),445915,'Ziziphus mauritiana','Ziziphus mauritiana','TaxRef v14', null, null,'surette'),
		(9213,3371,get_nom_corr(37),get_nom_corr(153),get_nom_corr(30),get_nom_corr(157), null,get_nom_corr(140),get_nom_corr(84),get_nom_corr(171),get_nom_corr(73), null,'Sant S.',get_nom_corr(446),197264,'Rosa xhybride (chinensis?????)','Rosa','TaxRef v14', null, null,'Rosier'),
		(9214,3371,get_nom_corr(37),get_nom_corr(153),get_nom_corr(30),get_nom_corr(157), null,get_nom_corr(140),get_nom_corr(84),get_nom_corr(171),get_nom_corr(73), null,'Sant S.',get_nom_corr(446),447477,'Coffea arabica','Coffea arabica','TaxRef v14', null, null,'Cafeier'),
		(9215,3371,get_nom_corr(37),get_nom_corr(153),get_nom_corr(30),get_nom_corr(157), null,get_nom_corr(140),get_nom_corr(84),get_nom_corr(171),get_nom_corr(73), null,'Sant S.',get_nom_corr(446),447488,'Gardenia jasminoides','Gardenia jasminoides','TaxRef v14', null, null,'Gardénia'),
		(9216,3371,get_nom_corr(37),get_nom_corr(153),get_nom_corr(30),get_nom_corr(157), null,get_nom_corr(140),get_nom_corr(84),get_nom_corr(171),get_nom_corr(73), null,'Sant S.',get_nom_corr(446),447502,'Ixora coccinea','Ixora coccinea','TaxRef v14', null, null, null),
		(9217,3371,get_nom_corr(37),get_nom_corr(153),get_nom_corr(30),get_nom_corr(157), null,get_nom_corr(140),get_nom_corr(84),get_nom_corr(171),get_nom_corr(73), null,'Sant S.',get_nom_corr(446),447516,'Morinda citrifolia','Morinda citrifolia','TaxRef v14', null, null,'noni, nono'),
		(9218,3371,get_nom_corr(37),get_nom_corr(153),get_nom_corr(30),get_nom_corr(157), null,get_nom_corr(140),get_nom_corr(84),get_nom_corr(171),get_nom_corr(73), null,'Sant S.',get_nom_corr(446),447519,'Mussaenda philippica','Mussaenda philippica','TaxRef v14', null, null, null),
		(9219,3371,get_nom_corr(37),get_nom_corr(153),get_nom_corr(30),get_nom_corr(157), null,get_nom_corr(140),get_nom_corr(84),get_nom_corr(171),get_nom_corr(73), null,'Sant S.',get_nom_corr(446),445970,'Citrus hystrix','Citrus hystrix','TaxRef v14', null, null,'Combava'),
		(9220,3371,get_nom_corr(37),get_nom_corr(153),get_nom_corr(30),get_nom_corr(157), null,get_nom_corr(140),get_nom_corr(84),get_nom_corr(171),get_nom_corr(73), null,'Sant S.',get_nom_corr(446),160289,'Citrus maxima','Citrus maxima','TaxRef v14', null, null,'shaddock, Chadek, Pamplemousse'),
		(9221,3371,get_nom_corr(37),get_nom_corr(153),get_nom_corr(30),get_nom_corr(157), null,get_nom_corr(140),get_nom_corr(84),get_nom_corr(171),get_nom_corr(73), null,'Sant S.',get_nom_corr(446),91811,'Citrus reticulata','Citrus medica','TaxRef v14', null, null,'Mandarinier'),
		(9222,3371,get_nom_corr(37),get_nom_corr(153),get_nom_corr(30),get_nom_corr(157), null,get_nom_corr(140),get_nom_corr(84),get_nom_corr(171),get_nom_corr(73), null,'Sant S.',get_nom_corr(446),971672,'Citrus x aurantium var. sinensis','Citrus x aurantium var. sinensis','TaxRef v14', null, null,'Oranger doux'),
		(9223,3371,get_nom_corr(37),get_nom_corr(153),get_nom_corr(30),get_nom_corr(157), null,get_nom_corr(140),get_nom_corr(84),get_nom_corr(171),get_nom_corr(73), null,'Sant S.',get_nom_corr(446),971674,'Citrus x latifolia','Citrus x latifolia','TaxRef v14', null, null,'Citron vert, lime'),
		(9224,3371,get_nom_corr(37),get_nom_corr(153),get_nom_corr(30),get_nom_corr(157), null,get_nom_corr(140),get_nom_corr(84),get_nom_corr(171),get_nom_corr(73), null,'Sant S.',get_nom_corr(446),966788,'Citrus x limon','Citrus x limon','TaxRef v14', null, null,'Citronnier'),
		(9225,3371,get_nom_corr(37),get_nom_corr(153),get_nom_corr(30),get_nom_corr(157), null,get_nom_corr(140),get_nom_corr(84),get_nom_corr(171),get_nom_corr(73), null,'Sant S.',get_nom_corr(446),894434,'Citrus x tangelo','Citrus x tangelo','TaxRef v14', null, null,'tangelo'),
		(9226,3371,get_nom_corr(37),get_nom_corr(153),get_nom_corr(30),get_nom_corr(157), null,get_nom_corr(140),get_nom_corr(84),get_nom_corr(171),get_nom_corr(73), null,'Sant S.',get_nom_corr(446),629744,'Flacourtia jangomas','Flacourtia jangomas','TaxRef v14', null, null,'Merise'),
		(9227,3371,get_nom_corr(37),get_nom_corr(153),get_nom_corr(30),get_nom_corr(157), null,get_nom_corr(140),get_nom_corr(84),get_nom_corr(171),get_nom_corr(73), null,'Sant S.',get_nom_corr(446),447595,'Melicoccus bijugatus','Melicoccus bijugatus','TaxRef v14', null, null,'Quenette'),
		(9228,3371,get_nom_corr(37),get_nom_corr(153),get_nom_corr(30),get_nom_corr(157), null,get_nom_corr(140),get_nom_corr(84),get_nom_corr(171),get_nom_corr(73), null,'Sant S.',get_nom_corr(446),447596,'Nephelium lappaceum','Nephelium lappaceum','TaxRef v14', null, null,'ramboutan'),
		(9229,3371,get_nom_corr(37),get_nom_corr(153),get_nom_corr(30),get_nom_corr(160), null,get_nom_corr(140),get_nom_corr(84),get_nom_corr(171),get_nom_corr(73), null,'Sant S.',get_nom_corr(446),446505,'Selaginella willdenowii','Selaginella willdenowii','TaxRef v14', null, null,'Invasive - Sélaginelle bleue'),
		(9230,3371,get_nom_corr(37),get_nom_corr(153),get_nom_corr(30),get_nom_corr(157), null,get_nom_corr(140),get_nom_corr(84),get_nom_corr(171),get_nom_corr(73), null,'Sant S.',get_nom_corr(446),447615,'Quassia amara','Quassia amara','TaxRef v14', null, null,'kwachi'),
		(9231,3371,get_nom_corr(37),get_nom_corr(153),get_nom_corr(30),get_nom_corr(157), null,get_nom_corr(140),get_nom_corr(84),get_nom_corr(171),get_nom_corr(73), null,'Sant S.',get_nom_corr(446),630690,'Solandra longiflora','Solandra longiflora','TaxRef v14', null, null,'Solanaceae'),
		(9232,3371,get_nom_corr(37),get_nom_corr(153),get_nom_corr(30),get_nom_corr(160), null,get_nom_corr(140),get_nom_corr(84),get_nom_corr(171),get_nom_corr(73), null,'Sant S.',get_nom_corr(446),446025,'Solanum torvum','Solanum torvum','TaxRef v14', null, null, null),
		(9233,3371,get_nom_corr(37),get_nom_corr(153),get_nom_corr(30),get_nom_corr(157), null,get_nom_corr(140),get_nom_corr(84),get_nom_corr(171),get_nom_corr(73), null,'Sant S.',get_nom_corr(446),630042,'Lippia alba','Lippia alba','TaxRef v14', null, null, null),
		(9234,3371,get_nom_corr(37),get_nom_corr(153),get_nom_corr(30),get_nom_corr(157), null,get_nom_corr(140),get_nom_corr(84),get_nom_corr(171),get_nom_corr(73), null,'Sant S.',get_nom_corr(446),630043,'Lippia micromera','Lippia micromera','TaxRef v14', null, null,'thym'),
		(9235,3371,get_nom_corr(37),get_nom_corr(153),get_nom_corr(30),get_nom_corr(160), null,get_nom_corr(140),get_nom_corr(84),get_nom_corr(171),get_nom_corr(73), null,'Sant S.',get_nom_corr(446),630488,'Priva lappulacea','Priva lappulacea','TaxRef v14', null, null, null),
		(9236,3371,get_nom_corr(37),get_nom_corr(153),get_nom_corr(30),get_nom_corr(157), null,get_nom_corr(140),get_nom_corr(84),get_nom_corr(171),get_nom_corr(73), null,'Sant S.',get_nom_corr(446),447681,'Stachytarfeta mutabilis','Stachytarpheta mutabilis','TaxRef v14', null, null, null),
		(9237,3371,get_nom_corr(37),get_nom_corr(153),get_nom_corr(30),get_nom_corr(157), null,get_nom_corr(140),get_nom_corr(84),get_nom_corr(171),get_nom_corr(73), null,'Sant S.',get_nom_corr(446),447930,'Alpinia zerumbet','Alpinia zerumbet','TaxRef v14', null, null,'Atoumo, Zerumbet'),
		(9238,3371,get_nom_corr(37),get_nom_corr(153),get_nom_corr(30),get_nom_corr(157), null,get_nom_corr(140),get_nom_corr(84),get_nom_corr(171),get_nom_corr(73), null,'Sant S.',get_nom_corr(446),448304,'Etlingera elatior','Etlingera elatior','TaxRef v14', null, null,'Rose de porcelaine');
UPDATE pr_occtax.t_occurrences_occtax set non_digital_proof = null where id_occurrence_occtax >=9104;
SELECT setval('pr_occtax.t_occurrences_occtax_id_occurrence_occtax_seq', (SELECT MAX(id_occurrence_occtax) FROM pr_occtax.t_occurrences_occtax)+1);
-----------------------------------------------2/ les counting des espèces exotiques
INSERT INTO pr_occtax.cor_counting_occtax(id_occurrence_occtax, id_nomenclature_life_stage, id_nomenclature_sex, id_nomenclature_obj_count, id_nomenclature_type_count, count_min, count_max)
	SELECT id_occurrence_occtax, get_nom_corr(1), get_nom_corr(167), get_nom_corr(141), get_nom_corr(90), 1, 50 from pr_occtax.t_occurrences_occtax where id_releve_occtax=3371;

