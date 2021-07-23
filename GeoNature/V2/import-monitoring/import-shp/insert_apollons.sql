-- Préparation
/*
CREATE TABLE tmp_process.dalles_apollons AS 
WITH U AS (
    SELECT * FROM tmp_process.dalles_negatives_2018_3 dn 
    UNION
    SELECT * FROM tmp_process.dalles_positives_2018_3 dp 
) 
SELECT *, uuid_generate_v4() AS uuid
FROM u;
*/

-- INSERTION des groupes de sites

INSERT INTO gn_monitoring.t_sites_groups (id_module, sites_group_name, sites_group_code
 -- sites_group_description, uuid_sites_group, "comments",
 -- "data", meta_create_date, meta_update_date
)
SELECT DISTINCT 
    (SELECT id_module FROM gn_commons.t_modules tm  WHERE module_code = 'apollons'),
    REPLACE(site, '_' ,' '),
    site
FROM tmp_process.dalles_apollons;
    
-- Insertion des sites
INSERT INTO gn_monitoring.t_base_sites
(id_inventor, id_digitiser, id_nomenclature_type_site, base_site_name, base_site_description, base_site_code, 
    first_use_date, geom, uuid_base_site ,
    --meta_create_date, meta_update_date, altitude_min, altitude_max, 
    geom_local
    --, old_chiro_id
    )
SELECT 1000123 AS id_inventor, 142 AS id_digitiser, 
    ref_nomenclatures.get_id_nomenclature( 'TYPE_SITE', 'APO_DALLES') AS id_nomenclature_type_site,
    nom AS base_site_name, NULL AS base_site_description, nom AS base_site_code,
    '2018-01-01' AS first_use_date,
    st_transform(ST_Force2D( geom), 4326) AS geom, uuid AS uuid_base_site,
    ST_Force2D(geom) AS geom_local 
FROM tmp_process.dalles_apollons;

-- Insertion site compléments
INSERT INTO gn_monitoring.t_site_complements (id_base_site, id_module, id_sites_group )
SELECT id_base_site, 
    (SELECT id_module FROM gn_commons.t_modules tm  WHERE module_code = 'apollons') AS id_module ,
    id_sites_group
FROM tmp_process.dalles_apollons a
JOIN gn_monitoring.t_base_sites tbs 
ON a.uuid = tbs.uuid_base_site 
JOIN gn_monitoring.t_sites_groups ts
ON ts.sites_group_code = a.site;

-- Insertion images
INSERT INTO gn_commons.t_medias
(unique_id_media, id_nomenclature_media_type, id_table_location, uuid_attached_row,
    title_fr, 
    --title_en, title_it, title_es, title_de, 
    media_url, media_path, author
    --description_fr, description_en, description_it, description_es, description_de,
    --is_public, meta_create_date, meta_update_date
)
SELECT uuid_generate_v4() AS unique_id_media, 467 AS id_nomenclature_media_type, 2 AS id_table_location, 
    tbs.uuid_base_site AS uuid_attached_row , 
    concat('Photo de situation de la dalle', tbs.base_site_name ),
    NULL AS media_url, CONCAT('static/medias/2/dalle_', (string_to_array(REPLACE(image, '\', '/'), '/'))[13]) AS media_path,
    'Maily MOSCHETTI'
FROM tmp_process.dalles_apollons a
JOIN gn_monitoring.t_base_sites tbs 
ON a.uuid = tbs.uuid_base_site;

-- En parallèle copier les fichiers

--Insertion visites
WITH ds AS (
    SELECT id_dataset 
    FROM gn_commons.cor_module_dataset cmd 
    WHERE id_module = (SELECT id_module FROM gn_commons.t_modules tm  WHERE module_code = 'apollons')
)INSERT INTO gn_monitoring.t_base_visits
(id_base_site, id_digitiser, visit_date_min, visit_date_max, "comments",
--, uuid_base_visit, meta_create_date, meta_update_date,
id_dataset, --, id_nomenclature_tech_collect_campanule, id_nomenclature_grp_typ,
 id_module
--, old_chiro_id
)
SELECT s.id_base_site , 142, time::date, time::date,  'Importation automatique des données de Maily MOSCHETTI' AS comments, 
(SELECT id_dataset FROM ds), (SELECT id_module FROM gn_commons.t_modules tm  WHERE module_code = 'apollons')
FROM tmp_process.dalles_apollons a
JOIN gn_monitoring.t_base_sites s 
ON a.uuid = s.uuid_base_site ;

--Insertion compléments
INSERT INTO gn_monitoring.t_visit_complements
(id_base_visit, "data")
WITH a AS (
    SELECT uuid , v.id_base_visit, s.id_base_site ,
    time::time AS time_first_detection,
    CASE WHEN  a.occupation  = 'positif' THEN 89 ELSE 87 END AS id_nomenclature_statut_obs
    FROM tmp_process.dalles_apollons a 
    JOIN gn_monitoring.t_base_sites s
    ON s.uuid_base_site = a.uuid
    JOIN gn_monitoring.t_base_visits v
    ON v.id_base_site = s.id_base_site
)
SELECT id_base_visit ,
    json_build_object(
        'cd_nom', 54496,
        'num_passage', '1',
        'time_first_detection', time_first_detection,
        'id_nomenclature_statut_obs', id_nomenclature_statut_obs
    ) AS data
FROM a
 ;

 -- Observateurs
 INSERT INTO gn_monitoring.cor_visit_observer (id_base_visit, id_role)
 SELECT v.id_base_visit , 1000123
 FROM tmp_process.dalles_apollons a 
    JOIN gn_monitoring.t_base_sites s
    ON s.uuid_base_site = a.uuid
    JOIN gn_monitoring.t_base_visits v
    ON v.id_base_site = s.id_base_site;
