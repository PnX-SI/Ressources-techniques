-- Requête pour supprimer les communes, les mailles et tous objets geo hors territoire
-- Gil Deluermoz (PNE) / 12-11-2019
-----------------------------------
-- Identification des communes hors territoire et proximité immédiate qui ont des observations
-- Attention : adapter la sous requête st_union qui calcule le territoire
SELECT a.area_name, a.area_code FROM (
  SELECT DISTINCT id_area
  FROM gn_synthese.cor_area_taxon
  WHERE id_area IN (
    SELECT id_area FROM ref_geo.l_areas WHERE NOT st_intersects(
      (SELECT st_buffer(ST_union(geom),1000)
      FROM ref_geo.l_areas a
      JOIN ref_geo.li_municipalities lm ON lm.id_area = a.id_area AND lm.insee_dep IN('05', '38')),geom)
  AND id_type = 25
)
)b
JOIN ref_geo.l_areas a ON a.id_area = b.id_area
;

-- Désactivation des triggers
ALTER TABLE ref_geo.l_areas DISABLE TRIGGER tri_meta_dates_change_l_areas;
ALTER TABLE ref_geo.li_municipalities DISABLE TRIGGER tri_meta_dates_change_li_municipalities;

-- Suppression des intersections faites dans les différents schémas
-- Attention : adapter la sous-requête st_union qui calcule le territoire
DELETE FROM gn_synthese.cor_area_synthese
WHERE id_area IN (
  SELECT id_area FROM ref_geo.l_areas WHERE NOT st_intersects(
    (SELECT st_buffer(ST_union(geom),1000)
    FROM ref_geo.l_areas a
    JOIN ref_geo.li_municipalities lm ON lm.id_area = a.id_area AND lm.insee_dep IN('05', '38')),geom)
  --AND id_type = 25
);

DELETE FROM gn_synthese.cor_area_taxon
WHERE id_area IN (
  SELECT id_area FROM ref_geo.l_areas WHERE NOT st_intersects(
    (SELECT st_buffer(ST_union(geom),1000)
    FROM ref_geo.l_areas a
    JOIN ref_geo.li_municipalities lm ON lm.id_area = a.id_area AND lm.insee_dep IN('05', '38')),geom)
  --AND id_type = 25
);

DELETE FROM ref_geo.li_municipalities
WHERE id_area IN (
  SELECT id_area FROM ref_geo.l_areas WHERE NOT st_intersects(
    (SELECT st_buffer(ST_union(geom),1000)
    FROM ref_geo.l_areas a
    JOIN ref_geo.li_municipalities lm ON lm.id_area = a.id_area AND lm.insee_dep IN('05', '38')),geom)
  --AND id_type = 25
);

DELETE FROM ref_geo.li_grids
WHERE id_area IN (
  SELECT id_area FROM ref_geo.l_areas WHERE NOT st_intersects(
    (SELECT st_buffer(ST_union(geom),1000)
    FROM ref_geo.l_areas a
    JOIN ref_geo.li_municipalities lm ON lm.id_area = a.id_area AND lm.insee_dep IN('05', '38')),geom)
  --AND id_type = 25
);

DELETE FROM gn_monitoring.cor_site_area
WHERE id_area IN (
  SELECT id_area FROM ref_geo.l_areas WHERE NOT st_intersects(
    (SELECT st_buffer(ST_union(geom),1000)
    FROM ref_geo.l_areas a
    JOIN ref_geo.li_municipalities lm ON lm.id_area = a.id_area AND lm.insee_dep IN('05', '38')),geom)
  --AND id_type = 25
);

DELETE FROM gn_sensitivity.cor_sensitivity_area
WHERE id_area IN (
  SELECT id_area FROM ref_geo.l_areas WHERE NOT st_intersects(
    (SELECT st_buffer(ST_union(geom),1000)
    FROM ref_geo.l_areas a
    JOIN ref_geo.li_municipalities lm ON lm.id_area = a.id_area AND lm.insee_dep IN('05', '38')),geom)
  --AND id_type = 25
);

