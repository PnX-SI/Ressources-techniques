SELECT column_name, e.enumlabel--, *
FROM pg_enum e
JOIN pg_type t ON e.enumtypid = t.oid
LEFT OUTER JOIN information_schema.columns on udt_name = typname
and  table_name ilike 'saisie_observation';


SELECT column_name, udt_name
FROM information_schema.columns
where table_name ilike 'saisie_observation'
;

-- code lpo ? champ comportement
SELECT * FROM saisie.comportement;
-- https://github.com/PnX-SI/GeoNature/issues/566