# migration (en cours)

Pour la migration V1->V2

- Vérifier que les fichiers config.ini et pag/config/settings.ini sont ok. (cf [README GENERAL](../README.md))

- Creer le fichier settings_V1.ini avec les info pour les FDW vers le serveur

```
db_host_v1=localhost
db_port_v1=5432
db_name_v1=gn1_pag
user_pg_v1=joel
user_pg_pass_v1=jojoalba
```


- Aller dans le repertoire PAG et lancer `./migrations.sh`