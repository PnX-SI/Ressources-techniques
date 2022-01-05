--- MAJ geométrie core_path


ALTER TABLE core_path DISABLE TRIGGER USER;

UPDATE core_path
   SET geom = cp_wn.geom_new,
       "comments" = cp_wn."comments",
       eid = cp_wn.eid,
       structure_id = cp_wn.structure_id,
	   date_update = CURRENT_TIMESTAMP
  FROM core_path_wip_new cp_wn
 WHERE cp_wn.id = core_path.id AND NOT core_path.geom = cp_wn.geom_new;



INSERT INTO core_path (geom, "comments", eid, structure_id, "valid", visible, draft, length, date_insert, date_update)
     SELECT geom_new,
            "comments",
            eid,
            structure_id,
            TRUE::boolean as valid,
            TRUE::boolean as visible,
            FALSE::boolean as draft,
            0 as length,
			CURRENT_TIMESTAMP as date_insert,
			CURRENT_TIMESTAMP as date_update
       FROM core_path_wip_new cp_wn
      WHERE cp_wn.geom IS NULL -- un tronçon sans géométrie initiale est forcément nouveau
        AND cp_wn.id NOT IN (SELECT id FROM core_path); -- double vérification que c'est bien un nouveau tronçon

ALTER TABLE core_path ENABLE TRIGGER USER;

