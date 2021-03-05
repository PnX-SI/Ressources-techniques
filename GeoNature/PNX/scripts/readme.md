# Commandes pratiques

## configuration

il faut créer et renseigner le fichier `settings.ini`.
```
parcs='xx yy'

ftp_xx='ftp://lgin_xx:password_xx@url_xx.xx'
ftp_xx='ftp://lgin_yy:password_yy@url_yy.yy'

```

# appliquer un script pour toutes les instances

./script_for_all.sh ./<script.sh>

## récupérer la config

```
./get_remote_config.sh xx
```

et

```
./script_for_all.sh ./get_remote_config.sh
```

permet de récupérer les configurations des différentes instances
ces dernière seront placées dans le dossier `./remote_config/xx/` pour le parc `xx`


## récupérer les logs

```
./get_logs.sh xx

```

## tester si les appli marchent

```
./test_apps.sh xx
```

et

Sort une ligne avec le parc, l'appli et le code retour si une des api appelée renvoie un code != 200.