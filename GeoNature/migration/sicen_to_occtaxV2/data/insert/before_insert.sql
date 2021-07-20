
-- add col id_obs

ALTER TABLE pr_occtax.t_releves_occtax ADD COLUMN IF NOT EXISTS ids_obs_releve INTEGER[];
ALTER TABLE pr_occtax.t_releves_occtax ADD COLUMN IF NOT EXISTS observateur TEXT;
ALTER TABLE pr_occtax.t_releves_occtax ADD COLUMN IF NOT EXISTS champs_addi_obsocc JSONB;


ALTER TABLE pr_occtax.t_occurrences_occtax ADD COLUMN IF NOT EXISTS ids_obs_occurrence INTEGER[];
ALTER TABLE pr_occtax.cor_counting_occtax ADD COLUMN IF NOT EXISTS id_obs INTEGER;

ALTER TABLE utilisateurs.bib_organismes ADD COLUMN IF NOT EXISTS id_structure INTEGER;
ALTER TABLE utilisateurs.t_roles ADD COLUMN IF NOT EXISTS id_personne INTEGER;


-- disabled triggers

SET session_replication_role = replica;

ALTER TABLE pr_occtax.cor_counting_occtax DISABLE TRIGGER tri_insert_synthese_cor_counting_occtax;

ALTER TABLE gn_synthese.synthese ENABLE TRIGGER tri_insert_cor_area_synthese;


-- ALTER TABLE gn_synthese.cor_observer_synthese DISABLE TRIGGER trg_maj_synthese_observers_txt;

-- ALTER TABLE gn_synthese.cor_area_synthese DISABLE TRIGGER tri_maj_cor_area_taxon;
-- ALTER TABLE gn_synthese.synthese DISABLE TRIGGER tri_del_area_synt_maj_corarea_tax;
-- ALTER TABLE gn_synthese.synthese DISABLE TRIGGER tri_insert_cor_area_synthese;
-- ALTER TABLE gn_synthese.synthese DISABLE TRIGGER tri_update_cor_area_taxon_update_cd_nom;
