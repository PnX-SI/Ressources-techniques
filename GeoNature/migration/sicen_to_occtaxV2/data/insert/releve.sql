-- pr_occtax.t_releves_occtax

WITH dataset AS (
    SELECT DISTINCT id_protocole, id_dataset::int, id_etude, ids_structure FROM export_oo.cor_dataset
)

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
    d.id_dataset,
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
    ST_TRANSFORM(geometrie, :srid) AS geom_local,
    ST_TRANSFORM(geometrie, 4326) AS geom_4326,
    ARRAY_AGG(id_obs) AS ids_obs_releve,
    s.observateur

    FROM export_oo.v_saisie_observation_cd_nom_valid s
    JOIN dataset d
        ON d.id_etude = s.id_etude
        AND d.id_protocole = s.id_protocole
        AND d.ids_structure = s.ids_structure

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

-- pr_occtax.cor_role_releves_occtax

WITH observers AS (
    SELECT UNNEST(STRING_TO_ARRAY(observateur, '&'))::int AS id_personne,
    id_releve_occtax
    FROM export_oo.v_releves_occtax
)
INSERT INTO pr_occtax.cor_role_releves_occtax (id_role, id_releve_occtax)
    SELECT DISTINCT r.id_role, vr.id_releve_occtax  
    FROM export_oo.v_releves_occtax vr
    JOIN observers o 
        ON o.id_releve_occtax = vr.id_releve_occtax
    JOIN export_oo.v_roles r 
        ON (r.champs_addi->>'id_personne')::int = o.id_personne
;


-- gn_commons.cor_module_dataset
INSERT INTO gn_commons.cor_module_dataset (id_module, id_dataset)
SELECT m.id_module, d.id_dataset
FROM export_oo.v_datasets d
JOIN gn_commons.t_modules m ON m.module_code = 'OCCTAX'
;