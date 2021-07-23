
CREATE SCHEMA temp_import_oedic;

ALTER TABLE gn_monitoring.t_base_sites ADD COLUMN IF NOT EXISTS id_base_site_old INT;
ALTER TABLE gn_monitoring.t_base_visits ADD COLUMN IF NOT EXISTS id_base_visit_old INT;
ALTER TABLE gn_monitoring.t_observations ADD COLUMN IF NOT EXISTS id_observation_old INT;


--
-- cor nomenclature new old
--
DROP TABLE IF EXISTS temp_import_oedic.cor_nomenclatures_old_new; 
CREATE TABLE temp_import_oedic.cor_nomenclatures_old_new AS
	SELECT new_n.id_nomenclature as id_nomenclature_new, old_n.id_nomenclature as id_nomenclature_old
		FROM import_ref_nomenclatures.t_nomenclatures old_n
		JOIN ref_nomenclatures.t_nomenclatures new_n
			ON new_n.cd_nomenclature = old_n.cd_nomenclature
		JOIN ref_nomenclatures.bib_nomenclatures_types new_nt
			ON new_nt.id_type = new_n.id_type
		JOIN import_ref_nomenclatures.bib_nomenclatures_types old_nt
			ON old_nt.id_type = old_n.id_type
				AND old_nt.mnemonique = new_nt.mnemonique;


-- cas particulier nature_observation les cd_nomenclatures ont changés

INSERT INTO temp_import_oedic.cor_nomenclatures_old_new
(id_nomenclature_new, id_nomenclature_old)
WITH cor AS (
	SELECT 'ND' AS old_cd, '21' AS new_cd
	UNION
	SELECT 'AUDVIS' AS old_cd, '25' AS new_cd
	UNION
	SELECT 'VIS' AS old_cd, '0' AS new_cd
	UNION
	SELECT 'AUD' AS old_cd, '1' AS new_cd
)
SELECT 
	ref_nomenclatures.get_id_nomenclature('OED_NAT_OBS', new_cd) AS id_nomenclature_new,
	old_n.id_nomenclature  AS id_nomenclature_old
FROM import_ref_nomenclatures.t_nomenclatures old_n
JOIN import_ref_nomenclatures.bib_nomenclatures_types old_nt
ON old_nt.id_type = old_n.id_type
JOIN cor ON cor.old_cd = old_n.cd_nomenclature 
WHERE  old_nt.mnemonique = 'OED_NAT_OBS';

-- sites

-- gn_monitoring.t_base_sites

INSERT INTO gn_monitoring.t_base_sites(id_digitiser, id_nomenclature_type_site, base_site_name, base_site_description, base_site_code, first_use_date, geom, id_base_site_old)
	SELECT r.id_role, cor_n.id_nomenclature_new, old_s.base_site_name, old_s.base_site_description, old_s.base_site_code, old_s.first_use_date, old_s.geom, old_s.id_base_site
		FROM  import_gn_monitoring.t_base_sites AS old_s
		JOIN temp_import_oedic.cor_nomenclatures_old_new AS cor_n
			ON cor_n.id_nomenclature_old = old_s.id_nomenclature_type_site
		JOIN utilisateurs.t_roles AS r
			ON r.nom_role='BROUARD';


-- gn_monitoring.t_site_complements

INSERT INTO gn_monitoring.t_site_complements(id_base_site, id_module)
	SELECT s.id_base_site, m.id_module
		FROM gn_monitoring.t_base_sites s
		JOIN gn_commons.t_modules m
			ON m.module_code = 'oedicnemes'
		WHERE s.id_nomenclature_type_site = ref_nomenclatures.get_id_nomenclature('TYPE_SITE', 'OEDIC');

-- gn_monitoring.cor_site_module

INSERT INTO gn_monitoring.cor_site_module(id_base_site, id_module)
	SELECT s.id_base_site, m.id_module
		FROM gn_monitoring.t_base_sites s
		JOIN gn_commons.t_modules m
			ON m.module_code = 'oedicnemes'
		WHERE s.id_nomenclature_type_site = ref_nomenclatures.get_id_nomenclature('TYPE_SITE', 'OEDIC');

-- visites

-- gn_monitoring.t_base_visits

