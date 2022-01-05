----------- CREATION DE TABLES DES TAMPONS DES TRONÇONS reference ET importe
---------- choix d'une distance de 5m par l'expérimentation de plusieurs valeurs
DROP TABLE IF EXISTS tampon_reference;

CREATE TABLE tampon_reference AS
	  SELECT id,
		     ST_Buffer(geom, 5) AS geom,
		     r.geom AS geom_r
	    FROM reference r;

DROP TABLE IF EXISTS tampon_importe;

CREATE TABLE tampon_importe AS
	  SELECT id,
		     ST_Buffer(geom, 5) AS geom,
	  	     i.geom AS geom_i
	    FROM importe i;

---------- CREATION INDEX SPATIAUX SUR LES TAMPONS
---------- accélère les requêtes spatiales
DROP INDEX IF EXISTS tampon_reference_geom_idx;

CREATE INDEX tampon_reference_geom_idx
  		  ON tampon_reference
  	   USING GIST(geom);

CLUSTER tampon_reference
  USING tampon_reference_geom_idx;


DROP INDEX IF EXISTS tampon_importe_geom_idx;

CREATE INDEX tampon_importe_geom_idx
  		  ON tampon_importe
  	   USING GIST(geom);

CLUSTER tampon_importe
  USING tampon_importe_geom_idx;
-------------------- OBTENTION DES RELATIONS reference PAR RAPPORT A importe

---------- le but est de comparer le linéaire de référence (r) au linéaire importé (i)
---------- pour cela, on se sert des tampons/buffers créés autour des tronçons i
---------- chaque tronçon r est comparé à chaque tampon i, afin de visualiser la relation entre chaque r et chaque i
---------- les géométries issues de ce découpage sont ou intérieures au tampon (inner), ou extérieures (outer)
---------- les relations entre un r et un i (ri) sont ensuite catégorisées selon la grille de cas définie précédemment
---------- cette catégorisation est faite du point de vue de r (cas_r) :
---------- 		100% doublon
---------- 		partiellement doublon de manière continue
---------- 		partiellement doublon de manière discontinue


---------- CREATION GEOMETRIES INTERIEURES AUX TAMPONS
---------- préparation de la table qui accueille toutes les géométries issues du découpage contre les tampons
DROP TABLE IF EXISTS tampon_splits_r;

CREATE TABLE tampon_splits_r (
	id 			SERIAL PRIMARY KEY,
	iid 		int,
    rid 		int,
    split_geom 	geometry,
    geom_i 		geometry,
    geom_r 		geometry,
    geom_tampon geometry
);

---------- découpage (ST_Split) des r contre les tampons i (tampon_importe)
---------- ST_Dump du résultat pour extraire chaque LineString de la MultiLineString issue du ST_Split
INSERT INTO tampon_splits_r (iid, rid, split_geom, geom_r, geom_i, geom_tampon)
	 SELECT ti.id as iid,
			r.id AS rid,
        	(ST_Dump(ST_Split(r.geom, ti.geom))).geom AS split_geom,
        	r.geom AS geom_r,
        	ti.geom_i,
        	ti.geom AS geom_tampon
       FROM reference r
	   JOIN tampon_importe ti
		 ON ST_DWithin(r.geom, ti.geom, 0); -- PERMET DE N'EFFECTUER LE SPLIT QUE SUR LES TAMPONS MITOYENS


---------- obtention des géométries intérieures
---------- si la géométrie d'un split est contenue dans le tampon, alors elle est intérieure
DROP TABLE IF EXISTS tampon_inner_r;

CREATE TABLE tampon_inner_r AS
	  SELECT iid,
		     rid,
		     geom_r,
		     NULL::integer AS cas_r,
	         CASE
		     WHEN ST_NumGeometries(ST_Collect(split_geom)) = 1
		     THEN ST_LineMerge(ST_Collect(split_geom))
		     ELSE ST_Collect(split_geom ORDER BY id)
		     END
		     AS geom_ri, -- RASSEMBLEMENT DE TOUS LES SPLITS D'UN TRONÇON reference
	         round((ST_Length(ST_Union(split_geom)))::NUMERIC, 1) AS longueur_ri,
	         round((ST_Length(geom_r))::NUMERIC, 1) AS longueur_r,
	         array_agg(id) AS ids_splits
	    FROM tampon_splits_r
	   WHERE ST_Contains(ST_Buffer(geom_tampon,0.00001), split_geom) -- FILTRE SUR LES SPLITS A L'INTERIEUR DES TAMPONS (0 NE FONCTIONNE PAS)
       GROUP BY iid, rid, geom_r;

