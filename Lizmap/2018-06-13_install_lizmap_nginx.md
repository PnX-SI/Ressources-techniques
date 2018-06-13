# Installation de Lizmap (Nginx et PHP-FPM) #

Ce guide montre une méthode d'installation de [Lizmap](https://www.3liz.com/lizmap.html) sur un serveur Debian9 (Stretch) en utilisant un serveur web Nginx et PHP-FPM.

La majorité des commandes faites par la suite s'effectuent en root ou en utilisant `sudo`.

## Installation des paquets ##
### Nginx et PHP-FPM ###

Tout d'abord, on installe les paquets nécessaires au fonctionnement de Nginx et PHP-FPM:
    
    apt-get update
    apt-get install nginx fcgiwrap php7.0-fpm 

### Autres paquets ###

Pour fonctionner, Lizmap nécessite d'autres paquets annexes.

    apt-get install curl php7.0 php7.0-sqlite3 php7.0-gd php7.0-xml php7.0-curl 
    
### QGIS Server ###

QGIS fournit une URL 'HTTPS' pour installer QGIS Server, si on souhaite l'utiliser, il faut ajouter un paquet pour `apt` :

    apt install apt-transport-https
    
Il faut ensuite ajouter les dépôts QGIS:
	
	cd /etc/apt/sources.list.d
	nano qgis.list
	
A ce moment là, il faut écrire dans le fichier `qgis.list`:

	deb https://qgis.org/debian-ltr stretch main
	deb-src https://qgis.org/debian-ltr stretch main
        
Pour installer via les dépôts QGIS, il faut ajouter la clé publique du dépôt qgis.org à votre trousseau `apt` en tapant: 
        
	wget -O - https://qgis.org/downloads/qgis-2017.gpg.key | gpg --import
	gpg --export --armor CAEB3DC3BDF7FB45 | apt-key add -
	
De là, il sera possible d'installer les paquets pour QGIS Server:
	
	apt update
	apt-get install qgis-server python-qgis
	
## Installation de Lizmap ##

On récupère le dossier d'installation:

	cd /var/www/
	MYAPP=lizmap-web-client
	VERSION=3.2beta2
	wget https://github.com/3liz/$MYAPP/archive/$VERSION.zip
	unzip $VERSION.zip
	mv /var/www/$MYAPP-$VERSION /var/www/$MYAPP
	ln -s /var/www/$MYAPP/lizmap/www/ /var/www/html/lm
	rm $VERSION.zip
	
On active les fichiers de configurations:
	
	cd /var/www/$MYAPP/lizmap/var/config
	cp lizmapConfig.ini.php.dist lizmapConfig.ini.php
	cp localconfig.ini.php.dist localconfig.ini.php
	cp profiles.ini.php.dist profiles.ini.php

Si l'on veut activer le répertoire de démo, on ajoute à `localconfig.ini.php`:

	[modules]
	lizmap.installparam=demo

On donne les droits d'accès au script afin que PHP puisse écrire des fichiers temporaires:

	cd ../../..
	lizmap/install/set_rights.sh www-data www-data

On peut alors lancer l'installeur:

	php lizmap/install/installer.php
	
### Remarque ###

Si l'installation renvoie des erreurs de version Jelix, ressayer toute l'installation de Lizmap en allant chercher directement sur github la version voulue.

	
## Configuration de Nginx ##

Il faut configurer Nginx pour qu'il puisse utiliser PHP-FPM.

	cd /etc/nginx/sites-available
	mv default default.backup
	nano default
	
Écrire à l'intérieur:

	 # Lizmapmutu hosting site
	 # Give access to accounts
	 server {
		listen 80 default_server;
		listen [::]:80 default_server ipv6only=on;

	    server_name _;

		index index.html index.php;
		root /var/www/html;
		
		access_log /var/log/lizmap.access.log;
		error_log /var/log/lizmap.error.log;

	    location / {
	    	root /var/www/html;
	     }

		# URI resolved to web sub directory
		# and found a index.php file here
		location ~* /\w+\.php {
			fastcgi_split_path_info ^(.+\.php)(/.+)$;
			set $path_info $fastcgi_path_info; # because of bug http://trac.nginx.org/nginx/ticket/321
			
			try_files $fastcgi_script_name =404;
			include fastcgi_params;
			
			fastcgi_index index.php;
			fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
			fastcgi_param SERVER_NAME lizmap;
			fastcgi_param PATH_INFO $path_info;
			fastcgi_param PATH_TRANSLATED $document_root$path_info;
			fastcgi_pass unix:/run/php/php7.0-fpm.sock;
		}

	}

Ensuite, créer un fichier similaire pour QGIS Server:

	nano qgis-server

Et écrire à l'intérieur:

	server {
		listen 8200 default_server;
		listen [::]:8200 default_server;
	
		root /var/www/html;
	
		# Add index.php to the list if you are using PHP
		index index.html index.htm index.php;
	
		server_name qgis;
	
		location / {
			# First attempt to serve request as file, then
			# as directory, then fall back to displaying a 404.
			try_files $uri $uri/ =404;
		}
	
        access_log /var/log/qgis.access.log;
        error_log /var/log/qgis.error.log;
	
		client_body_timeout 1200;
        client_header_timeout 600;
	
		location /qgis_218 {
			gzip           off;
			include        fastcgi_params;
			#fastcgi_param  PGSERVICEFILE /home/www-data/.pg_service.conf;
			fastcgi_pass   unix:/var/run/fcgiwrap.socket;
			fastcgi_param  SCRIPT_FILENAME /usr/lib/cgi-bin/qgis_mapserv.fcgi;
            fastcgi_param  QGIS_SERVER_LOG_FILE /var/log/qgis.log;
	        fastcgi_param  QGIS_SERVER_LOG_LEVEL 2;
			#fastcgi_param  DISPLAY       ":99";
		}
	}

Il faut ensuite créer un lien symbolique entre `sites-available` et `sites-enabled`:

	rm /etc/nginx/sites-enabled/default
	ln -s /etc/nginx/sites-available/default /etc/nginx/sites-enabled/default
	ln -s /etc/nginx/sites-available/qgis-server /etc/nginx/sites-enabled/qgis-server
	
Et recharger la configuration de Nginx:

	service nginx restart

## Test ##

Si l'installation de Lizmap, des paquets et des configurations se sont bien déroulées, l'URL [localhost/lm](localhost/lm) devrait afficher la page d'accueil de Lizmap.

Il est également possible de tester si QGIS Server fonctionne via [http://127.0.0.1:8200/qgis_218](http://127.0.0.1:8200/qgis_218). Ce qui devrait renvoyer un fichier XML.

## Configuration de Lizmap ##

Dernière étape, configurer Lizmap pour qu'il puisse afficher les différents projets cartographiques.

Pour cela, se connecter dans Lizmap (admin/admin par défaut) et dans l'onglet `Configuration Lizmap`, modifier la version de QGIS Server de `≤ 2.14` vers `≥ 2.18`. Et remplacer l'URL du serveur WMS par `http://localhost:8200/qgis_218`.

Si à l'enregistrement des paramètres, `500 - internal server error` apparait, il faut refaire:
	
	cd /var/www/mylizmap/
	lizmap/install/set_rights.sh www-data www-data
	
Et si besoin, redémarrer `Nginx`.
