


----------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------- BD PHOTO --------------------------------------------
----------------------------------------------------------------------------------------------------------------------------
DROP TABLE if exists gn_imports.t_releves_basephotoseb ;
DROP TABLE if exists gn_imports.t_occurrences_basephotoseb ;
DROP TABLE if exists gn_imports.cor_counting_basephotoseb ;
DROP TABLE if exists gn_imports.t_medias_basephotoseb;
--------------------------------------- 1/ import des releves
CREATE TABLE gn_imports.t_releves_basephotoseb (num integer,
    id_releve_occtax bigint NOT NULL,
    id_dataset integer NOT NULL,
    id_digitiser integer,
    observers_txt character varying(500) COLLATE pg_catalog."default",
    id_nomenclature_tech_collect_campanule integer,
    id_nomenclature_grp_typ integer NOT NULL,
    grp_method character varying(255) ,
    date_min character varying(16) NOT NULL DEFAULT now(),
    date_max character varying(16) NOT NULL DEFAULT now(),
    hour_min character varying(10),
    hour_max character varying(10),
    place_name character varying(500) COLLATE pg_catalog."default",
    meta_device_entry character varying(20) COLLATE pg_catalog."default",
    comment text COLLATE pg_catalog."default",
    id_nomenclature_geo_object_nature integer,
    "precision" integer);
COPY gn_imports.t_releves_basephotoseb (num, id_releve_occtax,id_dataset, id_digitiser, observers_txt , id_nomenclature_tech_collect_campanule,
											id_nomenclature_grp_typ , grp_method , date_min, date_max, hour_min , hour_max , place_name , 
											meta_device_entry , "comment" , id_nomenclature_geo_object_nature ,"precision" )
	FROM '/tmp/basephotoseb_1_releves.csv' WITH csv HEADER DELIMITER ';';
	
	
--------------------------------------- 2/ import des occurrences
CREATE TABLE gn_imports.t_occurrences_basephotoseb (num integer,
    id_occurrence_occtax bigint NOT NULL,
    id_releve_occtax bigint NOT NULL,
    id_nomenclature_obs_technique integer NOT NULL,
    id_nomenclature_bio_condition integer NOT NULL,
    id_nomenclature_bio_status integer,
    id_nomenclature_naturalness integer,
    id_nomenclature_exist_proof integer,
    id_nomenclature_diffusion_level integer,
    id_nomenclature_observation_status integer,
    id_nomenclature_blurring integer,
    id_nomenclature_source_status integer,
    id_nomenclature_behaviour integer,
    determiner character varying(255) ,
    id_nomenclature_determination_method integer,
    cd_nom integer,
    nom_cite character varying(255) NOT NULL,
 	nom_tmp_pour_cd_nom character varying(255) NOT NULL,
    meta_v_taxref character varying(50) ,
	sample_number_proof character varying(50) ,
    digital_proof text);
COPY gn_imports.t_occurrences_basephotoseb (num , id_occurrence_occtax ,id_releve_occtax , id_nomenclature_obs_technique ,id_nomenclature_bio_condition, 
											id_nomenclature_bio_status , id_nomenclature_naturalness , id_nomenclature_exist_proof , 
											id_nomenclature_diffusion_level, id_nomenclature_observation_status , id_nomenclature_blurring,
											id_nomenclature_source_status, id_nomenclature_behaviour ,   determiner ,   id_nomenclature_determination_method ,
											cd_nom , nom_cite , nom_tmp_pour_cd_nom , meta_v_taxref  , sample_number_proof  ,digital_proof )
		FROM '/tmp/basephotoseb_2_occurrences.csv' WITH csv HEADER DELIMITER ';';
		
		
--------------------------------------- 2/ import des décomptes
CREATE TABLE gn_imports.cor_counting_basephotoseb ( num integer,
    id_counting_occtax bigint ,
    id_occurrence_occtax bigint,
    id_nomenclature_life_stage integer,
    id_nomenclature_sex integer,
    id_nomenclature_obj_count integer,
    id_nomenclature_type_count integer,
    count_min integer,
    count_max integer);
	
COPY gn_imports.cor_counting_basephotoseb (num ,id_counting_occtax,id_occurrence_occtax , id_nomenclature_life_stage ,
										   id_nomenclature_sex , id_nomenclature_obj_count , id_nomenclature_type_count ,
										   count_min ,count_max)
		FROM '/tmp/basephotoseb_3_counting.csv' WITH csv HEADER DELIMITER ';';
		
		
		
		
---------------4- Les médias
CREATE TABLE gn_imports.t_medias_basephotoseb
(id_counting integer,
    id_nomenclature_media_type integer NOT NULL,
    id_table_location integer NOT NULL,
    title_fr character varying(255) COLLATE pg_catalog."default",
    media_path character varying(255) COLLATE pg_catalog."default",
    author character varying(100) COLLATE pg_catalog."default",
    description_fr text COLLATE pg_catalog."default");
COPY gn_imports.t_medias_basephotoseb (id_counting, id_nomenclature_media_type, id_table_location, title_fr, 
									   media_path, author, description_fr)
	FROM '/tmp/basephotoseb_4_media.csv' WITH csv HEADER DELIMITER ';';
	
	
