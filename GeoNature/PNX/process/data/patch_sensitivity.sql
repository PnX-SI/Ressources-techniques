    -- Correction NOT VALID gn_sensitivity
ALTER TABLE gn_sensitivity.cor_sensitivity_synthese DROP CONSTRAINT check_synthese_sensitivity;

ALTER TABLE gn_sensitivity.cor_sensitivity_synthese
  ADD CONSTRAINT check_synthese_sensitivity CHECK (ref_nomenclatures.check_nomenclature_type_by_mnemonique(id_nomenclature_sensitivity, 'SENSIBILITE'::character varying)) NOT VALID;

ALTER TABLE gn_sensitivity.t_sensitivity_rules DROP CONSTRAINT check_t_sensitivity_rules_niv_precis;

ALTER TABLE gn_sensitivity.t_sensitivity_rules
  ADD CONSTRAINT check_t_sensitivity_rules_niv_precis CHECK (ref_nomenclatures.check_nomenclature_type_by_mnemonique(id_nomenclature_sensitivity, 'SENSIBILITE'::character varying)) NOT VALID;
