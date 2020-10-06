DROP TABLE IF EXISTS export_oo.t_releves_occtax CASCADE;
CREATE TABLE export_oo.t_releves_occtax AS 
WITH d_date_hour AS (
	SELECT 
		id_obs,
		CASE 
			WHEN heure_obs IS NOT NULL THEN TRIM(CONCAT(date_obs, ' ', heure_obs))
			ELSE CONCAT(date_obs, ' 00:00:00')
		END AS date_hour
	FROM saisie.saisie_observation
), observers AS (
	SELECT 
		id_obs,
		REGEXP_SPLIT_TO_ARRAY(observateur, '&') AS observers
		FROM saisie.saisie_observation
)


SELECT 
	COUNT(*),
	d.date_hour,
	o.geometrie,
	ARRAY_AGG(o.id_obs) AS ids_obs,
	ob.observers,
	numerisateur,
	-- id_nomenclature_tech_collect_campanule 'TECHNIQUE_OBS'
	-- id_nomenclature_grp_typ TYP_GRP
	-- place_name id_lieu_dit
	-- date_minmax
	-- hour minmax
	STRING_AGG(DISTINCT o.remarque_obs, ', '), --comment
	precision,
	uuid_generate_v4() AS unique_id_sinp_grp,
	'end'
	
	FROM saisie.saisie_observation o
	
	JOIN d_date_hour d
		ON d.id_obs = o.id_obs
	JOIN observers ob
		ON ob.id_obs = o.id_obs
	
GROUP BY d.date_hour,
	o.geometrie,
	ob.observers,
	numerisateur,
	precision
	
ORDER BY COUNT(*) DESC;


DROP TABLE IF EXISTS export_oo.t_occurences_occtax CASCADE;
CREATE TABLE export_oo.t_occurences_occtax AS 

SELECT
	uuid_generate_v4() AS unique_id_occurence_occtax,
	r.unique_id_sinp_grp,
	ARRAY_AGG(o.id_obs) AS ids_obs,
	export_oo.get_synonyme_cd_nomenclature('METH_OBS', determination::text) AS cd_nomenclature_obs_technique, -- METH OBS
	COALESCE (
		export_oo.get_synonyme_cd_nomenclature('ETA_BIO', determination::text),
		export_oo.get_synonyme_cd_nomenclature('ETA_BIO', phenologie::text)
	) AS cd_nomenclature_bio_scondition, -- ETA_BIO
	
	'1' AS cd_nomenclature_bio_status, -- STATUT_BIO (non renseigné)
	'0' AS cd_nomenclature_naturalness, -- NATURALITE (Inconnu)

	CASE 
		WHEN LENGTH(STRING_AGG(o.url_photo, '')) > 0 THEN '1' -- PREUVE_EXIST (Oui)
		ELSE '0'  -- PREUVE_EXIST (Inconnu)
	END AS cd_nomenclature_exist_proof, --PREUVE EXIST

--	'0' AS cd_nomenclature_diffusion_level -- NIV_PRECIS (à mettre en lien avec precision??)

	'Pr' AS cd_nomenclature_observation_status, -- STATUS_OBS

	'NON' AS cd_nomenclature_blurring, -- DEE_FLOU

	-- id_nomenclature_source_status STATUT_SOURCE (Depuis le JDD redondance)

	export_oo.get_synonyme_cd_nomenclature('OCC_COMPORTEMENT', SUBSTRING(comportement::text, 1, 2)) AS cd_nomenclature_behaviour, -- OCC_COMPORTEMENT
	comportement,
	
	-- determiner TXT

	-- id_nomenclature_determination_method
	'1' AS cd_nomenclature_determination_method, -- OCC_COMPORTEMENT

	o.cd_nom::int,
	
	-- nom_complet AS nom_cite, depuis le cd_nom.

        -- meta_v_taxref ?????
        
        -- digital_proof text ????,
        -- non_digital_proof text ????,
        STRING_AGG(DISTINCT o.remarque_obs, ', ') AS comment,
        
	COUNT(*)
	
	FROM saisie.saisie_observation o
 	JOIN export_oo.t_releves_occtax r
 		ON o.id_obs =  ANY(r.ids_obs)
 	GROUP BY cd_nom, r.unique_id_sinp_grp, nom_complet, determination, phenologie, comportement
 	ORDER BY COUNT(*) DESC
;


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

	JOIN export_oo.t_occurences_occtax oo
		ON o.id_obs =  ANY(oo.ids_obs)
;

SELECT COUNT(*) 
	FROM export_oo.t_counting_occtax
	WHERE cd_nomenclature_obj_count IS NOT NULL
	LIMIT 10;
