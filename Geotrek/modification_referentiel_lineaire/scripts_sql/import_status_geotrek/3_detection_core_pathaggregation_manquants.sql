---------- Calcul des core_pathaggregation qui manquent à certaines core_topology
CREATE TABLE IF NOT EXISTS core_pathaggregation_manquants AS
WITH a AS (
    SELECT id,
           ST_LineMerge(geom) AS geom -- LineMerge des MultiLineString pour ne se pencher que sur celles qui ont deux éléments
      FROM core_topology lp
     WHERE ST_GeometryType(geom) != 'ST_LineString'
       AND kind IN ('PHYSICALEDGE', 'LANDEDGE')),
b AS ( -- Identification des deux points entre lesquels est présent le trou de core_topology
    SELECT id,
           ST_ClosestPoint(ST_Boundary(ST_GeometryN(geom, 1)), ST_Boundary(ST_GeometryN(geom, 2))) AS geom_1_closest_boundary,
           ST_ClosestPoint(ST_Boundary(ST_GeometryN(geom, 2)), ST_Boundary(ST_GeometryN(geom, 1))) AS geom_2_closest_boundary,
           geom
      FROM a
     WHERE ST_NumGeometries(geom) = 2),
c AS ( -- Identification du core_path qui comble le trou parfaitement
    SELECT cp.id AS path_id,
           cp.geom AS path_geom,
           CASE ST_StartPoint(cp.geom)
                   WHEN geom_1_closest_boundary THEN FALSE
                   WHEN geom_2_closest_boundary THEN TRUE
           END AS reversed, -- Détermination de la direction à donner au core_pathaggregation
           b.id AS topo_object_id,
           b.geom AS topo_geom
      FROM b
      JOIN core_path cp
        ON (ST_Equals(ST_StartPoint(cp.geom), geom_1_closest_boundary)
            AND ST_Equals(ST_EndPoint(cp.geom), geom_2_closest_boundary))
           OR
           (ST_Equals(ST_EndPoint(cp.geom), geom_1_closest_boundary)
            AND ST_Equals(ST_StartPoint(cp.geom), geom_2_closest_boundary))),
d AS (
    SELECT topo_object_id,
           count(topo_object_id) AS compte -- compte du nombre de core_path qui correspondent au trou de chaque core_topology
      FROM c
     GROUP BY topo_object_id
),
e AS ( -- Détermination des valeurs de start_position et end_position selon la direction
    SELECT path_id,
           c.topo_object_id,
           CASE reversed
                   WHEN FALSE THEN 0
                   WHEN TRUE THEN 1
           END AS start_position,
           CASE reversed
                   WHEN FALSE THEN 1
                   WHEN TRUE THEN 0
           END AS end_position,
           CASE reversed
                   WHEN FALSE THEN ST_EndPoint(path_geom)
                   WHEN TRUE THEN ST_StartPoint(path_geom)
           END AS end_position_geom,
           compte
      FROM c
      JOIN d
        ON c.topo_object_id = d.topo_object_id),
f AS ( -- Détermination de la valeur de "order" selon le core_path déjà présent dans core_pathaggregation
       -- dont les extrémités contiennent end_position_geom
    SELECT e.path_id,
           e.topo_object_id,
           e.start_position,
           e.end_position,
           cpa."order",
           compte
      FROM e
      JOIN core_path cp
        ON ST_Contains(ST_Boundary(cp.geom), end_position_geom)
       AND cp.id IN (SELECT path_id FROM core_pathaggregation WHERE topo_object_id = e.topo_object_id)
      JOIN core_pathaggregation cpa
        ON cp.id = cpa.path_id
       AND e.topo_object_id = cpa.topo_object_id
)
SELECT * FROM f
 ORDER BY topo_object_id;
