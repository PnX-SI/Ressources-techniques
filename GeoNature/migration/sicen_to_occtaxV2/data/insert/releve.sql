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
    geom_4326,
    ids_obs_releve,
    observateur

) SELECT 

	uuid_generate_v4() AS unique_id_sinp_grp,
    cd.id_dataset::int,
    ref_nomenclatures.get_id_nomenclature('TECHNIQUE_OBS', '133') AS id_nomenclature_tech_collect_campanule,
    ref_nomenclatures.get_id_nomenclature('TYP_GRP', 'NSP') AS id_nomenclature_grp_typ,
    s.date_min,
    s.date_max,
    hour_min,
    hour_max,
    altitude AS altitude_min,
    altitude AS altitude_max,
    depth AS depth_min,
    depth AS depth_max,
    STRING_AGG(DISTINCT remarque_obs, ', ') as comment,
    export_oo.get_synonyme_id_nomenclature('PRECISION', precision::text) AS precision,
    ST_TRANSFORM(geometrie, 2154) AS geom_local,
    ST_TRANSFORM(geometrie, 4326) AS geom_4326,
    ARRAY_AGG(id_obs) AS ids_obs_releve,
    s.observateur

    FROM export_oo.saisie_observation s
        JOIN export_oo.cor_dataset cd
            ON cd.id_etude = s.id_etude AND cd.id_protocole = s.id_protocole

    GROUP BY 
        id_dataset,
        date_min,
        date_max,
        hour_min,
        hour_max,
        altitude,
        depth,
        precision,
        geometrie,
        observateur
;



WITH observers AS (
    SELECT UNNEST(STRING_TO_ARRAY(observateur, '&'))::int AS id_personne,
    id_releve_occtax
    FROM pr_occtax.t_releves_occtax ro
)
INSERT INTO pr_occtax.cor_role_releves_occtax (id_role, id_releve_occtax)
    SELECT DISTINCT r.id_role, ro.id_releve_occtax  
    FROM pr_occtax.t_releves_occtax ro
    JOIN observers o 
        ON o.id_releve_occtax = ro.id_releve_occtax
    JOIN utilisateurs.t_roles r 
        ON r.id_personne = o.id_personne 
;