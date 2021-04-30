# Attention, il est conseille de travailler sur une copie de la base GNVA et non directement sur le serveur

clear
# s'arrete si erreur
set -e

# script de migration des données GNV1 vers GN2.6
parc=pag

echo "----------------------------------------------------------------------------"
echo "-------------------------------- Initialisation ----------------------------" 
echo "----------------------------------------------------------------------------"
echo "************************ load config "
<<<<<<< HEAD
echo $BASE_DIR
=======
>>>>>>> 83aeb523c0e9217697130a0682110cdd34bda999
parc=pag
export BASE_DIR=$(readlink -e "${0%/*}")/..
. $BASE_DIR/utils.sh
init_config $parc

echo "************************ init config "
. $BASE_DIR/$parc/config/settings.ini
. $BASE_DIR/$parc/config/settings_v1.ini
export psqlv1="psql -d ${db_name_v1} -h ${db_host_v1} -U ${user_pg_v1} -p ${db_port_v1} -v ON_ERROR_STOP=1"

echo "************************ clean "
$psqla -f $BASE_DIR/$parc/data/clean.sql

echo "************************ open fdw "
$psqla -f $BASE_DIR/$parc/data/open_fdw.sql \
    -v db_name_v1=$db_name_v1 \
    -v db_host_v1=$db_host_v1 \
    -v db_port_v1=$db_port_v1 \
    -v user_pg_pass_v1=$user_pg_pass_v1 \
    -v user_pg_v1=$user_pg_v1 \
    -v user_pg=$user_pg

echo "----------------------------------------------------------------------------"
echo "-------------------------------- Refs Geo ----------------------------" 
echo "----------------------------------------------------------------------------"
#./process_ref_geo.sh
<<<<<<< HEAD

echo "----------------------------------------------------------------------------"
echo "-------------------------------- Transfert refs ----------------------------" 
echo "----------------------------------------------------------------------------"
echo "************************ Creation de la synonymie"
$psqla -f $BASE_DIR/$parc/data/synonyme.sql

echo "************************ Transfert des users, permissions..."
$psqla -f $BASE_DIR/$parc/data/user.sql

echo "************************ Transfert taxonomie"
$psqla -f $BASE_DIR/$parc/data/taxonomie.sql

echo "************************ Transfert metadonnées.... "
$psqla -f $BASE_DIR/$parc/data/metadonnee.sql


echo "----------------------------------------------------------------------------"
echo "-------------------------------- Transfert data ----------------------------" 
echo "----------------------------------------------------------------------------"
echo "************************ occtax faune "
$psqla -f $BASE_DIR/$parc/data/occtax_faune.sql -v srid_local=$srid_local

echo "************************ occtax flore "
$psqla -f $BASE_DIR/$parc/data/occtax_flore.sql -v srid_local=$srid_local

echo "************************ Transfert synthese "
$psqla -f $BASE_DIR/$parc/data/synthese.sql -v srid_local=$srid_local

echo "----------------------------------------------------------------------------"
echo "--------------------------------- Finalisation -----------------------------" 
echo "----------------------------------------------------------------------------"
=======

echo "----------------------------------------------------------------------------"
echo "-------------------------------- Transfert refs ----------------------------" 
echo "----------------------------------------------------------------------------"
echo "************************ Creation de la synonymie"
$psqla -f $BASE_DIR/$parc/data/synonyme.sql
echo ""
echo "************************ Transfert des users & organismes"
$psqla -f $BASE_DIR/$parc/data/user.sql
echo ""
echo "************************ Transfert taxonomie + complements taxref v14"
wget http://geonature.fr/data/inpn/taxonomie/TAXREF_v14_2020.zip -P /tmp/taxhub
unzip -o /tmp/taxhub/TAXREF_v14_2020.zip -d /tmp/taxhub
$psqla -f $BASE_DIR/$parc/data/taxonomie.sql
echo ""
echo "************************ Transfert metadonnées "
$psqla -f $BASE_DIR/$parc/data/metadonnee.sql
echo ""
echo "----------------------------------------------------------------------------"
echo "-------------------------------- Transfert données ----------------------------" 
echo "----------------------------------------------------------------------------"
echo "************************ OccTax faune "
$psqla -f $BASE_DIR/$parc/data/occtax_faune.sql -v srid_local=$srid_local
echo ""
echo "************************ OccTax flore "
$psqla -f $BASE_DIR/$parc/data/occtax_flore.sql -v srid_local=$srid_local
echo ""
echo "************************ Transfert synthese"
$psqla -f $BASE_DIR/$parc/data/synthese.sql -v srid_local=$srid_local
echo ""
echo "----------------------------------------------------------------------------"
echo "--------------------------------- Finalisation -----------------------------" 
echo "----------------------------------------------------------------------------"
echo ""
echo "************************ Corrections sur les métadonnées/synthese "
$psqla -f $BASE_DIR/$parc/data/correction_metadata.sql
echo "************************ Permissions "
$psqla -f $BASE_DIR/$parc/data/permissions_pag.sql

echo "************************ close fdw "
#$psqla -f $BASE_DIR/$parc/data/close_fdw.sql
>>>>>>> 83aeb523c0e9217697130a0682110cdd34bda999

echo "************************ Application de corrections "
$psqla -f $BASE_DIR/$parc/data/corrections_data.sql

<<<<<<< HEAD
echo "************************ close fdw "
#$psqla -f $BASE_DIR/$parc/data/close_fdw.sql
=======
echo "----------------------------------------------------------------------------"
echo "-------------------------------- Gna tout fini? ----------------------------" 
echo "----------------------------------------------------------------------------"
>>>>>>> 83aeb523c0e9217697130a0682110cdd34bda999
