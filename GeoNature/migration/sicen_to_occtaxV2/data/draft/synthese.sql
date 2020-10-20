WITH myobservers AS ( SELECT
	array_to_string(array_agg(rol.nom_role || ' ' || rol.prenom_role), ', ') AS observers_name,
	array_agg(rol.id_role) AS observers_id,
	cor.id_releve_occtax
	FROM pr_occtax.cor_role_releves_occtax cor
	JOIN utilisateurs.t_roles rol ON rol.id_role = cor.id_role
	GROUP BY cor.id_releve_occtax
)
--SELECT * FROM myobservers
--SELECT * FROM pr_occtax.cor_role_releves_occtax
-- INSERT INTO gn_synthese.synthese (
-- unique_id_sinp,
-- unique_id_sinp_grp,
-- id_source,
-- entity_source_pk_value,
-- id_dataset,
-- id_module,
-- id_nomenclature_geo_object_nature,
-- id_nomenclature_grp_typ,
-- grp_method,
-- id_nomenclature_obs_technique,
-- id_nomenclature_bio_status,
-- id_nomenclature_bio_condition,
-- id_nomenclature_naturalness,
-- id_nomenclature_exist_proof,
-- id_nomenclature_diffusion_level,
-- id_nomenclature_life_stage,
-- id_nomenclature_sex,
-- id_nomenclature_obj_count,
-- id_nomenclature_type_count,
-- id_nomenclature_observation_status,
-- id_nomenclature_blurring,
-- id_nomenclature_source_status,
-- id_nomenclature_info_geo_type,
-- id_nomenclature_behaviour,
-- count_min,
-- count_max,
-- cd_nom,
-- cd_hab,
-- nom_cite,
-- meta_v_taxref,
-- sample_number_proof,
-- digital_proof,
-- non_digital_proof,
-- altitude_min,
-- altitude_max,
-- depth_min,
-- depth_max,
-- place_name,
-- precision,
-- the_geom_4326,
-- the_geom_point,
-- the_geom_local,
-- date_min,
-- date_max,
-- observers,
-- determiner,
-- id_digitiser,
-- id_nomenclature_determination_method,
-- comment_context,
-- comment_description,
-- last_action
-- )
SELECT
  counting.unique_id_sinp_occtax,
  releve.unique_id_sinp_grp,
  source.id_source,
  counting.id_counting_occtax,
  releve.id_dataset,
  gn_commons.get_id_module_bycode('OCCTAX'),
  releve.id_nomenclature_geo_object_nature,
  releve.id_nomenclature_grp_typ,
  releve.grp_method,
  occurrence.id_nomenclature_obs_technique,
  occurrence.id_nomenclature_bio_status,
  occurrence.id_nomenclature_bio_condition,
  occurrence.id_nomenclature_naturalness,
  occurrence.id_nomenclature_exist_proof,
  occurrence.id_nomenclature_diffusion_level,
   counting.id_nomenclature_life_stage,
   counting.id_nomenclature_sex,
   counting.id_nomenclature_obj_count,
   counting.id_nomenclature_type_count,
  occurrence.id_nomenclature_observation_status,
  occurrence.id_nomenclature_blurring,
  -- status_source récupéré depuis le JDD
  id_nomenclature_source_status,
  -- id_nomenclature_info_geo_type: type de rattachement = géoréferencement
  ref_nomenclatures.get_id_nomenclature('TYP_INF_GEO', '1'),
  occurrence.id_nomenclature_behaviour,
   counting.count_min,
   counting.count_max,
  occurrence.cd_nom,
  releve.cd_hab,
  occurrence.nom_cite,
  occurrence.meta_v_taxref,
  occurrence.sample_number_proof,
  occurrence.digital_proof,
  occurrence.non_digital_proof,
  releve.altitude_min,
  releve.altitude_max,
  releve.depth_min,
  releve.depth_max,
  releve.place_name,
  releve.precision,
  releve.geom_4326,
  ST_CENTROID(releve.geom_4326),
  releve.geom_local,
  date_trunc('day',releve.date_min)+COALESCE(releve.hour_min,'00:00:00'::time),
  date_trunc('day',releve.date_max)+COALESCE(releve.hour_max,'00:00:00'::time),
  COALESCE (myobservers.observers_name, releve.observers_txt),
  occurrence.determiner,
  releve.id_digitiser,
  occurrence.id_nomenclature_determination_method,
  releve.comment,
  occurrence.comment,
  'I'

    FROM pr_occtax.cor_counting_occtax counting
    JOIN export_oo.saisie_observation so
        ON so.unique_id_sinp_occtax = counting.unique_id_sinp_occtax
    JOIN pr_occtax.t_occurrences_occtax occurrence
        ON occurrence.id_occurrence_occtax = counting.id_occurrence_occtax
    JOIN pr_occtax.t_releves_occtax releve
        ON releve.id_releve_occtax = occurrence.id_releve_occtax
    JOIN gn_synthese.t_sources source 
	ON name_source ILIKE 'occtax'
    JOIN myobservers
	ON myobservers.id_releve_occtax = releve.id_releve_occtax
;