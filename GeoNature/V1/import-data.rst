=========================================================
Exemples d'intégration de données dans un GeoNature 1.9.1
=========================================================

Dans cet exemple, on va intégrer des données historiques dans une BDD GeoNature à partir de fichiers CSV ou SHP.

On va d'abord intégrer les données brutes dans un schéma dédié puis les reporter dans la Synthèse de GeoNature.

::

  -- Fichier CSV
  -- Ouvert avec QGIS (UTF8), importé tel quel dans une table temporaire de la BDD GeoNature (schema historique)

  -- Créer la table finale

  CREATE TABLE historique.ecrevisses_38
  (
    id serial NOT NULL,
    observateur character varying(255),
    dateobs character varying(255),
    dernieredate character varying(255),
    espece character varying(255),
    coursdeau character varying(255),
    codecoursdeau character varying(255),
    bassinversant character varying(255),
    the_geom geometry(Point,2154),
    commune character varying(255),
    CONSTRAINT ecrevisses_38_pkey PRIMARY KEY (id)
  )
  ;
  ALTER TABLE historique.ecrevisses_38
    OWNER TO geonatuser;

  -- Intégrer les données de la table importée vers la table finale
  
  INSERT INTO historique.ecrevisses_38 
    (observateur, dateobs, dernieredate, espece, cd_nom, coursdeau, codecoursdeau, bassinversant, the_geom, commune) 
    (SELECT 
      "Observateur", 
      "Date Observation", 
      "DERNIERE D", 
      espece, 
      '18437', 
      "nom du cou", 
      "code cours", 
      "bassin ver", 
      ST_SetSRID(ST_MakePoint("X L93"::numeric, "Y L93"::numeric),2154), 
      "COMMUNE" 
    FROM historique.ecrevisses_import);

  -- Supprimer la table d'import

  DROP TABLE historique.ecrevisses_import;

On va maintenant intégrer les données brutes dans la Synthèse.
	
Préparer le contenu des autres tables de métadonnées liées aux données sources avec de les intégrer dans la synthèse.

On créé un lot, mais dans notre cas, on rattache les données au programme Faune invertébrés et au protocole Contact invertebres

Dans ``meta.bib_lots``, ajouter la ligne : 

::

  8;"Historique ecrevisses";"Données historiques d'ecrevisses (mai 2018)";FALSE;TRUE;FALSE;3

Dans ``synthese.bib_sources``, ajouter la ligne : 

::

  8;"Historique";"Données historiques intégrées manuellement dans la BDD";"localhost";22;"";"";"geonaturedb";"historique";"";"id";"";"";"";"FAUNE";FALSE


::

  --------- Intégrer les données dans la Synthèse. Certaines données sont imprécises, notamment les dates, et doivent être traitées

  INSERT INTO synthese.syntheseff
  (id_source, id_organisme, id_protocole, id_precision, cd_nom, dateobs, observateurs, 
  determinateur, remarques, date_insert, date_update, derniere_action, supprime, the_geom_point, 
  id_lot, id_critere_synthese, the_geom_3857, the_geom_local, diffusable) 
    (SELECT
          8 AS id_source,
          4 AS id_organisme,
          3 AS id_protocole,
          12 AS id_precision,
          cd_nom AS cd_nom,
          CASE
           WHEN length(dateobs) = 10 THEN (dateobs)::date
           WHEN length(dateobs) = 8 THEN (left(dateobs,4)||'-'||substring(dateobs from 5 for 2)||'-'||right(dateobs,2))::date
           WHEN length(dateobs) = 6 THEN (left(dateobs,4)||'-'||substring(dateobs from 5 for 2)||'-01')::date
           WHEN length(dateobs) = 4 THEN (left(dateobs,4)||'-01-01')::date
           ELSE ('0001-01-01')::date
          END as dateobs,
          observateur AS observateurs,
          '' AS determinateur,
          CASE
           WHEN length(dateobs) = 4 THEN ('Date imprécise (année) - Cours d''eau : '||coursdeau||' ('||codecoursdeau||')- BV : '||bassinversant)
           WHEN dateobs = '1999-2011(TEREO)' THEN ('Date imprécise (1999-2011) - Cours d''eau : '||coursdeau||' ('||codecoursdeau||')- BV : '||bassinversant)
           WHEN length(dateobs) = 10 THEN ('Date précise - Cours d''eau : '||coursdeau||' ('||codecoursdeau||')- BV : '||bassinversant)
           ELSE ('Date inconnue - Cours d''eau : '||coursdeau||' ('||codecoursdeau||')- BV : '||bassinversant)
          END as remarques,
          now() AS date_insert,
          now() AS date_update,
          'c' AS derniere_action,
          false AS supprime,
          st_transform(st_centroid(the_geom),3857) AS the_geom_point,
          8 AS id_lot,
          1 AS id_critere_synthese,
          st_transform(the_geom, 3857) AS the_geom_3857,
          the_geom AS the_geom_local,
          true AS diffusable
    FROM historique.ecrevisses_38
    ORDER BY dateobs);
  
  --- Verifier les données intégrées 

  SELECT * FROM synthese.syntheseff
  WHERE id_organisme = 4
  

Importer un SHP
===============

Cet exemple est assez similaire mais les données sont plus précises et intégrés dans la BDD sans passer par une table d'import temporaire.

::

  -- Fichier SHP amphibiens
  -- Ouvert avec QGIS (System), importé dans BDD GeoNature (schema historique)
  
  Ajout dans meta.bib_lots

  10;"Historique amphibiens";"Données historiques d'amphibiens (mai 2018)";FALSE;TRUE;FALSE;1

  -- Intégration dans la Synthèse

  INSERT INTO synthese.syntheseff
  (id_source, id_organisme, id_protocole, id_precision, cd_nom, dateobs, observateurs, 
  determinateur, remarques, date_insert, date_update, derniere_action, supprime, the_geom_point, 
  id_lot, id_critere_synthese, the_geom_3857, the_geom_local, diffusable) 
    (SELECT
          8 AS id_source,
          4 AS id_organisme,
          1 AS id_protocole,
          12 AS id_precision,
          cd_nom::integer AS cd_nom,
          date as dateobs,
          observateu AS observateurs,
          '' AS determinateur,
          site||' - '||remarques as remarques,
          now() AS date_insert,
          now() AS date_update,
          'c' AS derniere_action,
          false AS supprime,
          st_transform(st_centroid(geom),3857) AS the_geom_point,
          10 AS id_lot,
          1 AS id_critere_synthese,
          st_transform(geom, 3857) AS the_geom_3857,
          geom AS the_geom_local,
          true AS diffusable
    FROM historique.amphibiens_05
    ORDER BY dateobs);