ALTER TABLE tampon_inner_r ADD PRIMARY KEY (rid, iid); -- nécessaire pour modification dans QGIS


---------- ATTRIBUTION DE CAS AUX RELATIONS ri
--UPDATE tampon_inner_r SET cas_i = NULL;

---------- TRONÇON reference 100% DOUBLON PAR RAPPORT A UN TRONÇON importe
---------- car l'union de tous ses splits intérieurs est égale à la géométrie initiale
UPDATE tampon_inner_r
   SET cas_r = 1
 WHERE ST_Equals(geom_ri, geom_r); -- TRONÇONS reference 100% DOUBLON PAR RAPPORT AU TRONÇON importe

---------- TRONÇON EN DOUBLON PARTIEL ET CONTINU
---------- car l'union de tous ses splits intérieurs est une LineString, mais la relation ne relève pas du cas 1
UPDATE tampon_inner_r
   SET cas_r = 2
 WHERE cas_r IS DISTINCT FROM 1
	   AND St_GeometryType(geom_ri) = 'ST_LineString';

---------- TRONÇON EN DOUBLON PARTIEL ET DISCONTINU
---------- car l'union de tous ses splits intérieurs est une MultiLineString
UPDATE tampon_inner_r
   SET cas_r = 3
 WHERE St_GeometryType(geom_ri) = 'ST_MultiLineString';
-------------------- OBTENTION DES RELATIONS importe PAR RAPPORT A reference

---------- le but est de comparer le linéaire importé (i) au linéaire de référence (r)
---------- pour cela, on se sert des tampons/buffers créés autour des tronçons r
---------- chaque tronçon i est comparé à chaque tampon r, afin de visualiser la relation entre chaque i et chaque r
---------- les géométries issues de ce découpage sont ou intérieures au tampon (inner), ou extérieures (outer)
---------- les relations entre un i et un r (ir) sont ensuite catégorisées selon la grille de cas définie précédemment
---------- cette catégorisation est faite du point de vue de i (cas_i) :
---------- 		100% doublon
---------- 		partiellement doublon de manière continue
---------- 		partiellement doublon de manière discontinue


---------- CREATION GEOMETRIES INTERIEURES AUX TAMPONS
---------- préparation de la table qui accueille toutes les géométries issues du découpage contre les tampons
DROP TABLE IF EXISTS tampon_splits_i;

CREATE TABLE tampon_splits_i (
	id 			SERIAL PRIMARY KEY,
	iid 		int,
    rid 		int,
    split_geom 	geometry,
    geom_i 		geometry,
    geom_r 		geometry,
    geom_tampon geometry
);

---------- découpage (ST_Split) des i contre les tampons r (tampon_reference)
---------- ST_Dump du résultat pour extraire chaque LineString de la MultiLineString issue du ST_Split
INSERT INTO tampon_splits_i (iid, rid, split_geom, geom_i, geom_r, geom_tampon)
	 SELECT i.id AS iid,
            tr.id as rid,
            (ST_Dump(ST_Split(i.geom, tr.geom))).geom AS split_geom,
            i.geom AS geom_i,
            tr.geom_r,
            tr.geom AS geom_tampon
       FROM importe i
       JOIN tampon_reference tr
      	 ON ST_DWithin(i.geom, tr.geom, 0); -- PERMET DE N'EFFECTUER LE SPLIT QUE SUR LES TAMPONS MITOYENS


---------- obtention des géométries intérieures
---------- si la géométrie d'un split est contenue dans le tampon, alors elle est intérieure
DROP TABLE IF EXISTS tampon_inner_i;

