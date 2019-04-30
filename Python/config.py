URI_DB_CONNECTION = "postgresql://geonatadmin:monpassachanger@localhost:5432/geonature2db"

SQL_QUERY = """
SELECT date_min, observers, s.cd_nom, lb_nom, nom_vern, regne, phylum, 
classe, ordre, famille, ST_Transform(s.the_geom_point, 2154) as wkb, d.dataset_name, unique_id_sinp
FROM gn_synthese.synthese s
JOIN taxonomie.taxref t ON t.cd_nom = s.cd_nom 
JOIN gn_meta.t_datasets d ON d.id_dataset = s.id_dataset
"""

EXPORT_SCHEMA = {
    "geometry": "Point",
    "properties": [
        ("date_min", "date"),
        ("observers", "str"),
        ("cd_nom", "int"),
        ("lb_nom", "str"),
        ("nom_vern", "str"),
        ("regne", "str"),
        ("phylum", "str"),
        ("classe", "str"),
        ("ordre", "str"),
        ("famille", "str"),
        ("dataset_name", "str"),
        ('unique_id_sinp', 'str')
    ],
}

# value available: 'GPKG' (geopackage), 'ESRI Shapefile'
# please adapt the EXPORT_PATH extension when you change the format
EXPORT_FORMAT = 'GPKG'

SRID = 2154

EXPORT_PATH = "/tmp/test.gpkg"
