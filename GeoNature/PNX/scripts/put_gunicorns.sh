parc=$1
. settings.ini
set -g

ftp_parc=ftp_${parc}
ftp_access=${!ftp_parc}

dirout=out/gunicorn

lftp "${ftp_access}" -e "
put $dirout/gngs -o geonature/backend/gunicorn_start.sh ;
put $dirout/uhgs -o usershub/gunicorn_start.sh;
put $dirout/thgs -o taxhub/gunicorn_start.sh;
put $dirout/atgs -o atlas/gunicorn_start.sh;

bye
"