CREATE TABLE tampon_inner_i AS
	  SELECT iid,
		     rid,
		     geom_i,
		     NULL::integer AS cas_i,
		     CASE
		     WHEN ST_NumGeometries(ST_Collect(split_geom)) = 1
		     THEN ST_LineMerge(ST_Collect(split_geom))
		     ELSE ST_Collect(split_geom ORDER BY id)
		     END
		     AS geom_ir, -- RASSEMBLEMENT DE TOUS LES SPLITS D'UN TRONÇON reference
	         round((ST_Length(ST_Union(split_geom)))::NUMERIC, 1) AS longueur_ir,
	         round((ST_Length(geom_i))::NUMERIC, 1) AS longueur_i,
	         array_agg(id) AS ids_splits
	    FROM tampon_splits_i
	   WHERE ST_Contains(ST_Buffer(geom_tampon,0.00001), split_geom) -- FILTRE SUR LES SPLITS A L'INTERIEUR DES TAMPONS (0 NE FONCTIONNE PAS)
       GROUP BY iid, rid, geom_i;

ALTER TABLE tampon_inner_i ADD PRIMARY KEY (iid, rid); -- nécessaire pour modification dans QGIS


-- ATTRIBUTION DE CAS AUX RELATIONS ir
--UPDATE tampon_inner_i SET cas_i = NULL;

---------- TRONÇON importe 100% DOUBLON PAR RAPPORT A UN TRONÇON reference
---------- car l'union de tous ses splits intérieurs est égale à la géométrie initiale
UPDATE tampon_inner_i
   SET cas_i = 1
 WHERE ST_Equals(geom_ir, geom_i);

---------- TRONÇON EN DOUBLON PARTIEL ET CONTINU
---------- car l'union de tous ses splits intérieurs est une LineString, mais la relation ne relève pas du cas 1
UPDATE tampon_inner_i
   SET cas_i = 2
 WHERE cas_i IS DISTINCT FROM 1
	   AND ST_GeometryType(geom_ir) = 'ST_LineString';

---------- TRONÇON EN DOUBLON PARTIEL ET DISCONTINU
---------- car l'union de tous ses splits intérieurs est une MultiLineString
UPDATE tampon_inner_i
   SET cas_i = 3
 WHERE ST_GeometryType(geom_ir) = 'ST_MultiLineString';
-------------------- FUSION DES DEUX tampon_inner ET CREATION DE MATRICE DE DECISION

---------- le but est de créer une matrice de décision avec toutes les relations entre r et i
---------- pour cela, il faut joindre les enregistrements des tables tampon_inner_r et tampon_inner_i
---------- afin d'avoir une vision complète de la relation sur la même ligne, à la fois du point de vue de r et du point de vue de i


---------- CREATION DE tampon_inner_all PAR JOINTURE DE tampon_inner_r ET tampon_inner_i
DROP TABLE IF EXISTS tampon_inner_all;

CREATE TABLE tampon_inner_all AS
   	  SELECT tii.rid,
		     tii.iid,
		     tir.cas_r,
		     tii.cas_i,
		     tir.geom_r,
		     tii.geom_i,
		     tir.geom_ri,
		     tii.geom_ir,
		     tir.longueur_ri,
		     tir.longueur_r,
		     tii.longueur_ir,
		     tii.longueur_i,
		     NULL::boolean AS bruit, -- INDICATEUR CALCULE ULTERIEUREMENT
		     NULL::geometry AS geom_ir_ri, -- INDICATEUR CALCULE ULTERIEUREMENT
		     NULL::NUMERIC AS aire_ir_ri -- INDICATEUR CALCULE ULTERIEUREMENT
	    FROM tampon_inner_r tir
	  	     JOIN tampon_inner_i tii
	         ON tir.iid = tii.iid
	         AND tir.rid = tii.rid;

ALTER TABLE tampon_inner_all ADD PRIMARY KEY (rid, iid); -- nécessaire pour modification dans QGIS


