-- BASE GN

-- PATCH pour CA JDD
-- :ca_field_name libelle_protocole|nom_etude
-- :jdd_field_name libelle_protocole|nom_etude

-- suppression

DELETE FROM pr_occtax.t_releves_occtax r 
USING gn_meta.t_datasets d 
WHERE r.id_dataset = d.id_dataset AND d.dataset_name LIKE '%' || :'db_oo_name' || '%';

DELETE FROM gn_meta.t_datasets WHERE dataset_name LIKE '%' || :'db_oo_name' || '%';

DELETE FROM gn_meta.t_acquisition_frameworks WHERE acquisition_framework_name LIKE '%' || :'db_oo_name' || '%';


-- CA

INSERT INTO gn_meta.t_acquisition_frameworks(
        acquisition_framework_name, 
        acquisition_framework_desc,
        acquisition_framework_start_date
)
SELECT 
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
    SELECT
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

-- fill up export_oo.cor_dataset

UPDATE export_oo.cor_dataset cd SET (id_dataset) = ( 
    SELECT id_dataset 
    FROM gn_meta.t_datasets d
    JOIN gn_meta.t_acquisition_frameworks ca 
        ON ca.id_acquisition_framework = d.id_acquisition_framework
    WHERE ca.acquisition_framework_name = :ca_field_name || ' ' || :'db_oo_name'
        AND d.dataset_name = :jdd_field_name || ' ' || :'db_oo_name'
)       
;