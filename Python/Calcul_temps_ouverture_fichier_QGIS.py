#calcul temps ouverture fichier shape
from datetime import datetime
start_time = datetime.now()
iface.addVectorLayer("/Users/cendr/Desktop/Stage/QGIS/test gpkg/commune.shp", "Communes", "ogr")
end_time = datetime.now()
print('Duration: {}'.format(end_time - start_time))


#calcul temps ouverture fichier gpkg qui contient des 3 types de geometries (Line, Point, Polygon)
#c'est pas du beau code mais ça fonctionne #bourin
from datetime import datetime
start_time = datetime.now()
path_to_gpkg="/Users/cendr/Desktop/Stage/QGIS/test gpkg/synthese_faune_flore.gpkg"
gpkg_layers = path_to_gpkg + "|layername=synthese|geometrytype=Point"
vlayer=QgsVectorLayer(gpkg_layers,"synthese","ogr")
gpkg_layers1 = path_to_gpkg + "|layername=synthese|geometrytype=LineString"
vlayer1=QgsVectorLayer(gpkg_layers1,"synthese","ogr")
gpkg_layers2 = path_to_gpkg + "|layername=synthese|geometrytype=Polygon"
vlayer2=QgsVectorLayer(gpkg_layers2,"synthese","ogr")

QgsProject.instance().addMapLayer(vlayer)
QgsProject.instance().addMapLayer(vlayer1)
QgsProject.instance().addMapLayer(vlayer2)
end_time = datetime.now()
print('Duration: {}'.format(end_time - start_time))
