

CREATE EXTENSION IF NOT EXISTS postgres_fdw;

--DROP SERVER obs_occ_server CASCADE;
CREATE SERVER obs_occ_server  
      FOREIGN DATA WRAPPER postgres_fdw 
      OPTIONS (host 'localhost', dbname 'obs_occ_pnc', port '5432');

CREATE USER MAPPING  
        FOR gn_user
        SERVER obs_occ_server
        OPTIONS (password 'obsocc_user_pass',user 'obsocc_user');

CREATE FOREIGN TABLE gn_imports.fdw_obs_occ_data
   (date_insert timestamp without time zone ,
    date_last_update timestamp without time zone ,
    unique_dataset_id uuid,
    id_obs integer ,
    unique_uuid uuid,
    date_obs date ,
    date_debut_obs date ,
    date_fin_obs date ,
    date_textuelle character varying ,
    regne character varying ,
    nom_vern character varying ,
    nom_complet character varying ,
    cd_nom text ,
    effectif_textuel character varying ,
    effectif_min bigint ,
    effectif_max bigint ,
    type_effectif character varying ,
    phenologie character varying ,
    id_waypoint character varying ,
    longitude double precision ,
    latitude double precision ,
    localisation character varying ,
    ids_observateur text[],
    observateur character varying ,
    id_numerisateur int,
    numerisateur character varying ,
    id_validateur int,
    validateur character varying ,
    structure character varying ,
    remarque_obs text ,
    code_insee character varying ,
    id_lieu_dit character varying ,
    diffusable boolean ,
    "precision" character varying ,
    statut_validation character varying ,
    id_etude integer ,
    id_protocole integer ,
    effectif bigint ,
    url_photo character varying ,
    commentaire_photo character varying ,
    decision_validation character varying ,
    heure_obs time without time zone ,
    determination character varying ,
    elevation bigint ,
    geometrie public.geometry ,
    phylum character varying ,
    classe character varying ,
    ordre character varying ,
    famille character varying ,
    nom_valide character varying ,
    qualification character varying ,
    comportement text )
   SERVER obs_occ_server
   OPTIONS (schema_name 'saisie', table_name 'v_export_for_synthese_gn2');
   


CREATE FOREIGN TABLE gn_imports.fdw_obs_occ_deleted (
  entity_source_pk_value int, 
  date_operation timestamp
)
   SERVER obs_occ_server
   OPTIONS (schema_name 'saisie', table_name 'v_export_deleted_data');
   
