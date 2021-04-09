parc=$1

# chargement de functions
BASE_DIR=$(readlink -e "${0%/*}")

. utils.sh

# init_config
init_config $parc

# install_db
install_db_all $parc

[[ -f $BASE_DIR/$parc/migration.sh ]] && $BASE_DIR/$parc/migration.sh $parc

# Atlas

# dump


# $pgdumpa > ${parc}.dump

# export ftp
#. $BASE_DIR/../scripts/settings.ini
#ftp_parc=ftp_${parc}
#ftp_access=${!ftp_parc}
# lftp "${ftp_access}" -e "put $parc/$parc.dump -o dumpfiles/$parc.dump ;bye"
