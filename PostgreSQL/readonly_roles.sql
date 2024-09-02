/*  Création d'un role/groupe readonly */

-- Script pour créer un role readonly générique ayant accès en lecture à toute la base de donnée.
-- Il suffit alors de créer un rôle héritant de ce dernier :
-- create role nouveaurole login encrypted password 'mdp' in role readonly;

BEGIN;

CREATE ROLE readonly;

DROP EVENT TRIGGER IF EXISTS grant_readonly_access;

/* Fonction attribuant automatiquement les droits d'usage sur les nouveaux schémas et de select sur les nouvelles tables */
CREATE OR REPLACE FUNCTION grant_readonly_on_new_relations()
    RETURNS EVENT_TRIGGER
    LANGUAGE plpgsql AS
$$
DECLARE
    obj RECORD;
BEGIN
    FOR obj IN SELECT * FROM pg_event_trigger_ddl_commands()
        LOOP
            IF obj.object_type LIKE 'schema'
            THEN
                EXECUTE
                    'GRANT USAGE ON SCHEMA ' || obj.object_identity || ' TO readonly';
                EXECUTE 'ALTER DEFAULT PRIVILEGES IN SCHEMA ' || obj.object_identity ||
                        ' GRANT SELECT ON TABLES TO readonly';
            END IF;
            IF obj.object_type LIKE 'table'
            THEN
                EXECUTE 'GRANT SELECT ON TABLE ' || obj.object_identity || ' TO readonly';
            END IF;
        END LOOP;
END
$$;

/* Application du trigger sur toutes les créations de schémas ou de tables */
CREATE EVENT TRIGGER grant_readonly_access
    ON ddl_command_end WHEN TAG IN ('CREATE TABLE','CREATE SCHEMA')
EXECUTE FUNCTION grant_readonly_on_new_relations();

/* Appliquer les droits en lecture seule sur les relations déjà existantes */
DO
$do$
    DECLARE
        listschemas RECORD;
    BEGIN
        FOR listschemas IN
            SELECT nspname
            FROM pg_catalog.pg_namespace
            WHERE nspname LIKE 'information_schema'
               OR nspname NOT LIKE 'pg_%'
            LOOP
                EXECUTE 'GRANT USAGE on schema ' || listschemas.nspname || ' TO readonly';
                EXECUTE 'GRANT SELECT ON ALL TABLES IN SCHEMA ' || listschemas.nspname ||
                        ' TO readonly';
                EXECUTE 'ALTER DEFAULT PRIVILEGES IN SCHEMA ' || listschemas.nspname ||
                        ' GRANT SELECT ON tables TO readonly';
                EXECUTE 'ALTER DEFAULT PRIVILEGES IN SCHEMA ' || listschemas.nspname ||
                        ' GRANT SELECT, USAGE ON sequences TO readonly';
            END LOOP;
    END
$do$;

COMMIT;

/* TESTS  with new user*/
DO
$test$
    BEGIN
        RESET ROLE;

        DROP ROLE IF EXISTS test;
        CREATE ROLE test IN ROLE readonly;

        DROP SCHEMA IF EXISTS testschema CASCADE;
        CREATE SCHEMA testschema;

        CREATE TABLE testschema.testtable
        (
            id  SERIAL PRIMARY KEY,
            lib VARCHAR
        );

        INSERT INTO testschema.testtable(lib)
        VALUES ('hjhjh')
             , ('jhjkhkjh')
             , ('jhjkhkjh');

        CREATE VIEW testschema.v_testtable AS
        SELECT *
        FROM testschema.testtable;
        CREATE MATERIALIZED VIEW testschema.mv_testtable AS
        SELECT *
        FROM testschema.testtable;
        SET ROLE test;

        RAISE NOTICE 'TEST Table';
        PERFORM *
        FROM testschema.testtable;
        RAISE NOTICE 'TEST View';
        PERFORM *
        FROM testschema.v_testtable;
        RAISE NOTICE 'TEST Materialized view';
        PERFORM *
        FROM testschema.mv_testtable;

        RESET ROLE;
        DROP SCHEMA IF EXISTS testschema CASCADE;
        DROP ROLE IF EXISTS test;
    END;
$test$
