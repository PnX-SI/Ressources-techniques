    -- occurrence.sql
    WITH ids_obs AS (

        SELECT id_occurrence_occtax, UNNEST(ids_obs_occurrence) AS id_obs
        FROM export_oo.v_occurrences_occtax
    )

    INSERT INTO pr_occtax.cor_counting_occtax (

        id_obs,
        unique_id_sinp_occtax,  
        id_occurrence_occtax,
        id_nomenclature_life_stage,
        id_nomenclature_sex,
        id_nomenclature_obj_count,
        id_nomenclature_type_count,
        count_min,
        count_max

    ) SELECT 

        s.id_obs,
        s.unique_id_sinp_occtax,
        vo.id_occurrence_occtax,
        
        COALESCE(
            export_oo.get_synonyme_id_nomenclature('STADE_VIE', type_effectif),
            export_oo.get_synonyme_id_nomenclature('STADE_VIE', phenologie),
            ref_nomenclatures.get_id_nomenclature('STADE_VIE', '1') -- (Inconnu) ?? ou '2' Indéterminé
        ) AS id_nomenclature_life_stage,

        COALESCE(
            export_oo.get_synonyme_id_nomenclature('SEXE', phenologie::text),
            ref_nomenclatures.get_id_nomenclature('SEXE', '0') -- (Inconnu) ?? ou '1' (Non renseigné) 
        ) AS id_nomenclature_sex,

        COALESCE(
            export_oo.get_synonyme_id_nomenclature('OBJ_DENBR', phenologie::text),
            export_oo.get_synonyme_id_nomenclature('OBJ_DENBR', type_effectif::text),
            ref_nomenclatures.get_id_nomenclature('OBJ_DENBR', 'NSP') -- (Ne sais pas) 
        ) AS id_nomenclature_obj_count,

        ref_nomenclatures.get_id_nomenclature('TYP_DENBR', 'NSP') AS id_nomenclature_typ_count, -- (Ne sais pas) 

        COALESCE(effectif_min, effectif_max, 1) AS count_min,
        COALESCE(effectif_max, effectif_min, 1) AS count_max

        FROM export_oo.v_occurrences_occtax vo
        JOIN ids_obs io 
            ON io.id_occurrence_occtax = vo.id_occurrence_occtax
        JOIN export_oo.v_saisie_observation_cd_nom_valid s
            ON s.id_obs = io.id_obs
    ;