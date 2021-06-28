/*
 Ajout de 2 colonnes de géométries à la table `serenabase.rnf_obse`:
    `geom_obse` pour stocker la geom de l'observation
    `geom_site` pour stocker la geom du site
*/

ALTER TABLE serenabase.rnf_obse
    ADD COLUMN geom_obse GEOMETRY;
ALTER TABLE serenabase.rnf_obse
    ADD COLUMN geom_site GEOMETRY;

/*
  Calcul des géométries de la colonne `serenabase.rnf_obse.geom_obse` :
    * Quand on a une geometrie reelle dans la colonne obse_car, éxécute d'abord une requête permettant d'identifier sommairement les différents système de coordonnées utilisés dans Serena afin d'adapter la requête suivante
*/

SELECT DISTINCT
    split_part(obse_car::TEXT, ' '::TEXT, 1)                                                 AS scr
  , (string_to_array(obse_car, ' ')::TEXT[])[array_upper(string_to_array(obse_car, ' '), 1)] AS proj
  , count(obse_id)                                                                           AS nb_obs
    FROM
        serenabase.rnf_obse
    GROUP BY
        split_part(obse_car::TEXT, ' '::TEXT, 1)
      , (string_to_array(obse_car, ' ')::TEXT[])[array_upper(string_to_array(obse_car, ' '), 1)]
    ORDER BY
        nb_obs DESC
;

/*
example de résultat
-------------------
scr	    proj	nb_obs >> commentaire                           >   SRID
		        160192 >> Observations sans geom
LIIEF	NTF	    38112  >> Observations en Lambert II étendu     >   27572
L93F	RGF93	33992  >> Observations en Lambert 93            >   2154
LIIIF	NTF	    87     >> Observations en Lambert III           >   27563
L93F	RGF	    21     >> Observations en Lambert 93...         >   2154
L93F	RGF100	1      >> Observations en Lambert 93...         >   2154
L93F	RGF101	1      >> Observations en Lambert 93...         >   2154
*/


/* On "reset" la colonne geom_obse (utile si on a déjà fait des essais) */
UPDATE serenabase.rnf_obse
SET
    geom_obse = NULL
  , geom_site = NULL;


/***************************************************
 *   PEUPLEMENT DE serenabase.rnf_obse.geom_obse   *
 *   A partir de la géométrie de l'observation     *
 ***************************************************/


/* On adapte la requête suivante selon les résultats de la requête précédente pour peupler la colonne `serenabase.rnf_obse.geom_obse`, ici avec les projections:
   * Lambert 93 RGF93
   * Lambert II étendu
   * Lambert III carto
 */

UPDATE serenabase.rnf_obse
SET
    geom_obse = (CASE
                     WHEN obse_car LIKE 'L93F%RGF%'
                         THEN st_setsrid(
                             st_point(replace(split_part(obse_car::TEXT, ' '::TEXT, 2), ',', '.')::FLOAT * 1000,
                                      (replace(split_part(obse_car::TEXT, ' '::TEXT, 3), ',', '.')::FLOAT * 1000)),
                             2154)
                     WHEN obse_car LIKE 'LIIEF%NTF'
                         THEN st_transform(st_setsrid(st_point(
                                                                  replace(split_part(obse_car::TEXT, ' '::TEXT, 2), ',', '.')::FLOAT *
                                                                  1000,
                                                                  (replace(split_part(obse_car::TEXT, ' '::TEXT, 3), ',', '.')::FLOAT *
                                                                   1000)), 27572), 2154)
                     WHEN obse_car LIKE 'LIIIF%NTF'
                         THEN st_transform(st_setsrid(st_point(
                                                                  replace(split_part(obse_car::TEXT, ' '::TEXT, 2), ',', '.')::FLOAT *
                                                                  1000,
                                                                  (replace(split_part(obse_car::TEXT, ' '::TEXT, 3), ',', '.')::FLOAT *
                                                                   1000)), 27563), 2154)
        /*WHEN obse_car LIKE 'LATLON%'
        THEN  ST_transform(ST_SetSRID(ST_Point(replace(split_part(obse_car::text, ' '::text, 2),',','.')::REAL, (replace(split_part(obse_car::text, ' '::text, 3),',','.')::REAL)), 4326), 2154)*/
        END)
    WHERE
          obse_car IS NOT NULL
      AND obse_car <> ''
;


/* Quand on a des coordonnées dans les colonnes obse_lat et obse_lon (+obse_dum) */

