#!/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin

cd /home/llepontois/python/lotek-data-sync/
source venv/bin/activate
python lotek2db.py
deactivate
