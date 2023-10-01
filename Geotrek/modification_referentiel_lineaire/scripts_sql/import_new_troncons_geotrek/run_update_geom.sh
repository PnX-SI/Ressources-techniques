#!/bin/bash

# ########################
# Lancement des commandes permettant de mettre à jour la geometrie de core_path
# ########################

. settings.ini

 
echo "Execution du script 1.1_maj_core_path_trigger !!! opération très longue"
export PGPASSWORD=$PG_PASS;psql -t -h $HOST -U $PG_USER -d $DATABASE_NAME  \
    -c "CREATE TABLE tmp_core_path_updated AS SELECT id FROM core_path;"

nb_core_path=(`export PGPASSWORD=$PG_PASS;psql -t -h $HOST -U $PG_USER -d $DATABASE_NAME  \
    -c "SELECT count(*) FROM tmp_core_path_updated;"`)

nb_decile=$(( (nb_core_path / 1000) + 1 ))

for (( offset=0; offset<=$nb_core_path; offset=offset+$nb_decile ))
do
    NOW=`date '+%F %H:%M:%S'`;
    echo "limit $nb_decile offset $offset -> Start time ${NOW}"

    sed "s|MY_LIMIT|${nb_decile}|g"  1.1_maj_core_path_trigger.sql >  1.1_maj_core_path_trigger_var.sql
    sed -i "s|MY_OFFSET|${offset}|g"  1.1_maj_core_path_trigger_var.sql
    # export PGPASSWORD=$PG_PASS;psql -h $HOST -U $PG_USER -d $DATABASE_NAME -v l=$nb_decile -v o=$offset -f 1.1_maj_core_path_trigger_var.sql
done

export PGPASSWORD=$PG_PASS;psql -t -h $HOST -U $PG_USER -d $DATABASE_NAME  \
    -c "DROP TABLE tmp_core_path_updated;"

NOW=`date '+%F %H:%M:%S'`;
echo "FIN ${NOW}"
