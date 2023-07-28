-------------------- ESTIMATION DU NOMBRE D'ERREURS À SUPERVISER

---------- CRÉATION D'INDEX POUR ACCÉLÉRER LES CALCULS
DROP INDEX IF EXISTS core_path_wip_new_geom_new_idx;

CREATE INDEX core_path_wip_new_geom_new_idx
           ON core_path_wip_new
        USING GIST(geom_new);

CLUSTER core_path_wip_new
  USING core_path_wip_new_geom_new_idx;


DROP INDEX IF EXISTS core_path_wip_new_geom_idx;

CREATE INDEX core_path_wip_new_geom_idx
           ON core_path_wip_new
        USING GIST(geom);

CLUSTER core_path_wip_new
  USING core_path_wip_new_geom_idx;

---------- CRÉATION D'UNE TABLE POUR ACCUEILLIR LES DÉCOMPTES
CREATE TABLE IF NOT EXISTS erreurs_compte
(st_crosses integer,
 st_overlaps_contains integer,
 st_isvalid integer,
 st_issimple integer,
 st_geometrytype integer,
 ligne_trop_courte integer,
 trop_court_extremite_libre integer,
 separes integer,
 troncon_isole integer,
 memes_extremites integer,
 se_touchent_presque integer,
 total integer,
 date timestamp);


---------- TRANSFORMATION DES POINTS EN FAUSSES LIGNES
---------- permet de les visualiser dans un SIG
UPDATE core_path_wip_new
   SET geom_new = ST_MakeLine(geom_new, ST_Translate(geom_new, 5, 5)),
       erreur = 'ligne_trop_courte'
 WHERE ST_GeometryType(geom_new) = 'ST_Point';

---------- EXTENSION DES LIGNES DE MOINS DE 1m POUR POUVOIR LES CORRIGER VISUELLEMENT
UPDATE core_path_wip_new
   SET geom_new = ST_AddPoint(geom_new, ST_GeometryN(ST_Points(ST_Buffer(geom_new, 5)), 1)),
       erreur = 'ligne_trop_courte'
 WHERE ST_Length(geom_new) < 1;


---------- DÉTECTION DE DIFFÉRENTS TYPES D'ERREURS
DROP TABLE IF EXISTS erreurs_liste;

CREATE TABLE erreurs_liste AS
WITH
a AS ( -- tronçons qui en croisent d'autres
    SELECT DISTINCT cp_wn1.id,
           'st_crosses' AS erreur
      FROM core_path_wip_new cp_wn1
            INNER JOIN core_path_wip_new cp_wn2
             ON ST_Crosses(cp_wn1.geom_new, cp_wn2.geom_new)
                   AND cp_wn1.id != cp_wn2.id),
b AS ( -- tronçons qui en chevauchent d'autres
    SELECT DISTINCT cp_wn1.id,
           'st_overlaps_contains_within' AS erreur
      FROM core_path_wip_new cp_wn1
            INNER JOIN core_path_wip_new cp_wn2
            ON (ST_Overlaps(cp_wn1.geom_new, cp_wn2.geom_new)
                OR ST_Contains(cp_wn1.geom_new, cp_wn2.geom_new)
                OR ST_Within(cp_wn1.geom_new, cp_wn2.geom_new))
               AND cp_wn1.id != cp_wn2.id),
c AS ( -- tronçons dont la géométrie n'est pas valide
    SELECT id,
           'st_isvalid' AS erreur
      FROM core_path_wip_new
     WHERE NOT ST_IsValid(geom_new)),
d AS ( -- tronçons qui s'auto-intersectent
    SELECT id,
           'st_issimple' AS erreur
      FROM core_path_wip_new
     WHERE NOT ST_IsSimple(geom_new)),
e AS ( -- tronçons multilinestring
    SELECT id,
           'st_geometrytype' AS erreur
      FROM core_path_wip_new
     WHERE NOT ST_GeometryType(geom_new) = 'ST_LineString'),
f AS ( -- tronçons trop courts
    SELECT id,
           'ligne_trop_courte' AS erreur
      FROM core_path_wip_new
     WHERE erreur = 'ligne_trop_courte'
           OR ST_Length(geom_new) < 1),
g AS ( -- tronçons courts dont une extrémité n'est pas reliée
    SELECT id,
           'trop_court_extremite_libre' AS erreur
      FROM core_path_wip_new cp_wn1
     WHERE ST_Length(cp_wn1.geom_new) < 5
       AND (NOT EXISTS
                (SELECT 1
                   FROM core_path_wip_new cp_wn2
                  WHERE cp_wn1.id != cp_wn2.id
                    AND ST_Intersects(ST_StartPoint(cp_wn1.geom_new), cp_wn2.geom_new))
            OR
            NOT EXISTS
                (SELECT 1
                   FROM core_path_wip_new cp_wn3
                  WHERE cp_wn1.id != cp_wn3.id
                    AND ST_Intersects(ST_EndPoint(cp_wn1.geom_new), cp_wn3.geom_new)))
),
h AS (  -- tronçons qui se touchaient mais ne se touchent plus
    SELECT DISTINCT cp_wn1.id,
           'separes' AS erreur
      FROM core_path_wip_new cp_wn1
           INNER JOIN core_path_wip_new cp_wn2
           ON ST_Touches(cp_wn1.geom, cp_wn2.geom)
           AND NOT ST_Touches(cp_wn1.geom_new, cp_wn2.geom_new)),
