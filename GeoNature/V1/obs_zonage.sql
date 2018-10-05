-- Créer une vue avec les observations Flore dans un zonage (Réserve intégrale du Lauvitel dans notre cas)
-- On ne prend que les observations dont la surface est inférieure 1 km² pour ne pas remonter les données imprécises

CREATE OR REPLACE VIEW synthese.v_flore_ril AS 
 SELECT s.id_synthese,
    s.cd_nom,
    t.nom_vern,
    t.nom_valide, 
    s.the_geom_local,
    s.dateobs,
    s.observateurs,
    s.id_organisme,
    s.id_lot
   FROM synthese.syntheseff s
     JOIN layers.l_zonesstatut l ON st_intersects(l.the_geom, s.the_geom_local)
     JOIN taxonomie.taxref t ON t.cd_nom = s.cd_nom
  WHERE l.id_zone = 3606 AND t.regne::text = 'Plantae'::text AND ST_area(s.the_geom_local) < 1000000;
  
-- Liste des taxons de Flore dans ce zonage : 

SELECT DISTINCT cd_nom, nom_vern, nom_valide, count(id_synthese) AS nb_obs
FROM synthese.v_flore_ril
GROUP BY cd_nom, nom_vern, nom_valide
ORDER BY nom_valide;
