parc=$1
. ftp.ini

for parc in $parcs
do 
echo recup config parc $parc
./get_remote_config.sh $parc
done