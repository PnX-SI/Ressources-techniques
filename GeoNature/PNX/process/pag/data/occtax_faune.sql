-- releve

INSERT INTO pr_occtax.t_releves_occtax(
            id_releve_occtax,
            unique_id_sinp_grp,
            id_dataset, 
            -- technique d'obs non traité en l'état -> NSP
            id_nomenclature_tech_collect_campanule, 
            id_nomenclature_grp_typ, 
            date_min, 
            date_max, 
            altitude_min, 
            altitude_max, 
            meta_device_entry, 
            geom_local, 
            geom_4326, 
            "precision"
        )
SELECT 
    id_cf AS id_releve_occtax,
    uuid_generate_v4() AS unique_id_sinp_grp,
    id_lot AS id_dataset,
    ref_nomenclatures.get_id_nomenclature('TECHNIQUE_OBS','133') AS id_nomenclature_tech_collect_campanule,
    COALESCE(v1_compat.get_synonyme_id_nomenclature('TYP_GRP', id_lot), ref_nomenclatures.get_id_nomenclature('TYP_GRP','NSP')) AS id_nomenclature_grp_typ,
    dateobs AS date_min,
    dateobs AS date_max,
    altitude_retenue AS altitude_min,
    altitude_retenue AS altitude_max,
    saisie_initiale AS meta_device_entry, 
    ST_TRANSFORM(the_geom_local, :srid_local) AS geom_local,
    ST_TRANSFORM(the_geom_local, 4326) AS geom_4326,
    50 AS precision
FROM v1_compat.t_fiches_cf cf
;

-- occurence


    INSERT INTO pr_occtax.t_occurrences_occtax(
                    id_occurrence_occtax,
            unique_id_occurence_occtax, 
            id_releve_occtax, 
            id_nomenclature_obs_technique, 
            id_nomenclature_bio_condition, 
            id_nomenclature_bio_status, 
            id_nomenclature_naturalness, 
            id_nomenclature_exist_proof, 
            id_nomenclature_diffusion_level, 
            id_nomenclature_observation_status, 
            id_nomenclature_blurring, 
            id_nomenclature_source_status, 
            determiner, 
            id_nomenclature_determination_method, 
            cd_nom, 
            nom_cite, 
            meta_v_taxref, 
            sample_number_proof, 
            digital_proof, 
            non_digital_proof, 
            comment
    )
    SELECT
    id_releve_cf AS id_occurrence_occtax,
    uuid_generate_v4() AS unique_id_occurence_occtax,
    id_cf AS id_releve_occtax,
    COALESCE(
	v1_compat.get_synonyme_id_nomenclature('METH_OBS', id_critere_cf),
	ref_nomenclatures.get_id_nomenclature('METH_OBS','21')
	) AS id_nomenclature_obs_meth,
    COALESCE(
	v1_compat.get_synonyme_id_nomenclature('ETA_BIO', id_critere_cf),
	ref_nomenclatures.get_id_nomenclature('ETA_BIO','0')
	) AS id_nomenclature_bio_condition,
    COALESCE(
	v1_compat.get_synonyme_id_nomenclature('STATUT_BIO', id_critere_cf),
	ref_nomenclatures.get_id_nomenclature('STATUT_BIO','1')
	) AS id_nomenclature_bio_status,
     ref_nomenclatures.get_id_nomenclature('NATURALITE','1') AS id_nomenclature_naturalness,
     ref_nomenclatures.get_id_nomenclature('PREUVE_EXIST','2') AS id_nomenclature_exist_proof,
     CASE 
       WHEN cf.diffusable = true THEN ref_nomenclatures.get_id_nomenclature('NIV_PRECIS','5') 
       WHEN cf.diffusable = false THEN ref_nomenclatures.get_id_nomenclature('NIV_PRECIS','4') 
       ELSE ref_nomenclatures.get_id_nomenclature('NIV_PRECIS','5') 
     END AS id_nomenclature_diffusion_level,
     ref_nomenclatures.get_id_nomenclature('STATUT_OBS','Pr') AS id_nomenclature_observation_status,
     ref_nomenclatures.get_id_nomenclature('DEE_FLOU','NON') AS id_nomenclature_blurring,
     ref_nomenclatures.get_id_nomenclature('STATUT_SOURCE','Te') AS id_nomenclature_source_status,
     -- determination = Non renseigné
     NULL AS determiner,
     ref_nomenclatures.get_id_nomenclature('METH_DETERMIN','1') AS id_nomenclature_source_status,
     bib_noms.cd_nom AS cd_nom,
     nom_taxon_saisi AS nom_cite,
     'Taxref V13.0' AS meta_v_taxref,
     NULL AS sample_number_proof,
     NULL AS digital_proof, 
     NULL AS non_digital_proof,
     cf.commentaire AS comment
    FROM v1_compat.t_releves_cf cf
    JOIN taxonomie.bib_noms bib_noms ON bib_noms.id_nom = cf.id_nom;
