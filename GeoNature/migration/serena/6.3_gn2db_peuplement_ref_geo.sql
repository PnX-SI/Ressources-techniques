-- Peuplement de la table ref_geo.l_areas avec l'ensemble des couches importées précédemment dans le schéma transitoire _ref_inpn_geo
	--> on reporte les id_type correspondants depuis la table bib_areas_types
-- Afin de limiter l'espace de stockage mobilisé dans la BDD, on choisi de n'importer que les zonages de la région qui concerne notre territoire. Ici Auvergne-Rhône-Alpes.
	--> Si l'on souhaite importer les zonages sur tout un territoire national (ici france métro.), 
	--  il faut commenter toutes les lignes finissant par le commentaire --> ### FILTRE SPATIAL ### et pas besoin de crée la table temporaire ci-dessous

-- On crée une table temporaire avec le polygone de la région à partir de ceux des communes (déjà intégrés dans ref_geo.l_areas et li_municipalities)
CREATE TABLE _imports_ref_geo.tmp_region_aura AS

(SELECT b.insee_reg::integer, b.nom_reg::text, 
	   (st_dump(st_makevalid(st_union(a.geom)))).geom::geometry(POLYGON,2154) as geom
	FROM ref_geo.l_areas a
	JOIN ref_geo.li_municipalities b ON a.area_code = b.insee_com
	WHERE b.nom_reg LIKE 'AUVERGNE-RHONE-ALPES'
	GROUP BY b.insee_reg, b.nom_reg);
							 
-- On désactive les triggers sur les tables que l'on met à jour :
ALTER TABLE ref_geo.l_areas DISABLE TRIGGER ALL;
ALTER TABLE ref_geo.li_grids DISABLE TRIGGER ALL;
							 
-- Ensuite on peuple l_areas avec les zonages de l'INPN en appliquant un filtre spatial sur la région AURA							 
INSERT INTO ref_geo.l_areas(
	id_type, area_name, area_code, geom, centroid, source, enable, meta_create_date)
(	SELECT
	12::integer as id_type,
	nom::text,
	id_mnhn::text,
	st_force2d(st_multi(t1.geom))::geometry(MULTIPOLYGON,2154) as geom, -- Conversion du type MULTIPOLYGON 4 dimensions (ZM) vers MULTIPOLYGON 2D
	st_centroid(st_makevalid(st_force2d(t1.geom)))::geometry(POINT,2154) as centroid,
	'https://inpn.mnhn.fr/docs/Shape/apb.zip' as source,
	true::boolean as enable,
	now():: timestamp without time zone as meta_create_date
   FROM _imports_ref_geo.cen2013_09 AS t1
   JOIN  _imports_ref_geo.tmp_region_aura t2 ON st_intersects(t1.geom,t2.geom) --> ### FILTRE SPATIAL ###
   ORDER BY id_mnhn
);

INSERT INTO ref_geo.l_areas(
	id_type, area_name, area_code, geom, centroid, source, enable, meta_create_date)
(	SELECT
	28::integer as id_type,
	code_10km::text,
	cd_sig::text,
	t1.geom::geometry(MULTIPOLYGON,2154) as geom,
	st_centroid(st_makevalid(t1.geom))::geometry(POINT,2154) as centroid,
	'https://inpn.mnhn.fr/docs/Shape/L93_1K.zip' as source,
	true::boolean as enable,
	now():: timestamp without time zone as meta_create_date
   FROM _imports_ref_geo.l93_1x1 AS t1
   JOIN  _imports_ref_geo.tmp_region_aura t2 ON st_intersects(t1.geom,t2.geom) --> ### FILTRE SPATIAL ###
   ORDER BY code_10km);
INSERT INTO ref_geo.li_grids(
	id_grid, id_area, cxmin, cxmax, cymin, cymax)
