-- Création d'une vue permettant d'exporter les randonnées mises en forme et conforme à la V0 du schéma de randonnées, à partir de la vue public.v_treks existante dans la BDD Geotrek.
-- Filtre pour ne prendre que les randos publiées, de source PNE et sans les étapes des itinérances
-- Les champs selectionnés sont à adapter en fonction de ce que vous voulez publier
-- Cette vue peut être exportée sous format GeoJSON afin d'être publiée sur une plateforme opendata

CREATE VIEW public.v_rando_opendata AS
WITH theme AS (
    SELECT string_agg("label", ', ') AS themes, t.trek_id 
    FROM common_theme c
    JOIN trekking_trek_themes t
    ON t.theme_id = c.id
    GROUP BY t.trek_id
), communes AS (
	SELECT t.topo_object_id AS tid, string_agg(z.name, ', ') AS communes 
	FROM public.zoning_city z, v_treks t
	WHERE ST_intersects(t.geom, z.geom)
	GROUP BY t.topo_object_id
), itinerance AS (
	SELECT 
	child_id, ARRAY_AGG (parent_id) AS itinerance
	FROM trekking_orderedtrekchild
	GROUP BY child_id
), media AS (
	SELECT 
        ca.object_id , 
        array_agg( 
            json_build_object(
                'url' , COALESCE('https://geotrek-admin.ecrins-parcnational.fr/media/' || NULLIF(attachment_file,''),attachment_link),
                'auteur', auteur ,
                'titre', titre,
                'legende', legende
            )
        ) AS medias
    FROM common_attachment ca 
    JOIN django_content_type dct ON dct.id = ca.content_type_id AND model = 'trek'
    JOIN common_filetype cf ON cf.id = ca.filetype_id AND TYPE='Photographie'
    GROUP BY object_id
	), accessibilite AS (
SELECT 
	tacc.trek_id, string_agg (acc.name, ', ') AS accessibilite
	FROM trekking_accessibility acc
	JOIN trekking_trek_accessibilities tacc on tacc.accessibility_id = acc.id
	GROUP BY tacc.trek_id
), balisage AS (
SELECT 
	tnet.trek_id, string_agg(net.network, ', ') AS balisage
	FROM trekking_treknetwork net
	JOIN trekking_trek_networks tnet on tnet.treknetwork_id = net.id
	GROUP BY tnet.trek_id
)

	
SELECT
	t.topo_object_id AS id_source,
	ats.name AS source,
	t.name AS nom,
	tp.name AS pratique,
	tr.route AS type,
	c.communes,
	t.departure AS depart,
	t.arrival AS arrivee,
	t.duration AS duree,
	bal.balisage,
	e.length AS longueur,
	td.difficulty AS difficulte,
	e.max_elevation AS altitude_max,
	e.min_elevation AS altitude_min,
	e.ascent AS denivele_positif,
	e.descent AS denivele_negatif,
	t.description_teaser AS description_courte,
	t.description AS description,
	th.themes, 
	t.advice AS recommandation,
	acs.accessibilite,
	t.access AS acces_routier,
	t.public_transport AS transport,
	e.geom AS geometrie,
	t.advised_parking AS parking,
	t.parking_location AS geometrie_parking,
	e.date_insert AS date_creation,
	e.date_update AS date_modification
	--m.medias


	FROM v_treks t

		LEFT JOIN authent_structure ats ON ats.id = t.structure_id
		LEFT JOIN trekking_practice tp ON tp.id = t.practice_id
		LEFT JOIN trekking_route tr ON tr.id = t.route_id
		LEFT JOIN core_topology e ON e.id = t.id
		LEFT JOIN trekking_difficultylevel td ON  td.id = t.difficulty_id
		LEFT JOIN theme th ON th.trek_id = t.topo_object_id 
		--LEFT JOIN media m ON m.object_id = t.topo_object_id
		LEFT JOIN communes c ON c.tid = t.topo_object_id
		LEFT JOIN accessibilite acs ON acs.trek_id = t.topo_object_id
		LEFT JOIN balisage bal ON bal.trek_id = t.topo_object_id

	WHERE t.published = true AND t.structure_id = 1 AND t.route_id <> 5 AND e.deleted = false;

  
-- Création d'une vue permettant d'exporter les POI 
-- Filtre pour ne prendre que les POI publiés et rattachées aux randonnées ci-dessus
-- Les champs selectionnés sont à adapter en fonction de que vous voulez publier


CREATE VIEW public.v_poi_opendata AS 
WITH trek AS (
SELECT *
    FROM core_pathaggregation
    WHERE topo_object_id IN (
        SELECT t.id 
        FROM core_topology t
        JOIN v_rando_opendata i ON i.id_source = t.id
        --WHERE kind = 'TREK' AND deleted = false AND i.published = true
    )
), poi AS (
SELECT *
    FROM core_pathaggregation
    WHERE topo_object_id IN (
        SELECT t.id 
        FROM core_topology t
        JOIN v_pois i ON i.id = t.id
        WHERE kind = 'POI' AND deleted = false AND i.published = true
    )
)

SELECT DISTINCT
p.geom,
p.id AS id_poi,
p.name AS nom,
p.description,
pt.label AS type,
array_agg(t.topo_object_id) AS randonnees,
p.publication_date AS date_publication,
ct.date_insert AS date_creation,
ct.date_update AS date_modification,
ats.name AS source

FROM trek t
JOIN poi ON poi.path_id = t.path_id
    AND (
     (t.start_position <= t.end_position AND poi.start_position between t.start_position AND t.end_position) 
     OR 
     (t.start_position > t.end_position AND poi.start_position between t.end_position  AND t.start_position) 
    )
JOIN v_pois p ON p.id = poi.topo_object_id
JOIN trekking_poitype pt ON pt.id = p.type_id
JOIN core_topology ct ON ct.id = p.id
JOIN authent_structure ats ON ats.id = p.structure_id
GROUP BY
p.geom,
p.id,
p.name,
p.description,
pt.label,
p.publication_date,
ct.date_insert,
ct.date_update,
ats.name;


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

