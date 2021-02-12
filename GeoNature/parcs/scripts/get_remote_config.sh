parc=$1
. ftp.ini
set -x

ftp_parc=ftp_${parc}
ftp_access=${!ftp_parc}

rm -rf remote_config/${parc}
mkdir -p remote_config/${parc}

lftp "${ftp_access}" -e "
get geonature/config/settings.ini -o remote_config/${parc}/settings.ini;
get geonature/config/geonature_config.toml -o remote_config/${parc}/geonature_config.toml;

get atlas/atlas/configuration/settings.ini -o remote_config/${parc}/settings_atlas.ini;
get atlas/atlas/configuration/config.py -o remote_config/${parc}/config_atlas.py;

get geonature/backend/static/mobile/occtax/settings.json -o remote_config_/${parc}/settings_occtax.json;
get geonature/backend/static/mobile/sync/settings.json -o remote_config_/${parc}/settings_sync.json;

bye
"