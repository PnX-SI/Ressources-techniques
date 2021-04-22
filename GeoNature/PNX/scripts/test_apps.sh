parc=$1
base_url="https://gn${parc}.brgm-rec.fr"
api=geonature/api/gn_commons/modules
apis="
geonature/api/gn_commons/t_mobile_apps
usershub/login
atlas/
taxhub/api/taxref/?classe=&famille=&is_inbibtaxons=false&is_ref=false&limit=25&order=asc&orderby=nom_complet&ordre=&page=1&phylum=&regne=
"

test=''

for api in $apis
do
url=${base_url}/${api}
res=$(curl -o /dev/null --silent --head --write-out '%{http_code}\n' ${url})   
if [ "$res" != "200" ]; then
echo $res $parc $api 
test=1
fi

done
[ -z "$test" ] && echo $parc OK
