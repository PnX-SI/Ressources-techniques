-- ### METADONNEES ### --

-- /!\ Les cadres d'acquisition et les jeux de données pour les données importés ont été crées depuis l'interface d'admin de Geonature
-- (Il est toutefois possible de les intégrer directement en SQL dans le schema gn_meta et en prenant soin de respecter les contraintes et les relations avec les autres objets de la BDD)

-- Cependant les emprises géographiques des Jeux de données n'ont pas été calculées via l'admin - on va donc mettre à jour manuellement la table gn_meta.t_datasets

-- On identifie d'abord l'id_area de son territoire dans l_areas et on relève l'id_area pour la requête suivante :
SELECT id_area, id_type, area_name, area_code
	FROM ref_geo.l_areas
	WHERE area_name ilike '%vercors%'
	AND id_type = 15;

-- On fait un update de la table gn_meta.t_datasets :	
WITH bound as (
SELECT st_extent(st_transform(geom, 4326)) as bbox
FROM ref_geo.l_areas 
WHERE id_area = 35288)
				 
UPDATE gn_meta.t_datasets
	SET bbox_west=st_xmin(bbox), bbox_east=st_xmax(bbox), bbox_south=st_ymin(bbox), bbox_north=st_ymax(bbox)
	FROM bound;

-- Ajout des sources de données à importer dans la table gn_synthese.t_sources
-- Ici, on joute une seule source pour l'ensemble des JDD identifiés dans Serena (ajouts manuellement dans GN via l'interface d'admin)
INSERT INTO gn_synthese.t_sources(
            name_source, desc_source, entity_source_pk_field, url_source)
VALUES ('Serena','Données issues de l''application Serena de RNF','serenabase.rnf_obse.obse_id','NULL'); 

-- ### IMPORT SYNTHESE ### --
				 
-- On désactive les triggers sur la synthese avant l'import
ALTER TABLE gn_synthese.synthese DISABLE TRIGGER ALL;
				 
-- On peuple la sythèse en s'appuyant sur la vue matérialisée crée à l'étape 1.3 : _import_serena.vm_obs_serena_detail_pt
-- en réalisant les calculs, correspondances et conversions de champs nécessaire pour peupler gn_synthese.synthese
				 
INSERT INTO gn_synthese.synthese(
	unique_id_sinp, unique_id_sinp_grp, id_source, entity_source_pk_value, 
	id_dataset, id_nomenclature_geo_object_nature, id_nomenclature_grp_typ, 
	id_nomenclature_obs_meth, id_nomenclature_obs_technique, id_nomenclature_bio_status, 
	id_nomenclature_bio_condition, id_nomenclature_naturalness, id_nomenclature_exist_proof, 
	id_nomenclature_valid_status, id_nomenclature_diffusion_level, id_nomenclature_life_stage, 
	id_nomenclature_sex, id_nomenclature_obj_count, id_nomenclature_type_count, 
	id_nomenclature_sensitivity, id_nomenclature_observation_status, id_nomenclature_blurring, 
	id_nomenclature_source_status, id_nomenclature_info_geo_type, 
	count_min, count_max, cd_nom, nom_cite, meta_v_taxref, 
	sample_number_proof, digital_proof, non_digital_proof, 
	altitude_min, altitude_max, the_geom_4326, the_geom_point, the_geom_local, date_min, date_max, 
	validator, validation_comment, 
	observers, determiner, id_digitiser, id_nomenclature_determination_method, 
	comments, meta_validation_date, meta_create_date, meta_update_date, last_action
	)
