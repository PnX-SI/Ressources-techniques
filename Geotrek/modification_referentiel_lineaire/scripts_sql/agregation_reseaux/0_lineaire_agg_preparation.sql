--- TEST : LES GÉOMÉTRIES DES TABLES IMPORTE ET REFERENCE DOIVENT TOUTES ÊTRE DES LINESTRING
--		SINON LES OPÉRATIONS D'AGRÉGATION NE PEUVENT PAS AVOIR LIEU
DO $$
BEGIN
	IF EXISTS(
		SELECT *
		FROM importe i
		WHERE NOT ST_GeometryType(geom) = 'ST_LineString'
	) THEN
  		RAISE EXCEPTION 'Les géométries de la table importe doivent être de type LineString' ;
  	END IF;
END $$;

DO $$
BEGIN
	IF EXISTS(
		SELECT *
		FROM reference r
		WHERE NOT ST_GeometryType(geom) = 'ST_LineString'
	) THEN
  		RAISE EXCEPTION 'Les géométries de la table reference doivent être de type LineString' ;
  	END IF;
END $$;



---------- CREATION DE LA TABLE DES CAS
---------- description des cinq types de cas
DROP TABLE IF EXISTS cas;

CREATE TABLE cas (
	id 			   SERIAL PRIMARY KEY,
	description    varchar
);

INSERT INTO cas(description)
VALUES ('100% doublon'),
	   ('Doublon partiel continu'),
	   ('Doublon partiel discontinu'),
	   ('Unique partiel'),
	   ('100% unique');


---------- CREATION INDEX SPATIAUX SUR reference ET importe
---------- accélère les requêtes spatiales
DROP INDEX IF EXISTS reference_geom_idx;

CREATE INDEX reference_geom_idx
 		  ON reference
 	   USING GIST(geom);

CLUSTER reference
  USING reference_geom_idx;


DROP INDEX IF EXISTS importe_geom_idx;

CREATE INDEX importe_geom_idx
  		  ON importe
  	   USING GIST(geom);

CLUSTER importe
  USING importe_geom_idx;