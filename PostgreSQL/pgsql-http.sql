-- Test de https://github.com/pramsey/pgsql-http
CREATE EXTENSION http;

-- Liste des statuts de protection de bubo bubo dans la région Languedoc-Roussillon
WITH st AS (
    SELECT json_array_elements((content::json->'_embedded'->'status')::json) as data
    FROM http_get('https://taxref.mnhn.fr/api/status/search/lines?taxrefId=3493&locationId=INSEER91')
)
SELECT
    data->>'statusTypeGroup',
    data->>'statusTypeName',
    data->>'statusName',  
    data->>'statusCode',
    data->>'statusName',
    data->>'locationId',
    data->>'locationName',
    data->>'locationAdminLevel'
FROM st;
