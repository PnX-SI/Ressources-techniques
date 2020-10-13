# DESC: test if GN export_oo.cor_etude_module_dataset exists
#       and if id_dataset are not NULL
# ARGS: NONE
# OUTS: 0 if true
function test_jdd() {

    log SQL "Test geometrie"
        
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

    return 0
}

test_geometry() {

    log SQL "Test geometrie"

    export PGPASSWORD=${user_pg_pass};\
    res=$(psql -tA -R";" -h ${db_host}  -p ${db_port} -U ${user_pg} -d ${db_gn_name} \
     -c "SELECT COUNT(*) 
     FROM export_oo.saisie_observation s 
     WHERE NOT ST_ISVALID(geometrie)" 
    )

    if [ ! "$res" = "0" ] ; then
        exitScript "Il y a ${res} lignes avec une géométrie invalide dans les observations ObsOcc.\n
Veuillez corriger ces geométries (ou bien relancer le script avec l'option -c" 1
    fi

}


test_taxonomy() {

    log SQL "Test taxonomie"

    export PGPASSWORD=${user_pg_pass};\
    res=$(psql -tA -R";" -h ${db_host}  -p ${db_port} -U ${user_pg} -d ${db_gn_name} \
     -c "SELECT DISTINCT o.cd_nom, o.nom_complet 
     FROM export_oo.saisie_observation o 
     LEFT JOIN taxonomie.taxref t ON t.cd_nom = o.cd_nom
     LEFT JOIN export_oo.t_taxonomie_synonymes s ON s.cd_nom_invalid = o.cd_nom 
     WHERE t.cd_nom IS NULL AND s.cd_nom_valid IS NULL")

    if [ -n "${res}" ] ; then
        pretty_res=$(echo $res | sed -e "s/;/\n/g" -e "s/|/\t/g" | awk -F $'\t' '{printf "%-15s %s\n", $1, $2}')
        exitScript "Dans la table saisie.observation, il y a des lignes avec le champ 'cd_nom' sans correspondance dans TaxRef\n\n${pretty_res} \n 
Veuillez au choix:
    - les corriger dans la base départ
    - compléter le fichier data/csv/taxonomie_custom.csv
    - les ignorer et relancer le script avec l'option -p TAX (pour ne pas en tenir compte) 
" 2
    fi
}


test_date() {
    log SQL "Test date"

    export PGPASSWORD=${user_pg_pass};\
    res=$(psql -tA -R";" -h ${db_host}  -p ${db_port} -U ${user_pg} -d ${db_gn_name} \
     -c "SELECT id_obs 
     FROM export_oo.saisie_observation s 
     WHERE date_min IS NULL or date_max IS NULL OR date_max < date_min"
    )

    if [ -n "$res" ] ; then
        exitScript "Il y a des lignes avec des dates non définis dans la table 'export_oo.saisie_observation'.\n\n ${res}\n
Voir le fichier data.export_oo/oo_data.sql." 1
    fi
}


test_effectif() {
    log SQL "Test effectif"

    export PGPASSWORD=${user_pg_pass};\
    res=$(psql -tA -R";" -h ${db_host}  -p ${db_port} -U ${user_pg} -d ${db_gn_name} \
     -c "SELECT id_obs , effectif_min, effectif_max
     FROM export_oo.saisie_observation s 
     WHERE effectif_min > effectif_max"
    )
           if [ -n "$res" ] ; then
pretty_res=$(echo $res | sed -e "s/;/\n/g" -e "s/|/\t/g" | awk -F $'\t' '
    BEGIN {
        printf "%20s %20s %20s\n\n", "id_obs", "effectif_min", "effectif_max";
    } {
        printf "%20s %20s %20s\n", $1, $2, $3
    }')
        exitScript "Il y a des lignes avec des effectifs_min > effectif_max dans la table 'export_oo.saisie_observation'.
        \n${pretty_res}\n
Veuillez corriger ces geométries (ou bien relancer le script avec l'option -c" 1
    fi
}