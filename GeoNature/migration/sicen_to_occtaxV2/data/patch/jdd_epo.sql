-- BASE GN

-- PATCH pour CA JDD
-- :ca_field_name libelle_protocole|nom_etude
-- :jdd_field_name libelle_protocole|nom_etude

-- CA

-- DELETE FROM gn_meta.cor_dataset_actor;
-- DELETE FROM gn_commons.cor_module_dataset;
-- DELETE FROM gn_meta.t_datasets;
-- DELETE FROM gn_meta.t_acquisition_frameworks;

INSERT INTO gn_meta.t_acquisition_frameworks(
        acquisition_framework_name, 
        acquisition_framework_desc,
        acquisition_framework_start_date,
        keywords
)
SELECT DISTINCT
    :ca_field_name,
    :ca_field_name,
    NOW()::date,
    :'db_oo_name'
    FROM export_oo.cor_dataset
;

-- SELECT * FROM export_oo.cor_dataset;
-- SELECT * FROM gn_meta.t_datasets;

-- JDD

INSERT INTO gn_meta.t_datasets(
    id_acquisition_framework,
    dataset_name,
    dataset_shortname,
    dataset_desc,
    marine_domain,
    terrestrial_domain
    ) 
    SELECT DISTINCT
        af.id_acquisition_framework,
        :jdd_field_name || ' ' || noms_structure,
        :jdd_field_name || ' ' || noms_structure,
        :jdd_field_name || ' ' || noms_structure,
        FALSE,
        FALSE

        FROM export_oo.cor_dataset cd
        JOIN gn_meta.t_acquisition_frameworks af
            ON af.acquisition_framework_desc LIKE :ca_field_name
;

WITH dataset_data AS (
    SELECT DISTINCT id_dataset, d.dataset_desc, ca.acquisition_framework_name, dataset_name 
    FROM export_oo.v_datasets d
    JOIN gn_meta.t_acquisition_frameworks ca 
        ON ca.id_acquisition_framework = d.id_acquisition_framework
)
UPDATE export_oo.cor_dataset cd SET (id_dataset) = (
    SELECT dd.id_dataset FROM dataset_data dd
    WHERE dd.acquisition_framework_name = cd.:ca_field_name
        AND dd.dataset_name = cd.:jdd_field_name || ' ' || cd.noms_structure
)
;

SELECT * FROM export_oo.cor_dataset;


SELECT dataset_name, keywords FROM gn_meta.t_datasets;

-- cor_dataset actor production