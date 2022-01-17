---------- Création d'une table agrégeant les géométries quand les données attributaires étaient équivalentes

CREATE TABLE IF NOT EXISTS rlesi_cartosud_updated_merged_on_type_revet AS
WITH a AS (
	SELECT (ST_Dump( -- Éclatement des GeometryCollections en LineString individuelles
                ST_LineMerge( -- Réduction au minimum du nombre de LineStrings de chaque GeometryCollection
                    UNNEST( -- Éclatement des array obtenues en GeometryCollections continues
                        ST_ClusterIntersecting(geom) -- Regroupement par partage d'attribut
                    )
                )
            )
           ).geom AS rcu_geom_union,
		   type_revet
	  FROM rlesi_cartosud_updated rcu
	 GROUP BY type_revet)
SELECT string_agg(id_carto, ', ') AS id_carto_array, -- Recalcul des id des tronçons présents dans chaque LineString
	   a.*
  FROM a
  JOIN rlesi_cartosud_updated rcu
	ON ST_Contains(a.rcu_geom_union, rcu.geom) -- Jointure spatiale afin de retrouver les tronçons importés
	OR ST_Equals(a.rcu_geom_union, rcu.geom)
 GROUP BY a.rcu_geom_union, a.type_revet;


---------- Insertion de tous les tronçons dans core_topology
INSERT INTO core_topology (date_insert, date_update, deleted, "offset", kind, geom, geom_need_update)
SELECT now() AS date_insert,
	   now() AS date_update,
	   FALSE AS deleted,
	   0 AS "offset",
	   'PHYSICALEDGE' AS kind,
	   rcu_geom_union AS geom,
	   FALSE AS geom_need_update
  FROM rlesi_cartosud_updated_merged_on_type_revet rcu;

---------- Insertion de tous les tronçons dans land_physicaledge
INSERT INTO land_physicaledge (topo_object_id, physical_type_id, eid)
SELECT ct.id AS topo_object_id,
	   lp.id AS physical_type_id,
	   id_carto_array AS eid
  FROM rlesi_cartosud_updated_merged_on_type_revet rcu
  JOIN core_topology ct
    ON ST_Equals(rcu.rcu_geom_union, ct.geom)
   AND ct.kind = 'PHYSICALEDGE'
  JOIN land_physicaltype lp
    ON lp.name = type_revet
 GROUP BY ct.id, eid, lp.id;

---------- Calcul des core_pathaggregation des core_topology 'PHYSICALEDGE'
---------- le but est de projeter les extrémités des géométries des PHYSICALEDGE
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
		ON ct.kind = 'PHYSICALEDGE'
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
