"""
Script for create geospatial files (Shapefile, GeoPackage, GeoJson) from the Fiona librairie
"""
import datetime
import fiona
import uuid

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


def as_dict(row):
    feature_dict = {}
    for prop in config.EXPORT_SCHEMA['properties']:
        value = getattr(row, prop[0])
        if type(value) is uuid.UUID:
            value = str(value)
        feature_dict[prop[0]] = value
    return feature_dict


# database connection
engine = create_engine(config.URI_DB_CONNECTION)
conn = engine.connect()


with fiona.open(
    config.EXPORT_PATH,
    "w",
    layer="points",
    driver=config.EXPORT_FORMAT,
    schema=config.EXPORT_SCHEMA,
    crs=from_epsg(config.SRID),
) as dst:
    results = conn.execute(config.SQL_QUERY)
    for r in results:
        geom_geojson = wkb_to_geojson(r, config.GEOMETRY_COLUMN_NAME)
        feature = {
            "geometry": geom_geojson,
            "properties": as_dict(r)
        }
        dst.write(feature)
