---- CREATION SOURCE ------
INSERT INTO gn_synthese.t_sources(name_source, desc_source)
VALUES
('FAUNE-ITALIE', 'Données italiennes de faune du parc des alpes maritimes ')

---- IMPORT DANS LA SYNTHESE -----------
INSERT INTO gn_synthese.synthese(
unique_id_sinp,
id_source,
id_dataset,
id_nomenclature_valid_status,
id_nomenclature_observation_status, 
id_nomenclature_source_status, 
id_nomenclature_biogeo_status,
count_min,
count_max,
cd_nom,
cd_hab,
nom_cite,
meta_v_taxref,
altitude_min,
altitude_max,
the_geom_4326,
the_geom_point,
the_geom_local,
precision,
date_min,
date_max,
validator,
observers,
meta_validation_date,
meta_create_date,
meta_update_date,
last_action
)
 SELECT
      uuid_generate_v4(),
      3 AS id_source,
      7 AS id_dataset,
      315 AS id_nomenclature_valid_status, --Certain
      84 AS id_nomenclature_observation_status, -- Présent
      72 AS id_nomenclature_source_status, --Ne sait pas
      176 AS id_nomenclature_biogeo_status, --Non renseigné
      numero_individui_esatto::integer, --count_min
      numero_individui_esatto::integer, --count_max
      (select cd_nom from taxonomie.taxref t where  t.nom_complet=nome_scientifico and t.cd_nom =t.cd_ref ::integer) AS cd_nom,
      (select id_habitat from taxonomie.taxref t where  t.nom_complet=nome_scientifico and t.cd_nom =t.cd_ref ::integer) AS cd_hab,
      descrizione_specie AS nom_cite,
      'Taxref V13.0' AS meta_v_taxref,
      quota_da::integer, -- Altitude min
      quota_a::integer, -- Altitude max
      ST_Transform(ST_SetSRID(ST_MakePoint("utm_x"::numeric,"utm_y"::numeric),23032),4326) AS the_geom_4326, -- WGS84
      ST_Centroid(ST_Transform(ST_SetSRID(ST_MakePoint("utm_x"::numeric, "utm_y"::numeric),23032),4326)) AS the_geom_point, -- WGS84
      ST_Transform(ST_SetSRID(ST_MakePoint("utm_x"::numeric, "utm_y"::numeric),23032),2154) AS the_geom_local, -- Lambert 93
      REPLACE(imprecisione,' m','')::integer AS precision, --Pb si km
      CONCAT(data_osservazione,' ',ora_osservazione_da)::timestamp AS date_min,
      CONCAT(data_osservazione,' ',ora_osservazione_da)::timestamp AS date_max,
      validatore,
      altri_osservatori::text, --observateur
      data_validazione::timestamp,
      data_registrazione::timestamp,
      NOW() AS meta_update_date,
      'I' AS last_action -- code de la dernière action effectuée: Valeurs possibiles 'I': insert, 'U': update
 FROM gn_imports.importavesbis
 ORDER BY CONCAT(data_osservazione,' ',ora_osservazione_da)
;