-- remove id_obs

-- ALTER TABLE pr_occtax.t_releves_occtax DROP ids_obs_releve;
-- --ALTER TABLE pr_occtax.t_releves_occtax DROP observateur;

-- ALTER TABLE pr_occtax.t_occurrences_occtax DROP ids_obs_occurrence;
-- ALTER TABLE pr_occtax.cor_counting_occtax DROP id_obs;

-- enable triggers
SET session_replication_role = DEFAULT;

ALTER TABLE pr_occtax.cor_counting_occtax ENABLE TRIGGER tri_insert_synthese_cor_counting_occtax;

ALTER TABLE gn_synthese.cor_observer_synthese DISABLE TRIGGER trg_maj_synthese_observers_txt;

ALTER TABLE gn_synthese.cor_area_synthese ENABLE TRIGGER tri_maj_cor_area_taxon;
ALTER TABLE gn_synthese.synthese ENABLE TRIGGER tri_del_area_synt_maj_corarea_tax;
ALTER TABLE gn_synthese.synthese ENABLE TRIGGER tri_insert_cor_area_synthese;
ALTER TABLE gn_synthese.synthese ENABLE TRIGGER tri_update_cor_area_taxon_update_cd_nom;
