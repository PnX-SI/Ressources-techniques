-----MÉTADONNÉES-----
INSERT INTO gn_synthese.t_sources(name_source, desc_source)
VALUES
('CBNMed', 'Données du CBNMed sur le territoire ALCOTRA')


---- IMPORT DANS LA SYNTHESE -----------
--Suppression des observations dont le cd_nom n'est pas dans taxref
delete from gn_imports.importcbnmed 
where i.cd_nom not in (select t.cd_nom from taxonomie.taxref t)

--Insertion des données de la table importcbnmed dans la synthèse
INSERT INTO gn_synthese.synthese(
unique_id_sinp,
unique_id_sinp_grp,
id_source,
id_dataset,
id_nomenclature_geo_object_nature,
id_nomenclature_grp_typ,
id_nomenclature_bio_status,
id_nomenclature_naturalness,
id_nomenclature_sex,
id_nomenclature_observation_status,
id_nomenclature_source_status,
id_nomenclature_info_geo_type,
reference_biblio,
count_min,
count_max,
cd_nom,
nom_cite,
digital_proof,
altitude_min,
altitude_max,
place_name,
the_geom_4326,
the_geom_point,
the_geom_local,
precision,
date_min,
date_max,
validator,
validation_comment,
observers,
determiner,
comment_context,
comment_description,
meta_create_date,
meta_update_date,
last_action
)
 SELECT
    "﻿unique_id_sinp"::uuid,
    unique_id_sinp_grp::uuid,
    8 AS id_source,
    187 AS id_dataset,
    CASE
        WHEN code_nomenclature_geo_object_nature = 'St' THEN (171)
        WHEN code_nomenclature_geo_object_nature = 'NSP' THEN (170)
        WHEN code_nomenclature_geo_object_nature = 'In' THEN (169)
        ELSE (null)
      END AS id_nomenclature_geo_object_nature,
    CASE
        WHEN code_nomenclature_grp_typ = 'STRAT' THEN (135) 
        WHEN code_nomenclature_grp_typ = 'REL' THEN (134)
        WHEN code_nomenclature_grp_typ = 'POINT' THEN (133)
        WHEN code_nomenclature_grp_typ = 'PASS' THEN (132)
        WHEN code_nomenclature_grp_typ = 'OP' THEN (131)
        WHEN code_nomenclature_grp_typ = 'OBS' THEN (130)
        WHEN code_nomenclature_grp_typ = 'NSP' THEN (129)
        WHEN code_nomenclature_grp_typ = 'LIEN' THEN (128)
        WHEN code_nomenclature_grp_typ = 'INVSTA' THEN (127)
        WHEN code_nomenclature_grp_typ = 'CAMP' THEN (126)
        WHEN code_nomenclature_grp_typ = 'AUTR' THEN (125)
        ELSE (null)
      END AS id_nomenclature_grp_typ,
    CASE
        WHEN code_nomenclature_bio_status = 0 THEN (29)
        WHEN code_nomenclature_bio_status = 1 THEN (30)
        WHEN code_nomenclature_bio_status = 2 THEN (31)
        WHEN code_nomenclature_bio_status = 3 THEN (32)
        WHEN code_nomenclature_bio_status = 4 THEN (33)
        WHEN code_nomenclature_bio_status = 5 THEN (34)
        WHEN code_nomenclature_bio_status = 9 THEN (35)
        WHEN code_nomenclature_bio_status = 13 THEN (36)
        ELSE (null)
      END AS id_nomenclature_bio_status,
    CASE
        WHEN code_nomenclature_naturalness = 5 THEN (161)
        WHEN code_nomenclature_naturalness = 4 THEN (160)
        WHEN code_nomenclature_naturalness = 3 THEN (159)
        WHEN code_nomenclature_naturalness = 2 THEN (158)
        WHEN code_nomenclature_naturalness = 1 THEN (157)
        WHEN code_nomenclature_naturalness = 0 THEN (156)
        ELSE (null)
      END AS id_nomenclature_naturalness,
    CASE
        WHEN code_nomenclature_sex = 6 THEN (168)
        WHEN code_nomenclature_sex = 5 THEN (167)
        WHEN code_nomenclature_sex = 4 THEN (166)
        WHEN code_nomenclature_sex = 3 THEN (165)
        WHEN code_nomenclature_sex = 2 THEN (164)
        WHEN code_nomenclature_sex = 1 THEN (163)
        WHEN code_nomenclature_sex = 0 THEN (162)
        ELSE (null)
      END AS id_nomenclature_sex,
    CASE
        WHEN code_nomenclature_observation_status = 'NSP' THEN (85)
        WHEN code_nomenclature_observation_status = 'Pr' THEN (84)
        WHEN code_nomenclature_observation_status = 'No' THEN (83)
        ELSE (null)
      END AS id_nomenclature_observation_status,
    CASE
        WHEN code_nomenclature_source_status = 'Te' THEN (73)
        WHEN code_nomenclature_source_status = 'NSP' THEN (72)
        WHEN code_nomenclature_source_status = 'Li' THEN (71)
        WHEN code_nomenclature_source_status = 'Co' THEN (70)
        ELSE (null)
      END AS id_nomenclature_source_status,
    CASE
        WHEN code_nomenclature_info_geo_type = 2 THEN (124)
        WHEN code_nomenclature_info_geo_type = 1 THEN (123)
        ELSE (null)
      END AS id_nomenclature_info_geo_type,
    reference_biblio,
    case 
    		when count_min='\N' or count_min='NA' then(null)
    		else(count_min::integer)
    	end as count_min,
    case 
    		when count_max ='\N' or count_max='NA' then(null)
    		else(count_max::integer)
    	end as count_max,
    cd_nom::integer,
    nom_cite,
    digital_proof,
    case 
    		when altitude_min='\N' or altitude_min='NA' then(null)
    		else(altitude_min::integer)
    	end as altitude_min,
    case 
    		when altitude_max='\N' or altitude_max='NA' then(null)
    		else(altitude_max::integer)
    	end as altitude_max,
    place_name,
    case
    		when geom<>'\N' then (ST_Transform(ST_GeomFromText(substring(geom,11,length(geom)),2154),4326))
    		else (null)
    	end as the_geom_4326, 
    case
    		when geom <> '\N' then(ST_Centroid(ST_Transform(ST_GeomFromText(substring(geom,11,length(geom)),2154),4326)))
    		else(null)
    	end as the_geom_point,
    case
    		when geom <> '\N' then (ST_GeomFromText(substring(geom,11,length(geom)),2154))
    		else (null)
    	end AS the_geom_local,
    case 
    		when precision='NA' then (null)
    		else (precision::integer)
    	end as precision,
    date_min::timestamp,
    date_max::timestamp,
    validator,
    validation_comment,
    observers,
    determiner,
    comment_context,
    comment_description,
    meta_create_date::timestamp,
    NOW() AS meta_update_date,
    'I' AS last_action -- code de la dernière action effectuée: Valeurs possibiles 'I': insert, 'U': update
FROM gn_imports.importcbnmed
ORDER BY date_min
;