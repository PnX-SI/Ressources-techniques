parc=$1
. settings.ini
set -g

ftp_parc=ftp_${parc}
ftp_access=${!ftp_parc}

dirout=out/gunicorn
rm -rf $dirout
mkdir -p $dirout

lftp "${ftp_access}" -e "
get geonature/backend/gunicorn_start.sh -o $dirout/gngs;
get usershub/gunicorn_start.sh -o $dirout/uhgs;
get taxhub/gunicorn_start.sh -o $dirout/thgs;
get atlas/gunicorn_start.sh -o $dirout/atgs;
bye
"