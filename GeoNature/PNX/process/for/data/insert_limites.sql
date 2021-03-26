DELETE FROM ref_geo.l_areas l 
USING ref_geo.bib_areas_types t
WHERE l.id_type=t.id_type AND t.type_code in ('ZC', 'AA', 'PEC');


-- Zone Coeur

INSERT INTO ref_geo.l_areas(
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
	'Zone coeur' as area_name,
	'ZC' AS area_code,
	geom, 
	ST_CENTROID(geom) AS centroid,
	ST_ASGEOJSON(ST_TRANSFORM(geom, 4326)) AS geojson_4326,
	'Parc National des Forêts' AS source,
	true AS enable
FROM ref_geo.tmp_coeur c
JOIN ref_geo.bib_areas_types t ON t.type_code='ZC'
;


-- AA ?? Union communes
--PEC ?? 
INSERT INTO ref_geo.l_areas(
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
	'Périmètre d''étude de la charte' as area_name,
	'PEC' AS area_code,
	geom, 
	ST_CENTROID(geom) AS centroid,
	ST_ASGEOJSON(ST_TRANSFORM(geom, 4326)) AS geojson_4326,
	'Parc National des Forêts' AS source,
	true AS enable
FROM ref_geo.tmp_ri c
JOIN ref_geo.bib_areas_types t ON t.type_code='PEC'
;


INSERT INTO ref_geo.l_areas(
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
	'Aire d''adhésion' as area_name,
	'AA' AS area_code,
	geom, 
	ST_CENTROID(geom) AS centroid,
	ST_ASGEOJSON(ST_TRANSFORM(geom, 4326)) AS geojson_4326,
	'Parc National des Forêts' AS source,
	true AS enable
FROM ref_geo.tmp_ri c
JOIN ref_geo.bib_areas_types t ON t.type_code='AA'
;
