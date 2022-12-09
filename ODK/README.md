# Récupération des données depuis un serveur ODK Central

## API documentation

https://odkcentral.docs.apiary.io

## Python : pyODK

https://github.com/getodk/pyodk

Client python permettant d'interagir avec un serveur ODK Central

Exemples d'utilisation : [Jupyter notebook](odk_api.ipynb)

## ODK2GN : récupération des données de ODK et importation dans une base de données GeoNature

https://github.com/PnX-SI/odk2gn

ODK2GN est un module python utilisant les modèles de GeoNature pour intégrer des données depuis l'API d'ODK Central vers la base de données de GeoNature, en utilisant pyODK.

Il permet actuellement d'importer des données collectées avec ODK vers le module Monitoring de GeoNature et de mettre à jour les listes de valeurs du formulaire ODK en fonction des données de la base de données GeoNature, en se basant sur les fichiers de configuration du module Monitoring.

![odk2gn Architecture](https://github.com/PnX-SI/odk2gn/raw/main/docs/img/archi_global.jpeg)


## PostgreSQL : Central2PG

Documentation détaillée de la mise en oeuvre de `central2pg` couplé avec `redash` : [Documentation](Central2PG.md)

## Python : Centralpy

https://github.com/pmaengineering/centralpy

Client python permettant d'interagir avec un serveur ODK central


### Exemple d'usage

Dans cette exemple il y a un couplage avec [csvkit](https://csvkit.readthedocs.io/en/latest/index.html) de façon à importer les données en base directement.

### Install python env

L'utilisation d'un virtual env n'est pas obligatoire

```sh
python3 -m venv venv
source venv/bin/activate
python3 -m pip install centralpy
python3 -m pip install psycopg2 csvkit
```

### Récupération des données depuis ODK Central

```sh
# ------------------------------
# Configuration
# ------------------------------
### Paramètres de connexion au serveur ODK
ODK_URL="ODK_URL"
ODK_USER="USER_MAIL"
ODK_PASS="USER_PASS"
# Liste des projets et formulaires que l'on souhaite récupérer
# 1 ligne = ID_PROJECT|NOM_FORM
ODK_PROJECTS_FORMS="
2|CEVENNES_SAISON_ESTIVAL_BILAN
2|CEVENNES_SAISON_ESTIVAL_EVENEMENT
"

### Paramètres propres à centralpy
CENTRALPY_CSV_DIR="/tmp/odk_csv"
CENTRALPY_ZIP_DIR="/tmp/odk_zip"
CENTRALPY_NB_DAYS=7


# ------------------------------
# Get data from ODK Central
# ------------------------------

for odk_form in $ODK_PROJECTS_FORMS; do
    ODK_PROJECT=$(echo $odk_form|cut -d"|" -f1)
    ODK_FORM_ID=$(echo $odk_form|cut -d"|" -f2)

    centralpy \
    --url ${ODK_URL} \
    --email ${ODK_USER} \
    --password ${ODK_PASS} \
    pullcsv \
    --project ${ODK_PROJECT} \
    --form-id ${ODK_FORM_ID} \
    --csv-dir ${CENTRALPY_CSV_DIR} \
    --zip-dir ${CENTRALPY_ZIP_DIR} \
    --keep ${CENTRALPY_NB_DAYS}
done
```


### Copie des données récupérées dans une base de données

```sh
### Paramètres de connexion à postgresql
PG_CONNEXION="postgresql://MON_USER:MON_PASS@MON_HOTE:5432/MA_DB"
PG_SCHEMA_NAME="SHEMA_NAME"

# ------------------------------
# Insert into db
# ------------------------------
for file in `ls ${CENTRALPY_CSV_DIR}/*.csv`; do
    formname=`basename ${file}`
    tablename=`echo "${formname%.*}" | tr '[:upper:]' '[:lower:]'`
    echo "insert ${tablename} into db"
    csvsql \
       --db ${PG_CONNEXION} \
       --db-schema ${PG_SCHEMA_NAME} \
       --tables $tablename \
       --insert --overwrite \
       --unique-constraint "KEY" \
       ${file}
done
```


## R package ruODK

Paquet R qui permet de récupérer les données d'ODK Central via les API ODATA et REST

https://github.com/ropensci/ruODK

![An ODK setup with ODK Build, Central, Collect, and
ruODK](https://www.lucidchart.com/publicSegments/view/952c1350-3003-48c1-a2c8-94bad74cdb46/image.png)

