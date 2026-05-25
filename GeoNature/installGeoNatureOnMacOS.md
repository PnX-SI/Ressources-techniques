# Installation de GeoNature sur macOS (Silicon)

Ce document explique comment installer GeoNature sur macOS. Il est principalement destiné aux développeurs qui souhaitent contribuer au projet GeoNature.

Version testée : macOS Sequoia 15.2

## Prérequis

- **Anaconda** : Anaconda est une distribution de Python permettant de gérer des environnements virtuels.
- **PostgreSQL** : PostgreSQL est une base de données relationnelle open source.
- **GDAL** : GDAL est une bibliothèque de traitement de données géographiques. Si Homebrew est installé, vous pouvez l'installer avec :
  ```shell
  brew install gdal
  ```

## Récupération du code GeoNature

Clonez le code source de GeoNature :

```shell
git clone https://github.com/PnX-SI/GeoNature
cd GeoNature
git submodule update --init
```

## Création de l'environnement virtuel avec Anaconda

GeoNature utilise `virtualenv` pour gérer les environnements virtuels. Cependant, ici, nous utilisons Anaconda.

Créez un environnement virtuel avec Anaconda :

```shell
conda create --name geonature python=3.11
```

Activez l'environnement virtuel :

```shell
conda activate geonature
```

Pour désactiver l'environnement virtuel Anaconda, utilisez :

```shell
conda deactivate
```

## Installation du backend

Cette section détaille l'installation du backend de GeoNature.

### Installation des dépendances

Installez les dépendances nécessaires :

```shell
conda install -c conda-forge glib
brew install gdal
conda install -c conda-forge pango
conda install psycopg2
cd backend
pip install -r requirements-dev.in
cd ..
```

> [!NOTE]
> Certaines dépendances présentent des problèmes d'installation avec `pip`. C'est pourquoi nous utilisons les versions disponibles sur les dépôts Anaconda.

### Installation de GeoNature

Depuis le répertoire principal, installez GeoNature en mode développement :

```shell
pip install -e .
```

### Configuration de GeoNature

GeoNature utilise un fichier de configuration nommé `geonature_config.toml`. Modifiez les paramètres en fonction de votre environnement :

```toml
SQLALCHEMY_DATABASE_URI = "postgresql://geonatadmin:geonatadmin@localhost:5432/geonature2db"
URL_APPLICATION = "http://127.0.0.1:4200"
API_ENDPOINT = "http://127.0.0.1:8000"

SECRET_KEY = "super_secret_key"

DEFAULT_LANGUAGE = "fr"

[HOME]
TITLE = "Bienvenue dans GeoNature"
INTRODUCTION = "Texte d'introduction, configurable pour le modifier régulièrement ou le masquer"
FOOTER = ""
```

### Exécution du backend

Démarrez le serveur backend de GeoNature :

```shell
geonature dev-back
```

> [!NOTE]
> Ne pas oublier de réactiver l'environnement virtuel pour chaque nouvelle session de terminal.

## Installation du client frontend (Angular)

### Installation de nvm

Installez `nvm` pour gérer les versions de Node.js :

```shell
brew install nvm
```

### Installation du frontend

Accédez au répertoire frontend, utilisez la version appropriée de Node.js et installez les dépendances :

```shell
cd frontend
nvm use
npm install
```

### Configuration de l'API Endpoint

Pour relier le frontend à l'API, exécutez les commandes suivantes :

```shell
api_end_point=$(geonature get-config API_ENDPOINT)
api_end_point=${api_end_point/'http:'/''}
echo "Set API_ENDPOINT to "$api_end_point" in frontend configuration file..."
echo '{"API_ENDPOINT":"'${api_end_point}'"}' > frontend/src/assets/config.json
```

### Exécution du frontend

Démarrez l'application Angular :

```shell
cd frontend
nvm use
npm run start
# ou le raccourci `make front` disponible depuis la 2.15.2
```

