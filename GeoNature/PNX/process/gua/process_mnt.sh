# usage ./process_mnt.sh <geonature
parc=$1
. set_config.sh $parc
cd $parc
echo process mnt
$psqla -c 'DELETE FROM ref_geo.dem'
$psqla -c 'DELETE FROM ref_geo.dem_vector'
echo lecture mnt
raster2pgsql -s $srid_local -c -C -I -M -d -t 5x5 ref_geo/fusionne.tif ref_geo.dem|$psqla > out
echo vectorisation mnt
$psqla -c "INSERT INTO ref_geo.dem_vector (geom, val) SELECT (ST_DumpAsPolygons(rast)).* FROM ref_geo.dem;"
echo index mnt
$psqla -c "REINDEX INDEX ref_geo.index_dem_vector_geom;"
echo mnt terminé
cd $cur