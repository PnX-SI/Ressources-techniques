parc=$1
cur=$(pwd)

. init_config.sh ${parc}

cd $geonature_DIR/install
./install_db.sh
cd $cur

# patch sensitivity
$psqla -f data/patch_sensitivity.sql

# mobile
$psqla -f data/mobile_test.sql

source $geonature_DIR/backend/venv/bin/activate
geonature install_gn_module $geonature_DIR/contrib/occtax /occtax --build=false
geonature install_gn_module $geonature_DIR/contrib/gn_module_occhab /occhab --build=false
geonature install_gn_module $geonature_DIR/contrib/gn_module_validation /validation --build=false

# atlas
# ./atlas.sh ${parc}

$pgdumpa > $BASE_DIR/$parc/dumps/gn_${parc}_pre

