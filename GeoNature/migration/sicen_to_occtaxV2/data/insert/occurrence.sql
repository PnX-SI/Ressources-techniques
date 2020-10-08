-- occurrence.sql

INSERT INTO pr_occtax.t_occurrences_occtax(

    unique_id_occurence_occtax,
    id_releve_occtax,
    id_nomenclature_obs_technique,
    id_nomenclature_bio_condition,
    id_nomenclature_bio_status,
    id_nomenclature_naturalness,
    id_nomenclature_exist_proof,
    id_nomenclature_observation_status,
    id_nomenclature_blurring,
    id_nomenclature_source_status,
    id_nomenclature_behaviour,
    -- determiner,
    id_nomenclature_determination_method,
    cd_nom,
    nom_cite,
    meta_v_taxref,
    comment
) SELECT

    oo.unique_id_occurence_occtax,
    ro.id_releve_occtax,
    ref_nomenclatures.get_id_nomenclature('METH_OBS', COALESCE(oo.cd_nomenclature_obs_technique, '24')) AS id_nomenclature_obs_technique, -- (Inconnu)
    ref_nomenclatures.get_id_nomenclature('ETA_BIO', COALESCE(oo.cd_nomenclature_bio_condition, '0')) AS id_nomenclature_bio_condition, -- (NSP)
    ref_nomenclatures.get_id_nomenclature('STATUT_BIO', oo.cd_nomenclature_bio_status) AS id_nomenclature_bio_status,
    ref_nomenclatures.get_id_nomenclature('NATURALITE', oo.cd_nomenclature_naturalness) AS id_nomenclature_naturalness,
    ref_nomenclatures.get_id_nomenclature('PREUVE_EXIST', oo.cd_nomenclature_exist_proof) AS id_nomenclature_exist_proof,
    ref_nomenclatures.get_id_nomenclature('STATUS_OBS', oo.cd_nomenclature_observation_status) AS id_nomenclature_observation_status,
    ref_nomenclatures.get_id_nomenclature('DEE_FLOU', oo.cd_nomenclature_blurring) AS id_nomenclature_blurring,
    d.id_nomenclature_source_status, -- FROM releve JDD
    ref_nomenclatures.get_id_nomenclature('OCC_COMPORTEMENT', oo.cd_nomenclature_behaviour) AS id_nomenclature_behaviour,
    -- TODO determiner
    ref_nomenclatures.get_id_nomenclature('METH_DETERMIN', oo.cd_nomenclature_determination_method) AS id_nomenclature_determination_method,
    oo.cd_nom,
    oo.nom_cite,
    (SELECT gn_commons.get_default_parameter('taxref_version')) AS meta_v_taxref,

    -- TODO nom_cite FROM cd_nom
    -- ??? digital proof
    -- ??? non digital proof,
    oo.comment

    FROM export_oo.t_occurrences_occtax oo
    JOIN pr_occtax.t_releves_occtax ro
        ON ro.unique_id_sinp_grp = oo.unique_id_sinp_grp
    JOIN gn_meta.t_datasets d
        ON d.id_dataset = ro.id_dataset