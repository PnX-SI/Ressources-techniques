#/bin/bash  
# utils.sh
# fonctions pour gerer les données des parcs
if [ -z "$BASE_DIR" ]; then 
    export BASE_DIR=$(readlink -e "${0%/*}")
fi

function set_config
{
    parc=$1
    . $BASE_DIR/config/config.ini
    . $BASE_DIR/config/${parc}.ini


    export PGPASSWORD=${user_pg_pass}
    export psqla="psql -d ${db_name} -h ${db_host} -U ${user_pg} -p ${db_port} -v ON_ERROR_STOP=1"
    export psqlg="psql -d postgres -h ${db_host} -U ${user_pg} -p ${db_port}"

    export pgdumpa="pg_dump -d ${db_name} -h ${db_host} -U ${user_pg} -p ${db_port} --no-acl --no-owner -Fc "
    export pgrestorea="pg_restore -d ${db_name} -h ${db_host} -U ${user_pg} -p ${db_port} --no-acl --no-owner -Fc "
    export db_name=$db_name
}

function up_schema_atlas() {
    parc=$1
    init_config $parc
    $psqla -c 'SELECT atlas.refresh_materialized_view_data()'
}

function up_app_config
{
    parc=$1
    build=$2
    init_config $parc
    sudo supervisorctl restart all
    cd $geonature_DIR/frontend
    if [ ! -z "$build" ]; then 
        npm run build
    fi
    cd $BASE_DIR
}

function set_app_files() {
    # config
    parc=$1
    .  ${BASE_DIR}/config/config.ini

    cp ${BASE_DIR}/${parc}/config/settings_geonature.ini $geonature_DIR/config/settings.ini
    cp ${BASE_DIR}/${parc}/config/geonature_config.toml $geonature_DIR/config/geonature_config.toml

    cp ${BASE_DIR}/${parc}/config/settings_atlas.ini $atlas_DIR/atlas/configuration/settings.ini
    cp ${BASE_DIR}/${parc}/config/config_atlas.py $atlas_DIR/atlas/configuration/config.py

    cp ${BASE_DIR}/${parc}/config/settings_usershub.ini $usershub_DIR/config/settings.ini
    cp ${BASE_DIR}/${parc}/config/config_usershub.py $usershub_DIR/config/config.py

    cp ${BASE_DIR}/${parc}/config/settings_taxhub.ini $taxhub_DIR/settings.ini
    cp ${BASE_DIR}/${parc}/config/config_taxhub.py $taxhub_DIR/config.py

    # custom

    # geonature
    cp ${BASE_DIR}/${parc}/custom/geonature/logo_structure.png $geonature_DIR/frontend/src/custom/images/.  
    cp ${BASE_DIR}/${parc}/custom/geonature/custom.scss $geonature_DIR/frontend/src/custom/.  
    cp ${BASE_DIR}/${parc}/custom/geonature/introduction.component.html $geonature_DIR/frontend/src/custom/components/introduction/.  

    # atlas
    cp -R ${BASE_DIR}/${parc}/custom/atlas/* $atlas_DIR/static/custom/.

}

function init_config
{
    parc=$1

    set_config $parc

    config_geonature=geonature_config.toml
    config_usershub=config_usershub.py
    config_taxhub=config_taxhub.py
    config_atlas=config_atlas.py


    cat $BASE_DIR/config/config.ini $BASE_DIR/config/${parc}.ini | grep -v '#' > $BASE_DIR/config/cur.ini
    for app in $(echo "geonature usershub taxhub atlas"); do
        # settings_<app>.ini
        settings_file=$BASE_DIR/${parc}/config/settings_${app}.ini
        cp $BASE_DIR/config/settings_${app}.ini.sample $settings_file
        # sed
        . $BASE_DIR/config/cur.ini

        while read line; do
            if echo $line | grep '#' > out; then continue; fi 
            if [ -z "$line" ]; then continue; fi 
            var_name=${line%%=*}
            var_value=${line##*=}
            sed -i -e "s#${var_name}=.*#${var_name}=${var_value}#g" $settings_file
        done < $BASE_DIR/config/cur.ini

        # config file
        config_file_var=config_${app}
        config_file_name=${!config_file_var}
        config_file=$BASE_DIR/$parc/config/$config_file_name
        cp $BASE_DIR/config/${config_file_name}.sample $config_file

        sed -i \
            -e "s/SQLALCHEMY_DATABASE_URI.*$/SQLALCHEMY_DATABASE_URI = \"postgresql:\/\/$user_pg:$user_pg_pass@$db_host:$db_port\/$db_name\"/" \
            -e "s/database_connection.*$/database_connection = \"postgresql:\/\/$user_pg:$user_pg_pass@$db_host:$db_port\/$db_name\"/" \
            -e "s#URL_APPLICATION.*#URL_APPLICATION = '${my_url}${app}'#g" \
            -e "s#API_ENDPOINT.*#API_ENDPOINT = '${my_url}geonature/api'#g" \
            -e "s#API_TAXHUB.*#API_TAXHUB = '${my_url}taxhub/api'#g" \
            -e "s/LOCAL_SRID.*/LOCAL_SRID = '${srid_local}'/g" \
            -e "s#TAXHUB_URL.*#TAXHUB_URL = '${my_url}taxhub'#g" \
            -e "s/MAP_CENTER.*/MAP_CENTER = ${map_center}/g" \
            -e "s/ZOOM_LEVEL.*/ZOOM_LEVEL = ${map_zoom_level}/g" \
            -e "s/'LAT_LONG'.*/'LAT_LONG': ${map_center},/g" \
            -e "s/'ZOOM'.*/'ZOOM': ${map_zoom_level},/g" \
            -e "s/PASS_METHOD.*/PASS_METHOD = '${pass_method}'/" \
            $config_file


    done
            set_app_files $parc
}



