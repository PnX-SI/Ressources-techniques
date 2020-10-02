

# DESC: Restore bdd obsocc
# ARGS: base_path: path to obsocc dump file
# OUTS: None
function import_bd_obsocc() {

    if [[ $# -lt 1 ]]; then
        exitScript 'Missing required argument to getRepositoryOptions()!' 2
    fi

    obsocc_dump_file=$1

    # test if db exist return
    if database_exists "${db_oo_name}"; then
        echo La base de données OBSOCC:  ${db_oo_name} existe déjà. 
        return 0
    fi

    echo La base de données OBSOCC:  ${db_oo_name} n existe pas. 


    # Create DB & extentions
    export PGPASSWORD=${user_pg_pass};psql -h ${db_host}  -p ${db_port} -U ${user_pg} -d postgres -c "CREATE DATABASE ${db_oo_name}";
    export PGPASSWORD=${user_pg_pass};psql -h ${db_host}  -p ${db_port} -U ${user_pg} -d ${db_oo_name} -c "CREATE EXTENSION IF NOT EXISTS postgis";
    # ?? postgis-raster
    export PGPASSWORD=${user_pg_pass};psql -h ${db_host}  -p ${db_port} -U ${user_pg} -d ${db_oo_name} -c 'CREATE EXTENSION IF NOT EXISTS "uuid-ossp"';

    # retore dump into ${db_oo_name}
    export PGPASSWORD=${user_pg_pass};pg_restore  -h ${db_host} -p ${db_port} --role=${user_pg} --no-owner --no-acl -U ${user_pg} -d ${db_oo_name} $obsocc_dump_file

}


# DESC: drop schema export_gn
# ARGS: NONE
# OUTS: NONE
function drop_export_gn() {

    echo "suppression du shema OO export_gn"

    # drop schema OO export_gn
    export PGPASSWORD=${user_pg_pass};psql -h ${db_host}  -p ${db_port} -U ${user_pg} -d ${db_oo_name} -c \
        "DROP SCHEMA IF EXISTS export_gn CASCADE" \
        &>> ${log_dir}/sql.log

}


# DESC: Create and fill OO schema export_gn
# ARGS: NONE
# OUTS: NONE
function create_export_gn() {

    if schema_exists ${db_oo_name} export_gn; then
        echo "OO export_gn : suppression"
        return 0
    fi

    # create schema OO export_gn
    echo "OO export_gn : creation"
    export PGPASSWORD=${user_pg_pass};psql -h ${db_host}  -p ${db_port} -U ${user_pg} -d ${db_oo_name} -c \
        "CREATE SCHEMA export_gn" \
        &>> ${log_dir}/sql.log


    # create data users, organisms
    echo "OO export_gn : add users, organism"
    export PGPASSWORD=${user_pg_pass};psql -h ${db_host}  -p ${db_port} -U ${user_pg} -d ${db_oo_name} \
        -f ${root_dir}/data/export_gn/user.sql \
        &>> ${log_dir}/sql.log

    # create cor_etude_protocol_dataset
    echo "OO export_gn : add cor_jdd"
    export PGPASSWORD=${user_pg_pass};psql -h ${db_host}  -p ${db_port} -U ${user_pg} -d ${db_oo_name} \
        -f ${root_dir}/data/export_gn/jdd.sql \
        &>> ${log_dir}/sql.log
    # export PGPASSWORD=${user_pg_pass};psql -h ${db_host}  -p ${db_port} -U ${user_pg} -d ${db_oo_name} \ 
    #     -f ${root_dir}/data/export_gn/jdd.sql \
    #     &>> ${log_dir}/sql.log

}


# DESC: create fdw schema GN import_oo from OO export_gn
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
        &>> ${log_dir}/sql.log

    echo FDW établi

}


# DESC: apply patch for jdd (create a jdd and set it for all line in cor_etude_module_dataset)
# ARGS: NONE
# OUTS: NONE
function apply_patch_jdd() {

    echo "apply patch jdd"

    export PGPASSWORD=${user_pg_pass}; \
    psql -h ${db_host}  -p ${db_port} -U ${user_pg} -d ${db_gn_name} \
        -f ${root_dir}/data/patch/jdd.sql \
        &>> ${log_dir}/sql.log

}


# DESC: test if GN import_oo.cor_etude_module_dataset exists
#       and if id_dataset are not NULL
# ARGS: NONE
# OUTS: 0 if true
function test_import_gn_cor_etude_protocol_dataset() {

    if ! table_exists ${db_gn_name} import_oo cor_etude_protocole_dataset; then
        echo La table GN import_oo cor_etude_protocole_dataset n existe pas
        return 1
    fi

    export PGPASSWORD=${user_pg_pass};res=$(psql -tA -R";" -h ${db_host}  -p ${db_port} -U ${user_pg} -d ${db_gn_name} -c "SELECT libelle_protocole, nom_etude Etude FROM import_oo.cor_etude_protocole_dataset WHERE id_dataset IS NULL;")

    if [ -n "$res" ] ; then 
        echo Dans la table import_oo.cor_etude_protocole_dataset, il n y a pas de JDD associé pour les ligne suivantes
        echo
        echo $res | sed -e "s/;/\n/g" -e "s/|/\t\t/g" | sort
        return 1
    fi

    echo " import_oo.cor_etude_protocole_dataset OK"

    return 0
}

# DESC: insert_data from GN.import_oo INTO GN
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
            &>> ${log_dir}/sql.log
    done

}