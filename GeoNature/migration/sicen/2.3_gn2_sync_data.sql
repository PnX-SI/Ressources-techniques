
REFRESH MATERIALIZED VIEW gn_imports.v_qry_synthese_obs_occ;
SELECT gn_imports.import_static_source('gn_imports.v_qry_synthese_obs_occ', (SELECT id_source FROM gn_synthese.t_sources  WHERE name_source = 'obs_occ'
), NULL);

REFRESH MATERIALIZED VIEW gn_imports.v_qry_synthese_obs_occ_deleted;
SELECT  gn_imports.delete_static_source('gn_imports.v_qry_synthese_obs_occ_deleted', (SELECT id_source FROM gn_synthese.t_sources  WHERE name_source = 'obs_occ'
));