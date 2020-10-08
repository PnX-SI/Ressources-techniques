
DROP TABLE IF EXISTS export_oo.t_counting_occtax CASCADE;
CREATE TABLE export_oo.t_counting_occtax AS 

SELECT 
	o.id_obs,
	uuid_generate_v4() AS unique_id_sinp_occtax,
	oo.unique_id_occurence_occtax,
	COALESCE(
		export_oo.get_synonyme_cd_nomenclature('STADE_VIE', type_effectif::text),
		export_oo.get_synonyme_cd_nomenclature('STADE_VIE', phenologie::text)
	) AS cd_nomenclature_life_stage, -- STADE_VIE
	
	export_oo.get_synonyme_cd_nomenclature('SEXE', phenologie::text) AS cd_nomenclature_sex, -- ??? inconnu ou indeterminé ??

	COALESCE(
		export_oo.get_synonyme_cd_nomenclature('OBJ_DENBR', phenologie::text),
		export_oo.get_synonyme_cd_nomenclature('OBJ_DENBR', type_effectif::text)
	) AS cd_nomenclature_obj_count, -- OBJ_DENBR

	'NSP' AS cd_nomenclature_typ_count,
	
	'end'

	

	FROM saisie.saisie_observation o

	JOIN export_oo.t_occurrences_occtax oo
		ON o.id_obs =  ANY(oo.ids_obs)
;