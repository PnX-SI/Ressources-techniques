#This script is used to launch some import parsers (EPN or SIT), then data synchronization and then copy data from 
#Geotrek-admin server to Geotrek-rando server. It can be executed manually or automatically with a cron
#!/usr/bin/env bash

ADMIN_HOST=ip-geotrek-admin
RANDO_HOST=ip-geotrek-rando
ADMIN_DIR=/home/myuser/data/
RANDO_DIR=/home/myuser/data/
LOG_FILE=/home/myuser/sync_rando.log

date > $LOG_FILE
/home/myuser/Geotrek/bin/django import bulkimport.parsers.API_EspritParcParser 2>&1 | tee -a $LOG_FILE
/home/myuser/Geotrek/bin/django import bulkimport.parsers.PTL_EspritParcParser 2>&1 | tee -a $LOG_FILE
/home/myuser/Geotrek/bin/django import bulkimport.parsers.HEBMBT_EspritParcParser 2>&1 | tee -a $LOG_FILE
/home/myuser/Geotrek/bin/django sync_rando -v2 --url http://$ADMIN_HOST $ADMIN_DIR 2>&1 | tee -a $LOG_FILE
killall phantomjs 2>&1 | tee -a $LOG_FILE
rsync -azv --delete-after $ADMIN_DIR $RANDO_HOST:$RANDO_DIR 2>&1 | tee -a $LOG_FILE
ssh $RANDO_HOST "chmod -R a+rX $RANDO_DIR" 2>&1 | tee -a $LOG_FILE
echo "Done" >> $LOG_FILE
date >> $LOG_FILE

