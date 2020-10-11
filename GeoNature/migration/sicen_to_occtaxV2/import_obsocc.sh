
#!/usr/bin/env bash
# Encoding : UTF-8
# Migrate GeoNature from v2.1.2 to v2.4.0
#
# Documentation : https://github.com/joelclems/install_gn
set -o pipefail

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
     -p | --apply-patch: apply patch :
        TAX: for taxonomy (ignore invalid cd_nom)
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
            "--apply-patch-jdd") set -- "${@}" "-p";; 
            "--apply-patch-taxonomie") set -- "${@}" "-t";; 
            "--db-oo-name")  set -- "${@}" "-o";;
            "--db-gn-name")  set -- "${@}" "-g";;
            "--correct-oo") set -- "${@}" "-c";;
            "--"*) exitScript "ERROR : parameter '${arg}' invalid ! Use -h option to know more." 1 ;;
            *) set -- "${@}" "${arg}"
        esac
    done

    while getopts "cdef:g:ho:p:tvx" option; do
        case "${option}" in
            "h") printScriptUsage ;;
            "v") readonly verbose=true ;;
            "x") readonly debug=true; set -x ;;
            "f") obsocc_dump_file="${OPTARG}" ;;
            "d") drop_export_oo=true ;;
            "p") patch="${OPTARG}" ;;
            "o") db_oo_name_opt="${OPTARG}" ;;
            "g") db_gn_name_opt="${OPTARG}" ;;
            "c") correct_oo=true ;;
            *) exitScript "ERROR : parameter invalid ! Use -h option to know more." 1 ;;
        esac
    done

}

# DESC: Main control flow
# ARGS: $@ (optional): Arguments provided to the script
# OUTS: None
function main() {

    # init script

    file_names="
        utils.sh
        config.sh 
        obsocc.sh 
        test.sh
    "
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
    printTitle "Initialisation de la configuration"
    init_config;
    

    # import bd obsocc from dump file (if needed)
    printTitle "Restauration de la base ObsOcc depuis le fichier ${obsocc_dump_file}"

    import_bd_obsocc ${obsocc_dump_file}


    # correction geometrie, doublons
    if [ -n "${correct_oo}" ] ; then
        exec_sql_file ${db_oo_name} ${root_dir}/data/correct_oo.sql "Correction dans la base ${db_oo_name} doublons et geometries"
    fi


    # test si la base OO est ok
    if ! schema_exists ${db_oo_name} md ; then
        exitScript "Le schema 00:md n'existe pas, il y a un  problème dans l'import de la base\
Veuillez supprimer la base ${db_oo_name} et relancer le script\
Voir le fichier ${restore_oo_log_file} pour plus d'informations" 2
    fi

    # create export_oo schema (data from OO pre-formated for GN)
    printTitle "Schema export_oo"
    create_export_oo

    # fdw de OO:export_oo -> GN:export_oo
    printTitle "FDW"
    create_fdw_obsocc

    # Synonymes
    printTitle "Synonymes (nomenclatures et taxons)"
    exec_sql_file ${db_gn_name} ${root_dir}/data/export_oo/synonyme.sql "synonymes"

    # Tests
    printTitle "Vérification des données"
    test_geometry
    test_patch 'TAX' || test_taxonomy
    test_date
    test_patch 'JDD' && patch_jdd 
    test_jdd


    printTitle "Insertion des données"
    insert_data

}

main "${@}"
