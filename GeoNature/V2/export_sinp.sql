-- Export Open data des observations du PNE pour alimenter automatiquement et dynamiquement Data.gouv.fr et DataSud
-- https://www.data.gouv.fr/fr/datasets/observations-de-biodiversite-faune-flore-du-parc-national-des-ecrins/

 WITH jdd_acteurs AS (
         SELECT d_1.id_dataset,
            string_agg(DISTINCT concat(COALESCE(orga.nom_organisme, ((roles.nom_role::text || ' '::text) || roles.prenom_role::text)::character varying), ' (', nomencl.label_default, ')'), ', '::text) AS acteurs
           FROM gn_meta.t_datasets d_1
             JOIN gn_meta.cor_dataset_actor act ON act.id_dataset = d_1.id_dataset
             JOIN ref_nomenclatures.t_nomenclatures nomencl ON nomencl.id_nomenclature = act.id_nomenclature_actor_role
             LEFT JOIN utilisateurs.bib_organismes orga ON orga.id_organisme = act.id_organism
             LEFT JOIN utilisateurs.t_roles roles ON roles.id_role = act.id_role
          WHERE act.id_organism = 2 -- Pour ne remonter que les données où le PNE est acteur
          GROUP BY d_1.id_dataset
        )
 SELECT s.id_synthese,
    s.entity_source_pk_value AS id_source,
    s.unique_id_sinp AS id_perm_sinp,
    s.unique_id_sinp_grp AS id_perm_grp_sinp,
    s.date_min AS date_debut,
    s.date_max AS date_fin,
    t.cd_nom,
    t.cd_ref,
    s.meta_v_taxref AS version_taxref,
    s.nom_cite,
    t.nom_vern,
    t.nom_valide,
    t.regne,
    t.group1_inpn,
    t.group2_inpn,
    t.classe,
    t.ordre,
    t.famille,
    t.id_rang AS rang_taxo,
    s.count_min AS nombre_min,
    s.count_max AS nombre_max,
    s.altitude_min,
    s.altitude_max,
    s.depth_min AS profondeur_min,
    s.depth_max AS profondeur_max,
    s.observers AS observateurs,
    s.determiner AS determinateur,
    s.validator AS validateur,
    s.sample_number_proof AS numero_preuve,
    s.digital_proof AS preuve_numerique,
    s.non_digital_proof AS preuve_non_numerique,
    s.the_geom_4326 AS geom,
    s.comment_context AS comment_releve,
    s.comment_description AS comment_occurrence,
    s.meta_create_date AS date_creation,
    s.meta_update_date AS date_modification,
    COALESCE(s.meta_update_date, s.meta_create_date) AS derniere_action,
    d.unique_dataset_id AS jdd_uuid,
    d.dataset_name AS jdd_nom,
    jdd_acteurs.acteurs AS jdd_acteurs,
    af.unique_acquisition_framework_id AS ca_uuid,
    af.acquisition_framework_name AS ca_nom,
    s.reference_biblio,
    s.cd_hab AS code_habitat,
    h.lb_hab_fr AS habitat,
    s.place_name AS nom_lieu,
    s."precision",
    s.additional_data::text AS donnees_additionnelles,
    st_astext(s.the_geom_4326) AS wkt_4326,
    st_x(s.the_geom_point) AS x_centroid_4326,
    st_y(s.the_geom_point) AS y_centroid_4326,
    n1.label_default AS nature_objet_geo,
    n2.label_default AS type_regroupement,
    s.grp_method AS methode_regroupement,
    n3.label_default AS comportement,
    n4.label_default AS technique_obs,
    n5.label_default AS statut_biologique,
    n6.label_default AS etat_biologique,
    n7.label_default AS naturalite,
    n8.label_default AS preuve_existante,
    n9.label_default AS precision_diffusion,
    n10.label_default AS stade_vie,
    n11.label_default AS sexe,
    n12.label_default AS objet_denombrement,
    n13.label_default AS type_denombrement,
    n14.label_default AS niveau_sensibilite,
    n15.label_default AS statut_observation,
    n16.label_default AS floutage_dee,
    n17.label_default AS statut_source,
    n18.label_default AS type_info_geo,
    n19.label_default AS methode_determination
   FROM gn_synthese.synthese s
     JOIN taxonomie.taxref t ON t.cd_nom = s.cd_nom
     JOIN gn_meta.t_datasets d ON d.id_dataset = s.id_dataset
     JOIN jdd_acteurs ON jdd_acteurs.id_dataset = s.id_dataset
     JOIN gn_meta.t_acquisition_frameworks af ON d.id_acquisition_framework = af.id_acquisition_framework
     JOIN gn_synthese.t_sources sources ON sources.id_source = s.id_source
     LEFT JOIN ref_habitats.habref h ON h.cd_hab = s.cd_hab
     LEFT JOIN ref_nomenclatures.t_nomenclatures n1 ON s.id_nomenclature_geo_object_nature = n1.id_nomenclature
     LEFT JOIN ref_nomenclatures.t_nomenclatures n2 ON s.id_nomenclature_grp_typ = n2.id_nomenclature
     LEFT JOIN ref_nomenclatures.t_nomenclatures n3 ON s.id_nomenclature_behaviour = n3.id_nomenclature
     LEFT JOIN ref_nomenclatures.t_nomenclatures n4 ON s.id_nomenclature_obs_technique = n4.id_nomenclature
     LEFT JOIN ref_nomenclatures.t_nomenclatures n5 ON s.id_nomenclature_bio_status = n5.id_nomenclature
     LEFT JOIN ref_nomenclatures.t_nomenclatures n6 ON s.id_nomenclature_bio_condition = n6.id_nomenclature
     LEFT JOIN ref_nomenclatures.t_nomenclatures n7 ON s.id_nomenclature_naturalness = n7.id_nomenclature
     LEFT JOIN ref_nomenclatures.t_nomenclatures n8 ON s.id_nomenclature_exist_proof = n8.id_nomenclature
     LEFT JOIN ref_nomenclatures.t_nomenclatures n9 ON s.id_nomenclature_diffusion_level = n9.id_nomenclature
     LEFT JOIN ref_nomenclatures.t_nomenclatures n10 ON s.id_nomenclature_life_stage = n10.id_nomenclature
     LEFT JOIN ref_nomenclatures.t_nomenclatures n11 ON s.id_nomenclature_sex = n11.id_nomenclature
     LEFT JOIN ref_nomenclatures.t_nomenclatures n12 ON s.id_nomenclature_obj_count = n12.id_nomenclature
     LEFT JOIN ref_nomenclatures.t_nomenclatures n13 ON s.id_nomenclature_type_count = n13.id_nomenclature
     LEFT JOIN ref_nomenclatures.t_nomenclatures n14 ON s.id_nomenclature_sensitivity = n14.id_nomenclature
     LEFT JOIN ref_nomenclatures.t_nomenclatures n15 ON s.id_nomenclature_observation_status = n15.id_nomenclature
     LEFT JOIN ref_nomenclatures.t_nomenclatures n16 ON s.id_nomenclature_blurring = n16.id_nomenclature
     LEFT JOIN ref_nomenclatures.t_nomenclatures n17 ON s.id_nomenclature_source_status = n17.id_nomenclature
     LEFT JOIN ref_nomenclatures.t_nomenclatures n18 ON s.id_nomenclature_info_geo_type = n18.id_nomenclature
     LEFT JOIN ref_nomenclatures.t_nomenclatures n19 ON s.id_nomenclature_determination_method = n19.id_nomenclature
     LEFT JOIN ref_nomenclatures.t_nomenclatures dl ON s.id_nomenclature_diffusion_level = dl.id_nomenclature
     LEFT JOIN ref_nomenclatures.t_nomenclatures st ON s.id_nomenclature_observation_status = st.id_nomenclature
  WHERE (dl.cd_nomenclature::text = '5'::text OR s.id_nomenclature_diffusion_level IS NULL) AND st.cd_nomenclature::text = 'Pr'::text; -- Pour exclure les données non diffusables (diffusion_level = '5') et n'inclure que les données de présence

