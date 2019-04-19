#!/bin/bash
#Parc national des Ecrins / April 2019

GEOTREK_HOME=$HOME
ARCHIVE_PREFIX=Geotrek-admin
ADMIN_PATH=$GEOTREK_HOME/Geotrek-admin
GIT_REPO=https://github.com/GeotrekCE/Geotrek-admin/archive
OLD_RELEASE=0.0.0
NEW_RELEASE=0.0.0

#---------------------------------
# Ls on the GEOTREK_HOME directory
# for user copy/paste
#---------------------------------
echo "ls $GEOTREK_HOME"
ls $GEOTREK_HOME

#--------------------------------
# Get old release path and number
#--------------------------------
while [ ! -e "$OLD_PATH" -o ! -n "$OLD_PATH" ]
do
   echo "Old release directory from $GEOTREK_HOME : "
   read OLD_PATH
   OLD_PATH=$GEOTREK_HOME/$OLD_PATH
done

OLD_RELEASE=`cat $OLD_PATH/VERSION`
OLD1=`echo $OLD_RELEASE | awk -F"." '{print $1}'`
OLD2=`echo $OLD_RELEASE | awk -F"." '{print $2}'`
OLD3=`echo $OLD_RELEASE | awk -F"." '{print $3}'`

#--------------------------------------------
# Ask if symlink exist, 
# if ok get the path to build it after update
#--------------------------------------------
echo "Is there a symlink on your GEOTREK admin instance ? [Y/n]"
read SYMLINK
if [ ! -n "$SYMLINK" -o "$SYMLINK" = "Y" -o "$SYMLINK" = "y" ]
then
   while [ ! -e "$SYMLINK_PATH" ]
   do
      echo "Symlink name in $GEOTREK_HOME :"
      read SYMLINK_PATH
      SYMLINK_PATH=$GEOTREK_HOME/$SYMLINK_PATH
   done
fi

#---------------------------------------
# Get the new release number, 
# it have to be greater than the old one
#---------------------------------------
NEW1=0
NEW2=0
NEW3=0
while [ ! -n "$NEW_RELEASE" -o "$OLD1" -gt "$NEW1" -o "$OLD2" -gt "$NEW2" -o "$OLD3" -gt "$NEW3" ]
do
   echo "Release num to upgrade to, have to be greater than $OLD_RELEASE :"
   read NEW_RELEASE
   NEW1=`echo $NEW_RELEASE | awk -F"." '{print $1}'`
   NEW2=`echo $NEW_RELEASE | awk -F"." '{print $2}'`
   NEW3=`echo $NEW_RELEASE | awk -F"." '{print $3}'`
done

#-----------------------------
# Download the release archive
#-----------------------------
cd $GEOTREK_HOME
wget $GIT_REPO/$NEW_RELEASE.tar.gz
if [ "$?" -ne "0" ]
then
   echo "The release number you gave doesn't exist"
   exit
fi

echo "Start to upgrade from $OLD_RELEASE to $NEW_RELEASE"
echo "--------------------------------------------------"
tar -zxvf $GEOTREK_HOME/$NEW_RELEASE.tar.gz
rm $GEOTREK_HOME/$NEW_RELEASE.tar.gz

#--------------------------------------------------------------
# Get num line of the old release info in the changelo.rst file 
# to display only first needed lines
#--------------------------------------------------------------
echo
echo "Here are the changelog :"
echo

NEW_PATH=$GEOTREK_HOME/$ARCHIVE_PREFIX-$NEW_RELEASE
NUM_LINE=`grep -n $OLD_RELEASE $NEW_PATH/docs/changelog.rst | awk -F":" '{print $1}'` 
NUM_LINE=`expr $NUM_LINE - 1`
head -$NUM_LINE $NEW_PATH/docs/changelog.rst

echo
echo "Are you agree to continue ? [Y/n]"
read REPLY

if [ -n "$REPLY" -a "$REPLY" != "Y" -a "$REPLY" != "y" ]
then
   rm -r $NEW_PATH
   "No ? Ok bye"
   exit
fi

#----------------
# Supervisor stop
#----------------
echo "Supervisor Stop"
echo
sudo supervisor stop all

#-------------------------
# Copy configuration files
#-------------------------
echo "Files copy"
echo

# Configuration files
cp -aRv $OLD_PATH/etc $NEW_PATH

# Uploaded files
cp -aRv $OLD_PATH/var $NEW_PATH

# Advanced settings, if exists
if [ -e $OLD_PATH/geotrek/settings/custom.py ]
then
   cp -av $OLD_PATH/geotrek/settings/custom.py $NEW_PATH/geotrek/settings/custom.py
fi

# Import parsers, if exists
if [ -e $OLD_PATH/bulkimport/parsers.py ]
then
   cp -av $OLD_PATH/bulkimport/parsers.py $NEW_PATH/bulkimport/parsers.py
fi

# Custom translations, if exists
if [ -e $OLD_PATH/geotrek/locale ]
then
   cp -aRv $OLD_PATH/geotrek/locale $NEW_PATH/geotrek/
fi

# Custom nginx configuration
cp -av $OLD_PATH/etc/nginx.d/*.conf $NEW_PATH/etc/nginx.d/

#---------------
# Run install.sh
#---------------
$NEW_PATH/install.sh

#-------------------
# Create the symlink
#-------------------
if [ -n $SYMLINK_PATH ]
then
   rm $SYMLINK_PATH
   ln -s $NEW_PATH $SYMLINK_PATH
fi

#------------
# Empty cache
#------------
echo "Empty cache"
sudo service memcached restart

#------------
# Restart
#------------
echo "Restart all process"
sudo supervisorctl restart all
