#! /bin/bash
. migratetoV2.ini
. ../../../config/settings.ini
echo $geonature1user

#Sur le serveur de GeoNature V2 : création du lien FDW avec la base GeoNature1 
sudo rm ../../../var/log/migratetov2.log
sudo touch ../../../var/log/migratetov2.log
sudo chmod 777 ../../../var/log/migratetov2.log

echo "************************ Création Foreign Data Wrapper" >> ../../../var/log/migratetov2.log
sudo -n -u postgres -s psql -d $db_name -c "CREATE EXTENSION IF NOT EXISTS postgres_fdw;" >> ../../../var/log/migratetov2.log
sudo -n -u postgres -s psql -d $db_name -c "DROP SERVER IF EXISTS geonature1server CASCADE;" >> ../../../var/log/migratetov2.log
sudo -n -u postgres -s psql -d $db_name -c "CREATE SERVER geonature1server FOREIGN DATA WRAPPER postgres_fdw OPTIONS (host '$geonature1host', dbname '$geonature1db', port '$geonature1port');" >> ../../../var/log/migratetov2.log
sudo -n -u postgres -s psql -d $db_name -c "CREATE USER MAPPING FOR $user_pg SERVER geonature1server OPTIONS (user '$geonature1user', password '$geonature1userpass');" >> ../../../var/log/migratetov2.log
sudo -n -u postgres -s psql -d $db_name -c "ALTER SERVER geonature1server OWNER TO $user_pg;" >> ../../../var/log/migratetov2.log

# Désactiver les triggers chronophage sur la synthèse
echo "************************ Désactiver les triggers chronophage sur la synthèse de GN255" >> ../../../var/log/migratetov2.log
export PGPASSWORD=$user_pg_pass;psql -h $db_host -U $user_pg -d $db_name -f 0_synthese_before_insert.sql  &>> ../../../var/log/migratetov2.log

echo "************************ Création des schémas & architectures v1_compat" >> ../../../var/log/migratetov2.log
echo "Create v1_compat schema and architecture"
export PGPASSWORD=$user_pg_pass;psql -h $db_host -U $user_pg -d $db_name -f 1_create_v1_compat.sql  &>> ../../../var/log/migratetov2.log

#schema utilisateurs
echo "************************ Import des utilisateurs" >> ../../../var/log/migratetov2.log
export PGPASSWORD=$user_pg_pass;psql -h $db_host -U $user_pg -d $db_name -f 2_users.sql  &>> ../../../var/log/migratetov2.log
echo "************************ Cadrage des permissions" >> ../../../var/log/migratetov2.log
export PGPASSWORD=$user_pg_pass;psql -h $db_host -U $user_pg -d $db_name -f 3_permissions.sql  &>> ../../../var/log/migratetov2.log
