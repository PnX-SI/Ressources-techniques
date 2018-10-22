## This scritp was done with Parc national des Cevennes to update a Geotrek-admin

OLD_VERSION=2.18.2
NEW_VERSION=2.19.1

# Shutdown previous version
sudo supervisorctl stop all

# Rename old version
mv Geotrek-admin-2.18.2 Geotrek-$OLD_VERSION

# Download new version
wget https://github.com/GeotrekCE/Geotrek-admin/archive/$NEW_VERSION.zip
unzip $NEW_VERSION.zip

echo 'unzip finish'
mv Geotrek-admin-$NEW_VERSION Geotrek
cd Geotrek

# Configuration files
cp -aR ../Geotrek-$OLD_VERSION/etc/ .

# Uploaded files
cp -aR ../Geotrek-$OLD_VERSION/var/ .

# If you have advanced settings
cp ../Geotrek-$OLD_VERSION/geotrek/settings/custom.py geotrek/settings/custom.py

# If you have import parsers
cp ../Geotrek-$OLD_VERSION/bulkimport/parsers.py bulkimport/parsers.py

# Other optional customisation files
mkdir -p ./geotrek/locale/fr/LC_MESSAGES/
cp -aR ../Geotrek-$OLD_VERSION/geotrek/locale/fr/LC_MESSAGES/* ./geotrek/locale/fr/LC_MESSAGES/
cp ../Geotrek-$OLD_VERSION/geotrek/tourism/static/touristicevent.svg geotrek/tourism/static/

#cp -aR ../Geotrek-$OLD_VERSION/templates .

# Re-run install
./install.sh

# Empty cache
sudo service memcached restart