i AS ( -- tronçons isolés qui ne touchent aucun autre tronçon
     SELECT cp_wn1.id,
            'troncon_isole' AS erreur
       FROM core_path_wip_new cp_wn1
      WHERE NOT EXISTS
            (SELECT 1
               FROM core_path_wip_new cp_wn2
              WHERE cp_wn1.id != cp_wn2.id
                AND ST_INTERSECTS(cp_wn1.geom_new, cp_wn2.geom_new))),
j AS ( -- tronçons qui ont les mêmes extrémités et sont entièrement contenus dans un buffer de 5m l'un de l'autre (sûrement des doublons)
     SELECT DISTINCT cp_wn1.id,
            'memes_extremites' AS erreur
       FROM core_path_wip_new cp_wn1
            INNER JOIN core_path_wip_new cp_wn2
            ON ST_Equals(ST_Boundary(cp_wn1.geom_new), ST_Boundary(cp_wn2.geom_new))
               AND cp_wn1.id != cp_wn2.id
               AND ST_Contains(ST_Buffer(cp_wn2.geom_new, 5), cp_wn1.geom_new)
               AND ST_Contains(ST_Buffer(cp_wn1.geom_new, 5), cp_wn2.geom_new)
              ORDER BY cp_wn1.id),
k AS ( -- tronçons se touchant soupçonneusement presque (moins de 1m)
     SELECT DISTINCT cp_wn1.id,
            'se_touchent_presque' AS erreur
       FROM core_path_wip_new cp_wn1
        INNER JOIN core_path_wip_new cp_wn2
           ON ST_DWithin(ST_Boundary(cp_wn1.geom_new), cp_wn2.geom_new, 1)
          AND NOT ST_Intersects(cp_wn1.geom_new, cp_wn2.geom_new))
SELECT * FROM a
  UNION ALL
SELECT * FROM b
  UNION ALL
SELECT * FROM c
  UNION ALL
SELECT * FROM d
  UNION ALL
SELECT * FROM e
  UNION ALL
SELECT * FROM f
  UNION ALL
SELECT * FROM g
  UNION ALL
SELECT * FROM h
  UNION ALL
SELECT * FROM i
  UNION ALL
SELECT * FROM j
  UNION ALL
SELECT * FROM k;


---------- DÉNOMBREMENT DES ERREURS ET INSERTION DANS erreurs_compte
INSERT INTO erreurs_compte (st_crosses, st_overlaps_contains, st_isvalid,
                              st_issimple, st_geometrytype, ligne_trop_courte,
                              trop_court_extremite_libre, separes, troncon_isole,
                              memes_extremites, se_touchent_presque, total, "date")
SELECT SUM(CASE WHEN erreur = 'st_crosses' THEN 1 ELSE 0 END) AS st_crosses,
       SUM(CASE WHEN erreur = 'st_overlaps_contains_within' THEN 1 ELSE 0 END) AS st_overlaps_contains_within,
       SUM(CASE WHEN erreur = 'st_isvalid' THEN 1 ELSE 0 END) AS st_isvalid,
       SUM(CASE WHEN erreur = 'st_issimple' THEN 1 ELSE 0 END) AS st_issimple,
       SUM(CASE WHEN erreur = 'st_geometrytype' THEN 1 ELSE 0 END) AS st_geometrytype,
       SUM(CASE WHEN erreur = 'ligne_trop_courte' THEN 1 ELSE 0 END) AS ligne_trop_courte,
       SUM(CASE WHEN erreur = 'trop_court_extremite_libre' THEN 1 ELSE 0 END) AS trop_court_extremite_libre,
       SUM(CASE WHEN erreur = 'separes' THEN 1 ELSE 0 END) AS separes,
       SUM(CASE WHEN erreur = 'troncon_isole' THEN 1 ELSE 0 END) AS troncon_isole,
       SUM(CASE WHEN erreur = 'memes_extremites' THEN 1 ELSE 0 END) AS memes_extremites,
       SUM(CASE WHEN erreur = 'se_touchent_presque' THEN 1 ELSE 0 END) AS se_touchent_presque,
       count(DISTINCT id) AS total,
       current_timestamp(0) AS "date"
  FROM erreurs_liste;

---------- MISE À JOUR DU CHAMP erreur DE core_path_wip_new
---------- afin de visualiser les tronçons problématiques dans QGIS
UPDATE core_path_wip_new cp_wn
   SET erreur = liste.erreur
  FROM erreurs_liste liste
 WHERE cp_wn.id = liste.id
   AND cp_wn.erreur IS DISTINCT FROM 'ligne_trop_courte'; -- évite d'écraser cette erreur avec une autre valeur



