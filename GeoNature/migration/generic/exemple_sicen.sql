
DROP TABLE IF EXISTS import_synthese.obs_occ_data;
CREATE TABLE import_synthese.obs_occ_data AS
WITH id_source AS (
    SELECT id_source FROM gn_synthese.t_sources WHERE name_source='obs_occ'
)
SELECT 
	(SELECT id_source FROM id_source) AS id_source, 
	id_obs::varchar AS entity_source_pk_value, 
	ds.id_dataset,  
	COALESCE(ref_nomenclatures.get_synonymes_nomenclature('METH_OBS', determination), gn_synthese.get_default_nomenclature_value('METH_OBS')) AS id_nomenclature_obs_meth, 

	COALESCE(ref_nomenclatures.get_synonymes_nomenclature('ETA_BIO', determination), gn_synthese.get_default_nomenclature_value('ETA_BIO')) AS id_nomenclature_bio_condition, 

	COALESCE(ref_nomenclatures.get_synonymes_nomenclature('STATUT_VALID', statut_validation) , gn_synthese.get_default_nomenclature_value('STATUT_VALID')) AS id_nomenclature_valid_status, 

	COALESCE(ref_nomenclatures.get_synonymes_nomenclature('STADE_VIE', type_effectif), gn_synthese.get_default_nomenclature_value('STADE_VIE')) AS id_nomenclature_life_stage, 
	COALESCE(ref_nomenclatures.get_synonymes_nomenclature('SEXE', phenologie), gn_synthese.get_default_nomenclature_value('SEXE')) AS id_nomenclature_sex, 


	CASE WHEN effectif_min > 0 THEN effectif_min ELSE Coalesce(effectif, effectif_max, 0) END AS count_min,
	CASE WHEN effectif_max > 0 THEN effectif_max ELSE Coalesce(effectif_min, effectif, 0) END AS count_max,

	tx.cd_nom::int, 
	COALESCE(d.nom_complet, d.nom_vern) AS nom_cite, 
	'Taxref V11'::varchar(50) AS  meta_v_taxref,
	url_photo AS digital_proof, 
	st_transform(st_setsrid(geometrie, 2154), 4326) AS the_geom_4326, 
	st_transform(st_centroid(st_setsrid(geometrie, 2154)), 4326)  AS the_geom_point, 
	st_transform(st_setsrid(geometrie, 2154), 2154) AS the_geom_local, 

	COALESCE(date_debut_obs, date_obs, '1900-01-01'::date) AS date_min,
	COALESCE(date_fin_obs, date_debut_obs, date_obs,  '1900-01-01'::date) AS  date_max,

	id_validateur AS id_validator, decision_validation AS validation_comment, 
	observateur AS observers,
	remarque_obs AS comments, date_insert AS  meta_create_date, date_last_update AS meta_update_date, 
	CASE
		WHEN date_last_update IS NULL THEN 'I'
		ELSE 'U'
	END AS last_action,
  ids_observateur AS id_observers
  FROM import_obs_occ.fdw_obs_occ_data d
  JOIN import_obs_occ.protocole p ON d.id_protocole = p.id_protocole
  JOIN gn_meta.t_datasets ds ON p.unique_dataset_id = ds.unique_dataset_id
  JOIN taxonomie.taxref tx ON d.cd_nom::int = tx.cd_nom;


CREATE INDEX i_obs_occ_data_ids
  ON import_synthese.obs_occ_data
  USING btree
  (id_source, entity_source_pk_value COLLATE pg_catalog."default");