(	SELECT 
	area_code::text,
	id_area::integer,
	st_xmin(geom)::integer,
	st_xmax(geom)::integer,
	st_ymin(geom)::integer,
	st_ymax(geom)::integer
	FROM ref_geo.l_areas
	WHERE source ILIKE '%L93_1K.zip'
);
				
INSERT INTO ref_geo.bib_areas_types(
	type_name, type_code, type_desc)
	VALUES ('Mailles5*5', 'M5', 'Type maille INPN 5*5km');
INSERT INTO ref_geo.l_areas(
	id_type, area_name, area_code, geom, centroid, source, enable, meta_create_date)
(	SELECT
	32::integer as id_type,
	code5km::text,
	cd_sig::text,
	t1.geom::geometry(MULTIPOLYGON,2154) as geom,
	st_centroid(st_makevalid(t1.geom))::geometry(POINT,2154) as centroid,
	'https://inpn.mnhn.fr/docs/Shape/L93_5K.zip' as source,
	true::boolean as enable,
	now():: timestamp without time zone as meta_create_date
   FROM _imports_ref_geo.l93_5k AS t1
   JOIN  _imports_ref_geo.tmp_region_aura t2 ON st_intersects(t1.geom,t2.geom) --> ### FILTRE SPATIAL ###
   ORDER BY code5km);
INSERT INTO ref_geo.li_grids(
	id_grid, id_area, cxmin, cxmax, cymin, cymax)
(	SELECT 
	area_code::text,
	id_area::integer,
	st_xmin(geom)::integer,
	st_xmax(geom)::integer,
	st_ymin(geom)::integer,
	st_ymax(geom)::integer
	FROM ref_geo.l_areas
	WHERE source ILIKE '%L93_5K.zip');


INSERT INTO ref_geo.l_areas(
	id_type, area_name, area_code, geom, centroid, source, enable, meta_create_date)
(	SELECT
	27::integer as id_type,
	code_10km::text,
	cd_sig::text,
	t1.geom::geometry(MULTIPOLYGON,2154) as geom,
	st_centroid(st_makevalid(t1.geom))::geometry(POINT,2154) as centroid,
	'https://inpn.mnhn.fr/docs/Shape/L93_10K.zip' as source,
	true::boolean as enable,
	now():: timestamp without time zone as meta_create_date
   FROM _imports_ref_geo.l93_10x10 AS t1
   JOIN  _imports_ref_geo.tmp_region_aura t2 ON st_intersects(t1.geom,t2.geom) --> ### FILTRE SPATIAL ###
   ORDER BY code_10km);
INSERT INTO ref_geo.li_grids(
	id_grid, id_area, cxmin, cxmax, cymin, cymax)
(	SELECT 
	area_code::text,
	id_area::integer,
	st_xmin(geom)::integer,
	st_xmax(geom)::integer,
	st_ymin(geom)::integer,
	st_ymax(geom)::integer
	FROM ref_geo.l_areas
	WHERE source ILIKE '%L93_10K.zip');

INSERT INTO ref_geo.l_areas(
	id_type, area_name, area_code, geom, centroid, source, enable, meta_create_date)
(	SELECT
	4::integer as id_type,
	nom_site::text,
	id_mnhn::text,
	t1.geom::geometry(MULTIPOLYGON,2154) as geom,
	st_centroid(st_makevalid(t1.geom))::geometry(POINT,2154) as centroid,
	'https://inpn.mnhn.fr/docs/Shape/apb.zip' as source,
	true::boolean as enable,
	now():: timestamp without time zone as meta_create_date
   FROM _imports_ref_geo.n_enp_apb_s_000 AS t1
   JOIN  _imports_ref_geo.tmp_region_aura t2 ON st_intersects(t1.geom,t2.geom) --> ### FILTRE SPATIAL ###
   ORDER BY id_mnhn);

INSERT INTO ref_geo.l_areas(
	id_type, area_name, area_code, geom, centroid, source, enable, meta_create_date)
