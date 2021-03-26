parc=$1
cur=$(pwd)

. init_config.sh ${parc}

cd $GN_dir/install
./install_db.sh
cd $cur

# patch sensitivity
$psqla -f data/patch_sensitivity.sql

# mobile
$psqla -f data/mobile_test.sql

source $GN_dir/backend/venv/bin/activate
geonature install_gn_module $GN_dir/contrib/occtax /occtax --build=false
geonature install_gn_module $GN_dir/contrib/gn_module_occhab /occhab --build=false
geonature install_gn_module $GN_dir/contrib/gn_module_validation /validation --build=false

# atlas
# ./atlas.sh ${parc}
