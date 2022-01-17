---------- IMPORT DU NOUVEAU RÉSEAU core_path_wip_new DANS core_path

---------- DÉSACTIVATION DES TRIGGERS DE core_path
ALTER TABLE core_path DISABLE TRIGGER USER;

---------- MISE À JOUR DE LA GÉOMÉTRIE ET DES ATTRIBUTS DES core_path EXISTANTS
UPDATE core_path
   SET geom = cp_wn.geom_new,
       "comments" = cp_wn."comments",
       eid = cp_wn.eid,
       structure_id = cp_wn.structure_id,
	   date_update = CURRENT_TIMESTAMP
  FROM core_path_wip_new cp_wn
 WHERE cp_wn.id = core_path.id
   AND NOT core_path.geom = cp_wn.geom_new;

---------- INSERTION DANS core_path DES NOUVEAUX TRONÇONS
INSERT INTO core_path (geom, "comments", eid, structure_id, "valid", visible, draft, length, date_insert, date_update)
     SELECT geom_new AS geom,
            "comments" AS "comments",
            eid AS eid,
            structure_id AS structure_id,
            TRUE::boolean AS valid,
            TRUE::boolean AS visible,
            FALSE::boolean AS draft,
            0 AS length,
			CURRENT_TIMESTAMP AS date_insert,
			CURRENT_TIMESTAMP AS date_update
       FROM core_path_wip_new cp_wn
      WHERE cp_wn.geom IS NULL -- un tronçon sans géométrie initiale est forcément nouveau
        AND cp_wn.id NOT IN (SELECT id FROM core_path); -- double vérification que c'est bien un nouveau tronçon

---------- ACTIVATION DES TRIGGERS DE core_path
ALTER TABLE core_path ENABLE TRIGGER USER;
