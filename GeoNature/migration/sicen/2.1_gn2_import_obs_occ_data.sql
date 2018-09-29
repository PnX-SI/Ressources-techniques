-- Import initial

-- Programme et cadre d'acquisition

WITH bound as (
SELECT st_extent(st_transform(geom, 4326)) as bbox
FROM ref_geo.l_areas 
WHERE id_type = 10002
)
INSERT INTO gn_meta.t_datasets( unique_dataset_id, id_acquisition_framework, dataset_name, 
            dataset_shortname, dataset_desc, 
            id_nomenclature_data_type, keywords, 
            marine_domain, terrestrial_domain, id_nomenclature_dataset_objectif, 
            bbox_west, bbox_east, bbox_south, bbox_north,
            default_validity)
SELECT unique_dataset_id, 1, libelle, libelle, COALESCE(resume, libelle), 
326, NULL, false, true, 415,
st_xmin(bbox), st_xmax(bbox), st_ymin(bbox), st_ymax(bbox),
true
FROM import_obs_occ.protocole, bound
WHERE NOT unique_dataset_id IN (SELECT unique_dataset_id FROM gn_meta.t_datasets);

-- Import des sources
INSERT INTO gn_synthese.t_sources(
            name_source, desc_source, entity_source_pk_field, 
            url_source)
VALUES (
    'obs_occ', 'Données issue de observations occasionelles', 'saisie.saisie_observation.id_obs', 
    'appli.cevennes-parcnational.net/obs_occ'
);


-- Import des données
ALTER TABLE gn_synthese.synthese DISABLE TRIGGER ALL;
WITH id_source AS (
    SELECT id_source FROM gn_synthese.t_sources WHERE name_source='obs_occ'
)
INSERT INTO gn_synthese.synthese(
            unique_id_sinp, unique_id_sinp_grp, id_source, entity_source_pk_value, 
            id_dataset, id_nomenclature_geo_object_nature, id_nomenclature_grp_typ, 
            id_nomenclature_obs_meth, id_nomenclature_obs_technique, id_nomenclature_bio_status, 
            id_nomenclature_bio_condition, id_nomenclature_naturalness, id_nomenclature_exist_proof, 
            id_nomenclature_valid_status, id_nomenclature_diffusion_level, 
            id_nomenclature_life_stage, id_nomenclature_sex, id_nomenclature_obj_count, 
            id_nomenclature_type_count, id_nomenclature_sensitivity, id_nomenclature_observation_status, 
            id_nomenclature_blurring, id_nomenclature_source_status, id_nomenclature_info_geo_type, 
            count_min, count_max, cd_nom, nom_cite, meta_v_taxref, sample_number_proof, 
            digital_proof, non_digital_proof, altitude_min, altitude_max, 
            the_geom_4326, the_geom_point, the_geom_local, date_min, date_max, 
            validator, validation_comment, 
            observers, determiner, id_nomenclature_determination_method, 
            comments, meta_validation_date, meta_create_date, meta_update_date, 
            last_action
       )
