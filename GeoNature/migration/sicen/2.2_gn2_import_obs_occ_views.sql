CREATE MATERIALIZED VIEW gn_imports.v_qry_synthese_obs_occ AS 
WITH last_import AS (
    SELECT COALESCE(max(start_time), '1000-01-01') as start_time
    FROM gn_imports.gn_imports_log
    WHERE table_name = 'gn_imports.v_qry_synthese_obs_occ'
        AND success = true
), data AS (
    SELECT e.* 
    FROM gn_imports.fdw_obs_occ_data e, last_import
    WHERE e.date_insert >= start_time OR e.date_last_update>=start_time
)
SELECT d.id_obs AS entity_source_pk_value,
    ds.id_dataset,
    d.unique_uuid AS unique_id_sinp,
    ref_nomenclatures.get_synonymes_nomenclature('METH_OBS'::character varying, d.determination) AS id_nomenclature_obs_meth,
    ref_nomenclatures.get_synonymes_nomenclature('ETA_BIO'::character varying, d.determination) AS id_nomenclature_bio_condition,
    ref_nomenclatures.get_synonymes_nomenclature('STATUT_VALID'::character varying, d.statut_validation) AS id_nomenclature_valid_status,
    ref_nomenclatures.get_synonymes_nomenclature('STADE_VIE'::character varying, d.type_effectif) AS id_nomenclature_life_stage,
    ref_nomenclatures.get_synonymes_nomenclature('SEXE'::character varying, d.phenologie) AS id_nomenclature_sex,
        CASE
            WHEN d.effectif_min > 0 THEN d.effectif_min
            ELSE COALESCE(d.effectif, d.effectif_max, 0::bigint)
        END AS count_min,
        CASE
            WHEN d.effectif_max > 0 THEN d.effectif_max
            ELSE COALESCE(d.effectif_min, d.effectif, 0::bigint)
        END AS count_max,
    tx.cd_nom,
    COALESCE(d.nom_complet, d.nom_vern) AS nom_cite,
    d.url_photo AS digital_proof,
    st_setsrid(d.geometrie, 4326) AS the_geom_4326,
    st_centroid(st_setsrid(d.geometrie, 4326)) AS the_geom_point,
    st_transform(st_setsrid(d.geometrie, 4326), 2154) AS the_geom_local,
    COALESCE(d.date_debut_obs, d.date_obs, '1900-01-01'::date) AS date_min,
    COALESCE(d.date_fin_obs, d.date_debut_obs, d.date_obs, '1900-01-01'::date) AS date_max,
    d.id_validateur AS id_validator,
    d.decision_validation AS validation_comment,
    d.observateur AS observers,
    NULL::text AS determiner,
    d.remarque_obs AS comments,
    NULL::text AS meta_validation_date,
    d.date_insert AS meta_create_date,
    d.date_last_update AS meta_update_date,
        CASE
            WHEN d.date_last_update IS NULL THEN 'I'::text
            ELSE 'U'::text
        END AS last_action,
    v.altitude_min AS altitude_min,
    v.altitude_max AS altitude_max,
    d.ids_observateur
   FROM data d
     JOIN gn_meta.t_datasets ds ON d.unique_dataset_id = ds.unique_dataset_id
     JOIN taxonomie.taxref tx ON d.cd_nom::integer = tx.cd_nom
    LEFT JOIN LATERAL ref_geo.fct_get_altitude_intersection(st_transform(st_setsrid(d.geometrie, 4326), 2154)) v(altitude_min, altitude_max) ON true
    
-- supression des données

CREATE MATERIALIZED VIEW gn_imports.v_qry_synthese_obs_occ_deleted AS 
WITH last_import AS (
    SELECT COALESCE(max(start_time), '1000-01-01') as start_time
    FROM gn_imports.gn_imports_log
    WHERE table_name = 'gn_imports.v_qry_synthese_obs_occ_deleted'
        AND success = true
)
SELECT e.* 
FROM gn_imports.fdw_obs_occ_deleted e, last_import
WHERE e.date_operation >= start_time;


 