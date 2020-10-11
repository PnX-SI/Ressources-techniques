INSERT INTO pr_occtax.t_releves_occtax(
    unique_id_sinp_grp,
    id_dataset,
    id_nomenclature_tech_collect_campanule,
    id_nomenclature_grp_typ,
    date_min,
    date_max,
    hour_min,
    hour_max,
    altitude_min,
    altitude_max,
    depth_min,
    depth_max,
    comment,
    precision,
    geom_local,
    geom_4326

) SELECT
    
    ro.unique_id_sinp_grp,
    cd.id_dataset::int,
    ref_nomenclatures.get_id_nomenclature('TECHNIQUE_OBS', '133') AS id_nomenclature_tech_collect_campanule,
    ref_nomenclatures.get_id_nomenclature('TYP_GRP', 'NSP') AS id_nomenclature_grp_typ,
    ro.date_min,
    ro.date_max,
    ro.hour_min,
    ro.hour_max,
    ro.altitude_min,
    ro.altitude_min,
    ro.depth_min,
    ro.depth_min,
    ro.comment,
    ro.precision::int,
    ST_TRANSFORM(geometrie, 2154) AS geom_local,
    ST_TRANSFORM(geometrie, 4326) AS geom_4326
    
    FROM export_oo.t_releves_occtax ro
    JOIN export_oo.cor_dataset cd
        ON cd.id_etude = ro.id_etude
            AND cd.id_protocole = ro.id_protocole
--    LEFT JOIN pr_occtax.t_releves_occtax r
--      ON r.unique_id_sinp_grp = ro.unique_id_sinp_grp
--    WHERE r.unique_id_sinp_grp IS NULL