(	SELECT
	17::integer as id_type,
	nom_site::text,
	id_mnhn::text,
	t1.geom::geometry(MULTIPOLYGON,2154) as geom,
	st_centroid(st_makevalid(t1.geom))::geometry(POINT,2154) as centroid,
	'https://inpn.mnhn.fr/docs/Shape/bios.zip' as source,
	true::boolean as enable,
	now():: timestamp without time zone as meta_create_date
   FROM _imports_ref_geo.n_enp_apb_s_000 AS t1
   JOIN  _imports_ref_geo.tmp_region_aura t2 ON st_intersects(t1.geom,t2.geom) --> ### FILTRE SPATIAL ###
   ORDER BY id_mnhn);

INSERT INTO ref_geo.l_areas(
	id_type, area_name, area_code, geom, centroid, source, enable, meta_create_date)
(	SELECT
	CASE WHEN code_r_enp = 'CPN' THEN 1 ELSE 20 END::integer as id_type,
	nom_site::text,
	id_mnhn::text,
	t1.geom::geometry(MULTIPOLYGON,2154) as geom,
	st_centroid(st_makevalid(t1.geom))::geometry(POINT,2154) as centroid,
	'https://inpn.mnhn.fr/docs/Shape/pn.zip' as source,
	true::boolean as enable,
	now():: timestamp without time zone as meta_create_date
   FROM _imports_ref_geo.n_enp_pn_s_000 AS t1
   JOIN  _imports_ref_geo.tmp_region_aura t2 ON st_intersects(t1.geom,t2.geom) --> ### FILTRE SPATIAL ###
   ORDER BY id_mnhn);

INSERT INTO ref_geo.l_areas(
	id_type, area_name, area_code, geom, centroid, source, enable, meta_create_date)
(	SELECT
	15::integer as id_type,
	nom_site::text,
	id_mnhn::text,
	t1.geom::geometry(MULTIPOLYGON,2154) as geom,
	st_centroid(st_makevalid(t1.geom))::geometry(POINT,2154) as centroid,
	'https://inpn.mnhn.fr/docs/Shape/pnr.zip' as source,
	true::boolean as enable,
	now():: timestamp without time zone as meta_create_date
   FROM _imports_ref_geo.n_enp_pnr_s_000 AS t1
   JOIN  _imports_ref_geo.tmp_region_aura t2 ON st_intersects(t1.geom,t2.geom) --> ### FILTRE SPATIAL ###
   ORDER BY id_mnhn);

INSERT INTO ref_geo.l_areas(
	id_type, area_name, area_code, geom, centroid, source, enable, meta_create_date)
(	SELECT
	19::integer as id_type,
	nom_site::text,
	id_mnhn::text,
	t1.geom::geometry(MULTIPOLYGON,2154) as geom,
	st_centroid(st_makevalid(t1.geom))::geometry(POINT,2154) as centroid,
	'https://inpn.mnhn.fr/docs/Shape/ramsar.zip' as source,
	true::boolean as enable,
	now():: timestamp without time zone as meta_create_date
   FROM _imports_ref_geo.n_enp_ramsar_s_000 AS t1
   JOIN  _imports_ref_geo.tmp_region_aura t2 ON st_intersects(t1.geom,t2.geom) --> ### FILTRE SPATIAL ###
   ORDER BY id_mnhn);

INSERT INTO ref_geo.l_areas(
	id_type, area_name, area_code, geom, centroid, source, enable, meta_create_date)
(	SELECT
	16::integer as id_type,
	nom_site::text,
	id_mnhn::text,
	t1.geom::geometry(MULTIPOLYGON,2154) as geom,
	st_centroid(st_makevalid(t1.geom))::geometry(POINT,2154) as centroid,
	'https://inpn.mnhn.fr/docs/Shape/rb.zip' as source,
	true::boolean as enable,
	now():: timestamp without time zone as meta_create_date
   FROM _imports_ref_geo.n_enp_ramsar_s_000 AS t1
   JOIN  _imports_ref_geo.tmp_region_aura t2 ON st_intersects(t1.geom,t2.geom) --> ### FILTRE SPATIAL ###
   ORDER BY id_mnhn);

