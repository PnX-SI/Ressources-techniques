script=$1

. settings.ini

for parc  in $parcs
do
$script $parc
done