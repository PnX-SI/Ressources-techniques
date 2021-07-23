

-- ajout champs add
ALTER TABLE gn_monitoring.t_sites_groups ADD IF NOT EXISTS id_sites_group_cheveche INT; 
ALTER TABLE gn_monitoring.t_base_sites ADD IF NOT EXISTS id_site_cheveche INT; 
ALTER TABLE gn_monitoring.t_base_visits ADD IF NOT EXISTS id_observation INT;


-- données groupes de site

INSERT INTO gn_monitoring.t_sites_groups (
    id_sites_group_cheveche,
    sites_group_code,
    sites_group_name,
    id_module
)
SELECT DISTINCT ON (t.id)
    t.id AS id_sites_group_cheveche,
	SPLIT_PART(t.code, '_', 1) AS sites_group_code,
	REPLACE(t.libelle, 'circuit ', '') AS sites_group_name,
    m.id_module

	FROM import_vocabulaire_controle.t_thesaurus t
--	JOIN import_cheveches.t_suivi_mc_sites s
--		ON s.site_id_circuit = t.id
	JOIN gn_commons.t_modules m
		ON m.module_code = 'cheveches'
	WHERE t.id_type=2 and t.id != 2
	ORDER BY t.id
;



-- donnees sites

INSERT INTO gn_monitoring.t_base_sites (
	id_site_cheveche,
	base_site_name,
	base_site_code,
	first_use_date,
	meta_create_date,
	id_digitiser,
	id_inventor,
	id_nomenclature_type_site,
	geom
)
	SELECT 
		s.id AS id_site_cheveche,
		CASE
			WHEN g.sites_group_code IS NULL THEN CONCAT(s.site_code, ' ', 'indéfini')
			WHEN g.sites_group_code IS NOT NULL THEN CONCAT(s.site_code, ' ', SUBSTRING(g.sites_group_name FROM '\d (.*)')) -- tout apres le premier chiffre   
		END AS base_site_name,
		s.site_code AS base_site_code,
		TO_DATE(annee_creation::text, 'yyyy') AS first_use_date,
		date_creation as meta_create_date,
		id_numerisateur AS id_digitiser,
		site_id_createur AS id_inventor,
		n.id_nomenclature AS id_nomenclature_type_site,
		ST_TRANSFORM(geom, 4326) AS geom

		FROM import_cheveches.t_suivi_mc_sites s
        
		LEFT JOIN gn_monitoring.t_sites_groups g
			ON SPLIT_PART(s.site_code, '.', 1)=g.sites_group_code
			
		JOIN ref_nomenclatures.t_nomenclatures n
			ON n.cd_nomenclature = 'CHE_PT_E';



-- donnees site complement

INSERT INTO gn_monitoring.t_site_complements(id_base_site, id_sites_group, id_module, data)
	SELECT
		s.id_base_site,
        g.id_sites_group,
		m.id_module,
		CAST(to_json(data_spe) AS JSONB) - 'id'

	FROM gn_monitoring.t_base_sites s
	JOIN gn_commons.t_modules m
		ON m.module_code = 'cheveches'
	JOIN import_cheveches.t_suivi_mc_sites ms
		ON ms.id = s.id_site_cheveche
    LEFT JOIN gn_monitoring.t_sites_groups g
		ON SPLIT_PART(ms.site_code, '.', 1)=g.sites_group_code
	JOIN (SELECT
		site_id_2010,
		site_code_2010,
		site_id_2014,
		site_code_2014,
		inactif,
		id
		FROM import_cheveches.t_suivi_mc_sites s
	)data_spe
		ON data_spe.id = s.id_site_cheveche
;

-- t_base_visits

INSERT INTO gn_monitoring.t_base_visits(
	id_observation,
	id_base_site,
	id_digitiser,
	visit_date_min,
	comments,
	id_module,
	id_dataset
)
	SELECT
		id AS id_observation,
		s.id_base_site,
		numerisateur AS id_digitiser,
		date_observation::date AS visit_date_min,
		TRIM(CONCAT(commentaires, ' ', meteo)) AS comments,
		m.id_module,
		cmd.id_dataset
		
		FROM import_cheveches.t_suivi_mc_observations o
		JOIN gn_monitoring.t_base_sites s
			ON s.id_site_cheveche = o.id_site
		JOIN gn_commons.t_modules m
			ON m.module_code = 'cheveches'
		JOIN gn_commons.cor_module_dataset cmd
			ON m.id_module = cmd.id_module
;


-- t_base_visit_complements

INSERT INTO gn_monitoring.t_visit_complements(id_base_visit, data)
SELECT
		v.id_base_visit,
		(CAST(to_json(data_spe) AS JSONB) - 'id') - 'id_resultat'

	FROM gn_monitoring.t_base_visits v
	JOIN (SELECT
		o.id,
		'' AS time_observation,
		o.num_passage,
		c.id_nomenclature AS id_nomenclature_statut_obs,
		o.id_resultat,
		NULL AS id_nomenclature_vent,
		NULL AS id_nomenclature_meteo,
		3511 AS cd_nom
		FROM import_cheveches.t_suivi_mc_observations o
		LEFT JOIN import_cheveches.cor_nomenclature_resultat c
			ON c.id = o.id_resultat
	)data_spe
		ON data_spe.id = v.id_observation		
;


-- cor_visit_observer

-- id_observateur_1

INSERT INTO gn_monitoring.cor_visit_observer(id_role, id_base_visit)
SELECT id_observateur_1 AS id_role, id_base_visit
	FROM import_cheveches.t_suivi_mc_observations o
	JOIN gn_monitoring.t_base_visits v
		ON v.id_observation = o.id
	WHERE id_observateur_1 IS NOT NULL AND id_observateur_1 != 0
;

-- id_observateur_2

INSERT INTO gn_monitoring.cor_visit_observer(id_role, id_base_visit)
SELECT id_observateur_2 AS id_role, id_base_visit
	FROM import_cheveches.t_suivi_mc_observations o
	JOIN gn_monitoring.t_base_visits v
		ON v.id_observation = o.id
	WHERE id_observateur_2 IS NOT NULL AND id_observateur_2 != 0
;

-- suppression du champs add id_site_cheveche

ALTER TABLE gn_monitoring.t_sites_groups DROP id_sites_group_cheveche; 
ALTER TABLE gn_monitoring.t_base_sites DROP id_site_cheveche; 
ALTER TABLE gn_monitoring.t_base_visits DROP id_observation;
