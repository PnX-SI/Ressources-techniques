parc=$1
base_url="https://gn${parc}.brgm-rec.fr"
api=geonature/api/gn_commons/modules
apis="
geonature/api/gn_commons/t_mobile_apps
usershub/login
atlas/
taxhub/ 
"

for api in $apis
do
url=${base_url}/${api}
res=$(curl -o /dev/null --silent --head --write-out '%{http_code}\n' ${url})   
if [ "$res" != "200" ]; then
echo $res $parc $api 
fi
done