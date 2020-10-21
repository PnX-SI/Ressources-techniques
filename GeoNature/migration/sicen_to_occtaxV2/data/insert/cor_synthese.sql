-- delete cor_area_synthese
DELETE FROM gn_synthese.cor_area_synthese cos
    USING gn_synthese.synthese s
    JOIN export_oo.v_saisie_observation_cd_nom_valid so
        ON s.unique_id_sinp = so.unique_id_sinp_occtax
;

-- insert cor_area_synthese

WITH point AS (
    SELECT
        s.the_geom_local,
        id_synthese
        FROM gn_synthese.synthese s
        JOIN export_oo.v_saisie_observation_cd_nom_valid so
			ON so.unique_id_sinp_occtax = s.unique_id_sinp
	WHERE public.ST_GEOMETRYTYPE(s.the_geom_local) = 'ST_Point'     
), not_point AS (
    SELECT
 s.the_geom_local,
        id_synthese
        FROM gn_synthese.synthese s
        JOIN export_oo.v_saisie_observation_cd_nom_valid so
			ON so.unique_id_sinp_occtax = s.unique_id_sinp
    	WHERE public.ST_GEOMETRYTYPE(s.the_geom_local) != 'ST_Point'
	), point2 AS (
        SELECT id_area, id_synthese
           FROM ref_geo.l_areas a
           JOIN point p 
            ON public.ST_INTERSECTS(p.the_geom_local, a.geom)
    ), not_point2 AS (
        SELECT id_area, id_synthese
           FROM ref_geo.l_areas a
           JOIN not_point np 
            ON public.ST_INTERSECTS(np.the_geom_local, a.geom)
             AND NOT ST_TOUCHES(np.the_geom_local,a.geom)

    )
INSERT INTO gn_synthese.cor_area_synthese(
    id_area,
    id_synthese
)
SELECT id_area, id_synthese FROM point2
UNION
SELECT id_area, id_synthese FROM not_point2
;

-- 

-- delete gn_synthese.cor_area_taxon
DELETE FROM gn_synthese.cor_area_taxon cat 
    USING gn_synthese.synthese s
    JOIN gn_synthese.cor_area_synthese cas
        ON cas.id_synthese = s.id_synthese
    JOIN export_oo.v_saisie_observation_cd_nom_valid so
        ON s.unique_id_sinp = so.unique_id_sinp_occtax
    WHERE cat.cd_nom = s.cd_nom AND cas.id_area = cat.id_area
;

-- inster gn_synthese.cor_area_taxon
 INSERT INTO gn_synthese.cor_area_taxon (cd_nom, nb_obs, id_area, last_date)
    SELECT s.cd_nom, count(s.id_synthese), cas.id_area,  max(s.date_min)
    FROM gn_synthese.cor_area_synthese cas
    JOIN gn_synthese.synthese s 
        ON s.id_synthese = cas.id_synthese
    JOIN export_oo.v_saisie_observation_cd_nom_valid so
        ON s.unique_id_sinp = so.unique_id_sinp_occtax
    GROUP BY cas.id_area, s.cd_nom
;