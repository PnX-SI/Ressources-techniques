-- Nombre de randos créées en 2022 et publiées, par structure
SELECT s."name", count(tt.topo_object_id)
FROM trekking_trek tt 
JOIN core_topology ct ON ct.id = tt.topo_object_id
JOIN authent_structure s ON s.id = tt.structure_id 
WHERE ct.kind='TREK' 
AND EXTRACT(YEAR FROM ct.date_insert) = 2022 
AND tt.published = true -- Pour limiter aux randos publiées
AND ct.deleted = false
GROUP BY s."name" 
  
-- Liste des randos créées en 2022 par la structure 1 et publiées
SELECT *
FROM trekking_trek tt 
JOIN core_topology ct ON ct.id = tt.topo_object_id
WHERE ct.kind='TREK' 
AND EXTRACT(YEAR FROM ct.date_insert) = 2022 
AND tt.published = true 
AND tt.structure_id = 1
AND ct.deleted = false
  
-- Nombre de signalétiques créées en 2022, par structure
SELECT s."name", count(tt.topo_object_id)
FROM signage_signage tt 
JOIN core_topology ct ON ct.id = tt.topo_object_id
JOIN authent_structure s ON s.id = tt.structure_id 
WHERE ct.kind='SIGNAGE' 
AND EXTRACT(YEAR FROM ct.date_insert) = 2022 
AND ct.deleted = false
GROUP BY s."name" 
