
-- add col id_obs

ALTER TABLE pr_occtax.t_releves_occtax ADD COLUMN IF NOT EXISTS ids_obs_releve INTEGER[];
ALTER TABLE pr_occtax.t_occurrences_occtax ADD COLUMN IF NOT EXISTS ids_obs_occurrence INTEGER[];
ALTER TABLE pr_occtax.cor_counting_occtax ADD COLUMN IF NOT EXISTS id_obs INTEGER;


-- disabled triggers

ALTER TABLE pr_occtax.cor_counting_occtax DISABLE TRIGGER tri_insert_synthese_cor_counting_occtax;

ALTER TABLE gn_synthese.synthese DISABLE TRIGGER tri_insert_cor_area_synthese;