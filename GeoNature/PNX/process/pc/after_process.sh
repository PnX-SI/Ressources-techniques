parc=$1

BASE_DIR=$(readlink -e "${0%/*}")/..
. $BASE_DIR/utils.sh
init_config $parc
. $BASE_DIR/config/config.ini
. $BASE_DIR/config/$parc.ini

$psqla -f "$BASE_DIR/$parc/data/after_process.sql"
