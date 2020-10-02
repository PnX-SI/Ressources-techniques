CREATE EXTENSION IF NOT EXISTS postgres_fdw;

DROP SERVER obsocc_server CASCADE;
CREATE SERVER obsocc_server  
      FOREIGN DATA WRAPPER postgres_fdw 
      OPTIONS (host :'db_host', dbname :'db_oo_name', port :'db_port');

CREATE USER MAPPING  
        FOR :user_pg
        SERVER obsocc_server
        OPTIONS (password :'user_pg_pass',user :'user_pg');

DROP SCHEMA IF EXISTS import_oo;
CREATE SCHEMA IF NOT EXISTS import_oo;
IMPORT FOREIGN SCHEMA export_gn
      FROM SERVER obsocc_server INTO import_oo;

