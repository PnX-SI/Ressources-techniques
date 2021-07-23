-- creation du dataset

INSERT INTO gn_meta.t_datasets(
    id_acquisition_framework,
    dataset_name,
    dataset_shortname,
    dataset_desc,
    active,
    validable,
    marine_domain,
    terrestrial_domain,
    id_nomenclature_data_type,
    id_nomenclature_dataset_objectif,
    id_nomenclature_collecting_method,
    id_nomenclature_data_origin,
    id_nomenclature_source_status,
    id_nomenclature_resource_type
)
	SELECT 
	    af.id_acquisition_framework,
	    'Oedicnèmes' AS dataset_name,
	    'Oedic.' AS dataset_shortname,
	    'Suivi Oedicnèmes' AS dataset_name,
	    TRUE AS active,
	    TRUE AS validable,
	    FALSE AS marine_domain,
	    TRUE AS terrestrial_domain,
	    ref_nomenclatures.get_id_nomenclature('DATA_TYP', '3') AS id_nomenclature_data_type,
	    ref_nomenclatures.get_id_nomenclature('JDD_OBJECTIFS', '1.3') AS id_nomenclature_dataset_objectif,
	    ref_nomenclatures.get_id_nomenclature('METHO_RECUEIL', '1') AS id_nomenclature_collecting_method,
	    ref_nomenclatures.get_id_nomenclature('DS_PUBLIQUE', 'Pu') AS id_nomenclature_data_origin,
	    ref_nomenclatures.get_id_nomenclature('STATUT_SOURCE', 'Te') AS id_nomenclature_source_status,
	    ref_nomenclatures.get_id_nomenclature('RESOURCE_TYP', '2') AS id_nomenclature_resource_type
	    
	    FROM gn_meta.t_acquisition_frameworks af
	    WHERE af.acquisition_framework_name = 'Données d''observation de la faune, de la Flore et de la fonge du Parc national des Cévennes'
;