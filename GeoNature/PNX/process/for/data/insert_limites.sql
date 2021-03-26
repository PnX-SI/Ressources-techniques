DELETE FROM ref_geo.l_areas l 
USING ref_geo.bib_areas_types t
WHERE l.id_type=t.id_type AND t.type_code in ('ZC', 'AA', 'PEC', 'RI');

-- bib_areas_type ajout Réserve intégrale
DELETE FROM ref_geo.bib_areas_types WHERE type_code = 'RI';

INSERT INTO ref_geo.bib_areas_types(
    type_name,
    type_code,
    type_desc
)
VALUES (
    'Réserve intégrale',
    'RI',
    'Réserve intégrale'
)
ON CONFLICT DO NOTHING;


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


-- RI
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
	'Réserve intégrale' as area_name,
	'RI' AS area_code,
	geom, 
	ST_CENTROID(geom) AS centroid,
	ST_ASGEOJSON(ST_TRANSFORM(geom, 4326)) AS geojson_4326,
	'Parc National des Forêts' AS source,
	true AS enable
FROM ref_geo.tmp_ri c
JOIN ref_geo.bib_areas_types t ON t.type_code='RI'
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
	ST_MULTI(ST_UNION(geom)), 
	ST_CENTROID(ST_UNION(geom)) AS centroid,
	ST_ASGEOJSON(ST_TRANSFORM(ST_UNION(geom), 4326)) AS geojson_4326,
	'Parc National des Forêts' AS source,
	true AS enable
FROM ref_geo.l_areas l
JOIN ref_geo.bib_areas_types t ON t.type_code='PEC'
JOIN ref_geo.bib_areas_types t2 ON t2.type_code='COM' AND l.id_type = t2.id_type
GROUP BY t.id_type
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
	ST_MULTI(ST_UNION(geom)), 
	ST_CENTROID(ST_UNION(geom)) AS centroid,
	ST_ASGEOJSON(ST_TRANSFORM(ST_UNION(geom), 4326)) AS geojson_4326,
	'Parc National des Forêts' AS source,
	true AS enable
FROM ref_geo.l_areas l
JOIN ref_geo.bib_areas_types t ON t.type_code='PEC'
JOIN ref_geo.bib_areas_types t2 ON t2.type_code='COM' AND l.id_type = t2.id_type
GROUP BY t.id_type
;

