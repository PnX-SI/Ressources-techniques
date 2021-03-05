CREATE EXTENSION IF NOT EXISTS postgres_fdw;

DROP SERVER IF EXISTS geonature1server CASCADE;
CREATE SERVER geonature1server  
      FOREIGN DATA WRAPPER postgres_fdw 
      OPTIONS (host :'db_host_v1', dbname :'db_name_v1', port :'db_port_v1');

CREATE USER MAPPING  
        FOR :user_pg_v1
        SERVER geonature1server
        OPTIONS (password :'user_pg_pass_v1',user :'user_pg_v1');

DROP SCHEMA IF EXISTS v1_compat CASCADE;
CREATE SCHEMA v1_compat;

IMPORT FOREIGN SCHEMA utilisateurs FROM SERVER geonature1server INTO v1_compat;
IMPORT FOREIGN SCHEMA taxonomie FROM SERVER geonature1server INTO v1_compat;
IMPORT FOREIGN SCHEMA synthese FROM SERVER geonature1server INTO v1_compat;
