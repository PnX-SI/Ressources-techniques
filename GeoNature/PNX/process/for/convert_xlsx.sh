set -e

parc=$1

# on met la config de la foret
cd ..
. ./set_config.sh $parc

# retour dans le repertoire courant
cd $parc

sql_access_file=data/schema_access.sql
schema=iaf

echo "DROP SCHEMA IF EXISTS ${schema} CASCADE;
CREATE SCHEMA ${schema};" > ${sql_access_file}

# Insertion des données access (nécessite csv kit)

for file in access/*.xlsx
do
    # on change les xlsx en csv
    csv_out=${file%%.xlsx}.csv
    rm -f $csv_out
    if [ ! -f ${csv_out} ]
        then 
        in2csv $file > $csv_out
    fi
    table=${file%%.xlsx}
    table=${table##*/}
    
    # Post process des csv sed

    # commande pour creer la table depuis le csv 
    # mis dans sql_access_file pour le jouer ensuite
    # cat ${csv_out} | \
    head -n 20 ${csv_out} | \
    csvsql --no-constraints --tables ${schema}.${table} | \

    # correction BOOLEAN -> VARCHAR et DECIMAL -> VARCHAR pour les champs mal matchés
    sed -e 's/"//g' -e 's/BOOLEAN/VARCHAR/g' -e 's/DECIMAL/VARCHAR/g' -e 's/-/_/g' >> ${sql_access_file};

    # on met toutes les commandes COPY dans sql_access_file
    echo "COPY ${schema}.${table} FROM '/tmp/${table}.csv' CSV HEADER;" >> ${sql_file};
done

# copie des csv dans /tmp
cp access/*.csv /tmp/.

# insertion des données acces en base 
$psqla -f $sql_access_file

