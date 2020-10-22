
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
     -f | --oo-dump-file <path to obsocc dump file>
     -n | --gn-dump-file <path to geonature dump file>
     -d | --drop-export-gn: re-create export_oo schema
     -p | --patch: <"PATCH1|PATCH2|...">  (details below)
     -g | --db-gn-name: GN database name
     -o | --db-oo-name: OO database name
     -c | --correct-oo: correct OO:saisie.saisie_observation geometry and doublons 
     -e | --etude-ca: etude=cadre aquisition (par defaut protcole=cadre aquisition) 
     -z | --clean : clean previous attemps
     -m | --media_dir : path to media dir
     -l | --limit set limit to test
     -r | --resume resume only

     -p | --apply-patch

        Taxonomy     
 
            Sans cette options le script affiche les cd_nom non attribués et renvoie une erreur
            A partir de cette liste, on peut soit
              corriger les cd_nom dans la base obsocc
              choisir de les ignorer avec l'option qui suit

            TAX: ignore unassociated cd_nom


        Acquisition framework and datasets

            Il est conseillé de lancer le script sans cette option une première fois
            Il va permettre de voir la structure (protocole, etude, organisme) des données
            On peut alors relancer le script et choisir une des options suivantes

            JDD_1       1 CA 'test' and 1 JDD 'test' for all data (pour tester la migration)
            JDD_EP      CA = etude, and JDD = (etude, protocole) 
            JDD_PE      CA = protocole, and JDD = (protocole, etude) 
            JDD_EPO     CA = etude, and JDD = (etude, protocole, organisme) 
            JDD_PEO     CA = protocole, and JDD = (protocole, etude, organisme) 

            Dans tout ces cas, il est conseillé d'éditer à post les jeux de données et cadres d'aquisition 
            afin de les renseigner au mieux

            Une autre option est de 
                créer les JDD depuis le module métadonnées 
                et de les assigner dans la table export_oo.cor_daset
           
        Exemple:

            ./import_obsocc <...autres options ...> -p "TAX|JDD1"

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
            "--correct-oo") set -- "${@}" "-c";;
            "--drop-export-gn") set -- "${@}" "-d";; 
            "--oo-dump-file") set -- "${@}" "-f" ;;
            "--db-gn-name")  set -- "${@}" "-g";;
            "--etude-ca") set -- "${@}" "-e";;
            "--help") set -- "${@}" "-h" ;;
            "--gn-dump-file") set -- "${@}" "-n" ;;
            "--db-oo-name")  set -- "${@}" "-o";;
            "--patch") set -- "${@}" "-p";; 
            "--verbose") set -- "${@}" "-v" ;;
            "--debug") set -- "${@}" "-x" ;;
            "--media-dir") set -- "${@}" "-m" ;;
            "--clean") set -- "${@}" "-z" ;;
            "--limit") set -- "${@}" "-l" ;;
            "--resume") set -- "${@}" "-r" ;;
            "--"*) exitScript "ERROR : parameter '${arg}' invalid ! Use -h option to know more." 1 ;;
            *) set -- "${@}" "${arg}"
        esac
    done

    while getopts "cdef:g:hl:m:n:o:p:rtvxz" option; do
        case "${option}" in
            "c") correct_oo=true ;;
            "d") drop_export_oo=true;;
            "e") cadre_aquisition=${etude};;
            "f") oo_dump_file="${OPTARG}" ;;
            "g") db_gn_name_opt="${OPTARG}" ;;
            "h") printScriptUsage ;;
            "n") gn_dump_file="${OPTARG}" ;;
            "o") db_oo_name_opt="${OPTARG}" ;;
            "p") patch="${OPTARG}" ;;
            "v") verbose=true ;;
            "x") debug=true; set -x ;;
            "m") media_dir=${OPTARG} ;;
            "z") clean=true ;;
            "l") limit=${OPTARG} ;;
            "r") display_resume=true ;;
            *) exitScript "ERROR : parameter invalid ! Use -h option to know more." 1 ;;
        esac
    done

}

# DESC: Main control flow
# ARGS: $@ (optional): Arguments provided to the script
# OUTS: None
function main() {

    # init script

    verbose=true 
    
    limit=10000000000000000

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

    init_config;

    if [ -n "${display_resume}" ]; then
        printPretty "\nResume pour la migration des données de la base Obsocc ${db_oo_name} vers la base GeoNature ${db_gn_name}\n"
        resume
        return
    fi

    printPretty "\nMigration des données de la base Obsocc ${db_oo_name} vers la base GeoNature ${db_gn_name}\n"


    printTitle "Initialisation"
    

    # resume
    # return 


    # import bd obsocc from dump file (if needed)
    printTitle "Restauration de la base ObsOcc depuis le fichier ${oo_dump_file}"

    import_bd_obsocc ${oo_dump_file}

    # correction geometrie, doublons
    if [ -n "${correct_oo}" ] ; then
        exec_sql_file ${db_oo_name} ${root_dir}/data/correct_oo.sql "Correction dans la base ${db_oo_name} doublons et geometries" "-v db_oo_name=${db_oo_name}"
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

    # views clean data
    clean_data

    # Tests
    printTitle "Vérification des données"
    test_user
    test_geometry
    test_patch 'TAX' || test_taxonomy
    
    test_patch 'MEDIA' && patch_media
    test_media
    
    test_date
    test_effectif
    test_patch 'JDD' && patch_jdd 
    test_jdd

    # Insertion
    printTitle "Insertion des données"

    insert_data

    # Résumé
    printTitle "Résumé pour ${db_oo_name}"
    resume


}

main "${@}"
