WITH data_validation AS (
	SELECT
		COALESCE(r.id_role, 1) AS id_validator, -- administratreur defautl
		co.id_obs,
		COALESCE(statut_validation::text, 'auto = default value') AS validation_comment,
		COALESCE(
			export_oo.get_synonyme_id_nomenclature('STATUT_VALID', statut_validation),
			ref_nomenclatures.get_id_nomenclature('STATUT_VALID', '0')
		) AS id_nomenclature_valid_status,
		statut_validation IS NULL as validation_auto,
		co.unique_id_sinp_occtax AS uuid_attached_row

	FROM export_oo.v_counting_occtax co
	JOIN export_oo.v_saisie_observation_cd_nom_valid s
		ON s.id_obs = co.id_obs
        LEFT JOIN utilisateurs.t_roles r
		ON (r.champs_addi->>'id_personne')::int = s.validateur
)
UPDATE gn_commons.t_validations v
	SET 
	id_nomenclature_valid_status= d.id_nomenclature_valid_status,
	validation_auto = d.validation_auto,
	validation_comment = d.validation_comment,
	id_validator = d.id_validator
-- INSERT INTO gn_commons.t_validations (
-- 	id_nomenclature_valid_status,
-- 	validation_auto,
-- 	validation_comment,
-- 	id_validator
-- 	)
-- 	SELECT id_nomenclature_valid_status,
-- 	validation_auto,
-- 	validation_comment,
-- 	id_validator

 	FROM data_validation d
 	WHERE v.uuid_attached_row = d.uuid_attached_row