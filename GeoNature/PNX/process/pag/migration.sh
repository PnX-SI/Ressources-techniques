# Attention, il est conseille de travailler sur une copie de la base GNVA et non directement sur le serveur

clear
# s'arrete si erreur
set -e

# script de migration des données GNV1 vers GN2.6
parc=pag

echo "----------------------------------------------------------------------------"
echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>  Bascule GN1.9 >> GN2.6"
echo "- Intégration des données et référentiels historiques: depuis GN1.9"
echo "- Mise à jour des référentiels taxo (TaxRef v14 + ajout refs faune-flore)"
echo "- Création des droits et permissions utilisateurs"
echo "- Correction des métadonnées"
echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>  MAJ Data partenariales"
echo "- Remplacement des données avec JDD de juin 2021 : "
echo "    - Faune-Guyane (63586 données PAG) "
echo "    - Herbier de Cayenne (120820 données Guyane)"
echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>  Intégration data"
echo "- Intégration des données bota de Sébastien: base photo et CardObs"
echo "- Redistribution des données Faune-Guyane pour les études PAG"
echo "- Intégration de divers JDD liés aux ABC, protocoles habitats, etc..."
echo ""
echo ""
echo "----------------------------------------------------------------------------"
echo "-------------------------------- Initialisation ----------------------------" 
echo "----------------------------------------------------------------------------"
echo "************************ load config "

parc=pag
export BASE_DIR=$(readlink -e "${0%/*}")/..
. $BASE_DIR/utils.sh
init_config $parc

echo "************************ init config "
. $BASE_DIR/config/${parc}_v1.ini
export psqlv1="psql -d ${db_name_v1} -h ${db_host_v1} -U ${user_pg_v1} -p ${db_port_v1} -v ON_ERROR_STOP=1"


echo "************************ get taxref v14 file"
if [ ! -f  /tmp/taxhub/TAXREF_v14_2020.zip ]; then
    mkdir -p /tmp/taxhub
    wget http://geonature.fr/data/inpn/taxonomie/TAXREF_v14_2020.zip -P /tmp/taxhub
    unzip -o /tmp/taxhub/TAXREF_v14_2020.zip -d /tmp/taxhub
fi

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

echo "************************** Copie des fichiers csv dans tmp"
cp $BASE_DIR/$parc/integration_data/*.csv $BASE_DIR/$parc/csv/*.csv /tmp/.
echo ""


#echo "----------------------------------------------------------------------------"
#echo "-------------------------------- Refs Geo ----------------------------" 
#echo "----------------------------------------------------------------------------"
#./process_ref_geo.sh
echo ""
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
$psqla -f $BASE_DIR/$parc/data/taxonomie.sql
echo ""
echo "************************ Permissions "
$psqla -f $BASE_DIR/$parc/data/permissions_pag.sql
echo ""
echo "************************ Transfert metadonnées "
$psqla -f $BASE_DIR/$parc/data/metadonnee.sql
echo ""
echo "----------------------------------------------------------------------------"
echo "--------------------- Transfert données historiques ------------------------" 
echo "----------------------------------------------------------------------------"
echo "************************ OccTax faune "
$psqla -f $BASE_DIR/$parc/data/occtax_faune.sql -v srid_local=$srid_local
echo ""
echo "************************ OccTax flore "
$psqla -f $BASE_DIR/$parc/data/occtax_flore.sql -v srid_local=$srid_local
echo ""
echo "************************ Transfert synthese -hors Faune-Guyane et Herbier de Cayenne"
$psqla -f $BASE_DIR/$parc/data/synthese.sql -v srid_local=$srid_local
echo ""
echo "************************ Correspondance nomenclatures / csv Access"
$psqla -f $BASE_DIR/$parc/data/correspondance_nomenclature.sql
echo ""
echo "************************ Corrections/ajouts sur les métadonnées "
$psqla -f $BASE_DIR/$parc/data/correction_metadata.sql
echo ""
echo "----------------------------------------------------------------------------"
echo "------------------------ MAJ données partenariales -------------------------" 
echo "----------------------------------------------------------------------------"
echo "************************ Faune-Guyane 01/06/2021 >>>>> Synthese"
$psqla -f $BASE_DIR/$parc/data/4_import_FGjuin2021.sql
echo ""
echo "************************ Herbier de Cayenne 01/06/2021 >>>>> Synthese" 
$psqla -f $BASE_DIR/$parc/data/5_import_Herbierjuin2021.sql
echo ""
echo "----------------------------------------------------------------------------"
echo "--------------------------------- Ajout data -------------------------------" 
echo "----------------------------------------------------------------------------"
echo ""
echo "************************** BD photo & CardObs: Import données"
$psqla -f $BASE_DIR/$parc/data/1_import_data_seb.sql
echo "************************** BD photo: Import données géo"
shp2pgsql -s ${srid_local} -D -I -W "latin1" $BASE_DIR/$parc/integration_data/20201013_cartoLocalites_polygones.shp gn_imports.tmp_localitespoly_seb | ${psqla}
shp2pgsql -s ${srid_local} -D -I -W "latin1" $BASE_DIR/$parc/integration_data/20201013_cartoLocalites_lignes.shp gn_imports.tmp_localiteslignes_seb | ${psqla}
shp2pgsql -s ${srid_local} -D -I -W "latin1" $BASE_DIR/$parc/integration_data/20201013_cartoLocalites_points.shp gn_imports.tmp_localitespoints_seb | ${psqla}
echo "************************** BD photo Seb: Intégraton données"
$psqla -f $BASE_DIR/$parc/data/2_ajout_data_BDPhotoseb.sql
echo "************************** CardObs Seb: Intégraton données"
$psqla -f $BASE_DIR/$parc/data/3_ajout_data_CardObsSeb.sql
echo ""
echo "************************** ECOBIOS-Limonade"
echo ">>> import data geo"
shp2pgsql -s ${srid_local} -D -I -W "latin1" $BASE_DIR/$parc/integration_data/20210628_Localisation_Data_Ecobios.shp gn_imports.tmp_localitespoly_ecobios | ${psqla}
echo ">>> traitement données natu"
$psqla -f $BASE_DIR/$parc/data/6_Ecobios_Limonade.sql
echo ""
echo "************************** Itoupé, répartition données FG, intégration données ABC..."
$psqla -f $BASE_DIR/$parc/data/7_Data_Limonade_et_ABC.sql

echo "----------------------------------------------------------------------------"
echo "--------------------------------- Finalisation -----------------------------" 
echo "----------------------------------------------------------------------------"
$psqla -f $BASE_DIR/$parc/data/close_fdw.sql
$psqla -f $BASE_DIR/$parc/data/10_Drop_tables.sql
echo ""
echo ""
echo "----------------------------------------------------------------------------"
echo "------------------------------- JOB DONE !----------------------------------"
echo ">>>>>>>>>> Ne pas oublier >>>>>>>>>> envoyer photos seb dans static/..."
echo "----------------------------------------------------------------------------"
echo ""
echo ""
echo ""
echo ""

