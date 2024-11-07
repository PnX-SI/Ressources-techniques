# gbif2pg

Fonction permettant de récupérer de façon incrémentale les données du GBIF.

# Pré-requis
- Postgis

# Procédure de première intégration
- Depuis le GBIF demander la génération d'un fichier au format **Darwin Core Archive** (appliquer les filtre selon les cas)
- Lorsque le fichier est généré, le télécharger puis le dezziper
- Renomer le fichier occurrence.txt en occurrence.csv
- Intégrer les données avec ogr2ogr (en adaptant les variable entre < >) :
```sh
$ ogr2ogr -f PostgreSQL PG:"host=<HOST> user=<DB_USER> dbname=<DB_NAME> password=<DB_PASSWORD>" -oo AUTODETECT_TYPE=YES -oo SEPARATOR=TAB -nln gbif2pg.tmp_occurrence_first_import occurrence.csv
```

- Depuis PostgreSQL Lancer la procédure gbif2pg.first_import en adaptant les paramètres
```sql
CALL gbif2pg.first_import('<SchemaName>', '<OccurrenceTablename>', '<DatasetTableName>');
```
Le script gbif2pg.first_import va créer le schéma s'il n'existe pas ainsi que la table occurrence et dataset puis intégrer les données dedans.

# Lancement d'une synchro incrémentale

Lancer la requête 

```sql
CALL gbif2pg.sync_from_gbif('<SchemaName>', '<OccurrenceTablename>', '<DatasetTableName>', '<filter>');
```

Adapter les paramètres de sorte que SchemaName, OccurrenceTablename et DatasetTableName correspondent à ce qui a été renseigné lors de la première intégration.

Les filtre peuvent être paramétré tel qu'attendu pas l'API GBIF

exemple : 
```
classKey=212&occurrenceStatus=PRESENT&country=GP
```
Avec :
- classKey=212 : Filtre sur les oiseaux uniquement, 
- occurrenceStatus=PRESENT : ne récupère que les données de présence
- country=GP : ne récupère que les donénes de Guadeloupe (répété le filtre country=XXX si on veutr les données sur plusieurs territoire ex : country=GP&country=GF pour avoir les données de Guadeloupe et de Guyanne)
