parc=$1
set -x
export BASE_DIR=$(readlink -e "${0%/*}")/..
. $BASE_DIR/utils.sh
init_config $parc

. $BASE_DIR/config/config.ini
. $BASE_DIR/config/pag_v1.ini

dumpfilev1=$BASE_DIR/pag/dumps/20210210_dumpGn19.backup
if ! database_exists $db_name && [ -f $dumpfilev1 ]; then
    psql -d postgres -h ${db_host_v1} -U ${user_pg_v1} -p ${db_port_v1} -c "CREATE DATABASE ${db_name_v1}"
    pg_restore -d ${db_name_v1} -h ${db_host_v1} -U ${user_pg_v1} -p ${db_port_v1} $dumpfilev1
fi
