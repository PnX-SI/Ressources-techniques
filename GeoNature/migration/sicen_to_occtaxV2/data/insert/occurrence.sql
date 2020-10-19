-- occurrence.sql

INSERT INTO pr_occtax.t_occurrences_occtax(

    ids_obs_occurrence,
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
    determiner,
    id_nomenclature_determination_method,
    cd_nom,
    nom_cite,
    meta_v_taxref,
    comment
    
    ) SELECT

        ARRAY_AGG(s.id_obs) AS ids_obs_occurrence,
        uuid_generate_v4() AS unique_id_occurence_occtax,

        r.id_releve_occtax,
        COALESCE(
            export_oo.get_synonyme_id_nomenclature('METH_OBS', determination::text),
            ref_nomenclatures.get_id_nomenclature('METH_OBS', '24') -- (Inconnu)
        ) AS id_nomenclature_obs_technique,

        COALESCE(
            export_oo.get_synonyme_id_nomenclature('ETA_BIO', determination::text),
            export_oo.get_synonyme_id_nomenclature('ETA_BIO', phenologie::text),
            ref_nomenclatures.get_id_nomenclature('ETA_BIO', '0') -- (NSP)
        ) AS id_nomenclature_bio_condition,

        ref_nomenclatures.get_id_nomenclature('STATUT_BIO', '1') AS id_nomenclature_bio_status, -- (non renseigné)
        ref_nomenclatures.get_id_nomenclature('NATURALITE', '0') AS id_nomenclature_naturalness, -- (Inconnu)
        
        CASE 
            WHEN LENGTH(STRING_AGG(s.url_photo, '')) > 0 
                THEN ref_nomenclatures.get_id_nomenclature('PREUVE_EXIST', '1') -- (Oui)
            ELSE ref_nomenclatures.get_id_nomenclature('PREUVE_EXIST', '0')  -- (Inconnu)
        END AS cd_nomenclature_exist_proof,

        ref_nomenclatures.get_id_nomenclature('STATUT_OBS', 'Pr') AS id_nomenclature_observation_status, -- (Présent)
        ref_nomenclatures.get_id_nomenclature('DEE_FLOU', 'NON') AS id_nomenclature_blurring,
        d.id_nomenclature_source_status,
        export_oo.get_synonyme_id_nomenclature('OCC_COMPORTEMENT', SUBSTRING(comportement::text, 1, 2)) AS id_nomenclature_behaviour, -- OCC_COMPORTEMENT

        NULL::text AS determiner,
        
        ref_nomenclatures.get_id_nomenclature('METH_DETERMIN', '1') AS id_nomenclature_determination_method, 
        
        COALESCE(t.cd_nom, st.cd_nom_valid) AS cd_nom,
        s.nom_complet AS nom_cite,
        (SELECT gn_commons.get_default_parameter('taxref_version')) AS meta_v_taxref,
        STRING_AGG(DISTINCT s.remarque_obs, ', ') AS comment

        FROM export_oo.saisie_observation s
        JOIN pr_occtax.t_releves_occtax r
            ON s.id_obs = ANY (r.ids_obs_releve)
        JOIN gn_meta.t_datasets d
            ON d.id_dataset = r.id_dataset
        LEFT JOIN export_oo.t_taxonomie_synonymes st
            ON st.cd_nom_invalid = s.cd_nom
        LEFT JOIN taxonomie.taxref t
            ON t.cd_nom = s.cd_nom OR t.cd_nom = st.cd_nom_valid
        
        WHERE COALESCE(t.cd_nom, st.cd_nom_valid) IS NOT NULL

        GROUP BY 
            r.id_releve_occtax,
            s.determination,
            s.phenologie,
            d.id_nomenclature_source_status,
            s.comportement,
            t.cd_nom,
            st.cd_nom_valid,
            s.nom_complet



