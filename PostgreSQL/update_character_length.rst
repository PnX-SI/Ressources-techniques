Petit script utilitaire pour mettre à jour la longueur d'un champs qui dépend de nombreuses vues sans toucher à la structure de la table :

- Se connecter en ligne de commande avec le super-utilisateur (``postgres`` par exemple) :
::

  sudo su postgres

- Se connecter à la base de données :
::

  psql -d <NOM_BASE>

- Exécuter cette commande :
::

  UPDATE pg_attribute SET atttypmod = 500+4
  WHERE attrelid = '<SCHEMA_NAME>.<TABLE_NAME>'::regclass
  AND attname = '<FIELD_NAME>';

NB: il faut rajouter +4 au nombre initial (fonctionnement interne de PG)

Source : https://sniptools.com/databases/resize-a-column-in-a-postgresql-table-without-changing-data/
