# Process ref_geo pag

parc=pag

BASE_DIR=$(readlink -e "${0%/*}")/..
. $BASE_DIR/utils.sh
init_config $parc

# Suppression des communes existantes

# Insertions des communes depuis for/ref_geo/Communes_AOA_geotreck.shp

# nettoyage
$psqla -c "
    DROP TABLE IF EXISTS ref_geo.tmp_coeur;
"

# Communes
# shp2pgsql -s ${srid_local} -D -I $BASE_DIR/$parc/ref_geo/Communes_AOA_geotrek.shp ref_geo.tmp_communes | ${psqla}
# $psqla -f $BASE_DIR/$parc/data/insert_communes.sql

# Limites
shp2pgsql -s ${srid_local} -D -I $BASE_DIR/$parc/ref_geo/PAG_ZA_Zcoeur.shp ref_geo.tmp_coeur | ${psqla}
$psqla -f $BASE_DIR/$parc/data/insert_limites.sql

# MNT
$psqla -c '
    DELETE FROM ref_geo.dem;
    DELETE FROM ref_geo.dem_vector;
'
raster2pgsql -s $srid_local -c -C -I -M -d -t 30x30 $BASE_DIR/$parc/ref_geo/MNT_SRTM30m/srtm_gf30_3l21.tif ref_geo.dem|$psqla > out
$psqla -c "INSERT INTO ref_geo.dem_vector (geom, val) SELECT (ST_DumpAsPolygons(rast)).* FROM ref_geo.dem;"
$psqla -c "REINDEX INDEX ref_geo.index_dem_vector_geom;"


