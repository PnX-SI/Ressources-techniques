#calcule le temps d'ouverture d'un fichier shape

#définit le chemin d'accès au fichier shape
path_to_gpkg="/Users/cendr/Desktop/Stage/QGIS/test gpkg/commune.shp"

from datetime import datetime
#récupère l'heure de démarrage du script
start_time = datetime.now()
#ajoute ma couche et donne lui le nom indiqué dans le second paramètre
iface.addVectorLayer(path_to_gpkg", "Communes", "ogr")
#récupère l'heure après avoir ajouté ma couche
end_time = datetime.now()
#affiche le temps d'ouverture du fichier en calculant la différence entre end-tim et start_time
print('Duration: {}'.format(end_time - start_time))

                

#calcule le temps ouverture d'un fichier gpkg qui contient 3 types de geometries (Ligne, Point, Polygone)
            
#définit le chemin d'accès au fichier gpkg
path_to_gpkg="/Users/cendr/Desktop/Stage/QGIS/test gpkg/synthese_faune_flore.gpkg"

#définit le chemin d'accès à ma couche avec une géométrie de type Point 
gpkg_layers = path_to_gpkg + "|layername=synthese|geometrytype=Point"
#définit ma couche vecteur et donne lui le nom indiqué dans le second paramètre
vlayer=QgsVectorLayer(gpkg_layers,"synthese","ogr")
#définit le chemin d'accès à ma couche avec une géométrie de type Ligne              
gpkg_layers1 = path_to_gpkg + "|layername=synthese|geometrytype=LineString"
vlayer1=QgsVectorLayer(gpkg_layers1,"synthese","ogr")
#définit le chemin d'accès à ma couche avec une géométrie de type Polygone 
gpkg_layers2 = path_to_gpkg + "|layername=synthese|geometrytype=Polygon"
vlayer2=QgsVectorLayer(gpkg_layers2,"synthese","ogr")
                     
from datetime import datetime
start_time = datetime.now()

#ajoute mes couches dans le projet 
QgsProject.instance().addMapLayer(vlayer)
QgsProject.instance().addMapLayer(vlayer1)
QgsProject.instance().addMapLayer(vlayer2)

end_time = datetime.now()
print('Duration: {}'.format(end_time - start_time))

                     
                     
#Version améliorée du code précédent

from datetime import datetime
start_time = datetime.now()

path_to_gpkg="/Users/cendr/Desktop/Stage/QGIS/test gpkg/synthese_faune_flore.gpkg"
geometry_type=["Point","LineString","Polygon"]
layername=["synthese"]
 
#fonction qui va ajouter touts mes couches définies dans la liste layername, ainsi que toutes les géométries liées, au projet.                   
def choix_geometry(layername,geometry_type):
    #pour chaque élément de la liste layername                 
    for f in layername :
        #pour chaque élément de la liste geometry_type         
        for i in geometry_type :
            #récupère le chemin complet de ma couche, qui comprend son type de géométrie         
            chemin_complet=path_to_gpkg + "|layername="+ f +"|geometrytype=" + i         
            vlayer=QgsVectorLayer(chemin_complet,"synthese","ogr")
            QgsProject.instance().addMapLayer(vlayer)
#execute ma fonction                    
choix_geometry(layername,geometry_type)

end_time = datetime.now()
print('Duration: {}'.format(end_time - start_time))