---------- CRÉATION DE geom_ir_ri, ET CALCUL DE aire_ir_ri;
---------- geom_ir_ri : polygone dont deux des côtés correspondent à geom_ir et à geom_ri
WITH projections AS ( -- LOCALISATION DES PROJECTIONS DES EXTREMITES DE ir SUR r AFIN DE DETERMINER LA DIRECTION DE ir PAR RAPPORT A r
		SELECT iid,
			   rid,
			   geom_ir,
			   geom_ri,
			   ST_LineLocatePoint(geom_r, ST_StartPoint(ST_GeometryN(geom_ir, 1))) AS start_ir_on_r,
			   ST_LineLocatePoint(geom_r, ST_EndPoint(ST_GeometryN(geom_ir, ST_NumGeometries(geom_ir)))) AS end_ir_on_r
		  FROM tampon_inner_all
		 WHERE ST_GeometryType(geom_ir) = 'ST_LineString' -- EXCLUSION DES GEOMETRIES DISCONTINUES POUR SIMPLIFIER LA TACHE
		   AND ST_GeometryType(geom_ri) = 'ST_LineString'
	),
	moities_sens_inverse AS ( -- AJOUT DE POINTS AU DEBUT ET A LA FIN DE geom_ri ET geom_ir AFIN DE FORMER LE POLYGONE
					   -- SI geom_ri ET geom_ir SONT DANS UN SENS INVERSE
		SELECT iid,
			   rid,
			   ST_AddPoint(geom_ir, ST_StartPoint(geom_ri)) AS un,
			   ST_AddPoint(geom_ri, ST_StartPoint(geom_ir)) AS deux
		  FROM projections
		 WHERE start_ir_on_r > end_ir_on_r
	),
	moities_meme_sens AS ( -- AJOUT DE POINTS AU DEBUT ET A LA FIN DE geom_ri ET geom_ir AFIN DE FORMER LE POLYGONE
					-- SI geom_ri ET geom_ir SONT DANS LE MEME SENS
		SELECT iid,
			   rid,
			   ST_AddPoint(ST_Reverse(geom_ir), ST_StartPoint(geom_ri)) AS un,
			   ST_AddPoint(geom_ri, ST_EndPoint(geom_ir)) AS deux
		  FROM projections
		 WHERE start_ir_on_r < end_ir_on_r
	),
	moities_toutes AS (
		SELECT * FROM moities_sens_inverse
		 UNION ALL
		SELECT * FROM moities_meme_sens
	),
	polygones AS ( -- CREATION DES POLYGONES => geom_ir_ri
		SELECT iid,
			   rid,
			   ST_CollectionHomogenize(ST_Polygonize(ST_Union(un, deux))) AS geom_ir_ri,
			   ST_Area(ST_Polygonize(ST_Union(un, deux))) AS aire_ir_ri
		  FROM moities_toutes
	     GROUP BY iid, rid
	)
UPDATE tampon_inner_all ti
   SET geom_ir_ri = p.geom_ir_ri,
	   aire_ir_ri = p.aire_ir_ri
  FROM polygones p
 WHERE p.iid = ti.iid
   AND p.rid = ti.rid;




---------- EXCLUSION DES RELATIONS CONSIDEREES COMME DU BRUIT
---------- certaines relations entre tronçons ne sont pas pertinentes, c'est du bruit créé par l'algorithme
---------- l'extrémité d'un tronçon r peut par exemple être en doublon avec plusieurs tronçons i au niveau d'une intersection
---------- ce sont des "faux" doublons, car les deux tronçons ne représentent pas réellement un même sentier
---------- ou une même partie de celui-ci.
---------- le but est donc de reconnaître un certain nombre de ces situations pour éliminer le bruit et clarifier les opérations ultérieures
---------- ceci en se servant, par ordre de préférence :
---------- 		 des cas définis précédemment
---------- 		 d'indicateurs "objectifs" (exemple : si r est déjà contenu à 100% dans un autre tampon i, alors ses autres relations sont du bruit)
----------       d'indicateurs subjectifs (valeurs seuils fixées plus ou moins empiriquement)

UPDATE tampon_inner_all
   SET bruit = NULL;

---------- SI r OU i EST ENTIEREMENT CONTENU DANS LE TAMPON DE L'AUTRE : PAS BRUIT
---------- une relation où l'un des tronçons est entièrement en doublon avec un autre est signifiante
UPDATE tampon_inner_all
   SET bruit = FALSE
 WHERE cas_r = 1
    OR cas_i = 1;

