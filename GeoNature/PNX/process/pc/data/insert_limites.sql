DELETE FROM ref_geo.l_areas l 
USING ref_geo.bib_areas_types t
WHERE l.id_type=t.id_type AND t.type_code in ('SEC', 'ZC', 'AA', 'AMA', 'PEC');



-- coeur = UNION(1, 2, 3)

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
	ST_UNION(geom), 
	ST_CENTROID(ST_UNION(geom)) AS centroid,
	ST_ASGEOJSON(ST_TRANSFORM(ST_UNION(geom), 4326)) AS geojson_4326,
	'Port Cros' AS source,
	true AS enable
FROM ref_geo.tmp_limites c
JOIN ref_geo.bib_areas_types t ON t.type_code='ZC'
WHERE gid IN (1, 2, 3, 15)
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
	ST_UNION(geom), 
	ST_CENTROID(ST_UNION(geom)) AS centroid,
	ST_ASGEOJSON(ST_TRANSFORM(ST_UNION(geom), 4326)) AS geojson_4326,
	'Port Cros' AS source,
	true AS enable
FROM ref_geo.tmp_limites c
JOIN ref_geo.bib_areas_types t ON t.type_code='AA'
WHERE gid >= 4 AND gid <= 14
GROUP BY id_type;


-- AMA
DELETE FROM ref_geo.bib_areas_types WHERE type_code='AMA';
INSERT INTO ref_geo.bib_areas_types(type_name, type_code, type_desc)
VALUES('Aire maritime adjacente', 'AMA', 'Aire maritime adjacente')
ON CONFLICT DO NOTHING;

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
	'Aire maritime adjacente' as area_name,
	'AMA' AS area_code,
	ST_MULTI(ST_CollectionExtract(ST_MAKEVALID(geom), 3)), 
	ST_CENTROID(geom) AS centroid,
	ST_ASGEOJSON(ST_TRANSFORM(geom, 4326)) AS geojson_4326,
	'Port Cros' AS source,
	true AS enable
FROM ref_geo.tmp_limites c
JOIN ref_geo.bib_areas_types t ON t.type_code='AMA'
WHERE gid = 16;


-- PEC (pour l'atlas)
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
	ST_UNION(geom), 
	ST_CENTROID(ST_UNION(geom)) AS centroid,
	ST_ASGEOJSON(ST_TRANSFORM(ST_UNION(geom), 4326)) AS geojson_4326,
	'Port Cros' AS source,
	true AS enable
FROM ref_geo.tmp_limites c
JOIN ref_geo.bib_areas_types t ON t.type_code='PEC'
GROUP BY id_type;
;