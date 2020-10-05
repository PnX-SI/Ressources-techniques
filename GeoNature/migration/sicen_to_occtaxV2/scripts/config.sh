# DESC: check and init
# ARGS: NONE
# OUTS: 0 if true
function init_config {

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


    # check if GN database exists
    if ! database_exists ${db_gn_name} ;  then 
        echo La base GN ${db_gn_name} n existe pas, ou les paramêtre de connexion sont erronés.
        return 1
    fi

    # check if OO database exists or if option -f (--obsocc-dump-file) is set
    if ! database_exists ${db_oo_name} && [ -z "${obsocc_dump_file}" ] ;  then 
        echo "La base OO ${db_oo_name} n existe pas, veuillez préciser le fichier d une sauvegarde de cette base. avec l'option -f=<file_path>"
        return 1
    fi

    echo La configuration est valide

    return 0
}

