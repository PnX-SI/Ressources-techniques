--DELETE FROM gn_synthese.cor_area_synthese m;
--DELETE FROM gn_synthese.cor_area_taxon;


DELETE FROM ref_geo.l_areas l 
USING ref_geo.bib_areas_types t
WHERE l.id_type=t.id_type AND t.type_code in ('SEC', 'ZC', 'AA', 'AMA', 'PEC');


-- secteurs

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
	nom as area_name,
	nom AS area_code,
	geom, 
	ST_CENTROID(geom) AS centroid,
	ST_ASGEOJSON(ST_TRANSFORM(geom, 4326)) AS geojson_4326,
	'https://www.karugeo.fr/geonetwork/srv/fre/catalog.search#/metadata/babf55ac-9dda-47a0-8018-f889a0bd1107' AS source,
	true AS enable
FROM ref_geo.tmp_coeur c
JOIN ref_geo.bib_areas_types t ON t.type_code='SEC';


-- coeur = UNION(secteurs)

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
	'https://www.karugeo.fr/geonetwork/srv/fre/catalog.search#/metadata/babf55ac-9dda-47a0-8018-f889a0bd1107' AS source,
	true AS enable
FROM ref_geo.tmp_coeur c
JOIN ref_geo.bib_areas_types t ON t.type_code='ZC'
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
	geom, 
	ST_CENTROID(geom) AS centroid,
	ST_ASGEOJSON(ST_TRANSFORM(geom, 4326)) AS geojson_4326,
	'https://www.karugeo.fr/geonetwork/srv/fre/catalog.search#/metadata/57c1c459-27b0-4b10-9286-9f327650624a' AS source,
	true AS enable
FROM ref_geo.tmp_aa c
JOIN ref_geo.bib_areas_types t ON t.type_code='AA';


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
	'https://www.karugeo.fr/geonetwork/srv/fre/catalog.search#/metadata/87102e7d-d85b-4dca-8d6d-a93ad8798b4c' AS source,
	true AS enable
FROM ref_geo.tmp_ama c
JOIN ref_geo.bib_areas_types t ON t.type_code='AMA'
WHERE c.nom = 'Aire maritime adjacente';


-- PEC (pour l'atlas)
-- ici union des M10

--select * from ref_geo.l_areas la limit 1
--select * from ref_geo.bib_areas_types bat2 

-- insert into ref_geo.l_areas(id_type, area_name, area_code, geom, centroid, geojson_4326, source, comment, enable)
-- select 
-- 	bat2.id_type,
-- 	'Plan d''etude de la charte' as area_name,
-- 	'PEC' as area_code, 
-- 	st_multi(st_union(la.geom)) as geom,
-- 	st_centroid(st_union(la.geom)) as centroid,
-- 	st_asgeojson(st_transform(st_union(la.geom), 4326)) as geojson_4326,
-- 	'M10' as source,
-- 	'Crée par union des M10 (pour l''atlas)' as comment,
-- 	true as enabled
-- 	from ref_geo.l_areas la
-- join ref_geo.bib_areas_types bat on bat.id_type = la.id_type 
-- join ref_geo.bib_areas_types bat2 on bat2.type_code = 'PEC' 
-- where bat.type_code = 'M10'
-- group by bat2.id_type
-- ;

insert into ref_geo.l_areas(id_type, area_name, area_code, geom, centroid, geojson_4326, source, comment, enable)
with geom as (
 select 
 st_multi(st_buffer(st_union(la.geom), 0.0)) as geom
from ref_geo.l_areas la
join ref_geo.bib_areas_types bat on bat.id_type = la.id_type 
where bat.type_code in ('ZC')
)
-- , geom2 AS (
-- 	id_area,
-- 	ST_MULTI(ST_UNION(ST_COLLECTION_EXTRACT(geom, 3))) as geom
-- )
select 
	bat2.id_type,
	'Plan d''etude de la charte' as area_name,
	'PEC' as area_code, 
	g.geom,
	st_centroid(g.geom) as centroid,
	st_asgeojson(st_transform(g.geom, 4326)) as geojson_4326,
	'M10' as source,
	'AMA AA ZC' as comment,
	true as enabled
	from geom g
join ref_geo.bib_areas_types bat2 on bat2.type_code = 'PEC' 
;