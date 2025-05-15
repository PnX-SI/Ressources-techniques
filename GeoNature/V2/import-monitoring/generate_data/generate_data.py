from pprint import pprint as print
from gn_module_monitoring.config.repositories import get_config
from geonature.app import create_app
from pypnnomenclature.repository import get_nomenclature_list
import pandas as pd
import random
import math
import uuid
import requests
from lorem_text import lorem
from faker import Faker

fake = Faker()
import argparse


def return_generator(field_data, min_=False, max_=False):
    if not "type_widget" in field_data:
        return
    type_widget = field_data["type_widget"]
    if type_widget == "number":
        return lambda: random.randint(0, 100)
    if type_widget == "integer":
        return lambda: random.randint(0, 100)
    if type_widget == "nomenclature":
        return lambda: random.choice(
            nomenclature_per_type[field_data["code_nomenclature_type"]]
        )
    if type_widget == "select":
        return lambda: random.choice(field_data["values"])
    if type_widget in ["text", "textarea", "html"]:
        if "type_util" in field_data and field_data["type_util"] == "nomenclature":
            return lambda: random.choice(
                nomenclature_per_type[field_data["value"]["code_nomenclature_type"]]
            )
        return lambda: lorem.words(random.randint(0, 50))
    if type_widget == "bool_checkbox":
        return lambda: bool(random.randint(0, 1))
    if type_widget == "date":
        if min_ in field_data:
            return lambda: fake.date_between(
                start_date="today", end_date="-30d"
            ).strftime("%d/%m/%Y")
        if max_:
            return lambda: fake.date_between(
                start_date="today", end_date="+30d"
            ).strftime("%d/%m/%Y")
        return lambda: fake.date(pattern="%d/%m/%Y")

    if type_widget == "time":
        return lambda: fake.time()
    if type_widget == "observers":
        return lambda: fake.name()
    return


def randfloat(a, b):
    return random.random() * random.randint(a, b)


def fill_dataframe_with_specificfields_random_data(
    dataframe: pd.DataFrame, specific_field_entity_data: dict
) -> None:
    for field_name, field_data in specific_field_entity_data.items():
        generator = return_generator(field_data)
        if generator:
            dataframe[field_name] = dataframe.apply(lambda row: generator(), axis=1)
    ## To ensure min max coherence
    for field_name, field_data in specific_field_entity_data.items():
        if (
            "_min" in field_name
            and field_name.strip("_min") + "_max" in specific_field_entity_data
        ):
            if field_data["type_widget"] in ("number", "integer"):
                dataframe[field_name.strip("_min") + "_max"] = dataframe[
                    field_name
                ].apply(lambda x: x + random.randint(0, 5))
            if field_data["type_widget"] in ("date"):

                dataframe[field_name.strip("_min") + "_max"] = dataframe[
                    field_name
                ].apply(
                    lambda x: fake.date_between(start_date=x, end_date="+30d").strftime(
                        "%d/%m/%Y"
                    )
                )


parser = argparse.ArgumentParser(
    "Génération de données d'import pour les protocoles monitorings"
)

parser.add_argument("name_protocol", help="Nom du protocole monitoring")
parser.add_argument(
    "--cdnom-parent",
    help="CdNom du taxon parent permettant de générer la liste de taxon utilisée",
    default=186233,
    type=int,
)
parser.add_argument(
    "--size-dataset",
    default=100,
    type=int,
    help="Nombre de lignes du fichier de sortie",
)

parser.add_argument(
    "-s", "--site-nb", default=2, type=int, help="Nombre de sites à générer"
)
parser.add_argument(
    "-v",
    "--visite-nb",
    default=4,
    type=int,
    help="Nombre de visites par site à générer",
)
parser.add_argument(
    "-o",
    "--observation-nb",
    default=2,
    type=int,
    help="Nombre d'observations par site à générer",
)


## Fetch protocole configuration
params = parser.parse_args()


PROTOCOLE_ID = params.name_protocol
SIZE_FILE = params.size_dataset

NB_SITES = params.site_nb
NB_VISIT_PER_SITE = params.visite_nb
NB_OBS_PER_VISIT = params.observation_nb

if SIZE_FILE > NB_SITES * NB_VISIT_PER_SITE * NB_OBS_PER_VISIT:
    SIZE_FILE = NB_SITES * NB_VISIT_PER_SITE * NB_OBS_PER_VISIT
CD_NOM_PARENT = params.cdnom_parent

app = create_app()


