. settings.ini
parc=$1

# dump md.user
mkdir -p dumps/$parc
dumpfile=dumps/$parc/obsocc_user.sql


echo 'DROP SCHEMA IF EXISTS md CASCADE; CREATE SCHEMA md;'> $dumpfile
pg_dump -d pn_$parc -n md -t md.personne -h localhost --no-owner --no-acl --column-inserts >> $dumpfile

# remove enum
sed -i \
-e "s/md.enum_.*/text,/" \
-e "s/CREATE INDEX.*//" \
-e "/CREATE TRIGGER/,+d" \
-e "/ALTER TABLE/,+2d" \
$dumpfile

## à executer dans pgadmin4
# update password

echo "
update utilisateurs.t_roles r set pass=a.mot_de_passe
FROM (select id_personne, mot_de_passe FROM md.personne)a 
WHERE a.id_personne = (r.champs_addi->'id_personne')::int;

" >> $dumpfile

## update password pour admin
pass_admin_name=pass_admin_${parc}
pass_admin=${!pass_admin_name}
pass_md5=$(echo ${pass_admin}| md5sum | sed -e 's/  -//')

echo "
UPDATE utilisateurs.t_role SET pass='$pass_md5' WHERE identifiant = 'admin';

" >> $dumpfile 

# ftp to /dumpfiles/md_user.sql
ftp_parc=ftp_${parc}
ftp_access=${!ftp_parc}
# lftp "${ftp_access}" -e "put -O dumpfiles/ $dumpfile; bye"




##

