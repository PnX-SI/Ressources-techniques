-- ### METADONNEES ### --

-- /!\ Les cadres d'acquisition et les jeux de données pour les données importés ont été crées depuis l'interface d'admin de Geonature
-- (Il est toutefois possible de les intégrer directement en SQL dans le schema gn_meta et en prenant soin de respecter les contraintes et les relations avec les autres objets de la BDD)

-- Cependant les emprises géographiques des Jeux de données n'ont pas été calculées via l'admin - on va donc mettre à jour manuellement la table gn_meta.t_datasets

-- On identifie d'abord l'id_area de son territoire dans l_areas et on relève l'id_area pour la requête suivante :
-- SELECT id_area, id_type, area_name, area_code
-- 	FROM ref_geo.l_areas
-- 	WHERE area_name ilike '%vercors%'
-- 	AND id_type = 15;

-- On fait un update de la table gn_meta.t_datasets :	
-- WITH bound as (
-- SELECT st_extent(st_transform(geom, 4326)) as bbox
-- FROM ref_geo.l_areas
-- WHERE id_area = 35288)
--
-- UPDATE gn_meta.t_datasets
-- 	SET bbox_west=st_xmin(bbox), bbox_east=st_xmax(bbox), bbox_south=st_ymin(bbox), bbox_north=st_ymax(bbox)
-- 	FROM bound;

-- Ajout des sources de données à importer dans la table gn_synthese.t_sources
-- Ici, on joute une seule source pour l'ensemble des JDD identifiés dans Serena (ajouts manuellement dans GN via l'interface d'admin)

/* TODO: Personnaliser la source*/
INSERT INTO
    gn_synthese.t_sources(name_source, desc_source, entity_source_pk_field, url_source)
    VALUES
    ('SERENA', 'Données issues de l''application Serena', 'serenabase.rnf_obse.obse_id', 'NULL');

-- ### IMPORT SYNTHESE ### --

-- On désactive les triggers sur la synthese avant l'import
ALTER TABLE gn_synthese.synthese
    DISABLE TRIGGER ALL;

-- On peuple la sythèse en s'appuyant sur la vue matérialisée crée à l'étape 1.3 : _import_serena.vm_obs_serena_detail_pt
-- en réalisant les calculs, correspondances et conversions de champs nécessaire pour peupler gn_synthese.synthese

