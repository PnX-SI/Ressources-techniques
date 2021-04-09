parc=$1

# chargement de functions
. utils.sh

# init_config
init_config $parc

# install_db
install_db_all $parc

# migration

# etc ...