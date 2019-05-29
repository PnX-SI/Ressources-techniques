-- Import initial

-- !!!!!!!!!!!!!!!!! id_acquisition_framework en dur

CREATE SCHEMA import_obs_occ;
 IMPORT FOREIGN SCHEMA md
    LIMIT TO (md.etude, md.protocole)
    FROM SERVER obs_occ_server
    INTO import_obs_occ;


WITH bound as (
    SELECT st_extent(st_transform(geom, 4326)) as bbox
    FROM ref_geo.l_areas 
    WHERE id_type = 10002
)
INSERT INTO gn_meta.t_datasets( unique_dataset_id, id_acquisition_framework, dataset_name, 
            dataset_shortname, dataset_desc, 
            id_nomenclature_data_type, keywords, 
            marine_domain, terrestrial_domain, id_nomenclature_dataset_objectif, 
            bbox_west, bbox_east, bbox_south, bbox_north,
            default_validity)
SELECT unique_dataset_id, 1, libelle, libelle, COALESCE(resume, libelle), 
326, NULL, false, true, 415,
st_xmin(bbox), st_xmax(bbox), st_ymin(bbox), st_ymax(bbox),
true
FROM import_obs_occ.protocole, bound
WHERE NOT unique_dataset_id IN (SELECT unique_dataset_id FROM gn_meta.t_datasets);

-- Import des sources
INSERT INTO gn_synthese.t_sources(
            name_source, desc_source, entity_source_pk_field, 
            url_source)
VALUES (
    'obs_occ', 'Données issue de observations occasionelles', 'saisie.saisie_observation.id_obs', 
    'appli.cevennes-parcnational.net/obs_occ'
);

DROP SCHEMA import_obs_occ;