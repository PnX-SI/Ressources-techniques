/*
 04/01/2021
   creation des tables pour l'ajout automatique des donnees externes de synthse dans OCCTAX
   synthese_ajout contient les lignes ajoutéees dans synthese inexistantes dans OCCTAX 
      la colonne id_synthese est renseignée mais pas unique_id_sinp_grp
	  on insére les lignes avec unique_id_sinp_grp à NULL depuis synthése
	  
   la table synthese_maj contient les lignes de cette table supprimées de synthese ou ajoutéees
       si ajoutees alors id_synthese est à NULL on ajoute directement depuis la table temporaire import
	   puis on execute le script python d'ajout synthse et OCCTAX

*/

-- Drop table

-- DROP TABLE gn_synthese.synthese_ajout;

CREATE TABLE gn_synthese.synthese_ajout (
    id_ajout serial primary key,
	id_synthese int4 NULL,
	unique_id_sinp uuid NULL,
	unique_id_sinp_grp uuid NULL,
	id_source int4 NULL,
	id_module int4 NULL,
	entity_source_pk_value varchar NULL,
	id_dataset int4 NULL,
	id_nomenclature_geo_object_nature int4 NULL DEFAULT gn_synthese.get_default_nomenclature_value('NAT_OBJ_GEO'::character varying),
	id_nomenclature_grp_typ int4 NULL DEFAULT gn_synthese.get_default_nomenclature_value('TYP_GRP'::character varying),
	id_nomenclature_obs_technique int4 NULL DEFAULT gn_synthese.get_default_nomenclature_value('METH_OBS'::character varying),
	id_nomenclature_bio_status int4 NULL DEFAULT gn_synthese.get_default_nomenclature_value('STATUT_BIO'::character varying),
	id_nomenclature_bio_condition int4 NULL DEFAULT gn_synthese.get_default_nomenclature_value('ETA_BIO'::character varying),
	id_nomenclature_naturalness int4 NULL DEFAULT gn_synthese.get_default_nomenclature_value('NATURALITE'::character varying),
	id_nomenclature_exist_proof int4 NULL DEFAULT gn_synthese.get_default_nomenclature_value('PREUVE_EXIST'::character varying),
	id_nomenclature_valid_status int4 NULL DEFAULT gn_synthese.get_default_nomenclature_value('STATUT_VALID'::character varying),
	id_nomenclature_diffusion_level int4 NULL,
	id_nomenclature_life_stage int4 NULL DEFAULT gn_synthese.get_default_nomenclature_value('STADE_VIE'::character varying),
	id_nomenclature_sex int4 NULL DEFAULT gn_synthese.get_default_nomenclature_value('SEXE'::character varying),
	id_nomenclature_obj_count int4 NULL DEFAULT gn_synthese.get_default_nomenclature_value('OBJ_DENBR'::character varying),
	id_nomenclature_type_count int4 NULL DEFAULT gn_synthese.get_default_nomenclature_value('TYP_DENBR'::character varying),
	id_nomenclature_sensitivity int4 NULL,
	id_nomenclature_observation_status int4 NULL DEFAULT gn_synthese.get_default_nomenclature_value('STATUT_OBS'::character varying),
	id_nomenclature_blurring int4 NULL DEFAULT gn_synthese.get_default_nomenclature_value('DEE_FLOU'::character varying),
	id_nomenclature_source_status int4 NULL DEFAULT gn_synthese.get_default_nomenclature_value('STATUT_SOURCE'::character varying),
	id_nomenclature_info_geo_type int4 NULL DEFAULT gn_synthese.get_default_nomenclature_value('TYP_INF_GEO'::character varying),
	count_min int4 NULL,
	count_max int4 NULL,
	cd_nom int4 NULL,
	nom_cite varchar(1000) NOT NULL,
	meta_v_taxref varchar(50) NULL DEFAULT gn_commons.get_default_parameter('taxref_version'::text, NULL::integer),
	sample_number_proof text NULL,
	digital_proof text NULL,
	non_digital_proof text NULL,
	altitude_min int4 NULL,
	altitude_max int4 NULL,
	the_geom_4326 geometry(geometry, 4326) NULL,
	the_geom_point geometry(point, 4326) NULL,
	the_geom_local geometry(geometry, 2154) NULL,
	date_min timestamp NOT NULL,
	date_max timestamp NOT NULL,
	"validator" varchar(1000) NULL,
	validation_comment text NULL,
	observers varchar(1000) NULL,
	determiner varchar(1000) NULL,
	id_digitiser int4 NULL,
	id_nomenclature_determination_method int4 NULL DEFAULT gn_synthese.get_default_nomenclature_value('METH_DETERMIN'::character varying),
	meta_validation_date timestamp NULL,
	meta_create_date timestamp NULL DEFAULT now(),
	meta_update_date timestamp NULL DEFAULT now(),
	last_action bpchar(1) NULL,
	comment_context text NULL,
	comment_description text NULL,
	reference_biblio varchar(5000) NULL,
	id_area_attachment int4 NULL,
	cd_hab int4 NULL,
	grp_method varchar(255) NULL,
	id_nomenclature_behaviour int4 NULL DEFAULT gn_synthese.get_default_nomenclature_value('OCC_COMPORTEMENT'::character varying),
	depth_min int4 NULL,
	depth_max int4 NULL,
	place_name varchar(500) NULL,
	"precision" int4 NULL,
	additional_data jsonb NULL,
	id_nomenclature_biogeo_status int4 NULL DEFAULT gn_synthese.get_default_nomenclature_value('STAT_BIOGEO'::character varying)
);

