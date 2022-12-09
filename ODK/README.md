# Récupération des données depuis un serveur odk central

## API documentation

https://odkcentral.docs.apiary.io


## Python : pyodk
https://github.com/getodk/pyodk
Client python permettant d'interragir avec un serveur ODK central

Exemples d'utilisation : [Jupyter notebook](odk_api.ipynb)


## Postgresql : central2PG

https://github.com/mathieubossaert/central2pg

Fonctions PostgreSQL pemrettant d'interragir avec un serveir ODK Central à travers son API ODATA, pour la récupération des données et la gestion (mise à jour de formulaires)
![central2pg](https://user-images.githubusercontent.com/1642645/165459944-a8bfe56e-6cf3-410d-b337-70fe6d1e5ef3.png)


## Python : Centralpy
https://github.com/pmaengineering/centralpy
Client python permettant d'interragir avec un serveur ODK central


### Exemple d'usage
Dans cette exemple il y a un couplage avec [csvkit](https://csvkit.readthedocs.io/en/latest/index.html) de façon à importer les données en base directement



### Install python env
L'utilisation d'un virtual env n'est pas obligatoire
```sh
python3 -m venv venv
source venv/bin/activate
python3 -m pip install centralpy
python3 -m pip install psycopg2 csvkit
```

### Récupération des données depuis odk central
```sh
# ------------------------------
# Configuration
# ------------------------------
### Paramètres de connexion au serveur odk
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
# Get data from central
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
Paquet r qui permet de récupérer les données d'ock central via les api ODATA et REST

https://github.com/ropensci/ruODK

![An ODK setup with ODK Build, Central, Collect, and
ruODK](https://www.lucidchart.com/publicSegments/view/952c1350-3003-48c1-a2c8-94bad74cdb46/image.png)

