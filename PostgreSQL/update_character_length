Petit script utilitaire pour mettre à jour la longueur d'un champs qui dépend de nombreuses vues sans toucher à la structure de la table:

se connecter en ligne de commande avec l'utilisateur postgres:
`sudo su postgres `
se connecter à sa base de l'atlas
`psql -d <NOM_BASE> `

executer cette commande:
```
UPDATE pg_attribute SET atttypmod = 500+4
WHERE attrelid = '<SCHEMA_NAME>.<TABLE_NAME>'::regclass
AND attname = '<FIELD_NAME>';
```
NB: il faut rajouter +4 au nombre initial (fonctionnement interne de PG)
