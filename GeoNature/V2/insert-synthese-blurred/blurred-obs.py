"""
Disclaimer: This script needs to be improved!

You must source the geonature venv to use it as it uses
packages installed in this venv and the session db

Goal: chooses between 2 sensitive species and insert an obs 
randomly in a box centered on France into the synthese table.

There are 2 "insert to synthese" functions. One with ORM and 
the other with bluk_insert which is faster

Parameters of the script
    # List of available cd_nom, nom_cite to choose from
    cd_noms = [(240, "Pélobate brun (Le)"), (18437, "Écrevisse à pieds blancs")]
    # id of the dataset
    id_dataset = 3318
    # id of the source to be able to remove easily the inserted obs
    id_source = 1484
    # date min and max of the observation
    date_min = datetime.now()
    date_max = datetime.now()
    # box min max dimensions
    x_min, x_max = -0.72, 5.89
    y_min, y_max = 43.6, 49.12
    # Nb obs to insert
    target_nb_obs = 500_000
"""
import random
from datetime import datetime

import pyproj
from geoalchemy2.shape import from_shape, WKBElement
from shapely.geometry import Point
from shapely.ops import transform

from geonature.core.gn_synthese.models import Synthese
from geonature.utils.env import db


def get_geom(x_min: float, x_max: float, y_min: float, y_max: float) -> Point:
    x = random.uniform(x_min, x_max)
    y = random.uniform(y_min, y_max)
    return Point(x, y)


def create_synthese(
    geom: Point,
    cd_nom: int,
    nom_cite: str,
    date_min: datetime,
    date_max: datetime,
    id_source: int,
    id_dataset: int,
) -> dict:
    wgs84 = pyproj.CRS("EPSG:4326")
    lambert = pyproj.CRS("EPSG:2154")

    project = pyproj.Transformer.from_crs(wgs84, lambert, always_xy=True).transform
    geom_2154 = transform(project, geom)
    geom_4326 = from_shape(geom, 4326)
    geom_2154 = from_shape(geom_2154, 2154)
    synthese = {
        "id_source": id_source,
        "id_dataset": id_dataset,
        "cd_nom": cd_nom,
        "nom_cite": nom_cite,
        "the_geom_4326": geom_4326,
        "the_geom_point": geom_4326,
        "the_geom_local": geom_2154,
        "date_min": date_min,
        "date_max": date_max,
    }
    return synthese


def create_synthese_orm(
    geom: WKBElement,
    cd_nom: int,
    nom_cite: str,
    date_min: datetime,
    date_max: datetime,
    id_source: int,
    id_dataset: int,
) -> Synthese:
    synthese_dict = create_synthese(
        geom, cd_nom, nom_cite, date_min, date_max, id_source, id_dataset
    )
    synthese = Synthese(**synthese_dict)

    with db.session.begin_nested():
        db.session.add(synthese)

    return synthese


def remove(id_source: int):
    Synthese.query.filter_by(id_source=id_source).delete()
    db.session.commit()


def main():
    # -- Parameters --
    # List of available cd_nom, nom_cite to choose from
    cd_noms = [(240, "Pélobate brun (Le)"), (18437, "Écrevisse à pieds blancs")]
    # id of the dataset
    id_dataset = 3318
    # id of the source to be able to remove easily the inserted obs
    id_source = 1484
    # date min and max of the observation
    date_min = datetime.now()
    date_max = datetime.now()
    # box min max dimensions
    x_min, x_max = -0.72, 5.89
    y_min, y_max = 43.6, 49.12
    # Nb obs to insert
    target_nb_obs = 500_000

    # ----

    n = target_nb_obs
    while n > 0:
        n = n - 1000
        synthese_list = []
        for _ in range(min(1000, n)):
            cd_nom, nom_cite = random.choice(cd_noms)
            geom = get_geom(x_min, x_max, y_min, y_max)
            synth = create_synthese(
                geom=geom,
                cd_nom=cd_nom,
                nom_cite=nom_cite,
                date_min=date_min,
                date_max=date_max,
                id_source=id_source,
                id_dataset=id_dataset,
            )
            synthese_list.append(synth)
        db.session.bulk_insert_mappings(Synthese, synthese_list)
        print(f"Remaining {n}\r", end="")
        # Commit every 10000 rows, to avoid data loss
        if n % 10000 == 0:
            db.session.commit()
    db.session.commit()
    print(f"END! {n}")


if __name__ == "__main__":
    from geonature.app import create_app

    app = create_app()
    with app.app_context():
        main()