## Installation de la base de données

### Ajout des extensions PostgreSQL nécessaires

#### Avec Docker

Créez un conteneur PostGIS avec :

```shell
docker run -d --name geopostgis -p 5432:5432 -e POSTGRES_USER=geonatadmin -e POSTGRES_DB=geonature2db -e POSTGRES_PASSWORD=geonatadmin postgis/postgis:17-3.5-alpine
```

> [!NOTE]  
> Les utilisateurs peuvent modifier la version de PostGIS en utilisant un tag différent (par exemple, `postgis/postgis:17-3.5`) mais aussi le nom de la base de données et le nom de l'utilisateur. Pour ne pas perdre les données, il est aussi conseillé de créer un volume.

Connectez-vous au conteneur en utilisant la commande suivante :

```shell
docker exec -it geopostgis bash
```

Puis, ouvrez la ligne de commande de postgreSQL en utilisant la commande suivante :

```shell
psql -U geonatadmin -d geonature2db
```

Puis, collez les commandes suivantes pour créer les extensions :

```sql
CREATE EXTENSION IF NOT EXISTS "hstore";
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_trgm";
CREATE EXTENSION IF NOT EXISTS "unaccent";
CREATE EXTENSION IF NOT EXISTS "ltree";
CREATE EXTENSION IF NOT EXISTS "postgis_raster";
```

#### Avec PostgreSQL local

Si vous utilisez une installation locale de PostgreSQL, créez l'utilisateur et la base de données, puis ajoutez les extensions :

```shell
sudo -u postgres createdb -E UTF8 geonature2db
sudo -u postgres psql -c "CREATE USER geonatadmin WITH PASSWORD 'geonatadmin';"
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE geonature2db TO geonatadmin;"
```

Tout comme pour la création de la base de données avec docker, lancer la commande suivante pour se connecter au psql de PostgreSQL :

    psql -U geonatadmin -d geonature2db

Ensuite, collez les mêmes commandes SQL pour créer les extensions :

```sql
CREATE EXTENSION IF NOT EXISTS "hstore";
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_trgm";
CREATE EXTENSION IF NOT EXISTS "unaccent";
CREATE EXTENSION IF NOT EXISTS "ltree";
CREATE EXTENSION IF NOT EXISTS "postgis_raster";
```

### Installation de la base de données minimale

Mettez à jour la base de données avec les dernières migrations et des données supplémentaires :

```shell
conda activate geonature
geonature db upgrade geonature@head -x local-srid=2154
geonature db autoupgrade -x local-srid=2154
geonature db upgrade ref_geo_fr_departments@head
geonature taxref import-v17 --taxref-region=fr

geonature db upgrade nomenclatures_taxonomie_data@head
geonature db upgrade geonature-samples@head
geonature sensitivity add-referential \
--source-name "Référentiel sensibilité TAXREF v17 20240325" \
--url https://geonature.fr/data/inpn/sensitivity/RefSensibiliteV17_20240325.zip \
--zipfile RefSensibiliteV17_20240325.zip \
--csvfile RefSensibilite_17.csv \
--encoding=utf-8
geonature sensitivity refresh-rules-cache
```

## Installation des dépendances pour le worker de GeoNature

Il faut installer redis. Pour ça deux possibilités, soit créer un conteneur Docker avec la commande suivante :

```shell
docker run -d --name georedis -p 6379:6379 redis
```

ou installé en local avec la commande suivante :

```shell
brew install redis
```

## Installation des contributions (Occtax, Occhab, Validation)

```shell
conda activate geonature
geonature install-gn-module contrib/occtax --build false --upgrade-db=true
geonature install-gn-module contrib/gn_module_occhab --build false --upgrade-db=true
geonature install-gn-module contrib/gn_module_validation --build false --upgrade-db=true
geonature permissions supergrant --group --nom "Grp_admin"
```
