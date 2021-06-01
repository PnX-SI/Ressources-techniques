script=$1
prod=$2

. settings.ini

for parc  in $parcs
do

echo $script $parc $prod
$script $parc $prod
done