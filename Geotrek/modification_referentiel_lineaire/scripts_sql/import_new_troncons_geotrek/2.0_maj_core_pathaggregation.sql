---------- CRÉATION D'UNE TABLE RETROUVANT LES core_pathaggregation À INSÉRER
---------- pour les tronçons ayant été découpés lors de la mise à jour de core_path
---------- le but est d'identifier les core_path issus d'un split grâce aux champs
---------- qu'ils partagent encore avec l'autre moitié du split
CREATE TABLE core_pathaggregation_to_insert AS
WITH
a AS ( -- OBTENTION DU NUMÉRO D'ORDRE MAX POUR UN core_path ET UN core_topology DONNÉS
	SELECT max("order") AS "order",
		   topo_object_id,
		   path_id
	  FROM core_pathaggregation cp
	 GROUP BY topo_object_id, path_id
),
b AS (
	SELECT cp.*
	  FROM core_pathaggregation cp
	  JOIN a
	    ON a."order" = cp."order"
	   AND a.topo_object_id = cp.topo_object_id
),
c AS (-- JOINTURE INTERNE POUR RETROUVER LES core_path ISSUS D'UN SPLIT
	SELECT cp1.id AS id1,
		   cp2.id AS id2
	  FROM core_path cp1
	 INNER JOIN core_path cp2
		ON cp1."comments" = cp2."comments" -- SI cp1 ET cp2 SONT ISSUS D'UN SPLIT, ILS ONT LES MÊMES VALEURS ATTRIBUTAIRES
		   AND cp1.eid = cp2.eid
		   AND cp2."name" IS NOT NULL -- SI "name" EST NUL, C'EST QUE LE core_path EST UN NOUVEAU core_path ISSU DU RÉSEAU IMPORTÉ
		   AND ST_Touches(cp1.geom, cp2.geom) -- SI cp1 ET cp2 SONT ISSUS D'UN SPLIT, ILS SE TOUCHENT PROBABLEMENT
		   AND cp1.id != cp2.id
		   AND cp1.id IN (SELECT path_id FROM core_pathaggregation cp) -- ON NE VEUT TROUVER QUE LES cp1 QUI SONT DÉJÀ UTILISÉS PAR UN core_topology
),
d AS (
	SELECT id2 AS path_id, -- ON NE CONSERVE QUE LE core_path ISSU DU SPLIT MAIS ABSENT DE core_pathaggregation
		   start_position,
		   end_position,
		   CASE
			WHEN start_position = 0 OR end_position = 1
			THEN b."order" + 1
			WHEN end_position = 0 OR start_position = 1
			THEN b."order" - 1
			ELSE NULL
		   END AS "order",
		   topo_object_id
	  FROM c
	  JOIN b
	    ON id1 = b.path_id
	   AND id2 NOT IN (SELECT id1 FROM c)
	 GROUP BY id2, start_position, end_position, "order", topo_object_id
)
-- CRÉATION DE POINTS DE PASSAGE POUR CHACUN DES core_path AJOUTÉS À core_pathaggregation
-- AFIN D'ÉVITER QU'ILS SOIENT DÉLAISSÉS PAR LE ROUTAGE AUTOMATIQUE DU CHEMIN LE PLUS COURT
-- LORSQU'ON CLIQUERA SUR "MODIFIER" SUR UN ITINÉRAIRE
SELECT path_id,
	   start_position,
	   (start_position + end_position)/2 AS end_position,
	   "order",
	   'a' AS suborder,
	   topo_object_id
  FROM d
 UNION
SELECT path_id,
	   (start_position + end_position)/2 AS start_position,
	   (start_position + end_position)/2 AS end_position,
	   "order",
	   'b' AS suborder,
	   topo_object_id
  FROM d
 UNION
SELECT path_id,
	   (start_position + end_position)/2 start_position,
	   end_position,
	   "order",
	   'c' AS suborder,
	   topo_object_id
  FROM d;


