# Attention, il est conseille de travailler sur une copie de la base GNVA et non directement sur le serveur


# s'arrete si erreur
set -e

# script de migration des données GNV1 vers GN2.6
parc=pag

echo "############# load config"
. config/settings.ini
. config/settings_v1.ini

export psqlv1="psql -d ${db_name_v1} -h ${db_host_v1} -U ${user_pg_v1} -p ${db_port_v1} -v ON_ERROR_STOP=1"

echo "############# init_config"
cd ..
. set_config.sh $parc
cd $parc

echo "############# clean"
$psqla -f data/clean.sql

echo "############# open fdw"
$psqla -f data/open_fdw.sql \
    -v db_name_v1=$db_name_v1 \
    -v db_host_v1=$db_host_v1 \
    -v db_port_v1=$db_port_v1 \
    -v user_pg_pass_v1=$user_pg_pass_v1 \
    -v user_pg_v1=$user_pg_v1

cp csv/synonyme_v1.csv /tmp/.
echo "############# Creation de la synonymie"
$psqla -f data/synonyme.sql

echo "############# Transfert des users, permissions..."
$psqla -f data/user.sql

echo "############# Transfert taxonomie"
$psqla -f data/taxonomie.sql

echo "############# Transfert metadonnées"
$psqla -f data/metadonnee.sql

echo "############# Transfert occtax faune"
$psqla -f data/occtax_faune.sql -v srid_local=$srid_local

echo "############# Transfert occtax flore"
$psqla -f data/occtax_flore.sql -v srid_local=$srid_local


echo "############# Transfert synthese"
$psqla -f data/synthese.sql -v srid_local=$srid_local


echo "############# Transfert close fdw"
#$psqla -f data/close_fdw.sql
