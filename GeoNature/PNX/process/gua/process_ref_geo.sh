# usage .install_grid.sh <geonature
parc=$1
set -e
. set_config.sh $parc
cd $parc
# Grilles 

# - SHP MNHM

# - - 10x10
echo 'Grille 10x10'
ls
shp_file='ref_geo/GLP_UTM20N10X10.shp'
table="ref_geo.tmp_gua10x10"
type_code=M10
taille_maille=10km
${psqla} -c "DROP TABLE IF EXISTS ${table}"
shp2pgsql -s ${srid_local} -D -I ${shp_file} ${table} | ${psqla}
#INSERT
$psqla -f data/insert_grid_shp.sql -v type_code=$type_code -v table=$table -v taille_maille=$taille_maille

# - - 5x5
echo 'Grille 5x5'
shp_file='ref_geo/GLP_UTM20N5X5.shp'
table="ref_geo.tmp_gua5x5"
type_code=M5
taille_maille=5km
${psqla} -c "DROP TABLE IF EXISTS ${table}"
shp2pgsql -s ${srid_local} -D -I ${shp_file} ${table} | ${psqla}
#INSERT
$psqla -f data/insert_grid_shp.sql -v type_code=$type_code -v table=$table -v taille_maille=$taille_maille

# - - 1x1
echo 'Grille 1x1'
gpkg_file=ref_geo/grille1km_971.gpkg
table="ref_geo.tmp_gua1x1"
type_code=M1
taille_maille=1km
${psqla} -c "DROP TABLE IF EXISTS ${table}"
ogr2ogr -f PostgreSQL PG:"dbname='${db_name}' host='${db_host}' port='${db_port}' user='${user_pg}' password='${user_pg_pass}'" ${gpkg_file} -nln ${table}

$psqla -f data/insert_grid_gpkg.sql -v type_code=$type_code -v table=$table -v taille_maille=$taille_maille


#- -  clean grid (on enleve les mailles qui n'intersectent pas les 1x1)
$psqla -f data/clean_grid.sql


# COMMUNES
shp_file=ref_geo/bd_topo_2015_commune_971.shp
table="ref_geo.tmp_communes"
${psqla} -c "DROP TABLE IF EXISTS ${table}"
shp2pgsql -s ${srid_local} -D -I ${shp_file} ${table} | ${psqla}
$psqla -f data/insert_communes.sql

# LIMITE COEUR ET ZONAGE, AA et AMA
${psqla} -c "DROP TABLE IF EXISTS ref_geo.tmp_coeur"
shp2pgsql -s ${srid_local} -D -I ref_geo/coeur_png.shp ref_geo.tmp_coeur | ${psqla}
${psqla} -c "DROP TABLE IF EXISTS ref_geo.tmp_aa"
shp2pgsql -s ${srid_local} -D -I ref_geo/airedadhesion.shp ref_geo.tmp_aa | ${psqla}
${psqla} -c "DROP TABLE IF EXISTS ref_geo.tmp_ama"
shp2pgsql -s ${srid_local} -D -I ref_geo/airemarineadjacente.shp ref_geo.tmp_ama | ${psqla}
$psqla -f data/insert_limites.sql

# MNT
$psqla -c 'DELETE FROM ref_geo.dem'
$psqla -c 'DELETE FROM ref_geo.dem_vector'
echo lecture mnt
raster2pgsql -s $srid_local -c -C -I -M -d -t 5x5 ref_geo/fusionne.tif ref_geo.dem|$psqla > a.out
echo vectorisation mnt
$psqla -c "INSERT INTO ref_geo.dem_vector (geom, val) SELECT (ST_DumpAsPolygons(rast)).* FROM ref_geo.dem;"
echo index mnt
$psqla -c "REINDEX INDEX ref_geo.index_dem_vector_geom;"
echo mnt terminé

cd $cur