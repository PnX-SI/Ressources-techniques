

# DESC: Restore bdd obsocc
# ARGS: base_path: path to obsocc dump file
# OUTS: None
function import_bd_obsocc() {

    rm -f ${export_oo_log_file}


    if [[ $# -lt 1 ]]; then
        exitScript '<dump file> is required for import_bd_obsocc()' 2
    fi

    obsocc_dump_file=$1

    # test if db exist return
    if database_exists "${db_oo_name}"; then
        log RESTORE "Restore OO : la base de données OO ${db_oo_name} existe déjà." 
        return 0
    fi

    if [ ! -f ${obsocc_dump_file} ] ; then 

        exitScript "Le fichier d'import pour la base OO ${obsocc_dump_file} n'existe pas" 2
    fi

    log RESTORE "Restauration de la ase de données OBSOCC:  ${db_oo_name}." 


    # Create DB
    log RESTORE "Creation de la base ${d_oo_name}"
    export PGPASSWORD=${user_pg_pass};psql -h ${db_host}  -p ${db_port} -U ${user_pg} -d postgres \
        -c "CREATE DATABASE ${db_oo_name}" \
        &>> ${export_oo_log_file}
    

    # extensions
    log RESTORE "Creation des extensions"
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
    log RESTORE "Restauration depuis le fichier ${obsocc_dump_file} (patienter)"
    export PGPASSWORD=${user_pg_pass}; \
        pg_restore  -h ${db_host} -p ${db_port} --role=${user_pg} --no-owner --no-acl -U ${user_pg} \
        -d ${db_oo_name} ${obsocc_dump_file} \
        &>> ${export_oo_log_file}

    # Affichage des erreurs (ou test sur l'extence des schemas???

    err=$(grep ERR ${export_oo_log_file})

    if [ -n "${err}" ] ; then 
        log RESTORE "Il y a eu des erreurs durant la restauratio de la bdd OO ${db_oo_name}"
        log RESTORE "Il peut s'agir d'erreurs mineures qui ne vont pas perturber la suite des opérations"
        log RESTORE "Voir le fichier ${export_oo_log_file} pour plus d'informations"
    fi

    return 0
}


# DESC: drop schema export_oo
# ARGS: NONE
# OUTS: NONE
function drop_export_oo() {

    log SQL "suppression du shema OO export_oo"

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
        log SQL "OO export_oo : le shema existe déjà"
        return 0
    fi

    # create schema OO export_oo
    log SQL "OO export_oo : creation"
    export PGPASSWORD=${user_pg_pass};psql -h ${db_host}  -p ${db_port} -U ${user_pg} -d ${db_oo_name} -c \
        "CREATE SCHEMA export_oo" \
        &>> ${sql_log_file}


    # create data users, organisms
    log SQL "OO export_oo : add users, organism"
    export PGPASSWORD=${user_pg_pass};psql -h ${db_host}  -p ${db_port} -U ${user_pg} -d ${db_oo_name} \
        -f ${root_dir}/data/export_oo/user.sql \
        &>> ${sql_log_file}
    checkError ${sql_log_file} "export_oo : Problème avec le fichier ${root_dir}/data/export_oo/user.sql"



    # create cor_etude_protocol_dataset
    log SQL "OO export_oo : add cor_jdd"
    export PGPASSWORD=${user_pg_pass};psql -h ${db_host}  -p ${db_port} -U ${user_pg} -d ${db_oo_name} \
        -f ${root_dir}/data/export_oo/jdd.sql \
        &>> ${sql_log_file}
    checkError ${sql_log_file} "export_oo : Problème avec le fichier ${root_dir}/data/export_oo/jdd.sql"

    log SQL "Prepare Data"

    # synonymes
    cp -rf ${root_dir}/data/csv/ /tmp/.
    log SQL "OO export_oo : create synonyme for nomenclature"
    export PGPASSWORD=${user_pg_pass};psql -h ${db_host}  -p ${db_port} -U ${user_pg} \
        -d ${db_oo_name} -f ${root_dir}/data/export_oo/synonyme.sql \
        &>> ${sql_log_file}
    checkError ${sql_log_file} "Problème à la creation de synomymes pour occtax"


    # create cor_etude_protocol_dataset
    log SQL "OO export_oo : create tables for OCCTAX revele occurrence and couting (patienter)"
    export PGPASSWORD=${user_pg_pass};psql -h ${db_host}  -p ${db_port} -U ${user_pg} \
        -d ${db_oo_name} -f ${root_dir}/data/export_oo/occtax.sql \
        &>> ${sql_log_file}
    checkError ${sql_log_file} "Problème à la creation de table pour occtax"


}


# DESC: create fdw schema GN export_oo from OO export_oo
# ARGS: NONE
# OUTS: NONE
function create_fdw_obsocc() {

    log SQL "Creation du lien FDW"
    export PGPASSWORD=${user_pg_pass}; \
    psql -h ${db_host}  -p ${db_port} -U ${user_pg} -d ${db_gn_name} \
        -v db_oo_name=$db_oo_name \
        -v db_host=$db_host \
        -v db_port=$db_port \
        -v user_pg_pass=$user_pg_pass \
        -v user_pg=$user_pg \
        -f ${root_dir}/data/fdw.sql \
        &>> ${sql_log_file}

    checkError ${sql_log_file} "Problème à la creation du fwd"


    log SQL OO GN: FDW établi

}


# DESC: apply patch for jdd (create a jdd and set it for all line in cor_etude_module_dataset)
# ARGS: NONE
# OUTS: NONE
function apply_patch_jdd() {

    log SQL "GN: apply patch jdd"

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
        log SQL "La table GN export_oo cor_dataset n existe pas"
        exitScript 'La table GN export_oo cor_dataset n existe pas' 2
    fi

    export PGPASSWORD=${user_pg_pass};\
        res=$(psql -tA -R";" -h ${db_host}  -p ${db_port} -U ${user_pg} -d ${db_gn_name} -c "SELECT libelle_protocole, nom_etude, nb_row, nb_by_protocole FROM export_oo.cor_dataset WHERE id_dataset IS NULL;")

    if [ -n "$res" ] ; then 
        echo "Dans la table export_oo.cor_dataset, il n y a pas de JDD associé pour les ligne suivantes"
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
        exitScript "Veuillez completer la table export_oo.cor_dataset avant de continuer" 2 
        return 1
    fi

    log SQL "GN: export_oo.cor_dataset OK"

    return 0
}

# DESC: insert_data from GN.export_oo INTO GN
# ARGS: NONE
# OUTS: NONE
function insert_data() {

    log SQL "Insert Data"

    file_names=" \
        user.sql
    "
    for file_name in $(echo ${file_names})
    do
        log SQL "process file ${file_name}"
        export PGPASSWORD=${user_pg_pass};psql -h ${db_host}  -p ${db_port} -U ${user_pg} -d ${db_gn_name} \
            -f ${root_dir}/data/insert/${file_name} \
            &>> ${sql_log_file}
        checkError ${sql_log_file} "Insert data : Problème avec le fichier ${file_name}"
        
    done

}