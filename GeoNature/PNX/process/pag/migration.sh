# Attention, il est conseille de travailler sur une copie de la base GNVA et non directement sur le serveur


# s'arrete si erreur
set -e

# script de migration des données GNV1 vers GN2.6
parc=pag

# load config
. config/settings.ini
. config/settings_v1.ini

export psqlv1="psql -d ${db_name_v1} -h ${db_host_v1} -U ${user_pg_v1} -p ${db_port_v1} -v ON_ERROR_STOP=1"

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


cp csv/synonyme_v1.csv /tmp/.
# user, orgs, perrmission, ...
$psqla -f data/synonyme.sql

# user, orgs, perrmission, ...
$psqla -f data/user.sql

# taxonomie
$psqla -f data/taxonomie.sql

# metadonnées
$psqla -f data/metadonnee.sql

# occtax faune
$psqla -f data/occtax_faune.sql -v srid_local=$srid_local

# occtax flore
$psqla -f data/occtax_flore.sql -v srid_local=$srid_local


#synthese
$psqla -f data/synthese.sql -v srid_local=$srid_local


# close fdw
#$psqla -f data/close_fdw.sql
