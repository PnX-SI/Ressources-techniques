# Script de synchronisation de données de SICEN/Obs Occ vers GeoNature V2



- Les scripts doivent être lancés dans l'ordre
- Les scripts préfixés par obs_occ doivent être lancés dans la BDD obs_occ
- Les scripts préfixés par gn2 doivent être lancés dans la base

## Prérequis
* Avoir créer les fonctions d'imports et de synonymes

## Préparation de la synchronisation

### Modification d'obs occ:
* Rajout d'un uuid au niveau des observations de façon à ce que les observation aient un identifiant unique SINP
* Rajout d'un uuid au niveau des protocoles qui vont correspondre aux jeux de données dans géonature
* Création de vues spécifiques pour l'import dans géonature2

```
0.1_obs_occ_alter_model.sql
```

### Ajout des synonymes entre obs_occ et la nomenclature GN2

```
0.2_gn2_add_synonymes_data.sql
```
Attention le mapping n'est pas forcement au top et il y a des données qui ne correspondent pas à obs_occ

### Création d'un lien FDW entre obs_occ et GN2
* Création du server obs_occ
* Import des vues spécifiques pour l'import créées dans obs_occ

```
1.0_gn2_create_fdw_obs_occ.sql
```

Modifier les paramètres de connexion à la BDD PostgreSQK d'obs_occ/SICEN

### Import des "métadonnées"
* Import des jeux de données à partir de la table md.protocoles
* Source
```
1.2_gn2_import_obs_occ_metadata.sql
```

Script à adapter
* Modifier le calcul de la bounding box (pour le moment périmètre du PN). 
* Modifier les données créées dans ``gn_synthese.t_sources``
* L'identifiant du cardre d'acquisition est en dur ...

### Création des requêtes d'import de données
* Création des vues matérialisées qui seront utilisées comme table d'import

```
2.2_gn2_import_obs_occ_views.sql
```
Si les utilisateurs ne sont pas déjà importés dans le schéma utilisateurs et/ou que les identifiants ne sont pas les mêmes entre obs_occ et la BDD UsersHub, désactiver les lignes : 36 et 50


### Script d'import des données 
* Importation des données dans la synthese
```
2.3_gn2_sync_data.sql
```

A configurer pour que ce soit une tache cron

NB : lors du premier import il est préférable de "tronçoner" les imports de façon à traiter des los de données plus réduit ~10000. Pour ce faire il faut modifier la vue ```gn_imports.v_qry_synthese_obs_occ```

exemple import des données avec un identifiant inférieur à 1000
```
CREATE MATERIALIZED VIEW gn_imports.v_qry_synthese_obs_occ AS 
WITH data AS (
    SELECT e.* 
    FROM gn_imports.fdw_obs_occ_data e
    WHERE e.id_obs < 1000
)
SELECT [...]
FROM data d
JOIN gn_meta.t_datasets ds ON d.unique_dataset_id = ds.unique_dataset_id
JOIN taxonomie.taxref tx ON d.cd_nom::integer = tx.cd_nom
LEFT JOIN LATERAL ref_geo.fct_get_altitude_intersection(st_transform(st_setsrid(d.geometrie, 4326), 2154)) v(altitude_min, altitude_max) ON true
```