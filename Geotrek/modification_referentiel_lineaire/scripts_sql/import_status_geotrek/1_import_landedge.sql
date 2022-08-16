---------- Insertion de tous les tronçons dans core_topology
INSERT INTO core_topology (date_insert, date_update, deleted, "offset", kind, geom, geom_need_update)
SELECT now() AS date_insert,
       now() AS date_update,
       FALSE AS deleted,
       -5 AS "offset", -- /!\ valeur par défaut définie dans les paramètres avancés de Geotrek-admin
       'LANDEDGE' AS kind,
       geom,
       FALSE AS geom_need_update
  FROM rlesi_cartosud_updated rcu
 WHERE rcu.proprio IS NOT NULL -- Vérification qu'on n'intégre pas de tronçon qui n'ait aucune information foncière
    OR rcu.ref_cad IS NOT NULL
    OR rcu.code_cadas IS NOT NULL
    OR convention IS NOT NULL
    OR statut_cad IS NOT NULL;


---------- Insertion de tous les tronçons dans land_landedge
INSERT INTO land_landedge
(topo_object_id, "owner", agreement, land_type_id, eid)
SELECT ct.id AS topo_object_id,
       CONCAT_WS('<br/><br/>', -- Double retour pour aérer le texte
            'Propriétaire : ' || NULLIF(rcu.proprio, '-'),
            'Référence cadastre : ' || NULLIF(ref_cad, '-'),
            'Code cadastre : ' || NULLIF(code_cadas, '-'),
            'Détails conventionnement : ' || NULLIF(convention, '-')
       ) AS "owner",
       CASE
               WHEN convention LIKE 'oui%' THEN TRUE
               ELSE FALSE
       END AS agreement,
       COALESCE((SELECT id FROM land_landtype WHERE name = statut_cad), -- Si le type de voie ne correspond pas à une valeur de land_landtype...
                (SELECT id FROM land_landtype WHERE name = 'Inconnu')   -- alors le type 'Inconnu' est attribué
       ) AS land_type_id,
       id AS eid
  FROM rlesi_cartosud_updated rcu
  JOIN core_topology ct
    ON ST_Equals(rcu.geom, ct.geom) -- Jointure sur les core_topology tout juste insérés afin de faire le lien avec le bon topo_object_id
   AND ct.kind = 'LANDEDGE';


---------- Calcul des core_pathaggregation des core_topology 'LANDEDGE'
---------- le but est de projeter les extrémités des géométries des LANDEDGE
---------- sur les core_path, et ainsi d'obtenir les valeurs start_position et end_position
---------- nécessaires à core_pathaggregation
INSERT INTO core_pathaggregation (path_id, topo_object_id, start_position, end_position, "order")
WITH a AS (
    SELECT CASE
           -- Si la projection des deux extrémités du core_path sur le core_topology est égale
           -- (par exemple quand le core_path est beaucoup plus grand et qu'il a une forme de U)
           -- alors c'est la projection directe des extrémités du core_topology sur le core_path qui est utilisée
                   WHEN ST_LineLocatePoint(ct.geom, ST_StartPoint(cp.geom)) = ST_LineLocatePoint(ct.geom, ST_EndPoint(cp.geom))
                   THEN ST_LineLocatePoint(cp.geom, ST_StartPoint(ct.geom))
                   ELSE ST_LineLocatePoint(cp.geom, -- Projection sur core_path de la plus petite projection sur le core_topology des extrémités de core_path
                                              ST_LineInterpolatePoint(ct.geom, -- Obtention de la géométrie correspondant à la plus petite valeur
                                                                       least(ST_LineLocatePoint(ct.geom, ST_StartPoint(cp.geom)), -- Obtention de la plus petite valeur de projection des extrémités de core_path sur le core_topology
                                                                       ST_LineLocatePoint(ct.geom, ST_EndPoint(cp.geom))
                                                                     )
                                             )
                        )
           END AS start_position,
           CASE
                   WHEN ST_LineLocatePoint(ct.geom, ST_StartPoint(cp.geom)) = ST_LineLocatePoint(ct.geom, ST_EndPoint(cp.geom))
                   THEN ST_LineLocatePoint(cp.geom, ST_EndPoint(ct.geom))
                   ELSE ST_LineLocatePoint(cp.geom, -- Projection sur core_path de la plus grande projection sur le core_topology des extrémités de core_path
                                              ST_LineInterpolatePoint(ct.geom, -- Obtention de la géométrie correspondant à la plus grande valeur
                                                                       greatest(ST_LineLocatePoint(ct.geom, ST_StartPoint(cp.geom)), -- Obtention de la plus grande valeur de projection des extrémités de core_path sur le core_topology
                                                                          ST_LineLocatePoint(ct.geom, ST_EndPoint(cp.geom))
                                                                     )
                                             )
                        )
           END AS end_position,
           cp.id AS path_id,
           ct.id AS topo_object_id,
           ST_LineLocatePoint(ct.geom,
                                 ST_ClosestPoint(cp.geom,
                                               ST_StartPoint(ct.geom)
                              )
           ) AS locate_on_ct_of_closest_cp_point_from_ct_start -- Obtention de la valeur de projection sur le core_topology
                                                                    -- du plus proche point de core_path du point de départ du core_topology
                                                                 -- afin de trier les core_pathaggregation selon leur distance au point de départ du core_topology
      FROM core_path cp
      JOIN core_topology ct
        ON ct.kind = 'LANDEDGE'
       AND (ST_Contains(cp.geom, ct.geom) -- Jointure sur le chevauchement partiel ou total entre le core_topology et le core_path
            OR ST_Overlaps(cp.geom, ct.geom)
            OR ST_Within(cp.geom, ct.geom)))
,b AS (
    -- Obtention de la valeur de "order" grâce à un groupement par "topo_object_id" et un tri par "locate_on_ct_of_closest_cp_point_from_ct_start"
    SELECT *,
           row_number() OVER (PARTITION BY topo_object_id ORDER BY locate_on_ct_of_closest_cp_point_from_ct_start) -1 AS "order"
    FROM a)
,c AS (
    -- Obtention de la valeur maximale de "order" pour chaque "topo_object_id"
    SELECT topo_object_id,
           max("order") AS max_order
      FROM b
     GROUP BY topo_object_id)
SELECT path_id,
       b.topo_object_id,
       -- On considère que tous les core_pathaggregation à l'exception du premier et du dernier vont de 0 à 1 ou de 1 à 0
       CASE -- Si le core_pathaggregation n'est pas le premier
               WHEN "order" != 0 AND start_position < end_position THEN 0 -- si la direction est normale, start_position vaut 0
               WHEN "order" != 0 AND start_position > end_position THEN 1 -- si la direction est inversée, start_position vaut 1
               ELSE start_position
       END AS start_position,
       CASE -- Si le core_pathaggregation n'est pas le dernier
               WHEN "order" != max_order AND start_position < end_position THEN 1 -- si la direction est normale, end_position vaut 1
               WHEN "order" != max_order AND start_position > end_position THEN 0 -- si la direction est inversée, end_position vaut 0
               ELSE end_position
       END AS end_position,
       "order"
  FROM b
  JOIN c
    ON b.topo_object_id = c.topo_object_id;
