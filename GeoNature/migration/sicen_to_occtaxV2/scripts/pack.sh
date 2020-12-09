. ./settings.ini
db_name=$1
db_gn_name=gn_${db_name}
pg_dump  -h ${db_host} -p ${db_port} -U ${user_pg} -Fc \
        -d ${db_gn_name} ${gn_dump_file} \
        > dumps/${db_gn_name}.dump


rm -Rf out/${db_name}*
mkdir -p out/${db_name}/GeoNature/backend
cp dumps/${db_gn_name}.dump out/${db_name}/.
cp -R media/out/medias_pn_${db_name}/static out/${db_name}/GeoNature/backend/. 
zip -r out/${db_name}.zip out/${db_name}