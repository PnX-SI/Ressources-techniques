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
    
    unique_id_sinp_grp,
    cd.id_dataset::int,
    ref_nomenclatures.get_id_nomenclature('TECHNIQUE_OBS', cd_nomenclature_tech_collect_campanule) AS id_nomenclature_tech_collect_campanule,
    ref_nomenclatures.get_id_nomenclature('TYP_GRP', cd_nomenclature_grp_typ) AS id_nomenclature_grp_typ,
    date_min,
    date_max,
    hour_min,
    hour_max,
    altitude_min,
    altitude_min,
    depth_min,
    depth_min,
    comment,
    precision::int,
    ST_TRANSFORM(geometrie, 2154) AS geom_local,
    ST_TRANSFORM(geometrie, 4326) AS geom_4326
    
    FROM export_oo.t_releves_occtax ro
    JOIN export_oo.cor_dataset cd
        ON cd.id_etude = ro.id_etude
            AND cd.id_protocole = ro.id_protocole