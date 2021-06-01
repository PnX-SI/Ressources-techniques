-- EXPORT des RANDOS et POI depuis une BDD Geotrek
-- Création d'une vue permettant d'exporter les randonnées mises en forme et conforme à la V0 du schéma de randonnées, à partir de la vue public.v_treks existante dans la BDD Geotrek.
-- Filtre pour ne prendre que les randos publiées, de source PNE et sans les étapes des itinérances
-- Les champs selectionnés sont à adapter en fonction de ce que vous voulez publier
-- Cette vue peut être exportée sous format GeoJSON afin d'être publiée sur une plateforme opendata
-- Les médias sont commentés pour ne pas être inclus par défaut, mais c'est fonctionnel en décommentant les lignes concernées
-- et en adaptant la base de leur URL

CREATE VIEW public.v_opendata_treks AS
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
	e.min_elevation AS altitude_min,
	e.max_elevation AS altitude_max,
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
-- TODO : Exclure de la liste des randonnées celles dont des POI sont exlus de la randonnées (trekking_trek_pois_excluded)

CREATE VIEW public.v_opendata_pois AS
WITH topo_trek AS (
SELECT *
    FROM core_pathaggregation
    WHERE topo_object_id IN (
        SELECT t.id 
        FROM core_topology t
        JOIN v_opendata_treks i ON i.id_source = t.id
    )
), topo_poi AS (
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
CAST(array_agg(t.topo_object_id) AS VARCHAR) AS randonnees,
p.publication_date AS date_publication,
ct.date_insert AS date_creation,
ct.date_update AS date_modification,
ats.name AS source

FROM topo_trek t
JOIN topo_poi ON topo_poi.path_id = t.path_id
    AND (
     (t.start_position <= t.end_position AND topo_poi.start_position between t.start_position AND t.end_position) 
     OR 
     (t.start_position > t.end_position AND topo_poi.start_position between t.end_position  AND t.start_position) 
    )
JOIN v_pois p ON p.id = topo_poi.topo_object_id
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
