
DROP TABLE IF EXISTS export_oo.t_counting_occtax CASCADE;
CREATE TABLE export_oo.t_counting_occtax AS 

SELECT 
	o.id_obs,
	uuid_generate_v4() AS unique_id_sinp_occtax,
	oo.unique_id_occurence_occtax,
	COALESCE(
		export_oo.get_synonyme_id_nomenclature('STADE_VIE', type_effectif::text),
		export_oo.get_synonyme_id_nomenclature('STADE_VIE', phenologie::text),
		ref_nomenclatures.get_id_nomenclature('STADE_VIE', '1') -- (Inconnu) ?? ou '2' Indéterminé
	) AS id_nomenclature_life_stage, -- STADE_VIE

	COALESCE(
		export_oo.get_synonyme_id_nomenclature('SEXE', phenologie::text),
		ref_nomenclatures.get_id_nomenclature('SEXE', '0') -- (Inconnu) ?? ou '1' (Non renseigné) 
	) AS id_nomenclature_sex

	COALESCE(
		export_oo.get_synonyme_id_nomenclature('OBJ_DENBR', phenologie::text),
		export_oo.get_synonyme_id_nomenclature('OBJ_DENBR', type_effectif::text)
		ref_nomenclatures.get_id_nomenclature('OBJ_DENBR', 'NSP') -- (Ne sais pas) 
	) AS id_nomenclature_obj_count, -- OBJ_DENBR

	ref_nomenclatures.get_id_nomenclature('TYP_DENBR', 'NSP') AS id_nomenclature_typ_count-- (Ne sais pas) 
	
	

	FROM saisie.saisie_observation o

	JOIN export_oo.t_occurrences_occtax oo
		ON o.id_obs =  ANY(oo.ids_obs)
;