"""
Script for create geospatial files (Shapefile, GeoPackage, GeoJson) from the Fiona librairie
"""
import fiona

from sqlalchemy import create_engine
from geoalchemy2.shape import to_shape
from fiona.crs import from_epsg
from geoalchemy2.shape import to_shape
from shapely.geometry import Point, Polygon, MultiPolygon, mapping
from shapely import wkb, wkt

import config


def wkb_to_geojson(row, wkb_col):
    """
    Return a Geojson from a row containing a wkb column
    """
    my_wkt = wkb.loads(getattr(row, wkb_col), hex=True)
    return mapping(my_wkt)


def wkt_to_geojson(row, wkt_col):
    """
    Return a Geojson from a row containing a wkt column
    """
    my_wkt = wkt.loads(getattr(row, wkt_col))
    return mapping(my_wkt)


def create_feature(row):
    pass


# database connection
engine = create_engine(config.URI_DB_CONNECTION)
conn = engine.connect()


query = """SELECT dateobs, observateurs, s.cd_nom, lb_nom, nom_vern, regne, phylum, 
classe, ordre, famille, nom_lot, ST_Transform(s.the_geom_point, 2154) as wkb
FROM synthese.syntheseff s
JOIN taxonomie.taxref t ON t.cd_nom = s.cd_nom 
JOIN meta.bib_lots lot ON lot.id_lot = s.id_lot
JOIN layers.foret_temp f ON ST_Intersects(f.geom, s.the_geom_local)
WHERE id_organisme = 2
AND date_part('year', dateobs) >= 1973
AND group2_inpn != 'Poissons'
AND s.cd_nom NOT IN (2645, 2869, 2860, 2852, 2856)
"""


with fiona.open(
    config.EXPORT_PATH,
    "w",
    layer="points",
    driver="GPKG",
    schema=config.EXPORT_SCHEMA,
    crs=from_epsg(config.SRID),
) as dst:
    results = conn.execute(query)
    for r in results:
        geom_geojson = wkb_to_geojson(r, "wkb")
        feature = {
            "geometry": geom_geojson,
            "properties": {
                "dateobs": r.dateobs.isoformat(),
                "observateurs": r.observateurs,
                "cd_nom": r.cd_nom,
                "lb_nom": r.lb_nom,
                "nom_vern": r.nom_vern,
                "regne": r.regne,
                "phylum": r.phylum,
                "classe": r.classe,
                "ordre": r.ordre,
                "famille": r.famille,
                "nom_lot": r.nom_lot,
            },
        }
        dst.write(feature)