-- Export des données du PNE pour un partenaire, n'incluant que les observations de papillons
WITH jdd_acteurs AS (
         SELECT d_1.id_dataset,
            array_to_json(array_agg(DISTINCT jsonb_build_object('nom_organisme', orga.nom_organisme, 'uuid_organism', orga.uuid_organisme, 'nom_role', roles.nom_role, 'uuid_role', roles.uuid_role, 'type_role', nomencl.cd_nomenclature))) AS actors
           FROM gn_meta.t_datasets d_1
             JOIN gn_meta.cor_dataset_actor act ON act.id_dataset = d_1.id_dataset
             JOIN ref_nomenclatures.t_nomenclatures nomencl ON nomencl.id_nomenclature = act.id_nomenclature_actor_role
             LEFT JOIN utilisateurs.bib_organismes orga ON orga.id_organisme = act.id_organism
             LEFT JOIN utilisateurs.t_roles roles ON roles.id_role = act.id_role
          WHERE act.id_organism = 2 AND act.id_organism <> 110 -- Pour n'intégrer que les données du PNE et où le partenaire n'est pas acteur, pour ne pas lui renvoyer ses propres données
          GROUP BY d_1.id_dataset
        )
 SELECT DISTINCT s.id_synthese,
    s.entity_source_pk_value AS id_source,
    s.unique_id_sinp AS id_perm_sinp,
    s.unique_id_sinp_grp AS id_perm_grp_sinp,
    s.date_min AS date_debut,
    s.date_max AS date_fin,
    s.cd_nom,
    s.meta_v_taxref AS version_taxref,
    s.nom_cite,
    s.count_min AS nombre_min,
    s.count_max AS nombre_max,
    s.altitude_min,
    s.altitude_max,
    s.depth_min AS profondeur_min,
    s.depth_max AS profondeur_max,
    s.observers AS observateurs,
    s.determiner AS determinateur,
    s.validator AS validateur,
    s.sample_number_proof AS numero_preuve,
    s.digital_proof AS preuve_numerique,
    s.non_digital_proof AS preuve_non_numerique,
    s.comment_context AS comment_releve,
    s.comment_description AS comment_occurrence,
    COALESCE(s.meta_update_date, s.meta_create_date) AS derniere_action,
    td.unique_dataset_id AS jdd_uuid,
    td.dataset_name AS jdd_nom,
    af.unique_acquisition_framework_id AS ca_uuid,
    af.acquisition_framework_name AS ca_nom,
    s.reference_biblio,
    s.cd_hab AS code_habitat,
    h.lb_hab_fr AS habitat,
    s.place_name AS nom_lieu,
    s."precision",
    s.additional_data AS donnees_additionnelles,
    st_astext(st_transform(s.the_geom_local, 4326)) AS wkt_4326,
    n1.cd_nomenclature AS nature_objet_geo,
    n2.cd_nomenclature AS type_regroupement,
    s.grp_method AS methode_regroupement,
    n3.cd_nomenclature AS comportement,
    n4.cd_nomenclature AS technique_obs,
    n5.cd_nomenclature AS statut_biologique,
    n6.cd_nomenclature AS etat_biologique,
    n7.cd_nomenclature AS naturalite,
    n8.cd_nomenclature AS preuve_existante,
    n9.cd_nomenclature AS precision_diffusion,
    n10.cd_nomenclature AS stade_vie,
    n11.cd_nomenclature AS sexe,
    n12.cd_nomenclature AS objet_denombrement,
    n13.cd_nomenclature AS type_denombrement,
    n14.cd_nomenclature AS niveau_sensibilite,
    n15.cd_nomenclature AS statut_observation,
    n16.cd_nomenclature AS floutage_dee,
    n17.cd_nomenclature AS statut_source,
    n18.cd_nomenclature AS type_info_geo,
    n19.cd_nomenclature AS methode_determination,
    n20.cd_nomenclature AS statut_validation
   FROM gn_synthese.synthese s
     JOIN taxonomie.taxref tax ON tax.cd_nom = s.cd_nom
     LEFT JOIN gn_synthese.cor_area_synthese cas ON s.id_synthese = cas.id_synthese
     JOIN jdd_acteurs ON jdd_acteurs.id_dataset = s.id_dataset
     JOIN gn_meta.t_datasets td ON td.id_dataset = s.id_dataset
     JOIN gn_meta.t_acquisition_frameworks af ON td.id_acquisition_framework = af.id_acquisition_framework
     JOIN gn_synthese.t_sources sources ON sources.id_source = s.id_source
     LEFT JOIN ref_habitats.habref h ON h.cd_hab = s.cd_hab
     LEFT JOIN ref_nomenclatures.t_nomenclatures n1 ON s.id_nomenclature_geo_object_nature = n1.id_nomenclature
     LEFT JOIN ref_nomenclatures.t_nomenclatures n2 ON s.id_nomenclature_grp_typ = n2.id_nomenclature
     LEFT JOIN ref_nomenclatures.t_nomenclatures n3 ON s.id_nomenclature_behaviour = n3.id_nomenclature
     LEFT JOIN ref_nomenclatures.t_nomenclatures n4 ON s.id_nomenclature_obs_technique = n4.id_nomenclature
     LEFT JOIN ref_nomenclatures.t_nomenclatures n5 ON s.id_nomenclature_bio_status = n5.id_nomenclature
     LEFT JOIN ref_nomenclatures.t_nomenclatures n6 ON s.id_nomenclature_bio_condition = n6.id_nomenclature
     LEFT JOIN ref_nomenclatures.t_nomenclatures n7 ON s.id_nomenclature_naturalness = n7.id_nomenclature
     LEFT JOIN ref_nomenclatures.t_nomenclatures n8 ON s.id_nomenclature_exist_proof = n8.id_nomenclature
     LEFT JOIN ref_nomenclatures.t_nomenclatures n9 ON s.id_nomenclature_diffusion_level = n9.id_nomenclature
     LEFT JOIN ref_nomenclatures.t_nomenclatures n10 ON s.id_nomenclature_life_stage = n10.id_nomenclature
     LEFT JOIN ref_nomenclatures.t_nomenclatures n11 ON s.id_nomenclature_sex = n11.id_nomenclature
     LEFT JOIN ref_nomenclatures.t_nomenclatures n12 ON s.id_nomenclature_obj_count = n12.id_nomenclature
     LEFT JOIN ref_nomenclatures.t_nomenclatures n13 ON s.id_nomenclature_type_count = n13.id_nomenclature
     LEFT JOIN ref_nomenclatures.t_nomenclatures n14 ON s.id_nomenclature_sensitivity = n14.id_nomenclature
     LEFT JOIN ref_nomenclatures.t_nomenclatures n15 ON s.id_nomenclature_observation_status = n15.id_nomenclature
     LEFT JOIN ref_nomenclatures.t_nomenclatures n16 ON s.id_nomenclature_blurring = n16.id_nomenclature
     LEFT JOIN ref_nomenclatures.t_nomenclatures n17 ON s.id_nomenclature_source_status = n17.id_nomenclature
     LEFT JOIN ref_nomenclatures.t_nomenclatures n18 ON s.id_nomenclature_info_geo_type = n18.id_nomenclature
     LEFT JOIN ref_nomenclatures.t_nomenclatures n19 ON s.id_nomenclature_determination_method = n19.id_nomenclature
     LEFT JOIN ref_nomenclatures.t_nomenclatures n20 ON s.id_nomenclature_valid_status = n20.id_nomenclature
  WHERE tax.ordre::text = 'Lepidotera'::text -- Pour n'exporter que les papillons
  ORDER BY s.id_synthese;
