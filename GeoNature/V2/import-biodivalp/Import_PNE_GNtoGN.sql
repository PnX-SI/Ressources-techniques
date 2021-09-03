--Insertion des données d'un GeoNature vers la synthèse
INSERT INTO gn_synthese.synthese(
unique_id_sinp,
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
observers,
determiner,
meta_create_date,
meta_update_date,
last_action
)
 SELECT
    uuid_generate_v4(),
    10 AS id_source,
    208 AS id_dataset,
    CASE
        WHEN nature_objet_geo = 'Stationnel' THEN (171)
        WHEN nature_objet_geo = 'Ne sait pas' THEN (170)
        WHEN nature_objet_geo = 'Inventoriel' THEN (169)
        ELSE (null)
      END AS id_nomenclature_geo_object_nature,
    CASE
        WHEN type_regroupement = 'STRAT' THEN (135) 
        WHEN type_regroupement = 'REL' THEN (134)
        WHEN type_regroupement = 'POINT' THEN (133)
        WHEN type_regroupement = 'PASS' THEN (132)
        WHEN type_regroupement = 'OP' THEN (131)
        WHEN type_regroupement = 'OBS' THEN (130)
        WHEN type_regroupement = 'NSP' THEN (129)
        WHEN type_regroupement = 'LIEN' THEN (128)
        WHEN type_regroupement = 'INVSTA' THEN (127)
        WHEN type_regroupement = 'CAMP' THEN (126)
        WHEN type_regroupement = 'AUTR' THEN (125)
        ELSE (null)
      END AS id_nomenclature_grp_typ,
    CASE
        WHEN statut_biologique = 'Inconnu' THEN (29)
        WHEN statut_biologique = 'Non renseigné' THEN (30)
        WHEN statut_biologique = 'Non Déterminé' THEN (31)
        WHEN statut_biologique = 'Reproduction' THEN (32)
        WHEN statut_biologique = 'Hibernation' THEN (33)
        WHEN statut_biologique = 'Estivation' THEN (34)
        WHEN statut_biologique = 'Pas de reproduction' THEN (35)
        WHEN statut_biologique = 'Végétatif' THEN (36)
        ELSE (null)
      END AS id_nomenclature_bio_status,
    CASE
        WHEN naturalite = 'Subspontané' THEN (161)
        WHEN naturalite = 'Féral' THEN (160)
        WHEN naturalite = 'Planté' THEN (159)
        WHEN naturalite = 'Cultivé/élevé' THEN (158)
        WHEN naturalite = 'Sauvage' THEN (157)
        WHEN naturalite = 'Inconnu' THEN (156)
        ELSE (null)
      END AS id_nomenclature_naturalness,
    CASE
        WHEN sexe = 'Non renseigné' THEN (168)
        WHEN sexe = 'Mixte' THEN (167)
        WHEN sexe = 'Hermaphrodite' THEN (166)
        WHEN sexe = 'Mâle' THEN (165)
        WHEN sexe = 'Femelle' THEN (164)
        WHEN sexe = 'Indéterminé' THEN (163)
        WHEN sexe = 'Inconnu' THEN (162)
        ELSE (null)
      END AS id_nomenclature_sex,
    CASE
        WHEN statut_observation = 'Ne Sait Pas' THEN (85)
        WHEN statut_observation = 'Présent' THEN (84)
        WHEN statut_observation = 'Non observé' THEN (83)
        ELSE (null)
      END AS id_nomenclature_observation_status,
    CASE
        WHEN statut_source = 'Terrain' THEN (73)
        WHEN statut_source = 'Ne Sait Pas' THEN (72)
        WHEN statut_source = 'Littérature' THEN (71)
        WHEN statut_source = 'Collection' THEN (70)
        ELSE (null)
      END AS id_nomenclature_source_status,
    CASE
        WHEN type_info_geo = 'Rattachement' THEN (124)
        WHEN type_info_geo = 'Géoréférencement' THEN (123)
        ELSE (null)
      END AS id_nomenclature_info_geo_type,
    reference_biblio,
    nombre_min::integer as nombre_min,
    nombre_max::integer as nombre_max,
    cd_nom::integer,
    nom_cite,
    preuve_numerique,
    altitude_min::integer as altitude_min,
    altitude_max::integer as altitude_max,
    nom_lieu,
    case
    		when geom<>'\N' then (ST_SetSRID(wkt_4326,4326))
    		else (null)
    	end as the_geom_4326, ---WGS84
    case
    		when geom <> '\N' then(ST_SetSRID(ST_MakePoint("x_centroid_4326"::numeric, "y_centroid_4326"::numeric),4326))
    		else(null)
    	end as the_geom_point,--- WGS84
    case
    		when geom <> '\N' then (st_transform(st_geomfromtext(wkt_4326,4326),2154))
    		else (null)
    	end AS the_geom_local, ---- Lambert 93
    precision::integer as precision,
    date_debut::timestamp,
    date_fin::timestamp,
    validateur,
    observateurs,
    determinateur,
    date_creation::timestamp,
    NOW() AS meta_update_date,
    'I' AS last_action -- code de la dernière action effectuée: Valeurs possibiles 'I': insert, 'U': update
FROM gn_exports.v_synthese_sinp_pne 
ORDER BY date_debut
;
