-- brouillon pour stoquer les test sur les geometrie
-- ST_MAKEVALID suffit ??


-- corrige les geometries non valides

UPDATE saisie.saisie_observation so 
	SET geometrie = correct.geometrie
	FROM ( SELECT 
		id_obs, ST_MAKEVALID(geometrie) AS geometrie
		FROM saisie.saisie_observation
		WHERE NOT ST_ISVALID(geometrie)
	)correct
WHERE correct.id_obs = so.id_obs
;

-- teste s il reste des geometries invalides

SELECT 
	COUNT(*)
	FROM saisie.saisie_observation
	WHERE NOT ST_ISVALID(geometrie);


