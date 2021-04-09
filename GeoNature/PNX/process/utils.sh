# utils.sh
# fonctions pour gerer les données des parcs
if [ -z "$BASE_DIR" ]; then 
    export BASE_DIR=$(readlink -e "${0%/*}")
fi

function set_config
{
    parc=$1
    . $BASE_DIR/config.ini
    . $BASE_DIR/${parc}/config/settings.ini
    # . ${parc}/config/settings_atlas.ini
    . $BASE_DIR/${parc}/config/settings.ini
    export cur=$(pwd)
    export PGPASSWORD=${user_pg_pass}
    export psqla="psql -d ${db_name} -h ${db_host} -U ${user_pg} -p ${db_port} -v ON_ERROR_STOP=1"
    export psqlg="psql -d postgres -h ${db_host} -U ${user_pg} -p ${db_port}"
    export pgdumpa="pg_dump -d ${db_name} -h ${db_host} -U ${user_pg} -p ${db_port} --no-acl --no-owner -Fc "
    export pgrestorea="pg_restore -d ${db_name} -h ${db_host} -U ${user_pg} -p ${db_port} --no-acl --no-owner -Fc "

}

function init_config
{
    parc=$1
    set_config $parc
    # geonature config.toml
    geonature_config_toml=$BASE_DIR/$parc/config/geonature_config.toml
    my_url="${my_url//\//\\/}"
    sed -i "s/SQLALCHEMY_DATABASE_URI = .*$/SQLALCHEMY_DATABASE_URI = \"postgresql:\/\/$user_pg:$user_pg_pass@$db_host:$db_port\/$db_name\"/" $geonature_config_toml
    sed -i "s/URL_APPLICATION = .*$/URL_APPLICATION = '${my_url}geonature' /g" $geonature_config_toml
    sed -i "s/API_ENDPOINT = .*$/API_ENDPOINT = '${my_url}geonature\/api'/g" $geonature_config_toml
    sed -i "s/API_TAXHUB = .*$/API_TAXHUB = '${my_url}taxhub\/api'/g" $geonature_config_toml
    sed -i "s/DEFAULT_LANGUAGE = .*$/DEFAULT_LANGUAGE = '${default_language}'/g" $geonature_config_toml
    sed -i "s/LOCAL_SRID = .*$/LOCAL_SRID = '${srid_local}'/g" $geonature_config_toml

    # copie
    cp ${BASE_DIR}/${parc}/config/settings.ini $GN_dir/config/settings.ini
    cp ${BASE_DIR}/${parc}/config/geonature_config.toml $GN_dir/config/geonature_config.toml
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

    # gestion des fichiers (applications /modules)
    manage_git $parc
    # installation base
    cd $GN_dir/install
    ./install_db.sh

    # si besoin installation app
    if [ ! -d $GN_dir/backend/venv ]; then
        ./install_app.sh
    else
        source $GN_dir/backend/venv/bin/activate
        geonature install_gn_module $GN_dir/contrib/occtax /occtax --build=false
        geonature install_gn_module $GN_dir/contrib/gn_module_occhab /occhab --build=false
        geonature install_gn_module $GN_dir/contrib/gn_module_validation /validation --build=false
    fi
    # installation modules

    # module qui ne sont pas dans le coeur

    echo $DEPOTS | grep 'import' && geonature install_gn_module $DEPOTS_DIR/gn_module_import /import --build=false
    echo $DEPOTS | grep 'export' && geonature install_gn_module $DEPOTS_DIR/gn_module_export /export --build=false
    echo $DEPOTS | grep 'dashboard' && geonature install_gn_module $DEPOTS_DIR/gn_module_dashboard /dashboard --build=false
    echo $DEPOTS | grep 'monitoring' && geonature install_gn_module $DEPOTS_DIR/gn_module_monitoring /monitoring --build=false
    
    # ref_geo
    [[ -f $BASE_DIR/$parc/process_ref_geo.sh ]] && $BASE_DIR/$parc/process_ref_geo.sh
}
