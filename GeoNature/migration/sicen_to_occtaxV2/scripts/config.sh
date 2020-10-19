# DESC: check and init
# ARGS: NONE
# OUTS: 0 if true
function init_config {

    if [ ! -f "${root_dir}/settings.ini" ] ; then
        exitScript "Le fichier ${root_dir}/settings.ini n'existe pas, veuillez le créer (prendre exemple ${root_dir}/settings.ini.sample sur ) et le renseigner \
        Veuillez le créer (prendre exemple ${root_dir}/settings.ini.sample sur ) et le renseigner" 2;
    fi

    if grep xxxx "${root_dir}/settings.ini" ; then
        exitScript "Veuillez renseigner le fichier ${root_dir}/settings.ini" 2;
    fi


    # source settings.ini

    source ${root_dir}/settings.ini
    export PGPASSWORD=${user_pg_pass};


    # cmd options

    if [ -n "${db_oo_name_opt}" ] ; then
        db_oo_name="${db_oo_name_opt}"
    fi

    if [ -n "${db_gn_name_opt}" ] ; then
        db_gn_name="${db_gn_name_opt}"
    fi


    # pour les fichiers logs (indexés avec ${db_oo_name})
    
    export sql_log_file="${log_dir}/sql_${db_oo_name}.log"
    export restore_oo_log_file="${log_dir}/restore_oo_${db_oo_name}.log"


    # pour les medias

    export media_in_dir=${root_dir}/media/in/${db_oo_name}
    export media_patch_dir=${root_dir}/media/patch/${db_oo_name}
    export media_test_dir=${root_dir}/media/test/${db_oo_name}
    export media_out_dir=${root_dir}/media/out/medias_${db_oo_name}


    rm -f ${sql_log_file} ${restore_oo_log_file}

    # check if GN database exists

    if ! database_exists ${db_gn_name} ;  then 
        exitScript "La base GN ${db_gn_name} n existe pas, ou les paramêtres de connexion sont erronés." 2
    fi


    # check if OO database exists or if option -f (--obsocc-dump-file) is set

    if ! database_exists ${db_oo_name} && [ -z "${oo_dump_file}" ] ;  then 
        exitScript "La base OO ${db_oo_name} n existe pas, veuillez préciser le fichier d une sauvegarde de cette base. avec l'option -f=<file_path>" 2
    fi

    export exec_sql="export PGPASSWORD=${user_pg_pass};psql -h ${db_host}  -p ${db_port} -U ${user_pg}"

    log SQL "La configuration est valide"

    return 0
}