(SELECT DISTINCT
    NULL::uuid AS unique_id_sinp,
    NULL::uuid AS unique_id_sinp_grp,
    2 as id_source,
    d.obse_id as entity_source_pk_value,
    COALESCE(ds.id_dataset,1),
    175::integer AS id_nomenclature_geo_object_nature,
    134::integer AS id_nomenclature_grp_typ, 
    COALESCE(ref_nomenclatures.get_synonymes_nomenclature('METH_OBS', methode_obs), 62)::integer as id_nomenclature_obs_meth,
    COALESCE(ref_nomenclatures.get_synonymes_nomenclature('TECHNIQUE_OBS', protocole), 317)::integer AS id_nomenclature_obs_technique,
    COALESCE(ref_nomenclatures.get_synonymes_nomenclature('STATUT_BIO', statut_bio), 28)::integer AS id_nomenclature_bio_status,
    COALESCE(ref_nomenclatures.get_synonymes_nomenclature('ETA_BIO', etat_bio), 157)::integer AS id_nomenclature_bio_condition,
    161::integer AS id_nomenclature_naturalness,
    81::integer AS id_nomenclature_exist_proof,
    COALESCE(ref_nomenclatures.get_synonymes_nomenclature('STATUT_VALID', statut_validation), 323)::integer AS id_nomenclature_valid_status,
    145::integer AS id_nomenclature_diffusion_level,
    COALESCE(ref_nomenclatures.get_synonymes_nomenclature('STADE_VIE', stade_vie), 1)::integer AS id_nomenclature_life_stage,
    COALESCE(ref_nomenclatures.get_synonymes_nomenclature('SEXE', sexe), 172)::integer AS id_nomenclature_sex,
    147::integer AS id_nomenclature_obj_count,
    COALESCE(ref_nomenclatures.get_synonymes_nomenclature('TYP_DENBR', type_denombrement), 95)::integer AS id_nomenclature_type_count,
    67::integer AS id_nomenclature_sensitivity,
    89 AS id_nomenclature_observation_status,
    176 AS id_nomenclature_blurring,
    74 AS id_nomenclature_source_status,
    127 AS id_nomenclature_info_geo_type,
	d.effectif AS count_min,
	d.effectif AS count_max,
    d.taxo_mnhn_id AS cd_nom,
    COALESCE(t.nom_complet, t.nom_vern) as nom_cite,
    'Taxref V11' as  meta_v_taxref,
    NULL AS sample_number_proof,
    NULL AS digital_proof,
    NULL AS non_digital_proof,
    d.altitude as altitude_min,
    d.altitude as altitude_max,
	st_transform(st_setsrid(geom, 2154), 4326) as the_geom_4326, 
	st_transform(st_centroid(st_setsrid(geom, 2154)), 4326) as the_geom_point, 
	st_setsrid(geom, 2154) as the_geom_local, 
    d.date,
    d.date,
    NULL as validator,
    NULL as validation_comment,
    d.observateur as observers,
    d.determinateur as determiner,
    NULL::integer as id_digitiser,
    NULL::integer as id_nomenclature_determination_method,
    concat_ws('|', 
			  'Méthode loc : ' || d.methode_loc,
			  'Age : ' || d.age,
			  'Comportement : ' || d.comportement,
			  'Etat santé : ' || d.etat_sante,
			  'Bague : ' || d.obse_bague,
			  'Multi-critères : '|| d.obse_multicr,
			  'Remarques : '|| d.obse_comment
			  ) as comments,
    NULL::timestamp without time zone as meta_validation_date,
    d.obse_crea_dath::timestamp without time zone as meta_create_date,
    d.obse_lmod_dath::timestamp without time zone  as meta_update_date,
    'I' as last_action
 
	FROM _import_serena.vm_obs_serena_detail_pt as d
	JOIN taxonomie.taxref t ON d.taxo_mnhn_id = t.cd_nom
	LEFT JOIN gn_meta.t_datasets ds ON d.obse_relv_id::text = ds.dataset_shortname
	ORDER BY d.date DESC
);
				 
				 
-- On calcule cor_area_synthese (triggers désactivés)
WITH s AS 
	(SELECT * FROM gn_synthese.synthese WHERE NOT id_synthese IN (SELECT id_synthese FROM gn_synthese.cor_area_synthese))
INSERT INTO gn_synthese.cor_area_synthese
SELECT id_synthese, id_area
FROM s
JOIN ref_geo.l_areas l
ON st_intersects(s.the_geom_local, l.geom);
																  
-- On calcule aussi les résultats de recherche de taxons suggérés dans l'outil de recherche de Synthèse (trigger désactivé)
INSERT INTO gn_synthese.taxons_synthese_autocomplete
      (SELECT t.cd_nom,
              t.cd_ref,
          concat(t.lb_nom, ' = <i>', t.nom_valide, '</i>') AS search_name,
          t.nom_valide,
          t.lb_nom,
          t.regne,
          t.group2_inpn
      FROM taxonomie.taxref t
	  JOIN taxonomie.bib_noms n ON t.cd_nom = n.cd_nom
	  LEFT JOIN gn_synthese.taxons_synthese_autocomplete s ON n.cd_nom = s.cd_nom
	  WHERE s.cd_nom IS NULL)
UNION
      (SELECT t.cd_nom,
        t.cd_ref,
        concat(t.nom_vern, ' =  <i> ', t.nom_valide, '</i>' ) AS search_name,
        t.nom_valide,
        t.lb_nom,
        t.regne,
        t.group2_inpn
      FROM taxonomie.taxref t
	  JOIN taxonomie.bib_noms n ON t.cd_nom = n.cd_nom
	  LEFT JOIN gn_synthese.taxons_synthese_autocomplete s ON n.cd_nom = s.cd_nom
	  WHERE t.nom_vern IS NOT NULL
	  AND s.cd_nom IS NULL);																  																  
																	
-- TO DO : Calcul de l'altitude

-- On réactive les triggers
ALTER TABLE gn_synthese.synthese ENABLE TRIGGER ALL;				 
