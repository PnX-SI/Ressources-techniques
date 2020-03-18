#!/usr/bin/env python3
# -*- coding: utf-8 -*-
import fiona
import os
# Installation de Fiona sur Ubuntu : python3 -m pip install Fiona
def SHP2GPKG(repertoire):
    """
    Transfert le contenu des fichiers shapefiles d'un dossier
    et ses sous-dossiers en fichiers Geopackages
    """
    liste=os.listdir(repertoire) # Lister le contenu du repertoire
    for fichier in liste:
        if os.path.isdir(os.path.join(repertoire,fichier)): # Si on trouve un dossier
            SHP2GPKG(os.path.join(repertoire,fichier)) # Recursivité de la fonction
        elif os.path.isfile(os.path.join(repertoire,fichier)): # Si on trouve un fichier
                if fichier[-4:].lower()==".shp": # On cherche à savoir si le fichier est un shapefile
                    layername=fichier[:-4]
                    print(layername)
                    layerFinal=layername+".gpkg" # Creation du nouveau nom de fichier
                    with fiona.open(os.path.join(repertoire,fichier,encoding='utf-8')) as src: # Ouverture du shapefile
                        meta = src.meta
                        if meta['schema']['geometry'][:5]!="Multi" and meta['schema']['geometry'][:2]!="3D": # Si l'entité n'est pas multi... ni en 3D
                            meta['schema']['geometry']='Multi'+meta['schema']['geometry'] # On ajoute le multi au debut
                        elif meta['schema']['geometry'][:2]=="3D": # Si on est en 3D
                                meta['schema']['geometry']='Multi'+meta['schema']['geometry'][3:] # On remplace le 3D par Multi
                        meta['driver']='GPKG' # On prepare le futur fichier en Geopackage
                        with fiona.open(os.path.join(repertoire,layerFinal), 'w',encoding='utf-8', **meta) as dst: # Creation du fichier geopackage
                            for f in src:
                                if 'MultiPolygon' in(meta['schema']['geometry']): # Si on a une couche de polygones
                                    if str(f['geometry']['coordinates'])[:3]=='[[[': # Si l'entité est un multipolygone
                                        f['geometry'] = {
                                            'type': meta['schema']['geometry'], # On donne le bon type de geometrie
                                            'coordinates': f['geometry']['coordinates']} # On affecte les coordonnees
                                    else: # Si c'est un polygone normal ou troué
                                         f['geometry'] = {
                                            'type': meta['schema']['geometry'],
                                            'coordinates': [f['geometry']['coordinates']]} # On rajoute un niveau de [] correspondant au multi
                                    dst.write(f)
                                elif 'MultiLineString' in(meta['schema']['geometry']): # Si l'entité est une ligne
                                        if str(f['geometry']['coordinates'])[:2]=='[[': # Si c'est une multi-ligne
                                            f['geometry'] = {
                                                'type': meta['schema']['geometry'],
                                                'coordinates': f['geometry']['coordinates']}
                                        else:
                                            f['geometry'] = { # Si c'est une ligne normale
                                                'type': meta['schema']['geometry'],
                                                'coordinates': [f['geometry']['coordinates']]} # On rajoute un niveau de [] correspondant au multi
                                        dst.write(f)
                                elif str(f['geometry']['coordinates'])[:1]=='[': # Si c'est un multi-point
                                    f['geometry'] = {
                                        'type':meta['schema']['geometry'],
                                        'coordinates': f['geometry']['coordinates']}
                                else:
                                    f['geometry'] = { # Si c'est un point
                                        'type': meta['schema']['geometry'],
                                        'coordinates': [f['geometry']['coordinates']]} # On rajoute un niveau de [] correspondant au multi
                                dst.write(f)
                        
def shpKiller(repertoire):
    """
    Supprime l'ensemble des shapefiles et des autres fichiers le composant
    dans un dossier et ses sous-dossiers
    """
    liste=os.listdir(repertoire)
    for fichier in liste:
        if os.path.isdir(os.path.join(repertoire,fichier)):
            shpKiller(os.path.join(repertoire,fichier))
        else:
            if os.path.isfile(os.path.join(repertoire,fichier)):
                if fichier[-4:].lower() in (".shp",".dbf",".shx",".prj",".qpj",".cpg"): # Si on trouve une extension parmi les 6
                    os.remove(os.path.join(repertoire,fichier)) # On supprime le fichier
                    
# Execution des fonctions
SHP2GPKG('C:/Users/Raphael Bres/Desktop/Cours/STID/ESSIG/Rectorat/Commande_Carto/Savoie/general')
shpKiller('C:/Users/Raphael Bres/Desktop/Cours/STID/ESSIG/Rectorat/Commande_Carto/Savoie/general')
