-- Création d'une vue permettant d'exporter les randonnées mises en forme, à partir de la vue rando.o_v_itineraire existante
-- Filtre pour ne prendre que les randos publiées, de source PNE et sans les itinérances et leurs étapes
-- Les champs selectionnés sont à adapter en fonction de que vous voulez publier

CREATE OR REPLACE VIEW rando.o_v_randos_pne_opendata AS 
 SELECT 
    i.evenement AS id_rando,
    i.geom,
    i.nom_fr,
    i.nom_en,
    i.nom_it,
    i.duree AS duree_heure,
    i.depart_fr,
    i.arrivee_fr,
    i.chapeau_fr,
    i.chapeau_en,
    i.chapeau_it,
    pr.nom_fr AS pratique_fr,
    pr.nom_en AS pratique_en,
    pr.nom_it AS pratique_it,
    pa.parcours_fr,
    pa.parcours_en,
    pa.parcours_it,
    di.difficulte_fr,
    di.difficulte_en,
    di.difficulte_it,
    i.parking_fr,
    i.parking_en,
    i.parking_it,
    st_astext(i.geom_parking) AS wkt_parking,
    i.recommandation_fr,
    i.recommandation_en,
    i.recommandation_it,
    i.transport_fr,
    i.transport_en,
    i.transport_it,
    i.acces_fr,
    i.acces_en,
    i.acces_it,
    i.date_publication,
    date(e.date_insert) AS date_creation,
    date(e.date_update) AS date_modification,
    i.public_fr AS publie_fr,
    i.public_en AS publie_en,
    i.public_it AS publie_it,
    s.name AS source
   FROM o_v_itineraire i
     LEFT JOIN o_r_itineraire_source rs ON rs.trek_id = i.evenement
     LEFT JOIN o_b_source_fiche s ON s.id = rs.recordsource_id
     LEFT JOIN o_b_pratique pr ON pr.id = i.pratique
     LEFT JOIN o_b_parcours pa ON pa.id = i.parcours
     LEFT JOIN o_b_difficulte di ON di.id = i.difficulte
     LEFT JOIN e_t_evenement e ON e.id = i.evenement
  WHERE i.public = true AND rs.recordsource_id = 1 AND i.parcours <> 5 AND i.parcours <> 6;

COMMENT ON VIEW rando.o_v_randos_pne_opendata
  IS 'Vue des randos à la journée publiées du PNE';
  
-- Création d'une vue permettant d'exporter les POI 
-- Filtre pour ne prendre que les POI publiés et rattachées aux randonnées ci-dessus
-- Les champs selectionnés sont à adapter en fonction de que vous voulez publier

CREATE VIEW rando.o_v_poi_pne_opendata AS 
WITH etrek AS (
    SELECT *
    FROM geotrek.e_r_evenement_troncon
    WHERE evenement IN (
        SELECT id 
        FROM geotrek.e_t_evenement et
        JOIN rando.o_t_itineraire i ON i.evenement = et.id
        WHERE kind = 'TREK' AND supprime = false AND i.public = true
    )
), epoi AS (
    SELECT *
    FROM geotrek.e_r_evenement_troncon
    WHERE evenement IN (
        SELECT id 
        FROM geotrek.e_t_evenement et
        JOIN rando.o_t_poi p ON p.evenement = et.id
        WHERE kind = 'POI' AND supprime = false AND p.public = true
    )
)
SELECT DISTINCT 
      p.evenement as id_poi, 
      ev.geom, 
      p.nom_fr,
      p.nom_en,
      p.nom_it, 
      p.description_fr,
      p.description_en, 
      p.description_it,
      bp.nom_fr AS type_fr,
      bp.nom_en AS type_en,
      bp.nom_it AS type_it,
      p.public_fr AS publie_fr,
      p.public_en AS publie_en, 
      p.public_it AS publie_it, 
      array_agg(et.evenement) AS randonnees,
      date_publication,
      date(ev.date_insert) AS date_creation,
      date(ev.date_update) AS date_modification,
      st.name AS source
      
FROM etrek et
JOIN epoi ep ON et.troncon = ep.troncon 
    AND (
     (et.pk_debut <= et.pk_fin AND ep.pk_debut between et.pk_debut AND et.pk_fin) 
     OR 
     (et.pk_debut > et.pk_fin AND ep.pk_debut between et.pk_fin  AND et.pk_debut) 
    )
JOIN rando.o_t_poi p ON p.evenement = ep.evenement
JOIN geotrek.e_t_evenement ev ON ev.id = p.evenement
JOIN rando.o_b_poi bp ON bp.id = p.type
JOIN geotrek.authent_structure st ON st.id = p.structure
WHERE et.evenement IN (SELECT id_rando FROM rando.o_v_randos_pne_opendata) AND p.public = true
GROUP BY 
      p.evenement, 
      ev.geom, 
      p.nom_fr,
      p.nom_en,
      p.nom_it, 
      p.description_fr,
      p.description_en, 
      p.description_it,
      bp.nom_fr,
      bp.nom_en,
      bp.nom_it,
      p.public_fr,
      p.public_en, 
      p.public_it, 
      date_publication,
      ev.date_insert,
      ev.date_update,
      st.name
ORDER BY p.nom_fr;

