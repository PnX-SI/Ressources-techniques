DROP TABLE IF EXISTS export_oo.t_occurrences_occtax CASCADE;
CREATE TABLE export_oo.t_occurrences_occtax AS 

SELECT
	uuid_generate_v4() AS unique_id_occurence_occtax,
	r.unique_id_sinp_grp,
	ARRAY_AGG(o.id_obs) AS ids_obs,
	export_oo.get_synonyme_cd_nomenclature('METH_OBS', determination::text) AS cd_nomenclature_obs_technique, -- METH_OBS
	COALESCE (
		export_oo.get_synonyme_cd_nomenclature('ETA_BIO', determination::text),
		export_oo.get_synonyme_cd_nomenclature('ETA_BIO', phenologie::text)
	) AS cd_nomenclature_bio_condition, -- ETA_BIO
	
	'1' AS cd_nomenclature_bio_status, -- STATUT_BIO (non renseigné)
	'0' AS cd_nomenclature_naturalness, -- NATURALITE (Inconnu)

	CASE 
		WHEN LENGTH(STRING_AGG(o.url_photo, '')) > 0 THEN '1' -- PREUVE_EXIST (Oui)
		ELSE '0'  -- PREUVE_EXIST (Inconnu)
	END AS cd_nomenclature_exist_proof, --PREUVE_EXIST

--	'0' AS cd_nomenclature_diffusion_level -- NIV_PRECIS (à mettre en lien avec precision??)

	'Pr' AS cd_nomenclature_observation_status, -- STATUS_OBS

	'NON' AS cd_nomenclature_blurring, -- DEE_FLOU

	-- id_nomenclature_source_status STATUT_SOURCE (Depuis le JDD redondance)

	export_oo.get_synonyme_cd_nomenclature('OCC_COMPORTEMENT', SUBSTRING(comportement::text, 1, 2)) AS cd_nomenclature_behaviour, -- OCC_COMPORTEMENT
	comportement,
	
	-- determiner TXT

	'1' AS cd_nomenclature_determination_method, -- METH_DETERMIN

	o.cd_nom::int,
    
	nom_complet AS nom_cite, --???, depuis le cd_nom.

        
        -- digital_proof text ????,
        -- non_digital_proof text ????,
        STRING_AGG(DISTINCT o.remarque_obs, ', ') AS comment,
        
	COUNT(*)
	
	FROM saisie.saisie_observation o
 	JOIN export_oo.t_releves_occtax r
 		ON o.id_obs =  ANY(r.ids_obs)
 	WHERE NOT cd_nom LIKE '%.%'-- pn_pyr ???
 	GROUP BY cd_nom, r.unique_id_sinp_grp, nom_complet, determination, phenologie, comportement
 	ORDER BY COUNT(*) DESC
;