-- Suppression des FK (accélération des performances de suppression dans l_areas)
-- Attention : adapter la sous-requête st_union qui calcule le territoire
ALTER TABLE ref_geo.li_municipalities DROP CONSTRAINT fk_li_municipalities_id_area;
ALTER TABLE ref_geo.li_grids DROP CONSTRAINT fk_li_grids_id_area;
ALTER TABLE gn_synthese.cor_area_synthese DROP CONSTRAINT fk_cor_area_synthese_id_area;
ALTER TABLE gn_synthese.cor_area_taxon DROP CONSTRAINT fk_cor_area_taxon_id_area;
ALTER TABLE gn_sensitivity.cor_sensitivity_area DROP CONSTRAINT fk_cor_sensitivity_area_id_area_fkey;
ALTER TABLE gn_monitoring.cor_site_area DROP CONSTRAINT fk_cor_site_area_id_area;

--Suppression des areas hors territoire
DELETE FROM ref_geo.l_areas
WHERE id_area IN (
  SELECT id_area FROM ref_geo.l_areas WHERE NOT st_intersects(
    (SELECT st_buffer(ST_union(geom),1000)
    FROM ref_geo.l_areas a
    JOIN ref_geo.li_municipalities lm ON lm.id_area = a.id_area AND lm.insee_dep IN('05', '38')),geom)
  --AND id_type = 25
);

-- Réactivation des triggers et des FK
ALTER TABLE ref_geo.li_municipalities ADD CONSTRAINT fk_li_municipalities_id_area FOREIGN KEY (id_area) REFERENCES ref_geo.l_areas(id_area) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE ref_geo.li_grids ADD CONSTRAINT fk_li_grids_id_area FOREIGN KEY (id_area) REFERENCES ref_geo.l_areas(id_area) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE gn_synthese.cor_area_synthese ADD CONSTRAINT fk_cor_area_synthese_id_area FOREIGN KEY (id_area) REFERENCES ref_geo.l_areas(id_area) ON UPDATE CASCADE;
ALTER TABLE gn_synthese.cor_area_taxon ADD CONSTRAINT fk_cor_area_taxon_id_area FOREIGN KEY (id_area) REFERENCES ref_geo.l_areas(id_area) ON UPDATE CASCADE;
ALTER TABLE gn_sensitivity.cor_sensitivity_area ADD CONSTRAINT fk_cor_sensitivity_area_id_area_fkey FOREIGN KEY (id_area) REFERENCES ref_geo.l_areas(id_area);
ALTER TABLE gn_monitoring.cor_site_area ADD CONSTRAINT fk_cor_site_area_id_area FOREIGN KEY (id_area) REFERENCES ref_geo.l_areas(id_area);
ALTER TABLE ref_geo.l_areas ENABLE TRIGGER tri_meta_dates_change_l_areas;
ALTER TABLE ref_geo.li_municipalities ENABLE TRIGGER tri_meta_dates_change_li_municipalities;

-- Recalculer les index
-- Attention, ceci peut prendre un peu de temps et bloquer temporairement la base (vacuum full verrouille les tables)
VACUUM ANALYSE ref_geo.l_areas, ref_geo.li_municipalities, ref_geo.li_grids, gn_synthese.cor_area_synthese, gn_synthese.cor_area_taxon, gn_sensitivity.cor_sensitivity_area, gn_monitoring.cor_site_area;
VACUUM FULL ref_geo.l_areas, ref_geo.li_municipalities, ref_geo.li_grids, gn_synthese.cor_area_synthese, gn_synthese.cor_area_taxon, gn_sensitivity.cor_sensitivity_area, gn_monitoring.cor_site_area;
REINDEX TABLE ref_geo.l_areas;
REINDEX TABLE ref_geo.li_municipalities;
REINDEX TABLE ref_geo.li_grids;
REINDEX TABLE gn_synthese.cor_area_synthese;
REINDEX TABLE gn_synthese.cor_area_taxon;
REINDEX TABLE gn_sensitivity.cor_sensitivity_area;
REINDEX TABLE gn_monitoring.cor_site_area;