INSERT INTO ref_geo.l_areas(
	id_type, area_name, area_code, geom, centroid, source, enable, meta_create_date)
(	SELECT
	5::integer as id_type,
	nom_site::text,
	id_mnhn::text,
	t1.geom::geometry(MULTIPOLYGON,2154) as geom,
	st_centroid(st_makevalid(t1.geom))::geometry(POINT,2154) as centroid,
	'https://inpn.mnhn.fr/docs/Shape/rnn.zip' as source,
	true::boolean as enable,
	now():: timestamp without time zone as meta_create_date
   FROM _imports_ref_geo.n_enp_rnn_s_000 AS t1
   JOIN  _imports_ref_geo.tmp_region_aura t2 ON st_intersects(t1.geom,t2.geom) --> ### FILTRE SPATIAL ###
   ORDER BY id_mnhn);

INSERT INTO ref_geo.l_areas(
	id_type, area_name, area_code, geom, centroid, source, enable, meta_create_date)
(	SELECT
	6::integer as id_type,
	nom_site::text,
	id_mnhn::text,
	t1.geom::geometry(MULTIPOLYGON,2154) as geom,
	st_centroid(st_makevalid(t1.geom))::geometry(POINT,2154) as centroid,
	'https://inpn.mnhn.fr/docs/Shape/rnr.zip' as source,
	true::boolean as enable,
	now():: timestamp without time zone as meta_create_date
   FROM _imports_ref_geo.n_enp_rnr_s_000 AS t1
   JOIN  _imports_ref_geo.tmp_region_aura t2 ON st_intersects(t1.geom,t2.geom) --> ### FILTRE SPATIAL ###
   ORDER BY id_mnhn);

INSERT INTO ref_geo.l_areas(
	id_type, area_name, area_code, geom, centroid, source, enable, meta_create_date)
(	SELECT
	11::integer as id_type,
	nom_site::text,
	id_mnhn::text,
	t1.geom::geometry(MULTIPOLYGON,2154) as geom,
	st_centroid(st_makevalid(t1.geom))::geometry(POINT,2154) as centroid,
	'https://inpn.mnhn.fr/docs/Shape/ripn.zip' as source,
	true::boolean as enable,
	now():: timestamp without time zone as meta_create_date
   FROM _imports_ref_geo.ripn2013 AS t1
   JOIN  _imports_ref_geo.tmp_region_aura t2 ON st_intersects(t1.geom,t2.geom) --> ### FILTRE SPATIAL ###
   ORDER BY id_mnhn);

INSERT INTO ref_geo.l_areas(
	id_type, area_name, area_code, geom, centroid, source, enable, meta_create_date)
(	SELECT
	9::integer as id_type,
	nom::text,
	id_spn::text,
	t1.geom::geometry(MULTIPOLYGON,2154) as geom,
	st_centroid(st_makevalid(t1.geom))::geometry(POINT,2154) as centroid,
	'https://inpn.mnhn.fr/docs/Shape/zico.zip' as source,
	true::boolean as enable,
	now():: timestamp without time zone as meta_create_date
   FROM _imports_ref_geo.zico AS t1
   JOIN  _imports_ref_geo.tmp_region_aura t2 ON st_intersects(t1.geom,t2.geom) --> ### FILTRE SPATIAL ###
   ORDER BY id_spn);

INSERT INTO ref_geo.l_areas(
	id_type, area_name, area_code, geom, centroid, source, enable, meta_create_date)
