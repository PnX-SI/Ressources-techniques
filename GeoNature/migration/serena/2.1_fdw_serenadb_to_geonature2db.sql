-- On crée ici une connexion en Foreign Data Wrapper entre les BDD de Serena et GeoNature
-- Note : Comme toujours, adapter les valeurs à son contexte

-- Installer l'extension postgres_fdw dans les bases de les bases de données de GeoNature ET de Serena
CREATE EXTENSION IF NOT EXISTS postgres_fdw;

-- DANS LA BDD DE GEONATURE :

-- Créer un serveur distant (connexion à la BDD Serena)
--DROP SERVER serenadb_server CASCADE;
CREATE SERVER serenadb_server 
    FOREIGN DATA WRAPPER postgres_fdw 
    OPTIONS (host 'localhost', dbname 'serenadb', port '5432');

-- créer une correspondance d'utilisateurs pour identifier le role utilisé sur le serveur distant (BDD Serena)
-- ici, on fait correspondre geonatadmin vers serenadmin
CREATE USER MAPPING 
    FOR geonatadmin 
    SERVER serenadb_server 
    OPTIONS (password 'monpassachanger',user 'serenadmin');

-- On crée un schéma à part dans la BDD GeoNature pour isoler les tables distantes de la BDD Serena que l'on va rapatrier du reste de la BDD Geonature
DROP SCHEMA IF EXISTS _import_serena CASCADE;
CREATE SCHEMA IF NOT EXISTS _import_serena;

-- On crée les tables distantes en important tout le schéma serenabase de BDD Serena
 IMPORT FOREIGN SCHEMA serenabase
    --LIMIT TO (serenabase.rnf_obse, serenabase.rnf_relv, serenabase.rnf_site)
    FROM SERVER serenadb_server
    INTO _import_serena;

-- On crée les tables distantes en important le schéma serenarefe de BDD Serena	
--> on se limite ici à la table rnf_taxo
 IMPORT FOREIGN SCHEMA serenarefe
    LIMIT TO (serenarefe.rnf_taxo)
    FROM SERVER serenadb_server
    INTO _import_serena;