# Mettre à jour PostgreSQL

## Intro

Il faut installer une autre version de PostgreSQL qui va tourner à coté de ta version 11 actuelle. 
Cette nouvelle version tournera alors sur un autre port (genre 5433). Tu peux verifier avec la commande `pg_lsclusters`.

- Tu backupes ta BDD dans ta version de PG actuelle. 
- Tu restaures ta BDD dans la version de PG plus récente.
- Tu branches ton application sur la BDD dans le PG récent.
- Entre temps tu peux switcher les ports de ton ancien PG vers le nouveau si tu veux que le nouveau PG soit accessible sur le port qu'utilisait l'ancien

C'est un peu délicat mais ça se fait bien. Si tu as bien géré les extensions, les utilisateurs postgresql, bien backup avec ou sans le propriétaire, etc... 
Voir la documentation de mise à jour de l'OS et de la BDD de Geotrek : https://github.com/PnX-SI/Ressources-techniques/blob/master/Geotrek/upgrade_ubuntu_18_24.md

## CBNA

Procédure CBNA : https://wiki-sinp.cbn-alpin.fr/serveurs/installation/db-srv/postgresql-config#mettre_a_jour_postgresql_ex_v11_vers_v15

Si PostgreSQL 11 est sur le port 5432 et PostgreSQL 15 sur le port 5433, il est possible de directement transférer les bases de la version 11 vers la 15 avec cette commande : 
`sudo -u postgres pg_dumpall -p 5432 | sudo -u postgres psql -d postgres -p 5433`.

`pg_dumpall` récupére tout de la BDD initiale.

----------

## PNC

Je fais pas à pas avec `pg_dumpall` (`--globals-only` ou  `--roles-only`) pour récupérer toutes les variables globales, puis je fais un dump et un restore des diffrérentes bases :

```
dump_and_restore_db()
{
    DB_NAME=$1
    export PGPASSWORD=$PASS_ORIG;pg_dump --username $USER_ORIG -Fc --host $SERVEUR_ORIG --port 5432 --username $USER_ORIG $DB_NAME > $DB_NAME.backup

    psql -d $DB_NAME -h localhost -U $USER_PG -d postgres -c "SELECT pg_terminate_backend(pg_stat_activity.pid) FROM pg_stat_activity WHERE pg_stat_activity.datname = '$DB_NAME'  AND pid <> pg_backend_pid();"
    psql -d $DB_NAME -h localhost -U $USER_PG -d postgres  -c "DROP DATABASE $DB_NAME;"
    psql -d $DB_NAME -h localhost -U $USER_PG  -d postgres -c "CREATE DATABASE $DB_NAME;"
    pg_restore  -F c -h localhost --username=$USER_PG -d $DB_NAME ${DB_NAME}.backup >  0.0_${DB_NAME}output_schema.log 2>&1
}
```
