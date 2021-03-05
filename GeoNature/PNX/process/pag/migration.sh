# s'arrete si erreur
set -e

# script de migration des données GNV1 vers GN2.6
parc=pag

# load config
. config/settings.ini
. config/settings_v1.ini

# init_config
cd ..
. set_config.sh $parc
cd $parc

# clean (pour les nombreux essais à venir)
$psqla -f data/clean.sql

# open fdw
$psqla -f data/open_fdw.sql \
    -v db_name_v1=$db_name_v1 \
    -v db_host_v1=$db_host_v1 \
    -v db_port_v1=$db_port_v1 \
    -v user_pg_pass_v1=$user_pg_pass_v1 \
    -v user_pg_v1=$user_pg_v1
    
# user, orgs, perrmission, ...
$psqla -f data/user.sql

# taxonomie
$psqla -f data/taxonomie.sql


# close fdw
#$psqla -f data/close_fdw.sql