INSERT INTO
    gn_synthese.synthese( unique_id_sinp
                        , unique_id_sinp_grp
                        , id_source
                        , entity_source_pk_value
                        , id_dataset
                        , id_nomenclature_geo_object_nature
                        , id_nomenclature_grp_typ
                        , id_nomenclature_obs_technique
                        , id_nomenclature_bio_status
                        , id_nomenclature_bio_condition
                        , id_nomenclature_naturalness
                        , id_nomenclature_exist_proof
                        , id_nomenclature_valid_status
                        , id_nomenclature_diffusion_level
                        , id_nomenclature_life_stage
                        , id_nomenclature_sex
                        , id_nomenclature_obj_count
                        , id_nomenclature_type_count
                        , id_nomenclature_sensitivity
                        , id_nomenclature_observation_status
                        , id_nomenclature_blurring
                        , id_nomenclature_source_status
                        , id_nomenclature_info_geo_type
                        , count_min
                        , count_max
                        , cd_nom
                        , nom_cite
                        , meta_v_taxref
                        , sample_number_proof
                        , digital_proof
                        , non_digital_proof
                        , altitude_min
                        , altitude_max
                        , the_geom_4326
                        , the_geom_point
                        , the_geom_local
                        , date_min
                        , date_max
                        , validator
                        , validation_comment
                        , observers
                        , determiner
                        , id_digitiser
                        , id_nomenclature_determination_method
                        , comment_description
                        , additional_data
                        , meta_validation_date
                        , meta_create_date
                        , meta_update_date
                        , last_action)
    (SELECT DISTINCT
--          NULL::uuid                                              AS unique_id_sinp
         uuid_generate_v4()                                                            AS unique_id_sinp
       , NULL::uuid                                                                    AS unique_id_sinp_grp
       , id_source                                                                     as id_source
       , d.obse_id                                                                     as entity_source_pk_value
       , COALESCE(jdd.id_dataset, 1)
       , ref_nomenclatures.get_id_nomenclature('NAT_OBJ_GEO', 'NSP') ::integer         AS id_nomenclature_geo_object_nature
       , ref_nomenclatures.get_id_nomenclature('TYP_GRP', 'OBS') ::integer             AS id_nomenclature_grp_typ
       , COALESCE(ref_nomenclatures.get_synonymes_nomenclature('METH_OBS', methode_obs),
                  ref_nomenclatures.get_id_nomenclature('METH_OBS', '21'))::integer    as id_nomenclature_obs_technique
       , COALESCE(ref_nomenclatures.get_synonymes_nomenclature('STATUT_BIO', statut_bio),
                  ref_nomenclatures.get_id_nomenclature('STATUT_BIO', '0'))::integer   AS id_nomenclature_bio_status
       , COALESCE(ref_nomenclatures.get_synonymes_nomenclature('ETA_BIO', etat_bio),
                  ref_nomenclatures.get_id_nomenclature('ETA_BIO', 'NSP'))::integer    AS id_nomenclature_bio_condition
       , ref_nomenclatures.get_id_nomenclature('NATURALITE', '0')::integer             AS id_nomenclature_naturalness
       , ref_nomenclatures.get_id_nomenclature('PREUVE_EXIST', '0')::integer           AS id_nomenclature_exist_proof
       , COALESCE(ref_nomenclatures.get_synonymes_nomenclature('STATUT_VALID', statut_validation),
                  ref_nomenclatures.get_id_nomenclature('STATUT_VALID', '6'))::integer AS id_nomenclature_valid_status
       , ref_nomenclatures.get_id_nomenclature('NIV_PRECIS', '5')::integer             AS id_nomenclature_diffusion_level
       , COALESCE(ref_nomenclatures.get_synonymes_nomenclature('STADE_VIE', stade_vie),
                  ref_nomenclatures.get_id_nomenclature('STADE_VIE', '0'))::integer    AS id_nomenclature_life_stage
       , COALESCE(ref_nomenclatures.get_synonymes_nomenclature('SEXE', sexe),
                  ref_nomenclatures.get_id_nomenclature('SEXE', '0'))::integer         AS id_nomenclature_sex
       , ref_nomenclatures.get_id_nomenclature('OBJ_DENBR', 'NSP')::integer            AS id_nomenclature_obj_count
       , COALESCE(ref_nomenclatures.get_synonymes_nomenclature('OBJ_DENBR', type_denombrement),
                  ref_nomenclatures.get_id_nomenclature('TYP_DENBR', 'NSP'))::integer  AS id_nomenclature_type_count
       , COALESCE(ref_nomenclatures.get_synonymes_nomenclature('SENSIBILITE', confidentialite),
                  ref_nomenclatures.get_id_nomenclature('SENSIBILITE', '0'))::integer  AS id_nomenclature_sensitivity
--        , ref_nomenclatures.get_id_nomenclature('TYP_DENBR', 'NSP')                                                                    AS id_nomenclature_observation_status
       , NULL::int                                                                     AS id_nomenclature_observation_status
       , ref_nomenclatures.get_id_nomenclature('DEE_FLOU', 'NSP')                      AS id_nomenclature_blurring
       , ref_nomenclatures.get_id_nomenclature('STATUT_SOURCE', 'NSP')                 AS id_nomenclature_source_status
       , ref_nomenclatures.get_id_nomenclature('TYP_INF_GEO', '1')                     AS id_nomenclature_info_geo_type
       , d.effectif_mix                                                                AS count_min
       , d.effectif_max                                                                AS count_max
       , d.taxo_mnhn_id                                                                AS cd_nom
       , COALESCE(t.nom_complet, t.nom_vern)                                           as nom_cite
       , 'Taxref V11'                                                                  as meta_v_taxref
       , NULL                                                                          AS sample_number_proof
       , NULL                                                                          AS digital_proof
       , NULL                                                                          AS non_digital_proof
       , d.altitude                                                                    as altitude_min
       , d.altitude                                                                    as altitude_max
       , st_transform(st_setsrid(geom, 2154), 4326)                                    as the_geom_4326
       , st_transform(st_centroid(st_setsrid(geom, 2154)), 4326)                       as the_geom_point
       , st_setsrid(geom, 2154)                                                        as the_geom_local
       , d.date
       , d.date
       , NULL                                                                          as validator
       , NULL                                                                          as validation_comment
       , d.observateur                                                                 as observers
       , d.determinateur                                                               as determiner
       , NULL::integer                                                                 as id_digitiser
       , NULL::integer                                                                 as id_nomenclature_determination_method
       , d.obse_comment                                                                as comments
       , jsonb_build_object(
        'methode_loc', d.methode_loc,
        'age', d.age,
        'comportement', d.comportement,
        'etat_sante', d.etat_sante,
        'bague', d.obse_bague,
        'multi_criteres', d.obse_multicr)                                              as additional_data
       , NULL::timestamp without time zone                                             as meta_validation_date
       , d.obse_crea_dath::timestamp without time zone                                 as meta_create_date
       , d.obse_lmod_dath::timestamp without time zone                                 as meta_update_date
       , 'I'                                                                           as last_action
         FROM
             _import_serena.vm_obs_serena_detail_point as d
                 join gn_meta.t_datasets jdd on d.obse_relv_id = jdd.entity_source_pk_value
                 JOIN taxonomie.taxref t ON d.taxo_mnhn_id = t.cd_nom
--                  left JOIN gn_meta.t_datasets ds ON d.obse_relv_id::text = ds.dataset_shortname
           , gn_synthese.t_sources
         where
             name_source like 'SERENA'
         ORDER BY d.date DESC
    );
