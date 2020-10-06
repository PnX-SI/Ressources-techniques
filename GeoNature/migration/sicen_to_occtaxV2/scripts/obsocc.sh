

# DESC: Restore bdd obsocc
# ARGS: base_path: path to obsocc dump file
# OUTS: None
function import_bd_obsocc() {

    rm -f ${export_oo_log_file}


    if [[ $# -lt 1 ]]; then
        exitScript 'Missing required argument to getRepositoryOptions()!' 2
    fi

    obsocc_dump_file=$1

    # test if db exist return
    if database_exists "${db_oo_name}"; then
        echo Restore OO : la base de données OO ${db_oo_name} existe déjà. 
        return 0
    fi

    if [ ! -f ${obsocc_dump_file} ] ; then 
        echo "Le fichier ${obsocc_dump_file} n'existe pas"
        return 1
    fi

    echo Restauration de la base de données OBSOCC:  ${db_oo_name}. 


    # Create DB

    export PGPASSWORD=${user_pg_pass};psql -h ${db_host}  -p ${db_port} -U ${user_pg} -d postgres \
        -c "CREATE DATABASE ${db_oo_name}" \
        &>> ${export_oo_log_file}
    

    # extensions

    export PGPASSWORD=${user_pg_pass};psql -h ${db_host}  -p ${db_port} -U ${user_pg} -d ${db_oo_name} \
        -c "CREATE EXTENSION IF NOT EXISTS postgis" \
        &>> ${export_oo_log_file}
    
    # ??? postgis-raster test si postgis 3 ou le faire dans tous les cas ?
#    export PGPASSWORD=${user_pg_pass};psql -h ${db_host}  -p ${db_port} -U ${user_pg} -d ${db_oo_name} \
#        -c "CREATE EXTENSION IF NOT EXISTS postgis_raster" \
#       &>> ${export_oo_log_file}

    export PGPASSWORD=${user_pg_pass};psql -h ${db_host}  -p ${db_port} -U ${user_pg} -d ${db_oo_name} \
        -c 'CREATE EXTENSION IF NOT EXISTS "uuid-ossp"' \
        &>> ${export_oo_log_file}


    # retore dump into ${db_oo_name}

    export PGPASSWORD=${user_pg_pass}; \
        pg_restore  -h ${db_host} -p ${db_port} --role=${user_pg} --no-owner --no-acl -U ${user_pg} \
        -d ${db_oo_name} ${obsocc_dump_file} \
        &>> ${export_oo_log_file}

    # Affichage des erreurs (ou test sur l'extence des schemas???
    err=$(grep ERR ${export_oo_log_file})

    if [ -n ${err} ] ; then 
        echo "Il y a eu des erreurs durant la restauratio de la bdd OO ${db_oo_name}"
        echo "Il peu d'agir d'erreur mineure qui ne vont pas perturber la suite des opérations"
        echo "Voir le fichier ${export_oo_log_file} pour plus d'informations"
    fi

    return 0
}


# DESC: drop schema export_oo
# ARGS: NONE
# OUTS: NONE
function drop_export_oo() {

    echo "suppression du shema OO export_oo"

    # drop schema OO export_oo
    export PGPASSWORD=${user_pg_pass};psql -h ${db_host}  -p ${db_port} -U ${user_pg} -d ${db_oo_name} -c \
        "DROP SCHEMA IF EXISTS export_oo CASCADE" \
        &>> ${sql_log_file}

}


# DESC: Create and fill OO schema export_oo
# ARGS: NONE
# OUTS: NONE
function create_export_oo() {

    if schema_exists ${db_oo_name} export_oo; then
        echo "OO export_oo : le shema existe déjà"
        return 0
    fi

    # create schema OO export_oo
    echo "OO export_oo : creation"
    export PGPASSWORD=${user_pg_pass};psql -h ${db_host}  -p ${db_port} -U ${user_pg} -d ${db_oo_name} -c \
        "CREATE SCHEMA export_oo" \
        &>> ${sql_log_file}


    # create data users, organisms
    echo "OO export_oo : add users, organism"
    export PGPASSWORD=${user_pg_pass};psql -h ${db_host}  -p ${db_port} -U ${user_pg} -d ${db_oo_name} \
        -f ${root_dir}/data/export_oo/user.sql \
        &>> ${sql_log_file}

    # create cor_etude_protocol_dataset
    echo "OO export_oo : add cor_jdd"
    export PGPASSWORD=${user_pg_pass};psql -h ${db_host}  -p ${db_port} -U ${user_pg} -d ${db_oo_name} \
        -f ${root_dir}/data/export_oo/jdd.sql \
        &>> ${sql_log_file}
    # export PGPASSWORD=${user_pg_pass};psql -h ${db_host}  -p ${db_port} -U ${user_pg} -d ${db_oo_name} \ 
    #     -f ${root_dir}/data/export_oo/jdd.sql \
    #     &>> ${sql_log_file}

}


# DESC: create fdw schema GN export_oo from OO export_oo
# ARGS: NONE
# OUTS: NONE
function create_fdw_obsocc() {

    export PGPASSWORD=${user_pg_pass}; \
    psql -h ${db_host}  -p ${db_port} -U ${user_pg} -d ${db_gn_name} \
        -v db_oo_name=$db_oo_name \
        -v db_host=$db_host \
        -v db_port=$db_port \
        -v user_pg_pass=$user_pg_pass \
        -v user_pg=$user_pg \
        -f ${root_dir}/data/fdw.sql \
        &>> ${sql_log_file}

    echo OO GN: FDW établi

}


# DESC: apply patch for jdd (create a jdd and set it for all line in cor_etude_module_dataset)
# ARGS: NONE
# OUTS: NONE
function apply_patch_jdd() {

    echo "GN: apply patch jdd"

    export PGPASSWORD=${user_pg_pass}; \
    psql -h ${db_host}  -p ${db_port} -U ${user_pg} -d ${db_gn_name} \
        -f ${root_dir}/data/patch/jdd.sql \
        &>> ${sql_log_file}

}


# DESC: test if GN export_oo.cor_etude_module_dataset exists
#       and if id_dataset are not NULL
# ARGS: NONE
# OUTS: 0 if true
function test_cor_dataset() {

    if ! table_exists ${db_gn_name} export_oo cor_dataset; then
        echo La table GN export_oo cor_dataset n existe pas
        return 1
    fi

    export PGPASSWORD=${user_pg_pass};\
        res=$(psql -tA -R";" -h ${db_host}  -p ${db_port} -U ${user_pg} -d ${db_gn_name} -c "SELECT libelle_protocole, nom_etude, nb_row, nb_by_protocole FROM export_oo.cor_dataset WHERE id_dataset IS NULL;")

    if [ -n "$res" ] ; then 
        echo Dans la table export_oo.cor_dataset, il n y a pas de JDD associé pour les ligne suivantes
        echo
        echo $res | sed -e "s/;/\n/g" -e "s/|/\t/g" \
            | awk -F $'\t' '
            BEGIN { 
                protcole=""; printf "%-50s %-50s %20s\n","Protocole", "Etude", "Nombre de données"
            }
            {
                if ( $1!=protocole ) {printf "\n%-50s %-50s %20s\n",$1, "", "("$4")"};
                if ( $1!=protocole ) {protocole=$1};
                printf "%-50s %-50s %20s\n", "", $2, $3
            }'
        return 1
    fi

    echo "GN: export_oo.cor_dataset OK"

    return 0
}

# DESC: insert_data from GN.export_oo INTO GN
# ARGS: NONE
# OUTS: NONE
function insert_data() {

    file_names=" \
        user.sql
    "
    for file_name in $(echo ${file_names})
    do
        echo process file ${file_name}
        export PGPASSWORD=${user_pg_pass};psql -h ${db_host}  -p ${db_port} -U ${user_pg} -d ${db_gn_name} \
            -f ${root_dir}/data/insert/${file_name} \
            &>> ${sql_log_file}
    done

}