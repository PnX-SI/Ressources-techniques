-- Ajout de 2 colonnes de géométries à la table serenabase.rnf_obse -> 1 pour stocker la geom de l'obse et l'autre celle du site :

ALTER TABLE serenabase.rnf_obse ADD COLUMN geom_obse geometry;
ALTER TABLE serenabase.rnf_obse ADD COLUMN geom_site geometry;

-- Calcul des géométries dans cette colonne pour les observations déjà dans rnf_obse :
-- Quand on a une geometrie reelle dans la colonne obse_car
-- On éxécute d'abord une requête permettant d'identifier somairement les différents système de coordonnées utilisés dans Serena afin d'adapter la requête suivante
SELECT DISTINCT split_part(obse_car::text, ' '::text, 1) as scr, 
				(string_to_array(obse_car, ' ')::text[])[array_upper(string_to_array(obse_car, ' '), 1)] as proj,
				count(obse_id) as nb_obs
	FROM serenabase.rnf_obse
	GROUP BY split_part(obse_car::text, ' '::text, 1), (string_to_array(obse_car, ' ')::text[])[array_upper(string_to_array(obse_car, ' '), 1)]
	ORDER BY nb_obs DESC
	;
-- On adapte la requête suivante selon les résultats de la requête précédente 
UPDATE serenabase.rnf_obse
	SET geom_obse = (CASE
			WHEN obse_car LIKE 'L93F%RGF93'
			THEN  ST_SetSRID(ST_Point(replace(split_part(obse_car::text, ' '::text, 2),',','.')::REAL * 1000, (replace(split_part(obse_car::text, ' '::text, 3),',','.')::REAL * 1000)), 2154)
			WHEN obse_car LIKE 'LIIEF%NTF'
			THEN  ST_transform(ST_SetSRID(ST_Point(replace(split_part(obse_car::text, ' '::text, 2),',','.')::REAL * 1000, (replace(split_part(obse_car::text, ' '::text, 3),',','.')::REAL * 1000)), 27572), 2154)
			WHEN obse_car LIKE 'UTM%31T%WGS84'
			THEN  ST_transform(ST_SetSRID(ST_Point(replace(split_part(obse_car::text, ' '::text, 3),',','.')::REAL * 1000, (replace(split_part(obse_car::text, ' '::text, 4),',','.')::REAL * 1000)), 32631), 2154)
			/*WHEN obse_car LIKE 'LATLON%' 
			THEN  ST_transform(ST_SetSRID(ST_Point(replace(split_part(obse_car::text, ' '::text, 2),',','.')::REAL, (replace(split_part(obse_car::text, ' '::text, 3),',','.')::REAL)), 4326), 2154)*/
			END)
	WHERE obse_car IS NOT NULL AND obse_car <>''
	;

-- Quand on a des coordonnées dans les colonnes obse_lat et obse_lon (+obse_dum)

UPDATE serenabase.rnf_obse
	SET geom_obse= ST_transform(ST_SetSRID(ST_Point(replace(substring(obse_lon,3,10),',','.')::REAL, replace(substring(obse_lat,3,10),',','.')::REAL),4326), 2154)::geometry(POINT,2154)
	WHERE (obse_car IS NULL OR obse_car LIKE '')
	AND ((obse_lat IS NOT NULL AND obse_lat <> '') AND (obse_lon IS NOT NULL AND obse_lon <> ''))
	;

-- A partir de la géométrie du site lié à l'observation

		-- TESTS :
		SELECT DISTINCT o.obse_id, og.ogll_nom, og.ogll_lon, og.ogll_lat, s.site_lon, s.site_lat, s.site_car, s.site_nom, sg.sgll_nom, sg.sgll_lon, sg.sgll_lat, obse_lon,obse_lat,obse_dum,obse_car,obse_alt,obse_sig_obj_id,obse_waypoint, v.*
		--SELECT DISTINCT obse_site_id, s.*
			FROM serenabase.rnf_obse o
			JOIN serenabase.vm_obs_serena_detail v ON o.obse_id = v.obse_id
			JOIN serenabase.tmp_ogll og ON og.ogll_obse_id = o.obse_id
			JOIN serenabase.rnf_site s ON o.obse_site_id = s.site_id
			JOIN serenabase.tmp_sgll sg ON sg.sgll_site_id = s.site_id
			WHERE o.geom_obse IS NULL
			--AND site_lon IS NULL

-- on va chercher la geometrie portee par le site
UPDATE serenabase.rnf_obse o
	SET geom_site= ST_transform(ST_SetSRID(ST_Point(replace(substring(s.site_lon,3,10),',','.')::REAL, replace(substring(s.site_lat,3,10),',','.')::REAL),4326), 2154)::geometry(POINT,2154)
	FROM serenabase.rnf_site s
	WHERE o.obse_site_id = s.site_id
	AND (o.obse_car IS NULL OR o.obse_car LIKE '')
	AND ((o.obse_lat IS NULL OR o.obse_lat LIKE '') AND (o.obse_lon IS NULL OR o.obse_lon LIKE ''))
	;

-- On identifie les observations dépourvues de géométries (site ET/OU obs) pour identifier le soucis (rattachement à la commune ??)
-- Vérifier si les géométries sont manquantes aussi dans un export réalisé depuis l'interface de Serena ou identifier les géométrie rattachées sur cette sélection observations 
SELECT DISTINCT o.obse_id, o.obse_site_id, o.obse_date, u.srce_compnom_c, o.obse_place, s.site_nom, l.choi_nom, s.site_lon, s.site_lat, s.site_car, o.obse_lon, o.obse_lat, o.obse_car, og.ogll_lon, og.ogll_lat, sg.sgll_lon, sg.sgll_lat
	FROM serenabase.rnf_obse o
	JOIN serenabase.rnf_srce u on o.obse_obsv_id = u.srce_id
	LEFT JOIN serenabase.rnf_choi l on o.obse_methloc_choi_id = l.choi_id
	JOIN serenabase.rnf_site s on o.obse_site_id = s.site_id
	JOIN serenabase.tmp_ogll og ON og.ogll_obse_id = o.obse_id
	JOIN serenabase.tmp_sgll sg ON sg.sgll_site_id = s.site_id
	WHERE o.geom_obse IS NULL AND o.geom_site IS NULL
	/*WHERE (o.obse_car IS NULL OR o.obse_car LIKE '')
	AND ((o.obse_lat IS NULL OR o.obse_lat LIKE '') AND (o.obse_lon IS NULL OR o.obse_lon LIKE ''))
	AND ((s.site_lat IS NULL OR s.site_lat LIKE '') AND (s.site_lon IS NULL OR s.site_lon LIKE ''))*/
	ORDER BY s.site_nom
	;

-- TO DO :
-- Si Serena reste une source de données vivantes, il faudra créer une fonction + trigger pour peupler les colonnes geom après chaque INSERT ou UPDATE dans Serena
-- /!\ A TESTER


