parc=$1

# chargement de functions
BASE_DIR=$(readlink -e "${0%/*}")

. utils.sh

# init_config
# init_config $parc

mkdir -p $BASE_DIR/$parc/var/log

# manage git
. $BASE_DIR/config/config.ini
manage_git $parc

# install_db
install_db_all $parc

[[ -f $BASE_DIR/$parc/migration.sh ]] && $BASE_DIR/$parc/migration.sh $parc


# ATLAS
# medias_taxref gua

up_schema_atlas $parc

set_admin_pass $parc

[[ -f $BASE_DIR/$parc/after_process.sh ]] && $BASE_DIR/$parc/after_process.sh $parc


$pgdumpa > ${parc}.dump

# export ftp
#. $BASE_DIR/../scripts/settings.ini
#ftp_parc=ftp_${parc}
#ftp_access=${!ftp_parc}
# lftp "${ftp_access}" -e "put $parc/$parc.dump -o dumpfiles/$parc.dump ;bye"
