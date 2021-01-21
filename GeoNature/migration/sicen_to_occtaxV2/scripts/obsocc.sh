# DESC : Restore bdd gn
# ARGS: base_path: path to gn dump file
# OUTS: None
function import_bd_gn() {
    rm -f ${restore_gn_log_file}

    gn_dump_file=$1

    # test if db exist return
    if database_exists "${db_gn_name}"; then
        log RESTORE "La base de données GN ${db_gn_name} existe déjà." 
        return 0
    fi

    if [[ $# -lt 1 ]]; then
        exitScript '<dump file> is required for import_bd_obsocc()' 2
    fi


    if [ ! -f ${gn_dump_file} ] ; then 

        exitScript "Le fichier d'import pour la base OO ${gn_dump_file} n'existe pas" 2
    fi

    log RESTORE "Restauration de la base de données GN:  ${db_gn_name}." 


    # Create DB
    log RESTORE "Creation de la base ${d_gn_name}"
    export PGPASSWORD=${user_pg_pass};psql -h ${db_host}  -p ${db_port} -U ${user_pg} -d postgres \
        -c "CREATE DATABASE ${db_gn_name}" \
        &>> ${restore_gn_log_file}
    

    # extensions
    log RESTORE "Creation des extensions"
    export PGPASSWORD=${user_pg_pass};psql -h ${db_host}  -p ${db_port} -U ${user_pg} -d ${db_gn_name} \
        -c "CREATE EXTENSION IF NOT EXISTS postgis" \
        &>> ${restore_gn_log_file}
    
    # ??? postgis-raster test si postgis 3 ou le faire dans tous les cas ?
#    export PGPASSWORD=${user_pg_pass};psql -h ${db_host}  -p ${db_port} -U ${user_pg} -d ${db_gn_name} \
#        -c "CREATE EXTENSION IF NOT EXISTS postgis_raster" \
#       &>> ${restore_gn_log_file}

    export PGPASSWORD=${user_pg_pass};psql -h ${db_host}  -p ${db_port} -U ${user_pg} -d ${db_gn_name} \
        -c 'CREATE EXTENSION IF NOT EXISTS "uuid-ossp"' \
        &>> ${restore_gn_log_file}


    # retore dump into ${db_gn_name}
    log RESTORE "Restauration depuis le fichier ${gn_dump_file} (patienter)"
    export PGPASSWORD=${user_pg_pass}; \
        pg_restore  -h ${db_host} -p ${db_port} --role=${user_pg} --no-owner --no-acl -U ${user_pg} \
        -d ${db_gn_name} ${gn_dump_file} \
        &>> ${restore_gn_log_file}

    # Affichage des erreurs (ou test sur l'extence des schemas???
    err=$(grep ERR ${restore_gn_log_file})

    if [ -n "${err}" ] ; then 
        log RESTORE "Il y a eu des erreurs durant la restauratio de la bdd GN ${db_gn_name}"
        log RESTORE "Il peut s'agir d'erreurs mineures qui ne vont pas perturber la suite des opérations"
        log RESTORE "Voir le fichier ${restore_gn_log_file} pour plus d'informations"
    fi

    return 0

}

# DESC: Restore bdd obsocc
# ARGS: base_path: path to obsocc dump file
# OUTS: None
function import_bd_obsocc() {

    rm -f ${restore_oo_log_file}

    oo_dump_file=$1

    # test if db exist return
    if database_exists "${db_oo_name}"; then
        log RESTORE "La base de données OO ${db_oo_name} existe déjà." 
        return 0
    fi

    if [[ $# -lt 1 ]]; then
        exitScript '<dump file> is required for import_bd_obsocc()' 2
    fi


    if [ ! -f ${oo_dump_file} ] ; then 
        exitScript "Le fichier d'import pour la base OO ${oo_dump_file} n'existe pas" 2
    fi

    log RESTORE "Restauration de la base de données OBSOCC:  ${db_oo_name}." 


    # Create DB
    log RESTORE "Creation de la base ${d_oo_name}"
    export PGPASSWORD=${user_pg_pass};psql -h ${db_host}  -p ${db_port} -U ${user_pg} -d postgres \
        -c "CREATE DATABASE ${db_oo_name}" \
        &>> ${restore_oo_log_file}
    

    # extensions
    log RESTORE "Creation des extensions"
    export PGPASSWORD=${user_pg_pass};psql -h ${db_host}  -p ${db_port} -U ${user_pg} -d ${db_oo_name} \
        -c "CREATE EXTENSION IF NOT EXISTS postgis" \
        &>> ${restore_oo_log_file}
    
    # ??? postgis-raster test si postgis 3 ou le faire dans tous les cas ?
#    export PGPASSWORD=${user_pg_pass};psql -h ${db_host}  -p ${db_port} -U ${user_pg} -d ${db_oo_name} \
#        -c "CREATE EXTENSION IF NOT EXISTS postgis_raster" \
#       &>> ${restore_oo_log_file}

    export PGPASSWORD=${user_pg_pass};psql -h ${db_host}  -p ${db_port} -U ${user_pg} -d ${db_oo_name} \
        -c 'CREATE EXTENSION IF NOT EXISTS "uuid-ossp"' \
        &>> ${restore_oo_log_file}


    # retore dump into ${db_oo_name}
    log RESTORE "Restauration depuis le fichier ${oo_dump_file} (patienter)"
    export PGPASSWORD=${user_pg_pass}; \
        pg_restore  -h ${db_host} -p ${db_port} --role=${user_pg} --no-owner --no-acl -U ${user_pg} \
        -d ${db_oo_name} ${oo_dump_file} \
        &>> ${restore_oo_log_file}

    # Affichage des erreurs (ou test sur l'extence des schemas???
    err=$(grep ERR ${restore_oo_log_file})

    if [ -n "${err}" ] ; then 
        log RESTORE "Il y a eu des erreurs durant la restauratio de la bdd OO ${db_oo_name}"
        log RESTORE "Il peut s'agir d'erreurs mineures qui ne vont pas perturber la suite des opérations"
        log RESTORE "Voir le fichier ${restore_oo_log_file} pour plus d'informations"
    fi

    return 0
}

function clean_data() {
    if [ -n "${clean}" ]; then 
        # create data users, organisms
        exec_sql_file ${db_gn_name} ${root_dir}/data/clean.sql "Suppression des données précédentes"\
            "-v db_oo_name=${db_oo_name}"
    # resume

    fi
}


# DESC: Create and fill OO schema export_oo
# ARGS: NONE
# OUTS: NONE
function create_export_oo() {

    # (dev) drop export_oo
    if [ -n "${drop_export_oo}" ]; then
        log SQL "suppression du shema OO export_oo"

        # drop schema OO export_oo
        export PGPASSWORD=${user_pg_pass};psql -h ${db_host}  -p ${db_port} -U ${user_pg} -d ${db_oo_name} -c \
            "DROP SCHEMA IF EXISTS export_oo CASCADE" \
            &>> ${sql_log_file}
    fi


    if schema_exists ${db_oo_name} export_oo; then
        log SQL "le shema existe déjà"
        return 0
    fi

    export PGPASSWORD=${user_pg_pass};psql -h ${db_host}  -p ${db_port} -U ${user_pg} -d ${db_oo_name} -c \
            "CREATE SCHEMA export_oo" \
            &>> ${sql_log_file}

    # create data users, organisms
    exec_sql_file ${db_oo_name} ${root_dir}/data/export_oo/user.sql "Personne Organismes"\
        "-v db_oo_name=${db_oo_name}"


    # create schema OO export_oo
    exec_sql_file ${db_oo_name} ${root_dir}/data/export_oo/oo_data.sql "Ajout des tables dans le schema export_oo (patienter)" "-v limit=${limit}"


    # create cor_etude_protocol_dataset (need view cd nom valid)
    exec_sql_file ${db_oo_name} ${root_dir}/data/export_oo/jdd.sql "Correspondance JDD études protocoles"


    return 0

}

function create_synonymes() {
    exec_sql_file ${db_gn_name} ${root_dir}/data/export_oo/synonyme.sql "synonymes"
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

    log SQL "FDW établi"

    # Synonymes
    exec_sql_file ${db_gn_name} ${root_dir}/data/export_oo/synonyme.sql "synonymes"

    # vue cd nom valid
    exec_sql_file ${db_gn_name} ${root_dir}/data/export_oo/views.sql "Vue observation cd nom valid" "-v db_oo_name=${db_oo_name}"

}


# DESC: apply patch for jdd (create a jdd and set it for all line in cor_etude_module_dataset)
# ARGS: NONE
# OUTS: NONE
function patch_jdd() {
    
    test_patch "JDD_TEST" && \
        exec_sql_file ${db_gn_name} ${root_dir}/data/patch/jdd_test.sql \
        "Patch jdd test" \
        "-v db_oo_name=${db_oo_name}" && \
        return 0

    test_patch "JDD_EPO" && \
        exec_sql_file ${db_gn_name} ${root_dir}/data/patch/jdd_epo.sql\
        "Patch jdd ca=etude jdd=protocole"\
        "-v db_oo_name=${db_oo_name} -v ca_field_name=nom_etude -v jdd_field_name=libelle_protocole" && \
        return 0

    test_patch "JDD_PEO" && \
        exec_sql_file ${db_gn_name} ${root_dir}/data/patch/jdd_epo.sql\
        "Patch jdd ca=etude jdd=protocole"\
        "-v db_oo_name=${db_oo_name} -v jdd_field_name=nom_etude -v ca_field_name=libelle_protocole" && \
        return 0

    test_patch "JDD_EP" && \
        exec_sql_file ${db_gn_name} ${root_dir}/data/patch/jdd_ep.sql\
        "Patch jdd ca=etude jdd=protocole"\
        "-v db_oo_name=${db_oo_name} -v ca_field_name=nom_etude -v jdd_field_name=libelle_protocole" && \
        return 0

    test_patch "JDD_PE" && \
        exec_sql_file ${db_gn_name} ${root_dir}/data/patch/jdd_ep.sql\
        "Patch jdd ca=etude jdd=protocole"\
        "-v db_oo_name=${db_oo_name} -v jdd_field_name=nom_etude -v ca_field_name=libelle_protocole" && \
        return 0




}

function patch_tax() {

    # ici on copie dans le tax ref les taxon qui ne sont pas dans la nouvelle version et dont on ne donne pas de synonyme
    log SQL "Patch tax"
        exec_sql_file ${db_gn_name} ${root_dir}/data/patch/taxonomie.sql\
        "Patch taxonomie ajout des cd_nom manquants"

}


function patch_media() {

    log SQL "Patch media"


    res_media_oo=$(psql -tA -h ${db_host}  -p ${db_port} -U ${user_pg} -d ${db_gn_name} \
            -c "SELECT TRANSLATE(url_photo,  'çéèî -(),''', 'ceei______') FROM export_oo.saisie_observation WHERE url_photo IS NOT NULL"
            &>> ${sql_log_file})


    rm -rf ${media_patch_dir}
    mkdir -p ${media_patch_dir}


    # patch create dir (wo patch copy dir to medias)
    for file_name in ${res_media_oo}; do
        dir_name=${file_name}
        mkdir -p ${media_patch_dir}/$(dirname ${file_name})
        touch ${media_patch_dir}/${file_name}
    done

    # clean_media_file_name

    export media_dir=${media_patch_dir}

}




# DESC: insert_data from GN.export_oo INTO GN
# ARGS: NONE
# OUTS: NONE
function insert_data() {

    exec_sql_file ${db_gn_name} ${root_dir}/data/insert/before_insert.sql "Pre - insert"
    # pour prendre en compte les champs ajoutés dans before_insert on refait les vues
    exec_sql_file ${db_gn_name} ${root_dir}/data/export_oo/views.sql "Vue observation cd nom valid" "-v db_oo_name=${db_oo_name}"
    exec_sql_file ${db_gn_name} ${root_dir}/data/insert/user.sql "Utilisateurs, organismes" "-v db_oo_name=${db_oo_name}"
    insert_media
    exec_sql_file ${db_gn_name} ${root_dir}/data/insert/releve.sql "Relevés (patienter)" "-v db_oo_name=${db_oo_name} -v srid=${srid}"
    exec_sql_file ${db_gn_name} ${root_dir}/data/insert/occurrence.sql "Occurrences (patienter)"
    exec_sql_file ${db_gn_name} ${root_dir}/data/insert/counting.sql "Dénombrement (patienter)"
    exec_sql_file ${db_gn_name} ${root_dir}/data/insert/synthese.sql "Synthese (patienter)" 
    exec_sql_file ${db_gn_name} ${root_dir}/data/insert/validation.sql "Validation (patienter)" 
    exec_sql_file ${db_gn_name} ${root_dir}/data/insert/cor_synthese.sql "Cor - Synthese (patienter)" 
    exec_sql_file ${db_gn_name} ${root_dir}/data/insert/after_insert.sql "After - insert" 
    exec_sql_file ${db_gn_name} ${root_dir}/data/insert/taxlist.sql "Update VM taxons Occtax" 

}


function initial_data {
    if ! table_exists ${db_gn_name} export_oo saisie_observation; then
        return 
    fi

    psql  -h ${db_host}  -p ${db_port} -U ${user_pg} -d ${db_oo_name} \
        -f ${root_dir}/data/initial_data.sql

}

function resume() {

    psql -h ${db_host}  -p ${db_port} -U ${user_pg} -d ${db_oo_name} \
        -f ${root_dir}/data/initial_data.sql


    if ! table_exists ${db_gn_name} export_oo saisie_observation; then
        return 
    fi

    psql  -h ${db_host}  -p ${db_port} -U ${user_pg} -d ${db_gn_name} \
        -f ${root_dir}/data/resume.sql

}

function insert_media() {

if [ ! -n "${media_dir}" ]; then 
    return 0
fi


# patch create media

mkdir -p ${media_in_dir}
rm -rf ${media_in_dir}
cp -rf ${media_dir} ${media_in_dir}

# clean_media_file_name

rm -rf ${media_out_dir}
mkdir -p ${media_out_dir}


# insertion des medias en base

exec_sql_file ${db_gn_name} ${root_dir}/data/insert/media.sql "Ajout des Medias en base"

# SQL + AWK + BASH (TODO SQL + BASH ??)

res_media_copy=$(psql -tA -R";" -h ${db_host}  -p ${db_port} -U ${user_pg} -d ${db_gn_name} \
        -c "SELECT TRANSLATE(url_photo,  'çéèî -(),''', 'ceei______'), media_path FROM gn_commons.t_medias WHERE url_photo IS NOT NULL"
        &>> ${sql_log_file})
echo ${res_media_copy} | sed -e "s/;/\n/g" -e "s/|/ /g" \
    | awk '{
        printf("mkdir -p $(dirname %s/%s)\n cp %s/%s %s/%s\n", "'${media_out_dir}'", $2, "'${media_in_dir}'", $1, "'${media_out_dir}'", $2)}' \
 | bash

}