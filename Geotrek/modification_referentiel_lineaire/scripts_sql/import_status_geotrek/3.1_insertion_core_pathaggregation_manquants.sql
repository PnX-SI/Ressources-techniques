---------- INSERTION DES CORE_PATHAGGREGATION MANQUANTS
INSERT INTO core_pathaggregation (start_position, end_position, "order", path_id, topo_object_id)
SELECT start_position, end_position, "order", path_id, topo_object_id
  FROM core_pathaggregation_manquants WHERE compte = 1;


---------- RENDRE VISIBLES TOUS LES CORE_PATH UTILISÉS DANS UN core_pathaggregation
---------- Un mécanisme sur lequel nous n'avons pas investigué semble en effet désactiver
---------- la visibilité de certains `core_path` lors des requêtes d'agrégation des réseaux.
---------- Est censé régler le problème de l'interface d'édition qui n'affiche aucun tracé sur la carte
---------- et du bouton "Créer une nouvelle route" grisé
UPDATE core_path
   SET visible = TRUE
 WHERE id IN (SELECT path_id FROM core_pathaggregation);
