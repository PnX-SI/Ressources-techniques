parc=$1
# chargement de functions
BASE_DIR=$(readlink -e "${0%/*}")/..
. $BASE_DIR/utils.sh
init_config $parc

[ ! -d $BASE_DIR/$parc/medias/renamed ] && rename_medias $parc

cd $BASE_DIR/../../migration/sicen_to_occtaxV2

./import_obsocc.sh \
    -d -v -s $srid_local -p "JDD_EP" -c -z \
    -o pn_${parc} \
    -g gn_${parc} \
    -f $BASE_DIR/$parc/dumps/pn_${parc}.dump \
    -n $BASE_DIR/$parc/dumps/gn_${parc}_pre.dump \
    -m $BASE_DIR/$parc/medias/renamed