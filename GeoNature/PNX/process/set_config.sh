parc=$1
. config.ini
. ${parc}/config/settings_atlas.ini
. ${parc}/config/settings.ini
export cur=$(pwd)
export PGPASSWORD=${user_pg_pass}
export psqla="psql -d ${db_name} -h ${db_host} -U ${user_pg} -p ${db_port} -v ON_ERROR_STOP=1"
export psqlg="psql -d postgres -h ${db_host} -U ${user_pg} -p ${db_port}"
export pgdumpa="pg_dump -d ${db_name} -h ${db_host} -U ${user_pg} -p ${db_port} --no-acl --no-owner -Fc "
export pgrestorea="pg_restore -d ${db_name} -h ${db_host} -U ${user_pg} -p ${db_port} --no-acl --no-owner -Fc "
