# Nettoyage des réseaux

Sommaire :
  - [Nettoyage de la base de données Geotrek](#nettoyage-de-la-base-de-données-geotrek)
  - [Nettoyage des données à intégrer](#nettoyage-des-données-à-intégrer)


L'objectif de cette partie est de présenter les principes et quelques techniques permettant d'avoir des données de qualité au sens topologique. Si vos données sont parfaites ce chapitre ne vous concerne pas.


## Nettoyage de la base de données Geotrek

Le but est de nettoyer sa base de données Geotrek de tous les artéfacts créés au fil des ans, des incohérences topologiques, etc. Pour cela, plusieurs requêtes SQL peuvent nous aider (ne pas oublier de créer un index spatial sur la colonne `geom` de la table `public.core_path` afin d'accélérer les requêtes) :

Identifier les tronçons qui en croisent d'autres sans être découpés à l'intersection :
``` sql
-- lines crossing another one
SELECT DISTINCT cp1.id,
       'st_crosses' AS error
  FROM core_path cp1
       INNER JOIN core_path cp2
       ON ST_Crosses(cp1.geom, cp2.geom)
          AND cp1.id != cp2.id;
```

Identifier les tronçons qui en chevauchent d'autres :
``` sql
-- lines overlapping, containing or being within another one
SELECT DISTINCT cp1.id,
       'st_overlaps_contains_or_within' AS error
  FROM core_path cp1
       INNER JOIN core_path cp2
       ON cp1.id != cp2.id
          AND (ST_Overlaps(cp1.geom, cp2.geom)
               OR ST_Contains(cp1.geom, cp2.geom)
               OR ST_Within(cp1.geom, cp2.geom));
```

Identifier les tronçons dont la géométrie n'est pas valide :
``` sql
-- lines with a non-valid geometry (cf. https://postgis.net/docs/using_postgis_dbmanagement.html#OGC_Validity)
SELECT id,
       'st_isvalid' AS error
  FROM core_path
 WHERE NOT ST_IsValid(geom);
```

Identifier les tronçons qui s'auto-intersectent :
``` sql
-- self-intersecting lines (normally already detected by previous validity test)
SELECT id,
       'st_issimple' AS error
  FROM core_path
 WHERE NOT ST_IsSimple(geom);
```

Identifier les tronçons qui ne sont pas une LineString :
``` sql
-- non linestring geometries
SELECT id,
       'st_geometrytype' AS error
  FROM core_path
 WHERE NOT ST_GeometryType(geom) = 'ST_LineString';
```


Toutes ces requêtes devraient renvoyer extrêmement peu de tronçons, car Geotrek-admin effectue déjà un certain nombre de ces vérifications au moment de la création d'un tronçon. Cependant, il est toujours utile d'en avoir le coeur net.

Cherchons maintenant d'autres types de situations que nous voudrions corriger :

Identifier les tronçons en doublon :
``` sql
-- lines strictly equal to another one
SELECT cp1.id,
       cp2.id,
       'st_equals' AS error
  FROM core_path cp1
       INNER JOIN core_path cp2
       ON ST_Equals(cp1.geom, cp2.geom)
          AND cp1.id != cp2.id;
```

Identifier les tronçons isolés du reste du réseau :
``` sql
-- isolated lines, that don't touch any other line
SELECT cp1.id,
       'isolated_line' as error
  FROM core_path cp1
 WHERE NOT EXISTS
        (SELECT 1
           FROM core_path cp2
          WHERE cp1.id != cp2.id
            AND ST_INTERSECTS(cp1.geom, cp2.geom));
```

Identifier les tronçons de moins de 1m (à priori peu pertinents, et pouvant poser problème lors des opérations à suivre) :
``` sql
-- -- lines measuring less than 1 meter
SELECT id,
       'short_line' as error
  FROM core_path
 WHERE ST_Length(geom) < 1;
```

Identifier les tronçons dont les deux extrémités sont identiques, et qui sont mutuellement compris dans un tampon de 5m autour de l'autre. Il s'agit souvent de résidus d'opérations de modification de tronçons, qui représentent en fait la même voie sur le terrain :
``` sql
-- lines that have the same boundaries and are fully contained within 5 meters of each other (surely duplicates)
SELECT cp1.id,
       cp2.id,
       'same_boundaries' AS error
       FROM core_path cp1
            INNER JOIN core_path cp2
            ON ST_Equals(ST_Boundary(cp1.geom), ST_Boundary(cp2.geom))
               AND cp1.id != cp2.id
               AND ST_Contains(ST_Buffer(cp2.geom, 5), cp1.geom)
               AND ST_Contains(ST_Buffer(cp1.geom, 5), cp2.geom)
              ORDER BY cp1.id;
```

Identifier les tronçons courts et dont une extrémité n'est reliée à aucun autre tronçon. Ce sont rarement des tronçons pertinents sur le terrain :
``` sql
-- lines that have a boundary not shared with any other line and measure less than 5 meters
SELECT DISTINCT cp1.id,
       'short_dead_end' AS error
  FROM core_path cp1
 WHERE ST_Length(cp1.geom) < 5
       AND (NOT EXISTS
            (SELECT 1
               FROM core_path cp2
              WHERE cp1.id != cp2.id
                    AND ST_Intersects(ST_StartPoint(cp1.geom), cp2.geom))
            OR
            NOT EXISTS
            (SELECT 1
               FROM core_path cp3
              WHERE cp1.id != cp3.id
                    AND ST_Intersects(ST_EndPoint(cp1.geom), cp3.geom))
           );
```


Et enfin, les tronçons qui se touchent presque, ce qui pourrait signifier qu'il leur manque un peu de longueur pour rentrer en contact et créer une intersection existant réellement sur le terrain :
``` sql
-- lines suspiciously almost touching each other (1 meter tolerance)
SELECT cp1.id,
       cp2.id,
       'almost_touching' AS error
  FROM core_path cp1
       INNER JOIN core_path cp2
       ON ST_DWithin(ST_Boundary(cp1.geom), cp2.geom, 1)
          AND NOT ST_Intersects(cp1.geom, cp2.geom);
```
Ici la tolérance est placée à 1 mètre, mais elle peut être modifiée à souhait.

Le nettoyage peut ensuite se faire directement en base de données, ou bien via un SIG comme QGIS en créant la colonne `error` dans la table et en appliquant une symbologie catégorisée sur celle-ci.

Si le choix de la méthode base de données est fait, on peut utiliser l'extension `topology` de PostGIS pour automatiser la correction d'un certain nombre des erreurs décrites. Voir ce billet de blog de Mathieu Leplâtre pour la méthode : [http://blog.mathieu-leplatre.info/use-postgis-topologies-to-clean-up-road-networks.html]().
Attention, les résultats de ces opérations sont donc non maîtrisés, au contraire de la méthode manuelle qui est plus longue mais vous assure un nettoyage tel qu'il correspond à votre vision et vos besoins.


## Nettoyage des données à intégrer

Les données reçues devraient dans l'idéal déjà se soumettre à des principes topologiques fondamentaux, si ce n'est pas le cas un nettoyage manuel est fortement recommandé :
- deux lignes différentes ne doivent pas se croiser, elles peuvent seulement se toucher aux extrémités => Si des lignes ne répondent pas à cette condition, il faut découper chaque ligne de part et d'autre de l'intersection ;
- une ligne ne peut s'auto-croiser => Si c'est le cas, il faut la découper en plusieurs lignes distinctes ;
- une géométrie ou un tronçon doit être de type LineString (et pas MultiLineString, Point, GeometryCollection...) => Si ce n'est pas le cas, il faut la décomposer (MultiLineString, GeometryCollection) ou la supprimer (Point).

Seule exception au nettoyage manuel : une ligne touchée en son milieu par l'extrémité d'une autre ligne n'a pas besoin d'être découpée. C'est une erreur topologique, car les contacts entre lignes ne devraient se faire qu'en leurs extrémités respectives, mais les triggers de Geotrek-admin se chargeront de ce découpage, ce qui nous économise du temps.

De manière plus subjective, pour garantir une qualité optimale du réseau, il est intéressant que :
- une intersection sur le terrain ne soit représentée que par une seule intersection dans le réseau => éviter de multiplier les intersections à quelques dizaines de centimètres d'écart (souvent le cas aux carrefours);
- des rues ou chemins qui sont connectées sur le terrain le soient aussi dans le réseau => éviter les "trous" de quelques centimètres qui donnent visuellement l'impression que les deux tronçons sont connectés jusqu'à ce qu'on zoome assez.

Pour cela, les mêmes requêtes spatiales que précédemment sont applicables, ici rassemblées en une seule pour plus de praticité (après création d'un index spatial pour plus de rapidité) :

``` sql
WITH
a AS ( -- lines crossing another one
     SELECT DISTINCT tn1.id,
            'st_crosses' AS error
       FROM "table_name" tn1
            INNER JOIN "table_name" tn2
            ON ST_Crosses(tn1.geom, tn2.geom)
               AND tn1.id != tn2.id),
b AS ( -- lines overlapping, containing or being within another one
     SELECT DISTINCT tn1.id,
            'st_overlaps_contains_or_within' AS error
       FROM "table_name" tn1
            INNER JOIN "table_name" tn2
            ON tn1.id != tn2.id
               AND (ST_Overlaps(tn1.geom, tn2.geom)
                    OR ST_Contains(tn1.geom, tn2.geom)
                    OR ST_Within(tn1.geom, tn2.geom)),
c AS ( -- lines with a non-valid geometry (cf. https://postgis.net/docs/using_postgis_dbmanagement.html#OGC_Validity)
     SELECT id,
            'st_isvalid' AS error
       FROM "table_name"
      WHERE NOT ST_IsValid(geom)),
d AS ( -- self-intersecting lines (normally already detected by previous validity test)
     SELECT id,
            'st_issimple' AS error
       FROM "table_name"
      WHERE NOT ST_IsSimple(geom)),
e AS ( -- non linestring geometries
     SELECT id,
            'st_geometrytype' AS error
       FROM "table_name"
      WHERE NOT ST_GeometryType(geom) = 'ST_LineString'),
f AS ( -- lines strictly equal to another one
     SELECT tn1.id,
            'st_equals' AS error
       FROM "table_name" tn1
            INNER JOIN "table_name" tn2
            ON ST_Equals(tn1.geom, tn2.geom)
               AND tn1.id != tn2.id),
g AS ( -- isolated lines, that don't touch any other line
     SELECT tn1.id,
            'isolated_line' AS error
       FROM "table_name" tn1
      WHERE NOT EXISTS
            (SELECT 1
               FROM "table_name" tn2
              WHERE tn1.id != tn2.id
                AND ST_INTERSECTS(tn1.geom, tn2.geom))),
h AS ( -- lines measuring less than 1 meter
     SELECT id,
            'short_line' as error
       FROM "table_name"
      WHERE ST_Length(geom) < 1),
i AS ( -- lines that have the same boundaries and are fully contained within 5 meters of each other (surely duplicates)
     SELECT tn1.id,
            'same_boundaries' AS error
       FROM "table_name" tn1
            INNER JOIN "table_name" tn2
            ON ST_Equals(ST_Boundary(tn1.geom), ST_Boundary(tn2.geom))
               AND tn1.id != tn2.id
               AND ST_Contains(ST_Buffer(tn2.geom, 5), tn1.geom)
               AND ST_Contains(ST_Buffer(tn1.geom, 5), tn2.geom)
              ORDER BY tn1.id),
j AS ( -- lines that have a boundary not shared with any other line and measure less than 5 meters
     SELECT tn1.id,
            'short_dead_end' AS error
       FROM "table_name" tn1
      WHERE ST_Length(tn1.geom) < 5
            AND (NOT EXISTS
                 (SELECT 1
                    FROM "table_name" tn2
                   WHERE tn1.id != tn2.id
                         AND ST_Intersects(ST_StartPoint(tn1.geom), tn2.geom))
                 OR
                 NOT EXISTS
                 (SELECT 1
                    FROM "table_name" tn3
                   WHERE tn1.id != tn3.id
                         AND ST_Intersects(ST_EndPoint(tn1.geom), tn3.geom))
                )),
k AS ( -- lines suspiciously almost touching each other (1 meter tolerance)
     SELECT DISTINCT tn1.id,
            'almost_touching' AS error
       FROM "table_name" tn1
        INNER JOIN "table_name" tn2
           ON ST_DWithin(ST_Boundary(tn1.geom), tn2.geom, 1)
          AND NOT ST_Intersects(tn1.geom, tn2.geom)),
l AS (
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
     SELECT * FROM k)
SELECT * FROM l;
```

Attention un `core_path` peut avoir plusieurs erreurs et donc se retrouver dans le résultat de plusieurs sous-requêtes.

------

Prochaine étape : [Analyse des réseaux en vue de leur fusion](./_1_agregation_reseaux.md)
