parc=$1
export BASE_DIR=$(readlink -e "${0%/*}")/..
. $BASE_DIR/utils.sh
init_config $parc

$BASE_DIR/$parc/insert_access_data.sh $parc

# USERS