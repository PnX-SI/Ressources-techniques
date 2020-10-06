
#!/usr/bin/env bash
# Encoding : UTF-8
# Migrate GeoNature from v2.1.2 to v2.4.0
#
# Documentation : https://github.com/joelclems/install_gn
set -eo pipefail

# DESC: Usage help
# ARGS: None
# OUTS: None
function printScriptUsage() {
    cat << EOF
Usage: ./$(basename $BASH_SOURCE)[options]
     -h | --help: display this help
     -v | --verbose: display more infos
     -x | --debug: display debug script infos
     -f | --dump_file_path: path to obsocc dump file
     -d | --drop-export-gn: re-create export_oo schema
     -p | --apply-patch: apply patch for JDD (one for all)
     -g | --db-gn-name: GN database name
     -o | --db-oo-name: OO database name
     -c | --correct-oo: correct OO:saisie.saisie_observation geometry and doublons 
EOF
    exit 0
}

# DESC: Parameter parser
# ARGS: $@ (optional): Arguments provided to the script
# OUTS: Variables indicating command-line parameters and options
function parseScriptOptions() {
    # Transform long options to short ones
    for arg in "${@}"; do
        shift
        case "${arg}" in
            "--help") set -- "${@}" "-h" ;;
            "--verbose") set -- "${@}" "-v" ;;
            "--debug") set -- "${@}" "-x" ;;
            "--obscocc-dump-file") set -- "${@}" "-f" ;;
            "--drop-export-gn") set -- "${@}" "-d";; 
            "--apply-patch") set -- "${@}" "-p";; 
            "--db-oo-name")  set -- "${@}" "-o";;
            "--db-gn-name")  set -- "${@}" "-g";;
            "--correct-oo") set -- "${@}" "-c";;
            "--"*) exitScript "ERROR : parameter '${arg}' invalid ! Use -h option to know more." 1 ;;
            *) set -- "${@}" "${arg}"
        esac
    done

    while getopts "cdef:g:ho:pvx" option; do
        case "${option}" in
            "h") printScriptUsage ;;
            "v") readonly verbose=true ;;
            "x") readonly debug=true; set -x ;;
            "f") obsocc_dump_file="${OPTARG}" ;;
            "d") drop_export_oo=true ;;
            "p") apply_patch=true ;;
            "o") db_oo_name_opt="${OPTARG}" ;;
            "g") db_gn_name_opt="${OPTARG}" ;;
            "c") correct_oo=true ;;
            *) exitScript "ERROR : parameter invalid ! Use -h option to know more." 1 ;;
        esac
    done

    # if [ -z ${obsocc_dump_file} ]; then
    #     exitScript "Please enter path to obsocc dump file (option -p or --obsocc-dump-file) ! Use -h option to know more" 2
    # fi 
}

# DESC: Main control flow
# ARGS: $@ (optional): Arguments provided to the script
# OUTS: None
function main() {

    # init script
    file_names="utils.sh config.sh obsocc.sh"
    for file_name in ${file_names}; do
        source "$(dirname "${BASH_SOURCE[0]}")/scripts/${file_name}"
    done

    parseScriptOptions "${@}"
    initScript "${@}"

    # init files

    rm -f ${sql_log_file}
    rm -Rf ${tmp_dir}
    mkdir -p ${tmp_dir}
    cp -R ${root_dir}/data/csv /tmp/.


    # init config

    if ! init_config; then 
        return 1
    fi


    # import bd obsocc from dump file (if needed)

    if ! database_exists ${db_oo_name} ;  then
        ! import_bd_obsocc ${obsocc_dump_file} && return 1
    fi


    # correction geometrie, doublons

    if [ -n ${correct_oo} ] ; then
        echo "Correct OO"
        export PGPASSWORD=${user_pg_pass};psql -h ${db_host}  -p ${db_port} -U ${user_pg} -d ${db_oo_name} \
            -f ${root_dir}/data/post_restore_oo.sql \
            &>> ${export_oo_log_file}
    fi


    # test si la base OO est ok
    if ! schema_exists ${db_oo_name} md ; then
        echo "Le schema 00:md n'existe pas, il y a un  problème dans l'import de la base"
        echo "Veuillez supprimer la base ${db_oo_name} et relancer le script"
        echo "Voir le fichier ${export_oo_log_file} pour plus d'informations"
        return 1
    fi


    # (dev) drop i
    echo drop_export_oo ${drop_export_oo}
    if [ -n "${drop_export_oo}" ]; then
        drop_export_oo
    fi


    # create export_oo schema (data from OO pre-formated for GN)

    create_export_oo


    # fdw de OO:export_oo -> GN:export_oo

    create_fdw_obsocc


    # (dev) patch for JDD (1 CA and 1 JDD 'test' for each data)

    if [ -n "${apply_patch}" ] ;  then
        apply_patch_jdd
    fi

    # test if id_dataset is not NULL for each line of GN:export_oo.cor_dataset

    if ! test_cor_dataset ; then 
        return 1
    fi


    # Insert data into GN (occtax (??or synthese))
    
    # TODO
    # Ok pour user
    insert_data


    # print SQL ERROR

    grep ERR ${sql_log_file}

}

main "${@}"
