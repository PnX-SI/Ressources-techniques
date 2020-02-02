-- STATISTIQUES DIVERSES

-- Nombre de données d'un organisme pour une année donnée
SELECT 
id_synthese, s.date_min, s.observers, 
ARRAY_AGG (c.id_organism || '-' || c.id_nomenclature_actor_role) Acteurs,
s.id_dataset, d.dataset_name 
FROM gn_synthese.synthese s
JOIN gn_meta.t_datasets d ON s.id_dataset = d.id_dataset
JOIN gn_meta.cor_dataset_actor c ON c.id_dataset = d.id_dataset
WHERE (EXTRACT (YEAR FROM s.date_min)) = 2015 AND c.id_organism = 2
GROUP BY id_synthese, s.id_dataset, s.date_min, s.observers, d.dataset_name
--LIMIT 100;
