# Commandes pratiques

```
./get_remote_config.sh xx
```

et

```
./get_all_remote_config.sh
```

permet de récupérer les configurations des différentes instances
ces dernière seront placées dans le dossier `./remote_config/xx/` pour le parc `xx`

il faut créer et renseigner le fichier `ftp.ini`.
```
parcs='xx'
ftp_xx='ftp://xx:xx@xx'
```