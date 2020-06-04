Convertir avec libre office
===========================

Exemple ligne de commande pour convertir un fichier en csv avec les paramètres suivants :

  - Field separator : , -> (44), ; -> (59)
  - Text Delimiter : " -> (34)
  - Encoding : UTF-8 -> (76)
  - Number of First Line : 1

Plus de doc : 
https://wiki.openoffice.org/wiki/Documentation/DevGuide/Spreadsheets/Filter_Options#Token_7.2C_csv_import

.. code-block::

  libreoffice --headless --convert-to csv:"Text - txt - csv (StarCalc)":44,34,76,1,1 --outdir /tmp/csv_out *.xlsx

CSVKIT
======
https://csvkit.readthedocs.io

Librairie permettant de manipuler des fichiers csv

Avec notamment :
  - `in2csv <https://csvkit.readthedocs.io/en/latest/scripts/in2csv.html>`_ : conversion de fichier (excel) en csv
  - `csvsql <https://csvkit.readthedocs.io/en/latest/scripts/csvsql.html>`_ : manipulation des fichiers csv en mode sql :
  
      - selection
      - import en base de données
    
