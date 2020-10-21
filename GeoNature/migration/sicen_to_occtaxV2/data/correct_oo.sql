-- correction des geometries

UPDATE saisie.saisie_observation so 
	SET geometrie = correct.geometrie
	FROM ( SELECT 
		id_obs, ST_BUFFER(geometrie, 0) AS geometrie
		FROM saisie.saisie_observation
		WHERE NOT ST_ISVALID(geometrie)
	)correct
WHERE correct.id_obs = so.id_obs
;


-- enlever les doublons

 WITH dbl as (
       
      SELECT  min(id_obs) AS min_id_obs,
      array_agg(id_obs) as id_s 
      
      FROM  saisie.saisie_observation
      GROUP BY 
        date_obs,
        date_debut_obs,
        date_fin_obs,
        date_textuelle,
        regne,
        nom_vern,
        nom_complet,
        cd_nom,
        effectif_textuel,
        effectif_min,
        effectif_max,
        type_effectif,
        phenologie,
        id_waypoint,
        longitude,
        latitude,
        localisation,
        observateur,
        numerisateur,
        validateur,
        structure,
        remarque_obs,
        code_insee,
        id_lieu_dit,
        diffusable,
        precision,
        statut_validation,
        id_etude,
        id_protocole,
        effectif,
        url_photo,
        commentaire_photo,
        decision_validation,
        heure_obs,
        determination,
        elevation,
        geometrie,
        phylum,
        classe,
        ordre,
        famille,
        nom_valide,
        qualification,
        comportement--,
--        taille_cm
--        uri_mobile

       HAVING count(*)>1
  
  )
  DELETE FROM  saisie.saisie_observation
      WHERE id_obs IN (
        SELECT  id
        FROM (SELECT unnest(id_s) AS id FROM dbl) a
        EXCEPT
        SELECT min_id_obs FROM dbl
  );


-- correction date_
UPDATE saisie.saisie_observation s1
  SET 
    date_debut_obs=date_fin_obs,
    date_fin_obs=date_debut_obs
  
  WHERE date_debut_obs > date_fin_obs 
;

-- correction effectif_min, effectif_max
UPDATE saisie.saisie_observation
  SET 
    effectif_min = effectif_max,
    effectif_max = effectif_min
  
  WHERE effectif_min > effectif_max
;