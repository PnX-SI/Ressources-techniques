DELETE FROM ref_geo.l_areas l USING ref_geo.bib_areas_types t 
WHERE t.type_code=:'type_code' AND l.id_type = t.id_type;

INSERT INTO ref_geo.l_areas (
id_type,
area_name,
area_code,
geom,
centroid,
geojson_4326,
source,
enable
)

SELECT 
	t.id_type,
	code_:taille_maille AS area_name,
	cd_sig AS area_code,
	geom,
	ST_CENTROID(geom) AS centroid,
	ST_ASGEOJSON(ST_TRANSFORM(geom, 4326)) AS geojson_4326,
	'https://inpn.mnhn.fr/telechargement/cartes-et-information-geographique/ref/referentiels' AS source,
	TRUE AS enable
FROM :table d
JOIN ref_geo.bib_areas_types t
	ON t.type_code = :'type_code'
;

INSERT INTO ref_geo.li_grids(id_grid, id_area, cxmin, cxmax, cymin, cymax)
SELECT l.area_code AS id_grid, l.id_area AS id_area, ROUND(ST_XMin(geom))AS cxmin, ST_XMax(geom) AS cxmax, ROUND(ST_YMIN(geom)) AScymin, ROUND(ST_YMAX(geom)) AS cymax
	FROM ref_geo.l_areas l
	JOIN ref_geo.bib_areas_types t
			ON t.id_type = l.id_type
	WHERE t.type_code = :'type_code'
;