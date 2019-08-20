Convertir un champs date en string et avec un format incomplet et en y ajoutant l'heure

- Input : 10/4/2018
- Output : 2018-10-04T14:00:00.000

::

  to_datetime(right( "Date" ,4) ||'-'|| right(('0'||left("Date",strpos( "Date",'/') -1)),2)||'-'|| right('0'|| left ( substr("Date", strpos( "Date",'/')+1,10), strpos(substr("Date", strpos( "Date",'/')+1,10),'/')-1),2)||' '|| totime("Time"))

Sinon faire une fonction Python dans le calculateur de champs (Basé sur https://gis.stackexchange.com/questions/217851/qgis-conversion-to-date-doesnt-work) : 

::

  from qgis.core import *
  from qgis.gui import *
  import datetime

  @qgsfunction(args='auto', group='Custom')
  def convertDateGPS(field, feature, parent):
      return datetime.datetime.strptime(field, "%M/%d/%Y").strftime("%Y-%M-%d")
