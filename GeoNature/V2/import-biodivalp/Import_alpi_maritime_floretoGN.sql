---- IMPORT FLORE DANS LA SYNTHESE -----------
INSERT INTO gn_synthese.t_sources(name_source, desc_source)
VALUES
('FLORE-ITALIE', 'Données italiennes de flore du parc des alpes maritimes ')


INSERT INTO gn_synthese.synthese(
unique_id_sinp,
id_source,
id_dataset,
id_nomenclature_observation_status,
id_nomenclature_source_status,
id_nomenclature_biogeo_status,
count_min,
count_max,
cd_nom,
cd_hab,
nom_cite,
meta_v_taxref,--OK
altitude_min,--OK
altitude_max, --OK
the_geom_4326, --OK
the_geom_point, --OK
the_geom_local, --OK
precision, --OK
date_min, --OK
date_max, --OK
validator, --OK
observers,
comment_description, --OK
meta_update_date, --OK
last_action --OK
)
 SELECT
      uuid_generate_v4(),
      5 AS id_source,
      10 AS id_dataset,
      84 AS id_nomenclature_observation_status, -- Présent
      72 AS id_nomenclature_source_status, --Ne sait pas
      176 AS id_nomenclature_biogeo_status, --Non renseigné
      1 AS numero_individui, --count_min ??
      1 AS numero_individui, --count_max
      79319 AS cd_nom,
      3 AS cd_hab,
      "﻿originale" AS nom_cite,
      'Taxref V13.0' AS meta_v_taxref,
      quota_min::integer, -- Altitude min
      quota_max::integer, -- Altitude max
      ST_Transform(ST_SetSRID(ST_MakePoint("utmx"::numeric,"utmy"::numeric),23032),4326) AS the_geom_4326, -- WGS84
      ST_Centroid(ST_Transform(ST_SetSRID(ST_MakePoint("utmx"::numeric, "utmy"::numeric),23032),4326)) AS the_geom_point, -- WGS84
      ST_Transform(ST_SetSRID(ST_MakePoint("utmx"::numeric, "utmy"::numeric),23032),2154) AS the_geom_local, -- Lambert 93
      imprecisio::integer AS precision,
      case 
      		when data_gg=0 or data_mm=0 then(null)
      		when data_gg>=10 then (CONCAT(data_anno,'-0',data_mm,'-',data_gg)::timestamp)
      		else (CONCAT(data_anno,'-0',data_mm,'-0',data_gg)::timestamp)
      	end AS date_min,
      case 
      		when data_gg=0 or data_mm=0 then(null)
      		when data_gg>=10 then (CONCAT(data_anno,'-0',data_mm,'-',data_gg)::timestamp)
      		else (CONCAT(data_anno,'-0',data_mm,'-0',data_gg)::timestamp)
      	end AS date_max, 
      validator,
      rilevatore::text, --observateur
      notetaxa::text,
      NOW() AS meta_update_date,
      'I' AS last_action -- code de la dernière action effectuée: Valeurs possibiles 'I': insert, 'U': update
 FROM gn_imports.importflore
 WHERE data_gg <> 0 or data_mm <> 0
 ORDER BY CONCAT(data_anno,'-0',data_mm,'-',data_gg)
;