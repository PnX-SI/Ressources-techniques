### On importe dans la BDD GeoNature les référentiels géographiques es espaces naturels disponibles sur le site de l'INPN
### Ces tables sont stockés provisoirement dans un schéma spécifique et isolé (_ref_geo_inpn) 
### Elles serviront ensuite a peupler la table ref_geo.l_areas de Geonature

## Déclaration de variables --> à personnaliser :
TMPDIR="/home/`whoami`/_imports/inpn_ref_geo/tmp/"
DATADIR="/home/`whoami`/_imports/inpn_ref_geo"
DBSCHEMA="_imports_ref_geo"
HOST="localhost"
PORT="5432"
DB="geonature2db"
USER_NAME="geonatadmin"
USER_PG_PASS="monpassachanger"
LOG_PATH="_imports/inpn_ref_geo/log"
LOG_FILE="/home/`whoami`/_imports/inpn_ref_geo/log/shp2pgsql_inpn_ref_geo.log"
   
## Création des répertoires
mkdir $TMPDIR
mkdir $DATADIR
mkdir $LOG_PATH

## Création d'un fichier pour enregistrer les logs
touch $LOG_FILE

## Télécharger au préalable les fichiers Shapefile des référentiels géographiques à intégrer depuis le site de l'inpn :
#--> https://inpn.mnhn.fr/telechargement/cartes-et-information-geographique/
#--> Exemple ici avec toutes les couches pour la métropole
cd $DATADIR
wget https://inpn.mnhn.fr/docs/Shape/apb.zip &>> $LOG_FILE
wget https://inpn.mnhn.fr/docs/Shape/aspim.zip &>> $LOG_FILE
wget https://inpn.mnhn.fr/docs/Shape/pn.zip &>> $LOG_FILE
wget https://inpn.mnhn.fr/docs/Shape/pnm.zip &>> $LOG_FILE
wget https://inpn.mnhn.fr/docs/Shape/pnr.zip &>> $LOG_FILE
wget https://inpn.mnhn.fr/docs/Shape/rb.zip &>> $LOG_FILE
wget https://inpn.mnhn.fr/docs/Shape/bios.zip &>> $LOG_FILE
wget https://inpn.mnhn.fr/docs/Shape/ripn.zip &>> $LOG_FILE
wget https://inpn.mnhn.fr/docs/Shape/rnc.zip &>> $LOG_FILE
wget https://inpn.mnhn.fr/docs/Shape/rnn.zip &>> $LOG_FILE
wget https://inpn.mnhn.fr/docs/Shape/rncfs.zip &>> $LOG_FILE
wget https://inpn.mnhn.fr/docs/Shape/rnr.zip &>> $LOG_FILE
wget https://inpn.mnhn.fr/docs/Shape/cen.zip &>> $LOG_FILE
wget https://inpn.mnhn.fr/docs/Shape/cdl.zip &>> $LOG_FILE
wget https://inpn.mnhn.fr/docs/Shape/ramsar.zip &>> $LOG_FILE
wget https://inpn.mnhn.fr/docs/Shape/ospar.zip &>> $LOG_FILE
wget https://inpn.mnhn.fr/docs/Shape/znieff1.zip &>> $LOG_FILE
wget https://inpn.mnhn.fr/docs/Shape/znieff2.zip &>> $LOG_FILE
wget https://inpn.mnhn.fr/docs/Shape/znieff1_mer.zip &>> $LOG_FILE
wget https://inpn.mnhn.fr/docs/Shape/znieff2_mer.zip &>> $LOG_FILE 
wget https://inpn.mnhn.fr/docs/Shape/zico.zip &>> $LOG_FILE 
wget https://inpn.mnhn.fr/docs/Shape/sic.zip &>> $LOG_FILE 
wget https://inpn.mnhn.fr/docs/Shape/sic_ue.zip &>> $LOG_FILE 
wget https://inpn.mnhn.fr/docs/Shape/zps.zip &>> $LOG_FILE 
wget https://inpn.mnhn.fr/docs/Shape/L93_1K.zip &>> $LOG_FILE 
wget https://inpn.mnhn.fr/docs/Shape/L93_5K.zip &>> $LOG_FILE 
wget https://inpn.mnhn.fr/docs/Shape/L93_10K.zip &>> $LOG_FILE 

## Déplacer les fichiers .zip via FTP dans un répertoire du serveur GeoNature en utilisant l'utilisateur crée lors de l'installation (ici : geonatureadmin)
#--> Par exemple dans : /home/geonatureadmin/_imports/inpn_ref_geo
mkdir -p _imports/inpn_ref_geo &>> $LOG_FILE 
     
## Se placer dans le dossier et dézipper l'ensemble des fichiers en ligne de commannde avec unzip et une boucle sur l'ensemble des fichiers
cd $DATADIR
for z in *.zip; 
	do unzip -o -d $TMPDIR $z &>> $LOG_FILE;  
	done
   
# On rapatrie à l'aide d'une boucle tous les fichiers des sous-répertoires extraits précédemment à la racine de /tmp 
# --> /!\ Faute d'être parvenu à faire mieux (récursif dans les sous-sous-dossiers), lancer la commande suivante pour prendre en compte les archives qui contiennent des sous-dossiers
cd $TMPDIR
for z in */*.*; do mv $z $TMPDIR &>> $LOG_FILE; done
for y in */*/*.*; do mv $y $TMPDIR &>> $LOG_FILE; done

# On supprime les sous-dossiers vides désormais
find $TMPDIR -empty -type d -delete

## Créer un schéma pour acceuillir les données importées de types ref géo
sudo -n -u postgres -s psql -d geonature2db -c 'CREATE SCHEMA _imports_ref_geo AUTHORIZATION geonatadmin;' &>> $LOG_FILE
	
## Lancer la commande shp2pgsql dans une boucle pour importer les Shapefile dans le schéma transitoire _imports_ref_geo avec conversion des noms de fichiers en minuscules
for f in *.shp; 
	do for n in $(echo $f| cut -d'.' -f 1 | tr '[:upper:]' '[:lower:]'); 
		do export PGPASSWORD=$USER_PG_PASS; shp2pgsql -s 2154 -I $TMPDIR$f $DBSCHEMA.$n | psql -d $DB -h $HOST -p $PORT -U $USER_PG_NAME &>> $LOG_FILE; 
		done 
	done

## Nettoyage du dossier temporaire
## Si on veut aussi supprimer les ZIP téléchargés on remplace $TMPDIR par $DATADIR
rm -rf $TMPDIR