----------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------- CardObs ---------------------------------------------
----------------------------------------------------------------------------------------------------------------------------
DROP TABLE if exists gn_imports.t_releves_cardobsseb;
DROP TABLE if exists gn_imports.t_occurrences_cardobsseb;
DROP TABLE if exists gn_imports.cor_counting_cardobsseb;

--------------------------------------- 1/ import des releves
CREATE TABLE gn_imports.t_releves_cardobsseb (num integer,
	cd_station integer NOT NULL,								  
    id_releve_occtax bigint NOT NULL,
    id_dataset integer NOT NULL,
    id_digitiser integer,
    observers_txt character varying(500) COLLATE pg_catalog."default",
    id_nomenclature_tech_collect_campanule integer,
    id_nomenclature_grp_typ integer NOT NULL,
    grp_method character varying(255) ,
    date_min character varying(30) NOT NULL DEFAULT now(),
    date_max character varying(30) NOT NULL DEFAULT now(),
    hour_min character varying(10),
    hour_max character varying(10),
    place_name character varying(500) COLLATE pg_catalog."default",
    meta_device_entry character varying(20) COLLATE pg_catalog."default",
    "comment" text COLLATE pg_catalog."default",
    id_nomenclature_geo_object_nature integer,
    "precision" integer,
	latitude character varying(30), 
	longitude character varying(30),
	regne character varying(30));
	
COPY gn_imports.t_releves_cardobsseb (num, cd_station, id_releve_occtax, id_dataset, id_digitiser, observers_txt , id_nomenclature_tech_collect_campanule,
											id_nomenclature_grp_typ , grp_method , date_min, date_max, hour_min , hour_max , place_name , 
											meta_device_entry , "comment" , id_nomenclature_geo_object_nature ,"precision", latitude, longitude, regne )
	FROM '/tmp/cardobsseb_1_releves.csv' WITH csv HEADER DELIMITER ';';


--------------------------------------- 2/ import des occurrences
CREATE TABLE gn_imports.t_occurrences_cardobsseb (num integer,
    id_occurrence_occtax bigint NOT NULL,
    id_releve_occtax bigint NOT NULL,
    id_nomenclature_obs_technique integer NOT NULL,
    id_nomenclature_bio_condition integer NOT NULL,
    id_nomenclature_bio_status integer,
    id_nomenclature_naturalness integer,
    id_nomenclature_exist_proof integer,
    id_nomenclature_diffusion_level integer,
    id_nomenclature_observation_status integer,
    id_nomenclature_blurring integer,
    id_nomenclature_source_status integer,
    id_nomenclature_behaviour integer,
    determiner character varying(255) ,
    id_nomenclature_determination_method integer,
    cd_nom integer,
    nom_cite character varying(255) NOT NULL,
 	nom_tmp_pour_cd_nom character varying(255) NOT NULL,
    meta_v_taxref character varying(50) ,
	sample_number_proof character varying(50) ,
    digital_proof text,
	"comment"  character varying(250));
COPY gn_imports.t_occurrences_cardobsseb (num , id_occurrence_occtax ,id_releve_occtax , id_nomenclature_obs_technique ,id_nomenclature_bio_condition, 
											id_nomenclature_bio_status , id_nomenclature_naturalness , id_nomenclature_exist_proof , 
											id_nomenclature_diffusion_level, id_nomenclature_observation_status , id_nomenclature_blurring,
											id_nomenclature_source_status, id_nomenclature_behaviour ,   determiner ,   id_nomenclature_determination_method ,
											cd_nom , nom_cite , nom_tmp_pour_cd_nom , meta_v_taxref  , sample_number_proof  ,digital_proof, "comment" )
		FROM '/tmp/cardobsseb_2_occurrences.csv' WITH csv HEADER DELIMITER ';';
		
		
--------------------------------------- 3/ import des décomptes
CREATE TABLE gn_imports.cor_counting_cardobsseb ( num integer,
    id_counting_occtax bigint ,
    id_occurrence_occtax bigint,
    id_nomenclature_life_stage integer,
    id_nomenclature_sex integer,
    id_nomenclature_obj_count integer,
    id_nomenclature_type_count integer,
    count_min integer,
    count_max integer);
	
COPY gn_imports.cor_counting_cardobsseb (num ,id_counting_occtax,id_occurrence_occtax , id_nomenclature_life_stage ,
										   id_nomenclature_sex , id_nomenclature_obj_count , id_nomenclature_type_count ,
										   count_min ,count_max)
		FROM '/tmp/cardobsseb_3_counting.csv' WITH csv HEADER DELIMITER ';';
		

----------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------- Données geo pour BD Photo ---------------------------
----------------------------------------------------------------------------------------------------------------------------		
DROP TABLE if exists gn_imports.tmp_localitespoly_seb ;
DROP TABLE if exists gn_imports.tmp_localiteslignes_seb ;
DROP TABLE if exists gn_imports.tmp_localitespoints_seb ;