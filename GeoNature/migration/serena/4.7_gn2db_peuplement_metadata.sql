/* Création des JDD issues de SERENA 
    ATTENTION, personnaliser les zones identifiées par les commentaires TODO!!!
*/

/* Ajout provisoire d'un champ entity_source_pk_value uniqe pour faire le lien avec les JDD SERENA */
alter table gn_meta.t_datasets
    add column entity_source_pk_value int;

alter table gn_meta.t_datasets
    add constraint unique_entity_source_pk_value unique (entity_source_pk_value);

/* Création des JDD dans un CA prédéfini (à créer préalablement dans GeoNature) */
INSERT INTO
    gn_meta.t_datasets( id_acquisition_framework
                      , entity_source_pk_value
                      , dataset_name
                      , dataset_shortname
                      , dataset_desc
                      , keywords
                      , marine_domain
                      , terrestrial_domain
                      , meta_create_date
                      , meta_update_date
                      , id_digitizer)
select
    (select
         id_acquisition_framework
         from
             gn_meta.t_acquisition_frameworks
         where
         /* TODO; spécifier ici l'UUID du CA à associer aux JDD de SERENA */
             unique_acquisition_framework_id = '<monUUIDAcquisitionFramework>')
  , relv_id                                                  entity_source_pk_value
  , relv_nom                                              as dataset_name
  , relv_nom                                              as dataset_shortname
  , coalesce(relv_categ_choi_nom || relv_comment, 'None') as dataset_desc
  , NULL                                                  as keywords
  , false                                                 as marine_domain
  , true                                                  as terrestrial_domain
  , now()
  , now()
  , (select id_role from utilisateurs.t_roles where identifiant like 'cedric.delcloy')
    from
        _import_serena.v_rnf_revl_jdd
ON CONFLICT DO NOTHING
;


/* Mettre le gestionnaire du SERENA  en contact principal des JDD */

INSERT INTO
    gn_meta.cor_dataset_actor (id_dataset, id_organism, id_nomenclature_actor_role)
select
    id_dataset
  , id_organisme
  , ref_nomenclatures.get_id_nomenclature('ROLE_ACTEUR', '4')
    from
        gn_meta.t_datasets
      , utilisateurs.bib_organismes

    where
    /* TODO : Spécifier ici l'organisme gestionnaire de SERENA */
          bib_organismes.nom_organisme like '<monFournisseurSerena>'
      and entity_source_pk_value is (select relv_id from _import_serena.v_rnf_revl_jdd)
    ON CONFLICT DO NOTHING;