---------- POUR LES TRONÇONS r ENTIEREMENT EN DOUBLON AVEC PLUSIEURS i : IDENTIFIER LE i LE PLUS PROCHE
---------- la relation dont aire_ir_ri a la valeur la plus faible est celle où le r et le i sont les plus proches
---------- donc devrait être la plus signifiante. Toutes les autres relations sont donc du bruit.
---------- utile pour les mini tronçons r (moins de 5m) entièrement compris dans plusieurs tampons i à la fois
WITH a AS (
	SELECT rid,
		   iid,
		   aire_ir_ri,
		   ROW_NUMBER() OVER ( -- NUMEROTATION DES LIGNES DE GROUPES D'ENREGISTREMENTS...
		   	PARTITION BY (rid) -- ...CREES SELON LEUR rid
		   		ORDER BY aire_ir_ri ASC -- TRI ASCENDANT POUR QUE LA RELATION DONT aire_ir_ri EST LA PLUS FAIBLE SOIT EN PREMIERE LIGNE DE CHAQUE GROUPE
		   		) rn
	  FROM tampon_inner_all ti
	 WHERE NOT cas_i = 1 -- EXCLUSION DES RELATIONS OÙ I EST AUSSI ENTIEREMENT COMPRIS DANS LE TAMPON R
	   AND cas_r = 1
	)
UPDATE tampon_inner_all ti
   SET bruit = TRUE
  FROM a
 WHERE rn != 1 -- EXCLUSION DES RELATIONS EN PREMIERE LIGNE DE CHAQUE GROUPE
   AND ti.rid = a.rid
   AND ti.iid = a.iid;

---------- POUR LES TRONÇONS i ENTIEREMENT EN DOUBLON AVEC PLUSIEURS r : IDENTIFIER LE r LE PLUS PROCHE
---------- la relation dont aire_ir_ri a la valeur la plus faible est celle où le i et le r sont les plus proches
---------- donc devrait être la plus signifiante. Toutes les autres relations sont donc du bruit.
---------- utile pour les mini tronçons i (moins de 5m) entièrement compris dans plusieurs tampons r à la fois
WITH a AS (
	SELECT rid,
		   iid,
		   aire_ir_ri,
		   ROW_NUMBER() OVER ( -- NUMEROTATION DES LIGNES DE GROUPES D'ENREGISTREMENTS...
		   	PARTITION BY (iid) -- ...CREES SELON LEUR rid
		   		ORDER BY aire_ir_ri ASC -- TRI ASCENDANT POUR QUE LA RELATION DONT aire_ir_ri EST LA PLUS FAIBLE SOIT EN PREMIERE LIGNE DE CHAQUE GROUPE
		   		) rn
	  FROM tampon_inner_all ti
	 WHERE NOT cas_r = 1 -- EXCLUSION DES RELATIONS OÙ r EST AUSSI ENTIEREMENT COMPRIS DANS LE TAMPON i
	   AND cas_i = 1
	)
UPDATE tampon_inner_all ti
   SET bruit = TRUE
  FROM a
 WHERE rn != 1 -- EXCLUSION DES RELATIONS EN PREMIERE LIGNE DE CHAQUE GROUPE
   AND ti.rid = a.rid
   AND ti.iid = a.iid;


---------- SI r EST DEJA 100% CONTENU DANS UN BUFFER i, ALORS LES AUTRES RELATIONS DE r SONT DU BRUIT
---------- corrollaire du traitement précédent :
---------- les relations de doublon partiel impliquant un tronçon r déjà en doublon total avec un i sont du bruit
WITH a AS (
	SELECT rid
	  FROM tampon_inner_all
	 WHERE cas_r = 1
	 )
UPDATE tampon_inner_all tia
   SET bruit = TRUE
  FROM a
 WHERE a.rid = tia.rid
   AND bruit IS NULL
   AND cas_r != 1;


---------- SI r ET i SONT DES DOUBLONS PARTIELS ET QUE LES LONGUEURS DE ri ET ir REPONDENT A CERTAINS CRITERES : BRUIT
---------- on considère que si les longueurs de ri ou de ir sont inférieures à 10m (soit deux fois la longueur du tampon)
---------- ou que si le rapport des longueurs de ri sur r et de ir sur i sont inférieurs à 10%, alors la relation est du bruit
---------- le choix des valeurs est arbitraire et crée un effet de seuil qui peut être indésirable
UPDATE tampon_inner_all
   SET bruit = TRUE
 WHERE bruit IS NULL
   AND cas_r in (2,3)
   AND cas_i IN (2,3)
   AND (longueur_ri < 10.5
   		OR longueur_ir < 10.5
		OR (longueur_ir/longueur_i < 0.1
			AND longueur_ri/longueur_r < 0.1));


