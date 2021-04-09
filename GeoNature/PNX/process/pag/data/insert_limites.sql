DELETE FROM ref_geo.l_areas l 
USING ref_geo.bib_areas_types t
WHERE l.id_type=t.id_type AND t.type_code in ('ZC', 'AA', 'SEC', 'PEC');

-- ZC
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
	ST_MULTI(ST_UNION(geom)),
	ST_CENTROID(ST_UNION(geom)) AS centroid,
	ST_ASGEOJSON(ST_TRANSFORM(ST_UNION(geom), 4326)) AS geojson_4326,
	'Parc Amazonien de Guyanne' AS source,
	true AS enable
FROM ref_geo.tmp_coeur c
JOIN ref_geo.bib_areas_types t ON t.type_code='ZC'
WHERE c.secteur = 'Coeur de Parc'
GROUP BY id_type
;

-- AA
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
	'Parc Amazonien de Guyanne' AS source,
	true AS enable
FROM ref_geo.tmp_coeur c
JOIN ref_geo.bib_areas_types t ON t.type_code='AA'
WHERE c.secteur = 'Zone d''adhésion'
GROUP BY id_type
;

-- PEC
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
	'Périmètre d''étude' as area_name,
	'PEC' AS area_code,
	ST_MULTI(ST_UNION(geom)),
	ST_CENTROID(ST_UNION(geom)) AS centroid,
	ST_ASGEOJSON(ST_TRANSFORM(ST_UNION(geom), 4326)) AS geojson_4326,
	'Parc Amazonien de Guyanne' AS source,
	true AS enable
FROM ref_geo.tmp_coeur c
JOIN ref_geo.bib_areas_types t ON t.type_code='PEC'
GROUP BY id_type
;


-- Secteur
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
	c.nom as area_name,
	c.gid AS area_code,
	geom,
	ST_CENTROID(geom) AS centroid,
	ST_ASGEOJSON(ST_TRANSFORM(geom, 4326)) AS geojson_4326,
	'Parc Amazonien de Guyanne' AS source,
	true AS enable
FROM ref_geo.tmp_coeur c
JOIN ref_geo.bib_areas_types t ON t.type_code='SEC'
;
