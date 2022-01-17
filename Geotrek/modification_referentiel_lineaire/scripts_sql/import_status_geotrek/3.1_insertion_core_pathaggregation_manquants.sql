---------- INSERTION DES CORE_PATHAGGREGATION MANQUANTS
INSERT INTO core_pathaggregation (start_position, end_position, "order", path_id, topo_object_id)
SELECT start_position, end_position, "order", path_id, topo_object_id
  FROM core_pathaggregation_manquants WHERE compte = 1;