-- 18/01/2022 ajout commentaire pour utilisation reference ajout par exemple - non utilisé dans les APIS
ALTER TABLE gn_synthese.synthese_ajout ADD comment_ref varchar(100) NULL;
COMMENT ON COLUMN gn_synthese.synthese_ajout.comment_ref IS 'commentaire pour reference ajout ligne ou autre';


-- Permissions

ALTER TABLE gn_synthese.synthese_ajout OWNER TO geonatadmin;
GRANT ALL ON TABLE gn_synthese.synthese_ajout TO geonatadmin;
GRANT SELECT ON TABLE gn_synthese.synthese_ajout TO geonatuser;

/*
  synthese_maj 
     contient les lignes qui ont été traitées et qui ont été ajoutés à OCCTAX et synthése via API
	    la colonne action contient 'S' pour 1 ajout avec suppression ou 'A' pour un ajout direct depuis synthese_ajout
		
*/

-- DROP TABLE gn_synthese.synthese_maj;

CREATE TABLE gn_synthese.synthese_maj (
    id_ajout int4 PRIMARY KEY,
	id_releve_occtax int8,
	unique_id_sinp_grp uuid,
	action varchar(1),
	date_maj timestamp 
);

-- Permissions

ALTER TABLE gn_synthese.synthese_maj OWNER TO geonatadmin;
GRANT ALL ON TABLE gn_synthese.synthese_maj TO geonatadmin;
GRANT SELECT ON TABLE gn_synthese.synthese_maj TO geonatuser;

/*
Insertion 

insert into gn_synthese.synthese_ajout(
id_synthese,
unique_id_sinp,
unique_id_sinp_grp,
id_source,
id_module,
entity_source_pk_value,
id_dataset,
id_nomenclature_geo_object_nature,
id_nomenclature_grp_typ,
id_nomenclature_obs_technique,
id_nomenclature_bio_status,
id_nomenclature_bio_condition,
id_nomenclature_naturalness,
id_nomenclature_exist_proof,
id_nomenclature_valid_status,
id_nomenclature_diffusion_level,
id_nomenclature_life_stage,
id_nomenclature_sex,
id_nomenclature_obj_count,
id_nomenclature_type_count,
id_nomenclature_sensitivity,
id_nomenclature_observation_status,
id_nomenclature_blurring,
id_nomenclature_source_status,
id_nomenclature_info_geo_type,
count_min,
count_max,
cd_nom,
nom_cite,
meta_v_taxref,
sample_number_proof,
digital_proof,
non_digital_proof,
altitude_min,
altitude_max,
the_geom_4326,
the_geom_point,
the_geom_local,
date_min,
date_max,
validator,
validation_comment,
observers,
determiner,
id_digitiser,
id_nomenclature_determination_method,
meta_validation_date,
meta_create_date,
meta_update_date,
last_action,
comment_context,
comment_description,
reference_biblio,
id_area_attachment,
cd_hab,
grp_method,
id_nomenclature_behaviour,
depth_min,
depth_max,
place_name,
precision,
additional_data,
id_nomenclature_biogeo_status)
select * from gn_synthese.synthese s where s.unique_id_sinp_grp is null and id_synthese =344185;
*/