---------- SI r ET i SONT DES DOUBLONS MAIS PAS DETECTES COMME BRUIT PRECEDEMMENT ET PAS DOUBLE RELATION DISCONTINUE : PAS BRUIT
UPDATE tampon_inner_all
   SET bruit = FALSE
 WHERE bruit IS NULL
   AND cas_r IN (2,3)
   AND cas_i IN (2,3)
   AND NOT (cas_r = 3 AND cas_i = 3);


---------- DOUBLE DOUBLON DISCONTINU A PRIORI REEL DOUBLON
---------- car r et i intersectent leurs tampons respectifs plus de deux fois
---------- ils sont donc en relation de manière assez constante
UPDATE tampon_inner_all
   SET bruit = FALSE
 WHERE cas_r = 3
   AND cas_i = 3
   AND (ST_NumGeometries(geom_ri) != 2 OR ST_NumGeometries(geom_ir) != 2);

---------- DOUBLE DOUBLON DISCONTINU A PRIORI REEL DOUBLON
---------- car la longueur en doublon d'un des tronçons de la relation est supérieure a la moitié de sa longueur totale
---------- le choix des valeurs est arbitraire et crée un effet de seuil qui peut être indésirable
UPDATE tampon_inner_all
   SET bruit = FALSE
 WHERE cas_r = 3
   AND cas_i = 3
   AND bruit IS NULL
   AND (longueur_ri/longueur_r > 0.5 OR longueur_ir/longueur_i > 0.5);

---------- DOUBLE DOUBLON DISCONTINU A PRIORI BRUIT (SOUVENT EXTREMITES DE TRONÇON)
---------- car la longueur en doublon des deux tronçons de la relation est inférieure a 20% de leur longueur totale
---------- le choix des valeurs est arbitraire et crée un effet de seuil qui peut être indésirable
UPDATE tampon_inner_all
   SET bruit = TRUE
 WHERE cas_r = 3
   AND cas_i = 3
   AND (ST_NumGeometries(geom_ri) = 2 OR ST_NumGeometries(geom_ir) = 2)
   AND longueur_ri/longueur_r < 0.2
   AND longueur_ir/longueur_i < 0.2;

---------- SI geom_ir D'UN i DEJA EVALUE CONTIENT geom_ir D'UNE AUTRE RELATION DE CE i, ALORS CETTE AUTRE RELATION = BRUIT
---------- une relation dont la geom_ir (la partie de i à moins de 5m de r) est entièrement comprise dans la geom_ir d'une autre relation est considérée comme du bruit
---------- en effet une même portion d'un tronçon i ne doit correspondre qu'à un seul tronçon r et pas à plusieurs
---------- il faut donc conserver la plus signifiante, donc celle qui englobe les autres
WITH a AS (
	SELECT iid,
		   rid,
		   geom_ir
	  FROM tampon_inner_all
	 WHERE NOT bruit
	)
UPDATE tampon_inner_all tia
   SET bruit = TRUE
  FROM a
 WHERE ST_Contains(ST_Buffer(a.geom_ir, 0.5), tia.geom_ir) -- TAMPON NECESSAIRE CAR LES geom_ir SONT LEGEREMENT DIFFERENTES
   AND a.iid = tia.iid
   AND a.rid != tia.rid
   AND cas_r IN (2,3)
   AND cas_i IN (2,3);


WITH a AS (
	SELECT iid,
		   rid,
		   geom_ri
	  FROM tampon_inner_all
	 WHERE NOT bruit
	)
UPDATE tampon_inner_all tia
   SET bruit = TRUE
  FROM a
 WHERE ST_Contains(ST_Buffer(a.geom_ri, 0.5), tia.geom_ri) -- TAMPON NECESSAIRE CAR LES geom_ri SONT LEGEREMENT DIFFERENTES
   AND a.rid = tia.rid
   AND a.iid != tia.iid
   AND cas_r IN (2,3)
   AND cas_i IN (2,3);