COMMENT ON VIEW rando.o_v_poi_pne_opendata
  IS 'Vues des POI publiés et associés aux randonnées du PNE';

-----------------------------------------------------------------
-- AUTRE EXEMPLE POUR LES RANDOS et LEURS POIs du Pays des Ecrins
-----------------------------------------------------------------

-- Itineraires du portail PDE, publiés et sans le GTE, ni les étapes des itinérances du PDE

CREATE OR REPLACE VIEW rando.o_v_randos_pde AS 
 SELECT i.evenement AS id_rando,
    i.geom,
    i.nom_fr,
    i.nom_en,
    i.nom_it,
    i.duree AS duree_heure,
    i.depart_fr,
    i.arrivee_fr,
    i.chapeau_fr,
    i.chapeau_en,
    i.chapeau_it,
    pr.nom_fr AS pratique_fr,
    pr.nom_en AS pratique_en,
    pr.nom_it AS pratique_it,
    pa.parcours_fr,
    pa.parcours_en,
    pa.parcours_it,
    di.difficulte_fr,
    di.difficulte_en,
    di.difficulte_it,
    i.parking_fr,
    i.parking_en,
    i.parking_it,
    st_astext(i.geom_parking) AS wkt_parking,
    i.recommandation_fr,
    i.recommandation_en,
    i.recommandation_it,
    i.transport_fr,
    i.transport_en,
    i.transport_it,
    i.acces_fr,
    i.acces_en,
    i.acces_it,
    i.date_publication,
    date(e.date_insert) AS date_creation,
    date(e.date_update) AS date_modification,
    i.public_fr AS publie_fr,
    i.public_en AS publie_en,
    i.public_it AS publie_it,
    s.name AS source,
    po.name AS portail
   FROM o_v_itineraire i
     LEFT JOIN o_r_itineraire_source rs ON rs.trek_id = i.evenement
     LEFT JOIN o_b_source_fiche s ON s.id = rs.recordsource_id
     LEFT JOIN o_r_itineraire_portal rp ON rp.trek_id = i.evenement
     LEFT JOIN o_b_target_portal po ON po.id = rp.targetportal_id
     LEFT JOIN o_b_pratique pr ON pr.id = i.pratique
     LEFT JOIN o_b_parcours pa ON pa.id = i.parcours
     LEFT JOIN o_b_difficulte di ON di.id = i.difficulte
     LEFT JOIN e_t_evenement e ON e.id = i.evenement
  WHERE i.public = true AND rp.targetportal_id = 4 AND i.evenement <> 937571 AND i.evenement <> 939205; 
-- Ne prendre que les publiés, du portail PDE et sans les 2 itinéraires du Tour des Ecrins

-- POI attachés aux itinéraires du PDE

CREATE VIEW rando.o_v_poi_pde AS 
WITH etrek AS (
    SELECT *
    FROM geotrek.e_r_evenement_troncon
    WHERE evenement IN (
        SELECT id 
        FROM geotrek.e_t_evenement et
        JOIN rando.o_t_itineraire i ON i.evenement = et.id
        WHERE kind = 'TREK' AND supprime = false AND i.public = true
    )
), epoi AS (
    SELECT *
    FROM geotrek.e_r_evenement_troncon
    WHERE evenement IN (
        SELECT id 
        FROM geotrek.e_t_evenement et
        JOIN rando.o_t_poi p ON p.evenement = et.id
        WHERE kind = 'POI' AND supprime = false AND p.public = true
    )
)
SELECT DISTINCT 
      p.evenement as id_poi, 
      ev.geom, 
      p.nom_fr,
      p.nom_en,
      p.nom_it, 
      p.description_fr,
      p.description_en, 
      p.description_it,
      bp.nom_fr AS type_fr,
      bp.nom_en AS type_en,
      bp.nom_it AS type_it,
      p.public_fr AS publie_fr,
      p.public_en AS publie_en, 
      p.public_it AS publie_it, 
      array_agg(et.evenement) AS randonnees,
      date_publication,
      date(ev.date_insert) AS date_creation,
      date(ev.date_update) AS date_modification,
      st.name AS source  
FROM etrek et
JOIN epoi ep ON et.troncon = ep.troncon 
    AND (
     (et.pk_debut <= et.pk_fin AND ep.pk_debut between et.pk_debut AND et.pk_fin) 
     OR 
     (et.pk_debut > et.pk_fin AND ep.pk_debut between et.pk_fin  AND et.pk_debut) 
    )
JOIN rando.o_t_poi p ON p.evenement = ep.evenement
JOIN geotrek.e_t_evenement ev ON ev.id = p.evenement
JOIN rando.o_b_poi bp ON bp.id = p.type
JOIN geotrek.authent_structure st ON st.id = p.structure
WHERE et.evenement IN (SELECT id_rando FROM rando.o_v_randos_pde) AND p.public = true
GROUP BY 
      p.evenement, 
      ev.geom, 
      p.nom_fr,
      p.nom_en,
      p.nom_it, 
      p.description_fr,
      p.description_en, 
      p.description_it,
      bp.nom_fr,
      bp.nom_en,
      bp.nom_it,
      p.public_fr,
      p.public_en, 
      p.public_it, 
      date_publication,
      ev.date_insert,
      ev.date_update,
      st.name
ORDER BY p.nom_fr;
