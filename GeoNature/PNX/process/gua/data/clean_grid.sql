-- on supprime les M10 et M5 qui n'intersectent pas M1

WITH m1  AS (
SELECT ST_UNION(geom) as geom
FROM ref_geo.l_areas l
JOIN ref_geo.bib_areas_types t
ON t.id_type = l.id_type AND t.type_code IN ('M1')
)

DELETE 
FROM ref_geo.l_areas l
USING ref_geo.bib_areas_types t, m1
WHERE  t.id_type = l.id_type AND t.type_code IN ('M10', 'M5')
AND NOT ST_INTERSECTS(m1.geom, l.geom)