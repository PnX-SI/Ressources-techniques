# Process ref_geo for

parc=$1

BASE_DIR=$(readlink -e "${0%/*}")/..

. $BASE_DIR/utils.sh
init_config $parc
# Communes depuis GeoTreck

# Suppression des communes existantes

# Insertions des communes depuis for/ref_geo/Communes_AOA_geotreck.shp

# nettoyage
$psqla -c "
    DROP TABLE IF EXISTS ref_geo.tmp_communes;
    DROP TABLE IF EXISTS ref_geo.tmp_coeur;
    DROP TABLE IF EXISTS ref_geo.tmp_ri;
"

# Communes
shp2pgsql -s ${srid_local} -D -I $BASE_DIR/$parc/ref_geo/Communes_AOA_geotrek.shp ref_geo.tmp_communes | ${psqla}
$psqla -f $BASE_DIR/$parc/data/insert_communes.sql

# Limites
shp2pgsql -s ${srid_local} -D -I $BASE_DIR/$parc/ref_geo/ContoursCoeurFINAL.shp ref_geo.tmp_coeur | ${psqla}
shp2pgsql -s ${srid_local} -D -I $BASE_DIR/$parc/ref_geo/perimetre_RI_13_02_2020.shp ref_geo.tmp_ri | ${psqla}
$psqla -f $BASE_DIR/$parc/data/insert_limites.sql

# MNT
$psqla -c '
    DELETE FROM ref_geo.dem;
    DELETE FROM ref_geo.dem_vector;
'

dem_sql=$BASE_DIR/$parc/ref_geo/dem.sql
if [ ! -f $dem_sql ]; then
    echo process raster file
    raster2pgsql -s $srid_local -c -C -I -M -d -t 25x25 $BASE_DIR/$parc/ref_geo/MNT_GIP.tif ref_geo.dem > $dem_sql
fi

$psqla -f $dem_sql > $BASE_DIR/$parc/var/log/mnt.log

# raster2pgsql -s $srid_local -c -C -I -M -d -t 25x25 ref_geo/MNT_GIP.tifref_geo.dem |$psqla > out
$psqla -c "INSERT INTO ref_geo.dem_vector (geom, val) SELECT (ST_DumpAsPolygons(rast)).* FROM ref_geo.dem;"
$psqla -c "REINDEX INDEX ref_geo.index_dem_vector_geom;"


