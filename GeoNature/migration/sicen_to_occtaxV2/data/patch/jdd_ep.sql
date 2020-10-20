-- BASE GN

-- PATCH pour CA JDD
-- :ca_field_name libelle_protocole|nom_etude
-- :jdd_field_name libelle_protocole|nom_etude

-- CA

INSERT INTO gn_meta.t_acquisition_frameworks(
        acquisition_framework_name, 
        acquisition_framework_desc,
        acquisition_framework_start_date
)
SELECT DISTINCT
    :ca_field_name || ' ' || :'db_oo_name',
    :ca_field_name || ' ' || :'db_oo_name',
    NOW()::date
    FROM export_oo.cor_dataset
;


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
        :jdd_field_name || ' ' || :'db_oo_name',
        :jdd_field_name || ' ' || :'db_oo_name',
        :jdd_field_name || ' ' || :'db_oo_name',
        FALSE,
        FALSE

        FROM export_oo.cor_dataset cd
        JOIN gn_meta.t_acquisition_frameworks af
            ON af.acquisition_framework_name LIKE :ca_field_name || ' ' || :'db_oo_name'
;


WITH dataset_data AS (
    SELECT DISTINCT id_dataset, d.id_acquisition_framework, d.dataset_name, ca.acquisition_framework_name 
    FROM gn_meta.t_datasets d
    JOIN gn_meta.t_acquisition_frameworks ca 
        ON ca.id_acquisition_framework = d.id_acquisition_framework
    WHERE id_dataset > 100
    ORDER BY id_acquisition_framework, id_dataset
)
SELECT * FROM dataset_data;

SELECT * from export_oo.cor_dataset;

-- fill up export_oo.cor_dataset

WITH dataset_data AS (
    SELECT id_dataset, d.dataset_name, ca.acquisition_framework_name 
    FROM gn_meta.t_datasets d
    JOIN gn_meta.t_acquisition_frameworks ca 
        ON ca.id_acquisition_framework = d.id_acquisition_framework
)
SELECT  dd.id_dataset, dataset_name, acquisition_framework_name, libelle_protocole, nom_etude, nom_structure FROM export_oo.cor_dataset cd
JOIN dataset_data dd
ON dd.acquisition_framework_name = cd.:ca_field_name || ' ' || :'db_oo_name'
        AND dd.dataset_name = cd.:jdd_field_name || ' ' || :'db_oo_name'

;


WITH dataset_data AS (
    SELECT id_dataset, d.dataset_name, ca.acquisition_framework_name 
    FROM gn_meta.t_datasets d
    JOIN gn_meta.t_acquisition_frameworks ca 
        ON ca.id_acquisition_framework = d.id_acquisition_framework
)
UPDATE export_oo.cor_dataset cd SET (id_dataset) = (SELECT id_dataset FROM dataset_data dd
   WHERE dd.acquisition_framework_name = cd.:ca_field_name || ' ' || :'db_oo_name'
        AND dd.dataset_name = cd.:jdd_field_name || ' ' || :'db_oo_name'
)
;