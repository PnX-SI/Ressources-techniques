# Fonctions génériques d'import

Le script ``create_import_synthese.sql`` ajoute des fonctions permettant l'import de données dans la synthèse de GeoNature.

Elle permet de gérer les données de sources actives : 

* Insertion des données non présentes dans la synthèse
* Mise à jour des données qui ont été modifiées depuis la dernière synchro
* Suppression des données qui ne sont plus présentes dans la source

## Mécanisme import des données


Idée générale : Importer les données d'une table dans la table synthèse.

La table gn_imports.gn_imports_log stoke les actions d'imports :
* date de l'import
* nom de la table des données importées
* succès: oui/nom
* Nombre de données insérées, mises à jour, supprimées
* En cas d'erreur stocke le message d'erreur

## Fonction  gn_imports.import_static_source


```sql
 gn_imports.import_static_source(
    tablename character varying, -- Nom de la table où se situent les données à importer
    idsource integer, -- Identifiant de la source (gn_synthese.t_sources)
    iddataset integer -- Identifiant du dataset pour l'ensemble du jeux de données (optionel si champ id_dataset présent)
)
```

### Principe
La table source peut être : une table, une vue, une vue matérialisée ou une table étrangère (FDW).

La table source doit obligatoirement avoir le champ ```entity_source_pk_value``` et ce champ doit avoir des valeurs uniques qui permettent de remonter de façon non ambigue à la donnée d'origine. Ce champ est extrement important car il est utilisé pour la mise à jour des données.

La fonction va lire les champs présents dans la table source et construire dynamiquement une requête d'insert et d'update des données vers la synthèse (```gn_synthese.synthese```).

Si un champ de la synthèse à une valeur par défaut il sera pris en compte et inséré si la table comprend la colonne correspondante avec des valeurs null.

Un transtypage automatique est réalisé pour chaque champ.

Une fois l'import réalisé, la fonction insère un enregistrement dans la table ```gn_imports.gn_imports_log```.

Au préalable:
* les données la source doit être enregistrée dans la table ```gn_synthese.t_sources```
* le ou les jeux de données doivent être renseigné

Pour les jeux de données si un champ id_dataset est présent dans la table source alors les données seront associés au jeux de données spécifié. Sinon il faut passer un identifiant de jeux de données en paramètre qui sera attribué à l'ensemble des données importées.


### Import des observateurs

Si votre source a les observateurs en lien avec UsersHub il est possible de spécifier à l'import de peupler ```cor_observer_synthese```

Pour cela il faut que :
* la source est un champ ```ids_observateur``` de type array (int[])


## gn_imports.delete_static_source

```sql
gn_imports.delete_static_source(
    tablename character varying, -- Nom de la table où se trouvent les données à supprimer
    id_source integer -- Identifiant de la source concernées
)
```

### Principe
La table source doit obligatoirement avoir le champ entity_source_pk_value et ce champ doit avoir des valeurs uniques qui permettent de remonter de façon non ambigue à la donnée d'origine. Ce champ est extrement important car il est utilisé pour trouver les données à supprimer dans la table ```gn_synthese.synthese```.

La fonction va trouver et supprimer les données de la source indiqué qui correspondent a la liste d'identifiant du champ entity_source_pk_value.

Une fois l'import réalisé, la fonction insère un enregistrement dans la table ```gn_imports.gn_imports_log```.