
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
     -d | --drop-export-gn: re-create export_gn schema
     -p | --apply-patch: apply patch for JDD (one for all)

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
            "--dump-file") set -- "${@}" "-f" ;;
            "--drop-export-gn") set -- "${@}" "-d";; 
            "- apply-patch") set -- "${@}" "-p";; 
            "--"*) exitScript "ERROR : parameter '${arg}' invalid ! Use -h option to know more." 1 ;;
            *) set -- "${@}" "${arg}"
        esac
    done

    while getopts "hvxepdf:" option; do
        case "${option}" in
            "h") printScriptUsage ;;
            "v") readonly verbose=true ;;
            "x") readonly debug=true; set -x ;;
            "f") obsocc_dump_file="${OPTARG}" ;;
            "d") drop_import_schema=true ;;
            "p") apply_patch=true ;;
            *) exitScript "ERROR : parameter invalid ! Use -h option to know more." 1 ;;
        esac
    done

    if [ -z ${obsocc_dump_file} ]; then
        exitScript "Please enter path to obsocc dump file (option -p or --dump-file) ! Use -h option to know more" 2
    fi 
}

# DESC: Main control flow
# ARGS: $@ (optional): Arguments provided to the script
# OUTS: None
function main() {

    # Load functions
    file_names="utils.sh obsocc.sh"
    for file_name in ${file_names}; do
        source "$(dirname "${BASH_SOURCE[0]}")/scripts/${file_name}"
    done

    parseScriptOptions "${@}"
    initScript "${@}"

    source ${root_dir}/settings.ini

    rm -f $log_dir/*.log

    import_bd_obsocc ${obsocc_dump_file}

    if ! [ -z ${drop_import_schema} ]; then
        drop_export_gn
    fi

    # ne recrée pas si export est déjà existant
    create_export_gn

    # fdw de OO export_gn vers GN import_oo
    create_fdw_obsocc

    if [ -n "${apply_patch}" ] ;  then
        apply_patch_jdd
    fi

    # test si id dataset est rempli pour chaque ligne de import_gn.cor_etude_protocol_dataset
    if ! test_import_gn_cor_etude_protocol_dataset ; then 
        return 1
    fi


    # TODO
    # Ok pour user
    insert_data

    grep ERR ${log_dir}/sql.log

}

main "${@}"
