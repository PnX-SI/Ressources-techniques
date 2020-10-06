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
), geom AS (
	SELECT 
		id_obs,
		ST_MAKEVALID(geometrie) AS geometrie
		FROM saisie.saisie_observation
)


SELECT 
	COUNT(*),
	d.date_hour,
	g.geometrie,
	ARRAY_AGG(o.id_obs) AS ids_obs,
	ob.observers,
	numerisateur,
	-- id_nomenclature_tech_collect_campanule 'TECHNIQUE_OBS'
	-- id_nomenclature_grp_typ TYP_GRP
	-- place_name id_lieu_dit
	-- date_minmax
	-- hour minmax
	STRING_AGG(o.remarque_obs, ', '), --comment
	precision,
	uuid_generate_v4() AS unique_id_sinp_grp,
	'end'
	
	FROM saisie.saisie_observation o
	
	JOIN d_date_hour d
		ON d.id_obs = o.id_obs
	JOIN observers ob
		ON ob.id_obs = o.id_obs
	JOIN geom g
		ON g.id_obs = o.id_obs


GROUP BY d.date_hour,
	g.geometrie,
	ob.observers,
	numerisateur,
	precision
	
ORDER BY COUNT(*) DESC;


DROP TABLE IF EXISTS export_oo.t_occurences_occtax CASCADE;
CREATE TABLE export_oo.t_occurences_occtax AS 

SELECT
	uuid_generate_v4() AS unique_id_occurence_occtax,
	r.unique_id_sinp_grp,
	o.cd_nom,
	ARRAY_AGG(o.id_obs) AS ids_obs,

	COUNT(*)
	
	FROM saisie.saisie_observation o
 	JOIN export_oo.t_releves_occtax r
 		ON o.id_obs =  ANY(r.ids_obs)
 	GROUP BY cd_nom, r.unique_id_sinp_grp
 	ORDER BY COUNT(*) DESC
;

SELECT * FROM export_oo.t_releves_occtax
LIMIT 100;

 SELECT *
 FROM saisie.saisie_observation o
 WHERE id_obs = ANY('{5319,5318}'::int[])
LIMIT 10;

SELECT * FROM export_oo.t_occurences_occtax
LIMIT 100;