(	SELECT
	3::integer as id_type,
	nom::text,
	id_mnhn::text,
	t1.geom::geometry(MULTIPOLYGON,2154) as geom,
	st_centroid(st_makevalid(t1.geom))::geometry(POINT,2154) as centroid,
	'https://inpn.mnhn.fr/docs/Shape/znieff1.zip' as source,
	true::boolean as enable,
	now():: timestamp without time zone as meta_create_date
   FROM _imports_ref_geo.znieff1 AS t1
   JOIN  _imports_ref_geo.tmp_region_aura t2 ON st_intersects(t1.geom,t2.geom) --> ### FILTRE SPATIAL ###
   ORDER BY id_mnhn);

INSERT INTO ref_geo.l_areas(
	id_type, area_name, area_code, geom, centroid, source, enable, meta_create_date)
(	SELECT
	2::integer as id_type,
	nom::text,
	id_mnhn::text,
	t1.geom::geometry(MULTIPOLYGON,2154) as geom,
	st_centroid(st_makevalid(t1.geom))::geometry(POINT,2154) as centroid,
	'https://inpn.mnhn.fr/docs/Shape/znieff2.zip' as source,
	true::boolean as enable,
	now():: timestamp without time zone as meta_create_date
   FROM _imports_ref_geo.znieff2 AS t1
   JOIN  _imports_ref_geo.tmp_region_aura t2 ON st_intersects(t1.geom,t2.geom) --> ### FILTRE SPATIAL ###
   ORDER BY id_mnhn);

INSERT INTO ref_geo.l_areas(
	id_type, area_name, area_code, geom, centroid, source, enable, meta_create_date)
(	SELECT
	7::integer as id_type,
	sitename::text,
	sitecode::text,
	t1.geom::geometry(MULTIPOLYGON,2154) as geom,
	st_centroid(st_makevalid(t1.geom))::geometry(POINT,2154) as centroid,
	'https://inpn.mnhn.fr/docs/Shape/zps.zip' as source,
	true::boolean as enable,
	now():: timestamp without time zone as meta_create_date
   FROM _imports_ref_geo.zps1810 AS t1
   JOIN  _imports_ref_geo.tmp_region_aura t2 ON st_intersects(t1.geom,t2.geom) --> ### FILTRE SPATIAL ###
   ORDER BY sitecode);
				
				
-- /!\ Particularité pour la couche sic_1810 (sic_eu) --> Sites classés au titre de la Directive Habitats : périmètres transmis à la CE (ZSC/pSIC/SIC) :
-- Les couches téléchargées sur le site de l'INPN ne contiennent plus de distinction de type entre ZSC/pSIC et SIC
-- On on affecte donc seulement l'id_type correspondant aux SIC (TO DO : voir pour les ZSC ?)
INSERT INTO ref_geo.l_areas(
	id_type, area_name, area_code, geom, centroid, source, enable, meta_create_date)
(	SELECT
	8::integer as id_type,
	sitename::text,
	sitecode::text,
	t1.geom::geometry(MULTIPOLYGON,2154) as geom,
	st_centroid(st_makevalid(t1.geom))::geometry(POINT,2154) as centroid,
	'https://inpn.mnhn.fr/docs/Shape/sic_ue.zip' as source,
	true::boolean as enable,
	now():: timestamp without time zone as meta_create_date
   FROM _imports_ref_geo.sic1810 AS t1
   JOIN  _imports_ref_geo.tmp_region_aura t2 ON st_intersects(t1.geom,t2.geom) --> ### FILTRE SPATIAL ###
   ORDER BY sitecode);

-- On réactive les triggers sur les tables que l'on a mis jour :
ALTER TABLE ref_geo.l_areas ENABLE TRIGGER ALL;
ALTER TABLE ref_geo.li_grids ENABLE TRIGGER ALL;	
				
-- On termine en réindexant la table l_areas puis en supprimant la table temporaire crée en début de script
REINDEX TABLE ref_geo.l_areas ;

DROP TABLE _imports_ref_geo.tmp_region_aura ;
