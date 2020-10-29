-- replay triggers
WITH myobservers AS ( SELECT
	array_to_string(array_agg(rol.nom_role || ' ' || rol.prenom_role), ', ') AS observers_name,
	array_agg(rol.id_role) AS observers_id,
	cor.id_releve_occtax
	FROM export_oo.v_role_releves_occtax cor
	JOIN export_oo.v_roles rol ON rol.id_role = cor.id_role
	GROUP BY cor.id_releve_occtax
)
INSERT INTO gn_synthese.synthese (
unique_id_sinp,
unique_id_sinp_grp,
id_source,
entity_source_pk_value,
id_dataset,
id_module,
id_nomenclature_geo_object_nature,
id_nomenclature_grp_typ,
grp_method,
id_nomenclature_obs_technique,
id_nomenclature_bio_status,
id_nomenclature_bio_condition,
id_nomenclature_naturalness,
id_nomenclature_exist_proof,
id_nomenclature_diffusion_level,
id_nomenclature_life_stage,
id_nomenclature_sex,
id_nomenclature_obj_count,
id_nomenclature_type_count,
id_nomenclature_observation_status,
id_nomenclature_blurring,
id_nomenclature_source_status,
id_nomenclature_info_geo_type,
id_nomenclature_behaviour,
count_min,
count_max,
cd_nom,
cd_hab,
nom_cite,
meta_v_taxref,
sample_number_proof,
digital_proof,
non_digital_proof,
altitude_min,
altitude_max,
depth_min,
depth_max,
place_name,
precision,
the_geom_4326,
the_geom_point,
the_geom_local,
date_min,
date_max,
observers,
determiner,
id_digitiser,
id_nomenclature_determination_method,
comment_context,
comment_description,
last_action
)
SELECT
  c.unique_id_sinp_occtax,
  r.unique_id_sinp_grp,
  source.id_source,
  c.id_counting_occtax,
  r.id_dataset,
  gn_commons.get_id_module_bycode('OCCTAX'),
  r.id_nomenclature_geo_object_nature,
  r.id_nomenclature_grp_typ,
  r.grp_method,
  o.id_nomenclature_obs_technique,
  o.id_nomenclature_bio_status,
  o.id_nomenclature_bio_condition,
  o.id_nomenclature_naturalness,
  o.id_nomenclature_exist_proof,
  o.id_nomenclature_diffusion_level,
   c.id_nomenclature_life_stage,
   c.id_nomenclature_sex,
   c.id_nomenclature_obj_count,
   c.id_nomenclature_type_count,
  o.id_nomenclature_observation_status,
  o.id_nomenclature_blurring,
  -- status_source récupéré depuis le JDD
  id_nomenclature_source_status,
  -- id_nomenclature_info_geo_type: type de rattachement = géoréferencement
  ref_nomenclatures.get_id_nomenclature('TYP_INF_GEO', '1'),
  o.id_nomenclature_behaviour,
   c.count_min,
   c.count_max,
  o.cd_nom,
  r.cd_hab,
  o.nom_cite,
  o.meta_v_taxref,
  o.sample_number_proof,
  o.digital_proof,
  o.non_digital_proof,
  r.altitude_min,
  r.altitude_max,
  r.depth_min,
  r.depth_max,
  r.place_name,
  r.precision,
  r.geom_4326,
  ST_CENTROID(r.geom_4326),
  r.geom_local,
  date_trunc('day',r.date_min)+COALESCE(r.hour_min,'00:00:00'::time),
  date_trunc('day',r.date_max)+COALESCE(r.hour_max,'00:00:00'::time),
  COALESCE (mo.observers_name, r.observers_txt),
  o.determiner,
  r.id_digitiser,
  o.id_nomenclature_determination_method,
  r.comment,
  o.comment,
  'I'

    FROM export_oo.v_saisie_observation_cd_nom_valid s
    JOIN export_oo.v_counting_occtax c
        ON s.unique_id_sinp_occtax = c.unique_id_sinp_occtax 
    JOIN export_oo.v_occurrences_occtax o
        ON o.id_occurrence_occtax = c.id_occurrence_occtax
    JOIN export_oo.v_releves_occtax r
        ON r.id_releve_occtax = o.id_releve_occtax
    JOIN gn_synthese.t_sources source 
	ON name_source ILIKE 'occtax'
    JOIN myobservers mo
	    ON mo.id_releve_occtax = r.id_releve_occtax
;


-- replay triggers

INSERT INTO gn_synthese.cor_observer_synthese (id_synthese, id_role)
    SELECT 
        s.id_synthese,
        c.id_role AS id_role

    FROM export_oo.v_saisie_observation_cd_nom_valid sv
    JOIN export_oo.v_synthese s
        ON s.unique_id_sinp = sv.unique_id_sinp_occtax
    JOIN pr_occtax.t_releves_occtax r
        ON s.unique_id_sinp_grp = r.unique_id_sinp_grp
    JOIN export_oo.v_role_releves_occtax c  
        ON c.id_releve_occtax = r.id_releve_occtax
;