UPDATE serenabase.rnf_obse
SET
    geom_obse= st_transform(st_setsrid(st_point(replace(substring(obse_lon, 3), ',', '.')::FLOAT,
                                                replace(substring(obse_lat, 3), ',', '.')::FLOAT), 4326),
                            2154)::GEOMETRY(POINT, 2154)
    WHERE
          (obse_car IS NULL OR obse_car LIKE '')
      AND ((obse_lat IS NOT NULL AND obse_lat <> '') AND (obse_lon IS NOT NULL AND obse_lon <> ''))
      AND (replace(substring(obse_lon, 3), ',', '.')::FLOAT != 0 AND
           replace(substring(obse_lon, 3), ',', '.')::FLOAT != 0)
;



/***********************************************************
 *   PEUPLEMENT DE serenabase.rnf_obse.geom_site           *
 *   A partir de la géométrie du site lié à l'observation  *
 ***********************************************************/

-- TESTS :
SELECT DISTINCT
    o.obse_id
  , og.ogll_nom
  , og.ogll_lon
  , og.ogll_lat
  , s.site_lon
  , s.site_lat
  , s.site_car
  , s.site_nom
  , sg.sgll_nom
  , sg.sgll_lon
  , sg.sgll_lat
  , obse_lon
  , obse_lat
  , obse_dum
  , obse_car
  , obse_alt
  , obse_sig_obj_id
  , obse_waypoint
--   , v.*
    --SELECT DISTINCT obse_site_id, s.*
    FROM
        serenabase.rnf_obse o
--             JOIN serenabase.vm_obs_serena_detail v ON o.obse_id = v.obse_id
            JOIN serenabase.tmp_ogll og ON og.ogll_obse_id = o.obse_id
            JOIN serenabase.rnf_site s ON o.obse_site_id = s.site_id
            JOIN serenabase.tmp_sgll sg ON sg.sgll_site_id = s.site_id
    WHERE
        o.geom_obse IS NULL
;


-- on va chercher la geometrie portee par le site
UPDATE serenabase.rnf_obse o
SET
    geom_site= st_transform(st_setsrid(st_point(replace(substring(s.site_lon, 3), ',', '.')::FLOAT,
                                                replace(substring(s.site_lat, 3), ',', '.')::FLOAT), 4326),
                            2154)::GEOMETRY(POINT, 2154)
    FROM
        serenabase.rnf_site s
    WHERE
          o.obse_site_id = s.site_id
      AND (((o.obse_car IS NULL OR o.obse_car LIKE '')
        AND ((o.obse_lat IS NULL OR o.obse_lat LIKE '') AND (o.obse_lon IS NULL OR o.obse_lon LIKE '')))
        OR o.geom_obse IS NULL)
;

/* On vérifie s'il reste des observations sans aucune géométrie (à l'observation ou au site)
   ex:
        +-------------+--------+
        | no_geometry |	 count |
        +-------------+--------+
        | false	      | 232418 |
        +-------------+--------+
    Si toutes les données sont avec no_geometry = False, alors on toutes les observations ont une géométrie assignée, sinon, il faut investigyer les problèmes
   */

SELECT
    geom_site IS NULL AND geom_obse IS NULL no_geometry
  , count(*)
    FROM
        serenabase.rnf_obse
    GROUP BY
        geom_site IS NULL AND geom_obse IS NULL;

/***************************************************
 * IDENTIFICATION DES OBSERVATIONS SANS GEOMETRIES *
 ***************************************************/

/* On identifie les observations dépourvues de géométries (site ET/OU obs) pour identifier le soucis (rattachement à la commune ??)
   Vérifier si les géométries sont manquantes aussi dans un export réalisé depuis l'interface de Serena ou identifier les géométrie rattachées sur cette sélection observations */

SELECT DISTINCT
    o.obse_id
  , o.obse_site_id
  , o.obse_date
  , u.srce_compnom_c
  , o.obse_place
  , s.site_nom
  , l.choi_nom
  , s.site_lon
  , s.site_lat
  , s.site_car
  , o.obse_lon
  , o.obse_lat
  , o.obse_car
  , og.ogll_lon
  , og.ogll_lat
  , sg.sgll_lon
  , sg.sgll_lat
    FROM
        serenabase.rnf_obse o
            JOIN serenabase.rnf_srce u ON o.obse_obsv_id = u.srce_id
            LEFT JOIN serenabase.rnf_choi l ON o.obse_methloc_choi_id = l.choi_id
            JOIN serenabase.rnf_site s ON o.obse_site_id = s.site_id
            JOIN serenabase.tmp_ogll og ON og.ogll_obse_id = o.obse_id
            JOIN serenabase.tmp_sgll sg ON sg.sgll_site_id = s.site_id
    WHERE
          o.geom_obse IS NULL
      AND o.geom_site IS NULL
    ORDER BY
        s.site_nom
;

/*
  TODO : Si Serena reste une source de données vivantes, il faudra créer une fonction + trigger pour peupler les colonnes geom après chaque INSERT ou UPDATE dans Serena
*/