---------- CRÉATION D'UNE NOUVELLE TABLE core_pathaggregation POUR REMPLACER L'ACTUELLE
---------- le but est d'intégrer le contenu de la table core_pathaggregation_to_insert
---------- ainsi que de créer des points de passage pour chacun des tronçons ayant été créés
---------- lors de la mise à jour des core_path, pour la même raison qu'au-dessus
CREATE TABLE core_pathaggregation_new AS
WITH
a AS (
	SELECT * FROM (SELECT *, TRUE AS split FROM core_pathaggregation_to_insert ORDER BY topo_object_id, "order", suborder, path_id) AS ordered
	 UNION ALL
	SELECT path_id, start_position, end_position, "order", NULL::varchar AS suborder, topo_object_id, FALSE AS split
	  FROM core_pathaggregation
	 WHERE topo_object_id IN (SELECT id FROM core_topology WHERE kind = 'TREK')
),
b AS (
	SELECT path_id,
		   topo_object_id
	  FROM a
	  JOIN core_path cp
	    ON cp.date_insert > 'yesterday'::TIMESTAMP -- FILTRE SUR LA DATE POUR NE CONSERVER QUE LES NOUVEAUX core_path
	   AND cp.id = a.path_id
	 GROUP BY path_id, topo_object_id
	HAVING count(path_id) = 1
),
c AS ( -- CRÉATION DES POINTS DE PASSAGE
	SELECT a.path_id,
		   start_position,
		   (start_position + end_position)/2 AS end_position,
		   "order",
	   	   'a' AS suborder,
		   a.topo_object_id,
		   FALSE AS split
	  FROM a
	  JOIN b
	    ON a.path_id = b.path_id
	   AND a.topo_object_id = b.topo_object_id
	 UNION ALL
	SELECT a.path_id,
		   (start_position + end_position)/2 AS start_position,
		   (start_position + end_position)/2 AS end_position,
		   "order",
	   	   'b' AS suborder,
		   a.topo_object_id,
		   FALSE AS split
	  FROM a
	  JOIN b
	    ON a.path_id = b.path_id
	   AND a.topo_object_id = b.topo_object_id
	 UNION ALL
	SELECT a.path_id,
		   (start_position + end_position)/2 start_position,
		   end_position,
		   "order",
	   	   'c' AS suborder,
		   a.topo_object_id,
		   FALSE AS split
	  FROM a
	  JOIN b
	    ON a.path_id = b.path_id
	   AND a.topo_object_id = b.topo_object_id
),
d AS (
	SELECT *
	  FROM c
	 UNION ALL
	SELECT *
	  FROM a
	 WHERE a.path_id NOT IN (SELECT path_id FROM c)
	 ORDER BY topo_object_id, "order"
)
-- ATTRIBUTION D'UN NOUVEAU NUMÉRO D'ORDRE EN GROUPANT PAR topo_object_id
SELECT *,
	   row_number() OVER (PARTITION BY topo_object_id ORDER BY "order", split, suborder) -1 AS new_order
  FROM d
 UNION ALL
SELECT path_id, start_position, end_position, "order", NULL::varchar AS suborder, topo_object_id, NULL AS split, "order" AS new_order
  FROM core_pathaggregation
 WHERE topo_object_id NOT IN (SELECT id FROM core_topology WHERE kind = 'TREK');

---------- DÉSACTIVATION DES TRIGGERS DE CORE_PATHAGGREGATION
ALTER TABLE core_pathaggregation DISABLE TRIGGER USER;

---------- SUPPRESSION DU CONTENU DE CORE_PATHAGGREGATION
DELETE FROM core_pathaggregation;

---------- INSERTION DU NOUVEAU CONTENU DE CORE_PATHAGGREGATION
INSERT INTO core_pathaggregation (
			path_id, start_position, end_position, "order", topo_object_id
			)
	 SELECT path_id, start_position, end_position, new_order, topo_object_id
	   FROM core_pathaggregation_new;

---------- ACTIVATION DES TRIGGERS DE CORE_PATHAGGREGATION
ALTER TABLE core_pathaggregation ENABLE TRIGGER USER;


---------- REND VISIBLE TOUS LES CORE_PATH UTILISÉS DANS CORE_PATHAGGREGATION
UPDATE core_path cp SET visible = TRUE
WHERE cp.id IN (SELECT path_id FROM core_pathaggregation);
