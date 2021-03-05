delete from ref_geo.l_areas l using ref_geo.bib_areas_types t where t.id_type = l.id_type and t.type_code='PEC';

insert into ref_geo.l_areas (id_type, area_name, area_code, geom, centroid, geojson_4326, "enable")
with geom as(
 select ST_MULTI( ST_TRANSFORM(ST_BUFFER(ST_SETSRID(st_point(5.4607754564, 43.2311510852), 4326), 2), 2154)) as geom --cal
-- select ST_MULTI(ST_TRANSFORM(ST_BUFFER(ST_SETSRID(st_point(6.3894049, 43.0637826), 4326), 1), 2154)) as geom --pc
--select ST_MULTI(ST_TRANSFORM(ST_BUFFER(ST_SETSRID(st_point(-61.5394194522855, 16.1977009479195), 4326), 1), 32620)) as geom --gua
)
select id_type, 'PEC', 'PEC', g.geom, ST_CENTROID(g.geom), st_asgeojson(g.geom), TRUE
from geom g
join ref_geo.bib_areas_types t on t.type_code='PEC';

atlas.refresh_materialized_view_data();

-- calculer la sensibilite
