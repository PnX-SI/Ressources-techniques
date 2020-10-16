-- BASE GN

-- PATCH pour les test du script

-- On crée un jdd et un CA pour tester les importd
-- Toutes les données auront le même JDD

-- Cette partie doit être faite 'à la main'
-- cad creer les CA et JDD GN et les associer aux protocoles et etude OO dans la table export_oo.cor_dataset

-- on fait en sorte de ne pas pouvoir recreer les infos deux fois
-- suppression creation


-- suppression

DELETE FROM pr_occtax.t_releves_occtax r 
USING gn_meta.t_datasets d 
WHERE r.id_dataset = d.id_dataset AND d.dataset_name LIKE :'%db_oo_name%';

DELETE FROM gn_meta.t_datasets WHERE dataset_name LIKE :'%db_oo_name%';

DELETE FROM gn_meta.t_acquisition_frameworks WHERE acquisition_framework_name LIKE :'%db_oo_name%';


-- CA

INSERT INTO gn_meta.t_acquisition_frameworks(
        acquisition_framework_name, 
        acquisition_framework_desc,
        acquisition_framework_start_date
)
SELECT 
    CONCAT(:ca_field_name,:' do_oo_name'),
    CONCAT(:ca_field_name,:' do_oo_name')
    NOW()::date
    FROM export_oo.cor_dataset


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
        CONCAT(:jdd_field_name, :' do_oo_name'),
        CONCAT(:jdd_field_name, :' do_oo_name'),
        CONCAT(:jdd_field_name, :' do_oo_name'),
        FALSE,
        FALSE
        
        FROM gn_meta.t_acquisition_frameworks af
        WHERE af.acquisition_framework_name = CONCAT(:ca_field_name,:' do_oo_name'),
;


-- fill up export_oo.cor_dataset

UPDATE export_oo.cor_dataset cd SET (id_dataset) = ( 
    SELECT id_dataset 
    FROM gn_meta.t_datasets d
    JOIN gn_meta.t_acquisition_framework a 
        ON a.id_acquistion_framework = d.id_acquisition_framework
    WHERE ca.acquisition_framework_name = CONCAT(:ca_field_name,:' do_oo_name')
        AND d.dataset_name = CONCAT(:jdd_field_name, :' do_oo_name')
)       
;