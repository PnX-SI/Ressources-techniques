ALTER TABLE pr_occtax.t_releves_occtax ADD COLUMN IF NOT EXISTS ids_obs_releve INTEGER[];
ALTER TABLE pr_occtax.t_occurrences_occtax ADD COLUMN IF NOT EXISTS ids_obs_occurrence INTEGER[];
ALTER TABLE pr_occtax.cor_counting_occtax ADD COLUMN IF NOT EXISTS id_obs INTEGER;
