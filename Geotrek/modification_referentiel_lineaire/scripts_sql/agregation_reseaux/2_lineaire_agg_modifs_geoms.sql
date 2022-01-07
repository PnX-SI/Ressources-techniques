---------- CRÉATION D'UNE MATRICE DE DÉCISION DES inner AVEC TOUTES LES RELATIONS N'ÉTANT PAS DU BRUIT
DROP TABLE IF EXISTS decision_inner;

CREATE TABLE decision_inner AS
	  SELECT rid,
	         iid,
	         cas_r,
	         cas_i,
	         geom_ri,
  	         geom_ir,
	         geom_r,
	         geom_i,
	         CASE
             WHEN cas_r IN (4,5) THEN 1-longueur_ri/longueur_r
		     ELSE longueur_ri/longueur_r
		     END AS tx_longueur_doublon_r, -- calcul d'un indicateur de pertinence de la relation ri
	         CASE
	         WHEN cas_i IN (4,5) THEN 1-longueur_ir/longueur_i
		     ELSE longueur_ir/longueur_i
		     END AS tx_longueur_doublon_i, -- calcul d'un indicateur de pertinence de la relation ir
		     geom_ir_ri,
		     aire_ir_ri,
		     NULL::varchar AS "action",
		     structure_id
	    FROM tampon_inner_all ti
	    JOIN importe i
	      ON i.id = ti.iid
	     AND NOT bruit IS TRUE -- (en l'absence de supervision, tous les "BRUIT IS NULL" sont importés aussi)
       ORDER BY rid;




-------------------- GÉOMÉTRIES UNIQUES DES TRONÇONS r :
---------- le but est d'obtenir à la fois la liste des tronçons r qui sont totalement en-dehors des tampons i
---------- mais aussi les portions uniques de tronçons r dont une partie est en doublon avec un ou plusieurs i
---------- le même procédé n'est pas appliqué aux tronçons i, dont les parties uniques sont récupérées ultérieurement d'une autre manière


---------- CRÉATION D'UNE TABLE AVEC TOUTES LES GÉOMÉTRIES UNIQUES DE r
DROP TABLE IF EXISTS tampon_outer_r;

CREATE TABLE tampon_outer_r AS
	WITH uniques AS ( -- sélection des tronçons dont l'id est absent de decision_inner, donc 100% uniques
		SELECT r.id AS rid,
			   r.geom AS geom_ri, -- sachant qu'il n'y a pas de i, ri est à comprendre comme la relation de r par rapport à "rien"
		       					    -- c'est donc la partie unique de r
			   r.geom AS geom_r,
			   5 AS cas_r
		  FROM reference r
		       LEFT JOIN decision_inner di
		       ON di.rid = r.id
		 WHERE di.rid IS NULL
	),
	split_outer AS ( -- création des géométries de r extérieures aux tampons i
 					  -- via ST_Difference sur un tampon des géométries intérieures geom_ri
		SELECT rid,
			   ST_Difference(geom_r, ST_Union(ST_Buffer(geom_ri, 0.000001, 'endcap=flat'))) AS geom_ri,
			   geom_r,
			   4 AS cas_r
		  FROM decision_inner
		 GROUP BY rid, geom_r
	),
	"union" AS ( -- union des deux tables
		SELECT * FROM uniques
		 UNION ALL
		SELECT * FROM split_outer
	)
SELECT rid,
	   geom_r,
	   cas_r,
       geom_ri,
       round((ST_Length(geom_ri))::NUMERIC, 1) AS longueur_ri,
	   round((ST_Length(geom_r))::NUMERIC, 1) AS longueur_r,
	   NULL::BOOLEAN AS bruit
  FROM "union";


---------- ÉLIMINATION DES r QUI N'ONT AUCUNE PARTIE UNIQUE
UPDATE tampon_outer_r
   SET bruit = TRUE
 WHERE geom_ri = 'GEOMETRYCOLLECTION EMPTY';

UPDATE tampon_outer_r
   SET bruit = FALSE
 WHERE bruit IS NULL;


---------- CRÉATION D'UNE TABLE DE DÉCISION
---------- sur le même modèle que decision_inner
DROP TABLE IF EXISTS decision_outer_r;

CREATE TABLE decision_outer_r AS
	  SELECT rid,
		     cas_r,
		     geom_ri,
		     geom_r,
		     longueur_ri/longueur_r AS tx_longueur_unicite_r, -- calcul d'un indicateur de pertinence de la relation ri
		     NULL::varchar AS "action"
	    FROM tampon_outer_r
	   WHERE bruit IS FALSE
	   ORDER BY rid;


-------------------- MODIFICATIONS DES GÉOMÉTRIES DU RÉFÉRENTIEL : DOUBLONS
---------- le but est ici d'attribuer à chaque relation une action de modification de la géométrie du tronçon r.
---------- on peut vouloir modifier la totalité de la géométrie de r, une partie seulement, ou bien ne rien modifier
DROP TABLE IF EXISTS core_path_wip_new;

CREATE TABLE core_path_wip_new AS
	   SELECT id,
	   		 geom,
	  	       NULL::geometry AS geom_new,
	  	       NULL::varchar AS erreur,
	  	       FALSE::boolean AS supervised,
	  	       "comments",
	  	       structure_id,
	  	       eid,
	  	       NULL::varchar AS geom_modified -- permet de tracer simplement si l'enregistrement a eu sa géométrie modifiée
	     FROM reference r;

ALTER TABLE core_path_wip_new ADD PRIMARY KEY(id); -- pour pouvoir modifier les géométries dans QGIS

CREATE SEQUENCE core_path_wip_new_id_seq OWNED BY core_path_wip_new.id;
SELECT setval('core_path_wip_new_id_seq', (SELECT max(id) FROM core_path_wip_new));
ALTER TABLE core_path_wip_new ALTER COLUMN id SET DEFAULT nextval('core_path_wip_new_id_seq');


---------- DÉFINITION DE L'ACTION À RÉALISER :

---------- IL Y A UNE RELATION DE DOUBLE DOUBLON TOTAL :
---------- la nouvelle géométrie de r sera geom_i
UPDATE decision_inner
   SET "action" = 'geom_r geom_i'
 WHERE cas_r = 1
   AND cas_i = 1;

---------- TOUT r EST DOUBLON AVEC i MAIS PAS L'INVERSE :
---------- la nouvelle géométrie de r sera une projection de celle-ci sur une partie de geom_i
UPDATE decision_inner
   SET "action" = 'geom_r locate geom_i'
 WHERE cas_r = 1
   AND cas_i != 1;

---------- UNE PARTIE DE r EST DOUBLON AVEC i :
---------- une partie de la nouvelle géométrie de r sera une projection de geom_ri sur une partie de geom_i
UPDATE decision_inner
   SET "action" = 'geom_ri locate geom_i'
 WHERE cas_r != 1;



---------- RÉALISATION DES ACTIONS :

---------- IL Y A UNE RELATION DE DOUBLE DOUBLON TOTAL
UPDATE core_path_wip_new cp_wn
   SET geom_new = geom_i,
       eid = iid,
       structure_id = di.structure_id,
       geom_modified = 'oui'
  FROM decision_inner di
 WHERE cp_wn.id = di.rid
   AND "action" = 'geom_r geom_i';


---------- TOUT r EST DOUBLON AVEC i MAIS PAS L'INVERSE :

---------- r est a moins de 5m du debut de i :
---------- la nouvelle géométrie de r est geom_i, de son point de départ (0)
---------- jusqu'au point le plus loin de celui-ci parmi
---------- les projections du point de départ et du point d'arrivée de geom_r
WITH a AS (
	SELECT *,
		   ST_LineSubstring(
		   		geom_i,
		   		0,
				GREATEST( -- nécessaire pour pallier aux différences de direction entre les tronçons r et i
					ST_LineLocatePoint(geom_i, ST_StartPoint(geom_r)),
					ST_LineLocatePoint(geom_i, ST_EndPoint(geom_r))
				)
		   ) AS geom_new
	  FROM decision_inner
	 WHERE "action" = 'geom_r locate geom_i'
	   AND ST_DWithin(ST_StartPoint(geom_i), ST_ClosestPoint(geom_i, ST_ClosestPoint(geom_r, ST_StartPoint(geom_i))), 5)
)
UPDATE core_path_wip_new cp_wn
   SET geom_new = a.geom_new,
       eid = iid,
       structure_id = a.structure_id,
       geom_modified = 'oui'
  FROM a
 WHERE cp_wn.id = a.rid;

---------- r est a moins de 5m de la fin de i :
---------- la nouvelle géométrie de r est geom_i, du point le plus proche de son point de départ
---------- parmi les projections du point de départ et du point d'arrivée de geom_r
---------- jusqu'à son point d'arrivée (1)
WITH a AS (
	SELECT *,
		   ST_LineSubstring(
				geom_i,
				LEAST( -- nécessaire pour pallier aux différences de direction entre les tronçons r et i
					ST_LineLocatePoint(geom_i, ST_StartPoint(geom_r)),
					ST_LineLocatePoint(geom_i, ST_EndPoint(geom_r))
				),
				1
		   ) AS geom_new
	  FROM decision_inner
	 WHERE "action" = 'geom_r locate geom_i'
	   AND ST_DWithin(ST_EndPoint(geom_i), ST_ClosestPoint(geom_i, ST_ClosestPoint(geom_r, ST_EndPoint(geom_i))), 5)
)
UPDATE core_path_wip_new cp_wn
   SET geom_new = a.geom_new,
       eid = iid,
       structure_id = a.structure_id,
       geom_modified = 'oui'
  FROM a
 WHERE cp_wn.id = a.rid;

---------- r n'est pas proche des extremites de i :
---------- en quelque sorte "au milieu" de i.
---------- la nouvelle géométrie de r est geom_i, du point le plus proche de son point de départ 
---------- parmi les projections du point de départ et du point d'arrivée de geom_r
---------- jusqu'au point le plus loin de son point de départ, toujours parmi les deux mêmes projections
WITH a AS (
	SELECT *,
		   ST_LineSubstring(
				geom_i,
				LEAST( -- nécessaire pour pallier aux différences de direction entre les tronçons r et i
					ST_LineLocatePoint(geom_i, ST_StartPoint(geom_r)),
					ST_LineLocatePoint(geom_i, ST_EndPoint(geom_r))
				),
				GREATEST( -- nécessaire pour pallier aux différences de direction entre les tronçons r et i
					ST_LineLocatePoint(geom_i, ST_StartPoint(geom_r)),
					ST_LineLocatePoint(geom_i, ST_EndPoint(geom_r))
				)
		   ) AS geom_new
	  FROM decision_inner
	 WHERE "action" = 'geom_r locate geom_i'
	   AND NOT ST_DWithin(ST_StartPoint(geom_i), ST_ClosestPoint(geom_i, ST_ClosestPoint(geom_r, ST_StartPoint(geom_i))), 5)
	   AND NOT ST_DWithin(ST_EndPoint(geom_i), ST_ClosestPoint(geom_i, ST_ClosestPoint(geom_r, ST_EndPoint(geom_i))), 5)
)
UPDATE core_path_wip_new cp_wn
   SET geom_new = a.geom_new,
       eid = iid,
       structure_id = a.structure_id,
       geom_modified = 'oui'
  FROM a
 WHERE cp_wn.id = a.rid;



---------- UNE PARTIE DE r EST DOUBLON AVEC i :
---------- la nouvelle géométrie de r est geom_i, du point le plus proche de son point de départ
---------- parmi les projections du point de départ et du point d'arrivée de geom_ri
---------- jusqu'au point le plus loin de son point de départ, toujours parmi les deux mêmes projections
WITH a AS (
	SELECT *,
		   ST_StartPoint(ST_GeometryN(geom_ri, 1)) AS start_ri,
		   ST_EndPoint(ST_GeometryN(geom_ri, ST_NumGeometries(geom_ri))) AS end_ri,
		   ST_LineLocatePoint(geom_i, ST_StartPoint(geom_r)) AS locate_r_start,
		   ST_LineLocatePoint(geom_i, ST_EndPoint(geom_r)) AS locate_r_end,
		   ST_LineLocatePoint(geom_i, ST_StartPoint(ST_GeometryN(geom_ri, 1))) AS locate_ri_start,
		   ST_LineLocatePoint(geom_i, ST_EndPoint(ST_GeometryN(geom_ri, ST_NumGeometries(geom_ri)))) AS locate_ri_end,
		   ST_DWithin(ST_StartPoint(ST_GeometryN(geom_ri, 1)), ST_StartPoint(geom_r), 5) AS starts_ri_r_5,
		   ST_DWithin(ST_EndPoint(ST_GeometryN(geom_ri, ST_NumGeometries(geom_ri))), ST_EndPoint(geom_r), 5) AS ends_ri_r_5,
		   ST_DWithin(geom_r, ST_StartPoint(geom_i), 5) AS start_i_r_5,
		   ST_DWithin(geom_r, ST_EndPoint(geom_i), 5) AS end_i_r_5
	  FROM decision_inner
	 WHERE "action" = 'geom_ri locate geom_i'
	 GROUP BY rid, geom_r, iid, geom_i, geom_ri, cas_r, cas_i, geom_ir, tx_longueur_doublon_r, tx_longueur_doublon_i, geom_ir_ri, aire_ir_ri, "action"
),
b AS (
	SELECT rid,
		   iid,
		   geom_i AS geom_new
	  FROM a
	 WHERE cas_i = 1
	    OR (cas_i != 1
	    	AND start_i_r_5
	    	AND end_i_r_5
	    	AND NOT ST_IsRing(geom_i))
	 GROUP BY rid, iid, geom_i
),
c AS (
	SELECT rid,
		   iid,
		   ST_LineSubstring(
				geom_i,
				0,
				GREATEST(locate_ri_start, locate_ri_end) -- nécessaire pour pallier aux différences de direction entre les tronçons r et i
		   ) AS geom_new
	  FROM a
	 WHERE cas_i != 1
	   AND start_i_r_5
	   AND NOT end_i_r_5
	 GROUP BY rid, iid, geom_i, locate_ri_start, locate_ri_end
),
d AS (
	SELECT rid,
		   iid,
		   ST_LineSubstring(
				geom_i,
				LEAST(locate_ri_start, locate_ri_end),
				1 -- nécessaire pour pallier aux différences de direction entre les tronçons r et i
		   ) AS geom_new
	  FROM a
	 WHERE cas_i != 1
	   AND NOT start_i_r_5
	   AND end_i_r_5
	 GROUP BY rid, iid, geom_i, locate_ri_start, locate_ri_end
),
e AS (
	SELECT rid,
		   iid,
		   ST_LineSubstring(
				geom_i,
				LEAST(locate_ri_start, locate_ri_end),
				GREATEST(locate_ri_start, locate_ri_end) -- nécessaire pour pallier aux différences de direction entre les tronçons r et i
		   ) AS geom_new
	  FROM a
	 WHERE cas_i != 1
	   AND NOT start_i_r_5
	   AND NOT end_i_r_5
	 GROUP BY rid, iid, geom_i, locate_ri_start, locate_ri_end
),
f AS (
	SELECT *, 'b' AS cas FROM b
	 UNION ALL
	SELECT *, 'c' AS cas FROM c
	 UNION ALL
	SELECT *, 'd' AS cas FROM d
	 UNION ALL
	SELECT *, 'e' AS cas FROM e
),
g AS (
	SELECT f.rid,
		   f.iid AS iid,
		   ST_LineMerge(ST_Union(geom_new)) AS geom_new,
		   a.structure_id
	  FROM f
	  JOIN a
	    ON a.rid = f.rid
	 GROUP BY f.rid, a.structure_id, f.iid
	 ORDER BY f.rid, f.iid
),
h AS (
	SELECT rid,
		   string_agg(iid::varchar, ',') AS iid,
		   ST_LineMerge(ST_Union(geom_new)) AS geom_new,
		   structure_id
	  FROM g
	  GROUP BY rid, structure_id
)
UPDATE core_path_wip_new cp_wn
   SET geom_new = h.geom_new,
       eid = iid,
       structure_id = h.structure_id,
       geom_modified = 'oui'
  FROM h
 WHERE cp_wn.id = h.rid;



-------------------- MODIFICATIONS DES GÉOMÉTRIES DU RÉFÉRENTIEL : PARTIES UNIQUES DE r ET DE i
---------- le but est d'identifier et intégrer les parties uniques de tronçons r ou i,
---------- qui ont donc déjà été partiellement intégrés sur leur partie en doublon (que ce soit r ou i)



---------- AJOUT DES PARTIES UNIQUES DE r :
---------- si geom_ri < 5m alors normalement déjà prise en compte via l'action "geom_r locate geom_i" sur les géométries intérieures
---------- si r est dans une relation "doublon discontinu" et "doublon discontinu" (cas_r = 3 et cas_i = 3) alors déjà prise en compte
---------- si geom_ri est une MultiLineString alors conservation uniquement des parties de plus de 5m
DROP TABLE IF EXISTS r_parties_uniques;

CREATE TABLE r_parties_uniques AS
WITH
a AS (
	SELECT rid,
		   (ST_Dump(geom_ri)).geom AS geom_ri,
		   geom_r
	  FROM decision_outer_r dor
	 WHERE ST_Length(geom_ri) > 5
	   AND cas_r = 4
),
b AS (
	SELECT *
	  FROM a
	 WHERE ST_Length(geom_ri) > 5
),
c AS (
	SELECT rid,
		   count(rid)
	  FROM b
	 GROUP BY rid
)
SELECT b.*
  FROM b
  JOIN c
    ON b.rid = c.rid
   AND (count = 1
        OR
        ST_Touches(b.geom_ri, ST_Boundary(geom_r))
       )
;




---------- MAJ DES GÉOMÉTRIES DES r DONT UNE PARTIE EST UNIQUE :
---------- le but est de rattacher les parties uniques aux géométries r qui ont été modifiées pour coller à des geom_i
---------- sur leurs parties en doublon. Il faut donc recréer une continuité pour éviter les trous et erreurs topologiques.
---------- (étape complétée plus tard par une autre requête pour les r dont l'extrémité de la partie unique doit egalement être modifiée)
WITH
a AS (  -- parties uniques à un bout ou l'autre de r (cf. ST_Overlaps)
	SELECT trpu.rid,
		   ST_ClosestPoint(ST_Boundary(cp_wn.geom_new),  -- identification de l'extrémité de geom_new la plus proche
		   				   ST_Boundary(trpu.geom_ri)  -- des extrémités de geom_ri unique (trpu.geom_ri)
		   ) AS closest_new,
		   ST_LineLocatePoint(trpu.geom_ri, -- identification de l'extrémité de trpu.geom_ri la plus proche
		   									-- des extrémités de geom_new
		   					  ST_ClosestPoint(ST_Boundary(trpu.geom_ri),
		   					  				  ST_Boundary(cp_wn.geom_new)
		   					  )
		   )::integer AS closest_ri,
		   trpu.geom_ri,
		   cp_wn.geom_new
	  FROM r_parties_uniques trpu -- jointure entre la table des parties uniques des r
	  								   -- et la table avec les géométries déjà modifiees par les requêtes précédentes
	  	   JOIN core_path_wip_new cp_wn
	       ON cp_wn.id = trpu.rid
	       AND ST_Overlaps(ST_Boundary(trpu.geom_ri), ST_Boundary(trpu.geom_r))
),
b AS (
	SELECT  rid,
			-- ajout de l'extrémité de geom_new la plus proche des extrémités de trpu.geom_ri à cette dernière
			CASE
				WHEN closest_ri = 1 THEN ST_AddPoint(geom_ri, closest_new)  -- est le point d'arrivée : closest_ri = 1
				ELSE ST_AddPoint(geom_ri, closest_new, 0) -- est le point de départ : closest_ri = 0
			END AS geom_ri_new
	  FROM a
),
union_geom_ri_new AS (
	SELECT rid,
		   ST_Union(geom_ri_new) AS geom_ri_new
	  FROM b
	 GROUP BY rid
),
c AS (
	SELECT rid,
		   ST_LineMerge(ST_Union(geom_ri_new, cp_wn.geom_new)) AS geom_new -- union de l'ancienne geom_new et de la partie unique
		   																-- augmentée du point de raccordement à la geom_new
	  FROM union_geom_ri_new
	  JOIN core_path_wip_new cp_wn
	    ON cp_wn.id = union_geom_ri_new.rid
)
UPDATE core_path_wip_new cp_wn
   SET geom_new = c.geom_new
  FROM c
 WHERE c.rid = cp_wn.id;



---------- INVERSION DU SENS DES TRONÇONS R QUI ONT ÉTÉ INVERSÉS
UPDATE core_path_wip_new cp_wn
   SET geom_new = ST_Reverse(cp_wn.geom_new)
 WHERE ST_Equals( -- si l'extrémité de geom_new la plus proche du dernier point de geom est
					-- son premier point, alors il faut inverser le sens de geom_new
			ST_StartPoint(cp_wn.geom_new),
			ST_ClosestPoint(ST_Boundary(cp_wn.geom_new),
							ST_EndPoint(cp_wn.geom)
			)
		 );




---------- CRÉATION D'UNE MATRICE DES EXTRÉMITÉS
---------- le but est d'identifier les extrémités de tronçons r qui ont changé de coordonnées
---------- afin de pouvoir rattacher les parties uniques d'autres tronçons r qui partageaient une extrémité identique
---------- en effet une partie unique de r n'étant par définition pas calquée sur une géométrie i,
---------- si le tronçon r auquel elles étaient connectées a changé de géométrie, il faut adapter les extrémités de cette partie unique
DROP TABLE IF EXISTS r_extremites;

CREATE TABLE r_extremites AS
	  SELECT id,
			 geom,
			 ST_StartPoint(geom) AS startpoint,
			 ST_EndPoint(geom) AS endpoint,
			 ST_StartPoint(geom_new) AS startpoint_new,
			 ST_EndPoint(geom_new) AS endpoint_new,
			 geom_new
		FROM core_path_wip_new;

---------- ENREGISTREMENT DES NOUVELLES EXTRÉMITÉS DES TRONÇONS r MODIFIÉS
DROP INDEX IF EXISTS r_extremites_geom_idx;

CREATE INDEX r_extremites_geom_idx
 		  ON r_extremites
 	   USING GIST(geom);

CLUSTER r_extremites
  USING r_extremites_geom_idx;

DROP INDEX IF EXISTS r_extremites_geom_new_idx;

CREATE INDEX r_extremites_geom_new_idx
 		  ON r_extremites
 	   USING GIST(geom_new);

CLUSTER r_extremites
  USING r_extremites_geom_new_idx;

DROP INDEX IF EXISTS r_extremites_startpoint_idx;

CREATE INDEX r_extremites_startpoint_idx
 		  ON r_extremites
 	   USING GIST(startpoint);

CLUSTER r_extremites
  USING r_extremites_startpoint_idx;

DROP INDEX IF EXISTS r_extremites_endpoint_idx;

CREATE INDEX r_extremites_endpoint_idx
 		  ON r_extremites
 	   USING GIST(endpoint);

CLUSTER r_extremites
  USING r_extremites_endpoint_idx;

DROP INDEX IF EXISTS r_extremites_startpoint_new_idx;

CREATE INDEX r_extremites_startpoint_new_idx
 		  ON r_extremites
 	   USING GIST(startpoint_new);

CLUSTER r_extremites
  USING r_extremites_startpoint_new_idx;

DROP INDEX IF EXISTS r_extremites_endpoint_new_idx;

CREATE INDEX r_extremites_endpoint_new_idx
 		  ON r_extremites
 	   USING GIST(endpoint_new);

CLUSTER r_extremites
  USING r_extremites_endpoint_new_idx;





---------- MISE À JOUR DES NOUVELLES EXTRÉMITÉS DES r EN PARTIE UNIQUES
---------- identification des extrémités qui étaient en commun entre plusieurs r dans le référentiel originel
---------- puis adaptation aux nouvelles extrémités provenant des modifications de géométrie ayant déjà eu lieu
WITH a AS (
 	SELECT r1.id AS r1_id,
		   r1.geom AS r1_geom, -- géométrie originelle
		   r1.startpoint AS r1_startpoint, -- point de départ originel
		   r1.endpoint AS r1_endpoint, -- point d'arrivée originel
		   r1.geom_new AS r1_geom_new, -- géométrie modifiée par les requêtes précédentes
		   r2.id AS r2_id,
		   r2.geom AS r2_geom,
		   r2.startpoint AS r2_startpoint,
		   r2.endpoint AS r2_endpoint,
		   r2.startpoint_new AS r2_startpoint_new, -- point de départ de la géométrie modifiée par les requêtes précédentes
		   r2.endpoint_new AS r2_endpoint_new -- point d'arrivée de la géométrie modifiée par les requêtes précédentes
	  FROM r_extremites r1
	       INNER JOIN r_extremites r2 -- jointure de la matrice des extrémités avec elle-même
	       ON r1.id != r2.id
	       	 AND r1.geom_new IS NOT NULL -- si r est en partie unique, alors il doit avoir une geom_new en raison de sa partie doublon
		   	 AND r2.geom_new IS NOT NULL -- on veut trouver les autres r dont la géométrie a été modifiée, donc qui ont une geom_new
			    AND (
			   	ST_Overlaps(ST_Boundary(r2.geom), ST_Boundary(r1.geom)) -- on veut trouver les r dont une extrémité
			   													  		-- était aussi une extrémité d'un autre r
			   	AND NOT
			   	ST_Overlaps(ST_Boundary(r2.geom_new), ST_Boundary(r1.geom_new)) -- mais dont les nouvelles extrémités ont divergé
			   	 														   		-- des nouvelles extrémités de cet autre r
			   																	-- (permet de ne pas prendre en compte
			   																	-- les extrémités communes ayant déjà ete modifiées ensemble)
			    )
	  JOIN r_parties_uniques trpu
	    ON trpu.rid = r1.id
), -- 4 cas à tester selon si l'extrémité commune était constituée du point de départ ou d'arrivée de r1 et du point de départ ou d'arrivée de r2
b AS (
	SELECT r2_startpoint_new AS r1_startpoint_new, -- étant donné les clauses WHERE ci-dessous, le nouveau startpoint de r1 est égal au r2_startpoint_new
		   NULL::geometry AS r1_endpoint_new,
		   *,
		   1 AS cas
	  FROM a
	 WHERE ST_Equals(r1_startpoint, r2_startpoint)
),
c AS (
	SELECT NULL::geometry AS r1_startpoint_new,
		   r2_endpoint_new AS r1_endpoint_new, -- étant donné les clauses WHERE ci-dessous, le nouveau endpoint de r1 est égal au r2_startpoint_new
		   *,
		   2 AS cas
	  FROM a
	 WHERE ST_Equals(r1_endpoint, r2_endpoint)
),
d AS (
	SELECT r2_endpoint_new AS r1_startpoint_new, -- étant donné les clauses WHERE ci-dessous, le nouveau startpoint de r1 est égal au r2_endpoint_new
		   NULL::geometry AS r1_endpoint_new,
		   *,
		   3 AS cas
	  FROM a
	 WHERE ST_Equals(r1_startpoint, r2_endpoint)
),
e AS (
	SELECT NULL::geometry AS r1_startpoint_new,
		   r2_startpoint_new AS r1_endpoint_new, -- étant donné les clauses WHERE ci-dessous, le nouveau endpoint de r1 est égal au r2_endpoint_new
		   *,
		   4 AS cas
	  FROM a
	 WHERE ST_Equals(r1_endpoint, r2_startpoint)
),
f AS (
	SELECT * FROM b
	 UNION ALL
	SELECT * FROM c
	 UNION ALL
	SELECT * FROM d
	 UNION ALL
	SELECT * FROM e
),
g AS (
	SELECT r1_id,
		   COALESCE(ST_Union(r1_startpoint_new), ST_StartPoint(r1_geom_new)) AS startpoint_new, -- si un nouveau startpoint_new n'a pas été attribué a r1, alors on reprend l'ancien startpoint_new
		   COALESCE(ST_Union(r1_endpoint_new), ST_EndPoint(r1_geom_new)) AS endpoint_new -- si un nouveau endpoint_new n'a pas été attribué a r1, alors on reprend l'ancien endpoint_new
	  FROM f
	 GROUP BY r1_id, r1_geom, r1_geom_new -- les intersections entre plus de deux r produisent plusieurs relations r1/r2,
	 									  -- il faut donc fusionner et regrouper par rid toutes les nouvelles extrémités produites
)
UPDATE r_extremites re
   SET startpoint_new = g.startpoint_new,
	   endpoint_new = g.endpoint_new
  FROM g
 WHERE re.id = g.r1_id;


---------- MISE À JOUR DES GÉOMÉTRIES DES r DONT UNE EXTRÉMITÉ A ÉTÉ DÉPLACÉE
---------- ajout des nouvelles extrémités au début et à la fin de tous les tronçons r ayant une geom_new
---------- pour une partie d'entre eux, leur geom_new, et donc leurs nouvelles extrémités, n'a pas été modifiée
---------- par la requête précédente, donc leurs points de départ et d'arrivée vont se retrouver dupliqués.
---------- d'où la nécessité de ST_RemoveRepeatedPoints, pour nettoyer les géométries

UPDATE core_path_wip_new cp_wn
   SET geom_new = ST_RemoveRepeatedPoints(ST_SetPoint(ST_SetPoint(cp_wn.geom_new, 0, startpoint_new), -1, endpoint_new))
  FROM r_extremites re
 WHERE re.id = cp_wn.id
   AND ST_GeometryType(startpoint_new) = 'ST_Point'
   AND ST_GeometryType(endpoint_new) = 'ST_Point'
   AND ST_GeometryType(cp_wn.geom_new) = 'ST_LineString';



---------- NOUVELLE MISE À JOUR DES EXTRÉMITÉS POUR PRENDRE EN COMPTE LES MODIFICATIONS JUSTE EFFECTUÉES
---------- comme nous venons de modifier les géométries des r ayant une partie unique, il faut de nouveau mettre à jour
---------- la table des extrémités, afin qu'elle soit correcte et prête pour la suite
UPDATE r_extremites re
   SET startpoint_new = ST_StartPoint(cp_wn.geom_new),
	   endpoint_new = ST_EndPoint(cp_wn.geom_new),
	   geom_new = cp_wn.geom_new
  FROM core_path_wip_new cp_wn
 WHERE cp_wn.geom_new IS NOT NULL
   AND cp_wn.id = re.id;



---------- CRÉATION DE NOUVEAUX TRONÇONS CORRESPONDANT AUX PARTIES UNIQUES DES i
---------- différence entre  les géométries des tronçons i et l'union de toutes les geom_new
---------- pour identifier les parties de i encore manquantes
INSERT INTO core_path_wip_new (geom_new, structure_id, eid)
WITH a AS (
	SELECT i.id AS iid,
		   ST_Difference(i.geom, ST_Buffer(ST_Union(cp_wn.geom_new), 0.00001, 'endcap=flat')) AS geom_diff,
		   i.geom AS geom_i,
		   i.structure_id
	  FROM importe i
	  JOIN decision_inner di
	    ON di.iid = i.id
	  JOIN core_path_wip_new cp_wn
	    ON cp_wn.id = di.rid
	 GROUP BY i.id, i.geom, i.structure_id
	),
b AS (
	SELECT iid,
	       structure_id,
		   (ST_Dump(geom_diff)).geom -- éclatement des MultiLinestrings en Linestrings individuelles
	  FROM a
	 WHERE ST_GeometryType(geom_diff) != 'ST_GeometryCollection'
	)
SELECT geom,
	   structure_id,
	   iid
  FROM b;


-------------------- INTÉGRATION DES TRONÇONS r 100% UNIQUES
---------- le but est d'intégrer les tronçons r 100% uniques
---------- et toujours d'identifier les extrémités qui ont pu être déplacées par des opérations précédentes

---------- MISE À JOUR DES EXTRÉMITÉS DES r 100% UNIQUES DONT AU MOINS UNE EXTRÉMITÉ A ÉTÉ DÉPLACÉE
---------- le fonctionnement est similaire à celui vu précédemment, les différences sont commentées
WITH a AS (
	SELECT r1.id AS r1_id,
		   r1.geom AS r1_geom,
		   r1.startpoint AS r1_startpoint,
		   r1.endpoint AS r1_endpoint,
		   r2.id AS r2_id,
		   r2.geom AS r2_geom,
		   r2.startpoint AS r2_startpoint,
		   r2.endpoint AS r2_endpoint,
		   r2.startpoint_new AS r2_startpoint_new,
		   r2.endpoint_new AS r2_endpoint_new
	  FROM r_extremites r1
	       INNER JOIN r_extremites r2
	       ON r1.id != r2.id
	       	 AND r1.geom_new IS NULL -- cette fois on souhaite identifier les tronçons r 100% uniques, donc dont la géométrie n'a pas été modifiée
	       	 AND r2.geom_new IS NOT NULL -- et toujours les appairer a des tronçons r dont la géométrie a été modifiée
	       	 AND ST_Touches(r2.geom, r1.geom)
	),
b AS (
	SELECT r2_startpoint_new AS r1_startpoint_new, -- étant donné les clauses WHERE ci-dessous, le nouveau startpoint de r1 est égal au r2_startpoint_new
		   NULL::geometry AS r1_endpoint_new,
		   *,
		   1 AS cas
	  FROM a
	 WHERE ST_Equals(r1_startpoint, r2_startpoint) -- les deux points de départ originels étaient identiques
),
c AS (
	SELECT NULL::geometry AS r1_startpoint_new,
		   r2_startpoint_new AS r1_endpoint_new, -- étant donné les clauses WHERE ci-dessous, le nouveau endpoint de r1 est égal au r2_startpoint_new
		   *,
		   3 AS cas
	  FROM a
	 WHERE ST_Equals(r1_endpoint, r2_startpoint)
),
d AS (
	SELECT r2_endpoint_new AS r1_startpoint_new, -- étant donné les clauses WHERE ci-dessous, le nouveau startpoint de r1 est égal au r2_endpoint_new
		   NULL::geometry AS r1_endpoint_new,
		   *,
		   5 AS cas
	  FROM a
	 WHERE ST_Equals(r1_startpoint, r2_endpoint)
),
e AS (
	SELECT NULL::geometry AS r1_startpoint_new,
		   r2_endpoint_new AS r1_endpoint_new, -- étant donné les clauses WHERE ci-dessous, le nouveau endpoint de r1 est égal au r2_endpoint_new
		   *,
		   7 AS cas
	  FROM a
	 WHERE ST_Equals(r1_endpoint, r2_endpoint)
),
f AS (
	SELECT * FROM b
	 UNION ALL
	SELECT * FROM c
	 UNION ALL
	SELECT * FROM d
	 UNION ALL
	SELECT * FROM e
),
g AS (
	SELECT r1_id,
		   ST_Union(r1_startpoint_new) AS startpoint_new, -- si un nouveau startpoint_new n'a pas été attribué a r1, alors on reprend le startpoint originel
		   ST_Union(r1_endpoint_new) AS endpoint_new -- si un nouveau endpoint_new n'a pas été attribué a r1, alors on reprend le endpoint originel
	  FROM f
	 GROUP BY r1_id, r1_geom -- les intersections entre plus de deux r produisent plusieurs relations r1/r2,
	 						 -- il faut donc fusionner et regrouper par rid toutes les nouvelles extrémités produites
)
UPDATE r_extremites re
   SET startpoint_new = g.startpoint_new,
	   endpoint_new = g.endpoint_new
  FROM g
 WHERE re.id = g.r1_id;


---------- MISE À JOUR DES geom_new DES r 100% UNIQUES DONT AU MOINS UNE EXTRÉMITÉ A ÉTÉ DÉPLACÉE
---------- utilisation des extrémités mises à jour pour remplacer la ou les extrémités qui ont été déplacées
WITH
a AS ( -- sélectionne les r dont seul le point de départ a été modifié
	SELECT id,
		   ST_SetPoint(geom, 0, startpoint_new) AS geom -- remplacement du point de départ du r par startpoint_new
	  FROM r_extremites
	 WHERE geom_new IS NULL
	   AND ST_GeometryType(startpoint_new) = 'ST_Point' -- vérification que startpoint_new existe et n'est pas un MultiPoint
	   AND endpoint_new IS NULL							-- exclut les r dont le point d'arrivée a été modifié
),
b AS ( -- sélectionne les r dont seul le point d'arrivée a été modifié
	SELECT id,
		   ST_SetPoint(geom, -1, endpoint_new) AS geom -- remplacement du point d'arrivée du r par endpoint_new
	  FROM r_extremites
	 WHERE geom_new IS NULL
	   AND ST_GeometryType(endpoint_new) = 'ST_Point' -- vérification que endpoint_new existe et n'est pas un MultiPoint
	   AND startpoint_new IS NULL					  -- exclut les r dont le point de départ a été modifié
),
c AS ( -- sélectionne les r dont les deux extrémités ont été modifiées
	SELECT id,
		   ST_SetPoint(ST_SetPoint(geom, -1, endpoint_new), 0, startpoint_new) AS geom -- remplacement des deux extrémités
	  FROM r_extremites
	 WHERE geom_new IS NULL
	   AND ST_GeometryType(startpoint_new) = 'ST_Point' -- vérification que startpoint_new existe et n'est pas un MultiPoint
	   AND ST_GeometryType(endpoint_new) = 'ST_Point' -- vérification que endpoint_new existe et n'est pas un MultiPoint
),
d AS (
	SELECT * FROM a
	 UNION ALL
	SELECT * FROM b
	 UNION ALL
	SELECT * FROM c
)
UPDATE core_path_wip_new cp_wn
   SET geom_new = d.geom
  FROM d
 WHERE d.id = cp_wn.id;


---------- MISE À JOUR DES geom_new DES r 100% UNIQUES ET DONT LA GÉOMÉTRIE N'EST PAS À MODIFIER
UPDATE core_path_wip_new
   SET geom_new = geom
 WHERE geom_new IS NULL;

---------- CRÉATION DE NOUVEAUX TRONÇONS CORRESPONDANT AUX i 100% UNIQUES
INSERT INTO core_path_wip_new (geom_new, structure_id, eid)
SELECT geom,
	   structure_id,
	   id
  FROM importe i
 WHERE NOT EXISTS (SELECT iid
 					 FROM decision_inner di
 					WHERE di.iid = i.id);




---------- MISE À JOUR DES COLONNES eid ET comments
---------- on se sert de la colonne eid qui a jusqu'ici été remplie avec decision_inner.iid,
---------- soit l'identifiant automatique de importe (donc un identifiant artificiel)
---------- car eid est absent de cette table decision_inner.
---------- Il faut donc refaire le lien avec la table importe et importer le réel eid, ainsi que les commentaires
---------- Idéalement il faudrait réécrire le script en intégrant directement les réels eid sans passer par cette étape
WITH a AS (
	SELECT id,
		   UNNEST(string_to_array(eid, ',')) AS eid -- étend l'array créée à partir du champ eid 
	  FROM core_path_wip_new
	 WHERE geom_modified = 'oui' -- tronçon issu de r dont la géométrie a été modifiée et dont on veut extraire l'eid issu de i
	 	 OR geom is NULL          -- si pas de geom, alors c'est un tronçon nouveau issu de importe, on veut aussi extraire son eid
),
b AS (
	SELECT a.id,
		   string_agg(i.eid::varchar, ', ') AS eid,
		   layer
	  FROM importe i
	  JOIN a
	    ON a.eid::integer = i.id
	 GROUP BY a.id, layer
),
c AS (
	SELECT id,
		   string_agg(eid::varchar, ', ') AS eid, -- agrégation des eid pour chaque tronçon de core_path_wip_new
		   'couche(s) ' || string_agg(layer::varchar, ', ') AS "comments" -- création du commentaire avec le nom de la couche/du fichier (il peut y en avoir plusieurs)
	  FROM b
	 GROUP BY id
)
UPDATE core_path_wip_new cp_wn
   SET eid = c.eid,
       "comments" = concat((cp_wn."comments" || ' ; '), c."comments") -- concaténation de l'ancien commentaire et du nouveau pour ne pas perdre d'information
  FROM c
 WHERE c.id = cp_wn.id;
