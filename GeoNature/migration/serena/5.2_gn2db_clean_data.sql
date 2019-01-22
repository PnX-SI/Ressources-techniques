-- Si l'on est sûr de ne plus avoir besoin des tables de données distantes et du serveur FDW que l'on a crée précedemment pour intégrer les données dans a BDD de GeoNature,
-- on peut, les supprimer comme suit :

DROP SERVER serena_server CASCADE;

DROP SCHEMA IF EXISTS _import_serena CASCADE;