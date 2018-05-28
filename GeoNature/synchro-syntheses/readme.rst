Cet exemple permet une synchronisation entre plusieurs synthèses GeoNature V1.

Dans cet exemple on connecte la BDD GeoNature d'un partenaire au GeoNature du PNE.

On peut envisager des mécanismes équivalents pour GeoNature V2.

On a créé un Foreign Data Wrapper (FDW) entre les deux BDD, un peu comme ça :

.. code:: sql

  --Sur le serveur du PNE, après création d'un utilisateur PostgreSQL dédié, GRANT des droits pour permettre la lecture sur les objets de la BDD pour cet utilisateur
  sudo su postgres
  for table in `echo "SELECT schemaname || '.' || relname FROM pg_stat_all_tables;" | psql geonaturedb | grep -v "pg_" | grep "^ "`;
  do
   echo "GRANT SELECT ON TABLE $table to afb;" 
   echo "GRANT SELECT ON TABLE $table to afb;" | psql geonaturedb
  done

  for schema in `echo "SELECT DISTINCT schemaname FROM pg_stat_all_tables;" | psql geonaturedb | grep -v "pg_" | grep "^ "`;
  do
   echo "GRANT USAGE ON SCHEMA $schema to myuserreader;" 
   echo "GRANT USAGE ON SCHEMA $schema to myuserreader;" | psql geonaturedb
  done

  --Sur le serveur local (partenaire)
  sudo -n -u postgres -s psql -d geonaturedb -c "CREATE EXTENSION IF NOT EXISTS postgres_fdw;"
  sudo -n -u postgres -s psql -d geonaturedb -c "CREATE SERVER geonaturepneserver FOREIGN DATA WRAPPER postgres_fdw OPTIONS (host 'ip', dbname 'geonaturedb', port '5432');"
  sudo -n -u postgres -s psql -d geonaturedb -c "CREATE USER MAPPING FOR geonatuser SERVER geonaturepneserver OPTIONS (user 'monuser', password 'pass');"
  sudo -n -u postgres -s psql -d geonaturedb -c "ALTER SERVER geonaturepneserver OWNER TO geonatuser;"

  CREATE SCHEMA synthesepne;
  IMPORT FOREIGN SCHEMA synthese
  FROM SERVER geonaturepneserver INTO synthesepne;

  CREATE MATERIALIZED VIEW synthesepne.vm_syntheseff AS
  SELECT * FROM synthesepne.syntheseff WHERE id_organisme = 2 AND supprime = false;
  CREATE UNIQUE INDEX i_id_synthesepne ON synthesepne.vm_syntheseff(id_synthese);

Voir aussi la documentation FWD (https://github.com/PnX-SI/Ressources-techniques/blob/master/Outils/FDW.rst).

Ensuite on importe la synthèse du PNE dans la synthèse dans la BDD locale (partenaire).

Le script ``synchro_syntheses.sql`` permet de mettre à jour la BDD locale (partenaire) et ne traiter dans la synthèse locale que le diff à partir des champs ``date_update`` et ``date_insert``.

Le script ``synchro_syntheses.sh`` permet de lancer le SQL et de loguer les résultats. 

Il peut être lancé automatiquement à intervalles réguliers avec un cron.
