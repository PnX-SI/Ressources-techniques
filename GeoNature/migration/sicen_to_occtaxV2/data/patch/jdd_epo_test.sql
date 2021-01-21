-- BASE GN

-- PATCH pour CA JDD
-- libelle_protocole libelle_protocole|nom_etude
-- nom_etude libelle_protocole|nom_etude

-- CA

SELECT * FROM gn_meta.t_acquisition_frameworks;

INSERT INTO gn_meta.t_acquisition_frameworks(
        acquisition_framework_name, 
        acquisition_framework_desc,
        acquisition_framework_start_date
)
SELECT DISTINCT
    libelle_protocole,
    libelle_protocole || ' ' || 'pn_gua',
    NOW()::date
    FROM export_oo.cor_dataset
;


SELECT * FROM gn_meta.t_acquisition_frameworks;


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
        nom_etude || ' ' || noms_structure,
        nom_etude || ' ' || noms_structure,
        nom_etude || ' ' || 'pn_gua',
        FALSE,
        FALSE

        FROM export_oo.cor_dataset cd
        JOIN gn_meta.t_acquisition_frameworks af
            ON af.acquisition_framework_desc LIKE libelle_protocole || ' ' || 'pn_gua'
;

WITH dataset_data AS (
    SELECT id_dataset, d.dataset_desc, ca.acquisition_framework_name 
    FROM export_oo.v_datasets d
    JOIN gn_meta.t_acquisition_frameworks ca 
        ON ca.id_acquisition_framework = d.id_acquisition_framework
)
UPDATE export_oo.cor_dataset cd SET (id_dataset) = (
    SELECT id_dataset FROM dataset_data dd
    WHERE dd.acquisition_framework_name LIKE CONCAT('%', cd.libelle_protocole, '%')

        AND dd.dataset_desc LIKE CONCAT('%', cd.nom_etude, '%')
)
;

-- cor_dataset actor production