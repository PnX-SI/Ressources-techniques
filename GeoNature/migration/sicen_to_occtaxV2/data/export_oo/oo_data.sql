CREATE OR REPLACE FUNCTION MY_TO_DATE( p_date_str CHARACTER VARYING, p_format_mask CHARACTER VARYING ) RETURNS DATE
IMMUTABLE
LANGUAGE plpgsql AS
$$
  DECLARE l_date DATE;
  DECLARE i_date_str CHARACTER VARYING;

BEGIN

SELECT INTO i_date_str UNACCENT(LOWER(p_date_str));
SELECT INTO i_date_str REPLACE(i_date_str, 'janvier', 'january');
SELECT INTO i_date_str REPLACE(i_date_str, 'fevrier', 'february');
SELECT INTO i_date_str REPLACE(i_date_str, 'mars', 'march');
SELECT INTO i_date_str REPLACE(i_date_str, 'avril', 'april');
SELECT INTO i_date_str REPLACE(i_date_str, 'mai', 'may');
SELECT INTO i_date_str REPLACE(i_date_str, 'juin', 'june');
SELECT INTO i_date_str REPLACE(i_date_str, 'juillet', 'july');
SELECT INTO i_date_str REPLACE(i_date_str, 'aout', 'august');
SELECT INTO i_date_str REPLACE(i_date_str, 'septembre', 'september');
SELECT INTO i_date_str REPLACE(i_date_str, 'novembre', 'november');
SELECT INTO i_date_str REPLACE(i_date_str, 'decembre', 'december');


  SELECT INTO l_date to_date( i_date_str, p_format_mask );
  RETURN l_date;
EXCEPTION
  WHEN others THEN
    RETURN null;
END;
$$;


-- saisie (avec les dates)

DROP TABLE IF EXISTS export_oo.saisie_observation;
CREATE TABLE export_oo.saisie_observation AS
WITH date_precomp AS (
SELECT 
	id_obs,
	date_obs,
	date_textuelle,

	CASE 
		WHEN date_debut_obs IS NOT NULL 
			THEN date_debut_obs
		WHEN date_textuelle LIKE '%été%'
			THEN (MY_TO_DATE(SUBSTRING(date_textuelle, '\d{4}'), 'YYYY') + interval '6 month')::DATE
		WHEN date_textuelle LIKE '%juillet aout%' 
			THEN (MY_TO_DATE(SUBSTRING(date_textuelle, '\d{4}'), 'YYYY') + interval '6 month')::DATE
		WHEN date_textuelle LIKE '%avril-mai%' 
			THEN (MY_TO_DATE(SUBSTRING(date_textuelle, '\d{4}'), 'YYYY') + interval '3 month')::DATE
		WHEN date_textuelle LIKE '%fin%' 
			THEN MY_TO_DATE(TRIM(SUBSTRING(date_textuelle, 4)), 'month YYYY') + interval '1 month' - interval '1 day'
		ELSE NULL
	END AS date_min,

	CASE 
		WHEN date_fin_obs IS NOT NULL 
			THEN date_fin_obs
		WHEN date_textuelle LIKE '%été%'
			THEN (MY_TO_DATE(SUBSTRING(date_textuelle, '\d{4}'), 'YYYY') + interval '8 month' - interval '1 day')::DATE
		WHEN date_textuelle LIKE '%juillet%aout%'
			THEN (MY_TO_DATE(SUBSTRING(date_textuelle, '\d{4}'), 'YYYY') + interval '8 month' - interval '1 day')::DATE
		WHEN date_textuelle LIKE '%avril-mai%' 
			THEN (MY_TO_DATE(SUBSTRING(date_textuelle, '\d{4}'), 'YYYY') + interval '8 month' - interval '1 day')::DATE

		ELSE NULL
	END AS date_max,

	CASE
		WHEN heure_obs IS NOT NULL
			THEN heure_obs
		WHEN date_textuelle LIKE '%de%à%'
			THEN TO_TIMESTAMP(SUBSTRING(REPLACE(date_textuelle, 'minuit', '0 h 00'), '(\d?\d h \d{2})'), 'HH24 h MI')::TIME
		ELSE NULL
	END AS hour_min,

	CASE 
		WHEN date_textuelle LIKE '%de%à%'
			THEN TO_TIMESTAMP(SUBSTRING(REPLACE(date_textuelle, 'minuit', '0 h 00'), '(\d?\d h \d{2})$'), 'HH24 h MI')::TIME
		ELSE NULL
	END AS hour_max,

	COALESCE(
		MY_TO_DATE(date_textuelle, 'YYYY'),
		MY_TO_DATE(LOWER(date_textuelle), 'TMmonth YYYY')
	) AS date_from_text
	
	FROM saisie.saisie_observation 

), date_comp AS (
	SELECT 
		id_obs,
		COALESCE(date_min, date_obs, date_from_text) AS date_min,
		CASE
            -- quand hour_min > hour_max : on passe au jour d'après 
			WHEN	hour_min IS NOT NULL 
				AND hour_max IS NOT NULL 
				AND hour_max < hour_min
				AND date_max IS NULL
				THEN (COALESCE(date_min, date_obs, date_from_text) + interval '1 day')::DATE
			ELSE COALESCE(date_max, date_min, date_obs, date_from_text)
		END AS date_max,
		COALESCE(hour_min, '00:00:00') AS hour_min,
		COALESCE(hour_max, hour_min, '00:00:00') AS hour_max,
		date_from_text,
		date_textuelle,
		date_obs

	FROM date_precomp

)
SELECT 

    s.id_obs,
    uuid_generate_v4() AS unique_id_sinp_occtax,
    cd_nom::integer,
	nom_complet,
    geometrie,
    date_min,
    date_max,
    hour_min,
    hour_max,
	CASE WHEN elevation::int >= 0 THEN elevation::int ELSE NULL END AS altitude,
	CASE WHEN elevation::int < 0 THEN elevation::int ELSE NULL END AS depth,
	id_etude,
	id_protocole,
	remarque_obs,
	precision::text,
	determination::text,
	phenologie::text,
	url_photo,
	comportement,
	type_effectif,
	effectif_min,
	effectif_max

FROM saisie.saisie_observation s
JOIN date_comp d
    ON d.id_obs = s.id_obs
WHERE regne != 'Habitat'
AND NOT ST_GeometryType(geometrie) = 'ST_GeometryCollection' -- 'patch cev ?
LIMIT 10

;


-- -- utilisateurs

-- DROP TABLE IF EXISTS export_oo.personne;
-- CREATE TABLE export_oo.personne AS
-- SELECT * FROM md.personne
-- ;

-- -- organismes

-- DROP TABLE IF EXISTS export_oo.structure;
-- CREATE TABLE export_oo.structure AS
-- SELECT * FROM md.structure
-- ;

-- -- etudes

-- DROP TABLE IF EXISTS export_oo.etude;
-- CREATE TABLE export_oo.etude AS
-- SELECT * FROM md.etude
-- ;

-- -- protocoles

-- DROP TABLE IF EXISTS export_oo.protocole;
-- CREATE TABLE export_oo.protocole AS
-- SELECT * FROM md.protocole
-- ;

