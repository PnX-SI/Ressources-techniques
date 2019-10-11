-- Assistant de création de requetes pivot

CREATE OR REPLACE FUNCTION public.pivot_query (tablename IN text, keycol text, alias in jsonb)
RETURNS text
AS 
$$ 
DECLARE
    k varchar;
    v varchar;
    q text;
BEGIN
    q := (SELECT 'SELECT ' || keycol || ' , ' || string_agg(CONCAT('data->>''', key, ''' AS ' ,value), ',') || ' FROM  ' || tablename || ';' from jsonb_each_text(alias));
    return q;

END;
$$
LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION public.pivot_query_return_results (query IN text, tablename IN text, keycol IN text, keycoltype IN text, alias IN jsonb, keyvaltype IN text)
RETURNS text
AS 
$$ 
DECLARE
    q text;
    astable text;
BEGIN
    astable := (
       SELECT CONCAT('AS t ( ', keycol, ' ', keycoltype , ', ') || string_agg (value, ' ' || keyvaltype || ',')
       FROM jsonb_each_text(alias)
    );
    q := (
        SELECT query || ' ' || pivot_query 
        FROM pivot_query ( tablename, keycol, alias)
    );
    RAISE NOTICE 'q %', q;
    RETURN q;
END;
$$
LANGUAGE plpgsql;

-- Exemple utilisation

SELECT public.pivot_query_return_results ('WITH area_type AS (
    SELECT id_type , type_code
    FROM  ref_geo.bib_areas_types at
    WHERE type_code IN ( ''ZC'', ''AA'', ''PEC'', ''MASSIF'', ''ZB'')
), data AS (
    SELECT s.id_synthese, cd_nom, a.id_area, l.area_code, at.type_code
    FROM gn_synthese.synthese s
    JOIN gn_synthese.cor_area_synthese a
    ON s.id_synthese = a.id_synthese
    JOIN ref_geo.l_areas l
    ON l.id_area = a.id_area
    JOIN  area_type at
    ON at.id_type = l.id_type
), d AS (
    SELECT cd_nom, id_area as code, count(DISTINCT id_synthese)
    FROM data
    GROUP BY cd_nom, id_area
), top AS (
  SELECT cd_nom, json_object_agg(code, count) as data
  FROM d
  GROUP BY cd_nom
  LIMIT 100
)', 'top', 'cd_nom', 'int',
(SELECT  ('{' || string_agg(CONCAT('"', id_area, '": "', type_code, '_', area_code, '"'), ',' ) || '}')::jsonb
FROM  ref_geo.bib_areas_types at
JOIN ref_geo.l_areas l
ON l.id_type = at.id_type
WHERE type_code IN ( 'ZC', 'AA', 'PEC', 'MASSIF', 'ZB'))::jsonb
, 'int');



 -- RETOURNE
 
WITH area_type AS (
    SELECT id_type , type_code
    FROM  ref_geo.bib_areas_types at
    WHERE type_code IN ( 'ZC', 'AA', 'PEC', 'MASSIF', 'ZB')
), data AS (
    SELECT s.id_synthese, cd_nom, a.id_area, l.area_code, at.type_code
    FROM gn_synthese.synthese s
    JOIN gn_synthese.cor_area_synthese a
    ON s.id_synthese = a.id_synthese
    JOIN ref_geo.l_areas l
    ON l.id_area = a.id_area
    JOIN  area_type at
    ON at.id_type = l.id_type
), d AS (
    SELECT cd_nom, id_area as code, count(DISTINCT id_synthese)
    FROM data
    GROUP BY cd_nom, id_area
), top AS (
  SELECT cd_nom, json_object_agg(code, count) as data
  FROM d
  GROUP BY cd_nom
  LIMIT 100
) SELECT cd_nom , data->>'1' AS ZC,data->>'28' AS AA,data->>'37' AS PPEC,data->>'55' AS MASSIF_AI,data->>'56' AS MASSIF_BCN,data->>'57' AS MASSIF_BCS,data->>'58' AS MASSIF_CG,data->>'59' AS MASSIF_ML,data->>'60' AS MASSIF_VC,data->>'61' AS ZB_CG,data->>'62' AS ZB_ML,data->>'63' AS ZB_CE,data->>'64' AS ZB_BCE,data->>'65' AS ZB_AI FROM  top;