# gestion des depots git
# depuis config.ini
function manage_git
{
    parc=$1
    init_config $parc

    cd $DEPOTS_DIR

    for depot in $(echo "$DEPOTS"); do
        name=${depot%-*}
        version=${depot#*-}
        [[ ! -d $DEPOTS_DIR/$name ]] && git clone https://github.com/PnX-SI/$name.git $DEPOTS_DIR/$name
        cd $DEPOTS_DIR/$name; git co $version; git pull origin $version 
    done   
}

# installer la base de données (+ modules)
function install_db_all
{
    parc=$1

    # initialisation de la config pour le parc
    init_config $parc
    . $BASE_DIR/config/config.ini
    . $BASE_DIR/config/${parc}.ini


    if  database_exists $db_name; then
        echo $db_name exist
        if ! $drop_apps_db; then
            echo dont process base
            return 0
        else 
            echo drop_apps_db is $drop_apps_db process re install db
        fi
    fi
    echo install db $db_name
    # gestion des fichiers (applications /modules)
    manage_git $parc
    # installation base

    cd $geonature_DIR/install
    ./install_db.sh
    # if base exists return no drop_app db


    # si besoin installation app
    if [ ! -d $geonature_DIR/backend/venv ]; then
        ./install_app.sh
    else
        source $geonature_DIR/backend/venv/bin/activate
        geonature install_gn_module $geonature_DIR/contrib/occtax /occtax --build=false
        geonature install_gn_module $geonature_DIR/contrib/gn_module_occhab /occhab --build=false
        geonature install_gn_module $geonature_DIR/contrib/gn_module_validation /validation --build=false
    fi
    # installation modules

    # module qui ne sont pas dans le coeur

    echo $DEPOTS | grep 'import' && geonature install_gn_module $DEPOTS_DIR/gn_module_import /import --build=false
    echo $DEPOTS | grep 'export' && geonature install_gn_module $DEPOTS_DIR/gn_module_export /export --build=false
    echo $DEPOTS | grep 'dashboard' && geonature install_gn_module $DEPOTS_DIR/gn_module_dashboard /dashboard --build=false
    echo $DEPOTS | grep 'monitoring' && geonature install_gn_module $DEPOTS_DIR/gn_module_monitoring /monitoring --build=false
    
    # ref_geo
    [[ -f $BASE_DIR/$parc/process_ref_geo.sh ]] && $BASE_DIR/$parc/process_ref_geo.sh $parc


    process_atlas_db $parc

    mkdir -p $BASE_DIR/$parc/dumps
    $pgdumpa > $BASE_DIR/$parc/dumps/gn_${parc}_pre.dump
}

function set_admin_pass() {

    parc=$1

    init_config $parc
    . $BASE_DIR/$parc/config/settings_geonature.ini

    #md5
    pass=$(echo -n $admin_pass | md5sum | sed -e 's/ .*//')
    # hash
    pass_plus=$(htpasswd -bnBC 10 "" $admin_pass | tr -d ':\n')
    echo $psqla -c "UPDATE utilisateurs.t_roles SET (pass, pass_plus) = ('$pass', '$pass_plus') WHERE nom_role = 'admin'"
    $psqla -c "UPDATE utilisateurs.t_roles SET (pass, pass_plus) = ('$pass', '$pass_plus') WHERE nom_role = 'Administrateur'"

    

}


function reset_all() {
    parc=$1
    init_config $parc
    . $BASE_DIR/$parc/config/settings_geonature.ini

    rm -f $BASE_DIR/$parc/ref_geo/dem.sql
    rm -Rf $BASE_DIR/$parc/renamed
    # rm -Rf $geonature_DIR/tmp

    $psqlg -c "SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE pid <> pg_backend_pid()AND datname = '${db_name}'";
    $psqlg -c "DROP DATABASE $db_name"
}

function medias_taxref() {
    parc=$1

    # initialisation de la config pour le parc
    init_config $parc
    . $BASE_DIR/config.ini
    . $BASE_DIR/$parc/config/settings_geonature.ini

    cp $BASE_DIR/data/medias_config.py $DEPOTS_DIR/TaxHub/data/scripts/import_inpn_media/config.py

    sed -i "s/SQLALCHEMY_DATABASE_URI = .*$/SQLALCHEMY_DATABASE_URI = \"postgresql:\/\/$user_pg:$user_pg_pass@$db_host:$db_port\/$db_name\"/" \
        $DEPOTS_DIR/TaxHub/data/scripts/import_inpn_media/config.py
    
    cd $DEPOTS_DIR/TaxHub/data/scripts/import_inpn_media/.
    
    if [ ! -d venv ]; then

        python3 -m virtualenv venv
        source venv/bin/activate
        pip install psycopg2
        pip install requests
        deactivate
    fi

    source venv/bin/activate
    python import_inpn_media.py
    deactivate

    cd $BASE_DIR

}

function process_atlas_db {
    parc=$1

    # initialisation de la config pour le parc
    init_config $parc
    . $BASE_DIR/$parc/config/settings_atlas.ini

    $psqla -c "DROP SCHEMA IF EXISTS atlas CASCADE"

    $psqla -c "CREATE SCHEMA atlas"

    cp $BASE_DIR/data/atlas/atlas.sql /tmp/atlas.sql
    sed -i "s/WHERE id_attribut IN (100, 101, 102, 103);$/WHERE id_attribut  IN ($attr_desc, $attr_commentaire, $attr_milieu, $attr_chorologie);/" /tmp/atlas.sql
    sed -i "s/date - 15$/date - $time/" /tmp/atlas.sql
    sed -i "s/date + 15$/date - $time/" /tmp/atlas.sql

    #customisation de l'altitude
    insert=""
    for i in "${!altitudes[@]}"
    do
        if [ $i -gt 0 ];
        then
            let max=${altitudes[$i]}-1
            sql="INSERT INTO atlas.bib_altitudes VALUES ($i,${altitudes[$i-1]},$max);"
            insert="${insert}\n${sql}"
        fi
    done

    if [ ! -z "${atlas_marin}" ]; then 
        sql="INSERT INTO atlas.bib_altitudes VALUES($i + 1, -30000, -1, '_en_mer');"
        insert="${insert}\n${sql}"
    fi

    sed -i "s/INSERT_ALTITUDE/${insert}/" /tmp/atlas.sql

    $psqla  -v type_maille=$type_maille -v type_territoire=$type_territoire -f $BASE_DIR/data/atlas/atlas_ref_geo.sql
    $psqla -f $BASE_DIR/data/atlas/atlas_synthese.sql
    $psqla -f /tmp/atlas.sql > out
    $psqla -f $BASE_DIR/data/atlas/observations_mailles.sql

    $psqla -c 'SELECT atlas.refresh_materialized_view_data();'

    # territoire.json (PEC)
    ogr2ogr -f "GeoJSON" -t_srs "EPSG:4326" -s_srs "EPSG:3857" $BASE_DIR/${parc}/ref_geo/territoire.json \
    PG:"host=$db_host user=$user_pg dbname=$db_name port=$db_port password=$user_pg_pass" \
    "atlas.t_layer_territoire"

    cp ${BASE_DIR}/${parc}/ref_geo/territoire.json $atlas_DIR/static/custom/territoire.json   

}

# DESC: check if DB exists
# ARGS: $1 : database name
# OUTS: 0 if true
# USAGE: database_exists test
function database_exists () {
    # /!\ Will return false if psql can't list database. Edit your pg_hba.conf
    # as appropriate.

    db_name=$1


    if [ -z $1 ]
        then
        # Argument is null
        return 1
    else
        # Grep DB name in the list of databases
        export PGPASSWORD=${user_pg_pass};\

        psql -tAl -h ${db_host}  -p ${db_port} -U ${user_pg} -d postgres -tAl | grep  "${db_name}" \
        &>> /tmp/out
        psql -tAl -h ${db_host}  -p ${db_port} -U ${user_pg} -d postgres -tAl | grep  "${db_name}|"
        return $?
    fi
}

function rename_medias () {
    parc=$1

    echo rename medias $parc

    cd $BASE_DIR/$parc/medias/base

    dir_out=renamed

    rm -f copy.sh
    rm -Rf ../$dir_out
    put="*/*/*"
    for f in ls -b */*/*; do
        [ "$f" = "ls" ] && continue
        [ "$f" = "-b" ] && continue

        new_file=$(ls -b "$f" | sed \
        -e 's/\\ /_/g' \
        -e 's/\\340//g' \
        -e 's/\\347/c/g' \
        -e 's/\\351/e/g' \
        -e 's/\\342/a/g' \
        -e 's/\\350/e/g' \
        -e 's/\\356/i/g' \
        -e 's/\\251//g' \
        -e "s/[\(\),']/_/g" \
        -e 's/-/_/g' \
        )
        mkdir -p $(dirname ../$dir_out/$new_file)
        cp "$f" ../$dir_out/$new_file

        # ls "$f"
    done


    # ls -b $put | sed \
    #     -e 's/\\ /_/g' \
    #     -e 's/\\340//g' \
    #     -e 's/\\347/c/g' \
    #     -e 's/\\351/e/g' \
    #     -e 's/\\350/e/g' \
    #     -e 's/\\356/i/g' \
    #     -e 's/\\251//g' \
    #     -e "s/[\(\),']/_/g" \
    #     -e 's/-/_/g'
    # do
    #     echo $file
    #     new_file=$(ls -b "$file" | sed \
    #     -e 's/\\ /_/g' \
    #     -e 's/\\340//g' \
    #     -e 's/\\347/c/g' \
    #     -e 's/\\351/e/g' \
    #     -e 's/\\350/e/g' \
    #     -e 's/\\356/i/g' \
    #     -e 's/\\251//g' \
    #     -e "s/[\(\),']/_/g" \
    #     -e 's/-/_/g' \
    #     )

    #     mkdir -p $(dirname ../$dir_out/$new_file)
    #     cp "$file" "../$dir_out/$new_file"
    # done
    
    # cd $BASE_DIR/$parc/medias
}