with app.app_context():
    # Fetch protocole configuration
    protocole_data = get_config(PROTOCOLE_ID)
    if not protocole_data:
        raise Exception(f"No config found for the protocole named {PROTOCOLE_ID}")

    ## Fetch all nomenclature available per declared nomenclature type
    nomenclature_per_type = {}
    for type_code_nomenc in protocole_data["data"]["nomenclature"]:
        available_nomenclature = get_nomenclature_list(code_type=type_code_nomenc)[
            "values"
        ]
        nomenclature_per_type[type_code_nomenc] = [
            nomenclature_data["mnemonique"]
            for nomenclature_data in available_nomenclature
        ]

## Fetch Taxon list using Taxref official API
response = requests.get(url=f"https://taxref.mnhn.fr/api/taxa/{CD_NOM_PARENT}/children")
list_taxon = [
    taxon_data["id"] for taxon_data in response.json()["_embedded"]["taxa"]
] + [CD_NOM_PARENT]


## Generate site data
site_protocole_data = protocole_data["site"]
site_specific_fields = site_protocole_data["specific"]
SITE_UUID_NAME_FIELD = site_protocole_data["uuid_field_name"]

df_sites = pd.DataFrame([])
df_sites[SITE_UUID_NAME_FIELD] = [uuid.uuid4() for _ in range(NB_SITES)]
df_sites["base_site_code"] = df_sites.apply(
    lambda row: f"{PROTOCOLE_ID}_{row.name}", axis=1
)
df_sites["altitude_min"] = df_sites.apply(lambda x: random.randint(0, 1800), axis=1)
df_sites["altitude_max"] = df_sites.altitude_min.apply(
    lambda x: x + random.randint(0, 50)
)
df_sites["description"] = df_sites.apply(
    lambda x: lorem.words(random.randint(0, 20)), axis=1
)
df_sites["x"] = df_sites.apply(
    lambda x: random.random() * random.randint(-180, 180), axis=1
)
df_sites["y"] = df_sites.apply(
    lambda x: random.random() * random.randint(-90, 90), axis=1
)
df_sites["WKT"] = df_sites.apply(lambda row: f"POINT({row.x} {row.y})", axis=1)
df_sites["id_inventor"] = 1


fill_dataframe_with_specificfields_random_data(df_sites, site_specific_fields)

## GENERATE VISITE DATA
visit_protocole_data = protocole_data["visit"]
visit_specific_fields = visit_protocole_data["specific"]
VISIT_UUID_NAME_FIELD = visit_protocole_data["uuid_field_name"]

df_visits = pd.DataFrame([])
df_visits[VISIT_UUID_NAME_FIELD] = [
    uuid.uuid4() for _ in range(NB_VISIT_PER_SITE * NB_SITES)
]
df_visits["date_min"] = pd.date_range(
    start="01/01/2024", end="01/12/2024", periods=len(df_visits)
)
df_visits["date_max"] = df_visits.date_min.apply(
    lambda x: x + pd.DateOffset(days=random.randint(0, 5), hour=random.randint(0, 5))
)
df_visits["nb_obs"] = df_visits.apply(lambda row: random.randint(0, 10), axis=1)
df_visits["observers_txt"] = df_visits.apply(lambda x: fake.name(), axis=1)
df_visits[SITE_UUID_NAME_FIELD] = random.choices(
    df_sites[SITE_UUID_NAME_FIELD].tolist(), k=len(df_visits)
)

fill_dataframe_with_specificfields_random_data(df_visits, visit_specific_fields)


# GENERATION OBSERVATION DATA

obs_protocole_data = protocole_data["observation"]
obs_specific_fields = obs_protocole_data["specific"]
OBS_UUID_NAME_FIELD = obs_protocole_data["uuid_field_name"]

df_obs = pd.DataFrame([])
df_obs[OBS_UUID_NAME_FIELD] = [
    uuid.uuid4() for _ in range(NB_VISIT_PER_SITE * NB_OBS_PER_VISIT * NB_SITES)
]
df_obs["cd_nom"] = random.choices(list_taxon, k=len(df_obs))
df_obs[VISIT_UUID_NAME_FIELD] = random.choices(
    df_visits[VISIT_UUID_NAME_FIELD].tolist(), k=len(df_obs)
)

fill_dataframe_with_specificfields_random_data(df_obs, obs_specific_fields)


# GENERATE FINAL DATAFRAME
df_final = pd.merge(df_sites, df_visits, how="right", on=SITE_UUID_NAME_FIELD)
df_final = pd.merge(df_final, df_obs, how="right", on=VISIT_UUID_NAME_FIELD)

# WRITE IN A CSV
df_final.to_csv(f"{PROTOCOLE_ID}_{SIZE_FILE}.csv", sep=";", index=False)
