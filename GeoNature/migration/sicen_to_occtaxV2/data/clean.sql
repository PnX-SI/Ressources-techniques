DELETE FROM pr_occtax.t_releves_occtax r 
USING gn_meta.t_datasets d 
WHERE r.id_dataset = d.id_dataset AND d.dataset_name LIKE '%' || :'db_oo_name' || '%';

DELETE FROM gn_meta.t_datasets WHERE dataset_name LIKE '%' || :'db_oo_name' || '%';

DELETE FROM gn_meta.t_acquisition_frameworks WHERE acquisition_framework_name LIKE '%' || :'db_oo_name' || '%';

    