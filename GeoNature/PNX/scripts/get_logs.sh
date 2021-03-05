parc=$1
. settings.ini
set -x

ftp_parc=ftp_${parc}
ftp_access=${!ftp_parc}

dir_log=out/log/${parc}

rm -rf $dir_log
mkdir -p $dir_log

lftp "${ftp_access}" -e "
get usershub/var/log/errors_uhv2.log -o ${dir_log}/;
get usershub/var/log/access_uhv2.log -o ${dir_log}/;

get taxhub/var/log/taxhub-errors.log -o ${dir_log}/;
get taxhub/var/log/taxhub-access.log -o ${dir_log}/;

get geonature/var/log/gn_errors.log -o ${dir_log}/;

get atlas/log/errors_atlas.log -o ${dir_log}/;

bye
"