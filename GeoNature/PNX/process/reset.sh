parc=$1

if [ -z "$parc" ]; then 
    exit 1
fi

# chargement de functions
BASE_DIR=$(readlink -e "${0%/*}")

. utils.sh

# init_config
init_config $parc


# remove db

# remove dem
rm -f $BASE_DIR/$parc/ref_geo/dem.sql