SELECT NULL AS unique_id_sinp, 
        NULL AS unique_id_sinp_grp, 
        (SELECT id_source FROM id_source) as id_source, 
        id_obs as entity_source_pk_value, 
       ds.id_dataset, 
       gn_synthese.get_default_nomenclature_value('NAT_OBJ_GEO') as id_nomenclature_geo_object_nature, 
       gn_synthese.get_default_nomenclature_value('TYP_GRP') as id_nomenclature_grp_typ, 
       COALESCE(ref_nomenclatures.get_synonymes_nomenclature('METH_OBS', determination), gn_synthese.get_default_nomenclature_value('METH_OBS')) as id_nomenclature_obs_meth, 
       gn_synthese.get_default_nomenclature_value('TECHNIQUE_OBS') id_nomenclature_obs_technique, 
       gn_synthese.get_default_nomenclature_value('STATUT_BIO') as id_nomenclature_bio_status, 
       COALESCE(ref_nomenclatures.get_synonymes_nomenclature('ETA_BIO', determination), gn_synthese.get_default_nomenclature_value('ETA_BIO')) as id_nomenclature_bio_condition, 
       gn_synthese.get_default_nomenclature_value('NATURALITE') as id_nomenclature_naturalness, 
       gn_synthese.get_default_nomenclature_value('PREUVE_EXIST') as id_nomenclature_exist_proof, 
       COALESCE(ref_nomenclatures.get_synonymes_nomenclature('STATUT_VALID', statut_validation) , gn_synthese.get_default_nomenclature_value('STATUT_VALID')) as id_nomenclature_valid_status, 
       gn_synthese.get_default_nomenclature_value('NIV_PRECIS') as id_nomenclature_diffusion_level, 
       COALESCE(ref_nomenclatures.get_synonymes_nomenclature('STADE_VIE', type_effectif), gn_synthese.get_default_nomenclature_value('STADE_VIE')) as id_nomenclature_life_stage, 
       COALESCE(ref_nomenclatures.get_synonymes_nomenclature('SEXE', phenologie), gn_synthese.get_default_nomenclature_value('SEXE')) as id_nomenclature_sex, 
       gn_synthese.get_default_nomenclature_value('OBJ_DENBR') as id_nomenclature_obj_count, 
       gn_synthese.get_default_nomenclature_value('TYP_DENBR') as id_nomenclature_type_count, 
       gn_synthese.get_default_nomenclature_value('SENSIBILITE') as id_nomenclature_sensitivity, 
       gn_synthese.get_default_nomenclature_value('STATUT_OBS') as id_nomenclature_observation_status, 
       gn_synthese.get_default_nomenclature_value('DEE_FLOU') as id_nomenclature_blurring, 
       gn_synthese.get_default_nomenclature_value('STATUT_SOURCE') as id_nomenclature_source_status,
       gn_synthese.get_default_nomenclature_value('TYP_INF_GEO') as id_nomenclature_info_geo_type, 
       
       CASE WHEN effectif_min > 0 THEN effectif_min ELSE Coalesce(effectif, effectif_max, 0) END AS count_min,
       CASE WHEN effectif_max > 0 THEN effectif_max ELSE Coalesce(effectif_min, effectif, 0) END AS count_max,

       tx.cd_nom::int, COALESCE(d.nom_complet, d.nom_vern) as nom_cite, 'Taxref V11' as  meta_v_taxref,
       NULL AS sample_number_proof, 
       url_photo AS digital_proof, 
       NULL AS non_digital_proof, 
       NULL AS altitude_min, NULL AS altitude_max, 
       st_setsrid(geometrie, 4326) as the_geom_4326, st_centroid(st_setsrid(geometrie, 4326)) as the_geom_point, st_transform(st_setsrid(geometrie, 4326), 2154) as the_geom_local, 

       
       COALESCE(date_debut_obs, date_obs, '1900-01-01'::date) AS date_debut,
        COALESCE(date_fin_obs, date_debut_obs, date_obs,  '1900-01-01'::date) AS  date_fin,
        
       
       id_validateur as id_validator, decision_validation as validation_comment, 
       observateur as observers,  NULL AS determiner, 
       gn_synthese.get_default_nomenclature_value('METH_DETERMIN') id_nomenclature_determination_method, 
       remarque_obs as comments, NULL AS meta_validation_date, date_insert AS  meta_create_date, date_last_update AS meta_update_date, 
       CASE
        WHEN date_last_update IS NULL THEN 'I'
        ELSE 'U'
       END as last_action
  FROM import_obs_occ.fdw_obs_occ_data d
  JOIN import_obs_occ.protocole p ON d.id_protocole = p.id_protocole
  JOIN gn_meta.t_datasets ds ON p.unique_dataset_id = ds.unique_dataset_id
  JOIN taxonomie.taxref tx ON d.cd_nom::int = tx.cd_nom
  ;



-- Import des observateurs
INSERT INTO gn_synthese.cor_observer_synthese (id_synthese, id_role)
SELECT id_synthese,  unnest(ids_observateur)::int as id_role
FROM import_obs_occ.fdw_obs_occ_data d
JOIN (
	SELECT id_synthese , entity_source_pk_value FROM gn_synthese.synthese s 
	WHERE id_source in (
	    SELECT id_source FROM gn_synthese.t_sources WHERE name_source='obs_occ'
	)
)s
on s.entity_source_pk_value = id_obs::varchar
WHERE NOT observateur IS NULL;

-- Calculate cor_area

INSERT INTO gn_synthese.cor_area_synthese
SELECT id_synthese, id_area
FROM  (SELECT * FROM gn_synthese.synthese WHERE NOT id_synthese IN (SELECT id_synthese FROM gn_synthese.cor_area_synthese)) s
JOIN ref_geo.l_areas l
ON st_intersects(s.the_geom_local, l.geom);

ALTER TABLE gn_synthese.synthese ENABLE TRIGGER ALL;
