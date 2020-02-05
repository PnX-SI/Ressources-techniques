-- liste les contraintes de type ref_nomenclatures.check_nomenclature
-- qui ne possèdent pas NOT VALID en fin de clause
-- et crée un commande (à copier coller) pour supprimer la contrainte 
-- et la re-créer ensuite avec NOT VALID

SELECT 
    'ALTER TABLE ' || d.table_schema || '.' || d.table_name || ' DROP CONSTRAINT ' || c.constraint_name || '; ',
    'ALTER TABLE ' || d.table_schema || '.' || d.table_name || ' ADD CONSTRAINT CHECK' || c.constraint_name || ' '  || check_clause || ' NOT VALID;'
FROM information_schema.check_constraints c
JOIN information_schema.constraint_column_usage  d
ON d.constraint_name = c.constraint_name AND d.table_schema = c.constraint_schema
WHERE check_clause ilike '%ref_nomenclatures.check_nomenclature%'
AND NOT check_clause ilike '%NOT VALID%';
