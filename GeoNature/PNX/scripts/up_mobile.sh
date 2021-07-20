# Script permettant de mettre à jour la configuration mobile sur les serveurs
#
# - Récupére des fichiers de version de code et des apk pour 
# le dépot gn_mobile_core (sync) et gn_mobile_occtax
#
# - Pousse les fichiers apk sur le serveur avec la commande lftp 
#
# - Créer la commande sql à éxécuter dans pgadmin4 (idéalement à automatiser avec psql)
#
# Entrées
# $1 : tag_sync (ex 1.1.9)
# $2 : tag_occtax (ex 1.2.4)
# $3 : nom du parc
# $4 : prod si non vide

## TODO debug ou non  pour l'instant en dur dans le code?????

# Initialisation des variables

tag_sync=$1
tag_occtax=$2
parc=$3
prod=$4

. settings.ini


# paramêtres de connexions ftp
ftp_parc=ftp_${parc}
if [ ! -z "$prod" ]; then ftp_parc=ftp_${parc}_prod; fi
ftp_access=${!ftp_parc}


# nom des fichiers etc..
dirmobile=out/mobile

sync_version_file=$dirmobile/sync_${tag_sync}.version
sync_apk_file=$dirmobile/sync-${tag_sync}-generic-debug.apk
remote_sync_apk_file=static/mobile/sync/sync-${tag_sync}-generic-debug.apk

occtax_version_file=$dirmobile/occtax_${tag_sync}.version
occtax_apk_file=$dirmobile/sync-${tag_occtax}-generic-debug.apk
remote_occtax_apk_file=static/mobile/occtax/occtax-${tag_occtax}-generic-debug.apk

sql_file=$dirmobile/script_sync_${tag_sync}_occtax_${tag_occtax}.sql



mkdir -p $dirmobile


# Version 

if [ ! -f "$sync_version_file" ]; then
    wget https://raw.githubusercontent.com/PnX-SI/gn_mobile_core/${tag_sync}/sync/version.properties -O "$sync_version_file"
fi

if [ ! -f "$occtax_version_file" ]; then
    wget https://raw.githubusercontent.com/PnX-SI/gn_mobile_occtax/${tag_occtax}/occtax/version.properties -O "$occtax_version_file"
fi

version_sync=$(cat $sync_version_file | grep 'VERSION_CODE=' | sed 's/VERSION_CODE=//')
version_occtax=$(cat $occtax_version_file | grep 'VERSION_CODE=' | sed 's/VERSION_CODE=//')

echo tag_sync $tag_sync version_sync $version_sync
echo tag_occtax $tag_occtax version_occtax $version_occtax


# apk

if [ ! -f "$sync_apk_file" ]; then
    wget https://github.com/PnX-SI/gn_mobile_core/releases/download/${tag_sync}/sync-${tag_sync}-generic-debug.apk \
        -O "$sync_apk_file"
fi

if [ ! -f "$occtax_apk_file" ]; then
    wget https://github.com/PnX-SI/gn_mobile_occtax/releases/download/${tag_occtax}/occtax-${tag_occtax}-generic-debug.apk \
        -O "$occtax_apk_file"
fi


# lftp put des fichiers apk sur le serveur

echo lftp "$ftp_access" -e "\"
    mkdir -p geonature/backend/static/mobile/sync;
    mkdir -p geonature/backend/static/mobile/occtax;
    put $sync_apk_file -o geonature/backend/${remote_sync_apk_file};
    put $occtax_apk_file -o geonature/backend/${remote_occtax_apk_file};
    bye;
\""


lftp "$ftp_access" -e "
    mkdir -p geonature/backend/static/mobile/sync;
    mkdir -p geonature/backend/static/mobile/occtax;
    put $sync_apk_file -o geonature/backend/${remote_sync_apk_file};
    put $occtax_apk_file -o geonature/backend/${remote_occtax_apk_file};
    bye;
"


# Création de la commande sql pour la jouer dans adminpg4

echo "-- script sql pour la mise à jour des applications mobiles
-- version sync : ${tag_sync}
-- version occtax : ${tag_occtax}

DELETE FROM gn_commons.t_mobile_apps;
INSERT INTO gn_commons.t_mobile_apps(
    id_mobile_app, app_code, relative_path_apk, url_apk, package, version_code
    )
VALUES
(2, 'SYNC', 'static/mobile/sync/sync-${tag_sync}-generic-debug.apk', '', 'fr.geonature.sync','${version_sync}'),
(1, 'OCCTAX', 'static/mobile/occtax/occtax-${tag_occtax}-generic-debug.apk', '', 'fr.geonature.occtax','${version_occtax}')
;"  > $sql_file

cat $sql_file
