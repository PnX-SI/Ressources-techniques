#!/bin/bash

#params
db_name=samplesourcedb

#dump db

#schema public
pg_dump -O  -t public.bib_* -t 'public."TableWithCapitale"'  -t public.cor_* -t public.tbl_*  -t public.v_* -f /tmp/sample_public_schema.sql $db_name
#schema utilisateurs
pg_dump -O -n utilisateurs -f /tmp/sample_utilisateurs_schema.sql $db_name
#schema layers
pg_dump -O -n layers -f /tmp/sample_layers_schema.sql $db_name
#schema principal
pg_dump -O -n main -f /tmp/sample_main_schema.sql $db_name

#push sql to new databases server
scp -P 22 /tmp/sample_*.sql MYLINUXUSER@1.2.3.4:/tmp/
