URI_DB_CONNECTION = "postgresql://<USER>:<PASS>@<IP>:<PORT>/<DB>"

SQL_QUERY = """
SELECT dateobs, observateurs, s.cd_nom, lb_nom, nom_vern, regne, phylum, 
classe, ordre, famille, ST_Transform(s.the_geom_point, 2154) as wkb
FROM synthese.syntheseff s
JOIN taxonomie.taxref t ON t.cd_nom = s.cd_nom 
"""

EXPORT_SCHEMA = {
    "geometry": "Point",
    "properties": [
        ("dateobs", "date"),
        ("observateurs", "str"),
        ("cd_nom", "int"),
        ("lb_nom", "str"),
        ("nom_vern", "str"),
        ("regne", "str"),
        ("phylum", "str"),
        ("classe", "str"),
        ("ordre", "str"),
        ("famille", "str"),
    ],
}

SRID = 2154

EXPORT_PATH = "/tmp/my_file.gpkg"