--
-- update gn_synthese.synthese
-- SET
--     id_dataset = jdd.id_dataset
--     from
--         _import_serena.vm_obs_serena_detail_point d
--             join gn_meta.t_datasets jdd
--                  on d.obse_relv_id = jdd.entity_source_pk_value
--     where
--           d.obse_id::text = synthese.entity_source_pk_value
--       and id_source = (select
--                            id_source
--                            from
--                                gn_synthese.t_sources
--                            where
--                                name_source like 'SerenaAFFO');

-- On calcule cor_area_synthese (triggers désactivés)
WITH
    s AS
        (SELECT *
             FROM
                 gn_synthese.synthese
             WHERE
                 NOT id_synthese IN (SELECT id_synthese FROM gn_synthese.cor_area_synthese))
INSERT
    INTO
        gn_synthese.cor_area_synthese
SELECT
    id_synthese
  , id_area
    FROM
        s
            JOIN ref_geo.l_areas l
                 ON st_intersects(s.the_geom_local, l.geom);

-- On calcule aussi les résultats de recherche de taxons suggérés dans l'outil de recherche de Synthèse (trigger désactivé)
INSERT INTO
    gn_synthese.taxons_synthese_autocomplete
    (SELECT
         t.cd_nom
       , t.cd_ref
       , concat(t.lb_nom, ' = <i>', t.nom_valide, '</i>') AS search_name
       , t.nom_valide
       , t.lb_nom
       , t.regne
       , t.group2_inpn
         FROM
             taxonomie.taxref t
                 JOIN taxonomie.bib_noms n ON t.cd_nom = n.cd_nom
                 LEFT JOIN gn_synthese.taxons_synthese_autocomplete s ON n.cd_nom = s.cd_nom
         WHERE
             s.cd_nom IS NULL)
UNION
(SELECT
     t.cd_nom
   , t.cd_ref
   , concat(t.nom_vern, ' =  <i> ', t.nom_valide, '</i>') AS search_name
   , t.nom_valide
   , t.lb_nom
   , t.regne
   , t.group2_inpn
     FROM
         taxonomie.taxref t
             JOIN taxonomie.bib_noms n ON t.cd_nom = n.cd_nom
             LEFT JOIN gn_synthese.taxons_synthese_autocomplete s ON n.cd_nom = s.cd_nom
     WHERE
           t.nom_vern IS NOT NULL
       AND s.cd_nom IS NULL);

-- TO DO : Calcul de l'altitude

-- On réactive les triggers
ALTER TABLE gn_synthese.synthese
    ENABLE TRIGGER ALL;


select
    count(*)
    from
        gn_synthese.synthese
    where
        id_dataset = 230;
