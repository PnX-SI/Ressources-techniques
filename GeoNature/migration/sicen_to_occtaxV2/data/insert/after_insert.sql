-- insertion dans la synthese

SELECT pr_occtax.insert_in_synthese(id_counting_occtax::int)
FROM pr_occtax.cor_counting_occtax c
LEFT JOIN gn_synthese.synthese s
    ON s.unique_id_sinp = c.unique_id_sinp_occtax 
WHERE s.id_synthese IS NULL;


-- remove id_obs

ALTER TABLE pr_occtax.t_releves_occtax DROP ids_obs_releve;
ALTER TABLE pr_occtax.t_occurrences_occtax DROP COLUMN ids_obs_occurrence;
ALTER TABLE pr_occtax.cor_counting_occtax DROP id_obs;


-- enable triggers

ALTER TABLE pr_occtax.cor_counting_occtax ENABLE TRIGGER tri_insert_synthese_cor_counting_occtax;
ALTER TABLE gn_synthese.synthese ENABLE TRIGGER tri_insert_cor_area_synthese;