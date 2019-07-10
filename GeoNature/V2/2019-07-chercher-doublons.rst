Vérifier les doublons dans la synthèse de GeoNature
===================================================

Par Donovan Maillard / Flavia (Juillet 2019)

Au fil des échanges, il est fréquent de récupérer, voire produire, des doublons n'ayant pas un identifiant unique pour les repérer (double saisies, transferts sans identifiants etc...). 

Ci-dessous un exemple de script pour repérer les "doublons" ou données très similaires dans la synthèse, sans s'appuyer sur les identifiants uniques. Ce script renvoie toutes les lignes pour lesquelles des données concernent :

- la même espèce au même stade et avec le même sexe, 
- vue aux mêmes dates, 
- par le(s) même(s) observateurs, 
- à moins de 20m d'écart (ce tampon compense les éventuels arrondis de coordonnées, il est adaptable dans la commande ST_Buffer). 

La requête renvoie les informations permettant de retrouver la donnée : date, lieu, espèce, observateur, stade, sexe, id_synthese de la ligne avec laquelle cela fait doublon. 

.. code-block:: sql

  -- Rechercher les infos d'une première donnée, en lui créant un tampon de quelques mètres pour éviter de rater 
  -- un doublon du fait de la précision des coordonnées provenant de différentes sources)
  WITH first_data AS (
      SELECT sy.id_synthese, sy.observers, sy.date_min, sy.date_max, ST_Buffer(sy.the_geom_local, 20) AS buffer_geom, sy.cd_nom, 
      sy.id_nomenclature_life_stage, sy.id_nomenclature_sex FROM gn_synthese.synthese sy)

  -- Rechercher les mêmes infos dans les éventuels doublons en récupérant la source et l'id de la ligne 
  -- avec laquelle la donnée fait doublon
  SELECT doublons.id_synthese, 
          s.name_source, 
          doublons.observers AS observateurs, 
          doublons.date_min, 
          doublons.date_max,
          ST_X(st_centroid(doublons.the_geom_local)) AS x_centroid, 
          ST_y(st_centroid(doublons.the_geom_local)) AS y_centroid, 
          doublons.cd_nom, 
          t.lb_nom, 
          n1.mnemonique AS stade, 
          n2.mnemonique AS sexe, 
          f.id_synthese AS doublon_avec 
  FROM gn_synthese.synthese doublons
  JOIN first_data f ON f.observers=doublons.observers
  AND f.date_min=doublons.date_min
  AND f.date_max=doublons.date_max
  AND f.cd_nom=doublons.cd_nom
  AND f.id_nomenclature_life_stage=doublons.id_nomenclature_life_stage
  AND f.id_nomenclature_sex=doublons.id_nomenclature_sex
  AND ST_Intersects(f.buffer_geom, doublons.the_geom_local) 
  AND doublons.id_synthese NOT IN (f.id_synthese)
  JOIN taxonomie.taxref t ON doublons.cd_nom=t.cd_nom
  JOIN ref_nomenclatures.t_nomenclatures n1 ON doublons.id_nomenclature_life_stage=n1.id_nomenclature
  JOIN ref_nomenclatures.t_nomenclatures n2 ON doublons.id_nomenclature_sex=n2.id_nomenclature
  JOIN gn_synthese.t_sources s ON doublons.id_source=s.id_source
