set -x
parc=$1

export BASE_DIR=$(readlink -e "${0%/*}")/..
. $BASE_DIR/utils.sh
init_config $parc

sql_access_file=$BASE_DIR/$parc/access/schema_access.sql
schema=access

echo "DROP SCHEMA IF EXISTS ${schema} CASCADE;
CREATE SCHEMA ${schema};" > ${sql_access_file}

# Insertion des données access (nécessite csv kit)

for file in access/*.xlsx
do
    # on change les xlsx en csv
    echo $file
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
    sed \
        -e 's/"//g' \
        -e 's/BOOLEAN/VARCHAR/g' \
        -e 's/DECIMAL/VARCHAR/g' \
        -e 's/DATETIME/VARCHAR/g' \
        -e 's/[éêè]/e/g' \
        -e 's/°/o/g' \
        -e 's/-/_/g' \
        -e 's/ /_/g' \
        -e 's/_VARCHAR/ VARCHAR/g' \
        -e 's/_DATE/ DATE/g' \
        -e 's/,_/,/g' \
        -e 's/CREATE_TABLE_/CREATE TABLE /g' \
        -e 's/_(/git(/g' \
        -e 's/+/_plus/g' >> ${sql_access_file};

    # on met toutes les commandes COPY dans sql_access_file
    echo "COPY ${schema}.${table} FROM '/tmp/${table}.csv' CSV HEADER;" >> ${sql_access_file};
done

# copie des csv dans /tmp
cp access/*.csv /tmp/.

# insertion des données acces en base 
$psqla -f $sql_access_file