INSERT INTO gn_monitoring.t_base_visits(
		id_base_site,
		id_module,
		id_digitiser,
		visit_date_min,
		visit_date_max,
		comments,
		id_dataset,
		id_base_visit_old
)
	SELECT 
		new_s.id_base_site,
		m.id_module,
		r.id_role as id_digitiser,
		old_v.visit_date_min,
		old_v.visit_date_min as visit_date_max,
		old_v.comments,
		ds.id_dataset,
		old_v.id_base_visit AS id_base_visit_old
		
		FROM import_gn_monitoring.t_base_visits AS old_v
		JOIN gn_monitoring.t_base_sites AS new_s
			ON new_s.id_base_site_old = old_v.id_base_site
		JOIN utilisateurs.t_roles as r
			ON r.nom_role='BROUARD'
		JOIN gn_commons.t_modules m
			ON m.module_code = 'oedicnemes'
		JOIN gn_meta.t_datasets ds
			ON ds.dataset_shortname = 'Oedic.'
; 

-- gn_monitoring.t_visit_complements

INSERT INTO gn_monitoring.t_visit_complements(id_base_visit, data)
	SELECT 
		v.id_base_visit,
		CAST(to_json(data_spe) AS JSONB) - 'id_base_visit_old' as data

		FROM gn_monitoring.t_base_visits v
		JOIN gn_commons.t_modules m
			ON m.module_code = 'oedicnemes'
		LEFT JOIN ( 
			SELECT
				old_vi.id_base_visit as id_base_visit_old,
				nb_ind_obs_min,
				nb_ind_obs_max,
				vent.label_fr AS meteo_vent,
				ciel.label_fr AS meteo_ciel,
				time_start,
				time_end
			FROM import_monitoring_oedic.t_visite_informations old_vi
			LEFT JOIN import_ref_nomenclatures.t_nomenclatures vent 
			ON id_nomenclature_meteo_vent = vent.id_nomenclature 
			LEFT JOIN import_ref_nomenclatures.t_nomenclatures ciel 
			ON id_nomenclature_meteo_ciel = ciel.id_nomenclature 
		) data_spe
			ON data_spe.id_base_visit_old = v.id_base_visit_old
		WHERE v.id_module = m.id_module
;	

-- cor_visit_observer

INSERT INTO gn_monitoring.cor_visit_observer(id_role, id_base_visit)
SELECT 
--	r_old.identifiant,
--	CONCAT(r_old.nom_role, ' ', r_old.prenom_role),
	r.id_role,
	v.id_base_visit
	
	FROM import_gn_monitoring.cor_visit_observer c_old
	JOIN gn_monitoring.t_base_visits v
		ON v.id_base_visit_old = c_old.id_base_visit
	JOIN import_utilisateurs.t_roles r_old
		ON r_old.id_role = c_old.id_role
	LEFT JOIN utilisateurs.t_roles r
		ON CONCAT(r_old.nom_role, ' ', r_old.prenom_role) ilike CONCAT(r.nom_role, ' ', r.prenom_role);


-- observations

-- gn_monitoring.t_observations

INSERT INTO gn_monitoring.t_observations(
	id_observation_old,
	id_base_visit,
	comments,
	cd_nom

)
	SELECT 
		o.id_visite_observation AS id_observation_old,
		v.id_base_visit,
		o.remarque_observation AS comments,
		3120 AS cd_nom
		
		FROM import_monitoring_oedic.t_visite_observations o
		JOIN gn_monitoring.t_base_visits v
		ON o.id_base_visit = v.id_base_visit_old;

-- gn_monitoring.t_observation_complements

INSERT INTO gn_monitoring.t_observation_complements
	SELECT
		o.id_observation,
		CAST(to_json(data_spe) AS JSONB) - 'id_visite_observation' as data

		FROM gn_monitoring.t_observations o
		JOIN ( SELECT
			o.id_visite_observation,
			o.nb_oiseaux,
			o.time_observation,
			cn.id_nomenclature_new AS id_nomenclature_nature_observation

			FROM import_monitoring_oedic.t_visite_observations o
			JOIN temp_import_oedic.cor_nomenclatures_old_new cn
				ON o.id_nomenclature_nature_observation = cn.id_nomenclature_old
		)data_spe
			ON data_spe.id_visite_observation = o.id_observation_old;


ALTER TABLE gn_monitoring.t_base_sites DROP COLUMN IF EXISTS id_base_site_old;
ALTER TABLE gn_monitoring.t_base_visits DROP COLUMN IF EXISTS id_base_visit_old;
ALTER TABLE gn_monitoring.t_observations DROP COLUMN IF EXISTS id_observation_old;

DROP SCHEMA IF EXISTS temp_import_oedic CASCADE;
