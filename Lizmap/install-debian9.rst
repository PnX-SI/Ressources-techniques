Adaptations de la documentation PnCalanques (Ubuntu 16) pour une installation sur Debian 9.

Attention l'installation dans la documentation PnCalanques est faite en sudo car l'appli est télécharger en ``sudo wget...``. Ce n'est pas le cas dans la documentation officielle et ce n'est pas conseillé car ``root`` sera propriétaire de tous les répertoires.

Installation des paquets nécessaires : 

::

  sudo apt-get install xauth htop curl apache2 libapache2-mod-fcgid libapache2-mod-php php-cgi php-gd php7.0-sqlite php-curl php-xmlrpc python-simplejson software-properties-common

Ajouter les sources pour QGIS server (voir https://www.qgis.org/fr/site/forusers/alldownloads.html#debian-ubuntu) : 

::

  wget -O - https://qgis.org/downloads/qgis-2017.gpg.key | gpg --import
  gpg --fingerprint CAEB3DC3BDF7FB45

  gpg --export --armor CAEB3DC3BDF7FB45 | sudo apt-key add -

  sudo apt-get install apt-transport-https

  sudo nano /etc/apt/sources.list.d/debian-gis.list

Collez ces lignes dans le fichier ``debian-gis.list`` :

::

  deb     https://qgis.org/debian stretch main
  deb-src https://qgis.org/debian stretch main

Probleme avec QGIS server, le WMS ne fonctionne pas. Voir https://issues.qgis.org/issues/18230

::

  nano /etc/apache2/sites-available/000-default.conf

Ajouter ces lignes (pas sur que toutes soient utiles) :

::

  # QGIS server
  FcgidInitialEnv QGIS_PREFIX_PATH "/usr"
  FcgidInitialEnv QGIS_DEBUG 1
  FcgidInitialEnv QGIS_SERVER_LOG_FILE /tmp/qgis-000.log
  FcgidInitialEnv QGIS_SERVER_LOG_LEVEL 0
  
Puis redémarrer Apache : 

::

  service apache2 stop
  service apache2 start
