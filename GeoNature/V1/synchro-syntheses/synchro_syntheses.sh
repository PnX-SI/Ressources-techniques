echo '' >> log/synchro_syntheses.log
echo '__________________________' >> log/synchro_syntheses.log
echo $(date) >> log/synchro_syntheses.log
echo '__________________________' >> log/synchro_syntheses.log
sudo -n -u postgres -s psql -d geonaturedb -f 'synchro_syntheses.sql' >> log/synchro_syntheses.log
