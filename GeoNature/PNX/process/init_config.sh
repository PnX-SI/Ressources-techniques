parc=$1
remote=$2

# emplacement des applis
. config.ini

# Config files
. ${parc}/config/settings.ini

if [ ! -z "${remote}" ]; then
echo aa
. ${parc}/config/settings_remote.ini
fi

# atlas

sed -i "s|db_host=.*|db_host=${db_host}|" ${parc}/config/settings_atlas.ini
sed -i "s/db_name=.*/db_name=${db_name}/" ${parc}/config/settings_atlas.ini
sed -i "s/db_port=.*/db_port=${db_port}/" ${parc}/config/settings_atlas.ini
sed -i "s/user_pg=.*/user_pg=${user_pg}/" ${parc}/config/settings_atlas.ini
sed -i "s/user_pg_pass=.*/user_pg_pass=${user_pg_pass}/" ${parc}/config/settings_atlas.ini
sed -i "s/owner_atlas=.*/owner_atlas=${user_pg}/" ${parc}/config/settings_atlas.ini
sed -i "s/owner_atlas_pass=.*/owner_atlas_pass=${user_pg_pass}/" ${parc}/config/settings_atlas.ini

. ${parc}/config/settings_atlas.ini

# geonature config.toml
my_url="${my_url//\//\\/}"
sed -i "s/SQLALCHEMY_DATABASE_URI = .*$/SQLALCHEMY_DATABASE_URI = \"postgresql:\/\/$user_pg:$user_pg_pass@$db_host:$db_port\/$db_name\"/" ${parc}/config/geonature_config.toml
sed -i "s/URL_APPLICATION = .*$/URL_APPLICATION = '${my_url}geonature' /g" ${parc}/config/geonature_config.toml
sed -i "s/API_ENDPOINT = .*$/API_ENDPOINT = '${my_url}geonature\/api'/g" ${parc}/config/geonature_config.toml
sed -i "s/API_TAXHUB = .*$/API_TAXHUB = '${my_url}taxhub\/api'/g" ${parc}/config/geonature_config.toml
sed -i "s/DEFAULT_LANGUAGE = .*$/DEFAULT_LANGUAGE = '${default_language}'/g" ${parc}/config/geonature_config.toml
sed -i "s/LOCAL_SRID = .*$/LOCAL_SRID = '${srid_local}'/g" ${parc}/config/geonature_config.toml

echo $db_host
cat ${parc}/config/geonature_config.toml | grep postgresql

# ATLAS config.py
sed -i "s/database_connection = .*$/database_connection = \"postgresql:\/\/$user_pg:$user_pg_pass@$db_host:$db_port\/$db_name\"/" ${parc}/config/config_atlas.py


if [ -z ${remote} ]; then
cp ${parc}/config/settings.ini $GN_dir/config/settings.ini
cp ${parc}/config/geonature_config.toml $GN_dir/config/geonature_config.toml
cp ${parc}/config/settings.ini $GN_dir/config/settings.ini
cp ${parc}/config/settings_atlas.ini ${ATLAS_dir}/atlas/configuration/settings.ini
cp ${parc}/config/config_atlas.py ${ATLAS_dir}/atlas/configuration/config.py
else
mkdir -p $parc/out/GeoNature/config/
mkdir -p $parc/out/atlas/atlas/configuration/
cp $parc/config/geonature_config.toml $parc/out/GeoNature/config/.
cp $parc/config/config_atlas.py $parc/out/atlas/atlas/configuration/config.py
fi

. set_config.sh ${parc}