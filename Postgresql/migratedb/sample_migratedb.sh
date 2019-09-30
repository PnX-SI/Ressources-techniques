#!/bin/bash

#params
db_name=sampledestdb
user_pg=mypguser
user_pg_pass=thepguserpass

#function
function database_exists () {
    # /!\ Will return false if psql can't list database. Edit your pg_hba.conf
    # as appropriate.
    if [ -z $1 ]
        then
        # Argument is null
        return 0
    else
        # Grep db name in the list of database
        sudo -u postgres -s -- psql -tAl | grep -q "^$1|"
        return $?
    fi
}

#script
if database_exists $db_name
then
    echo "Drop database..."
    sudo -u postgres -s dropdb $db_name
fi

if ! database_exists $db_name
then
    echo "Creating database..."
    echo "--------------------" &> install_db.log
    echo "Creating database" &>> install_db.log
    echo "--------------------" &>> install_db.log
    echo "" &>> install_db.log
    sudo -n -u postgres -s createdb -O $user_pg $db_name -E UTF-8 -l 'fr_FR.UTF-8'
    echo "Adding PostGIS and PLPGSQL extensions..."
    echo "" &>> install_db.log
    echo "" &>> install_db.log
    echo "--------------------" &>> install_db.log
    echo "Adding PostGIS and PLPGSQL extensions" &>> install_db.log
    echo "--------------------" &>> install_db.log
    echo "" &>> install_db.log
    sudo -n -u postgres -s psql -d $db_name -c "CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog; COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';" &>> install_db.log
    # commenter, ajouter ou supprimé les lignes ci-dessous selon les extentions necessaires (voir la base source)
    sudo -n -u postgres -s psql -d $db_name -c "CREATE EXTENSION IF NOT EXISTS postgis;" &>> install_db.log
    sudo -n -u postgres -s psql -d $db_name -c 'CREATE EXTENSION IF NOT EXISTS "uuid-ossp";' &>> install_db.log
fi

echo "Creating database schemas..."
echo "--------------------" &> install_db.log
echo "Creating database schemas" &>> install_db.log
echo "--------------------" &>> install_db.log
echo "" &>> install_db.log
export PGPASSWORD=$user_pg_pass;psql -h localhost -U $user_pg -d $db_name -f /tmp/sample_public_schema.sql &>> install_db.log
export PGPASSWORD=$user_pg_pass;psql -h localhost -U $user_pg -d $db_name -f /tmp/sample_utilisateurs_schema.sql &>> install_db.log
export PGPASSWORD=$user_pg_pass;psql -h localhost -U $user_pg -d $db_name -f /tmp/sample_layers_schema.sql &>> install_db.log
export PGPASSWORD=$user_pg_pass;psql -h localhost -U $user_pg -d $db_name -f /tmp/sample_main_schema.sql &>> install_db.log