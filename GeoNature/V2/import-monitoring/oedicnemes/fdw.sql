CREATE EXTENSION IF NOT EXISTS postgres_fdw;

DROP SERVER IF EXISTS data_oedic_server CASCADE;
CREATE SERVER data_oedic_server  
      FOREIGN DATA WRAPPER postgres_fdw 
      OPTIONS (host 'ip-serveur', dbname 'geonaturedb', port '5432');

CREATE USER MAPPING
    FOR myuser
 SERVER data_oedic_server
OPTIONS (user 'myuser', password 'toto');

DROP SCHEMA IF EXISTS import_gn_monitoring CASCADE;
CREATE SCHEMA IF NOT EXISTS import_gn_monitoring;
IMPORT FOREIGN SCHEMA gn_monitoring
    FROM SERVER data_oedic_server INTO import_gn_monitoring;

DROP SCHEMA IF EXISTS import_monitoring_oedic CASCADE;
CREATE SCHEMA IF NOT EXISTS import_monitoring_oedic;
IMPORT FOREIGN SCHEMA monitoring_oedic
    FROM SERVER data_oedic_server INTO import_monitoring_oedic;

DROP SCHEMA IF EXISTS import_ref_nomenclatures CASCADE;
CREATE SCHEMA IF NOT EXISTS import_ref_nomenclatures;
IMPORT FOREIGN SCHEMA ref_nomenclatures
    FROM SERVER data_oedic_server INTO import_ref_nomenclatures;

DROP SCHEMA IF EXISTS import_utilisateurs CASCADE;
CREATE SCHEMA IF NOT EXISTS import_utilisateurs;
IMPORT FOREIGN SCHEMA utilisateurs
    FROM SERVER data_oedic_server INTO import_utilisateurs;

