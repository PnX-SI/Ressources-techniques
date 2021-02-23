# Commandes pratiques

## configuration

il faut créer et renseigner le fichier `ftp.ini`.
```
parcs='xx yy'

ftp_xx='ftp://lgin_xx:password_xx@url_xx.xx'
ftp_xx='ftp://lgin_yy:password_yy@url_yy.yy'

```

## récupérer la config

```
./get_remote_config.sh xx
```

et

```
./get_all_remote_config.sh
```

permet de récupérer les configurations des différentes instances
ces dernière seront placées dans le dossier `./remote_config/xx/` pour le parc `xx`

## tester si les appli marchent

```
./test_apps.sh xx
```

et

```
./test_all_apps.sh
```

Sortie, si une des api appelée renvoie un code != 200.