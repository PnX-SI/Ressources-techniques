# Attention, il est conseille de travailler sur une copie de la base GNVA et non directement sur le serveur


# s'arrete si erreur
set -e

# script de migration des données GNV1 vers GN2.6
parc=pag

echo "----------------------------------------------------------------------------" 
echo "------------------------------- load config -------------------------------- "

parc=pag
export BASE_DIR=$(readlink -e "${0%/*}")/..
. $BASE_DIR/utils.sh
init_config $parc




echo "-------------------------------- init_config -------------------------------"

. $BASE_DIR/$parc/config/settings.ini
. $BASE_DIR/$parc/config/settings_v1.ini
export psqlv1="psql -d ${db_name_v1} -h ${db_host_v1} -U ${user_pg_v1} -p ${db_port_v1} -v ON_ERROR_STOP=1"



echo "---------------------------------- clean -----------------------------------"
$psqla -f $BASE_DIR/$parc/data/clean.sql

echo "--------------------------------  open fdw   -------------------------------"
$psqla -f $BASE_DIR/$parc/data/open_fdw.sql \
    -v db_name_v1=$db_name_v1 \
    -v db_host_v1=$db_host_v1 \
    -v db_port_v1=$db_port_v1 \
    -v user_pg_pass_v1=$user_pg_pass_v1 \
    -v user_pg_v1=$user_pg_v1 \
    -v user_pg=$user_pg

cp csv/synonyme_v1.csv /tmp/.
echo "----------------------------------------------------------------------------" 
echo "--------------------------- Creation de la synonymie -----------------------"
$psqla -f $BASE_DIR/$parc/data/synonyme.sql

echo "----------------------------------------------------------------------------"  
echo "--------------------- Transfert des users, permissions...-------------------"
$psqla -f $BASE_DIR/$parc/data/user.sql

echo "----------------------------------------------------------------------------"  
echo "-------------------------- Transfert taxonomie -----------------------------"
$psqla -f $BASE_DIR/$parc/data/taxonomie.sql

echo "----------------------------------------------------------------------------"  
echo "------------------------- Transfert metadonnées ----------------------------"
$psqla -f $BASE_DIR/$parc/data/metadonnee.sql

echo "----------------------------------------------------------------------------"  
echo "------------------------- Transfert occtax faune ---------------------------"
$psqla -f $BASE_DIR/$parc/data/occtax_faune.sql -v srid_local=$srid_local

echo "----------------------------------------------------------------------------"  
echo "------------------------- Transfert occtax flore ---------------------------"
$psqla -f $BASE_DIR/$parc/data/occtax_flore.sql -v srid_local=$srid_local


echo "----------------------------------------------------------------------------"  
echo "---------------------------- Transfert synthese ----------------------------"
$psqla -f $BASE_DIR/$parc/data/synthese.sql -v srid_local=$srid_local


echo "----------------------------------------------------------------------------"  
echo "--------------------------------- close fdw -------------------------------- "
#$psqla -f $BASE_DIR/$parc/data/close_fdw.sql
