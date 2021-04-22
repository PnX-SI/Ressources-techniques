ALTER TABLE ref_geo.l_areas DISABLE trigger all;
DELETE FROM ref_geo.l_areas l
    USING ref_geo.bib_areas_types t
    WHERE l.id_type = t.id_type AND t.type_code = 'COM';
DELETE FROM ref_geo.li_municipalities;
ALTER TABLE ref_geo.l_areas ENABLE trigger all;


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
	insee AS area_code,
 	geom, 
 	ST_CENTROID(geom) AS centroid,
 	ST_ASGEOJSON(ST_TRANSFORM(geom, 4326)) AS geojson_4326,
 	'import depuis GeoTreck parc des forets' AS source,
 	true AS enable
FROM ref_geo.tmp_communes c
JOIN ref_geo.bib_areas_types t ON t.type_code='COM';

INSERT INTO ref_geo.li_municipalities(
    id_municipality,
    id_area, 
    --status,
    insee_com,
    nom_com,
    nom_dep,
    insee_dep
    --nom_reg,
    --population,
    --plani_precision
)
SELECT 
    gid AS id_municipality,
    l.id_area AS id_area,
    --statut AS status,
    insee AS insee_com,
    nom AS nom_com,
    --'??' AS arr,
    SUBSTR(insee, 0, 3) AS nom_dep,
    SUBSTR(insee, 0, 3) AS insee_dep
    --'??' AS nom_reg
    --'??' AS insee_reg,
    --popul AS population,
    --prec_plani AS plani_precision

FROM ref_geo.l_areas l
JOIN ref_geo.bib_areas_types t 
	ON t.id_type = l.id_type
JOIN ref_geo.tmp_communes c
	ON c.insee = l.area_code 
WHERE t.type_code = 'COM'
;