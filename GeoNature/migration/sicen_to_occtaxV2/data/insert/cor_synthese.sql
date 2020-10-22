-- delete cor_area_synthese
EXPLAIN ANALYSE DELETE FROM gn_synthese.cor_area_synthese c
    USING export_oo.v_synthese vs
    WHERE vs.id_synthese = c.id_synthese
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
    USING export_oo.v_synthese vs
    JOIN gn_synthese.cor_area_synthese cas
        ON cas.id_synthese = vs.id_synthese
    WHERE cat.cd_nom = vs.cd_nom AND cas.id_area = cat.id_area
;

-- inster gn_synthese.cor_area_taxon
 INSERT INTO gn_synthese.cor_area_taxon (cd_nom, nb_obs, id_area, last_date)
    SELECT vs.cd_nom, count(vs.id_synthese), cas.id_area,  max(vs.date_min)
    FROM gn_synthese.cor_area_synthese cas
    JOIN export_oo.v_synthese vs 
        ON vs.id_synthese = cas.id_synthese
    GROUP BY cas.id_area, vs.cd_nom
;