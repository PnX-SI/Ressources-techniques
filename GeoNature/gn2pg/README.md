# gn2pg
Fonction SQL permettant le téléchargement des données mises à disposition par une instance de GeoNature à travers un export

# Pré-requis
- GeoNature >= 2.13.0
- Module GeoNature-Export installé sur GeoNature >= 1.5.0
- PostgreSQL

# Installation
Executer le script SQL gn2pg_install.sql dans sa base de données locale.
Ce script créé un schéma *gn2pg*, une fonction *gn2pg.gn2pg(...)* et une table de logs *gn2pg.logs*.


# Principe de fonctionnement
Le script fonctionne selon le principe de *l'annule et remplace*.
A chaque lancement, la table de destination est supprimée et recréée lors de la récupération des données.
Le script récupère les 1000 premières lignes et crée la table de destination.
Puis il boucle par lot de 1000 lignes tant qu'il y a des données à récupérer pour alimenter la table.


**Le script n'est pas en capacité de connaitre la structure de la table d'origine. Toutes les données sont rentrées dans la base locale dans un type "text".
Une requête SQL spécifique (à créer) pour chaque export doit être jouée par l'administrateur de données afin de ré-attribuer les bons types de données.**

# Utilisation

## Simple
```sql
select gn2pg.gn2pg('<gn_domain>', <gn_export_id>, '<gn_export_token>', '<destination_schema>', '<destination_table>');
```
- gn_domain : Nom de domaine de l'instance GeoNature
- gn_export_id : Identfiant de l'export 
- gn_export_token : Token associé à l'export 
- destination_schema : Nom du schéma de destination dans la base locale
- destination_table : Nom de la table de destination dans la base locale

## Avec filtre(s)
Il est possible d'appliquer un filtre lors de l'appel des données
```sql
select gn2pg.gn2pg('<gn_domain>', <gn_export_id>, '<gn_export_token>', '<destination_schema>', '<destination_table>', '<filters>');
```
- filters : la valeur de filtre doit construit selon les préconisations du module gn_export :
  - nom_col=val: Si nom_col fait partie des colonnes de la vue alors filtre nom_col=val
  - ilikenom_col=val: Si nom_col fait partie des colonnes de la vue et que la colonne est de type texte alors filtre nom_col ilike '%val%'
  - filter_d_up_nom_col=val: Si nom_col fait partie des colonnes de la vue et que la colonne est de type date alors filtre nom_col >= val
  - filter_d_lo_nom_col=val: Si nom_col fait partie des colonnes de la vue et que la colonne est de type date alors filtre nom_col <= val
  - filter_d_eq_nom_col=val: Si nom_col fait partie des colonnes de la vue et que la colonne est de type date alors filtre nom_col == val
  - filter_n_up_nom_col=val: Si nom_col fait partie des colonnes de la vue et que la colonne est de type numérique alors filtre nom_col >= val
  - filter_n_lo_nom_col=val: Si nom_col fait partie des colonnes de la vue et que la colonne est de type numérique alors filtre nom_col <= val

Il est possible de combiner les filtres en les séparant par le caractère '&'

# Les logs
En cas d'anomalie, il est possible d'avoir des éléments de compréhension de l'erreur en affichant le contenu de la table de logs.

Trois types de logs existent (champ statut) :
- start : Indique le lancement du script 
- end : Indique la fin de l'execution du script
- error : Indique que le script à rencontreé une anomalie

Cette table n'est jamais vidée par le script.
