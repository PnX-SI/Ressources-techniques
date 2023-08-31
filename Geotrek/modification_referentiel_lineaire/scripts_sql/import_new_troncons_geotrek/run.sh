#!/bin/bash

# ########################
# Lancement des commandes permettant d'importer des données "nettoyées" dans core_path de geotrek
# ########################

. settings.ini

# # Import des données à intégrer
echo "Import des données dans core_path_wip_new -> OK done"
# # TODO rajouter test table core_path_wip_new est bien présente

# Script de MAJ des core_path
echo "Execution du script 1.0_maj_core_path.sql"
export PGPASSWORD=$PG_PASS;psql -h $HOST -U $PG_USER -d $DATABASE_NAME  -f 1.0_maj_core_path.sql

echo "Execution du script 1.1_maj_core_path_trigger !!! opération très longue"
export PGPASSWORD=$PG_PASS;psql -t -h $HOST -U $PG_USER -d $DATABASE_NAME  \
    -c "CREATE TABLE tmp_core_path_updated AS SELECT id FROM core_path WHERE date_update = (SELECT max(date_update) FROM core_path cp2 );"

nb_core_path=(`export PGPASSWORD=$PG_PASS;psql -t -h $HOST -U $PG_USER -d $DATABASE_NAME  \
    -c "SELECT count(*) FROM tmp_core_path_updated;"`)

nb_decile=$(( (nb_core_path / 10) + 1 ))

for (( offset=0; offset<=$nb_core_path; offset=offset+$nb_decile ))
do
    NOW=`date '+%F %H:%M:%S'`;
    echo "limit $nb_decile offset $offset -> Start time ${NOW}"

    sed "s|MY_LIMIT|${nb_decile}|g"  1.1_maj_core_path_trigger.sql >  1.1_maj_core_path_trigger_var.sql
    sed -i "s|MY_OFFSET|${offset}|g"  1.1_maj_core_path_trigger_var.sql
    # export PGPASSWORD=$PG_PASS;psql -h $HOST -U $PG_USER -d $DATABASE_NAME -f 1.1_maj_core_path_trigger_var.sql
done

export PGPASSWORD=$PG_PASS;psql -h $HOST -U $PG_USER -d $DATABASE_NAME -c "DROP TABLE tmp_core_path_updated;"

# Script de MAJ des core_pathaggregation
NOW=`date '+%F %H:%M:%S'`;
echo "Execution du script 2.0_maj_core_pathaggregation -> Start time ${NOW}"
export PGPASSWORD=$PG_PASS;psql -h $HOST -U $PG_USER -d $DATABASE_NAME  -f 2.0_maj_core_pathaggregation.sql


NOW=`date '+%F %H:%M:%S'`;
echo "Execution du script 2.1_maj_core_topology_trigger -> Start time ${NOW}"
export PGPASSWORD=$PG_PASS;psql -h $HOST -U $PG_USER -d $DATABASE_NAME  -f 2.1_maj_core_topology_trigger.sql

# # Nettoyage
rm 1.1_maj_core_path_trigger_var.sql

NOW=`date '+%F %H:%M:%S'`;
echo "FIN ${NOW}"
