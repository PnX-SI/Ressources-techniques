parc=$1

BASE_DIR=$(readlink -e "${0%/*}")/..

. $BASE_DIR/utils.sh

echo 'Process ref_geo for'