---------- AIDE À LA CORRECTION SUR QGIS
---------- création d'une fonction appelée ensuite par le trigger
CREATE OR REPLACE FUNCTION trigger_geom_new()
   RETURNS TRIGGER
   LANGUAGE PLPGSQL
AS $$
DECLARE
    inversed boolean;
BEGIN

    NEW.geom_new := ST_LineMerge(NEW.geom_new); -- transforme les géometries curve créées par QGIS en LineStrings habituelles
                                                -- et fusionne les MultiLineStrings en LineStrings 

    SELECT ST_Equals( -- si l'extrémité de la geom_new corrigée la plus proche du point d'arrivée de geom est
                      -- son point de départ, alors il faut inverser le sens de geom_new
                ST_StartPoint(NEW.geom_new),
                ST_ClosestPoint(ST_Boundary(NEW.geom_new),
                                ST_EndPoint(cp_wn.geom)
                )
           )
      INTO inversed
      FROM core_path_wip_new cp_wn
     WHERE NEW.id = cp_wn.id;

      IF inversed THEN
          NEW.geom_new := ST_Reverse(NEW.geom_new);
      END IF;

    NEW.erreur :=  (
        WITH a AS -- réévalue si les tronçons modifiés répondent à une condition d'erreur
               (SELECT CASE
                    WHEN ST_Crosses(NEW.geom_new, cp_wn.geom_new)
                    THEN 'st_crosses'
                    WHEN ST_Overlaps(NEW.geom_new, cp_wn.geom_new)
                         OR ST_Contains(NEW.geom_new, cp_wn.geom_new)
                         OR ST_Within(NEW.geom_new, cp_wn.geom_new)
                    THEN 'st_overlaps_contains_within'
                    WHEN NOT ST_IsValid(NEW.geom_new)
                    THEN 'st_isvalid'
                    WHEN NOT ST_IsSimple(NEW.geom_new)
                    THEN 'st_issimple'
                    WHEN NOT ST_GeometryType(NEW.geom_new) = 'ST_LineString'
                    THEN 'st_geometrytype'
                    WHEN ST_Length(NEW.geom_new) < 1
                    THEN 'ligne_trop_courte'
                    WHEN ST_Length(NEW.geom_new) < 5
                         AND (NOT EXISTS (SELECT 1
                                            FROM core_path_wip_new cp_wn2
                                           WHERE NEW.id != cp_wn2.id
                                                 AND ST_Intersects(ST_StartPoint(NEW.geom_new), cp_wn2.geom_new))
                              OR
                              NOT EXISTS (SELECT 1
                                            FROM core_path_wip_new cp_wn3
                                           WHERE NEW.id != cp_wn3.id
                                                 AND ST_Intersects(ST_EndPoint(NEW.geom_new), cp_wn3.geom_new)))
                    THEN 'trop_court_extremite_libre'
                    WHEN ST_Touches(OLD.geom, cp_wn.geom)
                            AND NOT ST_Touches(NEW.geom_new, cp_wn.geom_new)
                    THEN 'separes'
                    WHEN NOT EXISTS (SELECT 1
                                       FROM core_path_wip_new cp_wn2
                                      WHERE NEW.id != cp_wn2.id
                                            AND ST_Intersects(NEW.geom_new, cp_wn2.geom_new))
                    THEN 'troncon_isole'
                    WHEN ST_Equals(ST_Boundary(NEW.geom_new), ST_Boundary(cp_wn2.geom_new))
                         AND NEW.id != cp_wn2.id
                         AND ST_Contains(ST_Buffer(cp_wn2.geom_new, 5), NEW.geom_new)
                         AND ST_Contains(ST_Buffer(NEW.geom_new, 5), cp_wn2.geom_new)
                    THEN 'memes_extremites'
                    WHEN ST_DWithin(ST_Boundary(NEW.geom), tn2.geom, 1)
                         AND NOT ST_Intersects(NEW.geom, tn2.geom)
                    THEN 'se_touchent_presque'
                    ELSE NULL::varchar
                    END AS erreur
              FROM core_path_wip_new cp_wn
             WHERE OLD.id != cp_wn.id)
        SELECT *
          FROM a
         GROUP BY erreur
         ORDER BY count(erreur) DESC
         LIMIT 1 -- en cas d'erreurs multiples, ne prend que celle qui ressort le plus souvent
       );

    NEW.supervised := TRUE;

    RETURN NEW;
END;
$$;


---------- CRÉATION DU TRIGGER
DROP TRIGGER IF EXISTS trigger_geom_new ON core_path_wip_new;

CREATE TRIGGER trigger_geom_new
  BEFORE UPDATE OF geom_new ON core_path_wip_new -- le trigger agit avant la mise à jour effective de la géométrie dans la base, permet d'utiliser la syntaxe new/old
  FOR EACH ROW
  EXECUTE PROCEDURE trigger_geom_new();



---------- VISUALISATION DU NOMBRE D'ERREURS
SELECT * FROM erreurs_compte;
