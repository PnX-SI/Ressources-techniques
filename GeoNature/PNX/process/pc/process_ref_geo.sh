# usage .install_grid.sh <geonature
parc=$1

BASE_DIR=$(readlink -e "${0%/*}")/..
. $BASE_DIR/utils.sh
init_config $parc
. $BASE_DIR/config/config.ini
. $BASE_DIR/config/$parc.ini


# CLEAN l_areas ??? (enveloppe choisie)
$psqla -c "
create table tmp_truc as SELECT st_transform(st_makeenvelope(5.5,42.8,7,43.7, 4326), 2154) AS env;
alter table ref_geo.l_areas disable trigger all;
delete from ref_geo.l_areas using tmp_truc t where not st_intersects(t.env, geom);
delete from ref_geo.li_grids g using (select g.id_area from ref_geo.li_grids g left join ref_geo.l_areas l on l.id_area = g.id_area WHERE l.id_area IS NULL)g1 WHERE g.id_area=g1.id_area; 
delete from ref_geo.li_municipalities g using (select g.id_area from ref_geo.li_municipalities g left join ref_geo.l_areas l on l.id_area = g.id_area WHERE l.id_area IS NULL)g1 WHERE g.id_area=g1.id_area; 
alter table ref_geo.l_areas enable trigger all;
drop table tmp_truc;
"

# LIMITES (fichiers fournis)
${psqla} -c "DROP TABLE IF EXISTS ref_geo.tmp_limites"
shp2pgsql -s ${srid_local} -D -I $BASE_DIR/${parc}/ref_geo/PNPC_delimitation_decret2012_charte_correction_2019/PNPC_delimitation_decret2012_charte_correction_2019.shp ref_geo.tmp_limites | ${psqla}
$psqla -f $BASE_DIR/${parc}/data/insert_limites.sql




# MNT
$psqla -c 'DELETE FROM ref_geo.dem'
$psqla -c 'DELETE FROM ref_geo.dem_vector'
echo lecture mnt
dem_sql=$BASE_DIR/$parc/ref_geo/dem.sql

w=25    

if [ ! -f $BASE_DIR/$parc/'ref_geo/out.tif' ]; then
    echo tiff -> tiff $w
    gdalwarp -tr $w $w $BASE_DIR/$parc/'ref_geo/Althy-Bathy_5m_Bandol-Sainte Maxime.tif' $BASE_DIR/$parc/ref_geo/out.tif

fi

if [ ! -f $dem_sql ]; then
    echo tiff -> sql
    raster2pgsql -s $srid_local -c -C -I -M -d -t ${w}x${w}  $BASE_DIR/$parc/ref_geo/out.tif ref_geo.dem > $dem_sql
fi


echo mnt sql
$psqla -f $dem_sql > $BASE_DIR/$parc/var/log/mnt.log
    
echo vectorisation mnt
$psqla -c "INSERT INTO ref_geo.dem_vector (geom, val) SELECT (ST_DumpAsPolygons(rast)).* FROM ref_geo.dem;"
echo index mnt
$psqla -c "REINDEX INDEX ref_geo.index_dem_vector_geom;"
echo mnt terminé
