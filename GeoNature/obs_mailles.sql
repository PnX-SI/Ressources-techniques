--

-- Création d'une VM avec toutes les observations d'une organisme

CREATE MATERIALIZED VIEW synthese.vm_observations_pne AS 
 SELECT * FROM synthese.syntheseff s
  WHERE s.id_organisme = 2

-- Création d'une VM intersectant les mailles 5km avec les observations pour compter le nombre d'observations par maille
-- Je ne sais pas encore pourquoi mais QGIS ne veut pas l'ouvrir, indiquant que la couche est invalide

CREATE MATERIALIZED VIEW synthese.vm_observations_pne_mailles_5km AS
  SELECT count(obs.id_synthese),
      m.area_name,
      m.geom
     FROM synthese.vm_observations_pne obs
  JOIN (SELECT * FROM ref_geo.l_areas WHERE id_type = 203) m ON st_intersects(obs.the_geom_point, st_transform(m.geom, 3857))
  GROUP BY m.area_name, m.area_code, m.geom
  
 -- Version Amandine de cette même intersection mais avec des calculs en plus
 
CREATE MATERIALIZED VIEW synthese.vm_observations_pne_mailles_5km AS
  SELECT 
    g.area_name, 
    g.area_code, 
    (ST_TRANSFORM(ST_SETSRID(g.geom,2154),3857)) as geom_maille_3857, 
    count(s.id_synthese) as nb_obs, 
    count(DISTINCT t.cd_ref) as nb_tax,
    count(DISTINCT t.cd_ref) FILTER (WHERE t.group2_inpn = 'Amphibiens') as nb_amphibiens
  FROM synthese.vm_observations_pne s
  JOIN (SELECT * FROM ref_geo.l_areas WHERE id_type = 203) g
    ON st_intersects(ST_TRANSFORM(ST_SETSRID(g.geom,2154),3857), ST_SETSRID(s.the_geom_point,3857))
  JOIN taxonomie.taxref t 
    ON t.cd_nom = s.cd_nom
  GROUP BY g.area_name, g.area_code, g.geom;
