---- IMPORT Invertébré DANS LA SYNTHESE -----------
INSERT INTO gn_synthese.t_sources(name_source, desc_source)
VALUES
('INVERTEBRE-ITALIE', 'Données italiennes invertébrés du parc des alpes maritimes ')

INSERT INTO gn_synthese.synthese(
unique_id_sinp, --OK
id_source, --OK
id_dataset, --OK
id_nomenclature_life_stage,--OK
id_nomenclature_observation_status, -- OK
id_nomenclature_source_status, -- OK
id_nomenclature_biogeo_status, --OK
count_min,--OK
count_max, --OK
cd_nom, --OK
cd_hab, --OK
nom_cite, --OK
meta_v_taxref,--OK
altitude_min,--OK
altitude_max, --OK
the_geom_4326, --OK
the_geom_point, --OK
the_geom_local, --OK
date_min, --OK
date_max, --OK
observers, --OK
comment_context, --OK
meta_update_date, --OK
last_action --OK
)
 SELECT
      uuid_generate_v4(),
      6 AS id_source,
      11 AS id_dataset,
      CASE
        WHEN stadio = 'Adulto' THEN (3) -- Ou bien ref_nomencltaure.get_id_nomenclature
        WHEN stadio = 'Indet' THEN (2)
        ELSE (1)
      END AS id_nomenclature_life_stage,
      84 AS id_nomenclature_observation_status, -- Présent
      72 AS id_nomenclature_source_status, --Ne sait pas
      176 AS id_nomenclature_biogeo_status, --Non renseigné
      n_esemplari::integer, --count_min
      n_esemplari::integer, --count_max
      (select cd_nom from taxonomie.taxref t where specie=t.lb_nom and t.cd_nom =t.cd_ref) ::integer AS cd_nom,
      (select id_habitat from taxonomie.taxref t where specie=t.lb_nom and t.cd_nom =t.cd_ref) ::integer AS cd_hab,
      specie AS nom_cite,
      'Taxref V13.0' AS meta_v_taxref,
      quota::integer, -- Altitude min
      quota::integer, -- Altitude max
      ST_Transform(ST_SetSRID(ST_MakePoint("utm_n"::numeric,"utm_e"::numeric),23032),4326) AS the_geom_4326, -- WGS84
      ST_Centroid(ST_Transform(ST_SetSRID(ST_MakePoint("utm_n"::numeric, "utm_e"::numeric),23032),4326)) AS the_geom_point, -- WGS84
      ST_Transform(ST_SetSRID(ST_MakePoint("utm_n"::numeric, "utm_e"::numeric),23032),2154) AS the_geom_local, -- Lambert 93
      "﻿data"::timestamp AS date_min,
      "﻿data"::timestamp AS date_max,
      rilevatore::text, --observateur
      note::text,
      NOW() AS meta_update_date,
      'I' AS last_action -- code de la dernière action effectuée: Valeurs possibiles 'I': insert, 'U': update
 FROM gn_imports.importinvertebre
 ORDER BY "﻿data"
;